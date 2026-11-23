@isTest
global class PMP_getAccessTokenMockTest implements HttpCalloutMock{
      String authorizationHeader='';
     //Implement this interface method
     global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);
        response.setBody('{"name":"testrec","Access_Token":"Aks"}');
        response.setStatusCode(200);
        return response; 
    }
}