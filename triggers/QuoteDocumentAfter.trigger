trigger QuoteDocumentAfter on SBQQ__QuoteDocument__c (after insert) {
	new Pricing_QuoteDocumentTriggerHandler().run();
}