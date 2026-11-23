trigger PRM_Email_Handler_Trigger on PRM_Email_Handler__c (before insert) {
    
    new PRM_Email_Handler_TriggerHandler().run();
     
}