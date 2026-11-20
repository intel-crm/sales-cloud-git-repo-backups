@isTest
public class Core_GenerateAccountSummary_Test {
    @isTest
    static void testMakePostRequest() {
		String recordId = '001o000000O650VAAR';
		String userId = '10681329';
		String action = 'has_summary';
        String userWWID = '10681329';

        Core_CRM_Labels__c apiSwitchRecord = new Core_CRM_Labels__c();
        apiSwitchRecord.Name = 'Account_API_switch';
        apiSwitchRecord.Value__c = 'true';
        insert apiSwitchRecord;
        
        Core_System_Credentials__c EndpointURL = new Core_System_Credentials__c();
        EndpointURL.Name = 'GenerateAccountSummaryAPIEndpoint';
        EndpointURL.Core_End_Point_URL__c = 'https://ci-pulse-backend.ai4sales.com/v1/pulse';
        insert EndpointURL;
        
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Core_GenerateAccountSummary.getCustomSettingsUserWWID();
        Boolean showValue = Core_GenerateAccountSummary.makePostRequest(recordId, userId, action, userWWID);

        System.assertEquals(true, showValue, 'Expected showValue to be true');
        delete apiSwitchRecord;
        test.stoptest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"body":{"show":true}}');
            return res;
        }
    }
}