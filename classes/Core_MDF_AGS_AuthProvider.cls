/*****************************************************************************************************
Class Name        	:    Core_MDF_AGS_AuthProvider
Test Class Name 	:    Core_MDF_AGS_CalloutQueueable_Test
Description         :    Auth provider plugin used by AGS integrations to launch the OAuth flow,
                          exchange the authorization code for tokens, and supply token refresh/user
                          info behavior expected by Salesforce Auth.Provider extensions.
Created By          :    Ramapriya
******************************************************************************************************/
global class Core_MDF_AGS_AuthProvider extends Auth.AuthProviderPluginClass {
    
    public String redirectUrl;
    private String key;
    private String secret;
    
    private String authUrl;
    private String accessTokenUrl;
    
    private String CUSTOM_METADATA_TYPE_NAME = 'Core_MDF_CCP_Auth_Provider__mdt';
    private String AUTH_PROVIDER_CLASS_NAME = '';
    
    /** Returns the custom metadata type that stores this auth provider's configuration. */
    global String getCustomMetadataType() {
        return CUSTOM_METADATA_TYPE_NAME;
    }
     /******************************************************************************************************
    Method Name:        initiate   
    Description:        Return a URL where we will redirect the user
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Starts the authorization redirect by building the AGS authorization URL. */
    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        authUrl = authProviderConfiguration.get('Auth_URL__c');
        key = authProviderConfiguration.get('Consumer_Key__c');
        AUTH_PROVIDER_CLASS_NAME =authProviderConfiguration.get('Redirect_Url_Suffix__c');
        redirectUrl = EncodingUtil.urlEncode(
            'https://' + System.Url.getOrgDomainUrl().getHost() + '/services/authcallback/' + AUTH_PROVIDER_CLASS_NAME,
            'UTF-8');
        
        String url = authUrl + '?response_type=code&client_id='+ key +'&redirect_uri='+ redirectUrl + '&state=' + stateToPropagate;
        return new PageReference(url);
    }

    
    /******************************************************************************************************
    Method Name:        handleCallback   
    Description:        Return a new object called AuthProviderTokenResponse.  This will contain an optional accessToken and refreshToken.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Exchanges the authorization code for access and refresh tokens after the callback returns. */
    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration,
                                                         Auth.AuthProviderCallbackState state )  { 
        
        key = authProviderConfiguration.get('Consumer_Key__c');
        secret = authProviderConfiguration.get('Consumer_Secret__c');
        accessTokenUrl = authProviderConfiguration.get('Access_Token_URL__c');
    
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');
        HttpRequest req = new HttpRequest();
        // Need to split since it's just over 900 chars, due to limits on System.debug
        String body = 'client_id=' + EncodingUtil.urlEncode(key, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(secret, 'UTF-8') +
             //'&grant_type=client_credentials'+
             //'&refresh_token=refresh_token full';
            //'&code=' + EncodingUtil.urlEncode('code', 'UTF-8');
            '&code=' + EncodingUtil.urlEncode(code, 'UTF-8');
        req.setBody(body);
        
        String url = accessTokenUrl;
        req.setEndpoint(url);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Host', accessTokenUrl.substringAfter('https://').substringBefore('/')); // e.g. 'apis.intel.com'
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody(); 
        TokenResponse tr = (TokenResponse) (JSON.deserialize(responseBody, TokenResponse.Class));
        return new Auth.AuthProviderTokenResponse('Apigee', tr.access_token, tr.refresh_token, sfdcState);
    }
     /******************************************************************************************************
    Method Name:        refresh   
    Description:        
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Refreshes the AGS access token using the configured token endpoint. */
    global override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) { 
        key = authProviderConfiguration.get('Consumer_Key__c');
        secret = authProviderConfiguration.get('Consumer_Secret__c');
        accessTokenUrl = authProviderConfiguration.get('Access_Token_URL__c');
        //String code = authProviderConfiguration.get('Code__c');
        HttpRequest req = new HttpRequest();
        // Need to split since it's just over 900 chars, due to limits on System.debug
        String body = 'client_id=' + EncodingUtil.urlEncode(key, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(secret, 'UTF-8') +
            '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8') +
            '&grant_type=client_credentials';
        req.setBody(body);                                           
        String url = accessTokenUrl;
        req.setEndpoint(url);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Host', accessTokenUrl.substringAfter('https://').substringBefore('/')); // e.g. 'apis.intel.com'
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        //String token = getTokenValueFromResponse(responseBody, 'Token', null);
        TokenResponse tr = (TokenResponse) (JSON.deserialize(responseBody, TokenResponse.Class));
        return new Auth.OAuthRefreshResult(tr.access_token, tr.refresh_token);
    }
    
    // Construct an Auth.UserData object
    // We're not currently using this method, so just return blanks/null for now
    /** Returns a minimal user payload because this auth provider does not map external profile data. */
    global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, 
                                     Auth.AuthProviderTokenResponse response) {
        //String token = response.oauthToken;
        Map<String,String> provMap = new Map<String,String>(); 
        provMap.put('what1', 'noidea1'); 
        provMap.put('what2', 'noidea2'); 
        return new Auth.UserData(
            '',
            '',
            '',
            '',
            '',
            'AGS',
            '',
            null,
            'AGS',
            null,
            new Map<String,String>()
        );
    }
    
    // Inner class to hold the token response returned by the AGS token endpoint.
    @TestVisible
    private class TokenResponse {
        @TestVisible String access_token = '';
        @TestVisible String id_token = '';
        @TestVisible String token_type = '';
        @TestVisible String expires_in = '';
        @TestVisible String scope = '';
        @TestVisible String refresh_token = '';
    }
}