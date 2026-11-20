trigger Core_Opportunity_Support on Core_Opportunity_Support__c (before insert, before update, after insert, after update, before delete) {
 
          new Core_OpportunitySupportTriggerHandler().run();
    }