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
        acc.Industry = '';
        acc.Core_CIM_ID__c='22213672';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        insert ct;
                ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;
        
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
        requestDetails.put('State',null);
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        
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
        acc.Industry = '';
        acc.Core_CIM_ID__c='10100006';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        insert ct;
        ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;
        
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
        requestDetails.put('State',null);
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        
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
        acc.Industry = '';
        acc.Core_CIM_ID__c='99900006';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        insert ct;
        ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;
        
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
        requestDetails.put('State',null);
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','USA');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        
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
        acc.Industry = '';
        acc.Core_CIM_ID__c='99900006';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b1.com';
        ct.AccountId=acc.id;
        insert ct;
        ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;
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
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo',' ');
        requestDetails.put('AccountName','Interm');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('AddressLine2','New');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State',null);
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','USA');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        System.assertEquals(accCntList.contactList.size(),0);
        
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
        acc.Industry = '';
        acc.Core_CIM_ID__c='22213672';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        insert ct;
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Herman Group');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State',null);
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        PRM_UICIMCallout uiCim =new PRM_UICIMCallout();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,null, 'new@b.com', 'Service Provider');
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,accSfdcId, 'new@b.com', 'Service Provider');
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, null,accSfdcId, 'new@b.com', 'Service Provider');
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, 'www.abc.com',accSfdcId, 'new@b.com', 'Service Provider');
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        
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
        acc.Industry = '';
        acc.Core_CIM_ID__c='22213672';
        insert acc;
        
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        insert ct;
        ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;
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
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        PRM_UICIMCallout uiCim =new PRM_UICIMCallout();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,null, 'new@b.com', 'Service Provider');
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77', null,accSfdcId, 'new@b.com', 'Service Provider');
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, null,accSfdcId, 'new@b.com', 'Service Provider');
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, null, 'www.abc.com',accSfdcId, 'new@b.com', 'Service Provider');
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Herman Group');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State',null);
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        
        
        
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
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
        acc.Industry = '';
        acc.Core_CIM_ID__c='22213672';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        insert ct;
                ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.prm_programCode__c= System.Label.PRM_IPAEngagement;
        insert cp;
        
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
        requestDetails.put('State',null);
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        
    }
}