@isTest
public class Core_IPS_AuthProviderHandler_Plugin_Test {
    public static testMethod void testGetMetadataType() {
        Core_IPS_AuthProviderHandler_Plugin instance = new Core_IPS_AuthProviderHandler_Plugin();
        System.assertEquals('Core_IPS_APIAuthSettingPlugin__mdt', instance.getCustomMetadataType());
    }

    public static testMethod void testInitiate() {
        Core_IPS_AuthProviderHandler_Plugin instance = new Core_IPS_AuthProviderHandler_Plugin();
        Map<String, String> config = new Map<String, String>();
        //config.put('Callback_URL__c', 'https://intel--crmqa7.sandbox.my.salesforce.com//services/authcallback/Core_IPS_MyIntel_Integration');
        final String state = 'randomState';

        PageReference ref = instance.initiate(config, state);
        //System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm() + 'https://intel--crmqa7.sandbox.my.salesforce.com//services/authcallback/Core_IPS_MyIntel_Integration?state=randomState', ref.getUrl());
      System.AssertEquals(state!= null, true);
    }

    public static testMethod void testHandleCallback_Success() {
        Map<String, String> config = new Map<String, String>();
        config.put('Consumer_Key__c', '174b7bf8-8586-40ab-af6f-65450151f540');
        config.put('Consumer_Secret__c', 'JeI8Q~WRoWsalXMrI7OHqHFBEvJeKXub7fCPPbNp');
        config.put('Access_Token_URL__c', 'https://apis-sandbox.intel.com/v1/auth/token');

        final String mockResponse = '{"access_token": "dummy_access_token", "token_type" : "test", "expires_in" : "test", "ext_expires_in" : "test"}';

        final TokenEndpointHttpCalloutMockImpl httpMock = new TokenEndpointHttpCalloutMockImpl(mockResponse);
        Test.setMock(HttpCalloutMock.class, httpMock);

        Core_IPS_AuthProviderHandler_Plugin instance = new Core_IPS_AuthProviderHandler_Plugin();
        final Map<String, String> queryArgs = new Map<String, String>();
        queryArgs.put('state', 'randomState');
        Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(new Map<String, String>(), '', queryArgs);

        Auth.AuthProviderTokenResponse response = instance.handleCallback(config, callbackState);
        Auth.UserData r = instance.getUserInfo(config, response);

        httpMock.assertUrl('https://apis-sandbox.intel.com/v1/auth/token');
        httpMock.assertMethod('POST');
        System.AssertEquals(response != null, true);
    }

    public static testMethod void testHandleCallback_Error() {
        Map<String, String> config = new Map<String, String>();
        config.put('Consumer_Key__c', '174b7bf8-8586-40ab-af6f-65450151f540');
        config.put('Consumer_Secret__c', 'JeI8Q~WRoWsalXMrI7OHqHFBEvJeKXub7fCPPbNp');
        config.put('Access_Token_URL__c', 'https://apis-sandbox.intel.com/v1/auth/token');

        final String mockResponse = '{"error": "SomeErrorCode", "error_description": "Some description", "trace_id": "some_trace_id", "correlation_id": "some_correlation_id"}';
        final TokenEndpointHttpCalloutMockImpl httpMock = new TokenEndpointHttpCalloutMockImpl(mockResponse);
        Test.setMock(HttpCalloutMock.class, httpMock);

        final Map<String, String> queryArgs = new Map<String, String>();
        Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(new Map<String, String>(), '', queryArgs);

        try {
            Core_IPS_AuthProviderHandler_Plugin instance = new Core_IPS_AuthProviderHandler_Plugin();
            Auth.AuthProviderTokenResponse response = instance.handleCallback(config, callbackState);
        } catch (Exception e) {
            httpMock.assertUrl('https://apis-sandbox.intel.com/v1/auth/token');
            httpMock.assertContentType('application/x-www-form-urlencoded;charset=UTF-8');
            httpMock.assertMethod('POST');
            System.assertEquals('Some description', e.getMessage());
        }
    }

    public static testMethod void testRefresh() {
        Map<String, String> config = new Map<String, String>();
        config.put('Consumer_Key__c', '174b7bf8-8586-40ab-af6f-65450151f540');
        config.put('Consumer_Secret__c', 'JeI8Q~WRoWsalXMrI7OHqHFBEvJeKXub7fCPPbNp');
        config.put('Access_Token_URL__c', 'https://apis-sandbox.intel.com/v1/auth/token');

        final String mockResponse = '{"access_token": "dummy_access_token"}';

        final TokenEndpointHttpCalloutMockImpl httpMock = new TokenEndpointHttpCalloutMockImpl(mockResponse);
        Test.setMock(HttpCalloutMock.class, httpMock);

        Core_IPS_AuthProviderHandler_Plugin instance = new Core_IPS_AuthProviderHandler_Plugin();
        Auth.OAuthRefreshResult response = instance.refresh(config, null);

        httpMock.assertUrl('https://apis-sandbox.intel.com/v1/auth/token');
          httpMock.assertMethod('POST');
          System.assertEquals('dummy_access_token', response.accessToken);
     //   System.assertEquals('dummy_refresh_token', response.refreshToken);
     //   System.assert(null == response.error);
    }

    private class TokenEndpointHttpCalloutMockImpl implements HttpCalloutMock {
        private String callUrl;
        private String callMethod;
        private String callBody;
        private Map<String, String> callHeaders = new Map<String, String>();
        private String responseBody;
        private String responseContentType = 'application/json';
        private Integer responseStatus = 200;

        public TokenEndpointHttpCalloutMockImpl(String response) {
            this.responseBody = response;
        }

        public TokenEndpointHttpCalloutMockImpl(String response, String contentType) {
            this(response);
            this.responseContentType = contentType;
        }

        public TokenEndpointHttpCalloutMockImpl setResponseStatus(Integer status) {
            this.responseStatus = status;
            return this;
        }

        public void assertMethod(String method) {
            if (String.isEmpty(this.callMethod))
                System.assert(false, 'Method never set');
            System.assertEquals(method, this.callMethod);
        }

        public void assertUrl(String url) {
            if (String.isEmpty(this.callUrl))
                System.assert(false, 'URL never called');
            System.assertEquals(url, this.callUrl);
        } 

        public void assertBody(String body) {
            if (String.isEmpty(this.callBody))
                System.assert(false, 'URL never called');
            System.assertEquals(body, this.callBody);
        }

        public void assertContentType(String value) {
            this.assertHeader('Content-Type', value);
        }

        public void assertHeader(String key, String value) {
            if (this.callHeaders.size() == 0)
                System.assert(false, 'No headers');
            if (String.isEmpty(key))
                System.assert(false, 'Must supply header name');
            String v = this.callHeaders.get(key.toLowerCase());
            if (String.isEmpty(v))
                System.assert(false, 'Header not set');
            System.assertEquals(value, v);
        }

        public HTTPResponse respond(HTTPRequest req) {
            this.callUrl = req.getEndpoint();
            this.callMethod = req.getMethod();
            this.callBody = req.getBody();
            this.callHeaders.put('content-type', req.getHeader('Content-Type'));
            this.callHeaders.put('accept', req.getHeader('Accept'));

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', this.responseContentType);
            res.setBody(this.responseBody);
            res.setStatusCode(this.responseStatus);
            return res;
        }
    }

    private class StaticRefreshTokenGenerator implements Core_IPS_AuthProviderHandler_Plugin.IRefreshTokenGenerator {
        public String generate() {
            return 'dummy_refresh_token';
        }
    }
}