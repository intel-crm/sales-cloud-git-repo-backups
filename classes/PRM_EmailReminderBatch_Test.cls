/**************************************************************************************
Apex Class Name:  PRM_EmailReminderBatch_Test
Version     : 1.0 
Created Date: 15 Feb 2022
Function    : Test Class for the PRM_EmailReminder_Test
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Sayeed Javid          02/15/2022              Added UpdateJobFunction_Test()
*************************************************************************************/
@isTest
public class PRM_EmailReminderBatch_Test {
    @isTest
    public static void PRM_EmailReminderTest() {
        Account newAccount = new Account(); //Account
        newAccount.Name = 'John Rick';
        newAccount.BillingCity = 'City';
        newAccount.BillingStreet = 'Street';
        newAccount.BillingCountry = 'India';
        newAccount.BillingPostalCode = 'Postal code';
        newAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.google.com';
        newAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        insert newAccount;
        

        List<Contact> contlist = new List<Contact>();
        Contact cont = new Contact(); //Contact
        cont.AccountId = newAccount.Id;
        cont.lastName = 'Grill';
        cont.FirstName = 'Adam';
        cont.email = 'AdamGrill@rediff.com';
        cont.MailingCountry= 'INDIA';
        cont.Core_Job_Function__c = 'Branch Manager';
        cont.Core_eRPM_Language_Code__c = 'Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_IPA_Email_Verification_Date__c = date.today();
        cont.Core_Enterprise_Id__c = '23456';
        cont.Core_Preferred_Language__c = 'ENG';
        contlist.add(cont);

        Contact cont2 = new Contact(); //Contact
        cont2.AccountId = newAccount.Id;
        cont2.lastName = 'Grill1';
        cont2.FirstName = 'Adam1';
        cont2.email = 'AdamGrill@rediff11.com';
        cont2.MailingCountry= 'INDIA';
        cont2.Core_Job_Function__c = 'Branch Manager';
        cont2.Core_eRPM_Language_Code__c = 'Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'abc1111';
        cont2.Core_IPA_Email_Verification_Date__c = date.today();
        cont2.Core_Enterprise_Id__c = '12345611';
        cont2.Core_Preferred_Language__c = 'ENG';
        contlist.add(cont2);
        insert contlist;

        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Intel Partner Alliance';
        cp.PRM_programCode__c = 'IPA';
        insert cp;

        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();

        PRM_ContactRelationships__c cr1 = new PRM_ContactRelationships__c();
        cr1.Name = System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c = 'RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c = cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);

        PRM_ContactRelationships__c cr2 = new PRM_ContactRelationships__c();
        cr2.Name = System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c = 'WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c = cp.Id;
        crList.add(cr2);
        insert crList;

        ChannelProgramLevel cpl = new ChannelProgramLevel();
        cpl.Name = 'Member';
        cpl.ProgramId = cp.Id;
        insert cpl;

        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c = newAccount.id;
        acm.PRM_Status_Nm__c = 'Approved';
        acm.PRM_Channel_Program_Id__c = cp.Id;
        acm.PRM_Channel_Program_Level_Id__c = cpl.Id;
        acm.PRM_Partner_Role__c = 'Seller';
        insert acm;

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acr.PRM_InActive_Ind__c = false;
        acr.PRM_Account_Id__c = newAccount.Id;
        acr.PRM_Relationship_Id__c = crList[1].Id;
        acr.PRM_Contact_Id__c = cont.Id;
        acr.PRM_Status_Nm__c = System.label.Pending_Action;
        acr.PRM_execute_trigger__c = true;
        acr.PRM_Start_Date_Dt__c = system.today() - 2;
        acr.PRM_End_Date_Dt__c = acr.PRM_Start_Date_Dt__c + 1;
        insert acr;
       

        PRM_Account_Contact_Relationship__c acr1 = new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acr1.PRM_InActive_Ind__c = false;
        acr1.PRM_Account_Id__c = newAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[0].Id;
        acr1.PRM_Contact_Id__c = cont.Id;
        acr1.PRM_execute_trigger__c = true;
        insert acr1;

        PRM_Account_Contact_Relationship__c acr2 = new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acr2.PRM_InActive_Ind__c = false;
        acr2.PRM_Account_Id__c = newAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[1].Id;
        acr2.PRM_Contact_Id__c = cont2.Id;
        acr2.PRM_execute_trigger__c = true;
        insert acr2;

        // id, name, PRM_Subject__c  , CreatedDate, PRM_Contact__c, PRM_Contact__r.Core_IPA_Email_Verification_Date__c ,PRM_Contact__r.Core_Email_Verification_Token__c, PRM_Contact__r.Core_Password_Token__c

        PRM_EmailLog__c Emaillog1 = new PRM_EmailLog__c(); //Account Contact Relationship
        Emaillog1.Email_Template_Name__c = 'SCRUACCTADD_English';
        Emaillog1.PRM_Subject__c = system.label.Acr_Subject;
        Emaillog1.PRM_Contact__c = cont.id;
        insert Emaillog1;

        Datetime yesterday = Datetime.now().addDays(-7);
        Test.setCreatedDate(Emaillog1.Id, yesterday);

        PRM_EmailLog__c Emaillog2 = new PRM_EmailLog__c(); //Account Contact Relationship
        Emaillog2.Email_Template_Name__c = 'SCRUACCTADD_English';
        Emaillog2.PRM_Subject__c = system.label.Acr_Subject;
        Emaillog2.PRM_Contact__c = cont2.id;
        insert Emaillog2;

        Datetime yesterday1 = Datetime.now().addDays(-7);
        Test.setCreatedDate(Emaillog2.Id, yesterday);

        Test.startTest();

        PRM_EmailReminderBatch obj = new PRM_EmailReminderBatch();
        DataBase.executeBatch(obj);

        Test.stopTest();
    }

    @isTest
    public static void PRM_EmailReminderTestCidaasFalse() {
        Account newAccount = new Account(); //Account
        newAccount.Name = 'John Rick';
        newAccount.BillingCity = 'City';
        newAccount.BillingStreet = 'Street';
        newAccount.BillingCountry = 'India';
        newAccount.BillingPostalCode = 'Postal code';
        newAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.google.com';
        newAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        insert newAccount;
        

        List<Contact> contlist = new List<Contact>();
        Contact cont = new Contact(); //Contact
        cont.AccountId = newAccount.Id;
        cont.lastName = 'Grill';
        cont.FirstName = 'Adam';
        cont.email = 'AdamGrill@rediff.com';
        cont.MailingCountry= 'INDIA';
        cont.Core_Job_Function__c = 'Branch Manager';
        cont.Core_eRPM_Language_Code__c = 'Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_IPA_Email_Verification_Date__c = null;
        cont.Core_Enterprise_Id__c = '23456';
        cont.Core_Preferred_Language__c = 'ENG';
        contlist.add(cont);

        Contact cont2 = new Contact(); //Contact
        cont2.AccountId = newAccount.Id;
        cont2.lastName = 'Grill1';
        cont2.FirstName = 'Adam1';
        cont2.email = 'AdamGrill@rediff11.com';
        cont2.MailingCountry= 'INDIA';
        cont2.Core_Job_Function__c = 'Branch Manager';
        cont2.Core_eRPM_Language_Code__c = 'Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'abc1111';
        cont2.Core_IPA_Email_Verification_Date__c = System.today();
        cont2.Core_Enterprise_Id__c = '12345611';
        cont2.Core_Preferred_Language__c = 'ENG';
        contlist.add(cont2);
        insert contlist;

        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Intel Partner Alliance';
        cp.PRM_programCode__c = 'IPA';
        insert cp;

        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();

        PRM_ContactRelationships__c cr1 = new PRM_ContactRelationships__c();
        cr1.Name = System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c = 'RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c = cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);

        PRM_ContactRelationships__c cr2 = new PRM_ContactRelationships__c();
        cr2.Name = System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c = 'WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c = cp.Id;
        crList.add(cr2);
        insert crList;

        ChannelProgramLevel cpl = new ChannelProgramLevel();
        cpl.Name = 'Member';
        cpl.ProgramId = cp.Id;
        insert cpl;

        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c = newAccount.id;
        acm.PRM_Status_Nm__c = 'Approved';
        acm.PRM_Channel_Program_Id__c = cp.Id;
        acm.PRM_Channel_Program_Level_Id__c = cpl.Id;
        acm.PRM_Partner_Role__c = 'Seller';
        insert acm;

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acr.PRM_InActive_Ind__c = false;
        acr.PRM_Account_Id__c = newAccount.Id;
        acr.PRM_Relationship_Id__c = crList[1].Id;
        acr.PRM_Contact_Id__c = cont.Id;
        acr.PRM_Status_Nm__c = System.label.Pending_Action;
        acr.PRM_execute_trigger__c = true;
        acr.PRM_Start_Date_Dt__c = system.today() - 2;
        acr.PRM_End_Date_Dt__c = acr.PRM_Start_Date_Dt__c + 1;
        insert acr;
        

        PRM_Account_Contact_Relationship__c acr1 = new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acr1.PRM_InActive_Ind__c = false;
        acr1.PRM_Account_Id__c = newAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[0].Id;
        acr1.PRM_Contact_Id__c = cont.Id;
        acr1.PRM_execute_trigger__c = true;
        insert acr1;

        PRM_Account_Contact_Relationship__c acr2 = new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acr2.PRM_InActive_Ind__c = false;
        acr2.PRM_Account_Id__c = newAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[1].Id;
        acr2.PRM_Contact_Id__c = cont2.Id;
        acr2.PRM_execute_trigger__c = true;
        insert acr2;

        // id, name, PRM_Subject__c  , CreatedDate, PRM_Contact__c, PRM_Contact__r.Core_IPA_Email_Verification_Date__c ,PRM_Contact__r.Core_Email_Verification_Token__c, PRM_Contact__r.Core_Password_Token__c

        PRM_EmailLog__c Emaillog1 = new PRM_EmailLog__c(); //Account Contact Relationship
        Emaillog1.Email_Template_Name__c = 'SCRUACCTADD_English';
        Emaillog1.PRM_Subject__c = system.label.Acr_Subject;
        Emaillog1.PRM_Contact__c = cont.id;
        insert Emaillog1;

        Datetime yesterday = Datetime.now().addDays(-7);
        Test.setCreatedDate(Emaillog1.Id, yesterday);

        PRM_EmailLog__c Emaillog2 = new PRM_EmailLog__c(); //Account Contact Relationship
        Emaillog2.Email_Template_Name__c = 'SCRUACCTADD_English';
        Emaillog2.PRM_Subject__c = system.label.Acr_Subject;
        Emaillog2.PRM_Contact__c = cont2.id;
        insert Emaillog2;

        Datetime yesterday1 = Datetime.now().addDays(-7);
        Test.setCreatedDate(Emaillog2.Id, yesterday);

        Test.startTest();

        PRM_EmailReminderBatch obj = new PRM_EmailReminderBatch();
        DataBase.executeBatch(obj);

        Test.stopTest();
    }

    public static void PRM_EmailReminderTestCidaasFalse2() {
        Account newAccount = new Account(); //Account
        newAccount.Name = 'John Rick';
        newAccount.BillingCity = 'City';
        newAccount.BillingStreet = 'Street';
        newAccount.BillingCountry = 'India';
        newAccount.BillingPostalCode = 'Postal code';
        newAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.google.com';
        newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        insert newAccount;
        

        List<Contact> contlist = new List<Contact>();
        Contact cont = new Contact(); //Contact
        cont.AccountId = newAccount.Id;
        cont.lastName = 'Grill';
        cont.FirstName = 'Adam';
        cont.email = 'AdamGrill@rediff.com';
        cont.MailingCountry= 'INDIA';
        cont.Core_Job_Function__c = 'Branch Manager';
        cont.Core_eRPM_Language_Code__c = 'Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_IPA_Email_Verification_Date__c = System.today();
        cont.Core_Enterprise_Id__c = '23456';
        cont.Core_Preferred_Language__c = 'ENG';
        contlist.add(cont);

        Contact cont2 = new Contact(); //Contact
        cont2.AccountId = newAccount.Id;
        cont2.lastName = 'Grill1';
        cont2.FirstName = 'Adam1';
        cont2.email = 'AdamGrill@rediff11.com';
        cont2.MailingCountry= 'INDIA';
        cont2.Core_Job_Function__c = 'Branch Manager';
        cont2.Core_eRPM_Language_Code__c = 'Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'abc1111';
        cont2.Core_IPA_Email_Verification_Date__c = System.today();
        cont2.Core_Enterprise_Id__c = '12345611';
        cont2.Core_Preferred_Language__c = 'ENG';
        contlist.add(cont2);
        insert contlist;

        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Intel Partner Alliance';
        cp.PRM_programCode__c = 'IPA';
        insert cp;

        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();

        PRM_ContactRelationships__c cr1 = new PRM_ContactRelationships__c();
        cr1.Name = System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c = 'RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c = cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);

        PRM_ContactRelationships__c cr2 = new PRM_ContactRelationships__c();
        cr2.Name = System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c = 'WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c = cp.Id;
        crList.add(cr2);
        insert crList;

        ChannelProgramLevel cpl = new ChannelProgramLevel();
        cpl.Name = 'Member';
        cpl.ProgramId = cp.Id;
        insert cpl;

        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c = newAccount.id;
        acm.PRM_Status_Nm__c = 'Approved';
        acm.PRM_Channel_Program_Id__c = cp.Id;
        acm.PRM_Channel_Program_Level_Id__c = cpl.Id;
        acm.PRM_Partner_Role__c = 'Seller';
        insert acm;

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acr.PRM_InActive_Ind__c = false;
        acr.PRM_Account_Id__c = newAccount.Id;
        acr.PRM_Relationship_Id__c = crList[1].Id;
        acr.PRM_Contact_Id__c = cont.Id;
        acr.PRM_Status_Nm__c = System.label.Pending_Action;
        acr.PRM_execute_trigger__c = true;
        acr.PRM_Start_Date_Dt__c = system.today() - 2;
        acr.PRM_End_Date_Dt__c = acr.PRM_Start_Date_Dt__c + 1;
        insert acr;
        
        PRM_Account_Contact_Relationship__c acr1 = new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acr1.PRM_InActive_Ind__c = false;
        acr1.PRM_Account_Id__c = newAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[0].Id;
        acr1.PRM_Contact_Id__c = cont.Id;
        acr1.PRM_execute_trigger__c = true;
        insert acr1;

        PRM_Account_Contact_Relationship__c acr2 = new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acr2.PRM_InActive_Ind__c = false;
        acr2.PRM_Account_Id__c = newAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[1].Id;
        acr2.PRM_Contact_Id__c = cont2.Id;
        acr2.PRM_execute_trigger__c = true;
        insert acr2;

        // id, name, PRM_Subject__c  , CreatedDate, PRM_Contact__c, PRM_Contact__r.Core_IPA_Email_Verification_Date__c ,PRM_Contact__r.Core_Email_Verification_Token__c, PRM_Contact__r.Core_Password_Token__c

        PRM_EmailLog__c Emaillog1 = new PRM_EmailLog__c(); //Account Contact Relationship
        Emaillog1.Email_Template_Name__c = 'SCRUACCTADD_English';
        Emaillog1.PRM_Subject__c = system.label.Acr_Subject;
        Emaillog1.PRM_Contact__c = cont.id;
        insert Emaillog1;

        Datetime yesterday = Datetime.now().addDays(-7);
        Test.setCreatedDate(Emaillog1.Id, yesterday);

        PRM_EmailLog__c Emaillog2 = new PRM_EmailLog__c(); //Account Contact Relationship
        Emaillog2.Email_Template_Name__c = 'SCRUACCTADD_English';
        Emaillog2.PRM_Subject__c = system.label.Acr_Subject;
        Emaillog2.PRM_Contact__c = cont2.id;
        insert Emaillog2;

        Datetime yesterday1 = Datetime.now().addDays(-7);
        Test.setCreatedDate(Emaillog2.Id, yesterday);

        Test.startTest();

        PRM_EmailReminderBatch obj = new PRM_EmailReminderBatch();
        DataBase.executeBatch(obj);

        Test.stopTest();
    }
}