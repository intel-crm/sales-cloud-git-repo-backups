trigger PRM_IPAMembershipAttr_Trigger on PRM_IPAMembership_Attributes__c (before update, before insert, after update, after insert) {
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_IPAMembership_TriggerHandler().run();
    }
}