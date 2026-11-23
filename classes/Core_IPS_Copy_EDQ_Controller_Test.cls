/***************************************************************************************************
* Apex Class Name: Core_IPS_Copy_EDQ_Controller_Test
* Description    : Test class for Core_IPS_Copy_EDQ_Controller
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                    17/05/2018             Created
****************************************************************************************************/
@isTest 
public class Core_IPS_Copy_EDQ_Controller_Test {
    
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
        }
        
        Test.startTest();
        
        Pagereference pgref = Page.Core_IPS_Copy_EnvironmentDetails;
        pgref.getParameters().put('id', lstSupProd[0].Id);
        Test.setCurrentPage(pgref);
        
        Core_IPS_Copy_EDQ_Controller instCopyED = new Core_IPS_Copy_EDQ_Controller(new ApexPages.StandardController(lstSupProd[0]));
        instCopyED.selectedSupProd = lstSupProd[1].Id;
        instCopyED.copyDetails();
        instCopyED.cancel();
        instCopyED.ErrorMessage = null;
    }

}