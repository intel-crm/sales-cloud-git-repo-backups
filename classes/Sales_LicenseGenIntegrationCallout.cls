@isTest
global class Sales_LicenseGenIntegrationCallout implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    public Sales_LicenseGenIntegrationCallout(Integer code,String status){
        this.code=code;
        this.status=status;
    }
    global HTTPResponse respond(HTTPRequest request) {
        if(request.getBody()!=null){
            String fullJson = '\"'+'Success'+'\"';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(fullJson);      
            response.setStatusCode(code);
            return response;   
        }
        else{
            String fullJson = '\"'+'Failure'+'\"';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(fullJson);      
            response.setStatusCode(code);
            return response; 
        }
    }
}