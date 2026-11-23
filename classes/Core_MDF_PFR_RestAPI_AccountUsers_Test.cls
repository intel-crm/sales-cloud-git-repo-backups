@IsTest
private class Core_MDF_PFR_RestAPI_AccountUsers_Test {
    @IsTest
    static void missingAccountNameReturnsBadRequest() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/account-users';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI_AccountUsers.doGet();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(false, response.get('isSuccess'));
        System.assertEquals('400', response.get('code'));
    }

    @IsTest
    static void accountNameCanBeReadFromEncodedUrlPath() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/account-users/CCF%20-%20MEGA%20CHIPS';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI_AccountUsers.doGet();
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(false, response.get('isSuccess'));
        System.assertEquals('404', response.get('code'));
        System.assert(String.valueOf(response.get('message')).contains('CCF - MEGA CHIPS'));
    }

    @IsTest
    static void accountNameQueryParameterIsSupported() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/account-users';
        request.addParameter('accountName', 'Missing Query Account');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI_AccountUsers.doGet();
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assert(String.valueOf(response.get('message')).contains('Missing Query Account'));
    }

    @IsTest
    static void successResponseReturnsAccountAndEmptyAllowedLists() {
        Account ultimateAccount = buildAccount('Ultimate API Account', null);
        insert ultimateAccount;
        Account childAccount = buildAccount('CCF - MEGA CHIPS', ultimateAccount.Id);
        insert childAccount;

        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/account-users/CCF%20-%20MEGA%20CHIPS';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI_AccountUsers.doGet();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(true, response.get('isSuccess'));
        System.assertEquals('200', response.get('code'));
        Map<String, Object> accountDetails = (Map<String, Object>) response.get('accountDetails');
        System.assertEquals(childAccount.Id, accountDetails.get('accountId'));
        System.assertEquals(ultimateAccount.Id, accountDetails.get('ultimateAccountId'));
        System.assertEquals(0, ((List<Object>) response.get('MemberAcceptorUsername')).size());
        System.assertEquals(0, ((List<Object>) response.get('IntelApproverUsername')).size());
    }

    @IsTest
    static void duplicateAccountNameReturnsBadRequest() {
        insert new List<Account>{
            buildAccount('Duplicate API Account', null),
            buildAccount('Duplicate API Account', null)
        };

        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/account-users/Duplicate%20API%20Account';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI_AccountUsers.doGet();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(false, response.get('isSuccess'));
        System.assert(String.valueOf(response.get('message')).contains('Multiple accounts found'));
    }

    private static Account buildAccount(String accountName, Id parentId) {
        return new Account(
            Name = accountName,
            ParentId = parentId,
            Core_Account_Type__c = 'Distributor',
            Industry = 'Communications',
            BillingCity = 'Pune',
            BillingCountry = 'IND',
            BillingCountryCode = 'IND',
            BillingState = 'MH',
            BillingStateCode = 'MH',
            BillingStreet = 'TestStreet'
        );
    }
}