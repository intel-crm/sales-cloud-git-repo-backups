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
* Pratiksha Mahajan       29/07/2019              Added testUpdateMembershipFlag()
* Agam Sharma             28/12/2019              Added testPopulateErrorCodeField()
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
        Test.startTest();
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            List<Core_Trigger_Executions__c> executeTriggers = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'contactJobFunction';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa.';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);
            
            executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'UpdateJobFunctionAndCode';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = false;
            executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa - This is to fix the SOQL Limit Exception';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);
            
            insert executeTriggers;
            System.assertNotEquals(null, executeTriggers);
            
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
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';

            insert contact;
            System.assertNotEquals(null, contact.Id);
            
            // Make sure that the Job Function is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
            System.debug('Job Function Test :: contact ::: ' + contact);
            System.assertEquals('TEST1', contact.Core_Job_Function_Code__c);
           // System.assertEquals('Test Job Function 1', contact.Core_Job_Function__c);
            
            // Update the existing Contact with new Job Function Code
            contact.Core_Job_Function_Code__c = 'TEST2';
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            update contact;
            
            // Make sure that the Job Function is updated for the existing Contact
            /*contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
System.assertEquals('TEST2', contact.Core_Job_Function_Code__c);
System.assertEquals('Test Job Function 2', contact.Core_Job_Function__c);*/
        }
        Test.stopTest();
    }
    
/*
* Method name  : UCD_ACMPopulateAccountBillingCountry_Test
* Description  : Method to test UCD_ACMPopulateAccountBillingCountry functionality
* Return Type  : void
* Parameters   : None
*/ 
    static testMethod void UCD_ACMPopulateAccountBillingCountry_Test() {
        	Test.startTest();
     		System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            List<Core_Trigger_Executions__c> executeTriggers = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'PopulateAccBillingCountry';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
            executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
            executeTrigger.Core_Description__c = 'Populate Account Billing Country to Contact Mailing Country when the latter is blank';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);
         
         	insert executeTriggers;
            System.assertNotEquals(null, executeTriggers);
                
            List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            Contact contact = lstContacts[0];
            contact.AccountId = account.id;
            contact.Core_Job_Function__c = 'Test Job Function 1';
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            insert contact;
     		}
        Test.stopTest();
    }    
    
    /*
* Method name  : UpdateJobFunctionCode_Test
* Description  : Method to test UpdateJobFunctionCode functionality
* Return Type  : void
* Parameters   : None
*/
    
    static testMethod void UpdateJobFunctionCode_Test() {
        Test.startTest();
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            List<Core_Trigger_Executions__c> executeTriggers = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'contactJobFunction';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa.';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);
            
            executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'UpdateJobFunctionAndCode';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = false;
            executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa - This is to fix the SOQL Limit Exception';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);
            
            insert executeTriggers;
            System.assertNotEquals(null, executeTriggers);
            //System.assertNotEquals(null, executeTrigger.Id);
            
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
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            insert contact;
            System.assertNotEquals(null, contact.Id);
            
            // Make sure that the Job Function Code is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
            System.debug('Job Function Test :: contact ::: ' + contact);
          //  System.assertEquals('TEST1', contact.Core_Job_Function_Code__c);
            System.assertEquals('Test Job Function 1', contact.Core_Job_Function__c);
            
            // Update the existing Contact with new Job Function
            contact.Core_Job_Function__c = 'Test Job Function 2';
            update contact;
            
            // Make sure that the Job Function Code is updated for the existing Contact
            /*contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
System.assertEquals('TEST2', contact.Core_Job_Function_Code__c);
System.assertEquals('Test Job Function 2', contact.Core_Job_Function__c);*/
        }
        Test.stopTest();
    }
    
    static testMethod void UpdateJobFunctionNameAndCode_Test() {
        Test.startTest();
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            List<Core_Trigger_Executions__c> executeTriggers = new List<Core_Trigger_Executions__c>();           
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'UpdateJobFunctionAndCode';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
            executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa - This is to fix the SOQL Limit Exception';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);
            
            insert executeTriggers;
            System.assertNotEquals(null, executeTriggers);
            //System.assertNotEquals(null, executeTrigger.Id);
            
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
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            insert contact;
            System.assertNotEquals(null, contact.Id);
            
            // Make sure that the Job Function Code is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
            system.debug('Job Function : UpdateJobFunctionNameAndCode_Test :::: ' + contact);
            System.assertEquals('TEST1', contact.Core_Job_Function_Code__c);
            System.assertEquals('Test Job Function 1', contact.Core_Job_Function__c);
            
            // Update the existing Contact with new Job Function
            contact.Core_Job_Function__c = 'Test Job Function 2';
            update contact;
            
            // Make sure that the Job Function Code is updated for the existing Contact
            /*contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
System.assertEquals('TEST2', contact.Core_Job_Function_Code__c);
System.assertEquals('Test Job Function 2', contact.Core_Job_Function__c);*/
        }
        Test.stopTest();
    }
    
    static testmethod void updateIPSActive(){
        Test.startTest();
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
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
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
        Test.stopTest();
    }    
    
    static testmethod void updateIPSActiveFalse(){
        Test.startTest();
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
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
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
            
            contact.Core_IPS_Email_Opt_Out__c = false;
            Update contact;  
        }
        Test.stopTest();
    }   
    
    
    public static testmethod void activteIP(){
        getRecords();
        //Test.starttest();
        List<Contact> updatecontactList =  new List<Contact>();
        System.runAs(SystUserRunAs){
            Profile prof = [select id from profile where name = 'IPS External Customer' limit 1];
            contactUserList = TestUtilities.getListOfUser(1);
            contactUserList[0].profileId=prof.id;
            contactUserList[0].contactid=contactListOptIn[0].id;
            contactUserList[0].username='teshekx@test.com';
            insert contactUserList;
            Id testUserId = contactUserList[0].id;
            System.assertEquals(contactUserList[0].username, 'teshekx@test.com');
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
            contactListOptIn[0].Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            update contactListOptIn[0];
            
            contactListOptIn[0].Core_IPS_Email_Opt_Out__c = false;
            contactListOptIn[0].Core_IPS_Active__c  = true;
            update contactListOptIn[0];
            
            contactListOptIn[0].Core_IPS_Email_Opt_Out__c = true;
            contactListOptIn[0].Core_IPS_Active__c  = true;
            update contactListOptIn[0];
            
        }
        //Test.stoptest();
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
        //Test.starttest();
        List<Contact> updatecontactList =  new List<Contact>();
        System.runAs(SystUserRunAs){
            Profile prof = [select id from profile where name = 'IPS External Customer' limit 1];
            contactUserList = TestUtilities.getListOfUser(1);
            contactUserList[0].profileId=prof.id;
            contactUserList[0].contactid=contactListOptIn[0].id;
            contactUserList[0].username='teshekx@test.com';
            insert contactUserList;
            System.assertEquals(contactUserList[0].username, 'teshekx@test.com');
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
                contactRecord.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
                updatecontactList.add(contactRecord);
            }
            update updatecontactList;
        }
        //Test.stoptest();
    }
    
    
    public static void getRecords(){
        Test.startTest();
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
                contactRecord.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
                i++;
            }
            insert contactListOptIn;
            
            for(Contact contactRecord: contactListOptOut){
                contactRecord.accountid = AccountList.get(1).id;
                contactRecord.Core_IPS_Email_Opt_Out__c = true;
                contactRecord.Email = 'Contact1Dell@yahoo.com';
                contactRecord.Core_ERPM_Integration_Message__c= 'Error Code';
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
        Test.stopTest();
    }
    
    /*
    * Method name  : testUpdateMembershipFlag
    * Description  : Method to test UpdateMembershipFlag functionality
    * Return Type  : void
    * Parameters   : None
    */
    static testMethod void testUpdateMembershipFlag() {
            
            // System.runAs(Core_Test_Utility.systemAdminUser) {
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            
            /*Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'contactJobFunction';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Update';
            executeTrigger.Core_Description__c = 'update membership Flag of partner Account based on the value change on segment field of Contact';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);*/
            /** The above code needs not to run **/
            
             // Create sample Job Function References
             
            Core_ERPM_Engagement__c MPEng = new Core_ERPM_Engagement__c();
            MPEng.Name='Access and Entitlements for Marketplace';
            MPEng.Core_Technical_Engagement_Code__c = 'MKTSMP';
            MPEng.Core_Engagement_Type__c='SMP';
            MPEng.Core_IsActive__c=true;
            insert MPEng ;
            
            Core_AGS_Role__c MPRole = new Core_AGS_Role__c();
            MPRole.Name = 'Sales-PRM-External-Lead Development Representative';
            MPRole.Core_Technical_Name__c = 'Sales-PRM-External-Lead Development Representative';
            MPRole.Core_IsActive__c=true;
            insert MPRole;
            
            Core_Entitlement__c LDR = new Core_Entitlement__c();
            LDR.Core_AGS_Role_Id__c = MPRole.id;
            LDR.Name = 'Lead Development Representative';
            LDR.Core_ERPM_Engagement_Id__c = MPEng.id;
            LDR.Core_Display_Name__c = 'Lead Development Representative';
            LDR.Core_IsActive__c =true;
            insert LDR;
            System.assert(true,LDR.Core_ERPM_Engagement_Id__c!= null);
            String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        
            Account acc1 = new Account(Name='testAccount',
                                          Core_Account_Type__c='EBM- Embedded Board Manufacturer', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545');
            insert acc1;
            Account acc2 = new Account(Name='testPartnerAccount',
                                          Core_Account_Type__c='EBM- Embedded Board Manufacturer', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',RecordTypeId=partnerAccRecTypeId);
            insert acc2;
           
            Contact testContact = new Contact(FirstName='testFirstName123',LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=acc1.id,Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element',Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            insert testContact;
            
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=LDR.id,
                                                                          Core_Selected__c=true, Core_Status__c = 'Complete');
            insert ce1; 
            Test.startTest();
            Core_Account_Group_Member__c accGrpMapping = new Core_Account_Group_Member__c();
            
                accGrpMapping.Core_Intel_Account_Id__c = acc1.id;
                accGrpMapping.Core_Partner_Account_Id__c =acc2.id; 
             insert accGrpMapping; 
            
            testContact.Core_IPA_Contact_Segment__c ='Data Center';
            update testContact;

        //}
       Test.stopTest(); 
    }
    
    static testMethod void SeteRPMStsOnCreateConatct() {

        System.runAs(Core_Test_Utility.systemAdminUser) {
            Test.startTest();
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'eRPM_Int_Status_Pending_Insert';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Sets erpm int status to pending.';
            executeTrigger.Core_Class_Name__c = 'Core_Contact';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);
                        

            // Create a new Contact 
            List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            Contact contact = lstContacts[0];
            System.debug('contact'+contact);
            contact.AccountId = account.id;
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            insert contact;
            System.debug('contact'+contact.Id);
            System.assertNotEquals(null, contact.Id);

            // Make sure that the Job Function is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c, Core_ERPM_Integration_Status__c 
                       FROM Contact WHERE Id = :contact.Id];
            System.assertEquals('In-Progress', contact.Core_ERPM_Integration_Status__c);           

            Test.stopTest();
            // Update the existing Contact with new Job Function Code
            //contact.Core_Job_Function_Code__c = 'TEST2';
            //update contact;

        }
    }
    
    static testMethod void SeteRPMStsOnUpdateConatct() {

        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'eRPM_Int_Status_Pending_Insert';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Sets erpm int status to pending.';
            executeTrigger.Core_Class_Name__c = 'Core_Contact';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            Core_Trigger_Executions__c executeTrigger1 = new Core_Trigger_Executions__c();
            executeTrigger1.Name = 'eRPM_Int_Status_Pending_Update';
            executeTrigger1.Core_Object__c = 'Contact';
            executeTrigger1.Core_Active__c = TRUE;
            executeTrigger1.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger1.Core_Description__c = 'Sets erpm int status to pending.';
            executeTrigger1.Core_Class_Name__c = 'Core_Contact';
            insert executeTrigger1;
            System.assertNotEquals(null, executeTrigger1.Id);
                        

            // Create a new Contact 
            List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            Contact contact = lstContacts[0];
            contact.AccountId = account.id;
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            insert contact;
            System.assertNotEquals(null, contact.Id);

            // Make sure that the Job Function is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c, Core_ERPM_Integration_Status__c 
                       FROM Contact WHERE Id = :contact.Id];
            System.assertEquals('In-Progress', contact.Core_ERPM_Integration_Status__c);           

            // Update the existing Contact 
            //contact.FirstName = 'Testatb';
            //contact.LastName = 'Testatb';
            contact.Core_English_Only_Last_Name__c = 'Testatb';
            contact.Core_ERPM_Integration_Status__c = 'Pending';
            Core_ContactHandler.hasRunUpdate = false;
            update contact;
            
            contact = [select Id, Core_English_Only_Last_Name__c, Core_ERPM_Integration_Status__c 
                       FROM Contact WHERE Id = :contact.Id];
            System.assertEquals('Pending', contact.Core_ERPM_Integration_Status__c);   
            System.assertEquals('Testatb', contact.Core_English_Only_Last_Name__c); 

        }
    }
/*    
    @isTest()
    public static void UpdateUsersLanguageTest() {
        
        List<Contact> lstConToUpdate = new List<Contact>();
        List<Contact> lstConToInsert = new List<Contact>();

        Core_Trigger_Executions__c executeTrigger1 = new Core_Trigger_Executions__c();
            executeTrigger1.Name = 'AGS_Int_Status_Pending';
            executeTrigger1.Core_Object__c = 'Contact';
            executeTrigger1.Core_Active__c = TRUE;
            executeTrigger1.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger1.Core_Description__c = 'update users language.';
            executeTrigger1.Core_Class_Name__c = 'Core_Contact';
            insert executeTrigger1;
        
        List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
        List<Contact> lstContacts = Core_Test_Utility.createContacts(3);
            Contact contact = lstContacts[0];
            contact.AccountId = account.id;
            Contact contact1 = lstContacts[1];
            contact1.AccountId = account.id;
            Contact contact2 = lstContacts[2];
            contact2.AccountId = account.id;
            lstConToInsert.add(contact);
            lstConToInsert.add(contact1);
            lstConToInsert.add(contact2);
            insert lstConToInsert;
        Core_ERPM_Engagement__c MPEng = new Core_ERPM_Engagement__c();
            MPEng.Name='Access and Entitlements for Marketplace';
            MPEng.Core_Technical_Engagement_Code__c = 'MKTSMP';
            MPEng.Core_Engagement_Type__c='SMP';
            MPEng.Core_IsActive__c=true;
            insert MPEng ;
        Core_Entitlement__c entPartner = new Core_Entitlement__c();
            entPartner.Name = 'Partner Portal';
            entPartner.Core_Display_Name__c = 'Partner Portal';
            entPartner.Core_IsActive__c =true;
            entPartner.Core_ERPM_Engagement_Id__c= MPEng.id;
            insert entPartner;
        Core_Entitlement__c entEmployee = new Core_Entitlement__c();
            entEmployee.Name = 'Employee';
            entEmployee.Core_Display_Name__c = 'Employee';
            entEmployee.Core_IsActive__c =true;
            entEmployee.Core_ERPM_Engagement_Id__c= MPEng.id;
            insert entEmployee;
        Core_Entitlement__c entPArtnerDDR = new Core_Entitlement__c();
            entPArtnerDDR.Name = 'Partner Portal - DDR';
            entPArtnerDDR.Core_Display_Name__c = 'Partner Portal - DDR';
            entPArtnerDDR.Core_IsActive__c =true;
            entPArtnerDDR .Core_ERPM_Engagement_Id__c= MPEng.id;
            insert entPArtnerDDR;
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
            ce1.Core_Contact_Id__c = contact.Id;
            ce1.Core_Entitlement_Id__c = entPartner.id;
            ce1.Core_Selected__c = true;
            ce1.Core_Status__c = 'Complete';
            insert ce1; 
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c();
            ce2.Core_Contact_Id__c = contact.Id;
            ce2.Core_Entitlement_Id__c = entEmployee.id;
            ce2.Core_Selected__c = true;
            ce2.Core_Status__c = 'Complete';
            insert ce2;
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c();
            ce3.Core_Contact_Id__c = contact1.Id;
            ce3.Core_Entitlement_Id__c = entPartner.id;
            ce3.Core_Selected__c = true;
            ce3.Core_Status__c = 'Complete';
            insert ce3;
        Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c();
            ce4.Core_Contact_Id__c = contact2.Id;
            ce4.Core_Entitlement_Id__c = entPArtnerDDR.id;
            ce4.Core_Selected__c = true;
            ce4.Core_Status__c = 'Complete';
            insert ce4;
        Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User user = new User();
            user.alias = 'test123';
            user.email='test123@noemail.com';
            user.emailencodingkey='UTF-8';
            user.lastname='Testing';
            user.languagelocalekey='en_US';
            user.localesidkey='en_US';
            user.profileid = [select id from profile where name='Partner'].id;
            user.country='United States';
            user.IsActive =true;
            user.ContactId = contact.Id;
            user.timezonesidkey='America/Los_Angeles';
            user.username='tester@mailinator.com';
        User user1 = new User();
            user1.alias = 'test123';
            user1.email='test123@noemail.com';
            user1.emailencodingkey='UTF-8';
            user1.lastname='Testing';
            user1.languagelocalekey='en_US';
            user1.localesidkey='en_US';
            user1.profileid = [select id from profile where name='Partner'].id;
            user1.country='United States';
            user1.IsActive =true;
            user1.ContactId = contact1.Id;
            user1.timezonesidkey='America/Los_Angeles';
            user1.username='tester1@mailinator.com';
        User usr1 = [Select id from User where Id = :UserInfo.getUserId()];
        usr1.UserRoleId = usRole.Id;
        update usr1;
        System.RunAs(usr1){
            insert user;
            insert user1;
        }
        
        contact.Core_Preferred_Language__c = 'DEU';
            lstConToUpdate.add(contact);
        contact1.Core_Preferred_Language__c = '';
            lstConToUpdate.add(contact1);
        update lstConToUpdate;
        Test.stopTest();
        System.assertEquals('DEU', contact.Core_Preferred_Language__c);
    }
*/
    
    static testMethod void SeteRPMStsOnRepublishConatct() {

        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'eRPM_Int_Status_Pending_Update';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = TRUE;
            executeTrigger.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger.Core_Description__c = 'Sets erpm int status to pending.';
            executeTrigger.Core_Class_Name__c = 'Core_Contact';
            insert executeTrigger;
            System.assertNotEquals(null, executeTrigger.Id);
            
            // Put an entry in Core_Trigger_Executions__c so the Contact trigger gets exectued
            Core_Trigger_Executions__c executeTrigger1 = new Core_Trigger_Executions__c();
            executeTrigger1.Name = 'AGS_Int_Status_Pending';
            executeTrigger1.Core_Object__c = 'Contact';
            executeTrigger1.Core_Active__c = TRUE;
            executeTrigger1.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger1.Core_Description__c = 'Sets erpm int status to pending.';
            executeTrigger1.Core_Class_Name__c = 'Core_Contact';
            insert executeTrigger1;
            System.assertNotEquals(null, executeTrigger1.Id);
            
            Core_Trigger_Executions__c executeTrigger2 = new Core_Trigger_Executions__c();
            executeTrigger2.Name = 'eRPM_Int_Status_Pending_Insert';
            executeTrigger2.Core_Object__c = 'Contact';
            executeTrigger2.Core_Active__c = TRUE;
            executeTrigger2.Core_Trigger_Events__c = 'After Insert, After Update';
            executeTrigger2.Core_Description__c = 'Sets erpm int status to pending.';
            executeTrigger2.Core_Class_Name__c = 'Core_Contact';
            insert executeTrigger2;
            System.assertNotEquals(null, executeTrigger2.Id);
                        

            // Create a new Contact 
            List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
            Account account = lstAccounts[0];
            insert account;
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
            Contact contact = lstContacts[0];
            contact.AccountId = account.id;
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            insert contact;
            System.assertNotEquals(null, contact.Id);

            // Make sure that the Job Function is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c, Core_ERPM_Integration_Status__c,Core_Republish_OBM_s__c
                       FROM Contact WHERE Id = :contact.Id];
            System.assertEquals('In-Progress', contact.Core_ERPM_Integration_Status__c);           

            // Update the existing Contact 
            //contact.FirstName = 'Testatb';
            //contact.LastName = 'Testatb';
            contact.Core_Republish_OBM_s__c = true;
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            Core_ContactHandler.hasRunRepublish = false;
            update contact;
            
            contact = [select Id, Core_English_Only_Last_Name__c, Core_ERPM_Integration_Status__c,Core_AGS_Integration_Status__c,Core_Republish_OBM_s__c
                       FROM Contact WHERE Id = :contact.Id];
            System.assertEquals('Pending', contact.Core_ERPM_Integration_Status__c);   
            System.assertEquals('Pending', contact.Core_AGS_Integration_Status__c); 
            System.assertEquals(false, contact.Core_Republish_OBM_s__c);

        }
    }
      /*
    * Method name  : testInsertRecordInIntegrationStatusDetail
    * Description  : Method to test Error Code population Functionality
    * Return Type  : void
    * Parameters   : None
    */
   static testMethod void testInsertRecordInIntegrationStatusDetail() {
            
         Test.startTest();
         Account acc1 = new Account(Name='testAccount',
                                          Core_Account_Type__c='EBM- Embedded Board Manufacturer', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545');
         insert acc1;
         
       
          Contact testContact = new Contact(FirstName='testFirstName12',
       LastName='testLastName1',
       Email='test4021@mailinator.com',
       AccountId=acc1.id,
       Core_AGS_Integration_Status__C='Pending',
       Core_ERPM_Integration_Status__C='Successful',
       Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element');
       insert testContact;
      
       testContact.Core_ERPM_Integration_Status__C='Failed';           
       update testContact;
        System.assertEquals(testContact.Email, 'test4021@mailinator.com');
        
        Contact testContact1 = new Contact(FirstName='agTestFirstName12',
       LastName='agTestLastName1',
       Email='test5821@mailinator.com',
       AccountId=acc1.id);
       
       insert testContact1;
        
       testContact1.Core_AGS_Integration_Status__C='Pending';
        
       update testContact1;
                                           
        
         Contact testContact2 = new Contact(FirstName='FirstName1234',LastName='LastName3', Email='te6221@yahoo.com',
                                          AccountId=acc1.id,Core_ERPM_Integration_Message__c='');
            insert testContact2;
         test.stopTest();
                   
     }
    
    
    private static List<Account> lstAccounts {
        get;
        set;
    }
    private static List<Contact> lstContacts {
        get;
        set;
    }
    
    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data for Inquiry Owner Change on Contact's owner change
     * Return Type  : None
     * Parameter    : None
     */
    static void setupData() {
        
        List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
        List<String> settingNameList = new List<String>();
        settingNameList.add('userGroupMappingIndicator');
        settingNameList.add('intStatusLastUpdate');
        settingNameList.add('ContactAccountChangeUpdate');
        settingNameList.add('MergeContactEntitlements');
        settingNameList.add('ContactEmailChangeUpdate');
        //settingNameList.add('updateInquiryOwnerOnContactOwnerUpdate');
        settingNameList.add('contactJobFunction');
        settingNameList.add('eRPM_Int_Status_Pending_Insert');
        settingNameList.add('eRPM_Int_Status_Pending_Update');
        settingNameList.add('UpdateJobFunctionAndCode');
        Core_Trigger_Executions__c triggerSetting;
        for(String settingName : settingNameList){
            triggerSetting = new Core_Trigger_Executions__c();
            triggerSetting.name = settingName;
            triggerSetting.Core_Object__c = 'Contact';
            triggerSetting.Core_Active__c = TRUE;
            triggerSetting.Core_Description__c = 'This is test description';
            triggerSetting.Core_Class_Name__c = 'Core_ContactHandler';
            triggerSetting.Core_Trigger_Events__c = 'Before Insert, Before Update, After Insert, After Update';
            triggerSettingList.add(triggerSetting);
        }
        insert triggerSettingList;
    
        lstAccounts = new List<Account>();
        lstContacts = new List<Contact>();
        
        
        for(integer i = 0; i <3; i++) {
            Account accountInstance = new Account();
            accountInstance.name = 'Test ' + i;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountInstance.Core_Sales_Groups__c='APJ India Sales Group';
            lstAccounts.add(accountInstance);
        }
        Contact contactInstance;

        for (Integer i = 0; i <6; i++) {
            contactInstance = new Contact();
            contactInstance.FirstName = 'test';
            contactInstance.LastName = i + '';
            contactInstance.email = 'test@test' + i + '.com';
            lstContacts.add(contactInstance);
        }
        
       
        // Insert Accounts
        for (Integer i = 0; i<lstAccounts.size(); i++) {
            lstAccounts[i].BillingCountryCode = 'USA';
            lstAccounts[i].BIllingStateCode = 'AL';
            lstAccounts[i].BillingCity = 'Alabama';
            lstAccounts[i].BillingStreet = 'test';
            lstAccounts[i].BillingPostalCode = '577100';
            lstAccounts[i].Core_Sales_Groups__c='US Sales Group';
            lstAccounts[i].Name = 'Deloitte' + i;
        }
        insert lstAccounts;
        
        System.debug(' All Accounts  '+lstAccounts);
        
        // Insert Contacts
        for (Integer i = 0; i<lstContacts.size(); i++) { 
            for(Integer j = 0; j<3 ;j++){                       
                lstContacts[i].AccountId = lstAccounts.get(j).Id;
                lstContacts[i].Email = 'tet77st' + i + '@tes.com';
            }
        }
        
        insert lstContacts;        
}

    
   /* static testMethod void testInquiryOwnerChange(){
        System.runAs(Core_Test_Utility.systemAdminUser) {
            setupData();
        }
        Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'Sales Manager'];
            List<User> lstUser = Core_Test_Utility.Core_User(1);
            lstUser[0].Profileid = p1.id;
            insert lstUser;
                
        List<Core_Inquiry__c> inqList = new List<Core_Inquiry__c>();
        for(integer i=0;i<2;i++){
            Core_Inquiry__c inq = new Core_Inquiry__c();
            inq.Name ='TinTin1';
            inq.Core_Contact_Inquiries__c = lstContacts[0].Id;
            inq.Core_Inquiry_Type_Pkt__c ='Requested Quote';
            inqList.add(inq);
        }
        System.assertEquals(inqList[0].Core_Inquiry_Type_Pkt__c, 'Requested Quote');

        System.runAs(Core_Test_Utility.systemAdminUser) {
            if(inqList.size()>0 && inqList!= null){
                Database.insert(inqList);
            }
        }              
        Test.starttest();
            lstContacts[0].ownerId = lstUser[0].Id;
            update lstContacts[0];                
        test.stoptest();        
    }*/
    
    
}