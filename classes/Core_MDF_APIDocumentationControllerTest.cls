/**
 * @description Test class for Core_MDF_APIDocumentationController
 */
@isTest
private class Core_MDF_APIDocumentationControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Initialize API Documentation custom settings
        Core_MDF_APIDocumentation_Initializer.initializeAPIDocumentation();
    }
    
    @isTest
    static void testGetAPIDocumentation() {
        Test.startTest();
        List<Core_MDF_APIDocumentationController.APIDocRecord> records = Core_MDF_APIDocumentationController.getAPIDocumentation();
        Test.stopTest();
        
        System.assertNotEquals(null, records, 'API records should not be null');
        System.assert(records.size() > 0, 'Should return at least one API record');
        System.assertNotEquals(null, records[0].apiName, 'API name should be populated');
        System.assertNotEquals(null, records[0].apiMethod, 'API method should be populated');
        System.assertEquals(true, records[0].isActive, 'Only active API records should be returned');
        System.assertEquals(true, records[0].isDefault, 'Default flag should be populated');
        System.assertNotEquals(null, records[0].eol, 'EOL should be populated');
    }
    
    @isTest
    static void testGetCommunityURL() {
        Test.startTest();
        String communityUrl = Core_MDF_APIDocumentationController.getCommunityURL();
        Test.stopTest();
        
        System.assertNotEquals(null, communityUrl, 'Community URL should not be null');
        System.assert(communityUrl.contains('Partnercenter'), 'URL should contain community name');
        System.assert(communityUrl.contains('API_Documentation'), 'URL should contain page path');
    }
    
    @isTest
    static void testAPIDocRecordWrapper() {
        Core_MDF_API_Documentation__c setting = new Core_MDF_API_Documentation__c(
            API_Name__c = 'Test API',
            Category__c = 'Test',
            Operation_Name__c = 'Test Operation',
            API_Method__c = 'POST',
            API_Endpoint__c = '/test/endpoint',
            Version__c = '1.0.0',
            Response_Status_Code__c = '200',
            Is_Active__c = true,
            Default__c = true,
            EOL__c = '2026-01-01 - 2026-12-31',
            Sort_Order__c = 1
        );
        
        Test.startTest();
        Core_MDF_APIDocumentationController.APIDocRecord record = new Core_MDF_APIDocumentationController.APIDocRecord(setting);
        Test.stopTest();
        
        System.assertEquals('Test API', record.apiName, 'API name should match');
        System.assertEquals('POST', record.apiMethod, 'API method should match');
        System.assertEquals('/test/endpoint', record.apiEndpoint, 'Endpoint should match');
        System.assertEquals(true, record.isActive, 'Is active should match');
        System.assertEquals(true, record.isDefault, 'Default should match');
        System.assertEquals('2026-01-01 - 2026-12-31', record.eol, 'EOL should match');
    }

    @isTest
    static void testInactiveRecordsAreExcluded() {
        insert new Core_MDF_API_Documentation__c(
            Name = 'Inactive_Test_API',
            API_Name__c = 'Inactive Test API',
            Operation_Name__c = 'Inactive Operation',
            API_Method__c = 'GET',
            Version__c = '1.0.0',
            Is_Active__c = false,
            Default__c = false,
            Sort_Order__c = 99
        );

        Test.startTest();
        List<Core_MDF_APIDocumentationController.APIDocRecord> records = Core_MDF_APIDocumentationController.getAPIDocumentation();
        Test.stopTest();

        for (Core_MDF_APIDocumentationController.APIDocRecord record : records) {
            System.assertNotEquals('Inactive Test API', record.apiName, 'Inactive API records should not be returned');
        }
    }
}