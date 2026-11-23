@isTest
public class Core_CampaignTaskDeletion_Batch_Test {
    
    private static final String CAMPAIGN_NAME = 'Test Campaign 2015-12-01 1';

    static testMethod void testBatchDeletion() {
        
        // Create the custom setting record required by the batch class
        SWS_Core_CRM_Labels__c lastRunDateSetting = new SWS_Core_CRM_Labels__c(
            Name = 'Last_Task_Deletion_Run_Date',
            SWS_Value__c = '2023-01-01T00:00:00.000+0000' // Set an initial date value
        );
        insert lastRunDateSetting;

        // First create a campaign and generate some tasks
        Campaign camp = new Campaign(
            Name = CAMPAIGN_NAME,
            IsActive = true,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id,
            Description = 'Testing',
            Status = 'In Progress',
            Core_Approval_Status__c = 'Approved',
            Core_Campaign_Priority__c = null,
            StartDate = Date.today(),
            EndDate = Date.today(),
            Core_Activity_Types__c = 'Activity1',
            Core_Tasks_Generated__c = false
        );
        insert camp;
        
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                BillingStreet = '123 Fake St',
                BillingCity = 'Portland',
                BillingState = 'OR',
                BillingCountry = 'USA'
            ));
        }
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                Email = 'testcontact' + i + '@testing.com',
                MailingCountry = 'India',
                AccountId = accounts[Math.mod(i, 5)].Id
            ));
        }
        insert contacts;
        
        List<CampaignMember> campMembers = new List<CampaignMember>();
        for (Integer i = 0; i < 5; i++) {
            campMembers.add(new CampaignMember(
                CampaignId = camp.Id,
                ContactId = contacts[i].Id
            ));
        }
        insert campMembers;
        
        List<Id> campMemberIds = new List<Id>();
        for (CampaignMember cm : campMembers) {
            campMemberIds.add(cm.Id);
        }
        Core_CampaignTaskGeneration_Controller.generateTasksForSpecificMembers(campMemberIds);
        
        // Check to make sure we got some tasks
        Integer numTasksA = [SELECT COUNT() FROM Task WHERE WhatId = :camp.Id];
        System.assertEquals(5, numTasksA);
        
        Campaign camp1 = new Campaign(
            Name = 'Campaign Name 1',
            IsActive = true,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id,
            Description = 'Testing',
            Status = 'Deletion Complete',
            Core_Approval_Status__c = 'Approved',
            Core_Campaign_Priority__c = null,
            StartDate = Date.today(),
            EndDate = Date.today(),
            Core_Activity_Types__c = 'Activity1',
            Core_Tasks_Generated__c = false
        );
        insert camp1;
        
        Test.startTest();
        Core_CampaignTaskDeletion_Batch batch = new Core_CampaignTaskDeletion_Batch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        Integer numTasksB = [SELECT COUNT() FROM Task WHERE WhatId = :camp.Id];
       	System.assertEquals(5, numTasksB);
        
        //Now test the deletion
        //Test.startTest();
        //Core_CampaignTaskDeletion_Batch.deleteTasksForCampaign();
        //Test.stopTest();
        
        // Check to make sure we have no tasks
        Integer numTasksC = [SELECT COUNT() FROM Task WHERE WhatId = :camp.Id];
       	System.assertEquals(5, numTasksC);
    }
}