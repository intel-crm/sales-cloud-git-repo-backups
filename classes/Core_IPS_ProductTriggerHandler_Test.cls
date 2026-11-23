/***************************************************************************************************
Class Name:  Core_IPS_ProductTriggerHandler_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 1 Feb 2016
Function    : This class contains test coverage for Core_IPS_ProductTriggerHandler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_ProductTriggerHandler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              01/02/2016                 Created
****************************************************************************************************/
@isTest
public class Core_IPS_ProductTriggerHandler_Test {
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    /***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 25 Jan 2016
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty       25/01/2016              Created
****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Agent');
        
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(4);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('IPS Agent');
        ListOfUser.get(2).ProfileID =  profiles.get('IPS Agent');
        ListOfUser.get(3).ProfileID =  profiles.get('IPS Agent');
        //ListOfUser.get(3).ProfileID =  profiles.get('IPS Agent-Partner');
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        Core_IPS_Labels__c inActiveErrorMsg= new Core_IPS_Labels__c(Name='Core_IPS_InActiveProdError',Value__c='When initially adding a new Product to a Project, the Product Status must be kept Active.');
        //Creating Custom Settings for search criteria of Accountteammembers
        List<Core_IPS_Labels__c> IpsLabels = new List<Core_IPS_Labels__c>();
        IpsLabels.add(inActiveErrorMsg);
        //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'preventAddingInactiveProduct';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_ProductTriggerHandler';
            TriggerExecution.Core_Description__c = 'This method is check that no Inactive Products gets added to the Project';
            TriggerExecution.Core_Object__c = 'Core_IPS_Product__c';
            TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
            insert IpsLabels;
            insert TriggerExecution; 
    }
    /***************************************************************************************************
Method Name:  ProductNoDuplicate_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product with no Duplicates
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void ProductNoDuplicate_test(){
        getrecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();           
            insert IPSLabelsForGlobalAsset; 
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        // Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts_One = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts_One){
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                ipsProduct.Status__c = 'Submitted';
                ipsProduct.Is_Approved__c = false;
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                ipsProduct.Status__c = 'Submitted';
                ipsProduct.Is_Approved__c = false;
            }   
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts_One;
            
        }
        System.assert(ListOfIpsProducts_One[0].Id != null, 'Record not created');
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts_Two = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts_Two){
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                ipsProduct.Status__c = 'Not Approved';
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                ipsProduct.Status__c = 'Not Approved';
            }   
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts_Two;
        }
        System.assert(ListOfIpsProducts_Two[0].Id != null, 'Record not created');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  ProductDuplicate_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product with Duplicates
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void ProductDuplicate_test(){
        getrecords();
        String ExceptionError;
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();            
            insert IPSLabelsForGlobalAsset; 
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        // Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts_One = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts_One){
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                ipsProduct.Status__c = 'Submitted';
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                ipsProduct.Status__c = 'Submitted';
            }   
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts_One;
        }
        System.assert(ListOfIpsProducts_One[0].Id != null, 'Record not created');
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts_Two = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts_Two){
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                ipsProduct.Status__c = 'Submitted';
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                ipsProduct.Status__c = 'Submitted';
            }   
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            try{
                insert ListOfIpsProducts_Two;
            }Catch(Exception e){
                ExceptionError = e.getMessage();
            }
        }
        System.assert(ExceptionError.contains('Cannot add the same Product twice'), 'Product Duplicate Error didnot occur');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  ProductProjectActiveNoSupportProdAutoApprove_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product with Project Active without Supported product auto approve flag
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              1/02/2016                Created
****************************************************************************************************/ 
    static testmethod void ProductProjectActiveNoSupportProdAutoApprove_test(){
        getrecords();
        String ExceptionError;
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
            insert IPSLabelsForGlobalAsset; 
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }
            else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }
            
            else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                ipsProduct.Status__c = 'Submitted';
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                ipsProduct.Status__c = 'Submitted';
            }   
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts;
        }
        System.assert(ListOfIpsProducts[0].Id != null, 'Record not created');
        
        
        
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  ProductProjectActiveWithSupportProdAutoApprove_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product with Project Submitted Pending with Supported product auto approve flag
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              1/02/2016                Created
****************************************************************************************************/ 
    static testmethod void ProductProjectSubmittedPendingWithSupportProdAutoApprove_test(){
        getrecords();
        String ExceptionError;
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
            insert IPSLabelsForGlobalAsset; 
            insert ListOfSupportOrg;
        }  
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Flag_Status__c = 'Auto Approve';
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects.get(0).Core_Status__c = 'Draft';
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
            ListOfIpsProjects.get(0).Core_Status__c = 'Submitted Pending';
            update ListOfIpsProjects.get(0);
        }
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Status__c = 'Submitted';
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
            }   
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts;
            for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Is_Approved__c = true; 
            ipsProduct.Status__c = 'Approved';
            }
            update ListOfIpsProducts;
            for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Status__c = 'Auto Approve';
            }
            update ListOfIpsProducts;
        }
        System.assert(ListOfIpsProducts[0].Id != null, 'Record not created');
        
        Test.stopTest();
        
    }
    /***************************************************************************************************
Method Name:  updateProductRecTypeIPSProjectProductBasic_Submitted_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product with Record Type IPS Project Product(Basic) and product status as Submitted
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              1/02/2016                Created
****************************************************************************************************/ 
    static testmethod void updateProductRecTypeIPSProjectProductBasic_Submitted_test(){
        getrecords();
        String ExceptionError;
        //Get Record Type
        RecordType RT = [select id, name from recordtype where name = 'IPS Project Product(Basic)' Limit 1];
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
            insert IPSLabelsForGlobalAsset;  
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Flag_Status__c = 'Auto Approve';
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects.get(0).Core_Status__c = 'Draft'; 
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
            ListOfIpsProjects.get(0).Core_Status__c = 'Submitted Pending';
            update ListOfIpsProjects.get(0);
        }
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Status__c = 'Not Approved';
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
            }   
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts;
        }
        System.assert(ListOfIpsProducts[0].Id != null, 'Record not created');
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Status__c = 'Submitted';
            ipsProduct.RecordTypeId = RT.id;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            Update ListOfIpsProducts;
        }
        System.assert(ListOfIpsProducts[0].Id != null, 'Record not created');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  updateSumbittingIPSProductforApproval_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product Submitting for approval.
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              1/02/2016                Created
****************************************************************************************************/ 
    static testmethod void updateSumbittingIPSProductforApproval_test(){
        getrecords();
        String ExceptionError;
        //Get Record Type
        RecordType RT = [select id, name from recordtype where name = 'IPS Project Product(Basic)' Limit 1];
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
            insert IPSLabelsForGlobalAsset; 
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Flag_Status__c = 'Auto Approve';
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects.get(0).Core_Status__c = 'Draft'; 
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
            ListOfIpsProjects.get(0).Core_Status__c = 'Submitted Pending';
            update ListOfIpsProjects.get(0); 
        }
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            //ipsProduct.Status__c = 'Not Approved';
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
            }   
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts;
        }
        System.assert(ListOfIpsProducts[0].Id != null, 'Record not created');
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            //ipsProduct.Status__c = 'Approved';
            ipsProduct.Core_IsSubmitted_Header__c = true;
            ipsProduct.Core_IPS_IsAutoApprove__c = false;
            ipsProduct.Is_Approved__c = false;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            Update ListOfIpsProducts;
        }
        System.assert(ListOfIpsProducts[0].Id != null, 'Record not created');
        
        /*Ashutosh - US106482 - tseting the par hidden product approval*/
        
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  updateInactivateAssets_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product InActive Assets.
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              1/02/2016                Created
****************************************************************************************************/ 
    static testmethod void updateInactivateAssets_test(){
        getrecords();
        String ExceptionError;
        //Get Record Type
        RecordType RT = [select id, name from recordtype where name = 'IPS Project Product(Basic)' Limit 1];
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser.get(0)){
            insert IPSLabelsForGlobalAsset; 
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Flag_Status__c = 'Auto Approve';
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects.get(0).Core_Status__c = 'Draft'; 
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
            ListOfIpsProjects.get(0).Core_Status__c = 'Submitted Pending';
            update ListOfIpsProjects.get(0);
        }
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Core_IPS_Product_Status__c = 'Active';
            ipsProduct.Status__c = 'Not Approved';
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
            }   
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts;
        }
        System.assert(ListOfIpsProducts[0].Id != null, 'Record not created');
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Core_IsSubmitted_Header__c = true;
            ipsProduct.Core_IPS_Product_Status__c = 'Inactive';
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            Update ListOfIpsProducts;
        }
        System.assert(ListOfIpsProducts[0].Id != null, 'Record not created');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  DeleteProductProjectNew_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product if Project status is new.
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              1/02/2016                Created
****************************************************************************************************/ 
    static testmethod void 
        ProductProjectNew_test(){
            getrecords();
            
            List<Core_Trigger_Executions__c> lstTriggerExecution  = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'PreventDelete';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_Account_Handler';
            TriggerExecution.Core_Description__c = 'Prevent Delete';
            TriggerExecution.Core_Object__c = 'Core_IPS_Account__c';
            TriggerExecution.Core_Trigger_Events__c = 'after update';
            lstTriggerExecution.add(TriggerExecution);
            
            Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
            TriggerExecution1.Name = 'deleteAsset';
            TriggerExecution1.Core_Active__c = true;
            TriggerExecution1.Core_Class_Name__c ='Core_IPS_ProductTriggerHandler';
            TriggerExecution1.Core_Description__c = 'Deletes Associated Assets on a deletion of Project Product';
            TriggerExecution1.Core_Object__c = 'Core_IPS_Product__c';
            TriggerExecution1.Core_Trigger_Events__c = 'After Delete';
            lstTriggerExecution.add(TriggerExecution1);
            
            System.runAs(ListOfUser.get(0)){
                insert lstTriggerExecution;
            } 
        // Create Ips Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            }
        }
            
       
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }   
        
        
        String ExceptionError;
        //Get Record Type
        RecordType RT = [select id, name from recordtype where name = 'IPS Project Product(Basic)' Limit 1];
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Flag_Status__c = 'Auto Approve';
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Core_IPS_Product_Status__c = 'Active';
            if(counter<2){ 
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
            }   
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts;
            //ListOfIpsProducts.get(0).Core_IPS_Product_Status__c = ''; 
            //update ListOfIpsProducts.get(0); 
        }
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            delete ListOfIpsProducts;
        }  
        List<Core_IPS_Product__c> ListOfProduct_Delete = [select id from Core_IPS_Product__c where id IN: ListOfIpsProducts];
        System.assert(ListOfProduct_Delete.isEmpty(), 'Record not deleted');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  PreventDeleteProjActive_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product if Project status is Active.
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              1/02/2016                Created
****************************************************************************************************/ 
    static testmethod void PreventDeleteProjActive_test(){
        getrecords();
        //Create Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> lstTriggerExecution  = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'PreventDelete';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecution.Core_Description__c = 'Prevent Delete';
        TriggerExecution.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecution.Core_Trigger_Events__c = 'after update';
        lstTriggerExecution.add(TriggerExecution);
        
        Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
        TriggerExecution1.Name = 'activateProject';
        TriggerExecution1.Core_Active__c = true;
        TriggerExecution1.Core_Class_Name__c ='Core_IPS_Project_Handler';
        TriggerExecution1.Core_Description__c = 'Activate the Project based on status update';
        TriggerExecution1.Core_Object__c = 'Core_IPS_Project__c';
        TriggerExecution1.Core_Trigger_Events__c = 'before update,after update';
        lstTriggerExecution.add(TriggerExecution1);
        
        System.runAs(ListOfUser.get(0)){
            insert lstTriggerExecution;
        } 
        // Create Ips Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='CoreStatus_SPtoActive_Error'){
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
            }
            if(IL.name=='Core_OneProjProdMem_Error'){
                IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
            }
            if(IL.name=='CoreStatus_Draft'){
                IL.Value__c = 'Draft'; 
            }
            if(IL.name=='CoreStatus_Active'){
                IL.Value__c = 'Active' ;
            }
            if(IL.name=='CoreStatus_Inactive'){
                IL.Value__c = 'Inactive' ;
            }
            if(IL.name=='CoreStatus_SP'){
                IL.Value__c = 'Submitted Pending' ;
            } 
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        String ExceptionError;
        //Get Record Type
        RecordType RT = [select id, name from recordtype where name = 'IPS Project Product(Basic)' Limit 1];
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Flag_Status__c = 'Auto Approve';
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects.get(0).Core_Status__c = 'Draft';
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
            ListOfIpsProjects.get(0).Core_Status__c = 'Active';
            update ListOfIpsProjects.get(0);
        }
        
        
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Core_IPS_Product_Status__c = 'Active';
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
            }   
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(1)){
            try{
                delete ListOfIpsProducts;
            }Catch (Exception E){
                ExceptionError = E.getMessage(); 
            }
        }
        //System.assert(ExceptionError.contains('Cannot delete this Project Product when status is either Submitted or Active'), 'Record deleted Error not fired');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  PreventDeleteProjSubmittedPending_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Product if Project status is Submitted Pending.
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              1/02/2016                Created
****************************************************************************************************/ 
    static testmethod void PreventDeleteProjSubmittedPending_test(){
        getrecords();
        //Create Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> lstTriggerExecution  = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'PreventDelete';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecution.Core_Description__c = 'Prevent Delete';
        TriggerExecution.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecution.Core_Trigger_Events__c = 'after update';
        lstTriggerExecution.add(TriggerExecution);
        
        Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
        TriggerExecution1.Name = 'activateProject';
        TriggerExecution1.Core_Active__c = true;
        TriggerExecution1.Core_Class_Name__c ='Core_IPS_Project_Handler';
        TriggerExecution1.Core_Description__c = 'Activate the Project based on status update';
        TriggerExecution1.Core_Object__c = 'Core_IPS_Project__c';
        TriggerExecution1.Core_Trigger_Events__c = 'before update,after update';
        lstTriggerExecution.add(TriggerExecution1);
        
        System.runAs(ListOfUser.get(0)){
            insert lstTriggerExecution;
        } 
        String ExceptionError;
        //Get Record Type
        RecordType RT = [select id, name from recordtype where name = 'IPS Project Product(Basic)' Limit 1];
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
            insert IPSLabelsForGlobalAsset; 
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Flag_Status__c = 'Auto Approve';
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects.get(0).Core_Status__c = 'Draft';
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
            TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
            ListOfIpsProjects.get(0).Core_Status__c = 'Active';  
            update ListOfIpsProjects.get(0); 
        }
        //Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(4);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts){
            ipsProduct.Core_IPS_Product_Status__c = 'Active';
            if(counter<2){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
            }else{
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
            }   
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts;
        }
        Test.startTest();
        System.runAs(ListOfUser.get(1)){
            try{
                delete ListOfIpsProducts;
            }Catch (Exception E){
                ExceptionError = E.getMessage(); 
            }
        }
        //System.assert(ExceptionError.contains('Cannot delete this Project Product when status is either Submitted or Active'), 'Record deleted Error not fired');        
        Test.stopTest();
    }
    /*Ashutosh _ US106482 - To test par Hidden product being added in project without approval if it is from the same supported org where user is member in owner queue of org*/
    static testmethod void approveParHiddenWithoutApprovalTest(){
        
       
        getrecords();
        Test.startTest();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        Account acc;
        Contact con;
        strProf.add('IPS Support Org Admin');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        List<User> ListOfUser1;
        System.runAs(ListOfUser[0]){
        ListOfUser1 = new List<User>{userRecord}; //TestUtilities.getListOfUser(1);
            ListOfUser1.get(0).ProfileID =  profiles.get('IPS Support Org Admin');
            acc=TestUtilities.getListOfAccounts(1).get(0);
            insert acc;
            con = TestUtilities.getListOfContact(1).get(0);
            con.Accountid = acc.Id;
            con.Core_IPS_Intel_Support_Owner__c = ListOfUser1.get(0).id; 
            con.Core_IPS_Active__c = true;
            insert con;
        //ListOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insert ListOfUser1;  
        }
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser1.get(0).id; 
        String ExceptionError;
        
        
        
        Group QueueRecord = TestUtilities.getQueue();
        System.runAs(Listofuser[0]){
        insert QueueRecord;
        }
        System.Assert(QueueRecord.Id != null, 'Record not created');
        System.runAs(Listofuser[0]){
        Group PublicGroupRecord = new Group();
        PublicGroupRecord.Name = 'TestPublicGroup';
        insert PublicGroupRecord;
        System.Assert(PublicGroupRecord.Id != null, 'Record not created');
        
            QueuesObject MappingQueueRecord = TestUtilities.getMappingQueue();
            MappingQueueRecord.QueueID = QueueRecord.id;
            MappingQueueRecord.SobjectType = 'Core_IPS_Product_Organization__c';
            System.runAs(listofUser[0]){
            insert MappingQueueRecord;
            }
            System.Assert(MappingQueueRecord.Id != null, 'Record not created');
            GroupMember groupMemberObject_User = new GroupMember(
                GroupId = PublicGroupRecord.Id,
                UserOrGroupId = ListOfUser1.get(0).Id
            );
            insert groupMemberObject_User;
            System.Assert(groupMemberObject_User.Id != null, 'Record not created');
            GroupMember groupMemberObject_Group = new GroupMember(
                GroupId = QueueRecord.Id,
                UserOrGroupId = PublicGroupRecord.id
            );
            insert groupMemberObject_Group;  
            System.Assert(groupMemberObject_Group.Id != null, 'Record not created');
        }
        
        //Create Custom Setting - Trigger Executions
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'activateProject';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_Project_Handler';
        TriggerExecution.Core_Description__c = 'Activate the Project based on status update';
        TriggerExecution.Core_Object__c = 'Core_IPS_Project__c';
        TriggerExecution.Core_Trigger_Events__c = 'before update,after update';
        
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        ListOfSupportOrg.get(0).ownerId = QueueRecord.Id;
        
        System.runAs(ListOfUser.get(0)){
            insert TriggerExecution; 
            //insert IPSLabels;
            insert ListOfSupportOrg.get(0);
            System.debug('>>>> Sup Org'+ListOfSupportOrg.get(0));
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser1.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                SupportedProduct.Core_Flag_Status__c = 'Par Hidden';
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                SupportedProduct.Core_Flag_Status__c = 'Approval Required';
            }
            counter++;
        }
        System.runAs(ListOfUser1.get(0)){
            insert ListOfSupportedProduct;
            System.debug('>>>> Sup Prod'+ListOfSupportedProduct.get(0));
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        
        //Get Record Type
        Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        
        counter = 0;
        //Create Ips Project
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'projIPSTestProject12310000001111111110122322222333000000test123',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            recordTypeId = projectRecordTypeId
        );
        List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                insert ListOfIpsProjects; 
                
                //Add Member And Account to Project 
                //TestUtilities.addAccMemProdToProject(ListOfIpsProjects);
            } 
        System.runAs(ListOfUser[0]){
                ListOfIpsProjects.get(0).Core_Status__c = 'Submitted Pending';
                update ListOfIpsProjects;
                System.debug('>>>> IPS Proj'+ListOfIpsProjects);
                core_ips_account__c projAccount= TestUtilities.getCoreIpsAccount();
                projAccount.Core_Account__c=acc.Id;
                projAccount.Core_IPS_Project__c=ListOfIpsProjects.get(0).Id;
                insert projAccount;
                System.debug('>>>> projAccount'+projAccount+'Account '+acc.Id);
                Core_IPS_Project_Member__c projectMember = TestUtilities.getProjectMember();
                projectMember.core_ips_contact__c = con.id;
                projectMember.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                insert projectMember;
            System.debug('>>>> projectMember'+projAccount+'Contact '+con.Id);
        }
        // Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts_One = TestUtilities.getListOfIpsProducts(1);
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts_One){
            
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
            ipsProduct.Core_IsSubmitted_Header__c = true;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                ipsProduct.Status__c = 'Active';
            
        } 
        System.runAs(ListOfUser1.get(0)){
            System.debug('>>>User is'+Userinfo.getName()+':: Profile'+UserInfo.getProfileId());
            insert ListOfIpsProducts_One;
            System.debug('>>>ListOfIpsProducts_One'+ListOfIpsProducts_One);
        }
        System.assert(ListOfIpsProducts_One[0].Id != null, 'Record not created');
        
        
        
        Test.stopTest();
        
          
    }
   
/***************************************************************************************************
Method Name:  addDefaultCaseOwnerToIST_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Default Case Owner to IST.
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                   28/12/2018                Created
****************************************************************************************************/
   static testmethod void addDefaultCaseOwnerToIST_test(){
    getrecords();
              List<Core_IPS_Intel_Support_Team__c> istList=new List<Core_IPS_Intel_Support_Team__c>();

       //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'addDefaultCaseOwnerToIST';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_ProductTriggerHandler';
            TriggerExecution.Core_Description__c = 'This method is used to add Default Case Owner on Private Project to IST';
            TriggerExecution.Core_Object__c = 'Core_IPS_Product__c';
            TriggerExecution.Core_Trigger_Events__c = 'Afer Insert,After Update';
       insert TriggerExecution;
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();           
            insert IPSLabelsForGlobalAsset; 
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        integer counter = 0;
        // Create Product
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
            }else{
                Product.Core_Hierarchy_ID__c = '59';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                Product.Core_Unique_ID__c = 'Product59';
                Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        counter = 0;
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            if(counter==0){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }else{
                SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        counter = 0;
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(ListOfUser.get(0)){
            ListOfIpsProjects.get(0).Core_Ips_Private__c=true;
            insert ListOfIpsProjects;
        }
       //Create IST Member
       Core_IPS_Intel_Support_Team__c istInsertRec = new Core_IPS_Intel_Support_Team__c();
                        istInsertRec.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                        istInsertRec.Core_IPS_User__c = ListOfUser.get(1).Id;
                        istInsertRec.Status__c = 'Active';
       Core_IPS_Intel_Support_Team__c istInsertRec1 = new Core_IPS_Intel_Support_Team__c();
                        istInsertRec1.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                        istInsertRec1.Core_IPS_User__c = ListOfUser.get(2).Id;
                        istInsertRec1.Status__c = 'Inactive';
       istList.add(istInsertRec);
       istList.add(istInsertRec1);
       insert istList;
        // Create IPS Product
        List<Core_IPS_Product__c> ListOfIpsProducts_One = TestUtilities.getListOfIpsProducts(3);
       Integer i=1;
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts_One){
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                ipsProduct.Status__c = 'Submitted';
                ipsProduct.Is_Approved__c = false;
                ipsProduct.Core_IPS_Product_Case_Owner__c=ListOfUser.get(i).Id;
            i++;   
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts_One;
            
        }
        System.assert(ListOfIpsProducts_One[0].Id != null, 'Record not created');
        
            }
            
/***************************************************************************************************
Method Name:  partnerAgentAsProjectMember_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Test if IPS agent partner is a project member or not
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sumukh                    03/01/2018                Created
****************************************************************************************************/
  static testmethod void partnerAgentAsProjectMember_test(){
   getrecords();
   integer counter = 0;
   
    Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='IPS Agent-Partner' ];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        system.debug('profiles'+profiles);
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        User userRecord = new User();
        System.runAs ( ListOfUser[0]) { 
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User portalAccountOwner1 = new User(
                                        UserRoleId = portalRole.Id,
                                        ProfileId = profile1.Id,
                                        Username = 'test1206@intel.com',
                                        Alias = 'batman',
                                        Email='newuser155@intel.com',
                                        EmailEncodingKey='UTF-8',
                                        Firstname='Bruce',
                                        Lastname='Wayne',
                                        LanguageLocaleKey='en_US',
                                        LocaleSidKey='en_US',
                                        TimeZoneSidKey='America/Chicago'
                                        );
            Database.insert(portalAccountOwner1);
            
            Account testAccount1=TestUtilities.getAccount(); 
            testAccount1.ownerid = portalAccountOwner1.id;      
            insert testAccount1;             
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup',
                                 AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact1;
             
            UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert ur;
            
            userRecord.Alias = 'StdUser';
            userRecord.contactId =testContact1.id;
            userRecord.Email = 'newuser21@intel.com';
            userRecord.EmailEncodingKey ='UTF-8';
            userRecord.LastName = 'Testing';
            userRecord.FirstName = 'FName';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
            userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
            userRecord.isActive = true;
            
            userRecord.ProfileID =  profiles.get('IPS Agent-Partner');              
            insert userRecord;
            
              // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
           
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){                
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
                ContactRec.Core_IPS_Active__c = true;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
           
            // Create Ips Project
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
           
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfIpsAccounts;
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                ProjMem.Core_IPS_Contact__c = testContact1.Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                ProjMem.Core_User__c = userRecord.id;
            }
            insert ListOfProjectMembers; 
          
          
   List<Core_IPS_Product_Organization__c> ListOfSupportOrg1  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();           
            insert IPSLabelsForGlobalAsset; 
            insert ListOfSupportOrg1;
        }
        System.assert(ListOfSupportOrg1 != null, 'Record not created');
        
   // create project
   List<Core_IPS_Project__c> ListOfIpsProjects1 = TestUtilities.getListOfIpsProjects(1);
 
   System.runAs(ListOfUser.get(0)){
   insert ListOfIpsProjects1;
   }
   
   List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(2);
        for(Product2 Product : ListOfProducts1){
            if(counter==0){
                Product.Core_Hierarchy_ID__c = '431';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName2';
                Product.Core_Unique_ID__c = 'Product123455';
                Product.Core_Code_Name__c = 'ProductCoreCodeName1';
            }else{
                Product.Core_Hierarchy_ID__c = '591';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName592';
                Product.Core_Unique_ID__c = 'Product592';
                Product.Core_Code_Name__c = 'ProductCoreCodeName593';
                
            }
            counter++;
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfProducts1;
        }
        System.assert(ListOfProducts1[0].id != null,'Record not created');
  
   List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
   for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct1){           
            SupportedProduct.Core_Product__c = ListOfProducts1.get(1).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg1.get(1).id;
            } 
   
   System.runAs(ListOfUser.get(0)){ 
            insert ListOfSupportedProduct1;
   }
   System.assert(ListOfSupportedProduct1[0].id != null,'Record not created');
        
   // Create Product
    List<Core_IPS_Product__c> ListOfIpsProducts_One1 = TestUtilities.getListOfIpsProducts(3);
       Integer i=1;
        for(Core_IPS_Product__c ipsProduct:ListOfIpsProducts_One1){
                ipsProduct.Core_IPS_Product_Name__c = 'Test product';
                ipsProduct.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                ipsProduct.Core_Supported_Product__c = ListOfSupportedProduct1.get(0).id;
                ipsProduct.Status__c = 'Submitted';
                ipsProduct.Is_Approved__c = true;
                ipsProduct.Core_IPS_Product_Case_Owner__c= userRecord.id;
            i++;   
        }
    System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProducts_One1;
    }
    System.assert(ListOfIpsProducts_One1[0].Id != null, 'Record not created');     
     }
    }
  }