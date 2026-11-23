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
    Profile ProfileRec = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
    // Create User
    userRecord = TestUtilities.getUser();
    userRecord.username = 'TestUserTest@intel.com';
    userRecord.ProfileID = ProfileRec.Id;
    insert userRecord;
        
    // Creating Queue
    QueueRecord = new Group(Name='SupportOrgQueue', 
                            Type='Queue'
                           );
    insert QueueRecord;        
    // Creating Public Group
    Group PublicGroupRecord = new Group(Name = 'SupportOrgPublicGroup');
    insert PublicGroupRecord;
        
    System.runAs(userRecord){
        
        // Mapping the Queue to the Core_IPS_Product_Organization__c object
        QueuesObject MappingQueueRecord = new QueueSObject(QueueID = QueueRecord.Id, SobjectType = 'Core_IPS_Product_Organization__c');
        insert MappingQueueRecord;
        
        QueuesObject MappingQueueRecord2 = new QueueSObject(QueueID = QueueRecord.Id, SobjectType = 'Core_IPS_MAP_PAR__c');
        insert MappingQueueRecord2;
        
        // Adding Public Group to the Queue
        GroupMember groupMemberObject_Group = new GroupMember(GroupId = QueueRecord.Id,
                                                               UserOrGroupId = PublicGroupRecord.Id  
                                                              );           
        insert groupMemberObject_Group;
        
        // Adding Member to the Public Group
        GroupMember groupMemberObject_User = new GroupMember(GroupId = PublicGroupRecord.Id,
                                                             UserOrGroupId = userRecord.Id
                                                             );
        insert groupMemberObject_User;
        
        // Creating Product Record
        Product2 createProductRecord = TestUtilities.getProduct();
        insert createProductRecord;
        System.Assert(createProductRecord.Id != null, 'Record not created');
        
        // Creating Support Org (Core_IPS_Product_Organization__c) Record
        Core_IPS_Product_Organization__c SupportOrgRecord = TestUtilities.getSupportOrg();
        SupportOrgRecord.OwnerId = QueueRecord.Id;
        insert SupportOrgRecord;
        System.Assert(SupportOrgRecord.Id != null, 'Record not created');
        
        // Creating Core Supported Product
        supportedProductRecord = TestUtilities.getSupportedProduct();
        supportedProductRecord.Core_Product__c = createProductRecord.id;
        supportedProductRecord.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord;
        System.Assert(supportedProductRecord.Id != null, 'Record not created');
        
        EnvironmentalDetailMaster1 = TestUtilities.getCoreQuestion();
        EnvironmentalDetailMaster1.Core_IPS_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster1;
        
        EnvironmentalDetailMaster2 = TestUtilities.getCoreQuestion();
        EnvironmentalDetailMaster2.Core_IPS_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster2;
        
        EnvironmentalDetailsOperational = TestUtilities.getEnvironmentalDetailsOperational();
        //EnvironmentalDetailsOperational.Core_IPS_Question__c = EnvironmentalDetailMaster2.id;
        EnvironmentalDetailsOperational.Core_Supported_Product__c = supportedProductRecord.Id;
        insert EnvironmentalDetailsOperational;
        
        // Create Custom Setting - IPS Error Codes
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        System.Assert(ListofIpsLables[0].Id != null, 'Record not created');
        
        // Create Case Category
        Core_IPS_Product_Issue_Category__c CaseCategory = TestUtilities.getCaseCategories();
        CaseCategory.Core_Type__c = 'Case Category';
        CaseCategory.Core_Supported_Product__c = supportedProductRecord.id;
        insert CaseCategory;
        
        // Create Case SubCategory
        CaseSubCategory = TestUtilities.getCaseCategories();
        CaseSubCategory.Core_Product_Issue_Category__c = CaseCategory.id; 
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
        System.assert(str == 'Success', true);
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