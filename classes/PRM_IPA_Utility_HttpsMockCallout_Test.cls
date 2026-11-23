@isTest
public class PRM_IPA_Utility_HttpsMockCallout_Test implements HttpCalloutMock {
    private String mockResponse;

    public PRM_IPA_Utility_HttpsMockCallout_Test(String mockResponse) {
        this.mockResponse = mockResponse;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockResponse);
        res.setStatusCode(200);
        return res;
    }
}