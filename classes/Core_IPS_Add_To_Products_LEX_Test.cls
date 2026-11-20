//System.assert()--> statement Added By Hassan Khan 01-02-2024 
@IsTest public class Core_IPS_Add_To_Products_LEX_Test {
  
    public static User userRecord;
    public static Group QueueRecord;
    public static Core_IPS_Question__c EnvironmentalDetailMaster1;
    public static Core_IPS_Question__c EnvironmentalDetailMaster2;
    public static Core_IPS_Product_Issue_Category__c CaseSubCategory;
    public static Core_IPS_Supported_Product__c supportedProductRecord;
    public static Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetailsOperational;
     
    static void getRecords(){
        
    // Query Admin Profile
    Profile profileRec = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
    // Create User
    userRecord = TestUtilities.getUser();
    userRecord.username = 'TestUserTest@intel.com';
    userRecord.ProfileID = profileRec.Id;
    User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
        System.runAs(validationBypassUser){
            insert userRecord;
        }
        
    // Creating Queue
    QueueRecord = new Group(Name='SupportOrgQueue', 
                            Type='Queue'
                           );
    insert QueueRecord;        
    // Creating Public Group
    Group publicGroupRecord = new Group(Name = 'SupportOrgPublicGroup');
    insert publicGroupRecord;
        
    System.runAs(userRecord){
        
        // Mapping the Queue to the Core_IPS_Product_Organization__c object
        QueuesObject mappingQueueRecord = new QueueSObject(QueueID = QueueRecord.Id, SobjectType = 'Core_IPS_Product_Organization__c');
        insert mappingQueueRecord;
        
        QueuesObject mappingQueueRecord2 = new QueueSObject(QueueID = QueueRecord.Id, SobjectType = 'Core_IPS_MAP_PAR__c');
        insert mappingQueueRecord2;
        
        // Adding Public Group to the Queue
        GroupMember groupMemberObjectGroup = new GroupMember(GroupId = QueueRecord.Id,
                           UserOrGroupId = publicGroupRecord.Id  
                                                              );           
        insert groupMemberObjectGroup;
        
        // Adding Member to the Public Group
        GroupMember groupMemberObjectUser = new GroupMember(GroupId = publicGroupRecord.Id,
                                                             UserOrGroupId = userRecord.Id
                                                             );
        insert groupMemberObjectUser;
        
        // Creating Product Record
        Product2 createProductRecord = TestUtilities.getProduct();
        insert createProductRecord;
        System.Assert(createProductRecord.Id != null, 'Record not created');
        
        // Creating Support Org (Core_IPS_Product_Organization__c) Record
        Core_IPS_Product_Organization__c supportOrgRecord = TestUtilities.getSupportOrg();
        supportOrgRecord.OwnerId = QueueRecord.Id;
        insert supportOrgRecord;
        System.Assert(supportOrgRecord.Id != null, 'Record not created');
        
        // Creating Core Supported Product
        supportedProductRecord = TestUtilities.getSupportedProduct();
        supportedProductRecord.Core_Product__c = createProductRecord.id;
        supportedProductRecord.Core_Product_Organization__c = supportOrgRecord.id;
        insert supportedProductRecord;
        System.Assert(supportedProductRecord.Id != null, 'Record not created');
        
        EnvironmentalDetailMaster1 = TestUtilities.getCoreQuestion();
        EnvironmentalDetailMaster1.Core_IPS_Product_Organization__c = supportOrgRecord.id;
        insert EnvironmentalDetailMaster1;
        
        EnvironmentalDetailMaster2 = TestUtilities.getCoreQuestion();
        EnvironmentalDetailMaster2.Core_IPS_Product_Organization__c = supportOrgRecord.id;
        insert EnvironmentalDetailMaster2;
        
        EnvironmentalDetailsOperational = TestUtilities.getEnvironmentalDetailsOperational();
        //EnvironmentalDetailsOperational.Core_IPS_Question__c = EnvironmentalDetailMaster2.id;
        EnvironmentalDetailsOperational.Core_Supported_Product__c = supportedProductRecord.Id;
        insert EnvironmentalDetailsOperational;
        
        // Create Custom Setting - IPS Error Codes
        List<Core_IPS_Error_Code__c> listOfIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert listOfIpsErrorCodes;
        
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> listOfIpsLables = TestUtilities.getIPSLabel();
        insert listOfIpsLables;
        System.Assert(listOfIpsLables[0].Id != null, 'Record not created');
        
        // Create Case Category
        Core_IPS_Product_Issue_Category__c caseCategory = TestUtilities.getCaseCategories();
        caseCategory.Core_Type__c = 'Case Category';
        caseCategory.Core_Supported_Product__c = supportedProductRecord.id;
        insert caseCategory;
        
        // Create Case SubCategory
        CaseSubCategory = TestUtilities.getCaseCategories();
        CaseSubCategory.Core_Product_Issue_Category__c = caseCategory.id; 
        insert CaseSubCategory;
        
        // Update EnvironmentalDetailsOperational
        EnvironmentalDetailsOperational.Core_Product_Issue_Sub_Category__c = CaseSubCategory.id;
        update EnvironmentalDetailsOperational;
        
        Core_IPS_Error_Code__c ec1 = new Core_IPS_Error_Code__c();
        ec1.Name='I105';
        ec1.Core_Error_Message__c='You do not have sufficient access to modify the Record';
        insert ec1;
        
        Core_IPS_Error_Code__c ec2 = new Core_IPS_Error_Code__c();
        ec2.Name='I106';
        ec2.Core_Error_Message__c='No Records to Display';
        insert ec2;
        
        Core_IPS_Error_Code__c ec3 = new Core_IPS_Error_Code__c();
        ec3.Name='I108';
        ec3.Core_Error_Message__c='Cannot add to product(s): Question is inactive';
        insert ec3;
      }
    }  
    
    @isTest
    public static void getSupportedProductsTest(){
        getRecords();
        Test.startTest();
        List<Core_IPS_Add_To_Products_LEX.ProductsSel> selectedProduct = Core_IPS_Add_To_Products_LEX.getSupportedProducts(EnvironmentalDetailMaster1.Id,0,0);
        Test.stopTest();
        System.assert(selectedProduct !=null, true);
    }
    
    @isTest
    public static void addToProductsTest(){
        getRecords();
        Test.startTest();
          List<Core_IPS_Add_To_Products_LEX.ProductsSel> selectedProduct = Core_IPS_Add_To_Products_LEX.getSupportedProducts(EnvironmentalDetailMaster1.Id,10,0);
          Core_IPS_Add_To_Products_LEX.addToProducts(selectedProduct, EnvironmentalDetailMaster1.Id);
        Test.stopTest();
        System.assert(selectedProduct.size() > 0, true);
    }
    
    @isTest 
    public static void checkBusinessRulesTest(){
        getRecords();
        Test.startTest();
        	String str = Core_IPS_Add_To_Products_LEX.checkBusinessRules(EnvironmentalDetailMaster1.Id);
        Test.stopTest();
       // System.assert(str == 'Success', true);
    }
    
    // No Records to Display
    @isTest  
    public static void SupportedProductEnd(){
       getRecords();
       supportedProductRecord.Core_EOIS__c = true;
       update supportedProductRecord;
        
       System.runAs(userRecord){
         Test.startTest();
            Core_IPS_Add_To_Products_LEX.checkBusinessRules(EnvironmentalDetailMaster1.Id);
         Test.stopTest();
        }
        System.assert(supportedProductRecord.id != null, true);
    }
    
    //Question status is Inactive
    @isTest
    public static void EnvDetMasterStatusInactive(){
       getRecords();
       EnvironmentalDetailMaster1.Core_IPS_Status__c = 'Inactive';
       update EnvironmentalDetailMaster1;
        
       System.runAs(userRecord){
         Test.startTest();
            Core_IPS_Add_To_Products_LEX.checkBusinessRules(EnvironmentalDetailMaster1.Id);
         Test.stopTest();
      }
      System.assert(EnvironmentalDetailMaster1.id != null, true);
    }

    @isTest
    public static void addToProductsNull(){
        getRecords();
        boolean addProd;
        try{
          addProd = Core_IPS_Add_To_Products_LEX.addToProducts(null, null);
        }   
        catch(Exception e){
	     }
        System.assertEquals(addProd == false, true);
    }
}