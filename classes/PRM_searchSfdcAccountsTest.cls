@isTest
public class PRM_searchSfdcAccountsTest {
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
        System.debug('INTEL ACCOUNT RT VALUE : '+intelaccountRT);
        
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@test.com';
        ct.AccountId=acc.id;      
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
        System.debug('INTEL ACCOUNT RT VALUE : '+intelaccountRT);
        
        contact ct1 = new contact();
        ct1.FirstName='None';
        ct1.LastName='New';
        ct1.Email='newone@test.com';
        ct1.AccountId=acc1.id;      
        insert ct1;
        
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
        
        ChannelProgramLevel channelProgramlevel1 = new ChannelProgramLevel();
        channelProgramlevel1.Name ='Titanium';
        channelProgramlevel1.ProgramId = channelProgram.Id;
        insert channelProgramlevel1;
        
        acm1.PRM_Channel_Program_Level_Id__c = channelProgramlevel1.Id;
        insert acm1;
        
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.add(acc.id);
        accountIdSet.add(acc1.id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_CIMAccountSearchHttpResponse());
        
       
        
        PRM_UICIMCallout prmUICimCallout = new PRM_UICIMCallout();
        List<PRM_CIMSearchResults__c> listOfCimResult = prmUICimCallout.getCimResults('Sample', 'Magarpatta', '411024','Maharashtra','IN','MH','10','40','www.sampletest.com',null,'nexttest@test.com','Service Provider');
        System.debug('>>>>>>>>> listOfCimResult '+listOfCimResult);
        
        List<PRM_SearchAccounts> lstSearchAccountObj = PRM_searchSfdcAccounts.getSortedAccountsCim(listOfCimResult,accountIdSet,'Service Provider');
       
        System.assert(lstSearchAccountObj!=null && lstSearchAccountObj.size()>0);
        Test.stopTest();
    }
  @isTest
    public static void instCimSearchResults_Test()
    {
		PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.PRM_Account_Name__c = 'Safari';
        regRequest.PRM_City__c = 'Bengaluru';
        Test.startTest();
        PRM_CIMSearchResults__c cimSearch = PRM_searchSfdcAccounts.instCimSearchResults(regRequest,'0016C00000GbI8cQAF');
        Test.stopTest();
    }
   @isTest
    public static void getSortedAccountsCim_Test()
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
        channelProgramlevel4.Name ='Members';
        channelProgramlevel4.ProgramId = channelProgram2.Id;
        insert channelProgramlevel4;
        
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Partner_Role__c = 'Service Provider';
        acm3.PRM_Status_Nm__c = 'Pending';
        acm3.PRM_Channel_Program_Level_Id__c = channelProgramlevel4.Id;
        acm3.PRM_Account_Id__c = acc4.id;
        acm3.PRM_Channel_Program_Id__c = channelProgram2.Id;
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
    @isTest
    public static void getSortedAccountsCim_Test1()
    {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@example.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'iuser', Email='standarduser@example.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        System.runAs(u) {
              System.debug('Current User: ' + UserInfo.getUserName());
              System.debug('Current Profile: ' + UserInfo.getProfileId());
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
        channelProgramlevel4.Name ='Members';
        channelProgramlevel4.ProgramId = channelProgram2.Id;
        insert channelProgramlevel4;
        
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Partner_Role__c = 'Service Provider';
        acm3.PRM_Status_Nm__c = 'Pending';
        acm3.PRM_Channel_Program_Level_Id__c = channelProgramlevel4.Id;
        acm3.PRM_Account_Id__c = acc4.id;
        acm3.PRM_Channel_Program_Id__c = channelProgram2.Id;
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
        channelProgramlevel4.Name ='Members';
        channelProgramlevel4.ProgramId = channelProgram2.Id;
        insert channelProgramlevel4;
        
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Partner_Role__c = 'Service Provider';
        acm3.PRM_Status_Nm__c = 'Pending';
        acm3.PRM_Channel_Program_Level_Id__c = channelProgramlevel4.Id;
        acm3.PRM_Account_Id__c = acc4.id;
        acm3.PRM_Channel_Program_Id__c = channelProgram2.Id;
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
        channelProgramlevel4.Name ='Members';
        channelProgramlevel4.ProgramId = channelProgram2.Id;
        insert channelProgramlevel4;
        
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Partner_Role__c = 'Service Provider';
        acm3.PRM_Status_Nm__c = 'Pending';
        acm3.PRM_Channel_Program_Level_Id__c = channelProgramlevel4.Id;
        acm3.PRM_Account_Id__c = acc4.id;
        acm3.PRM_Channel_Program_Id__c = channelProgram2.Id;
        insert acm3;
        
		PRM_CIMSearchResults__c searchResult1 = new PRM_CIMSearchResults__c();
        searchResult1.PRM_SearchScore_Nbr__c = 55;
        searchResult1.PRM_Account_Id__c = null;
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