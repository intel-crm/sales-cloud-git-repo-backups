@isTest
global class PRM_ExternalAPIControllerMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {      
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody('{"access_token":"eyJ0eXAiOiJKV1QiLCJh","expires_in":"3599","ext_expires_in":"3599","token_type":"Bearer"}');
        res.setStatusCode(200);
        return res;
    }
}