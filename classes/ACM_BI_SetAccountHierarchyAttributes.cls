public without sharing class ACM_BI_SetAccountHierarchyAttributes implements UCD_ACM_ServiceContracts.IBeforeInsertAccountTrigger {
    static Boolean runOnce = true;

    public void execute(List<Account> newAccounts) {
      try{
        if(runOnce || (Test.isRunningTest())) {
            UpdateHierarchyFields(newAccounts);

        }
        runOnce = false;
      }
      catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_BI_SetAccountHierarchyAttributes','execute','Message: ' + ex.getMessage(),NULL);
      }
    }

    private void updateHierarchyFields(List<Account> newValues) {
        If(newValues != null){
            Set<Id> loggingAccountIds = new Set<Id>();
            for (Account account : newValues) {
                loggingAccountIds.add(account.Id);
                if (String.isNotBlank(account.Core_Customer_Aggregation_Type__c)) {
                    updateAllHierarchyFields(account);
                }
            }
        }
    }
    
    private void updateAllHierarchyFields(Account account){
                
        if(account.RecordTypeId == Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId() ) {
                if(account.ParentId != null && account.Core_Customer_Aggregation_Type__c != 'UNFD_GLBL_CUST') {
                    UCD_ACM_Common.setHierarchyFields(account, null);
                }
                else if(account.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST') {
                    account.Core_Unified_Global_Customer_Name__c = account.Core_Data_Simplified_Account_Nm__c;
                    account.Core_Unified_Global_Customer_BP_Id__c = account.Core_Business_Party_Id__c;
                }
                else if(account.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST') {
                    account.Core_Unified_Intermediate_Customer_Name__c = account.Core_Data_Simplified_Account_Nm__c;
                    account.Core_Unified_Intermediate_Customer_BP_Id__c = account.Core_Business_Party_Id__c;
                }
        }               
    
    }  
}