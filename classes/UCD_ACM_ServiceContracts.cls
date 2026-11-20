public without sharing class UCD_ACM_ServiceContracts {
    public interface IAccountService {
        List <UCD_ACM_Models.BusinessOrganizationResponseforService> createBusinessOrganizationRequest (List<UCD_ACM_Models.AccountModel> accountModel);
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse getBusinessOrganization(UCD_ACM_BusinessOrganizationModel requestModel);
        Map<Id,Business_Types__c> getBusinessTypeMap(Set<Id> businessTypeIds, String queryFields);
        void updateACMIntegrationMessage(Set<Id> accountIds);
        //Map<Id,String> getComplianceWatchListByAccountId(Set<Id> accountIds);
        Map<Id,List<Business_Types__c>> getActiveBusinessTypeForAccount(Set<Id> accountIds);
    }
    
    public interface ICustomerAggregationType {
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> createBusinessOrganizationRequest(List<UCD_ACM_Models.AccountModel> accountRequestModel, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse );
    }

    public interface IMDMService {
        List<UCD_ACM_Models.ReltioResponse> searchAccountReltio(UCD_ACM_Models.SearchRequest requestPayload);
        List<UCD_ACM_ReltioModels.UpdateResponseModel> updateEntity(Map<String, UCD_ACM_ReltioModels.UpdateRequest> updateRequests);        
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
}