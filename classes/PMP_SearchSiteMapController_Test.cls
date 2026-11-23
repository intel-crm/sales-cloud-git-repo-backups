@isTest
public class PMP_SearchSiteMapController_Test {
    
    @isTest static void getAllCategories(){
        
        Test.startTest();
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'TPS_900002','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat4 = PMP_TestDataUtility.getCategory('System', 'IPA_TYPE_Sys','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat8 = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Board','IPA_TYPE_Sys', 'en_us');
        PMP_Category__c cat5 = PMP_TestDataUtility.getCategory('Software', 'TPS_900003','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat9 = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Board','TPS_900003', 'en_us');
        PMP_Category__c cat6 = PMP_TestDataUtility.getCategory('Service', 'IPA_TYPE_Ser','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat10 = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Board','IPA_TYPE_Ser', 'en_us');
        PMP_Category__c cat7 = PMP_TestDataUtility.getCategory('Solution', 'IPA_TYPE_Sol','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat11 = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Board','IPA_TYPE_Sol', 'en_us');
        PMP_Category__c cat3 = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Board','NPP_02_Comp', 'en_us');
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
        update catList;
        system.assertNotEquals(PMP_SearchSiteMapController.getAllCategories(), null);
        Test.stopTest();
        
    }
    
}