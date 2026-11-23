/**
 * This class is created to receive
 * the Response of Sentiment Analysis
 * API.
 * 
 * @author      Biswa
 * @since       20/07/2021
 * @revisions   N/A
 **/
global class SentimentAnalysisResponse {
    @AuraEnabled public List<Probabilities> probabilities    { get; set; } 
    
    global class Probabilities {
        @AuraEnabled public String label                     { get; set; } 
        @AuraEnabled public Double probability               { get; set; }
    }
}