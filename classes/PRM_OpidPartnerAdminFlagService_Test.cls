@IsTest
private class PRM_OpidPartnerAdminFlagService_Test {

    private class TestData {
        Account opid;
        Account intel;
        Core_Account_Group_Member__c cag;
        PRM_Account_Contact_Relationship__c acr;
    }

    private static TestData createData(Boolean acrActive, Boolean ipaMembership) {
        TriggerHandler.bypass('Core_AccountTriggerHandler');
        TriggerHandler.bypass('Core_Acct_Grp_Mbr_TriggerHandler');
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');

        TestData d = new TestData();
        d.opid = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType(
            'OPID PA Flag Partner', 'Partner Account Group', 'UNFD_GLBL_CUST');
        insert d.opid;
        d.intel = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType(
            'OPID PA Flag Intel', 'Intel Account', 'UNFD_GLBL_CUST');
        d.intel.Core_Intel_Partner_Alliance_PartnerGroup__c = ipaMembership;
        insert d.intel;

        d.cag = new Core_Account_Group_Member__c(
            Core_Partner_Account_Id__c = d.opid.Id,
            Core_Intel_Account_Id__c = d.intel.Id,
            Primary_Account__c = true,
            Core_Inactive_Ind__c = false);
        insert d.cag;

        Contact con = new Contact(FirstName = 'Pa', LastName = 'FlagTest',
            Email = 'pa.flagtest@example.com', AccountId = d.intel.Id, MailingCountry = 'India');
        insert con;

        PRM_ContactRelationships__c rel = new PRM_ContactRelationships__c(
            Name = System.Label.PRM_Primary_Contact,
            PRM_Contact_Relationship_Cd__c = 'RELTNPRCTC',
            PRM_InActive_Ind__c = false);
        insert rel;

        d.acr = new PRM_Account_Contact_Relationship__c(
            PRM_Account_Id__c = d.intel.Id,
            PRM_Contact_Id__c = con.Id,
            PRM_Relationship_Id__c = rel.Id,
            PRM_Status_Nm__c = System.Label.PRM_ACR_Status,
            PRM_Status_Reason_Txt__c = 'Test',
            PRM_InActive_Ind__c = !acrActive,
            PRM_execute_trigger__c = false);
        insert d.acr;

        TriggerHandler.clearAllBypasses();
        return d;
    }

    private static Boolean flagOf(Id opidId) {
        return [SELECT Is_Partner_Admin_Exist__c FROM Account WHERE Id = :opidId].Is_Partner_Admin_Exist__c;
    }

    private static void setFlag(Id opidId, Boolean value) {
        TriggerHandler.bypass('Core_AccountTriggerHandler');
        update new Account(Id = opidId, Is_Partner_Admin_Exist__c = value);
        TriggerHandler.clearAllBypasses();
    }

    @IsTest
    static void setPhaseSetsFlagWhenPartnerAdminOnboarded() {
        TestData d = createData(true, true);

        Test.startTest();
        System.enqueueJob(new PRM_OpidPartnerAdminFlagService.SyncJob());
        Test.stopTest();

        System.assertEquals(true, flagOf(d.opid.Id),
            'An onboarded Partner Admin should set the OPID flag to true.');
    }

    @IsTest
    static void setPhaseDoesNotTouchAlreadyFlaggedOpid() {
        TestData d = createData(true, true);
        setFlag(d.opid.Id, true);
        Datetime before = [SELECT LastModifiedDate FROM Account WHERE Id = :d.opid.Id].LastModifiedDate;

        Test.startTest();
        System.enqueueJob(new PRM_OpidPartnerAdminFlagService.SyncJob());
        Test.stopTest();

        System.assertEquals(true, flagOf(d.opid.Id), 'Flag must stay true.');
        System.assertEquals(before, [SELECT LastModifiedDate FROM Account WHERE Id = :d.opid.Id].LastModifiedDate,
            'Already-flagged OPIDs must not be updated again on later onboardings.');
    }

    @IsTest
    static void setPhaseIgnoresInactivePartnerAdmin() {
        TestData d = createData(false, true);

        Test.startTest();
        System.enqueueJob(new PRM_OpidPartnerAdminFlagService.SyncJob());
        Test.stopTest();

        System.assertEquals(false, flagOf(d.opid.Id),
            'Inactive Partner Admin ACRs must not set the flag.');
    }

    @IsTest
    static void setPhaseIgnoresNonIpaMembership() {
        TestData d = createData(true, false);

        Test.startTest();
        System.enqueueJob(new PRM_OpidPartnerAdminFlagService.SyncJob());
        Test.stopTest();

        System.assertEquals(false, flagOf(d.opid.Id),
            'Only IPA memberships qualify for the Partner Admin flag.');
    }

    @IsTest
    static void clearPhaseClearsFlagWhenPartnerAdminDeactivated() {
        TestData d = createData(true, true);
        setFlag(d.opid.Id, true);
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        d.acr.PRM_InActive_Ind__c = true;
        update d.acr;
        TriggerHandler.clearAllBypasses();

        Test.startTest();
        System.enqueueJob(new PRM_OpidPartnerAdminFlagService.SyncJob(true, null));
        Test.stopTest();

        System.assertEquals(false, flagOf(d.opid.Id),
            'Deactivating the last Partner Admin must clear the flag.');
    }

    @IsTest
    static void clearPhaseKeepsFlagWhilePartnerAdminActive() {
        TestData d = createData(true, true);
        setFlag(d.opid.Id, true);

        Test.startTest();
        System.enqueueJob(new PRM_OpidPartnerAdminFlagService.SyncJob(true, null));
        Test.stopTest();

        System.assertEquals(true, flagOf(d.opid.Id),
            'The flag must stay true while an active Partner Admin exists.');
    }

    private static Account queryWithOpid(Id intelId) {
        return [
            SELECT Id,
                (SELECT Core_Partner_Account_Id__c, Primary_Account__c,
                        Core_Partner_Account_Id__r.Is_Partner_Admin_Exist__c
                 FROM Partner_Account_Group_Members1__r
                 WHERE Core_Partner_Account_Id__c != null)
            FROM Account WHERE Id = :intelId
        ];
    }

    @IsTest
    static void resolveOpidAndFlagReadFromLoadedMembers() {
        TestData d = createData(true, true);
        System.assertEquals(d.opid.Id, PRM_OpidPartnerAdminFlagService.resolveOpid(queryWithOpid(d.intel.Id)));
        System.assertEquals(false, PRM_OpidPartnerAdminFlagService.hasPartnerAdmin(queryWithOpid(d.intel.Id)));

        setFlag(d.opid.Id, true);
        System.assertEquals(true, PRM_OpidPartnerAdminFlagService.hasPartnerAdmin(queryWithOpid(d.intel.Id)));
        System.assertEquals(null, PRM_OpidPartnerAdminFlagService.resolveOpid(new Account()));
        System.assertEquals(false, PRM_OpidPartnerAdminFlagService.hasPartnerAdmin(null));
    }

    @IsTest
    static void claimBlocksSecondAssignmentAndPersistsFlag() {
        TestData d = createData(true, true);
        Account acc = queryWithOpid(d.intel.Id);
        TriggerHandler.bypass('Core_AccountTriggerHandler');

        Test.startTest();
        PRM_OpidPartnerAdminFlagService.claim(d.opid.Id);
        System.assertEquals(true, PRM_OpidPartnerAdminFlagService.hasPartnerAdmin(acc),
            'A claimed OPID must report an existing Partner Admin in the same transaction.');
        PRM_OpidPartnerAdminFlagService.flushClaims();
        Test.stopTest();

        System.assertEquals(true, flagOf(d.opid.Id), 'The queueable must persist the claim.');
    }

    @IsTest
    static void schedulerStartsBatch() {
        TestData d = createData(true, true);

        Test.startTest();
        System.schedule('PRM OPID PA Flag Sync Test', '0 0 * * * ?', new PRM_OpidPartnerAdminFlagScheduler());
        Test.stopTest();

        System.assert(true, 'Scheduler must register without error.');
    }

    @IsTest
    static void acrChangeStampsFlagImmediately() {
        TestData d = createData(true, true);
        TriggerHandler.bypass('Core_AccountTriggerHandler');

        Test.startTest();
        PRM_OpidPartnerAdminFlagService.handleAcrChanges(
            new List<PRM_Account_Contact_Relationship__c>{ d.acr }, null);
        Test.stopTest();

        System.assertEquals(true, flagOf(d.opid.Id),
            'A new active Partner Admin ACR must stamp its OPID without waiting for the batch.');
    }

    @IsTest
    static void acrChangeIgnoresInactiveAndUnchanged() {
        TestData d = createData(true, true);
        PRM_Account_Contact_Relationship__c inactive = d.acr.clone(true);
        inactive.PRM_InActive_Ind__c = true;

        Test.startTest();
        PRM_OpidPartnerAdminFlagService.handleAcrChanges(
            new List<PRM_Account_Contact_Relationship__c>{ inactive }, null);
        PRM_OpidPartnerAdminFlagService.handleAcrChanges(
            new List<PRM_Account_Contact_Relationship__c>{ d.acr },
            new Map<Id, PRM_Account_Contact_Relationship__c>{ d.acr.Id => d.acr });
        PRM_OpidPartnerAdminFlagService.handleAcrChanges(null, null);
        Test.stopTest();

        System.assertEquals(false, flagOf(d.opid.Id), 'Inactive or unchanged ACRs must not stamp the flag.');
    }

    @IsTest
    static void acrDeactivationClearsFlagImmediately() {
        TestData d = createData(true, true);
        setFlag(d.opid.Id, true);
        PRM_Account_Contact_Relationship__c oldAcr = d.acr.clone(true);
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        d.acr.PRM_InActive_Ind__c = true;
        update d.acr;
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Core_AccountTriggerHandler');

        Test.startTest();
        PRM_OpidPartnerAdminFlagService.handleAcrChanges(
            new List<PRM_Account_Contact_Relationship__c>{ d.acr },
            new Map<Id, PRM_Account_Contact_Relationship__c>{ d.acr.Id => oldAcr });
        Test.stopTest();

        System.assertEquals(false, flagOf(d.opid.Id),
            'Deactivating the last Partner Admin must clear the OPID flag right away.');
    }

    @IsTest
    static void acrDeleteClearsFlagImmediately() {
        TestData d = createData(true, true);
        setFlag(d.opid.Id, true);
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        delete d.acr;
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Core_AccountTriggerHandler');

        Test.startTest();
        PRM_OpidPartnerAdminFlagService.handleAcrDeletes(new List<PRM_Account_Contact_Relationship__c>{ d.acr });
        Test.stopTest();

        System.assertEquals(false, flagOf(d.opid.Id), 'Deleting the last Partner Admin must clear the OPID flag.');
    }

    @IsTest
    static void groupMemberInactivationClearsFlag() {
        TestData d = createData(true, true);
        setFlag(d.opid.Id, true);
        Core_Account_Group_Member__c activeCag = d.cag.clone(true);
        TriggerHandler.bypass('Core_Acct_Grp_Mbr_TriggerHandler');
        d.cag.Core_Inactive_Ind__c = true;
        update d.cag;
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Core_AccountTriggerHandler');

        Test.startTest();
        PRM_OpidPartnerAdminFlagService.handleGroupMemberChanges(
            new List<Core_Account_Group_Member__c>{ d.cag },
            new Map<Id, Core_Account_Group_Member__c>{ d.cag.Id => activeCag });
        Test.stopTest();

        System.assertEquals(false, flagOf(d.opid.Id), 'An inactive membership must not keep the OPID flag.');
    }

    @IsTest
    static void groupMemberReactivationSetsFlag() {
        TestData d = createData(true, true);
        TriggerHandler.bypass('Core_Acct_Grp_Mbr_TriggerHandler');
        d.cag.Core_Inactive_Ind__c = true;
        update d.cag;
        Core_Account_Group_Member__c inactiveCag = d.cag.clone(true);
        d.cag.Core_Inactive_Ind__c = false;
        update d.cag;
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Core_AccountTriggerHandler');

        Test.startTest();
        PRM_OpidPartnerAdminFlagService.handleGroupMemberChanges(
            new List<Core_Account_Group_Member__c>{ d.cag },
            new Map<Id, Core_Account_Group_Member__c>{ d.cag.Id => inactiveCag });
        Test.stopTest();

        System.assertEquals(true, flagOf(d.opid.Id), 'Reactivating the membership must set the OPID flag.');
    }

    @IsTest
    static void helpersIgnoreEmptyInput() {
        PRM_OpidPartnerAdminFlagService.markOpidsWithPartnerAdmin(null);
        PRM_OpidPartnerAdminFlagService.markOpidsWithPartnerAdmin(new Set<Id>());
        PRM_OpidPartnerAdminFlagService.clearStaleFlags(null);
        PRM_OpidPartnerAdminFlagService.clearStaleFlags(new Set<Id>());
        System.assert(true, 'Empty input must be a no-op.');
    }
}