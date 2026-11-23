/**
 * This class is created to make requests to
 * various Einstein Endpoints.
 * 
 * @author      Biswa
 * @since       20/07/2021
 * @revisions   N/A
 **/
public class EinsteinAPI {
    public String tokenEndpoint             {
        get {
            Einstein_API_Settings__c settings = Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );
            
            return settings.Token_Endpoint__c;
        }
    }
    public Decimal tokenExpirationSeconds   {
        get {
            Einstein_API_Settings__c settings = Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );
            
            return settings.Token_Expiration_Seconds__c;
        }
    }
    public String registeredEmail           {
        get {
            Einstein_API_Settings__c settings = Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );
            
            return settings.Registered_Email__c;
        }
    }
    public String sentimentEndpoint         {
        get {
            Einstein_API_Settings__c settings = Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );
            
            return settings.Sentiment_Endpoint__c;
        }
    }
    public String sentimentModelId          {
        get {
            Einstein_API_Settings__c settings = Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );
            
            return settings.Sentiment_Model_Id__c;
        }
    }
    
    /**
     * This method is created to make a call
     * to the Token Endpoint and get the token
     * which will help us to make request to
     * other Endpoints of Einstein Services.
     * 
     * @return  String  Returns the access token of the Org
     */
    public String getAccessToken() {
        ContentVersion base64Content = [
            SELECT  Title
                    ,VersionData
            FROM    ContentVersion
            WHERE   Title = 'einstein_platform'
            ORDER BY Title
            LIMIT 1
        ];
        
        String keyContents  = base64Content.VersionData.tostring();
        keyContents         = keyContents.replace( '-----BEGIN RSA PRIVATE KEY-----', '' );
        keyContents         = keyContents.replace( '-----END RSA PRIVATE KEY-----', '' );
        keyContents         = keyContents.replace( '\n', '' );

        JWT jwt             = new JWT( 'RS256' );
        
        jwt.pkcs8           = keyContents; 
        jwt.iss             = 'test.salesforce.com';
        jwt.sub             = registeredEmail;
        jwt.aud             = tokenEndpoint;
        jwt.exp             = String.valueOf( tokenExpirationSeconds );
        String access_token = JWTBearerFlow.getAccessToken( tokenEndpoint, jwt );
        return access_token;
    }
    
    /**
     * This method is created to make call
     * to the Sentiment Endpoint and get 
     * the Sentiment of the block of text.
     * 
     * @param       text                        Block of text whose Sentiment has to be analysed
     * 
     * @return      SentimentAnalysisResponse   Returns an instance of SentimentAnalysisResponse class
     */
    public SentimentAnalysisResponse findSentiment( String text ) {
        String key = getAccessToken();
        
        Http http = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setMethod( 'POST' );
        req.setEndpoint( sentimentEndpoint );
        req.setHeader( 'Authorization', 'Bearer ' + key );
        req.setHeader( 'Content-type', 'application/json' );
        
        String body = '{\"modelId\":\"'+ sentimentModelId + '\",\"document\":\"' + text + '\"}';
        req.setBody( body );
        
        HTTPResponse res = http.send( req );
        
        SentimentAnalysisResponse resp = ( SentimentAnalysisResponse ) JSON.deserialize( res.getBody(), SentimentAnalysisResponse.class );
        return resp;
        /*Map<Double,String> maplabelprobablity = new Map<Double,String>();
        List<SentimentAnalysisResponse.Probabilities > labelWithProbablity = new List<SentimentAnalysisResponse.Probabilities >();
        for(SentimentAnalysisResponse.Probabilities selected : resp.Probabilities){
            SentimentAnalysisResponse.Probabilities selteced = new SentimentAnalysisResponse.Probabilities();
            selteced.label = selected.label;
            selteced.probability = selected.probability;
            maplabelprobablity.put(selteced.probability,selteced.label);
            labelWithProbablity.add(selteced);
        }
        if(labelWithProbablity.size()>0){
            system.debug('###Probablity###: '+ labelWithProbablity);
        }*/
    }
}