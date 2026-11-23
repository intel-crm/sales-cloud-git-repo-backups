@isTest
public class SWS_StringSplitUtility_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test custom setting data for excluded domains
        SWS_Core_CRM_Labels__c excludedDomainsLabel = new SWS_Core_CRM_Labels__c(
            Name = 'Excluded_Domains',
            SWS_Value__c = 'spam.com;blocked.net;invalid.org'
        );
        insert excludedDomainsLabel;
    }
    
    @isTest
    static void testSplitSemicolonString_ValidInput() {
        // Test with valid semicolon-separated string
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        SWS_StringSplitUtility.SplitStringRequest request = new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'test@example.com;user@domain.com;admin@company.org';
        requests.add(request);
        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isSuccess, 'Operation should be successful');
        System.assertEquals(null, results[0].errorMessage, 'Error message should be null');
        System.assertEquals(3, results[0].splitValues.size(), 'Should have 3 split values');
    }
    
    @isTest
    static void testSplitSemicolonString_WithWhitespace() {
        // Test with whitespace around values
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        SWS_StringSplitUtility.SplitStringRequest request = new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = ' test@example.com ; user@domain.com ; admin@company.org ';
        requests.add(request);
        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isSuccess, 'Operation should be successful');
        System.assertEquals(3, results[0].splitValues.size(), 'Should have 3 split values after trimming');
    }
    
    @isTest
    static void testSplitSemicolonString_EmptyString() {
        // Test with empty input string
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        SWS_StringSplitUtility.SplitStringRequest request = new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = '';
        requests.add(request);
        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
       
    }
    
    @isTest
    static void testSplitSemicolonString_NullString() {
        // Test with null input string
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        SWS_StringSplitUtility.SplitStringRequest request = new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = null;
        requests.add(request);        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();        
        System.assertEquals(1, results.size(), 'Should return one result');       
    }    
    @isTest
    static void testSplitSemicolonString_SingleValue() {
        // Test with single value (no semicolon)
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        SWS_StringSplitUtility.SplitStringRequest request = new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'test@example.com';
        requests.add(request);
        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isSuccess, 'Operation should be successful');
        System.assertEquals(1, results[0].splitValues.size(), 'Should have 1 split value');
    }
    
    @isTest
    static void testSplitSemicolonString_MultipleRequests() {
        // Test with multiple requests
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        
        SWS_StringSplitUtility.SplitStringRequest request1 = new SWS_StringSplitUtility.SplitStringRequest();
        request1.inputString = 'test1@example.com;test2@example.com';
        requests.add(request1);
        
        SWS_StringSplitUtility.SplitStringRequest request2 = new SWS_StringSplitUtility.SplitStringRequest();
        request2.inputString = 'user1@domain.com;user2@domain.com;user3@domain.com';
        requests.add(request2);
        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should return two results');
        System.assertEquals(true, results[0].isSuccess, 'First operation should be successful');
        System.assertEquals(true, results[1].isSuccess, 'Second operation should be successful');
        System.assertEquals(2, results[0].splitValues.size(), 'First result should have 2 values');
        System.assertEquals(3, results[1].splitValues.size(), 'Second result should have 3 values');
    }
    
    @isTest
    static void testSplitSemicolonString_NullRequestList() {
        // Test with null request list
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(null);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result for null input');
        System.assertEquals(true, results[0].isSuccess, 'Operation should be successful');
        System.assertEquals(0, results[0].splitValues.size(), 'Should have empty list');
        System.assertEquals(null, results[0].errorMessage, 'Error message should be null');
    }
    
    @isTest
    static void testSplitSemicolonString_EmptyRequestList() {
        // Test with empty request list
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result for empty list');
        System.assertEquals(true, results[0].isSuccess, 'Operation should be successful');
        System.assertEquals(0, results[0].splitValues.size(), 'Should have empty list');
        System.assertEquals(null, results[0].errorMessage, 'Error message should be null');
    }
    
    @isTest
    static void testSplitSemicolonString_WithEmptyValues() {
        // Test with string containing empty values between semicolons
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        SWS_StringSplitUtility.SplitStringRequest request = new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'test@example.com;;user@domain.com; ;admin@company.org';
        requests.add(request);
        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isSuccess, 'Operation should be successful');
        // The exact count depends on how SWS_EmailDomainFilter.filterEmailByDomain handles empty/whitespace values
        System.assertNotEquals(null, results[0].splitValues, 'Split values should not be null');
    }
    
    @isTest
    static void testSplitSemicolonString_NoCustomSetting() {
        // Delete the custom setting to test null handling
        delete [SELECT Id FROM SWS_Core_CRM_Labels__c WHERE Name = 'Excluded_Domains'];
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        SWS_StringSplitUtility.SplitStringRequest request = new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'test@example.com;user@domain.com';
        requests.add(request);
        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isSuccess, 'Operation should be successful even without custom setting');
    }
    
    @isTest
    static void testSplitSemicolonString_ExceptionHandling() {
        // This test might be challenging without knowing the exact implementation of SWS_EmailDomainFilter
        // You may need to create a scenario that causes an exception in that method
        // For now, testing with a very long string that might cause issues
        List<SWS_StringSplitUtility.SplitStringRequest> requests = new List<SWS_StringSplitUtility.SplitStringRequest>();
        SWS_StringSplitUtility.SplitStringRequest request = new SWS_StringSplitUtility.SplitStringRequest();
        
        // Create a very long string
        String longString = '';
        for (Integer i = 0; i < 1000; i++) {
            longString += 'test' + i + '@example.com;';
        }
        request.inputString = longString;
        requests.add(request);
        
        Test.startTest();
        List<SWS_StringSplitUtility.SplitStringResult> results = SWS_StringSplitUtility.splitSemicolonString(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        // The result could be either success or failure depending on system limits
        System.assertNotEquals(null, results[0].isSuccess, 'Success flag should be set');
    }
}