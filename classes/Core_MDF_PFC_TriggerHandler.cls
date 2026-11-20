/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_TriggerHandler 
* Version     : 1.0 
* Created Date: 11-03-2018
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV       11/03/2018          Created for extending Trigger framework to process Partner Fund Claim business logic methods.
* Intel -Areefa		   20 May,2021		   To insert claim on Claim Prediction object
*****************************************************************************************************************************************/
public class Core_MDF_PFC_TriggerHandler extends TriggerHandler{
    
    /**
    * @description : Method to execute the actions in before insert context of Core_MDF_PFC_Trigger
    */
    public override void beforeInsert() {
        
        if (isActive('Core_MDF_claimProcessesOnBeforeInsert')) {
            /**
            * @description        : Method for inserting claim to Claim Prediction object for training the claim Prediction Engine  
            * @param Trigger.NEW : List of the current Partner Fund Claims to be Inserted 
            */
            Core_MDF_PFCServiceHandler.claimProcessesOnBeforeInsert((List<PartnerFundClaim>) Trigger.NEW);
        }
    }
    
    /**
    * @description : Method to execute the actions in after insert context of Core_MDF_PFC_Trigger
    */
    public override void afterInsert(){
        
        if (isActive('Core_MDF_ClaimForEinPredOnAfterInsert')) {
            /**
            * @description          : Method for processing the CoMarketing Claims after their Insertion
            * @param Trigger.newMap : Map of the new Partner Fund Claims 
            */
            //Core_MDF_ClaimInsertForEinPred.claimProcessesForEinPredAfterInsert((Map<Id,PartnerFundClaim>) Trigger.newMap);
            Core_MDF_ProcessCCP_Claim.SendClaimsToClaimPrediction((Map<Id,PartnerFundClaim>) Trigger.oldMap, (Map<Id,PartnerFundClaim>) Trigger.newMap);
        }
        if (isActive('Core_MDF_claimProcessesOnAfterInsert')) {
            /**
            * @description          : Method for processing the CoMarketing Claims after their Insertion
            * @param Trigger.NEW    : List of the current Partner Fund Claims to be Inserted
            * @param Trigger.OLD    : List of the old Partner Fund Claims 
            * @param Trigger.oldMap : Map of the old Partner Fund Claims 
            */
            Core_MDF_PFCServiceHandler.claimProcessesOnAfterInsert((List<PartnerFundClaim>) Trigger.NEW,
                                                                (List<PartnerFundClaim>) Trigger.OLD,
                                                                (Map<Id,PartnerFundClaim>) Trigger.oldMap);         
        }     
        

    }
    
    /**
    * @description : Method to execute the actions in before update context of Core_MDF_PFC_Trigger
    */
    public override void beforeUpdate() {
       
                if (isActive('Core_MDF_claimProcessesOnBeforeUpdate')) {
            /**
            * @description          : Method for processing the CoMarketing Claims before their Updation
            * @param Trigger.NEW    : List of the current Partner Fund Claims to be Updated
            * @param Trigger.OLD    : List of the old Partner Fund Claims before Updation
            * @param Trigger.oldMap : Map of the old Partner Fund Claims before Updation
            */
            Core_MDF_PFCServiceHandler.claimProcessesOnBeforeUpdate((List<PartnerFundClaim>) Trigger.NEW,
                                                                (List<PartnerFundClaim>) Trigger.OLD,
                                                                (Map<Id,PartnerFundClaim>) Trigger.oldMap,
                                                                (Map<Id,PartnerFundClaim>) Trigger.newMap);
        }
    }
    
    /**
    * @description : Method to execute the actions in after update context of Core_MDF_PFC_Trigger
    */
    public override void afterUpdate(){
       
        if (isActive('Core_MDF_ClaimForEinPredOnAfterInsert')) {
            /**
            * @description          : Method for processing the CoMarketing Claims after their Insertion
            * @param Trigger.newMap : Map of the new Partner Fund Claims 
            */
            Core_MDF_ProcessCCP_Claim.SendClaimsToClaimPrediction((Map<Id,PartnerFundClaim>) Trigger.oldMap, (Map<Id,PartnerFundClaim>) Trigger.newMap);
        }
        if (isActive('Core_MDF_claimProcessesOnAfterUpdate')) {
            /**
            * @description          : Method for processing the CoMarketing Claims after their Updation
            * @param Trigger.NEW    : List of the current Partner Fund Claims to be Updated
            * @param Trigger.OLD    : List of the old Partner Fund Claims after Updation
            * @param Trigger.oldMap : Map of the old Partner Fund Claims after Updation
            */
            Core_MDF_PFCServiceHandler.claimProcessesOnAfterUpdate((List<PartnerFundClaim>) Trigger.NEW,
                                                                (List<PartnerFundClaim>) Trigger.OLD,
                                                                (Map<Id,PartnerFundClaim>) Trigger.oldMap);
            
        }
        
    }
    /*     
    public override void beforeDelete(){
    }
        public override void afterDelete(){        
    }
        public override void afterUndelete(){        
    } */
}