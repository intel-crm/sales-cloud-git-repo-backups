@isTest
public class PMP_SearchPartnerDetailsController_Test extends PMP_SearchWrapperStore{
    
    @testSetup static void setupTestData (){
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
        
        system.debug('-----'+UserInfo.getUserName());
        Test.startTest();
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_SearchTestDataFactory.createContentDocument(true);
        List<String> contIdlst = new List<String>();
        for(ContentDocument cd : [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Limit 5]){
            contIdlst.add(cd.Id);
        }
        PMP_Company__c testpartnerWc = PMP_SearchTestDataFactory.createCompanyInformation('testPartnerWc', acc1.Id, true);
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);                
        cmp1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        cmp1.PMP_Account_Dsc__c = 'Description below the limit.';
        cmp1.PMP_Company_Status_Update_Dt__c = system.today();
        cmp1.PMP_Is_Working_Copy_Ind__c = true;
        cmp1.PMP_Initial_Storefront_Submit_Date_Dt__c =system.today();
        update cmp1;
        
        PMP_Company__c cmp2 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany2', acc1.Id, true);        
        cmp2.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        cmp2.PMP_Account_Dsc__c = 'Description below the limit.';
        cmp2.PMP_Working_Copy_Id__c = cmp1.id;
        cmp2.PMP_Account_Tag_Line__c='Description below the limit.';
        update cmp2;
        
        
        
        
        
        
        
        PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
                                                                                     'TestDuplicate',cmp1.Id, true,'Draft','');
        
        
        
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Company_Resource__c resource=new PMP_Company_Resource__c();
        resource.PMP_Company_Id__c=cmp2.Id;
        resource.PMP_Company_Image__c=document.Id;
        resource.PMP_Company_Resource_Type_Nm__c='White Paper';
        resource.PMP_Company_Resource_Sequence_Nbr__c=0;
        
        insert resource;
        
        List<ContentDocument> doc1=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document1=[select Id from ContentDocument limit 1];
        PMP_Company_Resource__c resource1=new PMP_Company_Resource__c();
        resource1.PMP_Company_Id__c=cmp2.Id;
        resource1.PMP_Company_Image__c=document1.Id;
        resource1.PMP_Company_Resource_Type_Nm__c= PMP_StaticConstants_Partner.IMAGE;
        resource1.PMP_Company_Resource_Sequence_Nbr__c=0;
        
        insert resource1;
        
        
        
        PMP_Specification__c parentSpec= PMP_SearchTestDataFactory.getSpecs();
        
        PMP_Partner_Offering_Specification__c offSpecs = PMP_SearchTestDataFactory.getPMPOfferingSpecification(offering1.id);
        offSpecs.PMP_Display_Type_Nm__c = 'Checkbox';
        update offSpecs;
        
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec2;
        PMP_Specification_Value__c specValue0 = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue0;
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec.PMP_Company_Id__c = cmp2.Id;
        insert ptnrSpec;
        
        PMP_Company_Region__c ptnrSpec1 = new PMP_Company_Region__c();
        ptnrSpec1.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec1.PMP_Company_Id__c = cmp2.Id;
        insert ptnrSpec1;
        
        PMP_Company_Region__c ptnrSpec2 = new PMP_Company_Region__c();
        ptnrSpec2.PMP_Specification_Id__c = spec2.Id;
        ptnrSpec2.PMP_Company_Id__c = cmp2.Id;
        insert ptnrSpec2;
        
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        //cat0.PMP_Parent_Category_Id__c = null; 
        //app0.PMP_Parent_Category_Id__c = null;
        //ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        update catList;
        
        PMP_Partner_Offering_Category__c offCat1 = new PMP_Partner_Offering_Category__c();
        offCat1.PMP_Category_Id__c = cat1.Id;
        offCat1.PMP_Offering_Id__c = offering1.Id;
        insert offCat1;
        
        PMP_Partner_Category__c ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = app1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp2.Id;
        insert ptnrCat;
        
        PMP_Partner_Category__c ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = app1.Id;
        ptnrCat1.PMP_Partner_Id__c = cmp2.Id;
        insert ptnrCat1;
        
        PMP_Partner_Category__c ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = app2.Id;
        ptnrCat2.PMP_Partner_Id__c = cmp2.Id;
        insert ptnrCat2;
        
        ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = ind1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp2.Id;
        insert ptnrCat;
        
        ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = ind1.Id;
        ptnrCat1.PMP_Partner_Id__c = cmp2.Id;
        insert ptnrCat1;
        
        ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = ind2.Id;
        ptnrCat2.PMP_Partner_Id__c = cmp2.Id;
        insert ptnrCat2;
        
        PMP_Specification__c spec = [select name , PMP_Display_Type_Nm__c,PMP_Active_Ind__c,PMP_Parent_Specification_Id__c,PMP_Product_Parent_Specification_Id__c ,
                                     PMP_Partner_Product_Specification_Id__c,PMP_Partner_Product_Display_Sequence_Nbr__c FROM PMP_Specification__c where id = :offSpecs.PMP_Specification_Id__c];
        spec.PMP_Display_Type_Nm__c ='Checkbox';
        spec.PMP_Active_Ind__c = true;
        spec.PMP_Parent_Specification_Id__c = parentSpec.Id;
        spec.PMP_Partner_Product_Display_Sequence_Nbr__c = 1001;
        spec.PMP_Partner_Product_Specification_Id__c = 'NPP_IntelTechnologies';
        update spec;
        
        PMP_Specification_Value__c specValue = [select name,PMP_Product_Specification_Value_Cd__c,PMP_Display_Type_Nm__c ,PMP_Active_Ind__c from PMP_Specification_Value__c where id = :offSpecs.PMP_Specification_Value_Id__c];
        specValue.PMP_Display_Type_Nm__c = 'Checkbox';
        specValue.PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop';
        upsert specValue;
        
        PMP_Specification_Value_Association__c specValAsc = PMP_SearchTestDataFactory.createSpecValueAsc(specValue.name, cat0.Id,spec.Id,specValue.Id,true);
        
        PMP_Category_Specification_Association__c catSpec = PMP_SearchTestDataFactory.getCategorySpecs(offCat1.PMP_Category_Id__c , offSpecs.PMP_Specification_Id__c);
        
        offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Published;
        update offering1;
        
        
        PMP_Company_Translation__c compTrans = new PMP_Company_Translation__c();
        compTrans.Name = 'compTransTest';
        
        compTrans.PMP_Company_Information_Id__c = cmp2.Id;
        compTrans.PMP_Chinese_Txt__c = 'chinese';
        compTrans.PMP_Japanese_Txt__c = 'japanese';
        compTrans.PMP_English_Txt__c = 'englishxwswduihwsdwihihwadiiawdhishdihwaidhodiowdiowsdoiiosdjosjdosjdooesjdoiedjoejdedoedddeisdjodjoesjdoejsjodjoejdoejojejowejwodjoejdoejodoedjooecsdcdsdciefiiedijeiedjfjedfjedjjfesfeow'+
            +'scsdvdfgffhashcdishichfsdihfisdifvdifjvsidjfciosdjiocjfsoijdcfojseofjcseoifwsuidywiedwe8few8f8e8fwefwe9yf9wef9qw9';
        compTrans.PMP_Field_Nm__c = 'PMP_Account_Dsc__c';
        insert compTrans;
        PMP_Company_Translation__c compTrans2 = new PMP_Company_Translation__c();
        compTrans2.Name = 'compTransTest';
        
        compTrans2.PMP_Company_Information_Id__c = cmp2.Id;
        compTrans2.PMP_Chinese_Txt__c = 'chinese';
        compTrans2.PMP_Japanese_Txt__c = 'japanese';
        compTrans2.PMP_English_Txt__c = 'englishxwswduihwsdwihihwadiiawdhishdihwaidhodiowdiowsdoiiosdjosjdosjdooesjdoiedjoejdedoedddeisdjodjoesjdoejsjodjoejdoejojejowejwodjoejdoejodoedjooecsdcdsdciefiiedijeiedjfjedfjedjjfesfeow'+
            +'scsdvdfgffhashcdishichfsdihfisdifvdifjvsidjfciosdjiocjfsoijdcfojseofjcseoifwsuidywiedwe8few8f8e8fwefwe9yf9wef9qw9';
        compTrans2.PMP_Field_Nm__c = 'PMP_Account_Tag_Line__c';
        insert compTrans2;       
        
        
        
        PMP_Partner_Offering_Translation__c offTrans = new PMP_Partner_Offering_Translation__c();
        offTrans.Name = 'test';
        offTrans.PMP_Chinese_Txt__c = 'chinese';
        offTrans.PMP_English_Txt__c = 'English';
        offTrans.PMP_Japanese_Txt__c = 'japanese';
        offTrans.PMP_Field_Nm__c = PMP_StaticConstants_Partner.OFFERING_NAME;
        offTrans.PMP_Partner_Offering_Id__c = offering1.Id;
        insert offTrans;
        
        PMP_Partner_Offering_Translation__c offTrans1 = new PMP_Partner_Offering_Translation__c();
        offTrans1.Name = 'test1';
        offTrans1.PMP_Chinese_Txt__c = 'chinese';
        offTrans1.PMP_English_Txt__c = 'English';
        offTrans1.PMP_Japanese_Txt__c = 'japanese';
        offTrans1.PMP_Field_Nm__c = PMP_StaticConstants_Partner.OFFERING_DESCRIPTION;
        offTrans1.PMP_Partner_Offering_Id__c = offering1.Id;
        insert offTrans1;
        
        ContentVersion cvlist = new Contentversion(); 
        cvlist.Title = 'CZDSTOU'; 
        cvlist.PathOnClient = 'test'; 
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<ContentVersion> cvl = new List<ContentVersion>(); 
        cvl.add(cvlist); 
        insert cvl;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cvl[0].Id LIMIT 1];
        String docId = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentVersion_2.ContentDocumentId].Id;
        
        PMP_Partner_Offering_Resource__c offResource = new PMP_Partner_Offering_Resource__c();
        offResource.name = 'test ';
        offResource.PMP_Partner_Offering_Image__c = docId;
        offResource.PMP_Offering_Id__c = offering1.Id;
        offResource.PMP_Resource_Type_Nm__c = PMP_StaticConstants_Partner.THUMBNAIL_IMAGE; 
        offResource.PMP_Resource_Sequence_Nbr__c = 0;
        insert offResource;
        
    }
    
    
    @isTest static void partnerDetailsWithLongDesc(){
        
        
        List<PMP_Company__c> comp_info = [Select Id, Name, PMP_Account_Specialty__c, PMP_Account_Id__c FROM PMP_Company__c where Name='TestCompany2'];
        List<PMP_Company__c> comp_infoWc = [Select Id, Name, PMP_Account_Specialty__c, PMP_Account_Id__c FROM PMP_Company__c where Name='TestCompany1'];
        
        If(comp_info.size() > 0) {
            comp_info[0].PMP_Account_Dsc__c =  'Testing with text longer than 255 Testing with text longer than 255Testing with text longer than 255'+
                'Testing with text longer than 255 Testing with text longer than 255Testing with text longer than 255'+
                'Testing with text longer than 255 Testing with text longer than 255Testing with text longer than 255'+
                'Testing with text longer than 255 Testing with text longer than 255Testing with text longer than 255'+
                'Testing with text longer than 255 Testing with text longer than 255Testing with text longer than 255'+
                'Testing with text longer than 255 Testing with text longer than 255Testing with text longer than 255'+
                'Testing with text longer than 255 Testing with text longer than 255Testing with text longer than 255'+
                'Testing with text longer than 255 Testing with text longer than 255Testing with text longer than 255'+
                'Testing with text longer than 255 Testing with text longer than 255Testing with text longer than 255';
            
            
            String partnerDescription = 'description';
            String lang = UserInfo.getLanguage();
            PMP_SearchPartnerDetailsController.getPartnerDetails(comp_info[0].Id,lang);
            
            PMP_SearchPartnerDetailsController.getPartnerDetails(comp_infoWc[0].Id,lang);
            
        }
    }
    
    
    @isTest static void TestgetPartnerCategories(){
        
        
        
        PartnerDetail testpartnerDetail =  new PartnerDetail(); 
        testpartnerDetail.mobileList=new List<Mobile>();
        Mobile mob=new Mobile();
        mob.label='test';
        mob.imgUrl='https://www.google.com';
        testpartnerDetail.mobileList.add(mob);
        testpartnerDetail.categories=new List<CategoryTab>();
        
        List<String> contIdlst = new List<String>();
        for(ContentDocument cd : [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Limit 5])
        {
            contIdlst.add(cd.Id);
        }
        
        PMP_Company__c comp_info = [Select Id, Name, PMP_Account_Industry__c, PMP_Account_Application__c, 
                                    PMP_Account_Region__c, PMP_Account_Sub_Region__c, PMP_Account_Specialty__c, PMP_Account_Id__c FROM PMP_Company__c where Name =: 'TestCompany1' limit 1];
        system.debug('$$$$$$$$$$$$'+comp_info);
        
        
        
        //PMP_SearchPartnerDetailsController.getPartnerCategories(testpartnerDetail,comp_info.Id);
        String lang = UserInfo.getLanguage();
        PMP_SearchPartnerDetailsController.getPartnerOfferings(testpartnerDetail, comp_info.Id, comp_info.Name, lang);
        
    } 
    
    @isTest static void updatePartnerInfo_Test() {
        
        PMP_Company__c partner1 = new PMP_Company__c(Name = 'Working copy');
        insert partner1;
        
        PMP_Company__c partner = new PMP_Company__c(Name = 'Test_Partner', PMP_Working_Copy_Id__c=partner1.Id);
        insert partner;
        
        Test.startTest();
        PMP_SearchPartnerDetailsController.updatePartnerInfo(partner.Id);
        Test.stopTest();
    }
}