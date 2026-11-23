/***************************************************************************************************************************
 * Test Class: ProductStagingDMLServiceTest
 * Author And Date: Rohit Podder, 25 MAY 2026
 * Function: Test class for ProductStagingDMLService
 ****************************************************************************************************************************/
@isTest
public class ProductStagingDMLServiceTest {

    @isTest
    static void testUpsertStagingRecordsWithEmptyList() {
        ProductStagingDMLService service = new ProductStagingDMLService();

        Test.startTest();
        service.upsertStagingRecords(new List<Product_Inbound_Staging__c>(), 'testLoadId');
        Test.stopTest();
    }

    @isTest
    static void testUpsertStagingRecordsWithNullList() {
        ProductStagingDMLService service = new ProductStagingDMLService();

        Test.startTest();
        service.upsertStagingRecords(null, 'testLoadId');
        Test.stopTest();
    }

    @isTest
    static void testUpsertStagingRecordsSmallBatch() {
        List<Product_Inbound_Staging__c> records = new List<Product_Inbound_Staging__c>();
        for (Integer i = 0; i < 5; i++) {
            Product_Inbound_Staging__c pis = new Product_Inbound_Staging__c();
            pis.iPaaS_Load_ID__c = 'testLoadId';
            pis.Core_Unique_ID__c = 'unique_' + i;
            pis.level_1_epm_id__c = '1001';
            pis.level_1_epm_name__c = 'L1';
            pis.Core_Hierarchy_ID__c = '43';
            records.add(pis);
        }

        ProductStagingDMLService service = new ProductStagingDMLService();

        Test.startTest();
        service.upsertStagingRecords(records, 'testLoadId');
        Test.stopTest();

        //List<Product_Inbound_Staging__c> inserted = [SELECT Id FROM Product_Inbound_Staging__c WHERE iPaaS_Load_ID__c = 'testLoadId'];
        //System.assertEquals(5, inserted.size());
    }
    
    @isTest
    static void testUpsertStagingRecordsOnlySmallBatch() {
        List<Product_Inbound_Staging__c> records = new List<Product_Inbound_Staging__c>();
        for (Integer i = 0; i < 5; i++) {
            Product_Inbound_Staging__c pis = new Product_Inbound_Staging__c();
            pis.iPaaS_Load_ID__c = 'testLoadId';
            pis.Core_Unique_ID__c = 'unique_' + i;
            pis.level_1_epm_id__c = '1001';
            pis.level_1_epm_name__c = 'L1';
            pis.Core_Hierarchy_ID__c = '43';
            records.add(pis);
        }

        ProductStagingDMLService service = new ProductStagingDMLService();

        Test.startTest();
        service.upsertStagingRecordsOnly(records, 'testLoadId');
        Test.stopTest();

        //List<Product_Inbound_Staging__c> inserted = [SELECT Id FROM Product_Inbound_Staging__c WHERE iPaaS_Load_ID__c = 'testLoadId'];
        //System.assertEquals(5, inserted.size());
    }
}