@isTest
public class UCD_AcctDeactReActivationBatch_Test {
    @testSetup static void createSetupData() {
        
        Account account = new Account();
        account.Name = 'Test Deactivation Account';
        account.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        account.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        account.BillingCountryCode	= 'IND';
        account.BillingCity = 'TestCity';
        account.BillingStreet = 'TestStreet';
        account.Core_Business_Party_Id__c = '1001882777';
        account.ShippingCountryCode = 'IND';
        insert account;
        account.Core_Deactivated__c = true;
        account.Core_Deactivation_Reason__c = 'Salesforce Cleanup';
        update account;
        Business_Types__c busniessType = new Business_Types__c();
        busniessType.Is_Active__c = true;
        busniessType.Business_Type_Code__c = 'SLS_CRM';
        busniessType.Name = 'Sales CRM';
        busniessType.Business_Types_Category__c = 'CPE';
        insert busniessType;
        Account_Business_Types__c accBusinessTypes = new Account_Business_Types__c();
        accBusinessTypes.Account__c = account.Id;
        accBusinessTypes.Business_Types__c = busniessType.Id;
		accBusinessTypes.Effective_Start_Date__c = System.Today();
        insert accBusinessTypes;

    }

    @isTest
    public static void testRetryDeactivationBatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse_Retry());
        UCD_ACM_AcctDeactivtionReactivtion_Batch ucdDeactivatioReactivation = new UCD_ACM_AcctDeactivtionReactivtion_Batch();
        Database.executeBatch(ucdDeactivatioReactivation,1); 
        Test.StopTest();
        
    }
    @isTest
    public static void testDeactivationBatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse_Reactivated());
        UCD_ACM_AcctDeactivtionReactivtion_Batch ucdDeactivatioReactivation = new UCD_ACM_AcctDeactivtionReactivtion_Batch();
        Database.executeBatch(ucdDeactivatioReactivation,1); 
        Test.StopTest();
        
    }
    @isTest
    public static void testReactivationBatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_HttpCallouts_MockResponse_Deactivated());
        UCD_ACM_AcctDeactivtionReactivtion_Batch ucdDeactivatioReactivation = new UCD_ACM_AcctDeactivtionReactivtion_Batch();
        Database.executeBatch(ucdDeactivatioReactivation,1); 
        Test.StopTest();
        
    }
    @isTest
    public static void testcreateAccountStagingForCPEOfReActivatedAcc(){
        Test.startTest();
        List<Account> accountList = [SELECT Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c,Core_B2B_Entitlement__c,Core_Is_Opportunity_Account__c,Core_Sales_Groups__c FROM Account];
        accountList[0].Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accountList[0].Core_MDF_CoMarketingActive__c= true;
        accountList[0].Core_Is_Opportunity_Account__c= true;
        accountList[0].Core_B2B_Entitlement__c = true;
        accountList[0].Core_Sales_Groups__c= 'Global Solutions & Services Sales Group';
        UCD_ACM_AcctDeactivtionReactivtion_Batch.createAccountStagingForCPEOfReActivatedAcc(accountList);
        Test.StopTest();
        
    }

    public class Core_HttpCallouts_MockResponse_Reactivated implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"activated","crosswalks":["crosswalk1","crosswalk2"],"message":"Success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class Core_HttpCallouts_MockResponse_Deactivated implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"inactivated","crosswalks":["crosswalk1","crosswalk2"],"message":"Success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class Core_HttpCallouts_MockResponse_Retry implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"sucess","crosswalks":["crosswalk1","crosswalk2"],"message":"Success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}