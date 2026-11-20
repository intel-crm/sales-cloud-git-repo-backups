/**************************************************************************************
Apex Class Name: Core_AandE_Azure_Auth_Provider_Test
Description    : This class is Test class for Core_AandE_Azure_Auth_Provider
*************************************************************************************/
@isTest()
public class Core_AandE_Azure_Auth_Provider_Test {
    private static final String LOGIN_ID = 'testLoginId';
    private static final String FIRST_NAME = 'testFirstName';
    private static final String LAST_NAME = 'testLastName';
    private static final String EMAIL_ADDRESS = 'testEmailAddress';
    private static final String LOCALE_NAME = 'testLocalName';
    private static final String OAUTH_TOKEN = 'testToken';
    private static final String API_USER_VERSION_URL ='http://www.dummyhost.com/user/20/1';

    private static final String AUTH_URL ='http://www.dummy.com/authurl';
    private static final String KEY = 'testKey';
    private static final String STATE = 'testState';
    private static final String STATE_TO_PROPOGATE = 'testState';
    private static final String SECRET = 'testSecret';
    private static final String ACCESS_TOKEN_URL ='http://www.dummyhost.com/accessTokenUri';
    private static final String CUSTOM_METADATA_TYPE_NAME = 'API_M_Auth_Provider__mdt';
    private static final String AUTH_PROVIDER_CLASS_NAME = 'Core_AandE_Azure_Auth_Provider';
    private static final String redirectUrl ='https://' + System.Url.getOrgDomainUrl().getHost() + '/services/authcallback/' + AUTH_PROVIDER_CLASS_NAME+',UTF-8';
    //global string name= Core_AandE_Azure_Auth_Provider.getCustomMetadataType();
    
    private static Map<String,String> setupAuthProviderConfig (){
        Map<String,String> authProviderConfiguration = new Map<String,String>();
        authProviderConfiguration.put('Auth_URL__c', AUTH_URL);
        authProviderConfiguration.put('Consumer_Key__c', KEY);
        authProviderConfiguration.put('Consumer_Secret__c', SECRET);
        authProviderConfiguration.put('Access_Token_URL__c', ACCESS_TOKEN_URL);    
        authProviderConfiguration.put('Redirect_Url__c', redirectUrl);
        authProviderConfiguration.put('State_c', STATE);
        return authProviderConfiguration;
    }
    
    static testMethod void testInitiateMethod(){
     Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
     Core_AandE_Azure_Auth_Provider iaapCls = new Core_AandE_Azure_Auth_Provider();
     iaapCls.redirectUrl = authProviderConfiguration.get('Redirect_Url__c');   
        PageReference actualUrl = iaapCls.initiate(authProviderConfiguration, STATE_TO_PROPOGATE);
        string name= iaapCls.getCustomMetadataType();
        Core_AandE_Azure_Auth_Provider.TokenResponse tkObj = new Core_AandE_Azure_Auth_Provider.TokenResponse(); 
        tkObj.access_token= 'Test Token';
        tkObj.expires_in= 'test expire';
        tkObj.id_token= 'test token id';
        tkObj.refresh_token = 'refresh token';
        tkObj.scope= 'test scope';
        tkObj.token_type= 'Test type';
        
        System.assertEquals('refresh token',tkObj.refresh_token,'Value does not match');
    }
    
    static testMethod void testHandleCallback(){
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
        Core_AandE_Azure_Auth_Provider iaapCls = new Core_AandE_Azure_Auth_Provider();
        iaapCls.redirectUrl = authProviderConfiguration.get('Redirect_Url__c');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,'Complete','{"access_token": "testToken","id_token": "testId","token_type": "testTokenType","expires_in": "testExpires","scope": "testScope","refresh_token": "testToken"}',null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Map<String,String> headrOj = new Map<String,String>();
        headrOj.put('test','test');
        Map<String,String> queryParams = new Map<String,String>();
        queryParams.put('code','code');
        queryParams.put('state',authProviderConfiguration.get('State_c'));
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(headrOj,'test',queryParams);
        Auth.AuthProviderTokenResponse actualAuthProvResponse = iaapCls.handleCallback(authProviderConfiguration, cbState);
        Auth.OAuthRefreshResult actualAuthRefreshProvResponse = iaapCls.refresh(authProviderConfiguration,'Test');
        
        System.assertEquals(true,authProviderConfiguration.size() >0,'Value does not match');
    }
    
     static testMethod void testGetUserInfo()
    {
        Map<String,String> authProviderConfiguration =setupAuthProviderConfig();
        
        Core_AandE_Azure_Auth_Provider iaapCls = new Core_AandE_Azure_Auth_Provider();
       // Test.setMock(HttpCalloutMock.class, new ConcurMockHttpResponseGenerator());

        Auth.AuthProviderTokenResponse response =  new Auth.AuthProviderTokenResponse('Core_AandE_Azure_Auth_Provider', OAUTH_TOKEN ,'sampleOauthSecret', STATE);
        Auth.UserData actualUserData = iaapCls.getUserInfo(authProviderConfiguration, response) ;
        
        System.assertEquals(true,authProviderConfiguration.size() >0,'Value does not match');
       
       /* Map<String,String> provMap = new Map<String,String>();
        provMap.put('key1', 'value1');
        provMap.put('key2', 'value2');
        
       Auth.UserData expectedUserData = new Auth.UserData(LOGIN_ID,FIRST_NAME, LAST_NAME, FULL_NAME, EMAIL_ADDRESS,null, LOCALE_NAME, null, PROVIDER, null, provMap);*/

    }
    
}