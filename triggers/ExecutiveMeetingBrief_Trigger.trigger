trigger ExecutiveMeetingBrief_Trigger on Executive_Meeting_Brief__c (after insert,after update) {
	ExecutiveMeetingBrief_TriggerHandler handlerObject = new ExecutiveMeetingBrief_TriggerHandler();
    handlerObject.run();
   
}