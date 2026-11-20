trigger PRM_ALA_Trigger on PRM_AccountLegalAgreemntAssociation__c (after insert,after update,before insert, before update,after delete) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
    new PRM_ALA_TriggerHandler().run();
}
}