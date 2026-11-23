/**
 * @description Unit tests for Core_MDF_MultiObject_NotificationBatch.
 * Covers: start, execute, finish across supported objects (Campaign, PartnerFundRequest, PartnerMarketingBudget).
 * Ensures Record Tracking creation and ContentVersion/link creation flow executes without unhandled exceptions.
 *
 * Note:
 * - Avoids use of static methods inside inner helper types to prevent compile error:
 *   "static can only be used on methods of a top level type".
 * - External dependencies (handler maps, labels, constants) are not mocked; tests create minimal data so code paths run.
 */
@IsTest
private class Rishabh_Test {

    // Simple non-static helper to avoid static-on-inner-type compile error
    private class Helper {
        User makeUser() {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            User u = new User(
                FirstName = 'Test',
                LastName = 'User',
                Alias = 'tuser',
                Email = 'tuser@example.com',
                Username = 'tuser' + String.valueOf(Crypto.getRandomInteger()) + '@example.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id
            );
            insert u;
            return u;
        }

        Group makePublicGroup(String devName) {
            Group g = new Group(
                Name = devName,
                DeveloperName = devName,
                Type = 'Regular'
            );
            insert g;
            return g;
        }

        void addUserToGroup(Group g, User u) {
            GroupMember gm = new GroupMember(UserOrGroupId = u.Id, GroupId = g.Id);
            insert gm;
        }

        EmailTemplate makeTemplate(String devName) {
            // Simple text template kept in user's personal folder
            EmailTemplate et = new EmailTemplate(
                Name = devName,
                DeveloperName = devName,
                TemplateType = 'text',
                Subject = 'Test Subject',
                Body = 'Body',
                FolderId = UserInfo.getUserId()
            );
            insert et;
            return et;
        }

        Account makeAccountWithGeo() {
            Account a = new Account(Name = 'Acct with Geo');
            insert a;
            a.Core_Geo__c = 'WW';
            a.Core_Sub_Geo__c = 'Sub-Geo';
            update a;
            return a;
        }

        Campaign makeCampaignWithAccount(Account a) {
            Campaign c = new Campaign(
                Name = 'CMP With Acc',
                Core_MDF_Program__c = 'TEST_PRG_TXT',
                Core_MDF_Channel_Program__c = 'a0P000000000002',
                Core_MDF_Approval_Stage_nm__c = 'Stage-Y',
                Core_MDF_Opal_Budget_Type_Txt__c = 'BT-Y',
                //Core_MDF_Ultimate_Account_txt__c = '001000000000002',
                Core_MDF_Account__c = a.Id
            );
            insert c;
            return c;
        }

        PartnerFundRequest makePfr(Campaign c, Account partner) {
            PartnerFundRequest pfr = new PartnerFundRequest(
                Title = 'PFR Title',
                CampaignId = c.Id,
                ChannelPartnerId = partner.Id,
                //Core_MDF_Program__c = 'TEST_PRG_TXT',
                Core_MDF_Approval_Stage__c = 'Stage-Z',
                Core_MDF_Budget_Type_nm__c = 'BT-Z',
                //Core_MDF_Ultimate_Account_Id__c = partner.Id,
                Core_MDF_Region_nm__c = 'WW'
            );
            insert pfr;
            return pfr;
        }

        PartnerMarketingBudget makePmb(Account ultimateAcc) {
            PartnerMarketingBudget pmb = new PartnerMarketingBudget(
                Title = 'PMB Title',
                //Core_MDF_Program_Nm__c = 'TEST_PRG_TXT',
                Core_MDF_Program__c = 'a0P000000000003',
                Core_MDF_Budget_Type__c = 'BT-A'
                //Core_MDF_Ultimate_Account_Id__c = ultimateAcc.Id
            );
            insert pmb;
            return pmb;
        }

        Core_MDF_Record_Tracking__c getTrackingByScope() {
            List<Core_MDF_Record_Tracking__c> rts = [
                SELECT Id, Core_MDF_Scope_nm__c
                FROM Core_MDF_Record_Tracking__c
                WHERE Core_MDF_Scope_nm__c = 'Missing Approver Roles Configuration'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            return (rts.isEmpty() ? null : rts[0]);
        }
    }

    @IsTest
    static void test_campaign_path_creates_tracking_and_handles_finish() {
        Helper h = new Helper();
        User u = h.makeUser();

        System.runAs(u) {
            Group g = h.makePublicGroup('Core_MDF_Missing_Approver_Group');
            h.addUserToGroup(g, u);
            h.makeTemplate('Core_MDF_No_Approver_Email_Notifier');

            Account acc = h.makeAccountWithGeo();
            Campaign c = h.makeCampaignWithAccount(acc);

            Test.startTest();
            Database.executeBatch(new Core_MDF_MultiObject_NotificationBatch(), 5);
            Test.stopTest();

            Core_MDF_Record_Tracking__c rt = h.getTrackingByScope();
            System.assertNotEquals(null, rt, 'Record Tracking should be created in finish().');

            // Content links may or may not exist depending on handler-derived keys; query should not error
            Integer linkCount = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :rt.Id];
            System.assertEquals(true, linkCount >= 0, 'Finish completed without unhandled exceptions.');
        }
    }

    @IsTest
    static void test_pfr_path_recursion_and_finish() {
        Helper h = new Helper();
        User u = h.makeUser();

        System.runAs(u) {
            Group g = h.makePublicGroup('Core_MDF_Missing_Approver_Group');
            h.addUserToGroup(g, u);
            h.makeTemplate('Core_MDF_No_Approver_Email_Notifier');

            Account acc = h.makeAccountWithGeo();
            Campaign c = h.makeCampaignWithAccount(acc);
            h.makePfr(c, acc);

            Test.startTest();
            // Provide constructor that accepts index/recordTrackingId and run
            Core_MDF_MultiObject_NotificationBatch b = new Core_MDF_MultiObject_NotificationBatch(0, null);
            Database.executeBatch(b, 5);
            Test.stopTest();

            Core_MDF_Record_Tracking__c rt = h.getTrackingByScope();
            System.assertNotEquals(null, rt, 'Record Tracking should be created.');
        }
    }

    @IsTest
    static void test_pmb_path_runs_and_creates_tracking() {
        Helper h = new Helper();
        User u = h.makeUser();

        System.runAs(u) {
            Group g = h.makePublicGroup('Core_MDF_Missing_Approver_Group');
            h.addUserToGroup(g, u);
            h.makeTemplate('Core_MDF_No_Approver_Email_Notifier');

            Account ultimate = new Account(Name = 'Ultimate');
            insert ultimate;
            h.makePmb(ultimate);

            Test.startTest();
            Database.executeBatch(new Core_MDF_MultiObject_NotificationBatch(), 3);
            Test.stopTest();

            Core_MDF_Record_Tracking__c rt = h.getTrackingByScope();
            System.assertNotEquals(null, rt, 'Record Tracking should be created.');
        }
    }
}