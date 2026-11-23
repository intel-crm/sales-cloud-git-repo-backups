global class Apigee_SendPyloadMock implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('Request processed at Apigee');
        return res;
    }
}