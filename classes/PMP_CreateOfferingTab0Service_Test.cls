/****************************************************************************************************************************************
* Class Name  : PMP_CreateOfferingTab0Service_Test 
* Version     : 1.0 
* Created Date: 09-19-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Raj Yadav               09-19-2019                    Test class for PMP_CreateOfferingTab0Service
****************************************************************************************************************************************************************/
@isTest
public class PMP_CreateOfferingTab0Service_Test {
    
    // static testMethod void fetchTopLevelCategoriesTest(){
        
    //     List<PMP_Category__c> updateCategories = new List<PMP_Category__c>();
        
    //     PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
    //     PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'TPS_900002','NPP_01_TYPE', 'en_us');
    //     PMP_Category__c cat2 = PMP_TestDataUtility.getCategory('Memory', 'TPS_900022','TPS_900002', 'en_us');
    //     cat0.PMP_Parent_Category_Id__c = null;
    //     cat0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
    //    	cat1.PMP_Parent_Category_Id__c = cat0.Id;
    //     cat1.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
    //     cat1.PMP_Active_Ind__c = true;
    //     cat2.PMP_Parent_Category_Id__c = cat1.Id;
    //     cat2.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        
    //     updateCategories.add(cat0);
    //     updateCategories.add(cat1);
    //     updateCategories.add(cat2);
        
    //     update updateCategories;
    //     test.startTest();
    //     List<PMP_CreateOfferingTab0Service.CategoryWrapper> topLevelCategories = PMP_CreateOfferingTab0Service.fetchTopLevelCategories();
    //     System.assertEquals(1, topLevelCategories.size());
    //     test.stopTest();
        
    // }
    
    // static testMethod void createTopLevelOffCategoriesRecordTest(){
        
    //     PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
    //     PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'TPS_900002','NPP_01_TYPE', 'en_us');
        
    //     Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
    //     PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
    //     PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
    //     test.startTest();
    //     PMP_CreateOfferingTab0Service.createTopLevelOffCategoriesRecord(off1.Id, 'TPS_900002');
        
    //     List<PMP_Partner_Offering_Category__c> offCategories = [SELECT id,Name FROM PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__c =: off1.Id];
        
    //     System.assertEquals(2, offCategories.size());
    //     test.stopTest();
    // }

}