public without sharing class UCD_ACM_ServiceContracts {

    public interface IAccountService {
        List <UCD_ACM_Models.BusinessOrganizationResponseforService> createBusinessOrganizationRequest (List<UCD_ACM_Models.AccountModel> accountModel);
        void updateHierarchyFields(Account account, Boolean updateChildAccounts);
        void updateAccRecordTypeByBpId(List<Account> accounts,Map<Id,Account> oldAccountById);
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse getBusinessOrganization(UCD_ACM_BusinessOrganizationModel requestModel);
        void restrictUpdatingSFFields(List<Account> newValues, List<Account> oldvalues);
        Map<Id,Account> getAccountMap(Set<Id> accountIds, String queryFields);
        Map<Id,Business_Types__c> getBusinessTypeMap(Set<Id> businessTypeIds, String queryFields);
        void updateACMIntegrationMessage(Set<Id> accountIds);
        void onUpdatedOrMergedAccountsInMDM(List<Account> updatedOrMergedAccountsInMDM, List<Account> mergedAccountsInMDM,Set<String> currentAccountsBpIds,Set<Id> parentAcountIds);
        Map<Id,String> getComplianceWatchListByAccountId(Set<Id> accountIds);
       // Map<Id,String> getBusinessTypesByAccountId(Set<Id> accountIds);
        Map<Id,List<Business_Types__c>> getActiveBusinessTypeForAccount(Set<Id> accountIds);
        void updateRecordtype(List<Account> newValues, Map<Id, Account> oldAccounts);
        void updateParentAccountRecordtype(List<Account> newAccounts, Map<Id, Account> oldAccountById);
        //Boolean ApproveAccountRequest(List<Account_Create_Request__c> lstOfAccountCreateRequest);
        //Boolean RejectAccountRequest(List<Account_Create_Request__c> lstOfAccountCreateRequest);
        //List<Account> search();

    }
    public interface IAccountRecordType {
        List<UCD_ACM_Models.AccountResponseModel> createBusinessOrganization(List<UCD_ACM_Models.AccountModel> accountRequestModel);
    }
    public interface ICustomerAggregationType {
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> createBusinessOrganizationRequest(List<UCD_ACM_Models.AccountModel> accountRequestModel, List<UCD_ACM_Models.AccountModel> validAccountRequests, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse );

    }

    public interface IMDMService {
        List<UCD_ACM_Models.ReltioResponse> searchAccountReltio(UCD_ACM_Models.SearchRequest requestPayload);
    }

    public interface IBeforeInsertAccountTrigger {
        void execute(List<Account> newAccounts);
    }

    public interface IAfterInsertAccountTrigger {
        void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts);
    }

    public interface IBeforeUpdateAccountTrigger {
        void execute(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts);
    }

    public interface IAfterUpdateAccountTrigger {
        void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts);
    }
    /*public interface IAContactService {
        Core_UCD_MoveContactWithCases_Model.initializeWrapper getCurrContactDetails(String contactId);
        Core_UCD_MoveContactWithCases_Model.ResponseModel caseUpdate();
     }
 
     public interface IContactMoveGovernance {
         Core_UCD_MoveContactWithCases_Model.initializeWrapper getCurrContactDetails(String contactId); 
         Core_UCD_MoveContactWithCases_Model.ResponseModel caseUpdate();
      }*/
}