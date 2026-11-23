/**************************************************************************************
Apex Class Name:  Core_ContactHandler_Test
Version     : 1.0 
Created Date: 11 NOV 2015
Function    : Test Class for the Core_ContactHandler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Venu Karumuru           11/02/2015              Added UpdateJobFunction_Test()
* Venu Karumuru           11/02/2015              Added UpdateJobFunctionCode_Test()
*************************************************************************************/
@isTest
public class Core_ContactHandler_Test {
    
    /*
* Method name  : UpdateJobFunction_Test
* Description  : Method to test UpdateJobFunction functionality
* Return Type  : void
* Parameters   : None
*/
    
    static testMethod void UpdateJobFunction_Test() {
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'contactJobFunction';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa.';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);
            
            // Create sample Job Function References
            Core_Job_Function_Reference__c jobFunctionReference1 = new Core_Job_Function_Reference__c();
            jobFunctionReference1.Name = 'TEST1';
            jobFunctionReference1.Core_Job_Function_Code__c = 'TEST1';
            jobFunctionReference1.Core_Job_Function_Name__c = 'Test Job Function 1';            
            insert jobFunctionReference1;
            System.assertNotEquals(null, jobFunctionReference1.Id);
            
            Core_Job_Function_Reference__c jobFunctionReference2 = new Core_Job_Function_Reference__c();
            jobFunctionReference2.Name = 'TEST2';
            jobFunctionReference2.Core_Job_Function_Code__c = 'TEST2';
            jobFunctionReference2.Core_Job_Function_Name__c = 'Test Job Function 2';            
            insert jobFunctionReference2;
            System.assertNotEquals(null, jobFunctionReference2.Id);
            
            // Create a new Contact with Job Function Code
            List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            Contact contact = lstContacts[0];
            contact.AccountId = account.id;
            contact.Core_Job_Function_Code__c = 'TEST1';
            contact.MailingCountry = 'India';
            insert contact;
            System.assertNotEquals(null, contact.Id);
            
            // Make sure that the Job Function is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
            //System.assertEquals('TEST1', contact.Core_Job_Function_Code__c);
           // System.assertEquals('Test Job Function 1', contact.Core_Job_Function__c);
            
            // Update the existing Contact with new Job Function Code
            contact.Core_Job_Function_Code__c = 'TEST2';
            update contact;
            
            // Make sure that the Job Function is updated for the existing Contact
            /*contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
System.assertEquals('TEST2', contact.Core_Job_Function_Code__c);
System.assertEquals('Test Job Function 2', contact.Core_Job_Function__c);*/
        }
    }
    
    
    
    /*
* Method name  : UpdateJobFunctionCode_Test
* Description  : Method to test UpdateJobFunctionCode functionality
* Return Type  : void
* Parameters   : None
*/
    
    static testMethod void UpdateJobFunctionCode_Test() {
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'contactJobFunction';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa.';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);
            
            // Create sample Job Function References
            Core_Job_Function_Reference__c jobFunctionReference1 = new Core_Job_Function_Reference__c();
            jobFunctionReference1.Name = 'TEST1';
            jobFunctionReference1.Core_Job_Function_Code__c = 'TEST1';
            jobFunctionReference1.Core_Job_Function_Name__c = 'Test Job Function 1';            
            insert jobFunctionReference1;
            System.assertNotEquals(null, jobFunctionReference1.Id);
            
            Core_Job_Function_Reference__c jobFunctionReference2 = new Core_Job_Function_Reference__c();
            jobFunctionReference2.Name = 'TEST2';
            jobFunctionReference2.Core_Job_Function_Code__c = 'TEST2';
            jobFunctionReference2.Core_Job_Function_Name__c = 'Test Job Function 2';            
            insert jobFunctionReference2;
            System.assertNotEquals(null, jobFunctionReference2.Id);
            
            // Create a new Contact with Job Function
            List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            Contact contact = lstContacts[0];
            contact.AccountId = account.id;
            contact.Core_Job_Function__c = 'Test Job Function 1';
            contact.MailingCountry = 'India';
            insert contact;
            System.assertNotEquals(null, contact.Id);
            
            // Make sure that the Job Function Code is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
            //System.assertEquals('TEST1', contact.Core_Job_Function_Code__c);
           // System.assertEquals('Test Job Function 1', contact.Core_Job_Function__c);
            
            // Update the existing Contact with new Job Function
            contact.Core_Job_Function__c = 'Test Job Function 2';
            update contact;
            
            // Make sure that the Job Function Code is updated for the existing Contact
            /*contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
System.assertEquals('TEST2', contact.Core_Job_Function_Code__c);
System.assertEquals('Test Job Function 2', contact.Core_Job_Function__c);*/
        }
    }
    
    static testmethod void updateIPSActive(){
        System.debug('kalyani2 core_Contacthandler = ');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'contactJobFunction';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa.';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);
            
            // Create sample Job Function References
            Core_Job_Function_Reference__c jobFunctionReference1 = new Core_Job_Function_Reference__c();
            jobFunctionReference1.Name = 'TEST1';
            jobFunctionReference1.Core_Job_Function_Code__c = 'TEST1';
            jobFunctionReference1.Core_Job_Function_Name__c = 'Test Job Function 1';            
            insert jobFunctionReference1;
            System.assertNotEquals(null, jobFunctionReference1.Id);
            
            Core_Job_Function_Reference__c jobFunctionReference2 = new Core_Job_Function_Reference__c();
            jobFunctionReference2.Name = 'TEST2';
            jobFunctionReference2.Core_Job_Function_Code__c = 'TEST2';
            jobFunctionReference2.Core_Job_Function_Name__c = 'Test Job Function 2';            
            insert jobFunctionReference2;
            System.assertNotEquals(null, jobFunctionReference2.Id);
            
            // Create a new Contact with Job Function
            List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(2);
            Contact contact = lstContacts[1];
            contact.AccountId = account.id;
            contact.Core_Job_Function__c = 'Test Job Function 1';
            contact.Core_IPS_Email_Opt_Out__c = false;
            contact.MailingCountry = 'India';
            insert contact;
            System.assertNotEquals(null, contact.Id);
            
            //Create a Case with Same Contacts 
            Case Cs =  TestUtilities.getCase();
            cs.AccountId = account.id;
            cs.contactid = contact.id;
            insert Cs;
            
            //Create Interested Parties
            
            Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
            party.Contact__c = contact.id;
            party.Case__c = Cs.id;
            insert party;
            
            // Make Contact IPS InActive
            contact.Core_IPS_Active__c = false;
            contact.Core_IPS_Email_Opt_Out__c = true;
            Update contact;  
            
        }
    }    
    
    static testmethod void updateIPSActiveFalse(){
        System.debug('kalyani3 core_Contacthandler = ');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'contactJobFunction';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa.';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);
            
            // Create sample Job Function References
            Core_Job_Function_Reference__c jobFunctionReference1 = new Core_Job_Function_Reference__c();
            jobFunctionReference1.Name = 'TEST1';
            jobFunctionReference1.Core_Job_Function_Code__c = 'TEST1';
            jobFunctionReference1.Core_Job_Function_Name__c = 'Test Job Function 1';            
            insert jobFunctionReference1;
            System.assertNotEquals(null, jobFunctionReference1.Id);
            
            Core_Job_Function_Reference__c jobFunctionReference2 = new Core_Job_Function_Reference__c();
            jobFunctionReference2.Name = 'TEST2';
            jobFunctionReference2.Core_Job_Function_Code__c = 'TEST2';
            jobFunctionReference2.Core_Job_Function_Name__c = 'Test Job Function 2';            
            insert jobFunctionReference2;
            System.assertNotEquals(null, jobFunctionReference2.Id);
            
            // Create a new Contact with Job Function
            List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(2);
            Contact contact = lstContacts[1];
            contact.AccountId = account.id;
            contact.Core_Job_Function__c = 'Test Job Function 1';
            contact.Core_IPS_Email_Opt_Out__c = true;
            contact.MailingCountry = 'India';
            insert contact;
            System.assertNotEquals(null, contact.Id);
            
            //Create a Case with Same Contacts 
            Case Cs =  TestUtilities.getCase();
            cs.AccountId = account.id;
            cs.contactid = contact.id;
            insert Cs;
            
            //Create Interested Parties
            Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
            party.Contact__c = contact.id;
            System.debug('kalyani '+ contact.id);
            party.Case__c = Cs.id;
            insert party;
            
            contact.Core_IPS_Email_Opt_Out__c = false;
            Update contact;  
        }
    }   
    
    
    public static testmethod void activteIP(){
        getRecords();
        Test.starttest();
        List<Contact> updatecontactList =  new List<Contact>();
        System.runAs(SystUserRunAs){
            /*Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
       		triggerExecution.Name = 'myIntelIntegration';
            triggerExecution.Core_Active__c = true;
            triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            triggerExecution.Core_Description__c = 'To update Case fields.';
            triggerExecution.Core_Object__c = 'Case';
            triggerExecution.Core_Trigger_Events__c = 'before insert';
            insert triggerExecution;*/
            Profile prof = [select id from profile where name = 'IPS External Customer' limit 1];
            contactUserList = TestUtilities.getListOfUser(1);
            contactUserList[0].profileId=prof.id;
            contactUserList[0].contactid=contactListOptIn[0].id;
            contactUserList[0].username='teshekx@test.com';
            insert contactUserList;
            Id testUserId = contactUserList[0].id;
            
            //Create a Case with Same Contacts 
            Case Cs =  TestUtilities.getCase();
            cs.contactid = contactListOptIn[0].id;
            insert Cs;
            
            //Create Interested Parties
            Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
            party.Contact__c = contactListOptIn[0].id;
            party.Case__c = Cs.id;
            insert party;
            
            contactListOptIn[0].Core_IPS_Email_Opt_Out__c = true;
            contactListOptIn[0].Core_IPS_Active__c  = false;
            update contactListOptIn[0];
            
            contactListOptIn[0].Core_IPS_Email_Opt_Out__c = false;
            contactListOptIn[0].Core_IPS_Active__c  = true;
            update contactListOptIn[0];
            
            contactListOptIn[0].Core_IPS_Email_Opt_Out__c = true;
            contactListOptIn[0].Core_IPS_Active__c  = true;
            update contactListOptIn[0];
            
        }
        Test.stoptest();
    }
    
    
    
    public static User SystUserRunAs; 
    public static List<Case> caseList = new List<Case>();
    public static List<Core_IPS_Case_Interested_Party__c> interestedPartyListoptIn = new List<Core_IPS_Case_Interested_Party__c>();
    public static List<Core_IPS_Case_Interested_Party__c> interestedPartyListoptOut = new List<Core_IPS_Case_Interested_Party__c>();
    public static List<Account> accountList =  new List<Account>();
    public static List<Contact> contactListOptIn =  new List<Contact>();
    public static List<Contact> contactListOptOut =  new List<Contact>();
    public static List<User> userList = new List<user>();
    
    public static List<Core_IPS_Project__c> projectList =  new List<Core_IPS_Project__c>();
    public static List<Core_IPS_Project_Member__c> projMembersList = new List<Core_IPS_Project_Member__c>();
    public static List<User> contactUserList = new List<User>();
    
    public static testmethod void InactivateProjectMembers(){
        getRecords();
        Test.starttest();
        List<Contact> updatecontactList =  new List<Contact>();
        System.runAs(SystUserRunAs){
            Profile prof = [select id from profile where name = 'IPS External Customer' limit 1];
            contactUserList = TestUtilities.getListOfUser(1);
            contactUserList[0].profileId=prof.id;
            contactUserList[0].contactid=contactListOptIn[0].id;
            contactUserList[0].username='teshekx@test.com';
            insert contactUserList;
            Id testUserId = contactUserList[0].id;
            projectList = TestUtilities.getListOfIpsProjects(2);
            // Create Project Member
            projMembersList = TestUtilities.getListOfProjectMembers(2);
            for(Core_IPS_Project_Member__c ProjMem : projMembersList){
                ProjMem.Core_IPS_Contact__c = contactListOptIn.get(0).Id;
                ProjMem.Core_IPS_Project__c = projectList.get(0).Id;
                ProjMem.Core_Status__c = 'Active';
                ProjMem.Core_User__c = testUserId;            
            }
            for(Contact contactRecord: contactListOptIn){
                contactRecord.Core_IPS_Active__c  = false;
                updatecontactList.add(contactRecord);
            }
            update updatecontactList;
        }
        Test.stoptest();
    }
    
    
    public static void getRecords(){
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];    
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
        System.runAs(systUserRunAs){
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'test';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'test';
            executeTrigger.Core_Class_Name__c = 'Contact_Handler';
            insert executeTrigger;
            
            
            
            accountList = TestUtilities.getListOfAccounts(2);
            insert AccountList;
            
            contactListOptIn = TestUtilities.getListOfContact(2);
            contactListOptOut = TestUtilities.getListOfContact(2);
            Integer i = 0;
            for(Contact contactRecord: contactListOptIn){
                contactRecord.accountid = AccountList.get(0).id;
                contactRecord.Core_IPS_Email_Opt_Out__c = false;
                i++;
            }
            insert contactListOptIn;
            
            for(Contact contactRecord: contactListOptOut){
                contactRecord.accountid = AccountList.get(1).id;
                contactRecord.Core_IPS_Email_Opt_Out__c = true;
                contactRecord.Email = 'Contact1Dell@yahoo.com';
                i++;
            }
            insert contactListOptOut;
            
            caseList = TestUtilities.getListOfCases(2);
            integer  counter = 0 ;
            for(Case CaseRec : caseList){
                CaseRec.ContactId = contactListOptIn.get(counter).id;
                CaseRec.accountId = AccountList.get(counter).Id;
                counter++;
            }
            insert caseList;
            
            
            interestedPartyListoptIn = TestUtilities.getInternalInterestedParties(2);
            interestedPartyListoptOut = TestUtilities.getInternalInterestedParties(2);
            for(Core_IPS_Case_Interested_Party__c ip: interestedPartyListoptIn){
                ip.Case__c = caseList[0].id;
                ip.Contact__c = contactListOptIn.get(0).id;
                i++;
            }
            insert interestedPartyListoptIn;
            
            for(Core_IPS_Case_Interested_Party__c ip: interestedPartyListoptOut){
                ip.Case__c = caseList[0].id;
                ip.Contact__c = contactListOptOut.get(0).id;
                i++;
            }
            insert interestedPartyListoptOut;
        }
    }
    
}