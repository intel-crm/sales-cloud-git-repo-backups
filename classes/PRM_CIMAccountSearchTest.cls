/*********************************************************************************************************************
Apex Class Name  : PRM_CIMAccountSearchTest
Version          : 1.0
Created Date     : FEB 2020
Function         : Test class for PRM_CIMAccountSearch

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Prasant Sahu               03/02/2020             Test class for PRM_CIMAccountSearch

*********************************************************************************************************************/

@isTest
public class PRM_CIMAccountSearchTest {
   @isTest 
    public static void DoPostTest_One(){
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueOf('{Teledyne}');
        RestResponse res = new RestResponse();  
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        countryIsoSetting.Name='TestName';
        countryIsoSetting.ISO_Code__c='IND';
         countryIsoSetting.Country_Code__c='IN'; 
        insert countryIsoSetting;
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        PRM_CIMAccountSearch.doPost('companyName', address, 'companyWebsite', 'Cloud Service Provider (CSP)','test@test.com','3', '80');
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_Two(){      
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        PRM_CIMAccountSearch.doPost('companyName', null, 'companyWebsite', 'Cloud Service Provider (CSP)','test@test.com','3', '80');
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
        
    @isTest
    public static void DoPostTest_Three(){       
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        id accRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Address address = new Address('4733 Locust Street Near Vision University','Las Vegas','Las Vegas','','NY','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        
        
        Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = accRecordTypeId;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        insert acc;
        
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b1.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='India';
        insert ct;
        
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Partner_Role__c = 'Service Provider';
        acm.PRM_Account_Id__c = acc.id;
        acm.PRM_Status_Nm__c = 'Pending';
        
        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.Name = 'Intel Partner Alliance';
        channelProgram.PRM_programCode__c = 'IPA';
        channelProgram.IsActive= true;
        insert channelProgram;
        
        ChannelProgramLevel channelProgramlevel = new ChannelProgramLevel();
        channelProgramlevel.Name ='Members';
        channelProgramlevel.ProgramId = channelProgram.Id;
        insert channelProgramlevel;
        
        acm.PRM_Channel_Program_Level_Id__c = channelProgramlevel.Id;
        insert acm;   
        
        
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Partner_Role__c = 'Distributor';
        acm1.PRM_Account_Id__c = acc.id;
        acm1.PRM_Status_Nm__c = 'Pending';
        acm1.PRM_Channel_Program_Level_Id__c = channelProgramlevel.Id;
        insert acm1;
        
    	PRM_PartnerAgreement__c pam = new PRM_PartnerAgreement__c();
        pam.Name='Intel Partner Alliance Terms & Condition';
        pam.PRM_Channel_Program_Id__c = channelProgram.Id;
        pam.PRM_Agreement_Cd__c = 'IPA_TANDC';
        pam.PRM_Agreement_Dsc__c = 'IPA terms and Condition';
        
        insert pam;
        List<PRM_AccountLegalAgreemntAssociation__c> newLAs = new List<PRM_AccountLegalAgreemntAssociation__c>();
        PRM_AccountLegalAgreemntAssociation__c newLA = new PRM_AccountLegalAgreemntAssociation__c();
        newLA.PRM_Account_Id__c = acc.Id;
        newLA.PRM_Partner_Agreement_Id__c = pam.Id;
        newLA.PRM_Agreement_Sign_Dt__c = System.now();
        newLA.PRM_Contact__c = ct.Id;
        newLAs.add(newLA);
        insert newLAs;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 

        PRM_CIMAccountSearch.doPost('companyName', address, 'companyWebsite', 'Cloud Service Provider (CSP)','test@test.com','3', '80');
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_Four(){
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        Address address = new Address('Magarpatta','Hadapsar','Pune','IN','Maharashtra','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        PRM_CIMAccountSearch.doPost('companyName', address, 'companyWebsite', 'partnerRole','test@test.com','3', '80');
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    } 
    
   @isTest 
    public static void DoPostTest_Five(){      
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        PRM_CIMAccountSearch.doPost('companyName', null, 'companyWebsite', '(CSP)','test@test.com','3', '80');
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_Six(){      
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        PRM_CIMAccountSearch.doPost('companyName', null, 'companyWebsite', 'Cloud Service Provider (CSP)','test','3', '80');
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    @isTest
    public static void DoPostTest_Seven(){
        Address address = new Address('4733 Locust Street Near Vision University','Las Vegas','Las Vegas','','NY','02039399');
        id accRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = accRecordTypeId;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        insert acc;
        
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b1.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='India';
        insert ct;
        
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Partner_Role__c = 'Service Provider';
        acm.PRM_Account_Id__c = acc.id;
        acm.PRM_Status_Nm__c = 'Pending';
        
        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.Name = 'Intel Partner Alliance';
        channelProgram.PRM_programCode__c = 'IPA';
        channelProgram.IsActive= true;
        insert channelProgram;
        
        ChannelProgramLevel channelProgramlevel = new ChannelProgramLevel();
        channelProgramlevel.Name ='Members';
        channelProgramlevel.ProgramId = channelProgram.Id;
        insert channelProgramlevel;
        
        acm.PRM_Channel_Program_Level_Id__c = channelProgramlevel.Id;
        insert acm;   
        
        
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Partner_Role__c = 'Distributor';
        acm1.PRM_Account_Id__c = acc.id;
        acm1.PRM_Status_Nm__c = 'Pending';
        acm1.PRM_Channel_Program_Level_Id__c = channelProgramlevel.Id;
        insert acm1;
        
    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 

        PRM_CIMAccountSearch.doPost('companyName', address, 'companyWebsite', 'Cloud Service Provider (CSP)','test','3', '80');
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest
        public static void DoPostTest_Eight(){
        id accRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Address address = new Address('4733 Locust Street Near Vision University','Las Vegas','Las Vegas','','NY','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = accRecordTypeId;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        insert acc;
        
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b1.com';
        ct.AccountId=acc.id;
        insert ct;
        
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Partner_Role__c = 'Service Provider';
        acm.PRM_Account_Id__c = acc.id;
        acm.PRM_Status_Nm__c = 'Pending';
        
        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.Name = 'Intel Partner Alliance';
        channelProgram.PRM_programCode__c = 'IPA';
        channelProgram.IsActive= true;
        insert channelProgram;
        
        ChannelProgramLevel channelProgramlevel = new ChannelProgramLevel();
        channelProgramlevel.Name ='Members';
        channelProgramlevel.ProgramId = channelProgram.Id;
        insert channelProgramlevel;
        
        acm.PRM_Channel_Program_Level_Id__c = channelProgramlevel.Id;
        insert acm;   
        
        
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Partner_Role__c = 'Distributor';
        acm1.PRM_Account_Id__c = acc.id;
        acm1.PRM_Status_Nm__c = 'Pending';
        acm1.PRM_Channel_Program_Level_Id__c = channelProgramlevel.Id;
        insert acm1;
        
    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 

        PRM_CIMAccountSearch.doPost('companyName', address, 'companyWebsite', 'abc','test','3', '80');
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
}