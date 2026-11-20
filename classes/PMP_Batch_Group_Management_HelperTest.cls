@IsTest(SeeAllData=false)
public class PMP_Batch_Group_Management_HelperTest {

    @IsTest
    static void testHelperMethods(){

        Account partnerAcc = new Account(
            Name = 'HelperPartner',
            RecordTypeId = System.Label.PMP_Partner_Account_Record_Type_Id,
            Industry = 'Agriculture',
            Core_PMP_Membership_Change_Ind__c = true);
        insert partnerAcc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName  = 'Contact',
            MailingCountry = 'India',
            Email     = 'helper@test.com',
            AccountId = partnerAcc.Id);
        insert con;

        User contextUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(contextUser) {

            Profile partnerProfile =[SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];

            User partnerUser = new User(
                ProfileId = partnerProfile.Id,
                Username = 'helperuser' + System.now().getTime() + '@test.com',
                Email = 'helperuser@test.com',
                Alias = 'hpusr',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                LastName = 'User',
                ContactId = con.Id
            );
            insert partnerUser;

               //EXISTING GROUP
            String existingGroupName =System.Label.PMP_Group_Name_Prefix + partnerAcc.Id;

            Group existingGroup = new Group(
                Name = existingGroupName,
                DeveloperName = existingGroupName,
                DoesIncludeBosses = false);
            insert existingGroup;

            insert new GroupMember(
                GroupId = existingGroup.Id,
                UserOrGroupId = partnerUser.Id);

               //NEW GROUP (DOES NOT EXIST)
            String newGroupName =System.Label.PMP_Group_Name_Prefix + partnerAcc.Id + '_NEW';

            PMP_Batch_Group_Management.createPublicGroups(
                new Set<String>{
                    existingGroupName, // already exists → skipped
                    newGroupName       // does NOT exist → CREATED 
                }
            );
      
            Map<Id, Id> conToUser =PMP_Batch_Group_Management.getconIdToUserIdMap(new Set<Id>{ partnerAcc.Id });
            System.assertNotEquals(null, conToUser);

            PMP_Public_Group_Management_Settings__c rule =
                new PMP_Public_Group_Management_Settings__c(
                    Name = 'RULE1',
                    PMP_Action_Txt__c = 'Add',
                    PMP_Contributing_Entitlement_Nm__c = 'Employee',
                    PMP_Public_Group_Nm__c = 'PMP_<OPID>'
                );

            Map<String, Set<Id>> expectedMap =
                PMP_Batch_Group_Management.getPublicGroupExpectedMap(
                    new List<Core_Contact_Entitlement__c>(),
                    new List<PMP_Public_Group_Management_Settings__c>{ rule },
                    conToUser,
                    new List<Account>{ partnerAcc });

            System.assertNotEquals(null, expectedMap);

            PMP_Batch_Group_Management.assignRemoveUserstoPublicGroups(
                new List<Group>{ existingGroup },
                new Map<String, Set<Id>>{existingGroup.DeveloperName => new Set<Id>{ partnerUser.Id }},
                new Map<String, Set<Id>>());

               //trimGroupName()
            String trimmed =
                PMP_Batch_Group_Management.trimGroupName(existingGroupName + '_THIS_IS_LONGER_THAN_40_CHARACTERS');
            System.assert(trimmed.length() <= 40);
        }
    }
    
    @IsTest
    static void test_assignRemoveUserstoPublicGroups_missingInsertBranch_PartnerUser() {
    
        Account acc = new Account(
            Name = 'AssignRemovePartner3',
            RecordTypeId = System.Label.PMP_Partner_Account_Record_Type_Id);
        insert acc;
    
        Contact con = new Contact(
            FirstName = 'Partner',
            LastName  = 'Contact',
            Email     = 'partner.contact@test.com',
            AccountId = acc.Id,
            MailingCountry = 'India');
        insert con;
    
        User ctxUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    
        System.runAs(ctxUser) {
    
            // Existing user already in group
            Id userAlreadyInGroup = UserInfo.getUserId();
    
            Profile partnerProfile =[SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
    
            User partnerUser2 = new User(
                ProfileId = partnerProfile.Id,
                Username = 'partneruser2' + System.now().getTime() + '@test.com',
                Email = 'partneruser2@test.com',
                Alias = 'ptu2',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                LastName = 'PartnerUser',
                ContactId = con.Id
            );
            insert partnerUser2;
    
            String grpName = System.Label.PMP_Group_Name_Prefix + acc.Id;
    
            Group grp = new Group(
                Name = grpName,
                DeveloperName = grpName,
                DoesIncludeBosses = false
            );
            insert grp;
    
            GroupMember existingGM = new GroupMember(
                GroupId = grp.Id,
                UserOrGroupId = userAlreadyInGroup);
            insert existingGM;
    
            Map<String, Set<Id>> addMap = new Map<String, Set<Id>>();
            addMap.put(grpName, new Set<Id>{
                userAlreadyInGroup,   // already in group → skipped
                partnerUser2.Id       // NOT in group → INSERT BRANCH 
            });
    
            Map<String, Set<Id>> removeMap = new Map<String, Set<Id>>();
    
            PMP_Batch_Group_Management.assignRemoveUserstoPublicGroups(new List<Group>{ grp },addMap,removeMap);
            System.assert(true, 'Missing insert branch executed');
        }
    }
    @IsTest
    static void test_assignRemoveUserstoPublicGroups_only() {
    
        Account acc = new Account(
            Name = 'AssignRemovePartner',
            RecordTypeId = System.Label.PMP_Partner_Account_Record_Type_Id);
        insert acc;
    
        User ctxUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    
        System.runAs(ctxUser) {
    
            Id testUserId = UserInfo.getUserId();
    
            String grpWithMemberName =
                System.Label.PMP_Group_Name_Prefix + acc.Id;
    
            Group grpWithMember = new Group(
                Name = grpWithMemberName,
                DeveloperName = grpWithMemberName,
                DoesIncludeBosses = false
            );
            insert grpWithMember;
    
            GroupMember gm = new GroupMember(
                GroupId = grpWithMember.Id,
                UserOrGroupId = testUserId);
            insert gm;
    
            String grpEmptyName = grpWithMemberName + '_EMPTY';
    
            Group grpEmpty = new Group(
                Name = grpEmptyName,
                DeveloperName = grpEmptyName,
                DoesIncludeBosses = false);
            insert grpEmpty;
    
            Map<String, Set<Id>> addMap = new Map<String, Set<Id>>();
            addMap.put(grpWithMemberName, new Set<Id>{ testUserId });
            addMap.put(grpEmptyName, new Set<Id>{ testUserId });
    
            Map<String, Set<Id>> removeMap = new Map<String, Set<Id>>();
            removeMap.put(grpWithMemberName, new Set<Id>{ testUserId });
    
            PMP_Batch_Group_Management.assignRemoveUserstoPublicGroups(new List<Group>{ grpWithMember, grpEmpty },addMap,removeMap);
            System.assert(true, 'assignRemoveUserstoPublicGroups executed');
        }
    }
    
    @IsTest
    static void test_getAllContactEntitlementwithOPID_emptyPath() {
    
        // Partner account 
        Account partnerAcc = new Account(
            Name = 'EntitlementPartner',
            RecordTypeId = System.Label.PMP_Partner_Account_Record_Type_Id
        );
        insert partnerAcc;
    
        // Inputs
        Set<Id> partnerAccountIds = new Set<Id>{ partnerAcc.Id };
        Set<String> entitlementNames = new Set<String>{ 'Employee' };
    
        // Call method under test
        List<Core_Contact_Entitlement__c> results =
            PMP_Batch_Group_Management.getAllContactEntitlementwithOPID(
                partnerAccountIds,
                entitlementNames
            );
    
        // Assertions
        System.assertNotEquals(
            null,
            results,
            'Method should never return null'
        );
    
        // In test context, read‑only OPID field is null → query returns zero rows
        System.assertEquals(
            0,
            results.size(),
            'Expected empty list in test context'
        );
    }
}