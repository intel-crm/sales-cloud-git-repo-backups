trigger PRM_IPAMembershipAttr_Trigger on PRM_IPAMembership_Attributes__c (before update, before insert, after update, after insert) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_IPAMembership_TriggerHandler().run();
    }
}