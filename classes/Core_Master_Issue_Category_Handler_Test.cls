@isTest
public class Core_Master_Issue_Category_Handler_Test{
    static testmethod void updateCaseCategoriesStatus_Test(){
        // Variable Declaration
        List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseCat = new List<Core_IPS_Master_Issue_Category__c> ();
        List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseSubCat = new List<Core_IPS_Master_Issue_Category__c> ();
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = new List<Core_IPS_Product_Issue_Category__c> ();
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseSubCat = new List<Core_IPS_Product_Issue_Category__c> ();
        // Create Core_IPS_Master_Issue_Category__c - Core Master Issue Category - Type : Case Category
        ListOfCoreMasterIssueCategory_CaseCat = TestUtilities.getListOfCoreMastIssCategory(200);
        integer counter = 0;
        for(Core_IPS_Master_Issue_Category__c CoreMasterIssCategory : ListOfCoreMasterIssueCategory_CaseCat){
            CoreMasterIssCategory.Core_type__c = 'Case Category';
            counter++;
        }
        counter = 0;
        insert ListOfCoreMasterIssueCategory_CaseCat;
        System.Assert(ListOfCoreMasterIssueCategory_CaseCat[0].Id != null, 'Record not Created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Category
        ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(200);
        for(Core_IPS_Product_Issue_Category__c CoreProdIssCategory : ListOfCoreProdIssCategory_CaseCat){
            CoreProdIssCategory.Core_type__c = 'Case Category';
            CoreProdIssCategory.Core_Issue_Category_Name__c = ListOfCoreMasterIssueCategory_CaseCat.get(counter).id;
            counter++;
        }
        counter = 0;
        insert ListOfCoreProdIssCategory_CaseCat;
        System.Assert(ListOfCoreProdIssCategory_CaseCat[0].Id != null, 'Record not Created');
        // Create Core_IPS_Master_Issue_Category__c - Core Master Issue Category - Type : Case Subcategory
        ListOfCoreMasterIssueCategory_CaseSubCat = TestUtilities.getListOfCoreMastIssCategory(200);
        for(Core_IPS_Master_Issue_Category__c CoreMasterIssCategory : ListOfCoreMasterIssueCategory_CaseSubCat){
            CoreMasterIssCategory.Core_Master_Issue_Category__c = ListOfCoreMasterIssueCategory_CaseCat.get(counter).id;
            counter++;
        }
        counter = 0;
        insert ListOfCoreMasterIssueCategory_CaseSubCat;
        System.Assert(ListOfCoreMasterIssueCategory_CaseSubCat[0].Id != null, 'Record not Created');
        // Create Core_IPS_Product_Issue_Category__c - Core Product Issue Category - Type : Case Subcategory
        ListOfCoreProdIssCategory_CaseSubCat = TestUtilities.getListOfCoreProdIssCategory(200);
        for(Core_IPS_Product_Issue_Category__c CoreProdIssCategory : ListOfCoreProdIssCategory_CaseSubCat){
            CoreProdIssCategory.Core_Product_Issue_Category__c = ListOfCoreProdIssCategory_CaseCat.get(counter).id;
            CoreProdIssCategory.Core_Issue_Sub_Category_Name__c = ListOfCoreMasterIssueCategory_CaseSubCat.get(counter).id;
            counter++;
        }
        counter = 0;
        insert ListOfCoreProdIssCategory_CaseSubCat;
        System.Assert(ListOfCoreProdIssCategory_CaseSubCat[0].Id != null, 'Record not Created');
        Test.startTest();
        // Testing the Trigger Handler Functionality - "updateCaseCategoriesStatus" Method in Core_Master_Issue_Category_Handler Class
        for(Core_IPS_Master_Issue_Category__c CoreMasterIssCategory : ListOfCoreMasterIssueCategory_CaseSubCat){
            CoreMasterIssCategory.Core_Status__c = 'Inactive';
        }
        update ListOfCoreMasterIssueCategory_CaseSubCat;
        List<Core_IPS_Master_Issue_Category__c> LstOfCoreMasterIssueCategory_CaseSubCat= [select id,Core_Status__c from Core_IPS_Master_Issue_Category__c where Id IN: ListOfCoreMasterIssueCategory_CaseSubCat];
        System.assertEquals(LstOfCoreMasterIssueCategory_CaseSubCat[0].Core_Status__c, 'Inactive');
        for(Core_IPS_Master_Issue_Category__c CoreMasterIssCategory : ListOfCoreMasterIssueCategory_CaseCat){
            CoreMasterIssCategory.Core_Status__c = 'Inactive';
        }
        update ListOfCoreMasterIssueCategory_CaseCat;
        List<Core_IPS_Master_Issue_Category__c> LstOfCoreMasterIssueCategory_CaseCat= [select id,Core_Status__c from Core_IPS_Master_Issue_Category__c where Id IN: ListOfCoreMasterIssueCategory_CaseCat];
        System.assertEquals(LstOfCoreMasterIssueCategory_CaseCat[0].Core_Status__c, 'Inactive');
        // Test Delete DML
        delete ListOfCoreProdIssCategory_CaseCat;
        List<Core_IPS_Product_Issue_Category__c> LstOfCoreProdIssCategory_CaseCat= [select id from Core_IPS_Product_Issue_Category__c where Id IN: ListOfCoreProdIssCategory_CaseCat];
        System.Assert(LstOfCoreProdIssCategory_CaseCat.isEmpty(), 'Record not Deleted');
        delete ListOfCoreMasterIssueCategory_CaseCat;
        List<Core_IPS_Master_Issue_Category__c> CoreMasterIssueCategoryLst_CaseCat= [select id from Core_IPS_Master_Issue_Category__c where Id IN: ListOfCoreMasterIssueCategory_CaseCat];
        System.Assert(CoreMasterIssueCategoryLst_CaseCat.isEmpty(), 'Record not Deleted');
        // Test Undelete DML
        undelete ListOfCoreMasterIssueCategory_CaseCat;
        List<Core_IPS_Master_Issue_Category__c> CoreMasterIssueCategoryList_CaseCat = [select id from Core_IPS_Master_Issue_Category__c where Id IN: ListOfCoreMasterIssueCategory_CaseCat];
        System.Assert(CoreMasterIssueCategoryList_CaseCat[0].Id != null, 'Record not UnDeleted');
        Test.stopTest();
    }
}