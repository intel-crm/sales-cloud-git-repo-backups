@isTest
public class Utilities_Portal_LEX_Test {
    @isTest
    static void TestgetSubCategoriesPositive(){
        Core_IPS_Master_Issue_Category__c MasterIssue=new Core_IPS_Master_Issue_Category__c();
        MasterIssue.Core_Status__c='Active';
        MasterIssue.Core_Type__c='MasterIssue';
        MasterIssue.Name='Test Firmware/BIOS';
        insert MasterIssue;
        string masterId=MasterIssue.Id;
        Utilities_Portal_LEX.getSubCategories(masterId);
        
        
    }
    @isTest
    static void TestgetSubCategoriesNegative(){
        string masterId='';
        Utilities_Portal_LEX.getSubCategories(masterId);
    }
    @isTest
    public static void TestgetsubCategoryOptions1(){
        Core_IPS_Master_Issue_Category__c MasterIssue=new Core_IPS_Master_Issue_Category__c();
        MasterIssue.Core_Status__c='Active';
        MasterIssue.Core_Type__c='MasterIssue';
        MasterIssue.Name='Test Firmware/BIOS';
        insert MasterIssue;
        
        Core_IPS_Product_Issue_Category__c obj=new Core_IPS_Product_Issue_Category__c();
        obj.Core_Issue_Sub_Category_Name__c=MasterIssue.Id;
        obj.Core_Status__c = 'Active';
        insert obj;
        String prodCatId = obj.Id;
        Utilities_Portal_LEX porObj = new Utilities_Portal_LEX();
        Utilities_Portal_LEX.getsubCategory_Options(prodCatId);
        
    }
    @isTest
    public static void getAllFieldsAccessibleTest(){
        Case cs = new Case();
        cs.Subject = 'Test case';
        cs.Status = 'New';
        insert cs;
        
        Set<String> csIds = new Set<String>();
        csIds.add(cs.Id);
        Utilities_Portal_LEX.getAllFieldsAccessible(csIds,cs);
    }
    public static User adminUser = null;
    @isTest
    public static void getProductsTest1(){
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        System.runAs(adminUser){
            
            List<Asset> AssetList = Core_RestAPI_TestUtilities.getAssetList(10); 
            for(Integer i=0;i<=(AssetList.size()-1);i++){
                Asset objAsset = AssetList[i];
                objAsset.OwnerId = adminUser.Id;
                
            }
            insert AssetList;
            System.assertEquals(10, AssetList.size());
            List<Core_Flat_Product_Hierarchy__c> flatProductHierarchy =  Core_RestAPI_TestUtilities.getListOfFlatProductHierarchy(10);
            for(Integer i=0;i<=(flatProductHierarchy.size()-1);i++){
                Core_Flat_Product_Hierarchy__c flatproduct = flatProductHierarchy[i];
                flatproduct.OwnerId = adminUser.Id;
                flatproduct.Core_Unique_ID__c= assetList[i].Core_Product_EPM_ID__c;
            }
            insert flatProductHierarchy;
            Utilities_Portal_LEX.getProducts(assetList[0].Id);
        }    
        
        
    }
    @isTest
    public static void getProductsTest(){
        
        Core_IPS_Product_Organization__c prodOrg=new Core_IPS_Product_Organization__c();
        prodOrg.Core_Organization_Description__c='Datacenter, Servers, Networking, Comms and Storage';
        //prodOrg.Core_IPS_Support_Org_Name__c='Test Data Center';
        prodOrg.Core_IPS_Support_Org_Name__c='IPS';
        insert prodOrg;
        
        Product2 prod=new Product2();
        prod.Name='TestProd';
        prod.IsActive=true;
        prod.Core_Product_Name_EPM_ID__c='84470';
        prod.Core_Product_Org__c='IPS';
        prod.Core_IPS_Visible_Flag_Internal__c='YES';
        insert prod;
        
        Core_IPS_Supported_Product__c supportProd=new Core_IPS_Supported_Product__c();
        supportProd.Core_Flag_Status__c='Approval Required';
        supportProd.Core_Supported_Product_Alias__c='CWDM4, QSFP28';
        supportProd.Core_Product__c=prod.id;
        supportProd.Core_Product_Organization__c=prodOrg.Id;
        supportProd.Core_IPS_Is_Show_Variant__c=true;
        insert supportProd;
        
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='Test CC';
        Project.Core_Status__c='Draft';
        insert Project;
        
        Asset assetProduct=new Asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_Product_Organization__c=prodOrg.Id;
        assetProduct.Core_Supported_Product__c=supportProd.Id;
        assetProduct.Core_IPS_Project__c=Project.Id;
        assetProduct.Product2Id = prod.Id;
        insert assetProduct;
        
        List<asset> assetList = [SELECT id,Name,Core_Product_Organization__c,Core_Supported_Product__c,Core_IPS_Project__c,Core_Product_EPM_ID__c FROM asset LIMIT 1];
        List<Core_Flat_Product_Hierarchy__c> flatIdsList = new List<Core_Flat_Product_Hierarchy__c>();
        Core_Flat_Product_Hierarchy__c Flatproduct=new Core_Flat_Product_Hierarchy__c();
        Flatproduct.Core_EPM_Hierarchy_Name__c='Valid Product Hierarchy';
        Flatproduct.Core_L1_EPM_ID__c='L1 Id 1001';
        Flatproduct.Core_L1_EPM_Name__c='L1 Name 1001';
        Flatproduct.Core_L2_EPM_ID__c='L2 Id 1001';
        Flatproduct.Core_L2_EPM_Name__c='L2 Name 1001';
        Flatproduct.Core_Unique_ID__c= assetList[0].Core_Product_EPM_ID__c;
        //insert Flatproduct;
        
        Core_Flat_Product_Hierarchy__c Flatproduct1=new Core_Flat_Product_Hierarchy__c();
        Flatproduct1.Core_EPM_Hierarchy_Name__c='Valid Product Hierarchy1';
        Flatproduct1.Core_L1_EPM_ID__c='L1 Id 1001';
        Flatproduct1.Core_L1_EPM_Name__c='L1 Name 1001';
        Flatproduct1.Core_L2_EPM_ID__c='L2 Id 1001';
        Flatproduct1.Core_L2_EPM_Name__c='L2 Name 1001';
        Flatproduct1.Core_Unique_ID__c= assetList[0].Core_Product_EPM_ID__c;
        //insert Flatproduct1;
        
        
        flatIdsList.add(Flatproduct);
        insert flatIdsList;
        Utilities_Portal_LEX.getProducts(assetList[0].Id);
    }
    
    
    
    //////////////////////////////////////////////
    @isTest
    public static void TestgetProducts(){
        List<Core_Flat_Product_Hierarchy__c> flatIdsList=new List<Core_Flat_Product_Hierarchy__c>();
        Core_IPS_Product_Organization__c prodOrg=new Core_IPS_Product_Organization__c();
        prodOrg.Core_Organization_Description__c='Datacenter, Servers, Networking, Comms and Storage';
        prodOrg.Core_IPS_Support_Org_Name__c='Test Data Center';
        insert prodOrg;
        
        Product2 prod=new Product2();
        prod.Name='TestProd';
        prod.IsActive=true;
        prod.Core_Product_Org__c='IPS';
        prod.Core_IPS_Visible_Flag_Internal__c='YES';
        prod.Core_Product_Name_EPM_ID__c='84470';
        //prod.Core_IPS_Visible_Flag__c=true;
        //prod.Core_Product_Name_EPM_ID__c='Testing';
        insert prod;
        
        Core_IPS_Supported_Product__c supportProd=new Core_IPS_Supported_Product__c();
        supportProd.Core_Flag_Status__c='Approval Required';
        supportProd.Core_Supported_Product_Alias__c='CWDM4, QSFP28';
        supportProd.Core_Product__c=prod.id;
        supportProd.Core_Product_Organization__c=prodOrg.Id;
        supportProd.Core_IPS_Is_Show_Variant__c=true;
        insert supportProd;
        
        Core_IPS_Master_Issue_Category__c MasterIssue=new Core_IPS_Master_Issue_Category__c();
        MasterIssue.Core_Status__c='Active';
        MasterIssue.Core_Type__c='MasterIssue';
        MasterIssue.Name='Test Firmware/BIOS';
        insert MasterIssue;
        
        Core_IPS_Product_Issue_Category__c category=new Core_IPS_Product_Issue_Category__c();
        category.Core_Issue_Sub_Category_Name__c=MasterIssue.Id;
        category.Core_Type__c='Test Case Subcategory';
        category.Core_Status__c='Active';
        //category.Core_Supported_Product__c='a2E1J000000KbPyUAK';
        category.Core_Supported_Product__c=supportProd.Id;
        insert category;
        String categoryId=category.Id;
        
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='Test CC';
        Project.Core_Status__c='Draft';
        insert Project;
        
        Core_Flat_Product_Hierarchy__c Flatproduct=new Core_Flat_Product_Hierarchy__c();
        Flatproduct.Core_EPM_Hierarchy_Name__c='test Flatproduct';
        Flatproduct.Core_L1_EPM_ID__c='36786';
        Flatproduct.Core_L1_EPM_Name__c='Programs';
        Flatproduct.Core_L2_EPM_ID__c='36786';
        Flatproduct.Core_L2_EPM_Name__c='Pre-Sales Products';
        Flatproduct.Core_Unique_ID__c='84470';
        //insert Flatproduct;
        flatIdsList.add(Flatproduct);
        
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_Product_Organization__c=prodOrg.Id;
        assetProduct.Core_Supported_Product__c=supportProd.Id;
        assetProduct.Core_IPS_Project__c=Project.Id;
        insert assetProduct;
        List<asset>assetList=[SELECT id,Name,Core_Product_Organization__c,Core_Supported_Product__c,Core_IPS_Project__c,Core_Product_EPM_ID__c FROM asset WHERE Id=:assetProduct.Id];
        
        system.assertEquals(1, assetList.size());
        Test.startTest();
        Utilities_Portal_LEX.getProducts(assetProduct.Id);
        Test.stopTest();
    }
    
    /////////////////////////////////////////////////////////////////New
    static List<User> ListOfUser = new List<User> ();
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
    static testmethod void getSubCategories_PositiveTest(){
        getRecords();
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(1);
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreProdIssCategory_CaseCat;
        }
        System.Assert(ListOfCoreProdIssCategory_CaseCat[0].Id != null, 'Record not Created');
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseSubCat = TestUtilities.getListOfCoreProdIssCategory(200);
        for(Core_IPS_Product_Issue_Category__c CoreProdIssCategory : ListOfCoreProdIssCategory_CaseSubCat){
            CoreProdIssCategory.Core_Product_Issue_Category__c = ListOfCoreProdIssCategory_CaseCat.get(0).id;
        }
        System.RunAs(ListOfUser[0]){
            insert ListOfCoreProdIssCategory_CaseSubCat;
        }
        System.Assert(ListOfCoreProdIssCategory_CaseSubCat[0].Id != null, 'Record not Created');
        System.runAs(ListOfUser.get(0)){
            string CoreProdIssCategory_CaseCat = ListOfCoreProdIssCategory_CaseCat.get(0).id;
            Test.startTest();
            Utilities_Portal_LEX.getsubCategory_Options(CoreProdIssCategory_CaseCat);
            Test.stopTest();
        }   
    }

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
            Product.Core_Unique_ID__c = '12345';
            Product.Core_Code_Name__c = 'ProductCoreCodeName';
            Product.Core_Product_Name_EPM_ID__c='12345';
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
            SupportedProduct.Core_IPS_Is_Show_Variant__c = true;
            SupportedProduct.Core_Product_EPM_ID__c = '12345';
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
            Asst.Product2Id = ListOfProducts.get(0).id;
            
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
            
            FlatProductHierarchy.Core_Unique_ID__c = AssetList.get(0).Core_Product_EPM_ID__c;
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
            Utilities_Portal_LEX.getProducts(AssetList.get(0).Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getsubCategory_OptionsTest(){
        Profile ps = [select id, name from Profile where name = 'System Administrator'limit 1];
        ID recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        UserRole role=new UserRole();
        role.name='CEO';
        insert role;
        User sysAdimUser = TestUtilities.getUser();
        sysAdimUser.ProfileId = ps.id;
        sysAdimUser.userroleid=role.id;
        
        insert sysAdimUser;
        System.runAs(sysAdimUser){
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            
            List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(1);
            ListOfFlatProductHierarchy[0].Core_Unique_ID__c  =';75025;128758;123707;123704;94489';
            insert ListOfFlatProductHierarchy;
            
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssets(ListOfAccounts, 1);
            list<Core_IPS_Supported_Product__c> sps = new list<Core_IPS_Supported_Product__c>();    
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
                sps.add(new  Core_IPS_Supported_Product__c(id=Asst.core_supported_product__c, Core_IPS_Is_Show_Variant__c = true, Core_Product_EPM_ID__c = '75025'));
            }
            update  sps;  
            update AssetList; 
            
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert ListOfIpsProjects;
            
            // Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
            RecordType assetRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Asset' AND Name ='IPS Asset'];
            //Create Support Org
            Core_IPS_Product_Organization__c SupOrg = new Core_IPS_Product_Organization__c(); //SupportOrg
            SupOrg.Core_IPS_Support_Org_Name__c='Trident Solutions';
            SupOrg.Core_Organization_Description__c='This is from portal side';
            insert SupOrg;
            //List Of Products
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='75025';
            ListOfProducts[0].IsActive = true;
            ListOfProducts[0].Core_Code_Name_EPM_ID__c ='75025';
            ListOfProducts[0].Name = 'Haswell processor';
            ListOfProducts[0].IsActive = true;
            ListOfProducts[0].Core_Product_Status__c= 'Active';
            ListOfProducts[0].Core_IPS_Visible_Flag_External__c = true;
            ListOfProducts[0].Core_IPS_Visible_Flag_Internal__c = 'Yes';
            ListOfProducts[0].Core_Product_Org__c = 'IPS';
            ListOfProducts[0].Core_Hierarchy_ID__c = '43';
            
            insert ListOfProducts;
            //Create Supported product Record
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct[0].Core_Product__c = ListOfProducts[0].id;
            ListOfSupportedProduct[0].Core_Product_Organization__c = SupOrg.Id;
            ListOfSupportedProduct[0].Core_Flag_Status__c = 'Auto Approve';
            ListOfSupportedProduct[0].Core_Product_EPM_ID__c = '75025';
            ListOfSupportedProduct[0].Core_Supported_Product_Name__c = 'Haswell processor';
            upsert ListOfSupportedProduct;
            
            List<Asset> listofAssets= TestUtilities.getAssetList(1);
            listofAssets[0].Product2Id = ListOfProducts[0].id;
            listofAssets[0].Name = 'Haswell processor';
            listofAssets[0].AccountID =  ListOfContacts[0].AccountId;
            listofAssets[0].Core_Project_Asset_Status__c='Active';
            listofAssets[0].status ='Active';
            listofAssets[0].RecordTypeID= assetRecType.id;
            listofAssets[0].Core_IPS_Asset__c = true;
            listofAssets[0].Core_Code_Name__c = 'false';
            listofAssets[0].Core_Supported_Product__c = ListOfSupportedProduct[0].id;
            listofAssets[0].Core_Product_Organization__c =  SupOrg.Id;
            listofAssets[0].InstallDate = system.today();
            
            insert listofAssets;
            
            Utilities_Portal_LEX.getProducts(AssetList[0].Id);
            
            Core_IPS_Master_Issue_Category__c MasterCaseCategory = TestUtilities.getMasterCaseCategories();
            MasterCaseCategory.Core_type__c = 'Case Category';
            insert MasterCaseCategory;
            System.assert(MasterCaseCategory.Id != null, 'Record not created');
            
            Core_IPS_Master_Issue_Category__c MasterCategory = TestUtilities.getMasterCaseCategories();
            MasterCategory.Core_Master_Issue_Category__c = MasterCaseCategory.id;
            insert MasterCategory;
            System.assert(MasterCategory.Id != null, 'Record not created');
            Core_IPS_Product_Issue_Category__c caseCat = TestUtilities.getCaseCategories();
            caseCat.Core_Issue_Category_Name__c = MasterCategory.id;
            caseCat.Core_Type__c = 'Case Category';
            insert caseCat;
            System.assert(caseCat.Id != null, 'Record not created');
            
            Core_IPS_Product_Issue_Category__c subCategory = TestUtilities.getCaseCategories();
            subCategory.Core_Issue_Sub_Category_Name__c = MasterCategory.id;
            subCategory.Core_Type__c = 'Case Subcategory';
            insert subCategory;
            System.assert(subCategory.Id != null, 'Record not created');
            Utilities_Portal_LEX.getsubCategory_Options(caseCat.Id); 
            Utilities_Portal_LEX.getSubCategories(subCategory.Id);
        }
    }
    
    
    
    
}