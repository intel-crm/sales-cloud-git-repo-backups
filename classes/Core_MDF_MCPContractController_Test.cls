@IsTest
private class Core_MDF_MCPContractController_Test {
    private class ContractMock implements HttpCalloutMock {
        private Integer responseStatus;
        private Integer notificationStatus;

        ContractMock(Integer responseStatus) {
            this.responseStatus = responseStatus;
            this.notificationStatus = responseStatus;
        }

        ContractMock(Integer responseStatus, Integer notificationStatus) {
            this.responseStatus = responseStatus;
            this.notificationStatus = notificationStatus;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(request.getBody().contains('notifications/initialized')
                ? notificationStatus : responseStatus);
            response.setBody('{"jsonrpc":"2.0","result":{"tools":[]}}');
            if (responseStatus == 200) {
                response.setHeader('mcp-session-id', 'test-session');
            }
            return response;
        }
    }

    @IsTest
    static void unauthorizedResponsesRequireAuthentication() {
        Test.setMock(HttpCalloutMock.class, new ContractMock(401));

        Test.startTest();
        Map<String, Object> initializeResult = MCPContractController.initializeMCPSession();
        Map<String, Object> toolsResult = MCPContractController.getAvailableTools('test-session');
        Map<String, Object> contractResult = MCPContractController.getContractMetadata('test-session', 123, 1);
        Map<String, Object> fullFlowResult = MCPContractController.executeFullContractFlow(123, 1);
        Test.stopTest();

        for (Map<String, Object> result : new List<Map<String, Object>>{
            initializeResult, toolsResult, contractResult, fullFlowResult
        }) {
            System.assertEquals(false, result.get('success'));
            System.assertEquals(true, result.get('requiresAuth'));
            System.assertEquals('Authentication required', result.get('error'));
        }
    }

    @IsTest
    static void otherErrorsDoNotRequireAuthentication() {
        Test.setMock(HttpCalloutMock.class, new ContractMock(403));

        Test.startTest();
        Map<String, Object> initializeResult = MCPContractController.initializeMCPSession();
        Map<String, Object> contractResult = MCPContractController.getContractMetadata('test-session', 123, 1);
        Test.stopTest();

        System.assertEquals(false, initializeResult.get('requiresAuth'));
        System.assertEquals(false, contractResult.get('requiresAuth'));
    }

    @IsTest
    static void validSessionDoesNotRequireAuthentication() {
        Test.setMock(HttpCalloutMock.class, new ContractMock(200));

        Test.startTest();
        Map<String, Object> initializeResult = MCPContractController.initializeMCPSession();
        Map<String, Object> toolsResult = MCPContractController.getAvailableTools('test-session');
        Test.stopTest();

        System.assertEquals(true, initializeResult.get('success'));
        System.assertEquals('test-session', initializeResult.get('sessionId'));
        System.assertEquals(true, toolsResult.get('success'));
        System.assertEquals(false, toolsResult.get('requiresAuth'));
    }

    @IsTest
    static void unauthorizedNotificationRequiresAuthentication() {
        Test.setMock(HttpCalloutMock.class, new ContractMock(200, 401));

        Test.startTest();
        Map<String, Object> initializeResult = MCPContractController.initializeMCPSession();
        Map<String, Object> fullFlowResult = MCPContractController.executeFullContractFlow(123, 1);
        Test.stopTest();

        System.assertEquals(true, initializeResult.get('requiresAuth'));
        System.assertEquals(false, initializeResult.get('success'));
        System.assertEquals(true, fullFlowResult.get('requiresAuth'));
        System.assertEquals(false, fullFlowResult.get('success'));
    }

    @IsTest
    static void authenticationUrlRejectsExternalReturnPath() {
        try {
            MCPContractController.getAuthenticationUrl('//example.com');
            System.assert(false, 'Expected invalid return path to be rejected');
        } catch (AuraHandledException expected) {
            System.assertNotEquals(null, expected);
        }
    }
}