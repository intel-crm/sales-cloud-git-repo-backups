@IsTest(SeeAllData=false)
public class Core_MDF_AGS_CalloutQueueable_Test {

    private static final String TEST_FED_ID = 'iupgmtest.ags';

   public class AGSTokenMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');

        String contentType = req.getHeader('Content-Type');

        // ---------------------------------------------------------
        // 1. OAuth token request
        // Production class sends:
        // Content-Type = application/x-www-form-urlencoded
        // ---------------------------------------------------------
        if (contentType != null &&
            contentType.toLowerCase().contains(
                'application/x-www-form-urlencoded'
            )) {

            res.setBody(
                '{"access_token":"test_token_abc",' +
                '"token_type":"Bearer",' +
                '"expires_in":3600}'
            );

            return res;
        }

        // ---------------------------------------------------------
        // 2. Actual AGS POST request
        // ---------------------------------------------------------
        res.setBody(
            '{"status":"Success",' +
            '"requestId":"TEST-REQ-001"}'
        );

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
        System.assertNotEquals('Error', result.Core_MDF_AGS_Status_nm__c,
            'Successful mock should not produce Error status: '
            + result.Core_MDF_AGS_Status_nm__c);
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
    System.assertNotEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        'CREATE_USER from field should not produce Error with success mock');
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
    System.assertNotEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        'PERMISSION_SET_REQUEST from field should not produce Error');
}

@IsTest
static void testUnknownRequestTypeSkipped() {
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
        // calloutType is null, field is UNKNOWN_TYPE → skipped
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id }
        ));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c,
               Core_MDF_Request_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c
        WHERE  Id = :rec.Id
    ];
    // Record should remain unchanged — no error, no submitted
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        'Unknown AGS request type should produce Error status');
    System.assertNotEquals('Submitted', result.Core_MDF_AGS_Status_nm__c,
        'Unknown type should be skipped, not submitted');
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
    System.assertNotEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        'Multiple AGS roles should not produce Error with success mock');
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
        System.assertNotEquals('Error', r.Core_MDF_AGS_Status_nm__c,
            'Neither record should have Error status with success mock');
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
    Profile p = [
        SELECT Id
        FROM Profile
        WHERE Name = 'System Administrator'
        LIMIT 1
    ];

    User u = new User(
        Alias = 'nometa',
        Email = 'nometa@intel.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'NoFederationUser',
        FirstName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'nometa' + DateTime.now().getTime() + '@CoreMDF.com'
    );
    insert u;

    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                   = u.Id,
            Core_MDF_IUPGM_Program__c                = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c                = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c                = 'IPA AGS Read Only',
            Core_MDF_IUPGM_All_Account_Access__c     = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c   = 'WW',
            Core_MDF_Request_Status_nm__c            = 'AGS_User_Creation_Pending',
            Core_MDF_Is_IUPGM_Processed__c           = false,
            Core_MDF_AGS_Request_Type__c             = 'CREATE_USER' // Required for user creation processing
        );

    Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
        rec,
        'Core_MDF_New_User_Name__c',
        '   Test New User   '
    );

    Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
        rec,
        'Core_MDF_New_User_Email__c',
        '   NEWUSER@EXAMPLE.COM   '
    );

    Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
        rec,
        'Core_MDF_New_User_Federation_Id__c',
        'META123456'
    );

    insert rec;

    Test.setMock(
        HttpCalloutMock.class,
        new AGSTokenMock()
    );

    Test.startTest();
        System.enqueueJob(
            new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id }
            )
        );
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c,
               Core_MDF_AGS_Request_Id__c,
               Core_MDF_Error_Message_txt__c
        FROM Core_MDF_IUPGM_Request_Staging__c
        WHERE Id = :rec.Id
    ];

    System.assertEquals(
        'Submitted',
        result.Core_MDF_AGS_Status_nm__c,
        'Metadata federation ID should allow CREATE_USER to be submitted. Error: ' + result.Core_MDF_Error_Message_txt__c
    );
}

@IsTest
static void testResolveEnterpriseIdFromEmail() {
    Profile p = [
        SELECT Id
        FROM Profile
        WHERE Name = 'System Administrator'
        LIMIT 1
    ];

    User u = new User(
        Alias = 'emailfed',
        Email = 'emailfed@intel.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'EmailFederationUser',
        FirstName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'emailfed' + DateTime.now().getTime() + '@CoreMDF.com'
    );
    insert u;

    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                   = u.Id,
            Core_MDF_IUPGM_Program__c                = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c                = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c                = 'IPA AGS Read Only',
            Core_MDF_IUPGM_All_Account_Access__c     = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c   = 'WW',
            Core_MDF_Request_Status_nm__c            = 'AGS_User_Creation_Pending',
            Core_MDF_Is_IUPGM_Processed__c           = false,
            Core_MDF_AGS_Request_Type__c             = 'CREATE_USER' // Required for user creation processing
        );

    Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
        rec,
        'Core_MDF_New_User_Name__c',
        'Email User'
    );

    Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
        rec,
        'Core_MDF_New_User_Email__c',
        'emailuser@intel.com'
    );

    insert rec;

    Test.setMock(
        HttpCalloutMock.class,
        new AGSTokenMock()
    );

    Test.startTest();
        System.enqueueJob(
            new Core_MDF_AGS_CalloutQueueable(
                new Set<Id>{ rec.Id }
            )
        );
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT
            Core_MDF_AGS_Status_nm__c,
            Core_MDF_Error_Message_txt__c
        FROM Core_MDF_IUPGM_Request_Staging__c
        WHERE Id = :rec.Id
    ];

    System.assertEquals(
        'Submitted',
        result.Core_MDF_AGS_Status_nm__c,
        'Federation ID should be derived from the email local-part. Error: ' + result.Core_MDF_Error_Message_txt__c
    );
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
public class AGSStatusSuccessMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        String contentType = req.getHeader('Content-Type');

        // OAuth token request
        if (contentType != null &&
            contentType.toLowerCase().contains(
                'application/x-www-form-urlencoded'
            )) {

            res.setStatusCode(200);
            res.setBody(
                '{"access_token":"test_token_abc",' +
                '"token_type":"Bearer",' +
                '"expires_in":3600}'
            );

            return res;
        }

        // AGS status GET request
        res.setStatusCode(200);
        res.setBody(
            '{"requestItems":[' +
                '{' +
                    '"approvalStatus":"APPROVED",' +
                    '"provisioningStatus":"PROVISIONED"' +
                '}' +
            ']}'
        );

        return res;
    }
}
public class AGSStatusErrorMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        String contentType = req.getHeader('Content-Type');

        // OAuth token request must succeed
        if (contentType != null &&
            contentType.toLowerCase().contains(
                'application/x-www-form-urlencoded'
            )) {

            res.setStatusCode(200);
            res.setBody(
                '{"access_token":"test_token_abc",' +
                '"token_type":"Bearer",' +
                '"expires_in":3600}'
            );

            return res;
        }

        // AGS status request fails
        res.setStatusCode(500);
        res.setBody(
            '{"errorMessage":"Status service unavailable"}'
        );

        return res;
    }
}
@IsTest
static void testCheckRequestStatusSuccess() {
    Test.setMock(
        HttpCalloutMock.class,
        new AGSStatusSuccessMock()
    );

    Core_MDF_AGS_CalloutQueueable worker =
        new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>()
        );

    Test.startTest();

    Core_MDF_AGS_CalloutQueueable.AgsStatusResult result =
        worker.checkRequestStatus('0004267963');

    Test.stopTest();

    System.assertEquals(
        true,
        result.success,
        'Status check should succeed'
    );

    System.assertEquals(
        'APPROVED',
        result.approvalStatus,
        'Approval status should come from requestItems[0]'
    );

    System.assertEquals(
        'PROVISIONED',
        result.provisioningStatus,
        'Provisioning status should come from requestItems[0]'
    );

    System.assertNotEquals(
        null,
        result.rawBody,
        'Raw response body should be populated'
    );
}
@IsTest
static void testCheckRequestStatusBlankName() {
    Core_MDF_AGS_CalloutQueueable worker =
        new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>()
        );

    Test.startTest();

    Core_MDF_AGS_CalloutQueueable.AgsStatusResult result =
        worker.checkRequestStatus('');

    Test.stopTest();

    System.assertEquals(
        false,
        result.success,
        'Blank AGS request name should fail'
    );

    System.assertEquals(
        'No AGS request name provided.',
        result.error,
        'Blank request name should return expected error'
    );
}
@IsTest
static void testCheckRequestStatusHttpError() {
    Test.setMock(
        HttpCalloutMock.class,
        new AGSStatusErrorMock()
    );

    Core_MDF_AGS_CalloutQueueable worker =
        new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>()
        );

    Test.startTest();

    Core_MDF_AGS_CalloutQueueable.AgsStatusResult result =
        worker.checkRequestStatus('0004267963');

    Test.stopTest();

    System.assertEquals(
        false,
        result.success,
        'HTTP 500 should make status check unsuccessful'
    );

    System.assert(
        result.error != null &&
        result.error.contains('HTTP 500'),
        'Error should contain the HTTP status'
    );
}
@IsTest
static void testCheckRequestStatusTopLevelFields() {
    Test.setMock(
        HttpCalloutMock.class,
        new AGSStatusTopLevelMock()
    );

    Core_MDF_AGS_CalloutQueueable worker =
        new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>()
        );

    Test.startTest();

    Core_MDF_AGS_CalloutQueueable.AgsStatusResult result =
        worker.checkRequestStatus('0004267963');

    Test.stopTest();

    System.assertEquals(
        true,
        result.success,
        'Top-level status response should succeed'
    );

    System.assertEquals(
        'PENDING',
        result.approvalStatus,
        'Approval status should come from top-level field'
    );

    System.assertEquals(
        'NOT_STARTED',
        result.provisioningStatus,
        'Provisioning status should come from top-level field'
    );
}   
public class AGSStatusTopLevelMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        String contentType = req.getHeader('Content-Type');

        if (contentType != null &&
            contentType.toLowerCase().contains(
                'application/x-www-form-urlencoded'
            )) {

            res.setStatusCode(200);
            res.setBody(
                '{"access_token":"test_token_abc",' +
                '"token_type":"Bearer",' +
                '"expires_in":3600}'
            );
            return res;
        }

        res.setStatusCode(200);
        res.setBody(
            '{' +
                '"approvalStatus":"PENDING",' +
                '"provisioningStatus":"NOT_STARTED"' +
            '}'
        );

        return res;
    }
}
@IsTest
static void testUnknownAGSRequestTypeWithStagingFederationId() {
    Profile p = [
        SELECT Id
        FROM Profile
        WHERE Name = 'System Administrator'
        LIMIT 1
    ];

    // User deliberately has no FederationIdentifier.
    // This forces resolveEnterpriseId() to use the staging metadata.
    User u = new User(
        Alias = 'psremove',
        Email = 'psremove@intel.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'PSRemovalUser',
        FirstName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'psremove' + DateTime.now().getTime() + '@CoreMDF.com'
    );
    insert u;

    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c              = 'Role_A;Role_B',
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_PS_Pending',
            Core_MDF_Is_IUPGM_Processed__c         = false
        );

    Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
        rec,
        'Core_MDF_New_User_Federation_Id__c',
       // 'removal.enterprise.id'
         'REMOVAL123'
    );

    insert rec;

    Test.setMock(
        HttpCalloutMock.class,
        new AGSTokenMock()
    );

    Test.startTest();

    System.enqueueJob(
        new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id }
        )
    );

    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c,
               Core_MDF_AGS_Request_Id__c,
               Core_MDF_Error_Message_txt__c
        FROM Core_MDF_IUPGM_Request_Staging__c
        WHERE Id = :rec.Id
    ];

    System.assertEquals(
        'Error',
        result.Core_MDF_AGS_Status_nm__c,
        'A blank AGS request type with no explicit callout type must surface as Error'
    );

    System.assertEquals(
        null,
        result.Core_MDF_AGS_Request_Id__c,
        'No AGS request ID should be assigned when the AGS request type is missing'
    );
    System.assert(
        result.Core_MDF_Error_Message_txt__c != null
        && result.Core_MDF_Error_Message_txt__c.contains('Unknown AGS request type'),
        'Expected missing-request-type error, got: ' + result.Core_MDF_Error_Message_txt__c
    );
}

/* ══════════════════════════════════════════════════════════════════════════
   Additional coverage tests
   ══════════════════════════════════════════════════════════════════════════ */

/** Creates an instance with controlled private state, bypassing constructors. */
private static Core_MDF_AGS_CalloutQueueable deserializeInstance(String jsonBody) {
    return (Core_MDF_AGS_CalloutQueueable) JSON.deserialize(
        jsonBody, Core_MDF_AGS_CalloutQueueable.class);
}

@IsTest
static void testConstructorWithMissingConfigThrows() {
    Boolean threw = false;
    try {
        new Core_MDF_AGS_CalloutQueueable('Nonexistent_Config_XYZ');
    } catch (Core_MDF_AGS_CalloutQueueable.ConfigurationException e) {
        threw = true;
        System.assert(e.getMessage().contains('OAuth configuration not found'),
            'Unexpected message: ' + e.getMessage());
    }
    System.assert(threw, 'Missing OAuth config must throw ConfigurationException');
}

@IsTest
static void testThreeArgConstructorAndTokenResponseProps() {
    Core_MDF_AGS_CalloutQueueable q = new Core_MDF_AGS_CalloutQueueable(
        new Set<Id>(),
        Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST,
        'AGS_OAuth_Config');
    System.assertNotEquals(null, q, 'Three-arg constructor should build instance');

    Core_MDF_AGS_CalloutQueueable.TokenResponse tr =
        new Core_MDF_AGS_CalloutQueueable.TokenResponse();
    tr.scope      = 'test.scope';
    tr.token_type = 'Bearer';
    tr.expires_in = 60;
    System.assertEquals('test.scope', tr.scope, 'scope property should round-trip');
    System.assertEquals(false, tr.isSuccess(), 'No access token means not successful');
}

@IsTest
static void testGetAccessTokenConfigValidationBranches() {
    // config == null
    Core_MDF_AGS_CalloutQueueable qNull = deserializeInstance('{}');
    Core_MDF_AGS_CalloutQueueable.TokenResponse trNull = qNull.getAccessToken();
    System.assertEquals('configuration_error', trNull.error);
    System.assert(trNull.error_description.contains('not initialized'), trNull.error_description);

    // blank clientId
    Core_MDF_AGS_CalloutQueueable qNoId = deserializeInstance(
        '{"config":{"clientSecret":"s","accessTokenUrl":"https://example.invalid/token",'
        + '"grantType":"client_credentials","timeout":10000}}');
    Core_MDF_AGS_CalloutQueueable.TokenResponse trNoId = qNoId.getAccessToken();
    System.assertEquals('configuration_error', trNoId.error);
    System.assert(trNoId.error_description.contains('Client ID'), trNoId.error_description);

    // blank clientSecret
    Core_MDF_AGS_CalloutQueueable qNoSecret = deserializeInstance(
        '{"config":{"clientId":"c","accessTokenUrl":"https://example.invalid/token",'
        + '"grantType":"client_credentials","timeout":10000}}');
    Core_MDF_AGS_CalloutQueueable.TokenResponse trNoSecret = qNoSecret.getAccessToken();
    System.assertEquals('configuration_error', trNoSecret.error);
    System.assert(trNoSecret.error_description.contains('Client Secret'), trNoSecret.error_description);

    // blank accessTokenUrl
    Core_MDF_AGS_CalloutQueueable qNoUrl = deserializeInstance(
        '{"config":{"clientId":"c","clientSecret":"s",'
        + '"grantType":"client_credentials","timeout":10000}}');
    Core_MDF_AGS_CalloutQueueable.TokenResponse trNoUrl = qNoUrl.getAccessToken();
    System.assertEquals('configuration_error', trNoUrl.error);
    System.assert(trNoUrl.error_description.contains('Access Token URL'), trNoUrl.error_description);
}

public class EmptyTokenBodyMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('');
        return res;
    }
}

@IsTest
static void testGetAccessTokenEmptyResponseBody() {
    // scope + non-basic client auth exercise the request-building branches
    Core_MDF_AGS_CalloutQueueable q = deserializeInstance(
        '{"config":{"clientId":"c","clientSecret":"s",'
        + '"accessTokenUrl":"https://example.invalid/token",'
        + '"grantType":"client_credentials","scope":"read write",'
        + '"clientAuthentication":"client_secret_post","timeout":10000}}');
    Test.setMock(HttpCalloutMock.class, new EmptyTokenBodyMock());
    Test.startTest();
    Core_MDF_AGS_CalloutQueueable.TokenResponse tr = q.getAccessToken();
    Test.stopTest();
    System.assertEquals('empty_response', tr.error, 'Empty body should map to empty_response');
}

public class GarbageTokenBodyMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<<definitely-not-json>>');
        return res;
    }
}

@IsTest
static void testGetAccessTokenUnparseableBody() {
    Core_MDF_AGS_CalloutQueueable q = deserializeInstance(
        '{"config":{"clientId":"c","clientSecret":"s",'
        + '"accessTokenUrl":"https://example.invalid/token",'
        + '"grantType":"client_credentials","timeout":10000}}');
    Test.setMock(HttpCalloutMock.class, new GarbageTokenBodyMock());
    Test.startTest();
    Core_MDF_AGS_CalloutQueueable.TokenResponse tr = q.getAccessToken();
    Test.stopTest();
    System.assertEquals('parse_error', tr.error, 'Unparseable body should map to parse_error');
}

/** Token success + AGS response with only a "name" field. */
public class AGSNameFieldMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        String ct = req.getHeader('Content-Type');
        if (ct != null && ct.toLowerCase().contains('application/x-www-form-urlencoded')) {
            res.setBody('{"access_token":"t","token_type":"Bearer","expires_in":3600}');
        } else {
            res.setBody('{"name":"0004267963","id":"INTERNAL-GUID-1"}');
        }
        return res;
    }
}

@IsTest
static void testPSRequestStoresNameAsRequestId() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'AGS_PS_Pending');

    Test.setMock(HttpCalloutMock.class, new AGSNameFieldMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c, Core_MDF_AGS_Request_Id__c
        FROM   Core_MDF_IUPGM_Request_Staging__c WHERE Id = :rec.Id];
    System.assertEquals('Submitted', result.Core_MDF_AGS_Status_nm__c);
    System.assertEquals('0004267963', result.Core_MDF_AGS_Request_Id__c,
        'The short AGS "name" must be preferred over the internal id');
}

/** Token success + 200 AGS response whose body has no usable request id. */
public class AGSEmptyJsonMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        String ct = req.getHeader('Content-Type');
        if (ct != null && ct.toLowerCase().contains('application/x-www-form-urlencoded')) {
            res.setBody('{"access_token":"t","token_type":"Bearer","expires_in":3600}');
        } else {
            res.setBody('{}');
        }
        return res;
    }
}

@IsTest
static void testPSRequest200WithoutRequestIdIsError() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'AGS_PS_Pending');

    Test.setMock(HttpCalloutMock.class, new AGSEmptyJsonMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c, Core_MDF_Error_Message_txt__c
        FROM   Core_MDF_IUPGM_Request_Staging__c WHERE Id = :rec.Id];
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        '200 without a usable request id must be an Error');
    System.assert(result.Core_MDF_Error_Message_txt__c.contains('usable AGS'),
        'Unexpected error message: ' + result.Core_MDF_Error_Message_txt__c);
}

/** Token success + 200 AGS response with an unparseable body. */
public class AGSGarbageBodyMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        String ct = req.getHeader('Content-Type');
        if (ct != null && ct.toLowerCase().contains('application/x-www-form-urlencoded')) {
            res.setBody('{"access_token":"t","token_type":"Bearer","expires_in":3600}');
        } else {
            res.setBody('not-a-json-body');
        }
        return res;
    }
}

@IsTest
static void testPSRequest200UnparseableBodyIsError() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'AGS_PS_Pending');

    Test.setMock(HttpCalloutMock.class, new AGSGarbageBodyMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c WHERE Id = :rec.Id];
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        '200 with unparseable body must be an Error');
}

/** Token success + AGS 400 response (non-token HTTP error path). */
public class AGSHttp400Mock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String ct = req.getHeader('Content-Type');
        if (ct != null && ct.toLowerCase().contains('application/x-www-form-urlencoded')) {
            res.setStatusCode(200);
            res.setBody('{"access_token":"t","token_type":"Bearer","expires_in":3600}');
        } else {
            res.setStatusCode(400);
            res.setBody('{"errorMessage":"Bad Request"}');
        }
        return res;
    }
}

@IsTest
static void testPSRequestHttp400ProducesError() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'AGS_PS_Pending');

    Test.setMock(HttpCalloutMock.class, new AGSHttp400Mock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>{ rec.Id },
            Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c, Core_MDF_Error_Message_txt__c
        FROM   Core_MDF_IUPGM_Request_Staging__c WHERE Id = :rec.Id];
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        'HTTP 400 from AGS must produce Error status');
    System.assert(result.Core_MDF_Error_Message_txt__c.contains('400'),
        'Error message should mention status code');
}

@IsTest
static void testUserCreationDefaultRoleWhenNoRoleName() {
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c rec =
        new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'IPA_Read_Only_PS',
            Core_MDF_AGS_Role_Name__c              = null,
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_User_Creation_Pending',
            Core_MDF_Is_IUPGM_Processed__c         = false,
            Core_MDF_AGS_Request_Type__c           = 'CREATE_USER');
    insert rec;

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(new Set<Id>{ rec.Id }));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c
        FROM   Core_MDF_IUPGM_Request_Staging__c WHERE Id = :rec.Id];
    System.assertEquals('Submitted', result.Core_MDF_AGS_Status_nm__c,
        'User creation with default core-access role should be submitted');
}

@IsTest
static void testPSRequestMissingFederationIdError() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    // User deliberately has no FederationIdentifier and no new-user metadata exists.
    User u = new User(
        Alias = 'nofedid', Email = 'nofedid@intel.com', EmailEncodingKey = 'UTF-8',
        LastName = 'NoFedUser', FirstName = 'Test', LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US', ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'nofedid' + DateTime.now().getTime() + '@CoreMDF.com');
    insert u;

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
            Core_MDF_AGS_Request_Type__c           = 'PERMISSION_SET_REQUEST');
    insert rec;

    Test.setMock(HttpCalloutMock.class, new AGSTokenMock());
    Test.startTest();
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(new Set<Id>{ rec.Id }));
    Test.stopTest();

    Core_MDF_IUPGM_Request_Staging__c result = [
        SELECT Core_MDF_AGS_Status_nm__c, Core_MDF_Error_Message_txt__c
        FROM   Core_MDF_IUPGM_Request_Staging__c WHERE Id = :rec.Id];
    System.assertEquals('Error', result.Core_MDF_AGS_Status_nm__c,
        'Missing federation id must produce Error');
    System.assert(
        result.Core_MDF_Error_Message_txt__c.contains('Missing federation ID'),
        'Unexpected error: ' + result.Core_MDF_Error_Message_txt__c);
}

@IsTest
static void testFetchUserAccessBlankIdThrows() {
    Core_MDF_AGS_CalloutQueueable q = deserializeInstance('{}');
    Boolean threw = false;
    try {
        q.fetchUserAccessFromIds('  ');
    } catch (Core_MDF_AGS_CalloutQueueable.ConfigurationException e) {
        threw = true;
        System.assert(e.getMessage().contains('non-blank'), e.getMessage());
    }
    System.assert(threw, 'Blank enterprise id must throw');
}

@IsTest
static void testFetchUserAccessNotConfiguredThrows() {
    // Config present but Get_Endpoint_Path__c missing -> IDS not configured yet.
    Core_MDF_AGS_CalloutQueueable q = deserializeInstance(
        '{"config":{"clientId":"c","clientSecret":"s",'
        + '"accessTokenUrl":"https://example.invalid/token",'
        + '"grantType":"client_credentials","timeout":10000}}');
    Boolean threw = false;
    try {
        q.fetchUserAccessFromIds('WWID123');
    } catch (Core_MDF_AGS_CalloutQueueable.ConfigurationException e) {
        threw = true;
        System.assert(e.getMessage().contains('IDS integration is not configured'),
            e.getMessage());
    }
    System.assert(threw, 'Unconfigured IDS integration must throw');
}

public class IdsAccessListMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        // Match the IDS identity-role-entitlement-mappings response contract.
        res.setBody(
            '{"name":"IdentityRoleEntitlementMapping","elements":['
            + '{"RoleId":"RID-1","RoleSystemNm":"Role1","RoleDisplayNm":"Role One","Disabled":"False"},'
            + '{"RoleId":"RID-2","RoleSystemNm":"Role2","RoleDisplayNm":"Role Two","Disabled":"False"}'
            + '],"links":[]}'
        );
        return res;
    }
}

@IsTest
static void testFetchUserAccessSuccess() {
    // Pre-cached, unexpired token so get() skips the token endpoint entirely.
    Core_MDF_AGS_CalloutQueueable q = deserializeInstance(
        '{"cachedAccessToken":"cached-token",'
        + '"tokenExpiryTime":"2099-01-01T00:00:00.000Z",'
        + '"config":{"clientId":"c","clientSecret":"s",'
        + '"accessTokenUrl":"https://example.invalid/token",'
        + '"getEndpointPath":"https://example.invalid/ids/useraccess",'
        + '"grantType":"client_credentials","timeout":10000}}');
    Test.setMock(HttpCalloutMock.class, new IdsAccessListMock());

    Test.startTest();
    List<Core_MDF_AGS_CalloutQueueable.IdsRoleAssignment> rows =
        q.fetchUserAccessFromIds('WWID123');
    Test.stopTest();

    System.assertEquals(2, rows.size(),
        'Both distinct active IDS RoleId entries must be returned.');
    Set<String> returnedRoleNames = new Set<String>();
    Set<String> returnedRoleIds = new Set<String>();
    for (Core_MDF_AGS_CalloutQueueable.IdsRoleAssignment row : rows) {
        returnedRoleNames.add(row.roleName);
        returnedRoleIds.add(row.roleId);
        System.assert(String.isNotBlank(row.rawJson),
            'rawJson must be populated from the IDS element.');
        System.assertEquals(null, row.programName,
            'IDS does not return programName; callers resolve it from Salesforce configuration.');
    }
    System.assertEquals(new Set<String>{'Role1', 'Role2'}, returnedRoleNames);
    System.assertEquals(new Set<String>{'RID-1', 'RID-2'}, returnedRoleIds);
}

@IsTest
static void testFetchUserAccessHttpErrorThrows() {
    Core_MDF_AGS_CalloutQueueable q = deserializeInstance(
        '{"cachedAccessToken":"cached-token",'
        + '"tokenExpiryTime":"2099-01-01T00:00:00.000Z",'
        + '"config":{"clientId":"c","clientSecret":"s",'
        + '"accessTokenUrl":"https://example.invalid/token",'
        + '"getEndpointPath":"https://example.invalid/ids/useraccess?src=test",'
        + '"grantType":"client_credentials","timeout":10000}}');
    Test.setMock(HttpCalloutMock.class, new AGS500Mock());
    Boolean threw = false;
    Test.startTest();
    try {
        q.fetchUserAccessFromIds('WWID123');
    } catch (CalloutException e) {
        threw = true;
        System.assert(e.getMessage().contains('IDS user access lookup failed'),
            e.getMessage());
    }
    Test.stopTest();
    System.assert(threw, 'Non-200 IDS response must throw CalloutException');
}

@IsTest
static void testParseIdsRoleAssignmentsVariants() {
    Core_MDF_AGS_CalloutQueueable q = deserializeInstance('{}');

    System.assertEquals(0, q.parseIdsRoleAssignments(null).size(),
        'Null body must give empty list.');
    System.assertEquals(0, q.parseIdsRoleAssignments('').size(),
        'Blank body must give empty list.');

    // A top-level object without the IDS "elements" collection is not a valid IDS response.
    System.assertEquals(0,
        q.parseIdsRoleAssignments('{"roleName":"R1","program":"P1"}').size(),
        'An object without elements must return an empty list.');

    // One valid element is returned as one role assignment.
    List<Core_MDF_AGS_CalloutQueueable.IdsRoleAssignment> single =
        q.parseIdsRoleAssignments(
            '{"elements":[{"RoleId":"RID-1","RoleSystemNm":"R1",'
            + '"RoleDisplayNm":"Role One","Disabled":"False"}]}');
    System.assertEquals(1, single.size(),
        'One IDS element must produce one role assignment.');
    System.assertEquals('RID-1', single[0].roleId);
    System.assertEquals('R1', single[0].roleName);
    System.assertEquals(null, single[0].programName);
    System.assert(String.isNotBlank(single[0].rawJson));

    // Duplicate RoleIds are collapsed; disabled rows and non-object entries are ignored.
    List<Core_MDF_AGS_CalloutQueueable.IdsRoleAssignment> mixed =
        q.parseIdsRoleAssignments(
            '{"elements":['
            + '{"RoleId":"RID-2","RoleSystemNm":"R2","Disabled":"False"},'
            + '{"RoleId":"RID-2","RoleSystemNm":"R2-DUP","Disabled":"False"},'
            + '{"RoleId":"RID-3","RoleSystemNm":"R3","Disabled":"True"},'
            + '"plain-string",42,'
            + '{"RoleId":"RID-4","RoleDisplayNm":"Role Four","Disabled":"False"}'
            + ']}');

    System.assertEquals(2, mixed.size(),
        'Only two distinct active RoleIds should remain after filtering and deduplication.');
    Set<String> mixedIds = new Set<String>();
    Set<String> mixedNames = new Set<String>();
    for (Core_MDF_AGS_CalloutQueueable.IdsRoleAssignment item : mixed) {
        mixedIds.add(item.roleId);
        mixedNames.add(item.roleName);
    }
    System.assertEquals(new Set<String>{'RID-2', 'RID-4'}, mixedIds);
    System.assertEquals(new Set<String>{'R2', 'Role Four'}, mixedNames);
}

@IsTest
static void testCheckRequestStatusExceptionPath() {
    Core_MDF_AGS_CalloutQueueable q =
        new Core_MDF_AGS_CalloutQueueable(new Set<Id>());
    Test.setMock(HttpCalloutMock.class, new AGSTokenFailureMock());
    Test.startTest();
    Core_MDF_AGS_CalloutQueueable.AgsStatusResult result =
        q.checkRequestStatus('REQ-1');
    Test.stopTest();
    System.assertEquals(false, result.success,
        'Token failure during status check must not succeed');
    System.assert(result.error.contains('AGS status check exception'),
        'Unexpected error: ' + result.error);
}

@IsTest
static void testStagingFieldHelperGuards() {
    // put: null record / blank field / unknown field are silent no-ops
    Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
        null, 'Core_MDF_New_User_Email__c', 'x');
    Core_MDF_IUPGM_Request_Staging__c rec = new Core_MDF_IUPGM_Request_Staging__c();
    Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(rec, ' ', 'x');
    Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
        rec, 'Bogus_Field_XYZ__c', 'x');
    // Incompatible value type exercises the SObjectException guard when thrown
    try {
        Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
            rec, 'Core_MDF_New_User_Email__c', Date.today());
    } catch (Exception e) {
        // Acceptable: guard only swallows SObjectException by design
    }

    // get: null record / blank field / unknown field return null
    System.assertEquals(null,
        Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
            null, 'Core_MDF_New_User_Email__c'));
    System.assertEquals(null,
        Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(rec, ' '));
    System.assertEquals(null,
        Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
            rec, 'Bogus_Field_XYZ__c'));

    // SObjectException path: field exists but was not included in the SELECT
    User u = testUser();
    Core_MDF_IUPGM_Request_Staging__c inserted = insertStaging(u.Id, 'AGS_PS_Pending');
    Core_MDF_IUPGM_Request_Staging__c queried = [
        SELECT Id FROM Core_MDF_IUPGM_Request_Staging__c WHERE Id = :inserted.Id];
    System.assertEquals(null,
        Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
            queried, 'Core_MDF_New_User_Email__c'),
        'Unqueried field must safely return null');
}

}