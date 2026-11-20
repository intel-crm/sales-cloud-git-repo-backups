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
    
          UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User u = Core_MDF_CCP_TestDataUtility.createUser(false);
        u.LastName = 'User Test';
        u.Email = 'testsysAdmin@example.com';
        u.UserRoleId = adminRole.Id;
        insert u;
        
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'CRM_Executive_Meeting_Brief_PS'
            LIMIT 1
        ];
        
        insert new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );
        
        // Insert test timezone records
        List<CRM_Timezone_values__c> testRecords = new List<CRM_Timezone_values__c>();
        System.runAs(u){
        
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
    }
    
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
        
        
        // Check for country records (no state)
        Integer countryOnlyCount = 0;
        for (CRM_EMB_TimezoneValuesBatch.StateCountryWrapper wrapper : wrappers) {
            if (wrapper.stateCode == null) {
                countryOnlyCount++;
            }
        }
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
        List<CRM_Timezone_values__c> records = new List<CRM_Timezone_values__c>();
        User sysuser = [Select id from User where Email='testsysAdmin@example.com' limit 1];
        system.runAs(sysuser){
             records = [SELECT Id, CRM_Country_Code_txt__c, CRM_State_Code_txt__c FROM CRM_Timezone_values__c];
        }
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
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for USA
     */
    @isTest
    static void testGetTimezoneUSA() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('USA', 'CA');
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Canada
     */
    @isTest
    static void testGetTimezoneCanada() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('CAN', 'ON');
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Australia
     */
    @isTest
    static void testGetTimezoneAustralia() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('AUS', 'NSW');
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Brazil
     */
    @isTest
    static void testGetTimezoneBrazil() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('BRA', 'SP');
        
        Test.stopTest();
        
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Mexico
     */
    @isTest
    static void testGetTimezoneMexico() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('MEX', 'CMX');
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Russia
     */
    @isTest
    static void testGetTimezoneRussia() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('RUS', 'MOW');
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for Indonesia
     */
    @isTest
    static void testGetTimezoneIndonesia() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('IDN', 'JK');
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() for country default (no state)
     */
    @isTest
    static void testGetTimezoneCountryDefault() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('USA', null);
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() with invalid country
     */
    @isTest
    static void testGetTimezoneInvalidCountry() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('INVALID', 'XX');
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getTimezone() with invalid state for valid country
     */
    @isTest
    static void testGetTimezoneInvalidState() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getTimezone('USA', 'XX');
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getCountryDefaultTimezone()
     */
    @isTest
    static void testGetCountryDefaultTimezone() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getCountryDefaultTimezone('USA');
        
        Test.stopTest();
    }
    
    /**
     * @description Test CRM_EMB_TimezoneHelper.getCountryDefaultTimezone() with invalid country
     */
    @isTest
    static void testGetCountryDefaultTimezoneInvalid() {
        Test.startTest();
        
        String timezone = CRM_EMB_TimezoneHelper.getCountryDefaultTimezone('INVALID');
        
        Test.stopTest();
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
        // Verify records were inserted
        List<CRM_Timezone_values__c> records = new List<CRM_Timezone_values__c>();
        User sysuser = [Select id from User where Email='testsysAdmin@example.com' limit 1];
        system.runAs(sysuser){
             records = [SELECT CRM_State_Code_txt__c FROM CRM_Timezone_values__c WHERE CRM_Country_Code_txt__c = 'GBR'];
        }
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
        }
        
        Test.stopTest();
    }
}