/****************************************************************************************************************************************
Class Name  : Core_Integration_CaseList_Rest_Test
Version     : 1.0 
Created Date: 27 Sep 2017
Function    : Test Class for Core_Integration_CaseList_Rest
Team: PopcornApps  
*****************************************************************************************************************************************/
@isTest
private class Core_Integration_CaseList_Rest_Test{//Add Assertions 
    //Positive Scenario
    static testMethod void testGetMethod()
    {
        
        //Create Case
        case c = new case(Type = 'CEP Case',Status = 'Escalated',Origin = 'Email',Subject= 'Test Case');
        insert c;
        
        Test.startTest();     
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();    
        req.httpMethod = 'Get';
        req.addHeader('Content-Type','application/json'); 
        req.requestURI = '/services/apexrest/CaseList';  
        RestContext.request = req;
        RestContext.response = res; 
        Core_Integration_CaseList_REST.getCases();
        Test.stopTest();
    } 
}