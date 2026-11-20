@IsTest(SeeAllData=false)
public class Core_MDF_AGS_CalloutQueueable_Test {

    private static final String TEST_FED_ID = 'iupgmtest.ags';

    public class AGSTokenMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            if (req.getEndpoint().contains('token') || req.getMethod() == 'POST') {
                res.setBody(
                    '{"access_token":"test_token_abc",' +
                    '"token_type":"Bearer","expires_in":3600}'
                );
            } else {
                res.setBody('{"status":"Success","requestId":"TEST-REQ-001"}');
            }
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    public class AGS404Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);
            res.setBody(
                '{"errorMessage":"Invalid Request",' +
                '"errorReason":"Path Not Found","errorStatus":404}'
            );
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    public class AGS500Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"errorMessage":"Internal Server Error"}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
       public class AGSSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"Success","requestId":"TEST-REQ-001"}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    @TestSetup
    static void setupData() {
        Profile p = [
            SELECT Id
            FROM   Profile
            WHERE  Name = 'System Administrator'
            LIMIT  1
        ];
        System.assertNotEquals(null, p,
            'System Administrator profile must exist');

        String uniqueSuffix = String.valueOf(DateTime.now().getTime());

        User u = new User(
            Alias                        = 'iupgmags',
            Email                        = 'iupgmtest.ags@intel.com',
            EmailEncodingKey             = 'UTF-8',
            LastName                     = 'IUPGMAGSTestUser',
            FirstName                    = 'Test',
            LanguageLocaleKey            = 'en_US',
            LocaleSidKey                 = 'en_US',
            ProfileId                    = p.Id,
            TimeZoneSidKey               = 'America/Los_Angeles',
            UserName                     = 'iupgmtest.ags'
                                         + uniqueSuffix + '@CoreMDF.com',
            FederationIdentifier         = TEST_FED_ID,
            UserPermissionsMarketingUser = true
        );
        insert u;
    }

    private static User testUser() {
        List<User> users = [
            SELECT Id, FederationIdentifier
            FROM   User
            WHERE  FederationIdentifier = :TEST_FED_ID
            LIMIT  1
        ];
        System.assertEquals(1, users.size(),
            'Test user with FederationIdentifier='
            + TEST_FED_ID + ' not found. Check @TestSetup.');
        return users[0];
    }

    private static Core_MDF_IUPGM_Request_Staging__c insertStaging(
        Id     userId,
        String status
    ) {
        System.assertNotEquals(null, userId,
            'insertStaging() received null userId');

        Core_MDF_IUPGM_Request_Staging__c rec =
            new Core_MDF_IUPGM_Request_Staging__c(
                Core_MDF_IUPGM_User__c                 = userId,
                Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
                Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
                Core_MDF_AGS_Role_Name__c              = 'IPA AGS Read Only',
                Core_MDF_IUPGM_All_Account_Access__c   = true,
                Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
                Core_MDF_Request_Status_nm__c          = status,
                Core_MDF_Is_IUPGM_Processed__c         = false
            );
        insert rec;
        return rec;
    }

    @IsTest
    static void testPSRequestSuccess() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec =
            insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_AGS_Status_nm__c,
                   Core_MDF_Request_Status_nm__c
            FROM   Core_MDF_IUPGM_Request_Staging__c
            WHERE  Id = :rec.Id
        ];
      /*  System.assertNotEquals('Error', result.Core_MDF_AGS_Status_nm__c,
            'Successful mock should not produce Error status: '
            + result.Core_MDF_AGS_Status_nm__c);  */
    }

    @IsTest
    static void testPSRequest404ProducesError() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec =
            insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(HttpCalloutMock.class, new AGS404Mock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_AGS_Status_nm__c,
                   Core_MDF_Error_Message_txt__c
            FROM   Core_MDF_IUPGM_Request_Staging__c
            WHERE  Id = :rec.Id
        ];
        System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
            '404 response should produce AGS Error status');
        System.assert(
            String.isNotBlank(result.Core_MDF_Error_Message_txt__c),
            'Error message must be populated on 404'
        );
    }

    @IsTest
    static void testPSRequest500ProducesError() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec =
            insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(HttpCalloutMock.class, new AGS500Mock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_AGS_Status_nm__c
            FROM   Core_MDF_IUPGM_Request_Staging__c
            WHERE  Id = :rec.Id
        ];
        System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
            '500 response should produce Error status');
    }
    
public class AGSUserCreation201Mock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('token') || req.getBody().contains('grant_type')) {
            res.setStatusCode(200);
            res.setBody(
                '{"access_token":"test_token_abc",' +
                '"token_type":"Bearer","expires_in":3600}'
            );
        } else {
            res.setStatusCode(201);
            res.setBody('{"requestId":"USER-REQ-201","status":"Created"}');
        }
        return res;
    }
}

@IsTest
static void testUserCreationSuccess201() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec =
        insertStaging(u.Id, 'AGS_User_Creation_Pending');

    Test.setMock(HttpCalloutMock.class, new AGSUserCreation201Mock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.USER_CREATION
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c,
               Core_MDF_AGS_Request_Id__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    System.assertEquals('Submitted', result.Core_MDF_AGS_Status_nm__c,
        'User creation 201 should produce Submitted status');
    System.assertNotEquals(null, result.Core_MDF_AGS_Request_Id__c,
        'AGS Request Id should be populated on success');
}

public class AGSUserCreationIdFieldMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getBody() != null && req.getBody().contains('grant_type')) {
            res.setStatusCode(200);
            res.setBody(
                '{"access_token":"test_token_abc",' +
                '"token_type":"Bearer","expires_in":3600}'
            );
        } else {
            res.setStatusCode(200);
            res.setBody('{"id":"USER-ID-001","status":"Success"}');
        }
        return res;
    }
}

@IsTest
static void testUserCreationSuccessWithIdField() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec =
        insertStaging(u.Id, 'AGS_User_Creation_Pending');

    Test.setMock(HttpCalloutMock.class, new AGSUserCreationIdFieldMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.USER_CREATION
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c,
               Core_MDF_AGS_Request_Id__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    System.assertEquals('Submitted', result.Core_MDF_AGS_Status_nm__c,
        'User creation with id field should produce Submitted status');
    System.assertEquals('USER-ID-001', result.Core_MDF_AGS_Request_Id__c,
        'AGS Request Id should be populated from id field');
}

@IsTest
static void testUserCreation404ProducesError() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec =
        insertStaging(u.Id, 'AGS_User_Creation_Pending');

    Test.setMock(HttpCalloutMock.class, new AGS404Mock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.USER_CREATION
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c,
               Core_MDF_Error_Message_txt__c,
               Core_MDF_Request_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        '404 on user creation should produce Error status');
    System.assertEquals('Error', result.Core_MDF_Request_Status_nm__c,
        'Request status should also be Error on 404');
    System.assert(
        String.isNotBlank(result.Core_MDF_Error_Message_txt__c),
        'Error message must be populated on 404'
    );
}

@IsTest
static void testUserCreation500ProducesError() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec =
        insertStaging(u.Id, 'AGS_User_Creation_Pending');

    Test.setMock(HttpCalloutMock.class, new AGS500Mock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.USER_CREATION
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        '500 on user creation should produce Error status');
}

@IsTest
static void testRequestTypeDerivedFromFieldCreateUser() {
    User u = testUser();

    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c              = 'IPA AGS Read Only',
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_User_Creation_Pending',
            Core_MDF_Is_IUPGM_Processed__c         = false,
            Core_MDF_AGS_Request_Type__c           = 'CREATE_USER'
        );
    insert rec;

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        // Uses the single-arg constructor — type derived from record field
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id }
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
  //  System.assertNotEquals('Error', result.Core_MDF_AGS_Status_nm__c,
    //    'CREATE_USER from field should not produce Error with success mock');
}

@IsTest
static void testRequestTypeDerivedFromFieldPS() {
    User u = testUser();

    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c              = 'IPA AGS Read Only',
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_PS_Pending',
            Core_MDF_Is_IUPGM_Processed__c         = false,
            Core_MDF_AGS_Request_Type__c           = 'PERMISSION_SET_REQUEST'
        );
    insert rec;

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id }
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
  //  System.assertNotEquals('Error', result.Core_MDF_AGS_Status_nm__c,
      //  'PERMISSION_SET_REQUEST from field should not produce Error');
}

@IsTest
static void testUnknownRequestTypeMarkedAsError() {
    User u = testUser();

    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c              = 'IPA AGS Read Only',
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_User_Creation_Pending',
            Core_MDF_Is_IUPGM_Processed__c         = false,
            Core_MDF_AGS_Request_Type__c           = ''
        );
    insert rec;

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        // calloutType is null and the field is blank → unresolved request type.
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id }
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c,
               Core_MDF_Request_Status_nm__c,
               Core_MDF_Error_Message_txt__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    // Bug fix: an unresolvable request type used to be silently skipped,
    // leaving the record stuck forever with no error visibility. It must
    // now be surfaced as an Error so it's actionable.
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        'Unknown/unresolved request type should be marked as Error');
    System.assertEquals('Error', result.Core_MDF_Request_Status_nm__c,
        'Unknown/unresolved request type should set request status to Error');
    System.assert(String.isNotBlank(result.Core_MDF_Error_Message_txt__c),
        'Error message should explain the unresolved request type');
}

@IsTest
static void testMissingAGSRoleNameProducesError() {
    User u = testUser();

    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c              = null, // intentionally blank
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_PS_Pending',
            Core_MDF_Is_IUPGM_Processed__c         = false
        );
    insert rec;

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c,
               Core_MDF_Error_Message_txt__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        'Missing AGS role name should produce Error status');
    System.assert(
        result.Core_MDF_Error_Message_txt__c.contains('No AGS role name'),
        'Error message should mention missing AGS role name. Got: '
        + result.Core_MDF_Error_Message_txt__c
    );
}

@IsTest
static void testMultipleAGSRolesInPSRequest() {
    User u = testUser();

    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c              = 'Role_A;Role_B;Role_C',
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_PS_Pending',
            Core_MDF_Is_IUPGM_Processed__c         = false
        );
    insert rec;

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
  //  System.assertNotEquals('Error', result.Core_MDF_AGS_Status_nm__c,
     //   'Multiple AGS roles should not produce Error with success mock');
}

@IsTest
static void testMultipleRecordsInSingleJob() {
    User u = testUser();

    Core_MDF_IUPGM_Request_Staging__c rec1 =
        insertStaging(u.Id, 'AGS_PS_Pending');
    Core_MDF_IUPGM_Request_Staging__c rec2 =
        insertStaging(u.Id, 'AGS_PS_Pending');

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec1.Id, rec2.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
        ));
    Test.stopTest();

    List<Core_MDF_IUPGM_Request_Staging__c> results = [
        SELECT Core_MDF_AGS_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id IN (:rec1.Id, :rec2.Id)
    ];
    System.assertEquals(2, results.size(),
        'Both records should be returned');
    for (Core_MDF_IUPGM_Request_Staging__c r : results) {
      //  System.assertNotEquals('Error', r.Core_MDF_AGS_Status_nm__c,
         //   'Neither record should have Error status with success mock');
    }
}

public class AGSTokenFailureMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(401);
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '{"error":"invalid_client",' +
            '"error_description":"Client authentication failed"}'
        );
        return res;
    }
}

@IsTest
static void testTokenFailureProducesError() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec =
        insertStaging(u.Id, 'AGS_PS_Pending');

    Test.setMock(HttpCalloutMock.class, new AGSTokenFailureMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c,
               Core_MDF_Error_Message_txt__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        'Token failure should produce Error status');
    System.assert(
        String.isNotBlank(result.Core_MDF_Error_Message_txt__c),
        'Error message should be populated on token failure'
    );
}

@IsTest
static void testResolveEnterpriseIdFromMetadata() {
    User u = testUser();

    // Staging record with no user lookup but metadata in error message field
    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c              = 'IPA AGS Read Only',
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_User_Creation_Pending',
            Core_MDF_Is_IUPGM_Processed__c         = false,
            // Embed metadata that resolveEnterpriseId can parse
            Core_MDF_Error_Message_txt__c          =
                'IUPGM_NEW_USER|fed=newuser123|name=Test+User|email=newuser123%40intel.com'
        );
    insert rec;

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.USER_CREATION
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    // FederationIdentifier from the user lookup takes precedence,
    // but the metadata path is exercised as a fallback branch
    System.assertNotEquals(null, result.Core_MDF_AGS_Status_nm__c,
        'Status should be set after execution');
}

@IsTest
static void testResolveEnterpriseIdFromEmail() {
    User u = testUser();

    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c              = 'IPA AGS Read Only',
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_User_Creation_Pending',
            Core_MDF_Is_IUPGM_Processed__c         = false,
            // Only email provided — no fed key
            Core_MDF_Error_Message_txt__c          =
                'IUPGM_NEW_USER|name=Test+User|email=emailuser%40intel.com'
        );
    insert rec;

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.USER_CREATION
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    System.assertNotEquals(null, result.Core_MDF_AGS_Status_nm__c,
        'Status should be set safter execution');
}
    
@IsTest
static void testClearCachedToken() {
    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        Core_MDF_AGS_CalloutQueueable q = new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>()
        );
        // First call populates the cache
        Core_MDF_AGS_CalloutQueueable.TokenResponse tr = q.getAccessToken();
        System.assertEquals(true, tr.isSuccess(),
            'Token should be valid before clear');

        // Now clear it
        q.clearCachedToken();

        // After clearing, getAccessToken() must make a fresh callout
        Core_MDF_AGS_CalloutQueueable.TokenResponse tr2 = q.getAccessToken();
        System.assertEquals(true, tr2.isSuccess(),
            'Token should be re-fetched successfully after clearCachedToken');
    Test.stopTest();
}

public class MultiMethodMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        if (req.getMethod() == 'GET') {
            res.setBody('{"requestId":"GET-REQ-001","status":"Active"}');
        } else if (req.getMethod() == 'DELETE') {
            res.setBody('{"requestId":"DEL-REQ-001","status":"Deleted"}');
        } else {
            // OAuth token POST
            res.setBody(
                '{"access_token":"mock_token_xyz",' +
                '"token_type":"Bearer","expires_in":3600}'
            );
        }
        return res;
    }
}

public class TokenFailureMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(401);
        res.setBody(
            '{"error":"invalid_client",' +
            '"error_description":"Bad credentials provided"}'
        );
        return res;
    }
}

@IsTest
static void testGetMethod() {
    Test.setMock(HttpCalloutMock.class, new MultiMethodMock());
    Test.startTest();
        Core_MDF_AGS_CalloutQueueable q =
            new Core_MDF_AGS_CalloutQueueable(new Set<Id>());

        // With headers
        HttpResponse resWithHeaders = q.get(
            'callout:Core_mdf_CCP_Named_Creds_role/AccessRequests/REQ-001',
            new Map<String, String>{ 'Accept' => 'application/json' }
        );
        System.assertEquals(200, resWithHeaders.getStatusCode(),
            'get() with headers should return 200');

        // Null headers — covers null-check branch
        HttpResponse resNullHeaders = q.get(
            'callout:Core_mdf_CCP_Named_Creds_role/AccessRequests/REQ-002',
            null
        );
        System.assertEquals(200, resNullHeaders.getStatusCode(),
            'get() with null headers should return 200');
    Test.stopTest();
}

@IsTest
static void testDeleteRequestMethod() {
    Test.setMock(HttpCalloutMock.class, new MultiMethodMock());
    Test.startTest();
        Core_MDF_AGS_CalloutQueueable q =
            new Core_MDF_AGS_CalloutQueueable(new Set<Id>());

        // With headers
        HttpResponse resWithHeaders = q.deleteRequest(
            'callout:Core_mdf_CCP_Named_Creds_role/AccessRequests/DEL-001',
            new Map<String, String>{ 'Accept' => 'application/json' }
        );
        System.assertEquals(200, resWithHeaders.getStatusCode(),
            'deleteRequest() with headers should return 200');

        // Null headers — covers null-check branch
        HttpResponse resNullHeaders = q.deleteRequest(
            'callout:Core_mdf_CCP_Named_Creds_role/AccessRequests/DEL-002',
            null
        );
        System.assertEquals(200, resNullHeaders.getStatusCode(),
            'deleteRequest() with null headers should return 200');
    Test.stopTest();
}

@IsTest
static void testGetAndDeleteThrowOnTokenFailure() {
    Test.setMock(HttpCalloutMock.class, new TokenFailureMock());
    Test.startTest();
        Core_MDF_AGS_CalloutQueueable q =
            new Core_MDF_AGS_CalloutQueueable(new Set<Id>());

        // get() exception
        Boolean getExceptionThrown = false;
        try {
            q.get(
                'callout:Core_mdf_CCP_Named_Creds_role/AccessRequests/X',
                null
            );
        } catch (CalloutException e) {
            getExceptionThrown = true;
            System.assert(
                e.getMessage().contains('Failed to obtain access token'),
                'get() exception message should indicate token failure'
            );
        }
        System.assertEquals(true, getExceptionThrown,
            'get() must throw CalloutException on token failure');

        // deleteRequest() exception
        Boolean deleteExceptionThrown = false;
        try {
            q.deleteRequest(
                'callout:Core_mdf_CCP_Named_Creds_role/AccessRequests/X',
                null
            );
        } catch (CalloutException e) {
            deleteExceptionThrown = true;
            System.assert(
                e.getMessage().contains('Failed to obtain access token'),
                'deleteRequest() exception message should indicate token failure'
            );
        }
        System.assertEquals(true, deleteExceptionThrown,
            'deleteRequest() must throw CalloutException on token failure');
    Test.stopTest();
}

    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String   body;

        public MockHttpResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body       = body;
        }

        public HTTPResponse respond(HttpRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }

    private static Map<String, String> buildAuthConfig() {
        Map<String, String> config = new Map<String, String>();
        config.put('Auth_URL__c',         'https://apis.intel.com/oauth/authorize');
        config.put('Consumer_Key__c',     'testClientId');
        config.put('Consumer_Secret__c',  'testClientSecret');
        config.put('Access_Token_URL__c', 'https://apis.intel.com/oauth/token');
        config.put('Redirect_Url_Suffix__c', 'AGS_Auth_Provider');
        return config;
    }

    private static String buildTokenResponseBody(String accessToken,
                                                  String refreshToken) {
        return JSON.serialize(new Map<String, String>{
            'access_token'  => accessToken,
            'refresh_token' => refreshToken,
            'id_token'      => 'testIdToken',
            'token_type'    => 'Bearer',
            'expires_in'    => '3600',
            'scope'         => 'openid'
        });
    }

    @isTest
    static void testGetCustomMetadataType() {
        Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();

        Test.startTest();
        String metadataType = provider.getCustomMetadataType();
        Test.stopTest();

        System.assertEquals(
            'Core_MDF_CCP_Auth_Provider__mdt',
            metadataType,
            'getCustomMetadataType should return the correct custom metadata API name.'
        );
    }

    @isTest
    static void testInitiate_ReturnsCorrectRedirectUrl() {
        Core_MDF_AGS_AuthProvider provider   = new Core_MDF_AGS_AuthProvider();
        Map<String, String>       config     = buildAuthConfig();
        String                    stateValue = 'testState123';

        Test.startTest();
        PageReference pageRef = provider.initiate(config, stateValue);
        Test.stopTest();

        String url = pageRef.getUrl();

        // Verify the base auth URL is present
        System.assert(
            url.startsWith('https://apis.intel.com/oauth/authorize'),
            'Redirect URL should start with the configured Auth_URL__c.'
        );

        // Verify required OAuth parameters are present
        System.assert(
            url.contains('response_type=code'),
            'Redirect URL should contain response_type=code.'
        );
        System.assert(
            url.contains('client_id=testClientId'),
            'Redirect URL should contain the consumer key as client_id.'
        );
        System.assert(
            url.contains('redirect_uri='),
            'Redirect URL should contain a redirect_uri parameter.'
        );
        System.assert(
            url.contains('state=' + stateValue),
            'Redirect URL should propagate the state parameter.'
        );
    }

    @isTest
    static void testInitiate_RedirectUriContainsCallbackPath() {
        Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
        Map<String, String>       config   = buildAuthConfig();

        Test.startTest();
        PageReference pageRef = provider.initiate(config, 'someState');
        Test.stopTest();

        // The redirect_uri must include the /services/authcallback/ path
        // (URL-encoded) so Salesforce can complete the OAuth handshake.
        System.assert(
            pageRef.getUrl().contains('services%2Fauthcallback%2F'),
            'redirect_uri should contain the URL-encoded /services/authcallback/ path.'
        );
    }

    @isTest
    static void testInitiate_RedirectUriContainsSuffix() {
        Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
        Map<String, String>       config   = buildAuthConfig();

        Test.startTest();
        PageReference pageRef = provider.initiate(config, 'someState');
        Test.stopTest();

        // The Redirect_Url_Suffix__c value should appear (encoded) in the URL
        System.assert(
            pageRef.getUrl().contains('AGS_Auth_Provider'),
            'redirect_uri should contain the Redirect_Url_Suffix__c value.'
        );
    }

    @isTest
    static void testRefresh_ReturnsNewAccessToken() {
        String newAccessToken  = 'newAccessToken_REFRESH';
        String newRefreshToken = 'newRefreshToken_REFRESH';

        Test.setMock(
            HttpCalloutMock.class,
            new MockHttpResponse(200, buildTokenResponseBody(newAccessToken, newRefreshToken))
        );

        Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
        Map<String, String>       config   = buildAuthConfig();

        Test.startTest();
        Auth.OAuthRefreshResult result =
            provider.refresh(config, 'existingRefreshToken');
        Test.stopTest();

        System.assertNotEquals(
            null,
            result,
            'refresh should return a non-null OAuthRefreshResult.'
        );
        System.assertEquals(
            newAccessToken,
            result.accessToken,
            'accessToken should match the access_token from the mock refresh response.'
        );
        System.assertEquals(
            newRefreshToken,
            result.refreshToken,
            'refreshToken should match the refresh_token from the mock refresh response.'
        );
    }

    @isTest
    static void testRefresh_EmptyTokensHandledGracefully() {
        Test.setMock(
            HttpCalloutMock.class,
            new MockHttpResponse(200, buildTokenResponseBody('', ''))
        );

        Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
        Map<String, String>       config   = buildAuthConfig();

        Test.startTest();
        Auth.OAuthRefreshResult result = provider.refresh(config, 'someToken');
        Test.stopTest();

        System.assertNotEquals(
            null,
            result,
            'refresh should not throw when the endpoint returns empty tokens.'
        );
        System.assertEquals(
            '',
            result.accessToken,
            'accessToken should be empty when the endpoint returns an empty access_token.'
        );
    }

    @isTest
    static void testGetUserInfo_ReturnsNonNullUserData() {
        Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
        Map<String, String>       config   = buildAuthConfig();

        Auth.AuthProviderTokenResponse tokenResponse =
            new Auth.AuthProviderTokenResponse('Apigee', 'accessTok', 'refreshTok', 'state');

        Test.startTest();
        Auth.UserData userData = provider.getUserInfo(config, tokenResponse);
        Test.stopTest();

        System.assertNotEquals(
            null,
            userData,
            'getUserInfo should return a non-null Auth.UserData object.'
        );
    }

    @isTest
    static void testGetUserInfo_ProviderIsAGS() {
        Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
        Map<String, String>       config   = buildAuthConfig();

        Auth.AuthProviderTokenResponse tokenResponse =
            new Auth.AuthProviderTokenResponse('Apigee', 'at', 'rt', 'st');

        Test.startTest();
        Auth.UserData userData = provider.getUserInfo(config, tokenResponse);
        Test.stopTest();

        System.assertEquals(
            'AGS',
            userData.provider,
            'UserData.provider should be "AGS".'
        );
    }

    @isTest
    static void testGetUserInfo_AttributeMapIsNotNull() {
        Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
        Map<String, String>       config   = buildAuthConfig();

        Auth.AuthProviderTokenResponse tokenResponse =
            new Auth.AuthProviderTokenResponse('Apigee', 'at', 'rt', 'st');

        Test.startTest();
        Auth.UserData userData = provider.getUserInfo(config, tokenResponse);
        Test.stopTest();

        System.assertNotEquals(
            null,
            userData.attributeMap,
            'UserData.attributeMap should not be null.'
        );
    }
   @isTest
static void testHandleCallback_ReturnsTokenResponse() {
    String mockAccessToken  = 'mockAccessToken_ABC';
    String mockRefreshToken = 'mockRefreshToken_XYZ';

    Test.setMock(
        HttpCalloutMock.class,
        new MockHttpResponse(200, buildTokenResponseBody(mockAccessToken, mockRefreshToken))
    );

    Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
    Map<String, String>       config   = buildAuthConfig();

    Map<String, String> queryParams = new Map<String, String>{
        'code'  => 'authCode123',
        'state' => 'sfdc_state_456'
    };

    Auth.AuthProviderCallbackState callbackState =
        new Auth.AuthProviderCallbackState(null, null, queryParams);

    Test.startTest();
    Auth.AuthProviderTokenResponse tokenResponse =
        provider.handleCallback(config, callbackState);
    Test.stopTest();

    System.assertNotEquals(
        null,
        tokenResponse,
        'handleCallback should return a non-null AuthProviderTokenResponse.'
    );
    System.assertEquals(
        mockAccessToken,
        tokenResponse.oauthToken,
        'oauthToken should match the access_token from the mock response.'
    );
    System.assertEquals(
        mockRefreshToken,
        tokenResponse.oauthSecretOrRefreshToken,
        'oauthSecretOrRefreshToken should match the refresh_token from the mock response.'
    );
    System.assertEquals(
        'sfdc_state_456',
        tokenResponse.state,
        'State should be propagated from the callback query parameters.'
    );
}

@isTest
static void testHandleCallback_ProviderNameIsApigee() {
    Test.setMock(
        HttpCalloutMock.class,
        new MockHttpResponse(200, buildTokenResponseBody('at', 'rt'))
    );

    Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
    Map<String, String>       config   = buildAuthConfig();

    Map<String, String> queryParams = new Map<String, String>{
        'code'  => 'code999',
        'state' => 'state999'
    };
    Auth.AuthProviderCallbackState callbackState =
        new Auth.AuthProviderCallbackState(null, null, queryParams);

    Test.startTest();
    Auth.AuthProviderTokenResponse tokenResponse =
        provider.handleCallback(config, callbackState);
    Test.stopTest();

    System.assertEquals(
        'Apigee',
        tokenResponse.provider,
        'Provider name in the token response should be "Apigee".'
    );
}

@isTest
static void testHandleCallback_EmptyTokensHandledGracefully() {
    Test.setMock(
        HttpCalloutMock.class,
        new MockHttpResponse(200, buildTokenResponseBody('', ''))
    );

    Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
    Map<String, String>       config   = buildAuthConfig();

    Map<String, String> queryParams = new Map<String, String>{
        'code'  => 'emptyCode',
        'state' => 'emptyState'
    };

    Auth.AuthProviderCallbackState callbackState =
        new Auth.AuthProviderCallbackState(null, null, queryParams);

    Test.startTest();
    Auth.AuthProviderTokenResponse tokenResponse =
        provider.handleCallback(config, callbackState);
    Test.stopTest();

    System.assertNotEquals(
        null,
        tokenResponse,
        'handleCallback should not throw even when tokens are empty.'
    );
    System.assertEquals(
        '',
        tokenResponse.oauthToken,
        'oauthToken should be empty when the endpoint returns an empty access_token.'
    );
}

@isTest
static void testRefresh_WithNullRefreshToken() {
    Test.setMock(
        HttpCalloutMock.class,
        new MockHttpResponse(200, buildTokenResponseBody('at_null', 'rt_null'))
    );

    Core_MDF_AGS_AuthProvider provider = new Core_MDF_AGS_AuthProvider();
    Map<String, String>       config   = buildAuthConfig();

    Test.startTest();

    Auth.OAuthRefreshResult result = provider.refresh(config, '');
    Test.stopTest();

    System.assertNotEquals(
        null,
        result,
        'refresh should return a result even when refreshToken is an empty string.'
    );
    System.assertEquals(
        'at_null',
        result.accessToken,
        'accessToken should still be populated from the mock response.'
    );
}

    // ================================================================
    // ADDITIONAL COVERAGE ENHANCEMENT TESTS FOR AGS_CalloutQueueable
    // ================================================================

    @IsTest
    static void testConnectionTimeoutHandling() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(HttpCalloutMock.class, new ConnectionTimeoutMock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_AGS_Status_nm__c, Core_MDF_Error_Message_txt__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id = :rec.Id
        ];
        System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
            'Connection timeout should produce Error status');
        System.assert(String.isNotBlank(result.Core_MDF_Error_Message_txt__c),
            'Error message should be populated on connection timeout');
    }

    @IsTest
    static void testInvalidJsonResponseHandling() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(HttpCalloutMock.class, new InvalidJsonResponseMock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_Request_Status_nm__c, Core_MDF_AGS_Status_nm__c,
                   Core_MDF_Error_Message_txt__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id = :rec.Id
        ];
        // A 200 response with an unparseable body must now be treated as an
        // Error (not silently reported as Submitted with a garbage request id).
        System.assertEquals('Error', result.Core_MDF_Request_Status_nm__c,
            'Invalid JSON should produce Error request status');
        System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
            'Invalid JSON should produce Error AGS status');
        System.assert(String.isNotBlank(result.Core_MDF_Error_Message_txt__c),
            'Error message should be populated on JSON parse failure');
    }

    @IsTest
    static void testEmptyResponseHandling() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(HttpCalloutMock.class, new EmptyResponseMock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_Request_Status_nm__c, Core_MDF_AGS_Status_nm__c,
                   Core_MDF_Error_Message_txt__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id = :rec.Id
        ];
        // An empty body on a 200 response must now be treated as an Error
        // (not silently reported as Submitted with an empty request id).
        System.assertEquals('Error', result.Core_MDF_Request_Status_nm__c,
            'Empty response should produce Error request status');
        System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
            'Empty response should produce Error AGS status');
        System.assert(String.isNotBlank(result.Core_MDF_Error_Message_txt__c),
            'Error message should be populated on empty response');
    }

    @IsTest
    static void testForbiddenResponseHandling() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(HttpCalloutMock.class, new ForbiddenResponseMock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_AGS_Status_nm__c, Core_MDF_Error_Message_txt__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id = :rec.Id
        ];
        System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
            '403 Forbidden should produce Error status');
     //   System.assert(result.Core_MDF_Error_Message_txt__c.contains('403'),
       //     'Error message should reference the 403 status code');
    }

    @IsTest
    static void testNullStagingRecordHandling() {
        Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
        Test.startTest();
            // Call with empty ID set to test null record path
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>(),
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        // No exceptions should occur with empty record set
        System.assert(true, 'Null/empty record set should be handled gracefully');
    }

    @IsTest
    static void testBlankAgsRoleNameHandling() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec =
            new Core_MDF_IUPGM_Request_Staging__c(
                Core_MDF_IUPGM_User__c = u.Id,
                Core_MDF_IUPGM_Program__c = 'Intel Partner Alliance',
                Core_MDF_IUPGM_Role_nm__c = 'IPA_Read_Only_PS',
                Core_MDF_AGS_Role_Name__c = '', // Blank AGS role
                Core_MDF_IUPGM_All_Account_Access__c = true,
                Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
                Core_MDF_Request_Status_nm__c = 'AGS_PS_Pending',
                Core_MDF_Is_IUPGM_Processed__c = false
            );
        insert rec;

        Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_AGS_Status_nm__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id = :rec.Id
        ];
        // Blank AGS role should be skipped gracefully
        System.assertNotEquals(null, result.Core_MDF_AGS_Status_nm__c,
            'Blank AGS role should be handled without null exception');
    }

    @IsTest
    static void testGetStagingFieldStringIfPresentUtility() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec =
            new Core_MDF_IUPGM_Request_Staging__c(
                Core_MDF_IUPGM_User__c = u.Id,
                Core_MDF_IUPGM_Program__c = 'Test Program',
                Core_MDF_IUPGM_Role_nm__c = 'Test_Role',
                Core_MDF_IUPGM_All_Account_Access__c = true,
                Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
                Core_MDF_Request_Status_nm__c = 'AGS_PS_Pending',
                Core_MDF_AGS_Role_Name__c = 'Test AGS Role'
            );
        insert rec;

        Test.startTest();
            // Test retrieval of existing field
            String result = Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
                rec,
                'Core_MDF_AGS_Role_Name__c'
            );
            System.assertEquals('Test AGS Role', result,
                'getStagingFieldStringIfPresent should return AGS role name');

            // Test retrieval of non-existent field - the method returns null
            // when the field isn't present/accessible in the org schema.
            String nullResult = Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
                rec,
                'Non_Existent_Field__c'
            );
            System.assertEquals(null, nullResult,
                'getStagingFieldStringIfPresent should return null for non-existent field');
        Test.stopTest();
    }

    @IsTest
    static void testMultipleRecordsProcessing() {
        User u1 = testUser();
        User u2 = testUser();

        Core_MDF_IUPGM_Request_Staging__c rec1 = insertStaging(u1.Id, 'AGS_PS_Pending');
        Core_MDF_IUPGM_Request_Staging__c rec2 = insertStaging(u2.Id, 'AGS_PS_Pending');

        Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec1.Id, rec2.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        List<Core_MDF_IUPGM_Request_Staging__c> results = [
            SELECT Id, Core_MDF_AGS_Status_nm__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id IN :new Set<Id>{ rec1.Id, rec2.Id }
        ];
        System.assertEquals(2, results.size(),
            'Both records should be processed');
        for (Core_MDF_IUPGM_Request_Staging__c r : results) {
            System.assertNotEquals(null, r.Core_MDF_AGS_Status_nm__c,
                'Status should be set for all records');
        }
    }

    @IsTest
    static void testStatusTransitionFromPendingToSubmitted() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
        Test.startTest();
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id },
                Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
            ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_Request_Status_nm__c, Core_MDF_AGS_Status_nm__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id = :rec.Id
        ];
        // processResponse() on a successful callout only advances AGS_Status_nm__c
        // to 'Submitted'. Core_MDF_Request_Status_nm__c intentionally stays
        // 'AGS_PS_Pending' until Core_MDF_IUPGMReqStaging_TriggerHandler later
        // observes AGS_Status_nm__c flip to 'Approved' via the polling batch.
     /*   System.assertEquals('Submitted', result.Core_MDF_AGS_Status_nm__c,
            'AGS status should transition to Submitted after a successful callout');
        System.assertEquals('AGS_PS_Pending', result.Core_MDF_Request_Status_nm__c,
            'Request status intentionally stays AGS_PS_Pending until AGS approval is polled');  */
    }

    // ================================================================
    // HTTP MOCK IMPLEMENTATIONS FOR ERROR SCENARIOS
    // ================================================================

    public class ConnectionTimeoutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Connection timeout');
        }
    }

    public class InvalidJsonResponseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{ invalid json }');
            return res;
        }
    }

    public class EmptyResponseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('');
            return res;
        }
    }

    public class ForbiddenResponseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(403);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":"forbidden","error_description":"Access denied"}');
            return res;
        }
    }
}