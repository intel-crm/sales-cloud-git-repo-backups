@isTest
public class PMP_SearchSpecialistGroupList_Test extends PMP_SearchWrapperStore{
    @testSetup static void setup(){ 
        //Map<String,Listing> specMap = new Map<String,Listing>();
       
        /*Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Program_nm__c = 'ISA';
        cmp1.PMP_Company_Information_Language_Nm__c = 'English';
        cmp1.PMP_Account_Dsc__c = 'test desc';
        cmp1.PMP_Account_Tag_Line__c = 'test tagline';
        cmp1.PMP_Account_Specialty__c = 'Video';
        cmp1.PMP_Is_Published_Ind__c = true;
        update cmp1;
        System.debug('cmp1 '+cmp1);
        
        PMP_Company__c cmp2 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany2', acc1.Id, true);
        cmp2.PMP_Partner_Program_nm__c = 'ITP';
        cmp2.PMP_Company_Information_Language_Nm__c = 'English';
        cmp2.PMP_Account_Dsc__c = 'test desc';
        cmp2.PMP_Account_Tag_Line__c = 'test tagline';
        cmp2.PMP_Account_Specialty__c = 'Artificial Intelligence';
        cmp2.PMP_Is_Published_Ind__c = true;
        update cmp2;*/
        
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        insert testAccount;
        Id accId = [SELECT id from Account WHERE Name = 'testAccount'].id;
        
        PMP_Company__c testPartner1 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner1',accId , false);
        testPartner1.PMP_Account_Region__c = 'EMEA';
        testPartner1.PMP_Account_Sub_Region__c = 'TAIWAN';
        testPartner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        //testPartner1.PMP_Account_Specialty__c = 'Videos';
        testPartner1.PMP_Account_Industry__c = 'Energy';
        testPartner1.PMP_Account_Application__c = 'Storage';
        testPartner1.PMP_Partner_Program_nm__c = 'ISA;ODM-LOEM';
        testPartner1.PMP_Account_Dsc__c = 'test';
        testPartner1.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner1.PMP_Is_Published_Ind__c = true;
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Published;
        insert testPartner1;
        
        PMP_Company_Region__c reg = new PMP_Company_Region__c();
        reg.PMP_Company_Id__c = testPartner1.Id;
        reg.PMP_Company_Region__c = 'region';
        reg.PMP_Company_Sub_Region__c = 'sub';
        insert reg;
        
        PMP_Company__c testPartner2 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner2',accId , false);
        testPartner2.PMP_Account_Region__c = 'ASMO';
        testPartner2.PMP_Account_Sub_Region__c = 'KOREA';
        //testPartner2.PMP_Account_Specialty__c = 'LOEM-ODM Partner Program';
        testPartner2.PMP_Account_Specialty__c = 'Specialty Partner';
        testPartner2.PMP_Account_Industry__c = 'Energy';
        testPartner2.PMP_Account_Application__c = 'Storage';
        testPartner2.PMP_Partner_Program_nm__c = 'ISA;ODM-LOEM';
        testPartner2.PMP_Account_Dsc__c = 'test';
        testPartner2.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner2.PMP_Is_Published_Ind__c = true;
        testPartner2.PMP_Company_Lifecycle_Status_Nm__c=PMP_StaticConstants_Partner.Published;
        
        insert testPartner2;
        
        PMP_Company__c comp = [SELECT Id FROM PMP_Company__c WHERE PMP_Is_Published_Ind__c = true LIMIT 1];
        
        PMP_Company_Translation__c trans = new PMP_Company_Translation__c();
        trans.Name = 'test';
        trans.PMP_English_Txt__c = 'test';
        trans.PMP_Japanese_Txt__c = 'test';
        trans.PMP_Chinese_Txt__c = 'test';
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Partner.Tagline;
        trans.PMP_Company_Information_Id__c = comp.Id;
        insert trans;
        
        PMP_Partner_Specialty__c spec= new PMP_Partner_Specialty__c();
        spec.Name = 'Artificial Intelligence Specialist';
        spec.PMP_Is_Active_Ind__c=true;
        insert spec;
        
        /*SearchParams Catparms = new SearchParams();
       // Catparms.Cat = 'a3p0n000000GtGgAAK';
        Catparms.type = 'partner';
        
        Listing catList = new Listing();
        catList.label = 'Video';
        catList.imgUrl = 'https://via.placeholder.com/350x197/0071C5/FFFFFF?text=Product';
        catList.page = 'search';
        catList.searchParams = CatParms;
        specMap.put(cmp1.PMP_Account_Specialty__c, catList);
        System.debug('specMap '+specMap);*/
        
    }
    
    @isTest static void testGetSpecialistGroupListData(){
        Test.startTest();
    //    PMP_SearchPartnerController.getPartnerList('');
        PMP_SearchSpecialistGroupListController spec = new PMP_SearchSpecialistGroupListController();
       /* retVal = PMP_SearchSpecialistGroupListController.getSpecialistGroupListData('all','en_US');
        System.assertEquals(2, retVal.size());
        retVal = PMP_SearchSpecialistGroupListController.getSpecialistGroupListData('product','en_US');
        System.assertEquals(null, retVal);
        retVal = PMP_SearchSpecialistGroupListController.getSpecialistGroupListData('all','ja');
        System.assertNotEquals(null, retVal);
        retVal = PMP_SearchSpecialistGroupListController.getSpecialistGroupListData('all','zh_CN');
        System.assertNotEquals(null, retVal);*/
        Test.stopTest();
    }
}