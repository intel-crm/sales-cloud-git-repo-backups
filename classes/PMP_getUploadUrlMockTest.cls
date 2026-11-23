@isTest
global class PMP_getUploadUrlMockTest implements HttpCalloutMock{
    //Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        //Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"bucket":"ingestion-upload-production","object_key":"4090","access_key_id":"ASIA25ESR","secret_access_key":"h45w2C","session_token":"IQoJb3","signed_url":"hD","api_request_url":"amaz"}');
        response.setStatusCode(200);
        return response; 
    }
}