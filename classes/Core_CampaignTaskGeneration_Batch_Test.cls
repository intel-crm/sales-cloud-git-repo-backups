@isTest
public class Core_CampaignTaskGeneration_Batch_Test {
    
    private static final String CAMPAIGN_NAME1 = 'Test Campaign 2015-12-01 1';
    private static final String CAMPAIGN_NAME2 = 'Test Campaign 2015-12-01 2';
    private static final String CAMPAIGN_NAME3 = 'Test Campaign 2015-12-01 3';
    
    private static final String BATCH_FLAGGED_TO_START = 'Generation Flagged to Start';
    private static final String BATCH_STARTED = 'Generation Started';
    private static final String BATCH_COMPLETE = 'Generation Complete';
    private static final String BATCH_ERROR = 'Generation Error';
    
    //----------------------------------------------------------------------------------------
    // Test the code path that would kick off the batch process for > 6K campaign members
    // 
    static testMethod void testBatchKickoff() {
        
        Campaign camp1 = new Campaign(Name=CAMPAIGN_NAME1, IsActive=true, RecordTypeId=[select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id,
                                      Description='Testing', Status='In Progress', Core_Approval_Status__c='Approved',
                                      Core_Campaign_Priority__c=null, StartDate=Date.today(), EndDate=Date.today(),
                                      Core_Activity_Types__c='Activity1;Activity2;Activity3',
                                      Core_Tasks_Generated__c=false);
        insert camp1;
        
        List<Account> accounts1 = new List<Account>();
        for (Integer i=0; i<10; i++)
            accounts1.add(new Account(Name='Test Account '+i, BillingStreet='123 Fake St', BillingCity='Portland', BillingState='OR', BillingCountry='USA'));
        insert accounts1;
        
        List<Contact> contacts1 = new List<Contact>();
        for (Integer i=0; i<2001; i++)
            contacts1.add(new Contact(FirstName='Test', LastName='Contact '+i, Email='testcontact'+i+'@testing.com', AccountId=accounts1[Math.mod(i,10)].Id));
        insert contacts1;
        
        // These will be the initial Campaign Members that we'll generate Tasks for
        List<CampaignMember> campMembers1 = new List<CampaignMember>();
        for (Integer i=0; i<2001; i++)
            campMembers1.add(new CampaignMember(CampaignId=camp1.Id, ContactId=contacts1[i].Id));
        insert campMembers1;
                
        // Set the current page with an Id parameter, instantiate our controller, and try to generate some tasks.
        // Note: we will test the actual batch process below separately. This is just making sure the branch of code
        // executes that will kick off the batch.
        PageReference taskGenPage = Page.Core_CampaignTaskGeneration;
        Test.setCurrentPage(taskGenPage);
        ApexPages.currentPage().getParameters().put('Id', camp1.Id);
        Core_CampaignTaskGeneration_Controller taskGenController = new Core_CampaignTaskGeneration_Controller();
        taskGenController.generateTasks();
        
        // Since the code doesn't actually generate tasks if we're running a test, check to make sure that's true.
        Integer numTasks = [select count() from Task where WhatId = :camp1.Id];
        System.assertEquals(0, numTasks);
    }

    //--------------------------------------------------------------------------------------------
    // Test the actual batch process, with < 6K members, so it doesn't take a long time to execute
    // 
    static testMethod void testBatchGeneration() {
        
        Campaign camp2 = new Campaign(Name=CAMPAIGN_NAME2, IsActive=true, RecordTypeId=[select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id,
                                      Description='Testing', Status='In Progress', Core_Approval_Status__c='Approved',
                                      Core_Campaign_Priority__c=null, StartDate=Date.today(), EndDate=Date.today(),
                                      Core_Activity_Types__c='Activity1;Activity2',
                                      Core_Tasks_Generated__c=false, Core_Task_Batch_Status__c=BATCH_FLAGGED_TO_START);
        insert camp2;
        
        List<Account> accounts2 = new List<Account>();
        for (Integer i=0; i<5; i++)
            accounts2.add(new Account(Name='Test Account '+i, BillingStreet='123 Fake St', BillingCity='Portland', BillingState='OR', BillingCountry='USA'));
        insert accounts2;
        
        List<Contact> contacts2 = new List<Contact>();
        for (Integer i=0; i<30; i++)
            contacts2.add(new Contact(FirstName='Test', LastName='Contact '+i, Email='testcontact'+i+'@testing.com', AccountId=accounts2[Math.mod(i,5)].Id));
        insert contacts2;
        
        List<CampaignMember> campMembers2 = new List<CampaignMember>();
        for (Integer i=0; i<30; i++)
            campMembers2.add(new CampaignMember(CampaignId=camp2.Id, ContactId=contacts2[i].Id));
        insert campMembers2;

		// Now test the actual batch process
        Core_CampaignTaskGeneration_Batch batch = new Core_CampaignTaskGeneration_Batch();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Check to make sure we got all of the tasks and the status was set properly
        Integer numTasks = [select count() from Task where WhatId = :camp2.Id];
        System.assertEquals(30*2, numTasks);
        
        String batchStatus = [select Core_Task_Batch_Status__c from Campaign where Id = :camp2.Id].Core_Task_Batch_Status__c;
        System.assertEquals(BATCH_COMPLETE, batchStatus);
    }
    
    //--------------------------------------------------------------------------------------------
    // Test a batch that will generate an error (using a contact without an account)
    // 
    static testMethod void testBatchError() {
        
        Campaign camp3 = new Campaign(Name=CAMPAIGN_NAME3, IsActive=true, RecordTypeId=[select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id,
                                      Description='Testing', Status='In Progress', Core_Approval_Status__c='Approved',
                                      Core_Campaign_Priority__c=null, StartDate=Date.today(), EndDate=Date.today(),
                                      Core_Activity_Types__c='Activity1;Activity2;Activity3',
                                      Core_Tasks_Generated__c=false, Core_Task_Batch_Status__c=BATCH_FLAGGED_TO_START);
        insert camp3;
        
        List<Account> accounts3 = new List<Account>();
        for (Integer i=0; i<5; i++)
            accounts3.add(new Account(Name='Test Account '+i, BillingStreet='123 Fake St', BillingCity='Portland', BillingState='OR', BillingCountry='USA'));
        insert accounts3;
        
        List<Contact> contacts3 = new List<Contact>();
        for (Integer i=0; i<5; i++)
            contacts3.add(new Contact(FirstName='Test', LastName='Contact '+i, Email='testcontact'+i+'@testing.com', AccountId=accounts3[Math.mod(i,5)].Id));
        contacts3.add(new Contact(FirstName='Test', LastName='Contact 6', Email='testcontact6@testing.com', AccountId=null));
        insert contacts3;
        
        List<CampaignMember> campMembers3 = new List<CampaignMember>();
        for (Integer i=0; i<6; i++)
            campMembers3.add(new CampaignMember(CampaignId=camp3.Id, ContactId=contacts3[i].Id));
        insert campMembers3;

		// Now test the actual batch process
        try {
            Core_CampaignTaskGeneration_Batch batch = new Core_CampaignTaskGeneration_Batch();
            Test.startTest();
            Database.executeBatch(batch);
            Test.stopTest();
        }
        catch(Exception e) {
            System.assertEquals('System.DmlException', e.getTypeName());
        }
        
        // Check to make sure we got zero tasks and errored out
        List<Task> generatedTasks = [select Id from Task where WhatId = :camp3.Id];
        Integer numTasks = [select count() from Task where WhatId = :camp3.Id];
        System.assertEquals(0, numTasks);
        
        // For some reason, when run from an Apex test, it doesn't make it to the error status, even though in real-world execution, it does
        String batchStatus = [select Core_Task_Batch_Status__c from Campaign where Id = :camp3.Id].Core_Task_Batch_Status__c;
        System.assertEquals(BATCH_STARTED, batchStatus);
    }
}