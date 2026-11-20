@isTest
public class Core_IPS_Copy_CategoriesEDQ_LEX_Test {
	static testmethod void Test_Core_IPS_Copy_EDQ_Controller() {
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        List<User> userList = new List<user>();
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;
                
        List<Core_IPS_Supported_Product__c> lstSupProd = TestUtilities.getListOfSupportedProduct(2);
        
        System.runAs(userlist[0]) {
            Core_IPS_Product_Organization__c objSupportOrg = TestUtilities.getSupportOrg();
            insert objSupportOrg;
            
            List<Product2> ProductList = TestUtilities.getListOfProduct(2);
            insert ProductList;
            
            for(Core_IPS_Supported_Product__c objSupProd : lstSupProd) {                
                objSupProd.Core_Product_Organization__c = objSupportOrg.Id;
            }
            lstSupProd[0].Core_Product__c = ProductList[0].Id;
            lstSupProd[1].Core_Product__c = ProductList[1].Id;
            insert lstSupProd;
            
            Core_IPS_Question__c objEDQ = TestUtilities.getCoreQuestion();
            objEDQ.Core_IPS_Product_Organization__c = objSupportOrg.Id;
            insert objEDQ;
            
            Core_IPS_Product_Issue_Category__c caseCat = TestUtilities.getCaseCategories();
            caseCat.Core_Type__c = 'Case Category';
            caseCat.Core_Supported_Product__c = lstSupProd[0].Id;
            insert caseCat;
            
            Core_IPS_Product_Issue_Category__c caseSubCat = TestUtilities.getCaseCategories();
            caseSubCat.Core_Type__c = 'Case Subcategory';
            caseSubCat.Core_Product_Issue_Category__c = caseCat.Id;
            insert caseSubCat;
            
            List<Core_IPS_Assigned_Environment_Variables__c> lstEDO = TestUtilities.getListOfEnvDetailsOperational(2);
            lstEDO[0].Core_IPS_Question__c = lstEDO[1].Core_IPS_Question__c = objEDQ.Id;
            lstEDO[0].Core_Supported_Product__c = lstSupProd[0].Id;
            lstEDO[1].Core_Product_Issue_Sub_Category__c = caseSubCat.Id;
            insert lstEDO; 
             System.AssertEquals(lstEDO.size()>0, true);                     
        }
        
        Test.startTest();
        
        
        Core_IPS_Copy_CategoriesEDQ_LEX.checkUserPermission(lstSupProd[0].Id);
        Core_IPS_Copy_CategoriesEDQ_LEX.getSpportedProductList(lstSupProd[0].Id, 0, 0, 'All Data');
        Core_IPS_Copy_CategoriesEDQ_LEX.getSpportedProductList(lstSupProd[0].Id, 0, 0, 'Load Data');
        Core_IPS_Copy_CategoriesEDQ_LEX.copyCaseCatSubCatEDQ(lstSupProd[1].Id, lstSupProd[0].Id);
        Test.stopTest();
    }

}