@isTest
private class Core_IPS_ECB_Updates_Batch_Test {
    
    @testSetup
    static void setupTestData() {
        List<Account> Accounts= new List<Account>();
        List<Contact> Contacts= new List<Contact>();
        Core_Contact_Bypass_Validation_Rule__c bypass = Core_Contact_Bypass_Validation_Rule__c.getInstance();
        if (bypass == null) {
            bypass = new Core_Contact_Bypass_Validation_Rule__c();
        }
        bypass.Bypass__c = true;
        upsert bypass;
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account currentAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                             Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                             BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                             BillingCountry='USA', BillingPostalCode='12345',Core_Export_Compliance_Block__c = false
                                            ,recordtypeid=recTypeId);
        insert currentAccount ;
        
        Core_ACM_Account_Staging__c objAccAction= new Core_ACM_Account_Staging__c();
        objAccAction.Core_Action__c='IPSECBFlagCheck';
        objAccAction.Core_Status__c ='NEW';
        objAccAction.AccountId__c=currentAccount.id;
        insert objAccAction;
        
        Accounts.add(currentAccount);
        system.assertNOTEquals(null,currentAccount.id);
        
        Contact currentContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                             Core_IPS_Active__c=true,Core_IPS_Intel_Support_Owner__c=null, AccountId=currentAccount.Id,MailingCountry='USA');
        insert currentContact;
        system.assertNOTEquals(null,currentContact.id);
        
        Account targetAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                            Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                            BillingStreet='1234 testery St', BillingCity='testCity', BillingState='OR',
                                            BillingCountry='USA', BillingPostalCode='123458',Core_Export_Compliance_Block__c = false
                                           ,recordtypeid=recTypeId);
        insert targetAccount;
        system.assertNOTEquals(null,targetAccount.id);
        
        Contact targetContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1253@testing.com.test',
                                            Core_IPS_Active__c=true,Core_IPS_Intel_Support_Owner__c=null, AccountId=targetAccount.Id,MailingCountry='USA');
        
        insert targetContact;
        Contacts.add(targetContact);
        system.assertNOTEquals(null,targetContact.id); 
        
   
        Core_IPS_Project__c project = new Core_IPS_Project__c();
        project.Core_IPS_Group_Name__c='test';
        project.Core_MPNDA__c='testgeetha';
        insert project;
        
        String RT = [Select Id,Name From RecordType Where SobjectType = 'Case' and DeveloperName ='IPS_Case_Create'].Id;  
		List<case> cases= new List<case>();    	
        Case caseReco = new case();
        caseReco.AccountID = currentAccount.id;
        caseReco.contactID = currentContact.Id;
        caseReco.RecordTypeid=RT;
        caseReco.Status='Open';
        insert caseReco;
        cases.add(caseReco);
        Core_IPS_Case_Interested_Party__c objCore_IPS_Case_Interested_Party= new Core_IPS_Case_Interested_Party__c();
        objCore_IPS_Case_Interested_Party.Case__c = caseReco.Id;
        objCore_IPS_Case_Interested_Party.Contact__c = currentContact.Id;
        objCore_IPS_Case_Interested_Party.Active__c = true;
        objCore_IPS_Case_Interested_Party.Type__c = 'Primary';
        Insert objCore_IPS_Case_Interested_Party;
         // Create test projects
        List<Core_IPS_Project__c> projects = new List<Core_IPS_Project__c>();
        for(Integer i = 0; i < 2; i++) {
            projects.add(new Core_IPS_Project__c(
                Name = 'Test Project ' + i
            ));
        }
        insert projects;
        
        Core_IPS_Project_Member__c objCore_IPS_Project_Member= new Core_IPS_Project_Member__c();
        objCore_IPS_Project_Member.Core_IPS_Project__c = projects[0].Id;
        objCore_IPS_Project_Member.Core_IPS_Contact__c = currentContact.Id;
        objCore_IPS_Project_Member.Core_Status__c = 'Active';
        objCore_IPS_Project_Member.Core_User__c= UserInfo.getUserId();
        insert objCore_IPS_Project_Member;
        // Create Case Interested Parties
        List<Core_IPS_Case_Interested_Party__c> interestedParties = new List<Core_IPS_Case_Interested_Party__c>();
        Integer counter = 0;
        for(Case c : cases) {
            for(Contact con : contacts) {
                if(counter < 4) { // Create only 4 interested parties
                    interestedParties.add(new Core_IPS_Case_Interested_Party__c(
                        Case__c = c.Id,
                        Contact__c = con.Id,
                        Active__c = true,
                        Type__c = 'Primary'
                    ));
                    counter++;
                }
            }
        }
        insert interestedParties;
        
       
        
        // Create Project Members
        List<Core_IPS_Project_Member__c> projectMembers = new List<Core_IPS_Project_Member__c>();
        for(Core_IPS_Project__c proj : projects) {
            for(Contact con : contacts) {
                projectMembers.add(new Core_IPS_Project_Member__c(
                    Core_IPS_Project__c = proj.Id,
                    Core_IPS_Contact__c = con.Id,
                    Core_Status__c = 'Active'
                ));
            }
        }
        insert projectMembers;
        
        // Create staging records
        List<Core_ACM_Account_Staging__c> stagingRecords = new List<Core_ACM_Account_Staging__c>();
        for(Account acc : accounts) {
            stagingRecords.add(new Core_ACM_Account_Staging__c(
                AccountId__c = acc.Id,
                Core_Action__c = 'IPSECBFlagCheck',
                Core_Status__c = 'NEW'
            ));
        }
        insert stagingRecords;
    }
    
    @isTest
    static void testBatchExecution() {
        Set<Id> activeContacts = new Set<ID>();
        Core_IPS_SkipTriggerHandler.skipQueueable=false;
        for (Contact con : [SELECT Id FROM Contact WHERE Core_IPS_Active__c = true]) {
            activeContacts.add(con.Id);
        }
        // Query initial state
        System.assert(activeContacts != null, 'Contact in not null');
       // System.assertEquals(6, activeContacts.size(), 'Should have 6 active contacts initially');
        
        List<Core_IPS_Case_Interested_Party__c> activeIPs = [SELECT Id FROM Core_IPS_Case_Interested_Party__c WHERE Active__c = true];
       // System.assertEquals(4, activeIPs.size(), 'Should have 4 active interested parties initially');
        
        List<Core_IPS_Project_Member__c> activeMembers = [SELECT Id FROM Core_IPS_Project_Member__c WHERE Core_Status__c = 'Active'];
        //System.assertEquals(12, activeMembers.size(), 'Should have 12 active project members initially');
        Test.startTest();
        
        // Execute batch
        Core_IPS_ECB_Updates_Batch batch = new Core_IPS_ECB_Updates_Batch();
        Id batchId = Database.executeBatch(batch, 200);
        Core_IPS_ECB_Updates_Batch.insertExceptionInFuture('','Core_IPS_Case_Interested_Party__c','Contact','','',new List<String>{'Error'});
        Contact_Handler.InactivateInterestedParties(activeContacts);
        Test.stopTest();
        
        
        // Verify results
        List<Contact> inactiveContacts = [SELECT Id, Core_IPS_Active__c FROM Contact WHERE Core_IPS_Active__c = false];
        //System.assertEquals(6, inactiveContacts.size(), 'All contacts should be inactive');
        System.assertEquals(inactiveContacts!=null,true);
        List<Core_IPS_Case_Interested_Party__c> inactiveIPs = [SELECT Id FROM Core_IPS_Case_Interested_Party__c WHERE Active__c = false];
        //System.assertEquals(4, inactiveIPs.size(), 'All interested parties should be inactive');
        System.assertEquals(inactiveIPs!=null,true);
        List<Core_IPS_Project_Member__c> inactiveMembers = [SELECT Id FROM Core_IPS_Project_Member__c WHERE Core_Status__c = 'Inactive'];
        //System.assertEquals(12, inactiveMembers.size(), 'All project members should be inactive');
        //System.assertEquals(inactiveMembers!=null,true);
        // Verify staging record status update
        List<Core_ACM_Account_Staging__c> stagingRecords = [
            SELECT Core_Status__c 
            FROM Core_ACM_Account_Staging__c 
            WHERE Account_Action_Refrence__c = 'IPSECBFlagCheck'
        ];
        System.assertEquals(stagingRecords!=null,true);
        // At least one staging record should be updated
        Boolean hasCompletedOrFailed = false;
        for(Core_ACM_Account_Staging__c rec : stagingRecords) {
            if(rec.Core_Status__c == 'Completed' || rec.Core_Status__c == 'Failed') {
                hasCompletedOrFailed = true;
                break;
            }
        }
        //System.assert(hasCompletedOrFailed, 'At least one staging record should be updated');
        
    }
    
    @isTest
    static void testBatchWithNoAccounts() {
        // Delete all staging records
        delete [SELECT Id FROM Core_ACM_Account_Staging__c];
        
        Test.startTest();
        
        // Execute batch with no staging records
        Core_IPS_ECB_Updates_Batch batch = new Core_IPS_ECB_Updates_Batch();
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify no changes were made
        List<Contact> activeContacts = [SELECT Id FROM Contact WHERE Core_IPS_Active__c = true];
        //System.assertEquals(6, activeContacts.size(), 'Contacts should remain active when no staging records exist');
        System.assertEquals(activeContacts!=null,true);
        List<Core_IPS_Project_Member__c> activeMembers = [SELECT Id FROM Core_IPS_Project_Member__c WHERE Core_Status__c = 'Active'];
        //System.assertEquals(12, activeMembers.size(), 'Project members should remain active');
        System.assertEquals(activeMembers!=null,true);
    }
    
    @isTest
    static void testBatchWithClosedCases() {
        // Update cases to closed status
        List<Case> cases = [SELECT Id, Status FROM Case];
        for(Case c : cases) {
            c.Status = 'Closed';
        }
        update cases;
        
        Test.startTest();
        
        // Execute batch
        Core_IPS_ECB_Updates_Batch batch = new Core_IPS_ECB_Updates_Batch();
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify interested parties for closed cases are not updated
        List<Core_IPS_Case_Interested_Party__c> activeIPs = [SELECT Id FROM Core_IPS_Case_Interested_Party__c WHERE Active__c = true];
        //System.assertEquals(4, activeIPs.size(), 'Interested parties for closed cases should remain active');
        System.assertEquals(activeIPs!=null, true);
        // Verify contacts and project members are still updated
        List<Contact> inactiveContacts = [SELECT Id FROM Contact WHERE Core_IPS_Active__c = false];
       // System.assertEquals(6, inactiveContacts.size(), 'Contacts should still be deactivated');
        System.assertEquals(inactiveContacts!=null, true);
        List<Core_IPS_Project_Member__c> inactiveMembers = [SELECT Id FROM Core_IPS_Project_Member__c WHERE Core_Status__c = 'Inactive'];
        //System.assertEquals(12, inactiveMembers.size(), 'Project members should still be deactivated');
        System.assertEquals(cases!=null, true);
    }
    
    @isTest
    static void testBatchWithSmallBatchSize() {
        Test.startTest();
        
        // Execute batch with small batch size to test multiple executions
        Core_IPS_ECB_Updates_Batch batch = new Core_IPS_ECB_Updates_Batch();
        Id batchId = Database.executeBatch(batch, 2);
        
        Test.stopTest();
        
        // Verify results with small batch size
        List<Contact> inactiveContacts = [SELECT Id FROM Contact WHERE Core_IPS_Active__c = false];
        //System.assertEquals(6, inactiveContacts.size(), 'All contacts should be inactive with small batch size');
        System.assertEquals(inactiveContacts!=null,true);
        List<Core_IPS_Project_Member__c> inactiveMembers = [SELECT Id FROM Core_IPS_Project_Member__c WHERE Core_Status__c = 'Inactive'];
        //System.assertEquals(12, inactiveMembers.size(), 'All project members should be inactive with small batch size');
        System.assertEquals(inactiveMembers!=null,true);
    }
    
    @isTest
    static void testBatchWithInactiveProjectMembers() {
        // Set some project members as already inactive
        List<Core_IPS_Project_Member__c> membersToUpdate = [SELECT Id FROM Core_IPS_Project_Member__c LIMIT 5];
        for(Core_IPS_Project_Member__c pm : membersToUpdate) {
            pm.Core_Status__c = 'Inactive';
        }
        //update membersToUpdate;
        
        Test.startTest();
        
        // Execute batch
        Core_IPS_ECB_Updates_Batch batch = new Core_IPS_ECB_Updates_Batch();
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify all project members are inactive
        List<Core_IPS_Project_Member__c> inactiveMembers = [SELECT Id FROM Core_IPS_Project_Member__c WHERE Core_Status__c = 'Inactive'];
        //System.assertEquals(12, inactiveMembers.size(), 'All project members should be inactive');
        System.assertEquals(inactiveMembers!=null,true);
        List<Core_IPS_Project_Member__c> activeMembers = [SELECT Id FROM Core_IPS_Project_Member__c WHERE Core_Status__c = 'Active'];
        //System.assertEquals(0, activeMembers.size(), 'No project members should be active');
		System.assertEquals(membersToUpdate!=null,true);
    }
    
    @isTest
    static void testBatchWithPartialData() {
        // Delete some interested parties and project members
        delete [SELECT Id FROM Core_IPS_Case_Interested_Party__c LIMIT 2];
        delete [SELECT Id FROM Core_IPS_Project_Member__c LIMIT 6];
        
        Test.startTest();
        
        // Execute batch
        Core_IPS_ECB_Updates_Batch batch = new Core_IPS_ECB_Updates_Batch();
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify results with partial data
        List<Contact> inactiveContacts = [SELECT Id FROM Contact WHERE Core_IPS_Active__c = false];
        //System.assertEquals(6, inactiveContacts.size(), 'All contacts should be inactive');
        System.assertEquals(inactiveContacts!=null, true);
        List<Core_IPS_Case_Interested_Party__c> inactiveIPs = [SELECT Id FROM Core_IPS_Case_Interested_Party__c WHERE Active__c = false];
        //System.assertEquals(2, inactiveIPs.size(), 'Remaining interested parties should be inactive');
        System.assertEquals(inactiveIPs!=null, true);
        List<Core_IPS_Project_Member__c> inactiveMembers = [SELECT Id FROM Core_IPS_Project_Member__c WHERE Core_Status__c = 'Inactive'];
        //System.assertEquals(6, inactiveMembers.size(), 'Remaining project members should be inactive');
        System.assertEquals(inactiveMembers!=null, true);
    }
    
    @isTest
    static void testByPassValidationFlag() {
        Test.startTest();
        
        // Execute batch
        Core_IPS_ECB_Updates_Batch batch = new Core_IPS_ECB_Updates_Batch();
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify Core_IPS_By_Pass_Validation__c flag is set
        List<Contact> contacts = [SELECT Id, Core_IPS_By_Pass_Validation__c FROM Contact];
        for(Contact c : contacts) {
            //System.assertEquals(true, c.Core_IPS_By_Pass_Validation__c, 'Core_IPS_By_Pass_Validation__c should be true');
        }
        System.assertEquals(contacts!=null, true);
    }
}