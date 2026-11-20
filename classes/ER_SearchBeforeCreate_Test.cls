@isTest
public class ER_SearchBeforeCreate_Test {
    public static boolean IsEmailTest = false;

    @isTest 
    public static void DoPostTest_One(){
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
        
        Account acc = new Account();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.name='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_CNDA_Number__c ='63524108';
        insert acc;
        
        Contact ct = new Contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@test.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='India';
        insert ct;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        
        ER_SearchBeforeCreate.CIMSearchBeforeCreate cimSBC = new ER_SearchBeforeCreate.CIMSearchBeforeCreate();
        cimSBC.AccountName = 'companyName';
        cimSBC.AccountAddress = address;
        cimSBC.AccountURL = 'companyWebsite';
        cimSBC.EmailAddress='test@test.com';
        cimSBC.SearchLimit = '3';
        cimSBC.MinimumSearchScore = '80';
        cimSBC.EntitlementName ='Resource & Design Center for Secure Content';
        
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
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        ER_SearchBeforeCreate.doPost(cimSBC);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_CountryException(){
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        Address address = new Address('Magarpatta','Hadapsar','Pune','','Maharashtra','02039399');
        
        Account acc = new Account();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.name='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_CNDA_Number__c ='63524108';
        insert acc;
        
        Contact ct = new Contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@test.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='India';
        insert ct;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        
        ER_SearchBeforeCreate.CIMSearchBeforeCreate cimSBC = new ER_SearchBeforeCreate.CIMSearchBeforeCreate();
        cimSBC.AccountName = 'companyName';
        cimSBC.AccountAddress = address;
        cimSBC.AccountURL = 'companyWebsite';
        cimSBC.EmailAddress='test@test.com';
        cimSBC.SearchLimit = '3';
        cimSBC.MinimumSearchScore = '80';
        cimSBC.EntitlementName ='Resource & Design Center for Secure Content';
        
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
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        ER_SearchBeforeCreate.doPost(cimSBC);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_BusinessTypeException(){
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
        
        Account acc = new Account();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.name='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_CNDA_Number__c ='63524108';
        insert acc;
        
        Contact ct = new Contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@test.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='India';
        insert ct;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        
        ER_SearchBeforeCreate.CIMSearchBeforeCreate cimSBC = new ER_SearchBeforeCreate.CIMSearchBeforeCreate();
        cimSBC.AccountName = 'companyName';
        cimSBC.AccountAddress = address;
        cimSBC.AccountURL = 'companyWebsite';
        cimSBC.EmailAddress='test@test.com';
        cimSBC.SearchLimit = '3';
        cimSBC.MinimumSearchScore = '80';
        cimSBC.EntitlementName ='Resource & Design Center for Secure Content1';
        
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
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        ER_SearchBeforeCreate.doPost(cimSBC);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_Email(){
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Account acc = new Account();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.name='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_CNDA_Number__c ='63524108';
        insert acc;
        
        Contact ct = new Contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@test.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='India';
        insert ct;
        
        ER_SearchBeforeCreate.CIMSearchBeforeCreate cimSBC = new ER_SearchBeforeCreate.CIMSearchBeforeCreate();
        cimSBC.AccountName = 'companyName';
        cimSBC.AccountAddress = address;
        cimSBC.AccountURL = 'companyWebsite';
        cimSBC.EmailAddress='test@test.com';
        cimSBC.SearchLimit = '3';
        cimSBC.MinimumSearchScore = '80';
        cimSBC.EntitlementName ='Resource & Design Center for Secure Content';
        
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
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        IsEmailTest = true;
        ER_SearchBeforeCreate.doPost(cimSBC);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_3(){
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        Address address = new Address('Magarpatta','Hadapsar','Pune','HHH','Maharashtra','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        Account acc = new Account();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.name='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_CNDA_Number__c ='63524108';
        insert acc;
        
        Contact ct = new Contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@test.com';
        ct.MailingCountry='India';
        ct.AccountId=acc.id;
        
        insert ct;
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        countryIsoSetting.Name='TestName';
        countryIsoSetting.ISO_Code__c='IND';
        countryIsoSetting.Country_Code__c='IN'; 
        insert countryIsoSetting;
        
        ER_SearchBeforeCreate.CIMSearchBeforeCreate cimSBC = new ER_SearchBeforeCreate.CIMSearchBeforeCreate();
        cimSBC.AccountName = 'companyName';
        cimSBC.AccountAddress = address;
        cimSBC.AccountURL = 'companyWebsite';
        cimSBC.EmailAddress='test@test.com';
        cimSBC.SearchLimit = '3';
        cimSBC.MinimumSearchScore = '80';
        cimSBC.EntitlementName ='Resource & Design Center for Secure Content';
        
        Test.startTest();        
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        ER_SearchBeforeCreate.doPost(cimSBC);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
}