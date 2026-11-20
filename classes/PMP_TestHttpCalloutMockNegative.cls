@isTest(SeeAllData=false)
global class PMP_TestHttpCalloutMockNegative implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{ \"success\" : \"false\", \"code\" : \"405\", \"errors\" : [ \"Bad Request\" ] }');
        response.setStatusCode(500);
        return response; 
    }
}