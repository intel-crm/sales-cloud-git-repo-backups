/**************************************************************************************
Apex Class Name : Core_Draco_RoleCleanup_Batch_Test 
Created Date: 22nd Aug 2024
Description : Test class to cleanup account based portal roles 
* Modification Log :
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Sharmila                 22nd-Aug-2024             	Original Version
*************************************************************************************/
@IsTest(SeeAllData=false)
public class Core_Draco_RoleCleanup_Batch_Test {
    @isTest
    static void testPortalRoleCleanup() {
        // Create test Accounts
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
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
        
        Account acc2 = new Account();
        acc2.Name='Big Networks';
        acc2.Core_IPA_Partner_Role__c='Distributor';
        acc2.BillingCity='Texas';
        acc2.BillingStreet='Street 2';
        acc2.BillingCountry='USA';
		acc2.RecordTypeId=intelAccRecTypeId;
        acc2.BillingCountryCode='USA';
        acc2.BillingPostalCode='76890';
        acc2.Core_Account_Tier__c = 'Tier1';
        insert acc2;
        
        Contact testContact = new Contact(FirstName='testFirstName258',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName258', Email='test258@testing.com',
                                          AccountId=acc1.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',MailingCountry='India',
                                          Core_Enterprise_Id__c='245689',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
 
        // Create test Users
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        User user1 = new User(
            Username = 'testUser' + String.valueOf(Math.random()) + '@testing.com',
            LastName = 'TestUser1',
            Email = 'test258@testing.com',
            Alias = 'tuser1',
            ProfileId = partnerProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id
        );
        insert user1;

        Test.startTest();
        Core_Draco_RoleCleanup_Batch batch = new Core_Draco_RoleCleanup_Batch();
        Database.executeBatch(batch,10);
        Test.stopTest();
    }
    
}