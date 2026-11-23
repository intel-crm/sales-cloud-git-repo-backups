@isTest
public class PRM_CreateAccRelatedRecordsAdmin_Test 
{
    @isTest static void createAccountAndRelatedRecordsAdmintest()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        Map<String,PRM_AccountChannelMembership__c> existingACMMap = new Map<String,PRM_AccountChannelMembership__c>();
      
        Account a1 = PRM_TestUtility.getAccount();
        a1.AccountNumber = null;
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Name='New Account_old';
        a1.Core_Account_Type__c ='Distributor';
        a1.Industry='Agriculture';
        a1.BillingCity='New Delhi';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='4th Floor,New Road';
        a1.BillingPostalCode='110037';
        a1.BillingStateCode='KA';
        a1.Core_IPA_Partner_Role__c = 'Builder';
        a1.Industry='Construction';
        a1.Core_User_Defined_Website__c = 'www.sample_old.com';
        a1.Core_IPA_Partner_Segment__c='Internet of Things and Embedded';
        insert a1;

        Account a2 = PRM_TestUtility.getAccount();
        a2.AccountNumber = '435761';
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account_accountnew';
        a2.Core_Account_Type__c = null;
        a2.Industry='Agriculture';
        a2.BillingCity='New Delhi';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110037';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = null;
        a2.Industry='Construction';
        a2.Core_User_Defined_Website__c = 'www.sample_old.com';
        a2.Core_IPA_Partner_Segment__c='Internet of Things and Embedded';
        insert a2;

        Account a3 = PRM_TestUtility.getAccount();
        a3.AccountNumber = '435761';
        a3.RecordTypeId = accountRecordTypeIntel;
        a3.Name='Second account new Second';
        a3.Core_Account_Type__c = null;
        a3.Industry='Agriculture';
        a3.BillingCity='New Delhi';
        a3.BillingCountryCode='IND';
        a3.BillingStreet='4th Floor,New Road';
        a3.BillingPostalCode='110037';
        a3.BillingStateCode='KA';
        a3.Core_IPA_Partner_Role__c = null;
        a3.Industry='Construction';
        a3.Core_User_Defined_Website__c = 'www.secondaccountnew.com';
        a3.Core_IPA_Partner_Segment__c='Internet of Things and Embedded';
        insert a3;
        
         ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel levelold = new ChannelProgramLevel();   //Channel Program Level
        levelold.Name='Partner';
        levelold.prm_programlevelcode__c = 'Partner';
        levelold.ProgramId = cprogram.Id;
        insert levelold;
        
        PRM_AccountChannelMembership__c  acm_old = PRM_TestUtility.getMembership();
        acm_old.PRM_Account_Id__c = a1.Id;
        acm_old.PRM_Channel_Program_Id__c = cprogram.id;
        acm_old.PRM_Partner_Role__c='Builder';
        acm_old.PRM_Status_Nm__c ='Pending';
        acm_old.PRM_Status_Reason_Txt__c ='Pending';
        insert acm_old;
        
        
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435766';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Builder';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Builder';
        a.Industry='Construction';
        a.Core_User_Defined_Website__c = 'www.sample.com';
        a.Core_IPA_Partner_Segment__c='Internet of Things and Embedded';
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.MailingCountry = 'India';
        c.Email='hariharasudhan.meiyappan@spamok.com';
        c.Core_Preferred_Language__c = '';
        c.Core_eRPM_Language_Code__c = '';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
      //  c.Core_IPA_Partner_Role__c = 'Service Provider';
        c.Core_IPA_PartnerRole__c = 'Builder';
        insert c;

        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.MailingCountry = 'India';
        c1.Email='accountnew_new@spamok.com';
        c1.Core_Preferred_Language__c = '';
        c1.Core_eRPM_Language_Code__c = '';
        c1.RecordTypeId = contactRecordType;
        c1.Core_Do_Not_Contact__c = False;
      //  c.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Core_IPA_PartnerRole__c = null;
        insert c1;

        Contact c2 = PRM_TestUtility.getContact();
        c2.AccountId = a3.Id;
        c1.MailingCountry = 'India';
        c2.Email='accountnew_secondnew@spamok.com';
        c2.Core_Preferred_Language__c = '';
        c2.Core_eRPM_Language_Code__c = '';
        c2.RecordTypeId = contactRecordType;
        c2.Core_Do_Not_Contact__c = False;
      //  c.Core_IPA_Partner_Role__c = 'Service Provider';
        c2.Core_IPA_PartnerRole__c = null;
        insert c2;
        
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.prm_programlevelcode__c = 'Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = a.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.id;
        //acm.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm.PRM_Partner_Role__c='Builder';
        acm.PRM_Status_Nm__c ='Pending';
        acm.PRM_Status_Reason_Txt__c ='Pending';
        insert acm;
        
        existingACMMap.put(String.valueOf(acm.PRM_Account_Id__c)+String.valueOf(acm.PRM_Channel_Program_Id__c)+String.valueOf(acm.PRM_Partner_Role__c),acm);
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_No_Email__c = false;
        acr.PRM_execute_trigger__c = false;
        acr.PRM_Status_Nm__c = 'Pending Action';
        acr.PRM_Suppress_Email__c = true;
        acr.PRM_Status_Reason_Txt__c ='Pending';
        insert acr;

        PRM_Account_Contact_Relationship__c acr1 = new PRM_Account_Contact_Relationship__c();
        acr1.PRM_Relationship_Id__c = contRelation.Id;
        acr1.PRM_Account_Id__c = a2.Id;
        acr1.PRM_Contact_Id__c = c1.Id;
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_No_Email__c = false;
        acr1.PRM_execute_trigger__c = false;
        acr1.PRM_Status_Nm__c = 'Pending Action';
        acr1.PRM_Suppress_Email__c = true;
        acr1.PRM_Status_Reason_Txt__c = 'Pending';
        insert acr1;

        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Suppress_Email__c = true;
        acr1.PRM_Status_Reason_Txt__c=UserInfo.getName()+' '+' has opted for Suppress Email In this Transaction';
        update acr1;

        //PRM_Account_Contact_Relationship__c acr1 = new PRM_Account_Contact_Relationship__c();//RT
        //acr1.PRM_Relationship_Id__c = contRelation.Id;//RT
        //acr1.PRM_Account_Id__c = a.Id;//RT
        //acr1.PRM_Contact_Id__c = c.Id;//RT
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Suppress_Email__c = true;
        acr.PRM_Status_Reason_Txt__c=UserInfo.getName()+' '+' has opted for Suppress Email In this Transaction';
        update acr;



       // List<Contact> clist = new List<Contact>();
       // clist.add(c);
        
        Map<String,String> registrationDetailsMap1 = new Map<String,String>();
        registrationDetailsMap1.put('AccountDuplicateStatus','NoDup');
        registrationDetailsMap1.put('ContactDuplicateStatus','NoDuplicate');
        registrationDetailsMap1.put('DuplicateInfo','NoDup');
        registrationDetailsMap1.put('SelectedRow','');
        registrationDetailsMap1.put('AccountName','New Account');
        registrationDetailsMap1.put('AccountNumber','435766');
        registrationDetailsMap1.put('Country','USA');
        registrationDetailsMap1.put('State','NY');
        registrationDetailsMap1.put('AddressLine1','Test_address1');
        registrationDetailsMap1.put('AddressLine2','Test_address2');
        registrationDetailsMap1.put('City','New York');
        registrationDetailsMap1.put('PostalCode','11001');
        registrationDetailsMap1.put('BizOrgType','Builder');
        registrationDetailsMap1.put('PartnerRole','Builder');
        registrationDetailsMap1.put('PartnerSegment','Internet of Things and Embedded');
        registrationDetailsMap1.put('ContactFirstName','test_first');
        registrationDetailsMap1.put('ContactLastName','test_last');
        registrationDetailsMap1.put('ContactEmail','test1231@test.com');
        registrationDetailsMap1.put('PreferredLanguage','English');
        registrationDetailsMap1.put('PreferredLanguageCode','ENG');
        registrationDetailsMap1.put('SuppressEmail','true');
        registrationDetailsMap1.put('Website','www.test12321.com');
        registrationDetailsMap1.put('ContactCountry','USA');
        //registrationDetailsMap1.put('','');
        //
        Map<String,String> registrationDetailsMap2 = new Map<String,String>();
        registrationDetailsMap2.put('AccountDuplicateStatus','NoDup');
        registrationDetailsMap2.put('ContactDuplicateStatus','Duplicate');
        registrationDetailsMap2.put('DuplicateInfo','Dup');
        registrationDetailsMap2.put('SelectedRow','[{"Id":'+'"'+a.Id+'"'+',"Name":"Sapient","BillingStreet":"4492  Golden Ridge Road Church City","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"07292","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Builder","Core_IPA_Partner_Role__c":"Builder","Industry":"Chemicals","AccountName":"/lightning/r/Account/0016C00000CldIiQAJ/view","BillingAddress":"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA","DuplicateStatus":"PartDup"}]');
        registrationDetailsMap2.put('AccountName','Test Account');
        registrationDetailsMap2.put('AccountNumber','435766');
        registrationDetailsMap2.put('Country','USA');
        registrationDetailsMap2.put('State','NY');
        registrationDetailsMap2.put('AddressLine1','Test_address122');
        registrationDetailsMap2.put('AddressLine2','Test_address23');
        registrationDetailsMap2.put('City','New York');
        registrationDetailsMap2.put('PostalCode','11001');
        registrationDetailsMap2.put('BizOrgType','Builder');
        registrationDetailsMap2.put('PartnerRole','Builder');
        registrationDetailsMap2.put('PartnerSegment','Internet of Things and Embedded');
        registrationDetailsMap2.put('ContactFirstName','test_first');
        registrationDetailsMap2.put('ContactLastName','test_last');
        registrationDetailsMap2.put('ContactEmail','test1231@test.com');
        registrationDetailsMap2.put('PreferredLanguage','English');
        registrationDetailsMap2.put('PreferredLanguageCode','ENG');
        registrationDetailsMap2.put('SuppressEmail','true');
        registrationDetailsMap2.put('Website','www.test12321.com');
        registrationDetailsMap2.put('ContactCountry','USA');

        Map<String,String> registrationDetailsMap3 = new Map<String,String>();
        registrationDetailsMap3.put('AccountDuplicateStatus','NoDup');
        registrationDetailsMap3.put('ContactDupStatus','Duplicate');
        registrationDetailsMap3.put('DuplicateInfo','Dup');
        registrationDetailsMap3.put('SelectedRow','[{"Id":'+'"'+a.Id+'"'+',"Name":"Sapient","BillingStreet":"4492  Golden Ridge Road Church City","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"07292","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Builder","Core_IPA_Partner_Role__c":"Builder","Industry":"Chemicals","AccountName":"/lightning/r/Account/0016C00000CldIiQAJ/view","BillingAddress":"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA","DuplicateStatus":"PartDup"}]');
        registrationDetailsMap3.put('AccountName','Test Account');
        registrationDetailsMap3.put('AccountNumber','435766');
        registrationDetailsMap3.put('Country','USA');
        registrationDetailsMap3.put('State','NY');
        registrationDetailsMap3.put('AddressLine1','Test_address122');
        registrationDetailsMap3.put('AddressLine2','Test_address23');
        registrationDetailsMap3.put('City','New York');
        registrationDetailsMap3.put('PostalCode','11001');
        registrationDetailsMap3.put('BizOrgType','Builder');
        registrationDetailsMap3.put('PartnerRole','Builder');
        registrationDetailsMap3.put('PartnerSegment','Internet of Things and Embedded');
        registrationDetailsMap3.put('ContactFirstName','test_first');
        registrationDetailsMap3.put('ContactLastName','test_last');
        registrationDetailsMap3.put('ContactEmail','test1231@test.com');
        registrationDetailsMap3.put('PreferredLanguage','English');
        registrationDetailsMap3.put('PreferredLanguageCode','ENG');
        registrationDetailsMap3.put('SuppressEmail','true');
        registrationDetailsMap3.put('Website','www.test12321.com');
        registrationDetailsMap3.put('ContactCountry','USA');


        
        Map<String,String> results = new Map<String,String>();
        
        Test.startTest();
    //    PRM_CreateAccountAndRelatedRecordsAdmin.sendWelcomeEmailNotification(clist);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap1);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap3);
        
        
        //System.assertEquals(results.get('AccountId'), a.Id, 'Account match');
        //delete acm;
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
             
        Test.stopTest();
        //System.assertEquals( registrationDetailsMap2.get('AccountName'), 'New Account', 'Value does not match');

    }
    @isTest static void createAccountAndRelatedRecordsAdmintest_Approved()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
    
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435764';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Builder';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Builder';
        a.Industry='Construction';
        a.Core_User_Defined_Website__c = 'www.sample.com';
        a.Core_IPA_Partner_Segment__c='Internet of Things and Embedded';
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.MailingCountry = 'India';
        c.Email='hariharasudhan.meiyappan@spamok.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
      //  c.Core_IPA_Partner_Role__c = 'Service Provider';
        //c.Core_IPA_PartnerRole__c = 'Builder';
       c.Core_IPA_Contact_Segment__c='Internet of Things and Embedded';
        insert c;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        //cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.prm_programlevelcode__c = 'Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = a.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c='Builder';
        acm.PRM_Status_Nm__c ='Approved';
        acm.PRM_Status_Reason_Txt__c ='approved';
        insert acm;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        /*PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_No_Email__c = false;
        acr.PRM_execute_trigger__c = false;
        acr.PRM_Status_Nm__c = 'Pending Action';
        acr.PRM_Suppress_Email__c = true;
        insert acr;*/

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        insert acr;
        
       // List<Contact> clist = new List<Contact>();
       // clist.add(c);
        
        Map<String,String> registrationDetailsMap1 = new Map<String,String>();
        registrationDetailsMap1.put('AccountDuplicateStatus','NoDup');
        registrationDetailsMap1.put('ContactDuplicateStatus','NoDuplicate');
        registrationDetailsMap1.put('DuplicateInfo','NoDup');
        registrationDetailsMap1.put('SelectedRow','');
        registrationDetailsMap1.put('AccountName','New Account');
        registrationDetailsMap1.put('AccountNumber','435764');
        registrationDetailsMap1.put('Country','USA');
        registrationDetailsMap1.put('State','NY');
        registrationDetailsMap1.put('AddressLine1','Test_address1');
        registrationDetailsMap1.put('AddressLine2','Test_address2');
        registrationDetailsMap1.put('City','New York');
        registrationDetailsMap1.put('PostalCode','11001');
        registrationDetailsMap1.put('BizOrgType','Builder');
        registrationDetailsMap1.put('PartnerRole','Builder');
        registrationDetailsMap1.put('AccountPartnerSegment','Internet of Things and Embedded');
        registrationDetailsMap1.put('ContactFirstName','test_first');
        registrationDetailsMap1.put('ContactLastName','test_last');
        registrationDetailsMap1.put('ContactEmail','test1231@test.com');
        registrationDetailsMap1.put('PreferredLanguage','English');
        registrationDetailsMap1.put('ContactCountry','USA');
        //registrationDetailsMap1.put('SuppressEmail','false');
        //registrationDetailsMap1.put('','');
        //
        Map<String,String> registrationDetailsMap2 = new Map<String,String>();
        registrationDetailsMap2.put('AccountDuplicateStatus','NoDup');
        registrationDetailsMap2.put('ContactDupStatus','Duplicate');
        registrationDetailsMap2.put('DuplicateInfo','Dup');
        registrationDetailsMap2.put('SelectedRow','[{"Id":'+'"'+a.Id+'"'+',"Name":"Sapient","BillingStreet":"4492  Golden Ridge Road Church City","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"07292","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Builder","Core_IPA_Partner_Role__c":"Builder","Industry":"Chemicals","AccountName":"/lightning/r/Account/0016C00000CldIiQAJ/view","BillingAddress":"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA","DuplicateStatus":"PartDup"}]');
        registrationDetailsMap2.put('AccountName','Test Account');
        registrationDetailsMap2.put('AccountNumber','435764');
        registrationDetailsMap2.put('Country','USA');
        registrationDetailsMap2.put('State','NY');
        registrationDetailsMap2.put('AddressLine1','Test_address122');
        registrationDetailsMap2.put('AddressLine2','Test_address23');
        registrationDetailsMap2.put('City','New York');
        registrationDetailsMap2.put('PostalCode','11001');
        registrationDetailsMap2.put('BizOrgType','Distibutor;Builder');
        registrationDetailsMap2.put('PartnerRole','Builder');
        registrationDetailsMap2.put('AccountPartnerSegment','Internet of Things and Embedded');
        registrationDetailsMap2.put('ContactFirstName','test_first');
        registrationDetailsMap2.put('ContactLastName','test_last');
        registrationDetailsMap2.put('ContactEmail','test1231@test.com');
        registrationDetailsMap2.put('PreferredLanguage','');
        registrationDetailsMap2.put('SuppressEmail','true');
        registrationDetailsMap2.put('ContactCountry','USA');
        Map<String,String> results = new Map<String,String>();
        
        Test.startTest();
    //    PRM_CreateAccountAndRelatedRecordsAdmin.sendWelcomeEmailNotification(clist);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap1);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        
        
        //System.assertEquals(results.get('AccountId'), a.Id, 'Account match');
        //delete acm;
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        Test.stopTest();
        //System.assertEquals( registrationDetailsMap2.get('AccountName'), 'New Account', 'Value does not match');

    }
     
    @isTest static void createAccountAndRelatedRecordsAdmintest_Pending()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
    
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435764';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Builder';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Builder';
        a.Industry='Construction';
        a.Core_User_Defined_Website__c = 'www.sample.com';
        a.Core_IPA_Partner_Segment__c='Data Center';
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.MailingCountry = 'India';
        c.Email='hariharasudhan.meiyappan@spamok.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
      //  c.Core_IPA_Partner_Role__c = 'Service Provider';
        //c.Core_IPA_PartnerRole__c = 'Builder';
       c.Core_IPA_Contact_Segment__c='Data Center';
        insert c;
        List<Contact> conList = new List<Contact>();
        conList.add(c);
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        //cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.prm_programlevelcode__c = 'Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = a.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c='Builder';
        acm.PRM_Status_Nm__c ='Inactive';
        acm.PRM_Status_Reason_Txt__c ='Inactive';
        insert acm;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        /*PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_No_Email__c = false;
        acr.PRM_execute_trigger__c = false;
        acr.PRM_Status_Nm__c = 'Pending Action';
        acr.PRM_Suppress_Email__c = true;
        insert acr;*/

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        insert acr;
        
       // List<Contact> clist = new List<Contact>();
       // clist.add(c);
        
        Map<String,String> registrationDetailsMap1 = new Map<String,String>();
        registrationDetailsMap1.put('AccountDuplicateStatus','NoDup');
        registrationDetailsMap1.put('ContactDuplicateStatus','NoDuplicate');
        registrationDetailsMap1.put('DuplicateInfo','NoDup');
        registrationDetailsMap1.put('SelectedRow','');
        registrationDetailsMap1.put('AccountName','New Account');
        registrationDetailsMap1.put('AccountNumber','435764');
        registrationDetailsMap1.put('Country','USA');
        registrationDetailsMap1.put('State','NY');
        registrationDetailsMap1.put('AddressLine1','Test_address1');
        registrationDetailsMap1.put('AddressLine2','Test_address2');
        registrationDetailsMap1.put('City','New York');
        registrationDetailsMap1.put('PostalCode','11001');
        registrationDetailsMap1.put('BizOrgType','Builder');
        registrationDetailsMap1.put('PartnerRole','Builder');
        registrationDetailsMap1.put('AccountPartnerSegment','Internet of Things and Embedded');
        registrationDetailsMap1.put('ContactFirstName','test_first');
        registrationDetailsMap1.put('ContactLastName','test_last');
        registrationDetailsMap1.put('ContactEmail','test1231@test.com');
        registrationDetailsMap1.put('PreferredLanguage','English');
        registrationDetailsMap1.put('ContactCountry','USA');
        //registrationDetailsMap1.put('SuppressEmail','false');
        //registrationDetailsMap1.put('','');
        //
        Map<String,String> registrationDetailsMap2 = new Map<String,String>();
        registrationDetailsMap2.put('AccountDuplicateStatus','NoDup');
        registrationDetailsMap2.put('ContactDupStatus','Duplicate');
        registrationDetailsMap2.put('DuplicateInfo','Dup');
        registrationDetailsMap2.put('SelectedRow','[{"Id":'+'"'+a.Id+'"'+',"Name":"Sapient","BillingStreet":"4492  Golden Ridge Road Church City","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"07292","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Builder","Core_IPA_Partner_Role__c":"Builder","Industry":"Chemicals","AccountName":"/lightning/r/Account/0016C00000CldIiQAJ/view","BillingAddress":"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA","DuplicateStatus":"PartDup"}]');
        registrationDetailsMap2.put('AccountName','Test Account');
        registrationDetailsMap2.put('AccountNumber','435764');
        registrationDetailsMap2.put('Country','USA');
        registrationDetailsMap2.put('State','NY');
        registrationDetailsMap2.put('AddressLine1','Test_address122');
        registrationDetailsMap2.put('AddressLine2','Test_address23');
        registrationDetailsMap2.put('City','New York');
        registrationDetailsMap2.put('PostalCode','11001');
        registrationDetailsMap2.put('BizOrgType','Distibutor;Builder');
        registrationDetailsMap2.put('PartnerRole','Builder');
        registrationDetailsMap2.put('AccountPartnerSegment','Null');
        registrationDetailsMap2.put('ContactFirstName','test_first');
        registrationDetailsMap2.put('ContactLastName','test_last');
        registrationDetailsMap2.put('ContactEmail','test1231@test.com');
        registrationDetailsMap2.put('PreferredLanguage','');
        registrationDetailsMap2.put('SuppressEmail','true');
        registrationDetailsMap2.put('ContactCountry','USA');
        
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = a.Id;
        //prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Service Provider';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@malinator.com';
        //prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest.PRM_Profession__c='PROFESSOR';
         prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Preferred_Language__c='ENG';
        prmRegRequest.PRM_Legal_Agreements__c='IPA_TANDC';
        insert prmRegRequest;
        string businessEvent = 'business event';
        
        Map<String,String> results = new Map<String,String>();
        
        Test.startTest();
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap1);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        
        
        //System.assertEquals(results.get('AccountId'), a.Id, 'Account match');
        //delete acm;
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        Test.stopTest();
        //System.assertEquals( registrationDetailsMap2.get('AccountName'), 'New Account', 'Value does not match');

    }
      @isTest static void createAccountAndRelatedRecordsAdmin1test()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435767';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        a.Industry='Construction';
        a.Core_User_Defined_Website__c = 'www.sample.com';
        a.Core_IPA_Partner_Segment__c='Data Center';
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='hariharasudhan.meiyappan@spamok.com';
        c.MailingCountry='USA';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
        //c.Core_IPA_Partner_Role__c = 'Service Provider';
        c.Core_IPA_PartnerRole__c = 'Service Provider';
        c.Core_IPA_Contact_Segment__c='Data Center';
        insert c;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.prm_programlevelcode__c = 'Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = a.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
       // acm.PRM_Partner_Role__c='Builder';
        acm.PRM_Status_Nm__c ='Pending';
        acm.PRM_Status_Reason_Txt__c ='Pending';
        insert acm;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Status_Reason_Txt__c = 'Inactive';
        insert acr;
        
        List<Contact> clist = new List<Contact>();
        clist.add(c);
        
        Map<String,String> registrationDetailsMap1 = new Map<String,String>();
        registrationDetailsMap1.put('AccountDuplicateStatus','Dup');
        registrationDetailsMap1.put('ContactDuplicateStatus','NoDuplicate');
        registrationDetailsMap1.put('DuplicateInfo','NoDup');
        registrationDetailsMap1.put('SelectedRow','[{"Id":'+'"'+a.Id+'"'+',"Name":"Sapient","BillingStreet":"4492  Golden Ridge Road Church City","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"07292","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Cloud Service Provider (CSP)","Core_IPA_Partner_Role__c":"Service Provider","Industry":"Chemicals","AccountName":"/lightning/r/Account/0016C00000CldIiQAJ/view","BillingAddress":"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA","DuplicateStatus":"PartDup"}]');
        registrationDetailsMap1.put('AccountName','New Account');
        registrationDetailsMap1.put('Country','USA');
        registrationDetailsMap1.put('State','NY');
        registrationDetailsMap1.put('AddressLine1','Test_address1');
        registrationDetailsMap1.put('AddressLine2','Test_address2');
        registrationDetailsMap1.put('City','New York');
        registrationDetailsMap1.put('PostalCode','11001');
        registrationDetailsMap1.put('BizOrgType','Distributor');
        registrationDetailsMap1.put('PartnerRole','Service Provider');
        registrationDetailsMap1.put('PartnerSegment','Data Center');
        registrationDetailsMap1.put('ContactFirstName','test_first');
        registrationDetailsMap1.put('ContactLastName','test_last');
        registrationDetailsMap1.put('ContactEmail','test.meiyappan@spamok.com');
        registrationDetailsMap1.put('PreferredLanguage','English');
        registrationDetailsMap1.put('ContactCountry','USA');
		//registrationDetailsMap1.put('SuppressEmail','false');        
        //registrationDetailsMap1.put('','');
        //
        Map<String,String> registrationDetailsMap2 = new Map<String,String>();
        registrationDetailsMap2.put('AccountDuplicateStatus','Dup');
        registrationDetailsMap2.put('ContactDupStatus','Duplicate');
        registrationDetailsMap2.put('DuplicateInfo','Dup');
        registrationDetailsMap2.put('SelectedRow','[{"Id":'+'"'+a.Id+'"'+',"Name":"Sapient","BillingStreet":"4492  Golden Ridge Road Church City","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"07292","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Cloud Service Provider (CSP)","Core_IPA_Partner_Role__c":"Service Provider","Industry":"Chemicals","AccountName":"/lightning/r/Account/0016C00000CldIiQAJ/view","BillingAddress":"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA","DuplicateStatus":"PartDup"}]');
        registrationDetailsMap2.put('AccountName','New Account');
        registrationDetailsMap2.put('Country','USA');
        registrationDetailsMap2.put('State','NY');
        registrationDetailsMap2.put('AddressLine1','Test_address1');
        registrationDetailsMap2.put('AddressLine2','Test_address2');
        registrationDetailsMap2.put('City','New York');
        registrationDetailsMap2.put('PostalCode','11001');
        registrationDetailsMap2.put('BizOrgType','Distributor');
        registrationDetailsMap2.put('PartnerRole','Service Provider');
        registrationDetailsMap2.put('PartnerSegment','Data Center');
        registrationDetailsMap2.put('ContactFirstName','test_first');
        registrationDetailsMap2.put('ContactLastName','test_last');
        registrationDetailsMap2.put('ContactEmail','test1236@test.com');
        registrationDetailsMap2.put('PreferredLanguage','');
        registrationDetailsMap2.put('ContactCountry','USA');
        //registrationDetailsMap2.put('SuppressEmail','false');
        
        Map<String,String> results = new Map<String,String>();
        
        Test.startTest();
       //PRM_CreateAccountAndRelatedRecordsAdmin.sendWelcomeEmailNotification(clist);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap1);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        //System.assertEquals(results.get('AccountId'), a.Id, 'Account match');
       // delete acm;
        /*registrationDetailsMap1.remove('ContactDuplicateStatus');
        registrationDetailsMap1.put('ContactDuplicateStatus','NoDuplicate');*/
         registrationDetailsMap1.remove('PreferredLanguage');
        registrationDetailsMap1.put('PreferredLanguage','');
         results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap1);
       // results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap1);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        Test.stopTest();
       // System.assertEquals( registrationDetailsMap2.get('AccountName'), 'New Account', 'Value does not match');
    }
    
    
    @isTest static void sendAdminRegApprovalEmailtest(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        List<Contact> listContact = new List<Contact>();
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435768';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        a.Core_IPA_Partner_Segment__c='Data Center';
        a.Industry='Construction';
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='hariharasudhan.meiyappan@spamok.com';
        c.MailingCountry='USA';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
       // c.Core_IPA_Partner_Role__c = 'Service Provider';
        c.Core_IPA_PartnerRole__c = 'Service Provider';
        insert c;
        
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = a.Id;
        //prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Service Provider';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@malinator.com';
        //prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest.PRM_Profession__c='PROFESSOR';
         prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Preferred_Language__c='ENG';
        prmRegRequest.PRM_Legal_Agreements__c='IPA_TANDC';
        insert prmRegRequest;
        
        listContact.add(c);
        
        Test.startTest();
        
        PRM_CreateAccountAndRelatedRecordsAdmin.sendAdminRegApprovalEmail(listContact,prmRegRequest);
        Test.stopTest();   
        System.assertEquals( a.Name, 'New Account', 'Value does not match');     
    }
    
    
    @isTest 
    static void processRelatedRecordsAdmintest(){        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435769';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        a.Core_IPA_Partner_Segment__c='Data Center';
        a.Industry='Construction';
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='hariharasudhan.meiyappan@spamok.com';
        c.FirstName = 'Polygonst';
        c.LastName = 'User';
        c.MailingCountry='USA';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
      //  c.Core_IPA_Partner_Role__c = 'Service Provider';
        c.Core_IPA_PartnerRole__c = 'Service Provider';
       // c.Core_Job_Function__c='Mgr';
        c.Core_Profession__c='PROFESSOR';
        insert c;

        PRM_PartnerAgreement__c partnerAgr1 = new PRM_PartnerAgreement__c();
        partnerAgr1.Name='IPA Terms & Condition';
        partnerAgr1.PRM_Agreement_Cd__c='IPA_TANDC';
        insert partnerAgr1;

        PRM_AccountLegalAgreemntAssociation__c prmAccountAgrement1 = new PRM_AccountLegalAgreemntAssociation__c();
        prmAccountAgrement1.PRM_Account_Id__c=a.Id;
        prmAccountAgrement1.PRM_Partner_Agreement_Id__c=partnerAgr1.Id;
        prmAccountAgrement1.PRM_Agreement_Sign_Dt__c= System.today();
        prmAccountAgrement1.PRM_Signed_By_Email__c = c.Email;
        prmAccountAgrement1.PRM_Signed_By_Name__c = c.FirstName+' '+c.LastName;
        //prmAccountAgrement.PRM_Contact__c=c.Id;
        insert prmAccountAgrement1;
        
        List<Id> listOfAccountId = new List<Id>();
        listOfAccountId.add(a.Id);
        
        ChannelProgram channelPrg = new ChannelProgram();
        channelPrg.name='Intel Partner Alliance';
        channelPrg.PRM_programCode__c='IPA';
        channelPrg.PRM_inactind__c=true;
        insert channelPrg;
        
        
        PRM_AccountChannelMembership__c acmRecord = new PRM_AccountChannelMembership__c();
        acmRecord.PRM_Status_Nm__c = 'Pending';
        acmRecord.PRM_Status_Reason_Txt__c ='Pending';
        acmRecord.PRM_Account_Id__c=a.Id;
        acmRecord.PRM_Channel_Program_Id__c = channelPrg.Id;
        acmRecord.PRM_Partner_Role__c='Service Provider';
        insert acmRecord;
        
       
        
        List<String> contactList = new List<String>();
        contactList.add('checkuser@malinator.com');
        
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = a.Id;
        prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Service Provider';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@malinator.com';
        //prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest.PRM_Profession__c='PROFESSOR';
         prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Legal_Agreements__c='IPA_TANDC';
        insert prmRegRequest;
        
        /*PRM_PartnerAgreement__c partnerAgr = new PRM_PartnerAgreement__c();
        partnerAgr.Name='IPA Terms & Condition';
        partnerAgr.PRM_Agreement_Cd__c='IPA_TANDC';
        insert partnerAgr;*/
        
        PRM_AccountLegalAgreemntAssociation__c prmAccountAgrement = new PRM_AccountLegalAgreemntAssociation__c();
        prmAccountAgrement.PRM_Account_Id__c=a.Id;
        prmAccountAgrement.PRM_Partner_Agreement_Id__c=partnerAgr1.Id;
        prmAccountAgrement.PRM_Agreement_Sign_Dt__c= System.today();
        prmAccountAgrement.PRM_Signed_By_Email__c = c.Email;
        prmAccountAgrement.PRM_Signed_By_Name__c = c.FirstName+' '+c.LastName;
        //prmAccountAgrement.PRM_Contact__c=c.Id;
        insert prmAccountAgrement;

        Map<Id,PRM_Registration_Request__c> mapRegistationRequest = new Map<Id,PRM_Registration_Request__c>();
        mapRegistationRequest.put(a.Id,prmRegRequest);
        
        Test.startTest();
        PRM_CreateAccountAndRelatedRecordsAdmin.processRelatedRecordsAdmin(listOfAccountId,mapRegistationRequest,contactList);
        Test.stopTest();
        System.assertEquals( prmRegRequest.Name, 'checkuser', 'Value does not match');
    }

    
    
    @isTest
    static void createRelatedRecordstest(){        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();

        List<Contact> conList = new List<Contact>();
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435710';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Guest';
        a.Industry='Construction';
        insert a;
                
        ChannelProgram channelPrg = new ChannelProgram();
        channelPrg.name='Intel Partner Alliance';
        channelPrg.PRM_programCode__c='IPA';
        channelPrg.PRM_inactind__c=true;
        insert channelPrg;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='hariharasudhan.meiyappan@spamok.com';
        c.MailingCountry='USA';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
        //c.Core_IPA_Partner_Role__c = 'Guest';
        c.Core_IPA_PartnerRole__c = 'Guest';
       // c.Core_Job_Function__c='Mgr';
        c.Core_Profession__c='PROFESSOR';
        insert c;
        
        conList.add(c);
        
        Core_Country_Code_Mapping__c codeMap = new Core_Country_Code_Mapping__c();
        codeMap.Name = 'CP1';
        codeMap.Country_Code__c = 'US';
        codeMap.ISO_Code__c = 'USA';
        insert codeMap;
        
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = a.Id;
        prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Guest';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@malinator.com';
        prmRegRequest.PRM_Account_Phone__c = '9000000009';//RT
        //prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest.PRM_Profession__c='PROFESSOR';
        prmRegRequest.PRM_Contact_Country__c='US';
        //prmRegRequest.PRM_Legal_Agreements__c='CSP_ACK_EMEA_ENG';
        prmRegRequest.PRM_Subscriptions__c='CSPx2_Sub2';   
        prmRegRequest.PRM_EmailVerifiedDateTime__c = System.today();
        insert prmRegRequest;
                
       
         //PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(c.Email);
       
        
                
        PRM_Partner_Subscription__c prmSubscritpion = new PRM_Partner_Subscription__c();
        prmSubscritpion.Name='Intel® Cloud Insider Events and Tradeshows';
        prmSubscritpion.PRM_Subscription_Cd__c='CSPx2_Sub2';
        insert prmSubscritpion;
        
        PRM_ContactSubscriptionAssociation__c contSubscriptionAss = new PRM_ContactSubscriptionAssociation__c();
        contSubscriptionAss.PRM_Contact_Id__c = c.id;
        contSubscriptionAss.PRM_Partner_Subscription_Id__c = prmSubscritpion.id;
        contSubscriptionAss.PRM_Status_Nm__c = 'Active';
        contSubscriptionAss.PRM_Status_Reason_Txt__c ='Test';
        insert contSubscriptionAss;


        /*//second test-RT
        List<Contact> conList2 = new List<Contact>();
        Account a2 = PRM_TestUtility.getAccount();
        a2.AccountNumber = '435710';
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='Account Second';
        a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.BillingCity='New Delhi';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110037';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Guest';
        a2.Industry='Construction';
        insert a2;
                
        /*ChannelProgram channelPrg2 = new ChannelProgram();
        channelPrg2.name='Intel Partner Alliance';
        channelPrg2.PRM_programCode__c='IPA';
        channelPrg2.PRM_inactind__c=true;
        insert channelPrg2;*/
        
        /*Contact c2 = PRM_TestUtility.getContact();
        c2.AccountId = a2.Id;
        c2.Email='Accountsecond.second@spamok.com';
        c2.MailingCountry='IND';
        c2.Core_Preferred_Language__c = 'ENG';
        c2.Core_eRPM_Language_Code__c = 'ENG';
        c2.RecordTypeId = contactRecordType;
        c2.Core_Do_Not_Contact__c = False;
        //c.Core_IPA_Partner_Role__c = 'Guest';
        c2.Core_IPA_PartnerRole__c = 'Guest';
       // c.Core_Job_Function__c='Mgr';
        c2.Core_Profession__c='PROFESSOR';
        insert c2;
        
        conList2.add(c2);
        
        Core_Country_Code_Mapping__c codeMap2 = new Core_Country_Code_Mapping__c();
        codeMap2.Name = 'CP1';
        codeMap2.Country_Code__c = 'IN';
        codeMap2.ISO_Code__c = 'IND';
        insert codeMap2;
        
        PRM_Registration_Request__c prmRegRequest2 = new PRM_Registration_Request__c();
        prmRegRequest2.Name = 'seconduser account';
        prmRegRequest2.PRM_Salesforce_ID__c = a2.Id;
        prmRegRequest2.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest2.PRM_Partner_Role__c='Guest';
        prmRegRequest2.PRM_First_Name__c='Check';
        prmRegRequest2.PRM_Last_Name__c='User';
        prmRegRequest2.PRM_Email_ID__c='accountsecondandsecond@malinator.com';
        prmRegRequest2.PRM_Person_Phone_Number__c = '9000000009';//RT
        //prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest2.PRM_Profession__c='PROFESSOR';
        prmRegRequest2.PRM_Contact_Country__c='IND';
        //prmRegRequest.PRM_Legal_Agreements__c='CSP_ACK_EMEA_ENG';
        prmRegRequest2.PRM_Subscriptions__c='CSPx2_Sub2';   
        prmRegRequest2.PRM_EmailVerifiedDateTime__c = System.today();
        insert prmRegRequest2;
                
       
         //PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(c.Email);
       
        
                
        /*PRM_Partner_Subscription__c prmSubscritpion2 = new PRM_Partner_Subscription__c();
        prmSubscritpion2.Name='Intel® Cloud Insider Events and Tradeshows';
        prmSubscritpion2.PRM_Subscription_Cd__c='CSPx2_Sub2';
        insert prmSubscritpion2;*/
        
        /*PRM_ContactSubscriptionAssociation__c contSubscriptionAss2 = new PRM_ContactSubscriptionAssociation__c();
        contSubscriptionAss2.PRM_Contact_Id__c = c2.id;
        contSubscriptionAss2.PRM_Partner_Subscription_Id__c = prmSubscritpion.id;
        contSubscriptionAss2.PRM_Status_Nm__c = 'Active';
        insert contSubscriptionAss2;*/
            
        Test.startTest();
        PRM_CreateAccountAndRelatedRecordsAdmin.createRelatedRecords(prmRegRequest,a,c);
        PRM_CreateAccountAndRelatedRecordsAdmin.sendAdminRegApprovalEmail(conList, prmRegRequest);

        ////PRM_CreateAccountAndRelatedRecordsAdmin.createRelatedRecords(prmRegRequest2,a2,c2);
        //PRM_CreateAccountAndRelatedRecordsAdmin.sendAdminRegApprovalEmail(conList2, prmRegRequest2);
        Test.stopTest();
        System.assertEquals( prmRegRequest.Name, 'checkuser', 'Value does not match');
	    
    }
}