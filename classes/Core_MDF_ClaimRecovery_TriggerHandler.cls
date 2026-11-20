public class Core_MDF_ClaimRecovery_TriggerHandler extends TriggerHandler{
    public override void beforeInsert() {
        //Moved this trigger logic to Core_MDF_Batch_UpdateRecoveryClaims batch class
        /*if (!Core_MDF_Utility.byPassFeature('bypass_validateClmAmtOnClmRecoveryIns')) {
            Core_MDF_ClaimRecovery_ServiceHandler.validateClmAmtOrStatusOnClmRecoveryIns((List<Core_MDF_Recovery__c>) Trigger.NEW);
        }*/
    }
    public override void afterInsert() {
        //Moved this trigger logic to Core_MDF_Batch_UpdateRecoveryClaims batch class
        /*if (!Core_MDF_Utility.byPassFeature('bypass_updateClmAmtOnClaimRecoveryIns')) {
            Core_MDF_ClaimRecovery_ServiceHandler.updateClmAmtOnClaimRecoveryIns((List<Core_MDF_Recovery__c>) Trigger.NEW);
        }*/
        
    }
}