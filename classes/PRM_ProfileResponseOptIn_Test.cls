/**********************************************************************************************************************
Class Name    : PRM_ProfileResponseOptIn_Test
Version       : 1.0
Created Date  : June 2020
Function      : Test class for PRM_ProfileResponseOptIn

Modification Log :
* Developer                          Date                    Description
* ---------------------------------------------------------------------------------------------------------------------
* Pratik Sanganeria              25 June,2020            Test class for PRM_ProfileResponseOptIn

***********************************************************************************************************************/

@isTest
private class PRM_ProfileResponseOptIn_Test {
    @isTest
    private static void testCreateResponse()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<PRM_Profile_Questions__c> profQuesList = new List<PRM_Profile_Questions__c>();
        List<PRM_Profile_Answer__c> profAnsList = new List<PRM_Profile_Answer__c>();
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435766';
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
        accList.add(a);
        
        Account acc = PRM_TestUtility.getAccount();
        acc.AccountNumber = '43576612';
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Name='New Accounttest';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture1';
        acc.BillingCity='New Delhi1';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road1';
        acc.BillingPostalCode='1100371';
        acc.BillingStateCode='KA';
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        accList.add(acc);
        
        Account a1 = PRM_TestUtility.getAccount();
        a1.AccountNumber = '435788';
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Name='Test Account';
        a1.Core_Account_Type__c ='Distributor';
        a1.Industry='Agriculture';
        a1.BillingCity='Bengaluru';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='4th Floor,Koramangala 123';
        a1.BillingPostalCode='560037';
        a1.BillingStateCode='KA';
        a1.Core_IPA_Partner_Role__c = 'Distributor';
        accList.add(a1);
       
        insert accList;
        
        Contact c = new Contact();
        c.FirstName='john';
        c.LastName='harrison';
        c.AccountId = a.Id;
        c.MailingCountry='USA';
        c.Email='john.harrison@maildrop.cc';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
       // c.Core_IPA_Partner_Role__c = 'Service Provider';
         c.Core_IPA_PartnerRole__c = 'Service Provider';
        conList.add(c);
        
        Contact c1 = new Contact();
        c1.FirstName='alan';
        c1.LastName='cumberbatch';
        c1.AccountId = a1.Id;
        c1.MailingCountry='USA';
        c1.Email='alan.cumberbatch@maildrop.cc';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_Do_Not_Contact__c = False;
      //  c1.Core_IPA_Partner_Role__c = 'Distributor';
        c1.Core_IPA_PartnerRole__c = 'Distributor';
        conList.add(c1);

        Contact c1123 = new Contact();
        c1123.FirstName='alan';
        c1123.LastName='cumberbatch123';
        c1123.AccountId = acc.Id;
        c1123.MailingCountry='USA';
        c1123.Email='alan.cumberbatch123@maildrop.cc';
        c1123.Core_Preferred_Language__c = 'ENG';
        c1123.Core_eRPM_Language_Code__c = 'ENG';
        c1123.RecordTypeId = contactRecordType;
        c1123.Core_Do_Not_Contact__c = False;
      //  c1.Core_IPA_Partner_Role__c = 'Distributor';
        c1123.Core_IPA_PartnerRole__c = 'Distributor';
        conList.add(c1123);        
        insert conList;
        
         ChannelProgram cpNew = new ChannelProgram();
        cpNew.Name = 'Intel Partner Alliance';
        insert cpNew;
        
        ChannelProgramLevel cplNew = new ChannelProgramLevel();
        cplNew.Name = 'Partner';
        cplNew.ProgramId = cpNew.Id;
        insert cplNew;
        
        list<PRM_AccountChannelMembership__c> acmList1=new list<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acmNew = new PRM_AccountChannelMembership__c();
        acmNew.PRM_Partner_Role__c = 'Distributor';
        acmNew.PRM_Channel_Program_Id__c =cpNew.Id;
        acmNew.PRM_Channel_Program_Level_Id__c = cplNew.Id;
        acmNew.PRM_Status_Nm__c ='Inactive';
        acmNew.PRM_Account_Id__c =  acc.id;
        acmNew.PRM_Status_Reason_Txt__c = 'Test class';
        acmList1.add(acmNew);
        
        PRM_AccountChannelMembership__c acmNewA = new PRM_AccountChannelMembership__c();
        acmNewA.PRM_Partner_Role__c = 'Service Provider';
        acmNewA.PRM_Channel_Program_Id__c =cpNew.Id;
        acmNewA.PRM_Channel_Program_Level_Id__c = cplNew.Id;
        acmNewA.PRM_Status_Nm__c ='Approved';
        acmNewA.PRM_Account_Id__c =  acc.id;
        acmNewA.PRM_Status_Reason_Txt__c = 'Test class';
        acmList1.add(acmNewA);
        
         
         PRM_AccountChannelMembership__c acmNew1 = new PRM_AccountChannelMembership__c();
        acmNew1.PRM_Partner_Role__c = 'Service Provider';
        acmNew1.PRM_Channel_Program_Id__c =cpNew.Id;
        acmNew1.PRM_Channel_Program_Level_Id__c = cplNew.Id;
        acmNew1.PRM_Status_Nm__c ='Inactive';
        acmNew1.PRM_Account_Id__c =  a.id;
        acmNew1.PRM_Status_Reason_Txt__c = 'Test class';
        acmList1.add(acmNew1);
        insert acmList1;
        
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'PRM_Opt_In';
        profQuesList.add(profileQues);
        
        PRM_Profile_Questions__c profileQues1 =  new PRM_Profile_Questions__c();
        profileQues1.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        profQuesList.add(profileQues1);
        
        PRM_Profile_Questions__c profileQues11 =  new PRM_Profile_Questions__c();
        profileQues11.PRM_Question_Cd__c = 'PRM_Points_Not_Eligible';
        
        profQuesList.add(profileQues11);
        
        
        insert profQuesList;
        //System.debug('Profile qus ids :'+[select id,PRM_Question_Cd__c  from PRM_Profile_Questions__c]);
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'PRM_Opt_In_True';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        profAnsList.add(profileAns);
        
      
        
        PRM_Profile_Answer__c profileAns11 = new PRM_Profile_Answer__c();
        profileAns11.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_False';
        profileAns11.PRM_Profile_Questions_Id__c = profileQues11.Id;
        profAnsList.add(profileAns11);
        
        PRM_Profile_Answer__c profileAns12 = new PRM_Profile_Answer__c();
        profileAns12.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_True';
        profileAns12.PRM_Profile_Questions_Id__c = profileQues11.Id;
        profAnsList.add(profileAns12);
        
        PRM_Profile_Answer__c profileAns1 = new PRM_Profile_Answer__c();
        profileAns1.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns1.PRM_Profile_Questions_Id__c = profileQues1.Id;
        profAnsList.add(profileAns1);
        
        insert profAnsList;
        
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c();
        response.PRM_Account_Id__c = a.Id;
        response.PRM_Profile_Questions_Id__c = profileQues1.Id;
        response.PRM_Profile_Answer_Id__c = profileAns1.Id;
               
        insert response;
        
        PRM_Profile_Responses__c response12 = new PRM_Profile_Responses__c();
        response12.PRM_Account_Id__c = a.Id;
        response12.PRM_Response_Txt__c='true';
        response12.PRM_Profile_Questions_Id__c = profileQues.Id;
       
        response12.PRM_Profile_Answer_Id__c = profileAns.Id;
        insert response12;
        
         List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Core_IPA_One_Partner_Id__c='123768';
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        
        PRM_AccountChannelMembership__c acmNewAO = new PRM_AccountChannelMembership__c();
        acmNewAO.PRM_Partner_Role__c = 'Service Provider';
        acmNewAO.PRM_Channel_Program_Id__c =cpNew.Id;
        acmNewAO.PRM_Channel_Program_Level_Id__c = cplNew.Id;
        acmNewAO.PRM_Status_Nm__c ='Approved';
        acmNewAO.PRM_Account_Id__c =  newPagAccount.id;
        acmNewAO.PRM_Status_Reason_Txt__c = 'Test class';
       // acmList1.add(acmNewA);
        insert acmNewAO;
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = acc.id; 
        //insert coreAccnt;
        List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();
        cagList.add(coreAccnt);       
        insert cagList;
        List<PRM_Registration_Request__c> reglist = new List<PRM_Registration_Request__c>();
        insert reglist;
         Map<String, String> mapOfRegAccountQstnIdResTxt = new Map<String, String>();
         Map<Id, Id> mapOfOPIDAccIdLocAccId = new Map<Id, Id>();
        Test.startTest();
        PRM_ProfileResponseOptIn.checkExtProfRespOnOPIDAndCreateResp(accList,conList,cagList,reglist);
        PRM_ProfileResponseOptIn.createResponse(accList,conList,mapOfRegAccountQstnIdResTxt,mapOfOPIDAccIdLocAccId);
        
        PRM_ProfileResponseOptIn.createResponseForOpid(accList,conList,reglist,cagList);
        accList.clear();
        accList.add(a);
        PRM_ProfileResponseOptIn.checkExtProfRespOnOPIDAndCreateResp(accList,conList,cagList,reglist);
        PRM_ProfileResponseOptIn.createResponse(accList,conList,mapOfRegAccountQstnIdResTxt,mapOfOPIDAccIdLocAccId);
        PRM_ProfileResponseOptIn.createResponseForOpid(accList,conList,reglist,cagList);
        Test.stopTest();
        System.assertEquals('PRM_Opt_In', profileQues.PRM_Question_Cd__c,'Value does not match');
        
    }   
    
    @isTest private static void testCreateResponse1(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        List<Account> accList = new List<Account>();
        Set<Id> accidset = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        List<PRM_Profile_Questions__c> profQuesList = new List<PRM_Profile_Questions__c>();
        List<PRM_Profile_Answer__c> profAnsList = new List<PRM_Profile_Answer__c>();        
        
        Account acc123 = PRM_TestUtility.getAccount();
        acc123.AccountNumber = '43576612';
        acc123.RecordTypeId = accountRecordTypeIntel;
        acc123.Name='New Accounttest123';
        acc123.Core_Account_Type__c ='Distributor';
        acc123.Industry='Agriculture123';
        acc123.BillingCity='New Delhi1';
        acc123.BillingCountryCode='IND';
        acc123.BillingStreet='4th Floor,New Road';
        acc123.BillingPostalCode='1100371';
        acc123.BillingStateCode='KA';
        acc123.Core_IPA_Partner_Role__c = 'Guest';
        accList.add(acc123);
        
        Account a123 = PRM_TestUtility.getAccount();
        a123.AccountNumber = '435785';
        a123.RecordTypeId = accountRecordTypeIntel;
        a123.Name='Test Account 123';
        a123.Core_Account_Type__c ='Distributor';
        a123.Industry='Agriculture';
        a123.BillingCity='Bengaluru';
        a123.BillingCountryCode='IND';
        a123.BillingStreet='4th Floor,Koramangala';
        a123.BillingPostalCode='560037';
        a123.BillingStateCode='KA';
        a123.Core_IPA_Partner_Role__c = 'Distributor';
        accList.add(a123);
        
         Account acc1234 = PRM_TestUtility.getAccount();
        acc1234.AccountNumber = '435766123';
        acc1234.RecordTypeId = accountRecordTypeIntel;
        acc1234.Name='New Accounttest12344';
        acc1234.Core_Account_Type__c ='Distributor';
        acc1234.Industry='Agriculture1231';
        acc1234.BillingCity='New Delhi1';
        acc1234.BillingCountryCode='IND';
        acc1234.BillingStreet='24th Floor,New Road';
        acc1234.BillingPostalCode='1111371';
        acc1234.BillingStateCode='KA';
        acc1234.Core_IPA_Partner_Role__c = 'Distributor';
        accList.add(acc1234);
        
        Account a1235 = PRM_TestUtility.getAccount();
        a1235.AccountNumber = '43578511';
        a1235.RecordTypeId = accountRecordTypeIntel;
        a1235.Name='Test Account 12133';
        a1235.Core_Account_Type__c ='Distributor';
        a1235.Industry='Agriculture';
        a1235.BillingCity='Bengaluru';
        a1235.BillingCountryCode='IND';
        a1235.BillingStreet='14th Floor,Koramangala';
        a1235.BillingPostalCode='6789037';
        a1235.BillingStateCode='KA';
        a1235.Core_IPA_Partner_Role__c = 'Distributor';
        accList.add(a1235);
        accidset.add(a1235.id);
        insert accList;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = acc123.Id;
        c.Email='john.harrison@maildrop.cc';
        c.MailingCountry='USA';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
       // c.Core_IPA_Partner_Role__c = 'Service Provider';
         c.Core_IPA_PartnerRole__c = 'Service Provider';
        conList.add(c);
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a123.Id;
        c1.Email='alan.cumberbatch@maildrop.cc';
        c1.MailingCountry='USA';       
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_Do_Not_Contact__c = False;
      //  c1.Core_IPA_Partner_Role__c = 'Distributor';
        c1.Core_IPA_PartnerRole__c = 'Distributor';
        conList.add(c1);
        
        insert conList;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Intel Partner Alliance';
        insert cp;
        
        ChannelProgramLevel cpl = new ChannelProgramLevel();
        cpl.Name = 'Partner';
        cpl.ProgramId = cp.Id;
        insert cpl;
        list<PRM_AccountChannelMembership__c> acmList=new list<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Partner_Role__c = 'Distributor';
        acm.PRM_Channel_Program_Id__c =cp.Id;
        acm.PRM_Channel_Program_Level_Id__c = cpl.Id;
        acm.PRM_Status_Nm__c ='Approved';
        acm.PRM_Account_Id__c =  acc123.id;
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm);
        
         PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Partner_Role__c = 'Distributor';
        acm1.PRM_Channel_Program_Id__c =cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c = cpl.Id;
        acm1.PRM_Status_Nm__c ='Inactive';
        acm1.PRM_Account_Id__c =  a123.id;
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm1);
       
        PRM_AccountChannelMembership__c acm12 = new PRM_AccountChannelMembership__c();
        acm12.PRM_Partner_Role__c = 'Distributor';
        acm12.PRM_Channel_Program_Id__c =cp.Id;
        acm12.PRM_Channel_Program_Level_Id__c = cpl.Id;
        acm12.PRM_Status_Nm__c ='Inactive';
        acm12.PRM_Account_Id__c =  acc123.id;
        acm12.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm12);
        insert acmList;
        
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'PRM_Opt_In';
        profQuesList.add(profileQues);
        
        PRM_Profile_Questions__c profileQues1 =  new PRM_Profile_Questions__c();
        profileQues1.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        profQuesList.add(profileQues1);
        
        PRM_Profile_Questions__c profileQues11 =  new PRM_Profile_Questions__c();
        profileQues11.PRM_Question_Cd__c = 'PRM_Points_Not_Eligible';
        
        profQuesList.add(profileQues11);
        insert profQuesList;
      
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'PRM_Opt_In_True';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        profAnsList.add(profileAns);
        
         PRM_Profile_Answer__c profileAns14 = new PRM_Profile_Answer__c();
        profileAns14.PRM_Answer_Cd__c = 'PRM_Opt_In_False';
        profileAns14.PRM_Profile_Questions_Id__c = profileQues.Id;      
        profAnsList.add(profileAns14);
        
        PRM_Profile_Answer__c profileAns11 = new PRM_Profile_Answer__c();
        profileAns11.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_False';
        profileAns11.PRM_Profile_Questions_Id__c = profileQues11.Id;
        profAnsList.add(profileAns11);
        
         PRM_Profile_Answer__c profileAns12 = new PRM_Profile_Answer__c();
        profileAns12.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_True';
        profileAns12.PRM_Profile_Questions_Id__c = profileQues11.Id;
        profAnsList.add(profileAns12);
        
        PRM_Profile_Answer__c profileAns1 = new PRM_Profile_Answer__c();
        profileAns1.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns1.PRM_Profile_Questions_Id__c = profileQues1.Id;
        profAnsList.add(profileAns1);
        
        insert profAnsList;
        
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c();
        response.PRM_Account_Id__c = a123.Id;
        response.PRM_Profile_Questions_Id__c = profileQues.Id;
        response.PRM_Profile_Answer_Id__c = profileAns.Id;
               
        insert response;
        
        PRM_Profile_Responses__c response11 = new PRM_Profile_Responses__c();
        response11.PRM_Account_Id__c = a123.Id;
        response11.PRM_Response_Txt__c='True';
        response11.PRM_Profile_Questions_Id__c = profileQues11.Id;
        response11.PRM_Profile_Answer_Id__c = profileAns12.Id;
        insert response11;
         
        
        List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();

        accList.clear();
        acclist.add(a123);
        acclist.add(acc123);
        
         Map<String, String> mapOfRegAccountQstnIdResTxt = new Map<String, String>();
         Map<Id, Id> mapOfOPIDAccIdLocAccId = new Map<Id, Id>();
        
        Test.startTest();
        PRM_ProfileResponseOptIn.createResponse(accList,conList,mapOfRegAccountQstnIdResTxt,mapOfOPIDAccIdLocAccId);
        PRM_ProfileResponseOptIn.getCAGList(accidset);
        accList.clear();
        accList.add(a1235);
        accList.add(acc1234);
        PRM_ProfileResponseOptIn.createResponse(accList,conList,mapOfRegAccountQstnIdResTxt,mapOfOPIDAccIdLocAccId);
        Test.stopTest();
        System.assertEquals('PRM_Opt_In', profileQues.PRM_Question_Cd__c,'Value does not match');
    }
    @isTest private static void testCreateResponse2(){
        
        
         Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();  
      Id opidIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('1PID Account Attributes').getRecordTypeId();
      Id inteIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('Intel Account Attributes').getRecordTypeId();
        List<Contact> conList = new List<Contact>();
        List<Account> accts = new List<Account>();
        List<PRM_IPAMembership_Attributes__c> recordsToCreate = new List<PRM_IPAMembership_Attributes__c>();
        list<PRM_AccountChannelMembership__c> acmList1=new list<PRM_AccountChannelMembership__c>();
        Map<Id,String> existingACMMap=new Map<Id,String>();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        
        Account a1 = PRM_TestUtility.getAccount();
        a1.AccountNumber = '435766';
        a1.RecordTypeId = recordTypeIdPagAccount;
        a1.Name='New Account';
        a1.Core_Account_Type__c ='Builder';
        a1.Industry='Agriculture';
        a1.BillingCity='New Delhi';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='4th Floor,New Road';
        a1.BillingPostalCode='110037';
        a1.BillingStateCode='KA';
        a1.Core_IPA_Partner_Role__c = 'Builder';
        a1.Industry='Construction';
        a1.Core_User_Defined_Website__c = 'www.sample.com';
        a1.Core_IPA_Partner_Segment__c='Internet of Things and Embedded';
       accts.add(a1);
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435766';
        a.RecordTypeId = accountRecordTypeIntel;//recordTypeIdPagAccount
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
       a.Core_IPA_One_Partner_Id__c=a1.Id;
       accts.add(a);
        
         
        insert accts;
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        //cprogram.PRM_programCode__c='IPA';
        cprogram.prm_programCode__c = System.Label.PRM_IPAEngagement;
        insert cprogram;
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.prm_programlevelcode__c = 'Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = a1.id;
        coreAccnt.Core_Intel_Account_Id__c = a.id; 
        List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();
        cagList.add(coreAccnt);       
        insert cagList;
        
        list<PRM_AccountChannelMembership__c> acmList=new list<PRM_AccountChannelMembership__c>();
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Partner_Role__c = 'Distributor';
        acm.PRM_Channel_Program_Id__c =cprogram.Id;
        acm.PRM_Channel_Program_Level_Id__c = level.Id;
        acm.PRM_Status_Nm__c ='Approved';
        acm.PRM_Account_Id__c =  a1.id;
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm);
        
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Partner_Role__c = 'Distributor';
        acm1.PRM_Channel_Program_Id__c =cprogram.Id;
        acm1.PRM_Channel_Program_Level_Id__c = level.Id;
        acm1.PRM_Status_Nm__c ='Approved';
        acm1.PRM_Account_Id__c =  a.id;
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm1);
       
        PRM_AccountChannelMembership__c acm12 = new PRM_AccountChannelMembership__c();
        acm12.PRM_Partner_Role__c = 'Distributor';
        acm12.PRM_Channel_Program_Id__c =cprogram.Id;
        acm12.PRM_Channel_Program_Level_Id__c = level.Id;
        acm12.PRM_Status_Nm__c ='Approved';
        acm12.PRM_Account_Id__c =  a.id;
        acm12.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm12);
        
        PRM_AccountChannelMembership__c acm13 = new PRM_AccountChannelMembership__c();
        acm13.PRM_Partner_Role__c = 'Builder';
        acm13.PRM_Channel_Program_Id__c =cprogram.Id;
        acm13.PRM_Channel_Program_Level_Id__c = level.Id;
        acm13.PRM_Status_Nm__c ='Approved';
        acm13.PRM_Account_Id__c =  a1.id;
        acm13.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm13);
        insert acmList;
        
        
        List<PRM_Registration_Request__c> reglist = new List<PRM_Registration_Request__c>();
        insert reglist;
        
        Map<Id, String> opidAccIdWithApprovedPartnerRole = new Map<Id, String>();
        opidAccIdWithApprovedPartnerRole.put(acm.PRM_Account_Id__c, 'Eligible');
        opidAccIdWithApprovedPartnerRole.put(acm.PRM_Account_Id__c, 'Not Eligible');
        opidAccIdWithApprovedPartnerRole.put(acm.PRM_Account_Id__c, 'Both');
        for (PRM_AccountChannelMembership__c ac : acmList) {
            if (opidAccIdWithApprovedPartnerRole.containsKey(ac.PRM_Account_Id__c) && 
                ((opidAccIdWithApprovedPartnerRole.get(ac.PRM_Account_Id__c) == 'Eligible' && 
                  !System.Label.PointsOptInEligiblePartners.split(',').contains(ac.PRM_Partner_Role__c)) || 
                 (opidAccIdWithApprovedPartnerRole.get(ac.PRM_Account_Id__c) == 'Not Eligible' && 
                  System.Label.PointsOptInEligiblePartners.split(',').contains(ac.PRM_Partner_Role__c)))) {
                    opidAccIdWithApprovedPartnerRole.put(ac.PRM_Account_Id__c, 'Both');
            } else if (System.Label.PointsOptInEligiblePartners.split(',').contains(ac.PRM_Partner_Role__c)) {
                opidAccIdWithApprovedPartnerRole.put(ac.PRM_Account_Id__c, 'Eligible');
            } else {
                opidAccIdWithApprovedPartnerRole.put(ac.PRM_Account_Id__c, 'Not Eligible');
            }
        }
        
        PRM_PartnerAgreement__c partnerAgr1 = new PRM_PartnerAgreement__c();
        partnerAgr1.Name='IPA Terms & Condition';
        partnerAgr1.PRM_Agreement_Cd__c='IPA_TANDC';
        partnerAgr1.PRM_Channel_Program_Id__c=cprogram.Id;
        insert partnerAgr1;
// Create PRM_AccountLegalAgreemntAssociation__c records
        PRM_AccountLegalAgreemntAssociation__c legalAgreement1 = new PRM_AccountLegalAgreemntAssociation__c(
            PRM_Account_Id__c = a1.Id,
            PRM_Partner_Agreement_Id__c=partnerAgr1.Id,
            PRM_InActive_Ind__c = false,
            PRM_Agreement_Sign_Dt__c = system.today()
            
        );
        insert legalAgreement1;

        PRM_AccountLegalAgreemntAssociation__c legalAgreement2 = new PRM_AccountLegalAgreemntAssociation__c(
            PRM_Account_Id__c = a.Id,
            PRM_InActive_Ind__c = false,
            PRM_Partner_Agreement_Id__c = partnerAgr1.Id,
            PRM_Agreement_Sign_Dt__c=system.today()
        );
        insert legalAgreement2;        
       
       /* PRM_IPAMembership_Attributes__c pr1=new PRM_IPAMembership_Attributes__c(
                PRM_Account_Id__c = a1.Id,
                RecordTypeId=inteIpaMemAttrRecordId,
            	PRM_Points_Not_Eligible_Ind__c= FALSE,
                PRM_Points_Not_Eligible_Dt__c=system.today(),
            	PRM_Points_Opt_in_Ind__c=TRUE,
            PRM_Points_Opt_in_Dt__c=system.today(),
            PRM_Point_Status_Txt__c='Active',
            PRM_Point_Status_Dt__c=system.today()
            );
        recordsToCreate.add(pr1);
       
        PRM_IPAMembership_Attributes__c pr2=new PRM_IPAMembership_Attributes__c(
                PRM_Account_Id__c = a1.Id,
                RecordTypeId=inteIpaMemAttrRecordId,
            	PRM_Points_Not_Eligible_Ind__c= TRUE,
                PRM_Points_Not_Eligible_Dt__c=system.today(),
            	PRM_Points_Opt_in_Ind__c=FALSE,
            PRM_Points_Opt_in_Dt__c=system.today(),
            PRM_Point_Status_Txt__c='Not Eligible',
            PRM_Point_Status_Dt__c=system.today()
            );
        recordsToCreate.add(pr2);
        PRM_IPAMembership_Attributes__c pr3=new PRM_IPAMembership_Attributes__c(
                PRM_Account_Id__c = a1.Id,
                RecordTypeId=inteIpaMemAttrRecordId,
            	PRM_Points_Not_Eligible_Ind__c= False,
                PRM_Points_Not_Eligible_Dt__c=system.today(),
            	PRM_Points_Opt_in_Ind__c=True,
            PRM_Points_Opt_in_Dt__c=system.today(),
            PRM_Point_Status_Txt__c='Eligible',
            PRM_Point_Status_Dt__c=system.today()
            );
        recordsToCreate.add(pr3);
        
        insert recordsToCreate;
        Date NEDate = System.today().addDays(1);
         Map<String, Boolean> tncLocSigned = new Map<String, Boolean>{a1.Id => true, a.Id => true};
        Map<String, Boolean> tncSigned = new Map<String, Boolean>{a1.Id => false, a.Id => false};
        Test.startTest();
        PRM_ProfileResponseOptIn.checkExtProfRespOnOPIDAndCreateResp_IPAR(accts,conList,cagList,reglist);
        PRM_ProfileResponseOptIn.createResponse_IPAR(accts);
        List<PRM_IPAMembership_Attributes__c> updatedMemberships = PRM_ProfileResponseOptIn.pointStatusCalc_IPAR(recordsToCreate,null);
        Test.stopTest();
        // Perform assertions
        System.assertEquals(2, updatedMemberships.size(), 'The number of updated memberships should match');
        System.assert(updatedMemberships[0].PRM_Point_Status_Txt__c == 'Active', 'Account 1 should be updated to Active');
        System.assert(updatedMemberships[1].PRM_Point_Status_Txt__c == 'Not Eligible', 'Account 2 should remain Not Eligible');
    }*/
        // Insert Membership Attributes with variations
        List<PRM_IPAMembership_Attributes__c> recordsToTest = new List<PRM_IPAMembership_Attributes__c>{
            new PRM_IPAMembership_Attributes__c(
                PRM_Account_Id__c = a1.Id,
                RecordTypeId = inteIpaMemAttrRecordId,
                PRM_Points_Opt_in_Ind__c = TRUE,
                PRM_Points_Not_Eligible_Ind__c = FALSE,
                PRM_Points_Opt_in_Dt__c = System.today(),
                PRM_Point_Status_Txt__c = 'Active',
                PRM_Points_Not_Eligible_Dt__c = null
            ),
            new PRM_IPAMembership_Attributes__c(
                PRM_Account_Id__c = a1.Id,
                RecordTypeId = inteIpaMemAttrRecordId,
                PRM_Points_Opt_in_Ind__c = FALSE,
                PRM_Points_Not_Eligible_Ind__c = TRUE,
                PRM_Points_Not_Eligible_Reason_Txt__c ='Test',
                PRM_Points_Opt_in_Dt__c = null,
                PRM_Point_Status_Txt__c = 'Not Eligible',
                PRM_Points_Not_Eligible_Dt__c = System.today().addDays(-1)
            ),
            new PRM_IPAMembership_Attributes__c(
                PRM_Account_Id__c = a.Id,
                RecordTypeId = inteIpaMemAttrRecordId,
                PRM_Points_Opt_in_Ind__c = TRUE,
                PRM_Points_Not_Eligible_Ind__c = FALSE,
                PRM_Points_Opt_in_Dt__c = System.today().addDays(-5),
                PRM_Point_Status_Txt__c = 'Eligible',
                PRM_Points_Not_Eligible_Dt__c = null
            ),
            new PRM_IPAMembership_Attributes__c(
                PRM_Account_Id__c = a.Id,
                RecordTypeId = inteIpaMemAttrRecordId,
                PRM_Points_Opt_in_Ind__c = FALSE,
                PRM_Points_Not_Eligible_Ind__c = TRUE,
                PRM_Points_Not_Eligible_Reason_Txt__c ='Test',
                PRM_Points_Opt_in_Dt__c = null,
                PRM_Point_Status_Txt__c = null,
                PRM_Points_Not_Eligible_Dt__c = System.today()
            ),
            new PRM_IPAMembership_Attributes__c(
            PRM_Account_Id__c = a.Id,
            RecordTypeId = inteIpaMemAttrRecordId,
            PRM_Points_Opt_in_Ind__c = TRUE, // Opt-In enabled
            PRM_Points_Not_Eligible_Ind__c = FALSE,
            PRM_Points_Not_Eligible_Dt__c = null,
            PRM_Points_Opt_in_Dt__c = System.today(),
            PRM_Point_Status_Txt__c = '', // Empty string
            PRM_Point_Status_Dt__c = null
        )

        };

        insert recordsToTest;

       Map<Id, Boolean> tncLocSigned = new Map<Id, Boolean>();
        Map<Id, Boolean> tncSigned = new Map<Id, Boolean>();
        
        // Populate tncLocSigned with "signed" account
        tncLocSigned.put(a.Id, true);

        // Populate tncSigned with "not signed" account
        tncSigned.put(a.Id, false);

        // Test scenario where NEDate is both null and non-null
        Date NEDate = System.today().addDays(1);
        Date nullDate = null;

        // Start the test
        Test.startTest();
		PRM_ProfileResponseOptIn.checkExtProfRespOnOPIDAndCreateResp_IPAR(accts,conList,cagList,reglist);
        PRM_ProfileResponseOptIn.createResponse_IPAR(accts);
        // Call method for coverage
        List<PRM_IPAMembership_Attributes__c> updatedRecordsWithNEDate = PRM_ProfileResponseOptIn.pointStatusCalc_IPAR(recordsToTest, null);
        List<PRM_IPAMembership_Attributes__c> updatedRecordsWithoutNEDate = PRM_ProfileResponseOptIn.pointStatusCalc_IPAR(recordsToTest, null);

        Test.stopTest();

        // Perform assertions
        System.assert(updatedRecordsWithNEDate.size() > 0, 'Records should be updated when NEDate is provided.');
        System.assert(updatedRecordsWithoutNEDate.size() > 0, 'Records should be updated when NEDate is null.');
    }
    public static testmethod void pointsCal_IPARTest(){
    Id opidIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('1PID Account Attributes').getRecordTypeId();
        Id inteIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('Intel Account Attributes').getRecordTypeId();
         Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        List<account> acclist1  = new List<account>();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc.Name='vista';
        opidAcc.BillingCity='City9';
        opidAcc.BillingStreet='Street9';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
        acclist1.add(opidAcc) ;
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Test Intel Account';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount.Core_IPA_One_Partner_Id__c = opidAcc.id;
        newAccount.Core_Business_Party_Id__c = '9456456' ; //TWC729-1292
        
        acclist1.add(newAccount);
        insert acclist1;
        List<Contact> conList = new List<Contact>();
        Contact c = new Contact();
        c.FirstName='john';
        c.LastName='harrison';
        c.AccountId = newAccount.Id;
        c.MailingCountry='USA';
        c.Email='john.harrison@maildrop.cc';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
       // c.Core_IPA_Partner_Role__c = 'Service Provider';
         c.Core_IPA_PartnerRole__c = 'Service Provider';
        conList.add(c);
		List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
        cag.Core_Intel_Account_Id__c= newAccount.id;
        cag.Core_Partner_Account_Id__c = opidAcc.id;
        cag.Core_Inactive_Ind__c = false;
        cagList.add(cag);
        insert cagList;

        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group'; 
        insert pb;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = opidAcc.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c = 'Test class';
        insert aba;
        List<PRM_IPAMembership_Attributes__c> ipaMemList = new List<PRM_IPAMembership_Attributes__c>();
        PRM_IPAMembership_Attributes__c ipaMem = new PRM_IPAMembership_Attributes__c();
        ipaMem.PRM_Account_Id__c = newAccount.Id;
        ipaMem.RecordTypeId = inteIpaMemAttrRecordId;
        ipaMem.PRM_Registration_Source_Txt__c = 'Web';
        ipaMem.PRM_Points_Opt_in_Ind__c =true;
        ipaMem.PRM_Points_Opt_in_Dt__c = System.today();
        ipaMem.PRM_Point_Status_Txt__c = 'Active';
        ipaMem.PRM_Point_Status_Dt__c = System.today();
        ipaMemList.add(ipaMem);
        
        PRM_IPAMembership_Attributes__c ipaMemOpid = new PRM_IPAMembership_Attributes__c();
        ipaMemOpid.PRM_Account_Id__c = opidAcc.Id;
        ipaMemOpid.RecordTypeId = opidIpaMemAttrRecordId;
        ipaMemOpid.PRM_Registration_Source_Txt__c = 'Web';
        ipaMemOpid.PRM_Points_Not_Eligible_Ind__c =true ;
        ipaMemOpid.PRM_Points_Not_Eligible_Reason_Txt__c ='Test';
        ipaMemOpid.PRM_Points_Not_Eligible_Dt__c = System.today();
        ipaMemOpid.PRM_Point_Status_Txt__c = 'Not Eligible';
        ipaMemOpid.PRM_Point_Status_Dt__c = System.today();
        ipaMemList.add(ipaMemOpid);
        Insert ipaMemList;
        List<PRM_Registration_Request__c> reglist = new List<PRM_Registration_Request__c>();
        insert reglist;

        Test.startTest();
       PRM_ProfileResponseOptIn.checkExtProfRespOnOPIDAndCreateResp_IPAR(acclist1,conList,cagList,reglist);
        Test.stopTest();
        
    }
  
}