@isTest
public class PRM_CreateAccRelatedRecordsAdmin_Test 
{
    @isTest static void createAccountAndRelatedRecordsAdmintest()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
    
        Account a = PRM_TestUtility.getAccount();
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
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='hariharasudhan.meiyappan@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
        c.Core_IPA_Partner_Role__c = 'Service Provider';
        insert c;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        //cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Member';
        level.prm_programlevelcode__c = 'Member';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = a.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm.PRM_Status_Nm__c ='Pending';
        insert acm;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        insert acr;
        
        List<Contact> clist = new List<Contact>();
        clist.add(c);
        
        Map<String,String> registrationDetailsMap1 = new Map<String,String>();
        registrationDetailsMap1.put('AccountDuplicateStatus','NoDup');
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
        registrationDetailsMap1.put('PartnerRole','Distributor');
        registrationDetailsMap1.put('ContactFirstName','test_first');
        registrationDetailsMap1.put('ContactLastName','test_last');
        registrationDetailsMap1.put('ContactEmail','test123@test.com');
        registrationDetailsMap1.put('PreferredLanguage','ENG');
        
        //registrationDetailsMap1.put('','');
        //
        Map<String,String> registrationDetailsMap2 = new Map<String,String>();
        registrationDetailsMap2.put('AccountDuplicateStatus','PartDup');
        registrationDetailsMap2.put('contactDupStatus','PartDup');
        registrationDetailsMap2.put('DuplicateInfo','PartDup');
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
        registrationDetailsMap2.put('ContactFirstName','test_first');
        registrationDetailsMap2.put('ContactLastName','test_last');
        registrationDetailsMap2.put('ContactEmail','test123@test.com');
        registrationDetailsMap2.put('PreferredLanguage','');
        
        Map<String,String> results = new Map<String,String>();
        
        Test.startTest();
        PRM_CreateAccountAndRelatedRecordsAdmin.sendWelcomeEmailNotification(clist);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap1);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        //System.assertEquals(results.get('AccountId'), a.Id, 'Account match');
        delete acm;
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        Test.stopTest();
        System.assertEquals( registrationDetailsMap2.get('AccountName'), 'New Account', 'Value does not match');

    }
    
    
      @isTest static void createAccountAndRelatedRecordsAdmin1test()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a = PRM_TestUtility.getAccount();
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
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='hariharasudhan.meiyappan@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
        c.Core_IPA_Partner_Role__c = 'Service Provider';
        insert c;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        //cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Member';
        level.prm_programlevelcode__c = 'Member';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
        acm.PRM_Account_Id__c = a.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm.PRM_Status_Nm__c ='Pending';
        insert acm;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cprogram.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = contRelation.Id;
        acr.PRM_Account_Id__c = a.Id;
        acr.PRM_Contact_Id__c = c.Id;
        acr.PRM_InActive_Ind__c= false;
        insert acr;
        
        List<Contact> clist = new List<Contact>();
        clist.add(c);
        
        Map<String,String> registrationDetailsMap1 = new Map<String,String>();
        registrationDetailsMap1.put('AccountDuplicateStatus','NoDup');
        registrationDetailsMap1.put('ContactDuplicateStatus','Duplicate');
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
        registrationDetailsMap1.put('PartnerRole','Distributor');
        registrationDetailsMap1.put('ContactFirstName','test_first');
        registrationDetailsMap1.put('ContactLastName','test_last');
        registrationDetailsMap1.put('ContactEmail','hariharasudhan.meiyappan@intel.com');
        registrationDetailsMap1.put('PreferredLanguage','ENG');
        
        //registrationDetailsMap1.put('','');
        //
        Map<String,String> registrationDetailsMap2 = new Map<String,String>();
        registrationDetailsMap2.put('AccountDuplicateStatus','PartDup');
        registrationDetailsMap2.put('contactDupStatus','PartDup');
        registrationDetailsMap2.put('DuplicateInfo','PartDup');
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
        registrationDetailsMap2.put('ContactFirstName','test_first');
        registrationDetailsMap2.put('ContactLastName','test_last');
        registrationDetailsMap2.put('ContactEmail','test123@test.com');
        registrationDetailsMap2.put('PreferredLanguage','');
        
        Map<String,String> results = new Map<String,String>();
        
        Test.startTest();
        PRM_CreateAccountAndRelatedRecordsAdmin.sendWelcomeEmailNotification(clist);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap1);
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        //System.assertEquals(results.get('AccountId'), a.Id, 'Account match');
        delete acm;
        results = PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap2);
        Test.stopTest();
        System.assertEquals( registrationDetailsMap2.get('AccountName'), 'New Account', 'Value does not match');
    }
    
    
    @isTest static void sendAdminRegApprovalEmailtest(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        List<Contact> listContact = new List<Contact>();
        Account a = PRM_TestUtility.getAccount();
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
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='hariharasudhan.meiyappan@intel.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
        c.Core_IPA_Partner_Role__c = 'Service Provider';
        insert c;
        
        listContact.add(c);
        
        Test.startTest();
        
        PRM_CreateAccountAndRelatedRecordsAdmin.sendAdminRegApprovalEmail(listContact);
        Test.stopTest();   
        System.assertEquals( a.Name, 'New Account', 'Value does not match');     
    }
    
    
    @isTest 
    static void processRelatedRecordsAdmintest(){        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a = PRM_TestUtility.getAccount();
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
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='hariharasudhan.meiyappan@mailinator.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
        c.Core_IPA_Partner_Role__c = 'Service Provider';
        c.Core_Job_Function__c='Mgr';
        insert c;
        
        List<Id> listOfAccountId = new List<Id>();
        listOfAccountId.add(a.Id);
        
        ChannelProgram channelPrg = new ChannelProgram();
        channelPrg.name='Intel Partner Alliance';
        channelPrg.PRM_programCode__c='IPA';
        channelPrg.PRM_inactind__c=true;
       // insert channelPrg;
        
        
        PRM_AccountChannelMembership__c acmRecord = new PRM_AccountChannelMembership__c();
        acmRecord.PRM_Status_Nm__c = 'Pending';
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
        prmRegRequest.PRM_Job_Function__c='Branch Manager';
         prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Legal_Agreements__c='CSP_ACK_EMEA_ENG';
        insert prmRegRequest;
        
        PRM_PartnerAgreement__c partnerAgr = new PRM_PartnerAgreement__c();
        partnerAgr.Name='CSP_ACK_EMEA_ENG';
        partnerAgr.PRM_Agreement_Cd__c='CSP_ACK_EMEA';
        insert partnerAgr;
        
        PRM_AccountLegalAgreemntAssociation__c prmAccountAgrement = new PRM_AccountLegalAgreemntAssociation__c();
        prmAccountAgrement.PRM_Account_Id__c=a.Id;
        prmAccountAgrement.PRM_Partner_Agreement_Id__c=partnerAgr.Id;
        prmAccountAgrement.PRM_Agreement_Sign_Dt__c= System.today();
        prmAccountAgrement.PRM_Contact__c=c.Id;
        insert prmAccountAgrement;

        Map<Id,PRM_Registration_Request__c> mapRegistationRequest = new Map<Id,PRM_Registration_Request__c>();
        mapRegistationRequest.put(a.Id,prmRegRequest);
        
        Test.startTest();
		System.debug('alistOfAccountId'+listOfAccountId);
System.debug('amapRegistationRequest'+mapRegistationRequest);
System.debug('acontactList'+contactList);
        PRM_CreateAccountAndRelatedRecordsAdmin.processRelatedRecordsAdmin(listOfAccountId,mapRegistationRequest,contactList);
        Test.stopTest();
        System.assertEquals( prmRegRequest.Name, 'checkuser', 'Value does not match');
    }
    
    @isTest
    static void createRelatedRecordstest(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
  
        Account a = PRM_TestUtility.getAccount();
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
        insert a;
        
        ChannelProgram channelPrg = new ChannelProgram();
        channelPrg.name='Intel Partner Alliance';
        channelPrg.PRM_programCode__c='IPA';
        channelPrg.PRM_inactind__c=true;
        insert channelPrg;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='hariharasudhan.meiyappan@mailinator.com';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
        c.Core_IPA_Partner_Role__c = 'Service Provider';
        c.Core_Job_Function__c='Mgr';
        insert c;
        
         Core_Country_Code_Mapping__c codeMap = new Core_Country_Code_Mapping__c();
        codeMap.Name = 'CP1';
        codeMap.Country_Code__c = 'US';
        codeMap.ISO_Code__c = 'USA';
        insert codeMap;
        
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = a.Id;
        prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Service Provider';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@malinator.com';
        prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest.PRM_Contact_Country__c='US';
        //prmRegRequest.PRM_Legal_Agreements__c='CSP_ACK_EMEA_ENG';
        prmRegRequest.PRM_Subscriptions__c='CSPx2_Sub2';   
        insert prmRegRequest;
                
        PRM_Partner_Subscription__c prmSubscritpion = new PRM_Partner_Subscription__c();
        prmSubscritpion.Name='TESTSUBSCRTION';
        prmSubscritpion.PRM_Subscription_Cd__c='CSPx2_Sub2';
        insert prmSubscritpion;
            
        Test.startTest();
        PRM_CreateAccountAndRelatedRecordsAdmin.createRelatedRecords(prmRegRequest,a,c);
        Test.stopTest();
        System.assertEquals( prmRegRequest.Name, 'checkuser', 'Value does not match');
    }
}