/*********************************************************************************************************************
Apex Class Name  : UCD_ACM_AccountDeactivation
Author And Date  : Rajveer Ranawat, 11 June 2023
Function         : This class has code for deleting Xwalk and BusinessType Ids
Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Rajveer Ranawat         11/6/2023                  Created
* Chethan Kunder          17/10/2024                 Created removeCWL(),created & updated some variables
*********************************************************************************************************************/
public without sharing class UCD_ACM_AccountDeactivation {
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    //mAccts contains BusinessType Ids
    public static void removeUCDAttributes(Map<Id,Account> mAccts) {
        if(!mAccts.isEmpty()) {
            removeBusinessType(mAccts); 
        }
    }
    
    private static void removeBusinessType(Map<Id,Account> mAccts) { 
        List<Account_Business_Types__c> cpetoDelete = new List<Account_Business_Types__c>();
        List<Account_Business_Types__c> cpeRecords = new List<Account_Business_Types__c>();
        Set<Id> accountbusinessTypeIds=new Set<Id>();
        Set<Id> accountIds = new Set<Id>();        
        Map<Id,List<Business_Types__c>> businessTypesByAccountId = accountServiceInstance.getActiveBusinessTypeForAccount(mAccts.keySet());
        for(Account account : mAccts.values()) {
            if(businessTypesByAccountId != null && businessTypesByAccountId.containsKey(account.Id)) {
                for(Business_Types__c acctBusinessType : businessTypesByAccountId.get(account.Id)) {
                    accountIds.add(account.Id);
                    accountbusinessTypeIds.add(acctBusinessType.Id);
                }
            }
        }
        cpeRecords = [Select Id,Account__c,Business_Types__c,Effective_End_Date__c from Account_Business_Types__c Where Account__c IN :accountIds AND Business_Types__c IN :accountbusinessTypeIds WITH SECURITY_ENFORCED];
        if(!cpeRecords.isempty()){
            for(Account_Business_Types__c cpe : cpeRecords) {
                cpetoDelete.add(cpe);
            }
            if (Schema.sObjectType.Account_Business_Types__c.isDeletable()){
                delete cpetoDelete;
            }
        }        
    }    

    public static Account removeHierarchyAttr(Account acc){
        acc.Core_Unified_Global_Customer_BP_Id__c = null ;
        acc.Core_Unified_Global_Customer_Name__c = null ;
        acc.Core_Unified_Intermediate_Customer_BP_Id__c = null ;
        acc.Core_Unified_Intermediate_Customer_Name__c = null ;
        acc.Core_Unified_Intermdt_Customer_2_BP_Id__c = null ;
        acc.Core_Unified_Intermdt_Customer_2_Name__c = null ;
        acc.ParentId = null;
        acc.Core_Parent_Business_Party_Id__c = null;
        return acc;
    }

}