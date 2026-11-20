@isTest
global class PMP_ImageResizeServiceSuccessMock implements HttpCalloutMock {
   
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('Sample Success Response');
        response.setStatusCode(200);
        return response; 
    }
}