public without sharing class UCD_ACM_AccountDeactivation {
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    public static void removeUCDAttributes(Map<Id,Account> listofAccount) {

        // rollback if any account have issue 
        // reltio success and issue in SF then we need to push dTE TIME VAR IN RELTIO NEXT day or what ?
        // rollback pending
        // error log pending

        System.debug('removeUCDAttributes==>');

        if(!listOfAccount.isEmpty()) {
            removeBusinessType(listOfAccount); //10
            removeAccountAttributes(listOfAccount); //10
           // removeComplianceWatchlist(listOfAccount);//5
        }
    }

    
    private static void  removeAccountAttributes(Map<Id,Account> listOfAccount) {
        List<Account> accountTobeUpdate = new List<Account>();
        if(listOfAccount != null && listOfAccount.size() > 0) {
            System.debug('@@$account '+listOfAccount);
            for(Account account : listOfAccount.values()) {
                account.Core_Business_Party_Id__c = null;
                account.Core_Customer_Aggregation_Type__c = null;
                account.Core_Data_Simplified_Account_Nm__c = null;
                account.Core_Data_Simplified_Local_Language_Nm__c = null;
                account.Core_Data_Country_Nm__c = null;
                account.Unified_Hierarchy_View__c = null;
                account.Core_MDM_Website__c = null;
                account.Core_Unified_Global_Customer__c = null;
                account.Core_Unified_Global_Customer_Name__c = null;
                account.Core_Unified_Global_Customer_BP_Id__c = null;
                account.Core_Unified_Intermediate_Customer__c = null;
                account.Core_Unified_Intermediate_Customer_2__c = null;
                account.Core_Unified_Intermediate_Customer_Name__c = null;
                account.Core_Unified_Intermediate_Customer_BP_Id__c = null;
                account.Core_Unified_Country_Customer__c = null;
                account.ParentId = null;
                //account.Core_MDM_CPEs_c = null;
                //account.Core_MDM_Status_c = null;
                account.Core_Data_Country_Nm__c=null;
                account.Core_Parent_Business_Party_Id__c = null;
                account.Core_Account_Request_Rejection_Reason__c = null;
                account.Core_Account_Request_Rejection_Notes__c = null;
                accountTobeUpdate.add( account );
            }    
        }

        if(!accountTobeUpdate.isEmpty()){
            update accountTobeUpdate;
        }
    }
    /*
    private static void removeComplianceWatchlist(Map<Id,Account> listOfAccount) { 
        List<Core_Account_Compliance_Watch_List__c> complianceWatchListtoDelete = new List<Core_Account_Compliance_Watch_List__c>();
        Set<Id> accountIds=new Set<Id>();
        List<Core_Account_Compliance_Watch_List__c> complianceWatchListsRecords = new List<Core_Account_Compliance_Watch_List__c>();
        if(!listOfAccount.isempty()) {
            System.debug('@@$accouts'+listOfAccount);
            complianceWatchListsRecords = [Select id,Core_Account_Id__c,Core_Effective_End_Date__c from Core_Account_Compliance_Watch_List__c where Core_Account_Id__c IN :listofAccount.keyset()]; 
            System.debug('@@$complianceWatchListsRecords'+complianceWatchListsRecords);
            if(!complianceWatchListsRecords.isempty()) {
                for(Core_Account_Compliance_Watch_List__c complianceWatchList : complianceWatchListsRecords){
                    complianceWatchListtoDelete.add(complianceWatchList);
                }
            }
            System.debug('#$$complianceWatchListtoDelete '+complianceWatchListtoDelete);
            if(!complianceWatchListtoDelete.isEmpty()) {
                delete complianceWatchListtoDelete;
            }
        }
    }
    */
    public static void removeBusinessType(Map<Id,Account> listOfAccount) { 
        List<Account_Business_Types__c> cpetoDelete = new List<Account_Business_Types__c>();
        List<Account_Business_Types__c> cpeRecords = new List<Account_Business_Types__c>();
        Set<Id> accountbusinessTypeIds=new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        if(!listOfAccount.isempty()) {
            Map<Id,List<Business_Types__c>> businessTypesByAccountId = accountServiceInstance.getActiveBusinessTypeForAccount(listOfAccount.keySet());
            System.debug('businessTypesByAccountId@@@'+businessTypesByAccountId);
            for(Account account : listOfAccount.values()) {
                if(businessTypesByAccountId != null && businessTypesByAccountId.containsKey(account.Id)) {
                    for(Business_Types__c acctBusinessType : businessTypesByAccountId.get(account.Id)) {
                        accountIds.add(account.Id);
                        accountbusinessTypeIds.add(acctBusinessType.Id);
                    }
                }
            }
            cpeRecords = [Select Id,Account__c,Business_Types__c,Effective_End_Date__c from Account_Business_Types__c Where Account__c IN :accountIds AND Business_Types__c IN :accountbusinessTypeIds];
            System.debug('@@$cpeRecords'+cpeRecords);
            if(!cpeRecords.isempty()){
                for(Account_Business_Types__c cpe : cpeRecords) {
                    cpetoDelete.add(cpe);
                }
            }
            System.debug('@@$cpetoDelete '+cpetoDelete);
            if(!cpetoDelete.isEmpty()) {
                delete cpetoDelete;
            }
        }
    }  
   
    
}