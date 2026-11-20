@IsTest
public class Tooling_FindUnsedCustomLabelMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"records": [' +
                    '{"RefMetadataComponentId": "001xx0000012345"},' +
                    '{"RefMetadataComponentId": "001xx0000056789"}' +
                    ']}');
        res.setStatusCode(200);
        return res;
    }
}