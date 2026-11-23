//class can be used to create the Auth provider plugin
//TWC745-6310-Implement Privileged Access Management (PAM)-custom setting to Named credential change 
//-----------------------------------------------------------------------------------------------------
global class Core_IPS_AuthProviderHandler_Plugin extends Auth.AuthProviderPluginClass{
public String redirectUrl;
    private String key;
    private String secret;
    
    private String authUrl;
    private String accessTokenUrl;
    
    private String CUSTOM_METADATA_TYPE_NAME = 'Core_IPS_APIAuthSettingPlugin__mdt';
    private String AUTH_PROVIDER_CLASS_NAME = '';
    
    private IRefreshTokenGenerator generator = new DefaultRefreshTokenGenerator();

    
    global String getCustomMetadataType() {
        return CUSTOM_METADATA_TYPE_NAME;
    }
    
     // Return a URL where we will redirect the user
    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        final String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('base url data>>>>>>'+baseUrl);
        final String url = baseUrl+authProviderConfiguration.get('Callback_URL__c') + '?state=' + stateToPropagate; 
        System.debug(' url  data only ****************>>>>>>'+url);
        System.debug('initiate called - url <' + url + '>');
        return new PageReference(url);
    }
        // Return a new object called AuthProviderTokenResponse.  This will contain an optional accessToken and refreshToken.
    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state )  { 
        
        Map<String,String> queryParams = state.queryParameters;
        //String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');
                                                        
        String newRefreshToken = generateRefreshToken();                                                     
        String accesstoken = retrieveToken(authProviderConfiguration);                                   
        System.debug('state params: ' + queryParams);
        return new Auth.AuthProviderTokenResponse('Apigee',accesstoken, newRefreshToken, sfdcState);
    }
    
     global override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) { 
        String newRefreshToken = generateRefreshToken();                                                     
        String accesstoken = retrieveToken(authProviderConfiguration); 
        return new Auth.OAuthRefreshResult(accesstoken, newRefreshToken);
    }
    // Construct an Auth.UserData object
    // We're not currently using this method, so just return blanks/null for now
    global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, 
                                     Auth.AuthProviderTokenResponse response) {
        String token = response.oauthToken;
        Map<String,String> provMap = new Map<String,String>(); 
        provMap.put('what1', 'noidea1'); 
        provMap.put('what2', 'noidea2'); 
        return new Auth.UserData('', '', '', '', '', 'what', '', null, 'Apigee', null, provMap);
    }
    
     global String retrieveToken(Map<String, String> authProviderConfiguration) {
         key = authProviderConfiguration.get('Consumer_Key__c');
         secret = authProviderConfiguration.get('Consumer_Secret__c');
         accessTokenUrl = authProviderConfiguration.get('Access_Token_URL__c');
         String grantType ='client_credentials';
         HttpRequest req = new HttpRequest();
         
         String body = 'grant_type='+grantType+'&client_id='+key+'&client_secret='+secret;
         req.setBody(body);
         String url = accessTokenUrl;
         req.setEndpoint(url);
         req.setMethod('POST');
         Http http = new Http();
         HTTPResponse res = http.send(req);
         String responseBody = res.getBody();
         System.debug('Token response: ' + responseBody);
         TokenResponse tr = (TokenResponse) (JSON.deserialize(responseBody, TokenResponse.Class));
         System.debug('token response: ' + tr);
         return tr.access_token;
     }
    
    
    private String generateRefreshToken() {
        return generator.generate();
    }
    
    /**
     * Interface to allow us to override refresh token generation when testing.
     */
    public interface IRefreshTokenGenerator {
        String generate();
    }

    
    
    // Inner class to hold the token response
    @TestVisible
    private class TokenResponse {
        @TestVisible String access_token = '';
        @TestVisible String token_type = '';
        @TestVisible String expires_in = '';
        @TestVisible String ext_expires_in;

    }
    public class DefaultRefreshTokenGenerator implements IRefreshTokenGenerator {
        public String generate() {
            final String refreshToken = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
            return refreshToken;
        }
    }

}