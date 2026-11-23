/**
 * @description Utility class to retrieve picklist values for PartnerFundRequest object
 * @author Your Name
 * @date June 10, 2026
 */
public with sharing class PartnerFundRequestPicklistUtility {
    
    // Constants
    private static final String PARTNER_FUND_REQUEST_OBJECT = 'PartnerFundRequest';
    private static final String ERROR_PREFIX = 'PartnerFundRequestPicklistUtility Error: ';
    
    /**
     * @description Get all picklist fields and their values for PartnerFundRequest object
     * @return Map<String, List<String>> Field API name mapped to list of picklist values
     */
    public static Map<String, List<String>> getAllPicklistValues() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        
        try {
            Schema.DescribeSObjectResult partnerFundRequestDescribe = getPartnerFundRequestDescribe();
            Map<String, Schema.SObjectField> fieldMap = partnerFundRequestDescribe.fields.getMap();
            
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                
                if (isPicklistFieldType(fieldDescribe)) {
                    List<String> picklistValues = extractPicklistValues(fieldDescribe);
                    if (!picklistValues.isEmpty()) {
                        picklistMap.put(fieldName, picklistValues);
                    }
                }
            }
            
            System.debug('Successfully retrieved ' + picklistMap.size() + ' picklist fields for PartnerFundRequest');
            
        } catch (Exception e) {
            handleException('getAllPicklistValues', e);
        }
        
        return picklistMap;
    }
    
    /**
     * @description Get picklist values for a specific field
     * @param fieldName API name of the field
     * @return List<String> List of active picklist values
     */
    public static List<String> getPicklistValues(String fieldName) {
        List<String> picklistValues = new List<String>();
        
        if (String.isBlank(fieldName)) {
            throw new PartnerFundRequestPicklistException('Field name cannot be null or empty');
        }
        
        try {
            Schema.DescribeSObjectResult partnerFundRequestDescribe = getPartnerFundRequestDescribe();
            Map<String, Schema.SObjectField> fieldMap = partnerFundRequestDescribe.fields.getMap();
            String normalizedFieldName = fieldName.toLowerCase();
            
            if (fieldMap.containsKey(normalizedFieldName)) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(normalizedFieldName).getDescribe();
                
                if (isPicklistFieldType(fieldDescribe)) {
                    picklistValues = extractPicklistValues(fieldDescribe);
                } else {
                    throw new PartnerFundRequestPicklistException('Field "' + fieldName + '" is not a picklist field on PartnerFundRequest object');
                }
            } else {
                throw new PartnerFundRequestPicklistException('Field "' + fieldName + '" does not exist on PartnerFundRequest object');
            }
            
        } catch (PartnerFundRequestPicklistException e) {
            throw e;
        } catch (Exception e) {
            handleException('getPicklistValues for field: ' + fieldName, e);
        }
        
        return picklistValues;
    }
    
    /**
     * @description Get picklist values with labels and values for a specific field
     * @param fieldName API name of the field
     * @return List<PicklistOption> List of picklist options with label and value
     */
    public static List<PicklistOption> getPicklistOptionsWithLabels(String fieldName) {
        List<PicklistOption> picklistOptions = new List<PicklistOption>();
        
        if (String.isBlank(fieldName)) {
            throw new PartnerFundRequestPicklistException('Field name cannot be null or empty');
        }
        
        try {
            Schema.DescribeSObjectResult partnerFundRequestDescribe = getPartnerFundRequestDescribe();
            Map<String, Schema.SObjectField> fieldMap = partnerFundRequestDescribe.fields.getMap();
            String normalizedFieldName = fieldName.toLowerCase();
            
            if (fieldMap.containsKey(normalizedFieldName)) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(normalizedFieldName).getDescribe();
                
                if (isPicklistFieldType(fieldDescribe)) {
                    picklistOptions = extractPicklistOptions(fieldDescribe);
                } else {
                    throw new PartnerFundRequestPicklistException('Field "' + fieldName + '" is not a picklist field on PartnerFundRequest object');
                }
            } else {
                throw new PartnerFundRequestPicklistException('Field "' + fieldName + '" does not exist on PartnerFundRequest object');
            }
            
        } catch (PartnerFundRequestPicklistException e) {
            throw e;
        } catch (Exception e) {
            handleException('getPicklistOptionsWithLabels for field: ' + fieldName, e);
        }
        
        return picklistOptions;
    }
    
    /**
     * @description Get all picklist fields metadata including field info and options
     * @return List<PicklistFieldMetadata> List of picklist field metadata
     */
    public static List<PicklistFieldMetadata> getPicklistFieldsMetadata() {
        List<PicklistFieldMetadata> picklistFields = new List<PicklistFieldMetadata>();
        
        try {
            Schema.DescribeSObjectResult partnerFundRequestDescribe = getPartnerFundRequestDescribe();
            Map<String, Schema.SObjectField> fieldMap = partnerFundRequestDescribe.fields.getMap();
            
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                
                if (isPicklistFieldType(fieldDescribe)) {
                    List<PicklistOption> options = extractPicklistOptions(fieldDescribe);
                    
                    if (!options.isEmpty()) {
                        PicklistFieldMetadata metadata = new PicklistFieldMetadata();
                        metadata.objectType = PARTNER_FUND_REQUEST_OBJECT;
                        metadata.fieldName = fieldDescribe.getName();
                        metadata.fieldLabel = fieldDescribe.getLabel();
                        metadata.fieldType = fieldDescribe.getType().name();
                        metadata.isRequired = !fieldDescribe.isNillable();
                        metadata.isUpdateable = fieldDescribe.isUpdateable();
                        metadata.isCreateable = fieldDescribe.isCreateable();
                        metadata.options = options;
                        metadata.optionCount = options.size();
                        metadata.helpText = fieldDescribe.getInlineHelpText();
                        
                        picklistFields.add(metadata);
                    }
                }
            }
            
            // Sort by field label for better usability
            picklistFields.sort();
            
        } catch (Exception e) {
            handleException('getPicklistFieldsMetadata', e);
        }
        
        return picklistFields;
    }
    
    /**
     * @description Check if a field is a picklist field
     * @param fieldName API name of the field
     * @return Boolean True if field is picklist, false otherwise
     */
    public static Boolean isPicklistField(String fieldName) {
        if (String.isBlank(fieldName)) {
            return false;
        }
        
        try {
            Schema.DescribeSObjectResult partnerFundRequestDescribe = getPartnerFundRequestDescribe();
            Map<String, Schema.SObjectField> fieldMap = partnerFundRequestDescribe.fields.getMap();
            String normalizedFieldName = fieldName.toLowerCase();
            
            if (fieldMap.containsKey(normalizedFieldName)) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(normalizedFieldName).getDescribe();
                return isPicklistFieldType(fieldDescribe);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Error checking if field is picklist: ' + e.getMessage());
        }
        
        return false;
    }
    
    /**
     * @description Get default value for a picklist field
     * @param fieldName API name of the field
     * @return String Default value or null if no default
     */
    public static String getPicklistDefaultValue(String fieldName) {
        if (String.isBlank(fieldName)) {
            return null;
        }
        
        try {
            Schema.DescribeSObjectResult partnerFundRequestDescribe = getPartnerFundRequestDescribe();
            Map<String, Schema.SObjectField> fieldMap = partnerFundRequestDescribe.fields.getMap();
            String normalizedFieldName = fieldName.toLowerCase();
            
            if (fieldMap.containsKey(normalizedFieldName)) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(normalizedFieldName).getDescribe();
                
                if (isPicklistFieldType(fieldDescribe)) {
                    List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
                    for (Schema.PicklistEntry entry : entries) {
                        if (entry.isDefaultValue() && entry.isActive()) {
                            return entry.getValue();
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Error getting default value for field: ' + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * @description Validate if a value exists in a picklist field
     * @param fieldName API name of the field
     * @param value Value to validate
     * @return Boolean True if value exists and is active
     */
    public static Boolean isValidPicklistValue(String fieldName, String value) {
        if (String.isBlank(fieldName) || String.isBlank(value)) {
            return false;
        }
        
        try {
            List<String> validValues = getPicklistValues(fieldName);
            return validValues.contains(value);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Error validating picklist value: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Get picklist field information including dependencies
     * @param fieldName API name of the field
     * @return PicklistFieldInfo Detailed field information
     */
    public static PicklistFieldInfo getPicklistFieldInfo(String fieldName) {
        if (String.isBlank(fieldName)) {
            throw new PartnerFundRequestPicklistException('Field name cannot be null or empty');
        }
        
        try {
            Schema.DescribeSObjectResult partnerFundRequestDescribe = getPartnerFundRequestDescribe();
            Map<String, Schema.SObjectField> fieldMap = partnerFundRequestDescribe.fields.getMap();
            String normalizedFieldName = fieldName.toLowerCase();
            
            if (fieldMap.containsKey(normalizedFieldName)) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(normalizedFieldName).getDescribe();
                
                if (isPicklistFieldType(fieldDescribe)) {
                    PicklistFieldInfo fieldInfo = new PicklistFieldInfo();
                    fieldInfo.fieldName = fieldDescribe.getName();
                    fieldInfo.fieldLabel = fieldDescribe.getLabel();
                    fieldInfo.fieldType = fieldDescribe.getType().name();
                    fieldInfo.isRequired = !fieldDescribe.isNillable();
                    fieldInfo.isUpdateable = fieldDescribe.isUpdateable();
                    fieldInfo.isCreateable = fieldDescribe.isCreateable();
                    fieldInfo.helpText = fieldDescribe.getInlineHelpText();
                    fieldInfo.length = fieldDescribe.getLength();
                    fieldInfo.options = extractPicklistOptions(fieldDescribe);
                    fieldInfo.defaultValue = getPicklistDefaultValue(fieldName);
                    fieldInfo.isDependentPicklist = fieldDescribe.isDependentPicklist();
                    fieldInfo.isRestrictedPicklist = fieldDescribe.isRestrictedPicklist();
                    
                    return fieldInfo;
                } else {
                    throw new PartnerFundRequestPicklistException('Field "' + fieldName + '" is not a picklist field on PartnerFundRequest object');
                }
            } else {
                throw new PartnerFundRequestPicklistException('Field "' + fieldName + '" does not exist on PartnerFundRequest object');
            }
            
        } catch (PartnerFundRequestPicklistException e) {
            throw e;
        } catch (Exception e) {
            handleException('getPicklistFieldInfo for field: ' + fieldName, e);
        }
        
        return null;
    }
    
    // Private Helper Methods
    
    /**
     * @description Get PartnerFundRequest object describe result
     * @return Schema.DescribeSObjectResult
     */
    private static Schema.DescribeSObjectResult getPartnerFundRequestDescribe() {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        if (!globalDescribe.containsKey(PARTNER_FUND_REQUEST_OBJECT)) {
            throw new PartnerFundRequestPicklistException('PartnerFundRequest object not found in org');
        }
        return globalDescribe.get(PARTNER_FUND_REQUEST_OBJECT).getDescribe();
    }
    
    /**
     * @description Check if field describe result represents a picklist field
     * @param fieldDescribe Field describe result
     * @return Boolean True if picklist field
     */
    private static Boolean isPicklistFieldType(Schema.DescribeFieldResult fieldDescribe) {
        Schema.DisplayType fieldType = fieldDescribe.getType();
        return (fieldType == Schema.DisplayType.PICKLIST || 
                fieldType == Schema.DisplayType.MULTIPICKLIST);
    }
    
    /**
     * @description Extract picklist values from field describe
     * @param fieldDescribe Field describe result
     * @return List<String> List of active picklist values
     */
    private static List<String> extractPicklistValues(Schema.DescribeFieldResult fieldDescribe) {
        List<String> picklistValues = new List<String>();
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.isActive()) {
                picklistValues.add(entry.getValue());
            }
        }
        
        return picklistValues;
    }
    
    /**
     * @description Extract picklist options with labels from field describe
     * @param fieldDescribe Field describe result
     * @return List<PicklistOption> List of picklist options
     */
    private static List<PicklistOption> extractPicklistOptions(Schema.DescribeFieldResult fieldDescribe) {
        List<PicklistOption> picklistOptions = new List<PicklistOption>();
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.isActive()) {
                PicklistOption option = new PicklistOption();
                option.label = entry.getLabel();
                option.value = entry.getValue();
                option.isDefault = entry.isDefaultValue();
                picklistOptions.add(option);
            }
        }
        
        return picklistOptions;
    }
    
    /**
     * @description Handle exceptions consistently
     * @param methodName Name of the method where exception occurred
     * @param e Exception to handle
     */
    private static void handleException(String methodName, Exception e) {
        String errorMessage = ERROR_PREFIX + methodName + ' - ' + e.getMessage();
        System.debug(LoggingLevel.ERROR, errorMessage);
        System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        throw new PartnerFundRequestPicklistException(errorMessage);
    }
    
    // Wrapper Classes
    
    /**
     * @description Wrapper class for picklist options
     */
    public class PicklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public Boolean isDefault { get; set; }
        
        public PicklistOption() {
            this.isDefault = false;
        }
        
        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
            this.isDefault = false;
        }
        
        public PicklistOption(String label, String value, Boolean isDefault) {
            this.label = label;
            this.value = value;
            this.isDefault = isDefault;
        }
    }
    
    /**
     * @description Wrapper class for picklist field metadata
     */
    public class PicklistFieldMetadata implements Comparable {
        @AuraEnabled public String objectType { get; set; }
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public String fieldType { get; set; }
        @AuraEnabled public Boolean isRequired { get; set; }
        @AuraEnabled public Boolean isUpdateable { get; set; }
        @AuraEnabled public Boolean isCreateable { get; set; }
        @AuraEnabled public List<PicklistOption> options { get; set; }
        @AuraEnabled public Integer optionCount { get; set; }
        @AuraEnabled public String helpText { get; set; }
        
        public PicklistFieldMetadata() {
            this.options = new List<PicklistOption>();
            this.optionCount = 0;
            this.isRequired = false;
            this.isUpdateable = false;
            this.isCreateable = false;
        }
        
        // Implement Comparable interface for sorting
        public Integer compareTo(Object compareTo) {
            PicklistFieldMetadata compareToMetadata = (PicklistFieldMetadata) compareTo;
            if (fieldLabel == compareToMetadata.fieldLabel) return 0;
            if (fieldLabel > compareToMetadata.fieldLabel) return 1;
            return -1;
        }
    }
    
    /**
     * @description Wrapper class for detailed picklist field information
     */
    public class PicklistFieldInfo {
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public String fieldType { get; set; }
        @AuraEnabled public Boolean isRequired { get; set; }
        @AuraEnabled public Boolean isUpdateable { get; set; }
        @AuraEnabled public Boolean isCreateable { get; set; }
        @AuraEnabled public String helpText { get; set; }
        @AuraEnabled public Integer length { get; set; }
        @AuraEnabled public List<PicklistOption> options { get; set; }
        @AuraEnabled public String defaultValue { get; set; }
        @AuraEnabled public Boolean isDependentPicklist { get; set; }
        @AuraEnabled public Boolean isRestrictedPicklist { get; set; }
        
        public PicklistFieldInfo() {
            this.options = new List<PicklistOption>();
            this.isRequired = false;
            this.isUpdateable = false;
            this.isCreateable = false;
            this.isDependentPicklist = false;
            this.isRestrictedPicklist = false;
        }
    }
}