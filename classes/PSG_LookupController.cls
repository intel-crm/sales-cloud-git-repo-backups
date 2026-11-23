/****************************************************************************************************
Apex Class Name : PSG_LookupController
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This is a generic class used to get lookup records.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                    08/13/2021                Created
*****************************************************************************************************/
@isTest
public with sharing class PSG_LookupController {
    /************************************************************************************************************
    *Method Name : lookUp
    *Created Date: 08/13/2021
    *Author: Vijay
    *Description : method returns the matching sObject records with the requested parameters.
    ************************************************************************************************************/
    /*@AuraEnabled(cacheable=true)
    public static List<sObject> lookUp(String searchTerm, String objectName, String filters, String recordId, String fields) {
        /*searchTerm=searchTerm==null?searchTerm:String.escapeSingleQuotes(searchTerm);
        objectName=objectName==null?objectName:String.escapeSingleQuotes(objectName);
        filters=filters==null?filters:String.escapeSingleQuotes(filters);
        recordId=recordId==null?recordId:String.escapeSingleQuotes(recordId);
        fields=fields==null?fields:String.escapeSingleQuotes(fields);*/
        /*Integer limitNum = 20;
        String finalQuery = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ' + String.escapeSingleQuotes(objectName);
        if(String.isBlank(recordId)){
            if(String.isNotBlank(searchTerm)){
                finalQuery += ' WHERE Name Like  \'%' + String.escapeSingleQuotes(searchTerm) + '%\' ';
            }
        }else{
            finalQuery += ' WHERE Id =  \'' + String.escapeSingleQuotes(recordId) + '\'';
        }
        finalQuery+= ' LIMIT ' + limitNum;
        List<sObject> lookUpList = database.query(finalQuery);
        return lookUpList;  
    }*/
}