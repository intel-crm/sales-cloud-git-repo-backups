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
public without sharing class Core_MDF_PFCServiceHandler{
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public static void claimProcessesOnBeforeInsert(List<PartnerFundClaim> newClaimList){

            Core_MDF_ClaimActivityHelper.populateTimeSpendOnClaim(newClaimList);   
            Core_MDF_ClaimActivityHelper.processActivityOnClaims(newClaimList);   
            
            // Assign the record type to the inserted Claim and update the status initially 
            Core_MDF_Claim_Utility.assignClaimRecordType(newClaimList);
            
            // Assign the Claim Id to the Claim Inserted based on the Activity
            Core_MDF_ClaimActivityHelper.generateClaimRefNumber(newClaimList);
        
            if(!Core_MDF_Utility.byPassFeature('Bypass_Claims_ABM_Validation'))
                Core_MDF_Claim_Utility.validateABM(newClaimList);
            
            // Calculate the claim fields related to Amount/Currency
            Core_MDF_Claim_Utility.calculateClaimAmtFieldsOnInsert(newClaimList);
            
            //Updating Region field according to country selected
            Core_MDF_Claim_Utility.updateRegionFieldOverClaimOnInsert(newClaimList);
        
            //Updating the Claim owner field with the Claim submitter field of Claim or Escalation
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_UpdateOwner_To_ClaimSubmitter') &&
               mapFunctionalityNameTriggerExecution.get('Core_MDF_UpdateOwner_To_ClaimSubmitter').Core_Active__c){
                Core_MDF_ClaimActivityHelper.updateClaimOwner(newClaimList);
            }
            
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_BudgetCapValidation') &&
               mapFunctionalityNameTriggerExecution.get('Core_MDF_BudgetCapValidation').Core_Active__c){
                //Prevent claim creation if claim amount exceeds the remaining cap 
                Core_MDF_BudgetCapHelper.checkBudgetAvailabiltyOnClaimInsert(newClaimList);                                   
            }
            
            //Prevent claim creation if claim amount exceeds the remaining Activity Budget Amount, Applicable for Retail/IPA/Opal
            if(!Core_MDF_Utility.byPassFeature('Bypass_Claims_Amt_vs_Budget_Amt_Check'))
                Core_MDF_Claim_Utility.checkClaimAmtAgainstActivityBudgetAmt(newClaimList); 
        
            //call Campaign CAP for CCF/DCF/SPCF/Boost program
            if(!Core_MDF_Utility.byPassFeature('Bypass_Claims_Amt_vs_Camp_Amt_Check'))
                Core_MDF_PFC_Budget_CAP_Validations.checkClaimAmtAgainstCampaignCAPtAmt(newClaimList);
        
            
            if(mapFunctionalityNameTriggerExecution.containsKey('checkESDHoldAndUpdateClaimStatus') &&
               mapFunctionalityNameTriggerExecution.get('checkESDHoldAndUpdateClaimStatus').Core_Active__c){                   
                   // check if the Bank on ESD Hold during insertion of Claim       
                   Core_MDF_PFC_HoldCheck.checkESDHoldAndUpdateClaimStatusOnInsert(newClaimList);
               }

               // Check if the Claim is potentially duplicate and update the duplicate flag
            if(!Core_MDF_Utility.byPassFeature('Bypass_Claims_Duplicate_Check'))
                  Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert((newClaimList));
            
            // call generic Claim update status method inorder to map the standard and custom status field on Claim
            Core_MDF_Claim_Utility.updateClaimStatus(newClaimList,NULL);
            
            //Call populate Owner LanguageLocal key method on Claim Create
            if(!Core_MDF_Utility.byPassFeature('Bypass_Claim_OwnerLang_EmailTemp'))
                Core_MDF_Claim_Utility.populateOwnerLangLocalOnClaim(newClaimList,NULL);
            
            if(mapFunctionalityNameTriggerExecution.containsKey('enableClaimsVATEligible') &&  
            mapFunctionalityNameTriggerExecution.get('enableClaimsVATEligible').Core_Active__c){
               Core_MDF_Claim_VAT_Process.isClaimEligibleForVAT(newClaimList); 
           }
       
       // Populate Quarter Year field based on claims ad run start date
        Core_MDF_Claim_Utility.populateQuarterYearFieldOnClaimInsert(newClaimList);
        
            // Set Bank Document Hold Eligibility Indicator on the Eligible Claims
            Core_MDF_Claim_Utility.isClaimEligibleForBankDocHold(newClaimList);
        
        //Update payment reminder date on claim once Bank Document Hold is set to true
        Core_MDF_Claim_Utility.updatePaymentAdminReminderDate(newClaimList,null);
        
    }
    
    public static void claimProcessesOnAfterInsert(List<PartnerFundClaim> newClaimList, List<PartnerFundClaim> oldClaimList, Map<Id,PartnerFundClaim> oldClaimMap){
                
        List<PartnerFundClaim> claimsTobeAudited = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimsPFRToBeUpdated = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimsForVATProcess = new List<PartnerFundClaim>();
        Set<Id> pfrSetToBeUpdated = new Set<ID>();
        string isclaimAdjustmentType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type'); 
        for(PartnerFundClaim claim : newClaimList)
        {
            //preparing list to be sent for Activity In-Progress Update Adjustments are skipped as no action required
            if(!Core_MDF_Claim_Utility.isType(claim, isclaimAdjustmentType))
            {
                claimsPFRToBeUpdated.add(claim);
                pfrSetToBeUpdated.add(claim.RequestId); 
            }
            
            //check if adjustment and TobeAudit=true then break : Areefa ; also check if the CRR Positive claim indicator is false then only add the claims for audit            
            if( (!Core_MDF_Claim_Utility.isType(claim, isclaimAdjustmentType)))
            {
                claimsTobeAudited.add(claim);
            }
            //if the claim is VAT eligible and CRR Positive indicator is true or STP indicator is true or Claim is Adjustment type then send the claims for VAT process
            else if((Core_MDF_Claim_Utility.isType(claim, isclaimAdjustmentType)) && claim.Core_MDF_VAT_Eligibility_Ind__c ){ 
                claimsForVATProcess.add(claim);
            }
           
        }
        if(mapFunctionalityNameTriggerExecution.containsKey('enableClaimsVatAfterInsert') &&  
           mapFunctionalityNameTriggerExecution.get('enableClaimsVatAfterInsert').Core_Active__c){
               if(claimsForVATProcess!= null && claimsForVATProcess.size()>0){
                   Core_MDF_Claim_VAT_Process.createUpdateVATRecord(claimsForVATProcess,null,null);
               } 
           }
        
        Map<ID,PartnerFundClaim> claimIdToClaimMap = new Map<ID,PartnerFundClaim>(newClaimList);

           if(mapFunctionalityNameTriggerExecution.containsKey('checkAndSendClaimsForPIC') &&
          mapFunctionalityNameTriggerExecution.get('checkAndSendClaimsForPIC').Core_Active__c){
               // Call the Audit Selection Helper class and send all the claims for Audit
              ID jobID = System.enqueueJob(new Core_MDF_BatchtoPICClaim(claimsTobeAudited));
         } 

        // Share the Claims with the Internal Account Managers
        if(!Core_MDF_Utility.byPassFeature('Bypass_Claims_Sharing_Internal_Users'))
            Core_MDF_PFC_Sharing.shareClaimToInternalUsers(newClaimList);
        
        // Share the Claims with the Users having access to the Account(Node) on Claims
        if(!Core_MDF_Utility.byPassFeature('Bypass_Claims_Sharing_Partner_Users'))
            Core_MDF_PFC_Sharing.shareClaimToPartnerUsers(claimIdToClaimMap);
        
        //Update escalation with claim ID
        Core_MDF_Claim_Utility.updateClaimIdOnEscalation(newClaimList);       
       
        // Method to make the Activity related to Claim In Progress
        // Core_MDF_ClaimActivityHelper.updateActivityStatusInProgress(claimsPFRToBeUpdated, pfrSetToBeUpdated);       
        // Call the Update Owner and Func Reservation Functionality If Audit functionality is not Active
        //Core_MDF_ProcessCCP_Claim.updateOwnerAndFundReservationCheckOnInsert(claimIdToClaimMap);
    }
    
    public static void claimProcessesOnBeforeUpdate(List<PartnerFundClaim> newClaimList, List<PartnerFundClaim> oldClaimList, Map<Id,PartnerFundClaim> oldClaimMap,Map<Id,PartnerFundClaim> newClaimMap){
        
        List<string> opalBudgetTypes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').split(';');
        // Calculate the claim fields related to Amount/Currency if Amount related fields are updated 
         Core_MDF_Claim_Utility.calculateClaimAmtFieldsOnUpdate(newClaimMap,oldClaimMap);
            
            //Call VAT provess
            if(mapFunctionalityNameTriggerExecution.containsKey('enableClaimVatBeforeUpdate') &&  
               mapFunctionalityNameTriggerExecution.get('enableClaimVatBeforeUpdate').Core_Active__c){
                   Core_MDF_Claim_VAT_Process.processVATRecords(newClaimMap,oldClaimMap); 
               }
        
        Core_MDF_PIC_Utility.checkForHoldIndAndUpdateStatus(newClaimMap,oldClaimMap);
        
        //Updating Region field and subregion field according to country selected if country is updated
        Core_MDF_Claim_Utility.updateRegionFieldOverClaimOnUpdate(newClaimMap,oldClaimMap); 
        
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_BudgetCapValidation') &&
           mapFunctionalityNameTriggerExecution.get('Core_MDF_BudgetCapValidation').Core_Active__c){
            //Prevent claim creation if claim amount exceeds the remaining cap 
            Core_MDF_BudgetCapHelper.checkBudgetAvailabiltyOnClaimUpdate(newClaimMap,oldClaimMap);                                   
        }        
        
        if(mapFunctionalityNameTriggerExecution.containsKey('checkESDHoldAndUpdateClaimStatus') &&
           mapFunctionalityNameTriggerExecution.get('checkESDHoldAndUpdateClaimStatus').Core_Active__c){
               
               // Validate ABM is active and calulate the ESD Hold Bank Check If Bank is getting upated        
               Core_MDF_PFC_HoldCheck.validateBankMappingAndApplyHold(newClaimMap,oldClaimMap);
           }
         
        // Set Bank Document Hold Eligibility Indicator on the Eligible Claims
        Core_MDF_Claim_Utility.isClaimEligibleForBankDocOnBankChange(newClaimMap,oldClaimMap);   
        
        // Call Bank Document Hold method on Amount change
        Core_MDF_Claim_Utility.isClaimEligibleForBankDocOnAmtChange(newClaimMap,oldClaimMap);     
        
        if(!Core_MDF_Utility.byPassFeature('Bypass_Claims_Duplicate_Check'))
            if(mapFunctionalityNameTriggerExecution.containsKey('duplicateClaimCheck') &&
               mapFunctionalityNameTriggerExecution.get('duplicateClaimCheck').Core_Active__c){
                   
                   // Calculate the if the Claim updated is potentially duplicate 
                   Core_MDF_Claim_Utility.duplicateClaimCheckOnUpdate(newClaimList,oldClaimMap);          
            } 
        
        //Areefa :12 Nov,2021
        if(!Core_MDF_Utility.byPassFeature('Bypass_StampingOfActySubType_Check'))
        Core_MDF_Claim_Utility.updateClaimFieldsFromActivity(newClaimList,newClaimMap,oldClaimMap);

        
        // Call below method to prepare the Claims for PIC if any of the respective editable fields are updated
        Core_MDF_Claim_Utility.updateEvalInProgressFlag(newClaimList,oldClaimMap);
        
        
        // call generic Claim update status method inorder to map the standard and custom status field on Claim
        Core_MDF_Claim_Utility.updateClaimStatus(newClaimList,oldClaimMap);
        
         // Call the method for updating Language of respective users if Owner gets changed
        if(!Core_MDF_Utility.byPassFeature('Bypass_Claim_OwnerLang_EmailTemp'))
            Core_MDF_Claim_Utility.populateOwnerLangLocalOnClaim((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>) Trigger.oldMap);
        
          // Populate Quarter Year field based on claims ad run start date during claim Update
        Core_MDF_Claim_Utility.updateQuarterYearFieldOnClaimUpdate(newClaimList,oldClaimMap);
        //Update payment reminder date on claim once it is put on Bank Document Hold
        Core_MDF_Claim_Utility.updatePaymentAdminReminderDate(newClaimList,oldClaimMap);
        
        if(!Core_MDF_Utility.byPassFeature('Bypass_Queued_Hold_Email')){
            Core_MDF_Claim_Utility.updateQueuedHoldEmailSent(newClaimList); 
        }
    }
    
    public static void claimProcessesOnAfterUpdate(List<PartnerFundClaim> newClaimList, List<PartnerFundClaim> oldClaimList, Map<Id,PartnerFundClaim> oldClaimMap){
               if(mapFunctionalityNameTriggerExecution.containsKey('checkAndSendClaimsForPIC') &&
           mapFunctionalityNameTriggerExecution.get('checkAndSendClaimsForPIC').Core_Active__c){
               // Send the Claims not selected for PIC before, to PIC Process
               Core_MDF_Claim_Utility.sendclaimsforPIC((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>) Trigger.oldMap);
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
        
         if(mapFunctionalityNameTriggerExecution.containsKey('reserveFundsforNode') &&
               mapFunctionalityNameTriggerExecution.get('reserveFundsforNode').Core_Active__c){
             // Process the Claims which are Cancelled
             Core_MDF_ProcessCCP_Claim.reserveFundsforNode((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>) Trigger.oldMap);
        }
         // Release the funds on Auto closed Activity when the claim is cancelled
         if(mapFunctionalityNameTriggerExecution.containsKey('ReleaseFundsOnActivity') &&
               mapFunctionalityNameTriggerExecution.get('ReleaseFundsOnActivity').Core_Active__c){
             Core_MDF_ProcessCCP_Claim.OnCancelUpdateActivityAmount((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>) Trigger.oldMap);
        }
        
        // Call the method for sharing the Claim to respective users if Owner gets changed
        if(!Core_MDF_Utility.byPassFeature('Bypass_Claims_Sharing_On_Owner_Change'))
            Core_MDF_PFC_Sharing.recalculateShareClaimWhenOwnerChange((List<PartnerFundClaim>) Trigger.NEW,(Map<Id,PartnerFundClaim>) Trigger.oldMap);            
                    
        //Call this method to create VAT record for VAT eligible claim
        if(mapFunctionalityNameTriggerExecution.containsKey('enableClaimsVatAfterUpdate') &&  
           mapFunctionalityNameTriggerExecution.get('enableClaimsVatAfterUpdate').Core_Active__c){
              Core_MDF_Claim_VAT_Process.createUpdateVATRecord(newClaimList,(Map<Id,PartnerFundClaim>) Trigger.newMap, oldClaimMap);
           } 
    }
    
}