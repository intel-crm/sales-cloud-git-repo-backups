@isTest
public class PMP_MarketplaceNewPartnerDetail_Test {
    static testMethod void getPartnerDetailsPositiveTest(){
        Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName); 
        insert newUser;
        
		List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
		stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Industry_Id',PMP_Value__c='NPP_01_Industry'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Application_Id',PMP_Value__c='NPP_01_APP'));
		stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Region_Id',PMP_Value__c='NPP_GeographicCoverage'));
		stList.add(new PMP_Static_Constants__c(Name='PMP_LOEM_ODM_Partner_Program',PMP_Value__c='LOEM-ODM Partner Program'));
		stList.add(new PMP_Static_Constants__c(Name='PMP_BENEFIT_ENHANCED_CODE',PMP_Value__c='BFTMKTPLED'));
		stList.add(new PMP_Static_Constants__c(Name='PMP_Sys_Admin_Profile',PMP_Value__c='System Administrator'));
		stList.add(new PMP_Static_Constants__c(Name='PMP_IT_Admin_Profile',PMP_Value__c='IT Admin'));
		stList.add(new PMP_Static_Constants__c(Name='PMP_Thumbnail_Image',PMP_Value__c='Thumbnail Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_LDR',PMP_Value__c='PMP_External_Lead_Development_Representative'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Marketing_Specialist',PMP_Value__c='PMP_External_Marketing_Specialist'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Offering_Editor',PMP_Value__c='PMP_External_Offering_Editor'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Partner_Admin',PMP_Value__c='PMP_External_Partner_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Guest_User_Name',PMP_Value__c='Intel® Solutions Marketplace Site Guest User'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        insert stList;
		
		PMP_Partner_Specialty__c sp = new PMP_Partner_Specialty__c();
        sp.Name = 'Artificial Intelligence Specialist';
        sp.PMP_Is_Active_Ind__c =True;
        insert sp;
        
        PMP_Partner_Tier__c tier = new PMP_Partner_Tier__c();
        tier.Name = 'Gold';
        tier.PMP_Is_Biz_Org_Type_Ind__c=true;
        insert tier;
        
        PMP_Partner_Tier__c tier1 = new PMP_Partner_Tier__c();
        tier1.Name = 'Intel Authorized Distributor (IAD)';
        tier1.PMP_Is_Biz_Org_Type_Ind__c=true;
        insert tier1;
        
        PMP_Partner_Tier__c tier2 = new PMP_Partner_Tier__c();
        tier2.Name = 'Intel Authorized Distributor (IAD)';
        insert tier2;
        
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        update acc1;
		
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,false);
        cmp1.PMP_Account_Industry__c = 'Agriculture';
        cmp1.PMP_Account_Application__c= 'Storage';
        cmp1.PMP_Account_Region__c = 'APJ';
        cmp1.PMP_Account_Sub_Region__c = 'ANZ';
        //cmp1.PMP_Account_Specialty__c = 'None';
        cmp1.PMP_Account_Dsc__c = 'Description below the limit.';
        cmp1.PMP_Account_Website__c = 'www.TestCompany1.com';
        cmp1.PMP_Company_Lead_Gen_Language_Nm__c='English';
        cmp1.PMP_Partner_Program_nm__c = 'Manufacturer;Distributor';
        cmp1.PMP_Account_Program_Membership__c = 'Manufacturer - Gold';
        cmp1.PMP_Disti_Components_Nm__c = 'Data Center';
        cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
        cmp1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        cmp1.PMP_Disti_Country_Coverage_Txt__c = 'India;USA';
        cmp1.PMP_Is_Published_Ind__c = true;
        cmp1.PMP_Account_Id__c = acc1.Id;
        insert cmp1;
        //TranslationEOL
       /* PMP_Company_Translation__c trans = new PMP_Company_Translation__c();
        trans.Name = 'test';
        trans.PMP_English_Txt__c = 'test';
        trans.PMP_Japanese_Txt__c = 'test';
        trans.PMP_Chinese_Txt__c = 'test';
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Partner.Description;
        trans.PMP_Company_Information_Id__c = cmp1.Id;
        insert trans;
        
        PMP_Company_Translation__c trans1 = new PMP_Company_Translation__c();
        trans1.Name = 'test';
        trans1.PMP_English_Txt__c = 'test';
        trans1.PMP_Japanese_Txt__c = 'test';
        trans1.PMP_Chinese_Txt__c = 'test';
        trans1.PMP_Field_Nm__c = PMP_StaticConstants_Partner.Tagline;
        trans1.PMP_Company_Information_Id__c = cmp1.Id;
        insert trans1;*/
		
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Company_Resource__c resource=new PMP_Company_Resource__c();
        resource.PMP_Company_Id__c=cmp1.Id;
        resource.PMP_Company_Image__c=document.Id;
        resource.PMP_Company_Resource_Type_Nm__c='White Paper';
        resource.PMP_Company_Resource_Sequence_Nbr__c=0;
        insert resource;
        
        PMP_Partner_Program__c pp = new PMP_Partner_Program__c();
        pp.Name = 'Manufacturer';
        pp.PMP_Is_Active_Ind__c = true;
        pp.PMP_Partner_Program_Value_Txt__c = 'Manufacturer';
        pp.PMP_Partner_Role_Parent_Id__c = Null;
        insert pp;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
        //partner1.PMP_Account_Specialty__c='None';
        partner1.PMP_Is_Published_Ind__c = true;
        partner1.PMP_Account_Id__c = acc1.Id;
        partner1.PMP_Disti_Components_Nm__c = 'Data Center';
        partner1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
        partner1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        partner1.PMP_Disti_Country_Coverage_Txt__c = 'India';
        insert partner1;
        //IPA2.0:US-4497-1631_OfferingEOL
        /*PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = cmp1.Id;
        insert off;
       
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = cmp1.Id;
        insert off1;*/
        
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
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
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
        SYSTEM.assertNotEquals(NULL,PMP_MarketplaceNewPartnerDetail.getPartnerDetails(cmp1.Id, 'en_US'),'Failed');
        SYSTEM.assertNotEquals(NULL,PMP_MarketplaceNewPartnerDetail.getPartnerDetails(cmp1.Id, 'ja'),'Failed');
        SYSTEM.assertNotEquals(NULL,PMP_MarketplaceNewPartnerDetail.getPartnerDetails(cmp1.Id, 'zh_CN'),'Failed');
        Test.stopTest();
    }
}