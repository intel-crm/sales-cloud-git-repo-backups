/**
 * @description Batch class to populate CRM_Timezone_values__c custom object with 
 *              State and Country/Territory picklist data along with IANA timezones.
 *              This batch reads picklist values from Account.BillingCountryCode and 
 *              Account.BillingStateCode fields, maps the dependencies, and creates 
 *              records in the CRM_Timezone_values__c object.
 * 
 * @usage Execute in Anonymous Apex:
 *        // Delete existing records first (optional)
 *        delete [SELECT Id FROM CRM_Timezone_values__c];
 *        
 *        // Run the batch
 *        Database.executeBatch(new CRM_EMB_TimezoneValuesBatch(), 200);
 * 
 * @author Aswin Selvaraj/Citrus
 * @date 2026-07-21
 */
public class CRM_EMB_TimezoneValuesBatch implements Database.Batchable<CRM_EMB_TimezoneValuesBatch.StateCountryWrapper>, Database.Stateful {
    
    // Track statistics
    private Integer totalProcessed = 0;
    private Integer totalSuccess = 0;
    private Integer totalFailed = 0;
    private List<String> errorMessages = new List<String>();
    
    /**
     * @description Wrapper class to hold country-state data
     */
    public class StateCountryWrapper {
        public String countryLabel;
        public String countryCode;
        public String stateLabel;
        public String stateCode;
        
        public StateCountryWrapper(String countryLabel, String countryCode, String stateLabel, String stateCode) {
            this.countryLabel = countryLabel;
            this.countryCode = countryCode;
            this.stateLabel = stateLabel;
            this.stateCode = stateCode;
        }
    }
    
    /**
     * @description Start method - retrieves all country and state picklist combinations
     * @param bc BatchableContext
     * @return Iterable of StateCountryWrapper objects
     */
    public Iterable<StateCountryWrapper> start(Database.BatchableContext bc) {
        List<StateCountryWrapper> wrappers = new List<StateCountryWrapper>();
        
        // Get country picklist values
        Schema.DescribeFieldResult countryField = Account.BillingCountryCode.getDescribe();
        List<Schema.PicklistEntry> countryEntries = countryField.getPicklistValues();
        
        // Get state picklist values
        Schema.DescribeFieldResult stateField = Account.BillingStateCode.getDescribe();
        List<Schema.PicklistEntry> stateEntries = stateField.getPicklistValues();
        
        // Build country code to label map
        Map<String, String> countryCodeToLabel = new Map<String, String>();
        Map<Integer, String> countryIndexToCode = new Map<Integer, String>();
        
        Integer countryIndex = 0;
        for (Schema.PicklistEntry entry : countryEntries) {
            if (entry.isActive()) {
                countryCodeToLabel.put(entry.getValue(), entry.getLabel());
                countryIndexToCode.put(countryIndex, entry.getValue());
                
                // Add country-only entry (no state)
                wrappers.add(new StateCountryWrapper(
                    entry.getLabel(),
                    entry.getValue(),
                    null,
                    null
                ));
            }
            countryIndex++;
        }
        
        /*Schema.DescribeFieldResult stateField = Account.BillingStateCode.getDescribe();
        List<Schema.PicklistEntry> stateEntries = stateField.getPicklistValues();
        // Process states with their controlling country
        for (Schema.PicklistEntry stateEntry : stateEntries) {
            if (stateEntry.isActive()) {
                // Get the validFor bytes to determine controlling country
                Blob validForBlob = stateEntry.getValidFor();
                if (validForBlob != null) {
                    List<Integer> controllingIndexes = getControllingIndexes(validForBlob);
                    
                    for (Integer ctrlIndex : controllingIndexes) {
                        if (countryIndexToCode.containsKey(ctrlIndex)) {
                            String countryCode = countryIndexToCode.get(ctrlIndex);
                            String countryLabel = countryCodeToLabel.get(countryCode);
                            
                            wrappers.add(new StateCountryWrapper(
                                countryLabel,
                                countryCode,
                                stateEntry.getLabel(),
                                stateEntry.getValue()
                            ));
                        }
                    }
                }
            }
        }*/

// Process states with their controlling country
for (Schema.PicklistEntry stateEntry : stateEntries) {
    if (stateEntry.isActive()) {
        // Serialize and deserialize PicklistEntry to access hidden 'validFor' property
        PicklistEntryWrapper pleWrapper = (PicklistEntryWrapper) JSON.deserialize(
            JSON.serialize(stateEntry), 
            PicklistEntryWrapper.class
        );
        
        if (String.isNotBlank(pleWrapper.validFor)) {
            // Convert base64 validFor string to Blob
            Blob validForBlob = EncodingUtil.base64Decode(pleWrapper.validFor);
            
            List<Integer> controllingIndexes = getControllingIndexes(validForBlob);
            
            for (Integer ctrlIndex : controllingIndexes) {
                if (countryIndexToCode.containsKey(ctrlIndex)) {
                    String countryCode = countryIndexToCode.get(ctrlIndex);
                    String countryLabel = countryCodeToLabel.get(countryCode);
                    
                    wrappers.add(new StateCountryWrapper(
                        countryLabel,
                        countryCode,
                        stateEntry.getLabel(),
                        stateEntry.getValue()
                    ));
                }
            }
        }
    }
}
        
        return wrappers;
    }
    
    /**
     * @description Execute method - creates CRM_Timezone_values__c records
     * @param bc BatchableContext
     * @param scope List of StateCountryWrapper objects to process
     */
    public void execute(Database.BatchableContext bc, List<StateCountryWrapper> scope) {
        List<CRM_Timezone_values__c> recordsToInsert = new List<CRM_Timezone_values__c>();
        
        for (StateCountryWrapper wrapper : scope) {
            // Get timezone using helper class
            String timezone= CRM_EMB_TimezoneHelper.getTimezone(
                wrapper.countryCode, 
                wrapper.stateCode
            );
            
            // Create record
            CRM_Timezone_values__c record = new CRM_Timezone_values__c();
            //record.Name = generateRecordName(wrapper);
            record.CRM_Country_txt__c = wrapper.countryLabel;
            record.CRM_Country_Code_txt__c = wrapper.countryCode;
            record.CRM_State_txt__c = wrapper.stateLabel;
            record.CRM_State_Code_txt__c = wrapper.stateCode;
            record.CRM_Timezone_txt__c = timezone;
            
            recordsToInsert.add(record);
        }
        
        // Insert records with partial success allowed
        if (!recordsToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(recordsToInsert, false);
            
            for (Integer i = 0; i < results.size(); i++) {
                totalProcessed++;
                if (results[i].isSuccess()) {
                    totalSuccess++;
                } else {
                    totalFailed++;
                    for (Database.Error err : results[i].getErrors()) {
                        String errMsg = 'Record: ' + recordsToInsert[i].Name + ' - Error: ' + err.getMessage();
                        if (errorMessages.size() < 100) {errorMessages.add(errMsg);
                        }
                    }
                }
            }
        }
    }
    
    /**
     * @description Finish method - logs completion statistics
     * @param bc BatchableContext
     */
    public void finish(Database.BatchableContext bc) { }
    
    
    /**
     * @description Decode validFor blob to get controlling field indexes
     * @param validFor Blob containing the validFor data
     * @return List of controlling field indexes
     */
    private List<Integer> getControllingIndexes(Blob validFor) {
        List<Integer> indexes = new List<Integer>();
        
        // Convert blob to base64 string
        String base64String = EncodingUtil.base64Encode(validFor);
        
        // Decode base64 to get bytes
        Blob decodedBlob = EncodingUtil.base64Decode(base64String);
        String hexString = EncodingUtil.convertToHex(decodedBlob);
        
        // Process each byte
        Integer byteIndex = 0;
        for (Integer i = 0; i < hexString.length(); i += 2) {
            String hexByte = hexString.substring(i, i + 2);
            Integer byteValue = hexToInteger(hexByte);
            
            // Check each bit in the byte
            for (Integer bit = 0; bit < 8; bit++) {
                Integer mask = 1 << (7 - bit);
                if ((byteValue & mask) != 0) {
                    indexes.add(byteIndex * 8 + bit);
                }
            }
            byteIndex++;
        }
        
        return indexes;
    }
    
    /**
     * @description Convert hex string to integer
     * @param hex Two character hex string
     * @return Integer value
     */
    private Integer hexToInteger(String hex) {
        Integer result = 0;
        for (Integer i = 0; i < hex.length(); i++) {
            String c = hex.substring(i, i + 1).toLowerCase();
            Integer digit;
            if (c >= '0' && c <= '9') {
                digit = Integer.valueOf(c);
            } else {
                digit = 10 + (c.charAt(0) - 97); // 'a' = 97 in ASCII
            }
            result = result * 16 + digit;
        }
        return result;
    }
    public class PicklistEntryWrapper {
    public String active { get; set; }
    public String defaultValue { get; set; }
    public String label { get; set; }
    public String value { get; set; }
    public String validFor { get; set; } // Contains the Base64 bitmask
}
}