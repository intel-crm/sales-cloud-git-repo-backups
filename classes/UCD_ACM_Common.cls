public without sharing class UCD_ACM_Common {
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();

    private static Id dealAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();
    private static Id intelAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    private static Id inactiveAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();

        
    /*
    * description : Set UCD hierarchy fields
    * params : Account
    * author and date : chethan.s.kunder@intel.com, 25 Nov 2021
    * Updated : chethan.s.kunder@intel.com, 01 Dec 2022 - New UCD hierachy attributes integration
    * Updated : roushanx.kumar@intel.com , 08 Oct 2024 - Bulkifying 
    * Moved to this common class by yenugantix.tejasri@intel.com,3-APR-2023.
    */

    public static List<Account> setAccountHierarchyFields(List<Account> accountList, Account parentAcct) {
        List<Account> accountToReturn = new List<Account>();
        try{
            Map<Id,Account> parentAccountMap = New Map<Id,Account>();
            if(parentAcct == null) {
                Set<Id> parentAccountIds = new Set<Id>();
                for(Account account : accountList){
                    parentAccountIds.add(account.ParentId);
                }             
                UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 
                parentAccountMap = accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent());
            }
            UCD_ACM_Logger.information('UCD_ACM_Common','setAccountHierarchyFields','Accounts '+accountList ,'AccountIds: '+accountList);


            for(Account account : accountList){
                parentAcct = parentAccountMap.get(account.ParentId);
                string parentCustAggrType = parentAcct.Core_Customer_Aggregation_Type__c;
                Boolean hasSecondaryIntermediateParent = parentCustAggrType == 'UNFD_INTRMD_CUST' ? (parentAcct.Parent.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST' ? true : false) :false;
                account.Core_Unified_Global_Customer_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Business_Party_Id__c : parentAcct.Core_Unified_Global_Customer_BP_Id__c;
                account.Core_Unified_Global_Customer_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c : parentAcct.Core_Unified_Global_Customer_Name__c;

                
                switch on account.Core_Customer_Aggregation_Type__c {
                    when 'UNFD_LOC_CUST' {
                        account.Core_Unified_Intermediate_Customer_BP_Id__c = parentAcct.Core_Unified_Intermediate_Customer_BP_Id__c;
                        account.Core_Unified_Intermediate_Customer_Name__c = parentAcct.Core_Unified_Intermediate_Customer_Name__c;
                        account.Core_Unified_Intermdt_Customer_2_BP_Id__c = parentAcct.Core_Unified_Intermdt_Customer_2_BP_Id__c;
                        account.Core_Unified_Intermdt_Customer_2_Name__c = parentAcct.Core_Unified_Intermdt_Customer_2_Name__c;

                    }
                    when 'UNFD_CTRY_CUST' {
                        account.Core_Unified_Intermediate_Customer_BP_Id__c = parentAcct.Core_Unified_Intermediate_Customer_BP_Id__c;
                        account.Core_Unified_Intermediate_Customer_Name__c = parentAcct.Core_Unified_Intermediate_Customer_Name__c;
                        account.Core_Unified_Intermdt_Customer_2_BP_Id__c = parentAcct.Core_Unified_Intermdt_Customer_2_BP_Id__c;
                        account.Core_Unified_Intermdt_Customer_2_Name__c = parentAcct.Core_Unified_Intermdt_Customer_2_Name__c;
                    }
                    when 'UNFD_INTRMD_CUST' {                          
                        account.Core_Unified_Intermediate_Customer_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST'? account.Core_Business_Party_Id__c : (hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer_BP_Id__c : parentAcct.Core_Business_Party_Id__c);
                        account.Core_Unified_Intermediate_Customer_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? account.Core_Data_Simplified_Account_Nm__c : (hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer_Name__c : parentAcct.Core_Data_Simplified_Account_Nm__c);
                        account.Core_Unified_Intermdt_Customer_2_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? null : (hasSecondaryIntermediateParent ? parentAcct.Core_Business_Party_Id__c : account.Core_Business_Party_Id__c);
                        account.Core_Unified_Intermdt_Customer_2_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? null : (hasSecondaryIntermediateParent ? parentAcct.Core_Data_Simplified_Account_Nm__c : account.Core_Data_Simplified_Account_Nm__c);
                    
                    }
                }
            accountToReturn.add(account);
            }
        }catch(Exception e){
            UCD_ACM_Logger.error('UCD_ACM_Common','setAccountHierarchyFields','Message: ' + e.getStackTraceString(),NULL);
        }
        return accountToReturn;
        
    }
    
   /*
    * description : Set UCD hierarchy fields
    * params : Account
    * author and date : chethan.s.kunder@intel.com, 25 Nov 2021
    * Updated : chethan.s.kunder@intel.com, 01 Dec 2022 - New UCD hierachy attributes integration
    * Bulkified logic by ajayx.gat@intel.com,4-Mar-2024.
    */

    public static Map<Id, Account> setHierarchyFieldsBulk(Map<Id, Account> mChildAccounts) {
        
        Map<Id, Id> accountToParentAccountMap = new Map<Id, Id>();
        List<Account> nullParentAccList = new List<Account>();
        Set<Id> parentAccountIds = new Set<Id>();
        Map<Id, Account> mAccountsToUpdate = new Map<Id, Account>();
        Map<Id,Account> parentsAccountsById = new Map<Id,Account>();

        for (Id acctId: mChildAccounts.keySet()) {
            Account acct = mChildAccounts.get(acctId);
            Account parentAcct = acct.ParentId <> null ? mChildAccounts.get(acct.ParentId) : null;
			
            accountToParentAccountMap.put(acct.Id, acct.ParentId);
            if(parentAcct == null) {
                parentAccountIds.add(acct.ParentId);
            } else {
                parentsAccountsById.put(parentAcct.Id, parentAcct);
            }
        }  

        UCD_ACM_Logger.information('UCD_ACM_Common','setHierarchyFields','Account:ID: '+mChildAccounts.keySet() +' and AccountCustAggrType :' + account.Core_Customer_Aggregation_Type__c,'AccountIds: '+mChildAccounts.keySet());

        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 

        if(!parentAccountIds.isEmpty()) {            
            parentsAccountsById.putAll(accountQuerySelectorInstance.getAccountsByIds(parentAccountIds, model.getParentAccountQueryForEvent()));
        }

        Map<id, Boolean> parentAccToHasSecondary = hasSecondaryIntermediateParentBulk(parentsAccountsById.values());

        for (Id acctId: mChildAccounts.keySet()) {
            Account account = mChildAccounts.get(acctId);
            Account parentAcct = parentsAccountsById.get(accountToParentAccountMap.get(account.Id));
			
            if(parentAcct != null) {
                string parentCustAggrType = parentAcct.Core_Customer_Aggregation_Type__c;
                
                Boolean hasSecondaryIntermediateParent = parentCustAggrType == 'UNFD_INTRMD_CUST' ? (parentAccToHasSecondary.containsKey(parentAcct.Id) ? parentAccToHasSecondary.get(parentAcct.Id): false) :false;

                //account.Core_Unified_Global_Customer__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Id : parentAcct.Core_Unified_Global_Customer__c;
                account.Core_Unified_Global_Customer_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Business_Party_Id__c : parentAcct.Core_Unified_Global_Customer_BP_Id__c;
                account.Core_Unified_Global_Customer_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c : parentAcct.Core_Unified_Global_Customer_Name__c;
    
                
                switch on account.Core_Customer_Aggregation_Type__c {
                    when 'UNFD_LOC_CUST' {
                        //account.Core_Unified_Intermediate_Customer__c = parentAcct.Core_Unified_Intermediate_Customer__c;
                        //account.Core_Unified_Intermediate_Customer_2__c = parentAcct.Core_Unified_Intermediate_Customer_2__c;
                        //account.Core_Unified_Country_Customer__c = parentAcct.Id;
                        account.Core_Unified_Intermediate_Customer_BP_Id__c = parentAcct.Core_Unified_Intermediate_Customer_BP_Id__c;
                        account.Core_Unified_Intermediate_Customer_Name__c = parentAcct.Core_Unified_Intermediate_Customer_Name__c;
                        account.Core_Unified_Intermdt_Customer_2_BP_Id__c = parentAcct.Core_Unified_Intermdt_Customer_2_BP_Id__c;
                        account.Core_Unified_Intermdt_Customer_2_Name__c = parentAcct.Core_Unified_Intermdt_Customer_2_Name__c;
    
                    }
                    when 'UNFD_CTRY_CUST' {
                        
                        //account.Core_Unified_Intermediate_Customer__c = parentCustAggrType == 'UNFD_INTRMD_CUST' ? (parentAcct.Core_Unified_Intermediate_Customer__c != null ? parentAcct.Core_Unified_Intermediate_Customer__c : parentAcct.Id) : null;             
                        //account.Core_Unified_Intermediate_Customer_2__c = parentCustAggrType == 'UNFD_INTRMD_CUST' ? (parentAcct.Core_Unified_Intermediate_Customer_2__c != null ? parentAcct.Core_Unified_Intermediate_Customer_2__c : ((parentAcct.Core_Unified_Intermediate_Customer__c != null && parentAcct.Core_Unified_Intermediate_Customer__c != account.Core_Unified_Intermediate_Customer__c) ? parentAcct.Core_Unified_Intermediate_Customer__c : (parentAcct.Id!=account.Core_Unified_Intermediate_Customer__c?parentAcct.Id:null))):null;      
                        
                        // account.Core_Unified_Intermediate_Customer_BP_Id__c = hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__r.Core_Business_Party_Id__c: (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Business_Party_Id__c : null);
                        // account.Core_Unified_Intermediate_Customer_Name__c = hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__r.Core_Data_Simplified_Account_Nm__c: (parentCustAggrType == 'UNFD_INTRMD_CUST' ? parentAcct.Core_Data_Simplified_Account_Nm__c : null);
                        account.Core_Unified_Intermediate_Customer_BP_Id__c = parentAcct.Core_Unified_Intermediate_Customer_BP_Id__c;
                        account.Core_Unified_Intermediate_Customer_Name__c = parentAcct.Core_Unified_Intermediate_Customer_Name__c;
                        account.Core_Unified_Intermdt_Customer_2_BP_Id__c = parentAcct.Core_Unified_Intermdt_Customer_2_BP_Id__c;
                        account.Core_Unified_Intermdt_Customer_2_Name__c = parentAcct.Core_Unified_Intermdt_Customer_2_Name__c;
                    }
                    when 'UNFD_INTRMD_CUST' {
                        //account.Core_Unified_Intermediate_Customer__c = parentCustAggrType == 'UNFD_GLBL_CUST'? null : (hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer__c : parentAcct.Id);
                        //account.Core_Unified_Intermediate_Customer_2__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? null : (hasSecondaryIntermediateParent ? parentAcct.Id : null);   
                        
                        account.Core_Unified_Intermediate_Customer_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST'? account.Core_Business_Party_Id__c : (hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer_BP_Id__c : parentAcct.Core_Business_Party_Id__c);
                        account.Core_Unified_Intermediate_Customer_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? account.Core_Data_Simplified_Account_Nm__c : (hasSecondaryIntermediateParent ? parentAcct.Core_Unified_Intermediate_Customer_Name__c : parentAcct.Core_Data_Simplified_Account_Nm__c);
                        account.Core_Unified_Intermdt_Customer_2_BP_Id__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? null : (hasSecondaryIntermediateParent ? parentAcct.Core_Business_Party_Id__c : account.Core_Business_Party_Id__c);
                        account.Core_Unified_Intermdt_Customer_2_Name__c = parentCustAggrType == 'UNFD_GLBL_CUST' ? null : (hasSecondaryIntermediateParent ? parentAcct.Core_Data_Simplified_Account_Nm__c : account.Core_Data_Simplified_Account_Nm__c);
                    }
                }
                mAccountsToUpdate.put(account.Id, account);
            }
        }

        return mAccountsToUpdate;
    }
    
    /** 
    * description : Insert or Update ACM_Integration_Message_Queue__c 
    * original author and date : harshalx.sunil.gosavi@intel.com 08/02/2022.
    * Moved this to Common class by Abhishek as part of refactoring
    */
    public static void updateACMIntegrationMessage(UCD_ACM_UnitOfWork unitOfWork, Set<Id> accountIds){
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
               //if(integrationMessageQueueByAccountId.get(accountId).Message_Status__c == 'Success' ) {
                    ACM_Integration_Message_Queue__c integrationMessage = integrationMessageQueueByAccountId.get(accountId);
                    integrationMessage.Message_Status__c = 'New';
                    unitOfWork.registerModified(integrationMessage);
                //}
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
    
    /*
    * description : To check if an intermediate account has secondary intermediate parent
    * params : Account
    * author and date : chethan.s.kunder@intel.com, 15 Mar 2022
    * Moved to this common class by yenugantix.tejasri@intel.com,3-APR-2023.
    * Bulkified logic by ajayx.gat@intel.com, 11-Mar-2024.
    */
    @TestVisible private static Map<Id, Boolean> hasSecondaryIntermediateParentBulk(List<Account> parentAccounts){
        Map<Id, Boolean> parentToHasSecondary = new Map<id, Boolean>();
        Map<Id, Account> parent2AccountById = new Map<Id,Account>();
        Set<Id> parent2AccountIds = new Set<Id>();
        UCD_ACM_Models.AccountResponseModel model = new UCD_ACM_Models.AccountResponseModel(); 

        for(Account parentAccount: parentAccounts) {
            if(parentAccount.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST' && parentAccount.ParentId == null) {
                parentToHasSecondary.put(parentAccount.Id, false);
            } else if(parentAccount.ParentId != null){
                parent2AccountIds.add(parentAccount.ParentId);
            }
        }
        if(!parent2AccountIds.isEmpty()) {
            parent2AccountById = accountQuerySelectorInstance.getAccountsByIds(parent2AccountIds, model.getParentAccountQueryForEvent());

            for(Account parentAccount: parentAccounts) {
                
                if(parent2AccountById.containsKey(parentAccount.ParentId) && parent2AccountById.get(parentAccount.ParentId).Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST') {
                    parentToHasSecondary.put(parentAccount.Id, true);
                } else {
                    parentToHasSecondary.put(parentAccount.Id, false);
                }
            }
        } 
        return parentToHasSecondary;
    }
    
    @InvocableMethod(label='Get CWL Label')
    public static List<String> getCWLLabel(List<String> cwlList){
        List<String> cwlLabels = new List<String>();
        List<Schema.PicklistEntry> values = Core_Account_Compliance_Watch_List__c.Core_Type__c.getDescribe().getPicklistValues();
        Map<String,String> cwlApiToLabelMap = new Map<String,String>();
        For(Schema.PicklistEntry sp : values){
            cwlApiToLabelMap.put(sp.getValue(),sp.getLabel());
        }
        for(String cwl : cwlList){
            cwlLabels.add(cwlApiToLabelMap.get(cwl));
        }
        return cwlLabels;
    }

    /**
* Method to get Parent of intel accounts based on parent BP Id
*/
public static Map<String, Account> getParentAccountByBpId(Set<Account> intelAccounts) {
    Map<String, Account> pAcctByBPId = new Map<String, Account>();
    Set<String> parentBpIds = new Set<String>();
    for (Account account : intelAccounts) {
        if (account.Core_Parent_Business_Party_Id__c != null) {
            parentBpIds.add(account.Core_Parent_Business_Party_Id__c);
        }
    }
    //UCD_ACM_Logger.information('ACM_BU_AssignParentToIntelAccount','getParentAccountByBpId','Intel Account ParentBpids: ' + parentBpIds ,null);
    if(!parentBpIds.isEmpty()){
        List<Account> pAccts;
        // SOQL to get parent account details based on BPID
        // Adding Core_Export_Compliance_Block__c Check For TWC2056-5253
        if (Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible()){
            pAccts = [
                SELECT Id, Name, Core_Business_Party_Id__c, RecordTypeId
                FROM Account
                WHERE
                Core_Business_Party_Id__c IN :parentBpIds
                AND (RecordTypeId = :intelAcctRTId OR (Core_Export_Compliance_Block__c = true AND RecordTypeId = :inactiveAcctRTId))
                ORDER BY CreatedDate ASC
            ];
        }
        // Adding data into collection - parent account by BP ID
        if (pAccts!=null && !pAccts.isEmpty()) {
            for (Account account : pAccts) {
                //Below code-line helps getting the second parent, in the case of same account as parent
                String key = pAcctByBPId.get(account.Core_Business_Party_Id__c) == null ? account.Core_Business_Party_Id__c : (account.Core_Business_Party_Id__c+'_2');
                    if (pAcctByBPId.get(key) == null) {
                        pAcctByBPId.put(key, account);
                    }
            }
        }
    }
    
    return pAcctByBPId;
}

/**
* Method to set parent to Intel accounts
*/
    public static List<Account> setParentToIntelOrECBAccount(Set<Account> accounts, Map<String, Account> pAcctByBPId) {
        List<Account> accountsToUpdate = new List<Account>();
        for(Account account : accounts){
            if(account.Core_Parent_Business_Party_Id__c != null){
                String pBPId = account.Core_Parent_Business_Party_Id__c;
                if (pBPId != null && !pAcctByBPId.isEmpty() && pAcctByBPId.get(pBPId) != null) {
                    String key = (account.Id != pAcctByBPId.get(pBPId).Id) ? pBPId : (pBPId+'_2');
                        if (account.ParentId != null && account.ParentId == pAcctByBPId.get(key).Id ) {
                            continue;
                        }
                    account.parentId = (pAcctByBPId.get(key) != null) ? pAcctByBPId.get(key).Id : null;
                } else if(pAcctByBPId.get(pBPId) == null){
                    account.parentId = null;
                }
            }
            else {
                account.parentId = null;
            }
            accountsToUpdate.add(account);
        }
        return accountsToUpdate;
    }

    public static Map<String,List<Account>> getChildAccountColl(Set<String> parentAcctBPIds,Set<Id> accIdSet){
        
        Map<String,List<Account>> childAccountMap = new Map<String,List<Account>>();
        
        if (Schema.sObjectType.Account.fields.RecordTypeId.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Parent_Business_Party_Id__c.isAccessible()  &&
            Schema.sObjectType.Account.fields.ParentId.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Business_Party_Id__c.isAccessible()  ){
                for(Account accts : [
                                    Select Id, RecordTypeId, Core_Parent_Business_Party_Id__c, ParentId, Account.Parent.Core_Business_Party_Id__c,Name
                                    From Account
                                    Where (RecordTypeId =: intelAcctRTId OR RecordTypeId =: dealAcctRTId OR (Core_Export_Compliance_Block__c = true AND RecordTypeId =: inactiveAcctRTId))
                                    AND Core_Customer_Aggregation_Type__c != null
                                    AND Core_Customer_Aggregation_Type__c != 'UNFD_GLBL_CUST'
                                    AND Core_Business_Party_Id__c != null
                                    AND Core_Parent_Business_Party_Id__c!=null
                                    //AND ParentId != null
                                    AND (Core_Parent_Business_Party_Id__c IN:parentAcctBPIds OR ParentId IN:accIdSet) LIMIT 100 
                    ]){
                        String idForMapping = accts.ParentId == null ? accts.Core_Parent_Business_Party_Id__c : accts.ParentId;
                        if(childAccountMap.get(idForMapping) != null){
                            childAccountMap.get(idForMapping).add(accts);
                        }else{
                            childAccountMap.put(idForMapping,new List<Account>{accts});
                        }
                }
            }
        
        return childAccountMap;
    }

    public static Map<Id,Account> setParentToChildAccount(List<Account> childAccounts,Map<String, List<Account>> parentAccountByBPID ){
        Map<Id,Account> acctsToUpdate = new Map<Id,Account>();
        for(Account account : childAccounts) {
            Account accountToUpdate = new Account(Id = account.Id);
            List<Account> parentAccounts = parentAccountByBPID.get(account.Core_Parent_Business_Party_Id__c);
            if(parentAccounts == null && account.Core_Parent_Business_Party_Id__c != account.Parent.Core_Business_Party_Id__c && account.ParentId != null){
                accountToUpdate.ParentId = null;
                accountToUpdate.Core_Unified_Global_Customer_BP_Id__c = null;
                accountToUpdate.Core_Unified_Global_Customer_Name__c = null;
                accountToUpdate.Core_Unified_Intermediate_Customer_BP_Id__c = null;
                accountToUpdate.Core_Unified_Intermediate_Customer_Name__c = null;
                accountToUpdate.Core_Unified_Intermdt_Customer_2_BP_Id__c = null;
                accountToUpdate.Core_Unified_Intermdt_Customer_2_Name__c = null;
                accountToUpdate.Core_Reltio_Integration_Status__c = 'REPROCESS';
                acctsToUpdate.put(accountToUpdate.Id,accountToUpdate);
            }else{
                Account parentAccount = getSameRTParentAccount(account.RecordTypeId, parentAccounts);
                if(parentAccount != null) {
                    Boolean parentUpdated = false;
                    if(parentAccount.id != account.id && (account.ParentId == null || (account.ParentId != null && account.ParentId != parentAccount.Id && account.Core_Parent_Business_Party_Id__c != parentAccount.Core_Business_Party_Id__c && account.Parent.Core_Business_Party_Id__c != parentAccount.Core_Business_Party_Id__c))) {
                        accountToUpdate.ParentId = parentAccount.Id;
                        parentUpdated = true;
                    }
                    if(account.RecordTypeId == intelAcctRTId && account.ParentId != null && parentAccount.id == account.ParentId && account.Core_Parent_Business_Party_Id__c != parentAccount.Core_Business_Party_Id__c) {
                        accountToUpdate.ParentId = null;
                        accountToUpdate.Core_Reltio_Integration_Status__c = 'REPROCESS';
                        parentUpdated = true;
                    }
                    if(parentUpdated){
                        acctsToUpdate.put(accountToUpdate.Id,accountToUpdate);
                    }
                }
            }                 
        }
        return acctsToUpdate; 
    }

    private static Account getSameRTParentAccount(Id childRecordType, List<Account> parentAccounts) {
        for(Account account : parentAccounts) {
            if(account.RecordTypeId == childRecordType) {
                return account;
            }
        }
        return null;
    }

    public static List<Account> updateAccHierarchyAttributes(List<Account> accountList){
        List<Account> accToHierarchyUpdate = new List<Account>();
        List<Account> accList = new List<Account>();
        for(Account account : accountList){
            account.Core_Unified_Global_Customer_BP_Id__c = null;
            account.Core_Unified_Global_Customer_Name__c = null;
            account.Core_Unified_Intermediate_Customer_BP_Id__c = null;
            account.Core_Unified_Intermediate_Customer_Name__c = null;
            account.Core_Unified_Intermdt_Customer_2_BP_Id__c = null;
            account.Core_Unified_Intermdt_Customer_2_Name__c = null;
            if(account.ParentId != Null){
                accToHierarchyUpdate.add(account);
            }
            else if(account.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST') {
                account.Core_Unified_Intermediate_Customer_Name__c = account.Core_Data_Simplified_Account_Nm__c;
                account.Core_Unified_Intermediate_Customer_BP_Id__c = account.Core_Business_Party_Id__c;
            }    
        }             
        if(accToHierarchyUpdate.size()>0){
            accList = UCD_ACM_Common.setAccountHierarchyFields(accToHierarchyUpdate, null);
        }
        if(accList.size()> 0){
            return accList;
        }
        return accountList;
    }
}