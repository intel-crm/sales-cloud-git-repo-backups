@isTest
public class PRM_AdminRegistration_Test {
    
    /*@testSetup
    static void createTestRecords() {
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();

        Account a = PRM_TestUtility.getAccount();
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Manufacturer';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Manufacturer';
        a.Industry = 'Construction';
        insert a;
        

        Contact c = PRM_TestUtility.getContact();
        c.Core_IPA_PartnerRole__c = null;
        c.AccountId = a.Id;
        insert c;
        
        Contact c2 = PRM_TestUtility.getContact();
        c2.Email='hariharasudhan.meiyappan@intel.com';
        c2.Core_IPA_PartnerRole__c = 'Manufacturer';
        c2.AccountId = a.Id;
        insert c2;
                
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel levelold = new ChannelProgramLevel();   //Channel Program Level
        levelold.Name='Member';
        levelold.prm_programlevelcode__c = 'Member';
        levelold.ProgramId = cprogram.Id;
        insert levelold;
        
      /*  PRM_Registration_Request__c regRequestRec = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec.PRM_Status__c ='New' ;
      //  regRequestRec.PRM_Record_Type_Name_rpt_txt__c ='Account Create Request';
        regRequestRec.PRM_Email_ID__c = c.Email;
        insert regRequestRec;*/
      /* PRM_AccountChannelMembership__c approvedAcm =  new PRM_AccountChannelMembership__c();
        approvedAcm.PRM_Account_Id__c = a.Id;
        approvedAcm.PRM_Status_Nm__c = 'Approved';
        approvedAcm.PRM_Partner_Role__c = 'Manufacturer';
        approvedAcm.PRM_Channel_Program_Id__c = cprogram.id;
        insert approvedAcm;
        
    }*/
    
  /*  @isTest static void getAccountFromIdTest(){
        Account a = [Select Id from Account limit 1];
        List<Account> accList = new List<Account>();
        test.startTest();
        accList = PRM_AdminRegistration.getAccountFromId(a.id);    
        test.stopTest();
        System.assertequals(accList.size()>0,true,'The method did not return any record'); 
    } */
     
    @isTest static void fetchStateCountryValuesTest(){
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        //Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
		
        Account a = PRM_TestUtility.getAccount();
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Manufacturer';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Manufacturer';
        a.Industry = 'Construction';
        insert a;
        

        Contact c = PRM_TestUtility.getContact();
        c.Core_IPA_PartnerRole__c = null;
        c.AccountId = a.Id;
        c.MailingCountry='India';
        insert c;
        
        Contact c2 = PRM_TestUtility.getContact();
        c2.Email='hariharasudhan.meiyappan@intel.com';
        c2.Core_IPA_PartnerRole__c = 'Manufacturer';
        c2.MailingCountry='India';
        c2.AccountId = a.Id;
        insert c2;
                
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel levelold = new ChannelProgramLevel();   //Channel Program Level
        levelold.Name='Member';
        levelold.prm_programlevelcode__c = 'Member';
        levelold.ProgramId = cprogram.Id;
        insert levelold;
        
      /*  PRM_Registration_Request__c regRequestRec = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec.PRM_Status__c ='New' ;
      //  regRequestRec.PRM_Record_Type_Name_rpt_txt__c ='Account Create Request';
        regRequestRec.PRM_Email_ID__c = c.Email;
        insert regRequestRec;*/
       PRM_AccountChannelMembership__c approvedAcm =  new PRM_AccountChannelMembership__c();
        approvedAcm.PRM_Account_Id__c = a.Id;
        approvedAcm.PRM_Status_Nm__c = 'Approved';
        approvedAcm.PRM_Partner_Role__c = 'Manufacturer';
        approvedAcm.PRM_Channel_Program_Id__c = cprogram.id;
        insert approvedAcm;
        
        PRM_AdminRegistration.picklistValues picklistvalues = new PRM_AdminRegistration.picklistValues();
        test.starttest();
     //   Contact c = [Select Id,Email from Contact Limit 1];
        List<Contact> conList = [Select id, email from Contact limit 2];
        Contact c1 = [Select Id,Email from Contact where email = :conList[0].email  Limit 1];
        Contact c21 = [Select Id,Email from Contact where email = :conList[1].email  Limit 1];
        
        
        picklistvalues = PRM_AdminRegistration.getPicklistValues();
        PRM_AdminRegistration.fetchAccountDetails(c1.Email);
        PRM_AdminRegistration.fetchPendingACM(c1.Email);
         PRM_AdminRegistration.fetchAccountDetails(c21.Email);
        PRM_AdminRegistration.fetchPendingACM(c21.Email);
        test.stopTest();
        
        System.assertEquals(c1.Email, 'testrequest@mailinator.com', 'Value does not match');
        System.assertEquals(c21.Email, 'hariharasudhan.meiyappan@intel.com', 'Value does not match');
      //  System.assertEquals(c1.Email, 'testmail@disti.com', 'Value does not match');
      //  System.assertEquals(c2.Email, 'testmail@distib.com', 'Value does not match');

    }
@isTest static void fetchStateCountryValuesTest1(){
    
    Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        //Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
    //	Id regReqRecordType = Schema.getGlobalDescribe().get('New Registration').getDescribe().getRecordTypeInfosByDeveloperName().get('Account Create Request').getRecordTypeId();

        Account a1 = PRM_TestUtility.getAccount();
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Name='New Account 1';
        a1.Core_Account_Type__c ='';
        a1.Industry='Agriculture';
        a1.BillingCity='New Delhi 1';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='4th Floor,New Roadt';
        a1.BillingPostalCode='110039';
        a1.BillingStateCode='KA';
        a1.Core_IPA_Partner_Role__c = 'Manufacturer';
        a1.Industry = 'Construction';
        insert a1;
        

        Contact c3 = PRM_TestUtility.getContact();
        c3.Core_IPA_PartnerRole__c = null;
        c3.Email='testmail@disti.com';
        c3.AccountId = a1.Id;
        c3.MailingCountry='India';
        insert c3;
        
        Contact c4 = PRM_TestUtility.getContact();
        c4.Email='testmail@distib.com';
        c4.Core_IPA_PartnerRole__c = 'Manufacturer';
        c4.AccountId = a1.Id;
        c4.MailingCountry='India';
        insert c4;
                
        ChannelProgram cprogram1 = new ChannelProgram();
        cprogram1.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram1.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram1;
        
        ChannelProgramLevel levelold1 = new ChannelProgramLevel();   //Channel Program Level
        levelold1.Name='Member';
        levelold1.prm_programlevelcode__c = 'Member';
        levelold1.ProgramId = cprogram1.Id;
        insert levelold1;
        
        
        PRM_AccountChannelMembership__c pendingAcm = new PRM_AccountChannelMembership__c();
        pendingAcm.PRM_Account_Id__c = a1.Id;
        pendingAcm.PRM_Status_Nm__c = 'Pending';
		pendingAcm.PRM_Partner_Role__c = 'Manufacturer';
        pendingAcm.PRM_Channel_Program_Id__c = cprogram1.id;
        insert pendingAcm;
    
    
        PRM_AdminRegistration.picklistValues picklistvalues = new PRM_AdminRegistration.picklistValues();
        test.starttest();
     //   Contact c = [Select Id,Email from Contact Limit 1];
        List<Contact> conList = [Select id, email from Contact limit 2];
        Contact c1 = [Select Id,Email from Contact where email = :conList[0].email  Limit 1];
        Contact c2 = [Select Id,Email from Contact where email = :conList[1].email  Limit 1];
        
        
        picklistvalues = PRM_AdminRegistration.getPicklistValues();
        PRM_AdminRegistration.fetchAccountDetails(c1.Email);
        PRM_AdminRegistration.fetchPendingACM(c1.Email);
         PRM_AdminRegistration.fetchAccountDetails(c2.Email);
        PRM_AdminRegistration.fetchPendingACM(c2.Email);
        test.stopTest();
        
       // System.assertEquals(c1.Email, 'testrequest@mailinator.com', 'Value does not match');
       // System.assertEquals(c2.Email, 'hariharasudhan.meiyappan@intel.com', 'Value does not match');
        System.assertEquals(c1.Email, 'testmail@disti.com', 'Value does not match');
       System.assertEquals(c2.Email, 'testmail@distib.com', 'Value does not match');

    }
    
    
    @isTest
    static void fetchPendingSelfRegRequestsTest(){
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        //Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
		//Id regReqRecordType = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Account Create Request').getRecordTypeId();
		Id regReqRecordType = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByName().get('Account Create Request').getRecordTypeId();
        Account a = PRM_TestUtility.getAccount();
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Manufacturer';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Manufacturer';
        a.Industry = 'Construction';
        insert a;
        

        Contact c = PRM_TestUtility.getContact();
        c.Core_IPA_PartnerRole__c = null;
        c.AccountId = a.Id;
        c.MailingCountry='India';
        insert c;
        
        Contact c2 = PRM_TestUtility.getContact();
        c2.Email='hariharasudhan.meiyappan@intel.com';
        c2.Core_IPA_PartnerRole__c = 'Manufacturer';
        c2.AccountId = a.Id;
        c2.MailingCountry='India';
        insert c2;
                
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel levelold = new ChannelProgramLevel();   //Channel Program Level
        levelold.Name='Member';
        levelold.prm_programlevelcode__c = 'Member';
        levelold.ProgramId = cprogram.Id;
        insert levelold;
        
        PRM_Registration_Request__c regRequestRec = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec.PRM_Status__c ='New' ;
        regRequestRec.RecordTypeId =regReqRecordType;
        regRequestRec.PRM_Email_ID__c = c.Email;
        insert regRequestRec;
        
        PRM_Registration_Request__c regRequestRec2 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec2.PRM_Status__c ='New' ;
        regRequestRec2.RecordTypeId=regReqRecordType;
        regRequestRec2.PRM_Email_ID__c = c2.Email;
        insert regRequestRec2;
      /*  PRM_Registration_Request__c regRequestRec = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec.PRM_Status__c ='New' ;
      //  regRequestRec.PRM_Record_Type_Name_rpt_txt__c ='Account Create Request';
        regRequestRec.PRM_Email_ID__c = c.Email;
        insert regRequestRec;*/
        
        
       PRM_AccountChannelMembership__c approvedAcm =  new PRM_AccountChannelMembership__c();
        approvedAcm.PRM_Account_Id__c = a.Id;
        approvedAcm.PRM_Status_Nm__c = 'Approved';
        approvedAcm.PRM_Partner_Role__c = 'Manufacturer';
        approvedAcm.PRM_Channel_Program_Id__c = cprogram.id;
        insert approvedAcm;
        
        
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
        registrationDetailsMap1.put('BizOrgType','Manufacturer');
        registrationDetailsMap1.put('PartnerRole','Manufacturer');
        registrationDetailsMap1.put('PartnerSegment','Internet of Things and Embedded');
        registrationDetailsMap1.put('ContactFirstName','test_first');
        registrationDetailsMap1.put('ContactLastName','test_last');
        registrationDetailsMap1.put('ContactEmail','test1231@test.com');
        registrationDetailsMap1.put('PreferredLanguage','ENG');
        registrationDetailsMap1.put('PreferredLanguageCode','ENG');
        registrationDetailsMap1.put('SuppressEmail','true');
        
        Map<String,String> results = new Map<String,String>();
        
         test.starttest();
        //Contact c = [Select Id,Email from Contact Limit 1];
        List<Contact> conList = [Select id, email from Contact];
        Contact c1 = [Select Id,Email from Contact where email = :conList[0].email  ];
        Contact c21 = [Select Id,Email from Contact where email = :conList[1].email  ];
        PRM_AdminRegistration.fetchPendingSelfRegRequests(c1.Email);  
        PRM_AdminRegistration.fetchPendingSelfRegRequests(c21.Email);  
        results = PRM_AdminRegistration.submitAdminRequestForm(registrationDetailsMap1);
        test.stopTest();
        System.assertEquals(c1.Email, 'testrequest@mailinator.com', 'Value does not match');
        System.assertEquals(c21.Email, 'hariharasudhan.meiyappan@intel.com', 'Value does not match');
      //  System.assertEquals(c1.Email, 'testmail@disti.com', 'Value does not match');
      //  System.assertEquals(c2.Email, 'testmail@distib.com', 'Value does not match');
    }

@isTest
    static void fetchPendingSelfRegRequestsTest1(){
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        //Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
    	//Id regReqRecordType = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Account Create Request').getRecordTypeId();
		Id regReqRecordType = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByName().get('Account Create Request').getRecordTypeId();
        Account a1 = PRM_TestUtility.getAccount();
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Name='New Account 1';
        a1.Core_Account_Type__c ='Manufacturer';
        a1.Industry='Agriculture';
        a1.BillingCity='New Delhi 1';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='4th Floor,New Roadt';
        a1.BillingPostalCode='110039';
        a1.BillingStateCode='KA';
        a1.Core_IPA_Partner_Role__c = 'Manufacturer';
        a1.Industry = 'Construction';
        insert a1;
        

        Contact c3 = PRM_TestUtility.getContact();
        c3.Core_IPA_PartnerRole__c = null;
        c3.Email='testmail@disti.com';
        c3.AccountId = a1.Id;
        c3.MailingCountry='India';
        insert c3;
        
        Contact c4 = PRM_TestUtility.getContact();
        c4.Email='testmail@distib.com';
        c4.Core_IPA_PartnerRole__c = 'Manufacturer';
        c4.AccountId = a1.Id;
        c4.MailingCountry='India';
        insert c4;
                
        ChannelProgram cprogram1 = new ChannelProgram();
        cprogram1.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram1.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram1;
        
        ChannelProgramLevel levelold1 = new ChannelProgramLevel();   //Channel Program Level
        levelold1.Name='Member';
        levelold1.prm_programlevelcode__c = 'Member';
        levelold1.ProgramId = cprogram1.Id;
        insert levelold1;
        
        
        PRM_AccountChannelMembership__c pendingAcm = new PRM_AccountChannelMembership__c();
        pendingAcm.PRM_Account_Id__c = a1.Id;
        pendingAcm.PRM_Status_Nm__c = 'Pending';
		pendingAcm.PRM_Partner_Role__c = 'Manufacturer';
        pendingAcm.PRM_Channel_Program_Id__c = cprogram1.id;
        insert pendingAcm;
        
        PRM_Registration_Request__c regRequestRec3 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec3.PRM_Status__c ='New' ;
        regRequestRec3.RecordTypeId =regReqRecordType;
        regRequestRec3.PRM_Email_ID__c = c3.Email;
        insert regRequestRec3;
        
        PRM_Registration_Request__c regRequestRec4 = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec4.PRM_Status__c ='New' ;
        regRequestRec4.RecordTypeId =regReqRecordType;
        regRequestRec4.PRM_Email_ID__c = c4.Email;
        insert regRequestRec4;
        
        Map<String,String> registrationDetailsMap2 = new Map<String,String>();
        registrationDetailsMap2.put('AccountDuplicateStatus','NoDup');
        registrationDetailsMap2.put('ContactDupStatus','Duplicate');
        registrationDetailsMap2.put('DuplicateInfo','Dup');
        registrationDetailsMap2.put('SelectedRow','[{"Id":'+'"'+a1.Id+'"'+',"Name":"Sapient","BillingStreet":"4492  Golden Ridge Road Church City","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"07292","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Manufacturer","Core_IPA_Partner_Role__c":"Manufacturer","Industry":"Chemicals","AccountName":"/lightning/r/Account/0016C00000CldIiQAJ/view","BillingAddress":"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA","DuplicateStatus":"PartDup"}]');
        registrationDetailsMap2.put('AccountName','Test Account');
        registrationDetailsMap2.put('AccountNumber','435766');
        registrationDetailsMap2.put('Country','USA');
        registrationDetailsMap2.put('State','NY');
        registrationDetailsMap2.put('AddressLine1','Test_address122');
        registrationDetailsMap2.put('AddressLine2','Test_address23');
        registrationDetailsMap2.put('City','New York');
        registrationDetailsMap2.put('PostalCode','11001');
        registrationDetailsMap2.put('BizOrgType','Manufacturer');
        registrationDetailsMap2.put('PartnerRole','Manufacturer');
        registrationDetailsMap2.put('PartnerSegment','Internet of Things and Embedded');
        registrationDetailsMap2.put('ContactFirstName','test_first');
        registrationDetailsMap2.put('ContactLastName','test_last');
        registrationDetailsMap2.put('ContactEmail','test1231@test.com');
        registrationDetailsMap2.put('PreferredLanguage','ENG');
        registrationDetailsMap2.put('PreferredLanguageCode','ENG');
        registrationDetailsMap2.put('SuppressEmail','true');
        
        PRM_SBC_Account_Search_Configuration__c ipaconf=new PRM_SBC_Account_Search_Configuration__c();
        ipaconf.PRM_Contact__c=c3.id;
        ipaconf.Account__c=a1.id;
        insert ipaconf;
        Map<String,String> results2 = new Map<String,String>();
        
         test.starttest();
        //Contact c = [Select Id,Email from Contact Limit 1];
        List<Contact> conList = [Select id, email from Contact];
        Contact c1 = [Select Id,Email from Contact where email = :conList[0].email  ];
        Contact c2 = [Select Id,Email from Contact where email = :conList[1].email  ];
        PRM_AdminRegistration.fetchPendingSelfRegRequests(c1.Email);  
        PRM_AdminRegistration.fetchPendingSelfRegRequests(c2.Email);
         results2 = PRM_AdminRegistration.submitAdminRequestForm(registrationDetailsMap2);
        boolean block=PRM_AdminRegistration.getBlockedAccountContact('testmail@disti.com',a1.id);
        test.stopTest();
        //System.assertEquals(c1.Email, 'testrequest@mailinator.com', 'Value does not match');
        //System.assertEquals(c2.Email, 'hariharasudhan.meiyappan@intel.com', 'Value does not match');
        System.assertEquals(c1.Email, 'testmail@disti.com', 'Value does not match');
       System.assertEquals(c2.Email, 'testmail@distib.com', 'Value does not match');
    }
    
    @isTest
    static void systemAccountDetails(){
        
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        //Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();

        Account a = PRM_TestUtility.getAccount();
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Manufacturer';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Manufacturer';
        a.Industry = 'Construction';
        insert a;
        

        Contact c = PRM_TestUtility.getContact();
        c.Core_IPA_PartnerRole__c = null;
        c.AccountId = a.Id;
        c.MailingCountry='India';
        insert c;
        
        Contact c2 = PRM_TestUtility.getContact();
        c2.Email='hariharasudhan.meiyappan@intel.com';
        c2.Core_IPA_PartnerRole__c = 'Manufacturer';
        c2.AccountId = a.Id;
        c2.MailingCountry='India';
        insert c2;
                
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        
        ChannelProgramLevel levelold = new ChannelProgramLevel();   //Channel Program Level
        levelold.Name='Member';
        levelold.prm_programlevelcode__c = 'Member';
        levelold.ProgramId = cprogram.Id;
        insert levelold;
        
      /*  PRM_Registration_Request__c regRequestRec = PRM_TestUtility.getPRMRegistrationRequest();
        regRequestRec.PRM_Status__c ='New' ;
      //  regRequestRec.PRM_Record_Type_Name_rpt_txt__c ='Account Create Request';
        regRequestRec.PRM_Email_ID__c = c.Email;
        insert regRequestRec;*/
       PRM_AccountChannelMembership__c approvedAcm =  new PRM_AccountChannelMembership__c();
        approvedAcm.PRM_Account_Id__c = a.Id;
        approvedAcm.PRM_Status_Nm__c = 'Approved';
        approvedAcm.PRM_Partner_Role__c = 'Manufacturer';
        approvedAcm.PRM_Channel_Program_Id__c = cprogram.id;
        insert approvedAcm;
        
        
         test.starttest();
       // Contact c = [Select Id,Email from Contact Limit 1];
        List<Contact> conList = [Select id, email from Contact];
        Contact c1 = [Select Id,Email from Contact where email = :conList[0].email ];
        Contact c21 = [Select Id,Email from Contact where email = :conList[1].email  ];
        PRM_AdminRegistration.systemAccountDetails(c1.Email); 
        PRM_AdminRegistration.systemAccountDetails(c21.Email); 
        test.stopTest();
        System.assertEquals(c1.Email, 'testrequest@mailinator.com', 'false');
        System.assertEquals(c21.Email, 'hariharasudhan.meiyappan@intel.com', 'false');
     //   System.assertEquals(c1.Email, 'testmail@disti.com', 'false');
     //   System.assertEquals(c2.Email, 'testmail@distibcom', 'false');

    }

@isTest
    static void systemAccountDetails1(){
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        //Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();

        Account a1 = PRM_TestUtility.getAccount();
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Name='New Account 1';
        a1.Core_Account_Type__c ='Manufacturer';
        a1.Industry='Agriculture';
        a1.BillingCity='New Delhi 1';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='4th Floor,New Roadt';
        a1.BillingPostalCode='110039';
        a1.BillingStateCode='KA';
        a1.Core_IPA_Partner_Role__c = 'Manufacturer';
        a1.Industry = 'Construction';
        insert a1;
        

        Contact c3 = PRM_TestUtility.getContact();
        c3.Core_IPA_PartnerRole__c = null;
        c3.Email='testmail@disti.com';
        c3.AccountId = a1.Id;
        c3.MailingCountry='India';
        insert c3;
        
        Contact c4 = PRM_TestUtility.getContact();
        c4.Email='testmail@distib.com';
        c4.Core_IPA_PartnerRole__c = 'Manufacturer';
        c4.AccountId = a1.Id;
        c4.MailingCountry='India';
        insert c4;
                
        ChannelProgram cprogram1 = new ChannelProgram();
        cprogram1.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram1.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram1;
        
        ChannelProgramLevel levelold1 = new ChannelProgramLevel();   //Channel Program Level
        levelold1.Name='Member';
        levelold1.prm_programlevelcode__c = 'Member';
        levelold1.ProgramId = cprogram1.Id;
        insert levelold1;
        
        
        PRM_AccountChannelMembership__c pendingAcm = new PRM_AccountChannelMembership__c();
        pendingAcm.PRM_Account_Id__c = a1.Id;
        pendingAcm.PRM_Status_Nm__c = 'Pending';
		pendingAcm.PRM_Partner_Role__c = 'Manufacturer';
        pendingAcm.PRM_Channel_Program_Id__c = cprogram1.id;
        insert pendingAcm;
        
        
         test.starttest();
       // Contact c = [Select Id,Email from Contact Limit 1];
        List<Contact> conList = [Select id, email from Contact];
        Contact c1 = [Select Id,Email from Contact where email = :conList[0].email ];
        Contact c2 = [Select Id,Email from Contact where email = :conList[1].email  ];
        PRM_AdminRegistration.systemAccountDetails(c1.Email); 
        PRM_AdminRegistration.systemAccountDetails(c2.Email); 
        test.stopTest();
       // System.assertEquals(c1.Email, 'testrequest@mailinator.com', 'false');
        //System.assertEquals(c2.Email, 'hariharasudhan.meiyappan@intel.com', 'false');
        System.assertEquals(c1.Email, 'testmail@disti.com', 'false');
        System.assertEquals(c2.Email, 'testmail@distib.com', 'false');

    }
    
    
}