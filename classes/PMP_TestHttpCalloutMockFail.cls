@isTest(SeeAllData=false)
    global class PMP_TestHttpCalloutMockFail implements HttpCalloutMock {
       
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ \"status\" : \"fail\", \"message\" : \"Invalid Value in header : category\" }');
            //response.setStatusCode(201); //need to uncomment when retry is implemented
            response.setStatusCode(200);
            return response; 
        }
    }