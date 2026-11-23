public with sharing class Sales_CreateOptionProdEvalutionLicCtrl {
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__ProductOption__c> getOptnProdList(String prodId) {
        system.debug('prodId>>>'+prodId);
        List<SBQQ__ProductOption__c> productOptionList = [Select Id,SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, 
                                                            SBQQ__OptionalSKU__r.Name from SBQQ__ProductOption__c 
                                                            where SBQQ__Type__c ='Related Product' AND SBQQ__ConfiguredSKU__c=:prodId];
        system.debug('productOptionList>>>'+productOptionList);
        
        return productOptionList;

    }    
}