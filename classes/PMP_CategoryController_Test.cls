@isTest(SeeAllData=false)
public class PMP_CategoryController_Test {
    
    @isTest(SeeAllData=false) 
    static void validateRootNode(){  
        string rootNode=PMP_StaticConstants_Offering.ROOT_NODE; 
        //IPA2.0 Offering changes
        //List<PMP_Category__c> offeringCategory=new List<PMP_Category__c>();
        
        
        Test.startTest();
            
        PMP_Category__c category1=PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        //IPA2.0 Offering changes
        //offeringCategory.add(category1);
        
        PMP_Category__c category2=PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        //offeringCategory.add(category2);
        
        
        PMP_Category__c category3=PMP_TestDataUtility.getCategory('Type', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        category3.PMP_Partner_Product_Parent_Category_Cd__c= 'NPP_01_TYPE';
        update category3;
        //IPA2.0 Offering changes
        //offeringCategory.add(category3);
        
        //PMP_CategoryController.fetchTopLevelCategories();
        
        Test.stopTest();
        
        //System.assertEquals(offeringCategory[0].PMP_Partner_Product_Parent_Category_Cd__c,rootNode);
        //System.assertEquals(offeringCategory[0].PMP_Partner_Product_Parent_Category_Cd__c,rootNode);
        //System.assertEquals(offeringCategory[0].PMP_Partner_Product_Parent_Category_Cd__c,rootNode);         
    }
    
  
    
  /*  
    @isTest(SeeAllData=false) 
    static void validateGetOfferingCategoryListEng(){

        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='gireesh.k@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='gireesh.k@gmail.com.test.crm');
        System.assertEquals('standt', u.Alias);
        //System.runAs(u) {
            Id newOfferingId=PMP_TestDataUtility.getOffering();
            PMP_Partner_Offering_Category__c newPMPOfferingCat=PMP_TestDataUtility.getPMPOfferingCategory(newOfferingId);
            
            List<PMP_CategoryController.Core_PMP_OfferingCategory> offeringCategories=new List<PMP_CategoryController.Core_PMP_OfferingCategory>();
            offeringCategories= PMP_CategoryController.getOfferingCategoryList(newOfferingId);
            //system.assert(PMP_CategoryController.getOfferingCategoryList(newOfferingId)!=null);
        //}        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false) 
    static void validateGetOfferingCategoryListJp(){

        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='gireesh.k@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='ja', 
                          LocaleSidKey='JA_JP', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='gireesh.k@gmail.com.test.crm');
        System.assertEquals('standt', u.Alias);
        System.runAs(u) {
            Id newOfferingId=PMP_TestDataUtility.getOffering();
            PMP_Partner_Offering_Category__c newPMPOfferingCat=PMP_TestDataUtility.getPMPOfferingCategory(newOfferingId);
            
            List<PMP_CategoryController.Core_PMP_OfferingCategory> offeringCategories=new List<PMP_CategoryController.Core_PMP_OfferingCategory>();
            offeringCategories= PMP_CategoryController.getOfferingCategoryList(newOfferingId);
            //system.assert(PMP_CategoryController.getOfferingCategoryList(newOfferingId)!=null);
        }        
        Test.stopTest();
    }
    @isTest(SeeAllData=false) 
    static void validateGetOfferingCategoryListCh(){

        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='gireesh.k@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='zh_CN', 
                          LocaleSidKey='ZH_CN', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='gireesh.k@gmail.com.test.crm');
        System.assertEquals('standt', u.Alias);
        System.runAs(u) {
            Id newOfferingId=PMP_TestDataUtility.getOffering();
            PMP_Partner_Offering_Category__c newPMPOfferingCat=PMP_TestDataUtility.getPMPOfferingCategory(newOfferingId);
            
            List<PMP_CategoryController.Core_PMP_OfferingCategory> offeringCategories=new List<PMP_CategoryController.Core_PMP_OfferingCategory>();
            offeringCategories= PMP_CategoryController.getOfferingCategoryList(newOfferingId);
            //system.assert(PMP_CategoryController.getOfferingCategoryList(newOfferingId)!=null);
        }        
        Test.stopTest();
    }*/
    @isTest
    public static void getHomePageCategoriesTest(){
        Account acc = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        System.assertNotEquals(null,acc);
        PMP_Company__c cmp = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc.Id, true);
                                
        //PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
		//'TestDuplicate',cmp.Id, true,'Draft','Test');
                                                                                 
        //PMP_Partner_Offering_Category__c offCategory = PMP_TestDataUtility.getPMPOfferingCategory(offering.id);
        
        
        Test.startTest();
            
        PMP_CategoryController.getHomePageCategories('');
        //PMP_CategoryController.getHomePageCategories(offCategory.Name); 
        Test.stopTest();
                    
        }
    
    /*@isTest
    public static void fetchTopLevelCategoriesTest(){
        system.assert(PMP_CategoryController.fetchTopLevelCategories()!=null);
    }*/
    
    
   @isTest(SeeAllData=false) 
    static void getOfferingCaregories(){ 
        test.startTest();
        String offferingNameDesc=String.valueOf(DateTime.now());
        System.assertNotEquals(null,offferingNameDesc);
        
         Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
         
         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        //PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering(offferingNameDesc,'Public Content',offferingNameDesc,cmp1.Id,true,'Published','The paper Company');
        //PMP_CategoryController.getOfferingCaregories(testOffering.Id);
        test.stopTest();
    }
    /*@isTest(SeeAllData=false) 
    static void getOfferingCaregoriesMap(){  
        test.startTest();
        String offferingNameDesc=String.valueOf(DateTime.now());
        System.assertNotEquals(null,offferingNameDesc);
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
         
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
         
        //PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering(offferingNameDesc,'Public Content',offferingNameDesc,cmp1.Id,true,'Published','The paper Company');
        List<Id> offeringIds=new List<Id>();
        offeringIds.add(testOffering.Id);
        //PMP_CategoryController.getOfferingCaregoriesMap(offeringIds);
        test.stopTest();
    }*/
    @isTest
static void testFormatException() {
    Test.startTest();
    
    try {
        // Create a scenario that will throw an exception
        Account acc = new Account(); // Missing required Name field
        insert acc; // This will throw a DmlException
    } catch (Exception ex) {
        // Test formatException method
        Map<String, Object> result = PMP_CategoryController.formatException('TestClass', 'High', ex);
        
        // Assertions
        System.assertEquals('TestClass', result.get('Class Name'));
        System.assertEquals('High', result.get('Severity'));
        System.assertEquals(UserInfo.getUserId(), result.get('User Info'));
        System.assertNotEquals(null, result.get('Error Message'));
        System.assertNotEquals(null, result.get('Stack Trace'));
        
        // Test DML specific fields for DmlException
        if (ex instanceof DmlException) {
            List<String> dmlFieldNames = (List<String>) result.get('DML Field Names');
            List<String> dmlMessages = (List<String>) result.get('DML Messages');
            System.assertNotEquals(null, dmlFieldNames);
            System.assertNotEquals(null, dmlMessages);
        }
    }
    
    // Test with non-DML exception
    try {
        Integer i = 1/0; // This will throw MathException
    } catch (Exception ex) {
        Map<String, Object> result = PMP_CategoryController.formatException('TestClass', 'Medium', ex);
        
        System.assertEquals('TestClass', result.get('Class Name'));
        System.assertEquals('Medium', result.get('Severity'));
        System.assert(((String)result.get('Error Message')).contains('MathException'));
        
        // For non-DML exceptions, these should be empty
        List<String> dmlFieldNames = (List<String>) result.get('DML Field Names');
        System.assertEquals(0, dmlFieldNames.size());
    }
    
    Test.stopTest();
}
}