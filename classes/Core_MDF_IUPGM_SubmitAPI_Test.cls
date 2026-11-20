@IsTest(SeeAllData=false)
public class Core_MDF_IUPGM_SubmitAPI_Test {

    // FederationIdentifier has a UNIQUE constraint — WHERE on this field
    // can never return more than one row
    private static final String TEST_FED_ID = 'iupgmtest.submit';

    @TestSetup
    static void setupData() {
        List<Profile> profiles = [
            SELECT Id
            FROM   Profile
            WHERE  Name = 'System Administrator'
            LIMIT  1
        ];
        System.assertEquals(1, profiles.size(),
            'System Administrator profile must exist');

        User u = new User(
            Alias                        = 'iupgmsb',
            Email                        = 'iupgmtest.submit@intel.com',
            EmailEncodingKey             = 'UTF-8',
            LastName                     = 'IUPGMSubmitTestUser',
            FirstName                    = 'Test',
            LanguageLocaleKey            = 'en_US',
            LocaleSidKey                 = 'en_US',
            ProfileId                    = profiles[0].Id,
            TimeZoneSidKey               = 'America/Los_Angeles',
            UserName                     = 'iupgmtest.submit@CoreMDF.com',
            FederationIdentifier         = TEST_FED_ID,
            UserPermissionsMarketingUser = true
        );
        insert u;
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    /**
     * Queries the test user by FederationIdentifier.
     * UNIQUE constraint makes >1 row physically impossible.
     */
    private static User testUser() {
        return [
            SELECT Id, Email, FederationIdentifier
            FROM   User
            WHERE  FederationIdentifier = :TEST_FED_ID
            LIMIT  1
        ];
    }

    private static String callSubmit(Map<String, Object> payload) {
        RestRequest  req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI  = '/services/apexrest/access/submitRequest';
        req.httpMethod  = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request  = req;
        RestContext.response = res;
        return Core_MDF_IUPGM_SubmitAPI.submitRequest();
    }

    private static String callSubmitRaw(String rawBody) {
        RestRequest  req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI  = '/services/apexrest/access/submitRequest';
        req.httpMethod  = 'POST';
        req.requestBody = Blob.valueOf(rawBody);
        RestContext.request  = req;
        RestContext.response = res;
        return Core_MDF_IUPGM_SubmitAPI.submitRequest();
    }

    private static Map<String, Object> parse(String raw) {
        return (Map<String, Object>) JSON.deserializeUntyped(raw);
    }

    // =========================================================================
    // 1. Empty body → 400
    // =========================================================================
    @IsTest
    static void testEmptyBody() {
        RestRequest  req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI  = '/services/apexrest/access/submitRequest';
        req.httpMethod  = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request  = req;
        RestContext.response = res;

        Test.startTest();
        String result = Core_MDF_IUPGM_SubmitAPI.submitRequest();
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(false, r.get('success'), 'Empty body → success=false');
        System.assertEquals(400,   res.statusCode,   'Empty body → 400');
    }

    // =========================================================================
    // 2. Missing required fields → 400
    // =========================================================================
    @IsTest
    static void testMissingRequiredFields() {
        Map<String, Object> payload = new Map<String, Object>{
            'requestSummary' => new Map<String, Object>{
                'userId'  => null,
                'program' => null
            }
        };

        Test.startTest();
        String result = callSubmit(payload);
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(false, r.get('success'),
            'Missing fields → success=false');
        System.assertEquals(400, RestContext.response.statusCode,
            'Missing fields → 400');
    }

    // =========================================================================
    // 3. Missing permissionSetName → 400
    // =========================================================================
    @IsTest
    static void testMissingPermissionSetName() {
        User u = testUser();

        Map<String, Object> payload = new Map<String, Object>{
            'requestSummary' => new Map<String, Object>{
                'userId'  => String.valueOf(u.Id),
                'program' => 'Intel Partner Alliance'
            }
        };

        Test.startTest();
        String result = callSubmit(payload);
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(false, r.get('success'),
            'Missing psName → success=false');
        System.assertEquals(400, RestContext.response.statusCode,
            'Missing psName → 400');
    }

    // =========================================================================
    // 4. Duplicate in-flight → 409
    // =========================================================================
    @IsTest
    static void testDuplicateInFlight() {
        User u = testUser();

        insert new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Budget_Approver_PS',
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'New',
            Core_MDF_Is_IUPGM_Processed__c         = false
        );

        Map<String, Object> payload = new Map<String, Object>{
            'requestSummary' => new Map<String, Object>{
                'userId'            => String.valueOf(u.Id),
                'program'           => 'Intel Partner Alliance',
                'permissionSetName' => 'IPA_Budget_Approver_PS',
                'userName'          => 'Test User',
                'allAccountAccess'  => true,
                'geo'               => 'WW'
            }
        };

        Test.startTest();
        String result = callSubmit(payload);
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(false, r.get('success'),
            'Duplicate → success=false');
        System.assertEquals(409, RestContext.response.statusCode,
            'Duplicate → 409');
        System.assertEquals(true, r.get('duplicate'),
            'Duplicate flag must be set');
        System.assertNotEquals(null, r.get('requestNumber'),
            'Existing request number returned');
    }
    
    // =========================================================================
    // 7. Bulk empty array → 400
    // =========================================================================
    @IsTest
    static void testBulkEmptyArray() {
        Map<String, Object> payload = new Map<String, Object>{
            'requestSummaries' => new List<Object>()
        };

        Test.startTest();
        String result = callSubmit(payload);
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(false, r.get('success'),
            'Empty bulk array → success=false');
        System.assertEquals(400, RestContext.response.statusCode,
            'Empty bulk array → 400');
    }

    // =========================================================================
    // 8. Bulk submit success
    // =========================================================================
    @IsTest
    static void testBulkSubmitSuccess() {
        User u = testUser();

        List<Object> summaries = new List<Object>{
            new Map<String, Object>{
                'userId'            => String.valueOf(u.Id),
                'program'           => 'Intel Partner Alliance',
                'permissionSetName' => 'IPA_Read_Only_PS',
                'agsRoleName'       => 'IPA AGS Read Only',
                'userName'          => 'Test User',
                'userEmail'         => 'testuser@intel.com',
                'allAccountAccess'  => true,
                'geo'               => 'WW'
            }
        };

        Map<String, Object> payload = new Map<String, Object>{
            'requestSummaries' => summaries
        };

        Test.startTest();
        String result = callSubmit(payload);
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(true, r.get('success'),
            'Bulk submit should succeed: ' + result);
        System.assertEquals(true, r.get('bulkMode'),
            'bulkMode flag must be true');
        System.assertNotEquals(null, r.get('batchRequestId'),
            'batchRequestId must be returned');
        System.assertEquals(1, (Integer) r.get('totalUsers'),
            'totalUsers must be 1');

    }

    // =========================================================================
    // 9. Bulk submit duplicate
    // =========================================================================
    @IsTest
    static void testBulkSubmitDuplicate() {
        User u = testUser();

        insert new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c         = u.Id,
            Core_MDF_IUPGM_Program__c      = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c      = 'IPA_Read_Only_PS',
            Core_MDF_Request_Status_nm__c  = 'New',
            Core_MDF_Is_IUPGM_Processed__c = false
        );

        List<Object> summaries = new List<Object>{
            new Map<String, Object>{
                'userId'            => String.valueOf(u.Id),
                'program'           => 'Intel Partner Alliance',
                'permissionSetName' => 'IPA_Read_Only_PS',
                'agsRoleName'       => 'IPA AGS Read Only',
                'userName'          => 'Test User',
                'userEmail'         => 'testuser@intel.com',
                'allAccountAccess'  => true,
                'geo'               => 'WW'
            }
        };

        Map<String, Object> payload = new Map<String, Object>{
            'requestSummaries' => summaries
        };

        Test.startTest();
        String result = callSubmit(payload);
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(true,  r.get('success'),
            'Bulk response is still success=true');
        System.assertEquals(true,  r.get('bulkMode'),
            'bulkMode=true');
        System.assertEquals(0, (Integer) r.get('submitted'),
            'submitted=0');
        System.assertEquals(1, (Integer) r.get('duplicates'),
            'duplicates=1');

        List<Object> results = (List<Object>) r.get('results');
        Map<String, Object> entry = (Map<String, Object>) results[0];
        System.assertEquals(true,  entry.get('duplicate'),
            'Entry duplicate=true');
        System.assertEquals(false, entry.get('success'),
            'Entry success=false');
    }

    // =========================================================================
    // 10. Bulk submit incomplete summary → failed=1
    // =========================================================================
    @IsTest
    static void testBulkSubmitIncompleteSummary() {
        List<Object> summaries = new List<Object>{
            new Map<String, Object>{
                'userId'  => null,
                'program' => null
            }
        };

        Map<String, Object> payload = new Map<String, Object>{
            'requestSummaries' => summaries
        };

        Test.startTest();
        String result = callSubmit(payload);
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(true, r.get('success'),
            'Bulk always returns success=true');
        System.assertEquals(0, (Integer) r.get('submitted'),
            'submitted=0');
        System.assertEquals(1, (Integer) r.get('failed'),
            'failed=1');

        List<Object> results = (List<Object>) r.get('results');
        Map<String, Object> entry = (Map<String, Object>) results[0];
        System.assertEquals(false, entry.get('success'),
            'Entry success=false');
        System.assert(
            String.valueOf(entry.get('error')).contains('Incomplete'),
            'Error message mentions Incomplete'
        );
    }

    // =========================================================================
    // 11. Requestor email fallback
    // =========================================================================
   @IsTest
    static void testRequestorEmailFallback() {
        User u = testUser();

        Map<String, Object> payload = new Map<String, Object>{
            'requestSummary' => new Map<String, Object>{
                'userId'            => String.valueOf(u.Id),
                'program'           => 'Intel Partner Alliance',
                'permissionSetName' => 'IPA_Read_Only_PS',
                'agsRoleName'       => 'IPA AGS Read Only',
                'allAccountAccess'  => true,
                'geo'               => 'WW'
            }
        };

        Test.startTest();
        String result = callSubmit(payload);
        Test.stopTest();

        Map<String, Object> r = parse(result);
     
        List<Core_MDF_IUPGM_Request_Staging__c> recs = [
            SELECT Core_MDF_Requestor_Email__c
            FROM   Core_MDF_IUPGM_Request_Staging__c
            WHERE  Core_MDF_IUPGM_User__c = :u.Id
            LIMIT  1
        ];
    }   

    // =========================================================================
    // 12. Invalid JSON body → 500
    // =========================================================================
    @IsTest
    static void testInvalidJsonBody() {
        Test.startTest();
        String result = callSubmitRaw('{ this is not valid json }');
        Test.stopTest();

        Map<String, Object> r = parse(result);
        System.assertEquals(false, r.get('success'),
            'Invalid JSON → success=false');
        System.assertEquals(500, RestContext.response.statusCode,
            'Invalid JSON → 500');
    }
}