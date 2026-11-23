/**************************************************************************************
Apex Class Name:  Core_MDF_LookupSObjectController
Version     : 1.0 
Created Date: 18 10 2018
Function    : class for the sObject Look up generic component 
Author      : Anjali Haryani
*************************************************************************************/

public with sharing class Core_MDF_LookupSObjectController {
    /**
    * Aura enabled method to search a specified SObject for a specific string
    */
    public static Result[] lookup(String searchString, String sObjectAPIName, String fieldsToReturn, String whereClause)
    {
        return lookup(searchString, sObjectAPIName, fieldsToReturn, whereClause, null);
    }

    @AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName, String fieldsToReturn, String whereClause, String searchFields)
    {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        String sanitiziedfieldsToReturn = String.escapeSingleQuotes(fieldsToReturn);
        
        List<Result> results = new List<Result>();
        //sanitizedSearchString = escapeSOSLTerm(sanitizedSearchString);
        // Build our SOSL query
        String searchQuery = 'SELECT '+ sanitiziedfieldsToReturn +' FROM ' + sanitizedSObjectAPIName;
        
        List<String> conditions = new List<String>();
        if(whereClause != null && !whereClause.trim().equals('')){
            // To Sanitize the where clause and replace @quote;
            whereClause = String.escapeSingleQuotes(whereClause);
            whereClause = whereClause.replace('@quote;','\'');
            conditions.add(whereClause);
        }

        if (String.isNotBlank(searchFields)) {
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(sObjectAPIName).getDescribe().fields.getMap();
            List<String> searchConditions = new List<String>();
            for (String searchField : searchFields.split(',')) {
                String fieldName = searchField.trim();
                if (!objectFields.containsKey(fieldName)) {
                    continue; // Skip invalid fields
                }
                searchConditions.add(fieldName + ' LIKE :searchTerm');
            }
            if (!searchConditions.isEmpty()) {
                conditions.add('(' + String.join(searchConditions, ' OR ') + ')');
            }
        }

        if (!conditions.isEmpty()) {
            searchQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }
        searchQuery += ' Limit 100';
        
        System.debug('searchQuery'+searchQuery);
        // Execute the Query
        String searchTerm = '%' + sanitizedSearchString + '%';
        List<SObject> searchList = Database.query(searchQuery);
        
        // Create a list of matches to return
        //ATHR - Deeply Nested if 16209
        if(searchList==null || searchList.isEmpty()){
            return results;
        }
        //if(searchList!=null && searchList.size()>0){
            for (SObject so : searchList)
            {
                String fieldValues = '';
                List<String> returnFieldList = fieldsToReturn.split(',');
                // Title field for MDF Objects and Name for other SFDC Objects
                if(returnFieldList.contains('Title')){
                    fieldValues = (String)so.get('Title');
                }else if(returnFieldList.contains('Name')){
                    fieldValues = (String)so.get('Name');
                }
                
                for(String fieldLabel : returnFieldList){
                    //ATHR - Deeply Nested if 16209
                    if(fieldLabel.equalsIgnoreCase('id') || fieldLabel.equalsIgnoreCase('Title') || fieldLabel.equalsIgnoreCase('Name')){
                        continue;
                    }
                    //if(!fieldLabel.equalsIgnoreCase('id') && !fieldLabel.equalsIgnoreCase('Title') && !fieldLabel.equalsIgnoreCase('Name')){
                        //ATHR - Deeply Nested if 16209
                        if((String.valueOf(so.get(fieldLabel))) == null){
                            continue;
                        }
                        //if((String.valueOf(so.get(fieldLabel))) != null){
                            fieldValues = fieldValues + '' + '-' + '' +(fieldLabel=='Core_MDF_Total_Dollar_Impact_amt__c'?
                                                                        ('$'+String.valueOf(so.get(fieldLabel))) :
                                                                        String.valueOf(so.get(fieldLabel)));
                        //}
                    //}
                }
                
                fieldValues = fieldValues.removeEnd(',');
                results.add(new Result(fieldValues, so.Id));      
            }
        //}
       
        return results;
    }

    
    /**
    * Inner class to wrap up an SObject Label and its Id
    */
    public class Result
    {
        @AuraEnabled public String objectLabel {get; set;}
        @AuraEnabled public Id objectId {get; set;}
        
        public Result(String sObjectLabel, Id sObjectId)
        {
            this.objectLabel = sObjectLabel;
            this.objectId = sObjectId;
        }
    }
}