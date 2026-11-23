/**************************************************************************************
Apex Class Name : PMP_CategoryDataUpdateOnOfferings_Test
Version     : 1.0 
Created Date: 23rd September, 2019
Description : test class for PMP_CategoryDataUpdateOnOfferings 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raj Yadav                23/09/2019               Original Version
*************************************************************************************/
@isTest
public class PMP_CategoryDataUpdateOnOfferings_Test {
/*    //IPA2.0 Offering Changes
    static testMethod void testCategoryUpdateOnOfferings(){
        
        List<PMP_Category__c> updateCategories = new List<PMP_Category__c>();
        List<PMP_Partner_Offering_Category__c> insertOffCategories = new List<PMP_Partner_Offering_Category__c>();
        List<PMP_Partner_Offering_Translation__c> insertOffTranslation = new List<PMP_Partner_Offering_Translation__c>();
        
        Test.startTest();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'TPS_900002','NPP_01_TYPE', 'en_us');
        System.assertEquals('Component', cat1.Name);
        PMP_Category__c cat2 = PMP_TestDataUtility.getCategory('Memory', 'TPS_900022','TPS_900002', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Retail', 'IPA_Ind_Retail','NPP_01_Industry', 'en_us');
        System.assertEquals('Retail', ind2.Name);
        
        cat0.PMP_Parent_Category_Id__c = null;
        cat0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        app0.PMP_Parent_Category_Id__c = null;
        app0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        ind0.PMP_Parent_Category_Id__c = null;
        ind0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        cat1.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        cat2.PMP_Parent_Category_Id__c = cat1.Id;
        cat2.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
        app1.PMP_Parent_Category_Id__c = app0.Id;
        app1.PMP_Business_Segment_Nm__c = 'IoT';
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        ind1.PMP_Business_Segment_Nm__c = 'IoT';
        ind2.PMP_Parent_Category_Id__c = ind0.Id;
        ind2.PMP_Business_Segment_Nm__c = 'IoT';
        
        updateCategories.add(cat0);
        updateCategories.add(app0);
        updateCategories.add(ind0);
        updateCategories.add(cat1);
        updateCategories.add(cat2);
        updateCategories.add(app1);
        updateCategories.add(ind1);
        updateCategories.add(ind2);
        
        update updateCategories;
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        offering1.PMP_Partner_Offering_Source_Id__c = '3456578';
        update offering1;
        
        PMP_Partner_Offering_Category__c offCat1 = new PMP_Partner_Offering_Category__c();
        offCat1.Name = 'Categories';
        offCat1.PMP_Offering_Id__c = offering1.Id;
        offCat1.PMP_Category_Id__c = cat0.Id;
        offCat1.PMP_Ancestor_Category_Cd__c = cat0.PMP_Ancestor_Category_Cd__c;
        
        PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c();
        offCat2.Name = 'Component';
        offCat2.PMP_Offering_Id__c = offering1.Id;
        offCat2.PMP_Category_Id__c = cat1.Id;
        offCat2.PMP_Ancestor_Category_Cd__c = cat1.PMP_Ancestor_Category_Cd__c;
        
        PMP_Partner_Offering_Category__c offCat3 = new PMP_Partner_Offering_Category__c();
        offCat3.Name = 'Memory';
        offCat3.PMP_Offering_Id__c = offering1.Id;
        offCat3.PMP_Category_Id__c = cat2.Id;
        offCat3.PMP_Ancestor_Category_Cd__c = cat2.PMP_Ancestor_Category_Cd__c;
        
        insertOffCategories.add(offCat1);
        insertOffCategories.add(offCat2);
        insertOffCategories.add(offCat3);
        
        insert insertOffCategories;
        
        PMP_Partner_Offering_Translation__c offName = PMP_TestDataUtility.createOfferingTranslation(offering1.Id,'Translation');
        offName.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
        offName.PMP_Chinese_Txt__c = 'Chinese';
        offName.PMP_English_Txt__c = 'English';
        offName.PMP_Japanese_Txt__c = 'Japanese';
        
        PMP_Partner_Offering_Translation__c offName1 = PMP_TestDataUtility.createOfferingTranslation(offering1.Id,'Translation1');
        offName1.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
        offName1.PMP_Chinese_Txt__c = 'Chinese';
        offName1.PMP_English_Txt__c = 'English';
        
        PMP_Partner_Offering_Translation__c offName2 = PMP_TestDataUtility.createOfferingTranslation(offering1.Id,'Translation2');
        offName2.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
        offName2.PMP_Chinese_Txt__c = 'Chinese';
        offName2.PMP_Japanese_Txt__c = 'Japanese';
        
        PMP_Partner_Offering_Translation__c offName3 = PMP_TestDataUtility.createOfferingTranslation(offering1.Id,'Translation3');
        offName3.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
        offName3.PMP_English_Txt__c = 'English';
        offName3.PMP_Japanese_Txt__c = 'Japanese';
        
        PMP_Partner_Offering_Translation__c offName4 = PMP_TestDataUtility.createOfferingTranslation(offering1.Id,'Translation4');
        offName4.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
        offName4.PMP_English_Txt__c = 'English';
        
        PMP_Partner_Offering_Translation__c offName5 = PMP_TestDataUtility.createOfferingTranslation(offering1.Id,'Translation5');
        offName5.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
        offName5.PMP_Japanese_Txt__c = 'Japanese';
        
        PMP_Partner_Offering_Translation__c offName6 = PMP_TestDataUtility.createOfferingTranslation(offering1.Id,'Translation6');
        offName6.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
        offName6.PMP_Chinese_Txt__c = 'Chinese';
		
		insertOffTranslation.add(offName);
		insertOffTranslation.add(offName1);
		insertOffTranslation.add(offName2);
		insertOffTranslation.add(offName3);
       	insertOffTranslation.add(offName4);
		insertOffTranslation.add(offName5);
        insertOffTranslation.add(offName6);
        
        insert insertOffTranslation;
        
        PMP_CategoryDataUpdateOnOfferings obj = new PMP_CategoryDataUpdateOnOfferings();
        Id batchprocessid = Database.executeBatch(obj,1);
        Test.stopTest();
    }
*/
}