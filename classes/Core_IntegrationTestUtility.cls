@isTest
public class Core_IntegrationTestUtility {

    public static List<Account> setupAccountTestData() {

        // Account records
        List<Account> testAccounts = Core_Test_Utility.createAccount(6);
        testAccounts[0].Name = 'Test Account 0';
        testAccounts[1].Name = 'Test Account 1';
        testAccounts[2].Name = 'Test Account 2';
        testAccounts[3].Name = 'Test Account 3';
        testAccounts[4].Name = 'Test Account 4';
        testAccounts[5].Name = 'Test Account 5';

        testAccounts[0].Core_CIM_ID__c = '1000';
        testAccounts[1].Core_CIM_ID__c = '1001';
        testAccounts[2].Core_CIM_ID__c = '1002';
        testAccounts[3].Core_CIM_ID__c = '1003';
        testAccounts[4].Core_CIM_ID__c = '1004';
        testAccounts[5].Core_CIM_ID__c = '1005';

        testAccounts[0].Core_B2B_Entitlement__c = true;
        testAccounts[0].Core_CNDA_Number__c = '12345';
        testAccounts[1].Core_B2B_Entitlement__c = true;
        testAccounts[1].Core_CNDA_Number__c = '98765';
        testAccounts[2].Core_B2B_Entitlement__c = false;
        testAccounts[3].Core_B2B_Entitlement__c = false;
        testAccounts[4].Core_B2B_Entitlement__c = false;
        insert testAccounts;

        return testAccounts;
    }

    public static List<Contact> setupContactTestData(List<Account> testAccounts) {

        // Contacts
        List<Contact> testContacts = Core_Test_Utility.createContacts(5);
        testContacts[0].AccountId = testAccounts[0].Id;
        testContacts[1].AccountId = testAccounts[0].Id; // 2 Contacts under same Account
        testContacts[2].AccountId = testAccounts[2].Id;
        testContacts[3].AccountId = testAccounts[3].Id;
        testContacts[4].AccountId = testAccounts[4].Id;

        testContacts[0].Core_eRPM_Person_Id__c = '3000000';
        testContacts[0].Email = 'testcontact0@acct0.com';
        testContacts[0].Core_Login_ID__c = 'test0';
        testContacts[0].Core_Enterprise_ID__c = '1000001000';
        testContacts[0].Core_Identity_Status__c = '';
        testContacts[0].Title = 'Mr';
        testContacts[0].FirstName = 'FName0';
        testContacts[0].LastName = 'LName0';
        testContacts[0].Phone = '1001001000';
        testContacts[0].MobilePhone = '2001001000';
        testContacts[0].Fax = '3001001000';
        testContacts[0].MailingStreet = 'Test Address 0';
        testContacts[0].MailingCity = 'Vancouver';
        testContacts[0].MailingState = 'BC';
        testContacts[0].MailingPostalCode = '10000';
        testContacts[0].MailingCountry = 'CAN';
        testContacts[0].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[0].Core_ERPM_Integration_Message__c = 'Testing';
        testContacts[0].Core_AGS_Integration_Status__c = 'Pending';
        testContacts[0].Core_AGS_Integration_Message__c = 'Testing';
        testContacts[0].Core_Contact_B2B_Indicator__c = true;
        testContacts[0].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId(); // Had to add this since other unrelated IPS code was failing without it

        testContacts[1].LastName = 'Test Contact 1';
        testContacts[1].Core_eRPM_Person_Id__c = '3000010';
        testContacts[1].Email = 'testcontact1@acct0.com';
        testContacts[1].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[1].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();

        testContacts[2].LastName = 'Test Contact 2';
        testContacts[2].Core_eRPM_Person_Id__c = '3000020';
        testContacts[2].Email = 'testcontact2@acct2.com';
        testContacts[2].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[2].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();

        testContacts[3].LastName = 'Test Contact 3';
        testContacts[3].Core_eRPM_Person_Id__c = '3000030';
        testContacts[3].Email = 'testcontact3@acct3.com';
        testContacts[3].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[3].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();

        testContacts[4].LastName = 'Test Contact 4';
        testContacts[4].Core_eRPM_Person_Id__c = '3000040';
        testContacts[4].Email = 'testcontact4@acct4.com';
        testContacts[4].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[4].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();

        insert testContacts;

        return testContacts;
    }

    // Test utility method to set up a bunch of test data
    public static void setupAcctContactEntitlementTestData() {

        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='processInboundMessagesAGS', Core_Object__c='Core_Integration_Inbound_Message__c',
            Core_Class_Name__c='Core_IntegrationInboundMessageHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;

        triggerEntry = new Core_Trigger_Executions__c(
            Name='processInboundMessagesERPM', Core_Object__c='Core_Integration_Inbound_Message__c',
            Core_Class_Name__c='Core_IntegrationInboundMessageHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        insert new List<Core_Entitlement_Salutation_PrsTitle_Map__c> {
        	new Core_Entitlement_Salutation_PrsTitle_Map__c(Name = 'dr', PersonTitle__c ='DR', Salutation__c='Dr.'),
        	new Core_Entitlement_Salutation_PrsTitle_Map__c(Name = 'mr', PersonTitle__c ='MR', Salutation__c='Mr.')
        };

        List<Account> testAccounts = setupAccountTestData();
        List<Contact> testContacts = setupContactTestData(testAccounts);

        // ERPM Engagements
        List<Core_ERPM_Engagement__c> testERPMEnggs = new List<Core_ERPM_Engagement__c>();
        testERPMEnggs.add(newERPMEngagement('AE1'));
        testERPMEnggs.add(newERPMEngagement('AE2'));
        testERPMEnggs.add(newERPMEngagement('PE1'));
        testERPMEnggs.add(newERPMEngagement('PE2'));
        testERPMEnggs.add(newERPMEngagement('AE3'));
        testERPMEnggs.add(newERPMEngagement('PE3'));
        insert testERPMEnggs;
        
         //Core_IntegrationTestUtility.insertMissingEngagementsEntitlements(testERPMEnggs,enggCode);

        // AGS Roles
        List<Core_AGS_Role__c> testAGSRoles = new List<Core_AGS_Role__c>();
        testAGSRoles.add(new Core_AGS_Role__c(Name='Role 1', Core_Technical_Name__c='Role_1', Core_IsActive__c=true));
        testAGSRoles.add(new Core_AGS_Role__c(Name='Role 2', Core_Technical_Name__c='Role_2', Core_IsActive__c=true));
        insert testAGSRoles;

        // Entitlements
        List<Core_Entitlement__c> testEntitlements = new List<Core_Entitlement__c>();
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[0].Id, Core_IsActive__c=false,
            Name='Account Engg 1', Core_Display_Name__c='Account Engagement 1'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[1].Id, Core_IsActive__c=false,
            Name='Account Engg 2', Core_Display_Name__c='Account Engagement 2'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[2].Id, Core_IsActive__c=false,
            Name='Person Engg 1', Core_Display_Name__c='Person Engagement 1'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[3].Id, Core_IsActive__c=true,
            Name='Person Engg 2 AGS Role 1', Core_Display_Name__c='Person Engagement 2 AGS Role 1', Core_AGS_Role_Id__c=testAGSRoles[0].Id));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[3].Id, Core_IsActive__c=true,
            Name='Person Engg 2 AGS Role 2', Core_Display_Name__c='Person Engagement 2 AGS Role 2', Core_AGS_Role_Id__c=testAGSRoles[1].Id));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[3].Id, Core_IsActive__c=false,
            Name='Person Engg 2 No Role', Core_Display_Name__c='Person Engagement 2 No Role'));

        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[4].Id, Core_IsActive__c=false,
            Name='Account Engg 3', Core_Display_Name__c='Account Engagement 3'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[5].Id, Core_IsActive__c=false,
            Name='Person Engg 3', Core_Display_Name__c='Person Engagement 3'));
        insert testEntitlements;

        // Contact Entitlements
        // AE1: true, AE2: true, PE1: false, PE2-1: false, PE2-2: true, PE2-0: true
        List<Core_Contact_Entitlement__c> testCEs = new List<Core_Contact_Entitlement__c>();
        testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[0].Id,
                                                    Core_Selected__c=true, Core_From_Source__c=true));
        testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[1].Id,
                                                    Core_Selected__c=true, Core_From_Source__c=true));
        testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[2].Id,
                                                    Core_Selected__c=false, Core_From_Source__c=true, Core_Engagement_Tier__c = 'PERSONTIER1'));
        testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[3].Id,
                                                    Core_Selected__c=false, Core_From_Source__c=false));
        testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[4].Id,
                                                    Core_Selected__c=true, Core_From_Source__c=false));
        testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[5].Id,
                                                    Core_Selected__c=true, Core_From_Source__c=true));
        insert testCEs;

        // Account ERPM Engagements
        List<Core_Account_ERPM_Engagement__c> testAcctEnggs = new List<Core_Account_ERPM_Engagement__c>();
        testAcctEnggs.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[0].Id, Core_ERPM_Engagement_Id__c=testERPMEnggs[0].Id));
        testAcctEnggs.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[0].Id, Core_ERPM_Engagement_Id__c=testERPMEnggs[1].Id));
        insert testAcctEnggs;
    }

    private static Core_ERPM_Engagement__c newERPMEngagement(String enggCode) {
        return new Core_ERPM_Engagement__c(Name=enggCode, Core_IsActive__c=true, Core_Engagement_Type__c='SMP',
            Core_Technical_Engagement_Code__c=enggCode, Core_Description__c=enggCode);
    }
}