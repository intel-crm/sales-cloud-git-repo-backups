/* Created for testing the AGS integration, will be deleted once mock integration covered 
- Ref class :Core_MDF_AGS_AuthProvider */

public class OAuth2HttpClient {
    
    // OAuth Configuration
    public class OAuthConfig {
        public String grantType { get; set; }
        public String accessTokenUrl { get; set; }
        public String clientId { get; set; }
        public String clientSecret { get; set; }
        public String scope { get; set; }
        public String clientAuthentication { get; set; }
        public String tokenName { get; set; }
        public OAuthConfig() {
            this.grantType = 'client_credentials';
            this.clientAuthentication = 'client_secret_basic';
            this.clientId='5a48cdf7-3e76-4c7e-9dc1-a52822456bb0';
            this.clientSecret='A0j8Q~qrnBD38Mbjh3Wd80KhEmDxcQYtk8GXUco7'; 
            this.accessTokenUrl='https://login.microsoftonline.com/9889e411-4383-4500-8c2a-e8f095438f4f/oauth2/v2.0/token'; 
            this.scope='api://6ee2691f-e017-4258-8c62-340752525d45/.default'; 
            this.clientAuthentication='Send client credentials in Body';
            this.tokenName='AGS';
        }
    }
    
    // Token Response
    public class TokenResponse {
        public String access_token { get; set; }
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
        public String scope { get; set; }
        public String error { get; set; }
        public String error_description { get; set; }
        
        public Boolean isSuccess() {
            return String.isNotBlank(access_token) && String.isBlank(error);
        }
    }
    
    private OAuthConfig config;
    private String cachedAccessToken;
    private DateTime tokenExpiryTime;
    
    // Constructor
    public OAuth2HttpClient(OAuthConfig oauthConfig) {
        this.config = oauthConfig;
    }
    
    // Get Access Token
    public static TokenResponse getAccessToken() {
        try {
            OAuth2HttpClient.OAuthConfig config = new OAuth2HttpClient.OAuthConfig();
            OAuth2HttpClient client = new OAuth2HttpClient(config);
            // Check if we have a valid cached token , token should check within 1 hours ,
            
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(config.accessTokenUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            String requestBody = 'grant_type=' + EncodingUtil.urlEncode(config.grantType, 'UTF-8');
            
            if (String.isNotBlank(config.scope)) {
                requestBody += '&scope=' + EncodingUtil.urlEncode(config.scope, 'UTF-8');
            }
            
            // Handle different client authentication methods
            if (config.clientAuthentication == 'client_secret_basic') {
                // Basic Authentication
                String credentials = config.clientId + ':' + config.clientSecret;
                String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));
                req.setHeader('Authorization', 'Basic ' + encodedCredentials);
            } else {
                // client_secret_post - include credentials in body
                requestBody += '&client_id=' + EncodingUtil.urlEncode(config.clientId, 'UTF-8');
                requestBody += '&client_secret=' + EncodingUtil.urlEncode(config.clientSecret, 'UTF-8');
            }
            
            req.setBody(requestBody);
            req.setTimeout(60000); // 60 seconds timeout
            System.debug('2-=-=-=-=-=-=='+req);
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('3-=-=-=-=-=-=='+res.getBody());
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            
            // Cache the token if successful
            
            
            return tokenResponse;
            
        } catch (Exception e) {
            TokenResponse errorResponse = new TokenResponse();
            errorResponse.error = 'request_failed';
            errorResponse.error_description = e.getMessage();
            return errorResponse;
        }
    }
    public static void makeAuthenticatedRequest(String endpoint, String method, String body) {
        TokenResponse tokenResponse = getAccessToken();
        System.debug('4-=-=-=-=-=-=='+tokenResponse);
        if (!tokenResponse.isSuccess()) {
            throw new CalloutException('Failed to obtain access token: ' + tokenResponse.error_description);
        }
         //String agsEndPoint='callout:SalesCRM_Apigee/AccessRequests?sync=false&notify=false&noop=false';
        String agsEndPoint='https://apis-stage.intel.com/AccessRequests?sync=false&notify=false&noop=false';
        //https://069a99b8-e6a0-4828-a5a7-2b806d5514e5:WhX8Q~f_pSNssln4bZ9opatb6PkH6FBcPWwzBdjE@apis-sandbox.intel.com/m2r/user-roles/v1/entitlements
        String base64EncodedToken= EncodingUtil.base64Encode(Blob.valueOf(tokenResponse.access_token));
        HttpRequest req = new HttpRequest();
        req.setEndpoint(agsEndPoint);
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer' + base64EncodedToken);
        //req.setHeader('Authorization','Bearer ' +tokenResponse.access_token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('User-Agent', 'Salesforce-AGS-Client/1.0');
        body='{"requestee":{"enterpriseId":"12184888"},"requestItems":[{"operation":"Add","access":{"type":"Role","displayname":"CCPCY-72UPMANUAL-EDIR-ROLE103 Display"},"justification":"Explains why access is needed."}]}';
        System.debug('body======'+body);
        if (String.isNotBlank(body)) {
            req.setBody(body);
            System.debug('body=='+req);
            System.debug('body=='+req.getBody());
        }
        
        req.setTimeout(60000);
        
        Http http = new Http();
        //http.send(req);
        HttpResponse res = http.send(req);
        System.debug('response=='+res.getBody());
    }
    
    /* Convenience methods for different HTTP methods
    public HttpResponse get(String endpoint, Map<String, String> headers) {
        return makeAuthenticatedRequest(endpoint, 'GET', null, headers);
    }
    
    public HttpResponse post(String endpoint, String body, Map<String, String> headers) {
        return makeAuthenticatedRequest(endpoint, 'POST', body, headers);
    }
    
    public HttpResponse put(String endpoint, String body, Map<String, String> headers) {
        return makeAuthenticatedRequest(endpoint, 'PUT', body, headers);
    }
    
    public HttpResponse deleteRequest(String endpoint, Map<String, String> headers) {
        return makeAuthenticatedRequest(endpoint, 'DELETE', null, headers);
    }*/
    
    // Check if cached token is still valid, check should done from custom label
    private static Boolean isTokenValid() {
        DateTime currentTime = DateTime.now();
        DateTime oneHourAgo = currentTime.addHours(-1);
        //return String.isNotBlank(this.cachedAccessToken) && 
              // this.tokenExpiryTime != null && 
             //  tokenExpiryTime > oneHourAgo;
               return null;
    }
    
    // Clear cached token (useful for testing or forcing refresh)
    public void clearCachedToken() {
        this.cachedAccessToken = null;
        this.tokenExpiryTime = null;
    }
}