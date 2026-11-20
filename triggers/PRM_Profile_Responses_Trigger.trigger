trigger PRM_Profile_Responses_Trigger on PRM_Profile_Responses__c (before update, before insert, after update, after insert) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_ProfileResponses_TriggerHandler().run();
    }
}