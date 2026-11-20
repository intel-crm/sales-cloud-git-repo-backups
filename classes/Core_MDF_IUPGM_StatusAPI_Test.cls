@IsTest(SeeAllData=false)
public class Core_MDF_IUPGM_StatusAPI_Test {

    private static final String TEST_FED_ID = 'iupgmtest.status';

    @TestSetup
    static void setupData() {
        List<Profile> profiles = [
            SELECT Id
            FROM   Profile
            WHERE  Name = 'System Administrator'
            LIMIT  1
        ];
        System.assertEquals(1, profiles.size(), 'System Administrator profile must exist');

        User u = new User(
            Alias                        = 'iupgmst',
            Email                        = 'iupgmtest.status@intel.com',
            EmailEncodingKey             = 'UTF-8',
            LastName                     = 'IUPGMStatusTestUser',
            FirstName                    = 'Test',
            LanguageLocaleKey            = 'en_US',
            LocaleSidKey                 = 'en_US',
            ProfileId                    = profiles[0].Id,
            TimeZoneSidKey               = 'America/Los_Angeles',
            UserName                     = 'iupgmtest.status@CoreMDF.com',
            FederationIdentifier         = TEST_FED_ID,
            UserPermissionsMarketingUser = true
        );
        insert u;

        Core_MDF_IUPGM_Request_Staging__c staging =
            new Core_MDF_IUPGM_Request_Staging__c(
                Core_MDF_IUPGM_User__c         = u.Id,
                Core_MDF_IUPGM_Program__c      = 'Intel Partner Alliance',
                Core_MDF_IUPGM_Role_nm__c      = 'IPA_Read_Only_PS',
                Core_MDF_Request_Status_nm__c  = 'New',
                Core_MDF_Is_IUPGM_Processed__c = false
            );
        insert staging;
    }

    private static User testUser() {
        return [
            SELECT Id, Email, FederationIdentifier
            FROM   User
            WHERE  FederationIdentifier = :TEST_FED_ID
            LIMIT  1
        ];
    }

    private static Core_MDF_IUPGM_Request_Staging__c getStaging() {
        User u = testUser();
        return [
            SELECT Id, Name,
                   Core_MDF_Request_Status_nm__c,
                   Core_MDF_Error_Message_txt__c
            FROM   Core_MDF_IUPGM_Request_Staging__c
            WHERE  Core_MDF_IUPGM_User__c = :u.Id
            LIMIT  1
        ];
    }

    private static String callStatus(String requestNumber) {
        RestRequest  req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/access/fetchstatus';
        req.httpMethod = 'GET';
        if (String.isNotBlank(requestNumber)) {
            req.addParameter('requestNumber', requestNumber);
        }
        RestContext.request  = req;
        RestContext.response = res;
        return Core_MDF_IUPGM_StatusAPI.getStatus();
    }

    private static Map<String, Object> parse(String raw) {
        return (Map<String, Object>) JSON.deserializeUntyped(raw);
    }

    private static void setStatus(Id recId, String status, String errorMsg) {
        update new Core_MDF_IUPGM_Request_Staging__c(
            Id                             = recId,
            Core_MDF_Request_Status_nm__c  = status,
            Core_MDF_Error_Message_txt__c  = errorMsg,
            Core_MDF_Is_IUPGM_Processed__c = (status == 'Completed')
        );
    }

    @IsTest
    static void testMissingRequestNumber() {
        Test.startTest();
        String result = callStatus(null);
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(400, RestContext.response.statusCode, 'Should return 400');
        System.assertEquals(false, r.get('success'), 'success should be false');
    }

    @IsTest
    static void testBlankRequestNumber() {
        RestRequest  req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/access/fetchstatus';
        req.httpMethod = 'GET';
        req.addParameter('requestNumber', '   ');
        RestContext.request  = req;
        RestContext.response = res;

        Test.startTest();
        String result = Core_MDF_IUPGM_StatusAPI.getStatus();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @IsTest
    static void testNotFoundRequestNumber() {
        Test.startTest();
        String result = callStatus('REQ-99999999');
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusAGSUserCreationPending() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, 'AGS_User_Creation_Pending', null);

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusAGSPSPending() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, Core_MDF_CCP_ConstantClass.IUPGM_STATUS_AGS_PS_PENDING, null);

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusCompleted() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, Core_MDF_CCP_ConstantClass.IUPGM_STATUS_COMPLETED, null);

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusValidationFailedWithMessage() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, Core_MDF_CCP_ConstantClass.IUPGM_STATUS_VALIDATION_FAILED, 'Error message');

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusValidationFailedNoMessage() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, Core_MDF_CCP_ConstantClass.IUPGM_STATUS_VALIDATION_FAILED, null);

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusExternalUserBlocked() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, Core_MDF_CCP_ConstantClass.IUPGM_STATUS_EXTERNAL_USER_BLOCKED, null);

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusAGSRejectedWithMessage() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, Core_MDF_CCP_ConstantClass.IUPGM_STATUS_AGS_REJECTED, 'Denied');

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusAGSRejectedNoMessage() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, Core_MDF_CCP_ConstantClass.IUPGM_STATUS_AGS_REJECTED, null);

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusErrorNoMessage() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR, null);

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testStatusNew() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, 'New', null);

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode, 'Should return 200 for New status');
        Map<String, Object> r = parse(result);
        System.assertEquals('Request Received', r.get('statusLabel'), 'Status label should be Request Received');
        System.assert(
            ((String) r.get('statusDescription')).contains('queued for processing'),
            'Description should mention queueing for processing'
        );
    }

    @IsTest
    static void testStatusErrorWithMessage() {
        Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
        setStatus(rec.Id, Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR, 'A critical database error occurred.');

        Test.startTest();
        String result = callStatus(rec.Name);
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode, 'Should return 200 for Error status with message');
        Map<String, Object> r = parse(result);
        System.assertEquals('Processing Error', r.get('statusLabel'), 'Status label should be Processing Error');
        System.assert(
            r.containsKey('statusDescription'),
            'Should return status description'
        );
    }

    @IsTest
    static void testRoleLabelFromMetadataResolution() {
        List<Core_MDF_IUPGM_Rule_Config__mdt> configs = [
            SELECT Core_MDF_Permission_Set_Name__c, Core_MDF_Role_Label__c, Core_MDF_Program__c, Core_MDF_AGS_Role_Name__c 
            FROM Core_MDF_IUPGM_Rule_Config__mdt 
            WHERE Core_MDF_Permission_Set_Name__c != null 
              AND Core_MDF_Program__c != null
            LIMIT 1
        ];

        if (!configs.isEmpty()) {
            Core_MDF_IUPGM_Request_Staging__c rec = getStaging();
            Core_MDF_IUPGM_Rule_Config__mdt cfg = configs[0];
            
            String targetRole = cfg.Core_MDF_Permission_Set_Name__c;
            String targetAgsRole = cfg.Core_MDF_AGS_Role_Name__c != null ? cfg.Core_MDF_AGS_Role_Name__c : targetRole;

            update new Core_MDF_IUPGM_Request_Staging__c(
                Id = rec.Id,
                Core_MDF_IUPGM_Role_nm__c = targetRole,
                Core_MDF_AGS_Role_Name__c = targetAgsRole,
                Core_MDF_IUPGM_Program__c = cfg.Core_MDF_Program__c,
                Core_MDF_Request_Status_nm__c = 'New'
            );

            Test.startTest();
            String result = callStatus(rec.Name);
            Test.stopTest();

            System.assertEquals(200, RestContext.response.statusCode, 'Should return 200 success');
            Map<String, Object> r = parse(result);
            System.assertNotEquals(null, r.get('statusLabel'), 'Status API response should contain a status label');
        } else {
            System.assert(true, 'Skipped dynamic metadata test as no rule configs were found');
        }
    }
}