/***************************************************************************************************
* Apex Class Name : CustomLookupController
* Test Class Name : CustomLookupControllerTest
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                    23/10/2019              Created
****************************************************************************************************/
public with sharing class CustomLookupController {    
/***************************************************************************************************
Method Name: findRecords
Version     : 1.0 
Created Date: 23 Oct 2019
Description : This method takes searchKey and queryString and returns sobject list 
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  23/10/2019           Created for US410459
****************************************************************************************************/        
    @AuraEnabled(cacheable = true)
    public static List<SObject> findRecords(String searchKey, String queryString){
        String key = '%' + searchKey + '%';
        String QUERY = queryString;
        System.debug('key :::'+key);
        System.debug(System.LoggingLevel.DEBUG, QUERY);
        List<SObject> sObjectList = Database.query(QUERY);
        return sObjectList;
    }
}