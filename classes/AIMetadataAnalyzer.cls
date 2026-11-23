public without sharing class AIMetadataAnalyzer {
    
    // Remove the inner classes and use the external ones
    @AuraEnabled
    public static AIAnalysisStructures.AIAnalysisResponse analyzeWithAI(String query, List<String> selectedObjects, String analysisType) {
        try {
            // Null checks
            if (String.isBlank(query)) {
                AuraHandledException ex = new AuraHandledException('Query cannot be empty');
                ex.setMessage('Query cannot be empty');
                throw ex;
            }
            if (selectedObjects == null || selectedObjects.isEmpty()) {
                AuraHandledException ex = new AuraHandledException('Please select at least one object to analyze');
                ex.setMessage('Please select at least one object to analyze');
                throw ex;
            }
            if (String.isBlank(analysisType)) {
                analysisType = 'general_analysis';
            }
            
            // Create request object from parameters
            AIAnalysisStructures.AIAnalysisRequest request = new AIAnalysisStructures.AIAnalysisRequest();
            request.query = query;
            request.selectedObjects = selectedObjects;
            request.analysisType = analysisType;
            
            System.debug('Starting AI analysis for: ' + selectedObjects);
            
            // Get metadata context
            MetadataContext context = MetadataContext.buildContext(request.selectedObjects);
            if (context == null) {
                AuraHandledException ex = new AuraHandledException('Failed to build metadata context');
                ex.setMessage('Failed to build metadata context');
                throw ex;
            }
            
            // Build AI prompt based on request type
            String prompt = buildAnalysisPrompt(request, context);
            if (String.isBlank(prompt)) {
                AuraHandledException ex = new AuraHandledException('Failed to build analysis prompt');
                ex.setMessage('Failed to build analysis prompt');
                throw ex;
            }
            
            System.debug('Calling Azure OpenAI API...');
            
            // Call Azure OpenAI API - use coder model for technical analysis
            DeepSeekCalloutService.DeepSeekResponse deepSeekResponse = 
                DeepSeekCalloutService.callDeepSeekCoder(prompt);
            
            if (deepSeekResponse == null) {
                AuraHandledException ex = new AuraHandledException('No response from Azure OpenAI API');
                ex.setMessage('No response from Azure OpenAI API');
                throw ex;
            }
            
            if (!deepSeekResponse.success) {
                AuraHandledException ex = new AuraHandledException('Azure OpenAI API failed: ' + deepSeekResponse.errorMessage);
                ex.setMessage('Azure OpenAI API failed: ' + deepSeekResponse.errorMessage);
                throw ex;
            }
            
            System.debug('Parsing AI response...');
            
            // Parse AI response
            System.debug('Raw AI Response: ' + deepSeekResponse.content);
            
            AIAnalysisStructures.AIAnalysisResponse response = AIResponseParser.parseAnalysisResponse(deepSeekResponse.content);
            if (response == null) {
                AuraHandledException ex = new AuraHandledException('Failed to parse AI response');
                ex.setMessage('Failed to parse AI response');
                throw ex;
            }
            
            System.debug('Parsed Response Summary: ' + response.summary);
            System.debug('Recommendations Count: ' + (response.recommendations != null ? response.recommendations.size() : 0));
            
            // Add usage info
            response.tokensUsed = deepSeekResponse.totalTokens;
            response.modelUsed = deepSeekResponse.model;
            
            System.debug('AI analysis completed successfully');
            
            return response;
            
        } catch (Exception e) {
            System.debug('AIMetadataAnalyzer Error: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            
            // Create proper AuraHandledException
            AuraHandledException auraEx = new AuraHandledException('AI Analysis failed: ' + e.getMessage());
            auraEx.setMessage('AI Analysis failed: ' + e.getMessage());
            throw auraEx;
        }
    }
    
    @AuraEnabled
    public static AIAnalysisStructures.AIAnalysisResponse processNaturalLanguageQuery(String userQuery, List<String> objects) {
            try {
            // ✅ FIXED: Use correct parameter names
            System.debug('Processing natural language query: ' + userQuery);
            System.debug('Selected objects: ' + objects);
            
            if (String.isBlank(userQuery)) {
                throw new AuraHandledException('Please provide a question or request.');
            }
            
            if (objects == null || objects.isEmpty()) {
                objects = new List<String>{'Account'}; // Default to Account
            }
            
            // Build metadata context
            MetadataContext context = MetadataContext.buildContext(objects);
            System.debug('Metadata context built successfully');
            
            // Create a conversational prompt for natural language queries
            String prompt = buildConversationalPrompt(context.toString(), userQuery);
            System.debug('Built conversational prompt');
            
            // Call Azure OpenAI
            DeepSeekCalloutService.DeepSeekResponse apiResponse = DeepSeekCalloutService.callDeepSeek(prompt);
            
            if (!apiResponse.success) {
                throw new AuraHandledException('Azure OpenAI API call failed: ' + apiResponse.errorMessage);
            }
            
            System.debug('Azure OpenAI response received: ' + apiResponse.content);
            
            // For natural language queries, return the raw content as a simple response
            AIAnalysisStructures.AIAnalysisResponse response = new AIAnalysisStructures.AIAnalysisResponse();
            response.summary = apiResponse.content;
            response.recommendations = new List<AIAnalysisStructures.AIRecommendation>();
            // response.analysisType = 'Natural Language Query';
            // response.timestamp = DateTime.now();
            // response.objectsAnalyzed = objects;
            
            return response;
            
        } catch (Exception e) {
            System.debug('Error in processNaturalLanguageQuery: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Natural language query failed: ' + e.getMessage());
        }
    }
    
    private static String buildAnalysisPrompt(AIAnalysisStructures.AIAnalysisRequest request, MetadataContext context) {
        String basePrompt = 'SALESFORCE METADATA CLEANUP ANALYSIS\n\n' +
            'ORGANIZATION CONTEXT:\n' + JSON.serialize(context) + '\n\n' +
            'USER REQUEST: ' + request.query + '\n\n';
            
        // Customize instructions based on analysis type
        String specificInstructions = getSpecificInstructions(request.analysisType);
        String examples = getExampleRecommendations(request.analysisType);
        
        String prompt = basePrompt +
            'ANALYSIS TYPE: ' + request.analysisType + '\n\n' +
            specificInstructions + '\n\n' +
            'IMPORTANT CONSTRAINTS:\n' +
            '- Only analyze the ACTUAL metadata provided - do not assume fields exist\n' +
            '- Do not reference "standard functionality" unless you can see it in the metadata\n' +
            '- Be conservative and only suggest changes you can justify from the data\n' +
            '- If you cannot find genuine duplicates, say so in the summary\n\n' +
            'RESPONSE FORMAT (JSON only, no markdown):\n' +
            '{\n' +
            '  "summary": "Clear summary of specific findings for ' + request.analysisType + '",\n' +
            '  "recommendations": [\n' +
            examples + '\n' +
            '  ],\n' +
            '  "confidence": 85,\n' +
            '  "reasoning": "Analysis approach and methodology used"\n' +
            '}\n\n' +
            'CRITICAL: Return only valid JSON. Base recommendations only on the provided metadata.';
            
        return prompt;
    }
    
    private static String getSpecificInstructions(String analysisType) {
        switch on analysisType {
            when 'unused_fields' {
                return 'UNUSED FIELDS ANALYSIS:\n' +
                    '1. Identify custom fields with zero or very low data population\n' +
                    '2. Check if fields are referenced in Apex, Flows, or Page Layouts\n' +
                    '3. Focus on fields that can be safely removed\n' +
                    '4. Consider data retention requirements\n' +
                    '5. Prioritize fields with 0% data population and no code references';
            }
            when 'duplicates' {
                return 'DUPLICATE DETECTION ANALYSIS:\n' +
                    '1. Identify ACTUAL duplicate custom fields with very similar names or purposes\n' +
                    '2. Look for multiple custom fields storing the same type of data (e.g., two phone fields, two email fields)\n' +
                    '3. Find fields with overlapping purposes within the SAME object\n' +
                    '4. Only suggest consolidation if there are truly redundant CUSTOM fields\n' +
                    '5. DO NOT assume standard fields exist unless you can see them in the metadata\n' +
                    '6. Focus on genuine duplicates like Email__c vs Email_Address__c on the same object\n' +
                    '7. Be conservative - only flag clear duplicates with similar names/purposes';
            }
            when 'risk_assessment' {
                return 'COMPREHENSIVE RISK ASSESSMENT:\n' +
                    '1. Evaluate cleanup impact on business processes\n' +
                    '2. Assess technical dependencies and integrations\n' +
                    '3. Identify high-risk vs low-risk cleanup activities\n' +
                    '4. Consider user adoption and training needs\n' +
                    '5. Prioritize by business value and implementation effort';
            }
            when else {
                return 'GENERAL METADATA ANALYSIS:\n' +
                    '1. Analyze overall metadata health and optimization opportunities\n' +
                    '2. Identify quick wins and long-term improvement areas\n' +
                    '3. Consider governance and best practices\n' +
                    '4. Balance cleanup benefits with implementation effort';
            }
        }
    }
    
    private static String getExampleRecommendations(String analysisType) {
        switch on analysisType {
            when 'unused_fields' {
                return '    {\n' +
                    '      "itemName": "Legacy_Field__c",\n' +
                    '      "itemType": "CustomField",\n' +
                    '      "action": "REMOVE",\n' +
                    '      "riskLevel": "LOW",\n' +
                    '      "aiReasoning": "Field has 0% data population across all records ",\n' +
                    '      "confidenceScore": 95\n' +
                    '    }';
            }
            when 'duplicates' {
                return '    {\n' +
                    '      "itemName": "Email_Address__c",\n' +
                    '      "itemType": "CustomField",\n' +
                    '      "action": "CONSOLIDATE",\n' +
                    '      "riskLevel": "MEDIUM",\n' +
                    '      "aiReasoning": "Similar to existing Contact_Email__c field - both store email addresses. Consider consolidating into one field",\n' +
                    '      "confidenceScore": 75\n' +
                    '    }';
            }
            when 'risk_assessment' {
                return '    {\n' +
                    '      "itemName": "Critical_Business_Field__c",\n' +
                    '      "itemType": "CustomField",\n' +
                    '      "action": "KEEP",\n' +
                    '      "riskLevel": "HIGH",\n' +
                    '      "aiReasoning": "High business value field with active usage in reports and processes. Keep and optimize",\n' +
                    '      "confidenceScore": 90\n' +
                    '    }';
            }
            when else {
                return '    {\n' +
                    '      "itemName": "Sample_Field__c",\n' +
                    '      "itemType": "CustomField",\n' +
                    '      "action": "REVIEW",\n' +
                    '      "riskLevel": "MEDIUM",\n' +
                    '      "aiReasoning": "Requires further analysis to determine optimal action",\n' +
                    '      "confidenceScore": 70\n' +
                    '    }';
            }
        }
    }

    /**
     * Build a conversational prompt for natural language queries
     */
    private static String buildConversationalPrompt(String metadataContext, String userQuery) {
        String prompt = 'You are a helpful Salesforce assistant. Answer the user\'s question directly and concisely based on their org metadata. ';
        prompt += 'Do not provide unsolicited recommendations or lengthy explanations unless specifically asked.\n\n';
        
        prompt += 'SALESFORCE ORG METADATA:\n';
        prompt += metadataContext + '\n\n';
        
        prompt += 'USER QUESTION: ' + userQuery + '\n\n';
        
        prompt += 'INSTRUCTIONS:\n';
        prompt += '- Answer the specific question asked\n';
        prompt += '- Be concise and direct\n';
        prompt += '- Use simple formatting (no complex tables or excessive formatting)\n';
        prompt += '- Only include the information requested\n';
        prompt += '- Reference actual field names from the metadata\n';
        prompt += '- Do not add extra recommendations unless asked\n\n';
        
        prompt += 'RESPONSE:';
        
        return prompt;
    }

    @AuraEnabled
    public static Boolean testDeepSeekConnection() {
        return DeepSeekCalloutService.testConnection();
    }
}