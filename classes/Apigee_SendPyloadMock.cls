/******************************************************************************************************************************************
Class Name: Apigee_SendPyloadMock
Version     : 1.0
Created Date: 10 OCT 2021
Function    : HTTP Mock class for test class to test http rest callout

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Sankarshana               10/10/2021              Original version
*****************************************************************************************************************************************/
@isTest
global class Apigee_SendPyloadMock implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('Request processed at Apigee');
        return res;
    }
}