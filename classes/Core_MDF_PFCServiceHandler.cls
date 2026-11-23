/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFCServiceHandler
* Version     : 1.0 
* Created Date: 07-11-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture -    07-11-2018       Service Class for checking duplicates and calculating the fields on Partner Fund Claims.
* Intel     -    20-01-2020       Removed duplicate for fundReservationCheckOnInsert method
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PFCServiceHandler {
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public static void claimProcessesOnBeforeInsert(List<PartnerFundClaim> newClaimList){

            // Process All the Activities Before Claim Creation
	    // Validate Account Bank mapping if its active or not
            Core_MDF_Claim_Utility.validateABM(newClaimList);
             Core_MDF_ClaimActivityHelper.processActivityOnClaims(newClaimList);            
        
            // Assign the record type to the inserted Claim and update the status initially 
            Core_MDF_Claim_Utility.assignClaimRecordType(newClaimList); 
            
            // Assign the Claim Id to the Claim Inserted based on the Activity
            Core_MDF_ClaimActivityHelper.generateClaimRefNumber(newClaimList);
            
            // Calculate the claim fields related to Amount/Currency
            Core_MDF_Claim_Utility.calculateClaimAmtFieldsOnInsert(newClaimList);
        
            //Updating Region field according to country selected
            Core_MDF_Claim_Utility.updateRegionFieldOverClaimOnInsert(newClaimList);
        
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_BudgetCapValidation') &&
               mapFunctionalityNameTriggerExecution.get('Core_MDF_BudgetCapValidation').Core_Active__c){
                //Prevent claim creation if claim amount exceeds the remaining cap 
                Core_MDF_BudgetCapHelper.checkBudgetAvailabiltyOnClaimInsert(newClaimList);                                   
            }            
            
            if(mapFunctionalityNameTriggerExecution.containsKey('checkESDHoldAndUpdateClaimStatus') &&
               mapFunctionalityNameTriggerExecution.get('checkESDHoldAndUpdateClaimStatus').Core_Active__c){                   
                   // check if the Bank on ESD Hold during insertion of Claim       
                   Core_MDF_PFC_HoldCheck.checkESDHoldAndUpdateClaimStatusOnInsert(newClaimList);
               }
            
            if(mapFunctionalityNameTriggerExecution.containsKey('duplicateClaimCheck') &&
               mapFunctionalityNameTriggerExecution.get('duplicateClaimCheck').Core_Active__c){
                   
                   // Check if the Claim is potentially duplicate and update the duplicate flag
                   Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert((newClaimList));
               }
            
            // call generic Claim update status method inorder to map the standard and custom status field on Claim
            Core_MDF_Claim_Utility.updateClaimStatus(newClaimList,NULL);
            //Call populate Owner LanguageLocal key method on Claim Create
            Core_MDF_Claim_Utility.populateOwnerLangLocalOnClaim(newClaimList,NULL);       
        
    }
    
    public static void claimProcessesOnAfterInsert(List<PartnerFundClaim> newClaimList, List<PartnerFundClaim> oldClaimList, Map<Id,PartnerFundClaim> oldClaimMap){
        
        List<PartnerFundClaim> claimsTobeAudited = new List<PartnerFundClaim>();
        for(PartnerFundClaim claim : newClaimList)
        {
            //check if adjustment and TobeAudit=true then break : Areefa             
            if( (!Core_MDF_Claim_Utility.isType(claim, Label.Core_MDF_Claim_Adjustment_Type)) && !claim.Core_MDF_To_Be_Audited_Ind__c)
            {
                system.debug('inside claim for Audit');
                claimsTobeAudited.add(claim);
            }
        }
        Map<ID,PartnerFundClaim> claimIdToClaimMap = new Map<ID,PartnerFundClaim>(newClaimList);
        if(mapFunctionalityNameTriggerExecution.containsKey('checkAndSendClaimsToAudit') &&
           mapFunctionalityNameTriggerExecution.get('checkAndSendClaimsToAudit').Core_Active__c){
               // Call the Audit Selection Helper class and send all the claims for Audit
               ID jobID = System.enqueueJob(new Core_MDF_AuditSelectionHelper(claimsTobeAudited));
              
           }      
       
        // Share the Claims with the Internal Account Managers
        Core_MDF_PFC_Sharing.shareClaimToInternalUsers(newClaimList);
        
        
        // Share the Claims with the Users having access to the Account(Node) on Claims
        Core_MDF_PFC_Sharing.shareClaimToPartnerUsers(claimIdToClaimMap);
        
        //Update escalation with claim ID
        Core_MDF_Claim_Utility.updateClaimIdOnEscalation(newClaimList);       
       
        
        // Method to make the Activity related to Claim In Progress
        // Core_MDF_ClaimActivityHelper.updateActivityStatusInProgress(newClaimList);       
        // Call the Func Reservation Functionality If Audit functionality is not Active
        Core_MDF_ProcessCCP_Claim.fundReservationCheckOnInsert(claimIdToClaimMap);      

    }
    
    public static void claimProcessesOnBeforeUpdate(List<PartnerFundClaim> newClaimList, List<PartnerFundClaim> oldClaimList, Map<Id,PartnerFundClaim> oldClaimMap,Map<Id,PartnerFundClaim> newClaimMap){
     
        // Calculate the claim fields related to Amount/Currency if Amount related fields are updated 
        Core_MDF_Claim_Utility.calculateClaimAmtFieldsOnUpdate(newClaimMap,oldClaimMap);
        
        //Updating Region field and subregion field according to country selected if country is updated
        Core_MDF_Claim_Utility.updateRegionFieldOverClaimOnUpdate(newClaimMap,oldClaimMap);
        
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_BudgetCapValidation') &&
           mapFunctionalityNameTriggerExecution.get('Core_MDF_BudgetCapValidation').Core_Active__c){
            //Prevent claim creation if claim amount exceeds the remaining cap 
            Core_MDF_BudgetCapHelper.checkBudgetAvailabiltyOnClaimUpdate(newClaimMap,oldClaimMap);                                   
        }        
        
        if(mapFunctionalityNameTriggerExecution.containsKey('checkESDHoldAndUpdateClaimStatus') &&
           mapFunctionalityNameTriggerExecution.get('checkESDHoldAndUpdateClaimStatus').Core_Active__c){
               
               // Calulate the ESD Hold Bank Check If Bank is getting upated        
               Core_MDF_PFC_HoldCheck.validateBankMappingAndApplyHold(newClaimMap,oldClaimMap);
           }
        
        if(mapFunctionalityNameTriggerExecution.containsKey('duplicateClaimCheck') &&
           mapFunctionalityNameTriggerExecution.get('duplicateClaimCheck').Core_Active__c){
               
               // Calculate the if the Claim updated is potentially duplicate 
               Core_MDF_Claim_Utility.duplicateClaimCheckOnUpdate(newClaimList,oldClaimMap);          
           } 
        
        // Call below method to prepare the Claims for Audit if any of the respective editable fields are updated
        Core_MDF_Claim_Utility.updateAuditProgressFlag(newClaimList,oldClaimMap);
        
        // call generic Claim update status method inorder to map the standard and custom status field on Claim
        Core_MDF_Claim_Utility.updateClaimStatus(newClaimList,oldClaimMap);
        
         // Call the method for updating Language of respective users if Owner gets changed
        Core_MDF_Claim_Utility.populateOwnerLangLocalOnClaim((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>) Trigger.oldMap);
        
    }
    
        public static void claimProcessesOnAfterUpdate(List<PartnerFundClaim> newClaimList, List<PartnerFundClaim> oldClaimList, Map<Id,PartnerFundClaim> oldClaimMap){
          
        if(mapFunctionalityNameTriggerExecution.containsKey('checkAndSendClaimsToAudit') &&
           mapFunctionalityNameTriggerExecution.get('checkAndSendClaimsToAudit').Core_Active__c){
               // Send the Claims not selected for Audit before, to Audit Process
               Core_MDF_Claim_Utility.sendClaimsToAudit((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>) Trigger.oldMap);
           }
           
        //call the method for Case creation/update
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ClaimToCase') &&
           mapFunctionalityNameTriggerExecution.get('Core_MDF_ClaimToCase').Core_Active__c){        
            Core_MDF_ClaimReviewCaseProcess.processClaimReviewCases((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>)Trigger.oldMap);            
        }           
        
        if(mapFunctionalityNameTriggerExecution.containsKey('fundReservation') &&
           mapFunctionalityNameTriggerExecution.get('fundReservation').Core_Active__c){
               
               // Call the method for Checking the Reserving the funds for the Claim updated
               Core_MDF_ProcessCCP_Claim.fundReservationCheckOnUpdate((Map<Id,PartnerFundClaim>) Trigger.newMap,(Map<Id,PartnerFundClaim>) Trigger.oldMap);
               
           }
        
        // Process the Claims which are Cancelled
        Core_MDF_ProcessCCP_Claim.reserveFundsforNode((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>) Trigger.oldMap);
        
        // Call the method for sharing the Claim to respective users if Owner gets changed
        Core_MDF_PFC_Sharing.recalculateShareClaimWhenOwnerChange((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>) Trigger.oldMap);

    }
    
}