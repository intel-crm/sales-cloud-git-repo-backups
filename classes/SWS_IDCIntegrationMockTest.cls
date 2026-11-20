@isTest
global class SWS_IDCIntegrationMockTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"code": "WZWW-4A2S-YJ19","creator": "Test User","created": "2023-09-04T12:31:47Z","start": "2023-09-04T12:31:47Z","expires": "2023-12-03T12:31:47Z","disabled": null,"amount": 0.001,"numUses": 3,"numRedeemed": 3,"redemptions": [{ "code": "WZWW-4A2S-YJ19","cloudAccountId": "097854682559","redeemed": "2032-08-23T11:26:28Z","installed": true}]}');
        res.setStatusCode(200);
        return res;
    }
}