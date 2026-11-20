@isTest(SeeAllData=false)
    global class TestHttpCalloutMockFail implements HttpCalloutMock {
       
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ \"status\" : \"fail\", \"message\" : \"Invalid Value in header : category\" }');
            response.setStatusCode(200);
            return response; 
        }
    }