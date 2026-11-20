/****************************************************************************************************************************************
* Class Name  : Core_MDF_Escalation_TriggerHandler 
* Created Date: 15-05-2019
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - NP           15-05-2019           Extending Trigger framework for Apex Sharing of Escalation records
*****************************************************************************************************************************************/
public class Core_MDF_Escalation_TriggerHandler extends TriggerHandler{

    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
    boolean initializeEsclations= isActive('Core_MDF_Set_Channel_Program');
    boolean shareEscalationFlag = isActive('Core_MDF_Share_Escalations');
    boolean esclationApprovalAction = isActive('Core_MDF_Escalation_Approval_Action'); 
    boolean validateEscAmtWithCampAmt = isActive('Core_MDF_Bypass_CampAmtValidation');
    boolean validateEscAgainstRecoveries = isActive('Core_MDF_ValidateEscAgainstRecoveries');
    boolean shareEscalationWithAccNode = isActive('Core_MDF_Share_Escalations_With_AccNode');
    boolean validateEscAgainstClaims = isActive('Core_MDF_ValidateEscAgainstClaim');
    boolean updatePFRAmtWithEscAmount = isActive('Core_MDF_UpdatePFRAmtWithEscAmt');

    public override void beforeInsert(){        
        if(initializeEsclations){
            Core_MDF_Escalation_ServiceHandler.initializeEscalationFields((List<Core_MDF_Escalation__c>) Trigger.new,null,Trigger.isInsert); 
        }
        // Check Campaign Amount
        if(validateEscAmtWithCampAmt){
            Core_MDF_Escalation_ServiceHandler.validateCampAmt((List<Core_MDF_Escalation__c>) Trigger.new, (Map<Id, Core_MDF_Escalation__c>) Trigger.oldMap);
        }
        if(validateEscAgainstRecoveries){
           Core_MDF_Escalation_ServiceHandler.validateEscalationAgainstRecoveries((List<Core_MDF_Escalation__c>) Trigger.new, Trigger.isInsert);
        }
        //Check if PFR is Manually Closed and Actual date before PFR getting manually closed is in future then throw error and ask user to reopen
        //and create a claim
        if(Core_MDF_Utility.byPassFeature('Core_MDF_Validate_EscClaimingWindow')){
            Core_MDF_Escalation_ServiceHandler.validateClaimingWindow((List<Core_MDF_Escalation__c>) Trigger.new);
        }
    }
    
    public override void beforeUpdate(){      
        if(initializeEsclations){
            Core_MDF_Escalation_ServiceHandler.initializeEscalationFields((List<Core_MDF_Escalation__c>) Trigger.new,(Map<Id,Core_MDF_Escalation__c>) Trigger.oldMap,Trigger.isInsert);
        }
        // Check Campaign Amount
        if(validateEscAmtWithCampAmt){
            Core_MDF_Escalation_ServiceHandler.validateCampAmt((List<Core_MDF_Escalation__c>) Trigger.new, (Map<Id, Core_MDF_Escalation__c>) Trigger.oldMap);
        }
        if(validateEscAgainstRecoveries){
            Core_MDF_Escalation_ServiceHandler.validateEscalationAgainstRecoveries((List<Core_MDF_Escalation__c>) Trigger.new, false);
        }
        if(validateEscAgainstClaims){
            Core_MDF_Escalation_ServiceHandler.validationAgainstClaim((List<Core_MDF_Escalation__c>) Trigger.new, (Map<Id, Core_MDF_Escalation__c>) Trigger.oldMap);
        }
    }


    public override void afterInsert(){
        if(shareEscalationFlag ){
            Core_MDF_Escalation_ServiceHandler.shareEscalation((Map<Id,Core_MDF_Escalation__c>) Trigger.newMap,null,Trigger.isInsert);
        } 
        if(shareEscalationWithAccNode){
            Core_MDF_Escalation_ServiceHandler.shareEscalationWithAccNodeGroup((List<Core_MDF_Escalation__c>) Trigger.new, null, Trigger.isInsert);
        }
         
    }
    
    public override void afterUpdate(){ 
        if(shareEscalationFlag ){
       Core_MDF_Escalation_ServiceHandler.shareEscalation((Map<Id,Core_MDF_Escalation__c>) Trigger.newMap,(Map<Id,Core_MDF_Escalation__c>) Trigger.oldMap,Trigger.isInsert);
        }
        
        /*if(esclationApprovalAction){
            Core_MDF_Escalation_ServiceHandler.approvalAction((List<Core_MDF_Escalation__c>) Trigger.new,(Map<Id,Core_MDF_Escalation__c>) Trigger.oldMap);
        }*/
        if(shareEscalationWithAccNode){
            Core_MDF_Escalation_ServiceHandler.shareEscalationWithAccNodeGroup((List<Core_MDF_Escalation__c>) Trigger.new, (Map<Id,Core_MDF_Escalation__c>) Trigger.oldMap, Trigger.isInsert);
        }
        if(updatePFRAmtWithEscAmount){
            Core_MDF_Escalation_ServiceHandler.releaseEscalationAmount((List<Core_MDF_Escalation__c>) Trigger.new, (Map<Id, Core_MDF_Escalation__c>) Trigger.oldMap);
        }

        Core_MDF_Escalation_ServiceHandler.distributeEscalationAmountToOutcomeSubActivities((List<Core_MDF_Escalation__c>) Trigger.new, (Map<Id, Core_MDF_Escalation__c>) Trigger.oldMap);
    }
}