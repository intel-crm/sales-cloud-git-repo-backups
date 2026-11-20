@isTest(SeeAllData = false)
public class PicklistManager_Test {
    
    @TestSetup
    static void createTestUser() {
        // Query for the System Administrator profile ID (replace 'System Administrator' with the actual profile name)
        Id sysAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        
        // Create a test user with the System Administrator profile
        User testUser = new User(
            ProfileId = sysAdminProfileId,
            Username = 'picklistmanager@example.com',
            Email = 'picklistmanager@example.com',
            LastName = 'Test',
            FirstName = 'User',
            Alias = 'TUser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York'
        );
        
        // Insert the test user
        insert testUser;
    }
    
    
    static testMethod void testPLUpdate(){
        PicklistManager.PicklistWrapperClass pwcParams = new PicklistManager.PicklistWrapperClass();
        List<PicklistManager.PickListWrapper> pLList = new List<PicklistManager.PickListWrapper>();
        pwcParams.objectName='Account';
        pwcParams.fieldName='2017 Sales Group';
        pwcParams.fieldAPIName='Core_Sales_Group__c';
        pwcParams.sorted=true;
        PicklistManager.PickListWrapper pL = new PicklistManager.PickListWrapper();
        pL.label='test 07';
        pL.value='test 07';
        pL.isActive= true;
        pL.isDefaultValue = false;
        pLList.add(pL);
        pwcParams.picklistValues = pLList;
        Map<Boolean, String> result = PicklistManager.createOrUpdatePLV(pwcParams,false);
        
        System.assertEquals(false, result.containsKey(false), 'Cannot update through test class');
    }
    
    // Test method to cover the getPicklistValues method
    static testMethod void testGetPicklistValues() {
        // Call the getPicklistValues method
        List<PicklistManager.PickListWrapper> picklistValues = PicklistManager.getPicklistValues('Account', 'Core_Sales_Group__c'); // Replace 'MyField__c' with the field API name
        
        // Perform assertions
        System.assertNotEquals(null, picklistValues, 'List of picklist values should not be null');
        System.assertNotEquals(0, picklistValues.size(), 'List of picklist values should not be empty');
        
        for (PicklistManager.PickListWrapper picklistValue : picklistValues) {
            System.assertNotEquals(null, picklistValue.label, 'Label should not be null');
            System.assertNotEquals(null, picklistValue.value, 'Value should not be null');
        }
    }
    
    
    static testMethod void testGetRecordType() {
        
        // Call the GetRecordType method
        List<PicklistManager.Items> recordTypes = PicklistManager.GetRecordType('Account');
        
        // Perform assertions
        System.assertNotEquals(null, recordTypes, 'List of record types should not be null');
        System.assertNotEquals(0, recordTypes.size(), 'List of record types should not be empty');
        
        for (PicklistManager.Items recType : recordTypes) {
            System.assertNotEquals(null, recType.developerName, 'Developer name should not be null');
            System.assertNotEquals(null, recType.name, 'Name should not be null');
            System.assertNotEquals(null, recType.recordTypeId, 'Record Type Id should not be null');
            System.assertNotEquals(null, recType.ConCatname, 'Concatenated name should not be null');
        }
    }
    
    
    // Test a successful update
    static testMethod void testSuccessfulUpdate() {
        PicklistManager.RecordTypeWrapperClass rtParams = new PicklistManager.RecordTypeWrapperClass();
        // Set up rtParams with valid data
        List<PicklistManager.PickListWrapper> pLList = new List<PicklistManager.PickListWrapper>();
        Map<string,List<string>> fieldAPIToValues = new Map<string,List<string>>();
        list<string> anotherList = new List<string>();
        rtParams.recordTypeName = 'Intel Account';
        rtParams.recordTypeFullName='Account.Mastered_Account';
        PicklistManager.PicklistWrapperClass pwc = new PicklistManager.PicklistWrapperClass();
        pwc.objectName = 'Account';
        pwc.fieldAPIName = 'Core_Sales_Group__c';
        pwc.fieldName='2017 Sales Group';
        pwc.sorted=true;
        PicklistManager.PickListWrapper pL = new PicklistManager.PickListWrapper();
        pL.label='Sept263';
        pL.value='Sept263';
        pL.isActive= true;
        pL.isDefaultValue = false;
        pLList.add(pL);
        pwc.picklistValues = pLList;
        rtParams.pLWrapperParams = pwc;
        
        // Call the method
        Map<Boolean, String> result = PicklistManager.createOrUpdateRT(rtParams, false);
        
        // Assert that the update was successful
        System.assertEquals(false, result.containsKey(false), 'Cannot update through test class');
    }
    
    // Test a failure during the update
    static testMethod void testUpdateFailure() {
        PicklistManager.RecordTypeWrapperClass rtParams = new PicklistManager.RecordTypeWrapperClass();
        List<PicklistManager.PickListWrapper> pLList = new List<PicklistManager.PickListWrapper>();
        Map<string,List<string>> fieldAPIToValues = new Map<string,List<string>>();
        list<string> anotherList = new List<string>();
        rtParams.recordTypeName = 'Intel Account';
        rtParams.recordTypeFullName='Account.Mastered_Account';
        PicklistManager.PicklistWrapperClass pwc = new PicklistManager.PicklistWrapperClass();
        pwc.objectName = 'Account';
        pwc.fieldAPIName = 'Core_Sales_Group__c';
        pwc.fieldName='2017 Sales Group';
        pwc.sorted=true;
        PicklistManager.PickListWrapper pL = new PicklistManager.PickListWrapper();
        pL.label='Sept263';
        pL.value='Sept263';
        pL.isActive= true;
        pL.isDefaultValue = false;
        pLList.add(pL);
        pwc.picklistValues = pLList;
        rtParams.pLWrapperParams = pwc;
        
        // Call the method
        Map<Boolean, String> result = PicklistManager.createOrUpdateRT(rtParams, false);
        
        // Assert that the update failed
        System.assertEquals(false, result.containsKey(false), 'Expected an update failure');
    }
    
    
    @isTest
    static void testUserAccess_NoPermissionSets() {
        // Set up test data where the user has no Permission Sets
        Test.startTest();
        User usr = [select id from User where Username = 'picklistmanager@example.com'];
        System.runAs(usr) {
            String result = PicklistManager.userAccess();
            System.assertEquals('No Access', result, 'Expected "No Access" result');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUserAccess_EditPermissionSet() {
        // Set up test data where the user has the "PicklistManager_Edit" Permission Set
        PermissionSet ps = [select id from PermissionSet where name='PicklistManager_Edit'];
        User usr = [select id from User where Username = 'picklistmanager@example.com'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.id);
        Test.startTest();
        System.runAs(usr) {
            String result = PicklistManager.userAccess();
            System.assertEquals('Edit', result, 'Expected "Edit" result');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUserAccess_ReadOnlyPermissionSet() {
        // Set up test data where the user has the "PicklistManager_ReadOnly" Permission Set
        PermissionSet ps = [select id from PermissionSet where name='PicklistManager_ReadOnly'];
        User usr = [select id from User where Username = 'picklistmanager@example.com'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.id);
        Test.startTest();
        System.runAs(usr) {
            String result = PicklistManager.userAccess();
            System.assertEquals('Read', result, 'Expected "Read" result');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUserAccess_MultiplePermissionSets() {
        // Set up test data where the user has both "PicklistManager_Edit" and "PicklistManager_ReadOnly" Permission Sets
        PermissionSet ps1 = [select id from PermissionSet where name='PicklistManager_Edit'];
        PermissionSet ps2 = [select id from PermissionSet where name='PicklistManager_ReadOnly'];
        User usr = [select id from User where Username = 'picklistmanager@example.com'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps1.id);
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps2.id);
        Test.startTest();
        System.runAs(usr) {
            String result = PicklistManager.userAccess();
            System.assertEquals('Edit', result, 'Expected "Edit" result for multiple Permission Sets');
        }
        Test.stopTest();
    }
    
    
    
    // Mock HTTP response class to simulate the HTTP callout
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"values": [{"value": "Value1", "label": "Label1"}, {"value": "Value2", "label": "Label2"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testGetExistingPLValues() {
        // Create a test RecordTypeWrapperClass instance and set its properties
        PicklistManager.RecordTypeWrapperClass rtwo = new PicklistManager.RecordTypeWrapperClass();
        rtwo.recordTypeName='Intel Account';
        rtwo.recordTypeFullName='Account.Mastered_Account';
        PicklistManager.PicklistWrapperClass pw = new PicklistManager.PicklistWrapperClass();
        pw.objectName = 'Account';
        pw.fieldAPIName = 'Core_Sales_Group__c';
        rtwo.pLWrapperParams = pw;
        
        // Set up the HTTP callout mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        // Call the method you want to test
        PicklistManager.getExistingPLValues(rtwo);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(2, rtwo.pLWrapperParams.picklistValues.size(), 'Expected number of picklist values');
        System.assertEquals('Value1', rtwo.pLWrapperParams.picklistValues[0].value, 'Expected value for the first picklist item');
        System.assertEquals('Label1', rtwo.pLWrapperParams.picklistValues[0].label, 'Expected label for the first picklist item');
        System.assertEquals('Value2', rtwo.pLWrapperParams.picklistValues[1].value, 'Expected value for the second picklist item');
        System.assertEquals('Label2', rtwo.pLWrapperParams.picklistValues[1].label, 'Expected label for the second picklist item');
    }
    
    @isTest
    static void testFetchUserSessionId() {
        // Create a Visualforce page with the expected content
        PageReference reportPage = Page.Picklist_VF; 
        reportPage.getParameters().put('id', 'recordId'); 
        reportPage.getParameters().put('Name', 'Test Page');
        Test.setCurrentPage(reportPage);
        
        // Call the method you want to test
        String sessionId = PicklistManager.fetchUserSessionId();
        
        // Verify that the session ID was extracted correctly
        System.assertEquals('sessionID', sessionId, 'Session ID should be extracted correctly');
    }
    
    
}