/**************************************************************************************
Apex Class Name: Core_Lead_Daily_PartnerNotification_Test
Version : 1.0 
Created Date: 15 AUG 2016
Function: Test class for Core_Lead_Daily_PartnerNotification

Modification Log :
Developer                 Date                    Description
----------------------------------------------------------------------------                 
Venu Karumuru             08/15/2016              Initial Version
*************************************************************************************/

@isTest
private class Core_Lead_Daily_PartnerNotification_Test
{
    // Support method to create necessary test leads
    static void createTestLeads()
    {
        // Create a Lead Queue
        Group group1 = new Group();
        group1.Type = 'Queue';
        group1.Name = 'PTNR - TestPartner1';
        group1.DeveloperName = 'Core_PTNR_TestPartner1';
        insert group1;
            
        Queuesobject queue1 = new Queuesobject();
        queue1.SobjectType = 'Lead';
        queue1.QueueId = group1.id;
        insert queue1;
        
        // Test Profile Name
        String sProfileName1 = 'Standard User';
        // User used in the test
        String sLastName = 'User1';
        String sAlias = 'tuser1';
        String sEmail = 'test.user1@intel.com';
        String sUserName = 'test.user1@intel.com.crm.testclass';
        
         // Get the Id of the Profile 
        Id profileId1;            
        List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName1 LIMIT 1];
        if (lstProfiles.size() == 0)
            profileId1 = null;
        else
            profileId1 = lstProfiles[0].Id;
        
        // Make sure that the Id of the Profile is not null
        System.assertNotEquals(null, profileId1);
        
        // Create new user
        User testUser = new User(LastName = sLastName, Alias = sAlias, Email = sEmail, UserName = sUserName, ProfileId = profileId1,
            EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
            
        insert testUser;
        
        // Add user to the group/lead queue
        GroupMember groupMember = new GroupMember();
        groupMember.GroupId = group1.Id;
        groupMember.UserOrGroupId = testUser.Id;
        insert groupMember;
                
        // Get the minimum number of leads that a queue needs (to send the daily summary notification)
        Integer nThreshold = Integer.ValueOf(System.Label.Core_Partner_Daily_Summary_Threshold);

        // Create the leads
        List<Lead> lstLeads = new List<Lead>();
        for (Integer i = 0; i < nThreshold; i++)
        {
            // Create new lead
            Lead lead1 = new Lead();
            lead1.RecordTypeId = System.Label.Core_Partner_Lead_Record_Id;
            lead1.FirstName = 'Test1';
            lead1.LastName = 'Test1';
            lead1.email = 'test1@test1.com';
            lead1.Phone = '123 4567';
            lead1.Company = 'Test1';
            lead1.CountryCode = 'USA';
            lead1.LeadSource = 'Partner Program';
            lead1.Core_Partner_Name__c = 'TestPartner1';
            lead1.CreatedDate = Datetime.now().addDays(-1); // Create date should be yesterday, so the batch job can pick the lead for summary count
            lead1.OwnerId = queue1.QueueId;
            lstLeads.add(lead1);
        }

        insert lstLeads;
    }


    // Main test method
    static testMethod void SendSummayMailToPartners_Test() 
    {
        System.runAs(Core_Test_Utility.systemAdminUser)
        {
            String CRON_EXP = '0 0 0 15 3 ? 2022';

            createTestLeads();

            Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new Core_Lead_Daily_PartnerNotification());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        
            Test.stopTest();
        }
    }
}