/****************************************************************************************************************************************
* Class Name  : PMP_CategoryTriggerHandler_Test  
* Version     : 1.0 
* Created Date: 03-07-2020
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* MP Team - Raj Yadav			03-07-2020					  Test class for PMP_CategoryTriggerHandler
*****************************************************************************************************************************************/
@isTest
public class PMP_CategoryTriggerHandler_Test {
    
    static testMethod void afterInsertTest(){
        
        PMP_ParentCategoryUpdate_Test.updateParentOnInsertTest();
        System.assertEquals(true, PMP_CategoryTriggerHandler.triggerSwitch);
        
    }
    
    static testMethod void afterUpdateTest(){
        test.startTest();
        PMP_Category__c testCategorySystem = new PMP_Category__c();
        testCategorySystem.Name = 'System';
        testCategorySystem.PMP_Active_Ind__c = false;
        testCategorySystem.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategorySystem.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        testCategorySystem.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategorySystem.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategorySystem.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        insert testCategorySystem;
        
        testCategorySystem.Name = 'Systems';
        update testCategorySystem;
        
        System.assertEquals('Systems', testCategorySystem.Name);
        test.stopTest();
    }

}