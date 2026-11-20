trigger Core_Opportunity_Support_Team on Core_Opportunity_Support_Team__c (before insert, before update, after insert, after update, before delete,after delete) {
	new Core_OppSupportTeamTriggerHandler().run();
}