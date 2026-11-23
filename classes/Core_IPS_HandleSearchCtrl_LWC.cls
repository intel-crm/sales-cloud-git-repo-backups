public with sharing class Core_IPS_HandleSearchCtrl_LWC {
    @AuraEnabled(cacheable=true)
    public static List<List<sObject>> getSearchResult(String searchKey){
        string searchKeyword = '%' + searchKey + '%';
        List<List<sObject>> searchResult = [FIND :searchKeyword
        IN ALL FIELDS RETURNING
        Case(Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c, Subject, Core_IPS_Product_name__c, Core_IPS_Project_Case__r.Name, Core_Contact_Name__c, CreatedDate, LastModifiedDate, Core_IPS_Legacy_IPS_ID__c, Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c, ClosedDate, Core_Customer_Reference_ID__c),
        Asset(Id,Name, core_Product_Application__c, Core_IPS_Support_License__c, Core_IPS_Project_Id__c, Core_IPS_Project__r.Name, Account.Name),
        Core_IPS_Project__c(Id,Name, CreatedDate , Core_Project_Description__c, Core_Status__c ) LIMIT 5];
        System.debug(searchResult);
        return searchResult;
    }
    
}