/****************************************************************************************************************************************
* Class Name  : PMP_ParseCategoryJSON_Test 
* Version     : 1.0 
* Created Date: 09-07-2018
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     09/07/2018                    Test Class
* Infosys - Sangeetha Ganta     12/24/2018                    User Story - US244679. Sequencing of Categories
*****************************************************************************************************************************************/

@isTest
public class PMP_ParseCategoryJSON_Test {
    
    public static testMethod void parseEnglishCategoryJSONTest(){
        
     Test.startTest();
        //Create a category
        
        PMP_Category__c testCategoryCategories = new PMP_Category__c();
        testCategoryCategories.Name = 'Categories';
        testCategoryCategories.PMP_Active_Ind__c = true;
        testCategoryCategories.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategoryCategories.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        testCategoryCategories.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        testCategoryCategories.PMP_Display_Type_Nm__c = 'Label';
        testCategoryCategories.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
        
        insert testCategoryCategories;
        
        PMP_Category__c testCategorySystem = new PMP_Category__c();
        testCategorySystem.Name = 'System';
        testCategorySystem.PMP_Active_Ind__c = true;
        testCategorySystem.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategorySystem.PMP_Parent_Category_Id__c = testCategoryCategories.id;
        testCategorySystem.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        testCategorySystem.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategorySystem.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategorySystem.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        insert testCategorySystem;
        
        PMP_Category__c testCategoryComp = new PMP_Category__c();
        testCategoryComp.Name = 'Component';
        testCategoryComp.PMP_Active_Ind__c = false;
        testCategoryComp.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategoryComp.PMP_Parent_Category_Id__c = testCategoryCategories.id;
        testCategoryComp.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Cmp';
        testCategoryComp.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategoryComp.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategoryComp.PMP_Partner_Product_Category_Key__c = 'npp_02_type_cmp';
        
        insert testCategoryComp;
    
        PMP_ParseCategoryJSON.languageCode = 'en_US';
        PMP_ParseCategoryJSON.parseCategoryJSON('Test_Category_Hierarchy');
        System.assertEquals(testCategoryComp.PMP_Parent_Category_Id__c, testCategoryCategories.id);

    Test.stopTest();          
    }
    
    public static testMethod void parseChineseCategoryJSONTest(){
        
     Test.startTest();
        //Create a category
        
        PMP_Category__c testCategoryCategories = new PMP_Category__c();
        testCategoryCategories.Name = 'Categories';
        testCategoryCategories.PMP_Active_Ind__c = true;
        testCategoryCategories.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategoryCategories.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        testCategoryCategories.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        testCategoryCategories.PMP_Display_Type_Nm__c = 'Label';
        testCategoryCategories.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
        
        insert testCategoryCategories;
        
        PMP_Category__c testCategorySystem = new PMP_Category__c();
        testCategorySystem.Name = 'System';
        testCategorySystem.PMP_Active_Ind__c = true;
        testCategorySystem.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategorySystem.PMP_Parent_Category_Id__c = testCategoryCategories.id;
        testCategorySystem.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        testCategorySystem.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategorySystem.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategorySystem.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        insert testCategorySystem;
        
        PMP_Category__c testCategoryComp = new PMP_Category__c();
        testCategoryComp.Name = 'Component';
        testCategoryComp.PMP_Active_Ind__c = false;
        testCategoryComp.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategoryComp.PMP_Parent_Category_Id__c = testCategoryCategories.id;
        testCategoryComp.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Cmp';
        testCategoryComp.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategoryComp.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategoryComp.PMP_Partner_Product_Category_Key__c = 'npp_02_type_cmp';
        
        insert testCategoryComp;
    
        PMP_ParseCategoryJSON.languageCode = 'zh_CN';
        PMP_ParseCategoryJSON.parseCategoryJSON('Test_Category_Hierarchy');
        System.assertEquals(testCategoryComp.PMP_Parent_Category_Id__c, testCategoryCategories.id);

    Test.stopTest();          
    }
    
    public static testMethod void parseJapaneseCategoryJSONTest(){
        
     Test.startTest();
        //Create a category
        
        PMP_Category__c testCategoryCategories = new PMP_Category__c();
        testCategoryCategories.Name = 'Categories';
        testCategoryCategories.PMP_Active_Ind__c = true;
        testCategoryCategories.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategoryCategories.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        testCategoryCategories.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        testCategoryCategories.PMP_Display_Type_Nm__c = 'Label';
        testCategoryCategories.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
        
        insert testCategoryCategories;
        
        PMP_Category__c testCategorySystem = new PMP_Category__c();
        testCategorySystem.Name = 'System';
        testCategorySystem.PMP_Active_Ind__c = true;
        testCategorySystem.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategorySystem.PMP_Parent_Category_Id__c = testCategoryCategories.id;
        testCategorySystem.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Sys';
        testCategorySystem.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategorySystem.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategorySystem.PMP_Partner_Product_Category_Key__c = 'npp_02_type_sys';
        
        insert testCategorySystem;
        
        PMP_Category__c testCategoryComp = new PMP_Category__c();
        testCategoryComp.Name = 'Component';
        testCategoryComp.PMP_Active_Ind__c = false;
        testCategoryComp.PMP_Business_Segment_Nm__c = 'IoT;Server';
        testCategoryComp.PMP_Parent_Category_Id__c = testCategoryCategories.id;
        testCategoryComp.PMP_Partner_Product_Category_Cd__c = 'NPP_02_TYPE_Cmp';
        testCategoryComp.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
        testCategoryComp.PMP_Display_Type_Nm__c = 'Radiobutton';
        testCategoryComp.PMP_Partner_Product_Category_Key__c = 'npp_02_type_cmp';
        
        insert testCategoryComp;
    
        PMP_ParseCategoryJSON.languageCode = 'ja_JP';
        PMP_ParseCategoryJSON.parseCategoryJSON('Test_Category_Hierarchy');
        System.assertEquals(testCategoryComp.PMP_Parent_Category_Id__c, testCategoryCategories.id);

    Test.stopTest();          
    }
}