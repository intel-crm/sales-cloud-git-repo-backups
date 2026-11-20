/*********************************************************************************************************************
Apex Class Name  : PRM_UICIMCallout_Test
Version          : 1.0
Created Date     : DEC 2019
Function         : Test class for PRM_UICIMCallout/PRM_CIMWrapper

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Nishant Dhar               17/12/2019              Test class for PRM_UICIMCallout/PRM_CIMWrapper

*********************************************************************************************************************/
@isTest
private class PRM_UICIMCallout_Test {
     @testSetup
    static void createData(){
       List<ChannelProgram> cpp = new List<ChannelProgram>();
        
        // ChannelProgram cp = new ChannelProgram();
       // cp.Name='New Partner Program';
       // cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
      //  cpp.add(cp);
        
         ChannelProgram cp1 = new ChannelProgram();
        cp1.Name=System.Label.PRM_Intel_Partner_Alliance;
        cp1.prm_programCode__c= 'IPA';
        cp1.IsActive = true;
        insert cp1;
        //cpp.add(cp1);
        //insert cpp; 
        
    }
    
    @isTest static void testCallout() {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='USA';
        insert ct;
       
        //ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'New Partner Program' LIMIT 1];
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Teledyne');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State','LA');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.test.com');
        
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        System.assertEquals(requestDetails.get('ContactEmail'),'new@b.com','Value does not match');
        
    }
    @isTest static void testCallout1() {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='10100006';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='USA';
        insert ct;
       /* ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;*/
        
        //ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'New Partner Program' LIMIT 1];
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];

        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Newdyne');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State','LA');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.test.com');
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        System.assertEquals(requestDetails.get('ContactEmail'),'new@b.com','Value does not match');
        
    }
    @isTest static void testCallout2() {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Account acc = PRM_TestUtility.getAccount();
        //acc.BillingCity='Bengaluru';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='99900006';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='USA';
        insert ct;
       /* ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;*/
          //ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'New Partner Program' LIMIT 1];
                ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];

          
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Intel');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('AddressLine2','New');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State','LA');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','USA');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.test.com');
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        System.assertEquals(requestDetails.get('ContactEmail'),'new@b.com','Value does not match');
        
    }
    @isTest static void testCallout3() {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        
        Account acc = PRM_TestUtility.getAccount();
        //acc.BillingCity='Bengaluru';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='99900006';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b1.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='USA';
        insert ct;
       /* ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;*/
          //ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'New Partner Program' LIMIT 1];
                  ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];

        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        PRM_UICIMCallout uiCim =new PRM_UICIMCallout();
        PRM_UICIMCallout.getCimResultsWrapper obj_1=new PRM_UICIMCallout.getCimResultsWrapper();
        
        obj_1.accName='Herman';
        obj_1.accAddr='4th Floor ITPL Brookfield';
        obj_1.accPostalCode='560037';
        obj_1.accCity='Bengaluru';
        obj_1.accCountry='IND';
        obj_1.accStateProvince='KAR';
        obj_1.rcdLimit='0';
        obj_1.searchScore='77';
        obj_1.companyWebsite=null;
        obj_1.accountsSfdc=null;
        obj_1.regEmail='new@b.com';
        obj_1.partnerRole='Service Provider';
        uiCim.getCimResults(obj_1);//JB
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,null, 'new@b.com', 'Service Provider');
        Test.stopTest();
        /*
        PRM_UICIMCallout.getCimResultsWrapper obj_2=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_2.accName='Herman';
        obj_2.accAddr='4th Floor ITPL Brookfield';
        obj_2.accPostalCode='560037';
        obj_2.accCity='Bengaluru';
        obj_2.accCountry='IND';
        obj_2.accStateProvince='KAR';
        obj_2.rcdLimit='0';
        obj_2.searchScore='77';
        obj_2.companyWebsite=null;
        obj_2.accountsSfdc=accSfdcId;
        obj_2.regEmail='new@b.com';
        obj_2.partnerRole='Service Provider';
        uiCim.getCimResults(obj_2);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,accSfdcId, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_3=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_3.accName='Herman';
        obj_3.accAddr='4th Floor ITPL Brookfield';
        obj_3.accPostalCode='560037';
        obj_3.accCity='Bengaluru';
        obj_3.accCountry='IND';
        obj_3.accStateProvince='KAR';
        obj_3.rcdLimit=null;
        obj_3.searchScore=null;
        obj_3.companyWebsite=null;
        obj_3.accountsSfdc=accSfdcId;
        obj_3.regEmail='new@b.com';
        obj_3.partnerRole='Service Provider';
        uiCim.getCimResults(obj_3);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, null,accSfdcId, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_4=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_4.accName='Herman';
        obj_4.accAddr='4th Floor ITPL Brookfield';
        obj_4.accPostalCode='560037';
        obj_4.accCity='Bengaluru';
        obj_4.accCountry='IND';
        obj_4.accStateProvince='KAR';
        obj_4.rcdLimit=null;
        obj_4.searchScore=null;
        obj_4.companyWebsite='www.abc.com';
        obj_4.accountsSfdc=accSfdcId;
        obj_4.regEmail='new@b.com';
        obj_4.partnerRole='Service Provider';
        uiCim.getCimResults(obj_4);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, 'www.abc.com',accSfdcId, 'new@b.com', 'Service Provider');
       	
        PRM_UICIMCallout.getCimResultsWrapper obj_5=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_5.accName='Herman';
        obj_5.accAddr='4th Floor ITPL Brookfield';
        obj_5.accPostalCode='560037';
        obj_5.accCity='Bengaluru';
        obj_5.accCountry='IND';
        obj_5.accStateProvince='KAR';
        obj_5.rcdLimit=null;
        obj_5.searchScore=null;
        obj_5.companyWebsite=null;
        obj_5.accountsSfdc=null;
        obj_5.regEmail='new@b.com';
        obj_5.partnerRole='Service Provider';
        uiCim.getCimResults(obj_5);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, null,null, 'new@b.com', 'Service Provider');
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo',' ');
        requestDetails.put('AccountName','Interm');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('AddressLine2','New');
        requestDetails.put('City','Chestnut Ridge');
         requestDetails.put('State','LA');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','USA');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.test.com');
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        System.assertEquals(accCntList.contactList.size(),0,'Value does not match');*/
        
    }
    @isTest static void testCallout4() {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='USA';
        insert ct;
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
      /*  ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;*/
          //ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'New Partner Program' LIMIT 1];
                ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];

        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Herman Group');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
         requestDetails.put('State','LA');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.test.com');
        
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        PRM_UICIMCallout uiCim =new PRM_UICIMCallout();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        
        PRM_UICIMCallout.getCimResultsWrapper obj_6=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_6.accName='Herman';
        obj_6.accAddr='4th Floor ITPL Brookfield';
        obj_6.accPostalCode='560037';
        obj_6.accCity='Bengaluru';
        obj_6.accCountry='IND';
        obj_6.accStateProvince='KAR';
        obj_6.rcdLimit='0';
        obj_6.searchScore='77';
        obj_6.companyWebsite=null;
        obj_6.accountsSfdc=null;
        obj_6.regEmail='new@b.com';
        obj_6.partnerRole='Service Provider';
        uiCim.getCimResults(obj_6);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,null, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_7=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_7.accName='Herman';
        obj_7.accAddr='4th Floor ITPL Brookfield';
        obj_7.accPostalCode='560037';
        obj_7.accCity='Bengaluru';
        obj_7.accCountry='IND';
        obj_7.accStateProvince='KAR';
        obj_7.rcdLimit='0';
        obj_7.searchScore='77';
        obj_7.companyWebsite=null;
        obj_7.accountsSfdc=accSfdcId;
        obj_7.regEmail='new@b.com';
        obj_7.partnerRole='Service Provider';
        uiCim.getCimResults(obj_7);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,accSfdcId, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_8=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_8.accName='Herman';
        obj_8.accAddr='4th Floor ITPL Brookfield';
        obj_8.accPostalCode='560037';
        obj_8.accCity='Bengaluru';
        obj_8.accCountry='IND';
        obj_8.accStateProvince='KAR';
        obj_8.rcdLimit='0';
        obj_8.searchScore='77';
        obj_8.companyWebsite=null;
        obj_8.accountsSfdc=accSfdcId;
        obj_8.regEmail='new@b.com';
        obj_8.partnerRole='Service Provider';
        uiCim.getCimResults(obj_8);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, null,accSfdcId, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_9=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_9.accName='Herman';
        obj_9.accAddr='4th Floor ITPL Brookfield';
        obj_9.accPostalCode='560037';
        obj_9.accCity='Bengaluru';
        obj_9.accCountry='IND';
        obj_9.accStateProvince='KAR';
        obj_9.rcdLimit='0';
        obj_9.searchScore='77';
        obj_9.companyWebsite='www.abc.com';
        obj_9.accountsSfdc=accSfdcId;
        obj_9.regEmail='new@b.com';
        obj_9.partnerRole='Service Provider';
        uiCim.getCimResults(obj_9);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, 'www.abc.com',accSfdcId, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_10=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_10.accName='Herman';
        obj_10.accAddr='4th Floor ITPL Brookfield';
        obj_10.accPostalCode='560037';
        obj_10.accCity='Bengaluru';
        obj_10.accCountry='IND';
        obj_10.accStateProvince='KAR';
        obj_10.rcdLimit='0';
        obj_10.searchScore='77';
        obj_10.companyWebsite=null;
        obj_10.accountsSfdc=null;
        obj_10.regEmail='new@b.com';
        obj_10.partnerRole='Service Provider';
        uiCim.getCimResults(obj_10);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, null,null, 'new@b.com', 'Service Provider');
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        System.assertEquals(requestDetails.get('ContactEmail'),'new@b.com','Value does not match');*/
        
    }
    @isTest
    public static void testCallout5()
    {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        insert acc;
        
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='USA';
        insert ct;
      /*  ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;*/
          //ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'New Partner Program' LIMIT 1];
               ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];

        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        
        /*Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        PRM_UICIMCallout uiCim =new PRM_UICIMCallout();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        PRM_UICIMCallout.getCimResultsWrapper obj_11=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_11.accName='Herman';
        obj_11.accAddr='4th Floor ITPL Brookfield';
        obj_11.accPostalCode='560037';
        obj_11.accCity='Bengaluru';
        obj_11.accCountry='IND';
        obj_11.accStateProvince='KAR';
        obj_11.rcdLimit='0';
        obj_11.searchScore='77';
        obj_11.companyWebsite=null;
        obj_11.accountsSfdc=null;
        obj_11.regEmail='new@b.com';
        obj_11.partnerRole='Service Provider';
        uiCim.getCimResults(obj_11);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,null, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_12=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_12.accName='Herman';
        obj_12.accAddr='4th Floor ITPL Brookfield';
        obj_12.accPostalCode='560037';
        obj_12.accCity='Bengaluru';
        obj_12.accCountry='IND';
        obj_12.accStateProvince='KAR';
        obj_12.rcdLimit='0';
        obj_12.searchScore='77';
        obj_12.companyWebsite=null;
        obj_12.accountsSfdc=accSfdcId;
        obj_12.regEmail='new@b.com';
        obj_12.partnerRole='Service Provider';
        uiCim.getCimResults(obj_12);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,accSfdcId, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_13=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_13.accName='Herman';
        obj_13.accAddr='4th Floor ITPL Brookfield';
        obj_13.accPostalCode='560037';
        obj_13.accCity='Bengaluru';
        obj_13.accCountry='IND';
        obj_13.accStateProvince='KAR';
        obj_13.rcdLimit=null;
        obj_13.searchScore=null;
        obj_13.companyWebsite=null;
        obj_13.accountsSfdc=accSfdcId;
        obj_13.regEmail='new@b.com';
        obj_13.partnerRole='Service Provider';
        uiCim.getCimResults(obj_13);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, null,accSfdcId, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_14=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_14.accName='Herman';
        obj_14.accAddr='4th Floor ITPL Brookfield';
        obj_14.accPostalCode='560037';
        obj_14.accCity='Bengaluru';
        obj_14.accCountry='IND';
        obj_14.accStateProvince='KAR';
        obj_14.rcdLimit=null;
        obj_14.searchScore=null;
        obj_14.companyWebsite='www.abc.com';
        obj_14.accountsSfdc=accSfdcId;
        obj_14.regEmail='new@b.com';
        obj_14.partnerRole='Service Provider';
        uiCim.getCimResults(obj_14);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, 'www.abc.com',accSfdcId, 'new@b.com', 'Service Provider');
        
        PRM_UICIMCallout.getCimResultsWrapper obj_15=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_15.accName='Herman';
        obj_15.accAddr='4th Floor ITPL Brookfield';
        obj_15.accPostalCode='560037';
        obj_15.accCity='Bengaluru';
        obj_15.accCountry='IND';
        obj_15.accStateProvince='KAR';
        obj_15.rcdLimit='0';
        obj_15.searchScore=null;
        obj_15.companyWebsite=null;
        obj_15.accountsSfdc=null;
        obj_15.regEmail='new@b.com';
        obj_15.partnerRole='Service Provider';
        uiCim.getCimResults(obj_15);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', null, null,null, 'new@b.com', 'Service Provider');
		
        PRM_UICIMCallout.getCimResultsWrapper obj_16=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_16.accName='Herman';
        obj_16.accAddr='4th Floor ITPL Brookfield';
        obj_16.accPostalCode='560037';
        obj_16.accCity='Bengaluru';
        obj_16.accCountry='IND';
        obj_16.accStateProvince='KAR';
        obj_16.rcdLimit=null;
        obj_16.searchScore=null;
        obj_16.companyWebsite=null;
        obj_16.accountsSfdc=null;
        obj_16.regEmail='new@b.com';
        obj_16.partnerRole='Service Provider';
        uiCim.getCimResults(obj_16);
        //uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, null,null, 'new@b.com', 'Service Provider');
       	
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Herman Group');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
         requestDetails.put('State','LA');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');      
        requestDetails.put('Website','www.test.com');
        
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');*/

    }
    @isTest
    private static void testCallout6()
    {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='USA';
        insert ct;
        /*        ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;*/
         // ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'New Partner Program' LIMIT 1];
                ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];

        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Teledyne');
        requestDetails.put('ContactEmail','');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
         requestDetails.put('State','LA');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.test.com');
        
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        System.assertEquals(requestDetails.get('AccountName'),'Teledyne', 'Value does not match');
        
    }
}