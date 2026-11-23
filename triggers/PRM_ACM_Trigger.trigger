trigger PRM_ACM_Trigger on PRM_AccountChannelMembership__c (before update, before insert, after update, after insert) {
    system.debug('ACM trigger entry');
    new PRM_ACM_TriggerHandler().run();
}