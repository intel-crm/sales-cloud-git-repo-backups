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
                                                        String criteriaField, String criteriaFieldValue, String additionalCriteria, String sharingFlag, String strLabels){  //TWC3117-17837
                                                            
                                                            try{
                                                                objectDataWrapper recordData = new objectDataWrapper();
                                                                // Highlight: Unused Local Variable - 14285
                                                                // Map<String, String> resultMap = new Map<String, String>();
                                                                // List<String> returnMap = new List<String>();
                                                                List<SObject> lstRecords = new List<SObject>();
                                                                String sanitizedStrFields = String.escapeSingleQuotes(strFields);
                                                                reqFields = '';
                                                                system.debug('@@@reqFields'+reqFields);
                                                                system.debug('@@@relatedobjectApiName'+relatedobjectApiName);
                                                                system.debug('@@@criteriaField'+criteriaField);
                                                                system.debug('@@@criteriaFieldValue'+criteriaFieldValue);
                                                                system.debug('@@@additionalCriteria'+additionalCriteria);
                                                                List<String> inputFieldsList = sanitizedStrFields.split(',');
                                                                String userType = UserInfo.getUserType();
                                                                recordData.userType = userType;
                                                                // Highlight: Unused Local Variable - 14285
                                                                // String inputFields;
                                                                Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(relatedobjectApiName).getDescribe();
                                                                isCustomObject = objectDescribe.isCustom();
                                                                Map<String, Schema.SObjectField> MapofField = objectDescribe.fields.getMap();
                                                                recordData.objectLabel = objectDescribe.getLabel();
                                                                recordData.isCustomObject = isCustomObject;
                                                                prepareData(inputFieldsList,MapofField,recordData);
                                                                recordData.IdToValueMap = IdToValueMap;
                                                                recordData.fieldDataMap = fieldDataMap;
                                                                recordData.translatedLabels = getTranslatedLabels(strLabels); //TWC3117-17837
                                                                if(String.isNotBlank(reqFields)){           
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
        Set<String> addedQueryFields = new Set<String>();
        for(String field: inputFieldsList){
            String trimmedField = field != null ? field.trim() : null;
            if(String.isBlank(trimmedField)){
                continue;
            }
            Schema.SObjectField fieldName = MapofField.get(trimmedField);
            if(fieldName == null){
                continue;
            }
            Schema.DescribeFieldResult describeResult = fieldName.getDescribe();
            if(!describeResult.isAccessible()){
                continue;
            }

            fieldDataWrapper fld = new fieldDataWrapper();
            fld.fieldName = describeResult.getName();
            fld.fieldLabel = describeResult.getLabel();
            fld.dataType = String.valueOf(describeResult.getType());
            fieldDataMap.put(fld.fieldName,fld);

            if(!addedQueryFields.contains(fld.fieldName)){
                if(String.isBlank(reqFields)){
                    reqFields = fld.fieldName;
                } else {
                    reqFields += ',' + fld.fieldName;
                }
                addedQueryFields.add(fld.fieldName);
            }
            /*if(fld.dataType=='REFERENCE'){
relativeField = isCustomObject ? field.replace('__c','__r.Name') : field+'.Name';
IdToValueMap.put(field, relativeField);
}*/
            if (fld.dataType == 'REFERENCE') {
                Schema.DescribeFieldResult dfr = describeResult;
                String relationshipName = dfr.getRelationshipName();
                if (relationshipName != null) {
                    List<Schema.SObjectType> referenceTypes = dfr.getReferenceTo();
                    if(referenceTypes != null && !referenceTypes.isEmpty()){
                        Schema.DescribeSObjectResult refDescribe = referenceTypes[0].getDescribe();
                        Map<String, Schema.SObjectField> refFieldMap = refDescribe.fields.getMap();
                        if(refFieldMap.containsKey('Name') && refFieldMap.get('Name').getDescribe().isAccessible()){
                            relativeField = relationshipName + '.Name';
                            IdToValueMap.put(fld.fieldName, relativeField);
                            if(!addedQueryFields.contains(relativeField)){
                                reqFields += ',' + relativeField;
                                addedQueryFields.add(relativeField);
                            }
                        }
                    }
                }
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
        @AuraEnabled public List<String> translatedLabels { get; set; } //TWC3117-17837
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
            return false;
        }
    }
    @AuraEnabled(cacheable=false)
    public static Boolean getClaimData(Id recordId) {
        PartnerFundClaim claim = [SELECT Core_MDF_Has_Sub_Claims_Ind__c FROM PartnerFundClaim WHERE Id = :recordId LIMIT 1];
        return claim.Core_MDF_Has_Sub_Claims_Ind__c;
    }

    //TWC3117-17837
    /****************************************************************************************************** 
    Method Name:        getTranslatedLabels
    @return       :     List<String>
    @parameters   :     String (comma separated column labels)
    Description   :     Bulk-resolves column label translations from Core_MDF_History_Header_Translation__mdt
                        in a single SOQL query, so the LWC does not need one server call per label.
    ******************************************************************************************************/
    public static List<String> getTranslatedLabels(String strLabels) {
        List<String> translatedLabels = new List<String>();
        if (String.isBlank(strLabels)) {
            return translatedLabels;
        }
        List<String> labels = strLabels.split(',');
        Set<String> developerNames = new Set<String>();
        for (String lbl : labels) {
            // Convert spaces to underscores to match DeveloperName format
            developerNames.add(lbl.trim().replaceAll('\\s+', '_'));
        }
        Map<String, String> keyToTranslation = new Map<String, String>();
        for (Core_MDF_History_Header_Translation__mdt rec : [
            SELECT DeveloperName, toLabel(Core_MDF_History_Header_Translation_nm__c)
            FROM Core_MDF_History_Header_Translation__mdt
            WHERE DeveloperName IN :developerNames
        ]) {
            keyToTranslation.put(rec.DeveloperName, rec.Core_MDF_History_Header_Translation_nm__c);
        }
        for (String lbl : labels) {
            String original = lbl.trim();
            String metadataKey = original.replaceAll('\\s+', '_');
            String translated = keyToTranslation.get(metadataKey);
            translatedLabels.add(String.isNotBlank(translated) ? translated : original);
        }
        return translatedLabels;
    }
    //TWC3117-17837

    @AuraEnabled(cacheable=false)
    public static String getTableHeader(String displayHeader) {   
        String userLang = UserInfo.getLanguage();
        String strLabel = '';
        if(String.isNotBlank(displayHeader)) {
            Core_MDF_History_Header_Translation__mdt[] langTrans;
            String query = 'Select  toLabel(Core_MDF_History_Header_Translation_nm__c) ' + ' from Core_MDF_History_Header_Translation__mdt where DeveloperName=\''+String.escapeSingleQuotes(displayHeader)+'\'';
            String v1 = query;
            langTrans=Database.query(v1);
            if(langTrans != null && langTrans.size() > 0) {               
                strLabel = String.valueOf(langTrans[0].Core_MDF_History_Header_Translation_nm__c);
            }
        }
        return strLabel;
    }  
    
    //17311
    @AuraEnabled(cacheable=true)
    public static Boolean evaluateVisibilityCriteria(String recordId, String criteria) {
        try {
            if (String.isBlank(recordId) || String.isBlank(criteria)) {
                return true;
            }
            Id recId = Id.valueOf(recordId);
            String objectType = recId.getSObjectType().getDescribe().getName();
            String soql = 'SELECT Id FROM ' + objectType + ' WHERE Id = :recordId';
            if (String.isNotBlank(criteria)) {
                soql += ' AND (' + criteria + ')';
            }
            
            List<SObject> results = Database.query(soql);
            return !results.isEmpty();
            
        } catch (Exception e) {
            return true;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getLabelValue(String labelName) {
        return Label.get('', labelName);
    }
    
}