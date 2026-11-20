trigger PRM_IPA_MembershipTrigger on PRM_IPA_Membership__c (before insert, before update, after insert, after update) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new IPAMembershipTriggerHandler().run();
    }
}