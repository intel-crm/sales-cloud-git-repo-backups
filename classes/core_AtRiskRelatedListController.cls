public class core_AtRiskRelatedListController {
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getAtRiskProducts(Id OppId){
        return[select Id,Name from OpportunityLineItem where OpportunityId= :oppId AND Core_At_Risk__c=true];
    }
}