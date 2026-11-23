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
    @AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName, String fieldsToReturn, String whereClause)
    {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        String sanitiziedfieldsToReturn = String.escapeSingleQuotes(fieldsToReturn);
        
        List<Result> results = new List<Result>();
        //sanitizedSearchString = escapeSOSLTerm(sanitizedSearchString);
        // Build our SOSL query
        String searchQuery = 'SELECT '+ sanitiziedfieldsToReturn +' FROM ' + sanitizedSObjectAPIName;
        
        if(whereClause != null && !whereClause.trim().equals('')){
            searchQuery += ' WHERE '+ whereClause;
        }
        searchQuery += ' Limit 100';
        
        System.debug('Query formed >>' + searchQuery);
        // Execute the Query
        List<SObject> searchList = Database.query(searchQuery);
        
        // Create a list of matches to return
        if(searchList!=null && searchList.size()>0){
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
                    if(!fieldLabel.equalsIgnoreCase('id') && !fieldLabel.equalsIgnoreCase('Title') && !fieldLabel.equalsIgnoreCase('Name')){
                        if((String.valueOf(so.get(fieldLabel))) != null){
                            fieldValues = fieldValues + '' + '-' + '' +(fieldLabel=='Core_MDF_Total_Dollar_Impact_amt__c'?
                                                                        ('$'+String.valueOf(so.get(fieldLabel))) :
                                                                        String.valueOf(so.get(fieldLabel)));
                        }
                    }
                }
                
                fieldValues.removeEnd(',');
                results.add(new Result(fieldValues, so.Id));      
            }
        }
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