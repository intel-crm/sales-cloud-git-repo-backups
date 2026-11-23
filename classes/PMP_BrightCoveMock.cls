@isTest
global class PMP_BrightCoveMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Simulate different scenarios based on the request URL or method
        if (req.getMethod() == 'GET') {
            // Simulate a successful GET response for BrightCove API
            res.setStatusCode(200);
            res.setBody('{"state": "finished", "thumbnail": {"src": "exampleThumbnailURL"}}');
        } else if (req.getMethod() == 'DELETE') {
            // Simulate a successful DELETE response for BrightCove API
            res.setStatusCode(204);
        } else {
            // Handle other scenarios or errors as needed
            res.setStatusCode(500);
            res.setBody('{"error": "Internal Server Error"}');
        }
        
        return res;
    }
}