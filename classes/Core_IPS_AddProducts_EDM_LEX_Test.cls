@IsTest 
public class Core_IPS_AddProducts_EDM_LEX_Test {
 
    public static User userRecord;
    public static Group QueueRecord;
    public static Core_IPS_Question__c EnvironmentalDetailMaster1;
    public static Core_IPS_Environment_Variables__c EnvironmentalDetailMaster;
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
    System.debug('---QUEUE---'+QueueRecord);
        
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
        system.debug('groupMemberObject_User--');
        
        // Creating Product Record
        Product2 createProductRecord = TestUtilities.getProduct();
        insert createProductRecord;
        system.debug('createProductRecord--');
        System.Assert(createProductRecord.Id != null, 'Record not created');
        
        // Creating Support Org (Core_IPS_Product_Organization__c) Record
        Core_IPS_Product_Organization__c SupportOrgRecord = TestUtilities.getSupportOrg();
        SupportOrgRecord.OwnerId = QueueRecord.Id;
        insert SupportOrgRecord;
        system.debug('SupportOrgRecord--'+SupportOrgRecord);
        System.Assert(SupportOrgRecord.Id != null, 'Record not created');
        
        // Creating Core Supported Product
        supportedProductRecord = TestUtilities.getSupportedProduct();
        supportedProductRecord.Core_Product__c = createProductRecord.id;
        supportedProductRecord.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord;
        system.debug('supportedProductRecord--'+supportedProductRecord);
        System.Assert(supportedProductRecord.Id != null, 'Record not created');
        
        EnvironmentalDetailMaster1 = TestUtilities.getCoreQuestion();
        EnvironmentalDetailMaster1.Core_IPS_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster1;
        
        Core_IPS_Question__c EnvironmentalDetailMaster2 = TestUtilities.getCoreQuestion();
        EnvironmentalDetailMaster2.Core_IPS_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster2;
        
        EnvironmentalDetailMaster = TestUtilities.getEnvironmentalDetailMaster();
        EnvironmentalDetailMaster.Core_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster;
        system.debug('EnvironmentalDetailMaster--');
        
        EnvironmentalDetailsOperational = TestUtilities.getEnvironmentalDetailsOperational();
        EnvironmentalDetailsOperational.Core_IPS_Question__c = EnvironmentalDetailMaster2.id;
        EnvironmentalDetailsOperational.Core_Supported_Product__c = supportedProductRecord.Id;
        insert EnvironmentalDetailsOperational;
        system.debug('EnvironmentalDetailsOperational--');
        
        // Create Custom Setting - IPS Error Codes getEnvironmentalDetailMaster
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        system.debug('ListofIpsErrorCodes--');
        
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        system.debug('ListofIpsLables--');
        System.Assert(ListofIpsLables[0].Id != null, 'Record not created');
        
        // Create Case Category
        Core_IPS_Product_Issue_Category__c CaseCategory = TestUtilities.getCaseCategories();
        CaseCategory.Core_Type__c = 'Case Category';
        CaseCategory.Core_Supported_Product__c = supportedProductRecord.id;
        insert CaseCategory;
        system.debug('CaseCategory111--');
        
        // Create Case SubCategory
        CaseSubCategory = TestUtilities.getCaseCategories();
        CaseSubCategory.Core_Product_Issue_Category__c = CaseCategory.id; 
        insert CaseSubCategory;
        system.debug('CaseSubCategory--');
        
        // Update EnvironmentalDetailsOperational
        EnvironmentalDetailsOperational.Core_Product_Issue_Sub_Category__c = CaseSubCategory.id;
        update EnvironmentalDetailsOperational;
        System.debug('envirinmental --- data');
        
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
          Core_IPS_AddProductsEnvDetailMaster_LEX.getSupportedProducts(EnvironmentalDetailMaster.Id,0,0);
        Test.stopTest();
    }
    
     @isTest
    public static void addToProductsTest(){
        getRecords();
        Test.startTest();
          List<Core_IPS_AddProductsEnvDetailMaster_LEX.ProductsSel> selectedProduct = Core_IPS_AddProductsEnvDetailMaster_LEX.getSupportedProducts(EnvironmentalDetailMaster.Id,10,0);
          Core_IPS_AddProductsEnvDetailMaster_LEX.addToProducts(selectedProduct, EnvironmentalDetailMaster.Id);
        Test.stopTest();
    }
    
    @isTest 
    public static void checkBusinessRulesTest(){
        getRecords();
        Test.startTest();
        	Core_IPS_AddProductsEnvDetailMaster_LEX.checkBusinessRules(EnvironmentalDetailMaster.Id);
        Test.stopTest();
    }
    
    // No Records to Display
    @isTest  
    public static void SupportedProductEnd(){
       getRecords();
       supportedProductRecord.Core_EOIS__c = true;
       update supportedProductRecord;
        
       System.runAs(userRecord){
         Test.startTest();
            Core_IPS_AddProductsEnvDetailMaster_LEX.checkBusinessRules(EnvironmentalDetailMaster.Id);
         Test.stopTest();
        }
    }
    
    //Question status is Inactive
    @isTest
    public static void EnvDetMasterStatusInactive(){
       getRecords();
       EnvironmentalDetailMaster.Core_Status__c = 'Inactive';
       update EnvironmentalDetailMaster;
        
       System.runAs(userRecord){
         Test.startTest();
            Core_IPS_AddProductsEnvDetailMaster_LEX.checkBusinessRules(EnvironmentalDetailMaster.Id);
         Test.stopTest();
      }
    }

    @isTest
    public static void addToProductsNull(){
        getRecords();
        try{
          Core_IPS_AddProductsEnvDetailMaster_LEX.addToProducts(null, null);
        }   
        catch(Exception e){
	     }
    }
}