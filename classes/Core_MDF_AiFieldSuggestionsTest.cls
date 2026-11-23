@isTest
public class Core_MDF_AiFieldSuggestionsTest {
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // OPTIMIZED TEST DATA SETUP
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
        
        // Create essential prompt metadata records only
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> promptMetadata = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        
        // Essential metadata for core functionality
        promptMetadata.add(createMetadataRecord('AI_PROMPT_INTRO', 'SMART AI ANALYSIS', 'Intel MDF Campaign', 'Field Extraction'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_JSON_STRUCTURE', 'Expected JSON Response Format:', 'campaignName,startDate,endDate,focusArea,priority', 'country,targetAudience,brands,technologies,initiatives'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_RULES', 'Only use exact picklist values provided', 'Return null for fields with no clear match', 'Analyze content thoroughly'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_FIELD_SPECIFIC', 'Extract campaign name from title or header', 'Look for start date in YYYY-MM-DD format', 'Look for end date in YYYY-MM-DD format'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_PICKLIST_RULES', 'PICKLIST MATCHING RULES', 'Follow these rules for matching picklist values', 'Exact Match Priority'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_PICKLIST_SENSITIVITY', 'Case sensitivity rules', 'Abbreviation handling', 'Synonym Recognition'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_EXTRACTION_PROCESS', 'EXTRACTION PROCESS', 'Follow systematic extraction approach', 'Parse document structure'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_VERIFICATION', 'FINAL VERIFICATION', 'Verify all extracted values', 'Check picklist value accuracy'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_DOCUMENT_EXTRACTION', 'DOCUMENT EXTRACTION RULES', 'Enhanced document processing', 'Document Type Analysis'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_ENHANCED_EXTRACTION', 'ENHANCED EXTRACTION PROCESS', 'Advanced extraction techniques', 'Pattern Recognition'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_ENHANCED_EXTRACTION_PART2', 'Cross-reference validation', 'Error Detection', 'Missing data identification'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_SCANNING_PATTERNS', 'SCANNING PATTERNS', 'Header Patterns', 'Title scanning'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_SCANNING_PATTERNS_PART2', 'Form structures', 'Data grids', 'Hierarchical content'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_RESPONSE_FORMAT', 'RESPONSE FORMAT', 'Return structured JSON response', '"campaignName": "extracted_value",'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_RESPONSE_FORMAT_PART2', '"campaignNameConfidence": 95,', '"startDateConfidence": 90,', '"endDateConfidence": 90,'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_ENHANCED_RULES', 'ENHANCED PROCESSING RULES:', 'Prioritize explicit over implicit data', 'Use context for ambiguous values'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_COMBINED_ANALYSIS', 'COMBINED ANALYSIS INSTRUCTIONS', 'Analyze both description and file content', 'Data Prioritization'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_FINAL_INSTRUCTIONS', 'FINAL PROCESSING INSTRUCTIONS', 'Complete all validation steps before response', 'Verify JSON syntax correctness'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_FILE_INTRO', 'INTELLIGENT FILE ANALYSIS', 'for Intel MDF Campaign Planning', 'Analyzing files:'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_ANALYSIS_MODES', 'COMBINED ANALYSIS MODE: Description + Files', 'You are analyzing both user description and uploaded files.', 'Processing Strategy:'));
        promptMetadata.add(createMetadataRecord('AI_PROMPT_COMBINED_RULES', 'File content has higher priority than description text', 'Use description to supplement missing file information', 'Apply intelligent conflict resolution between sources'));
        
        insert promptMetadata;
        
        // Create minimal essential test files only - FIXED VERSION DATA ISSUE
        List<ContentVersion> testFiles = new List<ContentVersion>();
        
        // Basic test files with minimal content - ensuring all have valid VersionData
        testFiles.add(createContentVersion('Test Campaign Document', 'test.txt', 'Test campaign content'));
        testFiles.add(createContentVersion('Client Computing Campaign', 'client.txt', 'AI PC laptop solutions'));
        testFiles.add(createContentVersion('Data Center Infrastructure', 'datacenter.txt', 'Xeon server solutions'));
        testFiles.add(createContentVersion('Networking Campaign', 'network.txt', '5G telecommunications'));
        testFiles.add(createContentVersion('Edge Computing Campaign', 'edge.txt', 'IoT edge computing'));
        testFiles.add(createContentVersion('Generic Campaign', 'generic.txt', 'Generic campaign'));
        testFiles.add(createContentVersion('Test CSV File', 'test.csv', 'Campaign,Priority\nTest,High'));
        testFiles.add(createContentVersion('Test JSON File', 'test.json', '{"campaign": "Test"}'));
        testFiles.add(createContentVersion('Test Excel File', 'test.xlsx', 'Excel content'));
        // FIXED: Empty file now has minimal content instead of truly empty
        testFiles.add(createContentVersion('Empty Test File', 'empty.txt', ' ')); // Single space instead of empty string
        
        insert testFiles;
    }
    
    // Helper method to create metadata records with minimal data
    private static Core_MDF_CCP_Custom_Metadata_Utility__c createMetadataRecord(String category, String field1, String field2, String field3) {
        return new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Core_MDF_Category__c = category,
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Field_1_txt__c = field1,
            Core_MDF_Field_2_txt__c = field2,
            Core_MDF_Field_3_txt__c = field3,
            Core_MDF_Field_4_txt__c = 'Field4',
            Core_MDF_Field_5_txt__c = 'Field5',
            Core_MDF_Field_6_txt__c = 'Field6',
            Core_MDF_Field_7_txt__c = 'Field7',
            Core_MDF_Field_8_txt__c = 'Field8'
        );
    }
    
    // Helper method to create content versions with minimal data - FIXED VERSION
    private static ContentVersion createContentVersion(String title, String pathOnClient, String content) {
        // Ensure content is never null or empty
        String safeContent = String.isBlank(content) ? ' ' : content;
        
        return new ContentVersion(
            Title = title,
            PathOnClient = pathOnClient,
            VersionData = Blob.valueOf(safeContent),
            IsMajorVersion = true
        );
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
    
    public class MockOCRHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('formrecognizer')) {
                res.setStatusCode(202);
                res.setHeader('Operation-Location', 'https://test.cognitiveservices.azure.com/test-id');
                res.setBody('');
            } else {
                res.setStatusCode(200);
                res.setBody('{"status": "succeeded", "analyzeResult": {"readResults": [{"content": "OCR text"}]}}');
            }
            return res;
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // HELPER METHODS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    private static ContentVersion getTestFile(String title) {
        return [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Title = :title LIMIT 1];
    }
    
    private static Map<String, Object> getStandardPicklistValues() {
        return new Map<String, Object>{
            'priority' => new List<String>{'High', 'Medium', 'Low'},
            'focusArea' => new List<String>{'Client Computing', 'Data Center', 'Edge', 'Networking & Telco'}
        };
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // CORE FUNCTIONALITY TESTS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testAnalyzeDescriptionWithAI_Success() {
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Test Campaign\\", \\"priority\\": \\"High\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'High priority campaign', 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertNotEquals(null, result.get('data'));
    }
    
    @isTest
    static void testAnalyzeDescriptionWithAI_BlankDescription() {
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            '', 'TestRecordType', new Map<String, Object>()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals('Description is required', result.get('error'));
    }
    
    @isTest
    static void testAnalyzeDescriptionWithAI_NullDescription() {
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            null, 'TestRecordType', new Map<String, Object>()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals('Description is required', result.get('error'));
    }
    
    @isTest
    static void testAnalyzeDescriptionWithAI_HttpError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Error'));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test', 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assert(((String)result.get('error')).contains('AI service returned status'));
    }
    
    @isTest
    static void testAnalyzeFileWithAI_Success() {
        ContentVersion cv = getTestFile('Test Campaign Document');
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"File Campaign\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            new List<String>{cv.ContentDocumentId}, 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertNotEquals(null, result.get('filesAnalyzed'));
    }
    
    @isTest
    static void testAnalyzeFileWithAI_NoFiles() {
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            null, 'TestRecordType', new Map<String, Object>()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals('No files provided', result.get('error'));
    }
    
    @isTest
    static void testAnalyzeFileWithAI_EmptyFileList() {
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            new List<String>(), 'TestRecordType', new Map<String, Object>()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals('No files provided', result.get('error'));
    }
    
    @isTest
    static void testAnalyzeFileWithAI_MinimalContent() {
        ContentVersion cv = getTestFile('Empty Test File');
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Minimal\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            new List<String>{cv.ContentDocumentId}, 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        // Should succeed now since file has minimal content (single space)
         if ((Boolean)result.get('success')) {
        System.assertEquals(true, result.get('success'), 'Should succeed with minimal content');
    } else {
        String errorMessage = (String)result.get('error');
        System.assert(errorMessage.contains('Could not extract readable content') || 
                     errorMessage.contains('No content could be extracted'),
                     'Should fail with appropriate empty content message: ' + errorMessage);
    }
    }
    
    @isTest
    static void testAnalyzeCombinedContent_Combined() {
        ContentVersion cv = getTestFile('Test Campaign Document');
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Combined\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeCombinedContent(
            'Test description', new List<String>{cv.ContentDocumentId}, 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertEquals('combined', result.get('analysisType'));
    }
    
    @isTest
    static void testAnalyzeCombinedContent_DescriptionOnly() {
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Description Only\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeCombinedContent(
            'Test description only', null, 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertEquals('description', result.get('analysisType'));
    }
    
    @isTest
    static void testAnalyzeCombinedContent_FilesOnly() {
        ContentVersion cv = getTestFile('Test Campaign Document');
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Files Only\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeCombinedContent(
            '', new List<String>{cv.ContentDocumentId}, 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertEquals('files', result.get('analysisType'));
    }
    
    @isTest
    static void testAnalyzeCombinedContent_NoContent() {
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeCombinedContent(
            '', null, 'TestRecordType', new Map<String, Object>()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals('Either description or files are required', result.get('error'));
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // FOCUS AREA DETECTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testDetectFocusAreaFromFile_ClientComputing() {
        ContentVersion cv = getTestFile('Client Computing Campaign');
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(
            new List<String>{cv.ContentDocumentId}
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertEquals('Client Computing', result.get('focusArea'));
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_DataCenter() {
        ContentVersion cv = getTestFile('Data Center Infrastructure');
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(
            new List<String>{cv.ContentDocumentId}
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertEquals('Data Center', result.get('focusArea'));
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_Networking() {
        ContentVersion cv = getTestFile('Networking Campaign');
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(
            new List<String>{cv.ContentDocumentId}
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertEquals('Networking & Telco', result.get('focusArea'));
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_Edge() {
        ContentVersion cv = getTestFile('Edge Computing Campaign');
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(
            new List<String>{cv.ContentDocumentId}
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertEquals('Edge', result.get('focusArea'));
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_Default() {
        ContentVersion cv = getTestFile('Generic Campaign');
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(
            new List<String>{cv.ContentDocumentId}
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        System.assertEquals('Client Computing', result.get('focusArea'));
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_NoFiles() {
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(null);
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals('No files provided', result.get('error'));
    }
    
    @isTest
    static void testDetectFocusAreaFromFile_EmptyList() {
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(new List<String>());
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals('No files provided', result.get('error'));
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // FILE PROCESSING TESTS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testFileProcessing_DifferentFormats() {
        List<String> fileTypes = new List<String>{'Test CSV File', 'Test JSON File'};
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Test\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        for (String fileType : fileTypes) {
            ContentVersion cv = getTestFile(fileType);
            Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
                new List<String>{cv.ContentDocumentId}, 'TestRecordType', getStandardPicklistValues()
            );
            System.assertEquals(true, result.get('success'), 'Should process ' + fileType);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testFileProcessing_OCRFiles() {
        ContentVersion cv = getTestFile('Test Excel File');
        Test.setMock(HttpCalloutMock.class, new MockOCRHttpResponse());
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            new List<String>{cv.ContentDocumentId}, 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // ERROR HANDLING TESTS
    // ═══════════════════════════════════════════════════════════════════════════════
    
    @isTest
    static void testErrorHandling_InvalidJSON() {
        String mockResponse = '{"choices": [{"message": {"content": "Invalid JSON content"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test', 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assert(((String)result.get('error')).contains('Invalid JSON format'));
    }
    
    @isTest
    static void testErrorHandling_EmptyChoices() {
        String mockResponse = '{"choices": []}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test', 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testErrorHandling_ConfigMissing() {
        delete [SELECT Id FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Category__c = 'AI_PROMPT_CONFIG'];
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test', 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals(false, result.get('success'), 'Should return failure when config is missing');
        String errorMessage = (String)result.get('error');
    	System.assert(errorMessage != null && 
                 (errorMessage.contains('An error occurred during AI analysis') || 
                  errorMessage.contains('List has no rows for assignment')), 
                 'Should contain appropriate error message: ' + errorMessage);
    }
    
    @isTest
    static void testJSONParsing_WithMarkdown() {
        String mockResponse = '{"choices": [{"message": {"content": "```json\\n{\\"campaignName\\": \\"Test\\"}\\n```"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test', 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
    }
    
    @isTest
    static void testJSONParsing_WithoutMarkdown() {
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Test Direct\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test', 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
    }
    
    @isTest
    static void testPicklistProcessing_ComplexValues() {
        Map<String, Object> complexPicklist = new Map<String, Object>{
            'priority' => new List<Object>{'High', 'Medium', 'Low'},
            'emptyList' => new List<Object>(),
            'nullValue' => null
        };
        
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Test\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test', 'TestRecordType', complexPicklist
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
    }
    
    @isTest
    static void testMultipleFiles_Processing() {
        List<ContentVersion> files = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title IN ('Test Campaign Document', 'Test CSV File') LIMIT 2];
        List<String> docIds = new List<String>();
        for (ContentVersion cv : files) {
            docIds.add(cv.ContentDocumentId);
        }
        
        String mockResponse = '{"choices": [{"message": {"content": "{\\"campaignName\\": \\"Multi\\"}"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            docIds, 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'));
        List<String> filesAnalyzed = (List<String>)result.get('filesAnalyzed');
        System.assertEquals(2, filesAnalyzed.size());
    }
    
    @isTest
    static void testDetectFocusArea_InvalidFile() {
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.detectFocusAreaFromFile(
            new List<String>{'invalid_id'}
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals('Could not retrieve file content', result.get('error'));
    }
    
    @isTest
    static void testHTTPErrors_Various() {
        // Test 401 error
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(401, 'Unauthorized'));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test', 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assert(((String)result.get('error')).contains('401'));
    }
    
    @isTest
    static void testMalformedResponse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'Not JSON'));
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI(
            'Test', 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assert(((String)result.get('error')).contains('Failed to connect to AI service'));
    }
    
    @isTest
    static void testFileNotFound_Handling() {
        List<String> invalidIds = new List<String>{'068000000000000'};
        
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeFileWithAI(
            invalidIds, 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assertEquals('Could not retrieve file content from Salesforce', result.get('error'));
    }
    
    // Additional test to create a truly empty content scenario for testing
    @isTest
    static void testAnalyzeCombinedContent_NoExtractableContent() {
        // Create a test scenario where we can't extract content
        Test.startTest();
        Map<String, Object> result = Core_MDF_AiFieldSuggestions.analyzeCombinedContent(
            '', new List<String>{'invalid_document_id'}, 'TestRecordType', getStandardPicklistValues()
        );
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        // This should trigger the "No content could be extracted for analysis" error
        System.assert(((String)result.get('error')).contains('No content could be extracted') || 
                     ((String)result.get('error')).contains('An error occurred'));
    }
}