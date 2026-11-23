public class PRM_IPAMembership_TriggerHandler extends TriggerHandler {
   public override void afterInsert(){
      PRM_ProfileResponse.activateInactiveBenefit_IPAR(Trigger.new,null);
      PRM_ProfileResponse.OPIDToLoctionRollDown_IPAR(Trigger.new,null);
   }
   public override void beforeUpdate() {
      PRM_ProfileResponseOptIn.pointStatusCalc_IPAR((List<PRM_IPAMembership_Attributes__c>)Trigger.new,(Map<id, PRM_IPAMembership_Attributes__c>)Trigger.oldMap);//add oldmap
   }  
   public override void afterUpdate(){
      PRM_ProfileResponse.activateInactiveBenefit_IPAR((List<PRM_IPAMembership_Attributes__c>)Trigger.new,(Map<id, PRM_IPAMembership_Attributes__c>)Trigger.oldMap);
      PRM_ProfileResponse.OPIDToLoctionRollDown_IPAR((List<PRM_IPAMembership_Attributes__c>)Trigger.new,(Map<id, PRM_IPAMembership_Attributes__c>)Trigger.oldMap);
   }     
}