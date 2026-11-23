/**
 * 
 * 
 * @author      Biswa
 * @since       20/07/2021
 * @revisions   N/A
 *
 * This class calls the Einstein Sentiment 
 * API class to find the sentiment of a block 
 * of text.
 *
 * @return  SentimentAnalysisResponse   Returns an instance of SentimentAnalysisResponse class
 * @param  text  The text whose Sentiment has to be analysed
 **/

public without sharing class EinsteinService {
    @AuraEnabled
    public static SentimentAnalysisResponse findSentiment(String text) {
        EinsteinAPI api = new EinsteinApi();        
        SentimentAnalysisResponse resp = api.findSentiment( text );
        return resp;
    }
}