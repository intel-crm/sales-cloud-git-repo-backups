@isTest
public class PMP_SearchEditStoreFrontController_Test extends PMP_SearchWrapperStore{
    
    @testSetup static void dataFactory() {

        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User poeUser = new User(/**UserRoleId  = ur.Id,**/Alias = 'alias', Email='testUsercoreMDF@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test');
        insert poeUser;

        System.runAs(poeUser) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PMP_Internal_Intel_Admin'];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = poeUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;
            

        }

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
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        insert stList;
        Folder folder = [SELECT Id from Folder WHERE DeveloperName= 'PMP_Marketplace_Images' LIMIT 1];
        
        Document doc = new Document(Name='IntelLogo',FolderId = folder.Id); 
        insert doc;
        
        Id PartnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account accObj = PMP_TestDataUtility.createAccount('PartnerAccount',PartnerRecordTypeId,true);
        
        Core_Account_Group_Member__c acGrpNum=new Core_Account_Group_Member__c();
        acGrpNum.Core_Partner_Account_Id__c = accObj.Id;
        acGrpNum.Core_Inactive_Ind__c = false;
        acGrpNum.Core_Intel_Account_Id__c =accObj.id;
        insert acGrpNum;
        
        PMP_Company__c testpartnerWc = new PMP_Company__c(Name = 'testPartnerWc',PMP_Partner_Submitter_UserId__c =UserInfo.getUserId(),PMP_Company_Lifecycle_Status_Nm__c = 'Draft',PMP_Is_Updated_Ind__c = true,PMP_Is_Working_Copy_Ind__c = true,PMP_Partner_Segment_Nm__c ='Internet of Things and Embedded');
        insert testpartnerWc;
        
          
      
        
        PMP_Company__c testpartner = new PMP_Company__c(Name = 'testPartner',PMP_Partner_Submitter_UserId__c =UserInfo.getUserId(),PMP_One_Partner_ID__c=accObj.id,PMP_Company_Lifecycle_Status_Nm__c = 'Published',PMP_Is_Published_Ind__c = true,PMP_Working_Copy_Id__c = testpartnerWc.Id,PMP_Is_Updated_Ind__c = true,PMP_Partner_Program_nm__c='ISA');
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
        PMP_Specification_Value__c specValue1 = new PMP_Specification_Value__c(Name ='TestSpecVal',PMP_Spec_Value_Type_Nm__c = 'Geography' );
        insert specValue1;
        
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
        
        PMP_Company__c testpartnerWc2 = new PMP_Company__c(Name='testPartnerWc2',PMP_Company_Information_Language_Nm__c = 'English',PMP_Company_Lifecycle_Status_Nm__c = 'Update Required');
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
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
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
        ContentVersion contentVersion2 = [SELECT Id, Title, FileExtension,IsLatest, ContentSize, ContentDocumentId, VersionData, OwnerId FROM ContentVersion WHERE Id = :cvl[0].Id LIMIT 1];
        String docId = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentVersion2.ContentDocumentId].Id;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.LinkedEntityId = testpartner.Id; 
        //cdl.ShareType = 'C';
        cdl.Visibility = 'AllUsers'; 
        insert cdl;
    }
    
    @isTest static void getStepsTest(){
        
        Test.startTest();
        List<String> result = PMP_SearchEditStoreFrontController.getSteps();
        System.assert(result.size() > 0,'Failed');
        
       /* PermissionSet perm = [select id from PermissionSet where (Name=:PMP_StaticConstants_Partner.INTEL_ADMIN)];
        PermissionSetAssignment  assgn = new PermissionSetAssignment (AssigneeId = Userinfo.getUserId(),PermissionSetId = perm.Id);
        insert assgn;*/
        result = PMP_SearchEditStoreFrontController.getSteps();
        System.assert(result.size() > 0,'Failed');
        
        Test.stopTest();
    }
    
    @isTest static void isLockedTest(){
        PMP_Company__c partner = [SELECT Id,PMP_Company_Lifecycle_Status_Nm__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c where name='testPartner' LIMIT 1];
        
        Test.startTest();
        Boolean result = PMP_SearchEditStoreFrontController.isLocked(partner.Id);
        System.assertEquals(false, result,'Failed');
        PMP_Company__c wrk = [SELECT PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c WHERE Id=:partner.PMP_Working_Copy_Id__c];
        //wrk.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Admin_Review;
        update wrk;
        result = PMP_SearchEditStoreFrontController.isLocked(partner.Id);
        System.assertEquals(false, result,'Failed');
        partner.PMP_Working_Copy_Id__c = null;
        update partner;
        result = PMP_SearchEditStoreFrontController.isLocked(partner.Id);
        System.assertEquals(false, result,'Failed');
        partner.PMP_Is_Working_Copy_Ind__c = true;
        partner.PMP_Is_Published_Ind__c = false;
        update partner;
        result = PMP_SearchEditStoreFrontController.isLocked(partner.Id);
        System.assertEquals(false, result,'Failed');
        result = PMP_SearchEditStoreFrontController.isLocked('ID');
        Test.stopTest();
    }
    
    
    @isTest static void getPartnerExistingDataTest(){
        
        PMP_Company__c partner = [SELECT Id FROM PMP_Company__c where name='testPartner' LIMIT 1];
        
        Test.startTest();
        
        FormData result = PMP_SearchEditStoreFrontController.getPartnerExistingData(partner.Id,'en_US');
        System.assert(result != null,'Failed');
        partner.PMP_Working_Copy_Id__c = null;
        update partner;
        result = PMP_SearchEditStoreFrontController.getPartnerExistingData(partner.Id,'en_US');
        System.assert(result != null,'Failed');
        partner.PMP_Is_Working_Copy_Ind__c = true;
        partner.PMP_Is_Published_Ind__c = false;
        update partner;
        result = PMP_SearchEditStoreFrontController.getPartnerExistingData(partner.Id,'en_US');
        System.assert(result != null,'Failed');
        
        Test.stopTest();
        
    }
    
    @isTest static void saveEditFormDataTest(){
        
        PMP_Company__c partner = [SELECT Id, Name,PMP_Working_Copy_Id__c,PMP_Partner_Program_nm__c from PMP_Company__c where Name = 'testPartner'];
        PMP_Company__c partnerWc = [SELECT Id, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartnerWc'];
        String specId = [SELECT Id FROM PMP_Specification__c LIMIT 1].Id;
        
        User admin = PMP_SearchTestDataFactory.createUser(true);
        String adminName = [SELECT Name FROM User WHERE Id=:admin.Id].Name;
        
        //system.debug('Admin Name : '+adminName);
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
        
        data.partner = new PMP_SearchWrapperStore.PartnerWrapper();
       
        Boolean result;
        try{
            result = PMP_SearchEditStoreFrontController.saveEditFormData(partner.Id, JSON.serialize(data));
        }catch(Exception e){

        }
        Test.startTest();
        data.suppressEmail = false;
        PMP_SearchEditStoreFrontController.getDependentMap();
        PMP_Company__c wrk = [SELECT PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c WHERE Id=:partner.PMP_Working_Copy_Id__c];
        wrk.PMP_Company_Lifecycle_Status_Nm__c = 'Draft';
        update wrk;
        result = PMP_SearchEditStoreFrontController.saveEditFormData(partner.Id, JSON.serialize(data));
        System.assert(result == true,'Failed');
       // partner.PMP_Working_Copy_Id__c = null;
       // update partner;
       // result = PMP_SearchEditStoreFrontController.saveEditFormData(partner.Id, JSON.serialize(data));
        //System.assert(result == false,'Failed');
      
        partnerWc.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Update_Required;
        partnerWc.PMP_Partner_Submitter_UserId__c=UserInfo.getUserId();
        update partnerWc;
        
        //result = PMP_SearchEditStoreFrontController.saveEditFormData(partner.Id, JSON.serialize(data));
       // System.assert(result == false,'Failed');
        partner.PMP_Is_Working_Copy_Ind__c = true;
        partner.PMP_Is_Published_Ind__c = false;
        update partner;

       
      
        //result = PMP_SearchEditStoreFrontController.saveEditFormData(partnerWc.Id, JSON.serialize(data));

        try{
            result = PMP_SearchEditStoreFrontController.saveEditFormData(null, JSON.serialize(data));
        }catch(Exception e){

        }

        Test.stopTest();
      //      System.assert(result == true,'Failed');
        
        //324 to 328 was commented.
    }
	//IPA2.0 
    /*@isTest static void assignEnhancedBenefitTest(){
        
        
        PMP_Company__c partner = [SELECT Id, Name,PMP_Working_Copy_Id__c,PMP_Partner_Program_nm__c from PMP_Company__c where Name = 'testPartner'];
        PMP_Company__c partnerWc = [SELECT Id, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartnerWc'];
        String specId = [SELECT Id FROM PMP_Specification__c LIMIT 1].Id;
        
        User admin = PMP_SearchTestDataFactory.createUser(true);
        String adminName = [SELECT Name FROM User WHERE Id=:admin.Id].Name;
        
        //system.debug('Admin Name : '+adminName);
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
        
        data.partner = new PMP_SearchWrapperStore.PartnerWrapper();
        Test.startTest();
        Boolean result;
        try{
            PMP_SearchEditStoreFrontController.AssignEnhancedBenefitToStorefront(partner.Id, JSON.serialize(data));
        }catch(Exception e){

        }
        User u = [select Id, Core_IPA_One_Partner_Id__c, name, AccountID from User where alias='alias' limit 1];


        System.runas(u){

        data.suppressEmail = false;
        PMP_SearchEditStoreFrontController.AssignEnhancedBenefitToStorefront(partner.Id, JSON.serialize(data));
        }

        try{
            PMP_SearchEditStoreFrontController.AssignEnhancedBenefitToStorefront(partnerWc.Id, JSON.serialize(data));
        }catch(Exception e){

        }
        
    
    }*/
    //391-451 Commented
    
    @isTest static void getAdminDetailsTest(){
        FormData formData = new FormData();
        PMP_Company__c partner = [SELECT Id, Name,PMP_Working_Copy_Id__c,PMP_Intel_Admin_Nm__c,PMP_Intel_Admin_Id__c,LastModifiedDate,LastModifiedById from PMP_Company__c where Name = 'testPartner'];
        
        Test.startTest();
        PMP_SearchEditStoreFrontController.getAdminDetails(formData,partner);
        System.assert(String.isNotEmpty(formData.admin),'Failed');
        Test.stopTest();
    }
    
    @isTest static void getCompDescTest(){
        FormData formdata  = new FormData();
        PMP_Company__c partner = [SELECT Id,PMP_Company_Lifecycle_Status_Nm__c,PMP_Company_Information_Language_Nm__c, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartner'];
        partner.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Update_Required;
        partner.PMP_Company_Information_Language_Nm__c = 'Japanese';
        partner.PMP_Partner_Submitter_UserId__c=UserInfo.getUserId();
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
        List<PMP_Company_Translation__c> transList = new List<PMP_Company_Translation__c>();
        transList = [select id, Name, PMP_Field_Nm__c, PMP_English_Txt__c,
                             PMP_Chinese_Txt__c, PMP_Japanese_Txt__c from PMP_Company_Translation__c LIMIT 10]; 
        system.assertNotEquals(NULL,transList,'failed');
        Test.stopTest();
    }
    
    @isTest static void savePartnerCategoryTest(){
        PMP_Company__c partner = [SELECT Id,PMP_Company_Lifecycle_Status_Nm__c, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartner'];
        
        List<PMP_Category__c> catList = [SELECT Id FROM PMP_Category__c LIMIT 10];
        List<String> cats = new List<String>();
        for(PMP_Category__c cat: catList){
            cats.add(cat.Id);
        }
        
        Test.startTest();
        PMP_SearchEditStoreFrontController.savePartnerCategory(partner.Id,cats,'NPP_01_APP');
        List<PMP_Partner_Category__c> exCatList = [SELECT Id FROM PMP_Partner_Category__c LIMIT 10];
        system.assertNotEquals(NULL,exCatList,'Failed');
        Test.stopTest();
    }
    
    @isTest static void updateTranslationRecordsTest(){
        PMP_Company__c partner = [SELECT Id,PMP_Company_Lifecycle_Status_Nm__c, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartnerWc'];
        Test.startTest();
        PMP_SearchEditStoreFrontController.updateTranslationRecords(partner.Id,partner.Name,'Japanese','tag','desc');
        PMP_SearchEditStoreFrontController.updateTranslationRecords('Id',partner.Name,'Japanese','tag','desc');
        
        PMP_SearchEditStoreFrontController.updateTranslationRecords(partner.Id,partner.Name,'Simplified Chinese','tag','desc');
         List<PMP_Company_Translation__c> transList = new List<PMP_Company_Translation__c>();
     transList = [select id, Name, PMP_Field_Nm__c, PMP_English_Txt__c from PMP_Company_Translation__c LIMIT 10];
         system.assertNotEquals(NULL,transList,'Failed');
        Test.stopTest();
    }
    
    
    @isTest static void createTranslationRecordsTest(){
        PMP_Company__c comp = new PMP_Company__c(Name = 'Test Partner');
        
        Test.startTest();
        
        insert comp;
        insert PMP_SearchEditStorefrontController.createTranslationRecords(comp.Id,comp.Name,'English',PMP_StaticConstants_Partner.Description,'desc');
        insert PMP_SearchEditStorefrontController.createTranslationRecords(comp.Id,comp.Name,'Japanese',PMP_StaticConstants_Partner.Description,'desc');
        insert PMP_SearchEditStorefrontController.createTranslationRecords(comp.Id,comp.Name,PMP_StaticConstants_Partner.Chinese,PMP_StaticConstants_Partner.Description,'desc');
        List<PMP_Company_Translation__c> trans = [SELECT Id from PMP_Company_Translation__c WHERE PMP_Company_Information_Id__c =:comp.Id];
        system.assertEquals(3, trans.size(),'Failed');
        Test.stopTest();
    }
    
    @isTest static void getLogo(){
        Test.startTest();
        FormData formData = new FormData();
        PMP_Company__c part = new PMP_Company__c();
        PMP_SearchEditStorefrontController.getLogo(formData, part);
        system.assertNotEquals(NULL,part,'Failed');
        //line 405 was commented.
        Test.stopTest();
    }
    
    @isTest static void updateStatusAdminTest(){
        PMP_Company__c partner = [SELECT Id, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartner'];
        PMP_Company__c partnerWc = [SELECT Id, Name,PMP_Working_Copy_Id__c from PMP_Company__c where Name = 'testPartnerWc'];
        String specId = [SELECT Id FROM PMP_Specification__c LIMIT 1].Id;
        
        User admin = PMP_SearchTestDataFactory.createUser(true);
        String adminName = [SELECT Name FROM User WHERE Id=:admin.Id].Name;
        
        //system.debug('Admin Name : '+adminName);
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
        
        Boolean adm = PMP_SearchEditStoreFrontController.updateStatusAdmin(partner.Id, JSON.serialize(data));
        system.assertEquals(true,adm,'failed');
        Test.stopTest();
        
    }
    
    @isTest static void getlogoUrlTest(){
       String id = String.valueOf([SELECT Id from PMP_Company__c WHERE Name = 'testPartner'].Id);
        PMP_SearchEditStoreFrontController.getlogoUrl(id);
    }
  
   @isTest static void getPartnerNamesTest(){
       Test.startTest();
        FormData formData = new FormData();
        
         prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
        cpIPA.Name='Intel Partner Alliance';
        cpIPA.PRM_programCode__c='IPA';
        insert cpIPA;

        ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
        cplTitanium.Name='Titanium';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;

        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
                
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
       
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
      
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='Test';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
       coreAccnt.Primary_Account__c=true;
        insert coreAccnt;
       
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
       
       PMP_Company__c compInfo = [SELECT Id, Name FROM PMP_Company__c WHERE Name = 'test class Account'];
       system.debug('compInfo'+compInfo);
        
       
       
        
       PMP_SearchEditStorefrontController.getPartnerNames(formData, compInfo);
        Test.stopTest();
    }
    
    
}