/*
* Class Name  : Core_MDF_ClaimStage_TriggerHandler 
* Version     : 1.0 
* Created Date: 02-04-2019
* Modification Log :
* Developer               Date                          Description  
* -----------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture – JV         03/04/2019                    Created Core_MDF_ClaimStage_TriggerHandler for handling every action from Claim Stage Trigger
-------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public class Core_MDF_ClaimStage_TriggerHandler extends TriggerHandler{
    
    // recursive flags for before and after update
    public static Boolean recursiveCheckStopBeforeUpdate = false; 
    public static Boolean recursiveCheckStopAfterUpdate = false;
    // creating global oldClaimStageMap in order to be accessible in After Update scenario 
    public static Map<Id,Core_MDF_Claim_Batch_Stage__c> oldClaimStageMap;  

    public override void beforeInsert() {
        
        if (isActive('Core_MDF_claimStageProcessOnBeforeInsert')) {
            //calling below method to check mandatory and accessibility validations on insertion of Claim Stage Record List
            Core_MDF_ClaimStage_ServiceHandler.isValidOnInsert((List<Core_MDF_Claim_Batch_Stage__c>) Trigger.New);
        }
    }
    public override void afterInsert(){
        
        if (isActive('Core_MDF_claimStageProcessOnAfterInsert')) {
             Core_MDF_ClaimStage_ServiceHandler.statusUpdateClaimBatchOnAfterInsert((List<Core_MDF_Claim_Batch_Stage__c>) Trigger.New);
        }
    }
   
    public override void beforeUpdate() { 
       
       if(isActive('Core_MDF_claimStageProcessOnBeforeUpdate') && !recursiveCheckStopBeforeUpdate){
            // Make the recursive flag as true
            recursiveCheckStopBeforeUpdate = true;
            // Store the OldClaimStage Map to the Global Variable 
            oldClaimStageMap = (Map<Id,Core_MDF_Claim_Batch_Stage__c>)trigger.oldMap;
            //System.debug('oldClaimStageMap in before Update::::'+oldClaimStageMap);
            // check mandatory and accessibility validations for all the edited records from Claim Stage Record List
            Core_MDF_ClaimStage_ServiceHandler.isValidOnUpdate((List<Core_MDF_Claim_Batch_Stage__c>) Trigger.new,(Map<Id,Core_MDF_Claim_Batch_Stage__c>)trigger.oldMap,(Map<Id,Core_MDF_Claim_Batch_Stage__c>)trigger.newMap);
        }
    }
    
    public override void afterUpdate(){
        
        if(isActive('Core_MDF_claimStageProcessOnAfterUpdate')){
            // Get all the ClaimStageRecords which were edited
            //System.debug('oldClaimStageMap in after Update::::'+oldClaimStageMap);
            List<Core_MDF_Claim_Batch_Stage__c> updatedClaimStageRecordList = Core_MDF_ClaimStage_ServiceHandler.getUpdatedStageRecordList((List<Core_MDF_Claim_Batch_Stage__c>) Trigger.New,oldClaimStageMap);
            
            if(updatedClaimStageRecordList != NULL && updatedClaimStageRecordList.size() > 0 && !recursiveCheckStopAfterUpdate){
                // Make the recursive flag as True
                recursiveCheckStopAfterUpdate = true;
               // system.debug('in after update');
                // Get the Claim Object List From the ClaimStage List as Input
                List<PartnerFundClaim> getBulkOfClaims = Core_MDF_BatchClaimHelper.mapStageRecordsToClaim(updatedClaimStageRecordList);
                // call the function to check whether the ClaimList contains duplicates   
                Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper wrapInstance = new Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper();
                wrapInstance = Core_MDF_ClaimStage_ServiceHandler.handleDuplicateClaimsOnUpdate(getBulkOfClaims,wrapInstance);
                Core_MDF_BatchClaimHelper.insertClaimsAndUpdateClaimStageRecords(wrapInstance);
            }    
        }
        
        if(isActive('Core_MDF_ClaimBatchStageStatusChange')){
            Core_MDF_ClaimStage_ServiceHandler.statusUpdateClaimBatch((List<Core_MDF_Claim_Batch_Stage__c>) Trigger.new,(Map<Id,Core_MDF_Claim_Batch_Stage__c>)trigger.oldMap);
        }  
    }
    

    public override void beforeDelete(){
        if(isActive('Core_MDF_claimStageProcessOnBeforeDelete')){
            // function to prevent the deletion of "Successful" claim stage records
            Core_MDF_BatchClaimHelper.preventDeleteWhenClaimInSuccessStatus(Trigger.old);
        }
    }
    public override void afterDelete(){
        if(isActive('Core_MDF_claimStageProcessOnaAfterDelete')){
        Core_MDF_ClaimStage_ServiceHandler.statusUpdateClaimBatchStageDeletion(Trigger.old);
        }
    }
    
}