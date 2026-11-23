/******************************************************************************************************************************
Apex Class Name:  PRM_AccountContactRel_Trigger
Version     : 1.0 
Created Date: 21 NOV 2018
Function    : Trigger for the object PRM_Account_Contact_Relationship__c
*******************************************************************************************************************************/
trigger PRM_AccountContactRel_Trigger on PRM_Account_Contact_Relationship__c (after insert, before insert, before Update, before Delete,after update) {
    new PRM_AcctContRel_TriggerHandler().run();
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        //ContactERPMIntegrationStatusHandler.parseInputList(Trigger.new);
    }    
}