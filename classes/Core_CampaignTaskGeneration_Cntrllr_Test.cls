@isTest
public class Core_CampaignTaskGeneration_Cntrllr_Test {
    
    private static final String CAMPAIGN_NAME = 'Test Campaign 2015-10-05 1';
    private static final String CAMPAIGN_NAME2 = 'Test Campaign 2015-10-05 2';
    
    @testSetup
    static void setupTestData() {
        
        Id campRecordTypeId = [select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id;
        
        Campaign testCamp = new Campaign(Name=CAMPAIGN_NAME, IsActive=true, RecordTypeId=campRecordTypeId,
                                         Description='Testing', Status='In Progress', Core_Approval_Status__c='Approved',
                                         Core_Campaign_Priority__c=null, StartDate=Date.today(), EndDate=Date.today(),
                                         Core_Activity_Types__c='Activity1;Activity2;Activity3',
                                         Core_Tasks_Generated__c=false);
        insert testCamp;
        
        List<Account> accounts = new List<Account>();
        for (Integer i=0; i<21; i++)
            accounts.add(new Account(Name='Test Account '+i, BillingStreet='123 Fake St', BillingCity='Portland', BillingState='OR', BillingCountry='USA'));
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0; i<210; i++)
            contacts.add(new Contact(FirstName='Test', LastName='Contact '+i, Email='testcontact'+i+'@testing.com', AccountId=accounts[Math.mod(i,10)].Id));
        insert contacts;
        
        // These will be the initial Campaign Members that we'll generate Tasks for
        List<CampaignMember> campMembers = new List<CampaignMember>();
        for (Integer i=0; i<210; i++)
            campMembers.add(new CampaignMember(CampaignId=testCamp.Id, ContactId=contacts[i].Id));
        insert campMembers;
        
        // These will be Accounts/Contacts that we'll add later, to test that piece
        List<Account> accountsAddedLater = new List<Account>();
        for (Integer i=0; i<10; i++)
            accountsAddedLater.add(new Account(Name='Later Account '+i, BillingStreet='123 Fake St', BillingCity='Portland',
                                               BillingState='OR', BillingCountry='USA'));
        insert accountsAddedLater;
        
        // First 5 Contacts will be for existing Accounts, so they shouldn't have Tasks added. Next 10 should.
        List<Contact> contactsAddedLater = new List<Contact>();
        for (Integer i=0; i<5; i++)
            contactsAddedLater.add(new Contact(FirstName='Later', LastName='Contact '+i, Email='latercontact'+i+'@testing.com',
                                               AccountId=accounts[i].Id));
        for (Integer i=5; i<15; i++)
            contactsAddedLater.add(new Contact(FirstName='Later', LastName='Contact '+i, Email='latercontact'+i+'@testing.com',
                                               AccountId=accountsAddedLater[i-5].Id));
        insert contactsAddedLater;
    }

    // Test normal invocation of our controller via the VF page
    static testMethod void testCampaignTaskGenerationController() {
        
        // Get our test records
        Campaign camp = [select Id from Campaign where Name = :CAMPAIGN_NAME limit 1];
        
        List<Contact> contactsAddedLater = [select Id from Contact where Name like 'Later Contact%'];
        
        Test.startTest();
        
        // Check to make sure we're starting with a blank slate
        Integer numTasks = [select count() from Task where WhatId = :camp.Id];
        System.assertEquals(0, numTasks);
        
        // Set the current page with an Id parameter, instantiate our controller, and generate some tasks
        PageReference taskGenPage = Page.Core_CampaignTaskGeneration;
        Test.setCurrentPage(taskGenPage);
        ApexPages.currentPage().getParameters().put('Id', camp.Id);
        Core_CampaignTaskGeneration_Controller taskGenController = new Core_CampaignTaskGeneration_Controller();
        taskGenController.generateTasks();
        
        // Check to make sure we got what we should've gotten
        List<Task> generatedTasks = [select Id from Task where WhatId = :camp.Id];
        numTasks = [select count() from Task where WhatId = :camp.Id];
        System.assertEquals(210*3, numTasks);
        
        Test.stopTest();
    }
    
    // Test the invocable method in the class which is fired from Process Builder
    static testMethod void testCampaignTaskGenerationSpecificIds() {
        
        // For the Campaign already in the system, update it to indicate Tasks have already been generated
        Campaign camp = [select Id, Core_Tasks_Generated__c from Campaign where Name = :CAMPAIGN_NAME limit 1];
        camp.Core_Tasks_Generated__c = true;
        update camp;
        
        List<Contact> contactsAddedFirst = [select Id, AccountId, Account.Name from Contact where Name like 'Test Contact%'];
        List<Contact> contactsAddedLater = [select Id, AccountId, Account.Name from Contact where Name like 'Later Contact%'];
        
        List<Task> existingTasks = new List<Task>();
        for (Integer i=0; i<5; i++) {
            Contact cont = contactsAddedFirst[i];
            existingTasks.add(new Task(Subject='Test', Description='Test', WhatId=camp.Id, WhoId=cont.Id,
                                       Core_Account_ID__c=cont.AccountId, Core_Account_Name__c=cont.Account.Name,
                                       Status=Label.Core_Campaign_Task_Not_Started));
        }
        insert existingTasks;
        
        Test.startTest();
        
        // Check to make sure we're starting with the amount we think we are
        Integer numTasks = [select count() from Task where WhatId = :camp.Id];
        System.assertEquals(5, numTasks);
        
        // Add a few more Campaign Members and make sure our Tasks increase accordingly
        List<CampaignMember> campMembers = new List<CampaignMember>();
        for (Integer i=0; i<15; i++) {
            campMembers.add(new CampaignMember(CampaignId=camp.Id, ContactId=contactsAddedLater[i].Id));
        }
        insert campMembers;
        
        // There should now be 10*3 more Tasks, since we added 15 Contacts (times 3 Activity Types), but 5 were from the same Accounts
        numTasks = [select count() from Task where WhatId = :camp.Id];
        System.assertEquals(5 + 10*3, numTasks);
        
        Test.stopTest();
    }
    
    // Test some other corner cases that weren't included in the above execution paths
    static testMethod void testCampaignTaskGenerationOtherCases() {
        
        Core_Call_Script__c callScript = new Core_Call_Script__c(Name='Test Call Script',
                                                                 Core_API_Name__c='Core_Test_Call_Script');
        insert callScript;
        
        Id campRecordTypeId = [select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id;
        
        Campaign testCamp = new Campaign(Name=CAMPAIGN_NAME2, IsActive=true, RecordTypeId=campRecordTypeId,
                                         Description='Testing', Status='Planned', Core_Approval_Status__c='Approved',
                                         Core_Campaign_Priority__c=null, StartDate=Date.today(), EndDate=Date.today(),
                                         Core_Activity_Types__c='Activity1;Activity2;Activity3',
                                         Core_Tasks_Generated__c=true, Core_Call_Script__c=callScript.Id);
        insert testCamp;
        
        Id vendorSalesCenterUserId = Label.Core_Vendor_Sales_Center_ID;
        
        Account testAccount = new Account(Name='Test Account XYZ', BillingStreet='123 Fake St', BillingCity='Portland',
                                          BillingState='OR', BillingCountry='USA', OwnerId=vendorSalesCenterUserId);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Email='testcontactxyz@testing.com',
                                          AccountId=testAccount.Id);
        insert testContact;
        
        CampaignMember testCampMember = new CampaignMember(CampaignId=testCamp.Id, ContactId=testContact.Id);
        insert testCampMember;
        
        Test.startTest();
        
        // Check to make sure we're starting with a blank slate
        Integer numTasks = [select count() from Task where WhatId = :testCamp.Id];
        System.assertEquals(0, numTasks);
        
        // Set the current page with an Id parameter, instantiate our controller, and attempt to generate some tasks
        PageReference taskGenPage = Page.Core_CampaignTaskGeneration;
        Test.setCurrentPage(taskGenPage);
        ApexPages.currentPage().getParameters().put('Id', testCamp.Id);
        Core_CampaignTaskGeneration_Controller taskGenController = new Core_CampaignTaskGeneration_Controller();
        taskGenController.generateTasks();
        
        // Check to make sure we didn't generate any tasks
        numTasks = [select count() from Task where WhatId = :testCamp.Id];
        System.assertEquals(0, numTasks);
        
        // Set the status correctly
        testCamp = [select Id, Status, Core_Tasks_Generated__c from Campaign where Id = :testCamp.Id];
        testCamp.Status = 'In Progress';
        testCamp.Core_Tasks_Generated__c = true;
        update testCamp;
        taskGenController.generateTasks();
        
        // Check to make sure we still didn't generate any tasks
        numTasks = [select count() from Task where WhatId = :testCamp.Id];
        System.assertEquals(0, numTasks);
        
        // Set the "tasks generated" flag correctly
        testCamp = [select Id, Status, Core_Tasks_Generated__c from Campaign where Id = :testCamp.Id];
        testCamp.Status = 'In Progress';
        testCamp.Core_Tasks_Generated__c = false;
        update testCamp;
        taskGenController.generateTasks();
        
        // Check to see if we generated tasks this time
        numTasks = [select count() from Task where WhatId = :testCamp.Id];
        System.assertEquals(3, numTasks);
        
        // Check to make sure they were assigned to the campaign owner, since account owner is the generic VSC account
        Id taskAssignee = [select OwnerId from Task where WhatId = :testCamp.Id limit 1][0].OwnerId;
        System.assertEquals(UserInfo.getUserId(), taskAssignee);
        
        Test.stopTest();
    }
    
    // Generate tasks with a campaign member with "Assigned To User ID" set, to hit that code path
    static testMethod void testAlternateOwner() {
        
        Campaign camp2 = new Campaign(Name=CAMPAIGN_NAME2, IsActive=true, RecordTypeId=[select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id,
                                      Description='Testing', Status='In Progress', Core_Approval_Status__c='Approved',
                                      Core_Campaign_Priority__c=null, StartDate=Date.today(), EndDate=Date.today(),
                                      Core_Activity_Types__c='Activity1;Activity2;Activity3', Core_Tasks_Generated__c=false);
        insert camp2;
        
        Account account2 = new Account(Name='Test Account XYZ 2', BillingStreet='123 Fake St', BillingCity='Portland',
                                       BillingState='OR', BillingCountry='USA');
        insert account2;
        Contact contact2 = new Contact(FirstName='Test', LastName='Contact', Email='testcontactxyz2@testing.com',
                                       AccountId=account2.Id);
        insert contact2;
        
        CampaignMember campMember2 = new CampaignMember(CampaignId=camp2.Id, ContactId=contact2.Id,
                                                        Core_Assigned_To_User_ID__c=UserInfo.getUserId());
        insert campMember2;
                
        System.debug('#####1 '+ [select OwnerId, WhoId from Task where WhatId = :camp2.Id]);
        
        // Set the current page with an Id parameter, instantiate our controller, and try to generate some tasks.
        PageReference taskGenPage = Page.Core_CampaignTaskGeneration;
        Test.setCurrentPage(taskGenPage);
        ApexPages.currentPage().getParameters().put('Id', camp2.Id);
        Core_CampaignTaskGeneration_Controller taskGenController = new Core_CampaignTaskGeneration_Controller();
        taskGenController.generateTasks();
        
        System.debug('#####2 '+ [select OwnerId, WhoId from Task where WhatId = :camp2.Id]);
        System.debug('#####2 testContact2.Id: '+ contact2.Id);
        System.debug('#####2 UserInfo.getUserId(): '+ UserInfo.getUserId());
        
        Id taskAssignee2 = [select OwnerId from Task where WhatId = :camp2.Id and WhoId = :contact2.Id limit 1][0].OwnerId;
        System.assertEquals(UserInfo.getUserId(), taskAssignee2);
    }
    
    // Test to make sure we get an error with > 50K tasks
    static testMethod void testTooManyTasks() {
        
        String activityTypes = '';
        for (Integer i=0; i<100; i++)
            activityTypes += 'A' + i + ';';
        activityTypes = activityTypes.left(activityTypes.length()-1);
        Campaign camp2 = new Campaign(Name=CAMPAIGN_NAME2, IsActive=true, RecordTypeId=[select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id,
                                      Description='Testing', Status='In Progress', Core_Approval_Status__c='Approved',
                                      Core_Campaign_Priority__c=null, StartDate=Date.today(), EndDate=Date.today(),
                                      Core_Activity_Types__c=activityTypes, Core_Tasks_Generated__c=false);
        insert camp2;
        
        List<Account> accounts2 = new List<Account>();
        for (Integer i=0; i<10; i++)
            accounts2.add(new Account(Name='Test Account 2 '+i, BillingStreet='123 Fake St', BillingCity='Portland', BillingState='OR', BillingCountry='USA'));
        insert accounts2;
        
        List<Contact> contacts2 = new List<Contact>();
        for (Integer i=0; i<501; i++)
            contacts2.add(new Contact(FirstName='Test', LastName='Contact 2 '+i, Email='testcontact2.'+i+'@testing.com', AccountId=accounts2[Math.mod(i,10)].Id));
        insert contacts2;
        
        // These will be the initial Campaign Members that we'll generate Tasks for
        List<CampaignMember> campMembers2 = new List<CampaignMember>();
        for (Integer i=0; i<501; i++)
            campMembers2.add(new CampaignMember(CampaignId=camp2.Id, ContactId=contacts2[i].Id));
        insert campMembers2;
                
        // Set the current page with an Id parameter, instantiate our controller, and try to generate some tasks.
        PageReference taskGenPage = Page.Core_CampaignTaskGeneration;
        Test.setCurrentPage(taskGenPage);
        ApexPages.currentPage().getParameters().put('Id', camp2.Id);
        Core_CampaignTaskGeneration_Controller taskGenController = new Core_CampaignTaskGeneration_Controller();
        taskGenController.generateTasks();
        
        // Make sure we didn't generate any tasks
        Integer numTasks = [select count() from Task where WhatId = :camp2.Id];
        System.assertEquals(0, numTasks);
    }
}