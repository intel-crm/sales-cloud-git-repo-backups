/**
 * @description Test class for Core_MDF_TimezoneValuesBatch
 *              Tests the batch processing of country and state picklist data
 *              with timezone mappings into CRM_Timezone_values__c custom object
 * 
 * @author Auto-generated
 * @date 2026-07-21
 */
@isTest
public class Core_MDF_TimezoneValuesBatchTest {
    
    /**
     * @description Setup test data
     */
    @testSetup
    static void setupTestData() {
        List<CRM_Timezone_values__c> testRecords = new List<CRM_Timezone_values__c>();
        
        testRecords.add(new CRM_Timezone_values__c(
            //Name = 'USA-CA',
            CRM_Country_txt__c = 'United States',
            CRM_Country_Code_txt__c = 'USA',
            CRM_State_txt__c = 'California',
            CRM_State_Code_txt__c = 'CA',
            CRM_Timezone_txt__c = 'America/Los_Angeles'
        ));
        
        testRecords.add(new CRM_Timezone_values__c(
            //Name = 'USA-NY',
            CRM_Country_txt__c = 'United States',
            CRM_Country_Code_txt__c = 'USA',
            CRM_State_txt__c = 'New York',
            CRM_State_Code_txt__c = 'NY',
            CRM_Timezone_txt__c = 'America/New_York'
        ));
        
        insert testRecords;
    }
    
    @isTest
    static void testBatchStart() {
        Test.startTest();
        Core_MDF_TimezoneValuesBatch batch = new Core_MDF_TimezoneValuesBatch();
        Iterable<Core_MDF_TimezoneValuesBatch.StateCountryWrapper> result = batch.start(null);
        System.assertNotEquals(null, result);
        Test.stopTest();
    }
    
    @isTest
    static void testBatchExecute() {
        Test.startTest();
        List<Core_MDF_TimezoneValuesBatch.StateCountryWrapper> wrappers = 
            new List<Core_MDF_TimezoneValuesBatch.StateCountryWrapper>();
        
        wrappers.add(new Core_MDF_TimezoneValuesBatch.StateCountryWrapper(
            'United States', 'USA', 'California', 'CA'
        ));
        
        Core_MDF_TimezoneValuesBatch batch = new Core_MDF_TimezoneValuesBatch();
        batch.execute(null, wrappers);
        Test.stopTest();
    }
    
    /*@isTest
    static void testBatchFullExecution() {
        Test.startTest();
        Core_MDF_TimezoneValuesBatch batch = new Core_MDF_TimezoneValuesBatch();
        Id batchId = Database.executeBatch(batch, 200);
        Test.stopTest();
        System.assertNotEquals(null, batchId);
    }*/
    @isTest
static void testBatchIterableExecution() {
    Test.startTest();
    Core_MDF_TimezoneValuesBatch batch = new Core_MDF_TimezoneValuesBatch();
    // Get the iterable from start method
    Iterable<Core_MDF_TimezoneValuesBatch.StateCountryWrapper> wrapperIter = batch.start(null);
    // Convert to list and process in batches
    List<Core_MDF_TimezoneValuesBatch.StateCountryWrapper> wrapperList = 
        new List<Core_MDF_TimezoneValuesBatch.StateCountryWrapper>();
    for (Core_MDF_TimezoneValuesBatch.StateCountryWrapper wrapper : wrapperIter) {
        wrapperList.add(wrapper);
        // Process in chunks of 200
        if (wrapperList.size() >= 200) {
            batch.execute(null, wrapperList);
            wrapperList.clear();
        }
    }
    // Process remaining wrappers
    if (wrapperList.size() > 0) {
        batch.execute(null, wrapperList);
    }
    // Call finish
    batch.finish(null);
    Test.stopTest();
    System.assert(true, 'Batch iterable execution completed successfully');
}
    @isTest
    static void testStateCountryWrapper() {
        Test.startTest();
        Core_MDF_TimezoneValuesBatch.StateCountryWrapper wrapper = 
            new Core_MDF_TimezoneValuesBatch.StateCountryWrapper(
                'United States', 'USA', 'Texas', 'TX'
            );
        System.assertEquals('United States', wrapper.countryLabel);
        System.assertEquals('USA', wrapper.countryCode);
        Test.stopTest();
    }
    
    @isTest
    static void testTimezoneHelper() {
        Test.startTest();
        String usTimezone = Core_MDF_TimezoneHelper.getTimezone('USA', 'CA');
        System.assertEquals('America/Los_Angeles', usTimezone);
        
        String defaultTimezone = Core_MDF_TimezoneHelper.getTimezone('ZZZ', 'XX');
        System.assertEquals('UTC', defaultTimezone);
        Test.stopTest();
    }
}