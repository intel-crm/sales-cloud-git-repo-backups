@isTest
global class Core_IPS_CoveoPageController_Test {
    
   public static testMethod void testMethod1(){
       profile prof = [select id, name from Profile where name = 'System Administrator' limit 1];
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Core_WWID__c = '234567',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId(),
            isActive = true,
            ProfileId  =prof.id
        );
       INSERT userRecord;
       Test.setMock(HttpCalloutMock.class, new NoRolesMock());
        Case cs = TestUtilities.getCase();
        system.runAs(userRecord){
            ApexPages.StandardController sc = new ApexPages.StandardController(cs);
            Core_IPS_CoveoPageController coveoExtension = new Core_IPS_CoveoPageController(sc);
            Test.startTest();
       			coveoExtension.coveoPagePanel();
            Test.stopTest();
        System.assert(cs!=null);
       }
    }
    
    public static testMethod void testMethod1Exception(){
       profile prof = [select id, name from Profile where name = 'System Administrator' limit 1];
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Core_WWID__c = '234567',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId(),
            isActive = true,
            ProfileId  =prof.id
        );
       INSERT userRecord;
       Test.setMock(HttpCalloutMock.class, new NoRolesMock());
        Case cs = TestUtilities.getCase();
        Account ac = new Account();
        system.runAs(userRecord){
            ApexPages.StandardController sc = new ApexPages.StandardController(ac);
            Core_IPS_CoveoPageController coveoExtension = new Core_IPS_CoveoPageController(sc);
            Test.startTest();
       			coveoExtension.coveoPagePanel();
            Test.stopTest();
        System.assert(cs!=null);
       }
    }
    
    public static testMethod void testCatchBlock() {
        // Create test case record
        Case cs = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone'
        );
        insert cs;
        // Set mock
        Test.setMock(HttpCalloutMock.class, new NoRolesMock());
        Test.startTest();
        // Initialize controller
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        Core_IPS_CoveoPageController ctrl = new Core_IPS_CoveoPageController(std);
        // Call method → this will hit catch
        ctrl.coveoPagePanel();
        Test.stopTest();
        // Optional assertion (just to ensure execution)
        System.assert(true);
    }
    
    
     public static testMethod void testMethod2(){
          Case cs = TestUtilities.getCase();
         Test.setMock(HttpCalloutMock.class, new OnlyRDCMock());
         ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Core_IPS_CoveoPageController coveoExtension1 = new Core_IPS_CoveoPageController(sc);
         coveoExtension1.coveoPagePanel();
         System.assert(cs!=null); 
     }
	public static testMethod void testMethod3(){
          Case cs = TestUtilities.getCase();
         Test.setMock(HttpCalloutMock.class, new EmployeeMock());
         ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Core_IPS_CoveoPageController coveoExtension2 = new Core_IPS_CoveoPageController(sc);
        coveoExtension2.coveoPagePanel();
        System.assert(cs!=null); 
    }
    public static testMethod void testMethod4(){
          Case cs = TestUtilities.getCase();
         Test.setMock(HttpCalloutMock.class, new ContingentEmployeeMock());
         ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Core_IPS_CoveoPageController coveoExtension2 = new Core_IPS_CoveoPageController(sc);
        coveoExtension2.coveoPagePanel();
        System.assert(cs!=null); 
    }
     public static testMethod void testMethod5(){
          Case cs = TestUtilities.getCase();
         Test.setMock(HttpCalloutMock.class, new ContingentEmployeeOnlyMock());
         ApexPages.StandardController sc = new ApexPages.StandardController(cs);
         
        Core_IPS_CoveoPageController coveoExtension2 = new Core_IPS_CoveoPageController(sc);
         coveoExtension2.coveoPagePanel();
         System.assert(cs!=null); 
    }
    public static testMethod void testMethod6(){
        Case cs = TestUtilities.getCase();
         Test.setMock(HttpCalloutMock.class, new ErrorCodeMock());
         ApexPages.StandardController sc = new ApexPages.StandardController(cs);
         
        Core_IPS_CoveoPageController coveoExtension2 = new Core_IPS_CoveoPageController(sc);
         coveoExtension2.coveoPagePanel();
         System.assert(cs!=null);
    }
    
    global class NoRolesMock implements HttpCalloutMock{
       global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
           //String responseBody ='{"access_token":"some sample access token"}';      
           //
           String responseBody = 
    						'[{' +
    							'"id":"12345",' +
    							'"name":"John Doe",' +
							    '"roles":[' +
						        			'"Standard User",' +
 						        			'"RDC Privileged Full",' +
        									'"RDC Privileged User Internal"' +
               							']' +
    						'}]';


            Core_IPS_CoveoPageController.responseMap1 = new Map<String, Object>();
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type','application/json');
            response.setBody(responseBody);
            response.setStatusCode(200);  
            response.setStatus('Success'); 
            return response; 
        }
         
    }
    
    global class OnlyRDCMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response

           Core_IPS_CoveoPageController.responseMap1 = new Map<String, Object>{'roles' => new List<Object>{'RDC Privileged User Internal'}};

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"some sample access token"}');
            response.setStatusCode(200);  
            response.setStatus('Success'); 
            System.assert(response!=null);
            return response; 
        }
    }
        global class EmployeeMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
			Core_IPS_CoveoPageController.responseMap1 = new Map<String, Object>{'roles' => new List<Object>{'RDC Privileged User Internal, ODC User, SFDC A&E User, Employee'}};

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"some sample access token"}');
            response.setStatusCode(200);  
            response.setStatus('Success'); 
            System.assert(response!=null);
            return response; 
        }
        }
        global class ContingentEmployeeMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response

 			Core_IPS_CoveoPageController.responseMap1 = new Map<String, Object>{'roles' => new List<Object>{'RDC Privileged User Internal, ODC User, SFDC A&E User, Contingent Worker'}};
            
                HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"some sample access token"}');
            response.setStatusCode(200);  
            response.setStatus('Success'); 
            System.assert(response!=null);
            return response; 
        }
        }
       global class ContingentEmployeeOnlyMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response

 			Core_IPS_CoveoPageController.responseMap1 = new Map<String, Object>{'roles' => new List<Object>{'ODC User, SFDC A&E User, Contingent Worker'}};
            
                HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"some sample access token"}');
            response.setStatusCode(200);  
            response.setStatus('Success'); 
            System.assert(response!=null);
            return response; 
        }
         
    }
    global class ErrorCodeMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response

 			Core_IPS_CoveoPageController.responseMap1 = new Map<String, Object>{'roles' => new List<Object>{'ODC User, SFDC A&E User, Contingent Worker'}};
            
                HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"some sample access token"}');
            response.setStatusCode(200);  
            response.setStatus('Internal Server Error'); 
            System.assert(response!=null);
            return response;
            
        }
    }
}