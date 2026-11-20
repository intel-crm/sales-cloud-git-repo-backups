/**************************************************************************************************
* Apex Class Name   : Core_TestMockHttpNULLResponseGenerator
* Created Date      : 03 OCT 2014
* Description       : Implementation of method to send a mock response for a specific endpoint and method
* 
* Developer             Date        Description
* -------------------------------------------------------------------------------------------------                 
* Srikant Joshi         10/03/2014  Original Version
**************************************************************************************************/

@isTest
global class Core_TestMockHttpNULLResponseGenerator implements HttpCalloutMock {
    
    /* Implement this interface method
    send a mock response for a specific endpoint and method
    */
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake http response with NULL body
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(NULL);
        res.setStatusCode(200);
        res.setStatus('OK');
        
        //return the response too use it in the test class
        return res;
    }
}