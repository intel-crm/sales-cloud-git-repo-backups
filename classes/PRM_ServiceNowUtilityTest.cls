@isTest
private class PRM_ServiceNowUtilityTest {
    @isTest
    static void testCreateServiceNowCase() {
        // Create test data
        ServiceNow_Case__c snCase = new ServiceNow_Case__c(
            Title__c = 'Test Case',
            Urgency__c = 'High',
            Program__c = 'IPA',
            Description__c = 'Test Description'
        );
        insert snCase;

        // Call the method under test
        Test.startTest();
        PRM_ServiceNowUtility.createServiceNowCase(new List<ServiceNow_Case__c>{ snCase });
        Test.stopTest();

        // Assert the expected results
        // Add your assertions here
    }

    @isTest
    static void testITSMCallout() {
        // Create test data
        ServiceNow_Case__c snCase = new ServiceNow_Case__c(
            Title__c = 'Test Case',
            Urgency__c = 'High',
            Program__c = 'IPA',
            Description__c = 'Test Description'
        );
        insert snCase;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method under test
        Test.startTest();
        PRM_ServiceNowUtility.ITSMCallout('test body', new List<Id>{ snCase.Id });
        Test.stopTest();

        // Assert the expected results
        // Add your assertions here
    }

    @isTest
    static void testUpdateSNRecords() {
        // Create test data
        ServiceNow_Case__c snCase = new ServiceNow_Case__c(
            Title__c = 'Test Case',
            Urgency__c = 'High',
            Program__c = 'IPA',
            Description__c = 'Test Description'
        );
        insert snCase;


        // Call the method under test
        Test.startTest();
        PRM_ServiceNowUtility.updateSNRecords('INC001', new List<Id>{ snCase.Id });
        Test.stopTest();

        // Assert the expected results
        // Add your assertions here
    }


    @isTest
    static void testGetToken() {
        // Create test data
        PRM_Integration__mdt intreq = new PRM_Integration__mdt();
        intreq = [Select Id, API_Key__c,scope__c, EndPointURL__c, Password__c, Username__c from PRM_Integration__mdt where MasterLabel='ServiceNow' limit 1];  
        // Call the method under test
        Test.startTest();
        PRM_Token_Model token = PRM_ServiceNowUtility.getToken(intreq);
        Test.stopTest();

        // Assert the expected results
        // Add your assertions here
    }

    @isTest
    static void testConstructJSON() {
        // Create test data
        ServiceNow_Case__c snCase = new ServiceNow_Case__c(
            Title__c = 'Test Case',
            Urgency__c = 'High',
            Program__c = 'IPA',
            Description__c = 'Test Description'
        );
        insert snCase;


        // Call the method under test
        Test.startTest();
        String jsonBody = PRM_ServiceNowUtility.constructJSON(new List<ServiceNow_Case__c>{ snCase });
        Test.stopTest();

        // Assert the expected results
        // Add your assertions here
    }
    @isTest
    static void testcreateAttachment() { 
        ServiceNow_Case__c snCase = new ServiceNow_Case__c(
            Title__c = 'Test Case',
            Urgency__c = 'High',
            Program__c = 'IPA',
            Description__c = 'Test Description'
        );
        insert snCase;
        List<Id> lId = new List<Id>();
        lId.add(snCase.Id);
        
        String tt = 'iVBORw0KGgoAAAANSU';
        String base64File = EncodingUtil.urlDecode(tt, 'UTF-8'); 
        ContentVersion contentVersion = new ContentVersion();
               contentVersion.Title = 'test1.png';
               contentVersion.PathOnClient = 'test1.png';
              // contentVersion.FileType ='png';
               contentVersion.VersionData = EncodingUtil.base64Decode(base64File);
               contentVersion.FirstPublishLocationId =snCase.id ; // Set the appropriate parent record Id
               insert contentVersion;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        PRM_ServiceNowUtility.createAttachment('22ed7868dbff29500c396d8d139619c3',lId,'22ed7868dbff29500c396d8d139619c3dsfsfaff');
        Test.stopTest();

    }
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(201);
            response.setBody('{"result": {"number": "INC001", "sys_id": "sys123"}}');
            return response;
        }
    }
}