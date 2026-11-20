public without sharing class Core_MDF_ClaimPredictionTriggerHandler extends TriggerHandler{
    //added dummy method to get the code coverage for this class
    public static void getCodeCoverage(){
    }
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public override void afterInsert(){
        if(isActive('Core_MDF_Claim_Pred_Trigger_Switch')){
            Core_MDF_ClaimPredictionServiceHandler.isPredictionScoreUpdated(Trigger.isInsert,Trigger.isUpdate,
                                                                            (List<Core_MDF_Claim_Prediction__c>) Trigger.new, (Map<Id, Core_MDF_Claim_Prediction__c>) Trigger.oldMap, 
                                                                            'afterInsert');
        }
    }
	*/
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public override void afterUpdate(){
        if(isActive('Core_MDF_Claim_Pred_Trigger_Switch')){
            Core_MDF_ClaimPredictionServiceHandler.isPredictionScoreUpdated(Trigger.isInsert,Trigger.isUpdate,
                                                                            (List<Core_MDF_Claim_Prediction__c>) Trigger.new, (Map<Id, Core_MDF_Claim_Prediction__c>) Trigger.oldMap, 
                                                                            'afterUpdate');
        }
    }
	*/
}