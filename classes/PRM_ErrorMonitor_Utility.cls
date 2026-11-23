/****************************************************************************************************************************
Apex Class Name     : PRM_ErrorMonitor_Utility 
Version             : 1.0
Created Date        : Mar 2022

Modification Log    :
* Developer                  Description
* --------------------------------------------------------------------------------------------------------------------------
* Lata Dudam  
* Rohit Narnaware            To switch status of OPID Recommendation
****************************************************************************************************************************/
Public with sharing class PRM_ErrorMonitor_Utility {
    //TWC729-6800 EOL activities--Start
    Private static final string INTEGRATION_TYPE_FAILURE = 'OPID Inbound Failure';
    Private static final string INTEGRATION_TYPE_MISSING = 'OPID Not Received';
    Private static final string STATUS_FAILED = 'Failed';
    Private static final string STATUS_REP = 'Reprocessed';
    public static String CimPrimeEol=System.label.PRM_CIM_PRIME_Switch;// TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
    /*Public static void checkInboundRecord(List<PRM_Value_Exchange_Recommendation__c> scope){
        /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing //IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
        Map<Id,PRM_Value_Exchange_Recommendation__c> recExchangeMap = new Map<Id,PRM_Value_Exchange_Recommendation__c>();
        Map<Id,PRM_Value_Exchange_Recommendation__c> opidRecMap = new Map<Id,PRM_Value_Exchange_Recommendation__c>();
        Map<Id,Core_OnePartner_Inbound_Message__c> inboundMap = new Map<Id,Core_OnePartner_Inbound_Message__c>();
        List<Monitor_Log__c> errorRecords = new List<Monitor_Log__c>();
        String errorMsg = System.Label.Error_Logger;        
        String oldInbounds = System.Label.old_Inbound_found;
        
        
        //Checking scope and adding recRecord.PRM_Account_Id__c with VRX to the Map opidRecMap
        if(scope.size()>0){
            opidRecMap = getVXRecommendationMap(scope);
        }

        if(opidRecMap.size()>0){
            //Quering the Inbounds which having Core_SalesCloud_AccountID__c equals to OPID Rec PRM_Account_Id__c
            inboundMap = getinboundMsg(opidRecMap);

            for(PRM_Value_Exchange_Recommendation__c opidRec : opidRecMap.Values()){
                //Added by Rohit Narnaware
                //Agate-TWC729-4491: opidRec Recommendation record created/Outbound sent from SF but Inbound not received in SF 
                if(opidRec.PRM_Account_Id__c != NULL && !inboundMap.containskey(opidRec.PRM_Account_Id__c)
                   && opidRec.PRM_Recommendation_Status_Nm__c != label.PRM_Waiting_for_CIM_response)
                {
                    opidRec.PRM_Recommendation_Status_Nm__c = label.PRM_Waiting_for_CIM_response;
                    recExchangeMap.put(opidRec.Id, opidRec);
                    
                    Monitor_Log__c logError = createMonitorLogs(opidRec.Id,NULL, INTEGRATION_TYPE_MISSING,errorMsg,opidRec.PRM_Account_Id__c,STATUS_FAILED);
                    errorRecords.add(logError);
                }
                //Added by Rohit Narnaware
                //Agate-TWC729-4491: for old inbound swap status to Waiting for CIM Response
                //OPID Recommendation record created/Outbound sent from SF but Old Inbound present in the System or latest inbound it is discarded.
                else if(inboundMap.containsKey(opidRec.PRM_Account_Id__c) && inboundMap.get(opidRec.PRM_Account_Id__c).Core_SalesCloud_AccountID__c == opidRec.PRM_Account_Id__c){
                    if((inboundMap.get(opidRec.PRM_Account_Id__c).CreatedDate < opidRec.CreatedDate || 
                        (inboundMap.get(opidRec.PRM_Account_Id__c).CreatedDate >= opidRec.CreatedDate 
                            && inboundMap.get(opidRec.PRM_Account_Id__c).Core_Status__c == Label.PRM_INBOUNDMSG_DISCARDED)) 
                        && opidRec.PRM_Recommendation_Status_Nm__c != label.PRM_Waiting_for_CIM_response)
                    {
                        opidRec.PRM_Recommendation_Status_Nm__c = label.PRM_Waiting_for_CIM_response;
                        recExchangeMap.put(opidRec.Id, opidRec);
                        
                        Monitor_Log__c logError = createMonitorLogs(opidRec.Id,inboundMap.get(opidRec.PRM_Account_Id__c).Id, INTEGRATION_TYPE_FAILURE,inboundMap.get(opidRec.PRM_Account_Id__c).CreatedDate < opidRec.CreatedDate ? oldInbounds : Label.PRM_INBOUNDMSG_DISCARDED,opidRec.PRM_Account_Id__c,STATUS_FAILED);
                        errorRecords.add(logError);
                    }
                    //Added by Rohit Narnaware
                    //TWC729-4491: for discarded inbound swap status to Failed
                    //OPID Recommendation record created/Outbound sent from SF and inbound recieved with some error                          
                    else if(inboundMap.get(opidRec.PRM_Account_Id__c).CreatedDate >= opidRec.CreatedDate && 
                            (inboundMap.get(opidRec.PRM_Account_Id__c).Error_Description__c != NULL ||
                                inboundMap.get(opidRec.PRM_Account_Id__c).Core_Status__c  == Label.PRM_INBOUNDMSG_PROCESS_FAILED))
                    {
                        opidRec.PRM_Recommendation_Status_Nm__c = label.PRM_FailedLabel;
                        opidRec.Error_Description__c = inboundMap.get(opidRec.PRM_Account_Id__c).Error_Description__c;
                        recExchangeMap.put(opidRec.Id, opidRec);
                        
                        Monitor_Log__c logError =  createMonitorLogs(opidRec.Id,inboundMap.get(opidRec.PRM_Account_Id__c).Id, INTEGRATION_TYPE_FAILURE, inboundMap.get(opidRec.PRM_Account_Id__c).Error_Description__c, opidRec.PRM_Account_Id__c,STATUS_FAILED);
                        errorRecords.add(logError);
                    }
                    //Added by Rohit Narnaware
                    //TWC729-4491: If Inbound is created, OPID is Created and inbound Status change to PROCESSED
                    //then switch status to OPID Created
                    else if(inboundMap.get(opidRec.PRM_Account_Id__c).CreatedDate >= opidRec.CreatedDate && 
                            inboundMap.get(opidRec.PRM_Account_Id__c).Error_Description__c == NULL && 
                            inboundMap.get(opidRec.PRM_Account_Id__c).Core_Status__c == Label.PRM_INBOUNDMSG_PROCESSED)
                    {
                        opidRec.PRM_Recommendation_Status_Nm__c = label.PRM_VX_RecommendationStatus_OPIDCreated;
                        recExchangeMap.put(opidRec.Id, opidRec);
                    }
                }     
            }            
        }   
        if(recExchangeMap.size()>0){
            createTrackerRecords(recExchangeMap);
        }
        try{
            if(errorRecords.size()>0){
                insert errorRecords;
            }   
        }catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());            
        }}
    }*/
    /*public static void Map<Id, PRM_Value_Exchange_Recommendation__c> getVXRecommendationMap(List<PRM_Value_Exchange_Recommendation__c> scope) {
        /*Map<Id, PRM_Value_Exchange_Recommendation__c> opidRecMap = new Map<Id, PRM_Value_Exchange_Recommendation__c>();
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
        for (PRM_Value_Exchange_Recommendation__c recRecord : scope) {
            if (recRecord.PRM_Account_Id__c != null && !opidRecMap.containsKey(recRecord.PRM_Account_Id__c)) {
                opidRecMap.put(recRecord.PRM_Account_Id__c, recRecord);
            }
        }
        }
        return opidRecMap;
    }*/
    /*public static void Map<Id, Core_OnePartner_Inbound_Message__c> getinboundMsg(Map<Id, PRM_Value_Exchange_Recommendation__c> opidRecMap) {
        //Map<Id,Core_OnePartner_Inbound_Message__c> inboundMap = new Map<Id,Core_OnePartner_Inbound_Message__c>();
        /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
        List<Core_OnePartner_Inbound_Message__c> listOfInboundMsg = [SELECT
                                                            Id,
                                                            CreatedDate,
                                                            Core_Status__c,
                                                            Core_SalesCloud_AccountID__c,
                                                            Error_Description__c
                                                            FROM Core_OnePartner_Inbound_Message__c 
                                                            WHERE Core_SalesCloud_AccountID__c IN :opidRecMap.keyset()
                                                            AND Core_Effective_End_Date_Time__c = NULL
                                                            ORDER BY CreatedDate DESC];
        
        //Checking listOfInboundMsg and adding inboundMsg.Core_SalesCloud_AccountID__c with inbound to the inboundMap Map        
        if(listOfInboundMsg.size()>0){
            for(Core_OnePartner_Inbound_Message__c inboundMsg : listOfInboundMsg){
                if(inboundMsg.Core_SalesCloud_AccountID__c != null && !inboundMap.containsKey(inboundMsg.Core_SalesCloud_AccountID__c)){
                        inboundMap.put(inboundMsg.Core_SalesCloud_AccountID__c, inboundMsg);
                }                
            }
        }}
        return inboundMap;
    }*/
    /*public static void createTrackerRecords(Map<Id,PRM_Value_Exchange_Recommendation__c>recExchangeMap){
        /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
        List<PRM_Value_Exchange_Recommendation__c> opidRecListForTracker = new List<PRM_Value_Exchange_Recommendation__c>();  
        List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();     
        Set<Id> UpdatedOpidSet = new Set<Id>();
        try{
            Database.SaveResult[] srList =  Database.update(recExchangeMap.values(), false);
            for(Database.SaveResult sr : srList) {     
                if(sr.isSuccess()) {
                    UpdatedOpidSet.add(sr.getId());
                    opidRecListForTracker.add(recExchangeMap.get(sr.getId()));
                }
            }
           trackerList = getTrackerListtoInsert(opidRecListForTracker);
            
            if(!trackerList.isEmpty()){
                Database.SaveResult[] insertTracker = database.insert(trackerList, false);
                for (Database.SaveResult sr : insertTracker ) {
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            Core_Log_Entry.logEntryWithDetails('PRM_ErrorMonitor_Utility', 'IPA', 'Tracker record', 'exception', 'Exception occured while inserting PRM_Tracker__c', err.getMessage() , sr.getId(), 'PRM_Tracker__c', 'PRM_Tracker__c');
                        }
                    }
                }
            }            
        }catch(Exception ex){
            System.debug('Exception: ' + ex.getMessage());
        }}
    }*/
    /*public static void List<PRM_Tracker__c> getTrackerListtoInsert(List<PRM_Value_Exchange_Recommendation__c> opidRecListForTracker){
        //PRM_Tracker_steps__mdt waitingForCimResMdt = PRM_Tracker_steps__mdt.getInstance('WAIT_CIM_RES');
        //PRM_Tracker_steps__mdt opidCreatedMdt = PRM_Tracker_steps__mdt.getInstance('OPID_REQ_PROCESSED');
        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Tracker_steps__mdt');
        Map<String,Object> waitingForCimResMdt = customMetadata.getInstance('WAIT_CIM_RES');
        Map<String,Object> opidCreatedMdt = customMetadata.getInstance('OPID_REQ_PROCESSED');
        
        //List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();//
       /* if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
         if(!opidRecListForTracker.isEmpty()){
                for( PRM_Value_Exchange_Recommendation__c opidRec : opidRecListForTracker){
                    if(opidRec.PRM_Recommendation_Status_Nm__c == label.PRM_Waiting_for_CIM_response  && waitingForCimResMdt != null && !waitingForCimResMdt.isEmpty()){
                        //PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(waitingForCimResMdt.PRM_Type__c,waitingForCimResMdt.DeveloperName, opidRec.Id, null, null, null, null, true,null,null, null);    //
                        PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(String.valueOf(waitingForCimResMdt.get('PRM_Type__c')),String.valueOf(waitingForCimResMdt.get('DeveloperName')), opidRec.Id, null, null, null, null, true,null,null, null);    
                        trackerList.add(tracker);
                    }
                    else if(opidRec.PRM_Recommendation_Status_Nm__c == label.PRM_FailedLabel && opidCreatedMdt != null && !opidCreatedMdt.isEmpty()){
                        //PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(opidCreatedMdt.PRM_Type__c,opidCreatedMdt.DeveloperName, opidRec.Id, null, null, null, null, false,null,null, null);//
                        PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(String.valueOf(opidCreatedMdt.get('PRM_Type__c')),String.valueOf(opidCreatedMdt.get('DeveloperName')), opidRec.Id, null, null, null, null, false,null,null, null);    
                        trackerList.add(tracker);
                    }
                    else if(opidRec.PRM_Recommendation_Status_Nm__c == label.PRM_VX_RecommendationStatus_OPIDCreated && opidCreatedMdt != null ){
                        //PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(opidCreatedMdt.PRM_Type__c,opidCreatedMdt.DeveloperName, opidRec.Id, null, null, null, null, true,null,null, null);    //
                        PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(String.valueOf(opidCreatedMdt.get('PRM_Type__c')),String.valueOf(opidCreatedMdt.get('DeveloperName')), opidRec.Id, null, null, null, null, true,null,null, null);    
                        trackerList.add(tracker);
                    }
                }  
         }}
            return trackerList;
    }*/
    // Added by Rohit Narnaware
    // for Creating Monitor_Log__c records
    // Return Monitor_Log__c
    /*public static Monitor_Log__c createMonitorLogs(Id opidRecId, Id inboundmsgId, String integrationType, String errorMsg, Id accountId, String status){
        
        Monitor_Log__c logError = new Monitor_Log__c();
        /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
        logError.OPID_Recommendation__c = opidRecId;
        logError.One_Partner_Inbound_Message__c = inboundmsgId !=  null ? inboundmsgId : null;
        logError.Integration_Type__c = integrationType;
        logError.Error_Message__c = errorMsg;
        logError.Account_ID__c = accountId;
        logError.Status__c = status;
        }
        return logError;
        }*///TWC729-6800 EOL activities--End
}