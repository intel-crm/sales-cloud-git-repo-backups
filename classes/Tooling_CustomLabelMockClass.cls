@IsTest
public class Tooling_CustomLabelMockClass implements HttpCalloutMock {
    
    public boolean isFirstCall = true;
    
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if (isFirstCall) {
            res.setBody('{"records": [' +
                        '{"Name": "CustomLabel1", "Id": "001xx0000012345"},' +
                        '{"Name": "CustomLabel2", "Id": "001xx0000056789"}' +
                        '], "nextRecordsUrl": "/services/data/v56.0/query/nextpage"}');
            isFirstCall = false;
        } else {
            res.setBody('{"records": [' +
                        '{"Name": "CustomLabel1", "Id": "001xx0000012345"}' +
                        ']}');
        }
        
        res.setStatusCode(200);
        return res;
    }
}