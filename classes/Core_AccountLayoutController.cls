/**************************************************************************************
 Apex Class Name:  Core_AccountLayoutController
 Version     : 1.0
 Created Date: 3/27/2024
 Function    : To send the boolean value as true or false for preview section visibilty
 Modification Log :
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Rakshit Misra             5/9/2024             Original Version
 *************************************************************************************/
public with sharing class Core_AccountLayoutController{
    @AuraEnabled(cacheable = true)
    public static boolean displayAccountPreviewSection(){
        boolean displaySection = false;
        string customLabelStartDate = System.Label.accountPreviewVisibility;
        String customLabelStart = customLabelStartDate.split(';')[0];
        String customLabelEnd = customLabelStartDate.split(';')[1];
        If (!String.isBlank(customLabelStartDate)){
            date todayDate = Date.today();
            date customLabelStartDateValue = date.valueOf(customLabelStart);
            date customLabelEndDateValue = date.valueOf(customLabelEnd);
            if (todayDate >= customLabelStartDateValue && todayDate <= customLabelEndDateValue){
                displaySection = true;
            }
        }
        return displaySection;
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, Boolean> getFieldPermissions(String objectApiName){
        Map<String, Boolean> fieldPermissions = new Map<String, Boolean>();

        // Get the fields for the specified object
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();

        // Iterate through the fields and check permissions
        for (String fieldName : fieldsMap.keySet()){
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            fieldPermissions.put(fieldName, fieldDescribe.isUpdateable());
        }
        return fieldPermissions;
    }

}