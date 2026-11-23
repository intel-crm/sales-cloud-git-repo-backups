@isTest
global class Core_IPS_APIGEE_Utility_Test {
    public static TestMethod void testApigeeAPI(){
        /*Apex SFDX deployment test 15&17122025*/
        Core_IPS_APIGEE_Custom_Settings__c customSetting = new Core_IPS_APIGEE_Custom_Settings__c();
        customSetting.Name = 'Core_IPS_MyIntel_Integration';
        customSetting.MyIntel_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a8225308';
        customSetting.MyIntel_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.MyIntel_Endpoint_URL__c = 'https://apis.intel.com/m2r/intel-customers/v1/profiles';
        customSetting.MyIntel_GrantType__c = 'client_credentials';
        customSetting.MyIntel_Integration_Class_Name__c = 'Core_IPS_MyIntel_3';
        customSetting.MyIntel_Token_Endpoint_URL__c = 'https://apis-stage.intel.com/v1/auth/token';
        insert customSetting;
        Test.setMock(HttpCalloutMock.class, new Core_IPS_myIntelHttpCalloutMock());
        Test.startTest();
        String jsonString = Core_IPS_APIGEE_Utility.generateAccessToken('Core_IPS_MyIntel_Integration');
        Test.stopTest();
        System.assert(jsonString!=null);
    }
    public static TestMethod void testApigeeNegetive(){
        Core_IPS_APIGEE_Custom_Settings__c customSetting = new Core_IPS_APIGEE_Custom_Settings__c();
        customSetting.Name = 'Core_IPS_MyIntel_Integration';
        customSetting.MyIntel_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a8225308';
        customSetting.MyIntel_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.MyIntel_Endpoint_URL__c = 'https://apis.intel.com/m2r/intel-customers/v1/profiles';
        customSetting.MyIntel_GrantType__c = 'client_credentials';
        customSetting.MyIntel_Integration_Class_Name__c = 'Core_IPS_MyIntel_3';
        customSetting.MyIntel_Token_Endpoint_URL__c = 'https://apis-stage.intel.com/v1/auth/t';
        insert customSetting;
      
        Test.setMock(HttpCalloutMock.class, new Core_IPS_myIntelHttpCalloutMock());
        Test.startTest();
        String jsonString1 = Core_IPS_APIGEE_Utility.generateAccessToken('Core_IPS_MyIntel_Integration');
        Test.stopTest();
        System.assert(jsonString1==null);
    }
    
     public static TestMethod void testApigeeAPI1(){
         Core_IPS_System_Credentails_Apigee__c customSetting = new Core_IPS_System_Credentails_Apigee__c();
        customSetting.Name = 'Core_IPS_Case_Promote';
        customSetting.Core_IPS_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a822530833';
        customSetting.Core_IPS_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.Core_IPS_EndPointURL__c = 'https://apis.intel.com/m2r/ips/cases/v1/activities?action=promote';
        customSetting.Core_IPS_GrantType__c = 'cli ent_credentials';
        customSetting.Core_IPS_Authorization_URL__c = 'https://apis-stage.intel.com/v1/auth/token';
        insert customSetting;
        Test.setMock(HttpCalloutMock.class, new Core_IPS_myIntelHttpCalloutMock());
        Test.startTest();
        String jsonString = Core_IPS_APIGEE_Utility.generateAccessToken1('Core_IPS_Case_Promote');
        Test.stopTest();
        System.assert(jsonString!=null);
    }
        public static TestMethod void testApigeeNegetive1(){
        Core_IPS_System_Credentails_Apigee__c customSetting = new Core_IPS_System_Credentails_Apigee__c();
        customSetting.Name = 'Core_IPS_Case_Promote';
        customSetting.Core_IPS_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a822530833';
        customSetting.Core_IPS_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.Core_IPS_EndPointURL__c = 'https://apis.intel.com/m2r/ips/cases/v1/activities?action=promote';
        customSetting.Core_IPS_GrantType__c = 'client_credentials';
        customSetting.Core_IPS_Authorization_URL__c = 'https://apis-stage.intel.com/v1/auth/t';
        insert customSetting;
        Test.setMock(HttpCalloutMock.class, new Core_IPS_myIntelHttpCalloutMock());
        Test.startTest();
        String jsonString = Core_IPS_APIGEE_Utility.generateAccessToken1('Core_IPS_Case_Promote');
        Test.stopTest();
        System.assert(jsonString==null);
    }
	 global class Core_IPS_myIntelHttpCalloutMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            String tokenstring = 'eyJ0eXAi';
            if(request.getEndpoint() == 'https://apis-stage.intel.com/v1/auth/token'){
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"access_token": "tokenstring", "token_type": "Bearer","expires_in": "3599", "ext_expires_in": "3599"}');
            	response.setStatusCode(200);
            }
            return response;
        }
    }

}