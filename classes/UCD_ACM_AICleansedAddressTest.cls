@isTest
public without sharing class UCD_ACM_AICleansedAddressTest {
    
    @TestSetup
    private static void setCommonData(){
        Account_Create_Request__c accountCreateRequest=new Account_Create_Request__c();
        accountCreateRequest.Account_Name__c = 'Google';
        accountCreateRequest.Customer_Process_Engagement__c='DIR_PRC_EXCPT';
        accountCreateRequest.Rejected_Reason__c = 'Test Rejected';
        accountCreateRequest.Request_Flow_Status__c = 'Pending';
        accountCreateRequest.Process_Type__c = 'Opportunity Management';
        accountCreateRequest.Requestor_Name__c = UserInfo.getName();
        accountCreateRequest.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        accountCreateRequest.Address__City__s = 'Mountain View';
        accountCreateRequest.Address__CountryCode__s = 'USA';
        accountCreateRequest.Address__Street__s = '1600 Amphitheatre Parkway';
        accountCreateRequest.Address__StateCode__s = 'CA';
        accountCreateRequest.Address__PostalCode__s='1351';
        insert accountCreateRequest;

        Core_Country_Code_Mapping__c countryMapping = new Core_Country_Code_Mapping__c(
            Name = 'United States',
            ISO_Code__c = 'USA'
        );
        insert countryMapping;
    }
    public class UCD_ACM_AddressVerificationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"data": {"organization": "Google","address": "1600 Amphitheatre Parkway","country": "USA","stateProvince": "CA","city": "Mountain View","postalCode": ""},"cleansed": {"address": "1600 Amphitheatre Pkwy","country": "United States","countryAlpha2": "US","stateProvince": "California","city": "Mountain View","postalCode": "94043-1351","explanation": "The address was verified and standardized using Loqate. The street type was abbreviated to USPS standards, and the postal code was completed.","language": "English","addrVerificationStatus": "Verified"},"requestTimeMs": 4824,"confidence": 0.0,"scoreBreakdown": {}}');
            response.setStatusCode(200);
            return response; 
        }
    }
    public class UCD_ACM_AddressVerificationFlowMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"data": {"organization": "Google","address": "1600 Amphitheatre Parkway","country": "USA","stateProvince": "CA","city": "Mountain View","postalCode": ""},"cleansed": {"address": "1600 Amphitheatre Pkwy","country": "United States","countryAlpha2": "US","stateProvince": "California","city": "Mountain View","postalCode": "94043-1351","explanation": "The address was verified and standardized using Loqate. The street type was abbreviated to USPS standards, and the postal code was completed.","language": "English","addrVerificationStatus": "Verified"},"requestTimeMs": 4824,"confidence": 0.0,"scoreBreakdown": {}}');
            response.setStatusCode(200);
            return response; 
        }
    }
    @istest
    private static void addressVerificationTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UCD_ACM_AddressVerificationMock()); 
        UCD_ACM_AICleansedAddress.AIAddressResponseDataModel loqateResponse=UCD_ACM_AICleansedAddress.addressVerification('Google','1600 Amphitheatre Parkway','USA','CA','Mountain View','1351');
        Test.stopTest();
    }
    
    @isTest
    static void testDataModelClasses() {
        Test.startTest();
        
        // Test RequestBody
        UCD_ACM_AICleansedAddressDataModel.RequestBody requestBody = 
            new UCD_ACM_AICleansedAddressDataModel.RequestBody();
        UCD_ACM_AICleansedAddressDataModel.RequestData requestData = 
            new UCD_ACM_AICleansedAddressDataModel.RequestData();
        
        requestData.organization = 'Test Org';
        requestData.address = 'Test Address';
        requestData.country = 'Test Country';
        requestData.stateProvince = 'Test State';
        requestData.city = 'Test City';
        requestData.postalCode = '12345';
        
        requestBody.data = requestData;
        
        // Test ResponseBody
        UCD_ACM_AICleansedAddressDataModel.ResponseBody responseBody = 
            new UCD_ACM_AICleansedAddressDataModel.ResponseBody();
        UCD_ACM_AICleansedAddressDataModel.ResponseData responseData = 
            new UCD_ACM_AICleansedAddressDataModel.ResponseData();
        UCD_ACM_AICleansedAddressDataModel.CleansedData cleansedData = 
            new UCD_ACM_AICleansedAddressDataModel.CleansedData();
        
        responseData.organization = 'Test Org';
        responseData.address = 'Test Address';
        responseData.country = 'Test Country';
        
        cleansedData.organization = 'Test Org';
        cleansedData.address = 'Test Address';
        cleansedData.country = 'Test Country';
        cleansedData.countryAlpha2 = 'TC';
        cleansedData.stateProvince = 'Test State';
        cleansedData.city = 'Test City';
        cleansedData.postalCode = '12345';
        cleansedData.explanation = 'Test Explanation';
        cleansedData.language = 'en';
        cleansedData.addrVerificationStatus = 'VERIFIED';
        
        responseBody.data = responseData;
        responseBody.cleansed = cleansedData;
        responseBody.requestTimeMs = 100;
        responseBody.confidence = 0.95;
        
        Test.stopTest();
        
        // Assertions
        System.assertEquals('Test Org', requestBody.data.organization, 'Request organization should match');
        System.assertEquals('Test Org', responseBody.data.organization, 'Response organization should match');
        System.assertEquals('VERIFIED', responseBody.cleansed.addrVerificationStatus, 'Verification status should match');
        System.assertEquals(100, responseBody.requestTimeMs, 'Request time should match');
        System.assertEquals(0.95, responseBody.confidence, 'Confidence should match');
    }
}