/* Class Name : Core_MDF_GetObjectDetails
* Test class : Core_MDF_GetObjectDetailsTest
*/ 

public without sharing class Core_MDF_GetObjectDetails {
    public static String PowerPartner = Core_MDF_CCP_ConstantClass.Ext_UserType;
    public static Map<String,fieldDataWrapper> fieldDataMap = new Map<String,fieldDataWrapper>();
    public static String relativeField;
    public static String fieldsForQuery;
    public static String reqFields;
    public static Map<String,String> IdToValueMap = new Map<String,String>();
    public static Boolean isCustomObject = false;
    /****************************************************************************************************** 
Method Name:        getFieldsAndRecords
@return       :     void
@parameters   :     String, String, String, String
Description   :     To get fields from fieldset and get records from database
created By: Namratha        Date: 8th April 2024   
******************************************************************************************************/
//Move to a new apex class

//add try catch
@AuraEnabled
public static objectDataWrapper getFieldsAndRecords(String relatedobjectApiName, String strFields,
                                             String criteriaField, String criteriaFieldValue, String additionalCriteria, String sharingFlag){
    try{                                       
        objectDataWrapper recordData = new objectDataWrapper();
        Map<String, String> resultMap = new Map<String, String>();
        List<String> returnMap = new List<String>();
        List<SObject> lstRecords = new List<SObject>();
        String sanitizedStrFields = String.escapeSingleQuotes(strFields);
        reqFields = sanitizedStrFields;
        List<String> inputFieldsList = sanitizedStrFields.split(',');
        String userType = UserInfo.getUserType();
        recordData.userType = userType;
        String inputFields;
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(relatedobjectApiName).getDescribe();
        isCustomObject = objectDescribe.isCustom();
        Map<String, Schema.SObjectField> MapofField = objectDescribe.fields.getMap();
        recordData.objectLabel = objectDescribe.getLabel();
        recordData.isCustomObject = isCustomObject;
        prepareData(inputFieldsList,MapofField,recordData);
        recordData.IdToValueMap = IdToValueMap;
        recordData.fieldDataMap = fieldDataMap;
        if(!String.isEmpty(sanitizedStrFields) && !String.isEmpty(sanitizedStrFields)){           
            //prepare SOQL query based on fieldAPIs	
            String query = 'SELECT Id, ';
            query += reqFields;
            query += ' FROM ' + String.escapeSingleQuotes(relatedobjectApiName) ;

            //Just in case criteria field not specified then it will return all records
            if(!(String.isEmpty(criteriaField) && String.isEmpty(criteriaFieldValue))){
                query += ' WHERE ' + String.escapeSingleQuotes(criteriaField) + '=\'' +String.escapeSingleQuotes(criteriaFieldValue) + '\'';
            }
            if(!(String.isEmpty(additionalCriteria))){
                query += ' AND ' + String.escapeSingleQuotes(additionalCriteria);
            }
            query += String.escapeSingleQuotes(' WITH SECURITY_ENFORCED');
            if(sharingFlag == 'true'){
            	Core_MDF_GetObjectDetails_Sharing_Utility searchObj = new Core_MDF_GetObjectDetails_Sharing_Utility();
                lstRecords = searchObj.getSearch(query);
            }else{             
            	//execute query
                lstRecords = Database.query(query);
            }
            recordData.recordsData = lstRecords;
        }
        return recordData;
    }
    catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
        return null;
    }  
}
    
    public static void prepareData(List<String> inputFieldsList,Map<String, Schema.SObjectField> MapofField, objectDataWrapper recordData){
        for(String field: inputFieldsList){
            fieldDataWrapper fld = new fieldDataWrapper();
            Schema.SObjectField fieldName = MapofField.get(field);
            fld.fieldName = fieldName.getDescribe().getName();
            fld.fieldLabel = fieldName.getDescribe().getLabel();
            fld.dataType = String.valueOf(fieldName.getDescribe().getType());
            fieldDataMap.put(fld.fieldName,fld);
            if(fld.dataType=='REFERENCE'){
                relativeField = isCustomObject ? field.replace('__c','__r.Name') : field+'.Name';
                IdToValueMap.put(field, relativeField);
            }
            if(!String.isEmpty(relativeField)){
                fieldsForQuery = ','+relativeField;
                reqFields += fieldsForQuery;
            }
            if(fld.dataType == 'PICKLIST' || fld.dataType == 'MULTIPICKLIST'){
                if(recordData.picklistTranslatedMap == null){
                    recordData.picklistTranslatedMap = new Map<String, Map<String, String>>();
                }
                Map<String, String> valueLabelMap = new Map<String, String>();
                List<Schema.PicklistEntry> pickVals = fieldName.getDescribe().getPicklistValues();
                for(Schema.PicklistEntry entry : pickVals){
                    valueLabelMap.put(entry.getValue(), entry.getLabel()); // key: API name, value: translated label
                }
                recordData.picklistTranslatedMap.put(field, valueLabelMap);
            }
        }
    }
    
    public with sharing class Core_MDF_GetObjectDetails_Sharing_Utility{
        public List<SObject> getSearch(String query){
            List<SObject> lstRecords = new List<SObject>();
            lstRecords = Database.query(query);
            return lstRecords;
        }
    }
    
    public class objectDataWrapper {
    @AuraEnabled public String userType  { get; set; }
    @AuraEnabled public List<SObject> recordsData {get; set; }
    @AuraEnabled public String objectLabel { get; set; }
    @AuraEnabled public Map<String,fieldDataWrapper> fieldDataMap { get; set; }
    @AuraEnabled public Map<String,String> IdToValueMap { get; set; }
    @AuraEnabled public Boolean isCustomObject { get; set; }
    @AuraEnabled public Map<String, Map<String, String>> picklistTranslatedMap { get; set; }
    }
    
    //Wrapper name -> caps
    public class fieldDataWrapper {
        @AuraEnabled public String fieldName { get; set;} //fldapiname
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public String dataType { get; set; }
    }
    
    /****************************************************************************************************** 
    Method to check if the record is active getFilterConditionResult
    Method Name     : getFilterConditionResult
    @return Boolean : true if active, false otherwise
    @parameters     : RecordId (Campaign Id)
    Description     : To get fields from fieldset and get records from database
    created By      : Ealayaraja Shekar 
    Date            : 22th September 2025        
    ******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean getFilterCondition(Id recordId, String restrictFieldVisiblityCriteriaFieldAPIName) {
    try{    
        // Get the SObjectType from the record Id
        Schema.SObjectType sObjectType = recordId.getSObjectType();
        String objectName = sObjectType.getDescribe().getName();

        if (String.isEmpty(restrictFieldVisiblityCriteriaFieldAPIName)) {
            return false; // Invalid criteria
        }

        // Build dynamic query
        String query = 'SELECT Id';

        // Extract field names from conditions for SELECT clause
        Set<String> fieldNames = new Set<String>();
        List<String> conditions = new List<String>();

        for (String condition : restrictFieldVisiblityCriteriaFieldAPIName.split(',')) {
            condition = condition.trim();
            if (condition.contains('=')) {
                String lhs = condition.substringBefore('=').trim();
                fieldNames.add(lhs);
                conditions.add(condition);
            }
        }

        if (fieldNames.isEmpty()) {
            return false; // No valid fields to query
        }

        for (String f : fieldNames) {
            query += ', ' + f;
        }

        query += ' FROM ' + objectName + ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'';

        if (!conditions.isEmpty()) {
            query += ' AND ' + String.join(conditions, ' AND ');
        }

        // Run query
        List<SObject> results = Database.query(query);

        if (!results.isEmpty()) {
            SObject result = results[0];
            // You can loop over fieldNames and return true if any field is true
            for (String f : fieldNames) {
                Object fieldValue = result.get(f);
                if (fieldValue instanceof Boolean && (Boolean)fieldValue) {
                    return true;
                }
            }
        }

        return false;
        
    }catch (Exception e) {
         Core_MDF_CCP_UtilityClass.logError(e);
        return null;
        }
    }
    
}