public class AIAnalysisStructures {
    
    public class AIAnalysisRequest {
        @AuraEnabled public String query;
        @AuraEnabled public List<String> selectedObjects;
        @AuraEnabled public String analysisType;
    }
    
    public class AIAnalysisResponse {
        @AuraEnabled public String summary;
        @AuraEnabled public List<AIRecommendation> recommendations;
        @AuraEnabled public Integer confidence;
        @AuraEnabled public String reasoning;
        @AuraEnabled public Integer tokensUsed;
        @AuraEnabled public String modelUsed;
        @AuraEnabled public Datetime analysisTimestamp;
        
        public AIAnalysisResponse() {
            this.recommendations = new List<AIRecommendation>();
            this.analysisTimestamp = System.now();
        }
    }
    
    public class AIRecommendation {
        @AuraEnabled public String itemName;
        @AuraEnabled public String itemType;
        @AuraEnabled public String action;
        @AuraEnabled public String riskLevel;
        @AuraEnabled public String aiReasoning;
        @AuraEnabled public Integer confidenceScore;
        @AuraEnabled public String badgeVariant; // For UI
    }
}