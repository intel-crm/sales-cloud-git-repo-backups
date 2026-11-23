/***************************************************************************************************************************************
	Apex Class Name     : PRM_ISVCRepublishBatch
    Version             : 1.0
    Created Date        : July 2026
    Function            : Batch class to fix OutboundMessages Stuck in pending
    Maximum Batch Size  : 100
    Modification Log    :
     * Developer                         Date                           Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 * Sathwika                       27 July 2026                     Start Method returns all the Outbound Messages which are stuck in pending from last run and not successful and we republish its IPA integration Account/Contact
 *************************************************************************************************************************************************************/
global class PRM_ISVCRepublishBatch implements Database.Batchable<SObject>, Database.Stateful {
    public String logEntryMsgString = '';
    public Set<Id> accountIdsToRepublish = new Set<Id>();
	public Set<Id> contactIdsToRepublish = new Set<Id>();
    public List<Account> accountsToUpdate = new List<Account>();
    public List<Contact> contactsToUpdate = new List<Contact>();
    public List<PRM_IPA_DQ_Logs__c> dqLogList = new List<PRM_IPA_DQ_Logs__c>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime lastSuccessfulRun;
        PRM_BatchCustomSetting__c batchCustomSetting = [SELECT Id,Name,PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c FROM PRM_BatchCustomSetting__c WHERE Name = :System.Label.PRM_BatchValues LIMIT 1];
        Integer batchExecutionInterval = batchCustomSetting.PRM_SchedulingHour__c.intValue();
        DateTime batchExecutionHours =System.now().addHours(-batchExecutionInterval);
        DateTime startOfToday = DateTime.newInstance(Date.today(),Time.newInstance(0, 0, 0, 0));
        List<AsyncApexJob> lastBatchRun = [SELECT CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = 'PRM_ISVCRepublishBatch' AND Status = :System.Label.PRM_AsyncStatus ORDER BY CompletedDate DESC LIMIT 1];
        if(!lastBatchRun.isEmpty()) {
            lastSuccessfulRun = lastBatchRun[0].CompletedDate;
            return Database.getQueryLocator([SELECT ID,Name,Core_Status__c,Core_MessageType__c,Core_Tags__c,CreatedDate,LastModifiedDate,PRM_Account_Id__c FROM Core_Integration_Outbound_Message__c WHERE Core_MessageType__c IN ('Account Integration','Contact Integration') AND Core_Status__c IN ('Pending','Successful') AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun) AND CreatedDate < :startOfToday]);
        }
        return Database.getQueryLocator([SELECT ID,Name,Core_Status__c,Core_MessageType__c,Core_Tags__c,CreatedDate,LastModifiedDate,PRM_Account_Id__c FROM Core_Integration_Outbound_Message__c WHERE Core_MessageType__c IN ('Account Integration','Contact Integration') AND Core_Status__c IN ('Pending','Successful') AND LastModifiedDate > :batchExecutionHours AND CreatedDate < :startOfToday]);
    }
    global void execute(Database.BatchableContext bc,List<Core_Integration_Outbound_Message__c> scope) {
        List<Core_Integration_Outbound_Message__c> pendingList =new List<Core_Integration_Outbound_Message__c>();
        Map<String, Core_Integration_Outbound_Message__c> latestSuccessMap = new Map<String, Core_Integration_Outbound_Message__c>();
        for(Core_Integration_Outbound_Message__c msg : scope){
            if(msg.Core_Status__c == 'Pending'){
                pendingList.add(msg);
            }else if(msg.Core_Status__c == 'Successful'){
                if(!latestSuccessMap.containsKey(msg.Core_Tags__c) || msg.CreatedDate >latestSuccessMap.get(msg.Core_Tags__c).CreatedDate){
                    latestSuccessMap.put(msg.Core_Tags__c, msg);
                }
            }
        }
        System.debug(LoggingLevel.ERROR,'Success Map Size = ' + latestSuccessMap.size());
        for(Core_Integration_Outbound_Message__c pendingMsg : pendingList){
            Core_Integration_Outbound_Message__c successMsg = latestSuccessMap.get(pendingMsg.Core_Tags__c);
            Boolean republish = false;
            if(successMsg == null){
                republish = true;
                
            }else if(successMsg.CreatedDate < pendingMsg.CreatedDate){
                republish = true;
            }
            System.debug(LoggingLevel.ERROR,'Republish Decision -> ' +'Tag=' + pendingMsg.Core_Tags__c +', PendingId=' + pendingMsg.Id +', PendingCreated=' + pendingMsg.CreatedDate +', SuccessId=' + (successMsg == null ? 'NULL' : successMsg.Id) +', SuccessCreated=' +(successMsg == null ? 'NULL' : String.valueOf(successMsg.CreatedDate)) +', Republish=' + republish);
            if(republish){               
                //if(pendingMsg.Core_MessageType__c == 'Account Integration' && pendingMsg.PRM_Account_Id__c != null){
                if(pendingMsg.Core_MessageType__c =='Account Integration' && String.isNotBlank(pendingMsg.Core_Tags__c)){
                    String AccountId =pendingMsg.Core_Tags__c.split(';')[0];
                    if(String.isNotBlank(AccountId)){
                        accountIdsToRepublish.add((Id)AccountId);
                    }
                    //accountIdsToRepublish.add(pendingMsg.PRM_Account_Id__c);
                }
                if(pendingMsg.Core_MessageType__c =='Contact Integration' && String.isNotBlank(pendingMsg.Core_Tags__c)){
                    String contactId =pendingMsg.Core_Tags__c.split(';')[0];
                    if(String.isNotBlank(contactId)){
                        contactIdsToRepublish.add((Id)contactId);
                    }
                }
            }
            
        }
        if(!accountIdsToRepublish.isEmpty()){
                accountsToUpdate = [SELECT Id,PRM_IPA_Integration_Status__c FROM Account WHERE Id IN :accountIdsToRepublish];
            }
        if(!contactIdsToRepublish.isEmpty()){
            contactsToUpdate = [SELECT Id,PRM_IPA_Integration_Status__c FROM Contact WHERE Id IN :contactIdsToRepublish];
            }
    }
    global void finish(Database.BatchableContext bc){
        try{
            Decimal threshold = 0;
            Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
            if(dqObjectsMap != null &&!dqObjectsMap.isEmpty() && dqObjectsMap.containsKey('Threshold')){
                threshold = Decimal.valueOf(String.valueOf(dqObjectsMap.get('Threshold').get('Threshold__c')));
            }
            Integer totalRecordsToUpdate = accountsToUpdate.size() + contactsToUpdate.size();
            if(totalRecordsToUpdate < threshold){
                for(Account acc : accountsToUpdate){
                    acc.PRM_IPA_Integration_Status__c ='Pending';
                }
                for(Contact con : contactsToUpdate){
                    con.PRM_IPA_Integration_Status__c ='Pending';
                }
                if(!accountsToUpdate.isEmpty()){
                    
                    List<Database.SaveResult> accResults = Database.update(accountsToUpdate,false);
                    handleResult(accResults,'Account');
                }
                if(!contactsToUpdate.isEmpty()){
                    List<Database.SaveResult> conResults = Database.update(contactsToUpdate,false);
                    handleResult(conResults,'Contact');
                }
            }else{
                sendWarningEmail(totalRecordsToUpdate,'Account/Contact Republish');
            }
            if(!dqLogList.isEmpty()){
                List<Database.SaveResult> dqResultList = Database.insert(dqLogList,false);
                for(Database.SaveResult dqResult : dqResultList){
                    if(!dqResult.isSuccess()){
                        for(Database.Error err : dqResult.getErrors()){
                            logEntryMsgString += 'Message: ' + err.getMessage() + '\nFields: ' + err.Fields +'\nStatusCode: ' + err.getStatusCode() +'\n';
                        }
                    }
                }
            }
        }catch(Exception ex){
            logEntryMsgString +='\nFinish Error: ' + ex.getMessage();
        }    
        String jobInitiatedDateTime = System.Now().format('MM/dd/yyyy HH:MM:SS','PST');
        if(logEntryMsgString != ''){
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility = new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength = Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i = 0;i < logEntryUtility.logEntryList.size();i++){
                Core_Log_Entry.logEntryWithDetails('PRM_ISVCRepublishBatch','IPA','PRM_ISVCRepublishBatch','Medium','Job started at: ' + jobInitiatedDateTime +' PST',logEntryUtility.logEntryList[i],'', '', '');
                }
           }
        }

    public void sendWarningEmail(Integer recordCount, String objectName){
        try{
            Map<String, Map<String, Object>> dqObjectsMap =getCustomMetadataRecords();
            String scenarioDescription = '';
            if(dqObjectsMap != null &&!dqObjectsMap.isEmpty()){
                for(String metadataRec :dqObjectsMap.keySet()){
                    if(dqObjectsMap.get(metadataRec).get('Object__c') == objectName){
                        scenarioDescription =(String)dqObjectsMap.get(metadataRec).get('Scenario__c');
                        break;
                    }
                }
            }

            if(String.isBlank(scenarioDescription)){
                scenarioDescription ='Republish threshold exceeded.';
            }
            Map<String,String> placeholderMap =new Map<String,String>();
            placeholderMap.put('%ObjectName%',objectName);
            placeholderMap.put('%RecordCount%',String.valueOf(recordCount));
            placeholderMap.put('%ScenarioDescription%',scenarioDescription);
            placeholderMap.put('%ProcessDate%',String.valueOf(System.today()));
            PRM_OPIDProcessUtility.callSendEmailUtil(placeholderMap,'IPA_DQ_Email');
            PRM_IPA_DQ_Logs__c dqLog =new PRM_IPA_DQ_Logs__c();
            dqLog.PRM_Object_Name__c = objectName;
            dqLog.PRM_Message__c = scenarioDescription +' Record Count: ' + recordCount;
            dqLog.PRM_Apex_Class_Name__c ='PRM_ISVCRepublishBatch';
            dqLogList.add(dqLog);
            logEntryMsgString +='\n[WarningEmailSent] ' + objectName + ' Count: ' + recordCount;
        }
        catch(Exception ex){
            logEntryMsgString +='\n[WarningEmailSendFailed] ' +ex.getMessage();
        }
    }
    public void handleResult(List<Database.SaveResult> result,String objectName){
        String message ='Time: ' + String.valueOf(System.now());
        for(Database.SaveResult sr : result){
            if(!sr.isSuccess()){
                for(Database.Error err :sr.getErrors()){
                    logEntryMsgString +='Message: ' +err.getMessage() +'\nFields: ' + err.Fields +'\nStatusCode: ' +err.getStatusCode() +'\n';
                 }
            }else{
                if(objectName =='Account'){
                    message +='\nUpdated Account Record: ' +sr.getId();
                }
                else if(objectName =='Contact'){
                    message +='\nUpdated Contact Record: ' +sr.getId();
                }
            }
        }

        PRM_IPA_DQ_Logs__c dqLog =new PRM_IPA_DQ_Logs__c();
		dqLog.PRM_Object_Name__c = objectName;
        dqLog.PRM_Message__c = message;
        dqLog.PRM_Apex_Class_Name__c ='PRM_ISVCRepublishBatch';
        dqLogList.add(dqLog);
    }

    public Map<String, Map<String, Object>>getCustomMetadataRecords(){
        Map<String, Map<String, Object>> dqObjectsMap =new Map<String, Map<String, Object>>();
        Core_CustomMetadataObjectController customMetadataController = new Core_CustomMetadataObjectController('DQ_Objects_mdt');
        dqObjectsMap =customMetadataController.getAll();
        return dqObjectsMap;
    }
}