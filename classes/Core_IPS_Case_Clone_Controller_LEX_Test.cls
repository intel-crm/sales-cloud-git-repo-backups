@istest
public class Core_IPS_Case_Clone_Controller_LEX_Test {
    static testmethod void Method_getCaseDetails() {
     Profile ps = [select id, name from Profile where name = 'System Administrator'limit 1]; 
    ID recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        UserRole role=new UserRole();
        role.name='CEO';
        insert role;
    
    	User sysAdimUser = TestUtilities.getUser();
        sysAdimUser.ProfileId = ps.id;
        sysAdimUser.userroleid=role.id;
        
        insert sysAdimUser;   
        List < Account > ListOfAccounts = new List<Account>();
         List < Contact > ListOfContacts = new List<Contact>();
  
        System.runAs(sysAdimUser) {
             ListOfAccounts = TestUtilities.getAccountsList(1);
       		 ListOfAccounts.get(0).OwnerId = sysAdimUser.id;
             ListOfAccounts.get(0).Core_IPS_Active__c = true;
             ListOfAccounts.get(0).Core_B2B_Entitlement__c = true;
             ListOfAccounts.get(0).Core_CNDA_Number__c = '12523';
             
             insert ListOfAccounts;
             System.assert(ListOfAccounts[0].Id != null, 'Record not created');
             ListOfContacts = TestUtilities.getListOfContact(1);
                for (Contact ContactRec: ListOfContacts) {
                    ContactRec.Accountid = ListOfAccounts.get(0).Id;
                    ContactRec.Core_IPS_Active__c = true;
                    ContactRec.Core_Country_Region__c = 'India';
                } 
            insert ListOfContacts;
           System.assert(ListOfContacts[0].id != null, 'Record not created');
        
        	List < Product2 > ListOfProducts = TestUtilities.getListOfProduct(1);
            for (Product2 Product: ListOfProducts) {
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';

            }
            insert ListOfProducts;
             System.assert(ListOfProducts[0].id != null, 'Record not created');
             // Create Support Org
            List < Core_IPS_Product_Organization__c > ListOfSupportOrg = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Record not created');
            // Create Supported product
             List < Core_IPS_Supported_Product__c > ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            for (Core_IPS_Supported_Product__c SupportedProduct: ListOfSupportedProduct) {
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;

            }
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].id != null, 'Record not created');
            Asset asst = TestUtilities.getAsset();
            asst.Core_Supported_Product__c = ListOfSupportedProduct[0].Id;
            Asst.product2Id = ListOfProducts.get(0).id;
            Asst.Core_product_organization__c = ListOfSupportOrg.get(0).id;
            insert Asst;
            System.assert(Asst.Id != null, 'Record not created');
            
            // Create Case
            List <case>ListOfCases = TestUtilities.getListOfCases(10);
            for (Case CaseRec: ListOfCases) {
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.AssetId = Asst.id;
                CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                CaseRec.Status = 'Closed';
            }
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
             
             ListOfCases.get(0).Core_Case_Issue_Category__c = caseCat.id;
             ListOfCases.get(0).Core_case_issue_sub_category__c = subCategory.id;
             insert ListOfCases;
            

                System.assert(ListOfCases[0].Id != null, 'Record not created');
            //Core_IPS_Case_Clone_Controller_LEX getCaseDetails
            Core_IPS_Case_Clone_Controller_LEX.getCaseDetails(ListOfCases[0].Id);
            Core_IPS_Case_Clone_Controller_LEX.geCloneCaseDetails(ListOfCases[0].Id);
            Core_IPS_Case_Clone_Controller_LEX.saveCaseDetails();
            Core_IPS_Case_Clone_Controller_LEX.displayProductVariant(Asst.Id); 
            Core_IPS_Case_Clone_Controller_LEX.displaySubCategoryData(subCategory.Id);
            Core_IPS_Case_Clone_Controller_LEX.displayCategoryData(caseCat.Id);
            Core_IPS_Case_Clone_Controller_LEX.getBaseUrlToLoadIframePage();
            Core_IPS_Case_Clone_Controller_LEX.insertCaseData(ListOfCases);
                List < Core_IPS_Error_Code__c > errorCodes = TestUtilities.getListOfIpsErrorCodes();
                insert errorCodes;
                System.assert(errorCodes[0].Id != null, 'Record not created');
        }
    }
    
    
     //Added by Sowmya - Start - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
      static testmethod void createcloneCase() {
          
     	Profile ps = [select id, name from Profile where name = 'System Administrator'limit 1]; 
    	ID recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        UserRole role=new UserRole();
        role.name='CEO';
       	insert role;
    
    	User sysAdimUser = TestUtilities.getUser();
        sysAdimUser.ProfileId = ps.id;
        sysAdimUser.userroleid=role.id;
        insert sysAdimUser;
          
        List < Account > ListOfAccounts = new List<Account>();
        List < Contact > ListOfContacts = new List<Contact>();
        List<case> ListOfCases = new  List<case>();
  		Asset asst = new Asset();
        
          System.runAs(sysAdimUser) {
             ListOfAccounts = TestUtilities.getAccountsList(1);
       		 ListOfAccounts.get(0).OwnerId = sysAdimUser.id;
             ListOfAccounts.get(0).Core_IPS_Active__c = true;
             ListOfAccounts.get(0).Core_B2B_Entitlement__c = true;
             ListOfAccounts.get(0).Core_CNDA_Number__c = '12523';
             ListOfAccounts.get(0).Core_Military_Aerospace_and_Government__c	= False;
             insert ListOfAccounts;
             
              System.assert(ListOfAccounts[0].Id != null, 'Record not created');
              ListOfContacts = TestUtilities.getListOfContact(1);
                for (Contact ContactRec: ListOfContacts) {
                    ContactRec.Accountid = ListOfAccounts.get(0).Id;
                    ContactRec.Core_IPS_Active__c = true;
                    ContactRec.Core_Country_Region__c = 'India';
                } 
            insert ListOfContacts;
          System.assert(ListOfContacts[0].id != null, 'Record not created');
         
         }  
          
         Profile ps1 = [select id, name from Profile where name = 'IPS External Customer'limit 1]; 
		 User externaluser = TestUtilities.getUser();
         externaluser.ProfileId = ps1.id;
         externaluser.ContactId = ListOfContacts[0].Id;
         Insert externaluser;
      
          	System.runAs(sysAdimUser) {
       
        	List < Product2 > ListOfProducts = TestUtilities.getListOfProduct(1);
            for (Product2 Product: ListOfProducts) {
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';

            }
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null, 'Record not created');
            
            // Create Support Org
            List < Core_IPS_Product_Organization__c > ListOfSupportOrg = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Record not created');
            
            // Create Supported product
            List < Core_IPS_Supported_Product__c > ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            for (Core_IPS_Supported_Product__c SupportedProduct: ListOfSupportedProduct) {
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;

            }
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].id != null, 'Record not created');
            asst = TestUtilities.getAsset();
            asst.Core_Supported_Product__c = ListOfSupportedProduct[0].Id;
            Asst.product2Id = ListOfProducts.get(0).id;
            Asst.Core_product_organization__c = ListOfSupportOrg.get(0).id;
            insert Asst;
            System.assert(Asst.Id != null, 'Record not created');
            
            // Create Case
            ListOfCases = TestUtilities.getListOfCases(10);
            for (Case CaseRec: ListOfCases) {
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.AssetId = Asst.id;
                CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                CaseRec.Status = 'Closed';
             
           
            }
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
             
             ListOfCases.get(0).Core_Case_Issue_Category__c = caseCat.id;
             ListOfCases.get(0).Core_case_issue_sub_category__c = subCategory.id;
             insert ListOfCases;
            

             System.assert(ListOfCases[0].Id != null, 'Record not created');
          
     	 }
          System.runas(externaluser){
          
            Core_IPS_Case_Clone_Controller_LEX.createcloneCase(ListOfCases);
          
        }
    }
 // Sowmya - End - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
}