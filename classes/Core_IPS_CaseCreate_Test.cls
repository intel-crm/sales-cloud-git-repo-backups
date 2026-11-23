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
        
        Core_IPS_Master_Issue_Category__c masterIssue=new Core_IPS_Master_Issue_Category__c();
        masterIssue.Core_Status__c='Active';
        masterIssue.Core_Type__c='MasterIssue';
        masterIssue.Name='Test Firmware/BIOS';
        insert masterIssue;
        
        Core_IPS_Product_Issue_Category__c category=new Core_IPS_Product_Issue_Category__c();
        category.Core_Issue_Sub_Category_Name__c=masterIssue.Id;
        category.Core_Type__c='Test Case Subcategory';
        category.Core_Status__c='Active';
        //category.Core_Supported_Product__c='a2E1J000000KbPyUAK';
        category.Core_Supported_Product__c=supportProd.Id;
        insert category;
        String categoryId=category.Id;
        core_IPS_caseCreate_LEX.getCaseSubCategories(categoryId);
        Core_IPS_Project__c projectRecord=new Core_IPS_Project__c();
        projectRecord.Name='Test CC';
        projectRecord.Core_Status__c='Draft';
        insert projectRecord;
        
        Core_Flat_Product_Hierarchy__c flatProduct=new Core_Flat_Product_Hierarchy__c();
        flatProduct.Core_EPM_Hierarchy_Name__c='test Flatproduct';
        flatProduct.Core_L1_EPM_ID__c='36786';
        flatProduct.Core_L1_EPM_Name__c='Programs';
        flatProduct.Core_L2_EPM_ID__c='36786';
        flatProduct.Core_L2_EPM_Name__c='Pre-Sales Products';
        flatProduct.Core_Unique_ID__c='36786;36786;36786;36786;36786';
        insert flatProduct;
        
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_Product_Organization__c=prodOrg.Id;
        assetProduct.Core_Supported_Product__c=supportProd.Id;
        assetProduct.Core_IPS_Project__c=projectRecord.Id;
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
        
        Core_IPS_Product_Organization__c prodOrg=new Core_IPS_Product_Organization__c();
        prodOrg.Core_Organization_Description__c='Test Description';
        prodOrg.Core_IPS_Support_Org_Name__c='Test Embedded Products';
        insert prodOrg;
        
        Core_IPS_Supported_Product__c supportProd=new Core_IPS_Supported_Product__c();
        supportProd.Core_Product__c=prod.Id;
        supportProd.Core_Product_Organization__c=prodOrg.Id;
        insert supportProd;
        
        Core_IPS_Answer__c answerRecord=new Core_IPS_Answer__c();
        answerRecord.Core_IPS_Answer__c='yes';
        answerRecord.Core_IPS_Status__c='Active';
        answerRecord.Core_IPS_Question__c=questions.Id;
        insert answerRecord;
        
        Core_IPS_Assigned_Environment_Variables__c envVar=new Core_IPS_Assigned_Environment_Variables__c();
        envVar.Core_Supported_Product__c= supportProd.Id;
        envVar.Core_IPS_Question__c=questions.Id;
        insert envVar;
        system.assert(envVar != null);
        
        String supportedProdId=supportProd.Id;
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
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
                contactRec.Accountid = listOfAccounts.get(0).Id;
            }
            insert listOfContacts;
            
            List<Core_Flat_Product_Hierarchy__c> listOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(1);
            listOfFlatProductHierarchy[0].Core_Unique_ID__c  =';75025;128758;123707;123704;94489';
            insert listOfFlatProductHierarchy;
            
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssets(listOfAccounts, 1);
            list<Core_IPS_Supported_Product__c> sps = new list<Core_IPS_Supported_Product__c>();    
            for(Asset assetRecord : assetList){
                assetRecord.accountId = listOfAccounts.get(0).Id;
                assetRecord.Contactid = listOfContacts.get(0).id;
                sps.add(new  Core_IPS_Supported_Product__c(id=assetRecord.core_supported_product__c, Core_IPS_Is_Show_Variant__c = true, Core_Product_EPM_ID__c = '75025'));
            }
            update  sps;  
            update assetList; 
            
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        	insert listOfIpsProjects;
            system.assert(listOfIpsProjects != null);
           // Contact con = [Select Id, AccountId FROM Contact WHERE  Account.Name = 'TestAcct0' Limit 1];
            RecordType assetRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Asset' AND Name ='IPS Asset'];
       		//Create Support Org
            Core_IPS_Product_Organization__c supOrg = new Core_IPS_Product_Organization__c(); //SupportOrg
            supOrg.Core_IPS_Support_Org_Name__c='Trident Solutions';
            supOrg.Core_Organization_Description__c='This is from portal side';
            insert supOrg;
            //List Of Products
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
            listOfProducts.get(0).Core_Product_Name_EPM_ID__c='75025';
            listOfProducts[0].IsActive = true;
            listOfProducts[0].Core_Code_Name_EPM_ID__c ='75025';
            listOfProducts[0].Name = 'Haswell processor';
            listOfProducts[0].IsActive = true;
            listOfProducts[0].Core_Product_Status__c= 'Active';
            listOfProducts[0].Core_IPS_Visible_Flag_External__c = true;
            listOfProducts[0].Core_IPS_Visible_Flag_Internal__c = 'Yes';
            listOfProducts[0].Core_Product_Org__c = 'IPS';
            listOfProducts[0].Core_Hierarchy_ID__c = '43';
            
            insert listOfProducts;
             //Create Supported product Record
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            listOfSupportedProduct[0].Core_Product__c = listOfProducts[0].id;
            listOfSupportedProduct[0].Core_Product_Organization__c = supOrg.Id;
            listOfSupportedProduct[0].Core_Flag_Status__c = 'Auto Approve';
            listOfSupportedProduct[0].Core_Product_EPM_ID__c = '75025';
            listOfSupportedProduct[0].Core_Supported_Product_Name__c = 'Haswell processor';
            upsert listOfSupportedProduct;
            
            List<Asset> listofAssets= TestUtilities.getAssetList(1);
            listofAssets[0].Product2Id = listOfProducts[0].id;
            listofAssets[0].Name = 'Haswell processor';
            listofAssets[0].AccountID =  listOfContacts[0].AccountId;
            listofAssets[0].Core_Project_Asset_Status__c='Active';
            listofAssets[0].status ='Active';
            listofAssets[0].RecordTypeID= assetRecType.id;
            listofAssets[0].Core_IPS_Asset__c = true;
            listofAssets[0].Core_Code_Name__c = 'false';
            listofAssets[0].Core_Supported_Product__c = listOfSupportedProduct[0].id;
            listofAssets[0].Core_Product_Organization__c =  supOrg.Id;
            listofAssets[0].InstallDate = system.today();
            
            insert listofAssets;
            core_IPS_caseCreate_LEX.getProductVariants(assetList[0].Id);
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