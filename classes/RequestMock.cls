public with sharing class RequestMock implements HttpCalloutMock  {

    protected Map < String, String > responseHeaders;
    protected String bodyAsString, status;
    protected Blob bodyAsBlob;
    protected Integer code;

    //Default Constructor
    public RequestMock(){}

      /*
     * description : Parameter constructor
     * params : Integer code, String status, String body, Map < String, String > responseHeaders
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 02 Nov 2022
     */

    public RequestMock( Integer code, String status, String body, Map < String, String > responseHeaders){
        this.responseHeaders = responseHeaders;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.status = status;
        this.code = code;
    }

     /*
     * description : create mock Request
     * params : HTTPRequest req
     * return : HTTPResponse
     * author and date : ankit1x.sharma@intel.com, 02 Nov 2022
     */

    public HTTPResponse respond(HTTPRequest req){

        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);

        if(bodyAsBlob != null){
            resp.setBodyAsBlob(bodyAsBlob);
        } else {
            resp.setBody(bodyAsString);
        }

        if(responseHeaders != null){
            for(String key: responseHeaders.keySet()){
                resp.setHeader(key, responseHeaders.get(key));
            }
        }

        return resp;
    }
}