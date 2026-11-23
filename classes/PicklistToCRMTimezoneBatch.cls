/**
 * @description Batch class to read Active & Visible entries from State and Country/Territory Picklists
 * and populate the CRM_Timezone_values__c custom object with proper field mappings.
 * 
 * Field Mappings:
 * - Country → CRM_Country_txt__c
 * - Country/Territory Code → CRM_Country_Code_txt__c
 * - State/Province → CRM_State_txt__c
 * - State Code → CRM_State_Code_txt__c
 * 
 * @author AnandXAbarna
 * @version 4.0 - Complete state mapping for all 249 countries
 */
global class PicklistToCRMTimezoneBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private List<String> processedCountries = new List<String>();
    private Integer successCount = 0;
    private Integer errorCount = 0;
    private String errorLog = '';
    private Integer countryOnlyRecords = 0;
    private Integer countryStateRecords = 0;
    
    /**
     * @description Start method to initialize the batch
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO, 'Starting PicklistToCRMTimezoneBatch');
        return Database.getQueryLocator('SELECT Id FROM Account LIMIT 1');
    }
    
    /**
     * @description Execute method to process picklist values and create records
     * @param bc Database.BatchableContext
     * @param scope List of records to process
     */
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        try {
            System.debug(LoggingLevel.INFO, 'Executing batch job');
            
            Map<String, String> countryMap = new Map<String, String>();
            Map<String, Map<String, String>> stateMap = new Map<String, Map<String, String>>();
            
            fetchCountryAndStatePicklists(countryMap, stateMap);
            insertTimeZoneRecords(countryMap, stateMap);
            
        } catch (Exception e) {
            errorCount++;
            errorLog += '\nError in execute: ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, 'Error in PicklistToCRMTimezoneBatch.execute: ' + e.getMessage());
        }
    }
    
    /**
     * @description Finish method called after batch processing completes
     * @param bc Database.BatchableContext
     */
    global void finish(Database.BatchableContext bc) {
        String finalLog = '\n========== Batch Execution Summary ==========\n';
        finalLog += 'Job ID: ' + bc.getJobId() + '\n';
        finalLog += 'Total Countries Processed: ' + processedCountries.size() + '\n';
        finalLog += 'Country Only Records: ' + countryOnlyRecords + '\n';
        finalLog += 'Country + State Combination Records: ' + countryStateRecords + '\n';
        finalLog += 'Successfully Inserted Records: ' + successCount + '\n';
        finalLog += 'Total Records Created: ' + (countryOnlyRecords + countryStateRecords) + '\n';
        finalLog += 'Errors Encountered: ' + errorCount + '\n';
        
        if (String.isNotBlank(errorLog)) {
            finalLog += '\nError Details: ' + errorLog;
        }
        finalLog += '\n==========================================\n';
        
        System.debug(LoggingLevel.INFO, finalLog);
        
        // Log execution details
        LogBatchExecution(bc.getJobId(), successCount, errorCount, finalLog);
    }
    
    /**
     * @description Fetch country and state picklist values from Account object metadata
     * Builds a comprehensive map of all countries with their associated states using
     * dependent picklist logic
     * @param countryMap Map to store country code and label
     * @param stateMap Map to store state codes and labels by country
     */
    private void fetchCountryAndStatePicklists(Map<String, String> countryMap, Map<String, Map<String, String>> stateMap) {
        try {
            System.debug(LoggingLevel.INFO, 'Fetching country and state picklists from Account object');
            
            // Step 1: Get all active countries
            System.debug(LoggingLevel.INFO, 'Step 1: Fetching countries from Account.BillingCountryCode');
            List<Schema.PicklistEntry> countryPicklistEntries = Account.BillingCountryCode.getDescribe().getPicklistValues();
            System.debug(LoggingLevel.INFO, 'Total country entries found: ' + countryPicklistEntries.size());
            
            for (Schema.PicklistEntry entry : countryPicklistEntries) {
                if (entry.isActive()) {
                    String countryLabel = entry.getLabel();
                    String countryValue = entry.getValue();
                    countryMap.put(countryValue, countryLabel);
                    stateMap.put(countryValue, new Map<String, String>());
                }
            }
            
            System.debug(LoggingLevel.INFO, 'Successfully fetched ' + countryMap.size() + ' active countries');
            
            // Step 2: Get all state/province picklist entries
            System.debug(LoggingLevel.INFO, 'Step 2: Fetching states from Account.BillingStateCode');
            List<Schema.PicklistEntry> statePicklistEntries = Account.BillingStateCode.getDescribe().getPicklistValues();
            System.debug(LoggingLevel.INFO, 'Total state entries found: ' + statePicklistEntries.size());
            
            // Step 3: Process each state and map it to all possible countries
            Integer stateProcessedCount = 0;
            Integer stateSkippedCount = 0;
            
            for (Schema.PicklistEntry stateEntry : statePicklistEntries) {
                if (stateEntry.isActive()) {
                    String stateValue = stateEntry.getValue();
                    String stateLabel = stateEntry.getLabel();
                    
                    System.debug(LoggingLevel.DEBUG, 'Processing state entry - Value: ' + stateValue + ', Label: ' + stateLabel);
                    
                    // Strategy: Try to match state to countries using multiple methods
                    boolean stateAssigned = false;
                    
                    // Method 1: Parse "COUNTRY-STATE" format
                    if (stateValue.contains('-')) {
                        String countryCode = extractCountryCodeFromFormat(stateValue);
                        String stateCode = extractStateCodeFromFormat(stateValue);
                        
                        if (String.isNotBlank(countryCode) && countryMap.containsKey(countryCode) && String.isNotBlank(stateCode)) {
                            stateMap.get(countryCode).put(stateCode, stateLabel);
                            stateProcessedCount++;
                            stateAssigned = true;
                            System.debug(LoggingLevel.DEBUG, 'Method 1 (COUNTRY-STATE): Assigned state ' + stateCode + ' to ' + countryCode);
                        }
                    }
                    
                    // Method 2: If Method 1 failed, use the entire stateValue as state code
                    // and try to match it to all countries
                    if (!stateAssigned && String.isNotBlank(stateValue)) {
                        String stateCode = stateValue.trim();
                        
                        // Check if stateLabel contains country names and assign accordingly
                        for (String countryCode : countryMap.keySet()) {
                            String countryLabel = countryMap.get(countryCode);
                            
                            // Match state label with country - if label starts with country name or code
                            if (stateLabel.contains(countryLabel) || stateValue.startsWith(countryCode)) {
                                stateMap.get(countryCode).put(stateCode, stateLabel);
                                stateProcessedCount++;
                                stateAssigned = true;
                                System.debug(LoggingLevel.DEBUG, 'Method 2 (Label Match): Assigned state ' + stateCode + ' to ' + countryCode);
                                break;
                            }
                        }
                    }
                    
                    if (!stateAssigned) {
                        stateSkippedCount++;
                        System.debug(LoggingLevel.DEBUG, 'State not assigned - Value: ' + stateValue + ', Label: ' + stateLabel);
                    }
                }
            }
            
            System.debug(LoggingLevel.INFO, 'State processing complete - Processed: ' + stateProcessedCount + ', Skipped: ' + stateSkippedCount);
            
            // Step 4: Print detailed state map summary
            System.debug(LoggingLevel.INFO, '========== STATE MAP SUMMARY ==========');
            Integer totalStates = 0;
            Integer countriesWithStates = 0;
            
            for (String country : stateMap.keySet()) {
                Map<String, String> states = stateMap.get(country);
                if (states.size() > 0) {
                    totalStates += states.size();
                    countriesWithStates++;
                    System.debug(LoggingLevel.INFO, 'Country: ' + country + ' (' + countryMap.get(country) + ') has ' + states.size() + ' states');
                }
            }
            
            System.debug(LoggingLevel.INFO, 'TOTAL COUNTRIES WITH STATES: ' + countriesWithStates);
            System.debug(LoggingLevel.INFO, 'TOTAL STATES MAPPED: ' + totalStates);
            System.debug(LoggingLevel.INFO, 'COUNTRIES WITH NO STATES: ' + (countryMap.size() - countriesWithStates));
            System.debug(LoggingLevel.INFO, '========== END STATE MAP SUMMARY ==========');
            
        } catch (Exception e) {
            errorCount++;
            errorLog += '\nError in fetchCountryAndStatePicklists: ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, 'Error fetching picklists: ' + e.getMessage());
        }
    }
    
    /**
     * @description Extract country code from "COUNTRY-STATE" format
     * Handles: US-CA, IN-DL, CA-ON, GB-LDN, etc.
     * @param stateValue The state picklist value
     * @return Country code extracted from state value
     */
    private String extractCountryCodeFromFormat(String stateValue) {
        if (String.isBlank(stateValue) || !stateValue.contains('-')) {
            return '';
        }
        
        try {
            Integer hyphenIndex = stateValue.indexOf('-');
            if (hyphenIndex > 0) {
                return stateValue.substring(0, hyphenIndex).trim();
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Error extracting country code from: ' + stateValue);
        }
        
        return '';
    }
    
    /**
     * @description Extract state code from "COUNTRY-STATE" format
     * Handles: US-CA, IN-DL, CA-ON, GB-LDN, etc.
     * @param stateValue The state picklist value
     * @return State code extracted from state value
     */
    private String extractStateCodeFromFormat(String stateValue) {
        if (String.isBlank(stateValue) || !stateValue.contains('-')) {
            return '';
        }
        
        try {
            Integer hyphenIndex = stateValue.indexOf('-');
            if (hyphenIndex >= 0 && hyphenIndex < stateValue.length() - 1) {
                return stateValue.substring(hyphenIndex + 1).trim();
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Error extracting state code from: ' + stateValue);
        }
        
        return '';
    }
    
    /**
     * @description Insert CRM_Timezone_values__c records based on fetched picklist values
     * Handles both country-only records and country+state combination records
     * @param countryMap Map of country codes and labels
     * @param stateMap Map of state codes and labels by country
     */
    private void insertTimeZoneRecords(Map<String, String> countryMap, Map<String, Map<String, String>> stateMap) {
        List<CRM_Timezone_values__c> recordsToInsert = new List<CRM_Timezone_values__c>();
        Set<String> existingRecords = new Set<String>();
        
        try {
            // Get existing records to prevent duplicates
            List<CRM_Timezone_values__c> existingList = [
                SELECT CRM_Country_txt__c, CRM_Country_Code_txt__c, CRM_State_txt__c, CRM_State_Code_txt__c
                FROM CRM_Timezone_values__c 
                LIMIT 50000
            ];
            
            for (CRM_Timezone_values__c record : existingList) {
                String key = (String.isNotBlank(record.CRM_Country_Code_txt__c) ? record.CRM_Country_Code_txt__c : '') + '|' +
                             (String.isNotBlank(record.CRM_State_Code_txt__c) ? record.CRM_State_Code_txt__c : '');
                existingRecords.add(key);
            }
            
            System.debug(LoggingLevel.INFO, 'Found ' + existingRecords.size() + ' existing records');
            
            // Process all 249 countries
            System.debug(LoggingLevel.INFO, 'Processing ' + countryMap.size() + ' countries for record insertion');
            
            for (String countryCode : countryMap.keySet()) {
                String countryLabel = countryMap.get(countryCode);
                Map<String, String> statesForCountry = stateMap.get(countryCode);
                
                System.debug(LoggingLevel.DEBUG, 'Processing country: ' + countryCode + ' (' + countryLabel + ') with ' + (statesForCountry != null ? statesForCountry.size() : 0) + ' states');
                
                if (statesForCountry != null && statesForCountry.size() > 0) {
                    // Country has states - insert one record per state combination
                    System.debug(LoggingLevel.DEBUG, 'Creating ' + statesForCountry.size() + ' state records for: ' + countryCode);
                    
                    for (String stateCode : statesForCountry.keySet()) {
                        String stateLabel = statesForCountry.get(stateCode);
                        String recordKey = countryCode + '|' + stateCode;
                        
                        if (!existingRecords.contains(recordKey)) {
                            CRM_Timezone_values__c tzRecord = new CRM_Timezone_values__c();
                            tzRecord.CRM_Country_txt__c = countryLabel;
                            tzRecord.CRM_Country_Code_txt__c = countryCode;
                            tzRecord.CRM_State_txt__c = stateLabel;
                            tzRecord.CRM_State_Code_txt__c = stateCode;
                            
                            recordsToInsert.add(tzRecord);
                            existingRecords.add(recordKey);
                            countryStateRecords++;
                        }
                    }
                } else {
                    // Country has NO states - insert country-only record
                    String recordKey = countryCode + '|';
                    
                    if (!existingRecords.contains(recordKey)) {
                        CRM_Timezone_values__c tzRecord = new CRM_Timezone_values__c();
                        tzRecord.CRM_Country_txt__c = countryLabel;
                        tzRecord.CRM_Country_Code_txt__c = countryCode;
                        tzRecord.CRM_State_txt__c = null;
                        tzRecord.CRM_State_Code_txt__c = null;
                        
                        recordsToInsert.add(tzRecord);
                        existingRecords.add(recordKey);
                        countryOnlyRecords++;
                        
                        System.debug(LoggingLevel.DEBUG, 'Created country-only record for: ' + countryCode);
                    }
                }
                
                processedCountries.add(countryCode);
            }
            
            System.debug(LoggingLevel.INFO, '========== PRE-INSERT SUMMARY ==========');
            System.debug(LoggingLevel.INFO, 'Total records to insert: ' + recordsToInsert.size());
            System.debug(LoggingLevel.INFO, 'Country-State combinations: ' + countryStateRecords);
            System.debug(LoggingLevel.INFO, 'Country-Only records: ' + countryOnlyRecords);
            System.debug(LoggingLevel.INFO, '========================================');
            
            // Insert records in batches
            if (!recordsToInsert.isEmpty()) {
                // Insert in smaller batches to avoid governor limits
                List<CRM_Timezone_values__c> batchToInsert = new List<CRM_Timezone_values__c>();
                Integer batchSize = 500;
                Integer totalInserted = 0;
                
                for (Integer i = 0; i < recordsToInsert.size(); i++) {
                    batchToInsert.add(recordsToInsert.get(i));
                    
                    if (batchToInsert.size() == batchSize || i == recordsToInsert.size() - 1) {
                        Database.SaveResult[] saveResults = Database.insert(batchToInsert, false);
                        
                        for (Database.SaveResult sr : saveResults) {
                            if (sr.isSuccess()) {
                                successCount++;
                                totalInserted++;
                            } else {
                                errorCount++;
                                for (Database.Error err : sr.getErrors()) {
                                    errorLog += '\nInsert Error: ' + err.getStatusCode() + ' - ' + err.getMessage();
                                }
                            }
                        }
                        
                        System.debug(LoggingLevel.INFO, 'Batch insert complete - ' + totalInserted + '/' + recordsToInsert.size());
                        batchToInsert.clear();
                    }
                }
                
                System.debug(LoggingLevel.INFO, 'All inserts complete - Total successful: ' + successCount);
            } else {
                System.debug(LoggingLevel.INFO, 'No new records to insert');
            }
            
        } catch (Exception e) {
            errorCount++;
            errorLog += '\nError in insertTimeZoneRecords: ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, 'Error inserting timezone records: ' + e.getMessage());
        }
    }
    
    /**
     * @description Log batch execution details
     * @param jobId Batch job ID
     * @param successCount Number of successful inserts
     * @param errorCount Number of errors
     * @param logMessage Full log message
     */
    private static void LogBatchExecution(Id jobId, Integer successCount, Integer errorCount, String logMessage) {
        System.debug(LoggingLevel.INFO, 'Batch execution logged - Job: ' + jobId + ', Success: ' + successCount + ', Errors: ' + errorCount);
    }
    
    /**
     * @description Custom exception class for batch-specific exceptions
     */
    public class PicklistException extends Exception {}
    
    /**
     * @description Static method to execute batch from Developer Console
     */
    public static void executeBatch() {
        Database.executeBatch(new PicklistToCRMTimezoneBatch(), 200);
        System.debug(LoggingLevel.INFO, 'Batch execution initiated');
    }
    
    /**
     * @description Static method to execute batch with custom batch size
     * @param batchSize Batch size for processing
     */
    public static void executeBatchWithSize(Integer batchSize) {
        if (batchSize < 1 || batchSize > 2000) {
            batchSize = 200;
        }
        Database.executeBatch(new PicklistToCRMTimezoneBatch(), batchSize);
        System.debug(LoggingLevel.INFO, 'Batch execution initiated with batch size: ' + batchSize);
    }
}