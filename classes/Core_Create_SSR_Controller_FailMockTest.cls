/**************************************************************************************
* Apex Class Name   : Core_Create_SSR_Controller_FailMockTest 
* Created Date      : June, 2023
* Description       : Creates Sales Support Request in DRD system
* Modification Log  :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Pratik Padwal	  : Version 1:  June 27th, 2023  Initial Deployed Version
*************************************************************************************/
@isTest
global class Core_Create_SSR_Controller_FailMockTest implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
      //  response.setBody('{"id":"a15W00000018y0cIAA","success":true,"errors":[]}');
        response.setBody('"Fail"'); 
        response.setStatusCode(401);
        response.setStatus('Fail');
        return response; 
    }
}