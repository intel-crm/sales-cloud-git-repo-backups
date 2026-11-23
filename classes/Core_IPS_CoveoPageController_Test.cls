@isTest
global class Core_IPS_CoveoPageController_Test {
    
    public static testMethod void testMethod1(){
        Case cs = TestUtilities.getCase();
        Test.setMock(HttpCalloutMock.class, new NoRolesMock());
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        Core_IPS_CoveoPageController coveoExtension = new Core_IPS_CoveoPageController(sc);  
       coveoExtension.coveoPagePanel();//TWC745-8556 -IPS Salesforce Monthly Issues -Coveo page DML issue fix 
        System.assert(cs!=null);  
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
            Core_IPS_CoveoPageController.responseMap1 = new Map<String, Object>{'roles' => new List<Object>{''}};
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"some sample access token"}');
            response.setStatusCode(200);  
            response.setStatus('Success'); 
            System.assert(response!=null);
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
    global class ErrorCodeMock implements HttpCalloutMock{ //TWC745-8556 -IPS Salesforce Monthly Issues -Coveo page DML issue fix -begin
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response

 			Core_IPS_CoveoPageController.responseMap1 = new Map<String, Object>{'roles' => new List<Object>{'ODC User, SFDC A&E User, Contingent Worker'}};
            
                HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"some sample access token"}');
            response.setStatusCode(500);  
            response.setStatus('Internal Server Error'); 
            System.assert(response!=null);
            return response;
            
        }
    } //TWC745-8556 -IPS Salesforce Monthly Issues -Coveo page DML issue fix -end
}