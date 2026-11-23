/*****************************************************************************************************************************************************************
* Class Name  : PMP_ProductPartnerDetailsController_Test 
* Version     : 1.0 
* Created Date: 06-27-2019 
* Modification Log :
*
* Developer                           Date                          Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team                          06-27-2019                    Test class of PMP_ProductPartnerDetailsController apex class
******************************************************************************************************************************************************************/
@isTest
public class PMP_ProductPartnerDetailsController_Test extends PMP_SearchWrapperStore{
	
    static testMethod void getPartnerDetailsPositiveTest(){
        
       
        
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
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
        
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,false);
        cmp1.PMP_Account_Industry__c = 'Agriculture';
        cmp1.PMP_Account_Application__c= 'Storage';
        cmp1.PMP_Account_Region__c = 'APJ';
        cmp1.PMP_Account_Sub_Region__c = 'ANZ';
       cmp1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist;LOEM-ODM Partner Program';
        cmp1.PMP_Account_Dsc__c = 'Description below the limit.';
        cmp1.PMP_Account_Website__c = 'www.TestCompany1.com';
        cmp1.PMP_Company_Lead_Gen_Language_Nm__c='English';
        cmp1.PMP_Partner_Program_nm__c='ODM-LOEM';
        //cmp1.PMP_Account_Program_Membership__c='Member';
        cmp1.PMP_Account_Program_Membership__c='ITP - Gold';
       cmp1.PMP_Account_Program_Membership__c='LOEM-ODM Partner Program';
        
   //  cmp1.PMP_Account_Specialty__c=PMP_Static_Constants__c.getValu'LOEM-ODM Partner Program');
        
        cmp1.PMP_Is_Published_Ind__c = true;
        insert cmp1;
        system.debug('cmp1'+cmp1);
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Company_Resource__c resource=new PMP_Company_Resource__c();
        resource.PMP_Company_Id__c=cmp1.Id;
        resource.PMP_Company_Image__c=document.Id;
        resource.PMP_Company_Resource_Type_Nm__c='Image';
        resource.PMP_Company_Resource_Sequence_Nbr__c=0;
        insert resource;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
       //partner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        //partner1.PMP_Account_Specialty__c=PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program;
        partner1.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        partner1.PMP_Is_Published_Ind__c = true;
        insert partner1;
        
        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = cmp1.Id;
        insert off;
       
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = cmp1.Id;
        insert off1;
        
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec2;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue;
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec.PMP_Company_Id__c = cmp1.Id;
        insert ptnrSpec;
        
        PMP_Company_Region__c ptnrSpec1 = new PMP_Company_Region__c();
        ptnrSpec1.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec1.PMP_Company_Id__c = partner1.Id;
        insert ptnrSpec1;
        
        PMP_Company_Region__c ptnrSpec2 = new PMP_Company_Region__c();
        ptnrSpec2.PMP_Specification_Id__c = spec2.Id;
        ptnrSpec2.PMP_Company_Id__c = cmp1.Id;
        insert ptnrSpec2;
        
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
       	//cat0.PMP_Parent_Category_Id__c = null; 
        //app0.PMP_Parent_Category_Id__c = null;
        //ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        update catList;
        
        PMP_Partner_Category__c ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = app1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp1.Id;
        insert ptnrCat;
        
        PMP_Partner_Category__c ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = app1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        PMP_Partner_Category__c ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = app2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = ind1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp1.Id;
        insert ptnrCat;
        
        ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = ind1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = ind2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        Test.startTest();
        system.debug('testing===>'+cmp1);
        Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(cmp1.Id,null,true,'en_US');
        
        System.assertEquals(cmp1.Name, partner.name);
        System.assertEquals(cmp1.Id, partner.id);
      /*for(Attribute att : partner.attributes){
            for(Types type : att.types){
                //if(att.Name == 'Specialty'){
                if(att.Name == 'LOEM_ODM_Partner_Program'){
                    System.assertEquals(cmp1.PMP_Account_Specialty__c, type.name);
                }
                //Assumption : Company record created above has PMP_Partner_Program_nm__c as 'ITP' and PMP_Account_Program_Membership__c as 'ITP - GOLD'
                //if(att.Name == 'Program Membership'){
                if(att.Name == 'LOEM_ODM_Partner_Program'){
                    System.assertEquals('Intel® Technology Provider Program - GOLD', type.name);
                }
            }
        }
        Test.stopTest();*/
        
    }
    
    @isTest static void getPartnerDetailsNegativeTest(){
        
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
       PMP_Company__c cmp2=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,false);
        Test.startTest();
        Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(cmp2.Id, null, true, 'en_US');
        //Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(null, null, true, 'en_US');
        
        System.assertEquals(null, partner.name);
        System.assertEquals(null, partner.id);        
    }
    
    @isTest static void testGetRegionAttribute(){
        /*Account acc1=PMP_TestDataUtility.createIntelAccount('account2',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c partner=PMP_TestDataUtility.createCompanyInformation('TestCompny2',acc1.Id,true);
        
        PMP_Specification__c specification=new PMP_Specification__c();
        specification.Name='Geographic Coverage';
        specification.PMP_Partner_Product_Specification_Id__c='NPP_GeographicCoverage';
        specification.PMP_Product_Parent_Specification_Id__c='NPP_GeographicCoverage';
        specification.PMP_Active_Ind__c=true;
        insert specification;
        
        PMP_Specification__c specification1=new PMP_Specification__c();
        specification1.Name='Geographic Coverage';
        specification1.PMP_Partner_Product_Specification_Id__c='NPP_GeographicCoverage';
        specification1.PMP_Product_Parent_Specification_Id__c='NPP_GeographicCoverage';
        specification1.PMP_Active_Ind__c=true;
        specification1.PMP_Parent_Specification_Id__c=specification.Id;
        insert specification1;
        
        PMP_Company_Region__c reg = new PMP_Company_Region__c();
        reg.PMP_Company_Id__c = partner.Id;
        reg.PMP_Specification_Id__c=specification1.Id;*/
        
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        update cmp1;
        
        PMP_Company__c partner = new PMP_Company__c();
        partner.Name = 'Test_Partner';
        partner.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        partner.PMP_Is_Published_Ind__c = true;
        insert partner;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
        partner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        partner1.PMP_Is_Published_Ind__c = true;
        insert partner1;
        
        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = partner.Id;
        insert off;
       
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = partner.Id;
        insert off1;
        
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec2;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue;
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec.PMP_Company_Id__c = partner.Id;
        insert ptnrSpec;
        
        PMP_Company_Region__c ptnrSpec1 = new PMP_Company_Region__c();
        ptnrSpec1.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec1.PMP_Company_Id__c = partner1.Id;
        insert ptnrSpec1;
        
        PMP_Company_Region__c ptnrSpec2 = new PMP_Company_Region__c();
        ptnrSpec2.PMP_Specification_Id__c = spec2.Id;
        ptnrSpec2.PMP_Company_Id__c = partner.Id;
        insert ptnrSpec2;
        
        
        Test.startTest();
        Attribute attr=PMP_ProductPartnerDetailsController.getRegionAttribute(partner.Id, false, 'en_US');
        System.assertNotEquals(null, attr);
        Test.stopTest();
    }
    
    @isTest static void testGetCategoryAttribute(){
        
        Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        
        PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
       // cmp1.PMP_Account_Specialty__c=PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program;
        update cmp1;
        
        PMP_Company__c partner = new PMP_Company__c();
        partner.Name = 'Test_Partner';
        partner.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
       // partner.PMP_Account_Specialty__c=PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program;
        partner.PMP_Is_Published_Ind__c = true;
        insert partner;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
        partner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        //spartner1.PMP_Account_Specialty__c=PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program;
        partner1.PMP_Is_Published_Ind__c = true;
        insert partner1;
        
        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = partner.Id;
        insert off;
       
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = partner.Id;
        insert off1;
        
         List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
       	//cat0.PMP_Parent_Category_Id__c = null; 
        //app0.PMP_Parent_Category_Id__c = null;
        //ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        update catList;
        
        PMP_Partner_Category__c ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = app1.Id;
        ptnrCat.PMP_Partner_Id__c = partner.Id;
        insert ptnrCat;
        
        PMP_Partner_Category__c ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = app1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        PMP_Partner_Category__c ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = app2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = ind1.Id;
        ptnrCat.PMP_Partner_Id__c = partner.Id;
        insert ptnrCat;
        
        ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = ind1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = ind2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        Test.startTest();
        Attribute attr=PMP_ProductPartnerDetailsController.getCategoryAttribute(partner1.Id, false, 'NPP_01_Industry', 'en_US');
        System.assertNotEquals(null, attr);
        Test.stopTest();
        
      
    }
        
        
}