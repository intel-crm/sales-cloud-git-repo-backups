@isTest
public class Product_upsertProduct3RecordsTest{
    @isTest
    public static void testBatchExecution() {
        // Create test data for Core_Products_Staging__c records
        List<Core_Products_Staging__c> stagingRecords = new List<Core_Products_Staging__c>();        
        Core_Products_Staging__c stagingRecord1 = new Core_Products_Staging__c();
        stagingRecord1.iPaaS_Load_ID__c = '1687154732679';
        stagingRecord1.Core_Unique_ID__c = '128267';
        stagingRecord1.Core_Product_Org__c = 'Sales';       
        stagingRecords.add(stagingRecord1);         
        Core_Products_Staging__c stagingRecord2 = new Core_Products_Staging__c();
        stagingRecord2.iPaaS_Load_ID__c = '1687154732679';
        stagingRecord2.Core_Unique_ID__c = '128267';
        stagingRecord2.Core_Product_Org__c = 'IPS';
        stagingRecords.add(stagingRecord2); 
        Core_Products_Staging__c stagingRecord3 = new Core_Products_Staging__c();
        stagingRecord3.iPaaS_Load_ID__c = '1687154732679';
        stagingRecord3.Core_Unique_ID__c = '128267';
        stagingRecord3.Core_Product_Org__c = 'FPH';
        stagingRecords.add(stagingRecord3);  
        insert stagingRecords;        
        //create product records for both fph and sales
        Core_Flat_Product_Hierarchy__c fphRec1= new Core_Flat_Product_Hierarchy__c();
        fphRec1.Core_iPaaS_Load_ID__c ='273232332';
        fphRec1.Core_Unique_ID__c = '78788';
        fphRec1.Core_EPM_Hierarchy_ID__c ='43';
        insert fphRec1;
        Product2 prodRec = new Product2();
        prodRec.Core_iPaaS_Load_ID__c = '273232332';
        prodRec.Core_Unique_ID__c = '76787788';
        prodRec.Core_Hierarchy_ID__c ='43';
        prodRec.Core_Product_Org__c = 'Sales';
        prodRec.Name = 'Dummy';
        insert prodRec;
       
        
        Product2 prodCopy = new Product2();
        prodCopy.Core_iPaaS_Load_ID__c = '273232332';
        prodCopy.Core_Unique_ID__c = '76787788';
        prodCopy.Core_Hierarchy_ID__c ='43';
        prodCopy.Core_Product_Org__c = 'Sales';
        prodCopy.Name = 'Dummy';
        insert prodCopy;
        

        
        //upsert Staging Record 
        Test.startTest();    
        Database.executeBatch(new Product_upsertProduct3Records('1687154732679'));
        Test.stopTest();       
    }
}