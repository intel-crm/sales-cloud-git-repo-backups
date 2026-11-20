public class Tooling_CustomFieldMockClass implements HttpCalloutMock{
    public boolean isFirstCall =true;
    
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if (isFirstCall) {
            res.setBody('{"records": [{"Id": "001xx0000012345"},{"Id": "001xx0000056789"}], "nextRecordsUrl": "/services/data/v56.0/query/nextpage"}');
            isFirstCall = false;
        } else {
            res.setBody('{"records": [{"Id": "001xx0000012345"},{"Id": "001xx0000056789"}]}');
        }
        
        res.setStatusCode(200);
        return res;
    }
}