@isTest
public class PMP_RemoveSharingForPartners_Test {

    @isTest
    static void test_RemoveSharing_Success() {

        String unique = String.valueOf(System.currentTimeMillis());

        /* =====================================================
           STEP 1: NON-SETUP OBJECTS
        ===================================================== */

        // Engagement
        Core_ERPM_Engagement__c erpmEng = new Core_ERPM_Engagement__c(
            Name = 'Intel Premier Support ' + unique,
            Core_IsActive__c = true
        );
        insert erpmEng;

        // Entitlements (match label values)
        Core_Entitlement__c entitlementAdmin = new Core_Entitlement__c(
            Name = 'Partner Admin',
            Core_Display_Name__c = 'Partner Admin',
            Core_ERPM_Engagement_Id__c = erpmEng.Id
        );

        Core_Entitlement__c entitlementDelegate = new Core_Entitlement__c(
            Name = 'Partner Admin Delegate ' + unique, // avoid duplicate
            Core_Display_Name__c = 'Partner Admin Delegate',
            Core_ERPM_Engagement_Id__c = erpmEng.Id
        );

        insert new List<Core_Entitlement__c>{
            entitlementAdmin,
            entitlementDelegate
        };

        // Account
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;

        Account partnerAccount = new Account(
            Name = 'PartnerAccount ' + unique,
            Core_Account_Type__c = 'Original Design Manufacturer (ODM)',
            Core_Sales_Group_New__c = 'CCG Sales Group',
            Industry = 'Agriculture',
            RecordTypeId = partnerAccRecTypeId,
            BillingCity = 'Delhi',
            BillingCountry = 'India',
            BillingStreet = 'abc chowk delhi',
            Core_PMP_Membership_Change_Ind__c = true
        );
        insert partnerAccount;

        // Contact
        Contact contact1 = new Contact(
            FirstName = 'Intel',
            LastName = 'Contact1',
            Email = 'test' + unique + '@example.com',
            AccountId = partnerAccount.Id,
            MailingCountry = 'India',
            Core_IPA_Contact_Segment__c = 'Client Computing;Data Center');
        insert contact1;

        /* =====================================================
           STEP 2: CONTACT ENTITLEMENTS (MATCH LABEL LOGIC)
        ===================================================== */

        List<Core_Contact_Entitlement__c> lstConEnts = new List<Core_Contact_Entitlement__c>();

        // 👉 Used by batch (Partner Admin)
        lstConEnts.add(new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = contact1.Id,
            Core_Entitlement_Id__c = entitlementAdmin.Id,
            Core_Status__c = 'Complete',
            Core_Selected__c = false
        ));

        // 👉 Used by batch (Partner Admin Delegate)
        lstConEnts.add(new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = contact1.Id,
            Core_Entitlement_Id__c = entitlementDelegate.Id,
			Core_Status__c = 'Complete',
            Core_Selected__c = false
        ));

        insert lstConEnts;

        /* =====================================================
           STEP 3: SETUP OBJECTS (runAs to avoid MIXED DML)
        ===================================================== */

        Profile sysProfile = [
            SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1
        ];

        User adminUser = new User(
            Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = sysProfile.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com'
        );
        insert adminUser;

        System.runAs(adminUser) {

            /* -------------------------------
               Create Partner User (your style)
            ------------------------------- */
            Profile partnerProfile = [
                SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1
            ];

            User userRec = new User(
                ProfileId = partnerProfile.Id,
                Username = 'testUser' + unique + '@CoreMD.com',
                Email = 'pb' + unique + '@ff.com',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                Alias = 'nuser',
                LastName = 'lastname',
                ContactId = contact1.Id
            );
            insert userRec;

            /* -------------------------------
               Create Group (REQUIRED FORMAT)
            ------------------------------- */
            String groupName = 'PMP_' + partnerAccount.Id;

            Group grp = new Group(
                Name = groupName,
                DeveloperName = groupName,
                Type = 'Regular'
            );
            insert grp;

            /* -------------------------------
               Add User to Group
            ------------------------------- */
            insert new GroupMember(
                GroupId = grp.Id,
                UserOrGroupId = userRec.Id
            );

            /* =====================================================
               STEP 4: STAGING + BATCH EXECUTION
            ===================================================== */

            Core_ACM_Account_Staging__c staging = new Core_ACM_Account_Staging__c(
                AccountId__c = contact1.Id,
                Core_Action__c = 'REMOVE_MPSHARE',
                Core_Status__c = 'NEW'
            );
            insert staging;

            Test.startTest();
                Database.executeBatch(new PMP_RemoveSharingForPartners(), 1);
            Test.stopTest();

            /* =====================================================
               STEP 5: ASSERTIONS
            ===================================================== */

            // ✅ Group members removed
            System.assertEquals(
                0,
                [SELECT COUNT() FROM GroupMember WHERE GroupId = :grp.Id],
                'Group members should be removed'
            );

            // ✅ Staging updated
            staging = [
                SELECT Core_Status__c
                FROM Core_ACM_Account_Staging__c
                WHERE Id = :staging.Id
            ];

            System.assertEquals(
                'COMPLETED',
                staging.Core_Status__c,
                'Staging should be COMPLETED'
            );
        }
    }
}