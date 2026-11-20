@isTest(SeeAllData=false)
    global class TestHttpCalloutMock implements HttpCalloutMock {
       
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ \"status\": \"success\", \"result\": [ { \"product_no\": \"NPP155065693944693206\", \"status\": \"CREATED\" } ] }');
            response.setStatusCode(200);
            return response; 
        }
    }