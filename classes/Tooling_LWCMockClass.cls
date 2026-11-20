@IsTest
public class Tooling_LWCMockClass implements HttpCalloutMock {
    
    public boolean isFirstCall =true;
  
    public HTTPResponse respond(HTTPRequest req) {
       // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if (isFirstCall) {
            res.setBody('{"records": [' +
                '{"Source": "LWC Source 1", "LightningComponentBundle": {"DeveloperName": "LWCBundle1"}},' +
                '{"Source": "LWC Source 2", "LightningComponentBundle": {"DeveloperName": "LWCBundle2"}}' +
                '], "nextRecordsUrl": "/services/data/v56.0/query/nextpage"}');
            isFirstCall = false;
        } else {
            res.setBody('{"records": [' +
                '{"Source": "LWC Source 3", "LightningComponentBundle": {"DeveloperName": "LWCBundle3"}}' +
                ']}');
        }
        
        res.setStatusCode(200);
        return res;
    }
}