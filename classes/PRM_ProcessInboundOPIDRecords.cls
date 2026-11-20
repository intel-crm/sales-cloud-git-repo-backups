/**************************************************************************************************************
Apex Class Name:  PRM_ProcessInboundOPIDRecords
Version     : 1.0 
Created Date: 22 May 2020
Function    : This batch is use to process records from inbound table and create PAG record, link CAG record and call the other batch for rollup
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Anish Patole         05/22/2020        Initial version
* Srishty Sharma       11/17/2020        US835505:Implementation of logging mechanism for 1PID in inbound batch 1
***************************************************************************************************************/
global class PRM_ProcessInboundOPIDRecords  implements  Database.Batchable<sObject>,Database.stateful {
    
    public Set<Id> processIDs = new Set<Id>();    
    // List<Core_OnePartner_Inbound_Message__c> inboundMessageforBatch2 = new  List<Core_OnePartner_Inbound_Message__c>();        
    // public List<Core_Account_Group_Member__c> cagIds = new List<Core_Account_Group_Member__c>();
    // public Set<String> opidIds = new Set<String>();
    public Set<String> intelAccountIds = new Set<String>();    
    public Map<id,Core_Account_Group_Member__c> cagsToUpsertMap = new Map<id,Core_Account_Group_Member__c>(); //TWC729-4387
    global String logEntryMsg='';
    public string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
    public static final String LOG_ENTRY_ORIGIN = 'OPID Inbound Batch';
    public static final String LOG_ENTRY_PROJECT = 'IPA';
    public static final String LOG_ENTRY_SCOPE = 'OPID Inbound Batch';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String PRM_PROCESSINBOUNDCLASS = 'PRM_ProcessInboundOPIDRecords';
    public list<Core_OnePartner_Inbound_Message__c> listOfInboundsToProcess=new list<Core_OnePartner_Inbound_Message__c>();
    public list<string> listOfAccIds=new list<string>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //check if another apex job for this batch class is already running or in hold
        Id currentJobId = bc.getJobId();
        List<AsyncApexJob> apexJobsList = [Select id from AsyncApexJob where Status IN ('Holding', 'Preparing', 'Processing', 'Queued') and ApexClass.Name = :PRM_PROCESSINBOUNDCLASS and id != :currentJobId];
        
        if(!apexJobsList.isEmpty()){            
            System.abortJob(currentJobId);
        }
        // batch will run at specific time and will get all the records with status as new  and will pass it to execute method 
        
        //added by Anish - start
        String query;
            query = 'Select id,Core_Status__c,Core_CIM_ID__c,Core_OnePartnerID__c,Core_SalesCloud_AccountID__c,Core_PrimeID__c,Core_PAG_Grouping_Method__c,Core_Prime_Account_Name__c,Core_OnePartner_Account_Name__c, Error_Description__c, Core_Effective_End_Date_Time__c, Core_Effective_Start_Date_Time__c,Core_Status_Effective_End_Date_Time__c, Core_Request_Purpose_Cd__c, Core_Request_Status_Cd__c, Core_Change_Dt__c, Core_Error_Detail_Txt__c, Core_Error_Cd__c,Primary_Account__c, Comments__c, Delink_Association_User__c from Core_OnePartner_Inbound_Message__c where Core_Status__c = \'NEW\' AND (createdBy.Name != \'Integration User\' AND createdBy.name != \'Mulesoft Integration User\') order by Core_OnePartnerID__c, Core_Effective_End_Date_Time__c DESC NULLS LAST  LIMIT '+System.label.PRM_OPID_NoOfRecordsForProcessing;// LIMIT '+System.label.PRM_OPID_NoOfRecordsForProcessing; 

        return Database.getQueryLocator(query);
        //added by Anish - end
        
    }
    
    global void execute(Database.BatchableContext bc, List<Core_OnePartner_Inbound_Message__c> listOfAllInboundprocess) {
        logEntryMsg+='\nJob started at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
        List<Core_OnePartner_Inbound_Message__c> inboundprocess = new List<Core_OnePartner_Inbound_Message__c>();
        Map<String,Core_OnePartner_Inbound_Message__c> mapOfStatusUpdateInbound = new Map<String,Core_OnePartner_Inbound_Message__c>();
        List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();//TWC729-6801 OPID Tracker  
        try{
            if(listOfAllInboundprocess.size()>0){
                for(Core_OnePartner_Inbound_Message__c ip : listOfAllInboundprocess){
                    listOfInboundsToProcess.add(ip);
                    listOfAccIds.add(ip.Core_SalesCloud_AccountID__c);
                    if(ip.Core_Status__c == 'NEW'){
                        inboundprocess.add(ip);
                        //TWC729-6801 OPID Tracker Start
                        PRM_Tracker__c tracker = new PRM_Tracker__c();
                        
                        if((ip.Core_Effective_End_Date_Time__c != null && ip.Core_Effective_End_Date_Time__c.date() <= Date.Today()) || ip.Core_Status_Effective_End_Date_Time__c != null){
                            tracker.PRM_Type__c = 'OPID Updates';
                            tracker.PRM_Milestone__c = 'DLK_INBND_INPGS';
                            tracker.PRM_Location_Account__c = ip.Core_SalesCloud_AccountID__c;
                            tracker.PRM_Milestone_Display_Name__c ='OPID Delink Request In Progress';
                            tracker.PRM_Completed__c = true;
                            trackerList.add(tracker);
                        }else{
                            tracker.PRM_Type__c = 'OPID Updates';
                            tracker.PRM_Milestone__c = 'INBND_INPGS';
                            tracker.PRM_Location_Account__c = ip.Core_SalesCloud_AccountID__c;
                            tracker.PRM_Milestone_Display_Name__c ='OPID Request In Progress';
                            tracker.PRM_Completed__c = true;
                            trackerList.add(tracker);
                        }//}
                         //TWC729-6801 OPID Tracker End
                    }
                    
                }
                //TWC729-6801 OPID Tracker Start
                if (!trackerList.isEmpty() ) { 
                    //insert trackerList;
                    List<Database.SaveResult> insertTrackerResult = new List<Database.SaveResult>();
                    insertTrackerResult = Database.insert(trackerList,false);
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(trackerList, insertTrackerResult, 'PRM_Tracker__c');//TWC729-6988 Exception Handling
                }
                //TWC729-6801 OPID Tracker End
            }
            

            //Intial check of inboundMessage            
            List<Core_OnePartner_Inbound_Message__c> verifiedInboundMessage = getVerifiedInboundMessage(inboundprocess); 
            List<Core_OnePartner_Inbound_Message__c> updateList = new  List<Core_OnePartner_Inbound_Message__c>();           
            Map<String,String> errorLogOpidMap = new Map<String,String>();
            Map<String,String> errorLogCAGMap = new Map<String,String>();
            Map<String,List<Core_OnePartner_Inbound_Message__c>> discardedInboundMessagesMap = new Map<String,List<Core_OnePartner_Inbound_Message__c>>();
            if(verifiedInboundMessage != null && !verifiedInboundMessage.isEmpty()){    
                // process each batch of records default size is 200
                //Add the record ids from Core_OnePartner_Inbound_Message__c object that are process to list processIDs
                Map<String,List<Core_OnePartner_Inbound_Message__c>> mapOPIDInboundMessage = new Map<String,List<Core_OnePartner_Inbound_Message__c>>();
                // Map<String, Core_OnePartner_Inbound_Message__c> mapOfIntelAccRecentInboundMessage = new Map<String, Core_OnePartner_Inbound_Message__c>();            
                List<Core_OnePartner_Inbound_Message__c> accIdsForAccountAttachment = new List<Core_OnePartner_Inbound_Message__c>();
                List<Core_OnePartner_Inbound_Message__c> accIdsForAccountRemoval = new List<Core_OnePartner_Inbound_Message__c>();
                for(Core_OnePartner_Inbound_Message__c inboundMessage : verifiedInboundMessage){
                    
                    //Segregating based on End date in different lists for attachment & removal of Account
                    //String opid = String.valueOf(inboundMessage.Core_OnePartnerID__c.intValue());                
                    if((inboundMessage.Core_Effective_End_Date_Time__c != null && inboundMessage.Core_Effective_End_Date_Time__c.date() <= Date.Today()) || inboundMessage.Core_Status_Effective_End_Date_Time__c != null){                    
                        accIdsForAccountRemoval.add(inboundMessage);                                      
                    }else{
                        accIdsForAccountAttachment.add(inboundMessage);
                        /*
if(!mapOPIDInboundMessage.containskey(opid)){
listofInboundMessage = new List<Core_OnePartner_Inbound_Message__c>();
listofInboundMessage.add(inboundMessage);
mapOPIDInboundMessage.put(opid,listofInboundMessage);
}else{
mapOPIDInboundMessage.get(opid).add(inboundMessage);
}*/
                    }
                }  
                logEntryMsg+='\n***Inb rec succ. segregated for OPID account assoc. & disassoc.: Act for disassoc.: with val of list\n' + accIdsForAccountRemoval +'***';//DE101897:Added by Srishty
                List<String> logEntryMsgList= new List<String>();
                PRM_OPIDPAGRecordOperation opidAGRecOp = new PRM_OPIDPAGRecordOperation(updateList);
                //This method will return map of salesfore acc id and list of discarded detachment inbound msgs, as one sfid may have multiple inbound messages
                discardedInboundMessagesMap = opidAGRecOp.inactivateCoreAccGrpMembers(accIdsForAccountRemoval,logEntryMsgList); 
                if(logEntryMsgList.size()>0){
                    logEntryMsg+=logEntryMsgList[0];
                }
                logEntryMsg+='\n*** The CAGs are inact. succ. for disassoc. ***';//DE101897:Added by Srishty
                List<Core_OnePartner_Inbound_Message__c> discardList = new List<Core_OnePartner_Inbound_Message__c>();
                
                //From the inbound messages for removal, adding the discarded one in a separate list
                List<Core_OnePartner_Inbound_Message__c> inMsgList;
                for(Core_OnePartner_Inbound_Message__c inbMsg: accIdsForAccountRemoval){
                    inMsgList = discardedInboundMessagesMap.get(inbMsg.Core_SalesCloud_AccountID__c);                                    
                    if(inMsgList != null && inMsgList.contains(inbMsg)){
                        discardList.add(inbMsg); 
                    }else{
                        //For second batch processing
                        /* if(inbMsg.Core_OnePartnerID__c != null){
opidIds.add(String.valueOf(inbMsg.Core_OnePartnerID__c.intValue()));
} */           
                            intelAccountIds.add(inbMsg.Core_SalesCloud_AccountID__c);
                    }                                                                       
                }                                                                       
                
                // added by Pratik - start
                List<Core_OnePartner_Inbound_Message__c> discardedInbMsgList;           
                Boolean addToProcessingList;    
                
                //for each inb Msg in list of records for attachment, checking the discarded detachment inbound messages for the same sfid
                for(Core_OnePartner_Inbound_Message__c inboundMessage: accIdsForAccountAttachment){
                    String opid = null;
                    if(inboundMessage.Core_OnePartnerID__c != null)
                        opid = String.valueOf(inboundMessage.Core_OnePartnerID__c.intValue());
                    
                    //Flag to be set for adding to processing list
                    addToProcessingList = true;             
                    discardedInbMsgList = discardedInboundMessagesMap.get(inboundMessage.Core_SalesCloud_AccountID__c);
                    //If no discarded detachment record found, that means there were no other records for same sfid, flag is set to true by default
                    if(discardedInbMsgList != null){                                     
                        //If detachment records found, check if there is any record in the list with same OPID and end date less than detachment record start date
                        for(Core_OnePartner_Inbound_Message__c discardedInbMsg: discardedInbMsgList){
                            if(inboundMessage.Core_OnePartnerID__c == discardedInbMsg.Core_OnePartnerID__c && inboundMessage.Core_Effective_Start_Date_Time__c < discardedInbMsg.Core_Effective_End_Date_Time__c){
                                //set the flag to false as the record should be discarded & add to discard list
                                addToProcessingList = false;
                                discardList.add(inboundMessage);                                
                            }               
                        }
                    }
                    
                    List<Core_OnePartner_Inbound_Message__c> listofInboundMessage = null;
                    //if the flag is set to true, add it to the map for further processing
                    if(addToProcessingList == true){
                        // opidIds.add(opid);
                        intelAccountIds.add(inboundMessage.Core_SalesCloud_AccountID__c);
                        if(opid != null){
                            if(!mapOPIDInboundMessage.containskey(opid)){
                                listofInboundMessage = new List<Core_OnePartner_Inbound_Message__c>();
                                listofInboundMessage.add(inboundMessage);
                                mapOPIDInboundMessage.put(opid,listofInboundMessage);
                            }else{
                                mapOPIDInboundMessage.get(opid).add(inboundMessage);
                            }
                        }
                    }
                    
                }
                
                logEntryMsg+='\n*** Inb Msg records discarded from list of assoc. & disassoc. records:'+discardList+' ***';//DE101897:Added by Srishty
                
                Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
                Map<String,Account> accOpidMap = new Map<String,Account>();
                Map<String,Account> opidnewAccMap = new Map<String,Account>();
                Map<String,Set<String>> mapOfOPIDCAGs = new Map<String,Set<String>>();
                Map<String, String> errorLogCAGMapTemp = new Map<String, String>();
                Set<Core_Account_Group_Member__c> cagListToInsert = new Set<Core_Account_Group_Member__c>();    
                
                //List<Core_Account_Group_Member__c> existingCAGsList = new List<Core_Account_Group_Member__c>();
                Map<Id,Core_Account_Group_Member__c> existingCAGMap = new Map<Id,Core_Account_Group_Member__c>([Select ID,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_CIM_ID__c,Core_Intel_Account_Id__r.Core_Business_Party_Id__c,Core_Intel_Account_Id__r.Core_OnePartnerID__c,Core_Intel_Account_Id__r.Core_Prime_Account_Name__c,Core_Inactive_Ind__c, Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Name,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Partner_Account_Id__r.Core_Prime_Account_Name__c,Core_Partner_Account_Id__r.Core_Deactivated__c, Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c,PRM_RelationshipStartDate__c,PRM_RelationshipEndDate__c,Core_Partner_Account_Id__r.Exception_Comments__c,Delink_Association_User__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c IN: intelAccountIds or Core_Partner_Account_Id__r.Core_OnePartnerID__c IN:mapOPIDInboundMessage.keySet() order by Core_Partner_Account_Id__r.createddate DESC]);
                /*for(Core_Account_Group_Member__c cag : [Select ID,Core_Intel_Account_Id__c,Core_Inactive_Ind__c, Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Name,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Partner_Account_Id__r.Core_Prime_Account_Name__c, Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c IN: intelAccountIds or Core_Partner_Account_Id__r.Core_OnePartnerID__c IN:mapOPIDInboundMessage.keySet()]){        
existingCAGsList.add(cag);}*/
               
                logEntryMsg+='\n*** Existing CAGs found in system:'+existingCAGMap.values()+' ***';
                /*r(Account acc : [SELECT ID,Name,Core_OnePartnerID__c,(SELECT ID,Core_Intel_Account_Id__c,Core_Inactive_Ind__c FROM Partner_Account_Group_Members__r) FROM Account WHERE Core_OnePartnerID__c IN: mapOPIDInboundMessage.keySet() AND RecordTypeId =: accountRecordTypePAG]) */
                Set<String> accIds;
                Set<Id> cagIdsSet;
                Boolean allInactiveDuplicateCAG = false;
               // Map<String,boolean> duplicateCAG = new Map<String,boolean>();
                Map<String, Set<Id>> intelAccountIdsCAGsMap = new Map<String, Set<Id>>();
                List<String> opidListToBeFound = new List<String>();
                opidListToBeFound.addAll(mapOPIDInboundMessage.keySet());
                for(Core_Account_Group_Member__c cag:existingCAGMap.values())
                {
                    /*system.debug('Inside@@ '+acc);
accOpidMap.put(acc.Core_OnePartnerID__c,acc);     
mapOfOPIDCAGs.put(acc.Core_OnePartnerID__c,PRM_OPIDProcessUtility.getSetOfAsscoiatedSFID(acc.Partner_Account_Group_Members__r));*/
                    //Add all CAGs for each intel account id to check if any intel account has already an active CAG associated to it.
                    if(cag.Core_Inactive_Ind__c == false){
                        if(intelAccountIdsCAGsMap.containsKey(cag.Core_Intel_Account_Id__c)){
                            cagIdsSet = intelAccountIdsCAGsMap.get(cag.Core_Intel_Account_Id__c);
                        }
                        else{
                            cagIdsSet = new Set<Id>();
                        }
                        cagIdsSet.add(cag.id);
                        intelAccountIdsCAGsMap.put(cag.Core_Intel_Account_Id__c, cagIdsSet);                        
                    }
                    if(String.IsNotBlank(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c)){
                        Account acc = new Account();
                        acc.id = cag.Core_Partner_Account_Id__c;
                        acc.Core_PAG_Grouping_Method__c = cag.Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c;
                        
                        acc.Name = cag.Core_Partner_Account_Id__r.Name;
                        acc.Core_Deactivated__c = cag.Core_Partner_Account_Id__r.Core_Deactivated__c;
                        //TWC729-7414 : prevent blanking of comments or overriding during individual delinking scenario
                        acc.Exception_Comments__c = cag.Core_Partner_Account_Id__r.Exception_Comments__c;
                        //to handle multiple CAG records with duplicate OnePartnerID, in this case only active CAG's Account is considered,if all CAG is inactive, the oldest account will be considered.
                        if(accOpidMap.containsKey(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c)){
                            if(cag.Core_Inactive_Ind__c==false){  
                                allInactiveDuplicateCAG=false;                                                    
                                accOpidMap.put(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c,acc);
                            }
                            //if all CAG are inactive, we have to consider the CAG with oldest Account
                            else if(cag.Core_Inactive_Ind__c == true && allInactiveDuplicateCAG){
                                
                                accOpidMap.put(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c,acc);
                           }
                        }
                        else{
                            if(cag.Core_Inactive_Ind__c == true){
                                allInactiveDuplicateCAG = true;                             
                            }
                            accOpidMap.put(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c,acc);                         
                        }
                       
               
                        if(mapOfOPIDCAGs.containsKey(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c)){
                            accIds = mapOfOPIDCAGs.get(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c);                            
                        }else{
                            accIds = new Set<String>();
                        }
                        accIds.add(cag.Core_Intel_Account_Id__c);
                        mapOfOPIDCAGs.put(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c,accIds);
                        if(opidListToBeFound.IndexOf(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c) > -1){
                            opidListToBeFound.remove(opidListToBeFound.IndexOf(cag.Core_Partner_Account_Id__r.Core_OnePartnerID__c));
                        }                                                
                    }
                    
                }
              
                logEntryMsg+='\n*** No existing CAG found for OPIDs:'+opidListToBeFound+' ***';
                
                if(opidListToBeFound.size() > 0){
                    for(Account acc : [SELECT ID,Name,Core_OnePartnerID__c,Core_Deactivated__c,Core_Deactivation_Reason__c,Exception_Comments__c FROM Account WHERE Core_OnePartnerID__c IN: opidListToBeFound AND RecordTypeId =: accountRecordTypePAG]){
                        accOpidMap.put(acc.Core_OnePartnerID__c,acc); 
                        mapOfOPIDCAGs.put(acc.Core_OnePartnerID__c, null);
                    }
                }
                logEntryMsg+='\n***Existing OPID Acts found in SF :'+accOpidMap.keyset()+'***';//DE101897:Added by Srishty
                
                
                //Account creation and updation
                
                List<Account> listOfUpdateAccount = new List<Account>();
                for(String coreOpid : mapOPIDInboundMessage.keySet())
                {
                    List<Core_OnePartner_Inbound_Message__c> listOfInboundMessage = mapOPIDInboundMessage.get(coreOpid);
                    if(listOfInboundMessage != null){
                        Core_OnePartner_Inbound_Message__c inMsg = listOfInboundMessage[0];             
                        if(inMsg != null && !accOpidMap.keySet().contains(coreOpid) && !opidnewAccMap.containskey(coreOpid))
                        {
                            if(listOfInboundMessage != null){                    
                                String opidName =  inMsg.Core_OnePartner_Account_Name__c;
                                             
                                Account createAccount = new Account();
                                createAccount.RecordTypeId = accountRecordTypePAG;
                                createAccount.Name =opidName;                    
                                createAccount.Core_OnePartnerID__c = coreOpid;
                                //createAccount.Core_OPID_Name__c = opidName;  -- Not Required                    
                                //createAccount.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
                                createAccount.Core_PAG_Grouping_Method__c = inMsg.Core_PAG_Grouping_Method__c;
                                
                                //TWC729-6744 UCD Change
                                if(inMsg.Primary_Account__c ){
                                    createAccount.UCD_Primary_Account__c = inMsg.Core_SalesCloud_AccountID__c;
                                    createAccount.Exception_Comments__c = inMsg.Comments__c;
                                }
                                //createAccount.Core_PrimeID__c = inMsg.Core_PrimeID__c; --Uncomment it after filed creation.
                                listOfUpdateAccount.add(createAccount);
                                opidnewAccMap.put(coreOpid, createAccount);
                                logEntryMsg+='\n***New Act added for insertion for OPID : '+coreOpid+'***';
                            }
                        }else if(accOpidMap.containsKey(coreOpid)){
                            Account acc = accOpidMap.get(coreOpid);
                            //acc.Core_PAG_Grouping_Method__c = inMsg.Core_PAG_Grouping_Method__c;//TWC729-7384: commented as part of PAG method field updation defect
                            
                            acc.Name=inMsg.Core_OnePartner_Account_Name__c;
          //TWC729-7414 : prevent blanking of comments or overriding during individual delinking scenario
                            acc.Exception_Comments__c = (inMsg.Comments__c!=null && inMsg.Core_Effective_End_Date_Time__c==null)?inMsg.Comments__c:acc.Exception_Comments__c;
                            if(inMsg.Core_Status_Effective_End_Date_Time__c == null && acc.Core_Deactivated__c)
                            {
                                acc.Core_Deactivated__c = false;
                                acc.Core_Deactivation_Reason__c =null;
                            }
                            if(inMsg.Primary_Account__c ){
                                acc.UCD_Primary_Account__c = inMsg.Core_SalesCloud_AccountID__c;
                            }
                            listOfUpdateAccount.add(acc);
                            logEntryMsg+='\n***Existing Act found for update for OPID : '+coreOpid+'***';
                        }
                        //processIDs.add(mapOPIDInboundMessage.get(coreOpid).Id);
                    }
                }
                Database.UpsertResult[] opidnewAcc = null;
                set<Id> accOpidSuccess=new set<Id>();
                if(listOfUpdateAccount.size() > 0){
                    //insert opidnewAccMap.values();
                    opidnewAcc = Database.upsert(listOfUpdateAccount,false);
            
                    for(Database.upsertResult result:opidnewAcc) {
                        if (result.isSuccess() ){
                            accOpidSuccess.add(result.getId());
                        }
                       }
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(listOfUpdateAccount, opidnewAcc, 'Account');//added by srishty
                    //ErrorLogging for OPID
                    errorLogOpidMap = PRM_OPIDProcessUtility.getErrorMessageForOPID(listOfUpdateAccount,opidnewAcc);
                }
                logEntryMsg+='\n*** OPID Acts created/updated: \n'+listOfUpdateAccount+'***';
                Map<String,List<Core_OnePartner_Inbound_Message__c>> existingCAGOPIDs = new Map<String,List<Core_OnePartner_Inbound_Message__c>>();
                
                Boolean isCagAdded = false;
                for(List<Core_OnePartner_Inbound_Message__c> listOfInboundMessage: mapOPIDInboundMessage.values()){
                    for(Core_OnePartner_Inbound_Message__c inboundMessage: listOfInboundMessage){
                        String opidValue = null;
                        if(inboundMessage.Core_OnePartnerID__c != null){
                            opidValue = String.valueOf(inboundMessage.Core_OnePartnerID__c.intValue());
                        }
                        if(String.IsNotBlank(opidValue) && !errorLogOpidMap.containskey(opidValue)){
                            //Set<String> setOfCAGID = intelAccountIdsCAGsMap.get(inboundMessage.Core_SalesCloud_AccountID__c);
                            Set<Id> setOfCAGID = intelAccountIdsCAGsMap.get(inboundMessage.Core_SalesCloud_AccountID__c);
                            if(mapOfOPIDCAGs.containsKey(opidValue)) {
                                Set<String> setOfSFID = mapOfOPIDCAGs.get(opidValue);                                
                                if(setOfSFID == null || !setOfSFID.contains(inboundMessage.Core_SalesCloud_AccountID__c) && setOfCAGID == null){
                                    Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
                                    cag.Core_Intel_Account_Id__c = inboundMessage.Core_SalesCloud_AccountID__c;
                                    cag.Core_Partner_Account_Id__c = accOpidMap.get(opidValue).Id;
                  cag.PRM_RelationshipStartDate__c = inboundMessage.Core_Effective_Start_Date_Time__c; //UTKARSH - TWC727-102 - Added relationship start date check to filter out old opid data while processign the inbound.
                                    
                                    cag.Primary_Account__c = inboundMessage.Primary_Account__c ; // TWC729-6744 UCD Change
                  cag.Delink_Association_User__c = inboundMessage.Delink_Association_User__c;
                                    cag.Comments__c = inboundMessage.Comments__c;

                                    //cagIds.add(cag);
                                    isCagAdded = cagListToInsert.add(cag);
                                    if(isCagAdded == false){
                                        discardList.add(inboundMessage);   
                                        logEntryMsg+='\n* duplicate discarded Id:'+inboundMessage.id+' *';
                                    }else{
                                        // cagIds.add(cag);
                                        logEntryMsg+='\n* New CAG rec created for Intel Acc Id:'+inboundMessage.Core_SalesCloud_AccountID__c+' and OPID Acc Id:'+ accOpidMap.get(opidValue).Id + ' *';
                                    }
                                    
                                }else if(setOfSFID == null || !setOfSFID.contains(inboundMessage.Core_SalesCloud_AccountID__c) && setOfCAGID != null){

                                    List<inBoundMessageWrapper> inboundWrapList = new List<inBoundMessageWrapper>();
                                    List<Core_OnePartner_Inbound_Message__c> inBoundReturnList = new List<Core_OnePartner_Inbound_Message__c>();
                                    for(Id cagId :setOfCAGID){//0GK
                                        if(existingCAGMap.ContainsKey(cagId)){                      
                                            if(existingCAGMap.get(cagId).Core_Inactive_Ind__c==false){
                                                //Creating a Wrapper for Inbound Request               
                                                inboundWrapList.add(createInboundWrapper(existingCAGMap,cagId,accOpidMap,opidnewAccMap,opidValue));                                                
                                                                                           
                                                //CAG Record to associate 
                                                Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
                                                cag.Core_Intel_Account_Id__c = inboundMessage.Core_SalesCloud_AccountID__c;
                                                cag.PRM_RelationshipStartDate__c = inboundMessage.Core_Effective_Start_Date_Time__c; //UTKARSH - TWC727-102 - Added relationship start date check to filter out old opid data while processign the inbound.
                                                
                                                    cag.Primary_Account__c = inboundMessage.Primary_Account__c ;
                          cag.Delink_Association_User__c = inboundMessage.Delink_Association_User__c;
                                                    cag.Comments__c = inboundMessage.Comments__c;
                          // TWC729-6744 UCD Change
                                                
                                                if(accOpidMap.ContainsKey(opidValue)){
                                                    cag.Core_Partner_Account_Id__c = accOpidMap.get(opidValue).Id;  
                                                }else if (opidnewAccMap.ContainsKey(opidValue)){
                                                    cag.Core_Partner_Account_Id__c = opidnewAccMap.get(opidValue).Id;  
                                                }                                           
                                                isCagAdded = cagListToInsert.add(cag);
                                                if(isCagAdded == false){
                                                    discardList.add(inboundMessage);   
                                                    logEntryMsg+='\n* duplicate discarded Id:'+inboundMessage.id+' *';
                                                }else{
                                                    // cagIds.add(cag);
                                                    String OnePartnerIdDetails =accOpidMap.ContainsKey(opidValue)? accOpidMap.get(opidValue).Id :opidnewAccMap.get(opidValue).Id;  
                                                    logEntryMsg+='\n* New CAG rec created for Intel Acc Id:'+inboundMessage.Core_SalesCloud_AccountID__c+' and OPID Acc Id:'+ OnePartnerIdDetails + ' *';
                                                }
                                            }
                                        }
                                    }
                                    if(inboundWrapList.size()>0){
                                       inBoundReturnList= createInBoundDetachmentRecord(inboundWrapList);
                                    }
                                    if(inBoundReturnList.size()>0){
                                        verifiedInboundMessage.addAll(inBoundReturnList); 
                                    }
                                    //errorLogCAGMapTemp.put(String.valueOf(inboundMessage.Core_SalesCloud_AccountID__c), System.label.PRM_OPID_ExistingIntelAcc_Error);
                                    logEntryMsg+='\n* Exi. CAG found with assoc. to diff OPID Act for intel Acc Id:'+inboundMessage.Core_SalesCloud_AccountID__c+ '. Marking the inbmsg as failed. *';
                                    //inboundMessage.Error_Description__c = System.label.PRM_OPID_ExistingIntelAcc_Error;
                                    //discardList.add(inboundMessage);
                                }else{
                                    /**
* Added with respect to Defect :- DE83367
*/
                                    List<Core_OnePartner_Inbound_Message__c> listOfInMsg = null;
                                    id opid = accOpidMap.get(opidValue).Id;
                                    if(existingCAGOPIDs.containskey(opid)){
                                        listOfInMsg = existingCAGOPIDs.get(opid);
                                        listOfInMsg.add(inboundMessage);
                                    }else{
                                        listOfInMsg = new List<Core_OnePartner_Inbound_Message__c>();
                                        listOfInMsg.add(inboundMessage);
                                        existingCAGOPIDs.put(opid,listOfInMsg); 
                                    }
                                }
                            }else{
                                if(setOfCAGID != null){
                                    List<inBoundMessageWrapper> inboundWrapList = new List<inBoundMessageWrapper>();
                                    List<Core_OnePartner_Inbound_Message__c> inBoundReturnList = new List<Core_OnePartner_Inbound_Message__c>();
                                    for(Id cagId :setOfCAGID){//0GK
                                        if(existingCAGMap.ContainsKey(cagId)){                      
                                            if(existingCAGMap.get(cagId).Core_Inactive_Ind__c==false){
                                                //Creating a Wrapper for Inbound Request  
                                                inboundWrapList.add(createInboundWrapper(existingCAGMap,cagId,accOpidMap,opidnewAccMap,opidValue));                                                
                                                //CAG Record to associate 
                                                Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
                                                cag.Core_Intel_Account_Id__c = inboundMessage.Core_SalesCloud_AccountID__c;
                                               // cag.Intel_Record_Type_Text__c = 'Inactive_Account';
                                                cag.PRM_RelationshipStartDate__c = inboundMessage.Core_Effective_Start_Date_Time__c; //UTKARSH - TWC727-102 - Added relationship start date check to filter out old opid data while processign the inbound.

                                                    cag.Primary_Account__c = inboundMessage.Primary_Account__c ;
                          cag.Delink_Association_User__c = inboundMessage.Delink_Association_User__c;
                                                    cag.Comments__c = inboundMessage.Comments__c;                          
                          // TWC729-6744 UCD Change
                                                if(accOpidMap.ContainsKey(opidValue)){
                                                    cag.Core_Partner_Account_Id__c = accOpidMap.get(opidValue).Id;  
                                                }else if (opidnewAccMap.ContainsKey(opidValue)){
                                                    cag.Core_Partner_Account_Id__c = opidnewAccMap.get(opidValue).Id;  
                                                }
                                                isCagAdded = cagListToInsert.add(cag);
                                                if(isCagAdded == false){
                                                    discardList.add(inboundMessage);   
                                                    logEntryMsg+='\n* duplicate discarded Id:'+inboundMessage.id+' *';
                                                }else{
                                                    // cagIds.add(cag);
                                                    String OnePartnerIdDetails =accOpidMap.ContainsKey(opidValue)? accOpidMap.get(opidValue).Id :opidnewAccMap.get(opidValue).Id;  
                                                    logEntryMsg+='\n* New CAG rec created for Intel Acc Id:'+inboundMessage.Core_SalesCloud_AccountID__c+' and OPID Acc Id:'+ OnePartnerIdDetails + ' *';
                                                }
                                            }
                                        }
                                    }
                                    if(inboundWrapList.size()>0){
                                        inBoundReturnList= createInBoundDetachmentRecord(inboundWrapList);
                                    }
                                    if(inBoundReturnList.size()>0){
                                        verifiedInboundMessage.addAll(inBoundReturnList); 
                                    }
                                    //errorLogCAGMapTemp.put(String.valueOf(inboundMessage.Core_SalesCloud_AccountID__c), System.label.PRM_OPID_ExistingIntelAcc_Error);
                                    logEntryMsg+='\n* Exi. CAG found with assoc. to diff. OPID Act for intel Acc Id:'+inboundMessage.Core_SalesCloud_AccountID__c+ '. Marking the Inb msg as failed. *';
                                }else if(opidnewAccMap.containsKey(opidValue)){
                                    Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
                                    cag.Core_Intel_Account_Id__c = inboundMessage.Core_SalesCloud_AccountID__c;
                                    cag.Core_Partner_Account_Id__c = opidnewAccMap.get(opidValue).Id;
                                    
                                    cag.Primary_Account__c = inboundMessage.Primary_Account__c ;
                  cag.Delink_Association_User__c = inboundMessage.Delink_Association_User__c;
                                    cag.Comments__c = inboundMessage.Comments__c;
                  // TWC729-6744 UCD Change

                                //    cag.Intel_Record_Type_Text__c = 'Inactive_Account';
                  cag.PRM_RelationshipStartDate__c = inboundMessage.Core_Effective_Start_Date_Time__c; //UTKARSH - TWC727-102 - Added relationship start date check to filter out old opid data while processign the inbound.
                                    isCagAdded = cagListToInsert.add(cag);
                                    if(isCagAdded == false){
                                        discardList.add(inboundMessage);  
                                        logEntryMsg+='\n* Duplicate Discarded Id:'+inboundMessage.id+' *';
                                        
                                    }else{
                                        // cagIds.add(cag);
                                        logEntryMsg+='\n* New CAG record created for Intel Acc Id:'+inboundMessage.Core_SalesCloud_AccountID__c+' and OPID Acc Id:'+ opidnewAccMap.get(opidValue).Id + ' *';
                                    }
                                    
                                }else{
                                    inboundMessage.Error_Description__c = System.label.PRM_OPID_NoOPIDAcc_Error;
                                    discardList.add(inboundMessage); 
                                }
                            }
                        }
                    }
                } 
                
                logEntryMsg+='\n* Existing CAGs '+existingCAGOPIDs+'*';//DE101897:Added by Srishty // identified for same intel acc-OPID acc mapping :\n
                /**
* Added with respect to Defect :- DE83367
*/ 
                if(!existingCAGOPIDs.isEmpty()){
                    Map<Id,Core_Account_Group_Member__c> existingCAGList = new Map<Id,Core_Account_Group_Member__c>();
                    Map<Id,Core_Account_Group_Member__c> existingActiveCAGList = new Map<Id,Core_Account_Group_Member__c>();
                    for( Core_Account_Group_Member__c cag : [select Core_Partner_Account_Id__c, Core_Intel_Account_Id__c, Core_Inactive_Ind__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Partner_Account_Id__r.Name,PRM_RelationshipStartDate__c,PRM_RelationshipEndDate__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c in :existingCAGOPIDs.keySet() OR Core_Intel_Account_Id__c in :intelAccountIds]){   // TWC729-6744 UCD Change
                        if(cag.Core_Inactive_Ind__c==true && existingCAGOPIDs.containsKey(cag.Core_Partner_Account_Id__c)){
                            existingCAGList.put(cag.Core_Intel_Account_Id__c,cag);
                        }else if(cag.Core_Inactive_Ind__c==false){
                            existingActiveCAGList.put(cag.Core_Intel_Account_Id__c,cag);
                        }
                    }
                    if(existingCAGList != null && existingCAGList.size() > 0){
                        List<inBoundMessageWrapper> inboundWrapList = new List<inBoundMessageWrapper>();
                        List<Core_OnePartner_Inbound_Message__c> inBoundReturnList = new List<Core_OnePartner_Inbound_Message__c>();
                        for(Core_Account_Group_Member__c cag : existingCAGList.values()){
                            for(Core_OnePartner_Inbound_Message__c inboundMsg : existingCAGOPIDs.get(cag.Core_Partner_Account_Id__c)){
                                if(cag.Core_Intel_Account_Id__c == inboundMsg.Core_SalesCloud_AccountID__c && (cag.PRM_RelationshipEndDate__c == null || inboundMsg.Core_Effective_Start_Date_Time__c > cag.PRM_RelationshipEndDate__c)){
                                    if(!existingActiveCAGList.containsKey(cag.Core_Intel_Account_Id__c)){
                                        cag.Core_Inactive_Ind__c = false;                                
                                        cag.PRM_RelationshipStartDate__c = inboundMsg.Core_Effective_Start_Date_Time__c; //UTKARSH - TWC727-102 - Added relationship start date check to filter out old opid data while processign the inbound.
                                        cag.PRM_RelationshipEndDate__c = inboundMsg.Core_Effective_End_Date_Time__c;
                                    
                                            cag.Primary_Account__c = inboundMsg.Primary_Account__c ; // TWC729-6744 UCD Change
                                            cag.Delink_Association_User__c = inboundMsg.Delink_Association_User__c;
                                            cag.Comments__c = inboundMsg.Comments__c;

                                        isCagAdded = cagListToInsert.add(cag);
                                        if(isCagAdded == false){
                                            discardList.add(inboundMsg);
                                            logEntryMsg+='* Duplicate and Discared with\n*  Id:'+inboundMsg.id+' *';  //For existing CAGs found, inb msg found to be duplicate & discarded with
                                        }else{
                                            //   cagIds.add(cag);
                                            logEntryMsg+='\n* Updated existing CAG for intel acc Id:'+inboundMsg.Core_SalesCloud_AccountID__c+' and OPID Acc Id: '+cag.Core_Partner_Account_Id__c+' *';  
                                        }
                                    }
                                    else{   
                                        String opidValue= null;
                                        opidValue = String.valueOf(inboundMsg.Core_OnePartnerID__c.intValue());
                                        //Creating a Wrapper for Inbound Request               
                                        inboundWrapList.add(createInboundWrapper(existingCAGMap,existingActiveCAGList.get(cag.Core_Intel_Account_Id__c).Id,accOpidMap,opidnewAccMap,opidValue)); 
                                        
                                        cag.Core_Inactive_Ind__c = false;                                
                    cag.PRM_RelationshipStartDate__c = inboundMsg.Core_Effective_Start_Date_Time__c; //UTKARSH - TWC727-102 - Added relationship start date check to filter out old opid data while processign the inbound.
                    cag.PRM_RelationshipEndDate__c = inboundMsg.Core_Effective_End_Date_Time__c;
          cag.Delink_Association_User__c = inboundMsg.Delink_Association_User__c;
                    cag.Comments__c = inboundMsg.Comments__c;
                                        isCagAdded = cagListToInsert.add(cag);
                                        if(isCagAdded == false){
                                            discardList.add(inboundMsg);
                                            logEntryMsg+='* Duplicate and Discared with\n*  Id:'+inboundMsg.id+' *';  //For existing CAGs found, inb msg found to be duplicate & discarded with
                                        }else{                                          
                                            logEntryMsg+='\n* Updated existing CAG for intel acc Id:'+inboundMsg.Core_SalesCloud_AccountID__c+' and OPID Acc Id: '+cag.Core_Partner_Account_Id__c+' *';  
                                        }
                                    }
                                }
                else if(inboundMsg.Core_Effective_Start_Date_Time__c < cag.PRM_RelationshipEndDate__c){
                    inboundMsg.Core_Status__c = System.label.PRM_INBOUNDMSG_PROCESS_FAILED;
                    inboundMsg.Error_Description__c = System.label.PRM_OPIDErrorMsg;
                    logEntryMsg+='\nInbound message with Id:'+inboundMsg.Id+' failed due to '+System.label.PRM_OPIDErrorMsg;  //For existing CAGs found, new relationship start date is older then existing relationship end date. 
                }
                            }
                        }
                        
                        if(inboundWrapList.size()>0){
                            inBoundReturnList= createInBoundDetachmentRecord(inboundWrapList);
                        }
                        if(inBoundReturnList.size()>0){
                            verifiedInboundMessage.addAll(inBoundReturnList); 
                        }
                    }
                }
                logEntryMsg+='\n* Final list of inb meg rec identified for discarding: \n'+discardList+' *';//DE101897:Added by Srishty
                
                Database.UpsertResult[] cagInsertError = null;
                List<Core_Account_Group_Member__c> cagsToUpsert = new List<Core_Account_Group_Member__c>();
               
            if(!cagListToInsert.isempty() && cagListToInsert.size()>0){
          for(Core_Account_Group_Member__c cags:cagListToInsert){
          if(accOpidSuccess.contains(cags.Core_Partner_Account_Id__c)){
            cagsToUpsert.add(cags);
          }
          }
        }
    else{ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
                cagsToUpsert.addAll(cagListToInsert);
        }
                if(cagsToUpsert.size() > 0){
                    //TWC729-4387-Start
                    for(Core_Account_Group_Member__c cagVar:cagsToUpsert){
                        cagsToUpsertMap.put(cagVar.Core_Intel_Account_Id__c,cagVar);
                    }
                    //TWC729-4387-End
                    //insert cagListToInsert;
                    cagInsertError = Database.upsert(cagsToUpsert,false);
                    logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(cagsToUpsert, cagInsertError,'Core_Account_Group_Member__c');//added by srishty
                    //ErrorLogging for CAG
                    errorLogCAGMap = PRM_OPIDProcessUtility.getErrorMessageForCAGUpsert(cagsToUpsert,cagInsertError);
                    
                     }
                
                logEntryMsg+='\n* CAGs inserted: \n'+cagsToUpsert+'*';//DE101897:Added by Srishty
                errorLogCAGMap.putAll(errorLogCAGMapTemp);
               
                updateStatus(verifiedInboundMessage,errorLogOpidMap,errorLogCAGMap,discardList,null);
                //added by Anish - end 
                
                logEntryMsg+='\n*inbd msg rec verified successfully:'+verifiedInboundMessage+'*';
                //-----------------check heap size--------------
                
                if(logEntryMsg.length() > Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength() || Test.isRunningTest()){
                    if(logEntryMsg!=''){// this block will create error log records on the basis of length of logEntryMsg and Field limit.
                        PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
                        Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
                        logEntryUtility.addLogEntry(logEntryMsg,fieldLength);
                       
                        for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                             //Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,logEntryMsg.split('@@@')[0] ,logEntryUtility.logEntryList[i] , '', '', '');
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY, 'Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');           
                        }//loop ends here..
                    }
                    logEntryMsg = '';
                    
                }
               
                
            } 
            
            
        }catch(Exception e){            
            
            logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processException(e);//Added error log statement 
            updateStatus(listOfAllInboundprocess,null, null, null, e.getMessage() + ': ' + e.getStackTraceString());
        }
        
    }
    
    public void updateStatus(List<Core_OnePartner_Inbound_Message__c> listOfAllInboundprocess,Map<String,String> opidErrMap, Map<String,String> cagErrMap, List<Core_OnePartner_Inbound_Message__c> discardedInboundMessagesList, String errorMsg){
        logEntryMsg+='\n*UpdateStatus method enter...*';
        List<Core_OnePartner_Inbound_Message__c> updateList = new  List<Core_OnePartner_Inbound_Message__c>();

        //List<String> opidValues = new List<String>();
        for(Core_OnePartner_Inbound_Message__c  inboundRec : listOfAllInboundprocess){   
            if(opidErrMap == null && cagErrMap == null && String.IsNotBlank(errorMsg)){
                if(inboundRec.Core_Status__c == System.Label.PRM_INBOUNDMSG_NEW){
                    inboundRec.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESS_FAILED;
                }
                inboundRec.Error_Description__c = System.label.PRM_OPID_Batch_Failed + ': ' +errorMsg;
                logEntryMsg+='\n* inbd msg rec with Id:'+inboundRec.Id+' Status = FAILED err: '+errorMsg+'*';
            }
            if(inboundRec.Core_Status__c != System.Label.PRM_INBOUNDMSG_PROCESS_FAILED){
                inboundRec.Core_Status__c = System.Label.PRM_INBOUNDMSG_LOAD_COMPLETE;
                logEntryMsg+='\n*inbd msg rec with Id:'+inboundRec.Id+' Status = LOAD COMPLETE *';
            }
            if(discardedInboundMessagesList != null && discardedInboundMessagesList.contains(inboundRec)){
                if(String.IsBlank(inboundRec.Error_Description__c)){
                    inboundRec.Core_Status__c = System.label.PRM_INBOUNDMSG_DISCARDED;
                    logEntryMsg+='\n* inbd msg rec with Id:'+inboundRec.Id+' Status = DISCARDED*';
                }else{
                    inboundRec.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESS_FAILED;
                    logEntryMsg+='\n* inbd msg rec with Id:'+inboundRec.Id+' Satus = FAILED err :'+inboundRec.Error_Description__c+'*';
                }
            }            
            String opIDvalue = null;
            if(inboundRec.Core_OnePartnerID__c != null){
                opIDvalue = String.valueOf(inboundRec.Core_OnePartnerID__c.intValue());
            }
            if(opidErrMap != null && opIDvalue != null && opidErrMap.containskey(opIDvalue) && inboundRec.Core_Status__c != System.label.PRM_INBOUNDMSG_DISCARDED){
                inboundRec.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESS_FAILED;
                inboundRec.Error_Description__c = opidErrMap.get(opIDvalue);
                logEntryMsg+='\n* inbd msg rec with Id:'+inboundRec.Id+' Status = FAILED err: '+opidErrMap.get(opIDvalue)+'*';
            }
            
            if(cagErrMap != null && cagErrMap.containskey(inboundRec.Core_SalesCloud_AccountID__c) && inboundRec.Core_Status__c != System.label.PRM_INBOUNDMSG_DISCARDED){
                inboundRec.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESS_FAILED;
                inboundRec.Error_Description__c = cagErrMap.get(inboundRec.Core_SalesCloud_AccountID__c);
                logEntryMsg+='\n* inbd msg rec with Id:'+inboundRec.Id+' Status = FAILED err: '+cagErrMap.get(inboundRec.Core_SalesCloud_AccountID__c)+'*';
            } 
            
            if(inboundRec.Core_Status__c.equals(System.Label.PRM_INBOUNDMSG_LOAD_COMPLETE)){
                //    inboundMessageforBatch2.add(inboundRec);
                /*opidValues.add(opIDvalue); 
opidIds.add(opIDvalue); */
            }else if(!inboundRec.Core_Status__c.equals(System.Label.PRM_INBOUNDMSG_DISCARDED)){                
                /* if(!opidValues.contains(opIDvalue)){
opidIds.remove(opIDvalue);
}*/
                intelAccountIds.remove(inboundRec.Core_SalesCloud_AccountID__c);
                logEntryMsg+='\n* OPID removed, error:- '+opIDvalue +'*';
                logEntryMsg+='\n* IntelActIds removed, error:- '+inboundRec.Core_SalesCloud_AccountID__c+'*';
            }
            updateList.add(inboundRec);
        }            
        
        if(updateList.size() > 0){ 
            List<Database.SaveResult> updateListResult = new List<Database.SaveResult>();
            updateListResult = Database.Update(updateList,false);
            logEntryMsg+= PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(updateList, updateListResult,'Core_OnePartner_Inbound_Message__c');
        }
        logEntryMsg+='\n*UpdateStatus executed succ.*';
        // logEntryMsg+='\n*** List of Inbound Message Record for PRM_ProcessRollUpDownOPIDRecords Batch processing :\n '+inboundMessageforBatch2+'***';
    }
    
    public List<Core_OnePartner_Inbound_Message__c> createInBoundDetachmentRecord(List<inBoundMessageWrapper> inboundWrapList){
        Map<String,String> errorLogInBoundMsgMap = new Map<String,String>();
        List<Core_OnePartner_Inbound_Message__c> updateList = new  List<Core_OnePartner_Inbound_Message__c>();           
        List<Core_OnePartner_Inbound_Message__c> InboundlistToInsert = new List<Core_OnePartner_Inbound_Message__c>();
        Map<String,List<Core_OnePartner_Inbound_Message__c>> discardedInboundMessagesMap = new Map<String,List<Core_OnePartner_Inbound_Message__c>>();
        for(inBoundMessageWrapper wrap :inboundWrapList){
            Core_OnePartner_Inbound_Message__c inboundRecord = new Core_OnePartner_Inbound_Message__c();
            inboundRecord.Core_Status__c = wrap.Status;
            inboundRecord.Core_Status_Reason__c=wrap.StatusReason;
            inboundRecord.Core_SalesCloud_AccountID__c = wrap.SalesCloudAccountID;
            inboundRecord.Core_OnePartnerID__c = wrap.Core_OnePartnerID;
            inboundRecord.Core_CIM_ID__c=wrap.CIMId;
            inboundRecord.Core_OnePartner_Account_Name__c = wrap.OnePartnerAccountName; 
            inboundRecord.Core_Effective_End_Date_Time__c = wrap.EffectiveEndDate;   
            inboundRecord.Core_Prime_Account_Name__c= wrap.PrimeAccountName; 
            inboundRecord.Core_PAG_Grouping_Method__c = wrap.PartnerGroupingMethod;
            InboundlistToInsert.add(inboundRecord);
        }
        Database.UpsertResult[] inBoundInsertError = null;
        if(InboundlistToInsert.size()>0){
            inBoundInsertError = Database.upsert(InboundlistToInsert,false);
            logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(InboundlistToInsert, inBoundInsertError,'Core_OnePartner_Inbound_Message__c');//added by srishty
            //ErrorLogging for CAG
            errorLogInBoundMsgMap = PRM_OPIDProcessUtility.getErrorMessageForInboundMsgupsert(InboundlistToInsert,inBoundInsertError);
        }
        logEntryMsg+='\n*** Inbound Message Record for detaching has been created Sucessfully: \n'+InboundlistToInsert+'***';
        List<String> logEntryMsgList= new List<String>();
        PRM_OPIDPAGRecordOperation opidAGRecOp = new PRM_OPIDPAGRecordOperation(updateList);
        //This method will return map of salesfore acc id and list of discarded detachment inbound msgs, as one sfid may have multiple inbound messages
        discardedInboundMessagesMap = opidAGRecOp.inactivateCoreAccGrpMembers(InboundlistToInsert,logEntryMsgList); 
        if(logEntryMsgList.size()>0){
            logEntryMsg+=logEntryMsgList[0];
        }
        logEntryMsg+='\n*** The CAGs are inact. succ. for disassoc. ***';
       return InboundlistToInsert;
    }
    
    public InBoundMessageWrapper createInboundWrapper(Map<Id,Core_Account_Group_Member__c> existingCAGMap ,Id cagId,Map<String,Account> accOpidMap,Map<String,Account> opidnewAccMap,String opidValue){
        DateTime currDate =DateTime.now();
        InBoundMessageWrapper inboundwrapper= new InBoundMessageWrapper();
        inboundwrapper.SalesCloudAccountID =existingCAGMap.get(cagId).Core_Intel_Account_Id__c;
        inboundwrapper.Status ='NEW';
        if(accOpidMap.ContainsKey(opidValue)){
            inboundwrapper.StatusReason='Detach request created by SF as we have Inbound request to attach with'+' '+accOpidMap.get(opidValue).Id;
        }
        else if(opidnewAccMap.ContainsKey(opidValue)){
            inboundwrapper.StatusReason='Detach request created by SF as we have Inbound request to attach with'+' '+opidnewAccMap.get(opidValue).Id;
        }       
        inboundwrapper.OnePartnerAccountName=existingCAGMap.get(cagId).Core_Partner_Account_Id__r.Name;
        
        inboundwrapper.PartnerGroupingMethod =existingCAGMap.get(cagId).Core_Partner_Account_Id__r.Core_PAG_Grouping_Method__c;
        inboundwrapper.EffectiveEndDate=currDate.addDays(-1);
        inboundwrapper.Core_OnePartnerID=Integer.valueOf(existingCAGMap.get(cagId).Core_Partner_Account_Id__r.Core_OnePartnerID__c);
        
        return inboundwrapper;
    }
    
    private List<Core_OnePartner_Inbound_Message__c> getVerifiedInboundMessage(List<Core_OnePartner_Inbound_Message__c> listOfInboundMsg){
        logEntryMsg+='\n*get VerifiedInbMsg Method entered*';
        List<Core_OnePartner_Inbound_Message__c> verifiedInMessage = new List<Core_OnePartner_Inbound_Message__c>();
        List<Core_OnePartner_Inbound_Message__c> erroredOutINBRecords = new List<Core_OnePartner_Inbound_Message__c>();
        Map<String,List<Core_OnePartner_Inbound_Message__c>> mapOfSfInboundMessage = new  Map<String,List<Core_OnePartner_Inbound_Message__c>>();
        
        for(Core_OnePartner_Inbound_Message__c inboundMsg : listOfInboundMsg){
            if(String.IsBlank(inboundMsg.Core_SalesCloud_AccountID__c)){
                inboundMsg.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESS_FAILED;
                inboundMsg.Error_Description__c = System.Label.PRM_Blank_SFID_Error;
                erroredOutINBRecords.add(inboundMsg);
                logEntryMsg+='\n* Inb Msg with Id:'+inboundMsg.Id+'Status = FAILED Err :'+System.Label.PRM_Blank_SFID_Error+'*';
            }else{
                if(mapOfSfInboundMessage.containsKey(inboundMsg.Core_SalesCloud_AccountID__c)){
                    List<Core_OnePartner_Inbound_Message__c> listOfInMsg = mapOfSfInboundMessage.get(inboundMsg.Core_SalesCloud_AccountID__c);
                    listOfInMsg.add(inboundMsg);
                }else{
                    List<Core_OnePartner_Inbound_Message__c> listOfInMsgNew = new List<Core_OnePartner_Inbound_Message__c>();
                    listOfInMsgNew.add(inboundMsg);
                    mapOfSfInboundMessage.put(inboundMsg.Core_SalesCloud_AccountID__c,listOfInMsgNew);
                }
            }
        } 
        Map<id,Account> mapofAccount = new Map<id, Account>();
        for(Account a :[select id,Core_CIM_ID__c,Core_Business_Party_Id__c from account 
                        where id in :mapOfSfInboundMessage.keySet()]){
                            mapofAccount.put(a.id, a);
                        }
        logEntryMsg+='\n* Map of Act Id as Key :\n' +mapofAccount+'*';     
        for(String sfId : mapOfSfInboundMessage.keySet()){
            List<Core_OnePartner_Inbound_Message__c> listOfInMsg = mapOfSfInboundMessage.get(sfId);
            Account acc;
            try{
                acc = mapofAccount.get(sfId);             
            }catch(Exception e){
                for(Core_OnePartner_Inbound_Message__c inMsg :listOfInMsg){
                    inMsg.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESS_FAILED;
                    inMsg.Error_Description__c = System.Label.PRM_Invalid_SF_Id_Error;
                    erroredOutINBRecords.add(inMsg);
                    logEntryMsg+='\n* Inb msg Id:'+inMsg.Id+'Status = FAILED err :'+System.Label.PRM_Invalid_SF_Id_Error+'***';
                }
            }
            for(Core_OnePartner_Inbound_Message__c inMsg : listOfInMsg){
                if(acc == null && !erroredOutINBRecords.contains(inMsg)){
                    inMsg.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESS_FAILED;
                    inMsg.Error_Description__c = System.Label.PRM_Invalid_SF_Id_Error;
                    erroredOutINBRecords.add(inMsg);
                    logEntryMsg+='\n* Inb Msg Id:'+inMsg.Id+' Status = FAILED err : '+System.Label.PRM_Invalid_SF_Id_Error+'*';
                }else if((inMsg.Core_CIM_ID__c !=null || acc.Core_Business_Party_Id__c !=null) && acc != null ){ // TWC729-6744               //&& Integer.valueOf(inMsg.Core_CIM_ID__c) == Integer.valueOf(acc.Core_CIM_ID__c)
                    verifiedInMessage.add(inMsg);
                    logEntryMsg+='\n* Verified Inb Msg \n'+verifiedInMessage+'*';
                }
                //commented by dinesh as part of TWC729-121
                /*else if(!erroredOutINBRecords.contains(inMsg)){
                    inMsg.Core_Status__c = System.Label.PRM_INBOUNDMSG_PROCESS_FAILED;
                    inMsg.Error_Description__c = System.Label.PRM_CIM_ISSUE_MSG;
                    erroredOutINBRecords.add(inMsg);
                    logEntryMsg+='\n* Inb Msg with Id:'+inMsg.Id+'updated = Status err : '+System.Label.PRM_CIM_ISSUE_MSG+'*';
                }*/
            } 
        }
        List<Database.SaveResult> saveResultList =new List<Database.SaveResult>();
        if(erroredOutINBRecords != null){
            //US835505:update invalidCIMSfid 
            saveResultList = Database.update(erroredOutINBRecords,false);
            logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(erroredOutINBRecords, saveResultList,'Core_OnePartner_Inbound_Message__c');
        }
        logEntryMsg+='\n*get VerifiedInbMsg method executed succ.*';
        logEntryMsg+='\n*Inb Msg Rec verified success:'+verifiedInMessage+' *';
        //-----------------check heap size--------------        
        return verifiedInMessage;
    }
    
    
    global void finish(Database.BatchableContext bc) {
        //added by Anish - start
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,  
                            TotalJobItems, CreatedBy.Email 
                            FROM AsyncApexJob 
                            WHERE Id = :bc.getJobId()];        
        logEntryMsg+='\n*1st JOB END*';
        Integer numberofRecordstoProcess = !(Test.isRunningTest()) ? integer.valueof(System.Label.PRM_OPID_Batch_Processing) : 200;
        if(logEntryMsg!=''){// this block will create error log records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsg,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                //Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,logEntryMsg.split('@@@')[0] ,logEntryUtility.logEntryList[i] , '', '', '');
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY, 'Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');           
            }//loop ends here..
        }
        //PRM_ProcessRollUpDownOPIDRecords u = new PRM_ProcessRollUpDownOPIDRecords(opidIds,cagIds,intelAccountIds,inboundMessageforBatch2,accIdsForAccountRemoval,logEntryMsg);
        
            list<Core_OnePartner_Inbound_Message__c> listOfIncompleteInbound=new list<Core_OnePartner_Inbound_Message__c>();
            for(Core_OnePartner_Inbound_Message__c inboundMsg : listOfInboundsToProcess){
                if(inboundMsg.Core_Status__c!='LOAD COMPLETE'){
                    listOfIncompleteInbound.add(inboundMsg);
                }
            }
            if(!listOfIncompleteInbound.isempty())
            logEntryMsg+=PRM_OPIDProcessUtility.opidAssociationEmail(listOfAccIds,listOfIncompleteInbound,cagsToUpsertMap);
        
        PRM_ProcessRollUpDownOPIDRecords u = new PRM_ProcessRollUpDownOPIDRecords(intelAccountIds,cagsToUpsertMap); //TWC729-4387 
        Database.executeBatch(u,numberofRecordstoProcess);
        
        //added by Anish - end      
    }
    
    public class inBoundMessageWrapper{
        String SalesCloudAccountID;
        String Status;
        String StatusReason;
        String OnePartnerAccountName;
        String PrimeAccountName;
        DateTime EffectiveEndDate;
        Integer CIMId;
        Integer Core_OnePartnerID;
        String PartnerGroupingMethod;
    }
}