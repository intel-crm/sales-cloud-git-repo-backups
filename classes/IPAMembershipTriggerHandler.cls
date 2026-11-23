public class IPAMembershipTriggerHandler extends TriggerHandler {
 
    public override void beforeInsert(){ 
        IPAMembershipUtility.checkIfMultipleACMExists(Trigger.new);
        IPAMembershipUtility.checkIfAlreadyExists(Trigger.new);
        //IPAMembershipUtility.checkIfOnDemandSyncIsInProcess(Trigger.new); //Commenting out checkIfOnDemandSyncIsInProcess as a part of IPA Refresh 2.0 - TWC729-8250
    }
    /*public override void beforeUpdate() {
        IPAMembershipUtility.setApprovalLink((List<PRM_IPA_Membership__c>)Trigger.new, (Map<Id, PRM_IPA_Membership__c>)Trigger.oldMap); 
    }*/
    
    /*public override void afterInsert(){
        IPAMembershipUtility.suppressEmail(Trigger.new);
    }*/
}