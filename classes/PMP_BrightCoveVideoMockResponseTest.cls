/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveVideoMockResponseTest 
* Version     : 1.0 
* Created Date: 04/04/2022   
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal            04/04/2022                   This is used to create HTTP Callout Mock responses for brightcove video integration
* ****************************************************************************************************************************************/
@isTest
global class PMP_BrightCoveVideoMockResponseTest implements HttpCalloutMock {
    global String errorCode;
    global String stateCode;
    global PMP_BrightCoveVideoMockResponseTest(String errorCode , String stateCode)
    {
        this.errorCode=errorCode;
        this.stateCode=stateCode;
    }
    global HTTPResponse respond(HTTPRequest request) {
        if (request.getEndpoint().contains('access_token')) {  
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"test_token"}');
            response.setStatusCode(Integer.ValueOf(errorCode));
            return response; 
        }
        else if (request.getEndpoint()==String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos') {   
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "id": "6302734001001"}'); 
            if(errorCode=='201')
            {
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            else
            {
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            return response;
        }
        else if (request.getEndpoint().contains('callout:PMP_MuleSoft_Video_NamedCredentials')){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"message":"Request Captured and Processing it"}');
            response.setStatusCode(Integer.ValueOf(errorCode));
            return response;
        }
        else if (request.getEndpoint().contains('ingest_jobs')){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if(errorCode=='200' && stateCode=='finished')
            {
                response.setBody('{ "state": "finished"}');
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            else if(errorCode=='200' && stateCode=='processing')
            {
                response.setBody('{ "state": "processing"}');
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            else if(errorCode=='200' && stateCode=='failed')
            {
                response.setBody('{ "state": "failed"}');
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            else
            {
                response.setBody('{ "error_message": "Video Job Id status not found"}');
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            return response;
        }
        else if (request.getEndpoint().contains('images')){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"thumbnail": {"src": "https://cf-images.us-east-1.prod.boltdns.net/v1/jit/6298977448001/bdd27b50-d632-4d73-ac96-44bb8686f3c7/main/160x90/19s29ms/match/image.jpg"}}');
            if(errorCode=='200')
            {
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            else
            {
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            return response;
        }
        else if (request.getEndpoint().contains(String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL'))+String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'))+'/videos/')){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if(errorCode=='204')
            {
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            else
            {
                response.setStatusCode(Integer.ValueOf(errorCode));
            }
            return response;
        }
        else
        {
            return null;
        }
    }
}