@isTest
public class Core_EnvironmentVariablesController_Test{
    public static Core_IPS_Supported_Product__c supportedProductRecord;
    public static Core_IPS_Environment_Variables__c EnvironmentalDetailMaster1;
    public static Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetailsOperational;
    public static user userRecord;
    public static Group QueueRecord;
  public static Core_IPS_Product_Issue_Category__c CaseSubCategory;
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
        // Creating Public Group
        Group PublicGroupRecord = new Group(Name = 'SupportOrgPublicGroup');
        insert PublicGroupRecord;
        //User adminUser = [select id from user where profile.name='SystemAdministrator' limit 1];
        System.runAs(userRecord){
            // Mapping the Queue to the Core_Product_Organization__c object
            
            QueuesObject MappingQueueRecord = new QueueSObject(QueueID = QueueRecord.id, SobjectType = 'Core_IPS_Product_Organization__c');
            insert MappingQueueRecord;
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
        }
        // Creating Product Record
        Product2 createProductRecord = TestUtilities.getProduct();
        insert createProductRecord;
        System.Assert(createProductRecord.Id != null, 'Record not created');
        // Creating Support Org (Core_IPS_Product_Organization__c) Record
        Core_IPS_Product_Organization__c SupportOrgRecord = TestUtilities.getSupportOrg();
        //SupportOrgRecord.OwnerId = QueueRecord.Id;
        insert SupportOrgRecord;
        System.Assert(SupportOrgRecord.Id != null, 'Record not created');
        // Creating Core Supported Product
        supportedProductRecord = TestUtilities.getSupportedProduct();
        supportedProductRecord.Core_Product__c = createProductRecord.id;
        supportedProductRecord.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord;
        System.Assert(supportedProductRecord.Id != null, 'Record not created');
        EnvironmentalDetailMaster1 = TestUtilities.getEnvironmentalDetailMaster();
        EnvironmentalDetailMaster1.Core_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster1;
        Core_IPS_Environment_Variables__c EnvironmentalDetailMaster2 = TestUtilities.getEnvironmentalDetailMaster();
        EnvironmentalDetailMaster2.Core_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster2;
        EnvironmentalDetailsOperational = TestUtilities.getEnvironmentalDetailsOperational();
        EnvironmentalDetailsOperational.Core_Environment_Variable__c = EnvironmentalDetailMaster2.id;
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
    }
    /************************************************************************************************
    Testing Core_addEnvironmentDetailsToProduct Visualforce Page - Object : Core_Supported_Product__c 
    *************************************************************************************************/
    static testmethod void AddingEnvDetailsToProduct(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
            //commented for Classic EOL : Tejaswini
      /*  PageReference pageRef = Page.Core_addEnvironmentDetailsToProduct;
        Test.setCurrentPage(pageRef); */
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Core_EnvironmentVariablesController.EnvironmentVarSel WrapperObj = new Core_EnvironmentVariablesController.EnvironmentVarSel ();
        WrapperObj.selected=true;
        WrapperObj.env= EnvironmentalDetailMaster1;
        WrapperObj.required=false;
        WrapperObj.agentOnly=false;
        AddEnvVarContr.envDetails.add(WrapperObj);
        AddEnvVarContr.addEnvironmentVariables();
        Test.stopTest();
        }
    }
    static testmethod void SearchEnvDetails(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
            //commented for Classic EOL : Tejaswini
      /*  PageReference pageRef = Page.Core_addEnvironmentDetailsToProduct;
        Test.setCurrentPage(pageRef); */
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Core_EnvironmentVariablesController.EnvironmentVarSel WrapperObj = new Core_EnvironmentVariablesController.EnvironmentVarSel ();
        AddEnvVarContr.searchText = 'Issue';
        //AddEnvVarContr.getEnvironmentVariables_SupProd();
        Test.stopTest();
        }
    }
    // Supported Product - End of Life. Cannot add Env Variables to the org.
    static testmethod void SupportedProductEnded(){
        getRecords();
        supportedProductRecord.Core_EOIS__c = true;
        update supportedProductRecord;
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
            //commented for Classic EOL : Tejaswini
      /*  PageReference pageRef = Page.Core_addEnvironmentDetailsToProduct;
        Test.setCurrentPage(pageRef); */
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Test.stopTest();
        }
    }
    static testmethod void NotAuthorizedUserinthePublicGroup(){
        getRecords();
        // Testing Visualforce Page
        Test.startTest();
        //commented for Classic EOL : Tejaswini
      /*  PageReference pageRef = Page.Core_addEnvironmentDetailsToProduct;
        Test.setCurrentPage(pageRef); */
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Test.stopTest();
    }
    static testmethod void UserAddedDirectlyinQueue(){          
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
        System.runAs(userRecord){
            // Mapping the Queue to the Core_Product_Organization__c object
            QueuesObject MappingQueueRecord = new QueueSObject(QueueID = QueueRecord.id, SobjectType = 'Core_IPS_Product_Organization__c');
            insert MappingQueueRecord;
            // Adding user to the Queue
            GroupMember groupMemberObject = new GroupMember(
                GroupId = QueueRecord.Id,
                UserOrGroupId = userRecord.id
            );
            insert groupMemberObject;
        }
        // Creating Product Record
        Product2 createProductRecord = TestUtilities.getProduct();
        insert createProductRecord;
        System.Assert(createProductRecord.Id != null, 'Record not created');
        // Creating Support Org (Core_Product_Organization__c) Record
        Core_IPS_Product_Organization__c SupportOrgRecord = TestUtilities.getSupportOrg();
        //SupportOrgRecord.OwnerId = QueueRecord.Id;
        insert SupportOrgRecord;
        System.Assert(SupportOrgRecord.Id != null, 'Record not created');
        // Creating Core Supported Product
        supportedProductRecord = TestUtilities.getSupportedProduct();
        supportedProductRecord.Core_Product__c = createProductRecord.id;
        supportedProductRecord.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord;
        System.Assert(supportedProductRecord.Id != null, 'Record not created');
        EnvironmentalDetailMaster1 = TestUtilities.getEnvironmentalDetailMaster();
        EnvironmentalDetailMaster1.Core_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster1;
        Core_IPS_Environment_Variables__c EnvironmentalDetailMaster2 = TestUtilities.getEnvironmentalDetailMaster();
        EnvironmentalDetailMaster2.Core_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster2;
        Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetailsOperational1 = TestUtilities.getEnvironmentalDetailsOperational();
        EnvironmentalDetailsOperational1.Core_Environment_Variable__c = EnvironmentalDetailMaster2.id;
        EnvironmentalDetailsOperational1.Core_Supported_Product__c = supportedProductRecord.Id;
        insert EnvironmentalDetailsOperational1;
        // Create Custom Setting
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        // Testing Visualforce Page
        Test.startTest();
        //commented for Classic EOL : Tejaswini
      /*  PageReference pageRef = Page.Core_addEnvironmentDetailsToProduct;
        Test.setCurrentPage(pageRef); */
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Test.stopTest();
    }
    static testmethod void UserdirecltyAssignedtoSupOrg(){          
        // Query Admin Profile
        Profile ProfileRec = [select Id,name from Profile where name = 'System Administrator' limit 1];
        // Create User
        userRecord = TestUtilities.getUser();
        userRecord.username = 'TestClassUser@intel.com';
        userRecord.ProfileID = ProfileRec.id;
        insert userRecord;
        // Creating Product Record
        Product2 createProductRecord = TestUtilities.getProduct();
        insert createProductRecord;
        System.Assert(createProductRecord.Id != null, 'Record not created');
        // Creating Support Org (Core_Product_Organization__c) Record
        Core_IPS_Product_Organization__c SupportOrgRecord = TestUtilities.getSupportOrg();
        SupportOrgRecord.OwnerId = userRecord.Id;
        insert SupportOrgRecord;
        System.Assert(SupportOrgRecord.Id != null, 'Record not created');
        // Creating Core Supported Product
        supportedProductRecord = TestUtilities.getSupportedProduct();
        supportedProductRecord.Core_Product__c = createProductRecord.id;
        supportedProductRecord.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord;
        System.Assert(supportedProductRecord.Id != null, 'Record not created');
        EnvironmentalDetailMaster1 = TestUtilities.getEnvironmentalDetailMaster();
        EnvironmentalDetailMaster1.Core_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster1;
        Core_IPS_Environment_Variables__c EnvironmentalDetailMaster2 = TestUtilities.getEnvironmentalDetailMaster();
        EnvironmentalDetailMaster2.Core_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster2;
        Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetailsOperational1 = TestUtilities.getEnvironmentalDetailsOperational();
        EnvironmentalDetailsOperational1.Core_Environment_Variable__c = EnvironmentalDetailMaster2.id;
        EnvironmentalDetailsOperational1.Core_Supported_Product__c = supportedProductRecord.Id;
        insert EnvironmentalDetailsOperational1;
        // Create Custom Setting
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        // Testing Visualforce Page
        Test.startTest();
        //commented for Classic EOL : Tejaswini
      /*  PageReference pageRef = Page.Core_addEnvironmentDetailsToProduct;
        Test.setCurrentPage(pageRef); */
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Test.stopTest();
    } 
    /************************************************************************************************
    Testing Core_addEnvToProducts Visualforce Page - Object : Core_Environment_Variables__c  
    *************************************************************************************************/
    static testmethod void AddingEnvDetailsToEnvDetMaster(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addEnvToProducts;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(EnvironmentalDetailMaster1);
        ApexPages.CurrentPage().getparameters().put('id',EnvironmentalDetailMaster1.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Core_EnvironmentVariablesController.ProductsSel WrapperObj = new Core_EnvironmentVariablesController.ProductsSel ();
        WrapperObj.selected=true;
        WrapperObj.prod= supportedProductRecord;
        WrapperObj.prodId = null;
        WrapperObj.agentOnly=false;
        WrapperObj.required=false;
        WrapperObj.existingref = false;
        WrapperObj.prodName = null;
        AddEnvVarContr.supProductList.add(WrapperObj);
        AddEnvVarContr.addToProducts();
        Test.stopTest();
        }
    }
    // No Records to Display
    static testmethod void SupportedProductEnd(){
        getRecords();
        supportedProductRecord.Core_EOIS__c = true;
        update supportedProductRecord;
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addEnvToProducts;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(EnvironmentalDetailMaster1);
        ApexPages.CurrentPage().getparameters().put('id',EnvironmentalDetailMaster1.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Core_EnvironmentVariablesController.ProductsSel WrapperObj = new Core_EnvironmentVariablesController.ProductsSel ();
        Test.stopTest();
        }
    }
    static testmethod void EnvDetMasterStatusInactive(){
        getRecords();
        EnvironmentalDetailMaster1.Core_Status__c = 'Inactive';
        update EnvironmentalDetailMaster1;
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addEnvToProducts;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(EnvironmentalDetailMaster1);
        ApexPages.CurrentPage().getparameters().put('id',EnvironmentalDetailMaster1.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Core_EnvironmentVariablesController.ProductsSel WrapperObj = new Core_EnvironmentVariablesController.ProductsSel ();
        Test.stopTest();
        }
    }
  /************************************************************************************************
    Testing Core_addEnvironmentDetailsToIssueSubCat Visualforce Page - Object : Core_Product_Issue_Category__c  
    *************************************************************************************************/
  static testmethod void NoEnvDetToaddIssSubCat(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
            //commented for Classic EOL : Tejaswini
      /*  PageReference pageRef = Page.Core_addEnvironmentDetailsToIssueSubCat;
        Test.setCurrentPage(pageRef); */
        ApexPages.StandardController StndContr = new ApexPages.standardController(CaseSubCategory);
        ApexPages.CurrentPage().getparameters().put('id',CaseSubCategory.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        AddEnvVarContr.searchtext = 'abc';
        Core_EnvironmentVariablesController.EnvironmentVarSel WrapperObj = new Core_EnvironmentVariablesController.EnvironmentVarSel ();
        Test.stopTest();
        }
    }

  static testmethod void EnvDetToaddIssSubCat(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
            //commented for Classic EOL : Tejaswini
      /*  PageReference pageRef = Page.Core_addEnvironmentDetailsToIssueSubCat;
        Test.setCurrentPage(pageRef); */
        ApexPages.StandardController StndContr = new ApexPages.standardController(CaseSubCategory);
        ApexPages.CurrentPage().getparameters().put('id',CaseSubCategory.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        Core_EnvironmentVariablesController.EnvironmentVarSel WrapperObj = new Core_EnvironmentVariablesController.EnvironmentVarSel ();
        WrapperObj.selected=true;
        WrapperObj.env= EnvironmentalDetailMaster1;
        WrapperObj.required=false;
        WrapperObj.agentOnly=false;
        AddEnvVarContr.envDetails.add(WrapperObj);
        AddEnvVarContr.addEnvironmentVariables();
        Test.stopTest();
        }
    }
    /************************************************************************************************
    Testing Core_IPS_Environment_Details Visualforce Page - Object : Core_Product_Issue_Category__c  
    *************************************************************************************************/
    // Commented by chetan as part of classic EOL 
  static testmethod void getAssignedEnvironmentVariablestest(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_Environment_Details;        
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(EnvironmentalDetailsOperational);
        ApexPages.CurrentPage().getparameters().put('id',EnvironmentalDetailsOperational.Id);
        Core_EnvironmentVariablesController AddEnvVarContr = new Core_EnvironmentVariablesController(StndContr);
        //Core_EnvironmentVariablesController.ProductsSel WrapperObj = new Core_EnvironmentVariablesController.ProductsSel ();
        Pagereference  Pg = AddEnvVarContr.getAssignedEnvironmentVariables();
        pg = AddEnvVarContr.saveEvn();
        Test.stopTest();
        }
    }
}