@isTest
public class PMP_SearchMarqueeDetailController_Test extends PMP_SearchWrapperStore{
    
    @testSetup static void setup(){
        
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_LOEM_ODM_Partner_Program';
        st.PMP_Value__c = 'LOEM-ODM Partner Program';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Off_Sort_By_Featured';
        st.PMP_Value__c = 'PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Status_Update_Dt__c DESC NULLS LAST';
        stList.add(st);
        
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
        
        insert stList;
        
        PMP_Partner_Program__c pp = new PMP_Partner_Program__c();
        pp.Name = 'Manufacturer';
        pp.PMP_Is_Active_Ind__c = true;
        pp.PMP_Partner_Program_Value_Txt__c = 'Manufacturer';
        insert pp;
        
        
    }
    
    
    @isTest static void testGetPartnerData() {
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Application_Id';
        st.PMP_Value__c = 'NPP_01_APP';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Region_Id';
        st.PMP_Value__c = 'NPP_GeographicCoverage';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_LOEM_ODM_Partner_Program';
        st.PMP_Value__c = 'LOEM-ODM Partner Program';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_BENEFIT_ENHANCED_CODE';
        st.PMP_Value__c = 'BFTMKTPLED';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Sys_Admin_Profile';
        st.PMP_Value__c = 'System Administrator';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_IT_Admin_Profile';
        st.PMP_Value__c = ' IT Admin';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Thumbnail_Image';
        st.PMP_Value__c = 'Thumbnail Image';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Off_Sort_By_Featured';
        st.PMP_Value__c = 'PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Status_Update_Dt__c DESC NULLS LAST';
        stList.add(st);
        
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_LDR',PMP_Value__c='PMP_External_Lead_Development_Representative'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Marketing_Specialist',PMP_Value__c='PMP_External_Marketing_Specialist'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Offering_Editor',PMP_Value__c='PMP_External_Offering_Editor'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Partner_Admin',PMP_Value__c='PMP_External_Partner_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Guest_User_Name',PMP_Value__c='Intel® Solutions Marketplace Site Guest User'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        insert stList;
        
        Account testAccount = PMP_TestDataUtility.createIntelAccount('TestAccount1',  PMP_TestDataUtility.intel_Account_Record_Type, true);
        Id accId = [SELECT id from Account WHERE Name = 'TestAccount1'].id;
        //PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformation('testPartner',accId , false);
        
        PMP_Company__c partner_wc = new PMP_Company__c(Name='workingPartner', 
                                                       PMP_Is_Working_Copy_Ind__c = true,
                                                       PMP_Is_Enabled_Lead_Gen_Nm__c = 'true',
                                                       PMP_Is_Lead_Gen_Limited_Nm__c = 'true',
                                                       PMP_Company_Lead_Gen_Language_Nm__c = 'English',
                                                       PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile,
                                                       PMP_Company_Lifecycle_Status_Nm__c = 'Draft');
        insert partner_wc;
        
        PMP_Company__c testPartner=new PMP_Company__c();
        testPartner.Name='testPartner';
        testPartner.PMP_Benefit_Update_Ind__c=False;
        testPartner.PMP_Partner_Inactive_Ind__c = False;
        testPartner.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        testPartner.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        testPartner.PMP_Is_Published_Ind__c=true;
        testPartner.PMP_Working_Copy_Id__c = partner_wc.Id;
        //testPartner.PMP_Partner_Program_nm__c = 'ODM-LOEM';
        testPartner.PMP_Partner_Program_nm__c = 'Manufacturer';
        testPartner.PMP_Account_Program_Membership__c = 'Manufacturer - Gold;Distributor - Intel Approved Component Supplier (IACS);Distributor - Intel Authorized Distributor (IAD)';
        //testPartner.PMP_Account_Program_Membership__c = 'Intel® Internet of Things Solution Alliance General';
        //testPartner.PMP_Account_Program_Membership__c ='ODM-LOEM';
        //testPartner.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        //testPartner.PMP_Is_Working_Copy_Ind__c=true;
        
        insert testPartner;
        
        PMP_OPID_MPI_Rel__c NewOpid = new PMP_OPID_MPI_Rel__c();
        NewOpid.PMP_Marketing_Profile_Id__c = testPartner.id;
        NewOpid.PMP_One_Partner_ID__c = accId;
        NewOpid.Is_Active__c = true;
        insert NewOpid;
        
        
        PMP_Company__c partner = [SELECT id, name, PMP_Partner_Program_nm__c
                                  , PMP_Account_Program_Membership__c 
                                  from PMP_Company__c WHERE name =: 'testPartner' Limit 1 ];
        
        PartnerDetail partnerWrapper = new PartnerDetail();
        partnerWrapper.id = partner.id;
        partnerWrapper.categoryId = partner.id;
        partnerWrapper.name = partner.Name;
        partnerWrapper.imageUrl = 'https://www.intel.com/content/dam/products/hero/foreground/badge-9th-gen-core-i9-1x1.png.rendition.intel.web.550.550.png';
        partnerWrapper.partnerName = partner.Name;
        partnerWrapper.partnerLink = 'intel';
        List<Attribute> types = new List<Attribute>();
        //Tier attribute "hard-Coded" until master data is finalized
        Attribute tierAtt = new Attribute();
        tierAtt.id = partner.PMP_Account_Program_Membership__c;
        tierAtt.label = partner.PMP_Account_Program_Membership__c;
        types.add(tierAtt);
        if(partner.PMP_Partner_Program_nm__c!=null){
      /*      for (PMP_SearchPartnerProgram_Config__mdt prog: [select PMP_Partner_Program_Name__c,PMP_Partner_Program_Value__c from PMP_SearchPartnerProgram_Config__mdt where Active__c=true 
                                                             and PMP_Partner_Program_Value__c in :partner.PMP_Partner_Program_nm__c.split(';')]){
                                                                 Attribute ppAtt = new Attribute();
                                                                 ppAtt.id = prog.PMP_Partner_Program_Value__c;
                                                                 ppAtt.label = prog.PMP_Partner_Program_Name__c;
                                                                 types.add(ppAtt);
                                                             }*/
        for (PMP_Partner_Program__c prog: [select Name,PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c where PMP_Is_Active_Ind__c=true 
                                                         and PMP_Partner_Program_Value_Txt__c in :partner.PMP_Partner_Program_nm__c.split(';')]){
                                                                 Attribute ppAtt = new Attribute();
                                                                 ppAtt.id = prog.PMP_Partner_Program_Value_Txt__c;
                                                                 ppAtt.label = prog.Name;
                                                                 types.add(ppAtt);
                                                             }
        }
        Map<String, List<Attribute>> partnerAttributes = new Map<String, List<Attribute>>();
        partnerAttributes.put('Category', types);
        partnerWrapper.attributes = partnerAttributes;
        partnerWrapper.categories = types;
        PMP_SearchMarqueeDetailController.getPartnerData(partner_wc.id, 'en_US');
        System.assertEquals(partnerWrapper.name, PMP_SearchMarqueeDetailController.getPartnerData(partner.id, 'en_US').name,'Failed');
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;
        ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id LIMIT 1];
        ContentAsset ca = new ContentAsset();
        ca.DeveloperName = 'caDev';
        ca.MasterLabel = 'caTest';
        ca.isVisibleByExternalUsers = TRUE;
        insert ca;
        
        contentDocument cd = new contentDocument();
        cd.Id = contentVersion2.ContentDocumentId;
        cd.ContentAssetId = ca.Id;
        update cd;
        
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Company_Resource__c resource=new PMP_Company_Resource__c();
        resource.PMP_Company_Id__c=partner.Id;
        resource.PMP_Company_Image__c=cd.Id;
        resource.PMP_Company_Resource_Type_Nm__c='Image';
        resource.PMP_Company_Resource_Sequence_Nbr__c=0;
        insert resource;
        
        Profile prof = [select id from profile where name LIKE '%Intel® Solutions Marketplace Profile%'];
        User portalAccountOwner1 = new User(
        ProfileId = prof.Id,
        Username = System.now().millisecond() + 'testmarquee@test.com',
        Alias = 'batman',
        Email='bruce.wayne1@intel.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruce1',
        Lastname='Wayne1',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        insert portalAccountOwner1;
        system.runAs(portalAccountOwner1){
            PMP_SearchMarqueeDetailController.getPartnerData(partner.id, 'en_US');
        }
        
        Test.StartTest();      
        System.assertEquals(partnerWrapper.name, PMP_SearchMarqueeDetailController.getPartnerData(partner.id, 'en_US').name,'Failed');
        System.assertEquals(null, PMP_SearchMarqueeDetailController.getPartnerData(null, 'en_US').name,'Failed');
        //System.assertEquals(partnerWrapper.imageUrl, PMP_SearchMarqueeDetailController.getPartnerData(partner.id).imageUrl);
        //System.assertEquals(partnerWrapper.categories.size(), PMP_SearchMarqueeDetailController.getPartnerData(partner.id).categories.size());
        System.assert(PMP_SearchMarqueeDetailController.getPartnerData(partner.id, 'en_US').categories.size() > 0,'Failed');
        Test.StopTest();
        
    }
    
    public class PartnerDetail {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String categoryId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String imageUrl { get; set; }//  'https://via.placeholder.com/350x197/0071C5/FFFFFF?text=Partner';
        @AuraEnabled public String partnerName { get; set; }
        @AuraEnabled public String partnerLink { get; set; }        
        @AuraEnabled public Map<String, List<Attribute>> attributes { get; set; }
        @AuraEnabled public List<Attribute> categories { get; set; } 
    }
    
    public class Attribute{
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String label { get; set; }
    }
    
    
    @isTest static void getProductInformation(){
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
        
        //PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformationWithBenefit('TestCompany1', acc1.Id, true, PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformationWithBenefit('TestCompany1', acc1.Id, true, PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
        
        //PMP_Partner_Offering__c testOffering = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                  //'TestDuplicate',cmp1.Id, true,'Published','');
        //testOffering.PMP_Partner_Offering_Tag_Line_Txt__c='Test';
        //update testOffering;
        //testOffering = new PMP_Partner_Offering__c(Name='test_something');
        //insert testOffering;
        system.assertNotEquals(NULL,PMP_SearchMarqueeDetailController.getProductInformation(cmp1.Id,'en_US'),'Failed');
    }
    
    @isTest static void testFetchOfferingDetail(){
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        //PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
		PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
        testPartner.PMP_Partner_Program_nm__c = 'ISA';
        //testPartner.PMP_Account_Program_Membership__c = 'Intel® Internet of Things Solution Alliance General';
        testPartner.PMP_Account_Program_Membership__c ='ITP - GOLD';
        testPartner.PMP_Is_Working_Copy_Ind__c=true;
        insert testPartner;
        
        PMP_Partner_Offering__c partner=new PMP_Partner_Offering__c();
        partner.PMP_Business_Segment_Nm__c='IoT;Server';
        partner.PMP_Partner_Offering_Dsc__c='<p>test Name</p>';
        partner.PMP_Offering_Language_Nm__c='English';
        partner.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Test';
        partner.PMP_Company_Id__c=testPartner.Id;
        partner.PMP_Partner_Offering_Tag_Line_Txt__c='TNS';
        insert partner;
        
        PMP_Partner_Offering_Translation__c translation=new PMP_Partner_Offering_Translation__c();
        translation.PMP_Chinese_Txt__c='Test';
        translation.PMP_English_Txt__c='Test';
        translation.PMP_Japanese_Txt__c='Test';
        translation.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        translation.PMP_Partner_Offering_Id__c=partner.Id;
        insert translation;
        
        Test.startTest();
        //PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.fetchOfferingDetail(partner.Id, true, true, true, 'zh_CN', null);
        //PMP_LightningServerResponse response1=PMP_SearchMarqueeDetailController.fetchOfferingDetail(partner.Id, true, true, true, 'zh_CN', 'ja');
        //PMP_LightningServerResponse response2=PMP_SearchMarqueeDetailController.fetchOfferingDetail(partner.Id, true, true, true, null, null);
        //to cover catch block, offering id is hardcoded
        //PMP_LightningServerResponse response3=PMP_SearchMarqueeDetailController.fetchOfferingDetail('a3s0n0000008C7HUUU', true, true, true, null, null);
        //PMP_SearchMarqueeDetailController.offeringSpecValueMap offeringSpec = new PMP_SearchMarqueeDetailController.offeringSpecValueMap();//IPA 2.0 OFFERING EOL
        //offeringSpec.masterCategory='test';
        List<string> str = new List<string>();
        str.add('test');
        //offeringSpec.valueList=str;
        //System.assertNotEquals(null, response,'Failed');
        //System.assertNotEquals(null, response1,'Failed');
        
        Test.stopTest();
        
    }
    
    @isTest static void testFetchOfferingDetailForEnglish(){
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1',  PMP_TestDataUtility.intel_Account_Record_Type, true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        //PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
        testPartner.PMP_Partner_Program_nm__c = 'ISA';
        //testPartner.PMP_Account_Program_Membership__c = 'Intel® Internet of Things Solution Alliance General';
        testPartner.PMP_Account_Program_Membership__c ='ITP - GOLD';
        testPartner.PMP_Is_Working_Copy_Ind__c=true;
        insert testPartner;
        
        PMP_Partner_Offering__c partner=new PMP_Partner_Offering__c();
        partner.PMP_Business_Segment_Nm__c='IoT;Server';
        partner.PMP_Partner_Offering_Dsc__c='<p>test Name</p>';
        partner.PMP_Offering_Language_Nm__c='English';
        partner.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Test';
        partner.PMP_Company_Id__c=testPartner.Id;
        partner.PMP_Partner_Offering_Tag_Line_Txt__c='TNS';
        insert partner;
        
        PMP_Partner_Offering_Translation__c translation=new PMP_Partner_Offering_Translation__c();
        translation.PMP_Chinese_Txt__c='Test';
        translation.PMP_English_Txt__c='Test';
        translation.PMP_Japanese_Txt__c='Test';
        translation.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        translation.PMP_Partner_Offering_Id__c=partner.Id;
        insert translation;
        
        Test.startTest();
        //PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.fetchOfferingDetail(partner.Id, true, true, true, 'en_US', null);
        //System.assertNotEquals(null, response,'Failed');
        Test.stopTest();
        
    }
    
    @isTest static void testFetchOfferingDetailForJapanese(){
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1',  PMP_TestDataUtility.intel_Account_Record_Type, true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        //PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
        testPartner.PMP_Partner_Program_nm__c = 'ISA';
        //testPartner.PMP_Account_Program_Membership__c = 'Intel® Internet of Things Solution Alliance General';
        testPartner.PMP_Account_Program_Membership__c ='ITP - GOLD';
        testPartner.PMP_Is_Working_Copy_Ind__c=true;
        insert testPartner;
        
        List<PMP_Partner_Offering__c> off=new List<PMP_Partner_Offering__c>();
        
        PMP_Partner_Offering__c partner=new PMP_Partner_Offering__c();
        partner.PMP_Business_Segment_Nm__c='IoT;Server';
        partner.PMP_Partner_Offering_Dsc__c='<p>test Name</p>';
        partner.PMP_Offering_Language_Nm__c='English';
        partner.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Test';
        partner.PMP_Company_Id__c=testPartner.Id;
        partner.PMP_Partner_Offering_Tag_Line_Txt__c='TNS';
        insert partner;
        
        
        
        PMP_Partner_Offering_Translation__c translation=new PMP_Partner_Offering_Translation__c();
        translation.PMP_Chinese_Txt__c='Test';
        translation.PMP_English_Txt__c='Test';
        translation.PMP_Japanese_Txt__c='Test';
        translation.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        translation.PMP_Partner_Offering_Id__c=partner.Id;
        insert translation;
        
        Test.startTest();
        //PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.fetchOfferingDetail(partner.Id, true, true, true, 'ja_JP', null);
        //System.assertNotEquals(null, response,'Failed');
        // PMP_LightningServerResponse response1=PMP_SearchMarqueeDetailController.fetchOfferingDetail(null, true, true, true, 'ja_JP',true);
        //System.assertNotEquals(null, response1);
        
        Test.stopTest();
        
    }
    
    /*@isTest static void testGetProduct(){
PMP_Partner_Offering__c partner=new PMP_Partner_Offering__c();
partner.PMP_Business_Segment_Nm__c='IoT;Server';
partner.PMP_Partner_Offering_Dsc__c='<p>test Name</p>';
partner.PMP_Offering_Language_Nm__c='English';
partner.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Test';
partner.PMP_Partner_Offering_Tag_Line_Txt__c='TNS';
insert partner;

Test.startTest();
List<PMP_SearchProductController.Product> li=PMP_SearchMarqueeDetailController.getProduct(partner.Id);
System.assertEquals(1, li.size());
Test.stopTest();
}*/
    
    @isTest static void testFetchOfferingDetailNotPreview(){
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1',  PMP_TestDataUtility.intel_Account_Record_Type, true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        //PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
        testPartner.PMP_Partner_Program_nm__c = 'ISA';
        //testPartner.PMP_Account_Program_Membership__c = 'Intel® Internet of Things Solution Alliance General';
        testPartner.PMP_Account_Program_Membership__c ='ITP - GOLD';
        testPartner.PMP_Is_Working_Copy_Ind__c=true;
        insert testPartner;
        
        List<PMP_Partner_Offering__c> off=new List<PMP_Partner_Offering__c>();
        
        PMP_Partner_Offering__c partner=new PMP_Partner_Offering__c();
        partner.PMP_Business_Segment_Nm__c='IoT;Server';
        partner.PMP_Partner_Offering_Dsc__c='<p>test Name</p>';
        partner.PMP_Offering_Language_Nm__c='English';
        partner.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Test';
        partner.PMP_Company_Id__c=testPartner.Id;
        partner.PMP_Partner_Offering_Tag_Line_Txt__c='TNS';
        insert partner;
        
        
        
        PMP_Partner_Offering_Translation__c translation=new PMP_Partner_Offering_Translation__c();
        translation.PMP_Chinese_Txt__c='Test';
        translation.PMP_English_Txt__c='Test';
        translation.PMP_Japanese_Txt__c='Test';
        translation.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        translation.PMP_Partner_Offering_Id__c=partner.Id;
        insert translation;
        Test.startTest();
        //PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.fetchOfferingDetailNotPreview(partner.Id, true, true, true, 'ja_JP', null);
        //system.assertNotEquals(NULL,response,'Failed');
        Test.stopTest();
        
    }
    
    @isTest static void testGetOfferingDetail(){
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1',  PMP_TestDataUtility.intel_Account_Record_Type, true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        //PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
        testPartner.PMP_Partner_Program_nm__c = 'ISA';
        //testPartner.PMP_Account_Program_Membership__c = 'Intel® Internet of Things Solution Alliance General';
        testPartner.PMP_Account_Program_Membership__c ='ITP - GOLD';
        testPartner.PMP_Is_Working_Copy_Ind__c=true;
        insert testPartner;
        
        List<PMP_Partner_Offering__c> off=new List<PMP_Partner_Offering__c>();
        
        PMP_Partner_Offering__c partner1=new PMP_Partner_Offering__c();
        partner1.PMP_Business_Segment_Nm__c='IoT;Server';
        partner1.PMP_Partner_Offering_Dsc__c='<p>test Name</p>';
        partner1.PMP_Offering_Language_Nm__c='English';
        partner1.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Test';
        partner1.PMP_Company_Id__c=testPartner.Id;
        partner1.PMP_Partner_Offering_Tag_Line_Txt__c='TNS';
        insert partner1;
        
        PMP_Partner_Offering__c partner=new PMP_Partner_Offering__c();
        partner.PMP_Business_Segment_Nm__c='IoT;Server';
        partner.PMP_Partner_Offering_Dsc__c='<p>test Name</p>';
        partner.PMP_Offering_Language_Nm__c='English';
        partner.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Test';
        partner.PMP_Company_Id__c=testPartner.Id;
        partner.PMP_Working_Copy_Id__c=partner1.Id;
        partner.PMP_Partner_Offering_Tag_Line_Txt__c='TNS';
        insert partner;
        
        
        
        PMP_Partner_Offering_Translation__c translation=new PMP_Partner_Offering_Translation__c();
        translation.PMP_Chinese_Txt__c='Test';
        translation.PMP_English_Txt__c='Test';
        translation.PMP_Japanese_Txt__c='Test';
        translation.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        translation.PMP_Partner_Offering_Id__c=partner.Id;
        insert translation;
        Test.startTest();
        //PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.getOfferingDetail(partner.Id, true, true, true, 'ja_JP', null, true);//IPA 2.0  Offering EOL
        //PMP_LightningServerResponse response1=PMP_SearchMarqueeDetailController.getOfferingDetail(partner.Id, true, true, true, 'ja_JP',null, false);//IPA 2.0  Offering EOL
        //PMP_LightningServerResponse response2=PMP_SearchMarqueeDetailController.getOfferingDetail(partner.Id, true, true, true, null,'ja', false);//IPA 2.0  Offering EOL
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='ja', 
                          LocaleSidKey='ja', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@intel.com');  
        System.runAs(u) {
            // The following code runs as user 'u' 
            //PMP_LightningServerResponse response3=PMP_SearchMarqueeDetailController.getOfferingDetail(partner.Id, true, true, true, null,'ja', false);//IPA 2.0  Offering EOL
            //system.assertNotEquals(NULL,response3,'Failed');
            // System.debug('Current User: ' + UserInfo.getUserName());
            // System.debug('Current Profile: ' + UserInfo.getProfileId()); 
        }
        Test.stopTest();
    }

    @isTest static void testGetOfferingDetailProductDetails(){
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1',  PMP_TestDataUtility.intel_Account_Record_Type, true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        //PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformationWithBenefit('testPartner1',accId , false, PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
        testPartner.PMP_Partner_Program_nm__c = 'ISA';
        //testPartner.PMP_Account_Program_Membership__c = 'Intel® Internet of Things Solution Alliance General';
        testPartner.PMP_Account_Program_Membership__c ='ITP - GOLD';
        testPartner.PMP_Is_Working_Copy_Ind__c=true;
        insert testPartner;
        
        List<PMP_Partner_Offering__c> off=new List<PMP_Partner_Offering__c>();
        
        PMP_Partner_Offering__c partner=new PMP_Partner_Offering__c();
        partner.PMP_Business_Segment_Nm__c='IoT;Server';
        partner.PMP_Partner_Offering_Dsc__c='<p>test Name</p>';
        partner.PMP_Offering_Language_Nm__c='English';
        partner.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Test';
        partner.PMP_Company_Id__c=testPartner.Id;
        partner.PMP_Partner_Offering_Tag_Line_Txt__c='TNS';
        insert partner;
        
        
        
        PMP_Partner_Offering_Translation__c translation=new PMP_Partner_Offering_Translation__c();
        translation.PMP_Chinese_Txt__c='Test';
        translation.PMP_English_Txt__c='Test';
        translation.PMP_Japanese_Txt__c='Test';
        translation.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        translation.PMP_Partner_Offering_Id__c=partner.Id;
        insert translation;
        Test.startTest();
        //PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.getOfferingDetailProductDetails(partner.Id, true, true, true, 'ja_JP', null, true);
       	//PMP_LightningServerResponse response1=PMP_SearchMarqueeDetailController.getOfferingDetailProductDetails(partner.Id, true, true, true, 'ja_JP',null, false);
        //PMP_LightningServerResponse response2=PMP_SearchMarqueeDetailController.getOfferingDetailProductDetails(partner.Id, true, true, true, null,'ja', false);
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='ja', 
                          LocaleSidKey='ja', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@intel.com');  
        System.runAs(u) {
            // The following code runs as user 'u' 
            //PMP_LightningServerResponse response3=PMP_SearchMarqueeDetailController.getOfferingDetailProductDetails(partner.Id, true, true, true, null,'ja', false);
            //system.assertNotEquals(NULL,response3,'Failed');
            // System.debug('Current User: ' + UserInfo.getUserName());
            // System.debug('Current Profile: ' + UserInfo.getProfileId()); 
        }
        Test.stopTest();
    }
    
    @isTest static void testCheckLegalAgreementForAllLocations(){     
         
        //Create portal account owner
        User thisUser = [ select Id from User where Id =:UserInfo.getUserId()];
        //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        UserRole portalRole = new UserRole(DeveloperName ='MyCustomRole',Name = 'My Role',PortalType='None');
        insert portalRole;
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2Soo@test.com',
            Alias = 'batman',
            Email='bruce.wayne1@intel.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce1',
            Lastname='Wayne1',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert portalAccountOwner1;
                   
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
                Account accObj1 = new Account();
                Contact conObj1 =null;
                User user1 =null;
                
                
        
         System.runAs(portalAccountOwner1){
            accObj1.Name='test';
            accObj1.RecordTypeId = devRecordTypeId;
            accObj1.BillingStreet='1417 R Street';
            accObj1.BillingCity='Apple Valley';
            accObj1.BillingCountry='USA';    
            accObj1.BillingState='MN';
            accObj1.OwnerId=portalAccountOwner1.Id;
            accObj1.BillingPostalCode='55124';
            insert accObj1; 
             
             Account newAccount = new Account();//Account
                newAccount.RecordTypeId = recordTypeIdPAGAccount;
                newAccount.Name='Greg Thomas';
                newAccount.BillingCity='City';
                newAccount.BillingStreet='Street';
                newAccount.BillingCountry='India';
                newAccount.BillingPostalCode='Postal code';
                newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
                insert newAccount;
             
             //Core_Account_Group_Member__c creation
             Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
             coreAccnt.Core_Partner_Account_Id__c = newAccount.id;
             coreAccnt.Core_Intel_Account_Id__c = accObj1.id;
             insert coreAccnt;
            
            conObj1 = PMP_TestDataUtility.createContact(accObj1.id,true);
            conObj1.AccountId=accObj1.Id;
            update conObj1;
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='Partner' Limit 1];
            user1 = new User(
            Username = 'MP' + System.now().millisecond() + String.valueOf(Math.random()) + 'test123@test.com',
            ContactId = conObj1.Id,
           // UserRoleId = portalRole.Id,
            ProfileId = portalProfile.Id,
            Alias = 'MPtest12',
            Email = 'test123456@intel.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'MP_Solutions'+Date.today().day()+Datetime.now().second(),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
          ); 
            insert user1;
            }
        
        PermissionSet psEmployee = [SELECT id, Name from PermissionSet where Name =:PMP_StaticConstants_Partner.EMPLOYEE];
        PermissionSetAssignment permEmployee = new PermissionSetAssignment();
        permEmployee.AssigneeId = user1.Id;
        permEmployee.PermissionSetId = psEmployee.Id;
        insert permEmployee;

        system.runAs(user1) {
        Test.startTest();
        system.assertNotEquals(NULL,PMP_SearchMarqueeDetailController.checkLegalAgreementForAllLocations(),'Failed');
        Test.stopTest();
       }
    }
}