trigger Pricing_IntegrationStagingTrigger on Pricing_Integration_Staging__c (before insert, after insert, before update, after update) {
	new Pricing_IntegrationStagingTriggerHandler().run();
}