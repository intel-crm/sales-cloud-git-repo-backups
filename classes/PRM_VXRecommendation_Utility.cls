/****************************************************************************************************************************
Apex Class Name     : PRM_VXRecommendation_Utility 
Version             : 1.0
Created Date        : Mar 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Srishty Sharma        18-Mar-2020                 Added a new method vxRecommnedationUpdateCheck to restrict update on vsRecommendation
records without specifying grouping method

****************************************************************************************************************************/
public without sharing class PRM_VXRecommendation_Utility {
    public static Id opidRecordTypeId =Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByDeveloperName().get('PRM_OPID_Recommendation').getRecordTypeId();
    public static final string SYM_COL= ',' ;
    public static boolean firstRun = false;
    
    public static final String LOG_ENTRY_ORIGIN = 'opidOutboundMssg';
    public static final String LOG_ENTRY_PROJECT = 'opidOutboundMssg';
    public static final String LOG_ENTRY_SCOPE = 'PRM_VXRecommendation_Utility';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static String CimPrimeEol=System.label.PRM_CIM_PRIME_Switch;// TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
    public static String logEntryMsg='';
    //Method will check the condition for validation on vx recommendation record while updting and display error if Grouping Method is null. 
    //TWC729-6800 EOL activities--Start
    public static void vxRecommnedationUpdateCheck(List<PRM_Value_Exchange_Recommendation__c> vxRecommendationList, Id recordTypeOPID)
    {
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
        for(PRM_Value_Exchange_Recommendation__c vsRecommendation: vxRecommendationList){
            if((vsRecommendation.PRM_Grouping_Method_Nm__c =='' || vsRecommendation.PRM_Grouping_Method_Nm__c==null) && vsRecommendation.RecordTypeId==recordTypeOPID ){
                vsRecommendation.addError(System.Label.PRM_VXRecommendation_ValidationError);
            }
        }
        } }//TWC729-6800 EOL activities--End
    
    /* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala        18-Mar-2020                 Added a new method duplicateRecommendationcheck to restrict insert and update on vsRecommendation
records if a duplicate record already exists or if the account already have OPID

****************************************************************************************************************************/
    //TWC729-6800 EOL activities--Start
    public static void duplicateRecommendationcheck(List<PRM_Value_Exchange_Recommendation__c> vxRecommendationList, Map<Id,PRM_Value_Exchange_Recommendation__c> oldMap, Id recordTypeOPID){
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
        list<PRM_Value_Exchange_Recommendation__c> vxRecommendationNewList = new list<PRM_Value_Exchange_Recommendation__c>();
        Map<String,string> uniqueMap = new Map<String,string>();
        set<string> accountIDSet = new set<string>();
        set<string> opidaccountIDSet = new set<string>();
        Set<String> duplicateSet = new Set<String>();
        for(PRM_Value_Exchange_Recommendation__c vxr: vxRecommendationList){
            PRM_Value_Exchange_Recommendation__c vxrOld; 
            if(oldMap!=null && oldMap.size()>0){ vxrOld = (PRM_Value_Exchange_Recommendation__c) oldMap.get(vxr.id) ;}
            if(((oldMap==null)&&(vxr.RecordTypeId==recordTypeOPID)) || ((oldMap!=null && oldMap.size()>0)&&(vxrOld.PRM_Account_Id__c != vxr.PRM_Account_Id__c)&&(vxr.RecordTypeId==recordTypeOPID)))
            { 
                vxRecommendationNewList.add(vxr);
                accountIDSet.add(vxr.PRM_Account_Id__c);
                uniqueMap.put(vxr.PRM_Account_Id__c+''+vxr.RecordTypeId,vxr.PRM_Account_Id__c); 
            }
        }
        if(accountIDSet!= null &&accountIDSet.size()>0 ){
            for(Core_Account_Group_Member__c opid :[select id,Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c IN:accountIDSet AND Core_Inactive_Ind__c=False]){
                opidaccountIDSet.add(opid.Core_Intel_Account_Id__c);
            }
            for(PRM_Value_Exchange_Recommendation__c vxr:[select id,PRM_Account_Id__c,RecordTypeId from PRM_Value_Exchange_Recommendation__c where PRM_Account_Id__c IN:accountIDSet and RecordTypeId=:recordTypeOPID and PRM_Recommendation_Status_Nm__c != 'OPID Created']){
                if(vxr.PRM_Account_Id__c==uniqueMap.get(vxr.PRM_Account_Id__c+''+vxr.RecordTypeId)){
                    duplicateSet.add(vxr.PRM_Account_Id__c);
                }   
            }
            if((opidaccountIDSet!= null &&opidaccountIDSet.size()>0)||(duplicateSet != null && duplicateSet.size()>0)){
                for(PRM_Value_Exchange_Recommendation__c vxr: vxRecommendationList){
                    if(opidaccountIDSet.contains(vxr.PRM_Account_Id__c)){
                        vxr.addError(System.Label.PRM_VXRecommendation_ValidationError1);
                    }
                    if(duplicateSet.contains(vxr.PRM_Account_Id__c)){
                        vxr.addError(System.Label.PRM_VXRecommendation_ValidationError2);
                    }
                }
            }
        }
    }}//TWC729-6800 EOL activities--End
    
    /*****************************************************************************************************************************************************************
* author:      Utkarsh/Vijay   
* Date:        12/5/2020
* Parameters:  List<PRM_Value_Exchange_Recommendation__c> opidInputList, Map<Id,PRM_Value_Exchange_Recommendation__c> oldMap
* Description: This is the method used to update the ACM Tier to Eligibility Tier of VxRecemendation when the Status of OPID record is updated to 'In Process'.
* User Story : US632855
*************************************************************************************************************************************************************** */
   //TWC729-6800 EOL activities--Start
    public Static  void updateOrCreateACM(List<PRM_Value_Exchange_Recommendation__c> opidInputList, Map<Id,PRM_Value_Exchange_Recommendation__c> oldMap){
        List<Id> opidAccountList = new List<Id>();
        //Map<Id,Id> accntTierMap = new Map<Id,Id>();
        Map<Id,String> mapOPIDPartnerrole = new Map<Id,String>();
        PRM_Value_Exchange_Recommendation__c opidOld ;
        Map<Id,PRM_AccountChannelMembership__c> mapAccountIdACM = new Map<Id,PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> upsertACMList = new List<PRM_AccountChannelMembership__c>();
        boolean vxRecordtoProcess = false;
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
        // Fetching the old VxRecemendations records and checking the Status, If the Status is 'In Process', storing in a Map 
        if(opidInputList != null && !opidInputList.IsEmpty()){
            for(PRM_Value_Exchange_Recommendation__c vxRec : [Select Id,PRM_Account_Id__c,PRM_One_Partner_Id__c, PRM_Partner_Role_Nm__c, PRM_Tier_Id__c,PRM_Eligibility_Tier__c,PRM_Eligibility_Tier__r.Name,PRM_Recommendation_Status_Nm__c From PRM_Value_Exchange_Recommendation__c Where Id IN :opidInputList AND PRM_One_Partner_Id__c != null]){
                vxRecordtoProcess = true;
                if(oldMap!=null && oldMap.size()>0) {
                    opidOld = (PRM_Value_Exchange_Recommendation__c) oldMap.get(vxRec.id);
                }
                if(opidOld.PRM_Recommendation_Status_Nm__c != vxRec.PRM_Recommendation_Status_Nm__c && vxRec.PRM_Recommendation_Status_Nm__c == System.Label.PRM_VX_Status){
                    opidAccountList.add(vxRec.PRM_One_Partner_Id__c);
                    mapOPIDPartnerrole.put(vxRec.PRM_One_Partner_Id__c,vxRec.PRM_Partner_Role_Nm__c);
                } 
            }
        }
        
       
        
        if(vxRecordtoProcess){
            //ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name =:System.Label.PRM_Intel_Partner_Alliance LIMIT 1];
            /* Fetching all the ACM records for the OPID Account and fecthing all the ACM's if the Partner Role matches with VxRecemendation */
            if((opidAccountList != null && !opidAccountList.IsEmpty()) && (mapOPIDPartnerrole != null && !mapOPIDPartnerrole.IsEmpty())){
                for(PRM_AccountChannelMembership__c acm :[Select Id,Name, PRM_Account_Id__c,PRM_Partner_Role__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :opidAccountList AND PRM_Status_Nm__c =:System.Label.PRM_Status]){
                    if(acm.PRM_Partner_Role__c == mapOPIDPartnerrole.get(acm.PRM_Account_Id__c)){
                        mapAccountIdACM.put(acm.PRM_Account_Id__c,acm);
                    }
                }
            }
          
            
            /* If the Partner Role of ACM matches with Partner Role of VxRecemendation, then updating the ACM Tier to the Eligiblity Tier of VxRecemendation */
            if(opidInputList != null && !opidInputList.IsEmpty()){
                for(PRM_Value_Exchange_Recommendation__c vxr :opidInputList){
                    if(mapAccountIdACM.get(vxr.PRM_One_Partner_Id__c) != null){
                        PRM_AccountChannelMembership__c updateacm = new PRM_AccountChannelMembership__c();
                        updateacm = mapAccountIdACM.get(vxr.PRM_One_Partner_Id__c);
                        if(updateacm != null){
                            if(updateacm.PRM_Channel_Program_Level_Id__c != vxr.PRM_Eligibility_Tier__c){
                                updateacm.PRM_Channel_Program_Level_Id__c = vxr.PRM_Eligibility_Tier__c;
                                upsertACMList.add(updateacm);
                            }
                        }
                    }
                    // This Part is commented because ACM will be created already by Agate Team.
                    else{
                        /* PRM_AccountChannelMembership__c insertacm = new PRM_AccountChannelMembership__c();
insertacm.PRM_Account_Id__c = vxr.PRM_One_Partner_Id__c;
insertacm.PRM_Channel_Program_Id__c = cp.Id;
insertacm.PRM_Channel_Program_Level_Id__c = vxr.PRM_Eligibility_Tier__c;
insertacm.PRM_Partner_Role__c = vxr.PRM_Partner_Role_Nm__c;
insertacm.PRM_Status_Nm__c = System.Label.PRM_Status;
upsertACMList.add(insertacm); */
                    } 
                }
            }
           
            try{
                if(upsertACMList != null && !upsertACMList.IsEmpty()){
                    upsert upsertACMList;
                }
            }
            catch(Exception ex){
               
            }
        }
        }} //TWC729-6800 EOL activities--Start
    
    /*****************************************************************************************************************************************************************
* author     : Sheetal Bhargava  
* Date       : 11/06/2020
* Parameters : List<PRM_Value_Exchange_Recommendation__c> opidInputList, Map<Id,PRM_Value_Exchange_Recommendation__c> oldMap
* Description: This method is use to create outbound messaage post opid approval.
* User Story : US688055
*************************************************************************************************************************************************************** **/
    //TWC729-6800 EOL activities--Start
    public Static  void opidOutboundMssg(List<PRM_Value_Exchange_Recommendation__c> opidInputList, Map<Id,PRM_Value_Exchange_Recommendation__c> oldMap){
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
        logEntryMsg+='\nopidOutboundMssg Method Invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
        logEntryMsg+='\nNew Map'+opidInputList;
        logEntryMsg+='\nOld Map'+oldMap;
        
        set<PRM_Value_Exchange_Recommendation__c> setOfVer = new set<PRM_Value_Exchange_Recommendation__c>();
        set<Id> setOfAcc = new set<Id>();
        map<id,account> mapOfAccIdToAcc = new map<id,account>();
        List<PRM_IntegrationOutboundMessageUtility.OPIDRecommendation> lstOfMssgOutbound =  new List<PRM_IntegrationOutboundMessageUtility.OPIDRecommendation>();
        List<String> lstOfOutboundMssgResult = new List<String>(); 
        //map<Id,boolean> mapOfOutboundMssgResult=new map<Id,boolean>();
        if(opidInputList != null && !opidInputList.isEmpty()){
            for(PRM_Value_Exchange_Recommendation__c verObj: opidInputList){
                //logEntryMsg+='\nOld Map Status'+oldMap != NULL ? oldMap.get(verObj.Id).PRM_Recommendation_Status_Nm__c : null;
                logEntryMsg+='\nNew Map Status'+verObj.PRM_Recommendation_Status_Nm__c;
                
                if(verObj.PRM_Recommendation_Status_Nm__c == System.label.PRM_OPID_In_Process 
                   && (oldMap == null || oldMap.get(verObj.Id).PRM_Recommendation_Status_Nm__c != System.label.PRM_OPID_In_Process) 
                   && verObj.RecordTypeId == OpidRecordTypeId){
                       setOfVer.add(verObj);
                       setOfAcc.add(verObj.PRM_Account_Id__c);  
                   }  
            }
        }
        logEntryMsg+='\nAccountId To Process'+setOfAcc;
        If(setOfAcc != null && !setOfAcc.isEmpty()){
            For(Account acc: [Select id,name,Core_CIM_ID__c from account where id IN: setOfAcc ]){
                mapOfAccIdToAcc.put(acc.id,acc); 
            } 
        }
      
        
        if(setOfVer != null && !setOfVer.isEmpty()){
            for(PRM_Value_Exchange_Recommendation__c verObject: setOfVer){
                PRM_IntegrationOutboundMessageUtility.OPIDRecommendation obj =  new PRM_IntegrationOutboundMessageUtility.OPIDRecommendation();
                obj.accountId = verObject.PRM_Account_Id__c;
                obj.groupingMethod = verObject.PRM_Grouping_Method_Nm__c;
                if(mapOfAccIdToAcc.containsKey(verObject.PRM_Account_Id__c)){
                    obj.cimId = (mapOfAccIdToAcc.get(verObject.PRM_Account_Id__c).Core_CIM_ID__c != NULL ? mapOfAccIdToAcc.get(verObject.PRM_Account_Id__c).Core_CIM_ID__c :'null');  
                }
                obj.groupingValue = 'null';
                obj.recommendationId = verObject.Id;
                If(!PRM_CreateAccountAndRelatedRecords.mapToUpdateWebsite.isEmpty() && 
                   PRM_CreateAccountAndRelatedRecords.mapToUpdateWebsite.containsKey(verObject.PRM_Account_Id__c)){
                       //Rohit - Checking if PRM_CreateAccountAndRelatedRecords.mapToUpdateWebsite has website 
                       //or not If is their then we will pasting the Website from Account else we will stamped website from OPID Recommendation
                       obj.website = PRM_CreateAccountAndRelatedRecords.mapToUpdateWebsite.get(verObject.PRM_Account_Id__c);
                   } else{
                       obj.website = verObject.PRM_Website__c;
                   }
                
                lstOfMssgOutbound.add(obj);
            }  
        }
        
        logEntryMsg+='\nInbounds To Be Proceesed'+lstOfMssgOutbound;
       
        if(lstOfMssgOutbound != null && !lstOfMssgOutbound.isEmpty()){
            lstOfOutboundMssgResult = PRM_IntegrationOutboundMessageUtility.createOPIDRequestMessage(lstOfMssgOutbound);
           
        }
        //set<String> setOfOutboundMssgResult = new set<String>(lstOfOutboundMssgResult); 
        logEntryMsg+='\nInboundsProceesed'+lstOfOutboundMssgResult;
        }}  //TWC729-6800 EOL activities--End
    
    /*****************************************************************************************************************************************************************
* author     : Lata Dudam/ Rohit Narnaware
* Date       : 23/05/2022
* Parameters : recordId
* Description: This method is use Change status of OPID
*************************************************************************************************************************************************************** */
    
    Public static void statusCheck(Set<Id> tagIds){
        map<Id,boolean> recomIdCheckMap=new map<Id,boolean>();
        Map<Id,PRM_Value_Exchange_Recommendation__c> finalMapRec = new Map<Id,PRM_Value_Exchange_Recommendation__c>(); 
        List<PRM_Value_Exchange_Recommendation__c> listForTracker = new List<PRM_Value_Exchange_Recommendation__c>();  
        
        //Set<Id> setOfRecIds = new Set<Id>();
        
        
        List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
        Map<Id,Id> mapOfRecOutboundOne = new Map<Id,Id>();
        Map<Id,Id> mapOfRecOutboundTwo = new Map<Id,Id>();
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
                //Getting instance of PRM_Tracker_steps__mdt for inprogress status, Submitted for OPID and Mulesoft Acknowledge
            PRM_Tracker_steps__mdt trackerMdt = PRM_Tracker_steps__mdt.getInstance('IN_PRGS');
            PRM_Tracker_steps__mdt opidSubTrackMdt = PRM_Tracker_steps__mdt.getInstance('OPID_SUBMITTED');
            PRM_Tracker_steps__mdt mulesoftAckMdt = PRM_Tracker_steps__mdt.getInstance('MULESOFT_ACK');
            
            List<Core_Integration_Outbound_Message__c> outboundMsgs = [SELECT 
                                                                    Id,
                                                                    Name,
                                                                    Core_Status__c,
                                                                    Core_Tags__c 
                                                                    FROM Core_Integration_Outbound_Message__c 
                                                                    WHERE  Core_Tags__c IN : tagIds
                                                                    ORDER BY CreatedDate DESC];
            // passing outbound message Name to string
        
            for(Core_Integration_Outbound_Message__c outboundMsg : outboundMsgs)
            {
                if(outboundMsg.Id != null && outboundMsg.Core_Tags__c != null ){
                    if( outboundMsg.Core_Status__c=='Successful'){
                        recomIdCheckMap.put(outboundMsg.Core_Tags__c,true);                    
                    }
                    else if(outboundMsg.Core_Status__c=='Failed'){
                        recomIdCheckMap.put(outboundMsg.Core_Tags__c,false);
                    }
                    if(!mapOfRecOutboundOne.ContainsKey(outboundMsg.Core_Tags__c)){
                        mapOfRecOutboundOne.put(outboundMsg.Core_Tags__c, outboundMsg.Id);
                    }
                    mapOfRecOutboundTwo.put(outboundMsg.Core_Tags__c, outboundMsg.Id);
                }
                
                
            }
            
            set<Id> setOfOutboundMssgResult = new set<Id>(); 
            setOfOutboundMssgResult.addAll(recomIdCheckMap.keyset());
            
            If(setOfOutboundMssgResult !=null && !setOfOutboundMssgResult.isEmpty()){
                for(PRM_Value_Exchange_Recommendation__c verObjFinal: [SELECT 
                                                                    Id,
                                                                    PRM_Account_Id__c,
                                                                    PRM_Account_Id__r.Name,
                                                                    PRM_Account_Name__c,
                                                                    PRM_Recommendation_Status_Nm__c 
                                                                    FROM PRM_Value_Exchange_Recommendation__c 
                                                                    WHERE Id IN : setOfOutboundMssgResult
                                                                    AND RecordTypeId =: opidRecordTypeId]) 
                {
                    if(recomIdCheckMap.containsKey(verObjFinal.id) && recomIdCheckMap.get(verObjFinal.id)==true){
                        verObjFinal.PRM_Recommendation_Status_Nm__c = System.label.PRM_OPID_Opid_In_Process;
                        verObjFinal.PRM_Account_Name__c = verObjFinal.PRM_Account_Id__r.Name != null ? verObjFinal.PRM_Account_Id__r.Name : '';
                    } else {
                        verObjFinal.PRM_Recommendation_Status_Nm__c = System.Label.PRM_Failed_to_Submit_for_OPID;
                        verObjFinal.PRM_Account_Name__c = verObjFinal.PRM_Account_Id__r.Name != null ? verObjFinal.PRM_Account_Id__r.Name : '';
                    }
                    finalMapRec.put(verObjFinal.Id, verObjFinal);                
                }
            }
            
            if(!finalMapRec.isEmpty()){
                Database.SaveResult[] srlist= database.update(finalMapRec.Values(), false);
                
                for (Database.SaveResult sr:srlist ){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {
                            Core_Log_Entry.logEntryWithDetails('PRM_VXRecommendation_Utility', 'IPA','opidOutboundMssg', 'exception','Exception occured while inserting Core_Integration_Outbound_Message__c',err.getMessage() , sr.getId(), 'PRM_Value_Exchange_Recommendation__c', 'OPID Recommendation');
                        }
                    } else {
                        listForTracker.add(finalMapRec.get(sr.getId()));
                        
                    }
                }
                
                Map<Id, PRM_Value_Exchange_Recommendation__c > vxRecMap = new Map <Id, PRM_Value_Exchange_Recommendation__c>();
                for (PRM_Value_Exchange_Recommendation__c opidRec : listForTracker){
                    vxRecMap.put(opidRec.Id, opidRec);
                }
                //TWC729-4717 - Quering old tracker records
                List<PRM_Tracker__c> retriveTrackerList = [SELECT
                                                        Id,
                                                        PRM_Milestone__c,
                                                        PRM_OPID_Recommendation__c
                                                        FROM PRM_Tracker__c 
                                                        WHERE PRM_OPID_Recommendation__c IN : vxRecMap.KeySet()
                                                        AND PRM_Completed__c = false ];
                //TWC729-4717 - deleting old tracker record
                if(!retriveTrackerList.IsEmpty()){
                    for(PRM_Tracker__c tracker : retriveTrackerList ){
                        if(vxRecMap.containsKey(tracker.PRM_OPID_Recommendation__c)){
                            if( vxRecMap.get(tracker.PRM_OPID_Recommendation__c).PRM_Recommendation_Status_Nm__c == System.label.PRM_OPID_Opid_In_Process &&
                            tracker.PRM_Milestone__c == 'OPID_SUBMITTED' || tracker.PRM_Milestone__c == 'MULESOFT_ACK' ){
                                tracker.PRM_Completed__c = true;
                                trackerList.add(tracker);
                            }
                        }
                    }
                } else {
                    for (PRM_Value_Exchange_Recommendation__c opidRec : listForTracker ){
                        if(trackerMdt != null){
                            //TWC729-4717 - creating tracker for inprocess
                            PRM_Tracker__c inprogressTracker  = PRM_IPA_Utility.createTrackerInstance(trackerMdt.PRM_Type__c, trackerMdt.DeveloperName, opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, true, null, null,null);    
                            trackerList.add(inprogressTracker);
                        }  
                        if(opidRec.PRM_Recommendation_Status_Nm__c == System.label.PRM_OPID_Opid_In_Process){
                            //TWC729-4717 - creating tracker for Submitted for OPID
                            if(opidSubTrackMdt != null && mapOfRecOutboundOne.ContainsKey(opidRec.Id)){
                                PRM_Tracker__c opidSubTracker  = PRM_IPA_Utility.createTrackerInstance(opidSubTrackMdt.PRM_Type__c,opidSubTrackMdt.DeveloperName, opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, true, null, null, mapOfRecOutboundOne.get(opidRec.Id));    
                                trackerList.add(opidSubTracker);
                            }
                            //TWC729-4717 - creating tracker for CIM Acknowledgement
                            if(mulesoftAckMdt != null && mapOfRecOutboundTwo.ContainsKey(opidRec.Id)){
                                PRM_Tracker__c muletracker  = PRM_IPA_Utility.createTrackerInstance(mulesoftAckMdt.PRM_Type__c,mulesoftAckMdt.DeveloperName, opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, true, null, null, mapOfRecOutboundTwo.get(opidRec.Id));    
                                trackerList.add(muletracker);
                            }
                        } else {
                            //TWC729-4717 - creating tracker for Failed to Submitt for OPID
                            if(opidSubTrackMdt != null && mapOfRecOutboundOne.ContainsKey(opidRec.Id)){
                                PRM_Tracker__c opidSubTracker  = PRM_IPA_Utility.createTrackerInstance(opidSubTrackMdt.PRM_Type__c,opidSubTrackMdt.DeveloperName, opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, false, null, null, mapOfRecOutboundOne.get(opidRec.Id));    
                                trackerList.add(opidSubTracker);
                            }
                            //TWC729-4717 - creating tracker for Failed CIM Acknowledgement
                            if(mulesoftAckMdt != null && mapOfRecOutboundTwo.ContainsKey(opidRec.Id)){
                                PRM_Tracker__c muleTracker  = PRM_IPA_Utility.createTrackerInstance(mulesoftAckMdt.PRM_Type__c,mulesoftAckMdt.DeveloperName, opidRec.Id, null, opidRec.PRM_Account_Id__c, null, null, false, null, null, mapOfRecOutboundTwo.get(opidRec.Id));    
                                trackerList.add(muleTracker);
                            }
                        }
                    }
                }
                
                //TWC729-4717 - inserting tracker record
                if(!trackerList.isEmpty()){
                    Database.upsertResult[] insertTracker = database.upsert(trackerList, false);
                    for(Database.upsertResult sr : insertTracker ) {
                        if(!sr.isSuccess()){
                            for(Database.Error err : sr.getErrors()) {
                                Core_Log_Entry.logEntryWithDetails('PRM_VXRecommendation_Utility', 'IPA','Tracker', 'exception','Exception occured while inserting Tracker Record',err.getMessage() , sr.getId(), 'PRM_Tracker__c', 'PRM_Tracker__c');
                            }
                        }
                    }
                }
            }
            PRM_CreateAccountAndRelatedRecords.createLogEntry(logEntryMsg);
        }
    }
    /*****************************************************************************************************************************************************************
* author     : Tejasree 
* Date       : 21/08/2020
* Parameters : List<PRM_Value_Exchange_Recommendation__c> vxRecommendationList, Map<Id,PRM_Value_Exchange_Recommendation__c> oldMap
* Description: This method is use to update Tier on VxData after calculations.
* User Story : US762869
*************************************************************************************************************************************************************** */
    //TWC729-6800 EOL activities--Start
    public Static  void updateTierOnVxData(List<PRM_Value_Exchange_Recommendation__c> vxRecommendationList, Map<Id,PRM_Value_Exchange_Recommendation__c> oldMap){    
        Map<String,String> mapOfUpgradeRec=new Map<String,String>();
        PRM_Value_Exchange_Recommendation__c vxrOld; 
        //Map<String,String> uniqueMapOfVxData=new Map<String,String>();
        List<PRM_Value_Exchange_Data__c> updateVxDataList =new List<PRM_Value_Exchange_Data__c>();
        String keyComp='';
        List<String> opidList=new List<String>();
        List<String> accList=new List<String>();
        List<String> partnerRoles=new List<String>();
        List<String> tierList=new List<String>();
        List<String> marketTypes=new List<String>();
        Id recordTypeUpgrade = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();         
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing        
        
        
        /* Fetching the old VxRecomendations records and checking the Status, If the Status is 'Processed' and recordType is of Upgrade, storing them in a Map */
        if(vxRecommendationList!=Null && vxRecommendationList.size()>0){
            
            for(PRM_Value_Exchange_Recommendation__c vxRec:[Select 
                                                            Id,
                                                            PRM_Account_Id__c,
                                                            PRM_One_Partner_Id__c,
                                                            PRM_Partner_Role_Nm__c, 
                                                            PRM_Tier_Id__c,
                                                            PRM_Market_Type_Nm__c,
                                                            PRM_Eligibility_Tier__c,
                                                            PRM_Eligibility_Tier__r.Name,
                                                            PRM_Recommendation_Status_Nm__c 
                                                            From PRM_Value_Exchange_Recommendation__c 
                                                            Where Id IN :vxRecommendationList 
                                                            AND RecordTypeId=:recordTypeUpgrade 
                                                            AND PRM_Eligibility_Tier__c!=Null 
                                                            AND PRM_Recommendation_Status_Nm__c!=Null 
                                                            AND PRM_Recommendation_Type_Nm__c =:Label.PRM_Action_Upgrade])
            {
                if(oldMap!=null && oldMap.size()>0) {vxrOld = (PRM_Value_Exchange_Recommendation__c)oldMap.get(vxRec.id);} 
                if(vxrOld.PRM_Recommendation_Status_Nm__c != vxRec.PRM_Recommendation_Status_Nm__c && vxRec.PRM_Recommendation_Status_Nm__c == System.Label.PRM_VX_Status_Processed){
                    mapOfUpgradeRec.put(vxRec.PRM_One_Partner_Id__c+SYM_COL+vxRec.PRM_Account_Id__c+SYM_COL+vxRec.PRM_Partner_Role_Nm__c+SYM_COL+vxRec.PRM_Tier_Id__c+SYM_COL+vxRec.PRM_Market_Type_Nm__c,vxRec.PRM_Eligibility_Tier__c);
                    
                } 
            }
        }
        if(mapOfUpgradeRec!=Null && mapOfUpgradeRec.size()>0){
            for(String s :mapOfUpgradeRec.keySet()){
                String[] keySetOfVXRec = s.split(SYM_COL);
                opidList.add(keySetOfVXRec[0]);
                accList.add(keySetOfVXRec[1]);
                partnerRoles.add(keySetOfVXRec[2]);
                tierList.add(keySetOfVXRec[3]);
                marketTypes.add(keySetOfVXRec[4]);
            }
        }
        // System.debug('Size of mapOfUpgradeRec' +mapOfUpgradeRec.size());
        // System.debug('mapOfUpgradeRec' +mapOfUpgradeRec);
        //Fetching VxData Records which are processed by Batch Job 
        if(opidList.size()>0 && accList.size()>0 && partnerRoles.size()>0 && tierList.size()>0 && marketTypes.size()>0){
            for(PRM_Value_Exchange_Data__c vxData :[Select Id,PRM_Account_Id__c,PRM_One_Partner_Id__c,PRM_Partner_Role_Nm__c,PRM_Tier_Id__c,PRM_Country_Market_Type_Nm__c,PRM_Processed_Date_Time_Dt__c from PRM_Value_Exchange_Data__c where PRM_Processed_Date_Time_Dt__c!=Null
                                                    AND PRM_Account_Id__c IN:accList AND PRM_One_Partner_Id__c IN:opidList AND PRM_Partner_Role_Nm__c IN:partnerRoles AND PRM_Tier_Id__c IN:tierList AND PRM_Country_Market_Type_Nm__c IN:marketTypes]){
                                                        keyComp =vxData.PRM_One_Partner_Id__c+SYM_COL+vxData.PRM_Account_Id__c+SYM_COL+vxData.PRM_Partner_Role_Nm__c+SYM_COL+vxData.PRM_Tier_Id__c+SYM_COL+vxData.PRM_Country_Market_Type_Nm__c;
                                                        if(mapOfUpgradeRec.containsKey(keyComp)){ //Comparing unique key combination of VxRecomendations with VXData rec keyComp
                                                            // System.debug('Key Combination of VXData' +keyComp);
                                                            // System.debug('Value of mapOfUpgradeRec' +mapOfUpgradeRec.get(keyComp));
                                                            vxData.PRM_Tier_Id__c = mapOfUpgradeRec.get(keyComp); //Assigning Eligibility tier value of vxRec to Tier of VxData
                                                            //System.debug('VXData Tier' +vxData.PRM_Tier_Id__c);
                                                            updateVxDataList.add(vxData); 
                                                        }
                                                    }
        }
        if(updateVxDataList!=Null && updateVxDataList.size()>0){
            update updateVxDataList; //update vxData records
        }
        
        }}  //TWC729-6800 EOL activities--End
    
    /*****************************************************************************************************************************************************************
* author     : Rohit Narnaware  
* Date       : 23/05/2022
* Parameters : recordId
* Description: This method is use to resubmit OPID
* User Story : US TWC729-3674
*************************************************************************************************************************************************************** */
    //TWC729-6800 EOL activities--Start
    @AuraEnabled
    public static integer getOPID_Ids(string recId){
        
        List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
        
        List<PRM_Value_Exchange_Recommendation__c> listOfOpid = new List<PRM_Value_Exchange_Recommendation__c>();
        List<Core_Integration_Outbound_Message__c> lstOfOBMSWithPendingStatus = new List<Core_Integration_Outbound_Message__c>();
        PRM_Value_Exchange_Recommendation__c opidRec = new PRM_Value_Exchange_Recommendation__c();
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
            PRM_Tracker_steps__mdt opidCreatedMdt = PRM_Tracker_steps__mdt.getInstance('OPID_REQ_PROCESSED');
        Try{
            opidRec = [SELECT Id,Name, PRM_Recommendation_Status_Nm__c, RecordTypeId, PRM_Account_Id__c,
                       PRM_Grouping_Method_Nm__c, PRM_Account_Id__r.Core_CIM_ID__c, PRM_Website__c
                       FROM PRM_Value_Exchange_Recommendation__c 
                       WHERE ID = : recId];
            listOfOpid.add(opidRec);
            
            listOfInbound = [SELECT Id,
                             Core_SalesCloud_AccountID__c,
                             Core_Status__c
                             FROM Core_OnePartner_Inbound_Message__c 
                             WHERE Core_SalesCloud_AccountID__c = : opidRec.PRM_Account_Id__c
                             AND Core_Status__c ='PROCESSED' 
                             AND Core_OnePartnerID__c != null ];
        } 
        Catch(System.QueryException e){
            
        }
        if (listOfInbound.size() > 0 ){
            opidRec.PRM_Recommendation_Status_Nm__c = Label.PRM_VX_RecommendationStatus_OPIDCreated;
            Update opidRec;
            if(opidCreatedMdt != null){
                PRM_Tracker__c tracker  = PRM_IPA_Utility.createTrackerInstance(opidCreatedMdt.PRM_Type__c,opidCreatedMdt.DeveloperName, opidRec.Id, null, null, null, null, true,null,null,null );    
                trackerList.add(tracker);
            }
            
            if(!trackerList.isEmpty()){
                Database.SaveResult[] insertTracker= database.insert(trackerList,false);
                for (Database.SaveResult sr : insertTracker ) {
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors())
                        {
                            Core_Log_Entry.logEntryWithDetails('PRM_VXRecommendation_Utility', 'IPA','opidOutboundMssg', 'exception','Exception occured while inserting PRM_Tracker__c',err.getMessage() , sr.getId(), 'PRM_Tracker__c', 'PRM_Tracker__c');
                        }
                    }
                }
            }
            return listOfInbound.size();
        } else {
            List <Core_Integration_Outbound_Message__c> lstOfoutBoundMsg = [SELECT 
                                                                            Id, 
                                                                            Core_Status__c, 
                                                                            Core_Tags__c, 
                                                                            Core_Payload__c,
                                                                            Core_MessageType__c
                                                                            FROM Core_Integration_Outbound_Message__c 
                                                                            WHERE Core_Tags__c = : recId
                                                                            AND Core_MessageType__c = 'OPID Request'];
            
            If (lstOfoutBoundMsg.size() == 0  && (opidRec.PRM_Recommendation_Status_Nm__c == System.label.PRM_Failed_to_Submit_for_OPID ||
                                                  opidRec.PRM_Recommendation_Status_Nm__c == System.label.PRM_FailedLabel))
            {
                set<PRM_Value_Exchange_Recommendation__c> setOfVer = new set<PRM_Value_Exchange_Recommendation__c>();
                set<Id> setOfAcc = new set<Id>();
                map<id,account> mapOfAccIdToAcc = new map<id,account>();
                List<PRM_IntegrationOutboundMessageUtility.OPIDRecommendation> lstOfMssgOutbound =  new List<PRM_IntegrationOutboundMessageUtility.OPIDRecommendation>();
                //List<String> lstOfOutboundMssgResult = new List<String>(); 
                //map<Id,boolean> mapOfOutboundMssgResult=new map<Id,boolean>();
                if(listOfOpid != null && !listOfOpid.isEmpty()){
                    for(PRM_Value_Exchange_Recommendation__c verObj: listOfOpid){
                        setOfVer.add(verObj);
                        setOfAcc.add(verObj.PRM_Account_Id__c);  
                    }
                }
                If(setOfAcc != null && !setOfAcc.isEmpty()){
                    For(Account acc: [Select id,name,Core_CIM_ID__c from account where id IN: setOfAcc ]){
                        mapOfAccIdToAcc.put(acc.id,acc); 
                    } 
                }
                
                if(setOfVer != null && !setOfVer.isEmpty()){
                    for(PRM_Value_Exchange_Recommendation__c verObject: setOfVer){
                        PRM_IntegrationOutboundMessageUtility.OPIDRecommendation obj =  new PRM_IntegrationOutboundMessageUtility.OPIDRecommendation();
                        obj.accountId = verObject.PRM_Account_Id__c;
                        obj.groupingMethod = verObject.PRM_Grouping_Method_Nm__c;
                        if(mapOfAccIdToAcc.containsKey(verObject.PRM_Account_Id__c)){
                            obj.cimId = (mapOfAccIdToAcc.get(verObject.PRM_Account_Id__c).Core_CIM_ID__c != NULL ? mapOfAccIdToAcc.get(verObject.PRM_Account_Id__c).Core_CIM_ID__c :'null');  
                        }
                        obj.groupingValue = 'null';
                        obj.recommendationId = verObject.Id;
                        obj.website = verObject.PRM_Website__c;
                        lstOfMssgOutbound.add(obj);
                    }  
                }
                
                if(lstOfMssgOutbound != null && !lstOfMssgOutbound.isEmpty()){
                    PRM_IntegrationOutboundMessageUtility.createOPIDRequestMessage(lstOfMssgOutbound);
                }        
                
            } else if ( lstOfoutBoundMsg.size() > 0 && opidRec != null ){
                
                lstOfoutBoundMsg[0].Core_Payload__c = PRM_IntegrationOutboundMessageUtility.createPayload(System.label.Setup_Prime_Hierarchy,opidRec.PRM_Account_Id__c, opidRec.PRM_Account_Id__r.Core_CIM_ID__c, opidRec.PRM_Grouping_Method_Nm__c, UserInfo.getUserId() ,opidRec.PRM_Website__c);
                lstOfoutBoundMsg[0].Core_Status__c = 'Pending';            
                lstOfOBMSWithPendingStatus.add(lstOfoutBoundMsg[0]);
                
                lstOfoutBoundMsg[1].Core_Payload__c = PRM_IntegrationOutboundMessageUtility.createPayload(System.label.Setup_Partner_Account_Hierarchy,opidRec.PRM_Account_Id__c, opidRec.PRM_Account_Id__r.Core_CIM_ID__c, opidRec.PRM_Grouping_Method_Nm__c, UserInfo.getUserId() ,opidRec.PRM_Website__c );
                lstOfoutBoundMsg[1].Core_Status__c = 'Pending';            
                lstOfOBMSWithPendingStatus.add(lstOfoutBoundMsg[1]);            
            }        
            if(!lstOfOBMSWithPendingStatus.isEmpty()){
                Database.SaveResult[] srlist= database.update(lstOfOBMSWithPendingStatus,false);
            }             
        }   
        }return null;
    }//TWC729-6800 EOL activities--End
    
    /*****************************************************************************************************************************************************************
* author     : Rohit Narnaware  
* Date       : 23/05/2022
* Parameters : List<PRM_Value_Exchange_Recommendation__c> recList, Map<Id, PRM_Value_Exchange_Recommendation__c> recMap, Boolean isUpdate)    
* Description: This method is use to Update the Status Update Date
* User Story : US TWC729-4115
*************************************************************************************************************************************************************** */
    //TWC729-6800 EOL activities--Start 
     public static void updateDuration(List<PRM_Value_Exchange_Recommendation__c> recList, Map<Id, PRM_Value_Exchange_Recommendation__c> recMap, Boolean isUpdate){
       if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
       DateTime updatedDateAndTime = System.now();
        
        if (isUpdate == false){
            for (PRM_Value_Exchange_Recommendation__c rec : recList){
                rec.PRM_Duration_In_Days__c = '0 Day(s)';
            }            
        } else {
            for (PRM_Value_Exchange_Recommendation__c rec : recList){
                if (rec.PRM_Recommendation_Status_Nm__c != recMap.get(rec.Id).PRM_Recommendation_Status_Nm__c ){
                    integer differenceInDays =  rec.CreatedDate.date().daysBetween(updatedDateAndTime.date()) ;
                    rec.PRM_Duration_In_Days__c = differenceInDays + ' Day(s)';
                }
            }                        
        }        
       }} //TWC729-6800 EOL activities--End
}