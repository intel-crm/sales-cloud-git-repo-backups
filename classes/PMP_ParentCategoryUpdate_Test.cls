/****************************************************************************************************************************************
* Class Name  : PMP_ParentCategoryUpdate_Test  
* Version     : 1.0 
* Created Date: 03-07-2020
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* MP Team - Raj Yadav			03-07-2020					  Test class for PMP_ParentCategoryUpdate
*****************************************************************************************************************************************/
@isTest
public class PMP_ParentCategoryUpdate_Test {
    
    public static testMethod void updateParentOnInsertTest(){
        
        List<PMP_Category__c> uploadableCategories = new List<PMP_Category__c>();
        
        Test.startTest();
        PMP_Category__c testCategoryCategories = new PMP_Category__c();
        testCategoryCategories.Name = 'Categories';
        testCategoryCategories.PMP_Active_Ind__c = true;
        testCategoryCategories.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategoryCategories.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        testCategoryCategories.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        testCategoryCategories.PMP_Display_Type_Nm__c = 'Label';
        testCategoryCategories.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
        
        PMP_Category__c testCategorySystem = new PMP_Category__c();
        testCategorySystem.Name = 'System';
        testCategorySystem.PMP_Active_Ind__c = false;
        testCategorySystem.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategorySystem.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        testCategorySystem.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategorySystem.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategorySystem.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        PMP_Category__c testCategoryComp = new PMP_Category__c();
        testCategoryComp.Name = 'Component';
        testCategoryComp.PMP_Active_Ind__c = true;
        testCategoryComp.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategoryComp.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Cmp';
        testCategoryComp.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategoryComp.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategoryComp.PMP_Partner_Product_Category_Key__c = 'npp_02_type_cmp';
        
        uploadableCategories.add(testCategoryCategories);
        uploadableCategories.add(testCategorySystem);
        uploadableCategories.add(testCategoryComp);
        
        insert uploadableCategories;
    	
        PMP_ParentCategoryUpdate.updateParentOnInsert(uploadableCategories);
        PMP_Category__c cat = [Select Id,PMP_Parent_Category_Id__c from PMP_Category__c where id =: testCategoryComp.id];
        System.assertEquals(cat.PMP_Parent_Category_Id__c, testCategoryCategories.id);

    	Test.stopTest();          
    }
    
}