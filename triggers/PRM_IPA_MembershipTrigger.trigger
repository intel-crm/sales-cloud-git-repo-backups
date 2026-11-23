trigger PRM_IPA_MembershipTrigger on PRM_IPA_Membership__c (before insert, before update, after insert, after update) {
    new IPAMembershipTriggerHandler().run();
}