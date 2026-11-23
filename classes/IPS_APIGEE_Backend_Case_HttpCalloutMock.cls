@isTest
global class IPS_APIGEE_Backend_Case_HttpCalloutMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NQ", "token_type": "Case Comment","expires_in": "3599", "ext_expires_in": "3599"}');
            response.setStatusCode(400);
            return response;
        }

}