@isTest
public class PMP_SearchAttributeController_Test extends PMP_SearchWrapperStore{
    
    @testSetup static void setup(){
        PMP_Company__c partner = new PMP_Company__c();
        partner.Name = 'Test_Partner';
        partner.PMP_Account_Specialty__c = 'Specialty Partner';
        partner.PMP_Is_Published_Ind__c = true;
        insert partner;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
        partner1.PMP_Account_Specialty__c = 'Specialty Partner';
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
        
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        PMP_Category__c cat2 = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Comp_Board','NPP_02_Comp', 'en_us');
        cat0.PMP_Parent_Category_Id__c = null; 
        app0.PMP_Parent_Category_Id__c = null;
        ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        cat2.PMP_Parent_Category_Id__c = cat1.Id;
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        catList.add(cat2);
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
        
        PMP_Partner_Offering_Category__c offCat = new PMP_Partner_Offering_Category__c();
        offCat.PMP_Category_Id__c = app1.Id;
        offCat.PMP_Offering_Id__c = off.Id;
        insert offCat;
        
        PMP_Partner_Offering_Category__c offCat1 = new PMP_Partner_Offering_Category__c();
        offCat1.PMP_Category_Id__c = app1.Id;
        offCat1.PMP_Offering_Id__c = off1.Id;
        insert offCat1;
        
        PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c();
        offCat2.PMP_Category_Id__c = app2.Id;
        offCat2.PMP_Offering_Id__c = off1.Id;
        insert offCat2;
        
        PMP_Partner_Offering_Category__c offCat3 = new PMP_Partner_Offering_Category__c();
        offCat3.PMP_Category_Id__c = cat2.Id;
        offCat3.PMP_Offering_Id__c = off1.Id;
        insert offCat3;
        
        offCat3 = new PMP_Partner_Offering_Category__c();
        offCat3.PMP_Category_Id__c = cat1.Id;
        offCat3.PMP_Offering_Id__c = off1.Id;
        insert offCat3;
    }
    
    @isTest static void testgetOfferingAttributes(){
        List<String> temp = new List<String>();
        List<PMP_Partner_Offering__c> offerings = [Select Id FROM PMP_Partner_Offering__c WHERE Name Like 'Test_Off%'];
        for(PMP_Partner_Offering__c off :offerings){
            temp.add(off.Id);
        }
        Test.StartTest();
        Map<String , List<Attribute>> result =  PMP_SearchAttributeController.getOfferingAttributes(temp,'en_US');
        system.assert(result.size() == 2);
        Test.StopTest();
    }
    
    @isTest static void getPartnerAttributes_Test(){
        List<String> temp = new List<String>();
        List<PMP_Company__c> partners = [Select Id FROM PMP_Company__c WHERE Name Like 'Test_Partner%'];
        for(PMP_Company__c partner :partners){
            temp.add(partner.Id);
        }
        Test.startTest();
        Map<String , List<Attribute>> result = PMP_SearchAttributeController.getPartnerAttributes(temp,'en_US');
        system.assert(result.size() == 2);
        Test.stopTest();
    }
    
}