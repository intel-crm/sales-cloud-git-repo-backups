@IsTest
public class PMP_APIMultipleCalloutS3BrightcoveTest implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest request) { 
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Authorization', 'authorizationHeader');
            response.setStatusCode(200);
            if (request.getEndpoint().endsWith('access_token')) { 
            response.setBody('{"name":"testreca","Access_Token":"Ajkcs"}');
            } else if (request.getEndpoint().endsWith('videos')) { 
            response.setBody('{"names", "my videos"}');
            } else if (request.getEndpoint().contains('upload-urls')) { 
            response.setBody('{"bucket":"ingestion-upload-pro","object_key":"4090876643001","access_key_id":"ASIA25E","secret_access_key":"se1bnFn","session_toke":"IQoJb3JpZ2lu","signed_url":"https","api_request_url":"Test2"}');
            } else if (request.getEndpoint().endsWith('ingest-requests')) { 
            response.setBody('{"namessfd", "my videos upload"}');
            } 
            return response; 
        } 
}