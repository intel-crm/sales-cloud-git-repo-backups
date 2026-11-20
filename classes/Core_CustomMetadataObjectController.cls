/****************************************************************************************************************************************
* Class Name  : Core_CustomMetadataObjectController 
* Version     : 1.0 
* Created Date: 23-10-2024
* Modification Log :
* Developer            		  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                       23-10-2024         This apex class contains dynamic methods similar to custom metadata standard methods
*****************************************************************************************************************************************/
public with sharing class Core_CustomMetadataObjectController {
    public String customMetadataName;
    public Core_CustomMetadataObjectController(String cmName) {
        customMetadataName = cmName;
    }

    /**
     * This method is similar to getInstance method of custom metadata.
     */
    public Map<String, Object> getInstance(String devName) {
        Map<String, Object> finalInstance = new Map<String, Object>();
        Map<String, String> fieldMetadata = new Map<String, String>();

        for (Core_CustomMetadata_Object__c cmRec : getMetadata(devName)) {
            if (cmRec.Header_row__c == null) {
                fieldMetadata = getFieldMetadata(cmRec);
            } else {
                finalInstance = getFinalInstance(cmRec, fieldMetadata);
            }
        }
        return finalInstance;
    }
    /**
     * This method is similar to getAll method of custom metadata.
     */
    public Map<String, Map<String, Object>> getAll() {
        Map<String, Map<String, Object>> allRecs = new Map<String, Map<String, Object>>();
        Map<String, String> fieldMetadata = new Map<String, String>();

        for (Core_CustomMetadata_Object__c cmRec : getMetadata(null)) {
            if (cmRec.Header_row__c == null) {
                fieldMetadata = getFieldMetadata(cmRec);
            } else {
                Map<String, Object> finalInst = getFinalInstance(cmRec, fieldMetadata);
                allRecs.put(String.valueOf(finalInst.get('DeveloperName')), finalInst);
            }
        }

        return allRecs;
    }

    /**
     * This method is used to create an instance of Map<String,object>
     */
    private static Map<String, Object> getFinalInstance(Core_CustomMetadata_Object__c cmRec, Map<String, String> fieldMetadata) {
        Map<String, Object> finalInstance = new Map<String, Object>();
        for (String s : fieldMetadata.keySet()) {
            finalInstance.put(fieldMetadata.get(s), cmRec.get(s));
        }

        return finalInstance;
    }

    /**
     * This method is used to map values with field definitions
     */
    private static Map<String, String> getFieldMetadata(Core_CustomMetadata_Object__c cmRec) {
        Map<String, String> fieldMetadata = new Map<String, String>();
        fieldMetadata.put('MasterLabel__c', 'MasterLabel');
        fieldMetadata.put('DeveloperName__c', 'DeveloperName');

        for (String fieldApiName : getFieldApiNames()) {
            if (String.isNotBlank(String.valueOf(cmRec.get(fieldApiName)))) {
                fieldMetadata.put(fieldApiName, (String) cmRec.get(fieldApiName));
            }
        }

        return fieldMetadata;
    }

    /**
     * This method is similar to construct query for soql on Core_CustomMetadata_Object__c.
     */
    private List<Core_CustomMetadata_Object__c> getMetadata(String devName) {
        String query = 'SELECT Id,MasterLabel__c,Header_row__c,DeveloperName__c';

        for (String fieldApiName : getFieldApiNames()) {
            query += ',' + fieldApiName;
        }

        query += ' FROM Core_CustomMetadata_Object__c WHERE Metadata_Name__c =:customMetadataName';

        if (String.isNotBlank(devName)) {
            query += ' AND (DeveloperName__c =:devName OR Header_row__c = null)';
        }

        query += ' ORDER BY Header_row__c DESC';
        return Database.query(String.escapeSingleQuotes(query));
    }
    /**
     * This method is used to get field api names of Core_CustomMetadata_Object__c object.
     */
    private static List<String> getFieldApiNames() {
        List<String> fieldApiNames = new List<String>();

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Core_CustomMetadata_Object__c');
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        for (String fieldName : fieldsMap.keySet()) {
            if (fieldName.contains('field_')) {
                fieldApiNames.add(fieldName);
            }
        }

        return fieldApiNames;
    }
}