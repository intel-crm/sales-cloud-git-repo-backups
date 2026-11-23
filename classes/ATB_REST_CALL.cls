public class ATB_REST_CALL {
    
    //@future (callout=true)
    public static void getToken() {
        
        HttpRequest httpReq = new  HttpRequest();
        httpReq.setEndpoint('https://apis-sandbox.intel.com/v1/auth/token');
        //MediaType mt = MediaType.parse('application/x-www-form-urlencoded');
        httpReq.setMethod( 'POST' );
        httpReq.setHeader('content-type', 'application/x-www-form-urlencoded');
        
        //string gType = EncodingUtil.urlEncode('client_credentials','UTF-8');
        String payLoad = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode('818cac18-55ab-402d-9cb3-5e0960415e3','UTF-8') +'&client_secret=' + EncodingUtil.urlEncode('fJsrggS..Da.fl4RZ.9U1F0Pkyy62r701V', 'UTF-8');
        system.debug('payload- '+payload);       
        httpReq.setBody(payLoad);
        HttpResponse response = new Http().send(httpReq);
        //system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
        if(response.getStatusCode() == 200 ) {
            system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
            //return 'token';
        }
        if(response.getStatusCode() == 401) {
            system.debug('response- '+response.getBody());
        }
    }
    
}