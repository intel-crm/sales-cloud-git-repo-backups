public with sharing class Core_MDF_SearchableDropdownList {
	
    @AuraEnabled(Cacheable=true)
    public static Result[] getSearchableList(String sObjectAPIName, String fieldsToReturn, String whereClause ){
       
         // Sanitze the input
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        String sanitiziedfieldsToReturn = String.escapeSingleQuotes(fieldsToReturn);
        
        List<Result> results = new List<Result>();
         String searchQuery = 'SELECT '+ sanitiziedfieldsToReturn +' FROM ' + sanitizedSObjectAPIName;
        
         if(whereClause != null && !whereClause.trim().equals('')){
            searchQuery += ' WHERE '+ whereClause;
        }
        
        searchQuery += ' Limit 20';
        
        System.debug('Query formed >>' + searchQuery);
        
        List<SObject> searchList = Database.query(searchQuery);
        System.debug('List-> '+searchList);
        
        //results = [Select id, Name from Account limit 20];
        
        // Create a list of matches to return
        if(searchList!=null && searchList.size()>0){
            for (SObject so : searchList)
            {
                String fieldValues = '';
                List<String> returnFieldList = fieldsToReturn.split(',');
                System.debug('returnFieldList-> '+returnFieldList);
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
                
                fieldValues = fieldValues.removeEnd(',');
                results.add(new Result(fieldValues, so.Id));      
            }
        }
        System.debug('Result-> '+results);
        
       return results;
    }
    
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