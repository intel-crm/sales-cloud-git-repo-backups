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
            return generateAccessTokenResponse();
        } else if (request.getEndpoint().equals(getVideosEndpoint())) {
            return generateVideosEndpointResponse();
        } else if (request.getEndpoint().contains('callout:PMP_MuleSoft_Video_NamedCredentials')) {
            return generateCalloutResponse();
        } else if (request.getEndpoint().contains('ingest_jobs')) {
            return generateIngestJobsResponse();
        } else if (request.getEndpoint().contains('images')) {
            return generateImagesResponse();
        } else if (request.getEndpoint().contains(getBrightCoveVideosEndpoint())) {
            return generateBrightCoveVideosResponse();
        } else {
            return null;
        }
    }

    private HTTPResponse generateAccessTokenResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"access_token":"test_token"}');
        response.setStatusCode(Integer.valueOf(errorCode));
        return response;
    }

    private HTTPResponse generateVideosEndpointResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{ "id": "6302734001001"}');
        response.setStatusCode(Integer.valueOf(errorCode));
        return response;
    }

    private HTTPResponse generateCalloutResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"message":"Request Captured and Processing it"}');
        response.setStatusCode(Integer.valueOf(errorCode));
        return response;
    }

    private HTTPResponse generateIngestJobsResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if (errorCode == '200' && stateCode == 'finished') {
            response.setBody('{ "state": "finished"}');
        } else if (errorCode == '200' && stateCode == 'processing') {
            response.setBody('{ "state": "processing"}');
        } else if (errorCode == '200' && stateCode == 'failed') {
            response.setBody('{ "state": "failed"}');
        } else {
            response.setBody('{ "error_message": "Video Job Id status not found"}');
        }
        response.setStatusCode(Integer.valueOf(errorCode));
        return response;
    }

    private HTTPResponse generateImagesResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"thumbnail": {"src": "https://cf-images.us-east-1.prod.boltdns.net/v1/jit/6298977448001/bdd27b50-d632-4d73-ac96-44bb8686f3c7/main/160x90/19s29ms/match/image.jpg"}}');
        response.setStatusCode(Integer.valueOf(errorCode));
        return response;
    }

    private HTTPResponse generateBrightCoveVideosResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(Integer.valueOf(errorCode));
        return response;
    }

    private String getVideosEndpoint() {
        return String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL')) + String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID')) + '/videos';
    }

    private String getBrightCoveVideosEndpoint() {
        return String.valueOf(PMP_Utility.getValue('BrightCove_Video_API_Endpoint_URL')) + String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID')) + '/videos/';
    }

}