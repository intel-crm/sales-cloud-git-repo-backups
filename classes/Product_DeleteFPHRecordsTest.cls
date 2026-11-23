@isTest
public class Product_DeleteFPHRecordsTest {
    @isTest
    public static void testDeleteFPHRecords(){
        List<Core_Flat_Product_Hierarchy__c> recordsList= new List<Core_Flat_Product_Hierarchy__c>();
        Core_Flat_Product_Hierarchy__c hierarchyRecord=new Core_Flat_Product_Hierarchy__c();
        hierarchyRecord.Core_iPaaS_Load_ID__c='98567';
        hierarchyRecord.Core_EPM_Hierarchy_ID__c='59';
        hierarchyRecord.Core_L5_EPM_ID__c='34765';
        hierarchyRecord.Core_L5_EPM_Name__c= 'STRATIX 80 GX F43I2LG';
        recordsList.add(hierarchyRecord);
        insert recordsList;
        
        Test.startTest();
        Product_DeleteFPHRecords obj = new Product_DeleteFPHRecords('346598');
        DataBase.executeBatch(obj); 
        Test.stopTest();
        System.assertEquals('34765',hierarchyRecord.Core_L5_EPM_ID__c);
    }
}