public class Core_RestClient {

    private String url, httpMethod, body, responseBody;
    private Map < String, String > mapOfHeaders;
    private HttpResponse response;
    private HttpRequest request;
    private Http httpInstance;
    private Blob formBlobBody;
    private Integer timeout;

    //default constructor
    public Core_RestClient() {}
    
      /*
     * description : Constructor which receives Endpoint URL, Request Method, Map of Request Headers and Request Body
     * params : String url, String httpMethod, Map < String, String > mapOfHeaders, blob formBlobBody, Integer timeout
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 14 Sep 2022
     */
    public Core_RestClient(String url, String httpMethod, Map < String, String > mapOfHeaders, blob formBlobBody, Integer timeout) {

        this.mapOfHeaders = mapOfHeaders;
        this.formBlobBody = formBlobBody;
        this.httpInstance = new Http();
        this.httpMethod = httpMethod;
        this.timeout = timeout;
        this.url = url;
    }

      /*
     * description : Constructor which receives Endpoint URL, Request Method, Map of Request Headers and Request Body
     * params : String url, String httpMethod, Map < String, String > mapOfHeaders, String body, Integer timeout
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 14 Sep 2022
     */
    public Core_RestClient(String url, String httpMethod, Map < String, String > mapOfHeaders, String body, Integer timeout) {

        this.mapOfHeaders = mapOfHeaders;
        this.httpInstance = new Http();
        this.httpMethod = httpMethod;
        this.timeout = timeout;
        this.body = body;
        this.url = url;
    }

    
     /*
     * description : This method creates the request, make the Http Request and get the Response
     * params : N/A
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 14 Sep 2022
     */
    public HttpResponse invokeAPI() {
        buildRequest();
        sendRequest();
        setResponse();
        return getHttpResponse();
    }

    // To get the Http Response from callout.
    public HttpResponse getHttpResponse() {
        return response;
    }

    // To get the response body from callout.
    public String getHttpResponseBody() {
        return responseBody;
    }

    // To get the status of the request made.
    public String getHttpResponseStatus() {
        return response.getStatus();
    }

    // To get the status code of the request made.
    public Integer getHttpResponseStatusCode() {
        return response.getStatusCode();
    }

    // To get the status code of the request made.
    public String getHttpResponseHeader() {
        return response.getHeader('Location');
    }

    /*
     * description : This method is used to create HTTP Request with URL, Header and Body.
     * params : N/A
     * return : N/A
     * author and date : ankit1x.sharma@intel.com, 14 Sep 2022
     */
    private void buildRequest() {
        request = new HttpRequest();
        request.setMethod(httpMethod);
        request.setEndpoint(url);

        setRequestHeaders();
        setRequestBody();
        setRequestBlobFormBody();
        setRequestTimeout();
    }

    // This method is particularly used to set HTTP Header from map of Header.
    private void setRequestHeaders() {
        if (mapOfHeaders != null) {
            for (String headerKey: mapOfHeaders.keySet()) {
                request.setHeader(headerKey, mapOfHeaders.get(headerKey));
            }
        }
    }

    // This method is used to set the Http Request body.
    private void setRequestBody() {
        if (body != null && body != '' && body.length() > 0) {
            request.setBody(body);
        }
    }

    // This method is used to set the Http Request body.
    private void setRequestBlobFormBody() {
        if (formBlobBody != null) {
            request.setBodyAsBlob(formBlobBody);
        }
    }

    // This method is used to set the Http Request body.
    private void setRequestTimeout() {
        if (timeout != null ) {
            request.setTimeout(timeout);
        }
    }

    // This method make callout to the end point URL and set the response from API.
    private void sendRequest() {
        response = new HttpResponse();
        response = httpInstance.send(request);
    }

    // This method is used to get the body of the response from the server.
    private void setResponse() {
        responseBody = response.getBody();
    }

}