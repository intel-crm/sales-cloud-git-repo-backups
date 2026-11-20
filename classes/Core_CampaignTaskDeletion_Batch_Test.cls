@isTest
public class Core_CampaignTaskDeletion_Batch_Test {
    
    private static final String CAMPAIGN_NAME = 'Test Campaign 2015-12-01 1';

    static testMethod void testBatchDeletion() {
        
        // First create a campaign and generate some tasks
        Campaign camp = new Campaign(Name=CAMPAIGN_NAME, IsActive=true, RecordTypeId=[select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id,
                                     Description='Testing', Status='In Progress', Core_Approval_Status__c='Approved',
                                     Core_Campaign_Priority__c=null, StartDate=Date.today(), EndDate=Date.today(),
                                     Core_Activity_Types__c='Activity1',
                                     Core_Tasks_Generated__c=false);
        insert camp;
        
        List<Account> accounts = new List<Account>();
        for (Integer i=0; i<5; i++)
            accounts.add(new Account(Name='Test Account '+i, BillingStreet='123 Fake St', BillingCity='Portland', BillingState='OR', BillingCountry='USA'));
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0; i<5; i++)
            contacts.add(new Contact(FirstName='Test', LastName='Contact '+i, Email='testcontact'+i+'@testing.com', AccountId=accounts[Math.mod(i,5)].Id));
        insert contacts;
        
        List<CampaignMember> campMembers = new List<CampaignMember>();
        for (Integer i=0; i<5; i++)
            campMembers.add(new CampaignMember(CampaignId=camp.Id, ContactId=contacts[i].Id));
        insert campMembers;
        
        List<Id> campMemberIds = new List<Id>();
        for (CampaignMember cm : campMembers)
            campMemberIds.add(cm.Id);
        Core_CampaignTaskGeneration_Controller.generateTasksForSpecificMembers(campMemberIds);
        
        // Check to make sure we got some tasks
        Integer numTasks = [select count() from Task where WhatId = :camp.Id];
        System.assertEquals(5, numTasks);
        
        List<Id> campIds = new List<Id>();
        campIds.add(camp.Id);
        
        // Now test the deletion
        Test.startTest();
        Core_CampaignTaskDeletion_Batch.deleteTasksForCampaign(campIds);
        Test.stopTest();
        
        // Check to make sure we have no tasks
        numTasks = [select count() from Task where WhatId = :camp.Id];
        System.assertEquals(0, numTasks);
    }
}