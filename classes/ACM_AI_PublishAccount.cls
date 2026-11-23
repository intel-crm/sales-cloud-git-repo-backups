public without sharing class ACM_AI_PublishAccount implements UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger{
    static boolean runOnce = true;
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        if (runOnce && (isValid() || Test.isRunningTest())) {
            try {
                publishAccount(unitOfWork, oldAccounts, newAccounts);
            } catch (Exception ex) {
                UCD_ACM_Logger.error('ACM_AI_PublishAccount','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
            }
        }
        runOnce = false;
    }

    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
    }

    private void publishAccount(UCD_ACM_UnitOfWork unitOfWork, Map<Id,Account> oldAccounts, Map<Id, Account> newAccounts){
        Id endCustomerDealRecordtypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
        Id rejectedAccountRecordtypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Rejected Account').getRecordTypeId();

        Set<Id> accountIds = new Set<Id>();
        if(newAccounts != null){
            for(Account account : newAccounts.values()){
                if(account.recordTypeId == endCustomerDealRecordtypeId || account.recordTypeId == rejectedAccountRecordtypeId){
                    accountIds.add(account.Id);
                }
            }
        }
        if(accountIds.size()>0){
            UCD_ACM_Common.updateACMIntegrationMessage(unitOfWork, accountIds);
        }
    }

         
    /** 
    * description : Insert or Update ACM_Integration_Message_Queue__c 
    * original author and date : harshalx.sunil.gosavi@intel.com 08/02/2022.
    * Moved to ACM_AI_PublishAccount by Tejasri as part of refactoring
    */
    /*private void updateACMIntegrationMessage(UCD_ACM_UnitOfWork unitOfWork, Set<Id> accountIds) {
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageQueueById = accountQuerySelectorInstance.getIntegrationMessageQueueByAccountId(accountIds);
        List<ACM_Integration_Message_Queue__c> insertIntegrationMessages = new List<ACM_Integration_Message_Queue__c>();
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageQueueByAccountId = new Map<Id,ACM_Integration_Message_Queue__c>(); 
        
        if(integrationMessageQueueById != null && integrationMessageQueueById.size() > 0) {
            For(ACM_Integration_Message_Queue__c integrationMessageQueue : integrationMessageQueueById.values()) {
                integrationMessageQueueByAccountId.put(integrationMessageQueue.Content__c,integrationMessageQueue);
            }
        }
        For(Id accountId : accountIds) {
            if(integrationMessageQueueByAccountId != null && integrationMessageQueueByAccountId.size() > 0 && integrationMessageQueueByAccountId.containsKey(accountId)) {
                if(integrationMessageQueueByAccountId.get(accountId).Message_Status__c == 'Success' ) {
                    ACM_Integration_Message_Queue__c integrationMessage = integrationMessageQueueByAccountId.get(accountId);
                    integrationMessage.Message_Status__c = 'New';
                    unitOfWork.registerModified(integrationMessage);
                }
            } else {
                ACM_Integration_Message_Queue__c integrationMessage = new ACM_Integration_Message_Queue__c();
                integrationMessage.Content__c = accountId;
                integrationMessage.Custom_Filter__c = accountId;
                integrationMessage.Content_Type__c = 'AccountId';
                integrationMessage.Message_Status__c = 'New';
                integrationMessage.Module_Name__c = 'ACM';
                integrationMessage.Queue_Type__c = 'Outbound';
                integrationMessage.Retry_Count__c = 0;
                integrationMessage.Source_System__c = 'Reltio';
                insertIntegrationMessages.add(integrationMessage);
            }
        }
        
        if(insertIntegrationMessages.size() > 0) {
            unitOfWork.registerNew(insertIntegrationMessages);
        }
    }*/
            
}