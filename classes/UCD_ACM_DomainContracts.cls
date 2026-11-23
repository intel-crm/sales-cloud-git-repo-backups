public without sharing class UCD_ACM_DomainContracts {
    public interface IAccountDomain {
        void ValidateCustomerAggregationType(List<UCD_ACM_Models.AccountModel> validAccountRequests,  List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse);
        void ValidateCustomerProcessEngagement(List<UCD_ACM_Models.AccountModel> validAccountRequests,  List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse);
        void validateDuplicateAccountRequests(List<UCD_ACM_Models.AccountModel> validAccountRequests, List<Account> nameBasedAccounts, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse );
        Map<Id,UCD_ACM_Models.AccountResponseModel> getAccountDetailsForDuplicate(List<Account> accounts);
        void restrictUpdatingSFFields(List<Account> newValues, List<Account> oldvalues);
        void setParentOnUpdateOrMergeInMDM(UCD_ACM_UnitOfWork unitwork, List<Account> updatedParentAccountsInMDM, List<Account> mergedAccountsInMDM, Map<Id,Account> parentAccountById, Map<String,List<Account> > parentAccountsByBpId, Map<String,List<Account> > accountsByBpId);
        void ValidateAccountRequestReference(List<UCD_ACM_Models.AccountModel> validAccountRequests,  List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse);
        void updateRecordtype( List<Account> newValues, Map<Id, Account> oldAccounts);
        void updateParentAccountRecordtype(UCD_ACM_UnitOfWork unitwork, List< Account > newAccounts , Map< Id , Account > oldAccountById);
    }

    public interface IContactDomain {
        //Core_UCD_MoveContactWithCases_Model.initializeWrapper GECCaseValidation(List<Case> caseDetails, Core_UCD_MoveContactWithCases_Model.initializeWrapper initializeWrapper);
    }
}