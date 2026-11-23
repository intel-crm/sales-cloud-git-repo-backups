@IsTest
public class UCD_ACM_CountryAccountTest {
    private static UCD_ACM_ServiceContracts.ICustomerAggregationType accountCountryInstance = UCD_ACM_CountryAccount.getInstance();
@isTest
    private static void whenValidateAccountRequest(){
        List<UCD_ACM_Models.AccountModel> accountRequest = new List<UCD_ACM_Models.AccountModel>();
        List<UCD_ACM_Models.AccountModel> validAccounts = new List<UCD_ACM_Models.AccountModel>();
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();
        List <UCD_ACM_Models.BusinessOrganizationResponseforService> responseModel = new List <UCD_ACM_Models.BusinessOrganizationResponseforService>();
    	accountRequest.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount1','UNFD_CTRY_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India',''));
        test.startTest();
        responseModel = accountCountryInstance.createBusinessOrganizationRequest(accountRequest,validAccounts,invalidResponse);
        system.assertEquals('India', responseModel[0].CountryName);
        test.stopTest();
    }
    
    @isTest
    private static void whenValidateAccountRequestWithCountryCode(){
        List<UCD_ACM_Models.AccountModel> accountRequest = new List<UCD_ACM_Models.AccountModel>();
        List<UCD_ACM_Models.AccountModel> validAccounts = new List<UCD_ACM_Models.AccountModel>();
        List<UCD_ACM_Models.BusinessOrganizationResponseforService> invalidResponse = new List<UCD_ACM_Models.BusinessOrganizationResponseforService>();
        List <UCD_ACM_Models.BusinessOrganizationResponseforService> responseModel = new List <UCD_ACM_Models.BusinessOrganizationResponseforService>();
        accountRequest.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount','UNFD_CTRY_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India','IND'));
        test.startTest();
        responseModel = accountCountryInstance.createBusinessOrganizationRequest(accountRequest,validAccounts,invalidResponse);
        system.assertEquals('TestAccount', responseModel[0].AccountData.Name); 
        test.stopTest();
    }
}