@isTest
public class Core_IssueCategoryController_Test{
    static Core_IPS_Supported_Product__c supportedProductRecord;
    static user userRecord;
    static Group QueueRecord;
    static Core_IPS_Product_Issue_Category__c CaseCategory;
    static Core_IPS_Product_Issue_Category__c CaseSubCategory;
    static Core_IPS_Master_Issue_Category__c MasterCaseCategories;
    static Core_IPS_Master_Issue_Category__c MasterCaseCategories2;
    static Core_IPS_Master_Issue_Category__c MasterCaseSubCategories;
    static Core_IPS_Master_Issue_Category__c MasterCaseSubCategories2;
    static Core_IPS_Master_Issue_Category__c MasterCaseSubCategories3;
    Static List<Core_IPS_Labels__c> ipsLabels;
    static void getRecords(){
        // Query Admin Profile
        Profile ProfileRec = [select Id,name from Profile where name = 'System Administrator' limit 1];
        // Create User
        userRecord = TestUtilities.getUser();
        userRecord.username = 'TestClassUser@intel.com';
        userRecord.ProfileID = ProfileRec.id;
        insert userRecord;
        // Creating Queue
        System.runAs(userRecord){
        QueueRecord = new Group(Name='SupportOrgQueue', type='Queue');
        insert QueueRecord;
        // Creating Public Group
        Group PublicGroupRecord = new Group(Name = 'SupportOrgPublicGroup');
        insert PublicGroupRecord;
        System.runAs(userRecord){
            ipsLabels = new List<Core_IPS_Labels__c>();
            ipsLabels=TestUtilities.getIPSLabel();
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
        // Creating Support Org (Core_Product_Organization__c) Record
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
        // Create Custom Setting
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        // Create Case Category
        
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
        
        CaseCategory = TestUtilities.getCaseCategories();
        CaseCategory.Core_Type__c = 'Case Category';
        CaseCategory.Core_Supported_Product__c = supportedProductRecord.id;
        caseCategory.Core_Issue_Category_Name__c=MasterCaseCategories.id;
        insert CaseCategory;
        // Create Case SubCategory
        CaseSubCategory = TestUtilities.getCaseCategories();
        CaseSubCategory.Core_Product_Issue_Category__c = CaseCategory.id;
        CaseSubCategory.Core_Issue_Sub_Category_Name__c=MasterCaseSubCategories.id;
        insert CaseSubCategory;
        }
    }
    
    /************************************************************************************************
    Testing Core_addIssueCategories Visualforce Page - Object : Core_Supported_Product__c And Core_addSubCategories Visualforce Page - Object : Core_Product_Issue_Category__c
    *************************************************************************************************/
    static testmethod void AddingCaseCategoryToProduct(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addIssueCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_IssueCategoryController AddCaseCatContr = new Core_IssueCategoryController(StndContr);
        
        Core_IssueCategoryController.masterIssueCatSel WrapperObj = new Core_IssueCategoryController.masterIssueCatSel ();
        WrapperObj.selected=true;
        WrapperObj.masterIssueCat= MasterCaseCategories;
        AddCaseCatContr.issueCategoryList.add(WrapperObj);
        AddCaseCatContr.addIssueCategories();
        AddCaseCatContr.getAssignedSubCategory();
        Test.stopTest();
        }
    }
    static testmethod void NoCaseCategoryToDisplay(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addIssueCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_IssueCategoryController AddCaseCatContr = new Core_IssueCategoryController(StndContr);
        //AddCaseCatContr.CaseCategoryRecord=CaseCategory;
        Core_IssueCategoryController.masterIssueCatSel WrapperObj = new Core_IssueCategoryController.masterIssueCatSel ();
        WrapperObj.selected=true;
        WrapperObj.masterIssueCat= MasterCaseCategories;
        AddCaseCatContr.issueCategoryList.add(WrapperObj);
        //AddCaseCatContr.getAssignedSubCategory();
        Core_IssueCategoryController.masterIssueCatSel WrapperObj2 = new Core_IssueCategoryController.masterIssueCatSel ();
        WrapperObj2.selected=true;
        WrapperObj2.masterIssueCat= MasterCaseCategories2;
        AddCaseCatContr.issueCategoryList.add(WrapperObj2);
        AddCaseCatContr.addIssueCategories();
        //AddCaseCatContr.getAssignedSubCategory();
        Test.stopTest();
        }
    } 
    // Supported Product - End of Life. Cannot add Case Category to the org.
    static testmethod void SupportedProductEnded(){
        getRecords();
        supportedProductRecord.Core_EOIS__c = true;
        update supportedProductRecord;
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addIssueCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_IssueCategoryController AddCaseCatContr = new Core_IssueCategoryController(StndContr);
        Test.stopTest();
        }
    }
    static testmethod void NotAuthorizedUserinthePublicGroup(){
        getRecords();
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addIssueCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_IssueCategoryController AddCaseCatContr = new Core_IssueCategoryController(StndContr);
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
        SupportOrgRecord.OwnerId = QueueRecord.Id;
        insert SupportOrgRecord;
        System.Assert(SupportOrgRecord.Id != null, 'Record not created');
        // Creating Core Supported Product
        supportedProductRecord = TestUtilities.getSupportedProduct();
        supportedProductRecord.Core_Product__c = createProductRecord.id;
        supportedProductRecord.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord;
        System.Assert(supportedProductRecord.Id != null, 'Record not created');
        // Create Custom Setting
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addIssueCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_IssueCategoryController AddCaseCatContr = new Core_IssueCategoryController(StndContr);
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
        // Create Custom Setting
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addIssueCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(supportedProductRecord);
        ApexPages.CurrentPage().getparameters().put('id',supportedProductRecord.Id);
        Core_IssueCategoryController AddCaseCatContr = new Core_IssueCategoryController(StndContr);
        Test.stopTest();
    }
    // Supported Product - End of Life. Cannot add Case Sub Category to the org.
    static testmethod void SupportedProductEnded_SubCat(){
        getRecords();
        supportedProductRecord.Core_EOIS__c = true;
        update supportedProductRecord;
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addSubCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(CaseCategory);
        ApexPages.CurrentPage().getparameters().put('id',CaseCategory.Id);
        Core_IssueCategoryController AddCaseSubCatContr = new Core_IssueCategoryController(StndContr);
        Test.stopTest();
        }
    }
    // Adding Case SubCategory
    static testmethod void AddingCaseSubCategory(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addSubCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(CaseCategory);
        ApexPages.CurrentPage().getparameters().put('id',CaseCategory.Id);
        Core_IssueCategoryController AddCaseSubCatContr = new Core_IssueCategoryController(StndContr);
        Core_IssueCategoryController.masterIssueCatSel WrapperObj = new Core_IssueCategoryController.masterIssueCatSel ();
        WrapperObj.selected=true;
        WrapperObj.masterIssueCat= MasterCaseSubCategories;
        AddCaseSubCatContr.issueSubCategoryList.add(WrapperObj);
        AddCaseSubCatContr.addSubCategories();
        Test.stopTest();
        }
    }
    // No Records to Display
    static testmethod void NoCaseCategoryToDisplay_SubCat(){
        getRecords();
        System.runAs(userRecord){
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addSubCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(CaseCategory);
        ApexPages.CurrentPage().getparameters().put('id',CaseCategory.Id);
        Core_IssueCategoryController AddCaseSubCatContr = new Core_IssueCategoryController(StndContr);
        Core_IssueCategoryController.masterIssueCatSel WrapperObj = new Core_IssueCategoryController.masterIssueCatSel ();
        WrapperObj.selected=true;
        WrapperObj.masterIssueCat= MasterCaseSubCategories;
        AddCaseSubCatContr.issueSubCategoryList.add(WrapperObj);
        Core_IssueCategoryController.masterIssueCatSel WrapperObj2 = new Core_IssueCategoryController.masterIssueCatSel ();
        WrapperObj2.selected=true;
        WrapperObj2.masterIssueCat= MasterCaseSubCategories2;
        AddCaseSubCatContr.issueSubCategoryList.add(WrapperObj2);
        AddCaseSubCatContr.addSubCategories();
        Test.stopTest();
        }
    }
    static testmethod void NotAuthorizedUserinthePublicGroup_SubCat(){
        getRecords();
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addSubCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(CaseCategory);
        ApexPages.CurrentPage().getparameters().put('id',CaseCategory.Id);
        Core_IssueCategoryController AddCaseSubCatContr = new Core_IssueCategoryController(StndContr);
        Test.stopTest();
    }
    static testmethod void UserAddedDirectlyinQueue_SubCat(){          
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
        SupportOrgRecord.OwnerId = QueueRecord.Id;
        insert SupportOrgRecord;
        System.Assert(SupportOrgRecord.Id != null, 'Record not created');
        // Creating Core Supported Product
        supportedProductRecord = TestUtilities.getSupportedProduct();
        supportedProductRecord.Core_Product__c = createProductRecord.id;
        supportedProductRecord.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord;
        System.Assert(supportedProductRecord.Id != null, 'Record not created');
        // Create Custom Setting
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        // Create Case Category
        CaseCategory = TestUtilities.getCaseCategories();
        CaseCategory.Core_Type__c = 'Case Category';
        CaseCategory.Core_Supported_Product__c = supportedProductRecord.id;
        insert CaseCategory;
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addSubCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(CaseCategory);
        ApexPages.CurrentPage().getparameters().put('id',CaseCategory.Id);
        Core_IssueCategoryController AddCaseSubCatContr = new Core_IssueCategoryController(StndContr);
        Test.stopTest();
    }
    static testmethod void UserdirecltyAssignedtoSupOrg_SubCat(){          
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
        // Create Custom Setting
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        // Create Case Category
        CaseCategory = TestUtilities.getCaseCategories();
        CaseCategory.Core_Type__c = 'Case Category';
        CaseCategory.Core_Supported_Product__c = supportedProductRecord.id;
        insert CaseCategory;
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_addSubCategories;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(CaseCategory);
        ApexPages.CurrentPage().getparameters().put('id',CaseCategory.Id);
        Core_IssueCategoryController AddCaseSubCatContr = new Core_IssueCategoryController(StndContr);
        Test.stopTest();
    }
    //
    static testmethod void getAssignedSubCategoryTest(){          
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
        // Create Custom Setting
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        insert ListofIpsErrorCodes;
        // Create Custom Setting - IPS Lables
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        insert ListofIpsLables;
        // Create Case Category
        CaseCategory = TestUtilities.getCaseCategories();
        CaseCategory.Core_Type__c = 'Case Category';
        CaseCategory.Core_Supported_Product__c = supportedProductRecord.id;
        insert CaseCategory;
        // Testing Visualforce Page
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_Edit_Category;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(CaseCategory);
        ApexPages.CurrentPage().getparameters().put('id',CaseCategory.Id);
        Core_IssueCategoryController AddCaseSubCatContr = new Core_IssueCategoryController(StndContr);
        Pagereference Pg = AddCaseSubCatContr.getAssignedSubCategory();
        Pg  = AddCaseSubCatContr.saveCategory();
        Test.stopTest();
    }
}