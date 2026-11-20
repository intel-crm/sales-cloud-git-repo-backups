@isTest
public class Core_CampaignMemberTask_Test {
    
    private static final String CAMPAIGN_NAME = 'Test Campaign 2015-10-05';
    
    @testSetup
    static void setupTestData() {
        
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='memberDeletionTaskCleanup', Core_Object__c='CampaignMember', Core_Class_Name__c='Core_CampaignMemberHandler',
            Core_Trigger_Events__c='after delete', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
        Id campRecordTypeId = [select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id;
        
        Campaign testCamp = new Campaign(Name=CAMPAIGN_NAME, IsActive=true, RecordTypeId=campRecordTypeId,
                                         Description='Testing', Status='In Progress', Core_Approval_Status__c='Approved',
                                         Core_Campaign_Priority__c=null, StartDate=Date.today(), EndDate=Date.today(),
                                         Core_Activity_Types__c='Activity1;Activity2;Activity3',
                                         Core_Tasks_Generated__c=true);
        insert testCamp;
        
        List<Account> accounts = new List<Account>();
        for (Integer i=0; i<21; i++)
            accounts.add(new Account(Name='Test Account '+i, BillingStreet='123 Fake St', BillingCity='Portland', BillingState='OR', BillingCountry='USA'));
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0; i<210; i++)
            contacts.add(new Contact(FirstName='Test', LastName='Contact '+i, Email='testuser'+i+'@testing.com', AccountId=accounts[Math.mod(i,10)].Id));
        insert contacts;
        
        List<CampaignMember> campMembers = new List<CampaignMember>();
        for (Integer i=0; i<210; i++)
            campMembers.add(new CampaignMember(CampaignId=testCamp.Id, ContactId=contacts[i].Id));
        insert campMembers;
        
        List<Id> campMemberIds = new List<Id>();
        for (CampaignMember campMember : campMembers)
            campMemberIds.add(campMember.Id);
        
        Core_CampaignTaskGeneration_Controller.generateTasksForSpecificMembers(campMemberIds);
    }
    
    // Test to make sure any Campaign Members that get deleted from an In Progress Campaign have their
    // associated Tasks removed, if they're Not Started
    static testMethod void testMemberDeletionTaskCleanup() {
        
        Campaign camp = [select Id from Campaign where Name = :CAMPAIGN_NAME limit 1];
        
        List<CampaignMember> campMembers = [select Id from CampaignMember where CampaignId = :camp.Id];
        
        List<Task> generatedTasks = [select Id from Task where WhatId = :camp.Id];
        generatedTasks[0].Status = 'In Progress';
        generatedTasks[1].Status = 'Completed';
        update generatedTasks;
            
        Test.startTest();
        delete campMembers;
        Test.stopTest();
        
        generatedTasks = [select Id from Task where WhatId = :camp.Id];
        System.assertEquals(2, generatedTasks.size());
    }
}