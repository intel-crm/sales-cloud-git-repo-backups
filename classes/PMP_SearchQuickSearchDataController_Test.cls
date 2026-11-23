@isTest
private class PMP_SearchQuickSearchDataController_Test extends PMP_SearchWrapperStore {
	
 
    
    /* @isTest static void testGetPartnerOptions(){
        
        QuickSearchFilter testPartnerFilter = new QuickSearchFilter();
        List<PMP_SearchPartnerProgram_Config__mdt> partner_progs = [SELECT Label,PMP_Partner_Program_Name__c,Active__c,  PMP_Partner_Program_value__c FROM PMP_SearchPartnerProgram_Config__mdt
                                                                    WHERE Active__c = true ORDER BY PMP_Partner_Program_Name__c ];
        
        testPartnerFilter.label = partner_progs[0].Label;
        testPartnerFilter.value = partner_progs[0].Label + '_Partner';
        List<QuickSearchFilterOption> ppOptionWrapper = new List<QuickSearchFilterOption>();
        for(PMP_SearchPartnerProgram_Config__mdt pp : partner_progs){  	
            QuickSearchFilterOption ppM = new QuickSearchFilterOption();
            ppM.label = pp.PMP_Partner_Program_Name__c;
            ppM.value = pp.PMP_Partner_Program_Value__c;
            ppOptionWrapper.add(ppM);
        }
        testPartnerFilter.options = ppOptionWrapper;  
        
        system.assertEquals(testPartnerFilter.options.size(), PMP_SearchQuickSearchDataController.getPartnerOptions().options.size());      
        
    }
    
    @isTest static void testGetPartnerRegionOptions(){
        QuickSearchFilter testPartnerRegionFilter = new QuickSearchFilter();
                
              
        Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Region__c.getDescribe();      
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<QuickSearchFilterOption> options = new List<QuickSearchFilterOption>();
        for( Schema.PicklistEntry pickListVal : ple){
            QuickSearchFilterOption option = new QuickSearchFilterOption();
            option.label = pickListVal.getLabel();
            option.value = pickListVal.getLabel();
            options.add(option);
        }
        testPartnerRegionFilter.options = options;
        testPartnerRegionFilter.label=fieldResult.getLabel();
        testPartnerRegionFilter.value = fieldResult.getLabel()+'_Partner';
        
        system.assertEquals(testPartnerRegionFilter.options.size(), PMP_SearchQuickSearchDataController.getPartnerRegionOptions().options.size()); 
        
    }
    
    @isTest static void testGetPartnerIndustryOptions(){
        QuickSearchFilter testPartnerIndustryFilter = new QuickSearchFilter();
                      
               
        Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Industry__c.getDescribe();      
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<QuickSearchFilterOption> options = new List<QuickSearchFilterOption>();
        for( Schema.PicklistEntry pickListVal : ple){
            QuickSearchFilterOption option = new QuickSearchFilterOption();
            option.label = pickListVal.getLabel();
            option.value = pickListVal.getLabel();
            options.add(option);
        }
        testPartnerIndustryFilter.options = options;
        testPartnerIndustryFilter.label=fieldResult.getLabel();
        testPartnerIndustryFilter.value = fieldResult.getLabel()+'_Partner';
        
        system.assertEquals(testPartnerIndustryFilter.options.size(), PMP_SearchQuickSearchDataController.getPartnerIndustryOptions().options.size());
    }
    
    @isTest static void testGetPartnerApplicationOptions(){
       
        PMP_Category__c newTestCategory = PMP_TestDataUtility.getCategory('testCategory','NPP_01_TC' , 'NPP Taxonomy', 'en_us');        
        PMP_Category__c testCategoryChild1 = PMP_TestDataUtility.getCategory('testCategoryChild1','NPP_01_TCchild1' , 'NPP_01_TC', 'en_us');        
        PMP_Category__c testCategoryChild2 = PMP_TestDataUtility.getCategory('testCategoryChild2','NPP_01_TCchild2' , 'NPP_01_TC', 'en_us');        
        PMP_Category__c testCategoryChild3 = PMP_TestDataUtility.getCategory('testCategoryChild3','NPP_01_TCchild3' , 'NPP_01_TC', 'en_us');
        PMP_Category__c testCategoryChild4 = PMP_TestDataUtility.getCategory('testCategoryChild4','NPP_01_TCchild4' , 'NPP_01_TC', 'en_us');
        
        system.assertEquals( 4 , PMP_SearchQuickSearchDataController.getPartnerApplicationOptions('NPP_01_TC').options.size());
    
    }
    
     @isTest static void testGetCategoryOptions(){
         
      	PMP_Category__c newTestCategory = PMP_TestDataUtility.getCategory('testCategory','NPP_01_TC' , 'NPP Taxonomy', 'en_us');        
        PMP_Category__c testCategoryChild1 = PMP_TestDataUtility.getCategory('testCategoryChild1','NPP_01_TCchild1' , 'NPP_01_TC', 'en_us');        
        PMP_Category__c testCategoryChild2 = PMP_TestDataUtility.getCategory('testCategoryChild2','NPP_01_TCchild2' , 'NPP_01_TC', 'en_us');        
        PMP_Category__c testCategoryChild3 = PMP_TestDataUtility.getCategory('testCategoryChild3','NPP_01_TCchild3' , 'NPP_01_TC', 'en_us');
        PMP_Category__c testCategoryChild4 = PMP_TestDataUtility.getCategory('testCategoryChild4','NPP_01_TCchild4' , 'NPP_01_TC', 'en_us');
        
        system.assertEquals( 4 , PMP_SearchQuickSearchDataController.getCategoryOptions('NPP_01_TC').options.size());
    }
    
    
    @isTest static void testGetSearchFilterDataProduct(){
        
        Integer noOfFilters = 4;
        PMP_Category__c newTestCategory = PMP_TestDataUtility.getCategory('Application','NPP_01_APP' , 'NPP Taxonomy', 'en_us');  
        PMP_Category__c newTestCategory1 = PMP_TestDataUtility.getCategory('Industry','NPP_01_Industry' , 'NPP Taxonomy', 'en_us');
         
        PMP_Specification__c Spec = new PMP_Specification__c();
        Spec.name = 'Geographical Coverage';
        Spec.PMP_Product_Parent_Specification_Id__c = 'NPP_GeographicCoverage';
        insert spec;
        
        system.assertEquals(noOfFilters, PMP_SearchQuickSearchDataController.getSearchFilterData('Product').size());
        
    }
    
    @isTest static void testGetSearchFilterDataPartner(){
        
        Integer noOfFilters = 4;
        PMP_Category__c newTestCategory = PMP_TestDataUtility.getCategory('Application','NPP_01_APP' , 'NPP Taxonomy', 'en_us');  
        PMP_Category__c newTestCategory1 = PMP_TestDataUtility.getCategory('Industry','NPP_01_Industry' , 'NPP Taxonomy', 'en_us');
         
        PMP_Specification__c Spec = new PMP_Specification__c();
        Spec.name = 'Geographical Coverage';
        Spec.PMP_Product_Parent_Specification_Id__c = 'NPP_GeographicCoverage';
        insert spec;
        system.assertEquals(noOfFilters, PMP_SearchQuickSearchDataController.getSearchFilterData('Partner').size());
        
    }
    
    
    @isTest static void testGetProductRegionOptions(){
               
        
    } */
    
    @testSetup static void testDataFactory(){
        PMP_Specification__c specification=new PMP_Specification__c();
        specification.Name='Test';
        specification.PMP_Specification_Chinese_Nm__c='Test';
        specification.PMP_Specification_Japanese_Nm__c='Test';
        specification.PMP_Partner_Product_Specification_Id__c='NPP_GeographicCoverage';
        insert specification;
        
        /*PMP_Category__c category=new PMP_Category__c();
        category.Name='Test1';
        category.PMP_Category_Chinese_Nm__c='Test1';
        category.PMP_Category_Japanese_Nm__c='Test1';
        category.PMP_Partner_Product_Category_Cd__c='NPP_01_Industry';
        insert category;
        
        PMP_Category__c category1=new PMP_Category__c();
        category1.Name='Test2';
        category1.PMP_Category_Chinese_Nm__c='Test2';
        category1.PMP_Category_Japanese_Nm__c='Test2';
        category1.PMP_Partner_Product_Category_Cd__c='NPP_01_App';
        insert category1;*/
        
         User user = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
         System.runAs(user)   {
        	 user.LanguageLocaleKey = PMP_StaticConstants_Partner.ZH_CN;
        	 update user;
       
        	 user.LanguageLocaleKey = PMP_StaticConstants_Partner.JA;
        	 update user;
        }      
    }
    
     /*@isTest static void testGetCategoryOptions(){
         
      	PMP_Category__c newTestCategory = PMP_TestDataUtility.getCategory('testCategory','NPP_01_TC' , 'NPP Taxonomy', 'en_us');        
        PMP_Category__c testCategoryChild1 = PMP_TestDataUtility.getCategory('testCategoryChild1','NPP_01_TCchild1' , 'NPP_01_TC', 'en_us');        
        PMP_Category__c testCategoryChild2 = PMP_TestDataUtility.getCategory('testCategoryChild2','NPP_01_TCchild2' , 'NPP_01_TC', 'en_us');        
        PMP_Category__c testCategoryChild3 = PMP_TestDataUtility.getCategory('testCategoryChild3','NPP_01_TCchild3' , 'NPP_01_TC', 'en_us');
        PMP_Category__c testCategoryChild4 = PMP_TestDataUtility.getCategory('testCategoryChild4','NPP_01_TCchild4' , 'NPP_01_TC', 'en_us');
        
        //system.assertEquals( 4 , PMP_SearchQuickSearchDataController.getCategoryOptions('NPP_01_TC').options.size());
    }*/
    
    @isTest static void testGetCategoryOptionsForPIMIndustry(){
        PMP_Category__c newTestCategory1 = PMP_TestDataUtility.getCategory('Industry','NPP_01_Industry' , 'NPP Taxonomy', 'en_us');
        
        Test.startTest();
        Option result = PMP_SearchQuickSearchDataController.getCategoryOptions('NPP_01_Industry', 'en_US');
        System.assertNotEquals(null, result.value);
        Test.stopTest();
    }
    
     @isTest static void testGetCategoryOptionsForPIMApp(){
        PMP_Category__c newTestCategory = PMP_TestDataUtility.getCategory('Application','NPP_01_APP' , 'NPP Taxonomy', 'en_us');
        Test.startTest();
        Option result = PMP_SearchQuickSearchDataController.getCategoryOptions('NPP_01_App','en_US');
         System.assertNotEquals(null, result.value);
        Test.stopTest();
    }
    
    @isTest static void testGetCategoryOptionsForPIMCategory(){
        PMP_Category__c newTestCategory1 = PMP_TestDataUtility.getCategory('Component','NPP_01_Type' , 'TPS_900002', 'en_us');
        Test.startTest();
        Option result = PMP_SearchQuickSearchDataController.getCategoryOptions('NPP_01_Type','en_US');
        System.assertNotEquals(null, result.value);
        Test.stopTest();
    }
    
    @isTest static void testGetSearchFilterDataForProduct(){
         Test.startTest();
        Integer noOfFilters = 4;
        PMP_Category__c newTestCategory = PMP_TestDataUtility.getCategory('Application','NPP_01_APP' , 'NPP Taxonomy', 'en_us');  
        PMP_Category__c newTestCategory1 = PMP_TestDataUtility.getCategory('Industry','NPP_01_Industry' , 'NPP Taxonomy', 'en_us');
         
        PMP_Specification__c Spec = new PMP_Specification__c();
        Spec.name = 'Geographical Coverage';
        Spec.PMP_Product_Parent_Specification_Id__c = 'NPP_GeographicCoverage';
        insert spec;
       
        PMP_SearchQuickSearchDataController.getSearchFilterData('Product','en_US');
        system.assertEquals(noOfFilters, PMP_SearchQuickSearchDataController.getSearchFilterData('Product','en_US').size());
        Test.stopTest();
    }
    
    @isTest static void testGetSearchFilterDataForPartner(){
        Integer noOfFilters = 4;
        PMP_Category__c newTestCategory = PMP_TestDataUtility.getCategory('Application','NPP_01_APP' , 'NPP Taxonomy', 'en_us');  
        PMP_Category__c newTestCategory1 = PMP_TestDataUtility.getCategory('Industry','NPP_01_Industry' , 'NPP Taxonomy', 'en_us');
         
        PMP_Specification__c Spec = new PMP_Specification__c();
        Spec.name = 'Geographical Coverage';
        Spec.PMP_Product_Parent_Specification_Id__c = 'NPP_GeographicCoverage';
        insert spec;
        Test.startTest();
        PMP_SearchQuickSearchDataController.getSearchFilterData('Partner', 'en_US');
        system.assertEquals(noOfFilters, PMP_SearchQuickSearchDataController.getSearchFilterData('Partner', 'en_US').size());
        Test.stopTest();
    }
    
    @isTest static void testGetRegionOptionsForProduct(){
        Test.startTest();
        Option result = PMP_SearchQuickSearchDataController.getRegionOptions('', 'Product', 'en_US');
        System.assert(!result.options.isEmpty());
        Test.stopTest();
    }
  
    
    @isTest static void testGetRegionOptionsForPartner(){
        Test.startTest();
        Option result = PMP_SearchQuickSearchDataController.getRegionOptions('', 'Partner', 'en_US');
        System.assert(!result.options.isEmpty());
        Test.stopTest();
    }
    
    @isTest static void testGetPartnerOptions(){
        User user = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
         System.runAs(user)   {
        	 user.LanguageLocaleKey = 'nl_NL';
        	 update user;
       
        } 
        Test.startTest();
        PMP_SearchQuickSearchDataController.getSearchFilterData('Partner','en_US');
        //system.assertEquals(noOfFilters, PMP_SearchQuickSearchDataController.getSearchFilterData('Partner').size());
        Test.stopTest();
        
    }
    
}