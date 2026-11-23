@isTest
public  class Product_Variant_Utility_Test {
    static List<User> ListOfUser = new List<User> ();
    
    public static testMethod void showProductVariant() {
        
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        
        Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO1.Core_Organization_Description__c='This is from portal side';
        insert CIPO1;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        System.assert(ListOfProducts[0].id != null,'Product2 Record not created');
        
        List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
        ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='3456';
        insert ListOfProducts1;
        
        // Create Supported product Record
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        System.assert(ListOfSupportedProduct[0].id != null,'Supported product Record not created');  
        
        // Create Supported product Record
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
        ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
        ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =false;
        insert ListOfSupportedProduct1;
        System.assert(ListOfSupportedProduct[0].id != null,'Supported product Record not created');  
        
        //Premier Support Project
        Core_IPS_Project__c CIP = new Core_IPS_Project__c(); 
        CIP.Name='IPSProjectName1';
        CIP.Core_MPNDA__c='MPNDA value'; 
        insert CIP;
        
        //Asset Object 
        Asset ass=new Asset();
        ass.Name='test';    
        ass.Core_Product_Organization__c=CIPO.id;
        ass.Core_Supported_Product__c=ListOfSupportedProduct.get(0).Id;
        ass.Core_IPS_Project__c=CIP.Id;
        ass.Product2Id=ListOfProducts[0].id;
        //ass.Core_Product_EPM_ID__c='1234';               
        insert ass;
        
        Asset ass1=new Asset();
        ass1.Name='test1';    
        ass1.Core_Product_Organization__c=CIPO.id;
        ass1.Core_Supported_Product__c=ListOfSupportedProduct1.get(0).Id;
        ass1.Core_IPS_Project__c=CIP.Id;
        //ass1.Core_Product_EPM_ID__c='3456';              
        insert ass1; 
        
        
        
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchyc = TestUtilities.getListOfFlatProductHierarchy(1);
        ListOfFlatProductHierarchyc.get(0).Core_Unique_ID__c='3456;1234;5678';
        insert ListOfFlatProductHierarchyc;
        
        test.starttest();
        Product_Variant_Utility.displayProductVariant(ass.id);
        List<SelectOption> variants=Product_Variant_Utility.displayProductVariant(ass.Name);
        test.stoptest();
    }
    
    public static testMethod void showProductVariantNAC() {
        
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        
        Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO1.Core_Organization_Description__c='This is from portal side';
        insert CIPO1;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        System.assert(ListOfProducts[0].id != null,'Product2 Record not created');
        
        List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
        ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='3456';
        insert ListOfProducts1;
        
        // Create Supported product Record
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        System.assert(ListOfSupportedProduct[0].id != null,'Supported product Record not created');  
        
        // Create Supported Product NAC
        Core_IPS_Supported_Product__c sp = new Core_IPS_Supported_Product__c();
        // sp.Core_Code_Name__c = 'SKYLAKE';
        //sp.Core_Product__c = '01to0000004pB13';
        sp.Core_Product__c =  ListOfProducts.get(1).id;
        sp.Core_Product_EPM_ID__c = '88392';
        sp.Core_Supported_Product_Name__c = '6th Generation Intel® Core™ i7 Processors';
        // sp.Name = ListOfSupportedProduct.get(0).Id;
        sp.Core_Product_Organization__c =CIPO.id;
        sp.Core_IPS_Is_Show_Variant__c = true;
        insert sp;
        
        
        // Create Supported product Record
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
        ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
        ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =false;
        insert ListOfSupportedProduct1;
        System.assert(ListOfSupportedProduct[0].id != null,'Supported product Record not created');  
        
        //Premier Support Project
        Core_IPS_Project__c CIP = new Core_IPS_Project__c(); 
        CIP.Name='IPSProjectName1';
        CIP.Core_MPNDA__c='MPNDA value'; 
        insert CIP;
        
        //Asset Object 
        Asset ass=new Asset();
        ass.Name='test';    
        ass.Core_Product_Organization__c=CIPO.id;
        ass.Core_Supported_Product__c=ListOfSupportedProduct.get(0).Id;
        ass.Core_IPS_Project__c=CIP.Id;
        ass.Product2Id=ListOfProducts[0].id;
        //ass.Core_Product_EPM_ID__c='1234';               
        insert ass;
        
        Asset ass1=new Asset();
        ass1.Name='test1';    
        ass1.Core_Product_Organization__c=CIPO.id;
        ass1.Core_Supported_Product__c=ListOfSupportedProduct1.get(0).Id;
        ass1.Core_IPS_Project__c=CIP.Id;
        //ass1.Core_Product_EPM_ID__c='3456';              
        insert ass1; 
        
        
        
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchyc = TestUtilities.getListOfFlatProductHierarchy(1);
        ListOfFlatProductHierarchyc.get(0).Core_Unique_ID__c='3456;1234;88392;5678';
        insert ListOfFlatProductHierarchyc;
        
        test.starttest();
        Product_Variant_Utility.displayProductVariant_NAC(sp.id);
        List<SelectOption> variants=Product_Variant_Utility.displayProductVariant(ass.Name);
        test.stoptest();
    }
    
    
    
    /***************************************************************************************************
Method Name:  getPlatform_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 14 Mar 2018
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps              03/14/2018                Created
****************************************************************************************************/
    static testmethod void getPlatform_PositiveTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 Product : ListOfProducts){
            Product.Core_Hierarchy_ID__c = '59';
            Product.Core_Unique_ID__c = 'Product12345';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c FlatProductHierarchy : ListOfFlatProductHierarchy){
            if(counter < 3)
                FlatProductHierarchy.Core_L5_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 6)
                FlatProductHierarchy.Core_L4_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else
                FlatProductHierarchy.Core_L2_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            suppProductIdList.add(SupportedProduct.id);
        }
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<String, Set<String>> prodHierarchyBySupProd = Product_Variant_Utility.getPlatform(suppProductIdList);
            System.assert(prodHierarchyBySupProd != null,'Records are not fetched');
            Test.stopTest();
        }   
    }
    /***************************************************************************************************
Method Name:  getPlatform_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps       03/14/2018                Created
****************************************************************************************************/
    static testmethod void getPlatform_NegativeTest(){
        List<Id> suppProductIdList = new List<Id> ();
        getRecords();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Map<String, Set<String>> prodHierarchyBySupProd = Product_Variant_Utility.getPlatform(suppProductIdList);
            System.assert(prodHierarchyBySupProd == null,'Records are fetched');
            Test.stopTest();
        }
    }
    
    
    
    /***************************************************************************************************
Method Name:  getRecords
Method Type: Void Method
Version     : 1.0 
Created Date: 03 Nov 2015
Description:  Common Test data used in multiple test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps             03/14/2018                 Created
****************************************************************************************************/
    static void getRecords(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));     
    }
    
    /***************************************************************************************************
Method Name:  getplatform_Options_SupProd_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 04 Nov 2015
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps             03/14/2018               Created
****************************************************************************************************/
    static testmethod void getplatform_Options_SupProd_PositiveTest(){
        List<Id> idList = new List<Id> ();
        getRecords();
        // Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.Assert(ListOfAccounts[0].Id != null, 'Record not created');
        // IPS Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfIpsProjects;
        }
        System.Assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 Product : ListOfProducts){
            Product.Core_Hierarchy_ID__c = '59';
            Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            Product.Core_Unique_ID__c = 'Product12345';
            Product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        // Asset
        List<Asset> AssetList  = TestUtilities.getAssetList(1);
        for(Asset Asst : AssetList){
            Asst.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            Asst.accountId = ListOfAccounts.get(0).Id;
            Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert AssetList;
        }
        System.Assert(AssetList[0].Id != null, 'Record not created');
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c FlatProductHierarchy : ListOfFlatProductHierarchy){
            if(counter < 3)
                FlatProductHierarchy.Core_L5_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 6)
                FlatProductHierarchy.Core_L4_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else
                FlatProductHierarchy.Core_L2_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            idList.add(SupportedProduct.id);
        }
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<SelectOption> platformOptions = Product_Variant_Utility.getplatform_Options(idList);
            System.assert(platformOptions.size()>1,true);
            Test.stopTest();
        }
    }  
    
    /***************************************************************************************************
Method Name:  getplatform_Options_Asset_PositiveTest
Method Type: Test Method
Version     : 1.0 
Created Date: 08 Aug 2018
Description:  
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* PopcornApps              8/08/2018                   Created
****************************************************************************************************/
    static testmethod void getplatform_Options_Asset_PositiveTest(){
        List<Id> idList = new List<Id> ();
        getRecords();
        // Account
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfAccounts;
        }
        System.Assert(ListOfAccounts[0].Id != null, 'Record not created');
        // IPS Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfIpsProjects;
        }
        System.Assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportOrg;
        }
        System.assert(ListOfSupportOrg != null, 'Record not created');
        // Create Product
        List<Product2>  ListOfProducts = TestUtilities.getListOfProduct(1);
        for(Product2 Product : ListOfProducts){
            Product.Core_Hierarchy_ID__c = '59';
            Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
            Product.Core_Unique_ID__c = 'Product12345';
            Product.Core_Code_Name__c = 'ProductCoreCodeName';
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfProducts;
        }
        System.assert(ListOfProducts[0].id != null,'Record not created');
        // Create Supported product
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
            SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
            SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfSupportedProduct;
        }
        System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
        // Asset
        List<Asset> AssetList  = TestUtilities.getAssetList(1);
        for(Asset Asst : AssetList){
            Asst.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            Asst.accountId = ListOfAccounts.get(0).Id;
            Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert AssetList;
        }
        System.Assert(AssetList[0].Id != null, 'Record not created');
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
        integer counter = 0;
        for(Core_Flat_Product_Hierarchy__c FlatProductHierarchy : ListOfFlatProductHierarchy){
            if(counter < 3)
                FlatProductHierarchy.Core_L5_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else if(counter < 6)
                FlatProductHierarchy.Core_L4_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            else
                FlatProductHierarchy.Core_L2_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
            counter++;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        for(Asset AssetRec : AssetList){
            idList.add(AssetRec.id);
        }
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<SelectOption> platformOptions = Product_Variant_Utility.getplatform_Options(idList);
            System.assert(platformOptions.size()>1,true);
            Test.stopTest();
        }
    }
}