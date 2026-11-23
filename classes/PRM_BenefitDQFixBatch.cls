/***************************************************************************************************************************************
Apex Class Name     : PRM_BenefitDQFixBatch
Version             : 1.0
Created Date        : May 2026
Function            : Batch class to fix benefits based on ACM
Maximum Batch Size  : 100
Modification Log    :
* Developer                         Date                           Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------
* Ruchi                       24th May 2026                     Start Method returns all the ACMs which are modified in Last specified number of hours.
*************************************************************************************************************************************************************/


global class PRM_BenefitDQFixBatch implements Database.Batchable<sObject>,Database.stateful {
    public String logEntryMsgString = '';
    public List<PRM_AccountBenefitAssociation__c> abasToUpdate = new List<PRM_AccountBenefitAssociation__c>();
    public Set<PRM_AccountBenefitAssociation__c> abasToUpsert = new Set<PRM_AccountBenefitAssociation__c>();
    public List<Core_Account_Group_Member__c> cagsToUpdate = new List<Core_Account_Group_Member__c>();
    public List<PRM_IPA_DQ_Logs__c> dqLogList = new List<PRM_IPA_DQ_Logs__c>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime lastSuccessfulRun;
        PRM_BatchCustomSetting__c batchCustomSetting;
        batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        Integer batchExecutionInterval = batchCustomSetting.PRM_SchedulingHour__c.intValue();
        DateTime batchExecutionHours = System.Now().addHours(- batchExecutionInterval);
        //Query on AsyncApexJob to get the identical records which got modified in last 6 hrs.
        List<AsyncApexJob> lastBatchRun = [SELECT CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = 'PRM_BenefitDQFixBatch' AND Status =:System.Label.PRM_AsyncStatus Order By CompletedDate DESC LIMIT 1];
        
        //The batch picks all ACM Records last modified post the last batch run
        String query='Select Id, PRM_Account_Id__c,PRM_Status_Nm__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,PRM_Tier_Name_txt__c,createddate,PRM_Partner_Role__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Account_Id__r.Core_Business_Party_Id__c,PRM_Account_Id__r.Core_Parent_Business_Party_Id__c,PRM_Account_Id__r.Core_Unified_Global_Customer_BP_Id__c,PRM_Account_Id__r.Core_Customer_Aggregation_Type__c,PRM_Account_Id__r.Core_Unified_Global_Customer_Name__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =\'Intel Partner Alliance\' AND PRM_Channel_Program_Level_Id__r.PRM_inactind__c =false' ;
        
        if(lastBatchRun != NULL && !lastBatchRun.IsEmpty()){
            lastSuccessfulRun = (DateTime)lastBatchRun[0].CompletedDate;
            query+=' AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun) AND lastmodifiedby.name!=\'IPA Data Migration User\'';
        }else{
            query+=' AND LastModifiedDate > :batchExecutionHours AND lastmodifiedby.name!=\'IPA Data Migration User\'';
        }
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext context, List<PRM_AccountChannelMembership__c> scope){
        Set<String> accountIds = new Set<String>();
        Set<String> triggeringAcmIds = new Set<String>();
        Map<String,List<PRM_AccountChannelMembership__c>> approvedAccAcmMap = new Map<String,List<PRM_AccountChannelMembership__c>>();
        Map<String,List<PRM_AccountChannelMembership__c>> inactiveAccAcmMap = new Map<String,List<PRM_AccountChannelMembership__c>>();
        Map<String,List<PRM_Account_Contact_Relationship__c>> ipaAccAcrs = new Map<String,List<PRM_Account_Contact_Relationship__c>>();
        for(PRM_AccountChannelMembership__c acm: scope){
            if(acm.PRM_Status_Nm__c=='Approved'){
                if(!approvedAccAcmMap.containsKey(acm.PRM_Account_Id__c)){
                    approvedAccAcmMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
                }else {
                    approvedAccAcmMap.get(acm.PRM_Account_Id__c).add(acm);
                }
            }else if( acm.PRM_Status_Nm__c =='Inactive'){
                if(!inactiveAccAcmMap.containsKey(acm.PRM_Account_Id__c)){
                    inactiveAccAcmMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
                } else {
                    inactiveAccAcmMap.get(acm.PRM_Account_Id__c).add(acm);
                }
            }
            //Account Ids of all the ACMs retrieved
            accountIds.add(acm.PRM_Account_Id__c);
            triggeringAcmIds.add(acm.id);
        }
        //1a-------Active ABA with inactive ACM
        Set<Id> approvedAccountIds = new Set<Id>();
        for(PRM_AccountChannelMembership__c acm : [SELECT PRM_Account_Id__c FROM PRM_AccountChannelMembership__c WHERE PRM_Status_Nm__c = 'Approved' AND PRM_Account_Id__c IN :accountIds]){
            approvedAccountIds.add(acm.PRM_Account_Id__c);
        }
        
        List<PRM_AccountBenefitAssociation__c> toBeUpdatedABAs = [SELECT id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Status_Nm__c = 'Active' AND PRM_Account_Id__c in :accountIds AND PRM_Account_Id__c NOT IN :approvedAccountIds];
        for(PRM_AccountBenefitAssociation__c aba : toBeUpdatedABAs){
            aba.PRM_Status_Nm__c = 'Inactive';
            aba.PRM_Status_Reason_Txt__c = 'Benefit inactivated due to ACM inactivation';
        }
        
        //1b--------Inactive ABA with Activate ACM - Acc to benefit matrix
        Set<PRM_AccountBenefitAssociation__c> allAbasToUpsert = new Set<PRM_AccountBenefitAssociation__c>();
        List<Account> approvedAcmAccounts = [SELECT Id, Core_IPA_One_Partner_Id__c,(SELECT Id, PRM_Partner_Role__c, PRM_Channel_Program_Level_Id__r.Name, PRM_Status_Nm__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c='Approved') FROM Account WHERE RecordType.Name = 'Partner Account Group' AND Core_Deactivated__c = false and ID IN: accountIds];
        List<PRM_VXBnftMatrix__c> benefitMatrixList = new List<PRM_VXBnftMatrix__c>();
        try {
            benefitMatrixList = [SELECT Id, PRM_BenfitMatrix_Combination__c, PRM_Channel_Program_Id__c, PRM_Covered_Account_Ind__c,PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c, PRM_Partner_Benefit_Id__r.Name,
                                 PRM_Approval_Type_Nm__c, PRM_Channel_Program_Level_Id__r.Name, PRM_Partner_Role_Nm__c,
                                 PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c FROM PRM_VXBnftMatrix__c
                                 WHERE PRM_IsActive_Ind__c = true
                                 AND PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group'
                                 AND PRM_Partner_Benefit_Id__r.PRM_InActive_Ind__c = false  
                                 AND (PRM_Channel_Program_Level_Id__r.Name = 'Partner' OR PRM_Channel_Program_Level_Id__r.Name = 'Prestige')]; // need to add filter for prestige and partner, Verify that Benefit matrix is loaded with new tier values-- Varun
        }catch (Exception ex) {
            logEntryMsgString += '\n[BenefitMatrixFetchFailed] ' + ex.getMessage();
        }
        // Prepare Account -> ACM mapping
        Map<Id, List<PRM_AccountChannelMembership__c>> accountIdAcmMap = new Map<Id, List<PRM_AccountChannelMembership__c>>();
        Set<Id> accIds = new Set<Id>();
        for (Account acc : approvedAcmAccounts) {
            if (acc.Channel_Memberships1__r != null && acc.Channel_Memberships1__r.size() > 0) {
                accIds.add(acc.Id);
                accountIdAcmMap.put(acc.Id, acc.Channel_Memberships1__r);
                //PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
                //acm = acc.Channel_Memberships1__r;
                //actIdRoleTierMap.put(acc.Id, acm.PRM_Partner_Role__c+'-'+acm.PRM_Channel_Program_Level_Id__c);
            }
        }
        // Fetch existing ABA records
        Map<String, Set<PRM_AccountBenefitAssociation__c>> accBenMap = new Map<String, Set<PRM_AccountBenefitAssociation__c>>();
        try {
            for (PRM_AccountBenefitAssociation__c aba : [SELECT Id, Name, PRM_Status_Nm__c, PRM_Account_Id__c, PRM_Partner_Benefit_Id__c,PRM_Source__c,
                                                         PRM_Partner_Benefit_Id__r.Name
                                                         FROM PRM_AccountBenefitAssociation__c
                                                         WHERE PRM_Account_Id__c IN :accIds]) {
                                                             if (!accBenMap.containsKey(aba.PRM_Account_Id__c)){
                                                                 accBenMap.put(aba.PRM_Account_Id__c, new Set<PRM_AccountBenefitAssociation__c>());
                                                             }
                                                             accBenMap.get(aba.PRM_Account_Id__c).add(aba);
                                                         }
        } catch (Exception ex) {
            logEntryMsgString += '\n[Failed to Fetch ABA Records] ' + ex.getMessage();
        }
        // Process Matrix
        Map<String, Set<String>> roleTierBenefitMap = new Map<String, Set<String>>();
        Map<String, Set<String>> manualBenefitMap = new Map<String, Set<String>>();
        
        for (PRM_VXBnftMatrix__c vx : benefitMatrixList) {
            String key = vx.PRM_Channel_Program_Level_Id__r.Name + ':' + vx.PRM_Partner_Role_Nm__c;
            if (vx.PRM_Approval_Type_Nm__c == 'Automatic') {
                if (!roleTierBenefitMap.containsKey(key)) {
                    roleTierBenefitMap.put(key, new Set<String>());
                }
                if (!roleTierBenefitMap.get(key).contains(vx.PRM_Partner_Benefit_Id__c)) {
                    roleTierBenefitMap.get(key).add(vx.PRM_Partner_Benefit_Id__c);
                }
            } else {
                if (!manualBenefitMap.containsKey(key)) {
                    manualBenefitMap.put(key, new Set<String>());
                }
                manualBenefitMap.get(key).add(vx.PRM_Partner_Benefit_Id__c);
            }
        }
        
        // Build account benefit map
        Map<Id, Set<String>> accountBenefitMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> accountManualBenefitMap = new Map<Id, Set<String>>();
        
        for (Id accId : accIds) {
            List<PRM_AccountChannelMembership__c> acmSet = accountIdAcmMap.get(accId);
            
            for (PRM_AccountChannelMembership__c acm : acmSet) {
                Set<String> keys = new Set<String>();
                String key1 = 'Partner:' + acm.PRM_Partner_Role__c;
                
                if (acm.PRM_Channel_Program_Level_Id__r.Name == 'Prestige') {
                    String Key = 'Prestige' + ':' + acm.PRM_Partner_Role__c;
                    keys.add(Key);
                }
                keys.add(key1);               
                for (String applicableTier : keys) {
                    // Add automatic (tier) benefits
                    if (roleTierBenefitMap.containsKey(applicableTier)) {
                        if (!accountBenefitMap.containsKey(accId)) {
                            accountBenefitMap.put(accId, roleTierBenefitMap.get(applicableTier));
                        }
                        accountBenefitMap.get(accId).addAll(roleTierBenefitMap.get(applicableTier));
                    }
                    
                    // Add manual benefits
                    if (manualBenefitMap.containsKey(applicableTier)) {
                        if (!accountManualBenefitMap.containsKey(accId)) {
                            accountManualBenefitMap.put(accId, manualBenefitMap.get(applicableTier));
                        }
                        accountManualBenefitMap.get(accId).addAll(manualBenefitMap.get(applicableTier));
                    }
                }
            }
        }
        
        // Prepare benefit records to upsert
        //Set<PRM_AccountBenefitAssociation__c> abaToUpdate = new Set<PRM_AccountBenefitAssociation__c>();
        Map<Id, Set<PRM_AccountBenefitAssociation__c>> accountWiseABAs = new Map<Id, Set<PRM_AccountBenefitAssociation__c>>();
        
        for (Id accId : accountBenefitMap.keySet()) {
            Set<PRM_AccountBenefitAssociation__c> abaToUpdate = new Set<PRM_AccountBenefitAssociation__c>();
            Set<String> currentBenefits = accountBenefitMap.get(accId);
            Set<String> manualBenefits = accountManualBenefitMap.containsKey(accId)
                ? accountManualBenefitMap.get(accId)
                : new Set<String>();
            Set<PRM_AccountBenefitAssociation__c> existingAbas = accBenMap.containsKey(accId)
                ? accBenMap.get(accId)
                : new Set<PRM_AccountBenefitAssociation__c>();
            
            Set<String> existingBenefitIds = new Set<String>();
            Set<String> addedBenefitIds = new Set<String>();
            for (PRM_AccountBenefitAssociation__c aba : existingAbas) {
                existingBenefitIds.add(aba.PRM_Partner_Benefit_Id__c);
                
                if (currentBenefits.contains(aba.PRM_Partner_Benefit_Id__c) && aba.PRM_Status_Nm__c == 'Inactive'  && !addedBenefitIds.contains(aba.PRM_Partner_Benefit_Id__c)) {
                    aba.PRM_Status_Nm__c = 'Active';
                    aba.PRM_Status_Reason_Txt__c = 'Activated as part of IPA Refresh';
                    abaToUpdate.add(aba);
                    addedBenefitIds.add(aba.PRM_Partner_Benefit_Id__c);
                } else if (!currentBenefits.contains(aba.PRM_Partner_Benefit_Id__c) &&
                           !manualBenefits.contains(aba.PRM_Partner_Benefit_Id__c) && aba.PRM_Status_Nm__c == 'Active') {
                               aba.PRM_Status_Nm__c = 'Inactive';
                               aba.PRM_Status_Reason_Txt__c = 'Inactivated as part of IPA Refresh';
                               abaToUpdate.add(aba);
                           }
            }
      
            //Set<String> addedBenefitIds = new Set<String>();
            for (String benefitId : currentBenefits) {
                if (!existingBenefitIds.contains(benefitId) && !addedBenefitIds.contains(benefitId)) {
                    PRM_AccountBenefitAssociation__c newAba = new PRM_AccountBenefitAssociation__c();
                    newAba.PRM_Account_Id__c = accId;
                    newAba.PRM_Partner_Benefit_Id__c = benefitId;
                    newAba.PRM_Status_Nm__c = 'Active';
                    newAba.PRM_Source__c = 'Tier';
                    newAba.PRM_Status_Reason_Txt__c = 'Inserted & activated as part of IPA Refresh';
                    abaToUpdate.add(newAba);
                    addedBenefitIds.add(benefitId);
                }
            }
            accountWiseABAs.put(accId, new Set<PRM_AccountBenefitAssociation__c>(abaToUpdate));
        }
        
        Map<Id, Set<String>> accIdToMessages = new Map<Id, Set<String>>();
        
        // Flatten for upsert
        for (Set<PRM_AccountBenefitAssociation__c> abas : accountWiseABAs.values()) {
            allAbasToUpsert.addAll(abas);
        }
        
       /* //2-----Active cag in deactivated 1pid and no active acm
        List<Core_Account_Group_Member__c> toBeUpdatedCAGs = [SELECT id,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c,Comments__c  FROM Core_Account_Group_Member__c WHERE Core_Inactive_Ind__c = false AND Core_Partner_Account_Id__r.Core_Deactivated__c = true AND Core_Partner_Account_Id__c in :accountIds AND Core_Partner_Account_Id__c NOT IN :approvedAccountIds];
        for(Core_Account_Group_Member__c cag : toBeUpdatedCAGs ){
            cag.Core_Inactive_Ind__c = true ;
            cag.Comments__c  = 'CAG inactivation as no active ACM and linked to deactivated 1PID';
        }*/
        // 1A - Inactivate ABAs due to no approved ACM
        if (!toBeUpdatedABAs.isEmpty()) {
            abasToUpdate.addAll(toBeUpdatedABAs);
        }
        // 1B - Activate/Insert/Inactivate ABAs based on Benefit Matrix
        if (!allAbasToUpsert.isEmpty()) {
            abasToUpsert.addAll(allAbasToUpsert);
        }
        /*// 2 - Inactivate CAGs
        if (!toBeUpdatedCAGs.isEmpty()) {
            cagsToUpdate.addAll(toBeUpdatedCAGs);
        }*/
        
    }
    
    public void sendWarningEmail(Integer recordCount,String objectName){
        try{
            Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
            String scenarioDescription = '';
            if(dqObjectsMap != null && !dqObjectsMap.isEmpty()){
                
                for(String metadataRec : dqObjectsMap.keySet()){
                    if(dqObjectsMap.get(metadataRec).get('Object__c') == objectName){
                        scenarioDescription = (String)dqObjectsMap.get(metadataRec).get('Scenario__c');
                        break;
                    }
                }
            }
            
            if(String.isBlank(scenarioDescription)){
                scenarioDescription = 'Threshold exceeded for processing.';
            }
            
            Map<String,String> placeholderMap = new Map<String,String>();
            placeholderMap.put('%ObjectName%',objectName);
            placeholderMap.put('%RecordCount%',String.valueOf(recordCount));
            placeholderMap.put('%ScenarioDescription%',scenarioDescription);
            placeholderMap.put('%ProcessDate%',String.valueOf(System.today()));
            PRM_OPIDProcessUtility.callSendEmailUtil(placeholderMap,'IPA_DQ_Email');
            PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
            dqLog.PRM_Object_Name__c = objectName;
            dqLog.PRM_Message__c = scenarioDescription +' Record Count: ' + recordCount;
            dqLog.PRM_Apex_Class_Name__c ='PRM_BenefitDQFixBatch';
            dqLogList.add(dqLog);
            logEntryMsgString += '\n[WarningEmailSent] ' + objectName + ' Count: ' + recordCount;
        }catch(Exception e){
            logEntryMsgString +='\n[WarningEmailSendFailed] ' + e.getMessage();
        }
    }
    public void handleResult(List<Database.SaveResult> result,String objectName){
        String message ='Time : '+ String.valueOf(System.now());
        for(Database.SaveResult sr : result){
            if(!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()){
                    logEntryMsgString += '\nMessage : '+ err.getMessage()+ '\nStatusCode : '+ err.getStatusCode();
                }
            }else{
                if(objectName == 'PRM_AccountBenefitAssociation__c'){
                    message += '\nBenefit Deactivated due to ACM inactivation.RecordId:: '+ sr.getId();
                }
                /*else if(objectName == 'Core_Account_Group_Member__c'){
                    message += '\nCAG Deactivated due to Inactive ACM and deactivated 1PID.RecordId: '+ sr.getId();
                    
                }*/
                
            }
        }
        
        PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
        dqLog.PRM_Object_Name__c = objectName;
        dqLog.PRM_Message__c = message;
        dqLog.PRM_Apex_Class_Name__c ='PRM_BenefitDQFixBatch';
        dqLogList.add(dqLog);
    }
    public void handleUpsertResult(List<Database.UpsertResult> result,String objectName){
        
        String message ='Time : '+ String.valueOf(System.now());
        for(Database.UpsertResult sr : result){
            if(!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()){
                    
                    logEntryMsgString +='\nMessage : '+ err.getMessage()+ '\nStatusCode : '+ err.getStatusCode();
                }
            }else{
                if(objectName == 'PRM_AccountBenefitAssociation__c(Benefit Matrix Sync)'){
                    message += '\nBenefit activated/inserted based on Benefit Matrix eligibility.RecordId: '+ sr.getId();
                }
            }
        }
        PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
        dqLog.PRM_Object_Name__c =objectName;
        dqLog.PRM_Message__c = message;
        dqLog.PRM_Apex_Class_Name__c ='PRM_BenefitDQFixBatch';
        
        dqLogList.add(dqLog);
    }
    
    global void finish(Database.BatchableContext context){
        try{
            Decimal threshold = 0;
            Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
            if(dqObjectsMap != null &&!dqObjectsMap.isEmpty() && dqObjectsMap.containsKey('Threshold')){
                threshold = Decimal.valueOf(String.valueOf(dqObjectsMap.get('Threshold').get('Threshold__c')));
            }
            Set<Id> impactedAccountIds = new Set<Id>();
            for(PRM_AccountBenefitAssociation__c aba : abasToUpdate){
                if(aba.PRM_Account_Id__c != null){
                    impactedAccountIds.add(aba.PRM_Account_Id__c);
                }
            }
            for(PRM_AccountBenefitAssociation__c aba : abasToUpsert){
                if(aba.PRM_Account_Id__c != null){
                    impactedAccountIds.add(aba.PRM_Account_Id__c);
                }
            }
            Integer accountCount = impactedAccountIds.size();
            
            /*ABA Updates*/
            if(!abasToUpdate.isEmpty()){
                if(accountCount < threshold){
                    List<Database.SaveResult> abaResults =Database.update(abasToUpdate,false);
                    handleResult(abaResults,'PRM_AccountBenefitAssociation__c');
                }else{
                    sendWarningEmail(accountCount,'PRM_AccountBenefitAssociation__c');
                }
            }
            /*ABA Upserts*/
            if(!abasToUpsert.isEmpty()){
                List<PRM_AccountBenefitAssociation__c> abaList =new List<PRM_AccountBenefitAssociation__c>();
                abaList.addAll(abasToUpsert);
                if(accountCount < threshold){
                    List<Database.UpsertResult> upsertResults =Database.upsert(abaList,false);
                    handleUpsertResult(upsertResults,'PRM_AccountBenefitAssociation__c(Benefit Matrix Sync)');
                }else{
                    sendWarningEmail(accountCount,'PRM_AccountBenefitAssociation__c(Benefit Matrix Sync)');
                }
            }
            /* CAG Updates*/
            /*if(!cagsToUpdate.isEmpty()){
                if(cagsToUpdate.size() < threshold){
                    List<Database.SaveResult> cagResults =Database.update(cagsToUpdate,false);
                    handleResult(cagResults,'Core_Account_Group_Member__c');
                }else{
                    sendWarningEmail(cagsToUpdate.size(),'Core_Account_Group_Member__c');
                }
            }*/
            /*Insert DQ Logs*/
            if(!dqLogList.isEmpty()){
                Database.insert(dqLogList,false);
            }
        }catch(Exception ex){
            logEntryMsgString +='\nFinish Method Error : '+ ex.getMessage();
        }
        String jobInitiatedDateTime = System.Now().format('MM/dd/yyyy HH:MM:ss','PST');
        if(logEntryMsgString != ''){
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility = new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength = Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i = 0;i < logEntryUtility.logEntryList.size();i++){
                Core_Log_Entry.logEntryWithDetails('PRM_BenefitDQFixBatch','IPA','PRM_BenefitDQFixBatch','Medium','Job started at: ' + jobInitiatedDateTime +' PST',logEntryUtility.logEntryList[i],'', '', '');
                }
           }
    }
    public Map<String, Map<String, Object>> getCustomMetadataRecords(){
        Map<String, Map<String, Object>> dqObjectsMap = new Map<String, Map<String, Object>>();
        Core_CustomMetadataObjectController customMetadataController = new Core_CustomMetadataObjectController('DQ_Objects_mdt');
        dqObjectsMap = customMetadataController.getAll();
        return dqObjectsMap;
    }
    
}