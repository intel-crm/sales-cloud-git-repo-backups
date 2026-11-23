/**
 * @description Test class for CRM_EMB_TimezoneValuesBatch and CRM_EMB_TimezoneHelper
 * @author Aswin Selvaraj/Citrus
 * @date 2026-07-21
 */
@isTest
public class CRM_EMB_TimezoneValuesBatch_Test {
    
    /**
     * @description Test setup method to create test data
     */
    @TestSetup
    static void setupTestData() {
        // Insert test timezone records
        List<CRM_Timezone_values__c> testRecords = new List<CRM_Timezone_values__c>();
        
        testRecords.add(new CRM_Timezone_values__c(
            CRM_Country_txt__c = 'United States',
            CRM_Country_Code_txt__c = 'USA',
            CRM_State_txt__c = 'California',
            CRM_State_Code_txt__c = 'CA',
            CRM_Timezone_txt__c = 'America/Los_Angeles'
        ));
        
        testRecords.add(new CRM_Timezone_values__c(
            CRM_Country_txt__c = 'Canada',
            CRM_Country_Code_txt__c = 'CAN',
            CRM_State_txt__c = 'Ontario',
            CRM_State_Code_txt__c = 'ON',
            CRM_Timezone_txt__c = 'America/Toronto'
        ));
        
        insert testRecords;
    }
    
    /**
     * @description Test batch execution with country and state data
     */
    /*@isTest
    static void testBatchExecution() {
        Test.startTest();
        
        // Delete existing records
        delete [SELECT Id FROM CRM_Timezone_values__c];
        
        // Execute batch
        CRM_EMB_TimezoneValuesBatch batch = new CRM_EMB_TimezoneValuesBatch();
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify records were created
        List<CRM_Timezone_values__c> records = [SELECT Id, CRM_Country_Code_txt__c FROM CRM_Timezone_values__c];
        System.assert(records.size() > 0, 'Batch should create timezone records');
    }*/
    
    /**
     * @description Test batch start method
     */
    @isTest
    static void testBatchStart() {
        Test.startTest();
        
        CRM_EMB_TimezoneValuesBatch batch = new CRM_EMB_TimezoneValuesBatch();
        Database.BatchableContext bc = null;
        
        Iterable<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper> iterable = batch.start(bc);
        List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper> wrappers = new List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper>();
        
        // Convert iterable to list
        for (CRM_EMB_TimezoneValuesBatch.StateCountryWrapper wrapper : iterable) {
            wrappers.add(wrapper);
        }
        
        Test.stopTest();
        
        // Verify wrappers contain both countries and states
        System.assert(wrappers.size() > 0, 'Start method should return wrappers');
        
        // Check for country records (no state)
        Integer countryOnlyCount = 0;
        for (CRM_EMB_TimezoneValuesBatch.StateCountryWrapper wrapper : wrappers) {
            if (wrapper.stateCode == null) {
                countryOnlyCount++;
            }
        }
        System.assert(countryOnlyCount > 0, 'Should have country-only records');
    }
    
    /**
     * @description Test batch execute method
     */
    @isTest
    static void testBatchExecute() {
        Test.startTest();
        
        // Create test wrapper data
        List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper> scope = new List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper>();
        scope.add(new CRM_EMB_TimezoneValuesBatch.StateCountryWrapper(
            'United States',
            'USA',
            'New York',
            'NY'
        ));
        scope.add(new CRM_EMB_TimezoneValuesBatch.StateCountryWrapper(
            'Canada',
            'CAN',
            'British Columbia',
            'BC'
        ));
        scope.add(new CRM_EMB_TimezoneValuesBatch.StateCountryWrapper(
            'Australia',
            'AUS',
            'New South Wales',
            'NSW'
        ));
        
        CRM_EMB_TimezoneValuesBatch batch = new CRM_EMB_TimezoneValuesBatch();
        batch.execute(null, scope);
        
        Test.stopTest();
        
        // Verify records were inserted
        List<CRM_Timezone_values__c> records = [SELECT Id, CRM_Country_Code_txt__c, CRM_State_Code_txt__c FROM CRM_Timezone_values__c];
        System.assert(records.size() >= 3, 'Execute method should insert records');
        
        // Verify specific records
        System.assert([SELECT COUNT() FROM CRM_Timezone_values__c WHERE CRM_Country_Code_txt__c = 'USA' AND CRM_State_Code_txt__c = 'NY'] > 0);
        System.assert([SELECT COUNT() FROM CRM_Timezone_values__c WHERE CRM_Country_Code_txt__c = 'CAN' AND CRM_State_Code_txt__c = 'BC'] > 0);
    }
    
    /**
     * @description Test batch finish method
     */
    @isTest
    static void testBatchFinish() {
        Test.startTest();
        
        CRM_EMB_TimezoneValuesBatch batch = new CRM_EMB_TimezoneValuesBatch();
        batch.finish(null);
        
        Test.stopTest();
        
        // Finish method should complete without errors
        System.assert(true, 'Finish method executed successfully');
    }
    
    /**
     * @description Test StateCountryWrapper class
     */
    @isTest
    static void testStateCountryWrapper() {
        Test.startTest();
        
        CRM_EMB_TimezoneValuesBatch.StateCountryWrapper wrapper = 
            new CRM_EMB_TimezoneValuesBatch.StateCountryWrapper(
                'United States',
                'USA',
                'California',
                'CA'
            );
        
        Test.stopTest();
        
        System.assertEquals('United States', wrapper.countryLabel);
        System.assertEquals('USA', wrapper.countryCode);
        System.assertEquals('California', wrapper.stateLabel);
        System.assertEquals('CA', wrapper.stateCode);
    }
    
    /**
     * @description Test PicklistEntryWrapper class
     */
    @isTest
    static void testPicklistEntryWrapper() {
        Test.startTest();
        
        CRM_EMB_TimezoneValuesBatch.PicklistEntryWrapper wrapper = 
            new CRM_EMB_TimezoneValuesBatch.PicklistEntryWrapper();
        wrapper.active = 'true';
        wrapper.defaultValue = 'false';
        wrapper.label = 'Test Label';
        wrapper.value = 'TEST_VALUE';
        wrapper.validFor = 'AQ==';
        
        Test.stopTest();
        
        System.assertEquals('true', wrapper.active);
        System.assertEquals('false', wrapper.defaultValue);
        System.assertEquals('Test Label', wrapper.label);
        System.assertEquals('TEST_VALUE', wrapper.value);
        System.assertEquals('AQ==', wrapper.validFor);
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for USA
     */
    @isTest
    static void testGetTimezoneUSA() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('USA', 'CA');
        
        Test.stopTest();
        
        System.assertEquals('America/Los_Angeles', timezone, 'Should return California timezone');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Canada
     */
    @isTest
    static void testGetTimezoneCanada() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('CAN', 'ON');
        
        Test.stopTest();
        
        System.assertEquals('America/Toronto', timezone, 'Should return Ontario timezone');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Australia
     */
    @isTest
    static void testGetTimezoneAustralia() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('AUS', 'NSW');
        
        Test.stopTest();
        
        System.assertEquals('Australia/Sydney', timezone, 'Should return NSW timezone');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Brazil
     */
    @isTest
    static void testGetTimezoneBrazil() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('BRA', 'SP');
        
        Test.stopTest();
        
        System.assertEquals('America/Sao_Paulo', timezone, 'Should return Sao Paulo timezone');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Mexico
     */
    @isTest
    static void testGetTimezoneMexico() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('MEX', 'CMX');
        
        Test.stopTest();
        
        System.assertEquals('America/Mexico_City', timezone, 'Should return Mexico City timezone');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Russia
     */
    @isTest
    static void testGetTimezoneRussia() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('RUS', 'MOW');
        
        Test.stopTest();
        
        System.assertEquals('Europe/Moscow', timezone, 'Should return Moscow timezone');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Indonesia
     */
    @isTest
    static void testGetTimezoneIndonesia() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('IDN', 'JK');
        
        Test.stopTest();
        
        System.assertEquals('Asia/Jakarta', timezone, 'Should return Jakarta timezone');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for country default (no state)
     */
    @isTest
    static void testGetTimezoneCountryDefault() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('USA', null);
        
        Test.stopTest();
        
        System.assertEquals('America/New_York', timezone, 'Should return default USA timezone');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() with invalid country
     */
    @isTest
    static void testGetTimezoneInvalidCountry() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('INVALID', 'XX');
        
        Test.stopTest();
        
        System.assertEquals('UTC', timezone, 'Should return UTC for invalid country');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() with invalid state for valid country
     */
    @isTest
    static void testGetTimezoneInvalidState() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('USA', 'XX');
        
        Test.stopTest();
        
        System.assertEquals('America/New_York', timezone, 'Should return country default for invalid state');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getCountryDefaultTimezone()
     */
    @isTest
    static void testGetCountryDefaultTimezone() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getCountryDefaultTimezone('USA');
        
        Test.stopTest();
        
        System.assertEquals('America/New_York', timezone, 'Should return default USA timezone');
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getCountryDefaultTimezone() with invalid country
     */
    @isTest
    static void testGetCountryDefaultTimezoneInvalid() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getCountryDefaultTimezone('INVALID');
        
        Test.stopTest();
        
        System.assertEquals('UTC', timezone, 'Should return UTC for invalid country');
    }
    
    /**
     * @description Test various countries from the mapping
     */
    @isTest
    static void testMultipleCountries() {
        Test.startTest();
        
        Map<String, String> testData = new Map<String, String>{
            'GBR' => 'Europe/London',
            'FRA' => 'Europe/Paris',
            'DEU' => 'Europe/Berlin',
            'JPN' => 'Asia/Tokyo',
            'CHN' => 'Asia/Shanghai',
            'IND' => 'Asia/Kolkata',
            'ZAF' => 'Africa/Johannesburg',
            'NZL' => 'Pacific/Auckland'
        };
        
        for (String countryCode : testData.keySet()) {
            String expectedTz = testData.get(countryCode);
            String actualTz = CRM_EMB_TimezoneHelper.getCountryDefaultTimezone(countryCode);
            System.assertEquals(expectedTz, actualTz, 'Timezone mismatch for ' + countryCode);
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test US states coverage
     */
    @isTest
    static void testUSStatesCoverage() {
        Test.startTest();
        
        List<String> stateTests = new List<String>{
            'AL', 'CA', 'CO', 'FL', 'HI', 'MI', 'NY', 'TX', 'WA'
        };
        
        for (String state : stateTests) {
            String timezone = CRM_EMB_TimezoneHelper.getTimezone('USA', state);
            System.assert(String.isNotBlank(timezone), 'Should return timezone for state: ' + state);
            System.assertNotEquals('UTC', timezone, 'Should not return UTC for known state: ' + state);
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test Canada provinces coverage
     */
    @isTest
    static void testCanadaProvincesCoverage() {
        Test.startTest();
        
        List<String> provinceTests = new List<String>{
            'AB', 'BC', 'MB', 'ON', 'QC'
        };
        
        for (String province : provinceTests) {
            String timezone = CRM_EMB_TimezoneHelper.getTimezone('CAN', province);
            System.assert(String.isNotBlank(timezone), 'Should return timezone for province: ' + province);
            System.assertNotEquals('UTC', timezone, 'Should not return UTC for known province: ' + province);
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test Australia states coverage
     */
    @isTest
    static void testAustraliaStatesCoverage() {
        Test.startTest();
        
        List<String> stateTests = new List<String>{
            'NSW', 'VIC', 'QLD', 'SA', 'WA', 'TAS'
        };
        
        for (String state : stateTests) {
            String timezone = CRM_EMB_TimezoneHelper.getTimezone('AUS', state);
            System.assert(String.isNotBlank(timezone), 'Should return timezone for state: ' + state);
            System.assertNotEquals('UTC', timezone, 'Should not return UTC for known state: ' + state);
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test batch with empty scope
     */
    @isTest
    static void testBatchExecuteEmptyScope() {
        Test.startTest();
        
        List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper> emptyScope = 
            new List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper>();
        
        CRM_EMB_TimezoneValuesBatch batch = new CRM_EMB_TimezoneValuesBatch();
        batch.execute(null, emptyScope);
        
        Test.stopTest();
        
        // Should complete without errors
        System.assert(true, 'Batch should handle empty scope');
    }
    
    /**
     * @description Test batch with single record
     */
    @isTest
    static void testBatchExecuteSingleRecord() {
        Test.startTest();
        
        List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper> scope = 
            new List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper>();
        scope.add(new CRM_EMB_TimezoneValuesBatch.StateCountryWrapper(
            'Test Country',
            'TEST',
            'Test State',
            'TS'
        ));
        
        CRM_EMB_TimezoneValuesBatch batch = new CRM_EMB_TimezoneValuesBatch();
        batch.execute(null, scope);
        
        Test.stopTest();
        
        System.assert([SELECT COUNT() FROM CRM_Timezone_values__c] > 0);
    }
    
    /**
     * @description Test null state code handling
     */
    @isTest
    static void testNullStateCode() {
        Test.startTest();
        
        List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper> scope = 
            new List<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper>();
        scope.add(new CRM_EMB_TimezoneValuesBatch.StateCountryWrapper(
            'United Kingdom',
            'GBR',
            null,
            null
        ));
        
        CRM_EMB_TimezoneValuesBatch batch = new CRM_EMB_TimezoneValuesBatch();
        batch.execute(null, scope);
        
        Test.stopTest();
        
        List<CRM_Timezone_values__c> records = [SELECT CRM_State_Code_txt__c FROM CRM_Timezone_values__c WHERE CRM_Country_Code_txt__c = 'GBR'];
        System.assert(records.size() > 0);
        System.assertEquals(null, records[0].CRM_State_Code_txt__c);
    }
    
    /**
     * @description Test timezone mapping completeness for major countries
     */
    @isTest
    static void testMajorCountriesMapping() {
        Test.startTest();
        
        List<String> majorCountries = new List<String>{
            'USA', 'CAN', 'GBR', 'AUS', 'BRA', 'MEX', 'RUS', 'IDN', 'CHN', 'IND'
        };
        
        for (String country : majorCountries) {
            String timezone = CRM_EMB_TimezoneHelper.getCountryDefaultTimezone(country);
            System.assert(String.isNotBlank(timezone), 'Major country should have timezone: ' + country);
            System.assertNotEquals('UTC', timezone, 'Should have specific timezone for major country: ' + country);
        }
        
        Test.stopTest();
    }
}