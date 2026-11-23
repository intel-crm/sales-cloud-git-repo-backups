@isTest
public class Core_IPS_addEDQToProduct_LEX_Test {
public static Core_IPS_Supported_Product__c supportedProductRecord;
public static Core_IPS_Question__c EnvironmentalDetailMaster1;
public static Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetailsOperational;
public static user userRecord;
public static Group QueueRecord;
public static Core_IPS_Product_Issue_Category__c CaseCategory;    
public static Core_IPS_Product_Issue_Category__c CaseSubCategory;
static Core_IPS_Master_Issue_Category__c MasterCaseCategories;
static Core_IPS_Master_Issue_Category__c MasterCaseCategories2;
static Core_IPS_Master_Issue_Category__c MasterCaseSubCategories;
static Core_IPS_Master_Issue_Category__c MasterCaseSubCategories2;
static List<Core_IPS_Master_Issue_Category__c> mic = new List<Core_IPS_Master_Issue_Category__c>(); 
static List<Core_IPS_Master_Issue_Category__c> mic1 = new List<Core_IPS_Master_Issue_Category__c>();     
static void getRecords(){
    // Query Admin Profile
    Profile ProfileRec = [select Id,name from Profile where name = 'System Administrator' limit 1];
    // Create User
    userRecord = TestUtilities.getUser();
    userRecord.username = 'TestClassUser@intel.com';
    userRecord.ProfileID = ProfileRec.id;
    insert userRecord;
    // Creating Queue
    QueueRecord = new Group(Name='SupportOrgQueue', type='Queue');
    insert QueueRecord;
    System.debug('This is QUEUE '+QueueRecord);
    // Creating Public Group
    Group PublicGroupRecord = new Group(Name = 'SupportOrgPublicGroup');
    insert PublicGroupRecord;
    //User adminUser = [select id from user where profile.name='SystemAdministrator' limit 1];
    System.runAs(userRecord){
        // Mapping the Queue to the Core_IPS_Product_Organization__c object
        QueuesObject MappingQueueRecord = new QueueSObject(QueueID = QueueRecord.id, SobjectType = 'Core_IPS_Product_Organization__c');
        insert MappingQueueRecord;
        QueuesObject MappingQueueRecord2 = new QueueSObject(QueueID = QueueRecord.id, SobjectType = 'Core_IPS_MAP_PAR__c');
        insert MappingQueueRecord2;
        // Adding Public Group to the Queue
        GroupMember groupMemberObject_Group = new GroupMember(
            GroupId = QueueRecord.Id,
            UserOrGroupId = PublicGroupRecord.id
        );
        insert groupMemberObject_Group;
        // Adding Member to the Public Group
        GroupMember groupMemberObject_User = new GroupMember(
            GroupId = PublicGroupRecord.Id,
            UserOrGroupId = userRecord.id
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
        system.debug('EnvironmentalDetailMaster1--');
        Core_IPS_Question__c EnvironmentalDetailMaster2 = TestUtilities.getCoreQuestion();
        EnvironmentalDetailMaster2.Core_IPS_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster2;
        EnvironmentalDetailsOperational = TestUtilities.getEnvironmentalDetailsOperational();
        EnvironmentalDetailsOperational.Core_IPS_Question__c = EnvironmentalDetailMaster2.id;
        EnvironmentalDetailsOperational.Core_Supported_Product__c = supportedProductRecord.Id;
        insert EnvironmentalDetailsOperational;
        system.debug('EnvironmentalDetailsOperational--');
        // Create Custom Setting - IPS Error Codes
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        system.debug('ListofIpsErrorCodes--');
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        system.debug('ListofIpsLables--');
        System.Assert(ListofIpsLables[0].Id != null, 'Record not created');
        // Create Case Category
        CaseCategory = TestUtilities.getCaseCategories();
        CaseCategory.Core_Type__c = 'Case Category';
        CaseCategory.Core_Supported_Product__c = supportedProductRecord.id;
        insert CaseCategory;
        system.debug('CaseCategory111--');
        // Create Case SubCategory
        CaseSubCategory = TestUtilities.getCaseCategories();
        CaseSubCategory.Core_Product_Issue_Category__c = CaseCategory.id; 
        insert CaseSubCategory;
        
        // master case subcategory 
        // Create Core_Master_Issue_Category__c - Case Category
        MasterCaseCategories = TestUtilities.getMasterCaseCategories();
        MasterCaseCategories.Core_type__c = 'Case Category';
        insert MasterCaseCategories;
        MasterCaseCategories2 = TestUtilities.getMasterCaseCategories();
        MasterCaseCategories2.Core_type__c = 'Case Category';
        insert MasterCaseCategories2;
        // Create Core_Master_Issue_Category__c - Case SubCategory
        MasterCaseSubCategories = TestUtilities.getMasterCaseCategories();
        MasterCaseSubCategories.Core_Master_Issue_Category__c = MasterCaseCategories.id;
        MasterCaseSubCategories.core_type__c='Case Subcategory';
        insert MasterCaseSubCategories;
        MasterCaseSubCategories2 = TestUtilities.getMasterCaseCategories();
        MasterCaseSubCategories2.Core_Master_Issue_Category__c = MasterCaseCategories.id;
        MasterCaseSubCategories2.core_type__c='Case Subcategory';
        insert MasterCaseSubCategories2;
        mic.add(MasterCaseSubCategories);
        mic.add(MasterCaseSubCategories2);
 		mic1.add(MasterCaseCategories);
        mic1.add(MasterCaseCategories2);
        system.debug('CaseSubCategory--');
        // Update EnvironmentalDetailsOperational
        EnvironmentalDetailsOperational.Core_Product_Issue_Sub_Category__c = CaseSubCategory.id;
        update EnvironmentalDetailsOperational;
        Core_IPS_Error_Code__c ec = new Core_IPS_Error_Code__c();
        ec.Name='I110';
        ec.Core_Error_Message__c='No category associated to record';
        insert ec;
        Core_IPS_Error_Code__c ec1 = new Core_IPS_Error_Code__c();
        ec1.Name='I113';
        ec1.Core_Error_Message__c='Status inactive';
        insert ec1;
        Core_IPS_Error_Code__c ec2 = new Core_IPS_Error_Code__c();
        ec2.Name='I105';
        ec2.Core_Error_Message__c='Unauthorized User';
        insert ec2;
        Core_IPS_Error_Code__c ec3 = new Core_IPS_Error_Code__c();
        ec3.Name='I109';
        ec3.Core_Error_Message__c='No suported product to record';
        insert ec3;
        Core_IPS_Error_Code__c ec4 = new Core_IPS_Error_Code__c();
        ec4.Name='G108';
        ec4.Core_Error_Message__c='No Case Category Record';
        insert ec4;
        Core_IPS_Error_Code__c ec5 = new Core_IPS_Error_Code__c();
        ec5.Name='I112';
        ec5.Core_Error_Message__c='Status inactive';
        insert ec5;
        Core_IPS_Error_Code__c ec6 = new Core_IPS_Error_Code__c();
        ec6.Name='I106';
        ec6.Core_Error_Message__c='No records to display';
        insert ec6;
        Core_IPS_Error_Code__c ec7 = new Core_IPS_Error_Code__c();
        ec7.Name='I107';
        ec7.Core_Error_Message__c='EOIS Product';
        insert ec7;
        System.debug('envirinmental --- data');
    }
}
@isTest
    public static void TestgetEnvironmentVariables_SupProd(){
        getRecords();
        Test.startTest();
        	
        	
        	Core_IPS_addEDQToProduct_LEX.getEnvironmentVariables_SupProd(String.ValueOf(supportedProductRecord.id),0,0,'All Data');
        	Core_IPS_addEDQToProduct_LEX.getEnvironmentVariables_CaseCat(String.ValueOf(CaseSubCategory.id),0,0,'All Data');
        	Core_IPS_addEDQToProduct_LEX.getCategories(String.ValueOf(supportedProductRecord.id),0,0,'All Data');
            Core_IPS_addEDQToProduct_LEX.getCategories(String.ValueOf(supportedProductRecord.id),10,0,'Load Data');
        	Core_IPS_addEDQToProduct_LEX.getSubCategories(String.ValueOf(CaseCategory.id),0,0,'All Data');
            Core_IPS_addEDQToProduct_LEX.getSubCategories(String.ValueOf(CaseCategory.id),10,0,'Load Data');
        Test.stopTest();
    }
    @isTest 
    public static void TestcheckRules(){
        getRecords();
        Core_IPS_Product_Organization__c SupportOrgRecord = TestUtilities.getSupportOrg();
        SupportOrgRecord.OwnerId = UserInfo.getUserId();
        insert SupportOrgRecord;
		Product2 createProductRecord = TestUtilities.getProduct();
        insert createProductRecord;
        // Creating Core Supported Product
       	Core_IPS_Supported_Product__c supportedProductRecord1 = TestUtilities.getSupportedProduct();
        supportedProductRecord1.Core_Product__c = createProductRecord.id;
        supportedProductRecord1.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord1;
        Core_IPS_Product_Issue_Category__c CaseCategory2 = TestUtilities.getCaseCategories();
        CaseCategory2.Core_Type__c = 'Case Category';
        CaseCategory2.Core_Supported_Product__c = supportedProductRecord1.id;
        insert CaseCategory2;
        Test.startTest();
        	Core_IPS_addEDQToProduct_LEX.checkSPEDQRules(String.ValueOf(supportedProductRecord.id));
        	Core_IPS_addEDQToProduct_LEX.checkSPCaseCatRules(String.ValueOf(supportedProductRecord.id));
        	Core_IPS_addEDQToProduct_LEX.checkCaseSubCatEDQRules(String.ValueOf(CaseSubCategory.id));
        	Core_IPS_addEDQToProduct_LEX.checkCaseSubCatRules(String.ValueOf(CaseCategory2.id));
        	Core_IPS_addEDQToProduct_LEX.checkSPCaseCatRules(String.ValueOf(supportedProductRecord1.id));
        Test.stopTest();
    }
    @isTest 
    public static void TestaddEnvironmentVariables(){
        getRecords();
        Test.startTest();
        	List <Core_IPS_addEDQToProduct_LEX.EnvironmentVarSel> envdeatils = Core_IPS_addEDQToProduct_LEX.getEnvironmentVariables_SupProd(String.ValueOf(supportedProductRecord.id),10,0,'Load Data');
            List <Core_IPS_addEDQToProduct_LEX.EnvironmentVarSel> envdeatils1 = Core_IPS_addEDQToProduct_LEX.getEnvironmentVariables_CaseCat(String.ValueOf(CaseSubCategory.id),10,0,'Load Data');
        	List<Core_IPS_Master_Issue_Category__c> subcatlist = Core_IPS_addEDQToProduct_LEX.getSubCategories(String.ValueOf(CaseCategory.id),0,0,'All Data');
        	Core_IPS_addEDQToProduct_LEX.addSubCategories(String.ValueOf(CaseCategory.id),mic);
        	Core_IPS_addEDQToProduct_LEX.addCategories(String.ValueOf(supportedProductRecord.id),mic1);
        	Core_IPS_addEDQToProduct_LEX.addEnvironmentVariables(envdeatils, String.ValueOf(supportedProductRecord.id),null);
        	Core_IPS_addEDQToProduct_LEX.addEnvironmentVariables(envdeatils1, null,String.ValueOf(CaseSubCategory.id));
        Test.stopTest();
    }
    @isTest
    public static void TestNegative(){
        
        // For EOIS Condition to cover
        getRecords();
        supportedProductRecord.Core_EOIS__c = true;
        update supportedProductRecord;
        Core_IPS_Product_Issue_Category__c CaseSubCategory1 = TestUtilities.getCaseCategories();
        //CaseSubCategory1.Core_Product_Issue_Category__c = CaseCategory.id; 
        CaseSubCategory1.Core_Status__c = 'Active';
        insert CaseSubCategory1;
        CaseSubCategory.Core_Status__c = 'Inactive';
        update CaseSubCategory;
        Core_IPS_Product_Issue_Category__c CaseCategory1 = TestUtilities.getCaseCategories();
        CaseCategory1.Core_Type__c = 'Case Category';
        CaseCategory1.Core_Supported_Product__c = supportedProductRecord.id;
        insert CaseCategory1;
        system.debug('CaseCategory111--');
        // Create Case SubCategory
        Core_IPS_Product_Issue_Category__c CaseSubCategory2 = TestUtilities.getCaseCategories();
        CaseSubCategory2.Core_Product_Issue_Category__c = CaseCategory1.id; 
        insert CaseSubCategory2;
        
        Core_IPS_Product_Organization__c SupportOrgRecord = TestUtilities.getSupportOrg();
        SupportOrgRecord.OwnerId = UserInfo.getUserId();
        insert SupportOrgRecord;
       
        Product2 createProductRecord = TestUtilities.getProduct();
        insert createProductRecord;
        // Creating Core Supported Product
       Core_IPS_Supported_Product__c supportedProductRecord1 = TestUtilities.getSupportedProduct();
        supportedProductRecord1.Core_Product__c = createProductRecord.id;
        supportedProductRecord1.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord1;
        supportedProductRecord1.Core_EOIS__c = true;
        update supportedProductRecord1;
        Core_IPS_Product_Issue_Category__c CaseCategory2 = TestUtilities.getCaseCategories();
        CaseCategory2.Core_Type__c = 'Case Category';
        CaseCategory2.Core_Supported_Product__c = supportedProductRecord1.id;
        insert CaseCategory2;

        Test.startTest();
        	
        	Core_IPS_addEDQToProduct_LEX.checkSPEDQRules(String.ValueOf(supportedProductRecord.id));
        	Core_IPS_addEDQToProduct_LEX.checkSPCaseCatRules(String.ValueOf(supportedProductRecord1.id));
        	Core_IPS_addEDQToProduct_LEX.checkCaseSubCatEDQRules(String.ValueOf(CaseSubCategory1.id));
        	Core_IPS_addEDQToProduct_LEX.checkCaseSubCatEDQRules(String.ValueOf(CaseSubCategory.id));
            Core_IPS_addEDQToProduct_LEX.checkCaseSubCatEDQRules(String.ValueOf(CaseSubCategory2.id));
        	Core_IPS_addEDQToProduct_LEX.checkCaseSubCatRules(String.ValueOf(CaseCategory.id));
        	Core_IPS_addEDQToProduct_LEX.checkCaseSubCatRules(String.ValueOf(CaseCategory2.id));
        	//Core_IPS_addEDQToProduct_LEX.checkSPRules(null);
        	
        Test.stopTest();	
    }
   @isTest
    public static void TestNegative1(){
        getRecords();
        Test.startTest();
        	Core_IPS_addEDQToProduct_LEX.checkSPCaseCatRules(null);
        	Core_IPS_addEDQToProduct_LEX.checkCaseSubCatRules(null);
        	Core_IPS_addEDQToProduct_LEX.checkCaseSubCatEDQRules(null);
        Test.stopTest();
    }
}