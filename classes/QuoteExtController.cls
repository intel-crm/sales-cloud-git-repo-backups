public with sharing class QuoteExtController {
    private Id quoteId;
    public Boolean showWarning{get;set;}
    public Boolean showWarningMsg{get;set;}
    public String warningMsg{get;set;}
    public String pridMsg{get;set;}
    public Boolean pridDeactivation =true;
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
        for(SBQQ__QuoteLine__c qlList : [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteId and core_cpq_prid_alert__c LIKE '%De-activation%']){
            pridDeactivation = false;
             break;
        }
        if(!pridDeactivation){
            showWarningMsg = true;
            pridMsg = 'PRID De-activation will be triggered. Are you sure to proceed further ?';
        } 
    }
    public PageReference onSubmit() {
        /*SBQQ__Quote__c quote = [SELECT Id, Pricing_SW_Expiry_Date__c, SBQQ__Status__c, SBQQ__Opportunity2__r.Core_Approval_Status__c
                            FROM SBQQ__Quote__c
                            WHERE Id = :quoteId LIMIT 1];
        if (quote.Pricing_SW_Expiry_Date__c != null && quote.Pricing_SW_Expiry_Date__c <= Date.today().addDays(14)) {
        // Show a validation error for Expiry Date
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
            'Expiry Date must be more than 14 days in the future before the quote can be submitted.'));
        return null; // Stay on the page and prevent submission
    }
        if ((quote.SBQQ__Opportunity2__r.Core_Approval_Status__c == 'Submitted' || 
         quote.SBQQ__Opportunity2__r.Core_Approval_Status__c == 'Approved') &&
        (quote.SBQQ__Status__c == 'Draft')) {

        // Show a validation error for Opportunity's Approval Status
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
            'Quote cannot be submitted if Opportunity\'s Core Approval Status is Submitted or Approved and the status is changed.'));
        return null; // Stay on the page and prevent submission
    }*/
        
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