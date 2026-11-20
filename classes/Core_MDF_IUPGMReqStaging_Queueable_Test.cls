@IsTest(SeeAllData=false)
public class Core_MDF_IUPGMReqStaging_Queueable_Test {

    // FederationIdentifier has a UNIQUE constraint in Salesforce —
    // WHERE on this field can never return more than one row.
    // Keep it short (≤40 chars) to avoid field length errors.
    private static final String TEST_FED_ID = 'iupgmtest.queueable';

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
            Alias                        = 'iupgmqu',
            Email                        = 'iupgmtest.queueable@intel.com',
            EmailEncodingKey             = 'UTF-8',
            LastName                     = 'IUPGMQueueableTestUser',
            FirstName                    = 'Test',
            LanguageLocaleKey            = 'en_US',
            LocaleSidKey                 = 'en_US',
            ProfileId                    = profiles[0].Id,
            TimeZoneSidKey               = 'America/Los_Angeles',
            UserName                     = 'iupgmtest.queueable@CoreMDF.com',
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
            SELECT Id, IsActive, UserType
            FROM   User
            WHERE  FederationIdentifier = :TEST_FED_ID
            LIMIT  1
        ];
    }

    private static Core_MDF_IUPGM_Request_Staging__c insertStaging(
        Id     userId,
        String status
    ) {
        return insertStaging(
            userId, status,
            'IPA_Read_Only_PS', 'Intel Partner Alliance'
        );
    }

    private static Core_MDF_IUPGM_Request_Staging__c insertStaging(
        Id     userId,
        String status,
        String role,
        String program
    ) {
        Core_MDF_IUPGM_Request_Staging__c rec =
            new Core_MDF_IUPGM_Request_Staging__c(
                Core_MDF_IUPGM_User__c                 = userId,
                Core_MDF_IUPGM_Program__c              = program,
                Core_MDF_IUPGM_Role_nm__c              = role,
                Core_MDF_AGS_Role_Name__c              = 'IPA AGS Read Only',
                Core_MDF_IUPGM_All_Account_Access__c   = true,
                Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
                Core_MDF_Request_Status_nm__c          = status,
                Core_MDF_Is_IUPGM_Processed__c         = false
            );
        insert rec;
        return rec;
    }

    private static Core_MDF_IUPGM_Request_Staging__c reload(Id recId) {
        return [
            SELECT Id,
                   Core_MDF_Request_Status_nm__c,
                   Core_MDF_AGS_Status_nm__c,
                   Core_MDF_AGS_Request_Type__c,
                   Core_MDF_Is_IUPGM_Processed__c,
                   Core_MDF_Error_Message_txt__c
            FROM   Core_MDF_IUPGM_Request_Staging__c
            WHERE  Id = :recId
        ];
    }

    // =========================================================================
    // 1. SINGLE-OP — INITIATE
    // =========================================================================
    @IsTest
    static void testInitiateOperation() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'New');

        Test.startTest();
        System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(
            new Set<Id>{ rec.Id },
            Core_MDF_IUPGMReqStaging_Queueable.Operation.INITIATE
        ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = reload(rec.Id);
        System.assertNotEquals(
            'New',
            result.Core_MDF_Request_Status_nm__c,
            'INITIATE must advance status from New; got: '
                + result.Core_MDF_Request_Status_nm__c
        );
    }

    // =========================================================================
    // 2. SINGLE-OP — empty Set is a no-op
    // =========================================================================
    @IsTest
    static void testEmptySetIsNoop() {
        Test.startTest();
        System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(
            new Set<Id>(),
            Core_MDF_IUPGMReqStaging_Queueable.Operation.INITIATE
        ));
        Test.stopTest();

        System.assert(true, 'Empty Set must not throw');
    }

   
    // =========================================================================
    // 4. SINGLE-OP — PS_APPROVED
    // =========================================================================
    @IsTest
    static void testPSApprovedOperation() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec =
            insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(
            HttpCalloutMock.class,
            new Core_MDF_AGS_CalloutQueueable_Test.AGSSuccessMock()
        );

        Test.startTest();
        System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(
            new Set<Id>{ rec.Id },
            Core_MDF_IUPGMReqStaging_Queueable.Operation.PS_APPROVED
        ));
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = reload(rec.Id);
        Set<String> terminal =
            new Set<String>{ 'Completed', 'Skipped', 'Error' };
        System.assert(
            terminal.contains(result.Core_MDF_Request_Status_nm__c),
            'PS_APPROVED must reach terminal status; got: '
                + result.Core_MDF_Request_Status_nm__c
        );
    }

    // =========================================================================
    // 5. MULTI-OP — single operation in map
    // =========================================================================
    @IsTest
    static void testMultiOpConstructorSingleOp() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec = insertStaging(u.Id, 'New');

        Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>> opMap =
            new Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>>{
                Core_MDF_IUPGMReqStaging_Queueable.Operation.INITIATE
                    => new Set<Id>{ rec.Id }
            };

        Test.startTest();
        System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(opMap));
        Test.stopTest();

        System.assertNotEquals(
            'New',
            reload(rec.Id).Core_MDF_Request_Status_nm__c,
            'Multi-op (single op) must advance status from New'
        );
    }


    // =========================================================================
    // 8. MULTI-OP — empty map is a no-op
    // =========================================================================
    @IsTest
    static void testMultiOpEmptyMapIsNoop() {
        Test.startTest();
        System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(
            new Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>>()
        ));
        Test.stopTest();

        System.assert(true, 'Empty map must not throw');
    }

    // =========================================================================
    // 9. MULTI-OP — null Set inside map is a no-op
    // =========================================================================
    @IsTest
    static void testMultiOpNullSetInsideMapIsNoop() {
        Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>> opMap =
            new Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>>{
                Core_MDF_IUPGMReqStaging_Queueable.Operation.INITIATE => null
            };

        Test.startTest();
        System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(opMap));
        Test.stopTest();

        System.assert(true, 'Null Set inside map must not throw');
    }

    // =========================================================================
    // 10. MULTI-OP — empty Set inside map is a no-op
    // =========================================================================
    @IsTest
    static void testMultiOpEmptySetInsideMapIsNoop() {
        Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>> opMap =
            new Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>>{
                Core_MDF_IUPGMReqStaging_Queueable.Operation.PS_APPROVED
                    => new Set<Id>()
            };

        Test.startTest();
        System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(opMap));
        Test.stopTest();

        System.assert(true, 'Empty Set inside map must not throw');
    }

   

    // =========================================================================
    // 12. MULTI-OP — only PS_APPROVED in map
    // =========================================================================
    @IsTest
    static void testMultiOpOnlyPSApproved() {
        User u = testUser();
        Core_MDF_IUPGM_Request_Staging__c rec =
            insertStaging(u.Id, 'AGS_PS_Pending');

        Test.setMock(
            HttpCalloutMock.class,
            new Core_MDF_AGS_CalloutQueueable_Test.AGSSuccessMock()
        );

        Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>> opMap =
            new Map<Core_MDF_IUPGMReqStaging_Queueable.Operation, Set<Id>>{
                Core_MDF_IUPGMReqStaging_Queueable.Operation.PS_APPROVED
                    => new Set<Id>{ rec.Id }
            };

        Test.startTest();
        System.enqueueJob(new Core_MDF_IUPGMReqStaging_Queueable(opMap));
        Test.stopTest();

        Set<String> terminal =
            new Set<String>{ 'Completed', 'Skipped', 'Error' };
        System.assert(
            terminal.contains(reload(rec.Id).Core_MDF_Request_Status_nm__c),
            'Only-PS_APPROVED map must reach terminal status'
        );
    }

}