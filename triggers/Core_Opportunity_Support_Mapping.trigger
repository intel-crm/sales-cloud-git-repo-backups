trigger Core_Opportunity_Support_Mapping on Core_Opportunity_Support_Mapping__c (before insert,before Update,after Update) {
          new Core_OpptySupportMappingTriggerHandler().run();

}