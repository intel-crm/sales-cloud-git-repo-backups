public with sharing class QuoteExtController {
    private Id quoteId;
    public Boolean showWarning{get;set;}
    public String warningMsg{get;set;}
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
        showWarning =false;
        warningMsg=Label.PSGCPQuoteWarningMessage;
        String quoteType=[Select core_cpq_quote_type_nm__c from SBQQ__Quote__c where Id = :quoteId][0].core_cpq_quote_type_nm__c;
        if(quoteType == 'Contract Pricing'){
            List<ContentDocumentLink> cdlList=[Select Id from ContentDocumentLink where LinkedEntityId=:quoteId];
            if(cdlList.isEmpty()){
                showWarning=true;
            }
        }        
    }
    public PageReference onSubmit() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
    public PageReference goToRecord() {
        return new PageReference('/' + quoteId);
    }
}