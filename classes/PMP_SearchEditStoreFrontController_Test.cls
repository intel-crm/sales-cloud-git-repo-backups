@isTest
public class PMP_SearchEditStoreFrontController_Test extends PMP_SearchWrapperStore{
    
    @testSetup static void dataFactory() {
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Off_Sort_By_Featured';
        st.PMP_Value__c = 'PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Status_Update_Dt__c DESC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Partner_Sort_By_Name_Desc';
        st.PMP_Value__c = 'Name DESC NULLS LAST';
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
        Folder folder = [SELECT Id from Folder WHERE DeveloperName= 'PMP_Marketplace_Images' LIMIT 1];
        
        Document doc = new Document(Name='IntelLogo',FolderId = folder.Id); 
        insert doc;
        
        PMP_Company__c testpartnerWc = new PMP_Company__c(Name = 'testPartnerWc',PMP_Company_Lifecycle_Status_Nm__c = 'Draft',PMP_Is_Updated_Ind__c = true,PMP_Is_Working_Copy_Ind__c = true);
        insert testpartnerWc;
        
          
      
        
        PMP_Company__c testpartner = new PMP_Company__c(Name = 'testPartner',PMP_Company_Lifecycle_Status_Nm__c = 'Published',PMP_Is_Published_Ind__c = true,PMP_Working_Copy_Id__c = testpartnerWc.Id,PMP_Is_Updated_Ind__c = true,PMP_Partner_Program_nm__c='ISA');
        insert testpartner;
        testpartnerWc.PMP_Published_Copy_Id__c = testpartner.Id;
        PMP_Company_Resource__c testResource = PMP_SearchTestDataFactory.createCompanyResource('testResource', testpartner.Id, 'White Paper', true);
        PMP_Company_Resource__c testResourceWc = PMP_SearchTestDataFactory.createCompanyResource('testResource', testpartnerWc.Id, 'White Paper', true);
        
        PMP_Specification__c testRegionSpec = new PMP_Specification__c(name='testRegion',   PMP_Partner_Product_Specification_Id__c='NPP_GeographicCoverage');
        PMP_Specification__c testSubRegion = new PMP_Specification__c(name='testSubRegion',     PMP_Partner_Product_Specification_Id__c = 'Test_Spec',PMP_Product_Parent_Specification_Id__c='NPP_GeographicCoverage');
        insert testRegionSpec;
        insert testSubRegion;
        testSubRegion.PMP_Parent_Specification_Id__c = testRegionSpec.Id;
        update testSubRegion;
        PMP_Company_Region__c testRegionWc1 = PMP_SearchTestDataFactory.createCompanyRegion(testpartnerWc.Id, testRegionSpec.Id, true);
        PMP_Company_Region__c testRegionWc2 = PMP_SearchTestDataFactory.createCompanyRegion(testpartnerWc.Id, testSubRegion.Id, true);
        
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec2;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue;
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec.PMP_Company_Id__c = testpartnerWc.Id;
        insert ptnrSpec;
        
        PMP_Company_Region__c ptnrSpec1 = new PMP_Company_Region__c();
        ptnrSpec1.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec1.PMP_Company_Id__c = testpartnerWc.Id;
        insert ptnrSpec1;
        
        PMP_Company_Region__c ptnrSpec2 = new PMP_Company_Region__c();
        ptnrSpec2.PMP_Specification_Id__c = spec2.Id;
        ptnrSpec2.PMP_Company_Id__c = testpartnerWc.Id;
        insert ptnrSpec2;
        
        PMP_Company__c testpartnerWc2 = new PMP_Company__c(Name='testPartnerWc2',PMP_Account_Specialty__c='Specialty Partner',PMP_Company_Information_Language_Nm__c = 'English',PMP_Company_Lifecycle_Status_Nm__c = 'Update Required');
        insert testpartnerWc2;
        
        PMP_Company__c testpartner2 = new PMP_Company__c(Name='testPartner2',PMP_Company_Lifecycle_Status_Nm__c = 'Published',PMP_Working_Copy_Id__c = testpartnerWc2.Id);
        insert testpartner2;
        
        PMP_Company_Resource__c testResourceWc2 = PMP_SearchTestDataFactory.createCompanyResource('testResource', testpartnerWc2.Id, 'White Paper', true);
        
        PMP_Company_Translation__c trans = new PMP_Company_Translation__c(Name = 'test', PMP_Field_Nm__c='PMP_Account_Dsc__c',PMP_English_Txt__c='eng',PMP_Japanese_Txt__c='jap', PMP_Chinese_Txt__c='chi',PMP_Company_Information_Id__c=testpartnerWc.Id);
        insert trans;
        trans = new PMP_Company_Translation__c(Name = 'test', PMP_Field_Nm__c='PMP_Account_Tag_Line__c',PMP_English_Txt__c='eng',PMP_Japanese_Txt__c='jap', PMP_Chinese_Txt__c='chi',PMP_Company_Information_Id__c=testpartnerWc.Id);
        insert trans;
        trans = new PMP_Company_Translation__c(Name = 'test', PMP_Field_Nm__c='PMP_Account_Tag_Line__c',PMP_English_Txt__c='eng',PMP_Japanese_Txt__c='jap', PMP_Chinese_Txt__c='chi',PMP_Company_Information_Id__c=testpartner.Id);
        insert trans;
        trans = new PMP_Company_Translation__c(Name = 'test', PMP_Field_Nm__c='PMP_Account_Dsc__c',PMP_English_Txt__c='eng',PMP_Japanese_Txt__c='jap', PMP_Chinese_Txt__c='chi',PMP_Company_Information_Id__c=testpartner.Id);
        insert trans;
        
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        cat0.PMP_Parent_Category_Id__c = null; 
        app0.PMP_Parent_Category_Id__c = null;
        ind0.PMP_Parent_Category_Id__c = null;
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
        
        PMP_Partner_Category__c ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = app1.Id;
        ptnrCat.PMP_Partner_Id__c = testpartnerWc.Id;
        insert ptnrCat;
        
        PMP_Partner_Category__c ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = app1.Id;
        ptnrCat1.PMP_Partner_Id__c = testpartnerWc.Id;
        insert ptnrCat1;
        
        PMP_Partner_Category__c ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = app2.Id;
        ptnrCat2.PMP_Partner_Id__c = testpartnerWc.Id;
        insert ptnrCat2;
        
        ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = ind1.Id;
        ptnrCat.PMP_Partner_Id__c = testpartnerWc.Id;
        insert ptnrCat;
        
        ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = ind1.Id;
        ptnrCat1.PMP_Partner_Id__c = testpartnerWc.Id;
        insert ptnrCat1;
        
        ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = ind2.Id;
        ptnrCat2.PMP_Partner_Id__c = testpartnerWc.Id;
        insert ptnrCat2;
        
        PMP_Company_Resource__c res = new PMP_Company_Resource__c(name = 'res',PMP_Company_Resource_Type_Nm__c = PMP_StaticConstants_partner.IMAGE,PMP_Company_Id__c = testpartnerWc.Id);
        insert res;
        
        ContentVersion cvlist = new Contentversion(); 
        cvlist.Title = 'CZDSTOU'; 
        cvlist.PathOnClient = 'test'; 
        //cvlist.IsLatest=true;
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<ContentVersion> cvl = new List<ContentVersion>(); 
        cvl.add(cvlist); 
        insert cvl;
        ContentVersion contentVersion_2 = [SELECT Id, Title, FileExtension,IsLatest, ContentSize, ContentDocumentId, VersionData, OwnerId FROM ContentVersion WHERE Id = :cvl[0].Id LIMIT 1];
        String docId = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentVersion_2.ContentDocumentId].Id;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.LinkedEntityId = testpartner.Id; 
        cdl.ShareType = 'C';
        cdl.Visibility = 'AllUsers'; 
        
    }
    
    @isTest static void getSteps_Test(){
        
        Test.startTest();
        List<String> result = PMP_SearchEditStoreFrontController.getSteps();
        System.assert(result.size() > 0);
        
       /* PermissionSet perm = [select id from PermissionSet where (Name=:PMP_StaticConstants_Partner.INTEL_ADMIN)];
        PermissionSetAssignment  assgn = new PermissionSetAssignment (AssigneeId = Userinfo.getUserId(),PermissionSetId = perm.Id);
        insert assgn;*/
        result = PMP_SearchEditStoreFrontController.getSteps();
        System.assert(result.size() > 0);
        
        Test.stopTest();
    }
    
    @isTest static void isLocked_Test(){
        PMP_Company__c partner = [SELECT Id,PMP_Company_Lifecycle_Status_Nm__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c where name='testPartner' LIMIT 1];
        
        Test.startTest();
        Boolean result = PMP_SearchEditStoreFrontController.isLocked(partner.Id);
        System.assertEquals(false, result);
        PMP_Company__c wrk = [SELECT PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c WHERE Id=:partner.PMP_Working_Copy_Id__c];
        //wrk.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Admin_Review;
        update wrk;
        result = PMP_SearchEditStoreFrontController.isLocked(partner.Id);
        System.assertEquals(false, result);
        partner.PMP_Working_Copy_Id__c = null;
        update partner;
        result = PMP_SearchEditStoreFrontController.isLocked(partner.Id);
        System.assertEquals(false, result);
        partner.PMP_Is_Working_Copy_Ind__c = true;
        partner.PMP_Is_Published_Ind__c = false;
        update partner;
        result = PMP_SearchEditStoreFrontController.isLocked(partner.Id);
        System.assertEquals(false, result);
        result = PMP_SearchEditStoreFrontController.isLocked('ID');
        Test.stopTest();
    }
    
    
    @isTest static void getPartnerExistingData_Test(){
        
        PMP_Company__c partner = [SELECT Id FROM PMP_Company__c where name='testPartner' LIMIT 1];
        
        Test.startTest();
        
        FormData result = PMP_SearchEditStoreFrontController.getPartnerExistingData(partner.Id,'en_US');
        System.assert(result != null);
        partner.PMP_Working_Copy_Id__c = null;
        update partner;
        result = PMP_SearchEditStoreFrontController.getPartnerExistingData(partner.Id,'en_US');
        System.assert(result != null);
        partner.PMP_Is_Working_Copy_Ind__c = true;
        partner.PMP_Is_Published_Ind__c = false;
        update partner;
        result = PMP_SearchEditStoreFrontController.getPartnerExistingData(partner.Id,'en_US');
        System.assert(result != null);
        
        Test.stopTest();
        
    }
    
    @isTest static void saveEditFormData_Test(){
        
        PMP_Company__c partner = [SELECT Id, Name,PMP_Working_Copy_Id__c,PMP_Partner_Program_nm__c from PMP_Company__c where Name = 'testPartner'];
        PMP_Company__c partnerWc = [SELECT Id, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartnerWc'];
        String specId = [SELECT Id FROM PMP_Specification__c LIMIT 1].Id;
        
        User admin = PMP_SearchTestDataFactory.createUser(true);
        String adminName = [SELECT Name FROM User WHERE Id=:admin.Id].Name;
        
        system.debug('Admin Name : '+adminName);
        DescriptionData descData = new DescriptionData();
        descData.language = 'English';
        descData.tagline = 'DummyTag';
        descData.description = 'DummyDesc';
        
        List<Resource> resources = new List<Resource>();
        Resource res = new Resource();
        res.title = 'Dummy';
        res.type = 'White Paper';
        res.url = 'www.test.com';
        resources.add(res);
        
        
        
        FormDataSaveRequest data = new FormDataSaveRequest();
        data.admin = adminName;
        data.status = PMP_StaticConstants_Partner.Update_Required;
        data.regionsSelected = new List<String>();
        data.regionsSelected.add(specId);
        data.industriesSelected = new List<String>();
        
        data.applicationsSelected = new List<String>();
        data.descriptionData = descData;
        data.resources = resources;
        
        Test.startTest();
        Boolean result = PMP_SearchEditStoreFrontController.saveEditFormData(partner.Id, JSON.serialize(data));
        System.assert(result == true);
        PMP_Company__c wrk = [SELECT PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c WHERE Id=:partner.PMP_Working_Copy_Id__c];
        wrk.PMP_Company_Lifecycle_Status_Nm__c = 'Draft';
        update wrk;
        result = PMP_SearchEditStoreFrontController.saveEditFormData(partner.Id, JSON.serialize(data));
        System.assert(result == true);
        partner.PMP_Working_Copy_Id__c = null;
        update partner;
        result = PMP_SearchEditStoreFrontController.saveEditFormData(partner.Id, JSON.serialize(data));
        System.assert(result == false);
        partnerWc.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Update_Required;
        update partnerWc;
        result = PMP_SearchEditStoreFrontController.saveEditFormData(partner.Id, JSON.serialize(data));
        System.assert(result == false);
        partner.PMP_Is_Working_Copy_Ind__c = true;
        partner.PMP_Is_Published_Ind__c = false;
        update partner;
        result = PMP_SearchEditStoreFrontController.saveEditFormData(partnerWc.Id, JSON.serialize(data));
        System.assert(result == true);
        //324 to 328 was commented.
    }
    
    @isTest static void getAdminDetails_Test(){
        FormData formData = new FormData();
        PMP_Company__c partner = [SELECT Id, Name,PMP_Working_Copy_Id__c,PMP_Intel_Admin_Nm__c,PMP_Intel_Admin_Id__c,LastModifiedDate,LastModifiedById from PMP_Company__c where Name = 'testPartner'];
        
        Test.startTest();
        PMP_SearchEditStoreFrontController.getAdminDetails(formData,partner);
        System.assert(String.isNotEmpty(formData.admin));
        Test.stopTest();
    }
    
    @isTest static void getCompDesc_Test(){
        FormData formdata  = new FormData();
        PMP_Company__c partner = [SELECT Id,PMP_Company_Lifecycle_Status_Nm__c,PMP_Company_Information_Language_Nm__c, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartner'];
        partner.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Update_Required;
        partner.PMP_Company_Information_Language_Nm__c = 'Japanese';
        update partner;
        
        Test.startTest();
        partner.PMP_Company_Information_Language_Nm__c = 'Japanese';
        update partner;
        PMP_SearchEditStoreFrontController.getCompDesc(formData,partner,'en_US');
        //System.assert(String.isNotEmpty(formData.admin));
        //
        partner.PMP_Company_Information_Language_Nm__c = 'Simplified Chinese';
        update partner;
        PMP_SearchEditStoreFrontController.getCompDesc(formData,partner,'en_US');
        //PMP_SearchEditStoreFrontController.getCompDesc(formData,partner);
        //System.assert(String.isNotEmpty(formData.admin));
        Test.stopTest();
    }
    
    @isTest static void savePartnerCategory_Test(){
        PMP_Company__c partner = [SELECT Id,PMP_Company_Lifecycle_Status_Nm__c, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartner'];
        
        List<PMP_Category__c> catList = [SELECT Id FROM PMP_Category__c ];
        List<String> cats = new List<String>();
        for(PMP_Category__c cat: catList){
            cats.add(cat.Id);
        }
        
        Test.startTest();
        PMP_SearchEditStoreFrontController.savePartnerCategory(partner.Id,cats,'NPP_01_APP');
        Test.stopTest();
    }
    
    @isTest static void updateTranslationRecords_Test(){
        PMP_Company__c partner = [SELECT Id,PMP_Company_Lifecycle_Status_Nm__c, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartnerWc'];
        Test.startTest();
        PMP_SearchEditStoreFrontController.updateTranslationRecords(partner.Id,partner.Name,'Japanese','tag','desc');
        PMP_SearchEditStoreFrontController.updateTranslationRecords('Id',partner.Name,'Japanese','tag','desc');
        
        PMP_SearchEditStoreFrontController.updateTranslationRecords(partner.Id,partner.Name,'Simplified Chinese','tag','desc');
        Test.stopTest();
    }
    
    
    @isTest static void createTranslationRecords_Test(){
        PMP_Company__c comp = new PMP_Company__c(Name = 'Test Partner');
        
        Test.startTest();
        
        insert comp;
        insert PMP_SearchEditStorefrontController.createTranslationRecords(comp.Id,comp.Name,'English',PMP_StaticConstants_Partner.Description,'desc');
        insert PMP_SearchEditStorefrontController.createTranslationRecords(comp.Id,comp.Name,'Japanese',PMP_StaticConstants_Partner.Description,'desc');
        insert PMP_SearchEditStorefrontController.createTranslationRecords(comp.Id,comp.Name,PMP_StaticConstants_Partner.Chinese,PMP_StaticConstants_Partner.Description,'desc');
        List<PMP_Company_Translation__c> trans = [SELECT Id from PMP_Company_Translation__c WHERE PMP_Company_Information_Id__c =:comp.Id];
        system.assertEquals(3, trans.size());
        Test.stopTest();
    }
    
    @isTest static void getLogo(){
        Test.startTest();
        FormData formData = new FormData();
        PMP_Company__c part = new PMP_Company__c();
        PMP_SearchEditStorefrontController.getLogo(formData, part);
        //line 405 was commented.
        Test.stopTest();
    }
    
    @isTest static void updateStatusAdminTest(){
        PMP_Company__c partner = [SELECT Id, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartner'];
        PMP_Company__c partnerWc = [SELECT Id, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartnerWc'];
        String specId = [SELECT Id FROM PMP_Specification__c LIMIT 1].Id;
        
        User admin = PMP_SearchTestDataFactory.createUser(true);
        String adminName = [SELECT Name FROM User WHERE Id=:admin.Id].Name;
        
        system.debug('Admin Name : '+adminName);
        DescriptionData descData = new DescriptionData();
        descData.language = 'English';
        descData.tagline = 'DummyTag';
        descData.description = 'DummyDesc';
        
        List<Resource> resources = new List<Resource>();
        Resource res = new Resource();
        res.title = 'Dummy';
        res.type = 'White Paper';
        res.url = 'www.test.com';
        resources.add(res);
        
        
        
        FormDataSaveRequest data = new FormDataSaveRequest();
        data.admin = adminName;
        data.status = PMP_StaticConstants_Partner.Update_Required;
        data.regionsSelected = new List<String>();
        data.regionsSelected.add(specId);
        data.industriesSelected = new List<String>();
        
        data.applicationsSelected = new List<String>();
        data.descriptionData = descData;
        data.resources = resources;
        
        Test.startTest();
        
        PMP_SearchEditStoreFrontController.updateStatusAdmin(partner.Id, JSON.serialize(data));
        
        Test.stopTest();
        
    }
    
}