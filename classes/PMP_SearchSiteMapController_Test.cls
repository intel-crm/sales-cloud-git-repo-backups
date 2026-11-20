@isTest
public class PMP_SearchSiteMapController_Test {
    
    /*@testSetup
    public static void testFactory(){
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'TPS_900002','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat4 = PMP_TestDataUtility.getCategory('System', 'IPA_TYPE_Sys','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat8 = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Board','IPA_TYPE_Sys', 'en_us');
        PMP_Category__c cat5 = PMP_TestDataUtility.getCategory('Software', 'TPS_900003','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat9 = PMP_TestDataUtility.getCategory('Board', 'NPP_03_Board','TPS_900003', 'en_us');
        PMP_Category__c cat6 = PMP_TestDataUtility.getCategory('Service', 'IPA_TYPE_Ser','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat10 = PMP_TestDataUtility.getCategory('Board', 'NPP_04_Board','IPA_TYPE_Ser', 'en_us');
        PMP_Category__c cat7 = PMP_TestDataUtility.getCategory('Solution', 'IPA_TYPE_Sol','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat11 = PMP_TestDataUtility.getCategory('Board', 'NPP_05_Board','IPA_TYPE_Sol', 'en_us');
        PMP_Category__c cat3 = PMP_TestDataUtility.getCategory('Board', 'NPP_06_Board','NPP_02_Comp', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        cat0.PMP_Parent_Category_Id__c = null; 
        app0.PMP_Parent_Category_Id__c = null;
        ind0.PMP_Parent_Category_Id__c = null;
       
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        cat3.PMP_Parent_Category_Id__c = cat1.Id;
      
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        catList.add(cat3);
        catList.add(cat4);
        catList.add(cat5);
        catList.add(cat6);
        catList.add(cat7);
        catList.add(cat8);
        catList.add(cat9);
        catList.add(cat10);
        catList.add(cat11);
        for(PMP_Category__c cat : catList) {
            cat.PMP_Partner_Product_Category_Key__c = cat.PMP_Partner_Product_Category_Cd__c.toLowerCase();
        }
        update catList;
                
        PMP_Partner_Specialty__c partSpec = new PMP_Partner_Specialty__c();
        partSpec.Name ='Cloud Data Center Specialist';
        partSpec.PMP_Is_Active_Ind__c = true;
        insert partSpec;
        
        PMP_Partner_Program__c partProg0 = new PMP_Partner_Program__c(Name = 'Manufacturer',PMP_Is_Active_Ind__c =true,PMP_Partner_Program_Value_Txt__c = 'ODM-LOEM');
        insert partProg0;
        
        PMP_Partner_Program__c partProg1 = new PMP_Partner_Program__c();
        partProg1.Name = 'Solution, Software, and Service Providers';
        partProg1.PMP_Is_Active_Ind__c =true;
        insert partProg1;

        PMP_Partner_Program__c partProg = new PMP_Partner_Program__c();
        partProg.Name = 'Solution Provider';
        partProg.PMP_Is_Active_Ind__c =true;
        partProg.PMP_Partner_Program_Value_Txt__c = 'ODM-LOEM';
        partProg.PMP_Partner_Role_Parent_Id__c=partProg1.Id;
        insert partProg;
        PMP_Partner_Segment__c partSeg = new PMP_Partner_Segment__c();
        partSeg.Name = 'Client Computing';
        partSeg.PMP_Is_Active_Ind__c = true;
        insert partSeg;

         Account acc1 = PMP_SearchTestDataFactory.createIntelAccount('TestAccount1', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
         PMP_Company__c cmp1 = PMP_SearchTestDataFactory.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Program_nm__c = 'Manufacturer';
        cmp1.PMP_Is_Published_Ind__c = true;
        //cmp1.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
        cmp1.PMP_Partner_Segment_Nm__c = 'Client Computing';
        cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        cmp1.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
        cmp1.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        cmp1.PMP_Benefit_Update_Ind__c=False;
        update cmp1;
        
        PMP_Partner_Category__c partCategory = new PMP_Partner_Category__c(PMP_Category_Id__c=cat3.Id,PMP_Partner_Id__c=cmp1.Id);
        insert partCategory;
        
        PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
                                                                                     'TestDuplicate',cmp1.Id, true,'Draft','');
        offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering1.PMP_Offering_Status_Update_Dt__c = System.now();
        offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
        //offering1.PMP_Offering_Language_Nm__c = 'English';
        update offering1;
                
        List<PMP_Partner_Offering_Category__c> offCategories = new List<PMP_Partner_Offering_Category__c>();
        for(PMP_Category__c cat : [SELECT Id,PMP_Ancestor_Category_Cd__c,PMP_Partner_Product_Category_Cd__c,PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c,PMP_Partner_Product_Parent_Category_Cd__c FROM PMP_Category__c WHERE Id IN :catList]) {
            offCategories.add(new PMP_Partner_Offering_Category__c(PMP_Category_Id__c=cat.Id, PMP_Offering_Id__c=offering1.Id,
                                                                  PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|'+cat.PMP_Partner_Product_Category_Cd__c,
                                                                  PMP_Offering_Category_External_Key__c=cat.PMP_Partner_Product_Category_Cd__c));
            //System.debug('::PMP_Partner_Product_Category_Cd__c::' + cat.PMP_Partner_Product_Category_Cd__c + ':::' + cat.PMP_Partner_Product_Parent_Category_Cd__c + '::::' + cat.PMP_Ancestor_Category_Cd__c);
        }
        update catList;
        insert offCategories;*/
        /*
        PMP_Partner_Offering_Category__c offCategory = PMP_SearchTestDataFactory.getPMPOfferingCategory(offering1.id);
        offCategory.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|NPP_01_Industry';
        offCategory.PMP_Offering_Category_External_Key__c = 'NPP_01_Industry'; 
        update offCategory;
        */    
    /*}
    
    @isTest static void getAllCategories(){
        
        Test.startTest();
        PMP_Category__c cat = [SELECT id,PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c from PMP_Category__c where PMP_Partner_Product_Category_Cd__c='IPA_Ind_HealthCare' limit 1];
            
        PMP_Category_Partner__c pc = new PMP_Category_Partner__c();
        pc.Name = 'catPartner';
        pc.PMP_Category_Id__c = cat.Id;
        insert pc;
        
        PMP_Category__c cat1 = [SELECT id,PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c from PMP_Category__c where PMP_Partner_Product_Category_Cd__c='IPA_APP_ConnectedWorker' limit 1];
            
        PMP_Category_Partner__c pc1 = new PMP_Category_Partner__c();
        pc1.Name = 'catPartner';
        pc1.PMP_Category_Id__c = cat1.Id;
        insert pc1;        
        
        //system.debug('checking cat : ' + cat.PMP_Parent_Category_Id__r.PMP_Partner_Product_Category_Cd__c);
        
       //system.assertNotEquals(null, PMP_SearchSiteMapController.getAllCategories('en_us'),'No Error');
        PMP_SearchSiteMapController searchsite = new PMP_SearchSiteMapController();
        Test.stopTest();
        
    }*/
    

    
    
}