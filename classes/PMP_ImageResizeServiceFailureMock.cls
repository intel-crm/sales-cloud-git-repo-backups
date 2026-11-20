@isTest
global class PMP_ImageResizeServiceFailureMock implements HttpCalloutMock {
   
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('Sample FailureResponse');
        response.setStatusCode(100);
        return response; 
    }
}