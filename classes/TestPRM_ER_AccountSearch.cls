@isTest
public class TestPRM_ER_AccountSearch {
    
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
        PRM_ER_AccountSearch.CIMSearchBeforeCreate cim = new PRM_ER_AccountSearch.CIMSearchBeforeCreate(); 
        cim.AccountName = 'Test';
        cim.AccountAddress = address;
        cim.AccountURL = 'www.test.com';
        cim.EmailAddress = 'test@mailinator.com';
        cim.BizOrgType = 'Distributor';
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '10';
        cim.EntitlementName = null;
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        PRM_ER_AccountSearch.doPost(cim);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_Two(){
        
        // Boolean isProgramBased = False;
        Address address = new Address('Gandhi Nagar','IT Park','Bhubneshwar','IND','Udisa','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        PRM_ER_AccountSearch.CIMSearchBeforeCreate cim = new PRM_ER_AccountSearch.CIMSearchBeforeCreate(); 
        cim.AccountName = 'Apple';
        cim.AccountAddress = address;
        cim.AccountURL = 'www.appletest.com';
        cim.BizOrgType = null;
        cim.EmailAddress = 'test@appletest@';
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '80';
        cim.EntitlementName = 'Resource & Design Center for Secure Content';
        
        Test.startTest();
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;   
        PRM_ER_AccountSearch.doPost(cim);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest
    public static void DoPostTest_Three(){       
        //Address address = new Address('Magarpatta','Pune','411024','Maharashtra','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        
        
        Address address = new Address('4733 Locust Street Near Vision University','Las Vegas','Las Vegas','','NY','02039399');
        PRM_ER_AccountSearch.CIMSearchBeforeCreate cim = new PRM_ER_AccountSearch.CIMSearchBeforeCreate(); 
        cim.AccountName = 'Test';
        cim.AccountAddress = address;
        cim.AccountURL = 'www.test.com';
        cim.EmailAddress = 'test@mailinator.com';
        cim.SearchLimit = '10';
        cim.MinimumSearchScore = '10';
        cim.EntitlementName = 'RDC';
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        PRM_ER_AccountSearch.doPost(cim);
        
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
        PRM_ER_AccountSearch.doPost(null);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest
    public static void DoPostTest_Five(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
  		
        Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = '012o0000000GlzTAAS';
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
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_ER_AccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        PRM_ER_AccountSearch.getAccountLegalAgreements(acc);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest
    public static void DoPostTest_Six(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
         Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = '012o0000000GlzTAAS';
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
      
        List<PRM_ER_CIMAccountSearchInfo> listdata = new List<PRM_ER_CIMAccountSearchInfo>();
        //listdata.addAll(partnRole);
        List<ER_SearchAccounts> lstSrcAccount = new List<ER_SearchAccounts>();
        ER_SearchAccounts erList = new ER_SearchAccounts(acc.id,'String cimId', acc, 10);

        lstSrcAccount.add(erList);
        Map<String,String> countryMap = new Map<String,String>();
        countryMap.put('IND','INDIA');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_ER_AccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        PRM_ER_AccountSearch.getResponseJSON(lstSrcAccount, countryMap);
        //PRM_ER_AccountSearch.mapToPartnerRoleInfo(listdata);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
        
    }
    
     @isTest
    public static void DoPostTest_Seven(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
         Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = '012o0000000GlzTAAS';
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
    
        List<PRM_ER_CIMAccountSearchInfo> listdata = new List<PRM_ER_CIMAccountSearchInfo>();
        //listdata.addAll(partnRole);
        List<PRM_SearchAccounts> lstSrcAccount = new List<PRM_SearchAccounts>();
        PRM_SearchAccounts prmList = new PRM_SearchAccounts(acc.id,null, acc, 10);

        lstSrcAccount.add(prmList);
        Map<String,String> countryMap = new Map<String,String>();
        countryMap.put('IND','INDIA');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_ER_AccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        PRM_ER_AccountSearch.getResponseJSON(lstSrcAccount,'10',countryMap);
        //PRM_ER_AccountSearch.mapToPartnerRoleInfo(listdata);
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
        //acm.PRM_Channel_Program_Id__c=cp.Id;
        //acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acms.add(acm);       
              
        //insert acms;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_ER_AccountSearchHttpResponse());
        req.requestURI = 'https://intel--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res; 
        
        PRM_ER_AccountSearch.mapToPartnerRoleInfo(acms);
        //PRM_ER_AccountSearch.mapToPartnerRoleInfo(listdata);
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
        PRM_ER_AccountSearch.CIMSearchBeforeCreate cim = new PRM_ER_AccountSearch.CIMSearchBeforeCreate(); 
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
        PRM_ER_AccountSearch.doPost(cim);
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
        PRM_ER_AccountSearch.CIMSearchBeforeCreate cim = new PRM_ER_AccountSearch.CIMSearchBeforeCreate(); 
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
        PRM_ER_AccountSearch.doPost(cim);
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
        PRM_ER_AccountSearch.CIMSearchBeforeCreate cim = new PRM_ER_AccountSearch.CIMSearchBeforeCreate(); 
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
        PRM_ER_AccountSearch.doPost(cim);
        Test.stopTest();
        System.assertEquals('https://intel--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
}