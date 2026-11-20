@isTest
public class Core_ContactEngagementHandler_Test {
    
    public static testMethod void createExternalId_Test() {
        // Add a test account
        Account account = new Account();
        account.name = 'Contact Engagement Text Account';
        account.BillingCity = 'Forest Grove';
        account.BillingStreet = '1122 StoneHenge Dr.';
        account.BillingCountry = 'USA';
        account.BillingCountryCode = 'USA';
        account.BillingPostalCode = '97116';
        account.BillingStateCode = 'OR';
        insert account;
        String accountId = account.Id;
        
        // Add a test contact
        Contact contact = new Contact();
        contact.FirstName = 'Freddo';
        contact.LastName = 'Corleone';
        contact.Email = 'freddo@testerz.com';
        contact.AccountId = accountId;
        insert contact;
        String contactId = contact.Id;
        
        // Create a test Engagement
        Core_Engagement__c engagement = new Core_Engagement__c();
        engagement.Core_Engagement_Code__c = 'CODES_R_US';
        engagement.Name = 'Codes Are Us';
        engagement.Core_Editable__c = true;
        insert engagement;
        String engagementId = engagement.Id;
        
        // Add a contact engagement
        Core_Contact_Engagement__c contactEngagement = new Core_Contact_Engagement__c();
        contactEngagement.Core_Engagement__c = engagementId;
        contactEngagement.Core_Contact__c = contactId;
        contactEngagement.Core_Active__c = true;
        insert contactEngagement;
       
        
        // Query for the inserted Contact Engagement and check
        List<Core_Contact_Engagement__c> contactEngagementList = [SELECT Core_ExtId__c,Core_Engagement_Code__c, Core_Engagement_Label__c FROM Core_Contact_Engagement__c WHERE Id = :contactEngagement.Id];
        Core_Contact_Engagement__c contactEngagementNew = contactEngagementList[0]; 
        System.assertEquals(contactId + ';' + engagement.Core_Engagement_Code__c, contactEngagementNew.Core_ExtId__c);
        System.assertEquals(engagement.Core_Engagement_Code__c, contactEngagementNew.Core_Engagement_Code__c);
        System.assertEquals(engagement.Name, contactEngagementNew.Core_Engagement_Label__c);
        
         // Impersonate Integration User
        Profile profile = [SELECT Id from Profile WHERE Name = 'Integration'];
        User user = new User(Alias = 'newUser', Email = 'user3487324753245@example.com', LastName = 'bob', FirstName = 'bob', 
                            ProfileId = profile.Id, EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='user3487324753245@example.com');
        
        System.runAs(user) {
            
            // Create a test Engagement
            Core_Engagement__c engagement1 = new Core_Engagement__c();
            engagement1.Core_Engagement_Code__c = 'CODES_FOOD';
            engagement1.Name = 'Will Code For Food';
            engagement1.Core_Editable__c = true;
            insert engagement1;
            String engagementId1 = engagement1.Id;
            
            // Add a contact engagement
            Core_Contact_Engagement__c contactEngagement1 = new Core_Contact_Engagement__c();
            contactEngagement1.Core_Engagement__c = engagementId1;
            contactEngagement1.Core_Contact__c = contactId;
            contactEngagement.Core_Active__c = true;
            try {
                insert contactEngagement1;
            } catch(Exception e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains('already has a user profile for engagement [ CODES_R_US ]') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }

     }

}