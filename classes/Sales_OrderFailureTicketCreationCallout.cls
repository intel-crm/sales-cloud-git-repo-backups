global class Sales_OrderFailureTicketCreationCallout  implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    // Implement this interface method
    public Sales_OrderFailureTicketCreationCallout(Integer code,String status){
        this.code=code;
        this.status=status;
    }
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
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
        
        
        /*CalloutException e = (CalloutException)CalloutException.class.newInstance();
e.setMessage('Unable to tunnel through proxy. Proxy returns /"HTTP/1.1 503 Service Unavailable/"');
throw e;*/
    }
}