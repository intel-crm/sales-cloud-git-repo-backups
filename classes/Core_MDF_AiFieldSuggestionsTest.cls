@isTest
public class Core_MDF_AiFieldSuggestionsTest {
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // TEST DATA SETUP
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @TestSetup
    static void setupTestData() {
        // Create AI Config metadata
        Core_MDF_CCP_Custom_Metadata_Utility__c aiConfig = new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'AI_PROMPT_CONFIG',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_2_txt__c = 'You are an AI assistant for Intel MDF campaign analysis.',
            Core_MDF_Field_3_txt__c = '1000',
            Core_MDF_Field_4_txt__c = '0.7',
            Core_MDF_Field_5_txt__c = 'https://api.openai.com/v1/chat/completions',
            Core_MDF_Field_6_txt__c = '30000'
        );
        insert aiConfig; 
        
        // Create prompt metadata records
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> promptMetadata = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        
        // AI_PROMPT_INTRO
        promptMetadata.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'AI_PROMPT_INTRO',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_1_txt__c = 'SMART AI ANALYSIS',
            Core_MDF_Field_2_txt__c = 'Intel MDF Campaign',
            Core_MDF_Field_3_txt__c = 'Field Extraction'
        ));
        
        // AI_PROMPT_JSON_STRUCTURE
        promptMetadata.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'AI_PROMPT_JSON_STRUCTURE',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_1_txt__c = 'Expected JSON Response Format:',
            Core_MDF_Field_2_txt__c = 'campaignName,startDate,endDate,focusArea,priority',
            Core_MDF_Field_3_txt__c = 'country,targetAudience,brands,technologies,initiatives'
        ));
        
        // AI_PROMPT_RULES
        promptMetadata.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'AI_PROMPT_RULES',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_1_txt__c = 'Only use exact picklist values provided',
            Core_MDF_Field_2_txt__c = 'Return null for fields with no clear match',
            Core_MDF_Field_3_txt__c = 'Analyze content thoroughly',
            Core_MDF_Field_4_txt__c = 'Provide confidence scores'
        ));
        
        // AI_PROMPT_FIELD_SPECIFIC
        promptMetadata.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'AI_PROMPT_FIELD_SPECIFIC',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_1_txt__c = 'Extract campaign name from title or header',
            Core_MDF_Field_2_txt__c = 'Look for start date in YYYY-MM-DD format',
            Core_MDF_Field_3_txt__c = 'Look for end date in YYYY-MM-DD format',
            Core_MDF_Field_4_txt__c = 'Identify focus area from content context',
            Core_MDF_Field_5_txt__c = 'Determine priority level from content'
        ));
        
        // AI_PROMPT_PICKLIST_RULES
        promptMetadata.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'AI_PROMPT_PICKLIST_RULES',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_1_txt__c = 'PICKLIST MATCHING RULES',
            Core_MDF_Field_2_txt__c = 'Follow these rules for matching picklist values',
            Core_MDF_Field_3_txt__c = 'Exact Match Priority',
            Core_MDF_Field_4_txt__c = 'Look for exact string matches first',
            Core_MDF_Field_5_txt__c = 'Case insensitive matching allowed',
            Core_MDF_Field_6_txt__c = 'Partial matches acceptable if clear',
            Core_MDF_Field_7_txt__c = 'Use null if no clear match found'
        ));
        
        // AI_PROMPT_VERIFICATION
        promptMetadata.add(new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = 'AI_PROMPT_VERIFICATION',
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_1_txt__c = 'FINAL VERIFICATION',
            Core_MDF_Field_2_txt__c = 'Verify all extracted values',
            Core_MDF_Field_3_txt__c = 'Check picklist value accuracy',
            Core_MDF_Field_4_txt__c = 'Ensure date format compliance',
            Core_MDF_Field_5_txt__c = 'Validate confidence scores',
            Core_MDF_Field_6_txt__c = 'Return valid JSON format'
        ));
        
        insert promptMetadata;
        
        // Create test files in @TestSetup
        List<ContentVersion> testFiles = new List<ContentVersion>();
        
        // Basic test file
        testFiles.add(new ContentVersion(
            Title = 'Test Campaign Document',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('Test campaign content for AI analysis'),
            IsMajorVersion = true
        ));
        
        // Client Computing file
        testFiles.add(new ContentVersion(
            Title = 'Client Computing Campaign',
            PathOnClient = 'client_campaign.txt',
            VersionData = Blob.valueOf('This campaign focuses on AI PC and laptop solutions for enterprise clients'),
            IsMajorVersion = true
        ));
        
        // Data Center file
        testFiles.add(new ContentVersion(
            Title = 'Data Center Infrastructure',
            PathOnClient = 'datacenter.txt',
            VersionData = Blob.valueOf('This campaign targets enterprise server and Xeon processor solutions for data center infrastructure'),
            IsMajorVersion = true
        ));
        
        // Networking file
        testFiles.add(new ContentVersion(
            Title = 'Networking Campaign',
            PathOnClient = 'networking.txt',
            VersionData = Blob.valueOf('5g networking solutions for telecommunications and wireless connectivity'),
            IsMajorVersion = true
        ));
        
        // Edge file
        testFiles.add(new ContentVersion(
            Title = 'Edge Computing Campaign',
            PathOnClient = 'edge.txt',
            VersionData = Blob.valueOf('Edge computing and IoT solutions for industrial applications'),
            IsMajorVersion = true
        ));
        
        // Generic file (no specific keywords)
        testFiles.add(new ContentVersion(
            Title = 'Generic Campaign',
            PathOnClient = 'generic.txt',
            VersionData = Blob.valueOf('Generic campaign without specific technology keywords'),
            IsMajorVersion = true
        ));
        
        // CSV file
        testFiles.add(new ContentVersion(
            Title = 'Test CSV File',
            PathOnClient = 'test.csv',
            VersionData = Blob.valueOf('Campaign,Priority,Focus\nTest Campaign,High,Client Computing'),
            IsMajorVersion = true
        ));
        
        // Large file
        String largeContent = '';
        for (Integer i = 0; i < 200; i++) {
            largeContent += 'This is a test line for large file content processing. ';
        }
        testFiles.add(new ContentVersion(
            Title = 'Large Test File',
            PathOnClient = 'large.txt',
            VersionData = Blob.valueOf(largeContent),
            IsMajorVersion = true
        ));
        
        insert testFiles;
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // MOCK HTTP CALLOUT CLASS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // HELPER METHODS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    private static ContentVersion getTestFile(String title) {
        return [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Title = :title LIMIT 1];
    }
    
    private static List<ContentVersion> getTestFiles(List<String> titles) {
        return [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Title IN :titles];
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // TEST METHODS FOR DESCRIPTION ANALYSIS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testAnalyzeDescriptionWithAI_Success() {
        // Setup
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Test Campaign\\", \\"priority\\": \\"High\\", \\"focusArea\\": \\"Client Computing\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Map<String, Object> picklistValues = new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'},
            'focusArea' => new List<String>{'Client Computing', 'Data Center', 'Edge'}
        };
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'This is a high priority client computing campaign', 
            'TestRecordType', 
            picklistValues
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertNotEquals(null, result.get('data'), 'Should return data');
    }
    
    @isTest
    static void testAnalyzeDescriptionWithAI_BlankDescription() {
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            '', 
            'TestRecordType', 
            new Map<String, Object>()
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should return failure for blank description');
        System.assertEquals('Description is required', result.get('error'), 'Should return appropriate error message');
    }
    
    @isTest
    static void testAnalyzeDescriptionWithAI_HttpError() {
        // Setup
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        
        Map<String, Object> picklistValues = new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'}
        };
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test description', 
            'TestRecordType', 
            picklistValues
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should return failure for HTTP error');
        System.assert(((String)result.get('error')).contains('AI service returned status'), 'Should contain HTTP error message');
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // TEST METHODS FOR FILE ANALYSIS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testAnalyzeFileWithAI_Success() {
        // Setup
        ContentVersion cv = getTestFile('Test Campaign Document');
        List<String> contentDocumentIds = new List<String>{cv.ContentDocumentId};
        
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"File Campaign\\", \\"priority\\": \\"Medium\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Map<String, Object> picklistValues = new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'}
        };
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            contentDocumentIds, 
            'TestRecordType', 
            picklistValues
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertNotEquals(null, result.get('data'), 'Should return data');
        System.assertNotEquals(null, result.get('filesAnalyzed'), 'Should return analyzed files');
    }
    
    @isTest
    static void testAnalyzeFileWithAI_NoFiles() {
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            null, 
            'TestRecordType', 
            new Map<String, Object>()
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should return failure for no files');
        System.assertEquals('No files provided', result.get('error'), 'Should return appropriate error message');
    }
    
    @isTest
    static void testAnalyzeFileWithAI_EmptyFileList() {
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            new List<String>(), 
            'TestRecordType', 
            new Map<String, Object>()
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should return failure for empty file list');
        System.assertEquals('No files provided', result.get('error'), 'Should return appropriate error message');
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // TEST METHODS FOR COMBINED ANALYSIS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testAnalyzeCombinedContent_DescriptionAndFiles() {
        // Setup
        ContentVersion cv = getTestFile('Test Campaign Document');
        List<String> contentDocumentIds = new List<String>{cv.ContentDocumentId};
        
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Combined Campaign\\", \\"priority\\": \\"High\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Map<String, Object> picklistValues = new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'}
        };
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeCombinedContent(
            'Test description for combined analysis', 
            contentDocumentIds, 
            'TestRecordType', 
            picklistValues
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals('combined', result.get('analysisType'), 'Should indicate combined analysis');
        System.assertNotEquals(null, result.get('data'), 'Should return data');
    }
    
    @isTest
    static void testAnalyzeCombinedContent_DescriptionOnly() {
        // Setup
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Description Campaign\\", \\"priority\\": \\"Low\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Map<String, Object> picklistValues = new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'}
        };
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeCombinedContent(
            'Test description only', 
            null, 
            'TestRecordType', 
            picklistValues
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals('description', result.get('analysisType'), 'Should indicate description analysis');
    }
    
    @isTest
    static void testAnalyzeCombinedContent_FilesOnly() {
        // Setup
        ContentVersion cv = getTestFile('Test Campaign Document');
        List<String> contentDocumentIds = new List<String>{cv.ContentDocumentId};
        
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"File Only Campaign\\", \\"priority\\": \\"Medium\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Map<String, Object> picklistValues = new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'}
        };
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeCombinedContent(
            '', 
            contentDocumentIds, 
            'TestRecordType', 
            picklistValues
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals('files', result.get('analysisType'), 'Should indicate files analysis');
    }
    
    @isTest
    static void testAnalyzeCombinedContent_NoContent() {
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeCombinedContent(
            '', 
            null, 
            'TestRecordType', 
            new Map<String, Object>()
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should return failure for no content');
        System.assertEquals('Either description or files are required', result.get('error'), 'Should return appropriate error message');
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // TEST METHODS FOR FOCUS AREA DETECTION
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testDetectFocusAreaFromFile_ClientComputing() {
        // Setup
        ContentVersion cv = getTestFile('Client Computing Campaign');
        List<String> contentDocumentIds = new List<String>{cv.ContentDocumentId};
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(contentDocumentIds);
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals('Client Computing', result.get('focusArea'), 'Should detect Client Computing focus area');
        System.assertNotEquals(null, result.get('content'), 'Should return content preview');
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_DataCenter() {
        // Setup
        ContentVersion cv = getTestFile('Data Center Infrastructure');
        List<String> contentDocumentIds = new List<String>{cv.ContentDocumentId};
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(contentDocumentIds);
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals('Data Center', result.get('focusArea'), 'Should detect Data Center focus area');
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_Networking() {
        // Setup
        ContentVersion cv = getTestFile('Networking Campaign');
        List<String> contentDocumentIds = new List<String>{cv.ContentDocumentId};
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(contentDocumentIds);
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals('Networking & Telco', result.get('focusArea'), 'Should detect Networking & Telco focus area');
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_Edge() {
        // Setup
        ContentVersion cv = getTestFile('Edge Computing Campaign');
        List<String> contentDocumentIds = new List<String>{cv.ContentDocumentId};
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(contentDocumentIds);
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals('Edge', result.get('focusArea'), 'Should detect Edge focus area');
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_DefaultFocusArea() {
        // Setup
        ContentVersion cv = getTestFile('Generic Campaign');
        List<String> contentDocumentIds = new List<String>{cv.ContentDocumentId};
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(contentDocumentIds);
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals('Client Computing', result.get('focusArea'), 'Should return default Client Computing focus area');
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_NoFiles() {
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(null);
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should return failure for no files');
        System.assertEquals('No files provided', result.get('error'), 'Should return appropriate error message');
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_InvalidFileId() {
        // Test with non-existent file ID
        List<String> contentDocumentIds = new List<String>{'invalid_id'};
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(contentDocumentIds);
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should return failure for invalid file ID');
        System.assertEquals('Could not retrieve file content', result.get('error'), 'Should return appropriate error message');
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // TEST METHODS FOR FILE PROCESSING
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testFileExtraction_MultipleFiles() {
        // Setup - Get multiple test files
        List<ContentVersion> testFiles = getTestFiles(new List<String>{'Test Campaign Document', 'Test CSV File'});
        List<String> contentDocumentIds = new List<String>();
        for (ContentVersion cv : testFiles) {
            contentDocumentIds.add(cv.ContentDocumentId);
        }
        
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Test\\", \\"priority\\": \\"High\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            contentDocumentIds, 
            'TestRecordType', 
            new Map<String, Object>{'priority' => new List<String>{'High', 'Medium', 'Low'}}
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result.get('success'), 'Should successfully process multiple files');
        List<String> filesAnalyzed = (List<String>)result.get('filesAnalyzed');
        System.assertEquals(2, filesAnalyzed.size(), 'Should process both files');
    }
    
    @isTest
    static void testLargeFileHandling() {
        // Setup
        ContentVersion largeFile = getTestFile('Large Test File');
        
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Large File Campaign\\", \\"priority\\": \\"High\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            new List<String>{largeFile.ContentDocumentId}, 
            'TestRecordType', 
            new Map<String, Object>{'priority' => new List<String>{'High', 'Medium', 'Low'}}
        );
        Test.stopTest();
        
        // Verify that large files are handled (content should be truncated)
        System.assertEquals(true, result.get('success'), 'Should handle large files successfully');
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // TEST METHODS FOR ERROR HANDLING
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testAICallout_InvalidJSON() {
        // Setup - Mock response with invalid JSON
        String mockResponse = '{"choices": [{"message": {"content": "Invalid JSON content without proper structure"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Map<String, Object> picklistValues = new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'}
        };
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test description', 
            'TestRecordType', 
            picklistValues
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should handle invalid JSON response');
        System.assert(((String)result.get('error')).contains('Invalid JSON format'), 'Should return JSON format error');
    }
    
    @isTest
    static void testAICallout_EmptyResponse() {
        // Setup - Mock empty response
        String mockResponse = '{"choices": []}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Map<String, Object> picklistValues = new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'}
        };
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test description', 
            'TestRecordType', 
            picklistValues
        );
        Test.stopTest();
        
        // Verify - Should handle empty choices array gracefully
        System.assertNotEquals(null, result, 'Should return a result object');
    }
    
    @isTest
    static void testException_Handling() {
        // Test exception handling by not setting up required metadata
     delete [SELECT Id FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Category__c = 'AI_PROMPT_CONFIG'];
          
        Map<String, Object> picklistValues = new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'}
        };
        
        // Test
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test description', 
            'TestRecordType', 
            null
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should handle exceptions gracefully');
        System.assert(((String)result.get('error')).contains('An error occurred during AI analysis'), 'Should return appropriate error message');
    }
    
    @isTest
    static void testFileNotFound_Handling() {
        // Test with ContentDocumentId that exists but has no ContentVersion
        // This simulates a file that was deleted or corrupted
        List<String> invalidIds = new List<String>{'068000000000000'};
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            invalidIds, 
            'TestRecordType', 
            new Map<String, Object>{'priority' => new List<String>{'High', 'Medium', 'Low'}}
        );
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result.get('success'), 'Should handle file not found gracefully');
        System.assertEquals('Could not retrieve file content from Salesforce', result.get('error'), 'Should return appropriate error message');
    }
}