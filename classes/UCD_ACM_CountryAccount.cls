public without sharing class UCD_ACM_CountryAccount implements UCD_ACM_ServiceContracts.ICustomerAggregationType {
      private static UCD_ACM_DomainContracts.IAccountDomain accountDomianInstance = UCD_ACM_AccountDomain.getInstance();
      private static UCD_ACM_Models.BusinessOrganizationResponseforService modelResponse = new UCD_ACM_Models.BusinessOrganizationResponseforService();
      private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
      private static UCD_ACM_SelectorContracts.IAccountMutationSelector accountMutantSelectorInstance = UCD_ACM_AccountMutationSelector.getInstance();
  
      private static UCD_ACM_ServiceContracts.ICustomerAggregationType instance = UCD_ACM_CountryAccount.getInstance();
      private UCD_ACM_CountryAccount() {}
  
      public static UCD_ACM_ServiceContracts.ICustomerAggregationType getInstance(){
          if (instance == null) {
              instance = new UCD_ACM_CountryAccount();
          }
          return instance ;
      }
  
      /*
    * description :Validate Account request and create Account for valid Accounts
    * params :List<UCD_ACM_Models.AccountModel> accountRequestModel, List<UCD_ACM_Models.AccountModel> validAccountRequests, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse 
    * return : List<UCD_ACM_Models.BusinessOrganizationResponseforService>
    * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
    */
      public static List<UCD_ACM_Models.BusinessOrganizationResponseforService> createBusinessOrganizationRequest(List<UCD_ACM_Models.AccountModel> accountRequestModel, List<UCD_ACM_Models.AccountModel> validAccountRequests, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse ) {
          return  ValidateAccountRequest(accountRequestModel, validAccountRequests, invalidResponse);
      }
  
    /*
    * description : Validate Account request and create Account for valid Accounts
    * params : List<UCD_ACM_Models.AccountModel> accountRequestModel,List<UCD_ACM_Models.AccountModel> validAccountRequests, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse
    * return : List<UCD_ACM_Models.BusinessOrganizationResponseforService>
    * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
    */  
    private static List<UCD_ACM_Models.BusinessOrganizationResponseforService> ValidateAccountRequest(List<UCD_ACM_Models.AccountModel> accountRequestModel,List<UCD_ACM_Models.AccountModel> validAccountRequests, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse){
          validAccountRequests =  new List<UCD_ACM_Models.AccountModel>(accountRequestModel);

          accountDomianInstance.ValidateCustomerAggregationType(validAccountRequests,invalidResponse);
          accountDomianInstance.ValidateCustomerProcessEngagement(validAccountRequests,invalidResponse);
          accountDomianInstance.ValidateAccountRequestReference(validAccountRequests,invalidResponse);
          ValidateAddress(validAccountRequests,invalidResponse);
          ValidateDuplicateAccounts(validAccountRequests,invalidResponse);
  
          List<UCD_ACM_Models.BusinessOrganizationResponseforService> BusinessOrgResponseforService = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();
          if (validAccountRequests.size() > 0) {
              Map<Id,Account>  AccountById = accountMutantSelectorInstance.createAccount(validAccountRequests);
              BusinessOrgResponseforService = validateAccountResponse(AccountById);
          }
          BusinessOrgResponseforService.addAll(invalidResponse);
          return BusinessOrgResponseforService;
    }
  
    /*
    * description : Validate Country Details
    * params : List<UCD_ACM_Models.AccountModel> validAccountRequests, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse
    * return : N/A
    * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
    */
    private static void  ValidateAddress(List<UCD_ACM_Models.AccountModel> validAccountRequests, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse){
        for(Integer index = 0 ; index < validAccountRequests.size() ; index++){
            Boolean isValid = true;
            for (UCD_ACM_Models.AccountAddress address : validAccountRequests[index].Addresses) {
                isValid = !(String.isBlank(address.CountryCode) && String.isBlank(address.CountryName));
                if (String.isNotBlank(address.CountryCode)) {
                    String countryName = UCD_ACM_Utils.validateCountryCode(address.CountryCode);
                    isValid = String.isNotBlank(countryName);
                    address.CountryName = String.isNotBlank(countryName)? countryName: null;
                } else if (String.isNotBlank(address.CountryName)) {
                    String countryCode = UCD_ACM_Utils.validateCountryname(address.CountryName);
                    isValid = String.isNotBlank(countryCode);
                    address.CountryCode = String.isNotBlank(countryCode)? countryCode: null;
                }
            }
            if (!isValid) {
                invalidResponse.add( modelResponse.mapAccountsToAccountResponseModel (new Account (name = validAccountRequests[index].Name), '', validAccountRequests[index].Addresses.size()>0 ? validAccountRequests[index].Addresses[0].CountryName : null,'Invalid Country Details','',validAccountRequests[index].DuplicateAccountInfo) );
                validAccountRequests.remove(index);
                index-- ;
            }
        }
       
    }

    /*
    * description : Validate Duplicate SF Account
    * params : List<UCD_ACM_Models.AccountModel> accountModel
    * return : UCD_ACM_Models.AccountResponseModel
    * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
    */
    private static void ValidateDuplicateAccounts(List<UCD_ACM_Models.AccountModel> validAccountRequests, List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse){
        Set<String> accountNames = new Set<String>();
        String queryFields = 'Id,Name,Recordtype.Name,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_Data_Simplified_Account_Nm__c,'+
                            +'Core_Data_Country_Nm__c,Core_Customer_Aggregation_Type__c,CreatedDate,Core_Business_Party_Id__c,ParentId,'+
                            +'Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Core_Survivor_Account_Id__c,Core_Parent_Business_Party_Id__c';
        for(UCD_ACM_Models.AccountModel accountData : validAccountRequests){
                accountNames.add(accountData.Name);
        }
        List<Account> accountByName = accountQuerySelectorInstance.selectAccountsByName(accountNames,queryFields);
        accountDomianInstance.validateDuplicateAccountRequests(validAccountRequests,accountByName, invalidResponse);
        
    }
  
    /*
    * description : Success/Failure Account response mapping after creation
    * params : Map<Id,Account>  AccountById
    * return : List<UCD_ACM_Models.BusinessOrganizationResponseforService>
    * author and date : ankit1x.sharma@intel.com, 06 Dec 2021
    */
    private static List<UCD_ACM_Models.BusinessOrganizationResponseforService> validateAccountResponse(Map<Id,Account>  AccountById){
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> responsevalidator = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();
            if(AccountById.size()>0){
                for(Account accountRecord :AccountById.values()){
                    responsevalidator.add(modelResponse.mapAccountsToAccountResponseModel (accountRecord, 'Requested Account', UCD_ACM_Utils.validateCountryCode(accountRecord.BillingCountryCode),'',accountRecord.Id,null));
                }
            }else{
                responsevalidator.add(modelResponse.mapAccountsToAccountResponseModel (null, '', null,'Error in creating Accounts','', null));
            }
            return responsevalidator;
    }
  
  }