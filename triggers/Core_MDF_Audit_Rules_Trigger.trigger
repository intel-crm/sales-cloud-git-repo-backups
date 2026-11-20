/*Trigger on Audit Rules Engine*/
trigger Core_MDF_Audit_Rules_Trigger on Core_MDF_Audit_Rules_Engine__c (before insert, before update, after insert, after update) {
	new Core_MDF_Audit_Rules_TriggerHandler().run();
}