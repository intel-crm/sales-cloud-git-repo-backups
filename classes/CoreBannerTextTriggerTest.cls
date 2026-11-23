@isTest
private class CoreBannerTextTriggerTest {
    @testSetup
    static void setup() {
        // Create test users
        Profile p = [SELECT Id FROM Profile WHERE Name = 'IT admin' LIMIT 1];
        
        User allowedUser = new User(
            FirstName = 'Allowed',
            LastName = 'User',
            Email = 'alloweduser@example.com',
            Username = 'alloweduser@example.com',
            Alias = 'allusr',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert allowedUser;
        
        User disallowedUser = new User(
            FirstName = 'Disallowed',
            LastName = 'User',
            Email = 'disalloweduser@example.com',
            Username = 'disalloweduser@example.com',
            Alias = 'disusr',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert disallowedUser;
    }

    @isTest
    static void testAllowedUser() {
        User allowedUser = [SELECT Id FROM User WHERE Email = 'richard.mason@intel.com' LIMIT 1];
        System.runAs(allowedUser) {
            Test.startTest();
            Core_Banner_Text__c banner = new Core_Banner_Text__c(Name = 'Test Banner',Core_CRM_Project__c='CRM');
            insert banner;
            banner.Name = 'Updated Banner';
            update banner;
            Test.stopTest();
        }
    }

    @isTest
    static void testDisallowedUser() {
        User disallowedUser = [SELECT Id FROM User WHERE Email = 'disalloweduser@example.com' LIMIT 1];
        System.runAs(disallowedUser) {
            Test.startTest();
            Core_Banner_Text__c banner = new Core_Banner_Text__c(Name = 'Test Banner',Core_CRM_Project__c='CRM');
            
            try {
                insert banner;
                System.assert(false, 'Expected an exception but did not get one');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('You do not have access to create/edit records in this object.'),
                    'Expected access error but got: ' + e.getMessage());
            }
            
            Test.stopTest();
        }
    }
}