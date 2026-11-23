/********* 
 * Author: Ankit Sharma
 * Date: 30/09/2021
 * Test class for UCD_BizOrgRequestController 
*********/
@IsTest
public class UCD_BizOrgRequestControllerTest {
    
    private static UCD_BizOrgRequestModel Model;
    private static User uu;
    
     @TestSetup
    private static void setCommonData(){
        Profile pf= [Select Id from profile where Name='Integration' LIMIT 1]; 
        
        user uu = UCD_ACM_Cntrlr_TestDataInitialization.createUser(pf.Id); 
        insert uu;
		system.runAs(uu) {
            // Create Business Type
            Business_Types__c businessType = UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT');
            insert businessType;
        }
    }
    
    private static UCD_BizOrgRequestModel.AccountDetail fetchData(String Name, String CustomerAggregation, String CustomerProcess, String TypeCode, String CountryCode, String CountryName){
         uu = [select id from User where profile.name = 'Integration' LIMIT 1];

    	UCD_BizOrgRequestModel.AccountDetail modelAcc = new UCD_BizOrgRequestModel.AccountDetail();
			modelAcc.Name = Name ;
			modelAcc.CustomerAggregationTypeCode = CustomerAggregation ;
			modelAcc.CustomerProcessEngagmentCode = CustomerProcess ;
	
			List<UCD_BizOrgRequestModel.AccountAddresses> Addresses1  = new List<UCD_BizOrgRequestModel.AccountAddresses>();
				UCD_BizOrgRequestModel.AccountAddresses  addwrap  = new UCD_BizOrgRequestModel.AccountAddresses();
				addwrap.TypeCode = TypeCode;
				addwrap.CountryCode = CountryCode;
				addwrap.CountryName = CountryName;
			Addresses1.add(addwrap);
		modelAcc.Addresses = Addresses1;

        modelAcc.ParentBusinessPartyIdentifierReference = 'TestParentBPIdRef';
        return modelAcc;
       
    }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForSuccess(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        UCD_BizOrgRequestModel.AccountDetail AccountRecord2 = fetchData('TestAccountFor02', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Shipping', 'AFG', 'Afghanistan');

       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        lstOfRequest.add(AccountRecord2);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
			System.assertEquals(response[0].Code, '200');
        }
   }
    
    @isTest
    private static void whenMydealsSendAndAccountInsertMissingname(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
            System.assertEquals(response[0].Errormessage, 'Name, CustomerAggregationTypeCode and CustomerProcessEngagmentCode are mandatory fields');
         }
    }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertMissingCountry(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('TestAccount02', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', '', '');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
            System.assertEquals(response[0].Errormessage, 'CountryCode/CountryName is required');
         }
    }
    
    @isTest
    private static void whenMydealsSendAndAccountInsertWrongCountryLength(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('TestAccount02', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'INDA', '');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			 List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
             System.assertEquals(response[0].Errormessage, 'CountryCode length is not valid. Expected 3-character CountryCode');
         }
    }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForDuplicateAccount(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        UCD_BizOrgRequestModel.AccountDetail AccountRecord2 = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');

       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        lstOfRequest.add(AccountRecord2);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			 List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
             System.assertEquals(response[0].Code, '200');
         }
   }

     @isTest
    private static void whenMydealsSendAndAccountInsertForInvalidCustomerProcess(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('TestAccountFor01', 'abc', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			 List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
             System.assertEquals(response[0].Errormessage, 'CustomerAggregationTypeCode is not valid');
         }
   }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForInvalidCustomerAggregation(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'abc', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			 List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
             System.assertEquals(response[0].Errormessage, 'CustomerProcessEngagement is not valid');
         }
   }
    
      @isTest
    private static void whenMydealsSendAndAccountInsertForSuccessMissingCountryCode(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', '', 'Afghanistan');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			 List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
            System.debug('Model==>'+Model);
            System.debug('whenMydealsSendAndAccountInsertForSuccessMissingCountryCode==>'+response);
             System.assertEquals(response[0].Code, '200');
         }
   }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForDuplicateAccountInSF(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			 List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
             System.assertEquals(response[0].Code, '200');
         }
        
        UCD_BizOrgRequestModel.AccountDetail AccountRecord1 = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest1 = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest1.add(AccountRecord1);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest1;
        system.runAs(uu) {
			 List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response1 = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
             System.assertEquals(response1[0].Errormessage, 'Duplicate Account');
         }
   }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForDuplicateAccountInSfMissingCountryCode(){
        UCD_BizOrgRequestModel.AccountDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', '', 'Afghanistan');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest.add(AccountRecord);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest;
        system.runAs(uu) {
			 List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
             System.assertEquals(response[0].Code, '200');
         }
        
        UCD_BizOrgRequestModel.AccountDetail AccountRecord1 = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', '', 'Afghanistan');
        
       	List<UCD_BizOrgRequestModel.AccountDetail> lstOfRequest1 = new List<UCD_BizOrgRequestModel.AccountDetail>();
		lstOfRequest1.add(AccountRecord1);
        
     	Model = new UCD_BizOrgRequestModel();
		Model.AccountRequests = lstOfRequest1;
         system.runAs(uu) {
		List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> response1 = UCD_BizOrgRequestController.createBusinessOrganizationRequest(Model);
             System.debug('response12==>'+response1);
             System.assertEquals(response1[0].Errormessage, 'Duplicate Account');
         }
   }
	
}