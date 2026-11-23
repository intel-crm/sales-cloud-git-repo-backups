public with sharing class PCC_DealProductExtract {

    @AuraEnabled
    public static List<Product_Additional_Attribute__c> fetchDealProductExtract(String searchTerm) {
        List<Product_Additional_Attribute__c> prodAddAttList= new List<Product_Additional_Attribute__c>();
        String searchString = '%' + searchTerm + '%';
        prodAddAttList = [SELECT Id, Name, Product__r.Name,Programs_Eligible__c FROM Product_Additional_Attribute__c where Name LIKE :searchString];
        system.debug('prodAddAttList---'+prodAddAttList.size());
        return prodAddAttList;
    }

    @AuraEnabled
    public static Boolean fetchDealProdType(String recId) {
        //Product_Additional_Attribute__c prodAddAttRec= new Product_Additional_Attribute__c();
        boolean isFinEligible = false;
        Product_Additional_Attribute__c prodAddAttRec = [SELECT Id, Name, Product__r.Name,Programs_Eligible__c FROM Product_Additional_Attribute__c where id=:recId LIMIT 1];
        system.debug('prodAddAttRec---'+prodAddAttRec);
        if(prodAddAttRec != null && prodAddAttRec.Programs_Eligible__c=='PDI') {
            isFinEligible = true;
        }
        return isFinEligible;
    }
}