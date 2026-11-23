@isTest
public class PRM_searchSfdcAccountsTest {
    @isTest
    public static void emailValidationCheck_test(){
        Test.startTest();
        Boolean result=PRM_searchSfdcAccounts.emailValidationCheck('test456@test.com');
        Test.stopTest();
        System.assert(result==true);

    }
    @isTest
    public static void isBlacklistedEmailDomian_Test(){
        Test.startTest();
        Boolean result=PRM_searchSfdcAccounts.isBlacklistedEmailDomian('test456@test.com');
        Test.stopTest();
        System.assert(result==true);
    }

    @isTest
    public static void getAccounts_Test()
    {
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        insert acc;
        
        
        Account nonIpaAcc = new Account();
        nonIpaAcc.name='Test nonIpa';
        nonIpaAcc.RecordTypeId = intelaccountRT;
        nonIpaAcc.Core_CIM_ID__c = '22213672';
        nonIpaAcc.BillingCountry='USA';
        nonIpaAcc.BillingStreet='700 Chestnut Ridge Rd New';
        nonIpaAcc.BillingCity='Chestnut Ridge';
        nonIpaAcc.BillingPostalCode='109776435';
        nonIpaAcc.BillingState=null;
        nonIpaAcc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
                              //nonIpaAcc.Core_Covered_Account__c=true;        
        nonIpaAcc.Core_IPA_Partner_Role__c = 'Distributor';
        nonIpaAcc.Core_Account_Type__c = 'Distributor';
        nonIpaAcc.Industry = '';
        insert nonIpaAcc;
        
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@test.com';
        ct.AccountId=acc.id; 
        ct.MailingCountryCode='IND';
        insert ct;
        
        
        Account acc1 = new Account();
        acc1.name='Test2324';
        acc1.RecordTypeId = intelaccountRT;
        acc1.Core_CIM_ID__c = '22213672';
        acc1.BillingCountry='USA';
        acc1.BillingStreet='700 Chestnut Ridge Rd New';
        acc1.BillingCity='Chestnut Ridge';
        acc1.BillingPostalCode='109776435';
        acc1.BillingState=null;
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Service Provider';
        acc1.Core_Account_Type__c = 'Service Provider';
        acc1.Industry = '';
      
        
        insert acc1;
        
        
        Account accCovered = new Account();
        accCovered.name='Test23241';
        accCovered.RecordTypeId = intelaccountRT;
        accCovered.Core_CIM_ID__c = '222136721';
        accCovered.BillingCountry='USA';
        accCovered.BillingStreet='700 Chestnut Ridge Rd New';
        accCovered.BillingCity='Chestnut Ridge';
        accCovered.BillingPostalCode='1097764351';
        accCovered.BillingState=null;
        accCovered.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
       // accCovered.Core_Covered_Account__c=true;
        accCovered.Core_IPA_Partner_Role__c = 'Service Provider';
        accCovered.Core_Account_Type__c = 'Service Provider';
        accCovered.Industry = '';
       // accCovered.OwnerAlias='abc';
        insert accCovered;

        
        contact ct1 = new contact();
        ct1.FirstName='None';
        ct1.LastName='New';
        ct1.Email='newone@test.com';
        ct1.AccountId=acc1.id; 
        ct1.MailingCountryCode='IND';
        insert ct1;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Partner_Role__c = 'Service Provider';
        acm.PRM_Account_Id__c = accCovered.id;
         acm.PRM_Status_Reason_Txt__c='Test';
        
        //acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acm.PRM_Status_Nm__c = 'Pending';
        
        PRM_AccountChannelMembership__c acmCovered = new PRM_AccountChannelMembership__c();
        acmCovered.PRM_Partner_Role__c = 'Service Provider';
        acmCovered.PRM_Account_Id__c = accCovered.id;
        //acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acmCovered.PRM_Status_Nm__c = 'Pending';
        
        PRM_AccountChannelMembership__c acm11 = new PRM_AccountChannelMembership__c();
        acm11.PRM_Partner_Role__c = 'Service Provider';
        acm11.PRM_Account_Id__c = nonIpaAcc.id;
       // acm11.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c=false;
        acm11.PRM_Status_Nm__c = 'Pending';
         acm11.PRM_Status_Reason_Txt__c='Test';
        
        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.Name = 'Intel Partner Alliance';
        channelProgram.PRM_programCode__c = 'IPA';
        channelProgram.IsActive= true;
        insert channelProgram;
        
        ChannelProgramLevel channelProgramlevel = new ChannelProgramLevel();
        channelProgramlevel.Name ='Partner';
        channelProgramlevel.ProgramId = channelProgram.Id;
        insert channelProgramlevel;
        
        acm.PRM_Channel_Program_Level_Id__c = channelProgramlevel.Id;
         acm.PRM_Status_Reason_Txt__c='Test';
        acm11.PRM_Channel_Program_Level_Id__c=channelProgramlevel.Id;
        insert acm;  
         insert acm11;
        
        
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Partner_Role__c = 'Distributor';
        acm1.PRM_Account_Id__c = acc.id;
        acm1.PRM_Status_Nm__c = 'Pending';
        acm1.PRM_Status_Reason_Txt__c='Test';
        
        ChannelProgramLevel channelProgramlevel1 = new ChannelProgramLevel();
        channelProgramlevel1.Name ='Prestige';
        channelProgramlevel1.ProgramId = channelProgram.Id;
        insert channelProgramlevel1;
        
        acm1.PRM_Channel_Program_Level_Id__c = channelProgramlevel1.Id;
        insert acm1;
        
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.add(acc.id);
        accountIdSet.add(acc1.id);
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        
        
        
        /*PRM_UICIMCallout prmUICimCallout = new PRM_UICIMCallout();
        PRM_UICIMCallout.getCimResultsWrapper obj_1=new PRM_UICIMCallout.getCimResultsWrapper();
        obj_1.accName='Sample';
        obj_1.accAddr='Magarpatta';
        obj_1.accPostalCode='411024';
        obj_1.accCity='Maharashtra';
        obj_1.accCountry='IND';
        obj_1.accStateProvince='MH';
        obj_1.rcdLimit='10';
        obj_1.searchScore='40';
        obj_1.companyWebsite='www.sampletest.com';
        obj_1.accountsSfdc=null;
        obj_1.regEmail='nexttest@test.com';
        obj_1.partnerRole='Service Provider';
       	List<PRM_CIMSearchResults__c> listOfCimResult = prmUICimCallout.getCimResults(obj_1);//Athr fixes*/
        //List<PRM_CIMSearchResults__c> listOfCimResult = prmUICimCallout.getCimResults('Sample', 'Magarpatta', '411024','Maharashtra','IN','MH','10','40','www.sampletest.com',null,'nexttest@test.com','Service Provider');
        
    
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Current_Status__c ='Open';
        regRequest.Geo_Code__c='AP';
        regRequest.PRM_Account_Partner_Type__c='Cloud Service Provider (CSP)';
        regRequest.PRM_Account_Name__c='Test23241';
        regRequest.PRM_Address_Line_1__c ='700 Chestnut Ridge Rd New Chestnut Ridge';
        regRequest.PRM_Channel_Program__c=channelProgram.id;
        regRequest.PRM_Channel_Program_Level__c=channelProgramlevel.id;
        regRequest.PRM_Email_ID__c = 'www.test2341@test.com';
        regRequest.PRM_First_Name__c ='test';
        regRequest.PRM_Last_Name__c ='Test23241';
        TriggerHandler.bypass('PRM_RegRequest_TriggerHandler');
        insert regRequest;
        TriggerHandler.clearbypass('PRM_RegRequest_TriggerHandler');
        List<PRM_CIMSearchResults__c> listOfCimResult = new List<PRM_CIMSearchResults__c>();
        PRM_CIMSearchResults__c cimResult = new PRM_CIMSearchResults__c();
        cimResult.PRM_Account_Id__c = accCovered.id;
        cimResult.PRM_Account_Nm__c='Test23241';
        cimResult.PRM_AddressLine1_Txt__c='700 Chestnut Ridge Rd New Chestnut Ridge';
        cimResult.PRM_Source__c ='Reltio SBR';
        cimResult.PRM_RegReq_Id__c=regRequest.id;
        listOfCimResult.add(cimResult);
        List<PRM_SearchAccounts> lstSearchAccountObj = PRM_searchSfdcAccounts.getSortedAccountsCim(listOfCimResult,accountIdSet,'Service Provider');
        Map<id,contact> conMap = PRM_searchSfdcAccounts.getAccounts('www.test2341@test.com');
        
        //System.assert(lstSearchAccountObj!=null && lstSearchAccountObj.size()>0);
        Test.stopTest();
    }
    @isTest
    public static void instCimSearchResults_Test()
    {
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        insert acc;
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.PRM_Account_Name__c = 'Safari';
        regRequest.PRM_City__c = 'Bengaluru';
        Test.startTest();
        PRM_CIMSearchResults__c cimSearch = PRM_searchSfdcAccounts.instCimSearchResults(regRequest,acc.id);
        PRM_searchSfdcAccounts.instCimSearchResultsForEmailDomainMatch(regRequest,acc.id);
        Test.stopTest();
        System.assertEquals(0, cimSearch.PRM_SearchScore_Nbr__c);
    }
    @isTest
    public static void getSortedAccountsCim_Test()
    {
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account acc4 = new Account();
        acc4.name = 'Testing 123';
        acc4.RecordTypeId = intelaccountRT;
        acc4.BillingCity='Blue Ridge';
        acc4.Core_CIM_ID__c = '22213672';
        acc4.BillingCountry='USA';
        acc4.BillingStreet='700 Chestnut Ridge Rd New';
        acc4.BillingPostalCode='109776435';
        acc4.BillingState=null;
        acc4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc4.Core_IPA_Partner_Role__c = 'Service Provider';
        acc4.Core_Account_Type__c = 'Service Provider';
        acc4.Industry = '';
        insert acc4;
        
        Account accMinScore = new Account();
        accMinScore.name = 'Testing Minscore';
        accMinScore.RecordTypeId = intelaccountRT;
        accMinScore.BillingCity='Blue Ridge station';
        accMinScore.Core_CIM_ID__c = '12213672';
        accMinScore.BillingCountry='USA';
        accMinScore.BillingStreet='720 Ridge Rd New';
        accMinScore.BillingPostalCode='129776435';
        accMinScore.BillingState=null;
        accMinScore.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accMinScore.Core_IPA_Partner_Role__c = 'Service Provider';
        accMinScore.Core_Account_Type__c = 'Service Provider';
        accMinScore.Industry = '';
        insert accMinScore;
        
        ChannelProgram channelProgram2 = new ChannelProgram();
        channelProgram2.Name = 'Intel Partner Alliance';
        channelProgram2.PRM_programCode__c = 'IPA';
        channelProgram2.IsActive= true;
        insert channelProgram2;
        
        ChannelProgramLevel channelProgramlevel4 = new ChannelProgramLevel();
        channelProgramlevel4.Name ='Partner';
        channelProgramlevel4.ProgramId = channelProgram2.Id;
        insert channelProgramlevel4;
        
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Partner_Role__c = 'Service Provider';
        acm3.PRM_Status_Nm__c = 'Pending';
        acm3.PRM_Channel_Program_Level_Id__c = channelProgramlevel4.Id;
        acm3.PRM_Account_Id__c = acc4.id;
        acm3.PRM_Channel_Program_Id__c = channelProgram2.Id;
         acm3.PRM_Status_Reason_Txt__c='Test';
        insert acm3;
        
        PRM_CIMSearchResults__c searchResultMin = new PRM_CIMSearchResults__c();
        searchResultMin.PRM_SearchScore_Nbr__c = 25;
        searchResultMin.PRM_Account_Id__c = accMinScore.id;
        searchResultMin.PRM_CIM_Id__c = '2356899';
        
        
        PRM_CIMSearchResults__c searchResult1 = new PRM_CIMSearchResults__c();
        searchResult1.PRM_SearchScore_Nbr__c = 55;
        searchResult1.PRM_Account_Id__c = acc4.id;
        searchResult1.PRM_CIM_Id__c = '2356899';
        List<PRM_CIMSearchResults__c> cimList = new List<PRM_CIMSearchResults__c>();
         cimList.add(searchResultMin);
        cimList.add(searchResult1);
        
        Set<id> idSet = new Set<id>();
        idSet.add(acc4.id);
        
        Test.startTest();
        List<PRM_SearchAccounts> listSearchAccounts = PRM_searchSfdcAccounts.getSortedAccountsCim(cimList,idSet,'Service Provider');
        Test.stopTest();
    }
    @isTest
    public static void getSortedAccountsCim_Test1()
    {
               Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@example.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'iuser', Email='standarduser@example.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        System.runAs(u) {
           
            Account acc4 = new Account();
                   acc4.RecordTypeId = intelaccountRT;
            acc4.name = 'Testing 123';
            acc4.BillingCity='Blue Ridge';
            acc4.Core_CIM_ID__c = '22213672';
            acc4.BillingCountry='USA';
            acc4.BillingStreet='700 Chestnut Ridge Rd New';
            acc4.BillingPostalCode='109776435';
            acc4.BillingState=null;
            acc4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            acc4.Core_IPA_Partner_Role__c = 'Service Provider';
            acc4.Core_Account_Type__c = 'Service Provider';
            acc4.Industry = '';
            insert acc4;
            
            Account acc5 = new Account();
            acc5.name = 'Testing 1234';
            acc5.RecordTypeId = intelaccountRT;
            acc5.BillingCity='Blue Ridge4';
            acc5.Core_CIM_ID__c = '222136724';
            acc5.BillingCountry='USA';
            acc5.BillingStreet='7040 Chestnut Ridge Rd New';
            acc5.BillingPostalCode='1097764435';
            acc5.BillingState=null;
            acc5.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
            acc5.Core_IPA_Partner_Role__c = 'Service Provider';
            acc5.Core_Account_Type__c = 'Service Provider';
            acc5.Industry = '';
            insert acc5;

            ChannelProgram channelProgram2 = new ChannelProgram();
            channelProgram2.Name = 'Intel Partner Alliance';
            channelProgram2.PRM_programCode__c = 'IPA';
            channelProgram2.IsActive= true;
            insert channelProgram2;
            
            ChannelProgramLevel channelProgramlevel4 = new ChannelProgramLevel();
            channelProgramlevel4.Name ='Partner';
            channelProgramlevel4.ProgramId = channelProgram2.Id;
            insert channelProgramlevel4;
            
            PRM_AccountChannelMembership__c acm34 = new PRM_AccountChannelMembership__c();
            acm34.PRM_Partner_Role__c = 'Service Provider';
            acm34.PRM_Status_Nm__c = 'Pending';
            acm34.PRM_Channel_Program_Level_Id__c = channelProgramlevel4.Id;
            acm34.PRM_Account_Id__c = acc5.id;
            acm34.PRM_Channel_Program_Id__c = channelProgram2.Id;
             acm34.PRM_Status_Reason_Txt__c='Test';
            insert acm34;
            
            PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
            acm3.PRM_Partner_Role__c = 'Service Provider';
            acm3.PRM_Status_Nm__c = 'Pending';
            acm3.PRM_Channel_Program_Level_Id__c = channelProgramlevel4.Id;
            acm3.PRM_Account_Id__c = acc4.id;
            acm3.PRM_Channel_Program_Id__c = channelProgram2.Id;
             acm3.PRM_Status_Reason_Txt__c='Test';
            insert acm3;
            
            PRM_CIMSearchResults__c searchResult1 = new PRM_CIMSearchResults__c();
            searchResult1.PRM_SearchScore_Nbr__c = 55;
            searchResult1.PRM_Account_Id__c = acc4.id;
            searchResult1.PRM_CIM_Id__c = '2356899';
            
            List<PRM_CIMSearchResults__c> cimList = new List<PRM_CIMSearchResults__c>();
            cimList.add(searchResult1);
            
            Set<id> idSet = new Set<id>();
            idSet.add(acc4.id);
            
            Test.startTest();
            List<PRM_SearchAccounts> listSearchAccounts = PRM_searchSfdcAccounts.getSortedAccountsCim(cimList,idSet,'Service Provider');
            Test.stopTest();
        }
    }
    @isTest
    public static void getSortedAccountsCim_Test2()
    {

        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        

        Account acc4 = new Account();
        acc4.name = 'Testing 123';
        acc4.RecordTypeId = intelaccountRT;
        acc4.BillingCity='Blue Ridge';
        acc4.Core_CIM_ID__c = '22213672';
        acc4.BillingCountry='USA';
        acc4.BillingStreet='700 Chestnut Ridge Rd New';
        acc4.BillingPostalCode='109776435';
        acc4.BillingState=null;
        acc4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc4.Core_IPA_Partner_Role__c = 'Service Provider';
        acc4.Core_Account_Type__c = 'Service Provider';
        acc4.Industry = '';
        insert acc4;
        
        ChannelProgram channelProgram2 = new ChannelProgram();
        channelProgram2.Name = 'Intel Partner Alliance';
        channelProgram2.PRM_programCode__c = 'IPA';
        channelProgram2.IsActive= true;
        insert channelProgram2;
        
        ChannelProgramLevel channelProgramlevel4 = new ChannelProgramLevel();
        channelProgramlevel4.Name ='Partner';
        channelProgramlevel4.ProgramId = channelProgram2.Id;
        insert channelProgramlevel4;
        
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Partner_Role__c = 'Service Provider';
        acm3.PRM_Status_Nm__c = 'Pending';
        acm3.PRM_Channel_Program_Level_Id__c = channelProgramlevel4.Id;
        acm3.PRM_Account_Id__c = acc4.id;
        acm3.PRM_Channel_Program_Id__c = channelProgram2.Id;
        acm3.PRM_Status_Reason_Txt__c='Test';
        insert acm3;
        
        PRM_CIMSearchResults__c searchResult1 = new PRM_CIMSearchResults__c();
        searchResult1.PRM_SearchScore_Nbr__c = 55;
        searchResult1.PRM_Account_Id__c = acc4.id;
        searchResult1.PRM_CIM_Id__c = '2356899';
        
        List<PRM_CIMSearchResults__c> cimList = new List<PRM_CIMSearchResults__c>();
        cimList.add(searchResult1);
        
        Set<id> idSet = new Set<id>();
        idSet.add(acc4.id);
        
        Test.startTest();
        List<PRM_SearchAccounts> listSearchAccounts = PRM_searchSfdcAccounts.getSortedAccountsCim(cimList,idSet,null);
        Test.stopTest();
    }
    
    @isTest
    public static void getSortedAccountsCim_Test3()
    {
        Account acc4 = new Account();
        acc4.name = 'Testing 123';
        acc4.BillingCity='Blue Ridge';
        acc4.Core_CIM_ID__c = '22213672';
        acc4.BillingCountry='USA';
        acc4.BillingStreet='700 Chestnut Ridge Rd New';
        acc4.BillingPostalCode='109776435';
        acc4.BillingState=null;
        acc4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc4.Core_IPA_Partner_Role__c = 'Service Provider';
        acc4.Core_Account_Type__c = 'Service Provider';
        acc4.Industry = '';
        insert acc4;
        
        ChannelProgram channelProgram2 = new ChannelProgram();
        channelProgram2.Name = 'Intel Partner Alliance';
        channelProgram2.PRM_programCode__c = 'IPA';
        channelProgram2.IsActive= true;
        insert channelProgram2;
        
        ChannelProgramLevel channelProgramlevel4 = new ChannelProgramLevel();
        channelProgramlevel4.Name ='Partner';
        channelProgramlevel4.ProgramId = channelProgram2.Id;
        insert channelProgramlevel4;
        
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Partner_Role__c = 'Service Provider';
        acm3.PRM_Status_Nm__c = 'Pending';
        acm3.PRM_Channel_Program_Level_Id__c = channelProgramlevel4.Id;
        acm3.PRM_Account_Id__c = acc4.id;
        acm3.PRM_Status_Reason_Txt__c='Test';
        acm3.PRM_Channel_Program_Id__c = channelProgram2.Id;
        insert acm3;
        
        PRM_CIMSearchResults__c searchResult1 = new PRM_CIMSearchResults__c();
        searchResult1.PRM_SearchScore_Nbr__c = 55;
        searchResult1.PRM_Account_Id__c = null;
        searchResult1.PRM_CIM_Id__c = '2356899';
        integer criteria=6;
        map<integer,List<PRM_SearchAccounts>> cimMap=new map<integer,List<PRM_SearchAccounts>>();
        
        List<PRM_CIMSearchResults__c> cimList = new List<PRM_CIMSearchResults__c>();
        cimList.add(searchResult1);
        
        Set<id> idSet = new Set<id>();
        idSet.add(acc4.id);
        
        Test.startTest();
        List<PRM_SearchAccounts> listSearchAccounts = PRM_searchSfdcAccounts.getSortedAccountsCim(cimList,idSet,'Service Provider');
        cimMap.put(criteria,listSearchAccounts);
        //List<PRM_SearchAccounts> listGetRespLst=PRM_searchSfdcAccounts.getSortedList(cimMap,criteria);
        Test.stopTest();
        //System.assert(listSearchAccounts.size()>0);
        //System.assert(listSearchAccounts.size() != null);
    } 
        
    public static void getSortedAccountsCimAlias_Test()
    {
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        String uniqueUserName = 'standarduser1' + DateTime.now().getTime() + '@example.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User1'];
        User u = new User(Alias = 'abc', Email='standarduser1@example.com',
                          EmailEncodingKey='UTF-8', LastName='TestingTest', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        System.runAs(u) {
            
            Account acc45 = new Account();
            acc45.name = 'Testing 1236';
            acc45.RecordTypeId = intelaccountRT;
            acc45.BillingCity='Blue Ridge6';
            acc45.Core_CIM_ID__c = '222136726';
            acc45.BillingCountry='USA';
            acc45.BillingStreet='7006 Chest Ridge Rd New';
            acc45.BillingPostalCode='10977635';
            acc45.BillingState=null;
            acc45.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
           // acc45.Core_Covered_Account__c=true;
            acc45.Core_IPA_Partner_Role__c = 'Service Provider';
            acc45.Core_Account_Type__c = 'Service Provider';
            acc45.Industry = '';
            insert acc45;
            
            
            ChannelProgram channelProgram23 = new ChannelProgram();
            channelProgram23.Name = 'Intel Partner Alliance';
            channelProgram23.PRM_programCode__c = 'IPA';
            channelProgram23.IsActive= true;

            
            ChannelProgramLevel channelProgramlevel44 = new ChannelProgramLevel();
            channelProgramlevel44.Name ='Partner';
            channelProgramlevel44.ProgramId = channelProgram23.Id;
            insert channelProgramlevel44;
            
            PRM_AccountChannelMembership__c acm345 = new PRM_AccountChannelMembership__c();
            acm345.PRM_Partner_Role__c = 'Service Provider';
            acm345.PRM_Status_Nm__c = 'Pending';
            acm345.PRM_Channel_Program_Level_Id__c = channelProgramlevel44.Id;
            acm345.PRM_Account_Id__c = acc45.id;
            acm345.PRM_Channel_Program_Id__c = channelProgram23.Id;
            insert acm345;
            
                       
            PRM_CIMSearchResults__c searchResult12 = new PRM_CIMSearchResults__c();
            searchResult12.PRM_SearchScore_Nbr__c = 55;
            searchResult12.PRM_Account_Id__c = acc45.id;
            searchResult12.PRM_CIM_Id__c = '2356899';
            
            List<PRM_CIMSearchResults__c> cimList1 = new List<PRM_CIMSearchResults__c>();
            cimList1.add(searchResult12);
            
            Set<id> idSet1 = new Set<id>();
            idSet1.add(acc45.id);
            
            Test.startTest();
            List<PRM_SearchAccounts> listSearchAccounts = PRM_searchSfdcAccounts.getSortedAccountsCim(cimList1,idSet1,'Service Provider');
            Test.stopTest();
        }
    }
   
}