@isTest
public without sharing class UCD_ACM_AddressVerificationReqstQue_Test {
    @TestSetup
    private static void setCommonData(){
        Account_Create_Request__c accountCreateRequest=new Account_Create_Request__c();
        accountCreateRequest.Account_Name__c = 'Test';
        accountCreateRequest.Customer_Process_Engagement__c='DIR_PRC_EXCPT';
        accountCreateRequest.Rejected_Reason__c = 'Test Rejected';
        accountCreateRequest.Request_Flow_Status__c = 'Pending';
        accountCreateRequest.Process_Type__c = 'Opportunity Management';
        accountCreateRequest.Requestor_Name__c = UserInfo.getName();
        accountCreateRequest.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        accountCreateRequest.Address__City__s = 'Seymour';
        accountCreateRequest.Address__CountryCode__s = 'USA';
        accountCreateRequest.Address__Street__s = '36 Cogwheel Ln';
        accountCreateRequest.Address__StateCode__s = 'CT';
        accountCreateRequest.Address__PostalCode__s='06483-3922';
        insert accountCreateRequest;
    }
    public class UCD_ACM_AddressVerificationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{"type":"configuration/entityTypes/CustomerLocation","crosswalks":[{"value":"SfdcId","type":"configuration/sources/Salesforce"}],"attributes":{"Zip":[{"value":{"Zip5":[{"value":"06483","ov": true}]}}],"StateProvince":[{"value":"Connecticut","ov": true,"lookupCode":"US_CT"}],"Country":[{"value":"United States","ov": true}],"City":[{"value":"Seymour","ov": true}],"AddressLine1":[{"value":"36 Cogwheel Ln","ov": true}],"VerificationStatus":[{"value": "Verified","ov": true}]}}]');
            response.setStatusCode(200);
            return response; 
        }
    }
    public class UCD_ACM_AddressVerificationFlowMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{"type":"configuration/entityTypes/CustomerLocation","crosswalks":[{"value":"aDoD300000004udKAA","type":"configuration/sources/Salesforce"}],"attributes":{"Zip":[{"value":{"Zip5":[{"value":"06483","ov": true}]}}],"StateProvince":[{"value":"Connecticut","ov": true,"lookupCode":"US_CT"}],"Country":[{"value":"United States","ov": true}],"City":[{"value":"Seymour","ov": true}],"AddressLine1":[{"value":"36 Cogwheel Ln","ov": true}],"VerificationStatus":[{"value": "Verified","ov": true}]}}]');
            response.setStatusCode(200);
            return response; 
        }
    }
    @istest
    private static void addressVerificationTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UCD_ACM_AddressVerificationMock()); 
        UCD_ACM_AddressVerificationOnReqstQueue.LoqateResponseDataModel loqateResponse=UCD_ACM_AddressVerificationOnReqstQueue.addressVerification('36 Cogwheel Ln','Seymour','CT','USA','06483-3922');
        Test.stopTest();
        System.assertEquals('Seymour', loqateResponse.cityName);
    }

    @isTest
    private static void whenAddressVerificationApiTest(){
        List<Account_Create_Request__c> accountReq=[Select Id,CreatedDate,Requestor_Name__c,Process_Type__c,Account_Name__c, Core_Alternate_Language_Name__c, Status__c, Address__CountryCode__s, Address__Street__s, Address__City__s,Address__StateCode__s,Address__PostalCode__s From Account_Create_Request__c Where Account_Name__c='Test'];
        List<Id> ids=new List<Id>();
        ids.add(accountReq[0].Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UCD_ACM_AddressVerificationFlowMock());
        UCD_ACM_AddressVerificationOnReqstQueue.addressVerificationApiCall(ids);
        Test.stopTest();
        System.assertEquals('Seymour', accountReq[0].Address__City__s);
    }
}