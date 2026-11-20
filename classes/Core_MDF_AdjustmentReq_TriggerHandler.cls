/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_AdjustmentReq_TriggerHandler 
* Version           : 1.0 
* Created Date      : 31/May/2019
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel  - Areefa       31/May/2019        Trigger Handler class.
*****************************************************************************************************************************************/
public class Core_MDF_AdjustmentReq_TriggerHandler extends TriggerHandler {

    public override void beforeInsert() 
    {   
        if(!Core_MDF_Utility.byPassFeature('Bypass_Claim_AdjReq_Amount_Validation'))
            if (isActive('Core_MDF_AdjReqAmountOnBeforeInsert')){
                    Core_MDF_AdjustmentReq_ServiceHandler.claimAdjustmentAmountValidation(Trigger.NEW);
            }            
        if (isActive('Core_MDF_CreateAdjustments')) {
           Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(Trigger.NEW);
        }
    }
    
    public override void afterInsert()  {
        if (isActive('Core_MDF_CreateAdjustments') && isActive('Core_MDF_ShareAdjustmentRequests')) {
            if(!Core_MDF_Utility.byPassFeature('Bypass_ClaimAdjReq_Share_Internal_Usrs'))
            	Core_MDF_AdjustmentRequest_Sharing.shareAdjustmentRequestToInternalUsers((List<Core_MDF_Adjustment_Request__c>) Trigger.New);
            if(!Core_MDF_Utility.byPassFeature('Bypass_ClaimAdjReq_Share_External_Usrs'))
            	Core_MDF_AdjustmentRequest_Sharing.shareAdjustmentRequestToPartnerUsers((Map<Id,Core_MDF_Adjustment_Request__c>) Trigger.newMap);

        }
    }
    
    public override void beforeUpdate() {
        if (isActive('Core_MDF_CancelAdjustments')){
            Core_MDF_AdjustmentReq_ServiceHandler.cancelAdjustmentRequest((Map<Id,Core_MDF_Adjustment_Request__c>) Trigger.oldMap,(Map<Id,Core_MDF_Adjustment_Request__c>) Trigger.newMap);
        }
    }
    
    public override void afterUpdate()  {
        if (isActive('Core_MDF_CancelAdjustments')){
            Core_MDF_AdjustmentReq_ServiceHandler.cancelClaimOnAdjCancel((Map<Id,Core_MDF_Adjustment_Request__c>) Trigger.oldMap,(Map<Id,Core_MDF_Adjustment_Request__c>) Trigger.newMap);
        }
        if(!Core_MDF_Utility.byPassFeature('Bypass_ClaimAdjReq_Share_On_Owner_Chng'))
            if (isActive('Core_MDF_CreateAdjustments') && isActive('Core_MDF_ShareAdjustmentRequests')) {
                   Core_MDF_AdjustmentRequest_Sharing.recalculateShareAdjustmentRequestWhenOwnerChange(
                        (List<Core_MDF_Adjustment_Request__c>) Trigger.New,
                        (Map<Id,Core_MDF_Adjustment_Request__c>) Trigger.oldMap
                    );
            }
    }
}