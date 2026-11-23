/**Updated: Implementation of Coveo CRGA changes on IPS portal SBS page-TWC745-9525-Gangadhar**/
@IsTest
private class SampleTokenProviderTest {
    @IsTest
    static void getHeadlessConfigurationReturnsExpectedConfiguration() {
        Core_IPS_Coveo_TokenGenerator__c tokenGeneratorConfig =
            new Core_IPS_Coveo_TokenGenerator__c(
                Name = 'Core_IPS_Coveo',
                Core_IPS_Coveo_Token__c = 'Bearer test-token',
                Core_IPS_CoveoEndpoint__c = 'https://example.org/rest/search/v2/token'
            );
        insert tokenGeneratorConfig;

        User testUser = new User(
            LastName = 'TokenProviderTest',
            Alias = 'tokentst',
            Email = 'tokenprovider@example.com',
            Username = 'tokenprovider' + Crypto.getRandomLong() + '@example.com',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert testUser;

        Test.setMock(HttpCalloutMock.class, new TokenResponseMock());

        Test.startTest();
        String configurationJson;
        System.runAs(testUser) {
            configurationJson = SampleTokenProvider.getHeadlessConfiguration();
        }
        Test.stopTest();

        Map<String, Object> configuration =
            (Map<String, Object>) JSON.deserializeUntyped(configurationJson);
        String expectedOrganizationId = 'intelcorporationnonproduction2ybdyblf7';
        System.assertEquals(expectedOrganizationId, configuration.get('organizationId'));
        System.assertEquals('mock-coveo-token', configuration.get('accessToken'));

        Map<String, Object> endpoints =
            (Map<String, Object>) configuration.get('organizationEndpoints');
        System.assertEquals(3, endpoints.size());
        System.assertEquals(
            'https://' + expectedOrganizationId + '.org.coveo.com',
            endpoints.get('search')
        );
        System.assertEquals(
            'https://' + expectedOrganizationId + '.analytics.org.coveo.com',
            endpoints.get('analytics')
        );
        System.assertEquals(
            'https://' + expectedOrganizationId + '.platform.org.coveo.com',
            endpoints.get('platform')
        );
    }

    private class TokenResponseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"token":"mock-coveo-token"}');
            return response;
        }
    }
}