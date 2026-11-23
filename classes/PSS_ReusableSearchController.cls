/*IPA2.0: US-TWC729-7976*/
public with sharing class PSS_ReusableSearchController {
    // @AuraEnabled
    // public static List <sObject> fetchSearchData(String objectName, String fieldName, String searchKeyWord) {
    //     system.debug('searchKeyWord-->' + searchKeyWord);
    //     system.debug('objectName-->' + objectName);
    //     system.debug('fieldName-->' + fieldName);
    //     String searchword = '%'+searchKeyWord+'%';
    //     List <sObject> returnList = new List <sObject>();
    //     // Create a Dynamic SOQL Query For Fetch Record List
    //       String sQuery =  'select id, ' +fieldName + ' From ' +objectName + ' Where ' + fieldName +' LIKE: searchword ';
    //    // String sQuery = 'Select ' + fieldName + ' From ' + objectName;
    //     //     sQuery = sQuery + ' Where ' + fieldName + ' like :'+searchword+' ';
        
    //    List <sObject> lstOfRecords = Database.query(sQuery);
    //     for (sObject obj: lstOfRecords) {
    //         returnList.add(obj);
    //     }
    //     system.debug('returnList-->' + returnList);
        
    //     // Dynamic SOSL Query
    //     String searchString = '*'+searchKeyWord+'*';
    //     String searchQuery = 'FIND \'' + searchString + '\' IN ALL FIELDS RETURNING ' +objectName + ' ';
    //     system.debug('searchQuery-->' + searchQuery);
    //     List<List <sObject>> searchList = search.query(searchQuery);
    //     system.debug('searchList-->' + searchList);
        
    //     return returnList;
    // }
}