/**************************************************************************************
Apex Class Name : Core_Draco_PartnerLicCleanupBatch_Test
Version     : 1.0 
Created Date: 4th December 2024
Description : Test class for Core_Draco_PartnerLicenseCleanupBatch
* Modification Log : 
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Sharmila Garlapati        04-Dec-2024             Original Version
*************************************************************************************/
@isTest
public class Core_Draco_PartnerLicCleanupBatch_Test {
    
    @isTest
    static void testCoreDracoPartnerLicenseCleanupBatch() {
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            Account acc1 = new Account(); 
            acc1.Name = 'Mobile Networks';
            acc1.BillingCity = 'New York';
            acc1.BillingStreet = 'Street 1';
            acc1.BillingCountry = 'USA';
            acc1.BillingCountryCode = 'USA';
            acc1.BillingPostalCode = '24356';
            acc1.Core_Account_Tier__c = 'Tier1';
            acc1.RecordTypeId=intelAccRecTypeId;
            insert acc1;
            
            Contact contact1 = new Contact(
                FirstName = 'Contact1',
                LastName = 'Partneruser1',
                Email = 'partneruser1@example.com',
                AccountId = acc1.Id,
                MailingCountry = 'India'
            );
            insert contact1;
            
            Contact contact2 = new Contact(
                FirstName = 'Contact2',
                LastName = 'Partneruser2',
                Email = 'partneruser2@example.com',
                AccountId = acc1.Id,
                MailingCountry = 'USA'
            );
            insert contact2;
            
            Contact contact3 = new Contact(
                FirstName = 'Contact3',
                LastName = 'Partneruser3',
                Email = 'partneruser3@example.com',
                AccountId = acc1.Id,
                MailingCountry = 'Canada'
            );
            insert contact3;
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            User testUser1 = new User(
                Alias = 'testusr1',
                Email = 'testpartneruser1@example.com',
                Username = 'testpartneruser1@example.com',
                FirstName = 'Test1',
                LastName = 'Partneruser1',
                ProfileId = partnerProfile.Id,
                FederationIdentifier = '0987654',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = true, 
                Partner_License_Reclaimed__c = false, 
                ContactId = contact1.Id
            );
            insert testUser1;
            
            DateTime lessThan6MonthsAgo = DateTime.now().addMonths(-8).addDays(-10);
            Test.setCreatedDate(testUser1.Id, lessThan6MonthsAgo);
            
            User testUsr = [SELECT Id,LastLoginDate FROM User WHERE Id = :testUser1.Id];
            
            
            User testUser2 = new User(
                Alias = 'testusr2',
                Email = 'testpartneruser2@example.com',
                Username = 'testpartneruser2@example.com',
                FirstName = 'Test2',
                LastName = 'Partneruser2',
                ProfileId = partnerProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = true, 
                Partner_License_Reclaimed__c = false,
                ContactId = contact2.Id
            );
            insert testUser2;
            
            User testUser3 = new User(
                Alias = 'testusr3',
                Email = 'testpartneruser3@example.com',
                Username = 'testpartneruser3@example.com',
                FirstName = 'Test3',
                LastName = 'Partneruser3',
                ProfileId = partnerProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = true, 
                Partner_License_Reclaimed__c = false, 
                ContactId = contact3.Id
            );
            insert testUser3;
            
            
            Core_AGS_Role__c testAGSRole1 = new Core_AGS_Role__c();
            testAGSRole1.Name = 'SPCF Claim Submitter';
            testAGSRole1.Core_IsActive__c = true;
            testAGSRole1.Core_Technical_Name__c = 'SPCF_External_Claim _Submitter';
            insert testAGSRole1;
            
            Core_Entitlement__c testEntitlementDetail1 = new Core_Entitlement__c();
            testEntitlementDetail1.Name = 'SPCF Claim Submitter';
            testEntitlementDetail1.Core_Display_Name__c = 'SPCF Claim Submitter';
            testEntitlementDetail1.Entitlement_B2B_B2C_Indicator__c = 'B2B'; 
            testEntitlementDetail1.Core_AGS_Role_Id__c = testAGSRole1.Id;
            testEntitlementDetail1.Core_IsActive__c = true;
            testEntitlementDetail1.Core_Category__c='Intel® Partner Investment Center';
            insert testEntitlementDetail1;
            
            Core_Contact_Entitlement__c contactEntitlement1 = new Core_Contact_Entitlement__c(
                Core_Contact_Id__c=contact1.Id,Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
                Core_Entitlement_Id__c=testEntitlementDetail1.id,Core_Status__c ='Pending');
            insert contactEntitlement1;
            
            Core_AGS_Role__c testAGSRole2 = new Core_AGS_Role__c();
            testAGSRole2.Name = 'Partner Portal';
            testAGSRole2.Core_IsActive__c = true;
            testAGSRole2.Core_Technical_Name__c = 'Partner Portal';
            insert testAGSRole2;
            
            Core_Entitlement__c testEntitlementDetail2 = new Core_Entitlement__c();
            testEntitlementDetail2.Name = 'Partner Portal';
            testEntitlementDetail2.Core_Display_Name__c = 'Partner Portal';
            testEntitlementDetail2.Entitlement_B2B_B2C_Indicator__c = 'B2B'; 
            testEntitlementDetail2.Core_AGS_Role_Id__c = testAGSRole2.Id;
            testEntitlementDetail2.Core_IsActive__c = true;
            testEntitlementDetail2.Core_Category__c='Partner Portal';
            insert testEntitlementDetail2;
            
            Core_Contact_Entitlement__c contactEntitlement2 = new Core_Contact_Entitlement__c(
                Core_Contact_Id__c=contact1.Id,Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
                Core_Entitlement_Id__c=testEntitlementDetail2.id,Core_Status__c ='Pending');
            insert contactEntitlement2;
            
            Core_CustomMetadata_Object__c customMdt=new Core_CustomMetadata_Object__c();
            customMdt.Metadata_Name__c='Core_PartnerLicenseReclaim__mdt';
            customMdt.Field_1_Text_Area__c='testPermissionset';
            insert customMdt;
            
            Set<Id> conSetNew = new Set<Id>();
            conSetNew.add(contact1.Id);
            
            Test.startTest();
            Core_Draco_PartnerLicenseCleanupBatch batch = new Core_Draco_PartnerLicenseCleanupBatch();
            Database.executeBatch(batch,1); 
            
            
            Core_PartnerLicenseConUpdBatch batch1 = new Core_PartnerLicenseConUpdBatch(conSetNew);
            Database.executeBatch(batch1,1); 
            Test.stopTest();
            
        }
    }
}