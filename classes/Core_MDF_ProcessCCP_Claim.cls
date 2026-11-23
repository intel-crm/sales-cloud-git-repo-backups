/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Claim 
* Test Class  : Core_MDF_ProcessCCP_Claim_Test
* Version     : 1.0 
* Created Date: 11-03-2018
* Modification Log :
* Developer               Date                          Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – JV         11/03/2018                    Created Core_MDF_ProcessCCP_Claim for Claim Fund Check And Fund Allocation 
-----------------------------------------------------------------------------------------------------------------------------------------
Modified By:        Date:       Changes: 
Accenture- VD       05-02-2019  Created Set for recordType and created variable for SPCF record
Intel - SM          07-16-2019  Changed the auto transfer method to a bulkified one
*****************************************************************************************************************************************/

public without sharing class Core_MDF_ProcessCCP_Claim { 
    
    public static Boolean recursiveCheckStop = false;
    // Temporary Variables Initialization
    public static Decimal currentAllocationRemainingAmount = 0;
    public static Decimal autoTransferAllocationremainingAmount = 0;
    public static Decimal transferAmount = 0;
    public class CustomException extends Exception{} // Added by Areefa
    /**
* @description : This method is used for checking and releasing the funds on Claim Insertion and Updation
the method will not commit the changes to the database, for committing, explicit DML to be done
* @param originalClaimsTobeProcessed : List of Claims Inserted / Updated
*/
    public static void fundReservation(Map<ID,PartnerFundClaim> originalClaimsTobeProcessed, Boolean recoveryCheck){
        
        try {
            // checking the recurdsiveCheckStop to TRUE to avoid recursion
            recursiveCheckStop = true;
            //Record Type Info Map
            Map<String,Schema.RecordTypeInfo> claimRecordTypeMap = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName();
            // Assign set of CoMarketing Record Types for Claims
            Set<Id> recordTypeSet = Core_MDF_Claim_Utility.getRecordTypeSet(claimRecordTypeMap);
            // Get the claimReservationStatus to be checked for Claim Reservation Process
            Set<String> claimReservationStatusSet = new Set<String>();
            //map of the claims
            Map<ID,PartnerFundClaim> claimsTobeProcessed;
            
            List<Core_MDF_Bulk_Transaction__e> bulkTranEvents = new List<Core_MDF_Bulk_Transaction__e>();
            
            String claimReservationStatusList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimReservationCheckStatus');
            if(!String.IsBlank(claimReservationStatusList)){
                for(String claimStatus : claimReservationStatusList.split(';')){
                    claimReservationStatusSet.add(claimStatus);
                }
            }
            // modifying the incoming claim list to add the related fields like Allocation.Amount, ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c etc
            // and ordering the list according to the Creation Date of the Claims    
            PartnerFundClaim clm = [Select Id, Core_MDF_Status__c from PartnerFundClaim where Id IN: originalClaimsTobeProcessed.values() limit 1];
            if(recoveryCheck){
                claimsTobeProcessed = new Map<ID,PartnerFundClaim>(originalClaimsTobeProcessed);
            }else{
                claimsTobeProcessed = new Map<ID,PartnerFundClaim>([SELECT Id, Amount, AllocationId, Allocation.Amount, Allocation.TotalApprovedFcs,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,
                                                                                         Core_MDF_Claim_Previous_Status__c,ChannelPartnerId,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,Request.ChannelPartnerId,
                                                                                         Allocation.Core_MDF_Available_Allocation_Amount__c,Core_MDF_Status__c,CreatedDate,BudgetId,Status
                                                                                         FROM PartnerFundClaim  
                                                                                         WHERE ID IN:originalClaimsTobeProcessed.values() AND (RecordTypeId IN:recordTypeSet) 
                                                                                         AND Core_MDF_Status__c IN:claimReservationStatusSet ORDER BY CreatedDate]);
            }
            // Create Map<ClaimId, currentAllocationNodeId>
            Map<Id,String> claimIdToAutoTransferNodeId = new Map<Id,String>();
            
            // Create Map<ClaimId, currentAllocationBudgetId>
            Map<Id,Id> claimIdTocurrentAllocationBudgetId = new Map<Id,Id>();
            
            // Create Map<AllocationId, currentAllocationNodeId>
            Map<PartnerFundAllocation,String> allocationIdToNodeMap = new Map<PartnerFundAllocation,String>();
            
            // Create Map<ClaimId, AutoTransferAllocation>
            Map<Id,PartnerFundAllocation> claimIdToAutoTransferAllocationMap = new Map<Id,PartnerFundAllocation>();
            
            // Create the List of Claims according to their Account Node
            List<List<PartnerFundClaim>> claimListGroupedByAccountNode = new List<List<PartnerFundClaim>>();
            
            //List of budgetTransferWrapper objects to be sent to TransferAllocation Method
            List<Core_MDF_BudgetTransferWrapper> budgetTransferWrapperList = new List<Core_MDF_BudgetTransferWrapper>();            
            
            //List of fundAllocationWrapper objects to be sent to TransferAllocation Method
            List<PartnerFundClaim> autoTransferedClaimList = new List<PartnerFundClaim>();
            
            // Temporary Variables Initialization
            //Decimal currentAllocationRemainingAmount = 0;
            //Decimal autoTransferAllocationremainingAmount = 0;
            //Decimal transferAmount = 0;
            
            //List of MainWrapperToBeProcessed Class:
            List<MainWrapperToBeProcessed> mainWrapperList =  new List<MainWrapperToBeProcessed>();
            
            // Create the Set of AllocationIds associated with the Claims to be processed
            Set<ID> allocationIdSet = new Set<ID>();
            
            for(PartnerFundClaim pfc : claimsTobeProcessed.values()){
                allocationIdSet.add(pfc.AllocationId);
            }
            
            Set<Id> autoTransferAccIds = new Set<Id>();
            // Get all the Claims, Account-Node of which supports Auto Transfer
            for(PartnerFundClaim pfc : claimsTobeProcessed.values()){
                
                if(pfc.ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c){
                    claimIdToAutoTransferNodeId.put(pfc.Id,pfc.ChannelPartner.Core_MDF_Auto_Transfer_Account__c+Label.Core_MDF_Underscore+pfc.BudgetId);
                    autoTransferAccIds.add(pfc.ChannelPartner.Core_MDF_Auto_Transfer_Account__c);
                    claimIdTocurrentAllocationBudgetId.put(pfc.Id,pfc.BudgetId);
                }
            }
            
            if(claimIdToAutoTransferNodeId != NULL && claimIdToAutoTransferNodeId.size() > 0)
            {   
                for(PartnerFundAllocation pfa : [SELECT Id, Amount, BudgetId, ChannelPartnerId, TotalApprovedFcs FROM PartnerFundAllocation 
                                                 WHERE ChannelPartnerId IN: autoTransferAccIds 
                                                 AND BudgetId IN: claimIdTocurrentAllocationBudgetId.values()]){
                                                     
                                                     allocationIdToNodeMap.put(pfa,pfa.ChannelPartnerId+Label.Core_MDF_Underscore+pfa.BudgetId);
                                                 }
                
            }
            for(Id pfc : claimIdToAutoTransferNodeId.keyset()){
                
                for(PartnerFundAllocation pfa : allocationIdToNodeMap.keyset()){
                    
                    if(claimIdToAutoTransferNodeId.get(pfc) == allocationIdToNodeMap.get(pfa)){
                        
                        claimIdToAutoTransferAllocationMap.put(pfc,pfa);
                    }
                    
                }
            }
            
            // Prepare Main Wrapper conatining Account, List of its associated Claims and the Temporary shared variable 
            // containing remaining amount
            for(ID allocationId : allocationIdSet)
            {   
                MainWrapperToBeProcessed mainWrapperInstance =  new MainWrapperToBeProcessed();
                
                for(PartnerFundClaim claim : claimsTobeProcessed.values())
                {   
                    if(claim.AllocationId == allocationId){
                        
                        mainWrapperInstance.accNodeOfClaim = claim.ChannelPartnerId;
                        mainWrapperInstance.associatedClaims.add(claim);
                        mainWrapperInstance.currentAllocationAmount = (claim.Allocation.Amount - claim.Allocation.TotalApprovedFcs);                      
                    }
                     //Event handling
                    /* ClaimsWrapperForLogging clsWrap = claimWrapObjForLogging (claim,0.0,0.0,0.0,0.0,
                                                                               'Claim Allocation Amount block');
                     bulkTranEvents.add(bulkTransactionEvent(clsWrap,'PartnerFundClaim'));*/
                    
                }
                mainWrapperList.add(mainWrapperInstance);
            }
            // Iterate on the Main Wrapper List, check funds if available , add the claims to approprate list and 
            // update the offline transaction variable "currentAllocationRemainingAmount" accordingly
            for(MainWrapperToBeProcessed mainWrapperInstance : mainWrapperList){
                
                currentAllocationRemainingAmount = mainWrapperInstance.currentAllocationAmount;
                // autoTransferAllocationremainingAmount = mainWrapperInstance.autoTransferAllocationAmount;
                
                for(PartnerFundClaim claim : mainWrapperInstance.associatedClaims){                    
                    // if funds are available                         
                    if(claim.Amount <= currentAllocationRemainingAmount){
                        // add to the List of claims to be updated to Approved - Payment Due
                        originalClaimsTobeProcessed.get(claim.ID).Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Payment_Due');

                        currentAllocationRemainingAmount = (currentAllocationRemainingAmount - claim.Amount) < 0 ? 0 : (currentAllocationRemainingAmount - claim.Amount);
                        //Event handling
                       /*  ClaimsWrapperForLogging clsWrap = claimWrapObjForLogging (claim,currentAllocationRemainingAmount,
                                                                                   0.0,0.0,0.0,
                                                                                   'Claim Amount less than Current Allocation Remaining Amount');
                         bulkTranEvents.add(bulkTransactionEvent(clsWrap,'PartnerFundClaim'));   */                        
                       }
                    else{
                        
                        // check for auto-transfer on the claim.Request.ChannelPartner.AutoTransfer
                        if(claim.ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c){
                            // Find the Allocation for the Account Node -- Selected on the claim.Request.ChannelPartner
                            PartnerFundAllocation autoTransferAllocation = claimIdToAutoTransferAllocationMap.get(claim.Id); 
                            
                            if(autoTransferAllocation != NULL){autoTransferAllocationremainingAmount = (autoTransferAllocation.Amount - autoTransferAllocation.TotalApprovedFcs) <0 ? 0 : (autoTransferAllocation.Amount - autoTransferAllocation.TotalApprovedFcs);}
                            else{autoTransferAllocationremainingAmount = 0;}
                            
                            if(currentAllocationRemainingAmount + autoTransferAllocationremainingAmount >= claim.Amount){
                                
                                //calculate delta amount
                                transferAmount = claim.Amount - currentAllocationRemainingAmount;
                                // add to the budgetTransferWrapperList if funds available       
                                budgetTransferWrapperList.add(new Core_MDF_BudgetTransferWrapper(autoTransferAllocation.ChannelPartnerId, claim.ChannelPartnerId, 
                                                                                                 autoTransferAllocation.BudgetId,transferAmount, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Transfer_Type_Auto')));
                                
                                originalClaimsTobeProcessed.get(claim.ID).Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Payment_Due');
                                autoTransferedClaimList.add(claim);
                                
                                currentAllocationRemainingAmount = 0;
                                // we cannot use the below field as its formula, going with the field update of the fields used in formula
                                //autoTransferAllocation.Core_MDF_Available_Allocation_Amount__c -= transferAmount
                                // The below change in Amount ensures that the Reference to the Allocation --> Amount in the Map is changed, not the value
                                autoTransferAllocation.Amount = (autoTransferAllocation.Amount - transferAmount ) < 0 ? 0 : (autoTransferAllocation.Amount - transferAmount );
                                 //Event handling                                
                                 /*ClaimsWrapperForLogging clsWrap = claimWrapObjForLogging (claim,currentAllocationRemainingAmount,
                                                                                           transferAmount,autoTransferAllocation.Amount,
                                                                                           autoTransferAllocationremainingAmount,
                                                                                           'Remaining Amount greater than Claim Amount');                   
                                 bulkTranEvents.add(bulkTransactionEvent(clsWrap,'PartnerFundClaim'));*/
                                  
                                    }
                            else{
                                // else update the status of Claim to PAF
                                originalClaimsTobeProcessed.get(claim.ID).Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
                                
                            }
                        }
                        // else update the status of Claim to PAF
                        else{originalClaimsTobeProcessed.get(claim.ID).Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
                            }
                        
                    }    
                    
                }
                
            }

            if(budgetTransferWrapperList != NULL && budgetTransferWrapperList.size() > 0){
                try{string result = Core_MDF_BudgetTransferUtility.budgetTransfer(budgetTransferWrapperList);
                    if(!Label.Core_MDF_Success.equals(result)){throw new DMLException('Exception Occured:::'+result);
                                                              }
                   }catch(Exception e){throw new DMLException('Exception Occured:::'+e);}
            }
          //Event Publish
             /* if(bulkTranEvents != null && !bulkTranEvents.isEmpty()){              
                List<Database.SaveResult> results = EventBus.publish(bulkTranEvents);  
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                    } 
                    else { 
                        for(Database.Error err : sr.getErrors()) { 
                        }
                    }
                }  
            }   */
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new DMLException('Exception Occured:::'+e);}
    }
    
    
    /**
* @description: Create Wrapper Class, instance of which contains the Account Node, its associated claims 
and the currentAllocation Amount on the related Activity's allocation
*/
    public class MainWrapperToBeProcessed{
        
        ID accNodeOfClaim;
        List<PartnerFundClaim> associatedClaims = new List<PartnerFundClaim>();
        Decimal currentAllocationAmount = 0;
        
    }
    
    /***************************************************************************************************** 
Method Name:        reserveFundsforNode
@return  :          void
@parameters:        claimList
Description:        Method to reserveFundsforNode
@Added By:          Accenture - JV 
Modified By:        Date:            Changes:  
Accenture JV      18/3/2019        Moved the Method call outside the For Loop
******************************************************************************************************/ 
    public static void reserveFundsforNode(List<PartnerFundClaim> claimList, Map<Id,PartnerFundClaim> oldClaimMap){
        //Set of allocation ids
        Set<ID> allocationIds = new Set<ID>();
        for(partnerFundClaim pfcRecord: claimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(pfcRecord, Label.Core_MDF_Claim_Adjustment_Type))
            {continue;}
            if((oldClaimMap.get(pfcRecord.Id).Status!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Rejected')  && pfcRecord.Status == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Rejected')) 
               || (oldClaimMap.get(pfcRecord.Id).Core_MDF_Status__c !=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold') && pfcRecord.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold'))
               || (oldClaimMap.get(pfcRecord.Id).Core_MDF_Status__c !=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Denied') && pfcRecord.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Denied'))
               || (oldClaimMap.get(pfcRecord.Id).Core_MDF_Status__c !=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Adjusted') && pfcRecord.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Adjusted')))
            {
                allocationIds.add(pfcRecord.AllocationId);
            }  
            
        }
        
        if(!allocationIds.isEmpty() && allocationIds.size()>0)
        {
            System.enqueueJob(new Core_MDF_Queueable_Process_PAF_Claim(allocationIds));
        } 
    }
  
//WW11 - Release Funds on Claim cancellation/Resubmission Window closed Status. 

public static void OnCancelUpdateActivityAmount(List<PartnerFundClaim> claimList, Map<Id,PartnerFundClaim> oldClaimMap){
        List<Core_MDF_Bulk_Transaction__e> RecordList = new List<Core_MDF_Bulk_Transaction__e>();
        List<String> MDFBudgetTypes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDF_BudgetTypes').split(';');
        List<string> pfrProgramSpecific = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Close_Open_Activity_Program').split(';');
        String actionName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BulkPE_ActionName_Claim');
        Map<String, String> claimIdToClaimRefMap = new Map<String, String>();
        try{
      
        for(partnerFundClaim pfcRecord: claimList){
            
        if(pfcRecord.Core_MDF_Type_Txt__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Type') 
            && (pfcRecord.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled') || pfcRecord.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ResubWinClosed'))
               && pfcRecord.Core_MDF_Activity_Status_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Activity_Closed_Status'))
               {
                 PartnerFundClaim pfc = new PartnerFundClaim(Id=pfcRecord.id);
                pfc.RequestId = pfcRecord.RequestId;
                pfc.Core_MDF_Budget_Type_Options_Nm__c = pfcRecord.Core_MDF_Budget_Type_Options_Nm__c;
                pfc.Core_MDF_Escalation_Id__c = pfcRecord.Core_MDF_Escalation_Id__c;
                Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e(); 
                evtObj.Core_MDF_JSON_Data__c = JSON.serialize(pfc); 
                evtObj.Core_MDF_Object_Name__c = 'PartnerFundClaim';
                evtObj.Core_MDF_Action_Name__c = actionName;
                RecordList.add(evtObj);
            }

            if(pfcRecord.Core_MDF_Program__c == Label.Core_MDF_IPA_Technical_program_name &&  pfcRecord.Core_MDF_Activity_Category__c == Label.Core_MDF_Outcome_Based_CatType && pfcRecord.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled') && pfcRecord.Core_MDF_Status__c != oldClaimMap.get(pfcRecord.Id).Core_MDF_Status__c){
                claimIdToClaimRefMap.put(pfcRecord.Id, pfcRecord.Core_MDF_Claim_Ref_Number__c);
            }
        }

        if(claimIdToClaimRefMap != null && !claimIdToClaimRefMap.isEmpty()){
            Core_MDF_Tactics_Controller.updateClaimAttributes(claimIdToClaimRefMap, null, 'Cancel');
        }

           
        if(!RecordList.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(RecordList);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                } 
                else { 
                    for(Database.Error err : sr.getErrors()) {
                    }
                }
            }
         }
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}        
   
}
          
    /**
* @description : Method to check the claim's liability for Fund Reservation and thereby calling it if eligible
* @param newclaimMap : Map containing the claimId as key and new claims (updated) as value
* @param oldClaimMap : Map containing the claimId as key and claims (not updated) as value
*/
    public static void fundReservationCheckOnUpdate(Map<Id,PartnerFundClaim> newclaimMap,Map<Id,PartnerFundClaim> oldClaimMap){
        
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_MDF_PFCServiceHandler.mapFunctionalityNameTriggerExecution;
        // flag saying whether the PIC functionality is ON or OFF
        Boolean isPICRequired = (mapFunctionalityNameTriggerExecution.containsKey('checkAndSendClaimsForPIC') 
                                   && mapFunctionalityNameTriggerExecution.get('checkAndSendClaimsForPIC').Core_Active__c)
            ? true : false;
        
        // Map containing the claims to be sent for Fund Reservation
        Map<Id,PartnerFundClaim> claimsToBeReserved = new Map<Id,PartnerFundClaim>();
        
        for(PartnerFundClaim pfc : newclaimMap.values()){
            //check if adjustment then break
            Boolean isPICRequiredBasedOnPgm = pfc.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM ? false : isPICRequired;
            if(Core_MDF_Claim_Utility.isType(pfc, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type'))){continue;}
            if(!recursiveCheckStop && oldClaimMap != null && isClaimEligible(pfc,oldClaimMap.get(pfc.Id),isPICRequiredBasedOnPgm)){
                PartnerFundClaim newpfc = new PartnerFundClaim();
                newpfc.Id = pfc.Id;
                claimsToBeReserved.put(newpfc.Id,newpfc);
            }
            else{
                if(!recursiveCheckStop && oldClaimMap == null && isClaimEligible(pfc,null,isPICRequired)){
                    PartnerFundClaim newpfc = new PartnerFundClaim();
                    newpfc.Id = pfc.Id;
                    claimsToBeReserved.put(newpfc.Id,newpfc);
                }
            }

        }
        if(claimsToBeReserved != null && claimsToBeReserved.size()>0){
            fundReservation(claimsToBeReserved,false); 
            Database.update(claimsToBeReserved.values());
        }
    }
    
    /**
* @description : Method to check the claim's liability for Fund Reservation and thereby calling it if eligible
* @param newclaim : new claims (updated) 
* @param oldClaim : claims (not updated) 
*/
   public static Boolean isClaimEligible(PartnerFundClaim newclaim,PartnerFundClaim oldClaim, Boolean isPICRequired){  
        // if EvalInProgress is True; Don't Process the Claim for Fund Reservation
        if(newclaim != null && newclaim.Core_MDF_Claim_EvalInProgress_Ind__c == true){
            return false;
        }
        else{
            // if PIC is ON
            if(isPICRequired && oldClaim != null){  
                // if method called from Service Handler if PIC is turned off or in case of Release Hold 
                //  
                if(oldClaim !=null && (
                    (newclaim.Core_MDF_Audit_Hold__c == false && oldClaim.Core_MDF_Audit_Hold__c == true) || (newclaim.Core_MDF_ESD_Hold__c == false && oldClaim.Core_MDF_ESD_Hold__c == true) || (newclaim.Core_MDF_Payment_Hold_ind__c == false && oldClaim.Core_MDF_Payment_Hold_ind__c == true)||(newclaim.Core_MDF_Member_Manual_Hold_Ind__c == false && oldClaim.Core_MDF_Member_Manual_Hold_Ind__c == true) 
                    || (newclaim.Core_MDF_Intel_Manual_Hold_Ind__c == false && oldClaim.Core_MDF_Intel_Manual_Hold_Ind__c == true)||(newclaim.Core_MDF_Criteria_Hold_Ind__c == false && oldClaim.Core_MDF_Criteria_Hold_Ind__c == true)||(newclaim.Core_MDF_Audit_Adjustment_Amount__c != oldClaim.Core_MDF_Audit_Adjustment_Amount__c) || (newclaim.Core_MDF_VAT_Hold_Ind__c == false && oldClaim.Core_MDF_VAT_Hold_Ind__c == true) || (!newclaim.Core_MDF_Document_Hold_Ind__c && oldClaim.Core_MDF_Document_Hold_Ind__c) 
                    || (!newclaim.Core_MDF_Bank_Doc_Hold_Ind__c && oldClaim.Core_MDF_Bank_Doc_Hold_Ind__c)
                || (newclaim.Core_MDF_PIC_Review_Completed__c && !oldClaim.Core_MDF_PIC_Review_Completed__c)
                || (!newclaim.Core_MDF_Claim_EvalInProgress_Ind__c && oldClaim.Core_MDF_Claim_EvalInProgress_Ind__c)
                )
                   && (newclaim.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted') || newclaim.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Available_Fund'))){
                       return true;
                   }else{return false;} 
            }else{
                // if PIC is OFF / if method is called from Cancelled Claim / Update Allocation Method
                if(newclaim.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted') || newclaim.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Available_Fund')){
                    return true;
                }else{return false;}
            }
        }
    }
    /**
* @description : Method to check the claim's liability for Fund Reservation and thereby calling it if eligible
* @param newclaimMap : Map containing the claimId as key and new claims (updated) as value
*/
 /*   public static Map<Id, PartnerFundClaim> fundReservationCheckOnInsert(Map<Id,PartnerFundClaim> newclaimMap){
        // Map containing the claims to be sent for Fund Reservation
        Map<Id,PartnerFundClaim> claimsToBeReserved = new Map<Id,PartnerFundClaim>();        
        
        for(PartnerFundClaim pfc : newclaimMap.values()){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(pfc, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type')))
            {continue;}
            if(!recursiveCheckStop && pfc.Core_MDF_AuditSelectionInProgress__c == false 
               && (pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted')
                   || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Available_Fund')
                  )){
                      PartnerFundClaim newpfc = new PartnerFundClaim();
                      newpfc.Id = pfc.Id;
                      claimsToBeReserved.put(newpfc.Id,newpfc);
                  }
        }
        // Calling fund reservation method and Adding The claims to Final List
        if(claimsToBeReserved != null && claimsToBeReserved.size()>0){
            fundReservation(claimsToBeReserved,false); 
        }
        return claimsToBeReserved;
    }*/
    
    
    public static List<PartnerFundClaim> setBankDocHoldonEligibleClaims(List<PartnerFundClaim> claimList){
        List<PartnerFundClaim> claimListToBeUpdated = new List<PartnerFundClaim>();
        //claimMap = newClaimMap;
        for(PartnerFundClaim pfc : claimList){
            if(Core_MDF_Claim_Utility.isType(pfc, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type'))) { continue;}
            
            if(pfc.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c){                
                
                pfc.Core_MDF_Bank_Doc_Hold_Ind__c = true;
                //after PIC process
                //pfc.Core_MDF_Status__c = 'Hold';
            }
            claimListToBeUpdated.add(pfc);
        }
        return claimListToBeUpdated;
    }
    

    //Changes done by Ealisha for TWC742-257: [Tech] - Claims are scored when created or edited the model relevant fields  
    //Method to trigger a PE for inserting a record in claim pred object
    public static void InsertToClaimPredictionObj(Map<Id,PartnerFundClaim> newclaimMap){
        List<Core_MDF_Claim_Prediction_Event__e > plEventIdLst = new List<Core_MDF_Claim_Prediction_Event__e >();
            for(PartnerFundClaim claim :newclaimMap.values()){
                plEventIdLst.add(new Core_MDF_Claim_Prediction_Event__e(Core_MDF_PE_ID__c = claim.id, Core_MDF_Activity_ID__c= claim.RequestId,Core_MDF_Claim_Id_External_id__c=claim.id));           
            }
            List<Database.SaveResult> results = EventBus.publish(plEventIdLst);  
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        Throw new CustomException(err.getMessage());
                    } 
                }               
            }
    }
    
    //Changes done by Ealisha for TWC742-257: [Tech] - Claims are scored when created or edited the model relevant fields    
    public static void SendClaimsToClaimPrediction(Map<Id,PartnerFundClaim> oldclaimMap, Map<Id,PartnerFundClaim> newclaimMap){  
        try{
            
            //check if its new claim or updated claim
            //if new then check if leagcy. If legacy then upsert else call PE.
            //if updated check if legacy and if relevent fields then upsert else if non legacy and relevent fields then call PE. 
            
            Map<Id,PartnerFundClaim> claimMapForClaimPred = new Map<Id,PartnerFundClaim>();
            List<Core_MDF_Claim_Prediction__c> clmPredList = new List<Core_MDF_Claim_Prediction__c>();
            List<Id> claimIdsForSearchingClmPred = new List<Id>();
            
            if(oldclaimMap == null){
                for(Id claimId:newClaimMap.keySet()){
                    if(newClaimMap.get(claimId).Core_MDF_Legacy_Claim_Ind__c){
                        Core_MDF_Claim_Prediction__c clmPred = new Core_MDF_Claim_Prediction__c(Core_MDF_Claim_Id__c=claimId,Core_MDF_ClaimBrand_nm__c=newClaimMap.get(claimId).Core_MDF_Brand_Nm__c, Core_MDF_Claim_Id_External_id__c=claimId);
                        clmPredList.add(clmPred);
                    }
                    else{
                        // for non legacy claims only
                        if(newClaimMap.get(claimId).Core_MDF_PIC_Review_Completed__c){
                            claimMapForClaimPred.put(claimId,newClaimMap.get(claimId));
                        }
                    }
                }
            }
            else {
                for(PartnerFundClaim pfc:newClaimMap.values()){
                    if(Core_MDF_Claim_Utility.isClaimEdited(pfc,oldClaimMap)){
                        if(pfc.Core_MDF_Legacy_Claim_Ind__c){
                            Core_MDF_Claim_Prediction__c clmPred = new Core_MDF_Claim_Prediction__c(Core_MDF_Claim_Id__c=pfc.Id,Core_MDF_Claim_Id_External_id__c=pfc.Id);
                            clmPredList.add(clmPred);
                        }
                        else{
                            // for non legacy claims only
                            if(pfc.Core_MDF_PIC_Review_Completed__c){
                                claimMapForClaimPred.put(pfc.Id,newClaimMap.get(pfc.Id));
                            }
                        }
                    }
                }
            }
            
            if(clmPredList.size() > 0){
               upsert clmPredList Core_MDF_Claim_Id_External_id__c; 
            }
            if(claimMapForClaimPred != null){
                InsertToClaimPredictionObj(claimMapForClaimPred);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    } 
    
    
    public static void SendClaimIdToClaimPredictionObj(Map<Id,PartnerFundClaim> newclaimMap){  
        try{
            List<Core_MDF_Claim_Prediction_Event__e > plEventIdLst = new List<Core_MDF_Claim_Prediction_Event__e >();
            for(PartnerFundClaim claim :newclaimMap.values()){
                plEventIdLst.add(new Core_MDF_Claim_Prediction_Event__e(Core_MDF_PE_ID__c = claim.id, Core_MDF_Activity_ID__c= claim.RequestId, Core_MDF_Claim_Id_External_id__c=claim.id));           
            }
            List<Database.SaveResult> results = EventBus.publish(plEventIdLst);  
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        Throw new CustomException(err.getMessage());
                    } 
                }               
            } 
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    } 
   /***************************************************************************************************** 
    Method Name:        bulkTransactionEvent
    @return  :          Core_MDF_Bulk_Transaction__e Platform Event
    @parameters:        CliamsWrapperForLogging and Object Name
    Description:        Method to Capture bulkTransactionEvent
    @Added By:          Accenture 
    @CreatedDate:       07-Sept-2021
    ******************************************************************************************************/ 
    /*public static Core_MDF_Bulk_Transaction__e bulkTransactionEvent(ClaimsWrapperForLogging loggingData, String objName ){
        Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e(); 
        if(loggingData != null && objName != null){
            evtObj.Core_MDF_JSON_Data__c = JSON.serialize(loggingData); 
            evtObj.Core_MDF_Object_Name__c = objName;
        }
        return evtObj;
    }
    //Wrapper class for logging all the values while processing claim
    public class ClaimsWrapperForLogging{        
        String claimId;
        String claimAllocationId;
        String conditionalBlock;
        Decimal claimAllocationAmount;
        Decimal claimAllcationTotalAppFcs;
        Decimal claimAmount;
        Decimal currentAllocRemainingAmount;
        Decimal transferAmount;
        Decimal autoTransferAllocAmount;
        Decimal autoTransferAllocremainAmount;
        //List<PartnerFundClaim> associatedClaims = new List<PartnerFundClaim>();
        
    }
    public static ClaimsWrapperForLogging claimWrapObjForLogging(PartnerFundClaim claim,                                                    
                                                    Decimal currentAllocationRemainingAmount,
                                                    Decimal transferAmount,
                                                    Decimal autoTransferAllocAmount,
                                                    Decimal autoTransferAllocationremainingAmount,
                                                    String condMsg){
        ClaimsWrapperForLogging clsWrap = new ClaimsWrapperForLogging(); 
        clsWrap.claimId = claim.id;                     
        clsWrap.claimAllocationId = claim.AllocationId;
        clsWrap.conditionalBlock = condMsg;
        clsWrap.claimAllocationAmount = claim.Allocation.Amount;
        clsWrap.claimAllcationTotalAppFcs = claim.Allocation.TotalApprovedFcs;
        //clsWrap.associatedClaims.add(claim);   
        clsWrap.claimAmount = claim.Amount;
        clsWrap.currentAllocRemainingAmount = currentAllocationRemainingAmount;
        clsWrap.transferAmount = transferAmount;
        clsWrap.autoTransferAllocAmount = autoTransferAllocAmount;
        clsWrap.autoTransferAllocremainAmount = autoTransferAllocationremainingAmount;                                             
        return clsWrap;
    }*/
}