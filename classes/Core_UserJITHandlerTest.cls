/***************************************************************************************************** 
Class Name  :    Core_UserJITHandlerTest
Description :    This is the test class for Core_UserJITHandler class
Added By    :    Sharmila Garlapati
Created Date:   12/04/2024                     
*****************************************************************************************************/
@isTest
public class Core_UserJITHandlerTest {
    
    @isTest
    public static void testUpdateUser() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        System.runAs (thisUser) {
            Account acc1 = new Account(); 
            acc1.Name='Mobile Networks';
            acc1.BillingCity='Newyork';
            acc1.BillingStreet='Street 1';
            acc1.BillingCountry='USA';
            acc1.BillingCountryCode='USA';
            acc1.BillingPostalCode='24356';
            acc1.Core_Account_Tier__c = 'Tier1';
            acc1.RecordTypeId=intelAccRecTypeId;  
            insert acc1;
            
            Contact testContact = new Contact(FirstName='testFirstName258',LastName='testpartneruser258', Email='testpartneruser258@test.com',
                                              AccountId=acc1.id,Core_English_Only_First_Name__c = 'testFirst',MailingCountry='India',
                                              Core_Enterprise_Id__c='245689',Core_AGS_Integration_Status__c='Successful');
            
            insert testContact;
            
            Contact testContact1 = new Contact(FirstName='testFirstName15',LastName='testpartneruser15', Email='testpartneruser15@test.com',
                                              AccountId=acc1.id,Core_English_Only_First_Name__c = 'testFirst',MailingCountry='India',
                                              Core_Enterprise_Id__c='23689',Core_AGS_Integration_Status__c='Successful');
            
            insert testContact1;
            
            Contact testContact2 = new Contact(FirstName='testFirstName152',LastName='testpartneruser152', Email='testpartneruser152@test.com',
                                              AccountId=acc1.id,Core_English_Only_First_Name__c = 'testFirst',MailingCountry='India',
                                              Core_Enterprise_Id__c='236892',Core_AGS_Integration_Status__c='Successful');
            
            insert testContact2;
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            User testUser = new User(
                Alias = 'testusr5',
                Email = 'testpartneruser5@example.com',
                Username = 'testpartneruser5@example.com',
                FirstName = 'Test',
                LastName = 'Partneruser5',
                ProfileId = partnerProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = false,
                Partner_License_Reclaimed__c = true,
                ContactId = testContact.Id
            );
            insert testUser;
            
            User testUser1 = new User(
                Alias = 'testusr5',
                Email = 'testpartneruser15@example.com',
                Username = 'testpartneruser15@example.com',
                FirstName = 'Test',
                LastName = 'Partneruser15',
                ProfileId = partnerProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = false,
                ContactId = testContact1.Id
            );
            insert testUser1;
            
            User testUser2 = new User(
                Alias = 'tesr52',
                Email = 'testpartneruser152@example.com',
                Username = 'testpartneruser152@example.com',
                FirstName = 'Test',
                LastName = 'Partneruser152',
                ProfileId = partnerProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = false,
                Core_License_Reclaimed_on_Creation__c = true,
                ContactId = testContact2.Id
            );
            insert testUser2;
            
            Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
            testAGSRole.Name = 'Partner Portal';
            testAGSRole.Core_IsActive__c = true;
            testAGSRole.Core_Technical_Name__c = 'Partner Portal';
            insert testAGSRole;
            
            Core_AGS_Role__c testAGSRole1 = new Core_AGS_Role__c();
            testAGSRole1.Name = 'Employee';
            testAGSRole1.Core_IsActive__c = true;
            testAGSRole1.Core_Technical_Name__c = 'Employee';
            insert testAGSRole1;
            
            Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
            testEntitlementDetail.Name = 'Partner Portal';
            testEntitlementDetail.Core_Display_Name__c = 'Partner Portal';
            testEntitlementDetail.Entitlement_B2B_B2C_Indicator__c = 'B2B'; 
            testEntitlementDetail.Core_AGS_Role_Id__c = testAGSRole.Id;
            testEntitlementDetail.Core_IsActive__c = true;
            insert testEntitlementDetail;
            
            Core_Entitlement__c testEntitlementDetail1 = new Core_Entitlement__c();
            testEntitlementDetail1.Name = 'Employee';
            testEntitlementDetail1.Core_Display_Name__c = 'Employee';
            testEntitlementDetail1.Entitlement_B2B_B2C_Indicator__c = 'B2B'; 
            testEntitlementDetail1.Core_AGS_Role_Id__c = testAGSRole1.Id;
            testEntitlementDetail1.Core_IsActive__c = true;
            insert testEntitlementDetail1;
            
            Core_Contact_Entitlement__c contactEntitlement = new Core_Contact_Entitlement__c(
                Core_Contact_Id__c=testContact.Id,Core_From_Source__c=true, Core_Selected__c=false,Core_Data_Loaded__c= true,
                Core_Entitlement_Id__c=testEntitlementDetail.id,Core_Status__c ='Pending');
            insert contactEntitlement;
            
            Core_Contact_Entitlement__c contactEntitlement1 = new Core_Contact_Entitlement__c(
                Core_Contact_Id__c=testContact1.Id,Core_From_Source__c=true, Core_Selected__c=true,Core_Data_Loaded__c= true,
                Core_Entitlement_Id__c=testEntitlementDetail1.id,Core_Status__c ='Complete');
            insert contactEntitlement1;
            
            Test.startTest();
            
            Core_UserJITHandler handler = new Core_UserJITHandler();
            handler.createUser(null, null, testUser.Id, null, null, null);
            handler.updateUser(testUser.Id, null, null, null, null, null, null);
            handler.updateUser(testUser1.Id, null, null, null, null, null, null);
            handler.updateUser(testUser2.Id, null, null, null, null, null, null);
            Test.stopTest();
            
            User updatedUser = [SELECT Id, IsActive, Partner_License_Reclaimed__c, ContactId FROM User WHERE Id = :testUser.Id LIMIT 1];
            System.assertEquals(true, updatedUser.IsActive);
            System.assertEquals(false, updatedUser.Partner_License_Reclaimed__c);
            
            Core_Contact_Entitlement__c updatedEntitlement = [SELECT Core_Selected__c, Core_Status__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c = :testContact.Id LIMIT 1];
            System.assertEquals(true, updatedEntitlement.Core_Selected__c);
            System.assertEquals('Pending', updatedEntitlement.Core_Status__c);
        }
    }
}