public class AIResponseParser {
    
    public static AIAnalysisStructures.AIAnalysisResponse parseAnalysisResponse(String aiResponse) {
        AIAnalysisStructures.AIAnalysisResponse response = new AIAnalysisStructures.AIAnalysisResponse();
        
        try {
            System.debug('Raw AI Response: ' + aiResponse);
            
            // Clean up the AI response - remove markdown code blocks if present
            String cleanResponse = cleanAIResponse(aiResponse);
            System.debug('Cleaned AI Response: ' + cleanResponse);
            
            // Try to parse as JSON first
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(cleanResponse);
            System.debug('Parsed Response Map: ' + responseMap);
            
            response.summary = (String) responseMap.get('summary');
            response.confidence = getIntegerValue(responseMap.get('confidence'));
            response.reasoning = (String) responseMap.get('reasoning');
            
            // Parse recommendations
            List<Object> recommendationsList = (List<Object>) responseMap.get('recommendations');
            response.recommendations = new List<AIAnalysisStructures.AIRecommendation>();
            
            if (recommendationsList != null && !recommendationsList.isEmpty()) {
                for (Object recObj : recommendationsList) {
                    Map<String, Object> recMap = (Map<String, Object>) recObj;
                    AIAnalysisStructures.AIRecommendation rec = new AIAnalysisStructures.AIRecommendation();
                    
                    rec.itemName = (String) recMap.get('itemName');
                    rec.itemType = (String) recMap.get('itemType');
                    rec.action = (String) recMap.get('action');
                    rec.riskLevel = (String) recMap.get('riskLevel');
                    rec.aiReasoning = (String) recMap.get('aiReasoning');
                    rec.confidenceScore = getIntegerValue(recMap.get('confidenceScore'));
                    
                    response.recommendations.add(rec);
                }
            }
            
        } catch (Exception e) {
            System.debug('JSON parsing failed: ' + e.getMessage());
            System.debug('AI Response Length: ' + aiResponse.length());
            System.debug('First 500 chars: ' + aiResponse.substring(0, Math.min(500, aiResponse.length())));
            
            // Create a structured fallback response
            response.summary = 'AI analysis completed, but response format needs adjustment. Please try again or contact administrator.';
            response.confidence = 50;
            response.reasoning = 'Response parsing failed - may indicate AI formatting issues.';
            response.recommendations = new List<AIAnalysisStructures.AIRecommendation>();
            
            // Create a sample recommendation to show the structure works
            AIAnalysisStructures.AIRecommendation sampleRec = new AIAnalysisStructures.AIRecommendation();
            sampleRec.itemName = 'Response Format Issue';
            sampleRec.itemType = 'System';
            sampleRec.action = 'REVIEW';
            sampleRec.riskLevel = 'LOW';
            sampleRec.aiReasoning = 'AI response could not be parsed as JSON. This may be due to formatting issues with the AI model response.';
            sampleRec.confidenceScore = 100;
            response.recommendations.add(sampleRec);
        }
        
        return response;
    }
    
    private static String cleanAIResponse(String aiResponse) {
        if (String.isBlank(aiResponse)) {
            return '{}';
        }
        
        // Remove markdown code blocks
        String cleaned = aiResponse.trim();
        
        // Remove ```json and ``` markers
        if (cleaned.startsWith('```json')) {
            cleaned = cleaned.substring(7);
        }
        if (cleaned.startsWith('```')) {
            cleaned = cleaned.substring(3);
        }
        if (cleaned.endsWith('```')) {
            cleaned = cleaned.substring(0, cleaned.length() - 3);
        }
        
        return cleaned.trim();
    }
    
    private static Integer getIntegerValue(Object value) {
        if (value == null) return 0;
        
        if (value instanceof Integer) {
            return (Integer) value;
        } else if (value instanceof Decimal) {
            return ((Decimal) value).intValue();
        } else if (value instanceof String) {
            try {
                return Integer.valueOf((String) value);
            } catch (Exception e) {
                return 0;
            }
        }
        
        return 0;
    }
    
    private static List<AIAnalysisStructures.AIRecommendation> extractRecommendationsFromText(String text) {
        List<AIAnalysisStructures.AIRecommendation> recommendations = new List<AIAnalysisStructures.AIRecommendation>();
        
        if (String.isBlank(text)) {
            return recommendations;
        }
        
        // Simple text parsing for recommendations
        List<String> lines = text.split('\n');
        
        for (String line : lines) {
            line = line.trim();
            
            if (shouldCreateRecommendation(line)) {
                AIAnalysisStructures.AIRecommendation rec = new AIAnalysisStructures.AIRecommendation();
                rec.itemName = extractItemNameFromLine(line);
                rec.action = extractActionFromLine(line);
                rec.riskLevel = extractRiskFromLine(line);
                rec.aiReasoning = line;
                rec.confidenceScore = 60;
                rec.itemType = 'Field'; // Default assumption
                
                recommendations.add(rec);
            }
        }
        
        // If no recommendations found, create a general one
        if (recommendations.isEmpty()) {
            AIAnalysisStructures.AIRecommendation rec = new AIAnalysisStructures.AIRecommendation();
            rec.itemName = 'General Analysis';
            rec.itemType = 'Analysis';
            rec.action = 'REVIEW';
            rec.riskLevel = 'MEDIUM';
            rec.aiReasoning = 'AI provided general analysis. Manual review recommended.';
            rec.confidenceScore = 50;
            
            recommendations.add(rec);
        }
        
        return recommendations;
    }
    
    private static Boolean shouldCreateRecommendation(String line) {
        String lowerLine = line.toLowerCase();
        return (lowerLine.contains('remove') || 
                lowerLine.contains('delete') || 
                lowerLine.contains('unused') || 
                lowerLine.contains('duplicate') || 
                lowerLine.contains('consolidate') || 
                lowerLine.contains('field') && (lowerLine.contains('__c') || lowerLine.contains('custom')));
    }
    
    private static String extractItemNameFromLine(String line) {
        // Look for field patterns (ending with __c)
        Pattern fieldPattern = Pattern.compile('\\b\\w+__c\\b');
        Matcher fieldMatcher = fieldPattern.matcher(line);
        
        if (fieldMatcher.find()) {
            return fieldMatcher.group();
        }
        
        // Look for quoted items
        Pattern quotedPattern = Pattern.compile('"([^"]+)"');
        Matcher quotedMatcher = quotedPattern.matcher(line);
        
        if (quotedMatcher.find()) {
            return quotedMatcher.group(1);
        }
        
        // Extract first significant word
        List<String> words = line.split('\\s+');
        for (String word : words) {
            if (word.length() > 3 && !isCommonWord(word.toLowerCase())) {
                return word;
            }
        }
        
        return 'Unknown Item';
    }
    
    private static String extractActionFromLine(String line) {
        String lowerLine = line.toLowerCase();
        
        if (lowerLine.contains('remove') || lowerLine.contains('delete')) {
            return 'REMOVE';
        } else if (lowerLine.contains('consolidate') || lowerLine.contains('merge')) {
            return 'CONSOLIDATE';
        } else if (lowerLine.contains('keep') || lowerLine.contains('maintain')) {
            return 'KEEP';
        } else {
            return 'REVIEW';
        }
    }
    
    private static String extractRiskFromLine(String line) {
        String lowerLine = line.toLowerCase();
        
        if (lowerLine.contains('high risk') || lowerLine.contains('critical') || lowerLine.contains('dangerous')) {
            return 'HIGH';
        } else if (lowerLine.contains('low risk') || lowerLine.contains('safe')) {
            return 'LOW';
        } else {
            return 'MEDIUM';
        }
    }
    
    private static Boolean isCommonWord(String word) {
        Set<String> commonWords = new Set<String>{'the', 'and', 'this', 'that', 'with', 'from', 'they', 'have', 'will', 'can', 'are', 'not', 'but', 'all', 'for'};
        return commonWords.contains(word);
    }
}