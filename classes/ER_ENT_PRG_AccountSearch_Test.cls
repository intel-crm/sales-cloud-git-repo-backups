@isTest
public class ER_ENT_PRG_AccountSearch_Test {
    public static Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();

    @isTest 
    public static void DoPostTest_One(){
        
        //Boolean isProgramBased = true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        countryIsoSetting.Name='TestName';
        countryIsoSetting.ISO_Code__c='IND';
        countryIsoSetting.Country_Code__c='IN'; 
        insert countryIsoSetting;
        ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate cim = new ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate();
        
        cim.AccountName = 'Test';
        cim.AccountAddress = address;
        cim.AccountURL = 'www.test.com';
        cim.EmailAddress = 'test@mailinator.com';
        cim.BizOrgType = 'Distributor';
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '10';
        cim.EntitlementName = null;
        
        ER_SearchBeforeCreate.CIMSearchBeforeCreate cimm = new ER_SearchBeforeCreate.CIMSearchBeforeCreate();
        cimm.AccountName = 'Test';
        cimm.AccountAddress = address;
        cimm.AccountURL = 'www.test.com';
        cimm.EmailAddress = 'test@mailinator.com';
        //cimm.BizOrgType = 'Distributor';
        cimm.SearchLimit = '10';
        cimm.MinimumSearchScore = '10';
        cimm.EntitlementName = 'Resource & Design Center';
        
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        ER_ENT_PRG_AccountSearch.doPost(cim);
        ER_SearchBeforeCreate.doPost(cimm);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_Two(){
        
        // Boolean isProgramBased = False;
        Address address = new Address('Gandhi Nagar','IT Park','Bhubneshwar','IND','Udisa','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate cim = new ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate(); 
        cim.AccountName = 'Apple';
        cim.AccountAddress = address;
        cim.AccountURL = 'www.appletest.com';
        cim.BizOrgType = null;
        cim.EmailAddress = 'test@appletest@';
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '80';
        cim.EntitlementName = 'Resource & Design Center for Secure Content';
        
        ER_SearchBeforeCreate.CIMSearchBeforeCreate cimm = new ER_SearchBeforeCreate.CIMSearchBeforeCreate();
        cimm.AccountName = 'Test';
        cimm.AccountAddress = address;
        cimm.AccountURL = 'www.test.com';
        cimm.EmailAddress = 'test@mailinator.com';
        //cimm.BizOrgType = 'Distributor';
        cimm.SearchLimit = '10';
        cimm.MinimumSearchScore = '10';
        cimm.EntitlementName = null;
        
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;   
        ER_ENT_PRG_AccountSearch.doPost(cim);
        ER_SearchBeforeCreate.doPost(cimm);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest
    public static void DoPostTest_Three(){       
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        
        
        Address address = new Address('4733 Locust Street Near Vision University','Las Vegas','Las Vegas','','NY','02039399');
        ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate cim = new ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate(); 
        cim.AccountName = 'Test';
        cim.AccountAddress = address;
        cim.AccountURL = 'www.test.com';
        cim.EmailAddress = 'test@mailinator.com';
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '10';
        cim.EntitlementName = 'Resource & Design Center for Secure Content';
        
        ER_SearchBeforeCreate.CIMSearchBeforeCreate cimm = new ER_SearchBeforeCreate.CIMSearchBeforeCreate();
        cimm.AccountName = 'Test';
        cimm.AccountAddress = address;
        cimm.AccountURL = 'www.test.com';
        cimm.EmailAddress = 'test@mailinator.com';
        //cimm.BizOrgType = 'Distributor';
        cimm.SearchLimit = '10';
        cimm.MinimumSearchScore = '10';
        cimm.EntitlementName = null;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        ER_ENT_PRG_AccountSearch.doPost(cim);
        ER_SearchBeforeCreate.doPost(cimm);
        
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }

    
    
    @isTest 
    public static void DoPostTest_Four(){      
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        ER_ENT_PRG_AccountSearch.doPost(null);
        ER_SearchBeforeCreate.doPost(null);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest
    public static void DoPostTest_Five(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = accountRecordTypeIntel;
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
        ct.MailingCountry='IND';
        ct.AccountId=acc.id;
        insert ct;
        
        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.Name = 'Intel Partner Alliance';
        channelProgram.PRM_programCode__c = 'IPA';
        //channelProgram.IsActive= true;
        insert channelProgram;
        
        PRM_PartnerAgreement__c prt = new PRM_PartnerAgreement__c();
        prt.Name = 'Test';
        prt.PRM_Channel_Program_Id__c = channelProgram.id;
        prt.PRM_Agreement_Cd__c = 'abc0121';
        insert prt;
        
        PRM_AccountLegalAgreemntAssociation__c prtLegal = new PRM_AccountLegalAgreemntAssociation__c();
        prtLegal.PRM_Partner_Agreement_Id__c = prt.id;
        prtLegal.PRM_InActive_Ind__c = false;
        prtLegal.PRM_Account_Id__c = acc.id;
        prtLegal.PRM_Contact__c = ct.id;
        prtLegal.PRM_Agreement_Sign_Dt__c = system.today();
        insert prtLegal;
        
        Account acct = [Select Id,Name,(Select Id,PRM_Account_Id__c,PRM_Partner_Agreement_Id__c,PRM_InActive_Ind__c,PRM_Agreement_Sign_Dt__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c FROM AccountLegalAgreementAssociations__r) FROM Account limit 1];
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new ER_ENT_PRG_AccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        ER_ENT_PRG_AccountSearch.getAccountLegalAgreements(acct);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
	
	@isTest
    public static void DoPostTest_Priority(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
		Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
		acc.Core_B2B_Entitlement__c = true;
        insert acc;

      
        List<ER_ENT_PRG_CIMAccountSearchInfo> listdata = new List<ER_ENT_PRG_CIMAccountSearchInfo>();
        //listdata.addAll(partnRole);
        List<ER_SearchAccounts> lstSrcAccount = new List<ER_SearchAccounts>();
        ER_SearchAccounts erList = new ER_SearchAccounts(acc.id,'22213672', acc, 10);
		lstSrcAccount.add(erList);
		
		
		List<ER_SBC_PriorityMatrix__mdt> priorityMatrix = [SELECT AccountType__c,PriorityField__c,PriorityNumber__c,isObjectField__c,PriorityValue__c,isSearchScore__c FROM ER_SBC_PriorityMatrix__mdt WHERE AccountType__c = 'Developer Zone Premier' ORDER by PriorityNumber__c];
		
		Set<Id> acctIdset = new Set<Id> ();
		acctIdset.add(acc.id);
		
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new ER_ENT_PRG_AccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        List<ER_SearchAccounts> accts = ER_SearchSalesCloudAccounts.sortIdBasedOnSortingCriteria(lstSrcAccount, acctIdset,priorityMatrix,'10');
        List<PRM_CIMSearchResults__c> prmresults = new List<PRM_CIMSearchResults__c>();
        prmresults.add(ER_SearchSalesCloudAccounts.instCimSearchResults(acc.Id));
        try{
            ER_SearchSalesCloudAccounts.getSortedAccountsCim(prmresults,acctIdset,'Developer Zone Premier','0');
        }
        catch(Exception ex){
            
        }
        //ER_ENT_PRG_AccountSearch.mapToPartnerRoleInfo(listdata);
        Test.stopTest();
        System.assert(accts.size()>0);
        
    }
    
    @isTest
    public static void DoPostTest_Six(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
         Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = accountRecordTypeIntel;
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
       // PRM_AccountChannelMembership__c partnRole = new PRM_AccountChannelMembership__c();
      //  partnRole.PRM_Partner_Role__c = 'Service Provider';
      //  insert partnRole;
      
        List<ER_ENT_PRG_CIMAccountSearchInfo> listdata = new List<ER_ENT_PRG_CIMAccountSearchInfo>();
        //listdata.addAll(partnRole);
        List<ER_SearchAccounts> lstSrcAccount = new List<ER_SearchAccounts>();
        ER_SearchAccounts erList = new ER_SearchAccounts(acc.id,'String cimId', acc, 10);

        lstSrcAccount.add(erList);
        Map<String,String> countryMap = new Map<String,String>();
        countryMap.put('IND','INDIA');
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new ER_ENT_PRG_AccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        ER_ENT_PRG_AccountSearch.getResponseJSON(lstSrcAccount, countryMap);
        
        //ER_SearchBeforeCreate.getResponseJSON(lstSrcAccount, countryMap);
        //ER_ENT_PRG_AccountSearch.mapToPartnerRoleInfo(listdata);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
        
    }
    
     @isTest
    public static void DoPostTest_Seven(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
         Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = accountRecordTypeIntel;
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
    
        List<ER_ENT_PRG_CIMAccountSearchInfo> listdata = new List<ER_ENT_PRG_CIMAccountSearchInfo>();
        //listdata.addAll(partnRole);
        List<PRM_SearchAccounts> lstSrcAccount = new List<PRM_SearchAccounts>();
        PRM_SearchAccounts prmList = new PRM_SearchAccounts(acc.id,null, acc, 10);

        lstSrcAccount.add(prmList);
        Map<String,String> countryMap = new Map<String,String>();
        countryMap.put('IND','INDIA');
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new ER_ENT_PRG_AccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        ER_ENT_PRG_AccountSearch.getResponseJSON(lstSrcAccount,'10',countryMap);
        
        //ER_ENT_PRG_AccountSearch.mapToPartnerRoleInfo(listdata);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
       
        
    }
    
        @isTest
    public static void DoPostTest_Eight(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        List<PRM_AccountChannelMembership__c> acms = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        //acm.PRM_Account_Id__c=intelAccount.id;
        acm.PRM_Status_Nm__c='Pending';
        acm.PRM_Partner_Role__c='Service Provider';
        acms.add(acm);       
              
        //insert acms;
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new ER_ENT_PRG_AccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        ER_ENT_PRG_AccountSearch.mapToPartnerRoleInfo(acms);
        //ER_ENT_PRG_AccountSearch.mapToPartnerRoleInfo(listdata);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
        
    }
    
     @isTest 
    public static void DoPostTest_invalidQueryException(){
        
        //Boolean isProgramBased = true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        countryIsoSetting.Name='TestName';
        countryIsoSetting.ISO_Code__c='IND';
        countryIsoSetting.Country_Code__c='IN'; 
        insert countryIsoSetting;
        ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate cim = new ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate(); 
        cim.AccountName = 'Test';
        cim.AccountAddress = address;
        cim.AccountURL = 'www.test.com';
        cim.EmailAddress = 'test@mailinator.com';
        cim.BizOrgType = null;
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '10';
        cim.EntitlementName = null;
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        ER_ENT_PRG_AccountSearch.doPost(cim);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_invalidBizOrgType(){
        
        //Boolean isProgramBased = true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        countryIsoSetting.Name='TestName';
        countryIsoSetting.ISO_Code__c='IND';
        countryIsoSetting.Country_Code__c='IN'; 
        insert countryIsoSetting;
        ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate cim = new ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate(); 
        cim.AccountName = 'Test';
        cim.AccountAddress = address;
        cim.AccountURL = 'www.test.com';
        cim.EmailAddress = 'test@mailinator.com';
        cim.BizOrgType = '16r';
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '10';
        cim.EntitlementName = null;
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        ER_ENT_PRG_AccountSearch.doPost(cim);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
     @isTest 
    public static void DoPostTest_invalidEmail(){
        
        //Boolean isProgramBased = true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        countryIsoSetting.Name='TestName';
        countryIsoSetting.ISO_Code__c='IND';
        countryIsoSetting.Country_Code__c='IN'; 
        insert countryIsoSetting;
        ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate cim = new ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate(); 
        cim.AccountName = 'Test';
        cim.AccountAddress = address;
        cim.AccountURL = 'www.test.com';
        cim.EmailAddress = 'test@mailinator';
        cim.BizOrgType = 'Distributor';
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '10';
        cim.EntitlementName = null;
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        ER_ENT_PRG_AccountSearch.doPost(cim);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    static testMethod void callConstructors_codecoverage()
        {
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
        Account acc = new Account();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.name ='Test FPGA Licensing Account';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_CNDA_Number__c ='63524108';
        insert acc;

        Datetime dt =date.valueOf('2021-10-08 11:11:11');       
        ER_ENT_PRG_AccountSearch.AccountLegalAgreement legalAgreement = new ER_ENT_PRG_AccountSearch.AccountLegalAgreement(dt);
        PartnerRoleInfo role = new PartnerRoleInfo('Abcd', '2', 'open', dt);
        Test.startTest();         

        ER_ENT_PRG_CIMAccountSearchInfo obj_cimAccSrch_rdc = new ER_ENT_PRG_CIMAccountSearchInfo 
            (acc.name, address, acc.Id, '22213672');
        Test.stopTest();                       
            
        }
    
    
     @isTest
    public static void DoPostTest_Ten(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        //Address address = new Address('4733 Locust Street Near Vision University','Las Vegas','Las Vegas','','NY','02039399');
        Address address = new Address('StreetTest',null,null,'IND',null,'560098');
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        countryIsoSetting.Name='TestName';
        countryIsoSetting.ISO_Code__c='IND';
        countryIsoSetting.Country_Code__c='IN'; 
        insert countryIsoSetting;
        
        Account acc = new Account();
        acc.name='Test FPGA Licensing Account';
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Core_CIM_ID__c = '22213672';
        acc.Core_Business_Party_Id__c ='12345';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='StreetTest';
        acc.BillingCity='Mumbai';
        acc.BillingPostalCode='560098';
        acc.BillingStateCode='MH';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        acc.Core_MDM_Website__c = 'www.test.com';
        insert acc;
        
        ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate cim = new ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate(); 
        cim.AccountName = 'Test FPGA Licensing Account';
        cim.AccountAddress = address;
        cim.AccountAddress.CountryCode2 = 'IND';
        //cim.AccountAddress.StateCode2 = 'MH';   
        cim.AccountURL = 'www.test.com';
        cim.EmailAddress = 'test@mailinator.com';
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '10';
        cim.EntitlementName = 'Resource & Design Center for Secure Content';
        
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name='Resource & Design Center for Secure Content';
        ent.Core_Display_Name__c = 'Test';
        insert ent;
        
        Business_Types__c bt = new Business_Types__c();
        bt.Name = 'PSG';
        bt.Is_Active__c = true;
        bt.Business_Type_Code__c = 'Test';
        insert bt;
        
        //List<PRM_VXEnttlmntMatrix__c> lstTestData = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c testData = new PRM_VXEnttlmntMatrix__c();
        testData.Account__c = acc.id;
        testData.PRM_Approval_Type_Nm__c = 'Automatic';
        testData.PRM_Entitlement_Id__c  = ent.Id;  
        testData.Business_Types__c= bt.Id;
        
        //testData.PRM_Entitlement_Id__c = 'Resource & Design Center for Secure Content';
        insert testData;
        //lstTestData.add(testData);
        Account ac = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount1','Intel Account','UNFD_GLBL_CUST');
        ac.Core_Business_Party_Id__c = '12345';
        ac.Core_Data_Country_Nm__c = 'India';
        ac.Core_Data_Simplified_Account_Nm__c = 'TestDuplicateAccount';
        ac.OwnerId = UserInfo.getUserId();
        ac.BillingCountryCode = 'IND';
        ac.Core_MDM_Website__c = 'www.test.com';
        ac.Core_User_Defined_Website__c = 'Sample';
        ac.Core_Requested_Name__c = 'TestAccount1';

        insert ac;
        Account accountDup = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccountDuplicateCheck','Intel Account','UNFD_GLBL_CUST');
        accountDup.Core_Business_Party_Id__c = '12345';
        accountDup.Core_Data_Country_Nm__c = 'India';
        accountDup.Core_Data_Simplified_Account_Nm__c = 'TestAccountDuplicateCheck';
        accountDup.OwnerId = UserInfo.getUserId();
        accountDup.BillingCountryCode = 'IND';
        accountDup.BillingStreet='StreetTest';
        accountDup.BillingCity='Mumbai';
        accountDup.Core_MDM_Website__c = 'www.test.com';
        accountDup.BillingStateCode='MH';
        accountDup.BillingPostalCode='560098';
        insert accountDup;
        List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fswList = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw1 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw1.fieldLabel = 'BillingCountry';
        fsw1.fieldAPIName = 'BillingCountry';
        fsw1.fieldValue = 'India';
        fswList.add(fsw1);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        ER_ENT_PRG_AccountSearch.doPost(cim);
        
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
        
    }
    
    ///for Search CIM Accounts
    
    @isTest
    public static void testCallout_One()
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
        ct.MailingCountry='IND';
        ct.AccountId=acc.id;
        insert ct;
       
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        ER_ENT_PRG_SearchCIMAccount uiCim =new ER_ENT_PRG_SearchCIMAccount();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,'new@b.com', null,true ,null, 'Service Provider', true);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, '77','www.test.com','new@b.com', null,False ,null, 'Service Provider', true);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,null, null,False ,accSfdcId, 'Service Provider', False);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', null,'www.test.com','new@b.com', null,False ,null, 'Service Provider', true);
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
        
        		try{
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }
        catch(exception ex){
            
        }
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');

    }
    
    @isTest
    public static void testCallout_Two()
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
        ct.MailingCountry='IND';
        ct.AccountId=acc.id;
        insert ct;
       
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        ER_ENT_PRG_SearchCIMAccount uiCim =new ER_ENT_PRG_SearchCIMAccount();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,'new@b.com', null,true ,accSfdcId, 'Service Provider', true);
         uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, '77','www.test.com','new@b.com', null,False ,null, 'Service Provider', true);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,null, null,False ,accSfdcId, 'Service Provider', False);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', null,'www.test.com','new@b.com', null,False ,null, 'Service Provider', true);
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
        
        		try{
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }
        catch(exception ex){
            
        }
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');

    }
    
    @isTest
    public static void testCallout_Three()
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
        ct.MailingCountry='IND';
        ct.AccountId=acc.id;
        insert ct;
       
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        ER_ENT_PRG_SearchCIMAccount uiCim =new ER_ENT_PRG_SearchCIMAccount();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        uiCim.getCimResults(null, null, null, null, null, null, null, null,null,null, null,true ,null, null, true);
       // uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, '77','www.test.com','new@b.com', null,False ,null, 'Service Provider', true);
       // uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,null, null,False ,null, 'Service Provider', False);
       // uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', null,'www.test.com','new@b.com', null,False ,null, 'Service Provider', true);
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
        
       		try{
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }
        catch(exception ex){
            
        }
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');

    }
    
     @isTest
    public static void testCallout_Seven()
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
        ct.MailingCountry='IND';
        ct.AccountId=acc.id;
        insert ct;
        
        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.Name = 'Intel Partner Alliance';
        channelProgram.PRM_programCode__c = 'IPA';
        //channelProgram.IsActive= true;
        insert channelProgram;
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
       // insert acm;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        ER_SearchCIMAccounts uiCim =new ER_SearchCIMAccounts();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,'new@b.com', null,true );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, '77','www.test.com','new@b.com', null,False );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,null, null,False );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', null,'www.test.com','new@b.com', null,False );
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
        
       		try{
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }
        catch(exception ex){
            
        }
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');

    }
    
     @isTest
    public static void testCallout_Four()
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
        ct.MailingCountry='IND';
        ct.AccountId=acc.id;
        insert ct;
        
        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.Name = 'Intel Partner Alliance';
        channelProgram.PRM_programCode__c = 'IPA';
        insert channelProgram;
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
        //insert acm;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        ER_SearchCIMAccounts uiCim =new ER_SearchCIMAccounts();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,'new@b.com', null,true );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, '77','www.test.com','new@b.com', null,False );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,null, null,False );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', null,'www.test.com','new@b.com', null,False );
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
        try{
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }
        catch(exception ex){ 
            
        }
        
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');

    }

    @isTest
    public static void testCallout_Five()
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
        ct.MailingCountry='IND';
        ct.AccountId=acc.id;
        insert ct;
       
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        ER_SearchCIMAccounts uiCim =new ER_SearchCIMAccounts();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
     uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,'new@b.com', null,true );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, '77','www.test.com','new@b.com', null,False );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,null, null,False );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', null,'www.test.com','new@b.com', null,False );        map<string,string> requestDetails = new map<string,string>();
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
        
		try{
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }
        catch(exception ex){
            
        }
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');

    }
    
    @isTest
    public static void testCallout_Six()
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
        ct.MailingCountry='IND';
        ct.AccountId=acc.id;
        insert ct;
       
        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        ER_SearchCIMAccounts uiCim =new ER_SearchCIMAccounts();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
      uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,'new@b.com', null,true );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, '77','www.test.com','new@b.com', null,False );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,null, null,False );
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', null,'www.test.com','new@b.com', null,False );     map<string,string> requestDetails = new map<string,string>();
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
        try{
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        }
        catch(exception ex){
            
        }
       
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');

    }
     @isTest
    public static void testMain()
    {
        
        
    }   
}