@IsTest
private class Core_AccountIntelAdminSharing_Test {
    @TestSetup
    static void createGroup() {
        // Group is setup data and visible in tests; only create it in orgs that don't have it.
        if (![SELECT Id FROM Group WHERE DeveloperName = 'IPA_All_Intel_Admin_Users'].isEmpty()) {
            return;
        }
        insert new Group(
            Name = 'IPA All Intel Admin Users',
            DeveloperName = 'IPA_All_Intel_Admin_Users',
            Type = 'Regular'
        );
    }

    private static Map<Id, Account> createAccountsAndMemberships() {
        TriggerHandler.bypass('Core_AccountTriggerHandler');
        TriggerHandler.bypass('Core_Acct_Grp_Mbr_TriggerHandler');
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 4; i++) {
            accounts.add(UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType(
                'Intel Admin Sharing ' + i, 'Intel Account', 'UNFD_GLBL_CUST'
            ));
        }
        Account partner = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType(
            'Intel Admin Sharing Partner', 'Partner Account Group', 'UNFD_GLBL_CUST'
        );
        insert partner;
        insert accounts;
        insert new List<Core_Account_Group_Member__c>{
            new Core_Account_Group_Member__c(
                Core_Intel_Account_Id__c = accounts[0].Id,
                Core_Partner_Account_Id__c = partner.Id,
                Primary_Account__c = true,
                Core_Inactive_Ind__c = false
            ),
            new Core_Account_Group_Member__c(
                Core_Intel_Account_Id__c = accounts[1].Id,
                Core_Partner_Account_Id__c = partner.Id,
                Primary_Account__c = true,
                Core_Inactive_Ind__c = true
            ),
            new Core_Account_Group_Member__c(
                Core_Intel_Account_Id__c = accounts[2].Id,
                Core_Partner_Account_Id__c = partner.Id,
                Primary_Account__c = false
            )
        };
        accounts.add(partner);
        return new Map<Id, Account>(accounts);
    }

    private static List<Core_Account_Group_Member__c> synchronizeShares(Map<Id, Account> accounts) {
        List<Core_Account_Group_Member__c> members = [
            SELECT Id, Core_Intel_Account_Id__c, Primary_Account__c
            FROM Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c IN :accounts.keySet()
        ];
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(members, null);
        return members;
    }

    @IsTest
    static void sharesOnlyPrimaryIntelAccountsAndDoesNotDuplicate() {
        Map<Id, Account> accounts = createAccountsAndMemberships();
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'IPA_All_Intel_Admin_Users'].Id;
        Set<Id> expectedAccountIds = new Set<Id>();
        for (Account account : accounts.values()) {
            if (account.Name == 'Intel Admin Sharing 0' || account.Name == 'Intel Admin Sharing 1') {
                expectedAccountIds.add(account.Id);
            }
        }
        // Isolate this method from sharing performed by other membership automation.
        delete [SELECT Id FROM AccountShare WHERE AccountId IN :accounts.keySet()
                AND UserOrGroupId = :groupId AND RowCause = 'Manual'];

        Test.startTest();
        Integer queriesBefore = Limits.getQueries();
        synchronizeShares(accounts);
        System.assertEquals(3, Limits.getQueries() - queriesBefore, 'Queries must be bulkified, including the test helper query.');
        synchronizeShares(accounts);
        Test.stopTest();

        List<AccountShare> shares = [
            SELECT AccountId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel
            FROM AccountShare
            WHERE AccountId IN :accounts.keySet() AND UserOrGroupId = :groupId AND RowCause = 'Manual'
        ];
        System.assertEquals(2, shares.size(), 'Only the two primary Intel accounts should be shared.');
        for (AccountShare share : shares) {
            System.assert(expectedAccountIds.contains(share.AccountId), 'Do not share the partner or non-primary accounts.');
            System.assertEquals('Edit', share.AccountAccessLevel);
            System.assertEquals('None', share.OpportunityAccessLevel);
            System.assertEquals('None', share.CaseAccessLevel);
        }
    }

    @IsTest
    static void upgradesReadAccessWithoutChangingRelatedRecordAccess() {
        Map<Id, Account> accounts = createAccountsAndMemberships();
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'IPA_All_Intel_Admin_Users'].Id;
        Id accountId;
        for (Account account : accounts.values()) {
            if (account.Name == 'Intel Admin Sharing 0') {
                accountId = account.Id;
            }
        }
        delete [SELECT Id FROM AccountShare WHERE AccountId = :accountId
                AND UserOrGroupId = :groupId AND RowCause = 'Manual'];
        AccountShare originalShare = new AccountShare(
            AccountId = accountId,
            UserOrGroupId = groupId,
            AccountAccessLevel = 'Read',
            OpportunityAccessLevel = 'Read',
            CaseAccessLevel = 'Read',
            RowCause = Schema.AccountShare.RowCause.Manual
        );
        insert originalShare;

        Test.startTest();
        synchronizeShares(accounts);
        Test.stopTest();

        AccountShare upgradedShare = [
            SELECT AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel
            FROM AccountShare WHERE Id = :originalShare.Id
        ];
        System.assertEquals('Edit', upgradedShare.AccountAccessLevel);
        System.assertEquals('Read', upgradedShare.OpportunityAccessLevel);
        System.assertEquals('Read', upgradedShare.CaseAccessLevel);
    }

    @IsTest
    static void reportsMissingPublicGroup() {
        delete [SELECT Id FROM Group WHERE DeveloperName = 'IPA_All_Intel_Admin_Users'];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Map<Id, Account> accounts = createAccountsAndMemberships();
            Test.startTest();
            List<Core_Account_Group_Member__c> members = synchronizeShares(accounts);
            Test.stopTest();
            for (Core_Account_Group_Member__c member : members) {
                if (member.Primary_Account__c) {
                    System.assert(member.hasErrors(), 'Checked memberships should report a missing group.');
                    System.assert(member.getErrors()[0].getMessage().contains('IPA_All_Intel_Admin_Users'));
                } else {
                    System.assert(!member.hasErrors(), 'Memberships without a checkbox change should not report errors.');
                }
            }
        }
    }

    @IsTest
    static void skipsEmptyAndNonPrimaryAccounts() {
        Map<Id, Account> accounts = createAccountsAndMemberships();
        Map<Id, Account> nonPrimaryAccounts = new Map<Id, Account>();
        for (Account account : accounts.values()) {
            if (account.Name == 'Intel Admin Sharing 2' || account.Name == 'Intel Admin Sharing 3') {
                nonPrimaryAccounts.put(account.Id, account);
            }
        }
        Test.startTest();
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(null, null);
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(new List<Core_Account_Group_Member__c>(), null);
        Integer queriesBefore = Limits.getQueries();
        Integer dmlBefore = Limits.getDmlStatements();
        synchronizeShares(nonPrimaryAccounts);
        System.assertEquals(1, Limits.getQueries() - queriesBefore);
        System.assertEquals(dmlBefore, Limits.getDmlStatements(), 'Non-primary accounts must not create shares.');
        Test.stopTest();
    }

    @IsTest
    static void handlesCheckboxUpdatesAndSkipsUnchangedMemberships() {
        Map<Id, Account> accounts = createAccountsAndMemberships();
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'IPA_All_Intel_Admin_Users'].Id;
        List<Core_Account_Group_Member__c> members = synchronizeShares(accounts);
        Map<Id, Core_Account_Group_Member__c> oldMembers = new Map<Id, Core_Account_Group_Member__c>();
        for (Core_Account_Group_Member__c member : members) {
            oldMembers.put(member.Id, member.clone(true, false, false, false));
            member.Primary_Account__c = !member.Primary_Account__c;
        }
        update members;

        Test.startTest();
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(members, oldMembers);
        List<AccountShare> shares = [
            SELECT AccountId, AccountAccessLevel FROM AccountShare
            WHERE AccountId IN :accounts.keySet() AND UserOrGroupId = :groupId AND RowCause = 'Manual'
        ];
        System.assertEquals(1, shares.size(), 'Only the newly checked membership should grant a share.');
        for (Core_Account_Group_Member__c member : members) {
            if (member.Primary_Account__c) {
                System.assertEquals(member.Core_Intel_Account_Id__c, shares[0].AccountId);
            }
        }
        System.assertEquals('Edit', shares[0].AccountAccessLevel);
        Integer queriesBefore = Limits.getQueries();
        Integer dmlBefore = Limits.getDmlStatements();
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(
            members, new Map<Id, Core_Account_Group_Member__c>(members)
        );
        System.assertEquals(queriesBefore, Limits.getQueries(), 'Unchanged checkbox and lookup must skip processing.');
        System.assertEquals(dmlBefore, Limits.getDmlStatements());
        Test.stopTest();
    }

    @IsTest
    static void movesSharingWhenPrimaryIntelAccountChanges() {
        Map<Id, Account> accounts = createAccountsAndMemberships();
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'IPA_All_Intel_Admin_Users'].Id;
        List<Core_Account_Group_Member__c> members = synchronizeShares(accounts);
        Id oldAccountId;
        Id newAccountId;
        for (Account account : accounts.values()) {
            if (account.Name == 'Intel Admin Sharing 0') {
                oldAccountId = account.Id;
            } else if (account.Name == 'Intel Admin Sharing 3') {
                newAccountId = account.Id;
            }
        }
        Core_Account_Group_Member__c movedMember;
        for (Core_Account_Group_Member__c member : members) {
            if (member.Core_Intel_Account_Id__c == oldAccountId) {
                movedMember = member;
            }
        }
        Map<Id, Core_Account_Group_Member__c> oldMembers = new Map<Id, Core_Account_Group_Member__c>{
            movedMember.Id => movedMember.clone(true, false, false, false)
        };
        movedMember.Core_Intel_Account_Id__c = newAccountId;
        update movedMember;

        Test.startTest();
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(
            new List<Core_Account_Group_Member__c>{ movedMember }, oldMembers
        );
        Test.stopTest();

        System.assertEquals(0, [
            SELECT COUNT() FROM AccountShare
            WHERE AccountId = :oldAccountId AND UserOrGroupId = :groupId AND RowCause = 'Manual'
        ], 'The old account must not retain its share after the primary membership moves.');
        System.assertEquals(1, [
            SELECT COUNT() FROM AccountShare
            WHERE AccountId = :newAccountId AND UserOrGroupId = :groupId
                AND RowCause = 'Manual' AND AccountAccessLevel = 'Edit'
        ], 'The new Intel account should receive Edit access.');
    }

    @IsTest
    static void removesSharingFromOldAccountWhenUncheckedAndMoved() {
        Map<Id, Account> accounts = createAccountsAndMemberships();
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'IPA_All_Intel_Admin_Users'].Id;
        List<Core_Account_Group_Member__c> members = synchronizeShares(accounts);
        Id oldAccountId;
        Id newAccountId;
        for (Account account : accounts.values()) {
            if (account.Name == 'Intel Admin Sharing 0') {
                oldAccountId = account.Id;
            } else if (account.Name == 'Intel Admin Sharing 3') {
                newAccountId = account.Id;
            }
        }
        Core_Account_Group_Member__c movedMember;
        for (Core_Account_Group_Member__c member : members) {
            if (member.Core_Intel_Account_Id__c == oldAccountId) {
                movedMember = member;
            }
        }
        Map<Id, Core_Account_Group_Member__c> oldMembers = new Map<Id, Core_Account_Group_Member__c>{
            movedMember.Id => movedMember.clone(true, false, false, false)
        };
        movedMember.Core_Intel_Account_Id__c = newAccountId;
        movedMember.Primary_Account__c = false;
        update movedMember;

        Test.startTest();
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(
            new List<Core_Account_Group_Member__c>{ movedMember }, oldMembers
        );
        Test.stopTest();

        System.assertEquals(0, [
            SELECT COUNT() FROM AccountShare
            WHERE AccountId = :oldAccountId AND UserOrGroupId = :groupId AND RowCause = 'Manual'
        ], 'Unchecking while moving must remove the old account share.');
        System.assertEquals(0, [
            SELECT COUNT() FROM AccountShare
            WHERE AccountId = :newAccountId AND UserOrGroupId = :groupId AND RowCause = 'Manual'
        ], 'The new Intel account must not be shared when the membership is not primary.');
    }

    @IsTest
    static void removesSharingAfterPrimaryIsUnchecked() {
        Map<Id, Account> accounts = createAccountsAndMemberships();
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'IPA_All_Intel_Admin_Users'].Id;
        synchronizeShares(accounts);
        List<Core_Account_Group_Member__c> memberships = [
            SELECT Id, Core_Intel_Account_Id__c, Primary_Account__c
            FROM Core_Account_Group_Member__c
            WHERE Core_Intel_Account_Id__c IN :accounts.keySet() AND Primary_Account__c = true
        ];
        Map<Id, Core_Account_Group_Member__c> oldMemberships = new Map<Id, Core_Account_Group_Member__c>();
        for (Core_Account_Group_Member__c membership : memberships) {
            oldMemberships.put(membership.Id, membership.clone(true, false, false, false));
            membership.Primary_Account__c = false;
        }
        update memberships;

        Test.startTest();
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(memberships, oldMemberships);
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(memberships, oldMemberships);
        Test.stopTest();

        System.assertEquals(0, [
            SELECT COUNT() FROM AccountShare
            WHERE AccountId IN :accounts.keySet() AND UserOrGroupId = :groupId AND RowCause = 'Manual'
        ], 'Manual shares should be removed when UCD primary is unchecked.');
    }

    @IsTest
    static void keepsSharingWhenNonPrimaryMembershipIsInserted() {
        Map<Id, Account> accounts = createAccountsAndMemberships();
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'IPA_All_Intel_Admin_Users'].Id;
        Id accountId;
        Id partnerId;
        for (Account account : accounts.values()) {
            if (account.Name == 'Intel Admin Sharing 0') {
                accountId = account.Id;
            } else if (account.Name == 'Intel Admin Sharing Partner') {
                partnerId = account.Id;
            }
        }
        synchronizeShares(accounts);
        System.assertEquals(1, [
            SELECT COUNT() FROM AccountShare
            WHERE AccountId = :accountId AND UserOrGroupId = :groupId AND RowCause = 'Manual'
        ], 'A share must exist before inserting another membership.');
        Core_Account_Group_Member__c nonPrimaryMember = new Core_Account_Group_Member__c(
            Core_Intel_Account_Id__c = accountId,
            Core_Partner_Account_Id__c = partnerId,
            Primary_Account__c = false
        );
        insert nonPrimaryMember;

        Test.startTest();
        Integer dmlBefore = Limits.getDmlStatements();
        Core_Acct_Grp_Mbr_TriggerHandler.shareUcdPrimaryAccountsWithIntelAdmins(
            new List<Core_Account_Group_Member__c>{ nonPrimaryMember }, null
        );
        System.assertEquals(dmlBefore, Limits.getDmlStatements(), 'Inserting a non-primary membership must not touch sharing.');
        Test.stopTest();

        System.assertEquals(1, [
            SELECT COUNT() FROM AccountShare
            WHERE AccountId = :accountId AND UserOrGroupId = :groupId
                AND RowCause = 'Manual'
        ], 'Other memberships of the Intel account are not checked, so the share is kept.');
    }
}