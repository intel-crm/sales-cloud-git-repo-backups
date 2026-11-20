/********* 
 * Author: Ankit Sharma
 * Date: 30/09/2021
 * Test class for UCD_BizOrgRequestRestController 
*********/
@IsTest
public class UCD_BizOrgRequestRestControllerTest {
    
    private static RestRequest request = new RestRequest();
    private static UCD_BizOrgRequestRestModel restModel;
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
    
    private static UCD_BizOrgRequestRestModel.AccountRestDetail fetchData(String Name, String CustomerAggregation, String CustomerProcess, String TypeCode, String CountryCode, String CountryName){
        
        uu = [select id from User where profile.name = 'Integration' LIMIT 1];
            
        request.requestURI = '/services/apexrest/BusinessOrganizationRequest';
        request.httpMethod = 'POST';
        
    	UCD_BizOrgRequestRestModel.AccountRestDetail modelAcc = new UCD_BizOrgRequestRestModel.AccountRestDetail();
			modelAcc.Name = Name ;
			modelAcc.CustomerAggregationTypeCode = CustomerAggregation ;
			modelAcc.CustomerProcessEngagmentCode = CustomerProcess ;
	
			List<UCD_BizOrgRequestRestModel.AccountRestAddresses> Addresses1  = new List<UCD_BizOrgRequestRestModel.AccountRestAddresses>();
				UCD_BizOrgRequestRestModel.AccountRestAddresses  addwrap  = new UCD_BizOrgRequestRestModel.AccountRestAddresses();
				addwrap.TypeCode = TypeCode;
				addwrap.CountryCode = CountryCode;
				addwrap.CountryName = CountryName;
			Addresses1.add(addwrap);
		modelAcc.Addresses = Addresses1;

        UCD_BizOrgRequestRestModel.AccountRestRequestReference requestReference = new UCD_BizOrgRequestRestModel.AccountRestRequestReference();
        requestReference.Name = 'MyDeals';
        requestReference.Value = 'TestRefValue';
        List<UCD_BizOrgRequestRestModel.AccountRestRequestReference> requestReferences  = new List<UCD_BizOrgRequestRestModel.AccountRestRequestReference>();
        requestReferences.add(requestReference);
        modelAcc.AccountRequestReferences = requestReferences;

        modelAcc.ParentBusinessPartyIdentifierReference = 'TestParentBPIdRef';

        return modelAcc;
       
    }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForSuccess(){       
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord2 = fetchData('TestAccountFor02', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Shipping', 'AFG', 'Afghanistan');
		
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        lstOfRequest.add(AccountRecord2);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
        	System.assertEquals(response[0].code, '200');
         }
   }

   @isTest
    private static void whenMydealsThrowException(){       
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord2 = fetchData('TestAccountFor02', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Shipping', 'AFG', 'Afghanistan');
		
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        lstOfRequest.add(AccountRecord2);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
        	UCD_ACM_AccountService.isTestException = true;
            System.assertEquals(response[0].code, '200');
         }
   }
    
    @isTest
    private static void whenMydealsSendAndAccountInsertMissingname(){

        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
            System.assertEquals(response[0].ErrorMessage, 'Name, CustomerAggregationTypeCode and CustomerProcessEngagmentCode are mandatory fields');
        }
    }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertMissingCountry(){
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccount02', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', '', '');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
			System.assertEquals(response[0].ErrorMessage, 'CountryCode/CountryName is required');
        }
    }
    
    @isTest
    private static void whenMydealsSendAndAccountInsertWrongCountryLength(){
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccount02', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'INDA', '');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
			System.assertEquals(response[0].ErrorMessage, 'CountryCode length is not valid. Expected 3-character CountryCode');
        }
    }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForDuplicateAccount(){
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord2 = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        lstOfRequest.add(AccountRecord2);
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
			System.assertEquals(response[0].Code, '200');
        }
   }

     @isTest
    private static void whenMydealsSendAndAccountInsertForInvalidCustomerProcess(){
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccountFor01', 'abc', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
         	System.assertEquals(response[0].ErrorMessage, 'CustomerAggregationTypeCode is not valid');
        }
   }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForInvalidCustomerAggregation(){
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'abc', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
			System.assertEquals(response[0].ErrorMessage, 'CustomerProcessEngagement is not valid');
        }
   }
    
      @isTest
    private static void whenMydealsSendAndAccountInsertForSuccessMissingCountryCode(){
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', '', 'Afghanistan');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
			System.assertEquals(response[0].Code, '200');
        }
   }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForDuplicateAccountInSF(){
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
            System.assertEquals(response[0].Code, '200');

         }
        
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord1 = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', 'AFG', 'Afghanistan');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest1 = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest1.add(AccountRecord1);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest1;
        jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response1 = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
        	System.assertEquals(response1[0].ErrorMessage, 'Duplicate Account');
        }
   }
    
     @isTest
    private static void whenMydealsSendAndAccountInsertForDuplicateAccountInSfMissingCountryCode(){
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', '', 'Afghanistan');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest.add(AccountRecord);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest;
        String jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
        system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
             System.assertEquals(response[0].Code, '200');
         }
        
        UCD_BizOrgRequestRestModel.AccountRestDetail AccountRecord1 = fetchData('TestAccountFor01', 'UNFD_CTRY_CUST', 'DIR_PRC_EXCPT', 'Billing', '', 'Afghanistan');
        
       	List<UCD_BizOrgRequestRestModel.AccountRestDetail> lstOfRequest1 = new List<UCD_BizOrgRequestRestModel.AccountRestDetail>();
		lstOfRequest1.add(AccountRecord1);
        
     	restModel = new UCD_BizOrgRequestRestModel();
		restModel.AccountRequests = lstOfRequest1;
        jsonReq = JSON.serialize(restModel); 
        request.requestBody = Blob.valueof(jsonReq);
        RestContext.request = request;
         system.runAs(uu) {
			List<UCD_BizOrgRequestRestModel.BusinessOrganizationResponse> response1 = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
			System.assertEquals(response1[0].ErrorMessage, 'Duplicate Account');
        }
   }
	
    
    
}