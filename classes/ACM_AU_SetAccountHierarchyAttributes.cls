public without sharing class ACM_AU_SetAccountHierarchyAttributes implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    static Boolean runOnce = true;

    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try{
        if(runOnce || (Test.isRunningTest())) {
            UpdateHierarchyFields(newAccounts,oldAccounts);
        }
        runOnce = false;
        }
        catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_AU_SetAccountHierarchyAttributes','execute','Message: ' + ex.getStackTraceString(),NULL);
        }
    }
   
    private void updateHierarchyFields(Map<Id, Account> newAccounts, Map<Id,Account> oldAccounts) {
        Set<Id> loggingAccountIds = new Set<Id>();   
        for (Account account : newAccounts.values()) {
            loggingAccountIds.add(account.Id);
            if (String.isNotBlank(account.Core_Customer_Aggregation_Type__c) &&
                    ( account.Core_Business_Party_Id__c != oldAccounts.get(account.Id).Core_Business_Party_Id__c ||
                      account.ParentId != oldAccounts.get(account.Id).ParentId || 
                      account.Core_Customer_Aggregation_Type__c != oldAccounts.get(account.Id).Core_Customer_Aggregation_Type__c || 
                      account.RecordTypeId != oldAccounts.get(account.Id).RecordTypeId ||
                      account.Core_Data_Simplified_Account_Nm__c != oldAccounts.get(account.Id).Core_Data_Simplified_Account_Nm__c ||
                      ( String.isNotBlank(account.Core_Data_Simplified_Account_Nm__c) && 
                        String.isNotBlank(oldAccounts.get(account.Id).Core_Data_Simplified_Account_Nm__c) &&
                        !(account.Core_Data_Simplified_Account_Nm__c.equals(oldAccounts.get(account.Id).Core_Data_Simplified_Account_Nm__c))
                      )
                    )
            ) {
                    updateHierarchyFieldsForChildAccounts(account);
                }
        }

    }
    
    private void updateHierarchyFieldsForChildAccounts(Account account){
                
        if(account.RecordTypeId <> Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Rejected_Account').getRecordTypeId() && account.RecordTypeId <> Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Requested_Account').getRecordTypeId()) {
          UCD_ACM_UpdateHierarchyFieldsQueueable updateJob = new UCD_ACM_UpdateHierarchyFieldsQueueable(account.Id);
          ID jobID = System.enqueueJob(updateJob);
        }              
    }
}