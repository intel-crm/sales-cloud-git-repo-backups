public without sharing class Core_SharingClass {
    public static List<Core_IPS_Product_Issue_Category__c> getCategories(String productId){
        system.debug('productId'+productId);
        List<Core_IPS_Product_Issue_Category__c> coreIPSProductIssueCategory=new List<Core_IPS_Product_Issue_Category__c>();
        coreIPSProductIssueCategory = [SELECT id, Name,Core_Issue_Category_Name__c, Core_Issue_Category_Name__r.name FROM Core_IPS_Product_Issue_Category__c where Core_supported_product__c =: productId and core_status__c!='Inactive'];
                system.debug('coreIPSProductIssueCategory'+coreIPSProductIssueCategory);
            
        return coreIPSProductIssueCategory;
    }
     public static List<SObject> queryRecords(String query,Map<String, Object>  parameter){
        return Database.queryWithBinds(query,
                            parameter, 
                            AccessLevel.SYSTEM_MODE);
    }
    public static List<SObject> queryRecords(String query) {
        return Database.query(query,AccessLevel.SYSTEM_MODE);
    }
    public static Map<Id, SObject> queryRecordsAsMap(String query, Map<String, Object> parameter) {
        return new Map<Id, SObject>(
            Database.queryWithBinds(query, parameter, AccessLevel.SYSTEM_MODE)
        );
    }
     // Wrapper for dynamic SOQL
    public static List<SObject> executeDynamicQuery(String queryString) {
        return Database.query(queryString, AccessLevel.SYSTEM_MODE);
    }

    // Wrapper for SOSL (No SYSTEM_MODE API exists)
    public static List<List<SObject>> executeSOSL(String queryString) {
        return Search.query(queryString);
    }
    
}