@isTest
public without sharing class Core_ERPMInboundMessage_ContactTest {
    @TestSetup
    public static void setCommonData(){
        Core_IntegrationTestUtility.setupAcctContactEntitlementTestData(false);
        Account acc=[Select Id, Name From Account Where Name='Test Account 0' limit 1];
        ChannelProgram cp = Core_Integ_Additional_Attributes_Test.CreateChannelProgram('Intel Partner Alliance','IPA');
        List<ChannelProgramLevel> cpl = Core_Integ_Additional_Attributes_Test.CreateChannelProgramLevel(cp.Id);
        List<PRM_AccountChannelMembership__c> accountChannelMemberships = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm = new PRM_AccountChannelMembership__c(); 
        acm.PRM_Account_Id__c=acc.Id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl[0].Id;
        acm.PRM_Partner_Role__c = 'Seller';
        accountChannelMemberships.add(acm);
        
        acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.Id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl[1].Id;
        acm.PRM_Partner_Role__c = 'Manufacturer';
        accountChannelMemberships.add(acm);

        insert accountChannelMemberships;
    }

    // Helper Method to make easy to create Message
    public static Core_Integration_Inbound_Message__c newERPMPersonMessage(String payload) {
        Core_Integration_Inbound_Message__c message=new Core_Integration_Inbound_Message__c();
        message.Core_Source_System__c='ERPM';
        message.Core_Message_Type__c='Contact';
        message.Core_Processing_Status__c = 'Pending';
        message.Core_Payload__c=payload;
        return message;
    }

    //Contact match on ERPM Person ID. Update core info on Contact record
   /* @isTest
    private static void updateMatchingContact(){
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0_new@a.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'ISA');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />',
                          '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);

        Test.startTest();
        insert integrationinboundMessage;
        Account acc=[Select Id, Name From Account Where Name='Test Account 0' limit 1];
        acc.Core_IPA_Partner_Speciality__c='Enthusiast PC Specialist;Video Specialist';
        update acc;
        Core_ERPMInboundMessage_IPAContact.accountPartnerSpecsMap=new Map<Id,Account>([SELECT Core_IPA_Partner_Speciality__c FROM Account WHERE Id =:acc.Id]);
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
    }*/

    //if Person login Id and enterprise Id is not present Update contact login status to deleted
    @isTest
    private static void UpdateMatchContactLoginstatusDeleted(){
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000010');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     '');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testEmail@gmail.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'ISA');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />',
                          '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);

        Test.startTest();
        insert integrationinboundMessage;
        Contact c = [select Id, Core_eRPM_Person_Id__c, Core_Enterprise_ID__c, Core_Identity_Status__c, Core_Login_Id__c,
                     Core_Login_Status__c, Salutation, FirstName, LastName, Email, Phone, MobilePhone, Fax,
                     MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Core_Do_Not_Contact__c,
                     Core_ERPM_Integration_Status__c
                     from Contact where Core_eRPM_Person_Id__c = '3000010' limit 1];
        c.Core_Enterprise_ID__c='1078900';
        c.Core_Login_Status__c='Active';
        c.Core_Login_Id__c='test01';
        update c;
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
        System.debug('$$$$ contact '+c);
    }

    //Exception thrown when required field is blank and failed to update contact
    @isTest
    private static void whenContactUpdatefailed(){
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              '');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'ISA');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />',
                          '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);

        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
    }
    
    //when contact not found based on email and ErpmPersonId so insert new contact
    /*@isTest
    private static void whenNewContactInsert(){
        String msg1 = TEST_ERPM_PERSON_XML;
        msg1 = msg1.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg1 = msg1.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3001000');
        msg1 = msg1.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test7');
        msg1 = msg1.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000101000');
        msg1 = msg1.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg1 = msg1.replace('REPLACE_PERSON_TITLE',              'MR');
        msg1 = msg1.replace('REPLACE_PERSON_FIRST_NAME',         'Fire');
        msg1 = msg1.replace('REPLACE_PERSON_LAST_NAME',          'Exit');
        msg1 = msg1.replace('REPLACE_PERSON_EMAIL',              'testcontact7@acct0.com');
        msg1 = msg1.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg1 = msg1.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg1 = msg1.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg1 = msg1.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg1 = msg1.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg1 = msg1.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg1 = msg1.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg1 = msg1.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg1 = msg1.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg1 = msg1.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg1 = msg1.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg1 = msg1.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1001');
        msg1 = msg1.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 1');
        msg1 = msg1.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ISA');
        msg1 = msg1.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg1 = msg1.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
        msg1 = msg1.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg1 = msg1.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg1 = msg1.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');

        Core_Integration_Inbound_Message__c integrationinboundMessageInsert=newERPMPersonMessage(msg1);

        Test.startTest();
        insert integrationinboundMessageInsert;
        Account acc=[Select Id, Name From Account Where Name='Test Account 1' limit 1];
        acc.Core_IPA_Partner_Speciality__c='Enthusiast PC Specialist;Video Specialist';
        update acc;
        Core_ERPMInboundMessage_IPAContact.accountPartnerSpecsMap=new Map<Id,Account>([SELECT Core_IPA_Partner_Speciality__c FROM Account WHERE Id =:acc.Id]);
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessageInsert);
        Test.stopTest();
    }*/

    // ERPM Delete scenario.
    @isTest
    private static void whenPersonDelete(){
        String msg = TEST_ERPM_PERSON_DELETE_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','Y');
        msg = msg.replace('REPLACE_PERSON_INACT_INDICATOR',    'Y');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>', '<enterprise-id isnull-indicator="Y"/>');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);
        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
    }

    // ERPM Soft delete scenario.
    @isTest
    private static void whenPersonSoftDelete(){

        String msg = TEST_ERPM_PERSON_DELETE_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','Y');
        msg = msg.replace('REPLACE_PERSON_INACT_INDICATOR',    'N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);
        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
    }

    // Message has email address that contains ".duplicate". Ignore the message even if there's a matching contact record.
    @isTest
    private static void whenPersonMsgContainDuplicate(){
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0.duplicate23@acct0.com');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);
        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
    }

    // No Contact match, and no Account match, but it's RDC self-reg. Create Account, then Contact.
    @isTest
    private static void WhenRDCSelfRegistration(){
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test7');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000101000');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Flexi');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Seat');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact9@acct9.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1005');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 7');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', Label.Core_RDC_Engagement_Code);
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);

        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
    }

    // No Contact match, and no Account match and not RDC self-reg.
    @isTest
    private static void WhenNoContactAndAccountMatch(){
        String msg = TEST_ERPM_PERSON_XML;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3001000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test7');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000101000');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName7');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName7');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact7@acct0.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1007');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 7');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'AE1');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'PE1');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);
        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
    }
    
    // Ignore message when not find the account based on CIM ID
    @isTest
    public static void whenNoMatchingContactAccountIdfound(){

        String msg = TEST_ERPM_PERSON_XML2;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact21_new@a.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '8888');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account Testing');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'ISA');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />',
                          '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);

        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMInboundMessage_IPAContact.erpmAcctEnggCodes.add(system.label.ERPM_EngagementCode);
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
    }

    //Updating Erpm subscription
    @isTest
    private static void whenErpmSubscriptions(){
        String msg = TEST_ERPM_PERSON_XML3;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0_new@a.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE2', 'AE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE1',  'ISA');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'PE1 Name');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_CODE2',  'PE2');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME2',  'PE2 Name');
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />',
                          '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMPersonMessage(msg);

        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMInboundMessage_ContactService.processContactMessages(integrationinboundMessage);
        Test.stopTest();
    }

    // Soft and Hard Delete based on ERPM Message//
    @isTest
    public static void whenDisablePartnerPortalUser(){
        Test.startTest();
        Core_IPS_Run_Rules_Exception_Cust_Partne__c  IPScustom=new Core_IPS_Run_Rules_Exception_Cust_Partne__c();
        IPScustom.Run_Validation_Rule__c=True;
        Insert IPScustom;
        list<string> PartnerPortallist=new list<string>();
        list<user> Partnercontact=[select id,name,ContactId from user where IsPortalEnabled=true limit 1];
        System.assertEquals(1, Partnercontact.size());
        PartnerPortallist.add(Partnercontact[0].ContactId);
        System.assertEquals(1, PartnerPortallist.size());
        Core_ERPMInboundMessage_ContactService.DisablePartnerPortalUser(PartnerPortallist);
        Test.stopTest();
    }

    private static final String TEST_ERPM_PERSON_XML = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="Y" />' +
        '</person-information>' +
        '<person-accounts>' +
        '<person-account inact-indicator="Y">' +
        '<account-number>10450334</account-number>' +
        '<cim-id isnull-indicator="N">11154430</cim-id>' +
        '<account-name>Sistemas y Servicios Erazo Cia. Ltda.</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPITP</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="ITP">' +
        '<relation-code>RELTNTRNFR</relation-code>' +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>ITP</engg-code>' +
        '<eff-tier-cd>GOLD</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">02/22/2006 12:00:00 AM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNTRNFR</relation-code>' +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE2</engg-code>' +
        '<eff-tier-cd>ACCTTIER2</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +
        '<person-engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE1</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME1</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER1</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '</engagement>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE2</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME2</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER2</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '</engagement>' +
        '</person-engagements>' +
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '</person>';

        private static final String TEST_ERPM_PERSON_DELETE_XML =
        '<person xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" inact-indicator="REPLACE_PERSON_INACT_INDICATOR" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<changed-attributes />' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '</person-information>' +
        '<person-accounts />' +
        '<person-electronic-addresses />' +
        '<person-engagements />' +
        '<person-attributes />' +
        '<person-external-systems />' +
        '<person-interests />' +
        '<person-physical-addresses />' +
        '<person-subscription />' +
        '<person-preferences />' +
        '<change-agt-id>RIALTO</change-agt-id>' +
        '<publish-timestamp>01/01/2029 12:00:01 AM</publish-timestamp>' +
        '</person>';

        private static final String TEST_ERPM_PERSON_XML2 = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="Y" />' +
        '</person-information>' +
        '<person-accounts>' +
        '<person-account inact-indicator="Y">' +
        '<account-number>10450334</account-number>' +
        '<cim-id isnull-indicator="N">11154430</cim-id>' +
        '<account-name>Sistemas y Servicios Erazo Cia. Ltda.</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPITP</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="ITP">' +
        '<relation-code>RELTNTRNFR</relation-code>' +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>ITP</engg-code>' +
        '<eff-tier-cd>GOLD</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">02/22/2006 12:00:00 AM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNTRNFR</relation-code>' +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE2</engg-code>' +
        '<eff-tier-cd>ACCTTIER2</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +
        '<person-engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE1</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME1</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER1</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '</engagement>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE2</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME2</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER2</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '</engagement>' +
        '</person-engagements>' +
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '</person>';

        private static final String TEST_ERPM_PERSON_XML3 = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="Y" />' +
        '</person-information>' +
        '<person-accounts>' +
        '<person-account inact-indicator="Y">' +
        '<account-number>10450334</account-number>' +
        '<cim-id isnull-indicator="N">11154430</cim-id>' +
        '<account-name>Sistemas y Servicios Erazo Cia. Ltda.</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPITP</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="ITP">' +
        '<relation-code>RELTNTRNFR</relation-code>' +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>ITP</engg-code>' +
        '<eff-tier-cd>GOLD</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">02/22/2006 12:00:00 AM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNTRNFR</relation-code>' +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE2</engg-code>' +
        '<eff-tier-cd>ACCTTIER2</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +
        '<person-engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE1</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME1</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER1</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '</engagement>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE2</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME2</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER2</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '</engagement>' +
        '</person-engagements>' +
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="5/26/2022 6:57:38 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="SINGLE">'+
        '<subscription engg-code="ITP" category="PRDCTUPDTS">'+
        '<subscription-code>PRDSOLCOM</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>05/26/2022 06:57:38 AM</subscription-start-datetime>'+
        '<subscription-status-datetime>05/26/2022 06:57:38 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode/>'+
        '<subscription-marketing-source-ID/>'+
        '<subscription-marketing-tactic-ID/>'+
        '</subscription>'+
        '<subscription engg-code="ISA" category="EDCTNTRNGS">'+
        '<subscription-code>TRAWEBCOM</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>05/26/2022 06:57:38 AM</subscription-start-datetime>'+
        '<subscription-status-datetime>05/26/2022 06:57:38 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode/>'+
        '<subscription-marketing-source-ID/>'+
        '<subscription-marketing-tactic-ID/>'+
        '</subscription>'+
        '</person-subscription>'+
        '</person>';
}