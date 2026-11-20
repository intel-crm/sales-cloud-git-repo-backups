@isTest
public class PMP_HTTPCallRequestMock_test implements HttpCalloutMock {
		protected Integer code;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;
    
    	public PMP_HTTPCallRequestMock_test()
        {
            this.code = 200;
			this.status = 'Complete';
			this.bodyAsBlob = null;
			this.bodyAsString = '[{"Name": "sForceTest1"}]';
			this.responseHeaders = null;
        }

	
	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}