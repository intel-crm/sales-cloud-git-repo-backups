@isTest
public class Core_IPS_CaseCreate_Test {
    @isTest static void TestProductnegative()
    {
        String prodId;
        Test.startTest();
        core_IPS_caseCreate_LEX.getProductVariants(prodId);
        core_IPS_caseCreate_LEX.getCaseCategories(prodId);
        Test.stopTest();
    }
    @isTest static void TestSupportnegative()
    {
        String supportedProdId='';
        String supportedId='';
        Test.startTest();
        core_IPS_caseCreate_LEX.GetEdqMethod(supportedProdId);
        core_IPS_caseCreate_LEX.getEDQ(supportedId);
        Test.stopTest();
    }
    @isTest static void TestgetCaseSubCategoriesnegative()
    {
        String categoryId;
        Test.startTest();
        core_IPS_caseCreate_LEX.getCaseSubCategories(categoryId);
        Test.stopTest();
    }
    @isTest static void TestProductPositive()
    {
        Core_IPS_Product_Organization__c prodOrg=new Core_IPS_Product_Organization__c();
        prodOrg.Core_Organization_Description__c='Datacenter, Servers, Networking, Comms and Storage';
        prodOrg.Core_IPS_Support_Org_Name__c='Test Data Center';
        insert prodOrg;
        system.assert(prodOrg!= null);
        Product2 prod=new Product2();
        prod.Core_Product_Name_EPM_ID__c='75025';
            prod.IsActive = true;
            prod.Core_Code_Name_EPM_ID__c ='75025';
            prod.Name = 'Haswell processor';
            prod.IsActive = true;
            prod.Core_Product_Status__c= 'Active';
            prod.Core_IPS_Visible_Flag_External__c = true;
            prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
            prod.Core_Product_Org__c = 'IPS';
            prod.Core_Hierarchy_ID__c = '43';
        insert prod;
        
        Core_IPS_Supported_Product__c supportProd=new Core_IPS_Supported_Product__c();
        supportProd.Core_Flag_Status__c='Approval Required';
        supportProd.Core_Supported_Product_Alias__c='CWDM4, QSFP28';
        supportProd.Core_Product__c=prod.Id;
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
        core_IPS_caseCreate_LEX.getCaseSubCategories(categoryId);
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
        Flatproduct.Core_Unique_ID__c='36786;36786;36786;36786;36786';
        insert Flatproduct;
        
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_Product_Organization__c=prodOrg.Id;
        assetProduct.Core_Supported_Product__c=supportProd.Id;
        assetProduct.Core_IPS_Project__c=Project.Id;
        //assetProduct.Core_Product_EPM_ID__c=Flatproduct.Id;
        insert assetProduct;
        
        
        String prodId=assetProduct.Id;
        Test.startTest();
        core_IPS_caseCreate_LEX.getProductVariants(assetProduct.Id);
        core_IPS_caseCreate_LEX.getSupportedProd(assetProduct.Id);
        core_IPS_caseCreate_LEX.getCaseCategories(prod.Id);
        Test.stopTest();
    }
    @isTest static void TestSupportPositive()
    {
        Core_IPS_Question__c questions=new Core_IPS_Question__c();
        questions.Core_IPS_Question__c='Was your issue resolved?';
        questions.Core_IPS_Datatype__c='Picklist';
        questions.Core_IPS_Status__c='Active';
        questions.Core_IPS_Survey_Type__c='Customer';
        insert questions;
        
        Product2 prod=new Product2();
        prod.Core_Product_Name_EPM_ID__c='75025';
            prod.IsActive = true;
            prod.Core_Code_Name_EPM_ID__c ='75025';
            prod.Name = 'Haswell processor';
            prod.IsActive = true;
            prod.Core_Product_Status__c= 'Active';
            prod.Core_IPS_Visible_Flag_External__c = true;
            prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
            prod.Core_Product_Org__c = 'IPS';
            prod.Core_Hierarchy_ID__c = '43';
        insert prod;
        
        Core_IPS_Product_Organization__c ProdOrg=new Core_IPS_Product_Organization__c();
        ProdOrg.Core_Organization_Description__c='Test Description';
        ProdOrg.Core_IPS_Support_Org_Name__c='Test Embedded Products';
        insert ProdOrg;
        
        Core_IPS_Supported_Product__c SupportProd=new Core_IPS_Supported_Product__c();
        SupportProd.Core_Product__c=prod.Id;
        SupportProd.Core_Product_Organization__c=ProdOrg.Id;
        insert SupportProd;
        
        Core_IPS_Answer__c Answer=new Core_IPS_Answer__c();
        Answer.Core_IPS_Answer__c='yes';
        Answer.Core_IPS_Status__c='Active';
        Answer.Core_IPS_Question__c=questions.Id;
        insert Answer;
        
        Core_IPS_Assigned_Environment_Variables__c EnvVar=new Core_IPS_Assigned_Environment_Variables__c();
        EnvVar.Core_Supported_Product__c= SupportProd.Id;
        EnvVar.Core_IPS_Question__c=questions.Id;
        insert EnvVar;
        system.assert(EnvVar != null);
        
        String supportedProdId=SupportProd.Id;
        Test.startTest();
        core_IPS_caseCreate_LEX.GetEdqMethod(supportedProdId);
        core_IPS_caseCreate_LEX.getEDQ(supportedProdId);
        core_IPS_caseCreate_LEX.getContactDetails();
        Test.stopTest();
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
            system.debug('ListOfFlatProductHierarchy '+ListOfFlatProductHierarchy); 
            
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
            system.assert(ListOfIpsProjects != null);
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
            core_IPS_caseCreate_LEX.getProductVariants(AssetList[0].Id);
        }
    }
    @isTest
    public static void getCustomSettingLogs_Test(){
        Core_IPS_SSLCCase_DefaultData__c modeTest=new Core_IPS_SSLCCase_DefaultData__c();
        modeTest.Name='Asset';
        modeTest.Core_IPS_Default_Data__c='Licensed Products';
        insert modeTest;
        system.assert(modeTest != null);
        Core_IPS_CaseCreateMode_CTRL.getCustomSettingLogs();
    }
}