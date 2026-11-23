/*********************************************************************************************************************
Apex Class Name  : PRM_UpdateOPIDRecommendation
Version       : 1.0
Created Date  : 4th June 2020
Function      : This class updates existing OPID Recommendation Records based on inputs from the batch.
  
Modification Log :
* Developer                          Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Pratik Sanganeria               04/06/2020              Class for updating existing OPID Recommendation Records
* Shraddha More                   25/11/2022              Added updateOpidRecommendationStatus method to update OPID recommendation with PRIM/CIM Internal Statuses
*********************************************************************************************************************/

public without sharing class PRM_UpdateOPIDRecommendation {
    
    public static String updateValueExchangeRecords(List<String> intelAccountIds, Map<id,Core_Account_Group_Member__c> cagsToUpsertMap)
    {

        //List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
        Map<id,PRM_Tracker__c>trackerMap = new Map<id,PRM_Tracker__c>(); //varun
        //System.debug('@@ INSIDE VALUE EXCHANGE METHOD !!');
        String logEntryMsg='';
        logEntryMsg+='\n***INSIDE VALUE EXCHANGE METHOD For Updating OPID Recommendations record status to Submitted for OPID !!***';
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
        List<String> listOfMilestoneToCheck = System.Label.PRM_cimStatusUpdates.split(';');
        Map<String, PRM_Tracker__c> listOfAvailableMilestone = new Map<String, PRM_Tracker__c>();
        Map<string,PRM_Tracker_steps__mdt> trackerMetaData = new Map<string,PRM_Tracker_steps__mdt>();
        String CimPrimeEol=System.label.PRM_CIM_PRIME_Switch;// TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
        /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
 
        for(PRM_Tracker_steps__mdt tm : PRM_Tracker_steps__mdt.getAll().values()){
            if(tm.PRM_Type__c == 'OPID Recommendation'){
                trackerMetaData.put(tm.DeveloperName, tm);
            }
        }}*/

        //TWC729-6800 EOL activities--Start
        /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
 
                    //Initializing tracker
            PRM_Tracker_steps__mdt opidCreatedMdt = PRM_Tracker_steps__mdt.getInstance('OPID_REQ_PROCESSED');
            List<PRM_Value_Exchange_Recommendation__c> listOpidRecommendation = new List<PRM_Value_Exchange_Recommendation__c>();
            for(PRM_Value_Exchange_Recommendation__c valueExchange : [SELECT 
                                                                    Id,
                                                                    CreatedDate,
                                                                    Error_Description__c,
                                                                    PRM_Account_Id__c,
                                                                    PRM_Recommendation_Type_Nm__c,
                                                                    PRM_Recommendation_Status_Nm__c,
                                                                    PRM_One_Partner_Id__c,
                                                                    (select  id, PRM_Type__c, PRM_Milestone__c, PRM_Milestone_Display_Name__c, PRM_Integration_Logs__c, PRM_Log_Entries__c, PRM_Completed__c, PRM_Integration_Outbound_Message__c, PRM_OPID_Recommendation__c, PRM_Location_Account__c, PRM_OPID__c, PRM_OPID_account_name__c, PRM_LOC_account_name__c, One_Partner_Inbound_Message__c
                                                                    From Tracker__r where PRM_Type__c = 'OPID Recommendation')
                                                                    FROM PRM_Value_Exchange_Recommendation__c
                                                                    WHERE PRM_Recommendation_Type_Nm__c =: Label.PRM_VX_RecommendationType_OPID
                                                                    AND RecordTypeId =: opidRecommendationRecordType 
                                                                    AND PRM_Account_Id__c IN :intelAccountIds])
            {
                //System.debug('@@ VALUE EXCHANGE : '+valueExchange);
                //if(valueExchange != null){
                    //if(valueExchange.Tracker__r != null){
                        for( PRM_Tracker__c  tr: valueExchange.Tracker__r){
                            listOfAvailableMilestone.put(tr.PRM_Milestone__c, tr);
                        }
                    //}
                    
                    if(!listOfMilestoneToCheck.isEmpty() && !listOfAvailableMilestone.isEmpty() && !trackerMetaData.isEmpty()){
                        for(String lmc : listOfMilestoneToCheck){
                            if(!listOfAvailableMilestone.containsKey(lmc)){
                                PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(null, trackerMetaData.get(lmc).PRM_Type__c, trackerMetaData.get(lmc).DeveloperName, valueExchange.Id, valueExchange.PRM_Account_Id__c, true, null, false);   
                                trackerMap.put(tracker.id,tracker); //varun
                            }
                            else if(listOfAvailableMilestone.containsKey(lmc) && listOfAvailableMilestone.get(lmc).PRM_Completed__c == false){
                                PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(listOfAvailableMilestone.get(lmc).Id, trackerMetaData.get(lmc).PRM_Type__c, trackerMetaData.get(lmc).DeveloperName, valueExchange.Id, valueExchange.PRM_Account_Id__c, true, null, true);  
                                trackerMap.put(tracker.id,tracker); //varun
                            }                 
                        }
                    }
                    
                    if(opidCreatedMdt != null){
                        PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(opidCreatedMdt.PRM_Type__c,opidCreatedMdt.DeveloperName, valueExchange.Id, null, null, null, null, true,null,null,null );    
                        trackerMap.put(tracker.id,tracker);
                    } 
                    valueExchange.PRM_Recommendation_Status_Nm__c = System.Label.PRM_VX_RecommendationStatus_OPIDCreated;
                    valueExchange.Error_Description__c = NULL;
                    if(!cagsToUpsertMap.keySet().isEmpty() && cagsToUpsertMap.keySet().contains(valueExchange.PRM_Account_Id__c)){
                        valueExchange.PRM_One_Partner_Id__c   = cagsToUpsertMap.get(valueExchange.PRM_Account_Id__c).Core_Partner_Account_Id__c ;
                        PRM_Tracker__c tracker=PRM_IPA_Utility.createTrackerInstance('OPID Updates 1PID',
                            'OPID_REQ',
                            valueExchange.Id,
                            null,
                            cagsToUpsertMap.get(valueExchange.PRM_Account_Id__c).Core_Partner_Account_Id__c,
                            cagsToUpsertMap.get(valueExchange.PRM_Account_Id__c).Core_Partner_Account_Id__c,
                            '',
                            '',
                            true,
                            '',
                            '',
                            PRM_Tracker_steps__mdt.getInstance('OPID_REQ').PRM_Milestone_Display_Name__c                                                
                            );  
                            trackerMap.put(tracker.id,tracker); //varun
                    }
                    listOpidRecommendation.add(valueExchange);
                //}
                }
                if(listOpidRecommendation.size() > 0){
                    //System.debug('@@ OPID RECOMMENDATION LIST : '+listOpidRecommendation);
                    Database.SaveResult [] updateResultList=null;
                    logEntryMsg+='\n****** UPDATE of OPID RECOMMENDATION LIST'+listOpidRecommendation+'******';
                    updateResultList = Database.update(listOpidRecommendation,false); 
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(listOpidRecommendation, updateResultList,'PRM_Value_Exchange_Recommendation__c');
            }
        }*/
        //TWC729-6800 EOL activities--End
        //Inserting tracker records
        if(!trackerMap.isEmpty()){
            Database.UpsertResult[] upsertTracker = database.upsert(trackerMap.values(), false); //varun
            for (Database.UpsertResult sr : upsertTracker ) {
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        Core_Log_Entry.logEntryWithDetails('PRM_ErrorMonitor_Utility', 'IPA','Tracker record', 'exception','Exception occured while inserting PRM_Tracker__c',err.getMessage() , sr.getId(), 'PRM_Tracker__c', 'PRM_Tracker__c');
                    }
                }
            }
        } 
        logEntryMsg+='\n***EXIT VALUE EXCHANGE METHOD***' ;
        return logEntryMsg;
    }
    
    
    /**
    * @Description: update OPID recommendation with PRIM/CIM Internal Statuses
    * @return : String logEntryMessage
    * @US : TWC729-4773 & TWC729-4820
    * @shraddha M
    */
    //TWC729-6800 EOL activities--Start
    public static string updateOpidRecommendationStatus(Map<String,Core_OnePartner_Inbound_Message__c> mapOfInboundMsg){
        String logEntryMessage='';
        List<PRM_Tracker__c> trackerListToUpsert = new List<PRM_Tracker__c>();
        Map<id,PRM_Tracker__c>trackerMap = new Map<id,PRM_Tracker__c>(); //varun
        //List<PRM_Value_Exchange_Recommendation__c> recmmToUpsert = new List<PRM_Value_Exchange_Recommendation__c>();
        Map<Id,PRM_Value_Exchange_Recommendation__c> recmmToUpsertMap = new Map<Id,PRM_Value_Exchange_Recommendation__c>();
        //Map<Id,String> mapOftrackertoCheck = new Map<Id,String>();
        //Map<Id,String> mapRecmmAccPrty = new Map<Id,String>();
        Map<id, Decimal> mapOfAccHighestPriority = new Map<id, Decimal>();
        Map<id, Core_OnePartner_Inbound_Message__c> mapOfAccHighestPriorityList = new Map<id, Core_OnePartner_Inbound_Message__c>();        
        Map<id, set<string>> mapAllApplicableStatus = new Map<id, Set<String>>();
        Map<id, set<string>> mapAccTrckMlstnAvlbl = new Map<id, Set<String>>();
        Map<string, PRM_Tracker__c> mapAccTrckMlstnAvlblList = new Map<string, PRM_Tracker__c>();
        List<PRM_Value_Exchange_Recommendation__c> trackerlistRecmm = new List<PRM_Value_Exchange_Recommendation__c>();
        List<Core_OnePartner_Inbound_Message__c> listOfInboundMsgToUpdate = new List<Core_OnePartner_Inbound_Message__c>();
        Map<String, Decimal> mapOfStatusPriority = new Map<String, Decimal>{'OPID In Process' => 2.0,
            'Waiting for CIM response' => 4.0,
            'CRE_PRIM_HIER_NEW' => 5.0,
            'CRE_PRIM_HIER_WIP' => 6.0,
            'CRE_PRIM_HIER_COMPLETED'=> 7.0,
            'CRE_PRIM_HIER_FAILED' => 6.5,
            'CRE_CUST_AGRGT_HIER_WIP' => 8.0,
            'CRE_CUST_AGRGT_HIER_FAILED' =>7.5,
            'OPID Created'=>9.0
            };
        Map<string,PRM_Tracker_steps__mdt> trackerMetaData = new Map<string,PRM_Tracker_steps__mdt>();
        for(PRM_Tracker_steps__mdt tm : PRM_Tracker_steps__mdt.getAll().values()){
            if(tm.PRM_Type__c == 'OPID Recommendation'){
                trackerMetaData.put(tm.DeveloperName, tm);
            }
        }
        //System.debug('mapOfInboundMsg*********'+mapOfInboundMsg);
        //Integer highestValue = 0 ;
        //PRM_Value_Exchange_Recommendation__c valueExchange = new PRM_Value_Exchange_Recommendation__c ();
        //Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
        try{
            logEntryMessage+='\n***INSIDE VALUE EXCHANGE METHOD For Updating OPID Recommendations record status based on CIM responses !!***';
            if(!mapOfInboundMsg.isEmpty()){
                // The below map will have the highest priority status corresponding to each Account
                for(Core_OnePartner_Inbound_Message__c inBoundMsg : mapOfInboundMsg.values()){
                    string Core_Request_Status_Cd;
                    if(inBoundMsg.Core_Request_Status_Cd__c == 'IGNORED' || inBoundMsg.Core_Request_Status_Cd__c == 'FAILED' ){
                        Core_Request_Status_Cd = 'WIP';
                    }else {
                        Core_Request_Status_Cd = inBoundMsg.Core_Request_Status_Cd__c;
                    }
                    
                    if(trackerMetaData.containsKey(inBoundMsg.Core_Request_Purpose_Cd__c+'_'+Core_Request_Status_Cd)){
                        if(mapOfAccHighestPriority.keyset().contains(inBoundMsg.Core_SalesCloud_AccountID__c)){
                            Decimal OldhighestPriority = mapOfAccHighestPriority.get(inBoundMsg.Core_SalesCloud_AccountID__c);
                            if(trackerMetaData.get(inBoundMsg.Core_Request_Purpose_Cd__c+'_'+Core_Request_Status_Cd).PRM_Order__c  > OldhighestPriority ){
                                mapOfAccHighestPriority.put(inBoundMsg.Core_SalesCloud_AccountID__c,trackerMetaData.get(inBoundMsg.Core_Request_Purpose_Cd__c+'_'+Core_Request_Status_Cd).PRM_Order__c) ;
                                mapOfAccHighestPriorityList.put(inBoundMsg.Core_SalesCloud_AccountID__c,inBoundMsg);
                            }
                        }
                        else{                
                            mapOfAccHighestPriority.put(inBoundMsg.Core_SalesCloud_AccountID__c,trackerMetaData.get(inBoundMsg.Core_Request_Purpose_Cd__c+'_'+Core_Request_Status_Cd).PRM_Order__c );
                            mapOfAccHighestPriorityList.put(inBoundMsg.Core_SalesCloud_AccountID__c,inBoundMsg);
                        }  
                    }
                    inBoundMsg.Core_Status__c = 'PROCESSED';
                    listOfInboundMsgToUpdate.add(inBoundMsg);
                }
                //System.debug('mapOfAccHighestPriority*********'+mapOfAccHighestPriority);
                //System.debug('mapOfAccHighestPriorityList*********'+mapOfAccHighestPriorityList);
                
                // This map will contain all the required previous status applicable for the current highest priority status
                if(!mapOfAccHighestPriority.isEmpty() && !trackerMetaData.isEmpty()){
                    for(id accId : mapOfAccHighestPriority.keyset() ){
                        Set<string> applicableStatus= new set<String>();
                        for(PRM_Tracker_steps__mdt trackerRecords :trackerMetaData.values()){
                            if(trackerRecords.PRM_Order__c <=  (mapOfAccHighestPriority.get(accId)) && trackerRecords.PRM_Order__c >= 5){
                                applicableStatus.add(trackerRecords.DeveloperName);
                            }
                        }
                        if(!applicableStatus.isEmpty()){
                            mapAllApplicableStatus.put(accId,applicableStatus);
                        }                  
                    }
                }
                //System.debug('mapAllApplicableStatus*********'+mapAllApplicableStatus);
                //System.debug('trackerMetaData*********'+trackerMetaData);

                // To check the latest status in Tracker object 
                if(!mapOfAccHighestPriority.isEmpty()){
                    trackerlistRecmm = [select id,name,PRM_Account_Id__c, PRM_Grouping_Method_Nm__c, RecordTypeId, RecordType.name, PRM_Account_Id__r.name, PRM_Recommendation_Status_Nm__c, PRM_One_Partner_Id__c ,
                                        (select  id, PRM_Type__c, PRM_Milestone__c, PRM_Milestone_Display_Name__c, PRM_Integration_Logs__c, PRM_Log_Entries__c, PRM_Completed__c, PRM_Integration_Outbound_Message__c, PRM_OPID_Recommendation__c, PRM_Location_Account__c, PRM_OPID__c, PRM_OPID_account_name__c, PRM_LOC_account_name__c, One_Partner_Inbound_Message__c
                                         From Tracker__r where PRM_Type__c = 'OPID Recommendation' and PRM_Location_Account__c in : mapOfAccHighestPriority.keyset() )
                                        from PRM_Value_Exchange_Recommendation__c where RecordType.Name = 'OPID Recommendation' and PRM_Account_Id__c IN: mapOfAccHighestPriority.keyset()
                                       ];   
                }
                //System.debug('trackerlistRecmm*********'+trackerlistRecmm);
                // This will generate a map  with all available status in for an account in tracker object
                if(trackerlistRecmm.size()>0){
                    for( PRM_Value_Exchange_Recommendation__c recmmList  : trackerlistRecmm){
                        for( PRM_Tracker__c  trackerRecordsList: recmmList.Tracker__r){
                            if(mapAccTrckMlstnAvlbl.keyset().contains(trackerRecordsList.PRM_Location_Account__c)){
                                set<string> setOfTracks = mapAccTrckMlstnAvlbl.get(trackerRecordsList.PRM_Location_Account__c);
                                setOfTracks.add(trackerRecordsList.PRM_Milestone__c);
                                mapAccTrckMlstnAvlbl.put(trackerRecordsList.PRM_Location_Account__c, setOfTracks);
                            }
                            else{
                                mapAccTrckMlstnAvlbl.put(trackerRecordsList.PRM_Location_Account__c,new set<string>{trackerRecordsList.PRM_Milestone__c}) ;
                            }  
                            // Map of Account and tracker list
                            if(!mapAccTrckMlstnAvlblList.containskey(trackerRecordsList.PRM_Location_Account__c+'_'+trackerRecordsList.PRM_Milestone__c )){
                                mapAccTrckMlstnAvlblList.put(trackerRecordsList.PRM_Location_Account__c+'_'+trackerRecordsList.PRM_Milestone__c,trackerRecordsList);
                            }
                        }
                    }
                }
                //System.debug('mapAccTrckMlstnAvlblList*********'+mapAccTrckMlstnAvlblList);
                // Updation of tracker records happen in this loop
                PRM_Tracker__c tracker ;
                String milestonerec;
                Boolean isCompleted;
                if(trackerlistRecmm.size()>0){
                    for( PRM_Value_Exchange_Recommendation__c recmmList  : trackerlistRecmm){
                        if(mapAllApplicableStatus.size()>0 && mapAllApplicableStatus.containsKey(recmmList.PRM_Account_Id__c)){
                            for(string applcbleMileStone: mapAllApplicableStatus.get(recmmList.PRM_Account_Id__c) ){
                                if(mapAccTrckMlstnAvlbl.size()>0 && mapAccTrckMlstnAvlbl.get(recmmList.PRM_Account_Id__c).contains(applcbleMileStone) ){
                                    // Checking if tracker priority matches with highest one.check if status of highest prioty is failed or ignored. if yes, check if the tracker with is having true value, if yes, then make it false.
                                    if(trackerMetaData.size()>0 && mapOfAccHighestPriority.size()>0 && mapOfAccHighestPriorityList.size()>0 && mapAccTrckMlstnAvlblList.size()>0
                                       && trackerMetaData.get(applcbleMileStone).PRM_Order__c == mapOfAccHighestPriority.get(recmmList.PRM_Account_Id__c)  
                                       && (mapOfAccHighestPriorityList.get(recmmList.PRM_Account_Id__c).Core_Request_Status_Cd__c == 'FAILED' || mapOfAccHighestPriorityList.get(recmmList.PRM_Account_Id__c).Core_Request_Status_Cd__c == 'IGNORED' )
                                       &&  (mapAccTrckMlstnAvlblList.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).PRM_Completed__c == true)
                                      ){
                                        if(mapAccTrckMlstnAvlblList.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).One_Partner_Inbound_Message__c != null){
                                            milestonerec = mapAccTrckMlstnAvlblList.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).One_Partner_Inbound_Message__c;
                                        }else{
                                            milestonerec = mapOfInboundMsg.containskey(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone) ? mapOfInboundMsg.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).Id : null;
                                        }                                        
                                        isCompleted = true;  // update tracker with false value
                                        tracker  = PRM_IPA_Utility.createTrackerInstance(mapAccTrckMlstnAvlblList.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).id, trackerMetaData.get(applcbleMileStone).PRM_Type__c, trackerMetaData.get(applcbleMileStone).DeveloperName, recmmList.Id, recmmList.PRM_Account_Id__c, isCompleted ,milestonerec, true); 
                                        trackerListToUpsert.add(tracker); 
                                       trackerMap.put(tracker.id,tracker);
                                      }else if(mapAccTrckMlstnAvlblList.size()>0 && (mapAccTrckMlstnAvlblList.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).PRM_Completed__c == false || mapAccTrckMlstnAvlblList.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).One_Partner_Inbound_Message__c == null)){
                                        isCompleted = true;    // update tracker with true value   
                                        milestonerec = mapOfInboundMsg.containskey(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone) ? mapOfInboundMsg.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).Id : null;
                                        tracker  = PRM_IPA_Utility.createTrackerInstance(mapAccTrckMlstnAvlblList.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).id, trackerMetaData.get(applcbleMileStone).PRM_Type__c, trackerMetaData.get(applcbleMileStone).DeveloperName, recmmList.Id, recmmList.PRM_Account_Id__c, isCompleted ,milestonerec, true); 
                                        trackerListToUpsert.add(tracker);
                                        trackerMap.put(tracker.id,tracker);
                                      }
                                }
                                else{
                                    isCompleted = (trackerMetaData.get(applcbleMileStone).PRM_Order__c == mapOfAccHighestPriority.get(recmmList.PRM_Account_Id__c) && ( mapOfAccHighestPriorityList.get(recmmList.PRM_Account_Id__c).Core_Request_Status_Cd__c == 'FAILED' || mapOfAccHighestPriorityList.get(recmmList.PRM_Account_Id__c).Core_Request_Status_Cd__c == 'IGNORED') ) ? false : true;
                                    milestonerec = mapOfInboundMsg.containskey(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone) ? mapOfInboundMsg.get(recmmList.PRM_Account_Id__c+'_'+applcbleMileStone).Id : null;
                                    tracker  = PRM_IPA_Utility.createTrackerInstance(null, trackerMetaData.get(applcbleMileStone).PRM_Type__c, trackerMetaData.get(applcbleMileStone).DeveloperName, recmmList.Id, recmmList.PRM_Account_Id__c, isCompleted, milestonerec, false); 
                                    trackerListToUpsert.add(tracker);
                                    trackerMap.put(tracker.id,tracker);
                                }
                            }
                        }  
                        // This loop will check recommendation status.
                        if(mapOfStatusPriority.size()>0 && mapOfAccHighestPriorityList.size()>0 && mapOfStatusPriority.get(recmmList.PRM_Recommendation_Status_Nm__c) != null &&  mapOfAccHighestPriority.get(recmmList.PRM_Account_Id__c)  >= mapOfStatusPriority.get(recmmList.PRM_Recommendation_Status_Nm__c)){    
                            recmmList.PRM_Recommendation_Status_Nm__c = mapOfAccHighestPriorityList.get(recmmList.PRM_Account_Id__c).Core_Request_Purpose_Cd__c+'_'+mapOfAccHighestPriorityList.get(recmmList.PRM_Account_Id__c).Core_Request_Status_Cd__c;
                        }
                        recmmToUpsertMap.put(recmmList.PRM_Account_Id__c,recmmList);                
                    }
                }               
                
                //Upsert tracker records
               if(trackerListToUpsert.size() > 0){
               // if(!trackerMap.isEmpty()){
                    //System.debug('@@ TRACKER UPSERT LIST : '+trackerListToUpsert);
                    //System.debug('@@ TRACKER UPSERT LIST : '+trackerMap);
                    Database.UpsertResult [] upsertTrackerList=null;
                    logEntryMessage+='\n****** UPSERT of TRACKER LIST'+trackerMap+'******';
                    upsertTrackerList = Database.upsert(trackerListToUpsert,false); 
                } 
                
                //update Opid Recommendation records
                if(!recmmToUpsertMap.IsEmpty()){
                    //System.debug('@@ OPID RECOMMENDATION LIST : '+recmmToUpsertMap);
                    Database.SaveResult [] updateRecommendationList=null;
                    logEntryMessage+='\n****** UPDATE of OPID RECOMMENDATION LIST'+recmmToUpsertMap+'******';
                    updateRecommendationList = Database.update(recmmToUpsertMap.values(),false); 
                }
                
                //updating inbound message status after processing
                if(listOfInboundMsgToUpdate.size() > 0){
                    //System.debug('@@ INBOUND MESSAGE LIST : '+listOfInboundMsgToUpdate);
                    Database.SaveResult [] updateInboundtList=null;
                    logEntryMessage+='\n****** UPDATE of INBOUND MESSAGE LIST'+listOfInboundMsgToUpdate+'******';
                    updateInboundtList = Database.update(listOfInboundMsgToUpdate,false); 
                } 
            }
            
        }
        catch(exception ex){
            //System.debug('Exception occured!!');
            logEntryMessage+= '\n***Exception occured****'+ ex;
        }
        logEntryMessage+='\n***EXIT OPID RECOMMENDATION STATUS UPDATE METHOD***' ;
        return logEntryMessage;
    } //TWC729-6800 EOL activities-END
}