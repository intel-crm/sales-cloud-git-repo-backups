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
* Praveena Yegurla        21/4/2021               Modified testUpdateMembershipFlag()
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
            executeTrigger.Name = 'Contact_Insert_IPA_Integration_Trigger';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
            executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa - This is to fix the SOQL Limit Exception';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);
            executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'SendContactGECInfoToAGS';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
            executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa - This is to fix the SOQL Limit Exception';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);

            executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'ContactEmailChangeUpdate';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
            executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa - This is to fix the SOQL Limit Exception';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);
            executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'ContactAccountChangeUpdate';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
            executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa - This is to fix the SOQL Limit Exception';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);

            executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'SendContactstoLicense';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
            executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
            executeTrigger.Core_Description__c = 'Updates Job Function based on Job Function Code and vice versa - This is to fix the SOQL Limit Exception';
            executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
            executeTriggers.add(executeTrigger);

            executeTrigger = new Core_Trigger_Executions__c();
            executeTrigger.Name = 'intStatusLastUpdate';
            executeTrigger.Core_Object__c = 'Contact';
            executeTrigger.Core_Active__c = true;
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
            
            List<Contact> lstContacts = Core_Test_Utility.createContacts(2);
            
            // create new reg request here
            PRM_Registration_Request__c newRegistrationRequest11 = PRM_TestUtility.getPRMRegistrationRequest();
            ChannelProgram cpIpa = new ChannelProgram();
            cpIpa.Name=Label.PRM_Intel_Partner_Alliance;
            cpIpa.PRM_programCode__c='IPA';
            insert cpIpa;
            //ChannelProgram  cp=[select id from ChannelProgram where PRM_programCode__c='IPA' limit 1]; 
            newRegistrationRequest11.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
            newRegistrationRequest11.PRM_Partner_Type__c = 'FPGA Design Services';
            newRegistrationRequest11.PRM_Contact_Login_ID__c = 'testrequest@intel.com';
            newRegistrationRequest11.PRM_Status__c = 'New';
            newRegistrationRequest11.Name = 'Auto Approve Request On Partner Role';
            newRegistrationRequest11.PRM_Legal_Agreements__c = 'IPA_TANDC';
            newRegistrationRequest11.PRM_Profile_Response__c = 'test pr'; 
            newRegistrationRequest11.PRM_Email_ID__c = 'test@test0.com';
            newRegistrationRequest11.PRM_Country__c = 'US';
            newRegistrationRequest11.PRM_Preferred_Language__c = 'ENG';
            newRegistrationRequest11.PRM_Channel_Program__c = cpIpa.Id;
            newRegistrationRequest11.PRM_Auto_Approve__c = true;                        
            
            PRM_Registration_Request__c newRegistrationRequest2 = PRM_TestUtility.getPRMRegistrationRequest();
            newRegistrationRequest2.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
            newRegistrationRequest2.PRM_Partner_Type__c = 'FPGA Design Services';
            newRegistrationRequest2.PRM_Contact_Login_ID__c = 'testrequest@intel.com';
            newRegistrationRequest2.PRM_Status__c = 'New';
            newRegistrationRequest2.Name = 'Auto Approve Request On Partner Role';
            newRegistrationRequest2.PRM_Legal_Agreements__c = 'IPA_TANDC';
            newRegistrationRequest2.PRM_Profile_Response__c = 'test pr'; 
            newRegistrationRequest2.PRM_Email_ID__c = 'test@test1.com';
            newRegistrationRequest2.PRM_Country__c = 'US';
            newRegistrationRequest2.PRM_Preferred_Language__c = 'ENG';
            newRegistrationRequest2.PRM_Channel_Program__c = cpIpa.Id;
            newRegistrationRequest2.PRM_Auto_Approve__c = true;                        
            
            insert new List<PRM_Registration_Request__c>{newRegistrationRequest11,newRegistrationRequest2};
                
            Contact contact = lstContacts[0];
            contact.External_User_State__c='Accepted';
            contact.AccountId = account.id;
            contact.Core_Job_Function_Code__c = 'TEST1';
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            insert contact;
            
            Contact contact1 = lstContacts[1];
            contact1.External_User_State__c='Accepted';
            contact1.AccountId = account.id;
            contact1.Core_Job_Function_Code__c = 'TEST1';
            contact1.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            insert contact1; 
            
            PRM_Registration_Tracker__c trac=new PRM_Registration_Tracker__c();
            trac.Stage__c='52';
            trac.PRM_Email__c='testrequest@maildrop.cc';
            trac.PRM_Registration__c=newRegistrationRequest11.Id;
            trac.PRM_Step_Number__c=52;
            trac.PRM_Current_Step__c=52; 
            trac.PRM_contact__c = contact1.Id;
            insert trac;
            
            System.assertNotEquals(null, contact.Id);
            
            // Make sure that the Job Function is updated
            contact = [select Id, Core_Job_Function_Code__c, Core_Job_Function__c FROM Contact WHERE Id = :contact.Id];
            System.debug('Job Function Test :: contact ::: ' + contact);
            //System.assertEquals('TEST1', contact.Core_Job_Function_Code__c);
            //System.assertEquals('Test Job Function 1', contact.Core_Job_Function__c);
            
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
            //System.assertEquals('TEST1', contact.Core_Job_Function_Code__c);
            //System.assertEquals('Test Job Function 1', contact.Core_Job_Function__c);
            
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
            contact.Email = 'abc@abc.com';
            contact.Core_Job_Function__c = 'Test Job Function 1';
            contact.Core_IPS_Email_Opt_Out__c = false;
            contact.Core_IPA_Email_Verification_Date__c = null;
            contact.Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            insert contact;  
            
            contact.Core_IPA_Email_Verification_Date__c = datetime.newInstance(2022, 05, 19, 12, 30, 0);
            contact.Email = 'xyz@xyz.com'  ;         
                update contact;
            
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
        
        Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
        executeTrigger.Name = 'UpdateMembershipFlagInd';
        executeTrigger.Core_Object__c = 'Contact';
        executeTrigger.Core_Active__c = TRUE;
        executeTrigger.Core_Trigger_Events__c = 'After Update';
        executeTrigger.Core_Description__c = 'update membership Flag of partner Account based on the value change on segment field of Contact';
        executeTrigger.Core_Class_Name__c = 'Core_ContactHandler';
        insert executeTrigger;
        System.assertNotEquals(null, executeTrigger.Id);
        
        Core_Trigger_Executions__c executeTrigger1 = new Core_Trigger_Executions__c();
        executeTrigger1.Name = 'UpdateExternalUserLanguageInd';
        executeTrigger1.Core_Object__c = 'Contact';
        executeTrigger1.Core_Active__c = TRUE;
        executeTrigger1.Core_Trigger_Events__c = 'After Update';
        executeTrigger1.Core_Description__c = 'update membership Flag of partner Account based on the value change on segment field of Contact';
        executeTrigger1.Core_Class_Name__c = 'Core_ContactHandler';
        insert executeTrigger1;
        System.assertNotEquals(null, executeTrigger1.Id);
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
        
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        
        Account acc1 = new Account(Name='testAccount',RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId(),
                                   Core_Account_Type__c='EBM- Embedded Board Manufacturer', Industry='Others',
                                   BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                   BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545');
        insert acc1;
        Account acc2 = new Account(Name='testPartnerAccount',
                                   Core_Account_Type__c='EBM- Embedded Board Manufacturer', Industry='Others',
                                   BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                   BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',RecordTypeId=partnerAccRecTypeId);
        insert acc2;
        List<Contact> conList = new List<Contact>();
        Contact testContact = new Contact(FirstName='testFirstName123',LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=acc1.id,Core_ERPM_Integration_Message__c='Timestamp: 2022-08-05 10:18:36 GMT Inbound Message ID: a002i000004LlUPAA0 Error Code: 1028, Error Text: Technical Error Occurred, Error Details: Error in SetUserProfile. Error-User Name does not Exist',Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='300002700924',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        conList.add(testContact);
        Contact testContact01 = new Contact(FirstName='testFirstName1234',LastName='testLastName01', Email='test1234@testing01.com.testsetup',
                                          AccountId=acc1.id,Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element',Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        conList.add(testContact01);
        Test.startTest();
        insert conList;
        
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                          Core_Entitlement_Id__c=LDR.id,
                                                                          Core_Selected__c=true, Core_Status__c = 'Complete');
        insert ce1; 
      //  Test.startTest();
        Core_Account_Group_Member__c accGrpMapping = new Core_Account_Group_Member__c();
        
        accGrpMapping.Core_Intel_Account_Id__c = acc1.id;
        accGrpMapping.Core_Partner_Account_Id__c =acc2.id; 
        insert accGrpMapping; 
        
        conList[0].Core_IPA_Contact_Segment__c ='Data Center';
        update conList;
      //  Core_ContactHandler.UpdateMembershipFlag(null,null);
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
        account.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        account.Core_Sales_Groups__c='EMEA Partner Holding';
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
        
         Test.startTest();

        List<Core_Entitlement__c> lstCE = new List<Core_Entitlement__c>();
        Core_Entitlement__c entPartner = new Core_Entitlement__c();
        entPartner.Name = 'Partner Portal';
        entPartner.Core_Display_Name__c = 'Partner Portal';
        entPartner.Core_IsActive__c =true;
        lstCE.add(entPartner) ;
        Core_Entitlement__c entEmployee = new Core_Entitlement__c();
        entEmployee.Name = 'Employee';
        entEmployee.Core_Display_Name__c = 'Employee';
        entEmployee.Core_IsActive__c =true;
        lstCE.add(entEmployee) ;
        
        Core_Entitlement__c entPArtnerDDR = new Core_Entitlement__c();
        entPArtnerDDR.Name = 'Partner Portal - DDR';
        entPArtnerDDR.Core_Display_Name__c = 'Partner Portal - DDR';
        entPArtnerDDR.Core_IsActive__c =true;
        //insert entPArtnerDDR;
        lstCE.add(entPArtnerDDR) ;
        insert lstCE;
        List<Core_Contact_Entitlement__c> lstContactEnt = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
        ce1.Core_Contact_Id__c = contact.Id;
        ce1.Core_Entitlement_Id__c = entPartner.id;
        ce1.Core_Selected__c = true;
        ce1.Core_Status__c = 'Complete';
        //insert ce1; 
        lstContactEnt.add(ce1);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c();
        ce2.Core_Contact_Id__c = contact.Id;
        ce2.Core_Entitlement_Id__c = entEmployee.id;
        ce2.Core_Selected__c = true;
        ce2.Core_Status__c = 'Complete';
        //insert ce2;
        lstContactEnt.add(ce2);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c();
        ce3.Core_Contact_Id__c = contact1.Id;
        ce3.Core_Entitlement_Id__c = entPartner.id;
        ce3.Core_Selected__c = true;
        ce3.Core_Status__c = 'Complete';
        //insert ce3;
        lstContactEnt.add(ce3);
        Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c();
        ce4.Core_Contact_Id__c = contact2.Id;
        ce4.Core_Entitlement_Id__c = entPArtnerDDR.id;
        ce4.Core_Selected__c = true;
        ce4.Core_Status__c = 'Complete';
        // insert ce4;
        lstContactEnt.add(ce4);
        insert lstContactEnt;
      //  Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User user = new User();
        user.UserRoleId = usRole.Id;
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
        user.username=Math.random()+'@'+UserInfo.getOrganizationid()+'.test';
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
        user1.username=Math.random()+'@'+UserInfo.getOrganizationid()+'.test';
        User usr1 = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr1){
            //insert user;
            //insert user1;
        }
        
        contact.Core_Preferred_Language__c = 'DEU';
        lstConToUpdate.add(contact);
        contact1.Core_Preferred_Language__c = '';
        lstConToUpdate.add(contact1);
        update lstConToUpdate;
        Test.stopTest();
        System.assertEquals('DEU', contact.Core_Preferred_Language__c);
    }
    
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
            contact.Core_IPA_PartnerRole__c = 'Service Provider';
            contact.Core_Preferred_Language__c='FRA';
            contact.Core_English_Only_First_Name__c = 'testFirstfirst';
            contact.Core_English_Only_Last_Name__c ='testFirst';
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
            //System.assertEquals('Pending', contact.Core_AGS_Integration_Status__c); 
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
        Account acc1 = new Account(Name='testAccount',RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId(),
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
        testContact.Email='testmycont@test.com';
        update testContact;
        
        
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
        settingNameList.add('updateInquiryOwnerOnContactOwnerUpdate');
        settingNameList.add('contactJobFunction');
        settingNameList.add('eRPM_Int_Status_Pending_Insert');
        settingNameList.add('eRPM_Int_Status_Pending_Update');
        settingNameList.add('UpdateJobFunctionAndCode');
        settingNameList.add('UpdateMembershipFlagInd');
        settingNameList.add('UpdateExternalUserLanguageInd');
        settingNameList.add('Contact_Insert_IPA_Integration_Trigger');
        settingNameList.add('Contact_Update_IPA_Integration_Trigger');
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
            accountInstance.Core_Sales_Groups__c='PRC Sales Group';
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
            lstAccounts[i].Core_Sales_Groups__c='EMEA Partner Holding';
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
        
        for (Contact con : lstContacts){
            con.Email = con.lastName+'@test.com';
        }
        update lstContacts;
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Map<Id,Contact> oldCons = new Map<Id, Contact>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = accountRecordTypeIntel;
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.google.com';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount.Core_CNDA_Number__c = '778281992';
        newAccount.Core_CIM_ID__c = '71172272';
        newAccount.Core_B2B_Entitlement__c = true;
        newAccount.Core_English_Only_Name__c = 'John Rick';
        
        insert newAccount;
        
        Account secondAcc = new Account();//Account
        secondAcc.RecordTypeId = accountRecordTypeIntel;
        secondAcc.Name='Johny Rick';
        secondAcc.BillingCity='City1';
        secondAcc.BillingStreet='Street1';
        secondAcc.BillingCountry='India';
        secondAcc.BillingPostalCode='Postal code';
        secondAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        secondAcc.Core_User_Defined_Website__c = 'www.googlets.com';
        secondAcc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        secondAcc.Core_CNDA_Number__c = '778281933';
        secondAcc.Core_CIM_ID__c = '71172211';
        secondAcc.Core_B2B_Entitlement__c = true;
        secondAcc.Core_English_Only_Name__c = 'Johny Rick';
        insert secondAcc;
        System.debug('first account'+secondAcc);
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.RecordTypeId = contactRecordType;
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_Enterprise_Id__c = '23456';
        cont.PRM_IPA_Integration_Status__c = 'Successful';
        cont.Core_English_Only_First_Name__c = 'Adam';
        cont.Core_English_Only_Last_Name__c = 'Grill';
        cont.Core_Account_Changeable__c = true;
        insert cont;
        oldCons.put(cont.Id, cont);
        con.add(cont);
        con[0].AccountId=secondAcc.Id;
        update con[0];
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(con, oldCons);

        
    }
    
    
    static testMethod void testInquiryOwnerChange(){
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
        System.runAs(Core_Test_Utility.systemAdminUser) {
            if(inqList.size()>0 && inqList!= null){
                Database.insert(inqList);
            }
        }              
        Test.starttest();
        lstContacts[0].ownerId = lstUser[0].Id;
        update lstContacts[0];                
        test.stoptest();        
    }
   
    @isTest
    public static void updateSoftContactIndicatortest(){
        Test.startTest();       
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick';
        newAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.google.com';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newAccount;
        
        Account secondAcc = new Account();//Account
        secondAcc.Name='Johny Rick';
        secondAcc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        secondAcc.BillingCity='City1';
        secondAcc.BillingStreet='Street1';
        secondAcc.BillingCountry='India';
        secondAcc.BillingPostalCode='Postal code';
        secondAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        secondAcc.Core_User_Defined_Website__c = 'www.googlets.com';
        secondAcc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert secondAcc;
        System.debug('first account'+secondAcc);
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_Enterprise_Id__c = '23456';
       // cont.Core_IPS_Employee_Customer__c = 'false';
        cont.PRM_IPA_Integration_Status__c = 'Successful';
        insert cont;
        
        cont.email='testsecond@mail.com';
        update cont;
        

        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name=System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
       cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=newAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=cont.Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        insert acr;
        System.debug('acr--1>'+acr); 
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=newAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=cont.Id;
        acr1.PRM_execute_trigger__c=true;
        insert acr1;
        
        try{    
            cont.Core_Login_Status__c = '' ;
            update cont;
            cont.Core_Login_Status__c = 'Deleted' ;
            update cont;
            cont.email='testsecond@mail.com';
            update cont;
        }
        catch(Exception e){
            System.debug('Exception Occured');
        }
        //Core_ContactHandler.updateSoftContactIndicator(null,null);
        Test.stopTest();
        System.assertEquals(acr.PRM_Account_Id__c,newAccount.Id,'Value does not match');   
    }
    
     @isTest
    public static  void setContactIPAIntegrationStatusToPendingOnUpdate_test(){
        Test.startTest();      
        
        Map<Id,Contact> oldCons = new Map<Id, Contact>();
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick';
        newAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.google.com';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newAccount;
        
        Account secondAcc = new Account();//Account
        secondAcc.Name='Johny Rick';
        secondAcc.BillingCity='City1';
        secondAcc.BillingStreet='Street1';
        secondAcc.BillingCountry='India';
        secondAcc.BillingPostalCode='Postal code';
        secondAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        secondAcc.Core_User_Defined_Website__c = 'www.googlets.com';
        secondAcc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert secondAcc;
        System.debug('first account'+secondAcc);
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_Enterprise_Id__c = '23456';
        cont.PRM_IPA_Integration_Status__c = 'Successful';
        cont.Core_English_Only_First_Name__c = 'Adam';
        cont.Core_English_Only_Last_Name__c = 'Grill';
        insert cont;
        oldCons.put(cont.Id, cont);
        con.add(cont);
        con[0].email='testsecond@mail.com';
        update con[0];
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(con, oldCons);
        Test.stopTest();
    }
    
    @isTest
    public static  void setContactIPAIntegrationStatusToPendingOnUpdateAccountChange_test(){
        Test.startTest();      
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Map<Id,Contact> oldCons = new Map<Id, Contact>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = accountRecordTypeIntel;
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.google.com';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount.Core_CNDA_Number__c = '778281992';
        newAccount.Core_CIM_ID__c = '71172272';
        newAccount.Core_B2B_Entitlement__c = true;
        newAccount.Core_English_Only_Name__c = 'John Rick';
        
        insert newAccount;
        
        Account secondAcc = new Account();//Account
        secondAcc.RecordTypeId = accountRecordTypeIntel;
        secondAcc.Name='Johny Rick';
        secondAcc.BillingCity='City1';
        secondAcc.BillingStreet='Street1';
        secondAcc.BillingCountry='India';
        secondAcc.BillingPostalCode='Postal code';
        secondAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        secondAcc.Core_User_Defined_Website__c = 'www.googlets.com';
        secondAcc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        secondAcc.Core_CNDA_Number__c = '778281933';
        secondAcc.Core_CIM_ID__c = '71172211';
        secondAcc.Core_B2B_Entitlement__c = true;
        secondAcc.Core_English_Only_Name__c = 'Johny Rick';
        insert secondAcc;
        System.debug('first account'+secondAcc);
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.RecordTypeId = contactRecordType;
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill11@rediffg.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_Enterprise_Id__c = '23456';
        cont.PRM_IPA_Integration_Status__c = 'Successful';
        cont.Core_English_Only_First_Name__c = 'Adam';
        cont.Core_English_Only_Last_Name__c = 'Grill';
        cont.Core_Account_Changeable__c = true;
        insert cont;
        oldCons.put(cont.Id, cont);
        con.add(cont);
        con[0].AccountId=secondAcc.Id;
        update con[0];
        
        PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(con, oldCons);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Core_ContactHandler.trackCommunityChanges(oldCons,con);}
        Test.stopTest();
    }
    
    @isTest
    public static void updateParComConEntitlements(){
         Test.startTest();
         Id intelConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
         Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();
        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrixInertList = new List<PRM_VXEnttlmntMatrix__c>();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);    
        
        List<Contact> contactsInsert = new List<Contact>();
        Contact con = PRM_TestUtility.getContact();
        con.RecordTypeId = intelConRecordTypeId;
        con.Email='testrequest@mailinator.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
       // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        con.Core_Login_Id__c = 'abc';
        //con.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con.Core_Login_Status__c ='Active';
        //con.Core_IPS_Employee_Customer__c = 'false';
        con.PRM_IPA_Integration_Status__c = 'Successful';
        contactsInsert.add(con);
        //insert con;
        //System.debug(con);
        //
        
        Contact con123 =  PRM_TestUtility.getContact(); 
        con123.RecordTypeId = intelConRecordTypeId;
        con123.Email='testrequest123@mailinator.com';
        con123.AccountId = acc.Id;
        con123.Core_Job_Function__c='Branch Manager';
        con123.Core_eRPM_Language_Code__c='Eng';
       // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con123.Core_IPA_PartnerRole__c = 'Service Provider';
        con123.Core_Login_Id__c = 'abc';
        con123.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con123.Core_Login_Status__c ='Active';
       // con123.Core_IPS_Employee_Customer__c = 'false';
        con123.PRM_IPA_Integration_Status__c = 'Successful';
        contactsInsert.add(con123);
        
        Contact con2 = new Contact();  //Contact
        con2.AccountId=acc.Id;
        con2.RecordTypeId = intelConRecordTypeId;
        con2.lastName='John';
        con2.FirstName='Wing';
        con2.email='johnwing@rediff.com';
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';
        con2.Core_IPA_PartnerRole__c = 'Service Provider';
        con2.Core_Login_Id__c = 'def';
        con2.Core_Enterprise_Id__c = '234561';
        con2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con2.Core_Login_Status__c ='Active';
      //  con2.Core_IPS_Employee_Customer__c = 'false';
        con2.PRM_IPA_Integration_Status__c = 'Successful';
        contactsInsert.add(con2);
        
        
        Contact con1 = PRM_TestUtility.getContact();
        con1.RecordTypeId = intelConRecordTypeId;
        con1.Email='testrequest1@mailinator.com';
        con1.AccountId = acc.Id;
        con1.Core_Job_Function__c='Branch Manager';
        con1.Core_eRPM_Language_Code__c='Eng';
       // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con1.Core_IPA_PartnerRole__c = 'Service Provider';
        con1.Core_Login_Id__c = 'abcd';
        //con.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con1.Core_Login_Status__c ='Active';
        //con1.Core_IPS_Employee_Customer__c = 'false';
        con1.PRM_IPA_Integration_Status__c = 'Successful';
        contactsInsert.add(con1);
        
        if(contactsInsert.size()>0){
            insert contactsInsert;
            contactsInsert[0].Email = 'testexmail@mailinator.com';
            update contactsInsert[0];
        }
        
        //****************** TWC729-2258 - Agate ********************************************************************
        PRM_Partner_Subscription__c subsdef = new PRM_Partner_Subscription__c() ;
        subsdef.Name  = 'Intel® Cloud Insider Partner Community Communications' ;
        subsdef.PRM_Subscription_Dsc__c = 'Intel Cloud Insider Partner Community Communications' ;
        subsdef.PRM_Subscription_Cd__c = 'INTCLDCOM' ;
        subsdef.PRM_InActive_Ind__c = false ;
        subsdef.PRM_Community__c = 'Intel® Cloud Insider Partner'  ;
        system.debug('Value of subsdef'+subsdef);
        insert subsdef;  
        
        PRM_ContactSubscriptionAssociation__c subs = new PRM_ContactSubscriptionAssociation__c() ;
        // PRM_Contact_Id__c,PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c,PRM_Partner_Subscription_Id__r.PRM_Community__c,PRM_Status_Nm__c
        subs.PRM_Contact_Id__c = con123.id  ;
        subs.PRM_Partner_Subscription_Id__c = subsdef.Id ;
        subs.PRM_Status_Nm__c  = 'Active' ;
        insert subs; 
        
         PRM_Partner_Subscription__c subsdef1 = new PRM_Partner_Subscription__c() ;
        subsdef1.Name  = 'Training and Webinar Communications' ;
        subsdef1.PRM_Subscription_Dsc__c = 'Training and Webinar Communications' ;
        subsdef1.PRM_Subscription_Cd__c = 'TRAWEBCOM' ;
        subsdef1.PRM_InActive_Ind__c = false ;
        subsdef1.PRM_Community__c = 'Intel® Cloud Insider Partner'  ;
        system.debug('Value of subsdef'+subsdef);
        insert subsdef1;
        
        PRM_ContactSubscriptionAssociation__c subs1 = new PRM_ContactSubscriptionAssociation__c() ;
        // PRM_Contact_Id__c,PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c,PRM_Partner_Subscription_Id__r.PRM_Community__c,PRM_Status_Nm__c
        subs1.PRM_Contact_Id__c = con123.id  ;
        subs1.PRM_Partner_Subscription_Id__c = subsdef1.Id ;
        subs1.PRM_Status_Nm__c  = 'Inactive' ;
        insert subs1;
        
        con123.Core_IPA_Partner_Community__c = '';
        Core_ContactHandler.isCommunityUpdated = false;
        update con123;
        
        
        //******************  TWC729-2258 - Agate - End ************************************************************
        
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'IOT Community User';
        ent.Core_Display_Name__c = 'IOT Community User';
        ent.Core_IsActive__c = true;
        corEntitInertList.add(ent);
       
        
        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Cloud Community User';
        ent1.Core_Display_Name__c = 'Cloud Community User';
        ent1.Core_IsActive__c = true;
        corEntitInertList.add(ent1);
        
        Core_Entitlement__c ent2 = new Core_Entitlement__c();
        ent2.Name = 'FPGA Community User';
        ent2.Core_Display_Name__c = 'FPGA Community User';
        ent2.Core_IsActive__c = true;
        corEntitInertList.add(ent2);
        
        if(corEntitInertList.size() > 0){
            insert corEntitInertList;
        }
        
        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.Communities__c = 'Intel® IOT Solution Partner';
        entMatrix.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix);
        
        PRM_VXEnttlmntMatrix__c entMatrix1 = new PRM_VXEnttlmntMatrix__c();
        entMatrix1.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix1.Communities__c = 'Intel® Cloud Insider Partner';
        entMatrix1.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix1);

        
        PRM_VXEnttlmntMatrix__c entMatrix2 = new PRM_VXEnttlmntMatrix__c();
        entMatrix2.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix2.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix2.Communities__c = 'Intel® FPGA Partner';
       entMatrix2.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix2);
        
          if(entMatrixInertList.size() > 0){
            insert entMatrixInertList;
        }
        List<Contact> contactUpdate = new List<Contact>();
        con.Core_IPA_Partner_Community__c = 'Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        //update con;
        contactUpdate.add(con);
        
        con123.Core_IPA_Partner_Community__c = 'Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        contactUpdate.add(con123);
        //update con123;
        

        //System.debug(con1);
        
        Core_Contact_Entitlement__c coreCon = new Core_Contact_Entitlement__c();
        coreCon.Core_Contact_Id__c = con1.id;
        coreCon.Core_Entitlement_Id__c = ent1.id;
        coreCon.Core_Status__c = 'Pending';
        insert coreCon;
        
        con1.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner'; 
        Core_ContactHandler.isCommunityUpdated = false;
        update con1;
        
        List<PRM_Partner_Community_Enrollment_Request__c> parComInsert = new List<PRM_Partner_Community_Enrollment_Request__c>();
        PRM_Partner_Community_Enrollment_Request__c parCom = new PRM_Partner_Community_Enrollment_Request__c();
        parCom.PRM_Contact_Id__c = con.id;
        parCom.PRM_Partner_Community_Nm__c='Intel® FPGA Partner';
        parCom.PRM_Status_Nm__c = 'Rejected';
        
        parComInsert.add(parCom);
        
                
        PRM_Partner_Community_Enrollment_Request__c parCom1 = new PRM_Partner_Community_Enrollment_Request__c();
        parCom1.PRM_Contact_Id__c = con2.id;
        parCom1.PRM_Partner_Community_Nm__c='Intel® Cloud Insider Partner';
        parCom1.PRM_Status_Nm__c = 'Rejected';
        
        parComInsert.add(parCom1);
        
        if(parComInsert.size()>0){
            insert parComInsert;
        }

        
        /*Core_Contact_Entitlement__c coreCon2 = new Core_Contact_Entitlement__c();
        coreCon2.Core_Contact_Id__c = con2.id;
        coreCon2.Core_Entitlement_Id__c = ent1.id;
        coreCon2.Core_Status__c = 'Complete';
        coreCon2.Core_Selected__c = true;
        insert coreCon2;*/

        
        //****************** TWC729-2258 - Agate ********************************************************************

        con123.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        update con123;
         
        //******************  TWC729-2258 - Agate - End ************************************************************
        map<id,contact> contmap=new map<id,contact>();
        contmap.put(contactsInsert[0].id,contactsInsert[0]);
        Core_ContactHandler.assignPartnerCommunityContactEntitlements(contmap,contactsInsert);
        Core_ContactHandler.createEnrollmentRequest(contactsInsert[0].id,'str','New');
        
        Test.stopTest();

    }
    
    @isTest
    public static void updateParComConEntitlements_active(){

         Id intelConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
         Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();
        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrixInertList = new List<PRM_VXEnttlmntMatrix__c>();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);    
        
        List<Contact> contactsInsert = new List<Contact>();
        Contact con = PRM_TestUtility.getContact();
        con.RecordTypeId = intelConRecordTypeId;
        con.Email='testrequest@mailinator.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
       // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        con.Core_Login_Id__c = 'abc';
        //con.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con.Core_Login_Status__c ='Active';
        //con.Core_IPS_Employee_Customer__c = 'false';
        con.PRM_IPA_Integration_Status__c = 'Successful';
        contactsInsert.add(con);
        //insert con;
        //System.debug(con);
        //
        
        Contact con123 =  PRM_TestUtility.getContact(); 
        con123.RecordTypeId = intelConRecordTypeId;
        con123.Email='testrequest123@mailinator.com';
        con123.AccountId = acc.Id;
        con123.Core_Job_Function__c='Branch Manager';
        con123.Core_eRPM_Language_Code__c='Eng';
       // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con123.Core_IPA_PartnerRole__c = 'Service Provider';
        con123.Core_Login_Id__c = 'abc';
        con123.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con123.Core_Login_Status__c ='Active';
       // con123.Core_IPS_Employee_Customer__c = 'false';
        con123.PRM_IPA_Integration_Status__c = 'Successful';
        contactsInsert.add(con123);
        
        Contact con2 = new Contact();  //Contact
        con2.AccountId=acc.Id;
        con2.RecordTypeId = intelConRecordTypeId;
        con2.lastName='John';
        con2.FirstName='Wing';
        con2.email='johnwing@rediff.com';
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';
        con2.Core_IPA_PartnerRole__c = 'Service Provider';
        con2.Core_Login_Id__c = 'def';
        con2.Core_Enterprise_Id__c = '234561';
        con2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con2.Core_Login_Status__c ='Active';
      //  con2.Core_IPS_Employee_Customer__c = 'false';
        con2.PRM_IPA_Integration_Status__c = 'Successful';
        contactsInsert.add(con2);
        
        
        Contact con1 = PRM_TestUtility.getContact();
        con1.RecordTypeId = intelConRecordTypeId;
        con1.Email='testrequest1@mailinator.com';
        con1.AccountId = acc.Id;
        con1.Core_Job_Function__c='Branch Manager';
        con1.Core_eRPM_Language_Code__c='Eng';
       // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con1.Core_IPA_PartnerRole__c = 'Service Provider';
        con1.Core_Login_Id__c = 'abcd';
        //con.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con1.Core_Login_Status__c ='Active';
        //con1.Core_IPS_Employee_Customer__c = 'false';
        con1.PRM_IPA_Integration_Status__c = 'Successful';
        contactsInsert.add(con1);
        
        if(contactsInsert.size()>0){
            insert contactsInsert;
            contactsInsert[0].Email = 'testexmail@mailinator.com';
            update contactsInsert[0];
        }
        
        //****************** TWC729-2258 - Agate ********************************************************************
        PRM_Partner_Subscription__c subsdef = new PRM_Partner_Subscription__c() ;
        subsdef.Name  = 'Intel® Cloud Insider Partner Community Communications' ;
        subsdef.PRM_Subscription_Dsc__c = 'Intel Cloud Insider Partner Community Communications' ;
        subsdef.PRM_Subscription_Cd__c = 'INTCLDCOM' ;
        subsdef.PRM_InActive_Ind__c = false ;
        subsdef.PRM_Community__c = 'Intel® Cloud Insider Partner'  ;
        system.debug('Value of subsdef'+subsdef);
        insert subsdef;  
        
        PRM_ContactSubscriptionAssociation__c subs = new PRM_ContactSubscriptionAssociation__c() ;
        // PRM_Contact_Id__c,PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c,PRM_Partner_Subscription_Id__r.PRM_Community__c,PRM_Status_Nm__c
        subs.PRM_Contact_Id__c = con123.id  ;
        subs.PRM_Partner_Subscription_Id__c = subsdef.Id ;
        subs.PRM_Status_Nm__c  = 'Active' ;
        insert subs; 
        
         PRM_Partner_Subscription__c subsdef1 = new PRM_Partner_Subscription__c() ;
        subsdef1.Name  = 'Training and Webinar Communications' ;
        subsdef1.PRM_Subscription_Dsc__c = 'Training and Webinar Communications' ;
        subsdef1.PRM_Subscription_Cd__c = 'TRAWEBCOM' ;
        subsdef1.PRM_InActive_Ind__c = false ;
        subsdef1.PRM_Community__c = 'Intel® Cloud Insider Partner'  ;
        system.debug('Value of subsdef'+subsdef);
        insert subsdef1;
        
        PRM_ContactSubscriptionAssociation__c subs1 = new PRM_ContactSubscriptionAssociation__c() ;
        // PRM_Contact_Id__c,PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c,PRM_Partner_Subscription_Id__r.PRM_Community__c,PRM_Status_Nm__c
        subs1.PRM_Contact_Id__c = con123.id  ;
        subs1.PRM_Partner_Subscription_Id__c = subsdef1.Id ;
        subs1.PRM_Status_Nm__c  = 'Active' ;
        insert subs1;
        
        con123.Core_IPA_Partner_Community__c = '';
        Core_ContactHandler.isCommunityUpdated = false;
        update con123;
        
        
        //******************  TWC729-2258 - Agate - End ************************************************************
        
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'IOT Community User';
        ent.Core_Display_Name__c = 'IOT Community User';
        ent.Core_IsActive__c = true;
        corEntitInertList.add(ent);
       
        
        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Cloud Community User';
        ent1.Core_Display_Name__c = 'Cloud Community User';
        ent1.Core_IsActive__c = true;
        corEntitInertList.add(ent1);
        
        Core_Entitlement__c ent2 = new Core_Entitlement__c();
        ent2.Name = 'FPGA Community User';
        ent2.Core_Display_Name__c = 'FPGA Community User';
        ent2.Core_IsActive__c = true;
        corEntitInertList.add(ent2);
        Test.startTest();
        if(corEntitInertList.size() > 0){
            insert corEntitInertList;
        }
        
        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.Communities__c = 'Intel® IOT Solution Partner';
        entMatrix.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix);
        
        PRM_VXEnttlmntMatrix__c entMatrix1 = new PRM_VXEnttlmntMatrix__c();
        entMatrix1.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix1.Communities__c = 'Intel® Cloud Insider Partner';
        entMatrix1.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix1);

        
        PRM_VXEnttlmntMatrix__c entMatrix2 = new PRM_VXEnttlmntMatrix__c();
        entMatrix2.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix2.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix2.Communities__c = 'Intel® FPGA Partner';
        entMatrix2.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix2);
        
          if(entMatrixInertList.size() > 0){
            insert entMatrixInertList;
        }
        List<Contact> contactUpdate = new List<Contact>();
        con.Core_IPA_Partner_Community__c = 'Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        //update con;
        contactUpdate.add(con);
        
        con123.Core_IPA_Partner_Community__c = 'Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        contactUpdate.add(con123);
        //update con123;
        

        //System.debug(con1);
        
        Core_Contact_Entitlement__c coreCon = new Core_Contact_Entitlement__c();
        coreCon.Core_Contact_Id__c = con1.id;
        coreCon.Core_Entitlement_Id__c = ent1.id;
        coreCon.Core_Status__c = 'Pending';
        insert coreCon;
        
        con1.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner'; 
        Core_ContactHandler.isCommunityUpdated = false;
        update con1;
        
        List<PRM_Partner_Community_Enrollment_Request__c> parComInsert = new List<PRM_Partner_Community_Enrollment_Request__c>();
        PRM_Partner_Community_Enrollment_Request__c parCom = new PRM_Partner_Community_Enrollment_Request__c();
        parCom.PRM_Contact_Id__c = con.id;
        parCom.PRM_Partner_Community_Nm__c='Intel® FPGA Partner';
        parCom.PRM_Status_Nm__c = 'Rejected';
        
        parComInsert.add(parCom);
        
                
        PRM_Partner_Community_Enrollment_Request__c parCom1 = new PRM_Partner_Community_Enrollment_Request__c();
        parCom1.PRM_Contact_Id__c = con2.id;
        parCom1.PRM_Partner_Community_Nm__c='Intel® Cloud Insider Partner';
        parCom1.PRM_Status_Nm__c = 'Rejected';
        
        parComInsert.add(parCom1);
        
        if(parComInsert.size()>0){
            insert parComInsert;
        }

        
        Core_Contact_Entitlement__c coreCon2 = new Core_Contact_Entitlement__c();
        coreCon2.Core_Contact_Id__c = con2.id;
        coreCon2.Core_Entitlement_Id__c = ent1.id;
        coreCon2.Core_Status__c = 'Complete';
        coreCon2.Core_Selected__c = true;
        insert coreCon2;

        
        //****************** TWC729-2258 - Agate ********************************************************************

        con123.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        update con123;
         
        //******************  TWC729-2258 - Agate - End ************************************************************
        map<id,contact> contmap=new map<id,contact>();
        contmap.put(contactsInsert[0].id,contactsInsert[0]);
        Core_ContactHandler.assignPartnerCommunityContactEntitlements(contmap,contactsInsert);
        Core_ContactHandler.createEnrollmentRequest(contactsInsert[0].id,'str','New');
        
        Test.stopTest();

    }
    @isTest
    public static void updateEnrollRequests(){
        
        // Test.startTest();
        Id intelConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();
        
        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrixInertList = new List<PRM_VXEnttlmntMatrix__c>();
        
       
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'IOT Community User';
        ent.Core_Display_Name__c = 'IOT Community User';
        ent.Core_IsActive__c = true;
        corEntitInertList.add(ent);
        
        
        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Cloud Community User';
        ent1.Core_Display_Name__c = 'Cloud Community User';
        ent1.Core_IsActive__c = true;
        corEntitInertList.add(ent1);
        
        Core_Entitlement__c ent2 = new Core_Entitlement__c();
        ent2.Name = 'FPGA Community User';
        ent2.Core_Display_Name__c = 'FPGA Community User';
        ent2.Core_IsActive__c = true;
        corEntitInertList.add(ent2);
        
       
        if(corEntitInertList.size() > 0){
        insert corEntitInertList;
        }
        
        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.Communities__c = 'Intel® IOT Solution Partner';
        entMatrix.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix);
        
        PRM_VXEnttlmntMatrix__c entMatrix1 = new PRM_VXEnttlmntMatrix__c();
        entMatrix1.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix1.Communities__c = 'Intel® Cloud Insider Partner';
        entMatrix1.PRM_Entitlement_Id__c = ent1.id;
        entMatrixInertList.add(entMatrix1);
        
        
        
        
        PRM_VXEnttlmntMatrix__c entMatrix2 = new PRM_VXEnttlmntMatrix__c();
        entMatrix2.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix2.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix2.Communities__c = 'Intel® FPGA Partner';
       entMatrix2.PRM_Entitlement_Id__c = ent2.id;
        entMatrixInertList.add(entMatrix2);
        
        if(entMatrixInertList.size() > 0){
        insert entMatrixInertList;
        }
        
        Account enrolAccount = PRM_TestUtility.getAccount();
        enrolAccount.Core_IPA_Partner_Role__c = 'Service Provider';
        enrolAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        enrolAccount.Core_Account_Type__c ='Distributor';
        enrolAccount.Industry ='';
        enrolAccount.BillingCity='Gurugram';
        enrolAccount.BillingCountry='India';
        enrolAccount.BillingStreet='5th Floor,ITPL,Brookfield';
        enrolAccount.BillingPostalCode='325829';
        insert(enrolAccount); 
        
        List<Contact> insertNewContacts = new List<Contact>();
        
        Contact enrolCon = PRM_TestUtility.getContact();
        enrolCon.AccountId=enrolAccount.Id;
        enrolCon.RecordTypeId = intelConRecordTypeId;
        enrolCon.lastName='John1';
        enrolCon.FirstName='Wing1';
        enrolCon.email='johnwing1@rediff.com';
        enrolCon.Core_Job_Function__c='Branch Manager';
        enrolCon.Core_eRPM_Language_Code__c='Eng';
        enrolCon.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon.Core_Login_Id__c = 'def';
        enrolCon.Core_Enterprise_Id__c = '234562';
        enrolCon.Core_Login_Status__c ='Active';
        
        insertNewContacts.add(enrolCon);
        
        Contact enrolCon1 = PRM_TestUtility.getContact();  //Contact
        enrolCon1.AccountId=enrolAccount.Id;
        enrolCon1.RecordTypeId = intelConRecordTypeId;
        enrolCon1.lastName='John2';
        enrolCon1.FirstName='Wing2';
        enrolCon1.email='johnwing2@rediff.com';
        enrolCon1.Core_Job_Function__c='Branch Manager';
        enrolCon1.Core_eRPM_Language_Code__c='Eng';
        enrolCon1.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon1.Core_Login_Id__c = 'def';
        enrolCon1.Core_Enterprise_Id__c = '234564';
        enrolCon1.Core_Login_Status__c ='Active';
        
        insertNewContacts.add(enrolCon1);
        
        Contact enrolCon2 = PRM_TestUtility.getContact();  //Contact
        enrolCon2.AccountId=enrolAccount.Id;
        enrolCon2.RecordTypeId = intelConRecordTypeId;
        enrolCon2.lastName='John2';
        enrolCon2.FirstName='Wing2';
        enrolCon2.email='johnwing2@rediff.com';
        enrolCon2.Core_Job_Function__c='Branch Manager';
        enrolCon2.Core_eRPM_Language_Code__c='Eng';
        enrolCon2.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon2.Core_Login_Id__c = 'def';
        enrolCon2.Core_Enterprise_Id__c = '234564';
        enrolCon2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        enrolCon2.Core_Login_Status__c ='Active';
        
        insertNewContacts.add(enrolCon2);
        
        if(insertNewContacts.size() > 0){
            insert insertNewContacts;
        }
        
        List<PRM_Partner_Community_Enrollment_Request__c> insertCommunityRequests = new list<PRM_Partner_Community_Enrollment_Request__c>();
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest1 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest1.PRM_Contact_Id__c = enrolCon.id;
        parComRequest1.PRM_Partner_Community_Nm__c='Intel® IOT Solution Partner';
        parComRequest1.PRM_Status_Nm__c = 'Rejected';
        insertCommunityRequests.add(parComRequest1);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest2 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest2.PRM_Contact_Id__c = enrolCon.id;
        parComRequest2.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner ';
        parComRequest2.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest2);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest3 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest3.PRM_Contact_Id__c = enrolCon1.id;
        parComRequest3.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner';
        parComRequest3.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest3);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest4 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest4.PRM_Contact_Id__c = enrolCon2.id;
        parComRequest4.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner';
        parComRequest4.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest4);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest5 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest5.PRM_Contact_Id__c = enrolCon2.id;
        parComRequest5.PRM_Partner_Community_Nm__c ='Intel® IOT Solution Partner';
        parComRequest5.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest5);
        
        if(insertCommunityRequests.size() > 0){
            PRM_partnerComEnrReqUtility.isTriggerExecuted = false;
            insert insertCommunityRequests;
        }
          Test.startTest();
        list<Core_Contact_Entitlement__c> conEntLst=new list<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c coreCon = new Core_Contact_Entitlement__c();
        coreCon.Core_Contact_Id__c = enrolCon.id;
        coreCon.Core_Entitlement_Id__c = ent.id;
        coreCon.Core_Selected__c = false;
        conEntLst.add(coreCon);
        // insert coreCon;
        
        Core_Contact_Entitlement__c coreCon1 = new Core_Contact_Entitlement__c();
        coreCon1.Core_Contact_Id__c = enrolCon.id;
        coreCon1.Core_Entitlement_Id__c = ent1.id;
        coreCon1.Core_Selected__c = false;
         conEntLst.add(coreCon1);
        // insert coreCon1;
        Core_Contact_Entitlement__c coreCon2 = new Core_Contact_Entitlement__c();
        coreCon2.Core_Contact_Id__c = enrolCon1.id;
        coreCon2.Core_Entitlement_Id__c = ent.id;
        coreCon2.Core_Selected__c = false;
        conEntLst.add(coreCon2);
        Core_Contact_Entitlement__c coreCon3 = new Core_Contact_Entitlement__c();
        coreCon3.Core_Contact_Id__c = enrolCon2.id;
        coreCon3.Core_Entitlement_Id__c = ent.id;
        coreCon3.Core_Selected__c = false;
        conEntLst.add(coreCon3);
        
        insert conEntLst;
      //  Test.stopTest();
      
       
        List<Contact> updateContactsList = new List<Contact>();
        enrolCon.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        updateContactsList.add(enrolCon);
        
        enrolCon1.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        updateContactsList.add(enrolCon1);
        
        enrolCon2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        updateContactsList.add(enrolCon2);
        
        if(updateContactsList.size()>0){
            update updateContactsList;
        }
         Test.stopTest();
        }
    @isTest
    public static void updateEnrollRequests1(){
        
        // Test.startTest();
        Id intelConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();
        
        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrixInertList = new List<PRM_VXEnttlmntMatrix__c>();
        
       
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'IOT Community User';
        ent.Core_Display_Name__c = 'IOT Community User';
        ent.Core_IsActive__c = true;
        corEntitInertList.add(ent);
        
        
        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Cloud Community User';
        ent1.Core_Display_Name__c = 'Cloud Community User';
        ent1.Core_IsActive__c = true;
        corEntitInertList.add(ent1);
        
        Core_Entitlement__c ent2 = new Core_Entitlement__c();
        ent2.Name = 'FPGA Community User';
        ent2.Core_Display_Name__c = 'FPGA Community User';
        ent2.Core_IsActive__c = true;
        corEntitInertList.add(ent2);
        
       
        if(corEntitInertList.size() > 0){
        insert corEntitInertList;
        }
        
        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.Communities__c = 'Intel® IOT Solution Partner';
        entMatrix.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix);
        
        PRM_VXEnttlmntMatrix__c entMatrix1 = new PRM_VXEnttlmntMatrix__c();
        entMatrix1.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix1.Communities__c = 'Intel® Cloud Insider Partner';
        entMatrix1.PRM_Entitlement_Id__c = ent1.id;
        entMatrixInertList.add(entMatrix1);
        
        
        
        
        PRM_VXEnttlmntMatrix__c entMatrix2 = new PRM_VXEnttlmntMatrix__c();
        entMatrix2.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix2.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix2.Communities__c = 'Intel® FPGA Partner';
        entMatrix2.PRM_Entitlement_Id__c = ent2.id;
        entMatrixInertList.add(entMatrix2);
        
        if(entMatrixInertList.size() > 0){
        insert entMatrixInertList;
        }
        
        Account enrolAccount = PRM_TestUtility.getAccount();
        enrolAccount.Core_IPA_Partner_Role__c = 'Service Provider';
        enrolAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        enrolAccount.Core_Account_Type__c ='Distributor';
        enrolAccount.Industry ='';
        enrolAccount.BillingCity='Gurugram';
        enrolAccount.BillingCountry='India';
        enrolAccount.BillingStreet='5th Floor,ITPL,Brookfield';
        enrolAccount.BillingPostalCode='325829';
        insert(enrolAccount); 
        
        List<Contact> insertNewContacts = new List<Contact>();
        
        Contact enrolCon = PRM_TestUtility.getContact();
        enrolCon.AccountId=enrolAccount.Id;
        enrolCon.RecordTypeId = intelConRecordTypeId;
        enrolCon.lastName='John1';
        enrolCon.FirstName='Wing1';
        enrolCon.email='johnwing1@rediff.com';
        enrolCon.Core_Job_Function__c='Branch Manager';
        enrolCon.Core_eRPM_Language_Code__c='Eng';
        enrolCon.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon.Core_Login_Id__c = 'def';
        enrolCon.Core_Enterprise_Id__c = '234562';
        enrolCon.Core_Login_Status__c ='Active';
        
        insertNewContacts.add(enrolCon);
        
        Contact enrolCon1 = PRM_TestUtility.getContact();  //Contact
        enrolCon1.AccountId=enrolAccount.Id;
        enrolCon1.RecordTypeId = intelConRecordTypeId;
        enrolCon1.lastName='John2';
        enrolCon1.FirstName='Wing2';
        enrolCon1.email='johnwing2@rediff.com';
        enrolCon1.Core_Job_Function__c='Branch Manager';
        enrolCon1.Core_eRPM_Language_Code__c='Eng';
        enrolCon1.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon1.Core_Login_Id__c = 'def';
        enrolCon1.Core_Enterprise_Id__c = '234564';
        enrolCon1.Core_Login_Status__c ='Active';
        
        insertNewContacts.add(enrolCon1);
        
        Contact enrolCon2 = PRM_TestUtility.getContact();  //Contact
        enrolCon2.AccountId=enrolAccount.Id;
        enrolCon2.RecordTypeId = intelConRecordTypeId;
        enrolCon2.lastName='John2';
        enrolCon2.FirstName='Wing2';
        enrolCon2.email='johnwing2@rediff.com';
        enrolCon2.Core_Job_Function__c='Branch Manager';
        enrolCon2.Core_eRPM_Language_Code__c='Eng';
        enrolCon2.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon2.Core_Login_Id__c = 'def';
        enrolCon2.Core_Enterprise_Id__c = '234564';
        enrolCon2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        enrolCon2.Core_Login_Status__c ='Active';
        
        insertNewContacts.add(enrolCon2);
        
        if(insertNewContacts.size() > 0){
            insert insertNewContacts;
        }
        
        List<PRM_Partner_Community_Enrollment_Request__c> insertCommunityRequests = new list<PRM_Partner_Community_Enrollment_Request__c>();
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest1 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest1.PRM_Contact_Id__c = enrolCon.id;
        parComRequest1.PRM_Partner_Community_Nm__c='Intel® IOT Solution Partner';
        parComRequest1.PRM_Status_Nm__c = 'Rejected';
        insertCommunityRequests.add(parComRequest1);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest2 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest2.PRM_Contact_Id__c = enrolCon.id;
        parComRequest2.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner ';
        parComRequest2.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest2);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest3 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest3.PRM_Contact_Id__c = enrolCon1.id;
        parComRequest3.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner';
        parComRequest3.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest3);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest4 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest4.PRM_Contact_Id__c = enrolCon2.id;
        parComRequest4.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner';
        parComRequest4.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest4);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest5 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest5.PRM_Contact_Id__c = enrolCon2.id;
        parComRequest5.PRM_Partner_Community_Nm__c ='Intel® IOT Solution Partner';
        parComRequest5.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest5);
        
        if(insertCommunityRequests.size() > 0){
            PRM_partnerComEnrReqUtility.isTriggerExecuted = false;
            insert insertCommunityRequests;
        }
          Test.startTest();
        list<Core_Contact_Entitlement__c> conEntLst=new list<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c coreCon = new Core_Contact_Entitlement__c();
        coreCon.Core_Contact_Id__c = enrolCon.id;
        coreCon.Core_Entitlement_Id__c = ent.id;
        coreCon.Core_Selected__c = false;
        conEntLst.add(coreCon);
       // insert coreCon;
        
        Core_Contact_Entitlement__c coreCon1 = new Core_Contact_Entitlement__c();
        coreCon1.Core_Contact_Id__c = enrolCon.id;
        coreCon1.Core_Entitlement_Id__c = ent1.id;
        coreCon1.Core_Selected__c = false;
         conEntLst.add(coreCon1);
       // insert coreCon1;
        
        insert conEntLst;
      //  Test.stopTest();
      List<string> updateContactsstring = new List<string>();
        updateContactsstring.add('Intel® Cloud Insider Partner');
        updateContactsstring.add('Intel® IOT Solution Partner');
       updateContactsstring.add('Intel® Cloud Insider Partner');
       
        List<Contact> updateContactsList = new List<Contact>();
        enrolCon.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        updateContactsList.add(enrolCon);
        
        enrolCon1.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        updateContactsList.add(enrolCon1);
        
        enrolCon2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        updateContactsList.add(enrolCon2);
        
        if(updateContactsList.size()>0){
            //update updateContactsList;
        }
        Map<id, List<String>> contactIdCommunitymap=new Map<id, List<String>>();
        map<id, List<PRM_Partner_Community_Enrollment_Request__c>> comEnrolReqMap=new  map<id, List<PRM_Partner_Community_Enrollment_Request__c>>();
        contactIdCommunitymap.put(enrolCon2.id,updateContactsstring);
        comEnrolReqMap.put(enrolCon2.id,insertCommunityRequests);
        Core_ContactHandler.checkCommunityRequestAvail(contactIdCommunitymap,comEnrolReqMap);
        Test.stopTest();
        }
    @isTest
    public static void updateEnrollRequests2(){
        
        // Test.startTest();
        Id intelConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();
        
        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrixInertList = new List<PRM_VXEnttlmntMatrix__c>();
        
       
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'IOT Community User';
        ent.Core_Display_Name__c = 'IOT Community User';
        ent.Core_IsActive__c = true;
        corEntitInertList.add(ent);
        
        
        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Cloud Community User';
        ent1.Core_Display_Name__c = 'Cloud Community User';
        ent1.Core_IsActive__c = true;
        corEntitInertList.add(ent1);
        
        Core_Entitlement__c ent2 = new Core_Entitlement__c();
        ent2.Name = 'FPGA Community User';
        ent2.Core_Display_Name__c = 'FPGA Community User';
        ent2.Core_IsActive__c = true;
        corEntitInertList.add(ent2);
        
       
        if(corEntitInertList.size() > 0){
        insert corEntitInertList;
        }
        
        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.Communities__c = 'Intel® IOT Solution Partner';
        entMatrix.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix);
        
        PRM_VXEnttlmntMatrix__c entMatrix1 = new PRM_VXEnttlmntMatrix__c();
        entMatrix1.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix1.Communities__c = 'Intel® Cloud Insider Partner';
        entMatrix1.PRM_Entitlement_Id__c = ent1.id;
        entMatrixInertList.add(entMatrix1);
        
        
        
        
        PRM_VXEnttlmntMatrix__c entMatrix2 = new PRM_VXEnttlmntMatrix__c();
        entMatrix2.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix2.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix2.Communities__c = 'Intel® FPGA Partner';
       entMatrix2.PRM_Entitlement_Id__c = ent2.id;
        entMatrixInertList.add(entMatrix2);
        
        if(entMatrixInertList.size() > 0){
        insert entMatrixInertList;
        }
        
        Account enrolAccount = PRM_TestUtility.getAccount();
        enrolAccount.Core_IPA_Partner_Role__c = 'Service Provider';
        enrolAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        enrolAccount.Core_Account_Type__c ='Distributor';
        enrolAccount.Industry ='';
        enrolAccount.BillingCity='Gurugram';
        enrolAccount.BillingCountry='India';
        enrolAccount.BillingStreet='5th Floor,ITPL,Brookfield';
        enrolAccount.BillingPostalCode='325829';
        insert(enrolAccount); 
        
        List<Contact> insertNewContacts = new List<Contact>();
        
        Contact enrolCon = PRM_TestUtility.getContact();
        enrolCon.AccountId=enrolAccount.Id;
        enrolCon.RecordTypeId = intelConRecordTypeId;
        enrolCon.lastName='John1';
        enrolCon.FirstName='Wing1';
        enrolCon.email='johnwing1@rediff.com';
        enrolCon.Core_Job_Function__c='Branch Manager';
        enrolCon.Core_eRPM_Language_Code__c='Eng';
        enrolCon.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon.Core_Login_Id__c = 'def';
        enrolCon.Core_Enterprise_Id__c = '234562';
        enrolCon.Core_Login_Status__c ='Active';
        
        insertNewContacts.add(enrolCon);
        
        Contact enrolCon1 = PRM_TestUtility.getContact();  //Contact
        enrolCon1.AccountId=enrolAccount.Id;
        enrolCon1.RecordTypeId = intelConRecordTypeId;
        enrolCon1.lastName='John2';
        enrolCon1.FirstName='Wing2';
        enrolCon1.email='johnwing2@rediff.com';
        enrolCon1.Core_Job_Function__c='Branch Manager';
        enrolCon1.Core_eRPM_Language_Code__c='Eng';
        enrolCon1.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon1.Core_Login_Id__c = 'def';
        enrolCon1.Core_Enterprise_Id__c = '234564';
        enrolCon1.Core_Login_Status__c ='Active';
        
        insertNewContacts.add(enrolCon1);
        
        Contact enrolCon2 = PRM_TestUtility.getContact();  //Contact
        enrolCon2.AccountId=enrolAccount.Id;
        enrolCon2.RecordTypeId = intelConRecordTypeId;
        enrolCon2.lastName='John2';
        enrolCon2.FirstName='Wing2';
        enrolCon2.email='johnwing2@rediff.com';
        enrolCon2.Core_Job_Function__c='Branch Manager';
        enrolCon2.Core_eRPM_Language_Code__c='Eng';
        enrolCon2.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon2.Core_Login_Id__c = 'def';
        enrolCon2.Core_Enterprise_Id__c = '234564';
       // enrolCon2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        enrolCon2.Core_Login_Status__c ='Active';
        enrolCon2.Core_IPA_Partner_Community__c ='';
        
        insertNewContacts.add(enrolCon2);
        
        if(insertNewContacts.size() > 0){
            insert insertNewContacts;
        }
        
        List<PRM_Partner_Community_Enrollment_Request__c> insertCommunityRequests = new list<PRM_Partner_Community_Enrollment_Request__c>();
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest1 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest1.PRM_Contact_Id__c = enrolCon.id;
        parComRequest1.PRM_Partner_Community_Nm__c='Intel® IOT Solution Partner';
        parComRequest1.PRM_Status_Nm__c = 'Rejected';
        insertCommunityRequests.add(parComRequest1);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest2 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest2.PRM_Contact_Id__c = enrolCon.id;
        parComRequest2.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner ';
        parComRequest2.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest2);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest3 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest3.PRM_Contact_Id__c = enrolCon1.id;
        parComRequest3.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner';
        parComRequest3.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest3);
        
        /*PRM_Partner_Community_Enrollment_Request__c parComRequest4 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest4.PRM_Contact_Id__c = enrolCon2.id;
        parComRequest4.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner';
        parComRequest4.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest4);
        
        PRM_Partner_Community_Enrollment_Request__c parComRequest5 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest5.PRM_Contact_Id__c = enrolCon2.id;
        parComRequest5.PRM_Partner_Community_Nm__c ='Intel® IOT Solution Partner';
        parComRequest5.PRM_Status_Nm__c = 'Approved';
insertCommunityRequests.add(parComRequest5);*/
        
        if(insertCommunityRequests.size() > 0){
            PRM_partnerComEnrReqUtility.isTriggerExecuted = false;
            insert insertCommunityRequests;
        }
          Test.startTest();
        list<Core_Contact_Entitlement__c> conEntLst=new list<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c coreCon = new Core_Contact_Entitlement__c();
        coreCon.Core_Contact_Id__c = enrolCon.id;
        coreCon.Core_Entitlement_Id__c = ent.id;
        coreCon.Core_Selected__c = false;
        conEntLst.add(coreCon);
       // insert coreCon;
        
        Core_Contact_Entitlement__c coreCon1 = new Core_Contact_Entitlement__c();
        coreCon1.Core_Contact_Id__c = enrolCon.id;
        coreCon1.Core_Entitlement_Id__c = ent1.id;
        coreCon1.Core_Selected__c = false;
         conEntLst.add(coreCon1);
       // insert coreCon1;
        
        insert conEntLst;
      //  Test.stopTest();
      List<string> updateContactsstring = new List<string>();
        /*updateContactsstring.add('Intel® Cloud Insider Partner');
        updateContactsstring.add('Intel® IOT Solution Partner');
       updateContactsstring.add('Intel® Cloud Insider Partner');*/
       
        List<Contact> updateContactsList = new List<Contact>();
        enrolCon.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        updateContactsList.add(enrolCon);
        
        enrolCon1.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        updateContactsList.add(enrolCon1);
        
        enrolCon2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        Core_ContactHandler.isCommunityUpdated = false;
        updateContactsList.add(enrolCon2);
        
        if(updateContactsList.size()>0){
            //update updateContactsList;
        }
        Map<id, List<String>> contactIdCommunitymap=new Map<id, List<String>>();
        map<id, List<PRM_Partner_Community_Enrollment_Request__c>> comEnrolReqMap=new  map<id, List<PRM_Partner_Community_Enrollment_Request__c>>();
        //contactIdCommunitymap.put(enrolCon.id,updateContactsstring);
        comEnrolReqMap.put(enrolCon.id,insertCommunityRequests);
        Core_ContactHandler.isExecuted=true;
        PRM_partnerComEnrReqUtility.requestedInitiatedByCommunity=false;
        Core_ContactHandler.checkCommunityRequestAvail(contactIdCommunitymap,comEnrolReqMap);

        /*Map<id, List<String>> contactIdCommunitymap1=new Map<id, List<String>>();
map<id, List<PRM_Partner_Community_Enrollment_Request__c>> comEnrolReqMap1=new  map<id, List<PRM_Partner_Community_Enrollment_Request__c>>();
contactIdCommunitymap1.put(enrolCon1.id,updateContactsstring);
comEnrolReqMap1.put(enrolCon1.id,insertCommunityRequests);
Core_ContactHandler.isExecuted=true;
PRM_partnerComEnrReqUtility.requestedInitiatedByCommunity=false;
Core_ContactHandler.checkCommunityRequestAvail(contactIdCommunitymap1,comEnrolReqMap1);

Map<id, List<String>> contactIdCommunitymap2=new Map<id, List<String>>();
map<id, List<PRM_Partner_Community_Enrollment_Request__c>> comEnrolReqMap2=new  map<id, List<PRM_Partner_Community_Enrollment_Request__c>>();
contactIdCommunitymap2.put(enrolCon2.id,updateContactsstring);
comEnrolReqMap2.put(enrolCon2.id,insertCommunityRequests);
Core_ContactHandler.isExecuted=true;
PRM_partnerComEnrReqUtility.requestedInitiatedByCommunity=false;
Core_ContactHandler.checkCommunityRequestAvail(contactIdCommunitymap2,comEnrolReqMap2);*/
        Test.stopTest();
    }
    @isTest
    public static void updateEnrollRequests3(){

        Test.startTest();
        Id intelConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();

        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrixInertList = new List<PRM_VXEnttlmntMatrix__c>();


        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'IOT Community User';
        ent.Core_Display_Name__c = 'IOT Community User';
        ent.Core_IsActive__c = true;
        corEntitInertList.add(ent);


        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Cloud Community User';
        ent1.Core_Display_Name__c = 'Cloud Community User';
        ent1.Core_IsActive__c = true;
        corEntitInertList.add(ent1);

        Core_Entitlement__c ent2 = new Core_Entitlement__c();
        ent2.Name = 'FPGA Community User';
        ent2.Core_Display_Name__c = 'FPGA Community User';
        ent2.Core_IsActive__c = true;
        corEntitInertList.add(ent2);


        if(corEntitInertList.size() > 0){
            insert corEntitInertList;
        }

        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.Communities__c = 'Intel® IOT Solution Partner';
        entMatrix.PRM_Entitlement_Id__c = ent.id;
        entMatrixInertList.add(entMatrix);

        PRM_VXEnttlmntMatrix__c entMatrix1 = new PRM_VXEnttlmntMatrix__c();
        entMatrix1.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix1.Communities__c = 'Intel® Cloud Insider Partner';
        entMatrix1.PRM_Entitlement_Id__c = ent1.id;
        entMatrixInertList.add(entMatrix1);




        PRM_VXEnttlmntMatrix__c entMatrix2 = new PRM_VXEnttlmntMatrix__c();
        entMatrix2.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix2.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix2.Communities__c = 'Intel® FPGA Partner';
        entMatrix2.PRM_Entitlement_Id__c = ent2.id;
        entMatrixInertList.add(entMatrix2);

        if(entMatrixInertList.size() > 0){
            insert entMatrixInertList;
        }

        Account enrolAccount = PRM_TestUtility.getAccount();
        enrolAccount.Core_IPA_Partner_Role__c = 'Service Provider';
        enrolAccount.Core_Account_Type__c ='Distributor';
        enrolAccount.Industry ='';
        enrolAccount.BillingCity='Gurugram';
        enrolAccount.BillingCountry='India';
        enrolAccount.BillingStreet='5th Floor,ITPL,Brookfield';
        enrolAccount.BillingPostalCode='325829';
        insert(enrolAccount);

        List<Contact> insertNewContacts = new List<Contact>();

        Contact enrolCon = PRM_TestUtility.getContact();
        enrolCon.AccountId=enrolAccount.Id;
        enrolCon.RecordTypeId = intelConRecordTypeId;
        enrolCon.lastName='John1';
        enrolCon.FirstName='Wing1';
        enrolCon.email='johnwing1@rediff.com';
        enrolCon.Core_Job_Function__c='Branch Manager';
        enrolCon.Core_eRPM_Language_Code__c='Eng';
        enrolCon.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon.Core_Login_Id__c = 'def';
        enrolCon.Core_Enterprise_Id__c = '234562';
        enrolCon.Core_Login_Status__c ='Active';
        enrolCon.Core_IPA_Partner_Community__c ='';

        insertNewContacts.add(enrolCon);

        Contact enrolCon1 = PRM_TestUtility.getContact();  //Contact
        enrolCon1.AccountId=enrolAccount.Id;
        enrolCon1.RecordTypeId = intelConRecordTypeId;
        enrolCon1.lastName='John2';
        enrolCon1.FirstName='Wing2';
        enrolCon1.email='johnwing2@rediff.com';
        enrolCon1.Core_Job_Function__c='Branch Manager';
        enrolCon1.Core_eRPM_Language_Code__c='Eng';
        enrolCon1.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon1.Core_Login_Id__c = 'def';
        enrolCon1.Core_Enterprise_Id__c = '234564';
        enrolCon1.Core_Login_Status__c ='Active';
        enrolCon1.Core_IPA_Partner_Community__c ='';

        insertNewContacts.add(enrolCon1);

        Contact enrolCon2 = PRM_TestUtility.getContact();  //Contact
        enrolCon2.AccountId=enrolAccount.Id;
        enrolCon2.RecordTypeId = intelConRecordTypeId;
        enrolCon2.lastName='John2';
        enrolCon2.FirstName='Wing2';
        enrolCon2.email='johnwing2@rediff.com';
        enrolCon2.Core_Job_Function__c='Branch Manager';
        enrolCon2.Core_eRPM_Language_Code__c='Eng';
        enrolCon2.Core_IPA_PartnerRole__c = 'Service Provider';
        enrolCon2.Core_Login_Id__c = 'def';
        enrolCon2.Core_Enterprise_Id__c = '234564';
        //enrolCon2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
        enrolCon2.Core_Login_Status__c ='Active';
        enrolCon2.Core_IPA_Partner_Community__c ='';

        insertNewContacts.add(enrolCon2);

        if(insertNewContacts.size() > 0){
            insert insertNewContacts;
        }
        // Test.startTest();
        List<PRM_Partner_Community_Enrollment_Request__c> insertCommunityRequests = new list<PRM_Partner_Community_Enrollment_Request__c>();

        PRM_Partner_Community_Enrollment_Request__c parComRequest1 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest1.PRM_Contact_Id__c = enrolCon.id;
        parComRequest1.PRM_Partner_Community_Nm__c='Intel® IOT Solution Partner';
        parComRequest1.PRM_Status_Nm__c = 'Rejected';
        insertCommunityRequests.add(parComRequest1);

        PRM_Partner_Community_Enrollment_Request__c parComRequest2 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest2.PRM_Contact_Id__c = enrolCon.id;
        parComRequest2.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner ';
        parComRequest2.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest2);

        PRM_Partner_Community_Enrollment_Request__c parComRequest3 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest3.PRM_Contact_Id__c = enrolCon1.id;
        parComRequest3.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner';
        parComRequest3.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest3);

        PRM_Partner_Community_Enrollment_Request__c parComRequest4 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest4.PRM_Contact_Id__c = enrolCon2.id;
        parComRequest4.PRM_Partner_Community_Nm__c ='Intel® Cloud Insider Partner';
        parComRequest4.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest4);

        PRM_Partner_Community_Enrollment_Request__c parComRequest5 = new PRM_Partner_Community_Enrollment_Request__c();
        parComRequest5.PRM_Contact_Id__c = enrolCon2.id;
        parComRequest5.PRM_Partner_Community_Nm__c ='Intel® IOT Solution Partner';
        parComRequest5.PRM_Status_Nm__c = 'Approved';
        insertCommunityRequests.add(parComRequest5);

        if(insertCommunityRequests.size() > 0){
            PRM_partnerComEnrReqUtility.isTriggerExecuted = false;
            insert insertCommunityRequests;
        }

        list<Core_Contact_Entitlement__c> conEntLst=new list<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c coreCon = new Core_Contact_Entitlement__c();
        coreCon.Core_Contact_Id__c = enrolCon.id;
        coreCon.Core_Entitlement_Id__c = ent.id;
        coreCon.Core_Selected__c = false;
        conEntLst.add(coreCon);
        //insert coreCon;

        Core_Contact_Entitlement__c coreCon1 = new Core_Contact_Entitlement__c();
        coreCon1.Core_Contact_Id__c = enrolCon.id;
        coreCon1.Core_Entitlement_Id__c = ent1.id;
        coreCon1.Core_Selected__c = false;
        conEntLst.add(coreCon1);
        // insert coreCon1;

        insert conEntLst;
        //  Test.stopTest();
        List<string> updateContactsstring = new List<string>();
        updateContactsstring.add('Intel® Cloud Insider Partner');
        updateContactsstring.add('Intel® IOT Solution Partner');
        updateContactsstring.add('Intel® Cloud Insider Partner');

        /*  List<Contact> updateContactsList = new List<Contact>();
enrolCon.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
Core_ContactHandler.isCommunityUpdated = false;
updateContactsList.add(enrolCon);

enrolCon1.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner;Intel® IOT Solution Partner';
Core_ContactHandler.isCommunityUpdated = false;
updateContactsList.add(enrolCon1);

enrolCon2.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
Core_ContactHandler.isCommunityUpdated = false;
updateContactsList.add(enrolCon2);

if(updateContactsList.size()>0){
//update updateContactsList;
}*/
        Map<id, List<String>> contactIdCommunitymap=new Map<id, List<String>>();
        map<id, List<PRM_Partner_Community_Enrollment_Request__c>> comEnrolReqMap=new  map<id, List<PRM_Partner_Community_Enrollment_Request__c>>();
        contactIdCommunitymap.put(enrolCon2.id,updateContactsstring);
        comEnrolReqMap.put(enrolCon2.id,insertCommunityRequests);
        Core_ContactHandler.isExecuted=true;
        PRM_partnerComEnrReqUtility.requestedInitiatedByCommunity=false;
        Core_ContactHandler.checkCommunityRequestAvail(contactIdCommunitymap,comEnrolReqMap);
        Test.stopTest();
        }
    //******************  TWC729-2258 - Agate -  ************************************************************
    // To increase the coverage
     
    @isTest
    public static void updateCommunity(){
        Test.startTest();
        Id intelConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();
        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrixInertList = new List<PRM_VXEnttlmntMatrix__c>();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);    
        
        Contact con123 =  PRM_TestUtility.getContact(); 
        con123.RecordTypeId = intelConRecordTypeId;
        con123.Email='testrequest123@mailinator.com';
        con123.AccountId = acc.Id;
        con123.Core_Job_Function__c='Branch Manager';
        con123.Core_eRPM_Language_Code__c='Eng';
        // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con123.Core_IPA_PartnerRole__c = 'Service Provider';
        con123.Core_Login_Id__c = 'abc';
        con123.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con123.Core_Login_Status__c ='Active';
        insert con123;
        
        //****************** TWC729-2258 - Agate ********************************************************************
        PRM_Partner_Subscription__c subsdef = new PRM_Partner_Subscription__c() ;
        subsdef.Name  = 'Intel® Cloud Insider Partner Community Communications' ;
        subsdef.PRM_Subscription_Dsc__c = 'Intel Cloud Insider Partner Community Communications' ;
        subsdef.PRM_Subscription_Cd__c = 'INTCLDCOM' ;
        subsdef.PRM_InActive_Ind__c = false ;
        subsdef.PRM_Community__c = 'Intel® Cloud Insider Partner'  ;
        system.debug('Value of subsdef'+subsdef);
        insert subsdef;  
        
        PRM_ContactSubscriptionAssociation__c subs = new PRM_ContactSubscriptionAssociation__c() ;
        // PRM_Contact_Id__c,PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c,PRM_Partner_Subscription_Id__r.PRM_Community__c,PRM_Status_Nm__c
        subs.PRM_Contact_Id__c = con123.id  ;
        subs.PRM_Partner_Subscription_Id__c = subsdef.Id ;
        subs.PRM_Status_Nm__c  = 'Active' ;
        insert subs;   
        
        PRM_Partner_Subscription__c subsdef1 = new PRM_Partner_Subscription__c() ;
        subsdef1.Name  = 'Training and Webinar Communications' ;
        subsdef1.PRM_Subscription_Dsc__c = 'Training and Webinar Communications' ;
        subsdef1.PRM_Subscription_Cd__c = 'TRAWEBCOM' ;
        subsdef1.PRM_InActive_Ind__c = false ;
        subsdef1.PRM_Community__c = 'Intel® Cloud Insider Partner'  ;
        system.debug('Value of subsdef'+subsdef);
        insert subsdef1;
        
        PRM_ContactSubscriptionAssociation__c subs1 = new PRM_ContactSubscriptionAssociation__c() ;
        // PRM_Contact_Id__c,PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Partner_Subscription_Id__r.PRM_InActive_Ind__c,PRM_Partner_Subscription_Id__r.PRM_Community__c,PRM_Status_Nm__c
        subs1.PRM_Contact_Id__c = con123.id  ;
        subs1.PRM_Partner_Subscription_Id__c = subsdef1.Id ;
        subs1.PRM_Status_Nm__c  = 'Inactive' ;
        insert subs1;
        
        con123.Core_IPA_Partner_Community__c = '';
        Core_ContactHandler.isCommunityUpdated = false;
        update con123;
           
        
        Test.stopTest();
    }
    //****************** TWC729-2258 - Agate End ********************************************************************
    
    @isTest
    public static void createEnrollmentRequestTest(){
        
        Test.startTest();
        Account acc = PRM_TestUtility.getAccount();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);    
        
        Id intelConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact con123 =  PRM_TestUtility.getContact(); 
        con123.RecordTypeId = intelConRecordTypeId;
        con123.Email='testrequest123@mailinator.com';
        con123.AccountId = acc.Id;
        con123.Core_Job_Function__c='Branch Manager';
        con123.Core_eRPM_Language_Code__c='Eng';
        // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con123.Core_IPA_PartnerRole__c = 'Service Provider';
        con123.Core_Login_Id__c = 'abc';
        con123.Core_IPA_Partner_Community__c = 'Intel® Cloud Insider Partner';
        con123.Core_Login_Status__c ='Active';
        insert con123;
        String community = 'Intel Partner Alliance';
        String Status = 'New';
        Core_ContactHandler.createEnrollmentRequest(con123.Id, community, Status);
        Test.stopTest();
    }
    
}