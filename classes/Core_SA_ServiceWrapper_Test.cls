@isTest (SeeAllData=true)
public class Core_SA_ServiceWrapper_Test {
    public static final string SUCCESS='success';
    public static final string FAIL='fail';
    public static final string STATUS='status';
    public static final string CONTENT_TYPE='Content-Type';
    public static final string CONTENT_TYPE_JSON='application/json;charset=UTF-8';
    public static final string API_KEY='API_KEY';
    public static final string FALSE_VALUE='false';   
    public static final Integer TIME_OUT=60000; 
    public static final string METHOD='GET'; 
 
    
    @isTest static  void testGetTop3AssistsCallout() {
        String cim_id = '11773105';
        String user_id = '10526157';
        String uri;		
        Core_SA_Top3AssistsDefination TotalAssists;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_SA_ServiceWrapper_MockResponse());
        
        // Call method to test
		//Parse JSON Objec

        Core_SA_Top3AssistsDefination Top3 = Core_SA_ServiceWrapper.getTop3Assists(cim_id, user_id);
		//System.assertEquals(Top3.show, true);
		//System.assertEquals(Top3.total_count, 3);
		//System.assertEquals(Top3.AssistDetails.size(), 3); 
        Test.stopTest();
    }
 
    @isTest static  void testGetTop3AssistsCalloutNew() {
        String cim_id = '1177310512';
        String user_id = '10526156';
        String uri;
        Core_SA_Top3AssistsDefination TotalAssists;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_SA_ServiceWrapper_MockResponse2());
        // Call method to test
		//Parse JSON Objec

        Core_SA_Top3AssistsDefination Top3 = Core_SA_ServiceWrapper.getTop3Assists(cim_id, user_id);
		//System.assertEquals(Top3.show, true);
		//System.assertEquals(Top3.total_count, 3);
		//System.assertEquals(Top3.AssistDetails.size(), 3); 
        Test.stopTest();
    }
    @isTest static  void testGetUnreadAssistsCallout() {
        String cim_id = '11773105';
        String user_id = '10526157';
        String uri;
        Core_SA_UnreadAssistsDefination TotalAssists;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_SA_ServiceWrapper_MockResponse());
        
        // Call method to test
		//Parse JSON Objec

        TotalAssists = Core_SA_ServiceWrapper.getNewAssists(cim_id, user_id);
        system.assertEquals(TotalAssists.show, true);
        system.assertEquals(TotalAssists.content, 'You Have 31 Unread Assists!');
       // system.assertEquals('You Have 3 Unread Assists!'+ TotalAssists.content);
        Test.stopTest();
    }
    
     @isTest static  void testGetUnreadAssistsCalloutNew() {
        String cim_id = '11773105';
        String user_id = '10526157';
        String uri;
        Core_SA_UnreadAssistsDefination TotalAssists;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_SA_ServiceWrapper_MockResponse2());
        
        // Call method to test
		//Parse JSON Objec

        TotalAssists = Core_SA_ServiceWrapper.getNewAssists(cim_id, user_id);
        system.assertEquals(TotalAssists.show, false);
       // system.assertEquals(TotalAssists.content, 'You Have 31 Unread Assists!');
       // system.assertEquals('You Have 3 Unread Assists!'+ TotalAssists.content);
        Test.stopTest();
    }
    
    @isTest static  void testGetSessionData() {
        
        String cim_id = '';
        String user_id = '10526157';
        String uri;
        String accountId = '0012D00000H1ZAjQAN';
        //query account object 
        Account acct  = [SELECT Core_Account_ID__c FROM Account  WHERE Core_CIM_ID__c!=:Null LIMIT 1 ];
        //get CIM ID
        
        accountId = acct.Core_Account_ID__c;
          
        Core_SA_UserSessionDefination userSession;
         
        userSession = Core_SA_ServiceWrapper.getUserSessionData(accountId);
		//System.assertEquals('11773105', userSession.cimId, 'Incorrect Cim ID');
     }  
    
    /*
   	@isTest static  void testGetUnreadAssistCallout() {
        String cim_id = '11773105';
        String user_id = '10526157';
        String uri;
		String tempVar = 'gBZkCSanDUd1SoRax1Nxa6xOaV20U527';
        Core_SA_UnreadAssistsDefination TotalAssists;

       	uri = 'callout:Core_SA_ServiceCredentials' + '/unreadassist?cim_id='+cim_id+'&user_id='+user_id;
        
		//Set up new HTTP Request
		Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri);
 		req.setMethod('GET');
		req.setTimeout(60000);
        
		//Get the API-Key value from the custom settings
		Core_SA_API_Key__c apiKey = Core_SA_API_Key__c.getValues(API_KEY); 
		req.setHeader(API_KEY, tempVar );
        
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        mock.setStaticResource('{"content":"You Have 31 Unread Assists!", "show":true}');

        HttpResponse result;
        // Call method to test
		result = Http.send(req);
        
       	//Parse JSON Object
		TotalAssists = Core_SA_UnreadAssistsDefination.parse(result.getBody());
        
        // Verify mock response is not null
        System.assertNotEquals(null,result, 'The callout returned a null response.');
        // Verify status code
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200.');
        // Verify content type   
        System.assertEquals('application/json;charset=UTF-8', result.getHeader('Content-Type'), 'The content type value is not expected.');  
		// Verify content body
        System.assertEquals(true, TotalAssists.content.contains('Unread Assists!'), 'The array should only contain 1 items.');          
    }*/
}