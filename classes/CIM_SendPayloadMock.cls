global class CIM_SendPayloadMock implements HttpCalloutMock{
	 global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('Request processed at CIM');
        return res;
    }
}