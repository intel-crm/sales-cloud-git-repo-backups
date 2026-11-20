/****************************************************************************************************************************************
* Class Name  : Core_MDF_MockHttpResponseGenerator_Test
* Version     : 1.0 
* Created Date: 12/10/2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Shridhar K       12/10/2018                    Core_MDF_MockHttpResponseGenerator class is created to generate fake response for test class.
*****************************************************************************************************************************************/
@isTest
global class Core_MDF_MockHttpNullResponse implements HttpCalloutMock {
    // Implement this interface method
  global HTTPResponse respond(HTTPRequest request) {    
     HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-type', 'application/json');
        String strJSONResponse;

         response.setBody(strJSONResponse);        
         response.setStatusCode(200);
         return response;
    }
}