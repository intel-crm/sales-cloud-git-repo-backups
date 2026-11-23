/*****************************************************************************************************************************************************************
* Class Name  : MarketplaceCreateProductControllerTest  
* Version     : 1.0 
* Created Date: 06-04-2019 
* Modification Log :
*
* Developer                           Date                          Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team                          06-04-2019                    Test class of MarketplaceCreateProductController apex class
******************************************************************************************************************************************************************/
@isTest
public class MarketplaceCreateProductControllerTest {

    @testSetup
    public static void generateData(){
        List<PMP_Partner_Offering__c> offList = New List<PMP_Partner_Offering__c >();
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,false,'draft','taglineTest' );
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('Testoffering12', 'Public Content','off desc',null,false,'draft','taglineTest' );
        offering.PMP_Partner_Offering_Nm__c = 'Test1232';
        offering.PMP_Partner_Offering_Start_Dt__c = date.today() -1;
     //  offering.PMP_Admin_Email__c = 'abhishekx.kunikenahallijayakumar@intel.com';
        offering.PMP_Partner_Offering_Dsc__c = 'Test';
        offering1.PMP_Partner_Offering_Dsc__c = 'Test';
        offering1.PMP_Partner_Offering_Nm__c = 'Test12';
        offering1.PMP_Partner_Offering_Start_Dt__c = date.today() -1;
        offering1.PMP_Business_Segment_Nm__c = 'IoT';
      //  offering1.PMP_Admin_Email__c = 'abhishekx.kunikenahallijayakumar@intel.com';
        offList.add(offering);
        offList.add(offering1);
        insert offList;
        PMP_Category__c appCategory = new PMP_Category__c (Name='Application', PMP_Partner_Product_Category_Cd__c='NPP_01_APP',
                                    PMP_Partner_Product_Parent_Category_Cd__c='NPP_Taxonomy', PMP_Active_Ind__c=true);
        PMP_Category__c category = new PMP_Category__c(Name='Categories', PMP_Partner_Product_Category_Cd__c='NPP_01_Type',
                                   PMP_Partner_Product_Parent_Category_Cd__c= 'NPP_Taxonomy', PMP_Active_Ind__c=true);
        PMP_Category__c categorySystem = new PMP_Category__c(Name='System', PMP_Partner_Product_Category_Cd__c='NPP_01_Type|NPP_02_Type_SYS',
                                    PMP_Partner_Product_Parent_Category_Cd__c= 'NPP_Taxonomy|NPP_01_Type', PMP_Active_Ind__c=true);
        
        List<PMP_Category__c> categoryList = New List<PMP_Category__c>{appCategory,category,categorySystem};
        insert categoryList;
        
        PMP_Partner_Offering_Category__c offeringCat1 = new PMP_Partner_Offering_Category__c(Name='Application', PMP_Offering_Id__c = offering.id, PMP_Category_Id__c =appCategory.id );
        PMP_Partner_Offering_Category__c offeringCat2 = new PMP_Partner_Offering_Category__c(Name='Category', PMP_Offering_Id__c = offering.id, PMP_Category_Id__c =category.id );
        PMP_Partner_Offering_Category__c offeringCat3 = new PMP_Partner_Offering_Category__c(Name='System', PMP_Offering_Id__c = offering.id, PMP_Category_Id__c =categorySystem.id );
        
        List<PMP_Partner_Offering_Category__c> offCatList = New List<PMP_Partner_Offering_Category__c>{offeringCat1,offeringCat2,offeringCat3};
        insert offCatList;
        PMP_Specification__c Spec1 = new PMP_Specification__c(name = 'Processors', PMP_Partner_Product_Specification_Id__c= 'PMP_Processor');
        PMP_Specification__c Spec2 = new PMP_Specification__c(name = 'X1Processor',PMP_Partner_Product_Specification_Id__c= 'PMP_Processor|X1Processor');
        List<PMP_Specification__c> specificationList = New List<PMP_Specification__c>{spec1,spec2};
        insert specificationList;
        PMP_Specification_Value__c specVal = new PMP_Specification_Value__c();
        specVal.Name = 'Test';
        specVal.PMP_Active_Ind__c = true;
        insert specVal;
        PMP_Partner_Offering_Specification__c offSpec = New PMP_Partner_Offering_Specification__c(Name='Geo', PMP_Offering_Id__c = offering.id, PMP_Specification_Id__c= spec1.id,PMP_Specification_Nm__c='test');
        PMP_Partner_Offering_Specification__c offSpec2 = New PMP_Partner_Offering_Specification__c(Name='Geo', PMP_Offering_Id__c = offering.id,
                                                     PMP_Specification_Id__c= spec1.id,PMP_Specification_Nm__c='test2'
                                                    ,PMP_Specification_Value_Cd__c=specVal.name);
        PMP_Partner_Offering_Specification__c offSpec3 = New PMP_Partner_Offering_Specification__c(Name='Geo', PMP_Offering_Id__c = offering.id,
                                                     PMP_Specification_Id__c= spec1.id,PMP_Specification_Nm__c='test3',
                                                     PMP_Specification_Value_Id__c = specVal.id,PMP_Specification_Value_Cd__c=specVal.name);
        List<PMP_Partner_Offering_Specification__c> offSpecList = New List<PMP_Partner_Offering_Specification__c>{offSpec,offSpec2,offSpec3} ;
        insert offSpecList ;
        List<PMP_Partner_Offering_Resource__c> offeringResources = new List<PMP_Partner_Offering_Resource__c>();
        offeringResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',offering.Id,'Tutorials',''));
        offeringResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',offering.Id,'Image',''));
        offeringResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',offering.Id,'Thumbnail Image',''));
         insert offeringResources;
         PMP_Product_API_Key__c testApiKey= new PMP_Product_API_Key__c();
        testApiKey.Name='API_Key';
        testApiKey.PMP_API_KEY__c='MX3jJu56hDe22l4HL9Xc';
        insert testApiKey;
        
        PMP_Partner_Offering_Translation__c  nameTrans = New PMP_Partner_Offering_Translation__c(Name='nameTest',PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c',
                                                        PMP_English_Txt__c='Eng',PMP_Partner_Offering_Id__c=offering1.id);
        PMP_Partner_Offering_Translation__c  descTrans = New PMP_Partner_Offering_Translation__c(Name='nameTest',PMP_Field_Nm__c='PMP_Partner_Offering_Dsc__c',
                                                        PMP_English_Txt__c='Eng',PMP_Partner_Offering_Id__c=offering1.id); 
        PMP_Partner_Offering_Translation__c  tagTrans = New PMP_Partner_Offering_Translation__c(Name='nameTest',PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c',
                                                        PMP_English_Txt__c='Eng',PMP_Partner_Offering_Id__c=offering1.id);                                                                                                  
       List<PMP_Partner_Offering_Translation__c> translationList = New List<PMP_Partner_Offering_Translation__c>{nameTrans,descTrans,tagTrans};
       insert translationList; 
       
       document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'IntelLogo';
        document.FolderId = [select id from folder where name = 'PMP_Marketplace_Images'].id;
        insert document;
         
        
       
    }
    public static testMethod void saveOfferingTest1(){    
        PMP_Partner_Offering__c offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
                                              PMP_Review_Comment_Txt__c, // ISG test category field
                                              PMP_Offering_Create_Dt__c, // new offering date (date)
                                              PMP_Partner_Offering_Dsc__c, // description (rich text)
                                              PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
                                              PMP_Partner_Offering_Start_Dt__c, // start date (date)
                                              PMP_Partner_Offering_Visibility_Nm__c,
                                              PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
                                              PMP_Review_Comment_History_Txt__c, // text area
                                              PMP_Business_Segment_Nm__c, // multi-select picklist
                                              PMP_Partner_Offering_End_Dt__c, // end date (date)
                                              PMP_Company_Id__c, //Offered by (Dropdown)
                                              PMP_Company_Id__r.Name, //Offered by - Company Name
                                              PMP_Offering_Language_Nm__c, // multi-select picklist
                                              PMP_Offering_Status_Update_Dt__c,
                                              PMP_Category_nm__c
                                            FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test12' LIMIT 1 ];
        offering.PMP_Partner_Offering_Nm__c = 'TestoffName';
        List<PMP_Specification__c> specList = [Select id from PMP_Specification__c];   
        system.debug(offering);                                     
        Intel_WizardData wizData = New Intel_WizardData();


        Map<String, Intel_SpecificationDataWrapper> company = New Map<String, Intel_SpecificationDataWrapper>();
        Intel_ProductWebPageDataWrapper intelProdData = New Intel_ProductWebPageDataWrapper();
        Map<string, List<Intel_SpecificationDataWrapper>> map1 = new Map<string, List<Intel_SpecificationDataWrapper>>(); 
        Map<string, List<string>> map2 = new Map<string, List<string>>();  
        Intel_SpecificationDataWrapper wrap1 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[0].id;
        Intel_SpecificationDataWrapper wrap2 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[1].id;
        List<string> wrapList = New List<string>{wrap1.id,wrap2.id};
        map2.put('test', wrapList);
        Intel_FormData formData = New Intel_FormData();
        formData.selectedCategories = null;
        formData.offering = offering;
        formData.selectedCategories=null;
        formData.selectedCategoriesSubCategory = null;
        formData.resources = null;
        formData.ProductWebPageName=null;
        formData.ProductWebPageURL=null;
        formData.productWebPageData = intelProdData;
        formData.specifications = null;
        formData.specification_smplTab1 = map2;

        wizData.formData = formData;
        wizData.offeringId = offering.id;
        wizData.activeStep = 0;
        wizData.currentStep = 0;
        wizdata.stepChange = 0;
        wizData.deleteOfferingSpecifications = true;
        wizData.category = 'Service|IPA_TYPE_Ser';

        string wizString = JSON.serialize(wizData);
        Test.startTest();
        string responseString = MarketplaceCreateProductController.saveOffering(wizString);
        Test.stopTest();
        PMP_Partner_Offering__c updtdOffering = [Select id,PMP_Partner_Offering_Nm__c from  PMP_Partner_Offering__c  Where id =: offering.id];
        system.assertEquals(updtdOffering.PMP_Partner_Offering_Nm__c ,'TestoffName' );
        
    }
    public static testMethod void saveOfferingTest2(){    
        PMP_Partner_Offering__c offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
                                              PMP_Review_Comment_Txt__c, // ISG test category field
                                              PMP_Offering_Create_Dt__c, // new offering date (date)
                                              PMP_Partner_Offering_Dsc__c, // description (rich text)
                                              PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
                                              PMP_Partner_Offering_Start_Dt__c, // start date (date)
                                              PMP_Partner_Offering_Visibility_Nm__c,
                                              PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
                                              PMP_Review_Comment_History_Txt__c, // text area
                                              PMP_Business_Segment_Nm__c, // multi-select picklist
                                              PMP_Partner_Offering_End_Dt__c, // end date (date)
                                              PMP_Company_Id__c, //Offered by (Dropdown)
                                              PMP_Company_Id__r.Name, //Offered by - Company Name
                                              PMP_Offering_Language_Nm__c, // multi-select picklist
                                              PMP_Offering_Status_Update_Dt__c,
                                              PMP_Category_nm__c
                                            FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test12' LIMIT 1 ];
        offering.PMP_Partner_Offering_Nm__c = 'TestoffName';
        List<PMP_Specification__c> specList = [Select id from PMP_Specification__c];   
        system.debug(offering);                                     
        Intel_WizardData wizData = New Intel_WizardData();


        Map<String, Intel_SpecificationDataWrapper> company = New Map<String, Intel_SpecificationDataWrapper>();
        Intel_ProductWebPageDataWrapper intelProdData = New Intel_ProductWebPageDataWrapper();
        Map<string, List<Intel_SpecificationDataWrapper>> map1 = new Map<string, List<Intel_SpecificationDataWrapper>>(); 
        Map<string, List<string>> map2 = new Map<string, List<string>>();  
        Intel_SpecificationDataWrapper wrap1 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[0].id;
        Intel_SpecificationDataWrapper wrap2 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[1].id;
        List<string> wrapList = New List<string>{wrap1.id,wrap2.id};
        map2.put('test', wrapList);
        Intel_FormData formData = New Intel_FormData();
        formData.selectedCategories = null;
        formData.offering = offering;
        formData.selectedCategories=null;
        formData.selectedCategoriesSubCategory = null;
        formData.resources = null;
        formData.ProductWebPageName=null;
        formData.ProductWebPageURL=null;
        formData.productWebPageData = intelProdData;
        formData.specifications = null;
        formData.specification_smplTab1 = map2;

        wizData.formData = formData;
        wizData.offeringId = offering.id;
        wizData.activeStep = 0;
        wizData.currentStep = 0;
        wizdata.stepChange = 0;
        wizData.deleteOfferingSpecifications = true;
        wizData.selectedLanguage = 'en_US';
        wizData.translationSaveType = 'translation_table';
        wizData.category = 'Service|IPA_TYPE_Ser';
        string wizString = JSON.serialize(wizData);
        Test.startTest();
        string responseString = MarketplaceCreateProductController.saveOffering(wizString);
        Test.stopTest();
        PMP_Partner_Offering__c updtdOffering = [Select id,PMP_Partner_Offering_Nm__c from  PMP_Partner_Offering__c  Where id =: offering.id];
        system.assertEquals(updtdOffering.PMP_Partner_Offering_Nm__c ,'Test12' );
        
    }
    
    public static testMethod void saveOfferingTest3(){    
        PMP_Partner_Offering__c offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
                                              PMP_Review_Comment_Txt__c, // ISG test category field
                                              PMP_Offering_Create_Dt__c, // new offering date (date)
                                              PMP_Partner_Offering_Dsc__c, // description (rich text)
                                              PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
                                              PMP_Partner_Offering_Start_Dt__c, // start date (date)
                                              PMP_Partner_Offering_Visibility_Nm__c,
                                              PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
                                              PMP_Review_Comment_History_Txt__c, // text area
                                              PMP_Business_Segment_Nm__c, // multi-select picklist
                                              PMP_Partner_Offering_End_Dt__c, // end date (date)
                                              PMP_Company_Id__c, //Offered by (Dropdown)
                                              PMP_Company_Id__r.Name, //Offered by - Company Name
                                              PMP_Offering_Language_Nm__c, // multi-select picklist
                                              PMP_Offering_Status_Update_Dt__c,
                                              PMP_Category_nm__c
                                            FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test12' LIMIT 1 ];
        offering.PMP_Partner_Offering_Nm__c = 'TestoffName';
        List<PMP_Specification__c> specList = [Select id from PMP_Specification__c];   
        system.debug(offering);                                     
        Intel_WizardData wizData = New Intel_WizardData();


        Map<String, Intel_SpecificationDataWrapper> company = New Map<String, Intel_SpecificationDataWrapper>();
        Intel_ProductWebPageDataWrapper intelProdData = New Intel_ProductWebPageDataWrapper();
        Map<string, List<Intel_SpecificationDataWrapper>> map1 = new Map<string, List<Intel_SpecificationDataWrapper>>(); 
        Map<string, List<string>> map2 = new Map<string, List<string>>();  
        Intel_SpecificationDataWrapper wrap1 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[0].id;
        Intel_SpecificationDataWrapper wrap2 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[1].id;
        List<string> wrapList = New List<string>{wrap1.id,wrap2.id};
        map2.put('test', wrapList);
        Intel_FormData formData = New Intel_FormData();
        formData.selectedCategories = null;
        formData.offering = offering;
        formData.offering.PMP_Partner_Offering_Nm__c = 'ChangedName';
        formData.selectedCategories=null;
        formData.selectedCategoriesSubCategory = null;
        formData.resources = null;
        formData.ProductWebPageName=null;
        formData.ProductWebPageURL=null;
        formData.productWebPageData = intelProdData;
        formData.specifications = null;
        formData.specification_smplTab1 = map2;

        wizData.formData = formData;
        wizData.offeringId = offering.id;
        wizData.activeStep = 0;
        wizData.currentStep = 0;
        wizdata.stepChange = 0;
        wizData.deleteOfferingSpecifications = true;
        wizData.selectedLanguage = 'en_US';
        wizData.translationSaveType = 'both';
        wizData.category = 'Service|IPA_TYPE_Ser';
        string wizString = JSON.serialize(wizData);
        Test.startTest();
        string responseString = MarketplaceCreateProductController.saveOffering(wizString);
        Test.stopTest();
        PMP_Partner_Offering__c updtdOffering = [Select id,PMP_Partner_Offering_Nm__c from  PMP_Partner_Offering__c  Where id =: offering.id];
        system.assertEquals(updtdOffering.PMP_Partner_Offering_Nm__c ,'ChangedName' );
        
    }
    
    public static testMethod void saveOfferingTest4(){    //translationSaveType = null;
        PMP_Partner_Offering__c offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
                                              PMP_Review_Comment_Txt__c, // ISG test category field
                                              PMP_Offering_Create_Dt__c, // new offering date (date)
                                              PMP_Partner_Offering_Dsc__c, // description (rich text)
                                              PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
                                              PMP_Partner_Offering_Start_Dt__c, // start date (date)
                                              PMP_Partner_Offering_Visibility_Nm__c,
                                              PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
                                              PMP_Review_Comment_History_Txt__c, // text area
                                              PMP_Business_Segment_Nm__c, // multi-select picklist
                                              PMP_Partner_Offering_End_Dt__c, // end date (date)
                                              PMP_Company_Id__c, //Offered by (Dropdown)
                                              PMP_Company_Id__r.Name, //Offered by - Company Name
                                              PMP_Offering_Language_Nm__c, // multi-select picklist
                                              PMP_Offering_Status_Update_Dt__c,
                                              PMP_Category_nm__c
                                            FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test12' LIMIT 1 ];
        offering.PMP_Partner_Offering_Nm__c = 'TestoffName';
        List<PMP_Specification__c> specList = [Select id from PMP_Specification__c];   
        system.debug(offering);                                     
        Intel_WizardData wizData = New Intel_WizardData();


        Map<String, Intel_SpecificationDataWrapper> company = New Map<String, Intel_SpecificationDataWrapper>();
        Intel_ProductWebPageDataWrapper intelProdData = New Intel_ProductWebPageDataWrapper();
        Map<string, List<Intel_SpecificationDataWrapper>> map1 = new Map<string, List<Intel_SpecificationDataWrapper>>(); 
        Map<string, List<string>> map2 = new Map<string, List<string>>();  
        Intel_SpecificationDataWrapper wrap1 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[0].id;
        Intel_SpecificationDataWrapper wrap2 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[1].id;
        List<string> wrapList = New List<string>{wrap1.id,wrap2.id};
        map2.put('test', wrapList);
        Intel_FormData formData = New Intel_FormData();
        formData.selectedCategories = null;
        formData.offering = offering;
        formData.selectedCategories=null;
        formData.selectedCategoriesSubCategory = null;
        formData.resources = null;
        formData.ProductWebPageName=null;
        formData.ProductWebPageURL=null;
        formData.productWebPageData = intelProdData;
        formData.specifications = null;
        formData.specification_smplTab1 = map2;

        wizData.formData = formData;
        wizData.offeringId = offering.id;
        wizData.activeStep = 0;
        wizData.currentStep = 0;
        wizdata.stepChange = 0;
        wizData.deleteOfferingSpecifications = true;
        wizData.selectedLanguage = 'en_US';
        wizData.translationSaveType = null;
        wizData.category = 'Service|IPA_TYPE_Ser';
        string wizString = JSON.serialize(wizData);
        Test.startTest();
        string responseString = MarketplaceCreateProductController.saveOffering(wizString);
        Test.stopTest();
        PMP_Partner_Offering__c updtdOffering = [Select id,PMP_Partner_Offering_Nm__c from  PMP_Partner_Offering__c  Where id =: offering.id];
        //system.assertEquals(updtdOffering.PMP_Partner_Offering_Nm__c ,'TestoffName' );
        
    }
    public static testMethod void refreshDataTest(){    
        PMP_Partner_Offering__c offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
                                              PMP_Review_Comment_Txt__c, // ISG test category field
                                              PMP_Offering_Create_Dt__c, // new offering date (date)
                                              PMP_Partner_Offering_Dsc__c, // description (rich text)
                                              PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
                                              PMP_Partner_Offering_Start_Dt__c, // start date (date)
                                              PMP_Partner_Offering_Visibility_Nm__c,
                                              PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
                                              PMP_Review_Comment_History_Txt__c, // text area
                                              PMP_Business_Segment_Nm__c, // multi-select picklist
                                              PMP_Partner_Offering_End_Dt__c, // end date (date)
                                              PMP_Company_Id__c, //Offered by (Dropdown)
                                              PMP_Company_Id__r.Name, //Offered by - Company Name
                                              PMP_Offering_Language_Nm__c, // multi-select picklist
                                              PMP_Offering_Status_Update_Dt__c,
                                              PMP_Category_nm__c
                                            FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test12' LIMIT 1 ];
        List<PMP_Specification__c> specList = [Select id from PMP_Specification__c];   
        system.debug(offering);                                     
        Intel_WizardData wizData = New Intel_WizardData();


        Map<String, Intel_SpecificationDataWrapper> company = New Map<String, Intel_SpecificationDataWrapper>();
        Intel_ProductWebPageDataWrapper intelProdData = New Intel_ProductWebPageDataWrapper();
        Map<string, List<Intel_SpecificationDataWrapper>> map1 = new Map<string, List<Intel_SpecificationDataWrapper>>(); 
        Map<string, List<string>> map2 = new Map<string, List<string>>();  
        Intel_SpecificationDataWrapper wrap1 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[0].id;
        Intel_SpecificationDataWrapper wrap2 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[1].id;
        List<string> wrapList = New List<string>{wrap1.id,wrap2.id};
        map2.put('test', wrapList);
        Intel_FormData formData = New Intel_FormData();
        formData.selectedCategories = null;
        formData.offering = offering;
        formData.selectedCategories=null;
        formData.selectedCategoriesSubCategory = null;
        formData.resources = null;
        formData.ProductWebPageName=null;
        formData.ProductWebPageURL=null;
        formData.productWebPageData = intelProdData;
        formData.specifications = null;
        formData.specification_smplTab1 = map2;

        wizData.formData = formData;
        wizData.offeringId = offering.id;
        wizData.activeStep = 0;
        wizData.currentStep = 0;
        wizdata.stepChange = 0;
        wizData.deleteOfferingSpecifications = true;
        wizData.category = 'Service|IPA_TYPE_Ser';

        string wizString = JSON.serialize(wizData);
        test.startTest();
        string responseString = MarketplaceCreateProductController.refreshData(wizString);
        test.stopTest();
        integer offCatCount = [Select count() from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c =: offering.id];
        system.assertEquals(0, offCatCount);
    }
    
    /*public static testMethod void getPreviewDataTest(){
        PMP_Partner_Offering__c offering = [Select id from PMP_Partner_Offering__c Limit 1];
        MarketplaceCreateProductController.getPreviewData(offering.id);
        
    
    }*/
    public static testMethod void createRecordTest(){
        MarketplaceCreateProductController.createRecord();
        integer count = [Select count() from PMP_Partner_Offering__c];
        system.assertEquals(3, Count);
    }
    public static testMethod void getWizardDataTest(){
        PMP_Partner_Offering__c offering = [Select id from PMP_Partner_Offering__c Limit 1];
        MarketplaceCreateProductController.getWizardData(offering.id,null);
    }
    public static testMethod void getWizardDataTest2(){ //With language
        //offering1.PMP_Partner_Offering_Nm__c = 'Test12';
        PMP_Partner_Offering__c offering = [Select id from PMP_Partner_Offering__c Where PMP_Partner_Offering_Nm__c = 'Test12' Limit 1];
        MarketplaceCreateProductController.getWizardData(offering.id,'en_US');
    }
     public static testMethod void getCategoryListTest(){
         string categoryString = MarketplaceCreateProductController.getCategoryList();
         List<PMP_CreateOfferingTab0Service.CategoryWrapper> catWrap =  (List<PMP_CreateOfferingTab0Service.CategoryWrapper>)JSON.deserialize(categoryString,List<PMP_CreateOfferingTab0Service.CategoryWrapper>.class);
         system.assertEquals(0, catWrap.size());
     }
     public static testMethod void isDuplicateOfferingServerCallTest(){
        PMP_Partner_Offering__c offering = [Select id from PMP_Partner_Offering__c Limit 1];
        MarketplaceCreateProductController.isDuplicateOfferingServerCall('Test', offering.id, 'TestComp');
    }
     public static testMethod void submitOfferingTest(){
            
        PMP_Partner_Offering__c offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
                                              PMP_Review_Comment_Txt__c, // ISG test category field
                                              PMP_Offering_Create_Dt__c, // new offering date (date)
                                              PMP_Partner_Offering_Dsc__c, // description (rich text)
                                              PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
                                              PMP_Partner_Offering_Start_Dt__c, // start date (date)
                                              PMP_Partner_Offering_Visibility_Nm__c,
                                              PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
                                              PMP_Review_Comment_History_Txt__c, // text area
                                              PMP_Business_Segment_Nm__c, // multi-select picklist
                                              PMP_Translation_Lifecycle_Status_nm__c, //Picklist
                                              PMP_Partner_Offering_End_Dt__c, // end date (date)
                                              PMP_Company_Id__c, //Offered by (Dropdown)
                                              PMP_Company_Id__r.Name, //Offered by - Company Name
                                              PMP_Offering_Language_Nm__c, // multi-select picklist
                                              PMP_Offering_Status_Update_Dt__c,
                                              PMP_Category_nm__c
                                            FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test12' LIMIT 1 ];
        offering.PMP_Business_Segment_Nm__c = 'IoT';
         offering.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        update Offering;
        List<PMP_Specification__c> specList = [Select id from PMP_Specification__c];
        Map<String, Intel_SpecificationDataWrapper> company = New Map<String, Intel_SpecificationDataWrapper>();
        Intel_ProductWebPageDataWrapper intelProdData = New Intel_ProductWebPageDataWrapper();
        Map<string, List<Intel_SpecificationDataWrapper>> map1 = new Map<string, List<Intel_SpecificationDataWrapper>>(); 
        Map<string, List<string>> map2 = new Map<string, List<string>>();  
        Intel_SpecificationDataWrapper wrap1 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[0].id;
        Intel_SpecificationDataWrapper wrap2 = New Intel_SpecificationDataWrapper();
        wrap1.id=specList[1].id;
        List<string> wrapList = New List<string>{wrap1.id,wrap2.id};
        map2.put('test', wrapList);
        Intel_FormData formData = New Intel_FormData();
        formData.selectedCategories = null;
        formData.offering = offering;
        formData.selectedCategories=null;
        formData.selectedCategoriesSubCategory = null;
        formData.resources = null;
        formData.ProductWebPageName=null;
        formData.ProductWebPageURL=null;
        formData.productWebPageData = intelProdData;
        formData.specifications = null;
        formData.specification_smplTab1 = map2;
        string formString = JSON.serialize(formData);
        Test.startTest();
        MarketplaceCreateProductController.submitOffering(formString,'');
        Test.stopTest();
     }
     /*
      public static testMethod void cancelOfferingTest(){
          Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
          User u = PMP_TestDataUtility.createTestUser(profileId);
          insert u;
          
          PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering12', 'Public Content','off desc',null,false,'draft','taglineTest' );
          system.runAs(u){
              Test.startTest();
              MarketplaceCreateProductController.cancelOffering(offering.id);
              Test.stopTest();
              integer offCount = [Select count() from PMP_Partner_Offering__c WHERE Id =:offering.Id];
              system.assertEquals(0,offCount);
          }
      }
      */
      public static testMethod void getAdminDetailsTest(){
          PMP_Partner_Offering__c offering = [Select id,PMP_Business_Segment_Nm__c from PMP_Partner_Offering__c Limit 1];
          Test.startTest();
          PMP_LightningServerResponse response = MarketplaceCreateProductController.getAdminDetails(offering.id);
          Test.stopTest();
          user usr = (user) response.objectData.get('loggedInUser');
          system.assertEquals(userinfo.getUserId(), usr.Id);
      }
    public static testMethod void getAdminDetailsTest1(){
          PMP_Partner_Offering__c offeringRec = new PMP_Partner_Offering__c();
          offeringRec.PMP_Business_Segment_Nm__c = 'IoT';
          insert offeringRec;
          Test.startTest();
          PMP_LightningServerResponse response = MarketplaceCreateProductController.getAdminDetails(offeringRec.id);
          Test.stopTest();
          user usr = (user) response.objectData.get('loggedInUser');
          system.assertEquals(userinfo.getUserId(), usr.Id);
      }
     /* public static testMethod void syncBackWorkingCopyWithPublishedVersionTest(){
      
          
         
          PMP_Partner_Offering__c offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
                                              PMP_Review_Comment_Txt__c, // ISG test category field
                                              PMP_Offering_Create_Dt__c, // new offering date (date)
                                              PMP_Partner_Offering_Dsc__c, // description (rich text)
                                              PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
                                              PMP_Partner_Offering_Start_Dt__c, // start date (date)
                                              PMP_Partner_Offering_Visibility_Nm__c,
                                              PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
                                              PMP_Review_Comment_History_Txt__c, // text area
                                              PMP_Business_Segment_Nm__c, // multi-select picklist
                                              PMP_Partner_Offering_End_Dt__c, // end date (date)
                                              PMP_Company_Id__c, //Offered by (Dropdown)
                                              PMP_Company_Id__r.Name, //Offered by - Company Name
                                              PMP_Offering_Language_Nm__c, // multi-select picklist
                                              PMP_Offering_Status_Update_Dt__c,
                                              PMP_Category_nm__c
                                              
                                            FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test1232' LIMIT 1];
                                            
          
          PMP_Partner_Offering__c clonedOff = offering.clone(false,false,false,false);
          clonedOff.Name = 'AfterSync';
          clonedOff.PMP_Working_Copy_Id__c = offering.id;
         //offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
          insert clonedOff;
          
          update offering;
         List<PMP_Partner_Offering__c > offeringList = New List<PMP_Partner_Offering__c >();
         offeringList.add(offering);
         PMP_OfferingTriggerHelper.createPublishedOfferings(offeringList ); 
         Test.startTest();
          
          MarketplaceCreateProductController.syncBackWorkingCopyWithPublishedVersion(offering.id);
           system.debug('endDate-->'+offering.PMP_Partner_Offering_Dsc__c );
          Test.stopTest();
          PMP_Partner_Offering__c updatedOff = [Select Name FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test1232' LIMIT 1];
         system.assertequals('AfterSync', updatedOff.Name);
      
      } */
       public static testMethod void saveAdminDetailsTest(){
           PMP_Partner_Offering__c off = [Select id from PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test1232' Limit 1];
         User  user=[SELECT Id, Name FROM User where Id=:userinfo.getUserId() Limit 1];
         MarketplaceCreateProductController.saveAdminDetails(off.id, user.id, 'Approved');
         PMP_Partner_Offering__c updtdOff = [Select id,PMP_Partner_Offering_Lifecycle_Status_Nm__c from PMP_Partner_Offering__c Where id =: off.id ];
         system.assertequals('Approved', updtdOff.PMP_Partner_Offering_Lifecycle_Status_Nm__c );
           
       }
        public static testMethod void getOffSetValuesTest(){
            PMP_Partner_Offering__c off = [Select id from PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test1232' Limit 1];
            MarketplaceCreateProductController.getOffSetValues(off.id);
        }
        public static testMethod void getCreateOfferingAccessTest(){
            boolean res = MarketplaceCreateProductController.getCreateOfferingAccess();
            
        }
        public static testMethod void validateOfferingDataServerCallTest(){
            PMP_Partner_Offering__c offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Active_Step_Txt__c, PMP_Current_Step_Txt__c,
                                              PMP_Review_Comment_Txt__c, // ISG test category field
                                              PMP_Offering_Create_Dt__c, // new offering date (date)
                                              PMP_Partner_Offering_Dsc__c, // description (rich text)
                                              PMP_Partner_Offering_Tag_Line_Txt__c, // tag line (text)
                                              PMP_Partner_Offering_Start_Dt__c, // start date (date)
                                              PMP_Partner_Offering_Visibility_Nm__c,
                                              PMP_Partner_Offering_Lifecycle_Status_Nm__c, // status (picklist)
                                              PMP_Review_Comment_History_Txt__c, // text area
                                              PMP_Business_Segment_Nm__c, // multi-select picklist
                                              PMP_Translation_Lifecycle_Status_nm__c, //Picklist
                                              PMP_Partner_Offering_End_Dt__c, // end date (date)
                                              PMP_Company_Id__c, //Offered by (Dropdown)
                                              PMP_Company_Id__r.Name, //Offered by - Company Name
                                              PMP_Offering_Language_Nm__c, // multi-select picklist
                                              PMP_Offering_Status_Update_Dt__c,
                                              PMP_Category_nm__c
                                            FROM PMP_Partner_Offering__c WHERE PMP_Partner_Offering_Nm__c = 'Test12' LIMIT 1 ];
            Intel_FormData formData = New Intel_FormData();
            Map<String,List<Intel_SpecificationDataWrapper>> valueByTypeIndApp = new Map<String,List<Intel_SpecificationDataWrapper>>();
            PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
            List<Intel_SpecificationDataWrapper> applications = new List<Intel_SpecificationDataWrapper>();
            PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Retail', 'IPA_Ind_Retail','NPP_01_Industry', 'en_us');
            Intel_SpecificationDataWrapper specDataWrapper4 = new Intel_SpecificationDataWrapper();
            specDataWrapper4.id = ind1.Id;
            applications.add(specDataWrapper4);
            Intel_SpecificationDataWrapper specDataWrapper5 = new Intel_SpecificationDataWrapper();
            specDataWrapper5.id = ind2.Id;
            applications.add(specDataWrapper5);
            Map<string, List<string>> map2 = new Map<string, List<string>>();  
            List<PMP_Specification__c> specList = [Select id from PMP_Specification__c];
            Intel_SpecificationDataWrapper wrap1 = New Intel_SpecificationDataWrapper();
            wrap1.id=specList[0].id;
            Intel_SpecificationDataWrapper wrap2 = New Intel_SpecificationDataWrapper();
            wrap1.id=specList[1].id;
            List<string> wrapList = New List<string>{wrap1.id,wrap2.id};
            formData.offering = offering;
            map2.put('test', wrapList);
            valueByTypeIndApp.put('applicationValues', applications);
            formData.specification_smplTab1 = map2;
            formData.industryAndApplication = valueByTypeIndApp;
            string formString = JSON.serialize(formData);
            MarketplaceCreateProductController.validateOfferingDataServerCall(formString);  
        }       
 
}