@isTest
public class Core_IntegrationTestUtility {
    
    public static List<Account> setupAccountTestData() {
        
        // Account records
        List<Account> testAccounts = Core_Test_Utility.createAccount(25);
        for(integer i = 0; i < testAccounts.size(); i++) {
            testAccounts[i].Industry = 'Agriculture';
            if(i > 16)
            {
                testAccounts[i].BillingCountryCode = 'IND';
                testAccounts[i].BIllingStateCode = 'KA';
                testAccounts[i].BillingCity = 'Bengaluru';
                testAccounts[i].BillingStreet = 'M G Road';
                //accountList.add(accountInstance);
                
            }
        }
        testAccounts[0].Name = 'Test Account 0';
        testAccounts[1].Name = 'Test Account 1';
        testAccounts[2].Name = 'Test Account 2';
        testAccounts[3].Name = 'Test Account 3';
        testAccounts[4].Name = 'Test Account 4';
        testAccounts[5].Name = 'Test Account 5';
        testAccounts[6].Name = 'Test Account 6';
        testAccounts[7].Name = 'Test Account 7';
        testAccounts[8].Name = 'Test Account 8';
        testAccounts[9].Name = 'Test Account 9';
        testAccounts[10].Name = 'Test Account 10';
        testAccounts[11].Name = 'Test Account 11';
        
        testAccounts[12].Name = 'HSK Account 12';
        testAccounts[13].Name = 'HSK Account 13';
        testAccounts[14].Name = 'HSK Account 14';
        testAccounts[15].Name = 'HSK Account 15';
        testAccounts[16].Name = 'HSK Account 16';
        testAccounts[17].Name = 'HSK Account 17';
        testAccounts[18].Name = 'HSK Account 18';
        testAccounts[19].Name = 'HSK Account 19';
        testAccounts[20].Name = 'HSK Account 20';
        testAccounts[21].Name = 'HSK Account 21';
        testAccounts[22].Name = 'HSK Account 22';
        testAccounts[23].Name = 'HSK Account 23';
        testAccounts[24].Name = 'HSK Account 24';
        
        testAccounts[0].Core_CIM_ID__c = '1000';
        testAccounts[1].Core_CIM_ID__c = '1001';
        testAccounts[1].ShippingCity = 'Portland';
        testAccounts[2].Core_CIM_ID__c = '1002';
        testAccounts[3].Core_CIM_ID__c = '1003';
        testAccounts[4].Core_CIM_ID__c = '1004';
        testAccounts[5].Core_CIM_ID__c = '1005';
        testAccounts[6].Core_CIM_ID__c = '1006';
        testAccounts[7].Core_CIM_ID__c = '1237';
        testAccounts[8].Core_CIM_ID__c = '8888';
        testAccounts[9].Core_CIM_ID__c = '8888';
        testAccounts[12].Core_CIM_ID__c = '8970';
        testAccounts[13].Core_CIM_ID__c = '8970';
        testAccounts[14].Core_CIM_ID__c = '8970';
        testAccounts[15].Core_CIM_ID__c = '8970';
        testAccounts[17].Core_CIM_ID__c = '8970';
        testAccounts[18].Core_CIM_ID__c = '8970';
        testAccounts[10].Core_CIM_ID__c = '9999';
        testAccounts[11].Core_CIM_ID__c = '9999';
        testAccounts[16].Core_CIM_ID__c = '3690';
        testAccounts[19].Core_CIM_ID__c = '3690';
        testAccounts[20].Core_CIM_ID__c = '3690';
        testAccounts[21].Core_CIM_ID__c = '3690';
        testAccounts[22].Core_CIM_ID__c = '3690';
        testAccounts[23].Core_CIM_ID__c = '3690';
        testAccounts[24].Core_CIM_ID__c = '3691';
        
        
        testAccounts[0].Core_B2B_Entitlement__c = true;
        testAccounts[0].Core_CNDA_Number__c = '12345';
        testAccounts[1].Core_B2B_Entitlement__c = true;
        testAccounts[1].Core_CNDA_Number__c = '98765';
        testAccounts[2].Core_B2B_Entitlement__c = false;
        testAccounts[3].Core_B2B_Entitlement__c = false;
        testAccounts[4].Core_B2B_Entitlement__c = false;
        testAccounts[7].Core_B2B_Entitlement__c = false;
        
       
        
        testAccounts[2].Core_IPA_Partner_Role__c = 'Service Provider;Solution Integrator';
        testAccounts[3].Core_IPA_Partner_Role__c = 'Service Provider;Solution Integrator';
        testAccounts[3].Core_IPA_Partner_Role__c = 'Service Provider;Solution Integrator';
        testAccounts[24].Core_IPA_Partner_Role__c = 'Service Provider';
        
       /* testAccounts[2].Core_IPA_Partner_Speciality__c = 'Enthusiast PC Specialist';
        testAccounts[3].Core_IPA_Partner_Speciality__c = 'Enthusiast PC Specialist;Video Specialist';
        testAccounts[5].Core_IPA_Partner_Speciality__c = 'Enthusiast PC Specialist;Video Specialist';
        testAccounts[6].Core_IPA_Partner_Speciality__c = 'Enthusiast PC Specialist';
         testAccounts[24].Core_IPA_Partner_Speciality__c = 'Enthusiast PC Specialist';*/
        
        
        testAccounts[8].Core_Intel_Partner_Alliance_PartnerGroup__c = true;       
        testAccounts[9].Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccounts[12].Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccounts[13].Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccounts[14].Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccounts[15].Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        

      	testAccounts[9].Core_IPA_Partner_Role__c='Service Provider';
        
        testAccounts[16].OwnerId = [Select id from User where alias =: System.Label.PRM_UncoveredAccount][0].Id;
        testAccounts[19].OwnerId = [Select id from User where alias =: System.Label.PRM_UncoveredAccount][0].Id;
        testAccounts[20].OwnerId = [Select id from User where alias =: System.Label.PRM_UncoveredAccount][0].Id;
        testAccounts[21].OwnerId = [Select id from User where alias =: System.Label.PRM_UncoveredAccount][0].Id;
        testAccounts[22].OwnerId = [Select id from User where alias =: System.Label.PRM_UncoveredAccount][0].Id;
        testAccounts[23].OwnerId = [Select id from User where alias =: System.Label.PRM_UncoveredAccount][0].Id;
        
        testAccounts[16].CreatedDate=date.valueOf('2020-04-07 11:56:08');
        testAccounts[19].CreatedDate=date.valueOf('2020-04-07 11:57:08');
        testAccounts[20].CreatedDate=date.valueOf('2020-04-07 11:58:08');
        testAccounts[21].CreatedDate=date.valueOf('2020-04-07 11:59:08');
        testAccounts[22].CreatedDate=date.valueOf('2020-04-07 11:60:08');
        testAccounts[23].CreatedDate=date.valueOf('2020-04-07 11:61:08');
        
        insert testAccounts;
        System.debug(testAccounts[9].BillingCity + 'testAccounts[9].BillingCity');
           
        system.debug('account data done');
        return testAccounts;
    }
    
    public static List<Contact> setupContactTestData(List<Account> testAccounts) {
        
        // Contacts
        List<Contact> testContacts = Core_Test_Utility.createContacts(12);
        testContacts[0].AccountId = testAccounts[0].Id;
        testContacts[1].AccountId = testAccounts[0].Id; // 2 Contacts under same Account
        testContacts[2].AccountId = testAccounts[2].Id;
        testContacts[3].AccountId = testAccounts[3].Id;        
        testContacts[4].AccountId = testAccounts[4].Id;
        testContacts[5].AccountId = testAccounts[5].Id;
        testContacts[6].AccountId = testAccounts[6].Id;
        testContacts[7].AccountId = testAccounts[7].Id;
        testContacts[8].AccountId= testAccounts[14].Id;
        testContacts[9].AccountId= testAccounts[15].Id;
        testContacts[10].AccountId= testAccounts[15].Id;
        testContacts[11].AccountId = testAccounts[24].Id;
        
        testContacts[0].Core_eRPM_Person_Id__c = '3000000';
        testContacts[0].Email = 'testcontact0@acct0.com';
        testContacts[0].Core_Login_ID__c = 'test0';
        testContacts[0].Core_Enterprise_ID__c = '1000001000';
        testContacts[0].Core_Identity_Status__c = '';
        testContacts[0].Title = 'Mr';
        testContacts[0].FirstName = 'FName0';
        testContacts[0].LastName = 'LName0';
        testContacts[0].Phone = '1001001000';
        testContacts[0].Core_Preferred_Language__c = 'ENG';
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
        testContacts[0].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        
        testContacts[1].LastName = 'Test Contact 1';
        testContacts[1].Core_eRPM_Person_Id__c = '3000010';
        testContacts[1].Email = 'testcontact1@acct0.com';
        testContacts[1].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[1].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[1].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        testContacts[2].LastName = 'Test Contact 2';
        testContacts[2].Core_eRPM_Person_Id__c = '3000020';
        testContacts[2].Email = 'testcontact2@acct2.com';
        testContacts[2].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[2].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[2].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        testContacts[3].LastName = 'Test Contact 3';
        testContacts[3].Core_eRPM_Person_Id__c = '3000030';
        testContacts[3].Email = 'testcontact3@acct3.com';
        testContacts[3].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[3].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[3].Core_IPA_PartnerRole__c = 'Seller';
        testContacts[3].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        testContacts[4].LastName = 'Test Contact 4';
        testContacts[4].Core_eRPM_Person_Id__c = '3000040';
        testContacts[4].Email = 'testcontact4@acct4.com';
        testContacts[4].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[4].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[4].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        testContacts[5].LastName = 'Test Contact 5';
        testContacts[5].Core_eRPM_Person_Id__c = '3000050';
        testContacts[5].Email = 'testcontact5@acct5.com';
        testContacts[5].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[5].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[5].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        //testContacts[5].Core_IPA_PartnerRole__c = 'Seller;Manufacturer';
        testContacts[5].Core_IPA_PartnerRole__c = 'Manufacturer';
        
        testContacts[6].LastName = 'Test Contact 6';
        testContacts[6].Core_eRPM_Person_Id__c = '3000060';
        testContacts[6].Email = 'testcontact6@acct6.com';
        testContacts[6].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[6].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[6].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        testContacts[6].Core_IPA_PartnerRole__c = 'Seller';
        
        //testContacts[7].Core_eRPM_Person_Id__c = '';
        testContacts[7].Email = 'blackbox_integ_user@mailnator.com';
        testContacts[7].Core_Login_ID__c = 'test7';
        testContacts[7].Core_Enterprise_ID__c = '1000001007';
        testContacts[7].Core_Identity_Status__c = '';
        testContacts[7].Title = 'Mr';
        testContacts[7].FirstName = 'FName0';
        testContacts[7].LastName = 'LName0';
        testContacts[7].Phone = '1001001000';
        testContacts[7].Core_Preferred_Language__c = 'ENG';
        testContacts[7].MobilePhone = '2001001000';
        testContacts[7].Fax = '3001001000';
        testContacts[7].MailingStreet = 'Test Address 0';
        testContacts[7].MailingCity = 'Vancouver';
        testContacts[7].MailingState = 'BC';
        testContacts[7].MailingPostalCode = '10000';
        testContacts[7].MailingCountry = 'CAN';
        testContacts[7].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[7].Core_ERPM_Integration_Message__c = 'Testing';
        testContacts[7].Core_AGS_Integration_Status__c = 'Pending';
        testContacts[7].Core_AGS_Integration_Message__c = 'Testing';
        testContacts[7].Core_Contact_B2B_Indicator__c = true;
        testContacts[7].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId(); // Had to add this since other unrelated IPS code was failing without it
        testContacts[7].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        testContacts[8].FirstName = 'Kevin';
        testContacts[8].LastName = 'P';
        testContacts[8].Core_eRPM_Person_Id__c = '7000010';
        testContacts[8].Email = 'kevinp@mailinator.com';
        testContacts[8].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[8].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[8].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        testContacts[9].FirstName = 'Karla';
        testContacts[9].LastName = 'A';
        testContacts[9].Core_eRPM_Person_Id__c = '7004010';
        testContacts[9].Email = 'karlaa@mailinator.com';
        testContacts[9].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[9].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[9].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        testContacts[10].FirstName = 'John';
        testContacts[10].LastName = 'Y';
        testContacts[10].Core_eRPM_Person_Id__c = '7060010';
        testContacts[10].Email = 'johny@mailinator.com';
        testContacts[10].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[10].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[10].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        testContacts[11].LastName = 'Test Contact 11';
        testContacts[11].Core_eRPM_Person_Id__c = '3003691';
        testContacts[11].Email = 'testcontact11@acct11.com';
        testContacts[11].Core_ERPM_Integration_Status__c = 'Pending';
        testContacts[11].Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
        testContacts[11].RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        testContacts[11].Core_IPA_PartnerRole__c = 'Seller';
        
        insert testContacts;   
        system.debug('Contact data done'+testContacts);
        return testContacts;
    }
    
    // Test utility method to set up a bunch of test data
    public static void setupAcctContactEntitlementTestData(boolean IsIPATest) {
        
        List<Core_Trigger_Executions__c> triggerEntries = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='processInboundMessagesAGS', Core_Object__c='Core_Integration_Inbound_Message__c',
            Core_Class_Name__c='Core_IntegrationInboundMessageHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=true, Core_Description__c='testing, testing');
       // triggerEntries.add(triggerEntry);
        insert triggerEntry;
        
        triggerEntry = new Core_Trigger_Executions__c(
            Name='processInboundMessagesERPM', Core_Object__c='Core_Integration_Inbound_Message__c',
            Core_Class_Name__c='Core_IntegrationInboundMessageHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=true, Core_Description__c='testing, testing');
        //triggerEntries.add(triggerEntry);
        insert triggerEntry;
        
        triggerEntry = new Core_Trigger_Executions__c(Name='SwitchToERPMInboundContactService', Core_Object__c='Core_Integration_Inbound_Message__c',
            Core_Class_Name__c='Core_IntegrationInboundMessageHandler',
            Core_Trigger_Events__c='after insert', Core_Active__c=true, Core_Description__c='This is used to switch the ERPM to SF contact integration to refactored code');
        insert triggerEntry;
        
        triggerEntry = new Core_Trigger_Executions__c(
            Name='Core_ContactEntValidationSwitch', Core_Object__c='Core_Contact_Entitlement__c',
            //Core_Class_Name__c='Core_ContactEntitlementHandler',
            Core_Class_Name__c='Core_ContactEntitlementHelper', //Added by Draco to update helper class
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
        testERPMEnggs.add(newERPMEngagement('ISA'));
        testERPMEnggs.add(newERPMEngagement('ITP'));
        if(!IsIPATest){
            testERPMEnggs.add(newERPMEngagement('PE1'));
            testERPMEnggs.add(newERPMEngagement('PE2'));
            testERPMEnggs.add(newERPMEngagement('CSPx2'));
            testERPMEnggs.add(newERPMEngagement('PE3'));
        }
        insert testERPMEnggs;
        
        //Core_IntegrationTestUtility.insertMissingEngagementsEntitlements(testERPMEnggs,enggCode);        
        if(!IsIPATest){
            // AGS Roles
            List<Core_AGS_Role__c> testAGSRoles = new List<Core_AGS_Role__c>();
            testAGSRoles.add(new Core_AGS_Role__c(Name='Role 1', Core_Technical_Name__c='Role_1', Core_IsActive__c=true));
            testAGSRoles.add(new Core_AGS_Role__c(Name='Role 2', Core_Technical_Name__c='Role_2', Core_IsActive__c=true));
            testAGSRoles.add(new Core_AGS_Role__c(Name='Role 3', Core_Technical_Name__c='Role_3', Core_IsActive__c=true));
            testAGSRoles.add(new Core_AGS_Role__c(Name='Role 4', Core_Technical_Name__c='Role_4', Core_IsActive__c=true));
            testAGSRoles.add(new Core_AGS_Role__c(Name='Role 5', Core_Technical_Name__c='Role_5', Core_IsActive__c=true));
            testAGSRoles.add(new Core_AGS_Role__c(Name='Role 6', Core_Technical_Name__c='Role_6', Core_IsActive__c=true));
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
            testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[3].Id, Core_IsActive__c=true,
                                                         Name='Person Engg 2 AGS Role 3', Core_Display_Name__c='Person Engagement 2 AGS Role 3', Core_AGS_Role_Id__c=testAGSRoles[2].Id));
            testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[3].Id, Core_IsActive__c=true,
                                                         Name='Person Engg 2 AGS Role 4', Core_Display_Name__c='Person Engagement 2 AGS Role 4', Core_AGS_Role_Id__c=testAGSRoles[3].Id));
            testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[3].Id, Core_IsActive__c=true,
                                                         Name='Person Engg 2 AGS Role 5', Core_Display_Name__c='Person Engagement 2 AGS Role 5', Core_AGS_Role_Id__c=testAGSRoles[4].Id));
            testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[3].Id, Core_IsActive__c=true,
                                                         Name='Person Engg 2 AGS Role 6', Core_Display_Name__c='Person Engagement 2 AGS Role 6', Core_AGS_Role_Id__c=testAGSRoles[5].Id));
            
            testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[4].Id, Core_IsActive__c=false,
                                                         Name='Account Engg 3', Core_Display_Name__c='Account Engagement 3'));
            testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[5].Id, Core_IsActive__c=false,
                                                         Name='Person Engg 3', Core_Display_Name__c='Person Engagement 3'));
            
            insert testEntitlements;
            
            //test.startTest();
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
            testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[6].Id,
                                                        Core_Selected__c=true, Core_Status__c = 'Pending'));
            testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[7].Id,
                                                        Core_Selected__c=true, Core_Status__c = 'Pending')); 
            testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[8].Id,
                                                        Core_Selected__c=true, Core_Status__c = 'Complete'));
            testCEs.add(new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContacts[0].Id, Core_Entitlement_Id__c=testEntitlements[9].Id,
                                                        Core_Selected__c=false, Core_Status__c = 'Complete')); 
            insert testCEs;
            //test.stopTest();
            
            // Account ERPM Engagements
            List<Core_Account_ERPM_Engagement__c> testAcctEnggs = new List<Core_Account_ERPM_Engagement__c>();
            testAcctEnggs.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[0].Id, Core_ERPM_Engagement_Id__c=testERPMEnggs[0].Id));
            testAcctEnggs.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[0].Id, Core_ERPM_Engagement_Id__c=testERPMEnggs[1].Id));
            insert testAcctEnggs;
        }
        
        if(IsIPATest){
            //Channel Program
            ChannelProgram cp = Core_Integ_Additional_Attributes_Test.CreateChannelProgram('Intel Partner Alliance','IPA');
            //Channel Program Level
            List<ChannelProgramLevel> cpl = Core_Integ_Additional_Attributes_Test.CreateChannelProgramLevel(cp.Id); 
            //Account Channel Membership association
            
            List<PRM_AccountChannelMembership__c> accountChannelMemberships = new List<PRM_AccountChannelMembership__c>();
            PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); // Account Channel Membership association
            acm.PRM_Account_Id__c=testAccounts[0].Id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl[0].Id;
            acm.PRM_Partner_Role__c = 'Service Provider';//'Service Provider'
            accountChannelMemberships.add(acm);
            
            acm = new PRM_AccountChannelMembership__c(); // Account Channel Membership association
            acm.PRM_Account_Id__c=testAccounts[2].Id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl[1].Id;
            acm.PRM_Partner_Role__c = 'Seller';//'Seller'
            accountChannelMemberships.add(acm);
            
            acm = new PRM_AccountChannelMembership__c(); // Account Channel Membership association
            acm.PRM_Account_Id__c=testAccounts[2].Id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl[1].Id;
            acm.PRM_Partner_Role__c = 'Manufacturer';//'Manufacturer'
            accountChannelMemberships.add(acm);
            
            acm = new PRM_AccountChannelMembership__c(); // Account Channel Membership association
            acm.PRM_Account_Id__c=testAccounts[5].Id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl[1].Id;
            acm.PRM_Partner_Role__c = 'Manufacturer';//'Service Provider'
            accountChannelMemberships.add(acm);
            
            acm = new PRM_AccountChannelMembership__c(); // Account Channel Membership association
            acm.PRM_Account_Id__c=testAccounts[0].Id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl[0].Id;
            acm.PRM_Partner_Role__c = 'Manufacturer';//'Manufacturer'
            accountChannelMemberships.add(acm);
            
            acm = new PRM_AccountChannelMembership__c(); // Account Channel Membership association
            acm.PRM_Account_Id__c=testAccounts[3].Id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl[0].Id;
            acm.PRM_Partner_Role__c = 'Manufacturer';//'Manufacturer'
            accountChannelMemberships.add(acm);
            
            acm = new PRM_AccountChannelMembership__c(); // Account Channel Membership association
            acm.PRM_Account_Id__c=testAccounts[6].Id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl[0].Id;
            acm.PRM_Partner_Role__c = 'Manufacturer';//'Manufacturer'
            accountChannelMemberships.add(acm);
            
            acm = new PRM_AccountChannelMembership__c(); // Account Channel Membership association
            acm.PRM_Account_Id__c=testAccounts[24].Id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl[0].Id;
            acm.PRM_Partner_Role__c = 'Seller';//'Seller'
            accountChannelMemberships.add(acm);

            
            insert accountChannelMemberships;
            system.debug('--accountChannelMemberships -- ' + accountChannelMemberships);
            
            //Partner Type
            PRM_PartnerType__c partnrType = Core_Integ_Additional_Attributes_Test.CreatePartnerType(cp.Id); 
            
            //Profile Question 
            List<PRM_Profile_Questions__c> profileQstns = Core_Integ_Additional_Attributes_Test.CreateProfileQuestions(cp.Id, new List<string> { 'PQ-000010' , 'PQ-000011'}); 
            //Profile Answers        
            Core_Integ_Additional_Attributes_Test.CreateProfileAnswers(profileQstns[0].Id, new List<string> { 'PA-000010' , 'PA-000011'});                   
            //Profile Answers
            Core_Integ_Additional_Attributes_Test.CreateProfileAnswers(profileQstns[1].Id, new List<string> { 'PA-000012' , 'PA-000013'});        
            
            //Contact Relationships
            List<PRM_ContactRelationships__c> contactReltns = new List<PRM_ContactRelationships__c>();
            PRM_ContactRelationships__c contactReltn = new PRM_ContactRelationships__c();
            contactReltn.PRM_Contact_Relationship_Cd__c ='PRIMARY';
            contactReltn.Name ='Primary Contact';
            contactReltn.PRM_Mandatory_Relationship_Ind__c = true;
            contactReltn.PRM_InActive_Ind__c= false;
            contactReltn.PRM_Channel_Program_Id__c = cp.Id;
            contactReltns.add(contactReltn);
            //insert contactReltn;        
            
            contactReltn = new PRM_ContactRelationships__c();
            contactReltn.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
            contactReltn.Name ='Employee';
            contactReltn.PRM_Default_Relationship_Ind__c = true;
            contactReltn.PRM_InActive_Ind__c= false;
            contactReltn.PRM_Channel_Program_Id__c = cp.Id;
            contactReltns.add(contactReltn);
            insert contactReltns;
            system.debug('contactReltns --->> ' + contactReltns);
            
            List<PRM_Partner_Subscription__c> lps = new List<PRM_Partner_Subscription__c>();
            PRM_Partner_Subscription__c ps = new PRM_Partner_Subscription__c();
            ps.name = 'NewsletterGold - CIP';
            ps.PRM_Subscription_Cd__c = 'Gold';
            ps.PRM_InActive_Ind__c= false;
            ps.PRM_Subscription_Type_Nm__c = 'Newsletters - Distributor for Intel Technology Provider';
            lps.add(ps);
            
            ps = new PRM_Partner_Subscription__c();
            ps.name = 'NewsletterPlatinum - CIP';
            ps.PRM_Subscription_Cd__c = 'Platinum';
            ps.PRM_InActive_Ind__c= false;
            ps.PRM_Subscription_Type_Nm__c = 'Newsletters - Distributor for Intel Technology Provider';
            lps.add(ps);
            
            ps = new PRM_Partner_Subscription__c();
            ps.name = 'NewsletterSilver - CIP';
            ps.PRM_Subscription_Cd__c = 'Silver';
            ps.PRM_InActive_Ind__c= false;
            ps.PRM_Subscription_Type_Nm__c = 'Newsletters - Distributor for Intel Technology Provider';
            lps.add(ps);
            
            insert lps;
            
            List<Core_Account_ERPM_Engagement__c> testAcctEngagements = new List<Core_Account_ERPM_Engagement__c>();
            List<Core_ERPM_Engagement__c> testERPMEngg = new List<Core_ERPM_Engagement__c>();
            testERPMEngg.add(newERPMEngagement('ISA'));
            testERPMEngg.add(newERPMEngagement('ITP'));
            testERPMEngg.add(newERPMEngagement('CSPx2'));
            insert testERPMEngg;
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[2].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='98765',Core_ERPM_Business_Attributes__c='REGISTERED')); 
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[8].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='54321',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[9].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='54321',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[10].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='54321',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[11].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='54321',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[12].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='12345',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[13].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='12345',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[14].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='12345',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[15].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='12345',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[1].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[2].Id,Core_ERPM_Business_Attributes__c='GENERAL',Core_ERPM_Account_Number__c=''));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[3].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[2].Id,Core_ERPM_Account_Number__c='654789',Core_ERPM_Business_Attributes__c='GENERAL'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[17].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='12345',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[18].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='12345',Core_ERPM_Business_Attributes__c='REGISTERED'));
            //testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[16].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='3698574',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[19].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='3698574',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[20].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='3698574',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[21].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='3698574',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[22].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='3698574',Core_ERPM_Business_Attributes__c='REGISTERED'));
            testAcctEngagements.add(new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=testAccounts[23].Id, Core_ERPM_Engagement_Id__c=testERPMEngg[1].Id,Core_ERPM_Account_Number__c='3698574',Core_ERPM_Business_Attributes__c='REGISTERED'));

            
            
            System.debug('testAcctEnggs'+testAcctEngagements[1].Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
            insert testAcctEngagements;
            
            system.debug('PartnerSubs - '+lps);
        }
    }
    
    private static Core_ERPM_Engagement__c newERPMEngagement(String enggCode) {
        return new Core_ERPM_Engagement__c(Name=enggCode, Core_IsActive__c=true, Core_Engagement_Type__c='SMP',
                                           Core_Technical_Engagement_Code__c=enggCode, Core_Description__c=enggCode);
    } 
}