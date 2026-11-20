public class PRM_PartnerComEnrReq_TriggerHandler extends TriggerHandler {
    
    public static Boolean executeTrigger = true;
    
    Trigger_Execution__mdt executionEntries = Trigger_Execution__mdt.getInstance('Update_Partner_Com_Enr_Req_Status');
    
     public override void beforeInsert() {
        if(executeTrigger && executionEntries.Active__c && PRM_partnerComEnrReqUtility.isCommunityInserted == false){
            PRM_partnerComEnrReqUtility.isCommunityInserted = true;
            PRM_partnerComEnrReqUtility.autoApproveCommunityRequest((List<PRM_Partner_Community_Enrollment_Request__c>)Trigger.new);        
            PRM_partnerComEnrReqUtility.updateStartandEndDates((List<PRM_Partner_Community_Enrollment_Request__c>)Trigger.new);
        }
        
    }
     public override void afterUpdate() {
        if(executeTrigger && executionEntries.Active__c && PRM_partnerComEnrReqUtility.isCommunityUpdated == false){
            PRM_partnerComEnrReqUtility.isCommunityUpdated = true;
            PRM_partnerComEnrReqUtility.updatePartnerCommunityEnrollementRequestStatus((List<PRM_Partner_Community_Enrollment_Request__c>)Trigger.new);        
        }
        
    }
    // Added as part of US - TWC729-2267
     public override void beforeUpdate() {
        if(executeTrigger && executionEntries.Active__c && PRM_partnerComEnrReqUtility.isCommunityBeforeUpdated == false){
            PRM_partnerComEnrReqUtility.isCommunityBeforeUpdated = true;
            PRM_partnerComEnrReqUtility.updateStartandEndDates((List<PRM_Partner_Community_Enrollment_Request__c>)Trigger.new);        
        }
        
    }
}