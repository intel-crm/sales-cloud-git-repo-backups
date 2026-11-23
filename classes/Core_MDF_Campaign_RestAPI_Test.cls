@IsTest
private class Core_MDF_Campaign_RestAPI_Test {

    private class CampaignGetMock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        CampaignGetMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            return res;
        }
    }

    private static Campaign createCampaign() {
        Campaign c = new Campaign(
            Name = 'UT Campaign',
            IsActive = true,
            Status = 'In Progress',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(30)
        );
        insert c;
        return c;
    }

    private static void setGetContext(String uri) {
        RestRequest req = new RestRequest();
        req.requestUri = uri;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    private static Map<String, Object> getResponseBodyAsMap() {
        String body = RestContext.response.responseBody == null
            ? '{}'
            : RestContext.response.responseBody.toString();
        return (Map<String, Object>)JSON.deserializeUntyped(body);
    }

    private static String getResponseCode(Map<String, Object> responseBody) {
        if ((Boolean)responseBody.get('isSuccess')) {
            Map<String, Object> successBlock = (Map<String, Object>)responseBody.get('success');
            return successBlock == null ? null : (String)successBlock.get('code');
        }

        Map<String, Object> errorBlock = (Map<String, Object>)responseBody.get('error');
        return errorBlock == null ? null : (String)errorBlock.get('code');
    }

    @IsTest
    static void testGetCampaignDetails_MissingCampaignId_Returns400_7002() {
        setGetContext('/services/apexrest/v1.0/mdf/campaign/');

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(false, (Boolean)res.get('isSuccess'));
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY, getResponseCode(res));
    }

    @IsTest
    static void testGetCampaignDetails_InvalidCampaignId_Returns400_7004() {
        setGetContext('/services/apexrest/v1.0/mdf/campaign/001000000000000AAA');

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(false, (Boolean)res.get('isSuccess'));
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID, getResponseCode(res));
    }

    @IsTest
    static void testGetCampaignDetails_Success_Returns200() {
        Campaign c = createCampaign();
        setGetContext('/services/apexrest/v1.0/mdf/campaign/' + c.Id + '?v=1');

        Map<String, Object> calloutBody = new Map<String, Object>{
            'Id' => c.Id,
            'Name' => 'UT Campaign',
            'Status' => 'In Progress',
            'StartDate' => String.valueOf(Date.today()),
            'EndDate' => String.valueOf(Date.today().addDays(30)),
            'IsActive' => true
        };

        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(200, JSON.serialize(calloutBody)));

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(true, (Boolean)res.get('isSuccess'));
        System.assertEquals(Core_MDF_Campaign_APIConstants.SUCCESS_200, getResponseCode(res));
        System.assertNotEquals(null, res.get('details'));
    }

    @IsTest
    static void testGetCampaignDetails_CalloutFailure_Returns500_7003() {
        Campaign c = createCampaign();
        setGetContext('/services/apexrest/v1.0/mdf/campaign/' + c.Id);

        Test.setMock(HttpCalloutMock.class, new CampaignGetMock(500, '{"message":"downstream error"}'));

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(500, RestContext.response.statusCode);
        System.assertEquals(false, (Boolean)res.get('isSuccess'));
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7003_INTERNAL_SERVER_ERROR, getResponseCode(res));
    }

    @IsTest
    static void testClearConfigCache_NoException() {
        Test.startTest();
        Core_MDF_Campaign_RestAPI.clearConfigCache();
        Test.stopTest();
        System.assertEquals(true, true);
    }

    @IsTest
    static void testGetCampaignDetails_NullRestRequest_Returns400_7002() {
        RestContext.request = null;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY, getResponseCode(res));
    }

    @IsTest
    static void testGetCampaignDetails_NullResponse_AutoInitializes() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/v1.0/mdf/campaign/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = null;

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        System.assertNotEquals(null, RestContext.response);
        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY, getResponseCode(res));
    }

    @IsTest
    static void testGetCampaignDetails_UriWithoutCampaignSegment_Returns400_7002() {
        setGetContext('/services/apexrest/v1.0/mdf/not-campaign/123');

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY, getResponseCode(res));
    }

    @IsTest
    static void testGetCampaignDetails_NullRequestUri_Returns400_7002() {
        RestRequest req = new RestRequest();
        req.requestUri = null;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7002_CAMPAIGN_ID_EMPTY, getResponseCode(res));
    }

    @IsTest
    static void testGetCampaignDetails_MalformedCampaignIdCast_Returns400_7004() {
        setGetContext('/services/apexrest/v1.0/mdf/campaign/not-an-id');

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID, getResponseCode(res));
    }

    @IsTest
    static void testGetCampaignDetails_InvalidCampaignId_TooShort_Returns400_7004() {
        setGetContext('/services/apexrest/v1.0/mdf/campaign/701123');

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(false, (Boolean)res.get('isSuccess'));
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID, getResponseCode(res));
    }

    @IsTest
    static void testGetCampaignDetails_InvalidCampaignId_InvalidCharacters_Returns400_7004() {
        setGetContext('/services/apexrest/v1.0/mdf/campaign/70100000000000!AAA');

        Test.startTest();
        Core_MDF_Campaign_RestAPI.getCampaignDetails();
        Test.stopTest();

        Map<String, Object> res = getResponseBodyAsMap();
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(false, (Boolean)res.get('isSuccess'));
        System.assertEquals(Core_MDF_Campaign_APIConstants.CODE_7004_INVALID_CAMPAIGN_ID, getResponseCode(res));
    }
}