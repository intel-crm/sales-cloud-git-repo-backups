public class PCC_OpportunityLine_Controller {
    @AuraEnabled(cacheable=true)
    public static Id getQuoteLineIdFromOpportunityLineId(Id recordId) {
        OpportunityLineItem oli = [SELECT SBQQ__QuoteLine__c FROM OpportunityLineItem WHERE Id = :recordId];
        return oli.SBQQ__QuoteLine__c;
    }
}