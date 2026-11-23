@isTest
global class PMP_CreateVideoResponseMockTest {
    //Implement this interface method
       global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"name", "my video"}');
        response.setStatusCode(200);
        return response;
    }

}