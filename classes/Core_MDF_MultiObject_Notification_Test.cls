@isTest
public class Core_MDF_MultiObject_Notification_Test {

    @testSetup
    static void setupData() {

        // Create dummy PartnerFundRequest (used by one of the queries)
        /*PartnerFundRequest pfr = new PartnerFundRequest(
            Name = 'Test PFR',
            Title = 'PFR Title',
            Core_MDF_Program__c = 'PRG1',
            Core_MDF_Approval_Stage__c = 'Stage1'
        );
        insert pfr;*/

        // Create dummy Campaign
        Campaign cmp = new Campaign(
            Name = 'Test CMP',
            Core_MDF_Program__c = 'PRG1',
            Core_MDF_Approval_Stage_nm__c = 'Stage1'
        );
        insert cmp;

        // Create dummy PartnerMarketingBudget
       /* PartnerMarketingBudget pmb = new PartnerMarketingBudget(
            Name = 'Test PMB',
            Title = 'Test PMB',
            Core_MDF_Program_Nm__c = 'PRG1',
            Core_MDF_Program__c = 'PRG1',
            Core_MDF_Budget_Type__c = 'IPA'
        );
        insert pmb;*/

        // Email template for finish()
        EmailTemplate template = new EmailTemplate(
            Name = 'MissingConfigTemplate',
            DeveloperName = 'Core_MDF_No_Approver_Email_Notifier',
            FolderId = UserInfo.getUserId(),
            TemplateType = 'text',
            Subject = 'Test',
            Body = 'Testing'
        );
        insert template;

        // Create Public Group for email sending
        Group g = new Group(
            Name = 'Missing Approver Group',
            DeveloperName = 'Core_MDF_Missing_Approver_Roles_Configur',
            Type = 'Regular'
        );
        insert g;

        // Add current user to that group
        GroupMember gm = new GroupMember(
            GroupId = g.Id,
            UserOrGroupId = UserInfo.getUserId()
        );
        insert gm;
    }

    @isTest
    static void testBatchExecution() {

        Test.startTest();

        // Run first batch (index = 0)
        Core_MDF_MultiObject_NotificationBatch batchObj =
            new Core_MDF_MultiObject_NotificationBatch();

        Database.executeBatch(batchObj, 10);

        Test.stopTest();

        // -------------------------
        // Assertions
        // -------------------------

        // Check record tracking
        Core_MDF_Record_Tracking__c rt = [
            SELECT Id, Core_MDF_Scope_nm__c
            FROM Core_MDF_Record_Tracking__c
            LIMIT 1
        ];
        System.assertEquals(
            'Missing Approver Roles Configuration',
            rt.Core_MDF_Scope_nm__c,
            'Record tracking should be created in finish()'
        );

        // Verify at least one ContentDocument is created
        Integer cvCount = [
            SELECT COUNT() FROM ContentDocumentLink
            WHERE LinkedEntityId = :rt.Id
        ];
        System.assert(cvCount > 0, 'CSV attachment should be created in finish()');
    }

}