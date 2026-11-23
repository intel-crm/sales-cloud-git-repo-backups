@isTest(SeeAllData=false)
public class PMP_SpecificationController_Test {

    

    // @isTest
    // static void validateGetOfferingSpecificationList(){
        
    //     PMP_SpecificationController specificationController= new PMP_SpecificationController();
        
    //      User user = [SELECT LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()]; 
    //      String [] selectedCategoryIds = new List<String>();
        
    //     PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Test','Public Content','Test',null,true,'Draft',' ');
    //     PMP_Partner_Offering_Specification__c offeringSpec = PMP_TestDataUtility.getPMPOfferingSpecification(offering.Id);
    //   /*  if(offering.Id!=null){
    //         PMP_Partner_Offering_Specification__c offeringSpec = PMP_TestDataUtility.getPMPOfferingSpecification(offering.Id);
    //     } */
        
    //     PMP_Category__c category = PMP_TestDataUtility.getCategory('Component','NPP_02_TYPE_Comp','NPP_01_TYPE','');
    //     PMP_Specification__c spec1 = PMP_TestDataUtility.getSpecs();
    //     PMP_Specification__c spec2 = PMP_TestDataUtility.getSpecs();
    //     spec2.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Comp,NPP_01_TYPE';
    //     spec2.PMP_Partner_Product_Specification_Id__c = 'Test';
    //     spec2.PMP_Parent_Specification_Id__c = spec1.id;
    //     //spec2.PMP_Mandatory_Offering_Category_Nm__c='Not minimum requirement. Optional';
    //     //spec2.PMP_Ancestor_Specification_Cd__c = 'NPP_01_TYPE|NPP_02_TYPE_Sys';
    //     update spec2;
    //     PMP_Specification_Value_Association__c specCatValue = New PMP_Specification_Value_Association__c(Name = 'test',
    //                                                            PMP_Category_Id__c = category.id, PMP_Specification_Id__c = spec1.id,
    //                                                            PMP_Specification_Value_Id__c = offeringSpec.PMP_Specification_Value_Id__c );
    //     insert specCatValue;                                                        
    //     PMP_Category_Specification_Association__c catSpec = PMP_TestDataUtility.getCategorySpecs(category.Id,spec1.Id);
    //     PMP_Category_Specification_Association__c catSpec2 = PMP_TestDataUtility.getCategorySpecs(category.Id,spec2.Id);
        
        
    //     selectedCategoryIds.add('NPP_01_TYPE');
    //     selectedCategoryIds.add('NPP_02_TYPE_Sys');
    //     selectedCategoryIds.add('NPP_03_TYPE_Sys_Laptop');
    //     selectedCategoryIds.add('NPP_02_TYPE_Comp');
    //     test.startTest();
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs=PMP_SpecificationController.getOfferingSpecificationList(selectedCategoryIds,null);
    //     system.assert(offeringSpecs!=null);
         
        
        
    //   /*  for(PMP_SpecificationController.Core_PMP_OfferingSpecs spec: offeringSpecs){
    //         if(spec.specId=='NPP_IntelTechnologies'){
    //             system.assert(spec.specValues!=null);
    //             system.assertEquals(spec.categoryId,'NPP_01_TYPE');                
    //         }
            
    //     } */
        
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs1=PMP_SpecificationController.getOfferingSpecificationList(selectedCategoryIds,offering.Id);
    //     system.assert(offeringSpecs1!=null);
        
    //     String [] tempSelectedCategoryIds = new List<String>();
    //   //  List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs2=PMP_SpecificationController.getOfferingSpecificationList(tempSelectedCategoryIds,null, null);
    //     test.stopTest();
        
        
        
    // }
    // @isTest
    // static void validateGetOfferingSpecificationListwithMandatory(){
        
    //     PMP_SpecificationController specificationController= new PMP_SpecificationController();
        
    //      User user = [SELECT LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()]; 
    //      String [] selectedCategoryIds = new List<String>();
        
    //     PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Test','Public Content','Test',null,true,'Draft',' ');
    //     PMP_Partner_Offering_Specification__c offeringSpec = PMP_TestDataUtility.getPMPOfferingSpecification(offering.Id);
    //   /*  if(offering.Id!=null){
    //         PMP_Partner_Offering_Specification__c offeringSpec = PMP_TestDataUtility.getPMPOfferingSpecification(offering.Id);
    //     } */
        
    //     PMP_Category__c category = PMP_TestDataUtility.getCategory('Component','NPP_02_TYPE_Comp','NPP_01_TYPE','');
    //     PMP_Specification__c spec1 = PMP_TestDataUtility.getSpecs();
    //     PMP_Specification__c spec2 = PMP_TestDataUtility.getSpecs();
    //     spec2.PMP_Mandatory_Offering_Category_Nm__c = 'NPP_02_TYPE_Comp,NPP_01_TYPE';
    //     spec2.PMP_Partner_Product_Specification_Id__c = 'Test';
    //     spec2.PMP_Parent_Specification_Id__c = spec1.id;
    //     spec2.PMP_Mandatory_Offering_Category_Nm__c='Not minimum requirement. Optional';
    //     //spec2.PMP_Ancestor_Specification_Cd__c = 'NPP_01_TYPE|NPP_02_TYPE_Sys';
    //     update spec2;
    //     PMP_Specification_Value_Association__c specCatValue = New PMP_Specification_Value_Association__c(Name = 'test',
    //                                                            PMP_Category_Id__c = category.id, PMP_Specification_Id__c = spec1.id,
    //                                                            PMP_Specification_Value_Id__c = offeringSpec.PMP_Specification_Value_Id__c );
    //     insert specCatValue;                                                        
    //     PMP_Category_Specification_Association__c catSpec = PMP_TestDataUtility.getCategorySpecs(category.Id,spec1.Id);
    //     PMP_Category_Specification_Association__c catSpec2 = PMP_TestDataUtility.getCategorySpecs(category.Id,spec2.Id);
        
        
    //     selectedCategoryIds.add('NPP_01_TYPE');
    //     selectedCategoryIds.add('NPP_02_TYPE_Sys');
    //     selectedCategoryIds.add('NPP_03_TYPE_Sys_Laptop');
    //     selectedCategoryIds.add('NPP_02_TYPE_Comp');
    //     test.startTest();
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs=PMP_SpecificationController.getOfferingSpecificationList(selectedCategoryIds,null);
    //     system.assert(offeringSpecs!=null);
         
        
        
    //   /*  for(PMP_SpecificationController.Core_PMP_OfferingSpecs spec: offeringSpecs){
    //         if(spec.specId=='NPP_IntelTechnologies'){
    //             system.assert(spec.specValues!=null);
    //             system.assertEquals(spec.categoryId,'NPP_01_TYPE');                
    //         }
            
    //     } */
        
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs1=PMP_SpecificationController.getOfferingSpecificationList(selectedCategoryIds,offering.Id);
    //     system.assert(offeringSpecs1!=null);
        
    //     String [] tempSelectedCategoryIds = new List<String>();
    //   //  List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs2=PMP_SpecificationController.getOfferingSpecificationList(tempSelectedCategoryIds,null, null);
    //     test.stopTest();
        
        
        
    // }
    // @isTest
    // static void validateGetOfferingSpecificationList2(){
        

    //      //User user = [SELECT LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()]; 
    //      String [] selectedCategoryIds = new List<String>();
        
    //     PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Test','Public Content','Test',null,true,'Draft',' ');
    //     if(offering.Id!=null){
    //         PMP_Partner_Offering_Specification__c offeringSpec1 = PMP_TestDataUtility.getPMPOfferingSpecification(offering.Id);
    //         if(offeringSpec1.Id!=null){
    //             offeringSpec1.PMP_Ancestor_Specification_Cd__c = 'NPP_IntelTechnologies';
    //             update offeringSpec1;
    //         }
            
    //     }

    //     selectedCategoryIds.add('NPP_01_TYPE');
    //     selectedCategoryIds.add('NPP_02_TYPE_Sys');
    //     selectedCategoryIds.add('NPP_03_TYPE_Sys_Laptop');
    //     test.startTest();
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs=PMP_SpecificationController.getOfferingSpecificationList(selectedCategoryIds,null);
    //     system.assert(offeringSpecs!=null);
        
        
        
    //    /* for(PMP_SpecificationController.Core_PMP_OfferingSpecs spec: offeringSpecs){
    //         if(spec.specId=='NPP_IntelTechnologies'){
    //             system.assert(spec.specValues!=null);
    //             system.assertEquals(spec.categoryId,'NPP_01_TYPE');                
    //         }
            
    //     } */
        
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs1=PMP_SpecificationController.getOfferingSpecificationList(selectedCategoryIds,offering.Id);
    //     system.assert(offeringSpecs1!=null);
        
    //     String [] tempSelectedCategoryIds = new List<String>();
        
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs2=PMP_SpecificationController.getOfferingSpecificationList(tempSelectedCategoryIds,null);
    //     system.assertNotEquals(offeringSpecs2,Null);
    //     test.stopTest();
    // }
    
   
    // @isTest 
    // static void validateOfferingSpecMap(){
    //      PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
    //     insert apiKey;
    //     //Create account
    //     Account testAccount = new Account();
    //     testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
    //     testAccount.Name = 'Test Account 19-Jun-19';       
    //     testAccount.Core_Account_Country__c='India';
    //     testAccount.Core_Sales_Group_New__c='US Sales Group';
    //     testAccount.Core_Account_Type__c='ODM';
    //     testAccount.BillingStreet='Bangalore Central';
    //     testAccount.BillingCity='Bangalore';
    //     testAccount.BillingCountry='IND';
    //     testAccount.BillingState='KA';
    //     testAccount.BillingPostalCode='560029';
    //     testAccount.Industry='Agriculture';
    //     insert testAccount;
        
    //      PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
    //                                                      PMP_Account_Id__c=testAccount.Id);
        
       
                
       
                                
    //     PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
    //                                                                              'TestDuplicate',testCompany.Id, true,'Draft','');
    //     PMP_Partner_Offering_Category__c offCategory = PMP_TestDataUtility.getPMPOfferingCategory(offering1.id);
        
    //     PMP_Partner_Offering_Specification__c offSpecs = PMP_TestDataUtility.getPMPOfferingSpecification(offering1.id);
        
    //     list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        
    //     PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
    //     offering1.PMP_Partner_Offering_Start_Dt__c = system.Today();
    //     Test.startTest();
    //    // update offering1;
    //     offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft';
    //     update offering1;
    //     /*offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
    //     update offering1;
    //     */
       
    //     PMP_LightningServerResponse getOfferings = new PMP_LightningServerResponse();
    //     //string offerings = PMP_CreateOfferings.fetchOfferingDetail(offering1.id,true,true,false);
        
    //     system.assertEquals(offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c,'Draft');
    //     Test.stopTest();
    
    // }
    // @isTest
    // static void getOfferingSpecificationList(){
        
    //     List<String> selectedCategoryIds=new List<String>();
    //     selectedCategoryIds.add('NPP_01_TYPE');
    //     selectedCategoryIds.add('NPP_02_TYPE_Sys');
    //     selectedCategoryIds.add('NPP_03_TYPE_Sys_Laptop');
    //     selectedCategoryIds.add('NPP_02_TYPE_Comp');
    //     List<Id> offeringId=new List<Id>();
        
        
        
    //    //Create account
    //     Account testAccount = new Account();
    //     testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
    //     testAccount.Name = 'Test Account 19-Jun-19';       
    //     testAccount.Core_Account_Country__c='India';
    //     testAccount.Core_Sales_Group_New__c='US Sales Group';
    //     testAccount.Core_Account_Type__c='ODM';
    //     testAccount.BillingStreet='Bangalore Central';
    //     testAccount.BillingCity='Bangalore';
    //     testAccount.BillingCountry='IND';
    //     testAccount.BillingState='KA';
    //     testAccount.BillingPostalCode='560029';
    //     testAccount.Industry='Agriculture';
    //     insert testAccount;
        
    //      PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
    //                                                      PMP_Account_Id__c=testAccount.Id);
        
    //     PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering('Test 19 feb 8:50 PM', 'Public Content','Test 19 feb 8:50 PM',testCompany.id,true,'Published','The paper Company');
    //     //PMP_Partner_Offering__c testOffering2=PMP_TestDataUtility.createOffering('Test 19 feb 8:50 ', 'Public Content','Test 19 feb 8:50 PM','a3z0n0000003sHGAAY',true,'Published','');
    //     offeringId.add(testOffering.Id);
    //     PMP_TestDataUtility.getPMPOfferingCategory(testOffering.Id);
    //     //PMP_TestDataUtility.getPMPOfferingSpecification(testOffering.Id);
    //     PMP_Partner_Offering_Specification__c specs=PMP_TestDataUtility.createOfferingSpecification('2-in-1', testOffering.Id, 'NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_IntelTechnologies',
    //                                                     'NPP_02_TYPE_Sys','NPP_03_TYPE_Sys_Laptop', 'NPP_IntelTechnologies','Checkbox');
    //     Test.startTest();
    //     PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor', testOffering.Id, 'NPP_Processors',
    //                                                     'Intel® Celeron® Processor','Intel® Celeron® Processor', '122698','Checkbox');
        
    //     PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor 3000 Series', testOffering.Id, 'NPP_Processors|43521',
    //                                                     'Intel® Celeron® Processor','Intel® Celeron® Processor 3965Y (2M Cache, 1.50 GHz)', '122698','Checkbox');
        
    //     PMP_TestDataUtility.createOfferingSpecification('FPGAs', testOffering.Id, 'NPP_FPGA|Arria V',
    //                                                     'FPGAs','FPGAs', 'Arria V FPGAs','Checkbox');
    //     PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
    //                                                     'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '126380','Checkbox');
    //     PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
    //                                                     'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '','Checkbox');
        
    //     PMP_TestDataUtility.createOfferingSpecification('Mass Product', testOffering.Id, 'AvailabilityandPricingLevel1',
    //                                                     'NPP_AvailabilityAndPricing_MassProductionSchedule','NPP_AvailabilityAndPricing_MassProductionSchedule', '2019-02-28','Date');
        
    //     PMP_TestDataUtility.createOfferingSpecification('Order Lead Time (Days)', testOffering.Id, 'AvailabilityandPricingLevel1',
    //                                                     'NPP_AvailabilityAndPricing_OrderLeadTimeDays','NPP_AvailabilityAndPricing_MassProductionSchedule', '20','Integer');
        
        
    //     //PMP_TestDataUtility.getPMPOfferingSpecification(testOffering.Id);
    //     PMP_TestDataUtility.createResources('AXMA','www.axma.com',testOffering.Id, 'Web Page','');
        
    //     PMP_TestDataUtility.createResources('DataSheet1','www.datasheet1.com',testOffering.Id, 'Data Sheet','');
    //     PMP_TestDataUtility.createResources('Product Brief','www.productbrief.com',testOffering.Id, 'Product Brief','');
    //     PMP_TestDataUtility.createResources('AdditionalRes1','www.add1.com',testOffering.Id, 'Additional Resources','');
    //     List<contentDocument> contentDoc=PMP_TestDataUtility.createContentDocument(true);
    //     // system.debug('contentDoc:'+contentDoc);
    //     PMP_TestDataUtility.createResources('global-communications-icon','',testOffering.Id, 'Image', contentDoc[0].Id);
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs1=PMP_SpecificationController.getOfferingSpecificationList(selectedCategoryIds,testOffering.Id);
    //     List<PMP_Partner_Offering_Specification__c> specList=new List<PMP_Partner_Offering_Specification__c>();
    //     specList.add(specs);
    //     Map<string, List<string>> response = PMP_SpecificationController.getOfferingValuesAndSpecificationMap(specList,'en_US');
        
    //     system.assertNotEquals(response,Null);
    //     Test.stopTest();
    // }
    
    // @isTest
    // static void getOfferingSpecificationList2(){
        
    //     List<String> selectedCategoryIds=new List<String>();
    //     selectedCategoryIds.add('NPP_01_TYPE');
    //     selectedCategoryIds.add('NPP_02_TYPE_Sys');
    //     selectedCategoryIds.add('NPP_03_TYPE_Sys_Laptop');
    //     selectedCategoryIds.add('NPP_02_TYPE_Comp');
    //     List<Id> offeringId=new List<Id>();
        
    //     //Create account
    //     Account testAccount = new Account();
    //     testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
    //     testAccount.Name = 'Test Account 19-Jun-19';       
    //     testAccount.Core_Account_Country__c='India';
    //     testAccount.Core_Sales_Group_New__c='US Sales Group';
    //     testAccount.Core_Account_Type__c='ODM';
    //     testAccount.BillingStreet='Bangalore Central';
    //     testAccount.BillingCity='Bangalore';
    //     testAccount.BillingCountry='IND';
    //     testAccount.BillingState='KA';
    //     testAccount.BillingPostalCode='560029';
    //     testAccount.Industry='Agriculture';
    //     insert testAccount;
        
    //      PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
    //                                                      PMP_Account_Id__c=testAccount.Id);
        
    //     PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering('Test 19 feb 8:50 PM', 'Public Content','Test 19 feb 8:50 PM',testCompany.id,true,'Published','The paper Company');
    //     //PMP_Partner_Offering__c testOffering2=PMP_TestDataUtility.createOffering('Test 19 feb 8:50 ', 'Public Content','Test 19 feb 8:50 PM','a3z0n0000003sHGAAY',true,'Published','');
    //     offeringId.add(testOffering.Id);
    //     PMP_TestDataUtility.getPMPOfferingCategory(testOffering.Id);
    //     //PMP_TestDataUtility.getPMPOfferingSpecification(testOffering.Id);
    //     PMP_Partner_Offering_Specification__c specs=PMP_TestDataUtility.createOfferingSpecification('2-in-1', testOffering.Id, 'NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_IntelTechnologies',
    //                                                     'NPP_02_TYPE_Sys','NPP_03_TYPE_Sys_Laptop', 'NPP_IntelTechnologies','Checkbox');
    //     Test.startTest();
    //     PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor', testOffering.Id, 'NPP_Processors',
    //                                                     'Intel® Celeron® Processor','Intel® Celeron® Processor', '122698','Checkbox');
        
    //     PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor 3000 Series', testOffering.Id, 'NPP_Processors|43521',
    //                                                     'Intel® Celeron® Processor','Intel® Celeron® Processor 3965Y (2M Cache, 1.50 GHz)', '122698','Checkbox');
        
    //     PMP_TestDataUtility.createOfferingSpecification('FPGAs', testOffering.Id, 'NPP_FPGA|Arria V',
    //                                                     'FPGAs','FPGAs', 'Arria V FPGAs','Checkbox');
    //     PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
    //                                                     'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '126380','Checkbox');
    //     PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
    //                                                     'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '','Checkbox');
        
    //     PMP_TestDataUtility.createOfferingSpecification('Mass Product', testOffering.Id, 'AvailabilityandPricingLevel1',
    //                                                     'NPP_AvailabilityAndPricing_MassProductionSchedule','NPP_AvailabilityAndPricing_MassProductionSchedule', '2019-02-28','Date');
        
    //     PMP_TestDataUtility.createOfferingSpecification('Order Lead Time (Days)', testOffering.Id, 'AvailabilityandPricingLevel1',
    //                                                     'NPP_AvailabilityAndPricing_OrderLeadTimeDays','NPP_AvailabilityAndPricing_MassProductionSchedule', '20','Integer');
        
        
    //     //PMP_TestDataUtility.getPMPOfferingSpecification(testOffering.Id);
    //     PMP_TestDataUtility.createResources('AXMA','www.axma.com',testOffering.Id, 'Web Page','');
        
    //     PMP_TestDataUtility.createResources('DataSheet1','www.datasheet1.com',testOffering.Id, 'Data Sheet','');
    //     PMP_TestDataUtility.createResources('Product Brief','www.productbrief.com',testOffering.Id, 'Product Brief','');
    //     PMP_TestDataUtility.createResources('AdditionalRes1','www.add1.com',testOffering.Id, 'Additional Resources','');
    //     List<contentDocument> contentDoc=PMP_TestDataUtility.createContentDocument(true);
    //     // system.debug('contentDoc:'+contentDoc);
    //     PMP_TestDataUtility.createResources('global-communications-icon','',testOffering.Id, 'Image', contentDoc[0].Id);
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> offeringSpecs1=PMP_SpecificationController.getOfferingSpecificationList(selectedCategoryIds,testOffering.Id);
    //     List<PMP_Partner_Offering_Specification__c> specList=new List<PMP_Partner_Offering_Specification__c>();
    //     specList.add(specs);
    //     Map<string, List<string>> response = PMP_SpecificationController.getOfferingValuesAndSpecificationMap(specList,'en_US');
        
    //     system.assertNotEquals(response,Null);
    //     Test.stopTest();
    // }
    //  @isTest 
    // static void getOffSetValues(){
    //     String offferingNameDesc=String.valueOf(DateTime.now());
    //      //Create account
    //     Account testAccount = new Account();
    //     testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
    //     testAccount.Name = 'Test Account 19-Jun-19';       
    //     testAccount.Core_Account_Country__c='India';
    //     testAccount.Core_Sales_Group_New__c='US Sales Group';
    //     testAccount.Core_Account_Type__c='ODM';
    //     testAccount.BillingStreet='Bangalore Central';
    //     testAccount.BillingCity='Bangalore';
    //     testAccount.BillingCountry='IND';
    //     testAccount.BillingState='KA';
    //     testAccount.BillingPostalCode='560029';
    //     testAccount.Industry='Agriculture';
    //     insert testAccount;
    //     Test.startTest();
    //      PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
    //                                                      PMP_Account_Id__c=testAccount.Id);
    //     PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',testCompany.Id,true,'Draft','');
        
    //     PMP_Partner_Offering_Specification__c specs=PMP_TestDataUtility.createOfferingSpecification('2-in-1', testOffering.Id, 'NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_IntelTechnologies',
    //                                                     'NPP_02_TYPE_Sys','NPP_03_TYPE_Sys_Laptop', 'NPP_IntelTechnologies','Checkbox');
        
        
        
    //    //PMP_Specification_Value__c specificationValue=new PMP_Specification_Value__c(Name='testSpecification1', PMP_Product_Specification_Value_Cd__c='NPP_Spec_1', PMP_Display_Type_Nm__c='Solutions' ,
    //    //         PMP_Partner_Off_Roadmap_Ind__c=True);
    //     //insert specificationValue;
    //     //specs.PMP_Specification_Value_Id__c=specificationValue.id;        
    //     //specs.PMP_Specification_Value_Id__r.PMP_Partner_Off_Roadmap_Ind__c=True;
    //     //specs.PMP_Specification_Value_Id__c='werwer';
    //     //PMP_Partner_Offering_Specification__c offSetValues=new PMP_Partner_Offering_Specification__c();
    //     //offSetValues.add(specs);
    //     update specs;
    //     Boolean response = PMP_SpecificationController.getOffSetValues(testOffering.Id);
    //     system.assertNotEquals(response,true);
    //     Test.stopTest();
    // }
     
    //  @isTest 
    // static void getOfferingSpecificationsMap(){
    //     String offferingNameDesc=String.valueOf(DateTime.now());
        
    //      //Create account
    //     Account testAccount = new Account();
    //     testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
    //     testAccount.Name = 'Test Account 19-Jun-19';       
    //     testAccount.Core_Account_Country__c='India';
    //     testAccount.Core_Sales_Group_New__c='US Sales Group';
    //     testAccount.Core_Account_Type__c='ODM';
    //     testAccount.BillingStreet='Bangalore Central';
    //     testAccount.BillingCity='Bangalore';
    //     testAccount.BillingCountry='IND';
    //     testAccount.BillingState='KA';
    //     testAccount.BillingPostalCode='560029';
    //     testAccount.Industry='Agriculture';
    //     insert testAccount;
    //     Test.startTest();
    //      PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
    //                                                      PMP_Account_Id__c=testAccount.Id);
        
    //     PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering(offferingNameDesc,'Public Content',offferingNameDesc,testCompany.id,true,'Published','The paper Company');
    //     List<Id> offeringIds=new List<Id>();
    //     offeringIds.add(testOffering.Id);
        
    //     PMP_SpecificationController.Core_PMP_OfferingSpecsValues specValues=new PMP_SpecificationController.Core_PMP_OfferingSpecsValues();
    //     specValues.dateValue=String.valueOf(DateTime.now());
    //     specValues.intValue='8';
    //     Map<id,List<PMP_Partner_Offering_Specification__c>> response = PMP_SpecificationController.getOfferingSpecificationsMap(offeringIds);
        
    //     system.assertNotEquals(response,Null);
    //     Test.stopTest();
    // }
    
    // @isTest
    // static void getOfferingSpecifications(){
    //     Test.startTest();
    //    //Create account
    //     Account testAccount = new Account();
    //     testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
    //     testAccount.Name = 'Test Account 19-Jun-19';       
    //     testAccount.Core_Account_Country__c='India';
    //     testAccount.Core_Sales_Group_New__c='US Sales Group';
    //     testAccount.Core_Account_Type__c='ODM';
    //     testAccount.BillingStreet='Bangalore Central';
    //     testAccount.BillingCity='Bangalore';
    //     testAccount.BillingCountry='IND';
    //     testAccount.BillingState='KA';
    //     testAccount.BillingPostalCode='560029';
    //     testAccount.Industry='Agriculture';
    //     insert testAccount;
        
    //      PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
    //                                                      PMP_Account_Id__c=testAccount.Id);
    //     PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',testCompany.Id,true,'Draft','');
    //     List<PMP_Partner_Offering_Specification__c> response = PMP_SpecificationController.getOfferingSpecifications(testOffering.Id);
        
    //     system.assertNotEquals(response,Null);
    //     Test.stopTest();
    // }
    
    // @isTest
    // static void specificationMapNullAncestorSpecification(){
    //   //Create account
    //     Account testAccount = new Account();
    //     testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
    //     testAccount.Name = 'Test Account 19-Jun-19';       
    //     testAccount.Core_Account_Country__c='India';
    //     testAccount.Core_Sales_Group_New__c='US Sales Group';
    //     testAccount.Core_Account_Type__c='ODM';
    //     testAccount.BillingStreet='Bangalore Central';
    //     testAccount.BillingCity='Bangalore';
    //     testAccount.BillingCountry='IND';
    //     testAccount.BillingState='KA';
    //     testAccount.BillingPostalCode='560029';
    //     testAccount.Industry='Agriculture';
    //     insert testAccount;
        
    //      PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
    //                                                      PMP_Account_Id__c=testAccount.Id);
        
    //     List<PMP_Specification__c> specificationList=new List<PMP_Specification__c>();
        
    //     List<PMP_Partner_Offering_Specification__c> listOfferSpec=new List<PMP_Partner_Offering_Specification__c>();
    //     List<PMP_Partner_Offering_Specification__c> listOfferSpec2=new List<PMP_Partner_Offering_Specification__c>();
    //     List<PMP_Partner_Offering_Specification__c> listOfferSpec3=new List<PMP_Partner_Offering_Specification__c>();
    //     PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',testCompany.Id,true,'Draft','');
    //     PMP_Specification__c Spec = new PMP_Specification__c();
    //     Spec.Name = 'Displays';
    //     Spec.PMP_Specification_Name__c = 'Displays';
    //     Spec.PMP_Partner_Product_Specification_Id__c = 'DisplaysLevel1';
    //     Spec.PMP_Product_Parent_Specification_Id__c='';
    //     Spec.PMP_Active_Ind__c=true;
    //     insert Spec;
    //     specificationList.add(Spec);
        
    //     PMP_Specification__c Spec2 = new PMP_Specification__c();
    //     Spec2.name = 'Aspect Ratio';
    //     Spec2.PMP_Specification_Name__c = 'Aspect Ratio';
    //     Spec2.PMP_Parent_Specification_Id__c=Spec.Id;
    //     Spec2.PMP_Product_Parent_Specification_Id__c='DisplaysLevel1';
    //     Spec2.PMP_Partner_Product_Specification_Id__c = 'NPP_Displays_AspectRatio';
    //     Spec2.PMP_Display_Type_Nm__c='Checkbox';
    //     Spec2.PMP_Mandatory_Offering_Category_Nm__c='TPS_27,TPS_224,IPA_TYPE_Sys_Tab';
    //     Spec2.PMP_Specification_Type_Nm__c='Other';
    //     specificationList.add(Spec2);
        
    //     PMP_Specification__c Spec3 = new PMP_Specification__c();
    //     Spec3.name = 'Display Size';
    //     Spec3.PMP_Specification_Name__c = 'Display Size';
    //     Spec3.PMP_Parent_Specification_Id__c=Spec2.Id;
    //     Spec3.PMP_Product_Parent_Specification_Id__c='NPP_Displays_AspectRatio';
    //     Spec3.PMP_Partner_Product_Specification_Id__c = 'NPP_Displays_DisplaySize';
    //     Spec3.PMP_Display_Type_Nm__c='Checkbox';
    //     Spec3.PMP_Mandatory_Offering_Category_Nm__c='Not minimum requirement. Optional';
    //     Spec3.PMP_Specification_Type_Nm__c='Other';
    //     insert Spec3;
    //     specificationList.add(Spec3);
        
        
        
        
    //     PMP_Specification__c Spec4 = new PMP_Specification__c();
    //     Spec4.name = 'Geographic Coverage';
    //     Spec4.PMP_Specification_Name__c = 'Geographic Coverage';
    //     //Spec4.PMP_Parent_Specification_Id__c=;
    //     Spec4.PMP_Partner_Product_Specification_Id__c='NPP_GeographicCoverage';
    //     //Spec4.PMP_Partner_Product_Specification_Id__c = '';
    //     Spec4.PMP_Display_Type_Nm__c='Checkbox';
    //     Spec4.PMP_Mandatory_Offering_Category_Nm__c='All. Must select at least one';
    //     Spec4.PMP_Specification_Type_Nm__c='Other';
    //     Spec4.PMP_Active_Ind__c=true;
    //     insert Spec4;
    //     specificationList.add(Spec4);
        
        
    //     PMP_Specification__c Spec5 = new PMP_Specification__c();
    //     Spec5.Name = 'Americas';
    //     Spec5.PMP_Specification_Name__c = 'Americas';
    //     Spec5.PMP_Parent_Specification_Id__c=Spec4.Id;
    //     Spec5.PMP_Product_Parent_Specification_Id__c='NPP_GeographicCoverage';
    //     Spec5.PMP_Partner_Product_Specification_Id__c = 'etm-1b8f55ddb38f4054b32794910f6975cc';
    //     Spec5.PMP_Display_Type_Nm__c='Checkbox';
    //     Spec5.PMP_Active_Ind__c=true;
    //     Spec5.PMP_Specification_Type_Nm__c='Geography';
    //     insert Spec5;
    //      specificationList.add(Spec5);
        
        
        
    //     PMP_Specification__c Spec6 = new PMP_Specification__c();
    //     Spec6.Name = 'Latin America Region';
    //     Spec6.PMP_Specification_Name__c = 'Latin America Region';
    //     Spec6.PMP_Parent_Specification_Id__c=Spec5.Id;
    //     Spec6.PMP_Product_Parent_Specification_Id__c='etm-1b8f55ddb38f4054b32794910f6975cc';
    //     Spec6.PMP_Partner_Product_Specification_Id__c = 'etm-9b800fefe4964aa28d176d4868425839';
    //     Spec6.PMP_Display_Type_Nm__c='Checkbox';
    //     Spec6.PMP_Active_Ind__c=true;
    //     Spec6.PMP_Specification_Type_Nm__c='Geography';
    //     insert Spec6;
    //      specificationList.add(Spec6);
         
         
        
        
        
    //     PMP_Specification__c Spec7 = new PMP_Specification__c();
    //     Spec7.Name = 'Processor';
    //     Spec7.PMP_Specification_Name__c = 'Processor';
    //     Spec7.PMP_Partner_Product_Specification_Id__c = 'Npp_Processor';
    //     Spec7.PMP_Product_Parent_Specification_Id__c='';
    //     Spec7.PMP_Active_Ind__c=true;
    //     insert Spec7;
        
    //     PMP_Specification__c Spec8 = new PMP_Specification__c();
    //     Spec8.Name = 'Processor Socketed';
    //     Spec8.PMP_Specification_Name__c = 'Processor Socketed';
    //     Spec8.PMP_Parent_Specification_Id__c=Spec7.Id;
    //     Spec8.PMP_Product_Parent_Specification_Id__c= 'Npp_Processor';
    //     Spec8.PMP_Partner_Product_Specification_Id__c = 'NPP_Processors_NoOfProcessors';
    //     Spec8.PMP_Display_Type_Nm__c='Text';
    //     Spec8.PMP_Active_Ind__c=true;
    //     Spec8.PMP_Specification_Type_Nm__c='Other';
    //     insert Spec8;
        
    //     PMP_Specification__c Spec9 = new PMP_Specification__c(); 
    //     Spec9.Name = 'Processor Lev2';
    //     Spec9.PMP_Specification_Name__c = 'Processor Lev2';
    //     Spec9.PMP_Parent_Specification_Id__c=Spec7.Id;
    //     Spec9.PMP_Product_Parent_Specification_Id__c= 'Npp_Processor';
    //     Spec9.PMP_Partner_Product_Specification_Id__c = 'Lev2Processor';
    //     Spec9.PMP_Display_Type_Nm__c='Checkbox';
    //     Spec9.PMP_Active_Ind__c=true;
    //     Spec9.PMP_Specification_Type_Nm__c='Other';
    //     insert Spec9;
        
    //     PMP_Specification__c Spec10 = new PMP_Specification__c(); 
    //     Spec10 .Name = 'Processor Lev3';
    //     Spec10 .PMP_Specification_Name__c = 'Processor Lev3';
    //     Spec10 .PMP_Parent_Specification_Id__c=Spec9.Id;
    //     Spec10 .PMP_Product_Parent_Specification_Id__c= 'Lev2Processor';
    //     Spec10 .PMP_Partner_Product_Specification_Id__c = 'Lev3Processor';
    //     Spec10 .PMP_Display_Type_Nm__c='Checkbox';
    //     Spec10 .PMP_Active_Ind__c=true;
    //     Spec10 .PMP_Specification_Type_Nm__c='Other';
    //     insert Spec10 ;
    //    Test.startTest();
    //     PMP_Specification_Value__c newSpecVal0=new PMP_Specification_Value__c();
    //     newSpecVal0.PMP_Partner_Off_Roadmap_Ind__c=True;
    //     newSpecVal0.Name='processorLev4';
    //     newSpecVal0.PMP_Product_Specification_Value_Cd__c='processorLev4';
    //     newSpecVal0.PMP_Specification_Value_Cd__c='processorLev4';
    //     newSpecVal0.PMP_Active_Ind__c=true;
    //     newSpecVal0.PMP_Display_Type_Nm__c='Checkbox';
    //     newSpecVal0.PMP_Spec_Value_Type_Nm__c='Other';
    //     insert newSpecVal0;
 
    //     List<PMP_Specification__c> aa=[Select Id,  PMP_Ancestor_Specification_Nm__c, PMP_Parent_Specification_Id__r.Name, PMP_Ancestor_Specification_Cd__c from PMP_Specification__c limit 10];
      
    //     PMP_Specification_Value__c newSpecVal=new PMP_Specification_Value__c();
    //     newSpecVal.PMP_Partner_Off_Roadmap_Ind__c=True;
    //     newSpecVal.Name='Windows Server';
    //     newSpecVal.PMP_Product_Specification_Value_Cd__c='Windows Server';
    //     newSpecVal.PMP_Specification_Value_Cd__c='Windows Server';
    //     newSpecVal.PMP_Active_Ind__c=true;
    //     newSpecVal.PMP_Display_Type_Nm__c='Checkbox';
    //     newSpecVal.PMP_Spec_Value_Type_Nm__c='Other';
    //     insert newSpecVal;
        
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec.Name=Spec.Name;
    //     newPMPOfferingSpec.PMP_Offering_Id__c=testOffering.Id;
    //     newPMPOfferingSpec.PMP_Ancestor_Specification_Cd__c=Spec.PMP_Ancestor_Specification_Cd__c;
    //     newPMPOfferingSpec.PMP_Specification_Nm__c=Spec.Name;
    //     //newPMPOfferingSpec.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
    //     newPMPOfferingSpec.PMP_Product_Specification_Cd__c= Spec.PMP_Partner_Product_Specification_Id__c;
    //     newPMPOfferingSpec.PMP_Display_Type_Nm__c='Checkbox';
    //     newPMPOfferingSpec.PMP_Specification_Id__c=Spec.Id;
    //     //newPMPOfferingSpec.PMP_Specification_Value_Id__c=newSpecVal.Id;
    //     listOfferSpec.add(newPMPOfferingSpec);
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec2=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec2.Name=Spec2.Name;
    //     newPMPOfferingSpec2.PMP_Offering_Id__c=testOffering.Id;
    //     newPMPOfferingSpec2.PMP_Ancestor_Specification_Cd__c='DisplaysLevel1';
    //     newPMPOfferingSpec2.PMP_Specification_Nm__c=Spec2.Name;
    //     //newPMPOfferingSpec2.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
    //     newPMPOfferingSpec2.PMP_Product_Specification_Cd__c= Spec2.PMP_Partner_Product_Specification_Id__c;
    //     newPMPOfferingSpec2.PMP_Display_Type_Nm__c='Checkbox';
    //     newPMPOfferingSpec2.PMP_Specification_Id__c=Spec2.Id;
    //     //newPMPOfferingSpec2.PMP_Specification_Value_Id__c=newSpecVal.Id;
    //     listOfferSpec.add(newPMPOfferingSpec2);
        
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec3=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec3.Name=Spec3.Name;
    //     newPMPOfferingSpec3.PMP_Offering_Id__c=testOffering.Id;
    //     newPMPOfferingSpec3.PMP_Ancestor_Specification_Cd__c='DisplaysLevel1|NPP_Displays_AspectRatio';
    //     newPMPOfferingSpec3.PMP_Specification_Nm__c=Spec3.Name;
    //     //newPMPOfferingSpec3.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
    //     newPMPOfferingSpec3.PMP_Product_Specification_Cd__c= Spec3.PMP_Partner_Product_Specification_Id__c;
    //     newPMPOfferingSpec3.PMP_Display_Type_Nm__c='Checkbox';
    //     newPMPOfferingSpec3.PMP_Specification_Id__c=Spec3.Id;
    //     //newPMPOfferingSpec3.PMP_Specification_Value_Id__c=newSpecVal.Id;
    //     listOfferSpec.add(newPMPOfferingSpec3);
       
        
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec4=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec4.Name=Spec4.Name;
    //     newPMPOfferingSpec4.PMP_Offering_Id__c=testOffering.Id;
    //     newPMPOfferingSpec4.PMP_Ancestor_Specification_Cd__c='';
    //     newPMPOfferingSpec4.PMP_Specification_Nm__c=Spec4.Name;
    //     newPMPOfferingSpec4.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
    //     newPMPOfferingSpec4.PMP_Product_Specification_Cd__c= Spec4.PMP_Partner_Product_Specification_Id__c;
    //     newPMPOfferingSpec4.PMP_Display_Type_Nm__c='Checkbox';
    //     newPMPOfferingSpec4.PMP_Specification_Id__c=Spec4.Id;
        
    //     listOfferSpec.add(newPMPOfferingSpec4);
       
  
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec5=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec5.Name=Spec5.Name;
    //     newPMPOfferingSpec5.PMP_Offering_Id__c=testOffering.Id;
    //     newPMPOfferingSpec5.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage';
    //     newPMPOfferingSpec5.PMP_Specification_Nm__c=Spec5.Name;
    //     //newPMPOfferingSpec5.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
    //     newPMPOfferingSpec5.PMP_Product_Specification_Cd__c= Spec5.PMP_Partner_Product_Specification_Id__c;
    //     newPMPOfferingSpec5.PMP_Display_Type_Nm__c='Checkbox';
    //     newPMPOfferingSpec5.PMP_Specification_Id__c=Spec5.Id;     
    //     //newPMPOfferingSpec5.PMP_Specification_Value_Id__c=newSpecVal.Id;
    //     listOfferSpec.add(newPMPOfferingSpec5);
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec6=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec6.Name=Spec6.Name;
    //     newPMPOfferingSpec6.PMP_Offering_Id__c=testOffering.Id;
    //     newPMPOfferingSpec6.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
    //     newPMPOfferingSpec6.PMP_Specification_Nm__c=Spec6.Name;
    //     newPMPOfferingSpec6.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
    //     newPMPOfferingSpec6.PMP_Product_Specification_Cd__c= Spec6.PMP_Partner_Product_Specification_Id__c;
    //     newPMPOfferingSpec6.PMP_Display_Type_Nm__c='Checkbox';
    //     newPMPOfferingSpec6.PMP_Specification_Id__c=Spec6.Id;   
    //     newPMPOfferingSpec6.PMP_Specification_Value_Id__c=newSpecVal.Id;
    //     listOfferSpec.add(newPMPOfferingSpec6);
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec7=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec7.Name=Spec8.Name;
    //     newPMPOfferingSpec7.PMP_Offering_Id__c=testOffering.Id;
    //     newPMPOfferingSpec7.PMP_Ancestor_Specification_Cd__c='Npp_Processor';
    //     newPMPOfferingSpec7.PMP_Specification_Nm__c=Spec8.Name;
    //     newPMPOfferingSpec7.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
    //     newPMPOfferingSpec7.PMP_Specification_Value_Cd__c = '5';
    //     newPMPOfferingSpec7.PMP_Product_Specification_Cd__c= Spec8.PMP_Partner_Product_Specification_Id__c;
    //     newPMPOfferingSpec7.PMP_Display_Type_Nm__c='Text';
    //     newPMPOfferingSpec7.PMP_Specification_Id__c=Spec8.Id;   
    //     //newPMPOfferingSpec7.PMP_Specification_Value_Id__c=newSpecVal.Id;
    //     listOfferSpec.add(newPMPOfferingSpec7);
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec8=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec8.Name=Spec9.Name;
    //     newPMPOfferingSpec8.PMP_Offering_Id__c=testOffering.Id;
    //     newPMPOfferingSpec8.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
    //     newPMPOfferingSpec8.PMP_Specification_Nm__c=Spec9.Name;
    //     newPMPOfferingSpec8.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
    //     newPMPOfferingSpec8.PMP_Product_Specification_Cd__c= Spec9.PMP_Partner_Product_Specification_Id__c;
    //     newPMPOfferingSpec8.PMP_Display_Type_Nm__c='Checkbox';
    //     newPMPOfferingSpec8.PMP_Specification_Id__c=Spec9.Id;   
    //     //newPMPOfferingSpec8.PMP_Specification_Value_Id__c=newSpecVal.Id;
    //     listOfferSpec.add(newPMPOfferingSpec8);
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec9=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec9.Name=Spec10.Name;
    //     newPMPOfferingSpec9.PMP_Offering_Id__c=testOffering.Id;
    //     newPMPOfferingSpec9.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
    //     newPMPOfferingSpec9.PMP_Specification_Nm__c=Spec10.Name;
    //     newPMPOfferingSpec9.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
    //     newPMPOfferingSpec9.PMP_Product_Specification_Cd__c= Spec10.PMP_Partner_Product_Specification_Id__c;
    //     newPMPOfferingSpec9.PMP_Display_Type_Nm__c='Checkbox';
    //     newPMPOfferingSpec9.PMP_Specification_Id__c=Spec10.Id;   
    //     //newPMPOfferingSpec9.PMP_Specification_Value_Id__c=newSpecVal.Id;
    //     listOfferSpec.add(newPMPOfferingSpec9);
        
    //     insert listOfferSpec;
        
        
    //     //system.debug('newPMPOfferingSpec5:'+newPMPOfferingSpec5);

    //     // requerying as formula field was resulting in less code coverage.
    //     List <PMP_Partner_Offering_Specification__c> offSpecNewList = [SELECT Name,PMP_Ancestor_Specification_Cd__c,PMP_Display_Type_Nm__c,PMP_Localized_Specification_Nm__c,
    //                                                                     PMP_Localized_Specification_Value_Nm__c,PMP_Offering_Id__c,PMP_Product_Specification_Cd__c,
    //                                                                     PMP_Specification_Id__c,PMP_Specification_Nm__c,PMP_Specification_Value_Cd__c,
    //                                                                     PMP_Specification_Value_Id__c,PMP_Specification_Value_Nm__c,PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
    //                                                                     PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,
    //                                                                      PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c,PMP_Specification_Id__r.PMP_Specification_Name__c,
    //                                                                      PMP_Specification_Id__r.PMP_Ancestor_Specification_nm__c
    //                                                                     FROM PMP_Partner_Offering_Specification__c Where PMP_Offering_Id__c =: testOffering.id];
    //     Map<string, List<string>> response = PMP_SpecificationController.getOfferingValuesAndSpecificationMap(offSpecNewList,'en_US' );
        
    //     system.assertNotEquals(response,Null);
    //     Test.stopTest();
    // }
    
   
   
    
   
}