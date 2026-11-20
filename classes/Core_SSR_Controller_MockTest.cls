/**************************************************************************************
* Apex Class Name   : Core_SSR_Controller_MockTest 
* Created Date      : July, 2017
* Description       : Creates Sales Support Request in DRD system
* Modification Log  :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Rangesh Kona	  : Version 1:  Aug 22nd, 2017  Initial Deployed Version
*************************************************************************************/
@isTest
global class Core_SSR_Controller_MockTest implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
      //  response.setBody('{"id":"a15W00000018y0cIAA","success":true,"errors":[]}');
        response.setBody('"DRD_SSR-001"'); 
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }
}