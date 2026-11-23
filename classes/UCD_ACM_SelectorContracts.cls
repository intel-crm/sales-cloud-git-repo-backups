public without sharing class UCD_ACM_SelectorContracts {
    public interface IUnitOfWork {
        // Any register operation is going to be performed on commitWork method
        // Register Insert methods
        void registerNew(SObject record);
        void registerNew(List<SObject> records);
        void registerNew(SObject record,Schema.SObjectField relatedToParentField, SObject relatedToParentRecord);

        // Register Update methods
        void registerModified(SObject record);
        void registerModified(SObject record, List<SObjectField> fieldsToUpdate);
        
        // Register Delete methods
        void registerDeleted(SObject record);
        
        // All operations batched together and executed
        Boolean commitWork();
    }

    public interface IAccountQuerySelector {
        Map<Id,Account> getAccountsByIds(Set<Id> accountIds, String queryFields);
        List<Account> selectAccountsByName(Set<String> accountNames, String queryFields);
        Map<Id,List<Business_Types__c>> getBusinessTypesByAccountId(Set<Id> accountIds, String queryFields);
        Map<Id,List<Account_Create_Request__c>> getAccountRequestQueueByAccountId(Set<Id> accountIds, String queryFields);   
        Map<String,Business_Types__c> getBusinessTypeId(Set<String> typeCodes);
        //String getAccountByBpId(String bpId);
        Map<Id,Account> getAccountsByIds(Set<Id> accountIds, String queryFields, String andClause);
        Map<Id,Account> getAccountsByParentId(Set<Id> parentIds, String queryFields, String andClause);
        Map<Id,Business_Types__c> getBusinessTypeById(Set<Id> businessTypeIds,String queryFields);
        Map<Id,ACM_Integration_Message_Queue__c> getIntegrationMessageQueueByAccountId (Set<Id> accountId);
        Map<String,List<Account>> getAccountByBpId(Set<String> BpIds);
        //Map<Id,User> getUserById(Set<Id> userIds);
        Map<Id,Account> getAccountsByParentId(Set<Id> parentIds, String queryFields);
        Map<Id, Account> getAllChildAccounts(Set<Id> parentAccIds);
        Map< Id, List<Account> > getChildAccountsWithParent(Set<Id> parentIds, String queryFields, String andClause);
        Map<Id,Account_Create_Request__c> getAccountRequestQueueById(Set<Id> aqrIds, String queryFields);
        Map<Id,ACM_Integration_Message_Queue__c> getIntegrationMessageQueueByArqId (Set<Id> arqIds);

    }

    public interface IAccountMutationSelector {
         Map<Id,Account>  createAccount( List <UCD_ACM_Models.AccountModel> accountModel);
         void setIntegrationMessage(Set<Id> accountIds);
         void updateIntegrationMsgQueueStatus(Set<Id> accountIds,String statusType);
         void updateIntegrationMsgQueueStatusForARQ(Set<Id> arqIds, String statusType);
         //void createAccountByList(List<Account> accounts);
         //Map<Id,Account_Create_Request__c>  approveAccountRequest (List<Account_Create_Request__c> lstOfAccountCreateRequest);
         //Boolean  rejectAccountRequest (List<Account_Create_Request__c> lstOfAccountCreateRequest);
    } 
    /* unused code
    public interface IContactQuerySelector {
        List<Contact> getCurrContactDetails(String contactId, String queryFields);
        List<Case> getCaseDetails(String contactId, String queryFields);
        List<Asset> assetDetails(String queryFields, String whereClause);
        List<Core_Contact_Entitlement__c>  getEntitlementsDetails(String contactId, String queryFields);
        Account getTargetAccountObj(String AccountId, String accountQueryFields);
       // List<Contact_Move_Governance__c> getContactMoveGovDetails(String ContactMoveGovId , String contactMoveGovQueryFields);
    }*/
}