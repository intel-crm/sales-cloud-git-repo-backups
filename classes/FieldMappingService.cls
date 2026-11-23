/**
 * Developer  - DINESH
 * Created Date - 7/11/2024
 * Description -
 *   FieldMappingService class provides utilities to map fields between PCC_Change_Request_Field_Mapping__c records and SObjects.
 *
 * This service primarily facilitates the transformation of SObjects into a wrapper object structure as defined by
 * PCC_Change_Request_Field_Mapping__c field mappings. This is useful for transforming complex SObject relationships
 * into simpler structures for various application requirements.
 *
 * Methods:
 * - createObjectWrapper: Creates a list of map structures based on the provided field mappings.
 * - handleFieldMapping: Helper method to map fields based on field mappings, supporting nested fields.
 * - getNestedObject: Resolves nested SObjects based on a dotted field API name.
 * - mapFieldValue: Maps the field value to the wrapper map based on the field data type.
 *
 */
public without sharing class FieldMappingService {
    
    /**
     * Creates a list of map structures based on the provided PCC_Change_Request_Field_Mapping__c records.
     *
     * @param crList List of PCC_Change_Request_Field_Mapping__c records that define the field mappings.
     * @param objectName The name of the child object (optional) to be used for mapping. If blank, the objRecord is used directly.
     * @param objRecord The primary SObject record which contains the data to be mapped.
     * @return List of maps where each map represents a record with field mappings applied.
     */
    public static List<Map<String, String>> createObjectWrapper(List<PCC_Change_Request_Field_Mapping__c> crList, String objectName, SObject objRecord) {
        List<Map<String, String>> childRecordsLst = new List<Map<String, String>>();
        List<SObject> childRecords = new List<SObject>();
        System.debug('crList -->'+JSON.serialize(crList));
        System.debug('objRecord -->'+JSON.serialize(objRecord));
        System.debug('objRecord -->'+JSON.serialize(objRecord.getPopulatedFieldsAsMap()));
        
        if (!String.isBlank(objectName)) {
            if(objRecord.getPopulatedFieldsAsMap().keySet().contains(objectName)){
                childRecords = (List<SObject>) objRecord.getSObjects(objectName);
            }
        } else {
            childRecords.add(objRecord);
        }
        
        for (SObject record : childRecords) {
            Map<String, String> recordsMap = new Map<String, String>();
            for (PCC_Change_Request_Field_Mapping__c crRecord : crList) {
                if (crRecord.Enable_for_Query__c && !crRecord.ByPassSoqlValueMappping__c) {
                    if (crRecord.isParent__c) {
                        handleFieldMapping(crRecord, objRecord, recordsMap);
                    } else if(!String.isBlank(objectName)){
                        handleFieldMapping(crRecord, record, recordsMap);
                    }
                }
            }
            childRecordsLst.add(recordsMap);
        }
        System.debug('childRecordsLst -->'+JSON.serialize(childRecordsLst));
        
        return childRecordsLst;
    }
    
    /**
     * Handles the field mapping from SObject to the map based on the provided PCC_Change_Request_Field_Mapping__c record.
     *
     * @param crRecord The field mapping definition.
     * @param sObj The SObject from which the field value is extracted.
     * @param recordsMap The map where the mapped field value is stored.
     */
    private static void handleFieldMapping(PCC_Change_Request_Field_Mapping__c crRecord, SObject sObj, Map<String, String> recordsMap) {
        if (crRecord.PCC_Field_API_Name__c.contains('.')) {
            SObject nestedObject = getNestedObject(sObj, crRecord.PCC_Field_API_Name__c);
            if (nestedObject != null) {
                mapFieldValue(crRecord, nestedObject, recordsMap);
            }
        } else {
            mapFieldValue(crRecord, sObj, recordsMap);
        }
        System.debug('Map field values -->'+JSON.serialize(recordsMap));
    }
    
    /**
     * Retrieves the nested SObject based on the dotted field API name.
     *
     * @param sObj The SObject from which the nested SObject is resolved.
     * @param fieldApiName The dotted API name of the field representing the nested SObject.
     * @return The nested SObject if resolved, otherwise null.
     */
    private static SObject getNestedObject(SObject sObj, String fieldApiName) {
        List<String> fieldNames = fieldApiName.split('\\.');
        SObject nestedObject = sObj;
        for (Integer i = 0; i < fieldNames.size() - 1; i++) {
            if (nestedObject != null) {
                nestedObject = nestedObject.getSObject(fieldNames[i]);
            }
        }
        return nestedObject;
    }
    
    /**
     * Maps the field value from the SObject to the map based on the field data type specified in the mapping record.
     *
     * @param crRecord The field mapping definition.
     * @param sObj The SObject from which the field value is extracted.
     * @param recordsMap The map where the mapped field value is stored.
     */
    private static void mapFieldValue(PCC_Change_Request_Field_Mapping__c crRecord, SObject sObj, Map<String, String> recordsMap) {
        String fieldName = crRecord.PCC_Field_API_Name__c.contains('.') ? crRecord.PCC_Field_API_Name__c.split('\\.')[crRecord.PCC_Field_API_Name__c.split('\\.').size() - 1] : crRecord.PCC_Field_API_Name__c;
        if ( sObj.getSObjectType().getDescribe().fields.getMap().containsKey(fieldName) && sObj.get(fieldName) != null ) { //sObj.get(fieldName) != null
            if (crRecord.Object_Field_Data_Type__c == 'Decimal') {
                recordsMap.put(crRecord.WrapperFieldName__c, String.valueOf(sObj.get(fieldName)));
            } else if (crRecord.Object_Field_Data_Type__c == 'String') {
                recordsMap.put(crRecord.WrapperFieldName__c, (String) sObj.get(fieldName));
            } else if (crRecord.Object_Field_Data_Type__c == 'Date') {
                recordsMap.put(crRecord.WrapperFieldName__c, String.valueOf(sObj.get(fieldName)).trim().split(' ')[0]);
            } else if (crRecord.Object_Field_Data_Type__c == 'Boolean') {
                recordsMap.put(crRecord.WrapperFieldName__c, String.valueOf(sObj.get(fieldName)));
            } else if (crRecord.Object_Field_Data_Type__c == 'DateTime') {
                recordsMap.put(crRecord.WrapperFieldName__c, String.valueOf(sObj.get(fieldName)));
            }
        }
        
        // System.debug(recordsMap, )
    }
}