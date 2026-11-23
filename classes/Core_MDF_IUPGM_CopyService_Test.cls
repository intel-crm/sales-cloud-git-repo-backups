@IsTest(SeeAllData=false)
public class Core_MDF_IUPGM_CopyService_Test {

    private static final String ROLE_NAME =
        'Core_MDF_CCP_Internal_IPA_Acct_Mgr';

    private static final String PROGRAM_NAME =
        'Intel Partner Alliance';

    private static final String IPA_RECORD_TYPE =
        'Core_MDF_Intel_Partner_Alliance';

    // ============================================================
    // TEST DATA SETUP
    // ============================================================

    @TestSetup
    static void setupUsers() {

        Id profileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ].Id;

        insert new List<User>{
            makeUser(profileId, 'Copy Source', 'copysrc'),
            makeUser(profileId, 'Copy Target', 'copytgt')
        };
    }

    private static User makeUser(
        Id profileId,
        String lastName,
        String aliasValue
    ) {
        String token =
            String.valueOf(DateTime.now().getTime()) +
            String.valueOf(Crypto.getRandomInteger()).replace('-', '');

        return new User(
            Alias = aliasValue,
            Email = aliasValue + token + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = lastName,
            FirstName = 'IUPGM',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = aliasValue + token + '@example.com',
            FederationIdentifier = aliasValue + token,
            IsActive = true
        );
    }

    private static User sourceUser() {
        return [
            SELECT Id, Name
            FROM User
            WHERE Alias = 'copysrc'
            LIMIT 1
        ];
    }

    private static User targetUser() {
        return [
            SELECT Id, Name
            FROM User
            WHERE Alias = 'copytgt'
            LIMIT 1
        ];
    }

    // ============================================================
    // VALIDATION BYPASS
    // ============================================================

    private static void bypassValidation() {

        Core_MDF_CCP_TestDataUtility.byPassFeature(
            new List<String>{
                'Core_MDF_Bypass_AccOnboardValidation'
            },
            true,
            true
        );
    }

    // ============================================================
    // PERMISSION SET ASSIGNMENT
    // Mixed DML protection using System.runAs()
    // ============================================================

    private static void assignRolePermissionSet(Id userId) {

        List<PermissionSet> ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :ROLE_NAME
            LIMIT 1
        ];

        System.assertEquals(
            1,
            ps.size(),
            'Expected Permission Set is missing from this org: ' +
            ROLE_NAME
        );

        List<PermissionSetAssignment> existingAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId
            AND PermissionSetId = :ps[0].Id
            LIMIT 1
        ];

        if (existingAssignments.isEmpty()) {

            User currentUser = [
                SELECT Id
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];

            System.runAs(currentUser) {

                insert new PermissionSetAssignment(
                    AssigneeId = userId,
                    PermissionSetId = ps[0].Id
                );
            }
        }
    }

    // ============================================================
    // IUPGM RECORD CREATION
    // All records use the IPA record type
    // ============================================================

    private static Core_MDF_Int_Users_Partner_Geo_Mapping__c mapping(
        Id userId,
        String region,
        Boolean isActive
    ) {

        Id ipaRecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType =
                'Core_MDF_Int_Users_Partner_Geo_Mapping__c'
            AND DeveloperName = :IPA_RECORD_TYPE
            LIMIT 1
        ].Id;

        return new Core_MDF_Int_Users_Partner_Geo_Mapping__c(
            RecordTypeId = ipaRecordTypeId,
            Core_MDF_User_id__c = userId,
            Core_MDF_Role_nm__c = ROLE_NAME,
            Core_MDF_Program_nm__c = PROGRAM_NAME,
            Core_MDF_All_Accounts_cd__c = 'Yes',
            Core_MDF_Account_id__c = null,
            Core_MDF_All_Budget_Type_Access_Ind__c = TRUE,
            Core_MDF_Region_Sub_Region_nm__c = region,
            Core_MDF_Active_Ind__c = isActive
        );
    }

    // ============================================================
    // COPY SERVICE EXECUTION HELPER
    // ============================================================

    private static Core_MDF_IUPGM_CopyService.CopyOutcome copy(
        Id targetId,
        String sourceName
    ) {

        Test.startTest();

        Core_MDF_IUPGM_CopyService.CopyOutcome result =
            Core_MDF_IUPGM_CopyService.copyForOperation(
                targetId,
                sourceName
            );

        Test.stopTest();

        return result;
    }

    // ============================================================
    // 1. NULL TARGET
    // ============================================================

    @IsTest
    static void testNullTarget() {

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(null, sourceUser().Name);

        System.assertEquals(0, r.sourceCount);
        System.assert(r.message.contains('Target user missing'));
    }

    // ============================================================
    // 2. BLANK SOURCE NAME
    // ============================================================

    @IsTest
    static void testBlankSourceName() {

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(targetUser().Id, '  ');

        System.assertEquals(0, r.sourceCount);
        System.assert(r.message.contains('Source user name missing'));
    }

    // ============================================================
    // 3. UNKNOWN SOURCE NAME
    // ============================================================

    @IsTest
    static void testUnknownSourceName() {

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(targetUser().Id, 'No Such IUPGM User');

        System.assertEquals(0, r.sourceCount);
        System.assert(r.message.contains('could not be resolved'));
    }

    // ============================================================
    // 4. AMBIGUOUS SOURCE NAME
    // ============================================================

    @IsTest
    static void testAmbiguousSourceName() {

        Id profileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ].Id;

        insert makeUser(profileId, 'Copy Source', 'copydup');

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(targetUser().Id, sourceUser().Name);

        System.assertEquals(0, r.sourceCount);
        System.assert(r.message.contains('ambiguous'));
    }

    // ============================================================
    // 5. SOURCE HAS NO ACTIVE MAPPINGS
    // ============================================================

    @IsTest
    static void testNoActiveSourceMappings() {

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(targetUser().Id, sourceUser().Name);

        System.assertEquals(0, r.sourceCount);

        System.assertEquals(
            'Source user has no active IUPGM records.',
            r.message
        );
    }

    // ============================================================
    // 6. INACTIVE SOURCE MAPPING IS IGNORED
    // ============================================================

    @IsTest
    static void testInactiveSourceMappingIsIgnored() {

        bypassValidation();

        insert mapping(sourceUser().Id, 'APJ', false);

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(targetUser().Id, sourceUser().Name);

        System.assertEquals(0, r.sourceCount);

        System.assertEquals(
            'Source user has no active IUPGM records.',
            r.message
        );
    }

    // ============================================================
    // 7. TARGET DOES NOT HAVE REQUIRED PERMISSION SET
    // ============================================================

    @IsTest
    static void testMissingTargetPermissionSet() {

        bypassValidation();

        User s = sourceUser();
        User t = targetUser();

        insert mapping(s.Id, 'APJ', true);

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(t.Id, s.Name);

        System.assertEquals(1, r.sourceCount);
        System.assertEquals(0, r.createdCount);
        System.assertEquals(1, r.failedCount);

        System.assert(
            r.message.contains('Missing Permission Set')
        );

        System.assertEquals(
            0,
            [
                SELECT COUNT()
                FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                WHERE Core_MDF_User_id__c = :t.Id
            ]
        );
    }

    // ============================================================
    // 8. CREATE NEW MAPPING AND COPY FIELDS
    // ============================================================

    @IsTest
    static void testCreatesNewMappingAndCopiesFields() {

        bypassValidation();

        User s = sourceUser();
        User t = targetUser();

        assignRolePermissionSet(t.Id);

        Core_MDF_Int_Users_Partner_Geo_Mapping__c src =
            mapping(s.Id, 'APJ', true);

        insert src;

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(t.Id, s.Name);

        System.assertEquals(1, r.sourceCount);
        System.assertEquals(1, r.createdCount);
        System.assertEquals(0, r.failedCount);

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> copies = [
            SELECT Core_MDF_User_id__c,
                   Core_MDF_Role_nm__c,
                   Core_MDF_Program_nm__c,
                   Core_MDF_All_Accounts_cd__c,
                   Core_MDF_Account_id__c,
                   Core_MDF_Region_Sub_Region_nm__c,
                   Core_MDF_Active_Ind__c
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Core_MDF_User_id__c = :t.Id
        ];

        System.assertEquals(1, copies.size());

        System.assertEquals(t.Id, copies[0].Core_MDF_User_id__c);
        System.assertEquals(ROLE_NAME, copies[0].Core_MDF_Role_nm__c);
        System.assertEquals(PROGRAM_NAME, copies[0].Core_MDF_Program_nm__c);
        System.assertEquals('Yes', copies[0].Core_MDF_All_Accounts_cd__c);
        System.assertEquals(null, copies[0].Core_MDF_Account_id__c);

        System.assertEquals(
            'APJ',
            copies[0].Core_MDF_Region_Sub_Region_nm__c
        );


        System.assertEquals(true, copies[0].Core_MDF_Active_Ind__c);
    }

    // ============================================================
    // 9. EXACT ACTIVE COMBINATION IS SKIPPED
    // ============================================================

    @IsTest
    static void testExactActiveCombinationIsSkipped() {

        bypassValidation();

        User s = sourceUser();
        User t = targetUser();

        assignRolePermissionSet(t.Id);

        insert new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{
            mapping(s.Id, 'APJ', true),
            mapping(t.Id, 'APJ', true)
        };

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(t.Id, s.Name);

        System.assertEquals(1, r.sourceCount);
        System.assertEquals(1, r.skippedCount);
        System.assertEquals(0, r.createdCount);
        System.assertEquals(0, r.failedCount);
    }

    // ============================================================
    // 10. INACTIVE TARGET MAPPING IS REACTIVATED
    // ============================================================

    @IsTest
    static void testInactiveTargetMappingIsReactivated() {

        bypassValidation();

        User s = sourceUser();
        User t = targetUser();

        assignRolePermissionSet(t.Id);

        insert mapping(s.Id, 'APJ', true);

        Core_MDF_Int_Users_Partner_Geo_Mapping__c inactiveTarget =
            mapping(t.Id, 'APJ', false);

        insert inactiveTarget;

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(t.Id, s.Name);

        Core_MDF_Int_Users_Partner_Geo_Mapping__c refreshed = [
            SELECT Core_MDF_Active_Ind__c
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Id = :inactiveTarget.Id
        ];

        System.assertEquals(
            1,
            r.createdCount,
            'The service counts a reactivation/update in createdCount.'
        );

        System.assertEquals(
            true,
            refreshed.Core_MDF_Active_Ind__c
        );
    }

    // ============================================================
    // 11. REGION UNION
    // ============================================================

    @IsTest
    static void testRegionUnion() {

        bypassValidation();

        User s = sourceUser();
        User t = targetUser();

        assignRolePermissionSet(t.Id);

        // Source has EMEA access. Activity classification is intentionally
        // blank because this test focuses on region merging.
        Core_MDF_Int_Users_Partner_Geo_Mapping__c src =
            mapping(s.Id, 'EMEA', true);

        insert src;

        // Target already has APJ access.
        Core_MDF_Int_Users_Partner_Geo_Mapping__c tgt =
            mapping(t.Id, 'APJ', true);

        insert tgt;

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(t.Id, s.Name);

        Core_MDF_Int_Users_Partner_Geo_Mapping__c refreshed = [
            SELECT Core_MDF_Region_Sub_Region_nm__c,
                   Core_MDF_Active_Ind__c
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Id = :tgt.Id
        ];

        System.assertEquals(1, r.createdCount);
        System.assertEquals(0, r.failedCount);

        System.assertEquals(
            'APJ;EMEA',
            refreshed.Core_MDF_Region_Sub_Region_nm__c,
            'Existing APJ region should be retained and EMEA should be added.'
        );

        System.assertEquals(
            true,
            refreshed.Core_MDF_Active_Ind__c
        );
    }

    // ============================================================
    // 12. WW TARGET COVERS SPECIFIC REQUESTED REGION
    // ============================================================

    @IsTest
    static void testWWTargetCoversRequestedSpecificRegion() {

        bypassValidation();

        User s = sourceUser();
        User t = targetUser();

        assignRolePermissionSet(t.Id);

        insert new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{
            mapping(s.Id, 'APJ', true),
            mapping(t.Id, 'WW', true)
        };

        Core_MDF_IUPGM_CopyService.CopyOutcome r =
            copy(t.Id, s.Name);

        System.assertEquals(1, r.skippedCount);
        System.assertEquals(0, r.createdCount);
    }
}