@isTest
global class Sales_SapIntegrationUtilityCalloutMock implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    public Sales_SapIntegrationUtilityCalloutMock(Integer code,String status){
        this.code=code;
        this.status=status;
    }
    global HTTPResponse respond(HTTPRequest request) {
        if(request.getBody()!=null){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"testToken","expires_in":"3599","OrderResponse":{"SAPOrderDate":20210401,"SAPOrderNum":"0010061433","SAPScheduledDate":20210402,"comment":"Test","OrderNumber":"00004028","Status":"'+status+'"}}');      
            response.setStatusCode(code);
            return response;   
        }
        else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"testToken","expires_in":"3599","Order": "0010060026","Type": "Success","Message": "Sales Order has been canceled successfully"}');      
            response.setStatusCode(code);
            return response; 
        }
        }
    }