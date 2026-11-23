/***************************************************************************************************
* Apex Class Name : Core_IPS_CustomLookupController
* Test Class Name : Core_IPS_CustomLookupControllerTest
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                    23/10/2019              Created
* Ganapati                    27/12/2019              Modified for US534054 - LEX: Searching Account within a MAP to quickly return the correct results
****************************************************************************************************/
public with sharing class Core_IPS_CustomLookupController {
    
    /***************************************************************************************************
Method Name: findRecords
Version     : 1.0 
Created Date: 23 Oct 2019
Description : This method takes searchKey, queryString, record limit and returns sobject list 
Example for queryString - 'SELECT Id, Name FROM Account WHERE Name LIKE :key LIMIT :recordLimit'
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  23/10/2019           Created for US410459
* Ganapati                  27/12/2019           Modified for US534054

****************************************************************************************************/        
    @AuraEnabled(cacheable = true)
    public static List<SObject> findRecords(String searchKey, String queryString, Integer recordLimit, Boolean isSosl){
        String key = '%' + searchKey + '%';
        List<SObject> sObjectList;
        if(isSosl) {
            key = '*' + searchKey + '*';
            /*US1038991 - 09/07/2021 - Karthik - security vulnerability --*/
            /*security fix cannot be done as the functionality is breaking, 
after creating a case throwing error while adding project & product to the case*/ 
            List<List<sObject>> searchRes = Search.query(queryString);
            sObjectList = searchRes[0];    
            
        } else {
            sObjectList = Database.query(queryString);
        }
        return sObjectList;
    }
    
    /***************************************************************************************************
Method Name: findTotalRecords
Version     : 1.0 
Created Date: 27 Dec 2019
Description : This method takes searchKey and countQueryString and returns count of records in Integer 
Example for countQueryString - 'SELECT count() FROM Account WHERE Name LIKE :key'
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  27/12/2019           Created for US534054
****************************************************************************************************/     
    @AuraEnabled
    public static Integer findTotalRecords(String searchKey, String query){
        String key = '%' + searchKey + '%';
        /*US1038991 - 09/07/2021 - Karthik - security vulnerability --*/
        Integer result = Database.countQuery(query);
        return result;
    }
    
    @AuraEnabled
    public static Integer findTotalRecordsSosl(String searchKey, String query){
        String key = '*' + searchKey + '*';
        /*US1038991 - 09/07/2021 - Karthik - security vulnerability --*/
        /*security fix cannot be done as the functionality is breaking, 
after creating a case throwing error while adding project & product to the case*/ 
        List<List<sObject>> searchRes = Search.query(query);
        return searchRes[0].size();
    }
}