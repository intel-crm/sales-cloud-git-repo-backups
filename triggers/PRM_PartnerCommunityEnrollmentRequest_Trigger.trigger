trigger PRM_PartnerCommunityEnrollmentRequest_Trigger on PRM_Partner_Community_Enrollment_Request__c(after insert, after update, before insert, before update) {
    if(PRM_partnerComEnrReqUtility.isTriggerExecuted==true){
        new PRM_PartnerComEnrReq_TriggerHandler().run();   
    }
}