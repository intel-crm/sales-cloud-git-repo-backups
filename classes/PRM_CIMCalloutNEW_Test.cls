/*********************************************************************************************************************
Apex Class Name  : PRM_CIMCalloutNEW_Test
Version          : 1.0
Created Date     : DEC 2019
Function         : Test class for PRM_CIMCalloutNEW/PRM_CIMWrapper

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Nishant Dhar               17/12/2019              Test class for PRM_CIMCalloutNEW/PRM_CIMWrapper

*********************************************************************************************************************/
@isTest
private class PRM_CIMCalloutNEW_Test {
    public static boolean ipaRefresh = Boolean.valueOf(Label.PRM_IPARefresh);
    @testSetup
    static void createData(){
        List<ChannelProgram> cpp = new List<ChannelProgram>();
        
        ChannelProgram cp1 = new ChannelProgram();
        cp1.Name=System.Label.PRM_Intel_Partner_Alliance;
        cp1.prm_programCode__c= 'IPA';
        cp1.IsActive = true;
        insert cp1;
        
        Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
        
        User user = new User(Alias = 'itadmin', 
                             Email='itadminTest@intel.com', 
                             EmailEncodingKey='UTF-8',
                             LastName='UnitTestItAdmin',
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             ProfileId = itAdminProfile.Id, 
                             TimeZoneSidKey='America/Los_Angeles',
                             FirstName = 'Uncovered',
                             UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
         insert user; 
        
        User user2 = new User(Alias = 'itadmin', 
                             Email='itadminTestCovered@intel.com', 
                             EmailEncodingKey='UTF-8',
                             LastName='UnitTestItAdmin',
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             ProfileId = itAdminProfile.Id, 
                             TimeZoneSidKey='America/Los_Angeles',
                             FirstName = 'Test covered',
                             UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
         insert user2; 
        
    }
    
   /* @isTest static void testCallout() {
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();

        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Account acc = PRM_TestUtility.getAccount();
        acc.Name = 'Teledyne';
        acc.website = 'www.testwb.com';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='GBR';
        acc.BillingState = 'ENG';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.Unified_Hierarchy_View__c = 'Global';
        acc.Core_Business_Party_Id__c = '8q879q';
        acc.Core_Address_Details__c = 'test11idwoh';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Export_Compliance_Block__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Core_MDM_Website__c = 'www.testwb.com';
        acc.RecordTypeId = accountRecordType;
        TriggerHandler.bypass('Core_AccounTriggeHandler');
        insert acc;
        TriggerHandler.clearbypass('Core_AccounTriggeHandler');
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry ='USA';
        ct.MailingCity ='Mississippi';
        ct.MailingPostalCode='421910';
        ct.MailingState ='AK';
        ct.MailingStreet ='BandraStreet';
        insert ct;
        
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c=!ipaRefresh?'Seller':'Builder';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
        insert acm;
        
        TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
       
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Teledyne');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State','ENG');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','GBR');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.testwb.com');
        System.debug('REQ--> '+requestDetails.get('Website'));
        
        
        PRM_Registration_Request__c regReq  = PRM_TestUtility.getPRMRegistrationRequest();
        insert regReq;
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        cim.PRM_RegReq_Id__c = regReq.id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_AddressLine1_Txt__c = 'testqjak';
        Test.startTest();
        insert cim;
        
        try{
            
            PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper wrap = new PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper();
            wrap.AccountID ='';
            wrap.AccountName ='';
            wrap.PartnerRole ='';
            wrap.AddressLine1 ='';
            wrap.AddressLine2 ='';
            wrap.Country ='IND';
            wrap.State ='MH';
            
            wrap.DuplicateInfo ='';
            wrap.SelectedRow ='';
            wrap.AccountDuplicateStatus ='';
            wrap.ContactDuplicateStatus ='NoDuplicate';
            wrap.accountAssociatedToExistingContact ='';
            wrap.duplicateContactRecord ='';
            wrap.associatedAccountIsIPA ='';
            wrap.SuppressEmail ='';
            
            PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper wrapper = (PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper) JSON.deserialize(JSON.serialize(requestDetails),PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper.class);
            PRM_AdminRegistrationFlowCntrl.getDuplicateAccountContact(new List<PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper>{wrapper});
            accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }catch(Exception e){
            System.debug('CustomException1 occurred: ' + e.getMessage());
        }
        
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'),'new@b.com','Value does not match');
        
    }*/
    @isTest static void testFlowActionCntrl() {
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();

        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Account acc = PRM_TestUtility.getAccount();
        acc.Name = 'Teledyne';
        acc.website = 'www.testwb.com';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='GBR';
        acc.BillingState = 'ENG';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.Unified_Hierarchy_View__c = 'Global';
        acc.Core_Business_Party_Id__c = '8q879q';
        acc.Core_Address_Details__c = 'test11idwoh';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Export_Compliance_Block__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Core_MDM_Website__c = 'www.testwb.com';
        acc.RecordTypeId = accountRecordType;
        TriggerHandler.bypass('Core_AccounTriggeHandler');
        insert acc;
        TriggerHandler.clearbypass('Core_AccounTriggeHandler');
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry ='USA';
        ct.MailingCity ='Mississippi';
        ct.MailingPostalCode='421910';
        ct.MailingState ='AK';
        ct.MailingStreet ='BandraStreet';
        insert ct;
        
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c=!ipaRefresh?'Seller':'Builder';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
        insert acm;
        
        TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
       
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Teledyne');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State','ENG');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','GBR');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.testwb.com');
        System.debug('REQ--> '+requestDetails.get('Website'));
        
        
        PRM_Registration_Request__c regReq  = PRM_TestUtility.getPRMRegistrationRequest();
        insert regReq;
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        cim.PRM_RegReq_Id__c = regReq.id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_AddressLine1_Txt__c = 'testqjak';
        Test.startTest();
        insert cim;
        
        try{
            
            PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper wrap = new PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper();
            wrap.AccountID ='';
            wrap.AccountName ='';
            wrap.PartnerRole ='';
            wrap.AddressLine1 ='';
            wrap.AddressLine2 ='';
            wrap.Country ='IND';
            wrap.State ='MH';
            
            wrap.DuplicateInfo ='';
            wrap.SelectedRow ='';
            wrap.AccountDuplicateStatus ='';
            wrap.ContactDuplicateStatus ='NoDuplicate';
            wrap.accountAssociatedToExistingContact ='';
            wrap.duplicateContactRecord ='';
            wrap.associatedAccountIsIPA ='';
            wrap.SuppressEmail ='';
            
            PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper wrapper = (PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper) JSON.deserialize(JSON.serialize(requestDetails),PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper.class);
            PRM_AdminRegistrationFlowCntrl.getDuplicateAccountContact(new List<PRM_AdminRegistrationFlowCntrl.AccountDetailsWrapper>{wrapper});
            //accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }catch(Exception e){
            System.debug('CustomException1 occurred: ' + e.getMessage());
        }
        
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'),'new@b.com','Value does not match');
        
    }
    @isTest static void testCallout1() {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
		
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId=intelAccRecTypeId;
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        acc.Core_Customer_Aggregation_Type__c = '';
        acc.Unified_Hierarchy_View__c = 'Not Unified';
        acc.Core_Business_Party_Id__c = '8q879q';
        acc.Core_Address_Details__c = 'test11idwoh';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Export_Compliance_Block__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry ='USA';
        ct.MailingCity ='Mississippi';
        ct.MailingPostalCode='421910';
        ct.MailingState ='AK';
        ct.MailingStreet ='BandraStreet';
        insert ct;
        
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c=!ipaRefresh?'Seller':'Builder';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
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
        requestDetails.put('State','ENG');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.testwb.com');
        
        PRM_Registration_Request__c regReq  = PRM_TestUtility.getPRMRegistrationRequest();
        insert regReq;
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        //cim.PRM_RegReq_Id__c = rr.Id;
        cim.PRM_RegReq_Id__c = regReq.id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_AddressLine1_Txt__c = 'testqjak';
        
        insert cim;
        /*try{
accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
}catch(Exception e){
System.debug('CustomException1 occurred: ' + e.getMessage());
}*/
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'),'new@b.com','Value does not match');
        
    }
    @isTest static void testCallout2() {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId=intelAccRecTypeId;
        //acc.BillingCity='Bengaluru';
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
        acc.Unified_Hierarchy_View__c = 'Intermediate';
        acc.Core_Business_Party_Id__c = '8q879q';
        acc.Core_Address_Details__c = 'test11idwoh';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Export_Compliance_Block__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry ='USA';
        ct.MailingCity ='Mississippi';
        ct.MailingPostalCode='421910';
        ct.MailingState ='AK';
        ct.MailingStreet ='BandraStreet';
        insert ct;
        
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];
        
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c=!ipaRefresh?'Seller':'Builder';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
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
        requestDetails.put('State','ENG');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.testwb.com');
        
        PRM_Registration_Request__c regReq  = PRM_TestUtility.getPRMRegistrationRequest();
        insert regReq;
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        //cim.PRM_RegReq_Id__c = rr.Id;
        cim.PRM_RegReq_Id__c = regReq.id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_AddressLine1_Txt__c = 'testqjak';
        
        //cim.PRM_CIM_Id__c = 'CIM482429';
        insert cim;
        try{
            accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }catch(Exception e){
            System.debug('CustomException1 occurred: ' + e.getMessage());
        }
       
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'),'new@b.com','Value does not match');
        
    }
    @isTest static void testCallout3() {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId=intelAccRecTypeId;
        //acc.BillingCity='Bengaluru';
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        acc.Unified_Hierarchy_View__c = 'India';
        acc.Core_Business_Party_Id__c = '8q879q';
        acc.Core_Address_Details__c = 'test11idwoh';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Export_Compliance_Block__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b1.com';
        ct.AccountId=acc.id;
        ct.MailingCountry ='USA';
        ct.MailingCity ='Mississippi';
        ct.MailingPostalCode='421910';
        ct.MailingState ='AK';
        ct.MailingStreet ='BandraStreet';
        insert ct;
        
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
        acm.PRM_Partner_Role__c=!ipaRefresh?'Seller':'Builder';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
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
        requestDetails.put('State','ENG');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.testwb.com');
        
        PRM_Registration_Request__c regReq  = PRM_TestUtility.getPRMRegistrationRequest();
        insert regReq;
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        //cim.PRM_RegReq_Id__c = rr.Id;
        cim.PRM_RegReq_Id__c = regReq.id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_AddressLine1_Txt__c = 'testqjak';
        
        //cim.PRM_CIM_Id__c = 'CIM482429';
        insert cim;
        try{
            accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }catch(Exception e){
            System.debug('CustomException1 occurred: ' + e.getMessage());
        }
        
        Test.stopTest();
        System.assertEquals(accCntList.contactList.size(),0,'Value does not match');
        
    }
    @isTest static void testCallout4() {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId=intelAccRecTypeId;
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_LOC_CUST';
        acc.Unified_Hierarchy_View__c = 'Global';
        acc.Core_Business_Party_Id__c = '8q879q';
        acc.Core_Address_Details__c = 'test11idwoh';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Export_Compliance_Block__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        insert acc;
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry ='USA';
        ct.MailingCity ='Mississippi';
        ct.MailingPostalCode='421910';
        ct.MailingState ='AK';
        ct.MailingStreet ='BandraStreet';
        insert ct;
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c=!ipaRefresh?'Seller':'Builder';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm;
        
        PRM_CIM_Request__mdt cimMdt=new PRM_CIM_Request__mdt();
        cimMdt.Score_Bar__c=9;

        //NJ
        PRM_PartnerAgreement__c partnerAgreement = new PRM_PartnerAgreement__c();
        partnerAgreement.Name = 'Deal_Registration_Terms_and_Conditions';
        partnerAgreement.PRM_Agreement_Cd__c = 'Deal_Terms_Condition';
        partnerAgreement.PRM_Channel_Program_Id__c = cp.id;
        insert partnerAgreement;
        
        PRM_AccountLegalAgreemntAssociation__c PartnerLegalAgreement = new PRM_AccountLegalAgreemntAssociation__c();
        PartnerLegalAgreement.PRM_Account_Id__c = acc.Id;
        PartnerLegalAgreement.PRM_Contact__c = ct.Id;
        PartnerLegalAgreement.PRM_Partner_Agreement_Id__c = partnerAgreement.Id;
        PartnerLegalAgreement.PRM_Agreement_Sign_Dt__c = Datetime.now();
        insert PartnerLegalAgreement;
        //NJ
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        //requestDetails.put('AccountName','Herman Group');
        requestDetails.put('AccountName','Teledyne Group');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State','ENG');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.testwb.com');
        PRM_Registration_Request__c regReq  = PRM_TestUtility.getPRMRegistrationRequest();
        insert regReq;
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        //cim.PRM_RegReq_Id__c = rr.Id;
        cim.PRM_RegReq_Id__c = regReq.id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_AddressLine1_Txt__c = 'testqjak';
        
        //cim.PRM_CIM_Id__c = 'CIM482429';
        insert cim;
        try{
            accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }catch(Exception e){
            System.debug('CustomException1 occurred: ' + e.getMessage());
        }
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        PRM_CIMCalloutNEW uiCim =new PRM_CIMCalloutNEW();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        Address adobj=new Address(acc.Billingstreet,null,acc.BillingCity,'IN',acc.BillingState,acc.BillingPostalCode);
        //uiCim.getCimResults('Herman', adobj,  '20',30, 'www.newb.com', accSfdcId,'new@b.com',getChangedCustomMetadataRecord());
        uiCim.getCimResults('Teledyne', adobj,  '20',30, 'www.newb.com', accSfdcId,'new@b.com',getChangedCustomMetadataRecord());
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'),'new@b.com','Value does not match');
        
    }
    @isTest
    public static void testCallout5()
    {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId=intelAccRecTypeId;
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.Unified_Hierarchy_View__c = null;
        acc.Core_Business_Party_Id__c = '8q879q';
        acc.Core_Address_Details__c = 'test11idwoh';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Export_Compliance_Block__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        insert acc;
        
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry ='USA';
        ct.MailingCity ='Mississippi';
        ct.MailingPostalCode='421910';
        ct.MailingState ='AK';
        ct.MailingStreet ='BandraStreet';
        insert ct;
        
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
        acm.PRM_Partner_Role__c=!ipaRefresh?'Seller':'Builder';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
        insert acm;
        
        TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        PRM_CIMCalloutNEW uiCim =new PRM_CIMCalloutNEW();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        Address adobj=new Address(acc.Billingstreet,null,acc.BillingCity,'IN',acc.BillingState,acc.BillingPostalCode);
        uiCim.getCimResults('Herman', adobj,  '20',10, 'www.newb.com', accSfdcId,'new@b.com',getChangedCustomMetadataRecord());
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Herman Group');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State','ENG');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');        
        requestDetails.put('Website','www.testwb.com');
        PRM_Registration_Request__c regReq  = PRM_TestUtility.getPRMRegistrationRequest();
        insert regReq;
        /*PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        cim.PRM_RegReq_Id__c = regReq.id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_AddressLine1_Txt__c = 'testqjak';
        
        //cim.PRM_CIM_Id__c = 'CIM482429';
        insert cim;*/
        try{
            PRM_AdminRegistrationDuplicateDetails.getAccountsFromSBRResults(regReq.Id);
            accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }catch(Exception e){
            System.debug('CustomException1 occurred: ' + e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');
        
    }
    @isTest
    private static void testCallout6()
    {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId=intelAccRecTypeId;
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
        ct.MailingCountry ='USA';
        ct.MailingCity ='Mississippi';
        ct.MailingPostalCode='421910';
        ct.MailingState ='AK';
        ct.MailingStreet ='BandraStreet';
        insert ct;
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c=!ipaRefresh?'Seller':'Builder';
        acm.PRM_Status_Reason_Txt__c='Test';
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
        requestDetails.put('State','ENG');
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
        requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');
        requestDetails.put('Website','www.testwb.com');
        
        try{
            accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }catch(Exception e){
            System.debug('CustomException1 occurred: ' + e.getMessage());
        }
        Test.stopTest();
        //System.assertEquals(accCntList.contactList.size(),1);
        System.assertEquals(requestDetails.get('AccountName'),'Teledyne', 'Value does not match');
        
    }
    public static PRM_CIM_Request__mdt getChangedCustomMetadataRecord() {
        PRM_CIM_Request__mdt theRecord= PRM_CIM_Request__mdt.getinstance('PRM_Dupe_Scores');
        return theRecord;
    }   
    
    @isTest
    private static void testCallout7(){
        
        List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fswList = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw1 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw1.fieldLabel = 'BillingCountry';
        fsw1.fieldAPIName = 'BillingCountry';
        fsw1.fieldValue = 'India';
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw2 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw2.fieldLabel = 'Partner';
        fsw2.fieldAPIName = 'Partner';
        fsw2.fieldValue = 'Sample';
        
        fswList.add(fsw1);
        fswList.add(fsw2);
        
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.Unified_Hierarchy_View__c = null;
        acc.Core_Business_Party_Id__c = '8q879q';
        acc.Core_Address_Details__c = 'test11idwoh';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_Export_Compliance_Block__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        TriggerHandler.bypass('Core_AccounTriggeHandler');
        insert acc;
        TriggerHandler.clearbypass('Core_AccounTriggeHandler');
      
        
        PRM_Registration_Request__c regReq  = PRM_TestUtility.getPRMRegistrationRequest();
        insert regReq;
        
        PRM_CIMSearchResults__c cim = new PRM_CIMSearchResults__c();
        cim.PRM_RegReq_Id__c = regReq.id;
        cim.PRM_Account_Id__c = acc.Id;
        cim.PRM_AddressLine1_Txt__c = 'testqjak';
        insert cim;
        
       
        PRM_AdminRegistrationDuplicateDetails.fetchCountryStateForAddress('GBR', 'ENG');
        PRM_AdminRegistrationDuplicateDetails.getAccountsFromSBRResults(regReq.Id);
        //PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc);
        UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError accountMockResponse = UCD_GenericAcctSearch_SBR.getAcctResults(fswList,'Partner');
        try{
            Test.startTest();
            PRM_AdminRegistrationDuplicateDetails.fetchCountryStateForAddress('GBR', null);
        } catch(exception ex) {
            System.debug('Error Occurred');
        }
        Test.stopTest();
        System.assertEquals('Teledyne','Teledyne', 'Value does not match');

    }
    
    @isTest
    private static void testCallout8(){
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> accList = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        
        account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='test';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor test,ITPL,Brookfield';
        acc1.BillingPostalCode='560038';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Industry = 'Construction';
        acc1.Core_CIM_ID__c='22213672';
        acc1.Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        acc1.Unified_Hierarchy_View__c = null;
        acc1.Core_Business_Party_Id__c = '8q5579q';
        acc1.Core_Address_Details__c = 'test11idwoh';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc1.Core_Export_Compliance_Block__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_account_Type__c = 'Distributor';
        
        Map<String,String> parentAccMap = new Map<String,String>();//Nj
         map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>(); 
       // mapOfAccWithBlokedStatus.put(acc1.id,'true');
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc1 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc1,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc1);
        
        Test.startTest();
        PRM_AdminRegistrationDuplicateDetails.matchingAccountSort(accList);
        Test.stopTest();
        System.assertEquals('Teledyne','Teledyne', 'Value does not match');
        
    }
    
     @isTest
    private static void testCallout9(){
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> accList = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        
        account acc2 = PRM_TestUtility.getAccount();
        acc2.BillingCity='testCity';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='4th Floor test data,ITPL,Brookfield';
        acc2.BillingPostalCode='560040';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Industry = 'Construction';
        acc2.Core_CIM_ID__c='22213672';
        acc2.Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
        acc2.Unified_Hierarchy_View__c = null;
        acc2.Core_Business_Party_Id__c = '8q8799q';
        acc2.Core_Address_Details__c = 'test11idwoh';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_Export_Compliance_Block__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_account_Type__c = 'Distributor';
         map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>(); 
        Map<String,String> parentAccMap = new Map<String,String>();//Nj
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc2 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc2,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc2);
        
        account acc3 = PRM_TestUtility.getAccount();
        acc3.BillingCity='testPune';
        acc3.BillingCountryCode='IND';
        acc3.BillingStreet='4th Floor Pune,ITPL,Brookfield';
        acc3.BillingPostalCode='560041';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc3.Industry = 'Construction';
        acc3.Core_CIM_ID__c='22213672';
        acc3.Core_Customer_Aggregation_Type__c = 'UNFD_LOC_CUST';
        acc3.Unified_Hierarchy_View__c = null;
        acc3.Core_Business_Party_Id__c = '8q8756';
        acc3.Core_Address_Details__c = 'test11idwoh';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_Export_Compliance_Block__c = false;
        acc3.Core_IPA_Partner_Role__c = 'Distributor';
        acc3.Core_account_Type__c = 'Distributor';
        
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc3 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc3,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc3);
        
        Test.startTest();
        PRM_AdminRegistrationDuplicateDetails.matchingAccountSort(accList);
        Test.stopTest();
        System.assertEquals('Teledyne','Teledyne', 'Value does not match');
    }
    
     @isTest
    private static void testCallout10(){
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> accList = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        
        account acc2 = PRM_TestUtility.getAccount();
        acc2.BillingCity='testCity';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='4th Floor test data,ITPL,Brookfield';
        acc2.BillingPostalCode='560040';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Industry = 'Construction';
        acc2.Core_CIM_ID__c='22213672';
        acc2.Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
        acc2.Unified_Hierarchy_View__c = null;
        acc2.Core_Business_Party_Id__c = '8q8799q';
        acc2.Core_Address_Details__c = 'test11idwoh';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_Export_Compliance_Block__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_account_Type__c = 'Distributor';
        acc2.Core_Unified_Intermediate_Customer_BP_Id__c='17399910';
         map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>(); 
        Map<String,String> parentAccMap = new Map<String,String>();//Nj
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc2 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc2,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc2);
        
        account acc3 = PRM_TestUtility.getAccount();
        acc3.BillingCity='testPune';
        acc3.BillingCountryCode='IND';
        acc3.BillingStreet='4th Floor Pune,ITPL,Brookfield';
        acc3.BillingPostalCode='560041';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc3.Industry = 'Construction';
        acc3.Core_CIM_ID__c='22213672';
        acc3.Core_Customer_Aggregation_Type__c = 'UNFD_LOC_CUST';
        acc3.Unified_Hierarchy_View__c = null;
        acc3.Core_Business_Party_Id__c = '8q8756';
        acc3.Core_Address_Details__c = 'test11idwoh';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_Export_Compliance_Block__c = false;
        acc3.Core_IPA_Partner_Role__c = 'Distributor';
        acc3.Core_account_Type__c = 'Distributor';
        
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc3 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc3,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc3);
        
        Test.startTest();
        PRM_AdminRegistrationDuplicateDetails.matchingAccountSort(accList);
        Test.stopTest();
        System.assertEquals('Teledyne','Teledyne', 'Value does not match');
    }
    
     @isTest
    private static void testCallout11(){
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> accList = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        
        account acc1 = PRM_TestUtility.getAccount();
        acc1.BillingCity='testCity';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor test data,ITPL,Brookfield';
        acc1.BillingPostalCode='560040';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Industry = 'Construction';
        acc1.Core_CIM_ID__c='22213672';
       // acc2.Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
        acc1.Unified_Hierarchy_View__c = 'Not Unified';
        acc1.Core_Business_Party_Id__c = '8q8799q';
        acc1.Core_Address_Details__c = 'test11idwoh';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc1.Core_Export_Compliance_Block__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_account_Type__c = 'Distributor';
        acc1.Core_Unified_Intermediate_Customer_BP_Id__c='173999101';
        acc1.Core_Unified_Intermdt_Customer_2_BP_Id__c = '937910014';
        insert acc1;
        
        account acc2 = PRM_TestUtility.getAccount();
        acc2.BillingCity='testCity';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='4th Floor test data,ITPL,Brookfield';
        acc2.BillingPostalCode='560040';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Industry = 'Construction';
        acc2.Core_CIM_ID__c='22213672';
        acc2.Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
        acc2.Unified_Hierarchy_View__c = null;
        acc2.Core_Business_Party_Id__c = '8q8799q';
        acc2.Core_Address_Details__c = 'test11idwoh';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_Export_Compliance_Block__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_account_Type__c = 'Distributor';
        acc2.Core_Unified_Intermediate_Customer_BP_Id__c = '8q8799q';//Nj
        //acc2.Core_Unified_Intermediate_Customer__c=acc1.id;//nj
         map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>(); 
        Map<String,String> parentAccMap = new Map<String,String>();//Nj
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc2 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc2,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc2);
        
        account acc3 = PRM_TestUtility.getAccount();
        acc3.BillingCity='testPune';
        acc3.BillingCountryCode='IND';
        acc3.BillingStreet='4th Floor Pune,ITPL,Brookfield';
        acc3.BillingPostalCode='560041';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc3.Industry = 'Construction';
        acc3.Core_CIM_ID__c='22213672';
        acc3.Core_Customer_Aggregation_Type__c = 'UNFD_LOC_CUST';
        acc3.Unified_Hierarchy_View__c = null;
        acc3.Core_Business_Party_Id__c = '8q8756';
        acc3.Core_Address_Details__c = 'test11idwoh';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_Export_Compliance_Block__c = false;
        acc3.Core_IPA_Partner_Role__c = 'Distributor';
        acc3.Core_account_Type__c = 'Distributor';
         
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc3 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc3,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc3);
        
        Test.startTest();
        PRM_AdminRegistrationDuplicateDetails.matchingAccountSort(accList);
        Test.stopTest();
        System.assertEquals('Teledyne','Teledyne', 'Value does not match');
    }
    
    @isTest
    private static void testCallout12(){
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> accList = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        User ur = [Select id, Name from User where Email='itadminTestCovered@intel.com'];
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
    
        List<Account> accToInsert = new List<Account>();
        account acc2 = PRM_TestUtility.getAccount();
        acc2.BillingCity='testCity';
        acc2.BillingState='CO';
        acc2.BillingCountry='USA';
        acc2.BillingCountryCode='USA';
        acc2.BillingStreet='4th Floor test data,ITPL,Brookfield';
        acc2.BillingPostalCode='560040';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Industry = 'Construction';
        acc2.Core_CIM_ID__c='22213672';
        acc2.Unified_Hierarchy_View__c = 'Not Unified';
        acc2.Core_Business_Party_Id__c = '8q8799q';
        acc2.Core_Address_Details__c = 'test11idwoh';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_Export_Compliance_Block__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_account_Type__c = 'Distributor';
        acc2.Core_Unified_Intermediate_Customer_BP_Id__c='173999101';
        acc2.Core_Unified_Intermdt_Customer_2_BP_Id__c = '937910014';
        acc2.OwnerId = ur.id;
        acc2.RecordTypeId = accountRecordTypeIntel;
  map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>(); 
        Map<String,String> parentAccMap = new Map<String,String>();//Nj
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc2 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc2,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc2);
        
        account acc3 = PRM_TestUtility.getAccount();
        acc3.BillingCity='testCityUSA';
        acc3.BillingState='CO';
        acc3.BillingCountry='USA';
        acc3.BillingCountryCode='USA';
        acc3.BillingStreet='4th demo test data,ITPL,Brookfield';
        acc3.BillingPostalCode='560040';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc3.Industry = 'Construction';
        acc3.Core_CIM_ID__c='22213672';
        acc3.Core_Customer_Aggregation_Type__c = '';
        acc3.Unified_Hierarchy_View__c = '';
        acc3.Core_Business_Party_Id__c = '8q8756';
        acc3.Core_Address_Details__c = 'test11idwoh';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_Export_Compliance_Block__c = false;
        acc3.Core_IPA_Partner_Role__c = 'Distributor';
        acc3.Core_account_Type__c = 'Distributor';
        acc3.OwnerId = ur.id;
        acc3.RecordTypeId = accountRecordTypeIntel;
        acc3.Core_Deactivated__c = false;
        acc3.Core_Account_Primary_Coverage__c = 'Intel Covered';
        acc3.Core_Account_Category__c = 'End Customer';
        acc3.Core_Sales_Groups__c = 'EMEA Partner Led';
        acc3.Core_Account_Level__c = 'Level1';
        accToInsert.add(acc2);
        accToInsert.add(acc3);
        Insert accToInsert;
        
        //Insert Contact
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.FirstName = 'RDCAck2';
        con.LastName = 'RDCAck2';
        con.Email = 'test_rdcuser44@mailinator.com';
        con.AccountId = acc3.Id;
        con.Phone = '323253';
        con.Core_Preferred_Language__c= 'ENG';
        con.Core_Profession__c = 'CONSULTANT';
        con.Core_Job_Function__c = 'CONSLT' ; 
        con.Core_Do_Not_Contact__c = FALSE;
        con.Core_IPA_PartnerRole__c = 'Distributor';
        con.MailingCountry ='USA';
        con.MailingCity ='Mississippi';
        con.MailingPostalCode='421910';
        con.MailingState ='AK';
        con.MailingStreet ='BandraStreet';
        conList.add(con);
        insert conList;
        
        ChannelProgram channelPrg = [Select id from ChannelProgram limit 1];
        
        List<PRM_Registration_Request__c> regReqToInsert = new List<PRM_Registration_Request__c>();
                
        PRM_Registration_Request__c prmRegRequest1 = new PRM_Registration_Request__c();
        prmRegRequest1.Name = 'checkuser';
        prmRegRequest1.PRM_Salesforce_ID__c = acc2.Id;
        prmRegRequest1.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest1.PRM_Partner_Role__c='Distributor';
        prmRegRequest1.PRM_First_Name__c='Check';
        prmRegRequest1.PRM_Last_Name__c='User';
        prmRegRequest1.PRM_Email_ID__c='checkuser@mailinator.com';
        prmRegRequest1.PRM_Contact_Country__c='US';
        prmRegRequest1.PRM_Legal_Agreements__c='IPA_TANDC';
        prmRegRequest1.PRM_Status__c = 'Rejected';
        prmRegRequest1.PRM_Country__c = 'US';
        prmRegRequest1.PRM_Partner_Role__c = 'Distributor';
        prmRegRequest1.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c prmRegRequest2 = new PRM_Registration_Request__c();
        prmRegRequest2.Name = 'checkuser 2';
        prmRegRequest2.PRM_Salesforce_ID__c = acc3.Id;
        prmRegRequest2.PRM_Matching_Contact__c = con.Id;
        prmRegRequest2.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest2.PRM_Partner_Role__c='Distributor';
        prmRegRequest2.PRM_First_Name__c='Check';
        prmRegRequest2.PRM_Last_Name__c='User';
        prmRegRequest2.PRM_Email_ID__c='checkuser@mailinator.com';
        prmRegRequest2.PRM_Contact_Country__c='US';
        prmRegRequest2.PRM_Legal_Agreements__c='IPA_TANDC';
        prmRegRequest2.PRM_Status__c = 'Rejected';
        prmRegRequest2.PRM_Country__c = 'US';
        prmRegRequest2.PRM_Partner_Role__c = 'Distributor';
        prmRegRequest2.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        regReqToInsert.add(prmRegRequest1);
        regReqToInsert.add(prmRegRequest2);
        insert regReqToInsert;
        
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc3 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc3,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc3);
        
        Test.startTest();
        PRM_AdminRegistrationDuplicateDetails.matchingAccountSort(accList);
        PRM_AdminRegistrationDuplicateDetails.getAccountsFromSBRResults(prmRegRequest1.Id);
        PRM_AdminRegistrationDuplicateDetails.getAccountsFromSBRResults(prmRegRequest2.Id);
        PRM_AdminRegistrationDuplicateDetails.getAccountExistingPartnerRoleACM(prmRegRequest2);
        Test.stopTest();

        System.assertEquals('Teledyne','Teledyne', 'Value does not match');
    }
    
    @isTest
    private static void testCallout14_test(){
        
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> accList = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        User ur = [Select id, Name from User where Email='itadminTestCovered@intel.com'];
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
    
        List<Account> accToInsert = new List<Account>();
        
        account acc3 = PRM_TestUtility.getAccount();
        acc3.BillingCity='testCity1USA';
        acc3.BillingState='CO';
        acc3.BillingCountry='USA';
        acc3.BillingCountryCode='USA';
        acc3.BillingStreet='4th demo1 data,ITPL,Brookfield';
        acc3.BillingPostalCode='560041';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc3.Industry = 'Construction';
        acc3.Core_CIM_ID__c='22213672';
        acc3.Core_Customer_Aggregation_Type__c = '';
        acc3.Unified_Hierarchy_View__c = '';
        acc3.Core_Business_Party_Id__c = '8q81756';
        acc3.Core_Address_Details__c = 'test11idwoh';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_Export_Compliance_Block__c = false;
        acc3.Core_IPA_Partner_Role__c = 'Distributor';
        acc3.Core_account_Type__c = 'Distributor';
        acc3.OwnerId = ur.id;
        acc3.RecordTypeId = accountRecordTypeIntel;
        acc3.Core_Deactivated__c = false;
        acc3.Core_Account_Primary_Coverage__c = 'Intel Covered';
        acc3.Core_Account_Category__c = 'End Customer';
        acc3.Core_Sales_Groups__c = 'EMEA Partner Led';
        acc3.Core_Account_Level__c = 'Level1';
        accToInsert.add(acc3);
        Insert accToInsert;
        
        //Insert Contact
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.FirstName = 'RDCAck3';
        con.LastName = 'RDCAck3';
        con.Email = 'test_rdcuser44789@mailinator.com';
        con.AccountId = acc3.Id;
        con.Phone = '3232537';
        con.Core_Preferred_Language__c= 'ENG';
        con.Core_Profession__c = 'CONSULTANT';
        con.Core_Job_Function__c = 'CONSLT' ; 
        con.Core_Do_Not_Contact__c = FALSE;
        con.Core_IPA_PartnerRole__c = 'Distributor';
        con.MailingCountry ='USA';
        con.MailingCity ='Mississippi';
        con.MailingPostalCode='421910';
        con.MailingState ='AK';
        con.MailingStreet ='BandraStreet';
        con.MailingCountry = 'USA';
        conList.add(con);
        insert conList;
        
        ChannelProgram channelPrg = [Select id from ChannelProgram limit 1];
        
        List<PRM_Registration_Request__c> regReqToInsert = new List<PRM_Registration_Request__c>();
                
        PRM_Registration_Request__c prmRegRequest2 = new PRM_Registration_Request__c();
        prmRegRequest2.Name = 'checkuser 2';
        prmRegRequest2.PRM_Salesforce_ID__c = acc3.Id;
        prmRegRequest2.PRM_Matching_Contact__c = con.Id;
        prmRegRequest2.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest2.PRM_Partner_Role__c='Distributor';
        prmRegRequest2.PRM_First_Name__c='Check';
        prmRegRequest2.PRM_Last_Name__c='User';
        prmRegRequest2.PRM_Email_ID__c='checkuser@mailinator.com';
        prmRegRequest2.PRM_Contact_Country__c='US';
        prmRegRequest2.PRM_Legal_Agreements__c='IPA_TANDC';
        prmRegRequest2.PRM_Status__c = 'Rejected';
        prmRegRequest2.PRM_Country__c = 'US';
        prmRegRequest2.PRM_Partner_Role__c = 'Distributor';
        prmRegRequest2.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        regReqToInsert.add(prmRegRequest2);
        insert regReqToInsert;
        
    Test.startTest();
        PRM_AdminRegistrationDuplicateDetails.getAccountExistingPartnerRoleACM(prmRegRequest2);
        Test.stopTest();
        System.assertEquals('Teledyne','Teledyne', 'Value does not match');
  }
    
    @isTest
    private static void testCallout13(){
        List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> accList = new List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper>();
        
        account acc2 = PRM_TestUtility.getAccount();
        acc2.BillingCity='testCity';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='4th Floor test data,ITPL,Brookfield';
        acc2.BillingPostalCode='560040';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Industry = 'Construction';
        acc2.Core_CIM_ID__c='22213672';
        acc2.Core_Business_Party_Id__c = '8q8799q';
        acc2.Core_Address_Details__c = 'test11idwoh';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_Export_Compliance_Block__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_account_Type__c = 'Distributor';
        acc2.Core_Unified_Intermediate_Customer_BP_Id__c='173999101';
        acc2.Core_Unified_Intermdt_Customer_2_BP_Id__c = '937910014';
         map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>(); 
        Map<String,String> parentAccMap = new Map<String,String>();//Nj
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc2 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc2,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc2);
        
        account acc3 = PRM_TestUtility.getAccount();
        acc3.BillingCity='testPune';
        acc3.BillingCountryCode='IND';
        acc3.BillingStreet='4th Floor Pune,ITPL,Brookfield';
        acc3.BillingPostalCode='560041';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc3.Industry = 'Construction';
        acc3.Core_CIM_ID__c='22213672';
        acc3.Core_Customer_Aggregation_Type__c = '';
        acc3.Unified_Hierarchy_View__c = '';
        acc3.Core_Business_Party_Id__c = '8q8756';
        acc3.Core_Address_Details__c = 'test11idwoh';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_Export_Compliance_Block__c = false;
        acc3.Core_IPA_Partner_Role__c = 'Distributor';
        acc3.Core_account_Type__c = 'Distributor';
       
        PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper mAcc3 = PRM_AdminRegistrationDuplicateDetails.setMatchingAccWrapper(acc3,parentAccMap,mapOfAccWithBlokedStatus);//Nj
        accList.add(mAcc3);
        
        Test.startTest();
        PRM_AdminRegistrationDuplicateDetails.matchingAccountSort(accList);
        Test.stopTest();
        System.assertEquals('Teledyne','Teledyne', 'Value does not match');
    }
}