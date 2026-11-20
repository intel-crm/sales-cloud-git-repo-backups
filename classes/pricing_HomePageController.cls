public with sharing class pricing_HomePageController {
    
    @AuraEnabled(cacheable=true)
    public static List<ListView> getListViewValues(string objectApiName ){

        List<ListView> listListViews = new List<ListView>();  
        listListViews = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsSoqlCompatible, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, LastViewedDate, LastReferencedDate FROM ListView WHERE SobjectType =:objectApiName];
        return listListViews; 
    }
}