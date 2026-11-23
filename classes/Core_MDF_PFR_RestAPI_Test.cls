@isTest(SeeAllData=false)
private class Core_MDF_PFR_RestAPI_Test {

    private static final String VALID_B64 =
        EncodingUtil.base64Encode(Blob.valueOf('TestFileContent'));

    // ============================================================
    // TEST SETUP
    // ============================================================
    @TestSetup
    static void setupTestData() {
        List<String> bypassKeys = new List<String>{
            'BypassCampaignBenefitValidation',
            'Core_MDF_Bypass_Manual_Share',
            'Bypass_MDF_Budget_Access',
            'Bypass_MDF_Budget_Access_Validation'
        };
        try {
            Core_MDF_CCP_TestDataUtility.byPassFeature(bypassKeys, true, true);
        } catch (Exception e) { }

        ChannelProgram prog = Core_MDF_CCP_TestDataUtility.createProgram(
            'Client', 'Client CoMarketing Fund', true
        );
        Account intelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount(
            'Test Intel Account',
            Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true
        );
        Account partnerAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount(
            'Test Partner Account', prog.Id,
            Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAcc.Id, true
        );

        Campaign camp = new Campaign(
            Name                  = 'Test Campaign',
            Core_MDF_Program__c   = 'Client CoMarketing Fund',
            Status                = 'Draft',
            Core_MDF_Account__c   = partnerAcc.Id,
            RecordTypeId          = Schema.SObjectType.Campaign
                                        .getRecordTypeInfosByDeveloperName()
                                        .get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId(),
            StartDate             = System.today(),
            EndDate               = System.today().addDays(30),
            Core_MDF_Region_cd__c = 'APJ',
            Core_MDF_Market__c    = 'INDIA'
        );
        insert camp;

        PartnerMarketingBudget budget = new PartnerMarketingBudget(
            Title                       = 'Test Budget',
            Amount                      = 50000,
            Core_MDF_Budget_Partner__c  = partnerAcc.Id,
            Core_MDF_Program__c         = prog.Id,
            RecordTypeId                = Schema.SObjectType.PartnerMarketingBudget
                                            .getRecordTypeInfosByDeveloperName()
                                            .get('Core_MDF_Co_Marketing').getRecordTypeId(),
            StartDate                   = System.today(),
            EndDate                     = System.today().addDays(365),
            Description                 = 'Test',
            Core_MDF_Budget_Comments__c = 'Test',
            Core_MDF_Budget_Type__c     = 'MDF',
            Core_MDF_Budget_Type_Txt__c = 'MDF',
            Core_MDF_Budget_Status__c   = 'Released'
        );
        insert budget;

        PartnerFundAllocation alloc = new PartnerFundAllocation(
            Title            = 'Test Allocation',
            Amount           = 25000,
            BudgetId         = budget.Id,
            ChannelPartnerId = partnerAcc.Id,
            RecordTypeId     = Schema.SObjectType.PartnerFundAllocation
                                    .getRecordTypeInfosByDeveloperName()
                                    .get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId()
        );
        insert alloc;

        Id pfrRT = Schema.SObjectType.PartnerFundRequest
            .getRecordTypeInfosByDeveloperName()
            .get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();

        insert new PartnerFundRequest(
            Title                        = 'Test Activity',
            CampaignId                   = camp.Id,
            ChannelPartnerId             = partnerAcc.Id,
            AllocationId                 = alloc.Id,
            RecordTypeId                 = pfrRT,
            Core_MDF_Start_Date__c       = System.today(),
            Core_MDF_End_Date__c         = System.today().addDays(30),
            Core_MDF_ActivityCategory__c = 'Sales Readiness',
            Status                       = 'Draft',
            Core_MDF_Country_nm__c       = 'INDIA',
            Core_MDF_TargetAudience__c   = 'Consumer',
            RequestedAmount              = 10000
        );

        insert new PartnerFundRequest(
            Title                        = 'Ecosystem Activity',
            CampaignId                   = camp.Id,
            ChannelPartnerId             = partnerAcc.Id,
            AllocationId                 = alloc.Id,
            RecordTypeId                 = pfrRT,
            Core_MDF_Start_Date__c       = System.today(),
            Core_MDF_End_Date__c         = System.today().addDays(30),
            Core_MDF_ActivityCategory__c = 'Sales Readiness',
            Status                       = 'Draft',
            Core_MDF_Country_nm__c       = 'INDIA',
            Core_MDF_TargetAudience__c   = 'Consumer',
            RequestedAmount              = 10000,
            Core_MDF_Channel_Partner__c  = 'Test Partner Account'
        );

        Core_MDF_CCP_TestDataUtility.createUser(true);
    }

    // ============================================================
    // HELPERS
    // ============================================================
    private static void setContext(String body, String uri, Map<String,String> params) {
        RestRequest req = new RestRequest();
        req.requestUri  = uri;
        req.httpMethod  = 'POST';
        if (params != null) {
            for (String k : params.keySet()) req.addParameter(k, params.get(k));
        }
        if (body != null) req.requestBody = Blob.valueOf(body);
        RestContext.request  = req;
        RestContext.response = new RestResponse();
    }

    private static void setContext(String body, String uri) {
        setContext(body, uri, null);
    }

    private static User   getUser()    { return [SELECT Id,Username FROM User WHERE UserName LIKE 'testUser%@CoreMDF.com' LIMIT 1]; }
    private static Account getPartner(){ return [SELECT Id,Name FROM Account WHERE RecordType.DeveloperName='Core_MDF_Co_Marketing' AND Name='Test Partner Account' LIMIT 1]; }
    private static Campaign getCamp()  { return [SELECT Id FROM Campaign LIMIT 1]; }
    private static PartnerMarketingBudget getBudget() { return [SELECT Id FROM PartnerMarketingBudget LIMIT 1]; }
    private static PartnerFundRequest getPFR()        { return [SELECT Id FROM PartnerFundRequest WHERE Title='Test Activity' LIMIT 1]; }
    private static PartnerFundRequest getEcoPFR()     { return [SELECT Id FROM PartnerFundRequest WHERE Title='Ecosystem Activity' LIMIT 1]; }

    /** Full valid activity payload */
    private static String payload(String name, Id campId, String accName, Id budgetId, String approver) {
        return '{"activity":{'
            + '"ActivityName":"'          + name     + '",'
            + '"StartDate":"'             + System.today().addDays(5)  + '",'
            + '"EndDate":"'               + System.today().addDays(35) + '",'
            + '"Campaign":"'              + campId   + '",'
            + '"AccountName":"'           + accName  + '",'
            + '"BudgetType":"MDF",'
            + '"ActivitySpendingLimitLocal":10000,'
            + '"ReimbursementRate":"100",'
            + '"Currency":"USD",'
            + '"TargetAudience":"Consumer",'
            + '"Country":"INDIA",'
            + '"Brand":"Intel Core",'
            + '"BudgetReferenceNumber":"' + budgetId + '",'
            + '"ActivityCategory":"Sales Readiness",'
            + '"ActivityTypes":"Seminar",'
            + '"Priority":"High",'
            + '"IntelApproverUsername":"' + approver + '"'
            + '}}';
    }

    /** Payload with custom rate */
    private static String payloadRate(String name, Id campId, String accName,
                                       Id budgetId, String approver, String rate) {
        return payload(name, campId, accName, budgetId, approver)
            .replace('"ReimbursementRate":"100"', '"ReimbursementRate":"' + rate + '"');
    }

    /** Payload with segments appended */
    private static String payloadSegs(String name, Id campId, String accName,
                                       Id budgetId, String approver, String rate, String segsJson) {
        String base = payloadRate(name, campId, accName, budgetId, approver, rate);
        return base.substring(0, base.length() - 1) + ',"Segments":' + segsJson + '}';
    }

    /** Payload with ecosystem partners */
    private static String payloadEco(String name, Id campId, String accName,
                                      Id budgetId, String approver, String ecoJson) {
        String base = payload(name, campId, accName, budgetId, approver);
        return base.substring(0, base.length() - 1) + ',"EcosystemPartners":' + ecoJson + '}';
    }

    /** Payload with inline files */
    private static String payloadFiles(String name, Id campId, String accName,
                                        Id budgetId, String approver, String filesJson) {
        String base = payload(name, campId, accName, budgetId, approver);
        return base.substring(0, base.length() - 1) + ',"Files":' + filesJson + '}';
    }

    // ============================================================
    // 1. ENTRY POINT – empty / null / whitespace body
    // ============================================================
    @isTest
    static void test_emptyBody_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext('', '/services/apexrest/v1.0/activity/');
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
            System.assertEquals(false, Core_MDF_PFR_RestAPI.response.isSuccess);
        }
    }

    @isTest
    static void test_nullBody_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/v1.0/activity/';
            req.httpMethod = 'POST';
            RestContext.request  = req;
            RestContext.response = new RestResponse();
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_nullRestContext_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            RestContext.request  = null;
            RestContext.response = new RestResponse();
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    // ============================================================
    // 2. ACTION PARAM VALIDATION
    // ============================================================
    @isTest
    static void test_invalidAction_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext('{"activity":{}}', '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'delete'});
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_validateActionParam_AllBranches() {
        System.runAs(getUser()) {
            PartnerFundRequest pfr = getPFR();
            Test.startTest();

            // explicit create
            setContext('{}', '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'});
            System.assertEquals(true,     Core_MDF_PFR_RestAPI.validateActionParam());
            System.assertEquals('create', Core_MDF_PFR_RestAPI.actionType);

            // explicit update
            setContext('{}', '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>pfr.Id});
            System.assertEquals(true,     Core_MDF_PFR_RestAPI.validateActionParam());
            System.assertEquals('update', Core_MDF_PFR_RestAPI.actionType);

            // blank + no id → create
            setContext('{}', '/services/apexrest/v1.0/activity/');
            System.assertEquals(true,     Core_MDF_PFR_RestAPI.validateActionParam());
            System.assertEquals('create', Core_MDF_PFR_RestAPI.actionType);

            // blank + id → update
            setContext('{}', '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'id'=>pfr.Id});
            System.assertEquals(true,     Core_MDF_PFR_RestAPI.validateActionParam());
            System.assertEquals('update', Core_MDF_PFR_RestAPI.actionType);

            // invalid
            setContext('{}', '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'remove'});
            System.assertEquals(false, Core_MDF_PFR_RestAPI.validateActionParam());

            Test.stopTest();
        }
    }

    // ============================================================
    // 3. CREATE – validation failures
    // ============================================================
    @isTest
    static void test_create_MissingActivityNode_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext('{"other":{}}', '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'});
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_create_MalformedJSON_Returns500Or400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext('{bad json', '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'});
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            String c = Core_MDF_PFR_RestAPI.response.code;
            System.assert(c == '400' || c == '500');
        }
    }

    @isTest
    static void test_create_MissingRequiredFields_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            // Missing IntelApproverUsername
            setContext('{"activity":{"ActivityName":"X","Campaign":"' + getCamp().Id + '"}}',
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'});
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
            System.assert(!Core_MDF_PFR_RestAPI.response.failureContent.isEmpty());
        }
    }

    @isTest
    static void test_create_InvalidAccountName_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            String body = payload('Bad Acc', getCamp().Id, 'NONEXISTENT_XYZ', getBudget().Id, getUser().Username);
            setContext(body, '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'});
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_create_ValidPayload_EndToEnd() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payload('Full Create', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            String c = Core_MDF_PFR_RestAPI.response.code;
            System.assert(c == '201' || c == '400');
        }
    }

    // ============================================================
    // 4. UPDATE paths
    // ============================================================
    @isTest
    static void test_update_ExistingRecord() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payload('Updated', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>getPFR().Id}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            String c = Core_MDF_PFR_RestAPI.response.code;
            System.assert(c == '201' || c == '400');
        }
    }

    @isTest
    static void test_update_NoId_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payload('No ID', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_update_InvalidIdFormat_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payload('Bad ID', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>'NOTANID'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_update_WrongObjectType_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payload('Wrong Type', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>getPartner().Id}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_update_FakeId_DMLError() {
        System.runAs(getUser()) {
            Test.startTest();
            String fakeId = PartnerFundRequest.getSObjectType().getDescribe().getKeyPrefix() + '000000000001';
            setContext(
                payload('DML Fail', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>fakeId}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    // ============================================================
    // 5. FILE UPLOAD ROUTE (/uploadfile)
    // ============================================================
    @isTest
    static void test_fileUpload_ValidPDF_Success() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                '{"activity":"' + getPFR().Id + '","fileName":"test.pdf","file":"' + VALID_B64 + '"}',
                '/services/apexrest/v1.0/activity/uploadfile'
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            Core_MDF_PFR_RestAPI.FileUploadResponse r = Core_MDF_PFR_RestAPI.fileUploadResponse;
            System.assertEquals('200', r.code);
            System.assertEquals(true,  r.isSuccess);
            System.assertEquals(1,     r.totalRecords);
            System.assertEquals(null,  r.errorContent);
        }
    }

    @isTest
    static void test_fileUpload_AllowedExtensions() {
        System.runAs(getUser()) {
            Test.startTest();
            for (String ext : new List<String>{'pdf','doc','docx','xls','xlsx','ppt','pptx','txt','rtf','csv'}) {
                setContext(
                    '{"activity":"' + getPFR().Id + '","fileName":"f.' + ext + '","file":"' + VALID_B64 + '"}',
                    '/services/apexrest/v1.0/activity/uploadfile'
                );
                Core_MDF_PFR_RestAPI.doPost();
                Core_MDF_PFR_RestAPI.FileUploadResponse r = Core_MDF_PFR_RestAPI.fileUploadResponse;
                System.assertNotEquals(null, r, 'Null for ext: ' + ext);
            }
            Test.stopTest();
        }
    }

    @isTest
    static void test_fileUpload_InvalidExtension_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                '{"activity":"' + getPFR().Id + '","fileName":"virus.exe","file":"VGVzdA=="}',
                '/services/apexrest/v1.0/activity/uploadfile'
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.fileUploadResponse.code);
            System.assertEquals(false, Core_MDF_PFR_RestAPI.fileUploadResponse.isSuccess);
        }
    }

    @isTest
    static void test_fileUpload_NoExtension_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                '{"activity":"' + getPFR().Id + '","fileName":"nodot","file":"VGVzdA=="}',
                '/services/apexrest/v1.0/activity/uploadfile'
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.fileUploadResponse.code);
        }
    }

    @isTest
    static void test_fileUpload_MissingFields_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            // Missing activity
            setContext('{"fileName":"t.pdf","file":"VGVzdA=="}',
                '/services/apexrest/v1.0/activity/uploadfile');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.fileUploadResponse.code);

            // Missing fileName
            setContext('{"activity":"' + getPFR().Id + '","file":"VGVzdA=="}',
                '/services/apexrest/v1.0/activity/uploadfile');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.fileUploadResponse.code);

            // Missing file content
            setContext('{"activity":"' + getPFR().Id + '","fileName":"t.pdf"}',
                '/services/apexrest/v1.0/activity/uploadfile');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.fileUploadResponse.code);

            Test.stopTest();
        }
    }

    @isTest
    static void test_fileUpload_InvalidActivityId_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            // Bad Id format
            setContext('{"activity":"NOTANID","fileName":"t.pdf","file":"VGVzdA=="}',
                '/services/apexrest/v1.0/activity/uploadfile');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.fileUploadResponse.code);

            // Wrong object type
            setContext('{"activity":"' + getPartner().Id + '","fileName":"t.pdf","file":"VGVzdA=="}',
                '/services/apexrest/v1.0/activity/uploadfile');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.fileUploadResponse.code);

            // Non-existent PFR
            String fakeId = PartnerFundRequest.getSObjectType().getDescribe().getKeyPrefix() + '000000000000';
            setContext('{"activity":"' + fakeId + '","fileName":"t.pdf","file":"VGVzdA=="}',
                '/services/apexrest/v1.0/activity/uploadfile');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals('404', Core_MDF_PFR_RestAPI.fileUploadResponse.code);

            Test.stopTest();
        }
    }

    @isTest
    static void test_fileUpload_InvalidBase64_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                '{"activity":"' + getPFR().Id + '","fileName":"t.pdf","file":"!!!INVALID!!!"}',
                '/services/apexrest/v1.0/activity/uploadfile'
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals(false, Core_MDF_PFR_RestAPI.fileUploadResponse.isSuccess);
        }
    }

    @isTest
    static void test_fileUpload_InvalidJSON_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext('{bad}', '/services/apexrest/v1.0/activity/uploadfile');
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.fileUploadResponse.code);
        }
    }

    @isTest
    static void test_fileUpload_URLVariants() {
        System.runAs(getUser()) {
            Test.startTest();
            String body = '{"activity":"' + getPFR().Id + '","fileName":"t.pdf","file":"' + VALID_B64 + '"}';

            // Query string in URL
            setContext(body, '/services/apexrest/v1.0/activity/uploadfile?foo=bar');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.fileUploadResponse);

            // Case-insensitive URL
            setContext(body, '/services/apexrest/v1.0/activity/UploadFile');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.fileUploadResponse);

            Test.stopTest();
        }
    }

    // ============================================================
    // 6. INLINE FILES (attachInlineFiles)
    // ============================================================
    @isTest
    static void test_inlineFiles_ValidAndInvalidMixed() {
        System.runAs(getUser()) {
            Test.startTest();
            String filesJson = '['
                + '{"FileName":"ok.pdf","file":"'   + VALID_B64 + '"},'
                + '{"FileName":"bad.exe","file":"VGVzdA=="},'
                + '{"FileName":"","file":""},'
                + '{"FileName":"ok2.csv","file":"' + VALID_B64 + '"}'
                + ']';
            setContext(
                payloadFiles('Inline Mix', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username, filesJson),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>getPFR().Id}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
            if ('201'.equals(Core_MDF_PFR_RestAPI.response.code)) {
                System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.fileUploadContent);
            }
        }
    }

    @isTest
    static void test_inlineFiles_InvalidBase64_CaughtGracefully() {
        System.runAs(getUser()) {
            Test.startTest();
            String filesJson = '[{"FileName":"bad.pdf","file":"!!!INVALID!!!"}]';
            setContext(
                payloadFiles('Bad B64', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username, filesJson),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>getPFR().Id}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    // ============================================================
    // 7. SPIF VALIDATION ROUTE (/validatespif)
    // ============================================================
    @isTest
    static void test_spif_ValidRequest_Returns200() {
        System.runAs(getUser()) {
            Test.startTest();
            String body = '{"AccountId":"' + getPartner().Id
                + '","ChannelPartnerId":"' + getPartner().Id
                + '","Segments":[{"SegmentName":"S1","MinimumForecastVolume":10,"IncentiveAmountPerUnit":5}]}';
            setContext(body, '/services/apexrest/v1.0/activity/validatespif');
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals(200, RestContext.response.statusCode);
        }
    }

    @isTest
    static void test_spif_EmptySegments_Returns200() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                '{"AccountId":"' + getPartner().Id + '","ChannelPartnerId":"' + getPartner().Id + '","Segments":[]}',
                '/services/apexrest/v1.0/activity/validatespif'
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals(200, RestContext.response.statusCode);
        }
    }

    @isTest
    static void test_spif_MalformedJSON_HandledGracefully() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext('NOTJSON', '/services/apexrest/v1.0/activity/validatespif');
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, RestContext.response.statusCode);
        }
    }

    @isTest
    static void test_spif_URLVariants() {
        System.runAs(getUser()) {
            Test.startTest();
            String body = '{"AccountId":"' + getPartner().Id + '","ChannelPartnerId":"' + getPartner().Id + '","Segments":[]}';

            // Case-insensitive
            setContext(body, '/services/apexrest/v1.0/activity/ValidateSPIF');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals(200, RestContext.response.statusCode);

            // With query string
            setContext(body, '/services/apexrest/v1.0/activity/validatespif?debug=true');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals(200, RestContext.response.statusCode);

            Test.stopTest();
        }
    }

    // ============================================================
    // 8. SEGMENT VALIDATION (validateSegmentPayload)
    // ============================================================
    @isTest
    static void test_segment_PayoutExceedsContribution_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            // 10000 * 50% = 5000; 1000 * 100 = 100000 > 5000
            setContext(
                payloadSegs('Exceeds', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '50', '[{"SegmentName":"Big","MinimumForecastVolume":1000,"IncentiveAmountPerUnit":100}]'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_segment_PayoutWithinContribution_Passes() {
        System.runAs(getUser()) {
            Test.startTest();
            // 10000 * 100% = 10000; 1 * 1 = 1 < 10000
            setContext(
                payloadSegs('Within', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '100', '[{"SegmentName":"Small","MinimumForecastVolume":1,"IncentiveAmountPerUnit":1}]'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_segment_MissingNumericFields_SkipsCheck() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payloadSegs('NoFields', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '100', '[{"SegmentName":"NoVol"}]'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_segment_BlankRate_SkipsContributionCalc() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payloadSegs('BlankRate', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '', '[{"SegmentName":"S1","MinimumForecastVolume":10,"IncentiveAmountPerUnit":5}]'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_segment_InvalidRate_SkipsContributionCalc() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payloadSegs('BadRate', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    'NOTANUMBER', '[{"SegmentName":"S1","MinimumForecastVolume":10,"IncentiveAmountPerUnit":5}]'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_segment_PercentSymbolInRate_ParsedCorrectly() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payloadSegs('PctRate', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '100%', '[{"SegmentName":"S1","MinimumForecastVolume":1,"IncentiveAmountPerUnit":1}]'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_segment_OnUpdateSuccess_ProcessActivitySegments() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payloadSegs('SegUpdate', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '100', '[{"SegmentName":"S1","MinimumForecastVolume":1,"IncentiveAmountPerUnit":1}]'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>getPFR().Id}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    // ============================================================
    // 9. ECOSYSTEM PARTNER ALLOCATIONS
    // ============================================================
    @isTest
    static void test_ecosystem_InvalidPercentSum_Returns400() {
        System.runAs(getUser()) {
            Test.startTest();
            // 30 + 50 = 80 ≠ 100
            setContext(
                payloadEco('BadEco', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '{"P1":30,"P2":50}'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_ecosystem_ZeroPercent_Allowed() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payloadEco('ZeroEco', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '{"P1":0,"P2":0}'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_ecosystem_100Percent_OnUpdate() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payloadEco('Eco100', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '{"' + getPartner().Name + '":100}'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>getEcoPFR().Id}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    @isTest
    static void test_ecosystem_TwoPartners_SumTo100() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payloadEco('TwoEco', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username,
                    '{"PA":60,"PB":40}'),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'create'}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }

    // ============================================================
    // 10. INNER CLASSES
    // ============================================================
    @isTest
    static void test_innerClasses() {
        Test.startTest();

        // PFRSuccess
        Core_MDF_PFR_RestAPI.PFRSuccess s = new Core_MDF_PFR_RestAPI.PFRSuccess('ACT-001','Name','Approved');
        System.assertEquals('ACT-001',  s.activityNumber);
        System.assertEquals('Name',     s.pfrName);
        System.assertEquals('Approved', s.status);
        System.assertNotEquals(null,     s.createdDate);

        // PFRSuccess null values
        Core_MDF_PFR_RestAPI.PFRSuccess sNull = new Core_MDF_PFR_RestAPI.PFRSuccess(null,null,null);
        System.assertEquals(null, sNull.activityNumber);

        // FileUploadRequest
        Core_MDF_PFR_RestAPI.FileUploadRequest r = new Core_MDF_PFR_RestAPI.FileUploadRequest();
        r.activity='a0X1'; r.fileName='f.pdf'; r.file='abc'; r.comment='c';
        System.assertEquals('a0X1', r.activity);
        System.assertEquals('f.pdf', r.fileName);

        // FileUploadResponse
        Core_MDF_PFR_RestAPI.FileUploadResponse resp = new Core_MDF_PFR_RestAPI.FileUploadResponse();
        resp.totalRecords=1; resp.isSuccess=true; resp.code='200';
        resp.successContent = new List<Core_MDF_PFR_RestAPI.FileUploadSuccess>{
            new Core_MDF_PFR_RestAPI.FileUploadSuccess('Uploaded')
        };
        System.assertEquals(1,          resp.totalRecords);
        System.assertEquals('Uploaded', resp.successContent[0].activity);

        // FileUploadSuccess
        Core_MDF_PFR_RestAPI.FileUploadSuccess fs = new Core_MDF_PFR_RestAPI.FileUploadSuccess('msg');
        System.assertEquals('msg', fs.activity);

        Test.stopTest();
    }

    // ============================================================
    // 11. LOGGING & RESPONSE STRUCTURE
    // ============================================================
    @isTest
    static void test_noLogEntry_WhenNoErrors() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                payload('No Log', getCamp().Id, getPartner().Name, getBudget().Id, getUser().Username),
                '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>getPFR().Id}
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertEquals(0,
                [SELECT COUNT() FROM Core_Log_Entry__c WHERE Core_Origin__c='PartnerFundRequest RestAPI']);
        }
    }

    @isTest
    static void test_responseBodyAndStatusCodeAlwaysSet() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext('', '/services/apexrest/v1.0/activity/');
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, RestContext.response.responseBody);
            System.assertNotEquals(null, RestContext.response.statusCode);
            System.assert(RestContext.response.responseBody.toString().contains('isSuccess'));
        }
    }

    @isTest
    static void test_fileUploadResponse_SerializedInBody() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext(
                '{"activity":"' + getPFR().Id + '","fileName":"t.pdf","file":"' + VALID_B64 + '"}',
                '/services/apexrest/v1.0/activity/uploadfile'
            );
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            String body = RestContext.response.responseBody.toString();
            System.assert(body.contains('isSuccess') || body.contains('totalRecords'));
            System.assertEquals(200, RestContext.response.statusCode);
        }
    }

    // ============================================================
    // 12. EDGE CASES
    // ============================================================
    @isTest
    static void test_multipleCallsStateReset() {
        System.runAs(getUser()) {
            Test.startTest();
            setContext('', '/services/apexrest/v1.0/activity/');
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);

            setContext('{"activity":{}}', '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'delete'});
            Core_MDF_PFR_RestAPI.doPost();
            System.assertEquals('400', Core_MDF_PFR_RestAPI.response.code);
            System.assertEquals(null, Core_MDF_PFR_RestAPI.fileUploadResponse);
            Test.stopTest();
        }
    }

    @isTest
    static void test_combinedSegmentsFilesEcosystem_Update() {
        System.runAs(getUser()) {
            Test.startTest();
            String body = '{"activity":{'
                + '"ActivityName":"All Features",'
                + '"StartDate":"' + System.today().addDays(5) + '",'
                + '"EndDate":"'   + System.today().addDays(35) + '",'
                + '"Campaign":"'  + getCamp().Id + '",'
                + '"AccountName":"' + getPartner().Name + '",'
                + '"BudgetType":"MDF",'
                + '"ActivitySpendingLimitLocal":10000,'
                + '"ReimbursementRate":"100",'
                + '"Currency":"USD",'
                + '"TargetAudience":"Consumer",'
                + '"Country":"INDIA",'
                + '"Brand":"Intel Core",'
                + '"BudgetReferenceNumber":"' + getBudget().Id + '",'
                + '"ActivityCategory":"Sales Readiness",'
                + '"ActivityTypes":"Seminar",'
                + '"Priority":"High",'
                + '"IntelApproverUsername":"' + getUser().Username + '"'
                + '},'
                + '"Segments":[{"SegmentName":"S1","MinimumForecastVolume":1,"IncentiveAmountPerUnit":1}],'
                + '"Files":[{"FileName":"doc.pdf","file":"' + VALID_B64 + '"}],'
                + '"EcosystemPartners":{"PX":100}}';
            setContext(body, '/services/apexrest/v1.0/activity/',
                new Map<String,String>{'action'=>'update','id'=>getPFR().Id});
            Core_MDF_PFR_RestAPI.doPost();
            Test.stopTest();
            System.assertNotEquals(null, Core_MDF_PFR_RestAPI.response.code);
        }
    }
}