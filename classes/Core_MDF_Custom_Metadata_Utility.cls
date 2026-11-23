/****************************************************************************************************************************************
* Class Name  : Core_MDF_Custom_Metadata_Utility 
* Test Class  : Core_MDF_Custom_Metadata_Utility_Test
* Version     : 
* Created Date: 10-03-2024
* Modification Log :
* Developer                             Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Batthieni Gayathri        10/03/2024                   To fetch Core_MDF_CCP_Custom_Metadata_Utility__c records.
*****************************************************************************************************************************************/
public Without Sharing class Core_MDF_Custom_Metadata_Utility {


    public static List<sObject> getCustomObjectRecords(String whereClause) {
        System.debug('where clause*****'+whereClause);
         List<sObject> queryResults = new List<sObject>();
         Set<String> queryStringFields = new Set<String>();
        try{
            //if(categoryName == 'KPI'){
                String queryString = 'SELECT ';
                for(Schema.FieldSetMember fldSet : Schema.SObjectType.Core_MDF_CCP_Custom_Metadata_Utility__c.FieldSets.Core_MDF_CustomMetadata_Utility_FieldSet.getFields()) {
                    queryStringFields.add(fldSet.getFieldPath());         
                }
                if(!queryStringFields.isEmpty()){
                    for(String fldString : queryStringFields){
                        queryString += fldString + ',';
                    }
                }
                queryString = queryString.removeEnd(',');
                queryString += ' FROM Core_MDF_CCP_Custom_Metadata_Utility__c ';
                if (whereClause.trim() != '') {
                    String sanitizedWhereClause = String.escapeSingleQuotes(whereClause).replaceAll('\\\\','');
                    queryString += ' WHERE ' + sanitizedWhereClause ;
                }
            System.debug('queryString******'+queryString);
                queryResults = Database.query(queryString);
            System.debug('queryResults************'+queryResults);
            //}
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return queryResults;
        
        }
/****************************************************************************************************************************************
* Class Name  : Core_MDF_Custom_Metadata_Utility 
* Test Class  : Core_MDF_Custom_Metadata_Utility_Test
* Version     : 
* Created Date: 10-03-2024
* Modification Log :
* Developer                             Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Akanksha Gautam        10/03/2024                   To fetch Core_MDF_CCP_Custom_Metadata_Utility__c records.
*****************************************************************************************************************************************/    
    public static List<sObject> getCustomObjectRecordsUsingDynamicQuery(String query){
        Core_MDF_CCP_Custom_Metadata_Utility__c[] queryResults;
        // Highlight: Unused Local Variable - 14285
       // String strLabel = '';
        try{
            String sanitizedQuery = String.escapeSingleQuotes(query).replaceAll('\\\\','');
            if(sanitizedQuery != Null){
                System.debug('sanitizedQuery----'+sanitizedQuery);
                queryResults = Database.query(sanitizedQuery);
            } 
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return queryResults;
        
    }
}


/*Field 1         --Activity Category
  Field 2	      --Activity Type
  Field 3	      --Activity Subtype
  Field 4	      --Object API Field Name
  Sort order	  --Sort Order
  Checkbox Field 1--Is Picklist
  Checkbox Field 2--Is proposal Based
  Checkbox Field 3--Is Inactive For Activity
  Checkbox Field 4--Is Inactive For Claim
  Checkbox Field 5--Is Account Based
  Checkbox Field 6--Is EOLed 
  Checkbox Field 7--Manadtory
  Field 5
  Field 6         
  Field 7	
  Field 8	
  Field 9	
  Field 10	
  Is Active	              */