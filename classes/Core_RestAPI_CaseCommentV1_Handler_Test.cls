@isTest
public class Core_RestAPI_CaseCommentV1_Handler_Test{
    
    private static User commUser  = null;
    private static User adminUser  = null;
    private static User IPSAgentUser = null;
    private static User SalesB2BUser = null;
    private static Case objCase = null;
    
    
    @testSetup 
    public static void setupData(){
        
        Core_RestAPI_TestUtilities.setupCustomSetting();
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
            commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact)];
            IPSAgentUser = [SELECT Name FROM User WHERE Profile.Name= 'IPS Agent' AND isActive = true LIMIT 1];
            SalesB2BUser = [SELECT Name FROM User WHERE Profile.Name= 'Sales Rep-BB' AND isActive = true LIMIT 1];
            List<Case> lstCase = Core_RestAPI_TestUtilities.getListOfCases(10);
            for(Integer i =0;i<lstCase.size()/2;i++){
                Case c = lstCase[i];
               c.OwnerId = commUser.Id;
            }
            for(Integer i =lstCase.size()/2;i<lstCase.size();i++){
                Case c = lstCase[i];
                 c.OwnerId = adminUser.Id;
            }
            insert lstCase;
            List<Core_IPS_Case_Comments__c> lstCaseComments = Core_RestAPI_TestUtilities.getCaseComments(10);
            System.debug('lstCaseComments --->'+lstCaseComments);
            for(Integer i=0 ;i< lstCaseComments.size();i++){
                Core_IPS_Case_Comments__c objComments = lstCaseComments[i];
                objComments.Core_IPS_Case__c = lstCase[i].id;
                objComments.Core_IPS_Comment_Author_Type__c = 'Customer';
            }
            insert lstCaseComments;
            
            //System.runAs(IPSAgentUser){
            List<Core_IPS_Case_Comments__c> lstCaseCommentsIPSAgent= Core_RestAPI_TestUtilities.getCaseComments(10);
            System.debug('lstCaseComments --->'+lstCaseCommentsIPSAgent);
            for(Integer i=0 ;i< lstCaseCommentsIPSAgent.size();i++){
                Core_IPS_Case_Comments__c objComments = lstCaseCommentsIPSAgent[i];
                objComments.Core_IPS_Comment_Author_Type__c = 'Agent';
                objComments.Core_IPS_Case__c = lstCase[i].id;
            }
            insert lstCaseCommentsIPSAgent;
            //}
            
            //System.runAs(SalesB2BUser){
            List<Core_IPS_Case_Comments__c> lstCaseCommentSales= Core_RestAPI_TestUtilities.getCaseComments(10);
            System.debug('lstCaseCommentSales--->'+lstCaseCommentSales);
            for(Integer i=0 ;i< lstCaseCommentSales.size();i++){
                Core_IPS_Case_Comments__c objComments = lstCaseCommentSales[i];
                objComments.Core_IPS_Case__c = lstCase[i].id;
            }
            insert lstCaseCommentSales;
            //}
            System.debug('commUser.Id--->'+commUser.Id);
            objCase = [Select CaseNumber FROM Case where OwnerId =: commUser.Id Limit 1];
            System.debug('objCase.CaseNumber --->'+objCase.CaseNumber);
            RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            requestObj.resourcePath ='/services/apexrest/v1.0/cases/'+objCase.CaseNumber+'/comments';
            requestObj.requestUri ='/v1.0/cases/'+objCase.CaseNumber+'/comments';
            requestObj.httpMethod = 'GET';
            RestContext.request = requestObj;
            System.debug(' RestContext.request '+RestContext.request);
            
            Core_RestAPI_CaseCommentV1_Handler handler = new Core_RestAPI_CaseCommentV1_Handler(System.now(), 'Core_RestAPI_CaseCommentsV1'); 
            Core_RestAPI_Response finalResponse = null;
            handler.response.successContent = null;
            Boolean exceptionThrown = true;
            try{
                finalResponse = handler.getCaseComments();    
            }catch(Exception e){
                exceptionThrown = false;   
            }
        }
    }
    //This method test the handler methods: getProducts & processrequest
    @isTest public static void test_getComment_Positive(){
        commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact)];
        objCase = [Select CaseNumber FROM Case where OwnerId =: commUser.Id Limit 1];
        System.debug('objCase.CaseNumber --->'+objCase.CaseNumber);
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/'+objCase.CaseNumber+'/comments';
        requestObj.requestUri ='/v1.0/cases/'+objCase.CaseNumber+'/comments';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        System.debug(' RestContext.request '+RestContext.request);
        
        Core_RestAPI_CaseCommentV1_Handler handler = new Core_RestAPI_CaseCommentV1_Handler(System.now(), 'Core_RestAPI_CaseCommentsV1'); 
        Core_RestAPI_Response response = handler.getCaseComments();
        System.assertNotEquals(null, response);
        System.assertEquals(response.code, '200');
    }
    
    
    //Test error case: 
    //1. For any kind of exception handler should not throw raw exception.
    //2. Handler should return the response for any kind of exception
    @isTest public static void test_getComments_Negative(){
        commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact)];
        objCase = [Select CaseNumber FROM Case where OwnerId =: commUser.Id Limit 1];
        System.debug('objCase.CaseNumber --->'+objCase.CaseNumber);
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/'+objCase.CaseNumber+'/comments';
        requestObj.requestUri ='/v1.0/cases/'+objCase.CaseNumber+'/comments';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        System.debug(' RestContext.request '+RestContext.request);
        Core_RestAPI_CaseCommentV1_Handler handler = new Core_RestAPI_CaseCommentV1_Handler(System.now(), 'Core_RestAPI_CaseCommentsV1'); 
        Core_RestAPI_Response finalResponse = null;
        handler.response.successContent = null;
        Boolean exceptionThrown = true;
        try{
            finalResponse = handler.getCaseComments();    
        }catch(Exception e){
            exceptionThrown = false;   
        }
        System.assertNotEquals(null, finalResponse);
        System.assertEquals(true, exceptionThrown);
    }
    
    //Test method - tests the positive cases for the method doValidations.
   
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Positive(){
        commUser = [Select Name FROM User WHERE ContactId IN (Select Id FROM Contact)];
        objCase = [Select CaseNumber FROM Case where OwnerId =: commUser.Id Limit 1];
        System.debug('objCase.CaseNumber --->'+objCase.CaseNumber);
        RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        requestObj.resourcePath ='/services/apexrest/v1.0/cases/'+objCase.CaseNumber+'/comments';
        requestObj.requestUri ='/v1.0/cases/'+objCase.CaseNumber+'/comments';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        System.debug(' RestContext.request '+RestContext.request);
        Core_RestAPI_CaseCommentV1_Handler handler = new Core_RestAPI_CaseCommentV1_Handler(System.now(), 'Core_RestAPI_CaseCommentsV1'); 
        handler.doValidations();
    }
    
    
    
    //Test method - tests the negative cases for the method doValidations, method should not throw any excepctoin with invalid inputs
   
    //NOTE: for now there is no logic in doValidations and the method will be revisited when code gets added to doValidations method
    @isTest public static void test_doValidations_Negative(){
        Boolean exceptionThrown = false;
        try{
            objCase = [Select CaseNumber FROM Case where OwnerId =: commUser.Id Limit 1];
            System.debug('objCase.CaseNumber --->'+objCase.CaseNumber);
            RestRequest requestObj = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            requestObj.resourcePath ='/services/apexrest/v1.0/cases/'+objCase.CaseNumber+'/comments';
            requestObj.requestUri ='/v1.0/cases/'+objCase.CaseNumber+'/comments';
            requestObj.httpMethod = 'GET';
            RestContext.request = requestObj;
            System.debug(' RestContext.request '+RestContext.request);
            Core_RestAPI_CaseCommentV1_Handler handler = new Core_RestAPI_CaseCommentV1_Handler(System.now(), 'Core_RestAPI_CaseCommentsV1'); 
            handler.doValidations();
        }catch(Exception e){
            exceptionThrown = true;   
        }        
        System.assertEquals(true, exceptionThrown);
    } 
}