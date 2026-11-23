public without sharing class UCD_ACM_Common {
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();

        
    /*
    * description : Set UCD hierarchy fields
    * params : Account
    * author and date : chethan.s.kunder@intel.com, 25 Nov 2021
    * Updated : chethan.s.kunder@intel.com, 01 Dec 2022 - New UCD hierachy attributes integration
    * Moved to this common class by yenugantix.tejasri@intel.com,3-APR-2023.
    */

    public static void setHierarchyFields(Account account, Account parentAcct) {
        System.debug('account++++'+account); 
        
        UCD_ACM_Logger.information('UCD_ACM_Common','setHierarchyFields','Account:ID: '+account.Id +' and AccountCustAggrType :' + account.Core_Customer_Aggregation_Type__c,'AccountIds: '+account.Id);
        if(parentAcct == null) {
            Set<Id> parentAccountIds = new Set<Id>();
            parentAccountIds.add(account.ParentId);              
            UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 
            parentAcct = accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent()).get(account.ParentId);
            //parentAcctLoc = accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent()).get(account.Parent.ParentId);

        
        }
        string parentCustAggrType = parentAcct.Core_Customer_Aggregation_Type__c;
        Boolean hasSecondaryIntermediateParent = parentCustAggrType == 'UNFD_INTRMD_CUST' ? hasSecondaryIntermediateParent(parentAcct) :false;
        UCD_ACM_Logger.information('UCD_ACM_Common','setHierarchyFields','ParentCustAggrType:' + parentCustAggrType,'AccountIds: '+account.Id);
        account.Core_Unified_Global_Customer__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Id : parentAcct.Core_Unified_Global_Customer__c;
        account.Core_Unified_Global_Customer_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Business_Party_Id__c : parentAcct.Core_Unified_Global_Customer_BP_Id__c;
        account.Core_Unified_Global_Customer_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c : parentAcct.Core_Unified_Global_Customer_Name__c;

        
        switch on account.Core_Customer_Aggregation_Type__c {
            when 'UNFD_LOC_CUST' {
                System.debug('UNFD_LOC_CUST++++'+account);
                account.Core_Unified_Intermediate_Customer__c = parentAcct.Core_Unified_Intermediate_Customer__c;
                account.Core_Unified_Intermediate_Customer_2__c = parentAcct.Core_Unified_Intermediate_Customer_2__c;

                account.Core_Unified_Intermediate_Customer_BP_Id__c = parentAcct.Core_Unified_Intermediate_Customer_BP_Id__c;
                account.Core_Unified_Intermediate_Customer_Name__c = parentAcct.Core_Unified_Intermediate_Customer_Name__c;
                account.Core_Unified_Intermdt_Customer_2_BP_Id__c = parentAcct.Core_Unified_Intermdt_Customer_2_BP_Id__c;
                account.Core_Unified_Intermdt_Customer_2_Name__c = parentAcct.Core_Unified_Intermdt_Customer_2_Name__c;

            }
            when 'UNFD_CTRY_CUST' {
                
                account.Core_Unified_Intermediate_Customer__c = parentCustAggrType == 'UNFD_INTRMD_CUST' ? (parentAcct.Core_Unified_Intermediate_Customer__c != null ? parentAcct.Core_Unified_Intermediate_Customer__c : parentAcct.Id) : null;             
                account.Core_Unified_Intermediate_Customer_2__c = parentCustAggrType == 'UNFD_INTRMD_CUST' ? (parentAcct.Core_Unified_Intermediate_Customer_2__c != null ? parentAcct.Core_Unified_Intermediate_Customer_2__c : ((parentAcct.Core_Unified_Intermediate_Customer__c != null && parentAcct.Core_Unified_Intermediate_Customer__c != account.Core_Unified_Intermediate_Customer__c) ? parentAcct.Core_Unified_Intermediate_Customer__c : parentAcct.Id)):null;      
                
                // account.Core_Unified_Intermediate_Customer_BP_Id__c = hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__r.Core_Business_Party_Id__c: (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Business_Party_Id__c : null);
                // account.Core_Unified_Intermediate_Customer_Name__c = hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__r.Core_Data_Simplified_Account_Nm__c: (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c : null);
                account.Core_Unified_Intermediate_Customer_BP_Id__c = parentAcct.Core_Unified_Intermediate_Customer_BP_Id__c;
                account.Core_Unified_Intermediate_Customer_Name__c = parentAcct.Core_Unified_Intermediate_Customer_Name__c;
                account.Core_Unified_Intermdt_Customer_2_BP_Id__c = parentAcct.Core_Unified_Intermdt_Customer_2_BP_Id__c;
                account.Core_Unified_Intermdt_Customer_2_Name__c = parentAcct.Core_Unified_Intermdt_Customer_2_Name__c;
            }
            when 'UNFD_INTRMD_CUST' {  
                account.Core_Unified_Intermediate_Customer__c = parentCustAggrType == 'UNFD_GLBL_CUST'? null : (hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__c : parentAcct.Id);
                account.Core_Unified_Intermediate_Customer_2__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? null : (hasSecondaryIntermediateParent ? parentAcct.Id : null);   
                
                account.Core_Unified_Intermediate_Customer_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST'? account.Core_Business_Party_Id__c : (hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer_BP_Id__c : parentAcct.Core_Business_Party_Id__c);
                account.Core_Unified_Intermediate_Customer_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? account.Core_Data_Simplified_Account_Nm__c : (hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer_Name__c : parentAcct.Core_Data_Simplified_Account_Nm__c);
                account.Core_Unified_Intermdt_Customer_2_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? null : (hasSecondaryIntermediateParent ? parentAcct.Core_Business_Party_Id__c : account.Core_Business_Party_Id__c);
                account.Core_Unified_Intermdt_Customer_2_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? null : (hasSecondaryIntermediateParent ? parentAcct.Core_Data_Simplified_Account_Nm__c : account.Core_Data_Simplified_Account_Nm__c);
            
            }
        }
    }
    
    /** 
    * description : Insert or Update ACM_Integration_Message_Queue__c 
    * original author and date : harshalx.sunil.gosavi@intel.com 08/02/2022.
    * Moved this to Common class by Abhishek as part of refactoring
    */
    public static void updateACMIntegrationMessage(UCD_ACM_UnitOfWork unitOfWork, Set<Id> accountIds){
        System.debug('accountids@@@%%%'+accountIds);
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
                    System.debug('inside if common @@@%%%');
                    unitOfWork.registerModified(integrationMessage);
                }
            } else {
                System.debug('inside else@@@%%%');
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
        System.debug('insertIntegrationMessages@@@%%%'+insertIntegrationMessages);
        
        if(insertIntegrationMessages.size() > 0) {
            unitOfWork.registerNew(insertIntegrationMessages);
        }
    }
        /*
    * description : To check if an intermediate account has secondary intermediate parent
    * params : Account
    * author and date : chethan.s.kunder@intel.com, 15 Mar 2022
    * Moved to this common class by yenugantix.tejasri@intel.com,3-APR-2023.
    */
    @TestVisible private static Boolean hasSecondaryIntermediateParent(Account parentAccount){
        if(parentAccount.ParentId == null){
            return false;
        }
        Map<Id, Account> parent2AccountById = new Map<Id,Account>();
        Set<Id> parent2AccountIds = new Set<Id>();
        parent2AccountIds.add(parentAccount.ParentId);              
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 
        parent2AccountById = accountQuerySelectorInstance.getAccountsByIds(parent2AccountIds, model.getParentAccountQueryForEvent());
        return parent2AccountById.get(parentAccount.ParentId).Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST';
    }
}