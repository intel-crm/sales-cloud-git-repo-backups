@isTest
public class PMP_SearchAttributeController_Test extends PMP_SearchWrapperStore{
    
    @testSetup static void setup() {
        
        Id masterPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAcc = PMP_TestDataUtility.createIntelAccount('TestIntelAccount', masterPartner, true);
        intelAcc.Core_IPA_Partner_Role__c = 'Distributor';
        update intelAcc;
        
        PMP_Company__c partner = new PMP_Company__c();
        partner.Name = 'Test_Partner';
        partner.PMP_Partner_Program_nm__c = 'distributor';
        partner.PMP_Account_Id__c = intelAcc.Id;
        partner.PMP_Account_Specialty__c = 'Specialty Partner';
        partner.PMP_Is_Published_Ind__c = true;
        //partner.PMP_Disti_Components_Nm__c = 'Client CPUs and NUC';
		partner.PMP_Disti_Components_Nm__c ='Data Center';
        //partner.PMP_Disti_Sys_Solutions_Nm__c = 'Client CPUs and NUC';
        partner.PMP_Disti_Sys_Solutions_Nm__c = 'Internet of Things';
        partner.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        partner.PMP_Disti_Country_Coverage_Txt__c = 'India';
        insert partner;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner.PMP_Account_Id__c = intelAcc.Id;
        partner1.Name = 'Test_Partner1';
        partner1.PMP_Account_Specialty__c = 'Specialty Partner';
        partner1.PMP_Is_Published_Ind__c = true;
        //partner1.PMP_Disti_Components_Nm__c = 'Client CPUs and NUC';
		partner1.PMP_Disti_Components_Nm__c ='Data Center';
        //partner1.PMP_Disti_Sys_Solutions_Nm__c = 'Client CPUs and NUC';
        partner1.PMP_Disti_Sys_Solutions_Nm__c = 'Internet of Things';
        partner1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        partner1.PMP_Disti_Country_Coverage_Txt__c = 'India';
        insert partner1;
        
        //static constants from custom settings
        PMP_Static_Constants__c cust =New PMP_Static_Constants__c();  
        cust.Name='PMP_SOLUTION_MARKETPLACE_HIERARCHY';
        cust.PMP_Value__c='Solution_Marketplace_Hierarchy';
        insert cust;
        
        PMP_Static_Constants__c cust1 =New PMP_Static_Constants__c();  
        cust1.Name='PMP_PIM_Category_Id';
        cust1.PMP_Value__c='NPP_01_TYPE';
        insert cust1;
        
        //IPA2.0:US-4497-1631_OfferingEOL
        /*PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = partner.Id;
        insert off;
        
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = partner.Id;
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
        
 /*       List<PMP_Category__c> categories = new List<PMP_Category__c> {
            new PMP_Category__c(Name='Categories', PMP_Category_Chinese_Nm__c='Chinese', PMP_Category_Japanese_Nm__c='Japanese',PMP_Active_Ind__c=true,
                                PMP_Partner_Product_Category_Cd__c='NPP_01_TYPE',PMP_Partner_Product_Parent_Category_Cd__c='Solution_Marketplace_Hierarchy',
                                PMP_Partner_Product_Category_Key__c='npp_01_type'),
            new PMP_Category__c(Name='Agriculture', PMP_Category_Chinese_Nm__c='Chinese', PMP_Category_Japanese_Nm__c='Japanese',PMP_Active_Ind__c=true,
                                PMP_Partner_Product_Category_Cd__c='IPA_Ind_Agriculture',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_TYPE')
        };
        insert categories;
        
        categories[1].PMP_Parent_Category_Id__c = categories[0].Id;
        update categories;
        
        PMP_Partner_Category__c partCat1 = new PMP_Partner_Category__c(PMP_Category_Id__c = categories[1].Id,PMP_Partner_Id__c = partner.Id);
        insert partCat1;
        PMP_Partner_Category__c partCat2 = new PMP_Partner_Category__c(PMP_Category_Id__c = categories[1].Id,PMP_Partner_Id__c = partner1.Id);
        insert partCat2;
        
        PMP_Partner_Offering_Category__c offCat = new PMP_Partner_Offering_Category__c(PMP_Category_Id__c = categories[1].Id, PMP_Offering_Id__c = off.Id);
        insert offCat;
        */
        
         List<PMP_Category__c> categories = new List<PMP_Category__c>();
         PMP_Category__c cat1 = new PMP_Category__c();
         cat1.Name='Categories';
         cat1.PMP_Category_Chinese_Nm__c='Chinese';
         cat1.PMP_Category_Japanese_Nm__c='Japanese';
         cat1.PMP_Active_Ind__c=true;
         cat1.PMP_Partner_Product_Category_Cd__c='NPP_01_TYPE';
         cat1.PMP_Partner_Product_Parent_Category_Cd__c='Solution_Marketplace_Hierarchy';
         cat1.PMP_Partner_Product_Category_Key__c='npp_01_type';
             
         PMP_Category__c cat2 = new PMP_Category__c();
         cat2.Name='Component';
         cat2.PMP_Category_Chinese_Nm__c='Chinese';
         cat2.PMP_Category_Japanese_Nm__c='Japanese';
         cat2.PMP_Active_Ind__c=true;
         cat2.PMP_Partner_Product_Category_Cd__c='TPS_900002';
         cat2.PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_TYPE';
         cat2.PMP_Partner_Product_Category_Key__c='tps_900002';
             
         PMP_Category__c cat3 = new PMP_Category__c();
         cat3.Name='FPGA Boards';
         cat3.PMP_Category_Chinese_Nm__c='Chinese';
         cat3.PMP_Category_Japanese_Nm__c='Japanese';
         cat3.PMP_Active_Ind__c=true;
         cat3.PMP_Partner_Product_Category_Cd__c='TPS_900214';
         cat3.PMP_Partner_Product_Parent_Category_Cd__c='TPS_900002';
         cat3.PMP_Partner_Product_Category_Key__c='TPS_900214';
             
         PMP_Category__c cat4= new PMP_Category__c();
         cat4.Name='Development Kits';
         cat4.PMP_Category_Chinese_Nm__c='Chinese';
         cat4.PMP_Category_Japanese_Nm__c='Japanese';
         cat4.PMP_Active_Ind__c=true;
         cat4.PMP_Partner_Product_Category_Cd__c='TPS_900218';
         cat4.PMP_Partner_Product_Parent_Category_Cd__c='TPS_900214';
         cat4.PMP_Partner_Product_Category_Key__c=' tps_900218';
        
         PMP_Category__c cat5= new PMP_Category__c();
         cat5.Name='Application';
         cat5.PMP_Category_Chinese_Nm__c='Chinese';
         cat5.PMP_Category_Japanese_Nm__c='Japanese';
         cat5.PMP_Active_Ind__c=true;
         cat5.PMP_Partner_Product_Category_Cd__c='NPP_01_APP';
         cat5.PMP_Partner_Product_Parent_Category_Cd__c='Solution_Marketplace_Hierarchy';
         cat5.PMP_Partner_Product_Category_Key__c=' npp_01_app';
        
        PMP_Category__c cat6= new PMP_Category__c();
         cat6.Name='Advanced Analytics';
         cat6.PMP_Category_Chinese_Nm__c='Chinese';
         cat6.PMP_Category_Japanese_Nm__c='Japanese';
         cat6.PMP_Active_Ind__c=true;
         cat6.PMP_Partner_Product_Category_Cd__c='IPA_APP_AdvancedAnalytics';
         cat6.PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_APP';
         cat6.PMP_Partner_Product_Category_Key__c='ipa_app_advancedanalytics';
          
         cat2.PMP_Parent_Category_Id__c = cat1.Id;
        cat3.PMP_Parent_Category_Id__c = cat2.Id;
        cat4.PMP_Parent_Category_Id__c = cat3.Id;
        cat6.PMP_Parent_Category_Id__c = cat5.Id;
         categories.add(cat1);
         categories.add(cat2);
         categories.add(cat3);
         categories.add(cat4);
         categories.add(cat5);
        categories.add(cat6);
   
        insert categories;

        
          PMP_Partner_Category__c partCat1 = new PMP_Partner_Category__c(PMP_Category_Id__c = categories[3].Id,PMP_Partner_Id__c = partner.Id);
        insert partCat1;
        PMP_Partner_Category__c partCat2 = new PMP_Partner_Category__c(PMP_Category_Id__c = categories[3].Id,PMP_Partner_Id__c = partner1.Id);
        insert partCat2;
        //IPA2.0:US-4497-1631_OfferingEOL
        /*PMP_Partner_Offering_Category__c offCat = new PMP_Partner_Offering_Category__c(PMP_Category_Id__c = categories[3].Id, PMP_Offering_Id__c = off.Id);
        insert offCat;
        PMP_Partner_Offering_Category__c offCat1 = new PMP_Partner_Offering_Category__c(PMP_Category_Id__c = categories[2].Id, PMP_Offering_Id__c = off.Id);
        insert offCat1;
        PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c(PMP_Category_Id__c = categories[1].Id, PMP_Offering_Id__c = off.Id);
        insert offCat2;
        PMP_Partner_Offering_Category__c offCat3 = new PMP_Partner_Offering_Category__c(PMP_Category_Id__c = categories[5].Id, PMP_Offering_Id__c = off1.Id);
        insert offCat3;*/
        
    }
    //IPA2.0:US-4497-1631_OfferingEOL
    /*@isTest static void testgetOfferingAttributes(){
        List<String> temp = new List<String>();
        List<PMP_Partner_Offering__c> offerings = [Select Id FROM PMP_Partner_Offering__c WHERE Name Like 'Test_Off%'];
        for(PMP_Partner_Offering__c off :offerings){
            temp.add(off.Id);
        }
        Test.StartTest();
        Map<String , List<Attribute>> result =  PMP_SearchAttributeController.getOfferingAttributes(temp,'en_US');
 //       System.assertEquals(result.size()>0, true, 'result size  is'+result.size());
        Test.StopTest();
        system.assertNotEquals(offerings, null);
    }*/
    
    @isTest static void getPartnerAttributes_Test(){
        List<String> temp = new List<String>();
        List<PMP_Company__c> partners = [SELECT Id FROM PMP_Company__c WHERE Name Like 'Test_Partner%'];
        for(PMP_Company__c partner :partners){
            temp.add(partner.Id);
        }
        Test.startTest();
        Map<String, List<Attribute>> result = PMP_SearchAttributeController.getPartnerAttributes(temp, 'en_US');
        system.assertNotEquals(null, result);
        
        
        partners[0].PMP_Partner_Program_Nm__c = 'Distributor';
        update partners[0];
        system.assertNotEquals(null, PMP_SearchAttributeController.getPartnerAttributes(temp, 'en_US'));
        Test.stopTest();
    }
    
    
    
}