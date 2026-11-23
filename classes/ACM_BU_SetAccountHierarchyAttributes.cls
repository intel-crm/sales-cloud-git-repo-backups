public without sharing class ACM_BU_SetAccountHierarchyAttributes implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {
    static Boolean runOnce = true;

    public void execute(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
       try{
            if(runOnce || (Test.isRunningTest())) {
                UpdateHierarchyFields(newAccounts,oldAccounts);
            }
            runOnce = false;
        }
        catch (Exception ex) {
          UCD_ACM_Logger.error('ACM_BU_SetAccountHierarchyAttributes','execute','Message: ' + ex.getStackTraceString(),NULL);
        } 
    }
    
    private void updateHierarchyFields(Map<Id, Account> newAccounts, Map<Id,Account> oldAccounts) {

        for (Account account : newAccounts.values()) {
            if (String.isNotBlank(account.Core_Customer_Aggregation_Type__c) &&
                    (   account.Core_Business_Party_Id__c != oldAccounts.get(account.Id).Core_Business_Party_Id__c ||
                        account.ParentId != oldAccounts.get(account.Id).ParentId || 
                        account.Core_Customer_Aggregation_Type__c != oldAccounts.get(account.Id).Core_Customer_Aggregation_Type__c || 
                        account.RecordTypeId != oldAccounts.get(account.Id).RecordTypeId ||
                        account.Core_Data_Simplified_Account_Nm__c != oldAccounts.get(account.Id).Core_Data_Simplified_Account_Nm__c ||
                        (   String.isNotBlank(account.Core_Data_Simplified_Account_Nm__c) && 
                            String.isNotBlank(oldAccounts.get(account.Id).Core_Data_Simplified_Account_Nm__c) &&
                            !(account.Core_Data_Simplified_Account_Nm__c.equals(oldAccounts.get(account.Id).Core_Data_Simplified_Account_Nm__c))
                        )
                    )
                ) {  
                updateAllHierarchyFields(account);
            }
            if(Schema.sObjectType.Account.fields.Unified_Hierarchy_View__c.isUpdateable()){
                updateUnifiedHierarchy(account);
            }
         }
    }
    
    private void updateAllHierarchyFields(Account account){
                   
        if(account.RecordTypeId == Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId() ||
           account.RecordTypeId == Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId()) {
            
            account.Core_Unified_Country_Customer__c = null;
            account.Core_Unified_Intermediate_Customer__c = null;
            account.Core_Unified_Intermediate_Customer_2__c = null;
            account.Core_Unified_Global_Customer__c = null;
            account.Core_Unified_Global_Customer_BP_Id__c = null;
            account.Core_Unified_Global_Customer_Name__c = null;
            account.Core_Unified_Intermediate_Customer_BP_Id__c = null;
            account.Core_Unified_Intermediate_Customer_Name__c = null;
            if(account.ParentId != null && account.Core_Customer_Aggregation_Type__c != 'UNFD_GLBL_CUST') {
                System.debug('account++++'+account);       
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
    private void updateUnifiedHierarchy(Account account){
        if(account.KCR_Process_Outcome_Temp__c == 'Business Process Block'){
            account.Unified_Hierarchy_View__c = 'Not Unified';
        }
        else if (String.isNotBlank(account.Core_Customer_Aggregation_Type__c)){
            account.Unified_Hierarchy_View__c = account.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST' ? 'Global' : (account.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST' ? 'Intermediate' : (account.Core_Customer_Aggregation_Type__c == 'UNFD_CTRY_CUST' ? account.Core_Data_Country_Nm__c : (account.Core_Customer_Aggregation_Type__c == 'UNFD_LOC_CUST' && String.isNotBlank(account.Core_Data_Country_Nm__c) ? ('Location: ' + account.Core_Data_Country_Nm__c) : '')));
        }else if (account.KCR_Process_Outcome_Temp__c != 'Business Process Block'){
            account.Unified_Hierarchy_View__c = '';
        }
    }
}