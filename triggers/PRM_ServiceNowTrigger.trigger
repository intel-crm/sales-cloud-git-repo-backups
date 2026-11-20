trigger PRM_ServiceNowTrigger on ServiceNow_Case__c (after insert) {
   new PRM_ServiceNowCase_TriggerHandler().run(); 

}