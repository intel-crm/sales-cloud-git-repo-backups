/***************************************************************************************************** 
Class Name   :    Core_MDF_GenericRelatedListController
Description  :    Server-side controller of core_MDF_GenricReleatedList
Added By     :    Rishabh - Weezer
Created Date :    01/12/2025
******************************************************************************************************/
public with sharing class Core_MDF_GenericRelatedListController {

    @AuraEnabled(cacheable=true)
    public static List<SObject> getRelatedRecords(
        String childObjectApi,
        String relationshipField,
        Id parentId,
        String fieldList
    ) {
        // Always return 
        List<SObject> results = new List<SObject>();

        try {
            // Basic validation added
            if (String.isBlank(childObjectApi) ||
                String.isBlank(relationshipField) ||
                String.isBlank(fieldList) ||
                parentId == null) {
                return results;
            }

            String soql =
                'SELECT Id,' + fieldList +
                ' FROM ' + childObjectApi +
                ' WHERE ' + relationshipField + ' = :parentId';

            // Execute query
            results = Database.query(soql);
            
            return results;

        } catch (Exception e) {
            System.debug('ERROR in getRelatedRecords: ' + e.getMessage());
            return results; // never return null
        }
    }
    @AuraEnabled(cacheable=true)
public static Map<String, String> getFieldLabels(String objectApiName, String fieldList) {

    Map<String, String> fieldLabelMap = new Map<String, String>();

    if(String.isBlank(objectApiName) || String.isBlank(fieldList)){
        return fieldLabelMap;
    }

    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
    Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();

    for(String fld : fieldList.split(',')){
        fld = fld.trim();

        if(fieldsMap.containsKey(fld)){
            fieldLabelMap.put(
                fld,
                fieldsMap.get(fld).getDescribe().getLabel()
            );
        }
    }

    return fieldLabelMap;
}

}