@isTest
private class Core_MDF_OBCampDetailCtrl_Test {

    @testSetup
    static void setupData() {
        Core_MDF_CCP_TestDataUtility.byPassFeature(
            new List<String>{
                'Bypass_MDF_Budget_Access_Validation',
                'Bypass_MDF_Budget_Status_Validation',
                'Bypass_Allocation_Reservation',
                'BypassCampaignBenefitValidation'
            },
            true,
            true
        );

        ChannelProgram program = Core_MDF_CCP_TestDataUtility.createProgram(
            Core_MDF_CCP_ConstantClass.CCF_PROGRAM,
            'Client CoMarketing Fund',
            false
        );
        insert program;

        Account parentAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount(
            'OBD Parent Account',
            Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type,
            true
        );

        Account partnerAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount(
            'OBD Partner Account',
            program.Id,
            Core_MDF_CCP_TestDataUtility.account_Record_Type,
            parentAccount.Id,
            false
        );
        insert partnerAccount;
        partnerAccount.Core_MDF_CoMarketingActive__c = true;
        update partnerAccount;

        Campaign campaign = Core_MDF_CCP_TestDataUtility.createCampaign(
            'OBD Campaign',
            'Consumer',
            'Intel® Corporate Logo',
            'Yes',
            Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF,
            'Client CoMarketing Fund',
            System.today().addDays(-5),
            System.today().addDays(5),
            2000,
            'Unite',
            partnerAccount.Id,
            '2-in-1',
            false
        );
        campaign.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        insert campaign;

        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget(
            'OBD Budget',
            Core_MDF_CCP_TestDataUtility.budget_Record_Type,
            partnerAccount.Id,
            program.Id,
            50000,
            System.today().addDays(-10),
            System.today().addDays(10),
            false
        );
        budget.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        insert budget;

        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation(
            'OBD Allocation',
            budget,
            partnerAccount,
            25000,
            true
        );

        PartnerFundRequest requestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(
            String.valueOf(campaign.Id),
            String.valueOf(Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_CCF),
            String.valueOf(partnerAccount.Id),
            allocation,
            budget,
            'UNITED STATES',
            'Small Business',
            'Desktop',
            'Intel® Corporate Logo',
            'Broadcast',
            'Radio',
            'Approved',
            false
        );
        requestRecord.Amount = 1000;
        requestRecord.BudgetId = budget.Id;
        requestRecord.AllocationId = allocation.Id;
        requestRecord.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        requestRecord.Core_MDF_ActivityCategory__c = null;
        requestRecord.Core_MDF_Activity_Types__c = null;
        requestRecord.Core_MDF_Brand_nm__c = null;
        requestRecord.Core_MDF_TargetAudience__c = null;
        requestRecord.Core_MDF_Country_nm__c = null;
        insert requestRecord;

        insert new Core_MDF_Notes__c(
            Core_MDF_Activity_id__c = requestRecord.Id,
            Core_MDF_Title_txt__c = 'Seed Note',
            Core_MDF_Comments_txt__c = 'Seed Comment'
        );
    }

    private static PartnerFundRequest getRequestRecord() {
        return [
            SELECT Id
            FROM PartnerFundRequest
            WHERE Title = 'test'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }

    private static Core_MDF_Notes__c getSeedNote() {
        return [
            SELECT Id, Core_MDF_Title_txt__c, Core_MDF_Comments_txt__c
            FROM Core_MDF_Notes__c
            WHERE Core_MDF_Title_txt__c = 'Seed Note'
            LIMIT 1
        ];
    }

    @isTest
    static void testGetInternalNotesObjectAccess() {
        Map<String, Boolean> accessMap = Core_MDF_OutcomeBasedCampDetailCntllr.getInternalNotesObjectAccess();
        System.assert(accessMap.containsKey('canCreate'));
        System.assert(accessMap.containsKey('canUpdate'));
        System.assert(accessMap.containsKey('canDelete'));

        Core_MDF_OutcomeBasedCampDetailCntllr.testCanCreateOverride = false;
        Core_MDF_OutcomeBasedCampDetailCntllr.testCanUpdateOverride = false;
        Core_MDF_OutcomeBasedCampDetailCntllr.testCanDeleteOverride = false;
        accessMap = Core_MDF_OutcomeBasedCampDetailCntllr.getInternalNotesObjectAccess();
        System.assertEquals(false, accessMap.get('canCreate'));
        System.assertEquals(false, accessMap.get('canUpdate'));
        System.assertEquals(false, accessMap.get('canDelete'));

        Core_MDF_OutcomeBasedCampDetailCntllr.testForceObjectAccessException = true;
        accessMap = Core_MDF_OutcomeBasedCampDetailCntllr.getInternalNotesObjectAccess();
        System.assertEquals(false, accessMap.get('canCreate'));
        System.assertEquals(false, accessMap.get('canUpdate'));
        System.assertEquals(false, accessMap.get('canDelete'));

        Core_MDF_OutcomeBasedCampDetailCntllr.testForceObjectAccessException = false;
        Core_MDF_OutcomeBasedCampDetailCntllr.testCanCreateOverride = null;
        Core_MDF_OutcomeBasedCampDetailCntllr.testCanUpdateOverride = null;
        Core_MDF_OutcomeBasedCampDetailCntllr.testCanDeleteOverride = null;
    }

    @isTest
    static void testCheckUserRecordAccess() {
        PartnerFundRequest requestRecord = getRequestRecord();

        System.assertEquals(false,
            Core_MDF_OutcomeBasedCampDetailCntllr.checkUserRecordAccess(null, 'PartnerFundRequest').get('hasAccess')
        );
        System.assertEquals(false,
            Core_MDF_OutcomeBasedCampDetailCntllr.checkUserRecordAccess(requestRecord.Id, null).get('hasAccess')
        );
        System.assertEquals(false,
            Core_MDF_OutcomeBasedCampDetailCntllr.checkUserRecordAccess(requestRecord.Id, 'Does_Not_Exist__c').get('hasAccess')
        );
        System.assertEquals(true,
            Core_MDF_OutcomeBasedCampDetailCntllr.checkUserRecordAccess(requestRecord.Id, 'PartnerFundRequest').get('hasAccess')
        );
        System.assertEquals(false,
            Core_MDF_OutcomeBasedCampDetailCntllr.checkUserRecordAccess('abc', 'PartnerFundRequest').get('hasAccess')
        );
    }

    @isTest
    static void testGetInternalNotes() {
        PartnerFundRequest requestRecord = getRequestRecord();

        List<Map<String, String>> blankNotes = Core_MDF_OutcomeBasedCampDetailCntllr.getInternalNotes(null);
        System.assertEquals(0, blankNotes.size());

        List<Map<String, String>> notes = Core_MDF_OutcomeBasedCampDetailCntllr.getInternalNotes(requestRecord.Id);
        System.assertEquals(1, notes.size());
        System.assertEquals('Seed Note', notes[0].get('Title'));
        System.assertEquals('Seed Comment', notes[0].get('Comments'));
        System.assert(!String.isBlank(notes[0].get('CreatedDateFormatted')));

        List<Map<String, String>> malformedNotes = Core_MDF_OutcomeBasedCampDetailCntllr.getInternalNotes('abc');
        System.assertEquals(0, malformedNotes.size());
    }

    @isTest
    static void testCreateInternalNote() {
        PartnerFundRequest requestRecord = getRequestRecord();

        Test.startTest();
        Boolean created = Core_MDF_OutcomeBasedCampDetailCntllr.createInternalNote(requestRecord.Id, 'Created Note', 'Created Body');
        Test.stopTest();

        System.assertEquals(true, created);
        System.assertEquals(1, [SELECT Count() FROM Core_MDF_Notes__c WHERE Core_MDF_Title_txt__c = 'Created Note']);

        try {
            Core_MDF_OutcomeBasedCampDetailCntllr.createInternalNote(requestRecord.Id, '', 'Missing title');
            System.assert(false, 'Expected create validation exception.');
        } catch (AuraHandledException ex) {
            System.assert(true);
        }

        Core_MDF_OutcomeBasedCampDetailCntllr.testCanCreateOverride = false;
        try {
            Core_MDF_OutcomeBasedCampDetailCntllr.createInternalNote(requestRecord.Id, 'Denied', 'Denied Body');
            System.assert(false, 'Expected create permission exception.');
        } catch (AuraHandledException ex) {
            System.assert(true);
        }
        Core_MDF_OutcomeBasedCampDetailCntllr.testCanCreateOverride = null;
    }

    @isTest
    static void testUpdateInternalNote() {
        Core_MDF_Notes__c noteRecord = getSeedNote();

        Boolean updated = Core_MDF_OutcomeBasedCampDetailCntllr.updateInternalNote(noteRecord.Id, 'Updated Note', 'Updated Body');
        System.assertEquals(true, updated);

        Core_MDF_Notes__c updatedNote = [
            SELECT Core_MDF_Title_txt__c, Core_MDF_Comments_txt__c
            FROM Core_MDF_Notes__c
            WHERE Id = :noteRecord.Id
        ];
        System.assertEquals('Updated Note', updatedNote.Core_MDF_Title_txt__c);
        System.assertEquals('Updated Body', updatedNote.Core_MDF_Comments_txt__c);

        try {
            Core_MDF_OutcomeBasedCampDetailCntllr.updateInternalNote(noteRecord.Id, '', 'Missing title');
            System.assert(false, 'Expected update validation exception.');
        } catch (AuraHandledException ex) {
            System.assert(true);
        }

        Core_MDF_OutcomeBasedCampDetailCntllr.testCanUpdateOverride = false;
        try {
            Core_MDF_OutcomeBasedCampDetailCntllr.updateInternalNote('001000000000000AAA', 'Denied Update', 'Denied Body');
            System.assert(false, 'Expected update permission exception.');
        } catch (AuraHandledException ex) {
            System.assert(true);
        }
        Core_MDF_OutcomeBasedCampDetailCntllr.testCanUpdateOverride = null;

        try {
            Core_MDF_OutcomeBasedCampDetailCntllr.updateInternalNote('abc', 'Malformed', 'Malformed Body');
            System.assert(false, 'Expected malformed update exception.');
        } catch (AuraHandledException ex) {
            System.assert(true);
        }
    }

    @isTest
    static void testDeleteInternalNote() {
        PartnerFundRequest requestRecord = getRequestRecord();
        Core_MDF_Notes__c deletableNote = new Core_MDF_Notes__c(
            Core_MDF_Activity_id__c = requestRecord.Id,
            Core_MDF_Title_txt__c = 'Delete Me',
            Core_MDF_Comments_txt__c = 'Delete Body'
        );
        insert deletableNote;

        Boolean deleted = Core_MDF_OutcomeBasedCampDetailCntllr.deleteInternalNote(deletableNote.Id);
        System.assertEquals(true, deleted);
        System.assertEquals(0, [SELECT Count() FROM Core_MDF_Notes__c WHERE Id = :deletableNote.Id]);

        try {
            Core_MDF_OutcomeBasedCampDetailCntllr.deleteInternalNote('');
            System.assert(false, 'Expected delete validation exception.');
        } catch (AuraHandledException ex) {
            System.assert(true);
        }

        Core_MDF_OutcomeBasedCampDetailCntllr.testCanDeleteOverride = false;
        try {
            Core_MDF_OutcomeBasedCampDetailCntllr.deleteInternalNote('001000000000000AAA');
            System.assert(false, 'Expected delete permission exception.');
        } catch (AuraHandledException ex) {
            System.assert(true);
        }
        Core_MDF_OutcomeBasedCampDetailCntllr.testCanDeleteOverride = null;

        try {
            Core_MDF_OutcomeBasedCampDetailCntllr.deleteInternalNote('abc');
            System.assert(false, 'Expected malformed delete exception.');
        } catch (AuraHandledException ex) {
            System.assert(true);
        }
    }
}