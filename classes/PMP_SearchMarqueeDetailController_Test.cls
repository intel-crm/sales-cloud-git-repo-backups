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
        
        insert stList;
        
        
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
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP - All Intel Admin Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        insert stList;
        
        Account testAccount = PMP_TestDataUtility.createIntelAccount('TestAccount1', '012o0000000GlzTAAS', true);
        Id accId = [SELECT id from Account WHERE Name = 'TestAccount1'].id;
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformation('testPartner',accId , false);
        //testPartner.PMP_Partner_Program_nm__c = 'ODM-LOEM';
        testPartner.PMP_Partner_Program_nm__c = 'ISA';
        testPartner.PMP_Account_Program_Membership__c = 'ISA-General';
        //testPartner.PMP_Account_Program_Membership__c = 'Intel® Internet of Things Solution Alliance General';
        //testPartner.PMP_Account_Program_Membership__c ='ODM-LOEM';
        testPartner.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        testPartner.PMP_Is_Working_Copy_Ind__c=true;
        insert testPartner;
         PMP_Company__c partner = [SELECT id, name, PMP_Partner_Program_nm__c
                                   , PMP_Account_Program_Membership__c 
                                   from PMP_Company__c WHERE PMP_Account_Id__c =: accId ];
        
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
            for (PMP_SearchPartnerProgram_Config__mdt prog: [select PMP_Partner_Program_Name__c,PMP_Partner_Program_Value__c from PMP_SearchPartnerProgram_Config__mdt where Active__c=true 
                               and PMP_Partner_Program_Value__c in :partner.PMP_Partner_Program_nm__c.split(';')]){
               Attribute ppAtt = new Attribute();
               ppAtt.id = prog.PMP_Partner_Program_Value__c;
               ppAtt.label = prog.PMP_Partner_Program_Name__c;
               types.add(ppAtt);
            }
        }
        Map<String, List<Attribute>> partnerAttributes = new Map<String, List<Attribute>>();
        partnerAttributes.put('Category', types);
        partnerWrapper.attributes = partnerAttributes;
        partnerWrapper.categories = types;
        
        System.assertEquals(partnerWrapper.name, PMP_SearchMarqueeDetailController.getPartnerData(partner.id, 'en_US').name);
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentAsset ca = new ContentAsset();
        ca.DeveloperName = 'caDev';
        ca.MasterLabel = 'caTest';
        ca.isVisibleByExternalUsers = TRUE;
        insert ca;
        
        contentDocument cd = new contentDocument();
        cd.Id = contentVersion_2.ContentDocumentId;
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
       
         Test.StartTest();      
         System.assertEquals(partnerWrapper.name, PMP_SearchMarqueeDetailController.getPartnerData(partner.id, 'en_US').name);
         System.assertEquals(null, PMP_SearchMarqueeDetailController.getPartnerData(null, 'en_US').name);
         //System.assertEquals(partnerWrapper.imageUrl, PMP_SearchMarqueeDetailController.getPartnerData(partner.id).imageUrl);
         //System.assertEquals(partnerWrapper.categories.size(), PMP_SearchMarqueeDetailController.getPartnerData(partner.id).categories.size());
         System.assert(PMP_SearchMarqueeDetailController.getPartnerData(partner.id, 'en_US').categories.size() > 0);
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
        
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        PMP_Partner_Offering__c testOffering = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                  'TestDuplicate',cmp1.Id, true,'Published','');
        //testOffering = new PMP_Partner_Offering__c(Name='test_something');
        //insert testOffering;
        PMP_SearchMarqueeDetailController.getProductInformation(testOffering.Id,'en_US');
    }
    
    @isTest static void testFetchOfferingDetail(){
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1', '012o0000000GlzTAAS', true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformation('testPartner1',accId , false);
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
        PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.fetchOfferingDetail(partner.Id, true, true, true, 'zh_CN');
        System.assertNotEquals(null, response);
        Test.stopTest();
        
    }
    
    @isTest static void testFetchOfferingDetailForEnglish(){
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1', '012o0000000GlzTAAS', true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformation('testPartner1',accId , false);
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
        PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.fetchOfferingDetail(partner.Id, true, true, true, 'en_US');
        System.assertNotEquals(null, response);
        Test.stopTest();
        
    }
    
    @isTest static void testFetchOfferingDetailForJapanese(){
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1', '012o0000000GlzTAAS', true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformation('testPartner1',accId , false);
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
        PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.fetchOfferingDetail(partner.Id, true, true, true, 'ja_JP');
        System.assertNotEquals(null, response);
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
        Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1', '012o0000000GlzTAAS', true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformation('testPartner1',accId , false);
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
        PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.fetchOfferingDetailNotPreview(partner.Id, true, true, true, 'ja_JP');
        Test.stopTest();
    }
    
 @isTest static void testGetOfferingDetail(){
     Account testAccount = PMP_TestDataUtility.createIntelAccount('testAccount1', '012o0000000GlzTAAS', true);
        Id accId = [SELECT id from Account WHERE Name = 'testAccount1'].id;
        PMP_Company__c testPartner =  PMP_TestDataUtility.createCompanyInformation('testPartner1',accId , false);
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
        PMP_LightningServerResponse response=PMP_SearchMarqueeDetailController.getOfferingDetail(partner.Id, true, true, true, 'ja_JP',true);
     PMP_LightningServerResponse response1=PMP_SearchMarqueeDetailController.getOfferingDetail(partner.Id, true, true, true, 'ja_JP',false);
        Test.stopTest();
 }

}