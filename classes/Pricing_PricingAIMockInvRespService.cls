global class Pricing_PricingAIMockInvRespService implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest req){
        String respJSON = '{"successContent":[],"errorContent":[{"message":"Family: is not supported, for Intel sku: E3-1535MV5.","quoteLineNumber":"Q-95723-010"}]}';
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(respJSON);
        return res;
    }
}