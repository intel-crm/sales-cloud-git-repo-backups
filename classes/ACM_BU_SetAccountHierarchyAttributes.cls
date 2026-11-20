public without sharing class ACM_BU_SetAccountHierarchyAttributes implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {
    public static Boolean runOnce = true;

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
    
    public static void updateHierarchyFields(Map<Id, Account> newAccounts, Map<Id,Account> oldAccounts) {

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
                    if(account.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST'){
                        updateAcctHierarchyAttributes(account);
                    }
            }
            if(Schema.sObjectType.Account.fields.Unified_Hierarchy_View__c.isUpdateable()){
                updateUnifiedHierarchy(account); 
            }
        }
    }
 
    public static void updateUnifiedHierarchy(Account account){
        
        if (String.isNotBlank(account.Core_Customer_Aggregation_Type__c)){
          account.Unified_Hierarchy_View__c = account.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST' ? 'Global' : (account.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST' ? 'Intermediate' : (account.Core_Customer_Aggregation_Type__c == 'UNFD_CTRY_CUST' ? account.Core_Data_Country_Nm__c : (account.Core_Customer_Aggregation_Type__c == 'UNFD_LOC_CUST' && String.isNotBlank(account.Core_MDM_Location_Country_Nm__c) ? ('Location: ' + account.Core_MDM_Location_Country_Nm__c) : '')));
      }
      else {
          account.Unified_Hierarchy_View__c = '';
      }
  }


    private static void updateAcctHierarchyAttributes(Account account){
        List<Account> accToHierarchyUpdate = new List<Account>();
        List<Account> accList = new List<Account>();
        if(account.RecordTypeId == UCD_ACM_ConstantUtil.acctRTIntel || 
            (account.Core_Export_Compliance_Block__c == true && account.RecordTypeId == UCD_ACM_ConstantUtil.acctRTInactive)) {
            
                account.Core_Unified_Global_Customer_BP_Id__c = null;
                account.Core_Unified_Global_Customer_Name__c = null;
                account.Core_Unified_Intermediate_Customer_BP_Id__c = null;
                account.Core_Unified_Intermediate_Customer_Name__c = null;
                account.Core_Unified_Intermdt_Customer_2_BP_Id__c = null;
                account.Core_Unified_Intermdt_Customer_2_Name__c = null;
                account.Core_Unified_Global_Customer_Name__c = account.Core_Data_Simplified_Account_Nm__c;
                account.Core_Unified_Global_Customer_BP_Id__c = account.Core_Business_Party_Id__c;
                if(account.ParentId != null){
                    account.ParentId = null;
                }

            }
    }
}