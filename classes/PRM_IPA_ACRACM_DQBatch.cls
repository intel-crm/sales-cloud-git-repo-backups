global class PRM_IPA_ACRACM_DQBatch implements Database.Batchable<sObject>,Database.stateful {
// Optional: Variables to maintain state across batches
    public String logEntryMsgString='';
    public static Final String ORIGIN  = 'PRM_IPA_ACRACM_DQBatch';
    public static Final String SEVERITY  = 'Error';
    public static Final String PROJECT  = 'IPA';
    public static Final String SCOPE  = 'ACR_ACM_DQ_Batch';
    public List<PRM_IPA_DQ_Logs__c> dqLogList = new List<PRM_IPA_DQ_Logs__c>();
    global Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
    // Start method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime lastSuccessfulRun;
        PRM_BatchCustomSetting__c batchCustomSetting;
        batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        Integer batchExecutionInterval = batchCustomSetting.PRM_SchedulingHour__c.intValue();
        DateTime batchExecutionHours = System.Now().addHours(- batchExecutionInterval);
        List<AsyncApexJob> lastBatchRun = [SELECT CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = 'PRM_IPA_ACRACM_DQBatch' AND Status =:System.Label.PRM_AsyncStatus Order By CompletedDate DESC LIMIT 1];
        if(lastBatchRun != NULL && !lastBatchRun.IsEmpty()){
            lastSuccessfulRun = (DateTime)lastBatchRun[0].CompletedDate;
            return database.getQueryLocator([SELECT Id, Name,Core_IPA_One_Partner_Id__c FROM Account WHERE RecordTypeId =:recordTypeIdAccount AND Core_Intel_Partner_Alliance_PartnerGroup__c =true AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun) AND lastmodifiedby.name!='IPA Data Migration User' ]);
        }else{
            return database.getQueryLocator([SELECT Id, Name,Core_IPA_One_Partner_Id__c FROM Account WHERE RecordTypeId =:recordTypeIdAccount AND Core_Intel_Partner_Alliance_PartnerGroup__c =true AND LastModifiedDate > :batchExecutionHours AND lastmodifiedby.name!='IPA Data Migration User' ]);
        }
    }
 
 
    // Execute method
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        //Scenario 1 : ACM Is not there in ipa acc, but if there is any active acr, we need to inactivate acr
        ////ACR without ACM record(acm deleted) acm is not there but pcr is active
        logEntryMsgString+='Inside execute method, scope size: '+scope.size();
         Decimal threshold=0;
            Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
            if(dqObjectsMap != null && !dqObjectsMap.isEmpty()){
                if(dqObjectsMap.containsKey('Threshold')){
                    threshold = Decimal.valueOf(String.valueOf(dqObjectsMap.get('Threshold').get('Threshold__c')));
                }
            }
        set<Id> accIds=new set<Id>();
            Set<Id> accIdsWithApprovedAcm = new Set<Id>();
            //map<id,string> mapAccIdWithoutStatus= new map<id,string>();
            //map<id,string> mapAccIdWithStatus= new map<id,string>();
            for (Account acc : scope) {
                accIds.add(acc.Id);
            }
            //list to store all intel acc acm
           //list<PRM_AccountChannelMembership__c> IntelLstAcms=[select id, PRM_Account_Id__c, PRM_Status_Nm__c from PRM_AccountChannelMembership__c  where PRM_Account_Id__c in: accIds AND PRM_Status_Nm__c = 'Approved'];
           //for (PRM_AccountChannelMembership__c acm:IntelLstAcms){
                /*if(acm.PRM_Status_Nm__c!='Approved')//even if there is not acm this condition satisfies
                    mapAccIdWithoutStatus.put(acm.PRM_Account_Id__c,acm.PRM_Status_Nm__c);*/
            for (PRM_AccountChannelMembership__c acm:[select PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in: accIds AND PRM_Status_Nm__c = 'Approved']){
               //if(acm.PRM_Status_Nm__c == 'Approved'){
               accIdsWithApprovedAcm.add(acm.PRM_Account_Id__c);
                    //mapAccIdWithStatus.put(acm.PRM_Account_Id__c,acm.PRM_Status_Nm__c);
               }
            list<PRM_Account_contact_relationship__c> acrLstToUpdate = new list<PRM_Account_contact_relationship__c>();
          for(PRM_Account_Contact_Relationship__c acr:[Select Id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c, PRM_Account_Id__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accIds and PRM_Status_Nm__c='Complete' and PRM_InActive_Ind__c=false]){
           //If in this map , the acr accid is not there that means there is no approved acm on the account , so inactivate your acr.
              if(!accIdsWithApprovedAcm.contains(acr.PRM_Account_Id__c)){
                acr.PRM_InActive_Ind__c=true;
                acr.PRM_Status_Reason_Txt__c='Inactivate ACR when no approved ACM exist on the IPA account.';
                acrLstToUpdate.add(acr);
            }
          }
            //Write dml
           //Scenario 2: Acm Roll up not proper
           //get the associated opid accounts
    //get the acm's of these opid
    //map<opid id,list<acm>>
    //get all the intel accounts associated with this opid
    //map<opid id ,list<location id>>
    //map<opid id, list<location acm>>--- u shld calculate what all acm shld be there
    //if map 1 and map3 are in sync correct on opid account and insert/update
    //now check if the opid has the acm which are there on intel account and if there is a discrepancy correct on opid account
    /*********************************************************************
    * Scenario 2 : ACM Rollup Correction
    *********************************************************************/
    //1. No acm of that type at all on opid, 2.acm with that partner role will be there but could be diff tier or status
    // Intel -> OPID Map
    // Map<Id,Id> intelToOpidMap = new Map<Id,Id>();
    // Set<Id> opidIds = new Set<Id>();
    // List<Core_Account_Group_Member__c> listOfCAG = [
    //     SELECT
    //         Core_Partner_Account_Id__c,
    //         Core_Intel_Account_Id__c,
    //         Core_Partner_Account_Id__r.Core_Deactivated__c
    //     FROM Core_Account_Group_Member__c
    //     WHERE Core_Intel_Account_Id__c IN :accIds
    //     AND Core_Inactive_Ind__c = false
    //     AND Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true
    //     AND Core_Partner_Account_Id__r.Core_Deactivated__c = false
    // ];
    // for(Core_Account_Group_Member__c cag : listOfCAG){
    //     intelToOpidMap.put(
    //         cag.Core_Intel_Account_Id__c,
    //         cag.Core_Partner_Account_Id__c
    //     );
    //     opidIds.add(cag.Core_Partner_Account_Id__c);
    // }
    // if(!opidIds.isEmpty()){
    //     /*****************************************************************
    //     * Get existing ACMs on OPID
    //     * Map<OPID , Map<Channel , ACM>>
    //     *****************************************************************/
    //    Map<Id, Map<String,PRM_AccountChannelMembership__c>>
    // opidAcmMap =
    // new Map<Id, Map<String,PRM_AccountChannelMembership__c>>();
    // List<PRM_AccountChannelMembership__c> opidAcms = [
    //     SELECT
    //         Id,
    //         PRM_Account_Id__c,
    //         PRM_Channel_Program_Id__c,
    //         PRM_Partner_Role__c,
    //         PRM_Channel_Program_Level_Id__c,
    //         PRM_Status_Nm__c,
    //         PRM_Status_Reason_Txt__c
    //     FROM PRM_AccountChannelMembership__c
    //     WHERE PRM_Account_Id__c IN :opidIds
    // ];
    // //opidAcmMap - opid to MAP<orog id,acm>
    //    for(PRM_AccountChannelMembership__c acm : opidAcms){
    //     if(!opidAcmMap.containsKey(acm.PRM_Account_Id__c)){
    //         opidAcmMap.put(
    //             acm.PRM_Account_Id__c,
    //             new Map<String,PRM_AccountChannelMembership__c>()
    //         );
    //     }
    //     String acmKey =
    //         acm.PRM_Channel_Program_Id__c +
    //         '|' +
    //         acm.PRM_Partner_Role__c;
    //     opidAcmMap.get(acm.PRM_Account_Id__c)
    //               .put(acmKey, acm);
    // }
 
    //     /*****************************************************************
    //     * Get all Intel Accounts under OPID
    //     * Map<OPID,List<Location>>
    //     *****************************************************************/
    //   Map<Id, Set<Id>> opidLocationMap = new Map<Id, Set<Id>>();
    // List<Core_Account_Group_Member__c> allCagRecords = [
    //     SELECT
    //         Core_Partner_Account_Id__c,
    //         Core_Intel_Account_Id__c
    //     FROM Core_Account_Group_Member__c
    //     WHERE Core_Partner_Account_Id__c IN :opidIds
    //     AND Core_Inactive_Ind__c = false
    //     AND Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true
    //     AND Core_Partner_Account_Id__r.Core_Deactivated__c = false
    // ];
    // for(Core_Account_Group_Member__c cag : allCagRecords){
    //     if(!opidLocationMap.containsKey(cag.Core_Partner_Account_Id__c)){
    //         opidLocationMap.put(
    //             cag.Core_Partner_Account_Id__c,
    //             new Set<Id>()
    //         );
    //     }
    //     opidLocationMap.get(cag.Core_Partner_Account_Id__c)
    //                    .add(cag.Core_Intel_Account_Id__c);
    // }
 
    //     /*****************************************************************
    //     * Get Location ACMs
    //     * Calculate what ACMs should exist on OPID
    //     * Map<OPID , Set<Channel>>
    //     *****************************************************************/
    //     Set<Id> allLocationIds = new Set<Id>();
    //     for(Set<Id> ids : opidLocationMap.values()){
    //         allLocationIds.addAll(ids);
    //     }
    //     Map<Id, Map<String,PRM_AccountChannelMembership__c>>
    // expectedAcmMap =
    // new Map<Id, Map<String,PRM_AccountChannelMembership__c>>();
    // for(PRM_AccountChannelMembership__c locationAcm : [
    //     SELECT
    //         Id,
    //         PRM_Account_Id__c,
    //         PRM_Channel_Program_Id__c,
    //         PRM_Partner_Role__c,
    //         PRM_Channel_Program_Level_Id__c,
    //         PRM_Status_Nm__c
    //     FROM PRM_AccountChannelMembership__c
    //     WHERE PRM_Account_Id__c IN :allLocationIds
    // AND PRM_Status_Nm__c = 'Approved'
    // ]){
    //     Id opidId =
    //         intelToOpidMap.get(locationAcm.PRM_Account_Id__c);
    //     if(opidId == null){
    //         continue;
    //     }
    //     if(!expectedAcmMap.containsKey(opidId)){
    //         expectedAcmMap.put(
    //             opidId,
    //             new Map<String,PRM_AccountChannelMembership__c>()
    //         );
    //     }
    //     String acmKey =
    //         locationAcm.PRM_Channel_Program_Id__c +
    //         '|' +
    //         locationAcm.PRM_Partner_Role__c;
    //     expectedAcmMap.get(opidId)
    //                   .put(acmKey, locationAcm);
    // }
    //     /*****************************************************************
    //     * Compare Expected vs Existing
    //     *****************************************************************/
    //     List<PRM_AccountChannelMembership__c> acmsToInsert = new List<PRM_AccountChannelMembership__c>();
    //     List<PRM_AccountChannelMembership__c> acmsToUpdate = new List<PRM_AccountChannelMembership__c>();
    //  for(Id opidId : expectedAcmMap.keySet()){
    //     Map<String,PRM_AccountChannelMembership__c> expectedAcms =
    //         expectedAcmMap.get(opidId);
    //     Map<String,PRM_AccountChannelMembership__c> existingAcms =
    //         opidAcmMap.containsKey(opidId)
    //         ? opidAcmMap.get(opidId)
    //         : new Map<String,PRM_AccountChannelMembership__c>();
    //     for(String acmKey : expectedAcms.keySet()){
    //         PRM_AccountChannelMembership__c expectedAcm =
    //             expectedAcms.get(acmKey);
    //         if(!existingAcms.containsKey(acmKey)){
    //             PRM_AccountChannelMembership__c newAcm =
    //                 new PRM_AccountChannelMembership__c();
    //             newAcm.PRM_Account_Id__c =
    //                 opidId;
    //             newAcm.PRM_Channel_Program_Id__c =
    //                 expectedAcm.PRM_Channel_Program_Id__c;
    //             newAcm.PRM_Partner_Role__c =
    //                 expectedAcm.PRM_Partner_Role__c;
    //             newAcm.PRM_Channel_Program_Level_Id__c=
    //                 expectedAcm.PRM_Channel_Program_Level_Id__c;
    //             newAcm.PRM_Status_Nm__c =
    //                 expectedAcm.PRM_Status_Nm__c;
    //             newAcm.PRM_Status_Reason_Txt__c='Rollup ACM.';
    //             acmsToInsert.add(newAcm);
    //         }
    //         else{
    //             PRM_AccountChannelMembership__c existingAcm =
    //                 existingAcms.get(acmKey);
    //     Boolean updateNeeded = false;
    // existingAcm.PRM_Status_Reason_Txt__c='Update ACM for Rollup.';
    // if(existingAcm.PRM_Status_Nm__c
    //     != expectedAcm.PRM_Status_Nm__c){
    //     existingAcm.PRM_Status_Nm__c =
    //         expectedAcm.PRM_Status_Nm__c;
    //     updateNeeded = true;
    // }
    // if(existingAcm.PRM_Channel_Program_Level_Id__c
    //     != expectedAcm.PRM_Channel_Program_Level_Id__c){
    //     existingAcm.PRM_Channel_Program_Level_Id__c =
    //         expectedAcm.PRM_Channel_Program_Level_Id__c;
    //     updateNeeded = true;
    // }
    // if(updateNeeded){
    //     acmsToUpdate.add(existingAcm);
    // }
    //         }
    //     }
    //    for(String existingKey : existingAcms.keySet()){
    //     if(!expectedAcms.containsKey(existingKey)){
    //         PRM_AccountChannelMembership__c existingAcm =
    //             existingAcms.get(existingKey);
    //         if(existingAcm.PRM_Status_Nm__c == 'Approved'){
    //             existingAcm.PRM_Status_Nm__c = 'Inactive'; // use actual status value
    //             acmsToUpdate.add(existingAcm);
    //         }
    //     }
    // }
    // }
 
 
    //     if(!acmsToInsert.isEmpty()){
    //         //insert acmsToInsert;
    //         //Database.SaveResult[] acmInsertResults = Database.insert(acmsToInsert, false);
    //         upsertData(acmsToInsert,'PRM_AccountChannelMembership__c',threshold);
    //     }
    //     if(!acmsToUpdate.isEmpty()){
    //         //update acmsToUpdate;
    //         //Database.SaveResult[] acmUpdateResults = Database.update(acmsToUpdate, false);
    //         upsertData(acmsToUpdate,'PRM_AccountChannelMembership__c',threshold);
    //     }
    // }
    /*********************************************************************
    * Scenario 3 : OPID stamped without active CAG
    *********************************************************************/
    List<Account> intelAccountsToUpdate = new List<Account>();
    Map<Id,Account> intelAccMap = new Map<Id,Account>();
            for(Account acc : scope){
                if(acc.Core_IPA_One_Partner_Id__c != null){
                    intelAccMap.put(acc.Id, acc);
                }
            }
 
    Set<String> activeCagKeys = new Set<String>();
    for(Core_Account_Group_Member__c cag : [
        SELECT Core_Intel_Account_Id__c,
               Core_Partner_Account_Id__c
        FROM Core_Account_Group_Member__c
        WHERE Core_Intel_Account_Id__c IN :intelAccMap.keySet()
        AND Core_Inactive_Ind__c = false
    ]){
        activeCagKeys.add(
            cag.Core_Intel_Account_Id__c +
            '-' +
            cag.Core_Partner_Account_Id__c
        );
    }
    for(Account intelAcc : intelAccMap.values()){
        String key =
            intelAcc.Id +
            '-' +
            intelAcc.Core_IPA_One_Partner_Id__c;
        if(!activeCagKeys.contains(key)){
            intelAcc.Core_IPA_One_Partner_Id__c = null;
            intelAccountsToUpdate.add(intelAcc);
        }
    }
            /*********************************************************************
    * Scenario 4 : Active CAG to Deactivated OPID
    *********************************************************************/
    List<Core_Account_Group_Member__c> cagsToUpdate =
        new List<Core_Account_Group_Member__c>();
    for(Core_Account_Group_Member__c cag : [
        SELECT Id,
               Core_Inactive_Ind__c,
               Core_Partner_Account_Id__r.Core_Deactivated__c
        FROM Core_Account_Group_Member__c
        WHERE Core_Inactive_Ind__c = false
        AND Core_Partner_Account_Id__r.Core_Deactivated__c = true
        AND Core_Intel_Account_Id__c IN :accIds
        ]){
            cag.Core_Inactive_Ind__c = true;
            cagsToUpdate.add(cag);
        }
            if(!acrLstToUpdate.isEmpty()){
                //update acrLstToUpdate;
                //Database.SaveResult[] acrResults = Database.update(acrLstToUpdate, false);
                upsertData(acrLstToUpdate,'Account_Contact_Relationship',threshold);
            }
            if(!intelAccountsToUpdate.isEmpty()){
                //update intelAccountsToUpdate;
                //Database.SaveResult[] intelAccResults = Database.update(intelAccountsToUpdate, false);
                upsertData(intelAccountsToUpdate,'Account_CAG',threshold);
            }
            if(!cagsToUpdate.isEmpty()){
                //update cagsToUpdate;
                //Database.SaveResult[] cagResults = Database.update(cagsToUpdate, false);
                upsertData(cagsToUpdate,'Core_Account_Group_Member__c',threshold);
            }
        }
     public void sendWarningEmail(List<sObject> dmlList, String objectName){
        try{
            Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
            // Get scenario description from custom metadata using helper method
            String scenarioDescription = '';
             // Get scenario description based on object name
            if(dqObjectsMap != null && !dqObjectsMap.isEmpty()){
                for(String metadataRec : dqObjectsMap.keySet()){
                    if(dqObjectsMap.get(metadataRec).get('Object__c') == objectName){
                        scenarioDescription = (String)dqObjectsMap.get(metadataRec).get('Scenario__c');
                        break;
                    }
                }
            }
            // Fallback to default message if no scenario found
            if(String.isEmpty(scenarioDescription)){
                scenarioDescription = 'Exception Unknown.';
            }
            // Prepare placeholder map similar to opidAssociationEmail
            Map<String,String> placeholderMap = new Map<String,String>();
            placeholderMap.put('%ObjectName%', objectName);
            placeholderMap.put('%RecordCount%', String.valueOf(dmlList.size()));
            placeholderMap.put('%ScenarioDescription%', scenarioDescription != null ? scenarioDescription : 'Records will be updated as part of PRM_IPA_ACRACM_DQBatch processing.');
            placeholderMap.put('%ProcessDate%', String.valueOf(System.today()));
            // Call email utility from PRM_OPIDProcessUtility
            PRM_OPIDProcessUtility.callSendEmailUtil(placeholderMap, 'IPA_DQ_Email');
            PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
            dqLog.PRM_Object_Name__c=objectName;
            dqLog.PRM_Message__c = scenarioDescription;
            dqLog.PRM_Apex_Class_Name__c = 'PRM_IPA_ACRACM_DQBatch';
            dqLogList.add(dqLog);
 
           
            logEntryMsgString += '\n[WarningEmailSent] Using PRM_EmailUtility for ' + objectName + ' with ' + dmlList.size() + ' records';
        } catch(Exception e){
            logEntryMsgString += '\n[WarningEmailSendFailed] ' + e.getMessage();
        }
    }
 
    // Finish method
    global void finish(Database.BatchableContext bc) {
 
        try{
            List<Database.SaveResult> dqResultList = Database.insert(dqLogList,false);
            for(Database.SaveResult dqResult: dqResultList){
                if(!dqResult.isSuccess()){
                    for (Database.Error err : dqResult.getErrors()) {
                        logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'  + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode() + '\n';
                    }
                }
            }
        }
        catch(Exception ex){
            logEntryMsgString+='\n errors:'+ex;
        }
        string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                Core_Log_Entry.logEntryWithDetails('PRM_IPA_ACRACM_DQBatch', 'IPA', 'PRM_IPA_ACRACM_DQBatch', 'Medium','Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
            }
        }
        // Optional:
        // Send email
        // Chain another batch
        // Schedule another job
    }
    public void upsertData(List<SObject> newLst,String objectName,Decimal threshold)
   {
      
        if(newLst == null || newLst.isEmpty()) {
            return;
        }
        if(threshold > 0 && newLst.size() >= threshold){
            sendWarningEmail(newLst,objectName);
            return;
        }
        Database.UpsertResult[] urList =Database.upsert(newLst, false);
        Integer index = 0;
        for(Database.UpsertResult ur : urList){
            if(!ur.isSuccess()){
                SObject currentRecord = newLst[index];
                Id sId = currentRecord.Id;
                String sObjectType = '';
                String tags = '';
                if(sId != null){
                    sObjectType =sId.getSObjectType().getDescribe().getName();
                }
                for(Database.Error err : ur.getErrors()){
                    PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
                    dqLog.PRM_Object_Name__c=sObjectType;
                    dqLog.PRM_Message__c = err.getMessage();
                    dqLog.PRM_Apex_Class_Name__c = 'PRM_IPA_ACRACM_DQBatch';
                    dqLogList.add(dqLog);
                 }
            }
            index++;
        }
 
 
    }
 
   
    public  Map<String, Map<String, Object>> getCustomMetadataRecords (){
        Map<String, Map<String, Object>> dqObjectsMap = new Map<String, Map<String, Object>>();
        Core_CustomMetadataObjectController customMetadataController = new Core_CustomMetadataObjectController('DQ_Objects_mdt');
        dqObjectsMap = customMetadataController.getAll();
        return dqObjectsMap;
    }
}