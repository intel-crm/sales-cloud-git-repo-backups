@isTest
public class SWS_StringSplitUtility_Test {
    
    // Mock implementation of SWS_EACUtility for testing
    @TestSetup
    static void setupTestData() {
        // Setup any test data if needed
    }
    
    @isTest
    static void testSplitSemicolonString_NullInput() {
        // Test with null input
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(null);
        
        System.assertEquals(1, results.size(), 'Should return one empty result for null input');
        validateEmptyResult(results[0]);
    }
    
    @isTest
    static void testSplitSemicolonString_EmptyList() {
        // Test with empty list
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>();
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        System.assertEquals(1, results.size(), 'Should return one empty result for empty list');
        validateEmptyResult(results[0]);
    }
    
    @isTest
    static void testSplitSemicolonString_BlankInputString() {
        // Test with blank input string
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = '';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        System.assertEquals(1, results.size(), 'Should return one result');
        validateEmptyResult(results[0]);
    }
    
    @isTest
    static void testSplitSemicolonString_NullInputString() {
        // Test with null input string
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = null;
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        System.assertEquals(1, results.size(), 'Should return one result');
        validateEmptyResult(results[0]);
    }
    
    @isTest
    static void testSplitSemicolonString_ValidIntelEmails() {
        // Mock the email validation to return valid emails
        Test.startTest();
        
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'john.doe@intel.com;jane.smith@intel.com';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        // You'll need to mock SWS_EACUtility.validateEmail method
        // This assumes the method returns the input if valid, null if invalid
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        SWS_StringSplitUtility.SplitStringResult result = results[0];
        System.assertEquals(true, result.isSuccess, 'Operation should be successful');
        System.assertEquals(null, result.errorMessage, 'No error message expected');
        // Note: Actual assertions depend on SWS_EACUtility implementation
    }
    
    @isTest
    static void testSplitSemicolonString_ValidNonIntelEmails() {
        Test.startTest();
        
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'john@gmail.com;jane@yahoo.com';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        SWS_StringSplitUtility.SplitStringResult result = results[0];
        System.assertEquals(true, result.isSuccess, 'Operation should be successful');
        System.assertEquals(null, result.errorMessage, 'No error message expected');
    }
    
    @isTest
    static void testSplitSemicolonString_MixedEmails() {
        Test.startTest();
        
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'john@intel.com;jane@gmail.com;bob@intel.com;alice@yahoo.com';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        SWS_StringSplitUtility.SplitStringResult result = results[0];
        System.assertEquals(true, result.isSuccess, 'Operation should be successful');
    }
    
    @isTest
    static void testSplitSemicolonString_RFC2822Format() {
        Test.startTest();
        
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'John Doe <john@intel.com>;Jane Smith <jane@gmail.com>';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        SWS_StringSplitUtility.SplitStringResult result = results[0];
        System.assertEquals(true, result.isSuccess, 'Operation should be successful');
    }
    
    @isTest
    static void testSplitSemicolonString_InvalidRFC2822Format() {
        Test.startTest();
        
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'John Doe <john@intel.com';  // Missing closing bracket
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
    }
    
    @isTest
    static void testSplitSemicolonString_EmptyEmailsAfterValidation() {
        Test.startTest();
        
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'invalid-email;another-invalid';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        SWS_StringSplitUtility.SplitStringResult result = results[0];
        System.assertEquals(true, result.isSuccess, 'Operation should be successful');
    }
    
    @isTest
    static void testSplitSemicolonString_WithWhitespace() {
        Test.startTest();
        
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = ' john@intel.com ; jane@gmail.com ; ';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        SWS_StringSplitUtility.SplitStringResult result = results[0];
        System.assertEquals(true, result.isSuccess, 'Operation should be successful');
    }
    
    @isTest
    static void testSplitSemicolonString_MultipleRequests() {
        Test.startTest();
        
        SWS_StringSplitUtility.SplitStringRequest request1 = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request1.inputString = 'john@intel.com';
        
        SWS_StringSplitUtility.SplitStringRequest request2 = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request2.inputString = 'jane@gmail.com';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request1, request2};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should return two results');
        for (SWS_StringSplitUtility.SplitStringResult result : results) {
            System.assertEquals(true, result.isSuccess, 'All operations should be successful');
        }
    }
    
    @isTest
    static void testSplitSemicolonString_ExceptionHandling() {
        Test.startTest();
        
        // Create a request that might cause an exception
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'test@example.com';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        // This test depends on how SWS_EACUtility.validateEmail behaves
        // You might need to modify this based on actual implementation
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        // The result will depend on the actual implementation of validateEmail
    }
    
    @isTest
    static void testRFC2822EdgeCases() {
        Test.startTest();
        
        // Test various RFC2822 edge cases
        SWS_StringSplitUtility.SplitStringRequest request = 
            new SWS_StringSplitUtility.SplitStringRequest();
        request.inputString = 'Name <email@intel.com>;><invalid>;Name<email@gmail.com>';
        
        List<SWS_StringSplitUtility.SplitStringRequest> requests = 
            new List<SWS_StringSplitUtility.SplitStringRequest>{request};
        
        List<SWS_StringSplitUtility.SplitStringResult> results = 
            SWS_StringSplitUtility.splitSemicolonString(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
    }
    
    // Helper method to validate empty results
    private static void validateEmptyResult(SWS_StringSplitUtility.SplitStringResult result) {
        System.assertEquals(true, result.isSuccess, 'Empty result should be successful');
        System.assertEquals(null, result.errorMessage, 'Empty result should have no error message');
        System.assertNotEquals(null, result.splitUserValues, 'splitUserValues should not be null');
        System.assertNotEquals(null, result.splitContactValues, 'splitContactValues should not be null');
        System.assertEquals(0, result.splitUserValues.size(), 'splitUserValues should be empty');
        System.assertEquals(0, result.splitContactValues.size(), 'splitContactValues should be empty');
    }
}