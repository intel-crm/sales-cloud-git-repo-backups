global class core_S2S_CaseExternalFeedMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Id":"x017j00000H8GIkAAN","ExternalId":"5007j00000H8GIkAAN"}');
        res.setStatusCode(200);
        return res;
    }
}