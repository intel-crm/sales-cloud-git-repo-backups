@isTest
global class Core_RESTAPI_MoveFileMock_Test implements HttpCalloutMock {
    private static final String SFT_APP_NAME = 'IPS_SCFT';
    public boolean returnError = false;
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        if(returnError == false) {
	        res.setBody('{"AppName":"IPS_SCFT","DestinationFileName":"gdsfgjk123456789-c","FileSize":"5242880"}');
        } else {
            res.setBody('{"Message":"An error has occurred."}');
        }
        return res;
    }
}