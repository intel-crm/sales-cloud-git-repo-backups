public class SWS_TokenHandler {
    
    private static String key;
    private static String secret;
    private static String body;
    private static String accessTokenUrl;
    
    public static TokenResponse getAccessToken(){
        setParameters();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accessTokenUrl);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        req.setMethod('POST');
        Http http = new Http();
        System.HttpResponse response = http.send(req);
        String responseBody = response.getBody();
        return (TokenResponse)JSON.deserialize(responseBody, TokenResponse.class);
    }
    
    private static void setParameters(){
        API_M_Auth_Provider__mdt mdt = getDetailsFromAuth();
        key = mdt.Consumer_Key__c;
        secret = mdt.Consumer_Secret__c;
        accessTokenUrl = mdt.Access_Token_URL__c;
        body = 	'client_id=' + EncodingUtil.urlEncode(key, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(secret, 'UTF-8')+
            '&grant_type=client_credentials';
    }
    
    private static API_M_Auth_Provider__mdt getDetailsFromAuth(){
        String IDCMasterLabel = (SWS_Core_CRM_Labels__c.getValues('IDCMasterLabel') != null ? SWS_Core_CRM_Labels__c.getValues('IDCMasterLabel').SWS_Value__c : 'IDC_Credit_Request');
        return ([SELECT Access_Token_URL__c, Auth_URL__c, Consumer_Key__c, Consumer_Secret__c 
                 FROM API_M_Auth_Provider__mdt 
                 WHERE MasterLabel=:IDCMasterLabel]);
    }
    
    public class TokenResponse{
        public String access_token;
        public Integer expires_in;
        public String token_type;
        public String error;
        public String error_description;
    }
}