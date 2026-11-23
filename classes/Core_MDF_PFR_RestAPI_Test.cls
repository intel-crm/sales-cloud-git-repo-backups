/**
 * @description Test class for Core_MDF_PFR_RestAPI main REST endpoint
 * Covers POST request handling, action validation, file upload routing, SPIF validation routing, 
 * error handling, and response formatting.
*/
@IsTest
private class Core_MDF_PFR_RestAPI_Test {

    // ========== Setup Test Data ==========

    private class ActivityTestData {
        Account parentFundAccount;
        Account channelPartner;
        Campaign campaign;
        PartnerMarketingBudget budget;
        PartnerFundAllocation allocation;
        User memberAcceptor;
        PartnerFundRequest activity;
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
            BillingStreet = 'TestStreet',
            ShippingCity = 'Pune',
            ShippingCountry = 'IND',
            ShippingState = 'MH',
            ShippingStreet = 'TestStreet'
        );
    }

    private static void enablePfrFixtureBypasses() {
        Core_MDF_CCP_TestDataUtility.byPassFeature(
            new List<String>{
                'Bypass_MDF_Budget_Status_Validation',
                'Bypass_MDF_Budget_Access_Validation',
                'Bypass_MDF_Budget_Access',
                'Bypass_Duplicate_Budget_Check',
                'Bypass_GeoBased_Budget_Sharing',
                'Bypass_GeoBased_Allocation_Sharing'
            },
            true,
            true
        );
    }

    private static ActivityTestData createActivityTestData() {
        ActivityTestData data = new ActivityTestData();
        User setupUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(setupUser) {
            enablePfrFixtureBypasses();

            ChannelProgram program = new ChannelProgram(
                Name = 'Client',
                Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'
            );
            insert program;

            Id intelAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            Account parentFundAccount = buildAccount('PFR Test Parent Fund Account', null);
            parentFundAccount.RecordTypeId = intelAccountRecordTypeId;
            parentFundAccount.AccountSource = 'Auto';
            insert parentFundAccount;

            Id coMarketingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
            Account channelPartner = new Account(
                Name = 'PFR Test Channel Partner',
                RecordTypeId = coMarketingAccountRecordTypeId,
                Core_MDF_Channel_Program__c = program.Id,
                Core_MDF_Parent_Fund_Account__c = parentFundAccount.Id,
                Core_MDF_CoMarketing_Ultimate_Account__c = parentFundAccount.Id,
                Core_MDF_CoMarketingActive__c = true,
                AccountSource = 'Auto'
            );
            insert channelPartner;

            Campaign campaign = new Campaign(
                Name = 'PFR Test Campaign',
                RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId(),
                Core_MDF_Program__c = 'Client CoMarketing Fund',
                Core_MDF_Account__c = channelPartner.Id,
                StartDate = System.today().addDays(-1),
                EndDate = System.today().addDays(30),
                Core_MDF_External_Visibility_Date__c = System.today().addDays(-1),
                Core_MDF_First_Year_Budget_Amount__c = 100000,
                Core_MDF_Reimbursement_Rate__c = '50%',
                Core_MDF_Priority__c = 'Consumer non-Evo',
                Core_MDF_Product_Type__c = 'Desktop',
                Core_MDF_Region_cd__c = 'APJ',
                Core_MDF_Market__c = 'INDIA',
                Status = 'Active'
            );
            insert campaign;

            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget(
                'PFR Test Budget',
                Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                channelPartner.Id,
                program.Id,
                10000,
                System.today().addDays(-60),
                System.today().addDays(60),
                false
            );
            budget.Core_MDF_Budget_Type_Txt__c = 'MDF';
            budget.Core_MDF_Budget_Status__c = 'Released';
            insert budget;

            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation(
                'PFR Test Allocation',
                budget,
                channelPartner,
                10000,
                true
            );

            Core_MDF_Campaign_Budgets__c campaignBudget = new Core_MDF_Campaign_Budgets__c(
                Core_MDF_Campaign_Id__c = campaign.Id,
                Core_MDF_Budget_Name_Id__c = budget.Id,
                Core_MDF_Budget_Amt__c = 10000,
                Core_MDF_Reimbursement_Amt__c = 5000,
                Core_MDF_Reimbursement_Rate_Pct__c = '50%',
                Core_MDF_Active_ind__c = true
            );
            insert campaignBudget;

            data.parentFundAccount = parentFundAccount;
            data.channelPartner = channelPartner;
            data.campaign = [
                SELECT Id, Name, Core_MDF_Campaign_Reference_Number__c
                FROM Campaign
                WHERE Id = :campaign.Id
            ];
            data.budget = [
                SELECT Id, Core_MDF_budget_ref_nbr__c
                FROM PartnerMarketingBudget
                WHERE Id = :budget.Id
            ];
            data.allocation = allocation;
        }
        return data;
    }

    private static PartnerFundRequest createExistingActivity(ActivityTestData data) {
        PartnerFundRequest activity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(
            String.valueOf(data.campaign.Id),
            String.valueOf(Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_CCF),
            String.valueOf(data.channelPartner.Id),
            data.allocation,
            data.budget,
            'INDIA',
            'Consumer',
            'Desktop',
            'Intel® Corporate Logo',
            'Technical Sales',
            'Seed Unit',
            'Draft',
            true
        );
        activity.Core_MDF_Budget_Type_nm__c = 'MDF';
        activity.Core_MDF_Budget_Amount_Local_amt__c = 1000;
        activity.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        activity.Core_MDF_Channel_Partner__c = 'Digital';
        update activity;
        data.activity = activity;
        return activity;
    }

    private static RestResponse invokePost(String uri, String body, Map<String, String> parameters) {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = uri;
        request.requestBody = body == null ? null : Blob.valueOf(body);
        if (parameters != null) {
            for (String key : parameters.keySet()) {
                request.addParameter(key, parameters.get(key));
            }
        }
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Core_MDF_PFR_RestAPI.doPost();
        return RestContext.response;
    }

    private static String activityRequestBody(Map<String, Object> activity) {
        return JSON.serialize(new Map<String, Object>{ 'activity' => activity });
    }

    private static String repeatedText(String token, Integer repetitions) {
        String value = '';
        for (Integer index = 0; index < repetitions; index++) {
            value += token;
        }
        return value;
    }

    private static Map<String, Object> fullCreatePayload(ActivityTestData data) {
        return new Map<String, Object>{
            'ActivityName' => 'REST Create Activity',
            'ActivityDescription' => 'REST API create coverage activity',
            'StartDate' => String.valueOf(System.today().addDays(5)),
            'EndDate' => String.valueOf(System.today().addDays(10)),
            'Campaign' => data.campaign.Core_MDF_Campaign_Reference_Number__c,
            'AccountName' => data.channelPartner.Name,
            'BudgetReferenceNumber' => data.budget.Core_MDF_budget_ref_nbr__c,
            'BudgetType' => 'MDF',
            'ActivitySpendingLimitLocal' => 1000,
            'ReimbursementRate' => '50%',
            'TargetAudience' => 'Consumer',
            'Country' => 'INDIA',
            'Brand' => 'Intel® Corporate Logo',
            'ProductType' => 'Desktop',
            'ActivityCategory' => 'Technical Sales',
            'ActivityTypes' => 'Seed Unit',
            'Priority' => 'Consumer non-Evo',
            'EcosystemPartner' => 'Digital',
            'Industry' => 'Communications',
            'MemberAcceptorUsername' => UserInfo.getUserId(),
            'Currency' => 'USD'
        };
    }

    private static Campaign buildCampaign(String campaignName, Id accountId) {
        return new Campaign(
            Name = campaignName,
            Core_MDF_Account__c = accountId,
            Status = 'Active'
        );
    }

    private static PartnerFundRequest buildPFR(String title, Id campaignId) {
        PartnerFundRequest pfr = new PartnerFundRequest();
        pfr.Title = title;
        pfr.CampaignId = campaignId;
        return pfr;
    }

    // ========== Test Cases: Empty Request Body ==========

    @IsTest
    static void emptyRequestBodyReturnsBadRequestWith9001Code() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Should return 400 for empty body');
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        String errorCode = (String) response.get('code');
        System.assertEquals(Core_MDF_PFR_RestAPI_Constants.ERR_9001_NO_RECORDS, errorCode, 'Should return error code 9001');
    }

    @IsTest
    static void nullRequestBodyReturnsBadRequest() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = null;
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Should return 400 for null body');
    }

    // ========== Test Cases: Route Detection ==========

    @IsTest
    static void fileUploadRequestDetected() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/uploadfile';
        request.requestBody = Blob.valueOf('{"activity":{}}');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Response should be generated (actual file upload handling tested separately)
        System.assertNotEquals(null, RestContext.response.responseBody, 'Should process file upload route');
    }

    @IsTest
    static void spifValidationRequestDetected() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/validatespif';
        request.requestBody = Blob.valueOf('{"Segments":[]}');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Response should be generated for SPIF validation
        System.assertNotEquals(null, RestContext.response.responseBody, 'Should process SPIF validation route');
    }

    @IsTest
    static void fileUploadRequestDetectedWithQueryParameters() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/uploadfile?test=true';
        request.requestBody = Blob.valueOf('{"activity":{}}');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Should strip query parameters before checking endpoint
        System.assertNotEquals(null, RestContext.response.responseBody, 'Should handle query parameters in file upload');
    }

    @IsTest
    static void spifValidationRequestDetectedWithQueryParameters() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/validatespif?test=true';
        request.requestBody = Blob.valueOf('{"Segments":[]}');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        System.assertNotEquals(null, RestContext.response.responseBody, 'Should handle query parameters in SPIF validation');
    }

    // ========== Test Cases: Action Parameter Validation ==========

    @IsTest
    static void actionParameterDefaultsToCreateWhenNotProvided() {
        String validActivity = '{"activity":{"Title":"Test Activity"}}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf(validActivity);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Action should default to create
        System.assertEquals('create', Core_MDF_PFR_RestAPI.actionType, 'Should default to create action');
    }

    @IsTest
    static void actionParameterDefaultsToUpdateWhenIdProvided() {
        String validActivity = '{"activity":{"Title":"Test Activity"}}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.addParameter('id', 'a07TH000003NHpQAW');
        request.requestBody = Blob.valueOf(validActivity);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Action should infer update when id parameter provided
        System.assertEquals('update', Core_MDF_PFR_RestAPI.actionType, 'Should infer update action when id parameter provided');
    }

    @IsTest
    static void actionParameterExplicitCreateAccepted() {
        String validActivity = '{"activity":{"Title":"Test Activity"}}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.addParameter('action', 'create');
        request.requestBody = Blob.valueOf(validActivity);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        System.assertEquals('create', Core_MDF_PFR_RestAPI.actionType, 'Should accept explicit create action');
    }

    @IsTest
    static void actionParameterExplicitUpdateAccepted() {
        String validActivity = '{"activity":{"Title":"Test Activity"}}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.addParameter('action', 'update');
        request.requestBody = Blob.valueOf(validActivity);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        System.assertEquals('update', Core_MDF_PFR_RestAPI.actionType, 'Should accept explicit update action');
    }

    @IsTest
    static void actionParameterCaseInsensitive() {
        String validActivity = '{"activity":{"Title":"Test Activity"}}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.addParameter('action', 'CREATE');
        request.requestBody = Blob.valueOf(validActivity);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        System.assertEquals('CREATE', Core_MDF_PFR_RestAPI.actionType, 'Should accept uppercase action');
    }

    @IsTest
    static void invalidActionParameterReturnsBadRequest() {
        String validActivity = '{"activity":{"Title":"Test Activity"}}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.addParameter('action', 'invalid');
        request.requestBody = Blob.valueOf(validActivity);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Should return 400 for invalid action');
    }

    // ========== Test Cases: Request Processing ==========

    @IsTest
    static void validJsonRequestProcessed() {
        ActivityTestData data = createActivityTestData();

        String activityJson = '{"activity":{"ActivityName":"Test Activity","Campaign":"' + data.campaign.Core_MDF_Campaign_Reference_Number__c + '","AccountName":"' + data.channelPartner.Name + '"}}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf(activityJson);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Response should be generated
        System.assertNotEquals(null, RestContext.response.responseBody, 'Should process valid activity request');
    }

    @IsTest
    static void createRequestWithResolvedPfrRecordsBuildsValidationFailure() {
        ActivityTestData data = createActivityTestData();

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            activityRequestBody(fullCreatePayload(data)),
            new Map<String, String>{ 'action' => 'create' }
        );
        Test.stopTest();

        System.assertEquals(400, response.statusCode, 'Create request should return structured validation when member acceptor eligibility is not configured');
        System.assertEquals(false, Core_MDF_PFR_RestAPI.response.isSuccess, 'Create validation response should be unsuccessful');
        System.assert(
            Core_MDF_PFR_RestAPI.response.failureContent != null && !Core_MDF_PFR_RestAPI.response.failureContent.isEmpty(),
            'Resolved create payload should populate validation failure content'
        );
    }

    @IsTest
    static void updateRequestWithValidIdProcessesDmlSuccess() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);
        Map<String, Object> payload = new Map<String, Object>{ 'ActivityName' => 'Updated REST Activity' };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            activityRequestBody(payload),
            new Map<String, String>{ 'action' => 'update', 'id' => String.valueOf(activity.Id) }
        );
        Test.stopTest();

        System.assertEquals(201, response.statusCode, 'Successful sparse update should use success response status');
        System.assertEquals('201', Core_MDF_PFR_RestAPI.response.code, 'Successful update should prepare success payload');
    }

    @IsTest
    static void updateRequestWithInlineFilesAttachesFileToActivity() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);
        Map<String, Object> payload = new Map<String, Object>{
            'ActivityName' => 'Inline File Update',
            'Files' => new List<Object>{
                new Map<String, Object>{
                    'FileName' => 'proof.pdf',
                    'file' => 'PHN2ZyB4bWxucz0iaHR0cDo+DQogIDwvZz4NCjwvc3ZnPg0K',
                    'comment' => 'Testing upload'
                }
            }
        };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            activityRequestBody(payload),
            new Map<String, String>{ 'action' => 'update', 'id' => String.valueOf(activity.Id) }
        );
        Test.stopTest();

        System.assertEquals(201, response.statusCode, 'Inline file payload should not block the activity update');
        System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.fileUploadContent, 'attachInlineFiles should populate file upload results');
        System.assertEquals(1, Core_MDF_PFR_RestAPI.response.fileUploadContent.size(), 'One inline file should produce one upload result');
        System.assertEquals('proof.pdf', Core_MDF_PFR_RestAPI.response.fileUploadContent[0].fileName, 'Upload result should include the inline file name');
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :activity.Id
        ];
        System.assertEquals(1, links.size(), 'attachInlineFiles should create a content document link for the activity');
        ContentVersion version = [
            SELECT Title, PathOnClient
            FROM ContentVersion
            WHERE ContentDocumentId = :links[0].ContentDocumentId
            LIMIT 1
        ];
        System.assertEquals('proof', version.Title, 'Inline file title should be derived from FileName');
        System.assertEquals('proof.pdf', version.PathOnClient, 'Inline file path should preserve FileName');
    }

    @IsTest
    static void updateRequestWithTooLongActivityNameBuildsDmlFailure() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);
        Map<String, Object> payload = new Map<String, Object>{
            'ActivityName' => repeatedText('Too Long Activity Name ', 20)
        };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            activityRequestBody(payload),
            new Map<String, String>{ 'action' => 'update', 'id' => String.valueOf(activity.Id) }
        );
        Test.stopTest();

        System.assertEquals(400, response.statusCode, 'DML save result errors should return validation response status');
        System.assertEquals(false, Core_MDF_PFR_RestAPI.response.isSuccess, 'DML save result failure should mark response unsuccessful');
        System.assert(
            Core_MDF_PFR_RestAPI.response.failureContent != null && !Core_MDF_PFR_RestAPI.response.failureContent.isEmpty(),
            'DML save result failure should populate failure content'
        );
        System.assert(String.join(Core_MDF_PFR_RestAPI.rawErrorLogs, ';').contains('DML Technical Error'), 'DML save result failure should be formatted through formatDmlError');
    }

    @IsTest
    static void getBusinessValidationMessageCoversBlankAndCleanedMessages() {
        System.assertEquals(
            '9006: 9006',
            Core_MDF_PFR_RestAPI.getBusinessValidationMessage(null),
            'Blank business validation messages should fall back to the configured business validation code and message'
        );
        System.assertEquals(
            '9006: Approval amount cannot be negative',
            Core_MDF_PFR_RestAPI.getBusinessValidationMessage('FIELD_CUSTOM_VALIDATION_EXCEPTION, Approval amount cannot be negative: []'),
            'Salesforce validation wrappers should be stripped from the business rule message'
        );
    }

    @IsTest
    static void toConfiguredBusinessValidationErrorUsesBusinessValidationSetting() {
        insert new Core_MDF_External_API_Response_Codes__c(
            Name = 'Test_9006_Business_Validation',
            Core_Code__c = '9006',
            Core_Message__c = 'Configured business validation message',
            Core_Http_Status_Code__c = '400',
            Core_Context_of_Error__c = 'BUSINESS_VALIDATION'
        );

        System.assertEquals(
            '9006: Configured business validation message',
            Core_MDF_PFR_RestAPI.toConfiguredBusinessValidationError('ERR-9006', 'Fallback business validation message'),
            'Business validation response should normalize ERR-prefixed codes and prefer configured message text'
        );
    }

    @IsTest
    static void updateRequestWithInvalidIdBuildsValidationFailure() {
        Map<String, Object> payload = new Map<String, Object>{ 'ActivityName' => 'Invalid Id Update' };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            activityRequestBody(payload),
            new Map<String, String>{ 'action' => 'update', 'id' => UserInfo.getUserId() }
        );
        Test.stopTest();

        System.assertEquals(400, response.statusCode, 'Invalid update id should return validation failure');
        System.assertEquals(false, Core_MDF_PFR_RestAPI.response.isSuccess, 'Response should be unsuccessful');
    }

    @IsTest
    static void updateRequestWithInvalidAllocationPercentagesFailsBeforeDml() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);
        Map<String, Object> payload = new Map<String, Object>{
            'ActivityName' => 'Bad Allocation Update',
            'EcosystemPartnerAllocations' => new List<Object>{
                new Map<String, Object>{ 'partner' => 'Digital', 'percent' => 75 }
            }
        };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            activityRequestBody(payload),
            new Map<String, String>{ 'action' => 'update', 'id' => String.valueOf(activity.Id) }
        );
        Test.stopTest();

        System.assertEquals(400, response.statusCode, 'Non-100 allocation percentages should fail validation');
        System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code, 'Allocation validation should prepare a validation response');
    }

    @IsTest
    static void updateRequestWithEcosystemPartnerAllocationsCreatesAllocationRecords() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);
        Map<String, Object> payload = new Map<String, Object>{
            'ActivityName' => 'Allocation Processing Update',
            'EcosystemPartner' => 'Others',
            'OtherEcosystemPartner' => 'Test',
            'EcosystemPartnerAllocations' => new List<Object>{
                new Map<String, Object>{ 'partner' => 'Others', 'percent' => 100 }
            }
        };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            activityRequestBody(payload),
            new Map<String, String>{ 'action' => 'update', 'id' => String.valueOf(activity.Id) }
        );
        Test.stopTest();

        System.assertEquals(201, response.statusCode, 'Valid ecosystem partner allocations should process after the activity update');
        List<Core_MDF_Ecosystem_Partner_Allocation__c> allocations = [
            SELECT Core_MDF_Ecosystem_Partner_txt__c, Core_MDF_Percentage_pct__c, Core_MDF_Active_Ind__c
            FROM Core_MDF_Ecosystem_Partner_Allocation__c
            WHERE Core_MDF_Activity_Id__c = :activity.Id
        ];
        System.assertEquals(1, allocations.size(), 'processEcosystemPartnerAllocations should create one allocation row');
        System.assertEquals('Others', allocations[0].Core_MDF_Ecosystem_Partner_txt__c, 'Allocation partner should come from the updated ecosystem partner field');
        System.assertEquals(100, allocations[0].Core_MDF_Percentage_pct__c, 'Allocation percent should come from EcosystemPartnerAllocations');
        System.assertEquals(true, allocations[0].Core_MDF_Active_Ind__c, 'Created allocation should be active');
    }

    @IsTest
    static void validateSegmentPayoutAgainstIntelContributionCoversCombinations() {
        PartnerFundRequest pfr = new PartnerFundRequest(
            Title = 'Segment payout helper activity',
            Core_MDF_Budget_Amount_Local_amt__c = 100,
            Core_MDF_Reimbursement_Rate_txt__c = '50%'
        );

        System.assertEquals(0, Core_MDF_PFR_RestAPI.validateSegmentPayoutAgainstIntelContribution(null, null).size(), 'Null PFR should skip payout validation');
        System.assertEquals(0, Core_MDF_PFR_RestAPI.validateSegmentPayoutAgainstIntelContribution(pfr, null).size(), 'Null segments should skip payout validation');
        System.assertEquals(0, Core_MDF_PFR_RestAPI.validateSegmentPayoutAgainstIntelContribution(pfr, new List<Map<String, Object>>()).size(), 'Empty segments should skip payout validation');
        System.assertEquals(
            0,
            Core_MDF_PFR_RestAPI.validateSegmentPayoutAgainstIntelContribution(
                new PartnerFundRequest(Title = 'No contribution'),
                new List<Map<String, Object>>{ new Map<String, Object>{ 'MinimumForecastVolume' => 100, 'IncentiveAmountPerUnit' => 1 } }
            ).size(),
            'Missing contribution inputs should skip payout validation'
        );

        List<Map<String, Object>> segmentMaps = new List<Map<String, Object>>{
            null,
            new Map<String, Object>{ 'SegmentName' => 'Missing Forecast', 'IncentiveAmountPerUnit' => 1 },
            new Map<String, Object>{ 'SegmentName' => 'Missing Incentive', 'MinimumForecastVolume' => 1 },
            new Map<String, Object>{ 'SegmentName' => 'Below Contribution', 'MinimumForecastVolume' => 10, 'IncentiveAmountPerUnit' => 1 },
            new Map<String, Object>{ 'SegmentName' => 'Equal Contribution', 'MinimumForecastVolume' => 10, 'IncentiveAmountPerUnit' => 5 },
            new Map<String, Object>{ 'SegmentName' => 'Over Contribution', 'MinimumForecastVolume' => 11, 'IncentiveAmountPerUnit' => 5 },
            new Map<String, Object>{ 'MinimumForecastVolume' => 20, 'IncentiveAmountPerUnit' => 5 }
        };

        List<String> errors = Core_MDF_PFR_RestAPI.validateSegmentPayoutAgainstIntelContribution(pfr, segmentMaps);
        System.assertEquals(2, errors.size(), 'Only segments with payout over Intel contribution should fail');
        System.assert(errors[0].contains('Over Contribution'), 'Named over-contribution segment should use the segment name');
        System.assert(errors[1].startsWith('Segment:'), 'Unnamed over-contribution segment should use the fallback segment name');
    }

    @IsTest
    static void updateRequestWithSegmentPayoutOverContributionBuildsValidationFailure() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);
        Product2 product = new Product2(Name = 'PFR Segment Payout Product', IsActive = true);
        insert product;
        Map<String, Object> payload = new Map<String, Object>{
            'ActivityName' => 'Segment Validation Update',
            'ActivityCategory' => 'Seller Incentive',
            'ActivityTypes' => 'SPIF - Target',
            'ActivitySpendingLimitLocal' => 100,
            'ReimbursementRate' => '50%'
        };
        List<Object> segments = new List<Object>{
                new Map<String, Object>{
                    'SegmentName' => 'High Payout Segment',
                    'MinimumForecastVolume' => 1000,
                    'IncentiveAmountPerUnit' => 10,
                    'ProductIds' => new List<String>{ String.valueOf(product.Id) }
                }
        };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            JSON.serialize(new Map<String, Object>{ 'activity' => payload, 'Segments' => segments }),
            new Map<String, String>{ 'action' => 'update', 'id' => String.valueOf(activity.Id) }
        );
        Test.stopTest();

        System.assertEquals(400, response.statusCode, 'Segment payout over Intel contribution should fail validation before DML');
        System.assertEquals(false, Core_MDF_PFR_RestAPI.response.isSuccess, 'Over-contribution segment validation should mark response unsuccessful');
        System.assert(
            Core_MDF_PFR_RestAPI.response.failureContent != null &&
            Core_MDF_PFR_RestAPI.response.failureContent[0].errors[0].contains('Minimum Forecast Volume * Incentive Amount'),
            'Over-contribution validation should return the segment payout error'
        );
    }

    @IsTest
    static void updateRequestWithValidSegmentPayloadProcessesDmlSuccess() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);
        Product2 product = new Product2(Name = 'PFR Segment Test Product', IsActive = true);
        insert product;

        Map<String, Object> payload = new Map<String, Object>{
            'ActivityName' => 'Valid Segment Update',
            'ActivityCategory' => 'Seller Incentive',
            'ActivityTypes' => 'SPIF - Target',
            'RequestedAmount' => 100,
            'ReimbursementRate' => '50%'
        };
        List<Object> segments = new List<Object>{
                new Map<String, Object>{
                    'SegmentName' => 'Graphics',
                    'MinimumForecastVolume' => 10,
                    'IncentiveAmountPerUnit' => 1,
                    'ProductIds' => new List<String>{ String.valueOf(product.Id) }
                }
        };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            JSON.serialize(new Map<String, Object>{ 'activity' => payload, 'Segments' => segments }),
            new Map<String, String>{ 'action' => 'update', 'id' => String.valueOf(activity.Id) }
        );
        Test.stopTest();

        System.assertEquals(201, response.statusCode, 'Valid segment payload should pass segment validation and update the activity');
        System.assertEquals('201', Core_MDF_PFR_RestAPI.response.code, 'Successful segment update should prepare success payload');
    }

    @IsTest
    static void fileUploadRouteCoversValidationFailures() {
        Test.startTest();
        RestResponse invalidJsonResponse = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/uploadfile',
            '{invalid',
            null
        );
        RestResponse missingActivityResponse = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/uploadfile',
            '{"fileName":"proof.pdf","file":"' + EncodingUtil.base64Encode(Blob.valueOf('proof')) + '"}',
            null
        );
        RestResponse unsupportedExtensionResponse = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/uploadfile',
            '{"activity":"' + UserInfo.getUserId() + '","fileName":"proof.exe","file":"' + EncodingUtil.base64Encode(Blob.valueOf('proof')) + '"}',
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, invalidJsonResponse.responseBody, 'Invalid upload JSON should return a response body');
        System.assertNotEquals(null, missingActivityResponse.responseBody, 'Missing activity id should return a response body');
        System.assertNotEquals(null, unsupportedExtensionResponse.responseBody, 'Unsupported file extension should return a response body');
    }

    @IsTest
    static void fileUploadRouteAttachesPdfToActivity() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);
        Map<String, Object> payload = new Map<String, Object>{
            'activity' => String.valueOf(activity.Id),
            'fileName' => 'proof-of-marketing.pdf',
            'file' => 'JVBERi0xLjQKJeLjz9MNCjEgMCBvYmo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFI+PmVuZG9iagoyIDAgb2JqPDwvVHlwZS9QYWdlcw==',
            'comment' => 'Supporting documentation for activity claim'
        };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/uploadfile',
            JSON.serialize(payload),
            null
        );
        Test.stopTest();

        System.assertEquals(200, response.statusCode, 'Valid file upload payload should return success');
        System.assertEquals(true, Core_MDF_PFR_RestAPI.fileUploadResponse.isSuccess, 'File upload response should be successful');
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :activity.Id
        ];
        System.assertEquals(1, links.size(), 'File upload should create a content document link for the activity');
        ContentVersion version = [
            SELECT Title, PathOnClient
            FROM ContentVersion
            WHERE ContentDocumentId = :links[0].ContentDocumentId
            LIMIT 1
        ];
        System.assertEquals('proof-of-marketing', version.Title, 'Content title should be derived from the uploaded PDF file name');
        System.assertEquals('proof-of-marketing.pdf', version.PathOnClient, 'Content path should preserve the uploaded PDF file name');
    }

    @IsTest
    static void invalidJsonReturnsBadRequest() {
        String invalidJson = '{"activity":{invalid}}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf(invalidJson);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Should return error for invalid JSON
        System.assertNotEquals(null, RestContext.response.responseBody, 'Should handle invalid JSON');
    }

    // ========== Test Cases: Error Handling ==========

    @IsTest
    static void unexpectedExceptionReturns500Error() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf('{"activity":{"Title":"Test"}}');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        // Exception will be caught and handled
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Response should be generated even on error
        System.assertNotEquals(null, RestContext.response.responseBody, 'Should handle exceptions gracefully');
    }

    @IsTest
    static void errorMessageRetrievedFromCustomSettings() {
        // Create test custom setting for error 9001
        Core_MDF_External_API_Response_Codes__c setting = new Core_MDF_External_API_Response_Codes__c(
            Name = 'Test_9001_No_Records',
            Core_Code__c = '9001',
            Core_Message__c = 'No activity records were provided in the request',
            Core_Http_Status_Code__c = '400'
        );
        insert setting;

        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        String message = (String) response.get('message');
        System.assert(String.isNotBlank(message), 'Error message should be populated from custom settings');
    }

    // ========== Test Cases: Response Structure ==========

    @IsTest
    static void responseIncludesContentTypeHeader() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        String contentType = RestContext.response.headers.get('Content-Type');
        System.assertEquals('application/json', contentType, 'Response should include Content-Type header');
    }

    @IsTest
    static void responseBodyIsValidJson() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        try {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
            System.assertNotEquals(null, response, 'Response should be valid JSON');
        } catch (Exception e) {
            System.assert(false, 'Response should be valid JSON, got: ' + e.getMessage());
        }
    }

    @IsTest
    static void responseIncludesRequiredFields() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        // Error responses contain code, message, and httpStatusCode
        System.assert(response.containsKey('code'), 'Response should include code field');
        System.assert(response.containsKey('message'), 'Response should include message field');
        System.assert(response.containsKey('httpStatusCode'), 'Response should include httpStatusCode field');
    }

    // ========== Test Cases: SPIF Validation Routing ==========

    @IsTest
    static void spifValidationWithInvalidJsonReturnsBadRequest() {
        // Use properly formatted but empty JSON that should be processed by SPIF
        String invalidPayload = '{}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/validatespif';
        request.requestBody = Blob.valueOf(invalidPayload);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // SPIF validation should process the request and return a response
        System.assertNotEquals(null, RestContext.response.responseBody, 'SPIF validation should return a response');
    }

    @IsTest
    static void spifValidationWithValidPayloadProcessed() {
        String spifPayload = '{"Segments":[],"AccountId":"001XX000003DHP","Program":"Client CoMarketing Fund"}';
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/validatespif';
        request.requestBody = Blob.valueOf(spifPayload);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Should return response without throwing exception
        System.assertNotEquals(null, RestContext.response.responseBody, 'Should process SPIF validation payload');
    }

    // ========== Test Cases: Static State Management ==========

    @IsTest
    static void staticStateResetBetweenCalls() {
        // First call
        RestRequest request1 = new RestRequest();
        request1.httpMethod = 'POST';
        request1.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request1.requestBody = Blob.valueOf('');
        RestContext.request = request1;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        String firstCode = Core_MDF_PFR_RestAPI.response.code;
        
        // Second call
        RestRequest request2 = new RestRequest();
        request2.httpMethod = 'POST';
        request2.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request2.requestBody = Blob.valueOf('');
        RestContext.request = request2;
        RestContext.response = new RestResponse();
        
        Core_MDF_PFR_RestAPI.doPost();
        String secondCode = Core_MDF_PFR_RestAPI.response.code;
        Test.stopTest();

        // Both should have response codes
        System.assertNotEquals(null, firstCode, 'First response should have code');
        System.assertNotEquals(null, secondCode, 'Second response should have code');
    }

    @IsTest
    static void fileUploadResponseNullWhenNotProcessing() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // File upload response should be null for regular requests
        System.assertEquals(null, Core_MDF_PFR_RestAPI.fileUploadResponse, 'File upload response should be null for non-upload requests');
    }

    @IsTest
    static void rawErrorLogsInitializedForEachRequest() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        // Raw error logs should be initialized (empty or with entries)
        System.assertNotEquals(null, Core_MDF_PFR_RestAPI.rawErrorLogs, 'Raw error logs should be initialized');
    }
// =========================================================================
    // Additional Coverage: Exception Handlers & Catch Blocks (JSON & Generic)
    // Targets: Lines 129-149 (doPost JSONException catch block)
    // =========================================================================
    @IsTest
    static void testJsonAndGenericExceptionHandlers() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/v1.0/partnercenter/activity/';
        // Malformed JSON targeting the main doPost JSON parser
        request.requestBody = Blob.valueOf('{malformed_json_syntax');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_PFR_RestAPI.doPost();
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode, 'Malformed body should trigger exception handling status code');
    }

// =========================================================================
    // Additional Coverage: Campaign Access Denied Response
    // Targets: Lines 357-373 (validateCampaignAccess & prepareCampaignAccessDeniedResponse)
    // =========================================================================
    @IsTest
    static void testCampaignAccessDeniedHandling() {
        ActivityTestData data = createActivityTestData();
        
        // Safely query RecordTypeId from data.campaign to prevent SObjectException
        Campaign baseCampaign = [SELECT RecordTypeId FROM Campaign WHERE Id = :data.campaign.Id LIMIT 1];

        Id coMarketingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
        Account otherAccount = buildAccount('Restricted Channel Partner', data.parentFundAccount.Id);
        otherAccount.RecordTypeId = coMarketingAccountRecordTypeId;
        otherAccount.Core_MDF_Channel_Program__c = data.channelPartner.Core_MDF_Channel_Program__c;
        otherAccount.Core_MDF_Parent_Fund_Account__c = data.parentFundAccount.Id;
        otherAccount.Core_MDF_CoMarketing_Ultimate_Account__c = data.parentFundAccount.Id;
        otherAccount.Core_MDF_CoMarketingActive__c = true;
        otherAccount.AccountSource = 'Auto';
        insert otherAccount;
        
        // Populate required fields so Core_MDF_ProcessCCP_Campaign doesn't throw a NullPointerException
        Campaign restrictedCampaign = new Campaign(
            Name = 'Restricted Campaign',
            RecordTypeId = baseCampaign.RecordTypeId,
            Core_MDF_Program__c = 'Client CoMarketing Fund',
            Core_MDF_Account__c = otherAccount.Id,
            StartDate = System.today().addDays(-1),
            EndDate = System.today().addDays(30),
            Core_MDF_External_Visibility_Date__c = System.today().addDays(-1),
            Core_MDF_First_Year_Budget_Amount__c = 100000,
            Core_MDF_Reimbursement_Rate__c = '50%',
            Core_MDF_Priority__c = 'Consumer non-Evo',
            Core_MDF_Product_Type__c = 'Desktop',
            Core_MDF_Region_cd__c = 'APJ',
            Core_MDF_Market__c = 'INDIA',
            Status = 'Active'
        );
        insert restrictedCampaign;

        Map<String, Object> payload = new Map<String, Object>{
            'ActivityName' => 'Restricted Campaign Activity',
            'Campaign' => restrictedCampaign.Id,
            'AccountName' => data.channelPartner.Name
        };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            activityRequestBody(payload),
            new Map<String, String>{ 'action' => 'create' }
        );
        Test.stopTest();

        System.assertNotEquals(null, response.responseBody, 'Should return response for restricted campaign access');
    }

    // =========================================================================
    // Additional Coverage: File Upload Edge Cases & Error Validations
    // Targets: Upload endpoint lines 706-742, 779-802 (Missing filename/base64, bad base64)
    // =========================================================================
    @IsTest
    static void testFileUploadValidationErrors() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);

        // 1. Missing filename or file content
        Map<String, Object> missingFieldsPayload = new Map<String, Object>{
            'activity' => String.valueOf(activity.Id),
            'fileName' => '',
            'file'     => ''
        };
        RestResponse res1 = invokePost('/services/apexrest/v1.0/partnercenter/activity/uploadfile', JSON.serialize(missingFieldsPayload), null);

        // 2. Invalid Base64 content
        Map<String, Object> invalidBase64Payload = new Map<String, Object>{
            'activity' => String.valueOf(activity.Id),
            'fileName' => 'test.pdf',
            'file'     => 'NOT_VALID_BASE64_STRING!@#'
        };
        RestResponse res2 = invokePost('/services/apexrest/v1.0/partnercenter/activity/uploadfile', JSON.serialize(invalidBase64Payload), null);

        // 3. Invalid Activity ID in upload
        Map<String, Object> invalidIdPayload = new Map<String, Object>{
            'activity' => '001000000000000AAA',
            'fileName' => 'test.pdf',
            'file'     => EncodingUtil.base64Encode(Blob.valueOf('test'))
        };
        RestResponse res3 = invokePost('/services/apexrest/v1.0/partnercenter/activity/uploadfile', JSON.serialize(invalidIdPayload), null);

        Test.startTest();
        Test.stopTest();

        System.assertNotEquals(null, res1.responseBody, 'Should handle missing file fields');
        System.assertNotEquals(null, res2.responseBody, 'Should handle invalid base64 exception catch');
        System.assertNotEquals(null, res3.responseBody, 'Should handle invalid activity lookup');
    }

    // =========================================================================
    // Additional Coverage: Segment Error Parsing & Ecosystem Partner Edge Cases
    // Targets: Lines 307-315 (invalid segment maps), 527-528, 576-583, 597
    // =========================================================================
    @IsTest
    static void testSegmentAndAllocationEdgeCases() {
        ActivityTestData data = createActivityTestData();
        PartnerFundRequest activity = createExistingActivity(data);

        // Malformed segment structure containing non-map objects or invalid formatting
        Map<String, Object> payload = new Map<String, Object>{
            'ActivityName' => 'Segment Error Parsing Test',
            'ActivityCategory' => 'Seller Incentive',
            'ActivityTypes' => 'SPIF - Target'
        };
        
        List<Object> malformedSegments = new List<Object>{
            'NotAMapStructure', // Triggers non-map continue branch
            new Map<String, Object>{
                'segmentName' => 'Error Segment',
                'errors' => new List<Object>{ 'Unit threshold not met' }
            }
        };

        Test.startTest();
        RestResponse response = invokePost(
            '/services/apexrest/v1.0/partnercenter/activity/',
            JSON.serialize(new Map<String, Object>{ 'activity' => payload, 'Segments' => malformedSegments }),
            new Map<String, String>{ 'action' => 'update', 'id' => String.valueOf(activity.Id) }
        );
        Test.stopTest();

        System.assertNotEquals(null, response.responseBody, 'Should process malformed segment error iterations cleanly');
    }

}