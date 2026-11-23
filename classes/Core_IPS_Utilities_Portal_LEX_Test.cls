@isTest
public class Core_IPS_Utilities_Portal_LEX_Test {
 @isTest
    public static void getAllFieldsAccessibleTest(){
        test.startTest();
        Profile ps = [select id, name from Profile where name = 'System Administrator'limit 1];
        ID recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        UserRole role=new UserRole();
        role.name='CEO';
        insert role;
        User sysAdimUser = TestUtilities.getUser();
        sysAdimUser.ProfileId = ps.id;
        sysAdimUser.userroleid=role.id;
        
        insert sysAdimUser;
        System.runAs(sysAdimUser) {
        Case cs = new Case();
        cs.Subject = 'Test case';
        cs.Status = 'New';
       
        Set<String> csIds = new Set<String>();
        csIds.add(cs.Id);
            Utilities_Portal_LEX.getAllFieldsAccessible(csIds,cs);}
		test.stopTest();
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