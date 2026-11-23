public class Core_MDF_Claim_OffsetTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() 
    {        
        
    }
    
    public override void afterInsert()  {
        Core_MDF_Claim_Offset_Sharing.shareClaimOffsetToInternalAccountManagers((List<Core_MDF_Claim_Offset__c>) Trigger.New);
        Core_MDF_Claim_Offset_Sharing.shareClaimOffsetToPartnerUsers((Map<Id,Core_MDF_Claim_Offset__c>) Trigger.newMap);
    }
    
    public override void beforeUpdate() {}
    
    public override void afterUpdate()  {
        Core_MDF_Claim_Offset_Sharing.recalculateShareClaimOffsetWhenOwnerChange(
            (List<Core_MDF_Claim_Offset__c>) Trigger.New,
            (Map<Id,Core_MDF_Claim_Offset__c>) Trigger.oldMap
        );
    }
}