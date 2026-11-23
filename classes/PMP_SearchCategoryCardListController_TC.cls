@isTest
private class PMP_SearchCategoryCardListController_TC extends PMP_SearchWrapperStore {
   
    @isTest static void testCategoryCardList(){ 
        Test.startTest();
         
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Off_Sort_By_Featured';
        st.PMP_Value__c = 'PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Status_Update_Dt__c DESC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Partner_Sort_By_Name_Desc';
        st.PMP_Value__c = 'Name DESC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Application_Id';
        st.PMP_Value__c = 'NPP_01_APP';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Region_Id';
        st.PMP_Value__c = 'NPP_GeographicCoverage';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_LOEM_ODM_Partner_Program';
        st.PMP_Value__c = 'LOEM-ODM Partner Program';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_BENEFIT_ENHANCED_CODE';
        st.PMP_Value__c = 'BFTMKTPLED';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Sys_Admin_Profile';
        st.PMP_Value__c = 'System Administrator';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_IT_Admin_Profile';
        st.PMP_Value__c = '	IT Admin';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Thumbnail_Image';
        st.PMP_Value__c = 'Thumbnail Image';
        stList.add(st);
        
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_LDR',PMP_Value__c='PMP_External_Lead_Development_Representative'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Marketing_Specialist',PMP_Value__c='PMP_External_Marketing_Specialist'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Offering_Editor',PMP_Value__c='PMP_External_Offering_Editor'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Partner_Admin',PMP_Value__c='PMP_External_Partner_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Guest_User_Name',PMP_Value__c='Intel® Solutions Marketplace Site Guest User'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP - All Intel Admin Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        insert stList;
     
        PMP_Category__c category = new PMP_Category__c();
        category.name = 'Categories';
        category.PMP_Partner_Product_Category_Cd__c= 'NPP_01_Type';
        //category.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_Taxonomy';
        category.PMP_Partner_Product_Parent_Category_Cd__c = 'TPS_900002';
        category.PMP_Active_Ind__c=true;
        insert category;
        
        PMP_Category__c category1 = new PMP_Category__c();
        category1.name = 'Component';
        category1.PMP_Parent_Category_Id__c = category.id;
        category1.PMP_Partner_Product_Category_Cd__c = 'NPP_02_Comp';
        category1.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_Type';
        category1.PMP_Active_Ind__c=true;
        insert category1; 
        
        
        
        
        System.assertEquals(1, PMP_SearchCategoryCardListController.getCategoryData('Product', 'en_US').size());
        Test.stopTest(); 
    }
    
    @isTest static void testGetPartnerPrograms(){
        PMP_Static_Constants__c st7 = new PMP_Static_Constants__c();
        st7.Name = 'PMP_LOEM_ODM_Partner_Program';
        st7.PMP_Value__c = 'LOEM-ODM Partner Program';
        insert st7;
       Test.startTest();
       PMP_SearchCategoryCardListController.getPartnerPrograms('en_US');
      
       System.assertNotEquals(null, PMP_SearchCategoryCardListController.getPartnerPrograms('en_US').size()); 
       Test.stopTest();
    }
}