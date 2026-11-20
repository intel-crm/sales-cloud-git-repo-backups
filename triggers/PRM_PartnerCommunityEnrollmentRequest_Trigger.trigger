trigger PRM_PartnerCommunityEnrollmentRequest_Trigger on PRM_Partner_Community_Enrollment_Request__c(after insert, after update, before insert, before update) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(PRM_partnerComEnrReqUtility.isTriggerExecuted==true || !FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_PartnerComEnrReq_TriggerHandler().run();   
    }
}