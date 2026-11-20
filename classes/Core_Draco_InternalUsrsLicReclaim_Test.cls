/**************************************************************************************
Apex Class Name : Core_Draco_InternalUsrsLicReclaim_Test 
Created Date: 3rd Oct 2025
Description : Test class for email automation of internal users license reclaim
* Modification Log :
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Sharmila                 03-Oct-2025             	Original Version
*************************************************************************************/
@isTest
private class Core_Draco_InternalUsrsLicReclaim_Test {
    
    @isTest
    static void testDracoInternalUsrsLicReclaim() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Create test Users
            Profile ProfileId = [SELECT Id FROM Profile WHERE Name='Production Support-Display' LIMIT 1];
            
            User testUser1 = new User(
                Alias = 'testusr1',
                Email = 'testpartnerusr@example.com',
                Username = 'testpartnerusr@example.com',
                FirstName = 'Test',
                LastName = 'user1',
                ProfileId = ProfileId.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = true,
                FederationIdentifier='11686330',
                Core_Is_HQ_User__c=false
            );
            insert testUser1;
            
            DateTime lessThan6MonthsAgo = DateTime.now().addMonths(-2).addDays(-10);
            Test.setCreatedDate(testUser1.Id, lessThan6MonthsAgo);
            
            User testUsr = [SELECT Id,LastLoginDate FROM User WHERE Id = :testUser1.Id];
            
            // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String CRON_EXP = '0 6 * * * ?';
            system.debug('CRON_EXP');
            test.startTest();    
            String jobId = System.schedule('SendEmail',  CRON_EXP, new Core_Draco_InternalUsrsLicReclaim());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
        }
    }
}