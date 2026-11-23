trigger ContactMoveGovernanceTrigger on Contact_Move_Governance__c (after update, before update, after insert, before insert) {

    if(Trigger.isAfter &&  Trigger.isUpdate){
        UCD_ACM_ContactMoveHandler.contactUpdateTrigger(Trigger.operationType,Trigger.new,Trigger.oldMap);
    }

    if(Trigger.isBefore &&  Trigger.isUpdate){
        UCD_ACM_ContactMoveHandler.contactMoveGovernanceUpdateTrigger(Trigger.operationType,Trigger.new,Trigger.oldMap);
        UCD_ACM_ContactMoveHandler.contactMoveGovernanceBeforeInsertTrigger(Trigger.operationType,Trigger.new);

    }
    if(Trigger.isAfter &&  Trigger.isInsert){
        UCD_ACM_ContactMoveHandler.contactMoveGovernanceAfterInsertTrigger(Trigger.operationType,Trigger.new);
    }
    if(Trigger.isBefore &&  Trigger.isInsert){
        UCD_ACM_ContactMoveHandler.contactMoveGovernanceBeforeInsertTrigger(Trigger.operationType,Trigger.new);
    }




}