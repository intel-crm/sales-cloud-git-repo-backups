/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Claim_Clone 
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

public without sharing class Core_MDF_ProcessCCP_Claim_Clone { 
    
    public static Boolean recursiveCheckStop = false;
    // Temporary Variables Initialization
    public static Decimal currentAllocationRemainingAmount = 0;
    public static Decimal autoTransferAllocationremainingAmount = 0;
    public static Decimal transferAmount = 0;
    
    /**
      * @description : This method is used for checking and releasing the funds on Claim Insertion and Updation
                       the method will not commit the changes to the database, for committing, explicit DML to be done
      * @param originalClaimsTobeProcessed : List of Claims Inserted / Updated
      */
    public static void fundReservation(Map<ID,PartnerFundClaim> originalClaimsTobeProcessed){
        
        try {
            // checking the recurdsiveCheckStop to TRUE to avoid recursion
            recursiveCheckStop = true;
            
            //Record Type Info Map
            Map<String,Schema.RecordTypeInfo> claimRecordTypeMap = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName();
            
            // Assign set of CoMarketing Record Types for Claims
            Set<Id> recordTypeSet = Core_MDF_Claim_Utility_Clone.getRecordTypeSet(claimRecordTypeMap);
            // Get the claimReservationStatus to be checked for Claim Reservation Process
            Set<String> claimReservationStatusSet = new Set<String>();
            String claimReservationStatusList = System.label.Core_MDF_ClaimReservationCheckStatus;
            if(!String.IsBlank(claimReservationStatusList)){
                for(String claimStatus : claimReservationStatusList.split(';')){
                    claimReservationStatusSet.add(claimStatus);
                }
            }
            // modifying the incoming claim list to add the related fields like Allocation.Amount, ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c etc
            // and ordering the list according to the Creation Date of the Claims    
            Map<ID,PartnerFundClaim> claimsTobeProcessed = new Map<ID,PartnerFundClaim>([SELECT Id, Amount, AllocationId, Allocation.Amount, Allocation.TotalApprovedFcs,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,
                                                                                         Core_MDF_Claim_Previous_Status__c,ChannelPartnerId,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,Request.ChannelPartnerId,
                                                                                         Allocation.Core_MDF_Available_Allocation_Amount__c,Core_MDF_Status__c,CreatedDate,BudgetId,Status
                                                                                         FROM PartnerFundClaim  
                                                                                         WHERE ID IN:originalClaimsTobeProcessed.values() AND (RecordTypeId IN:recordTypeSet) 
                                                                                         AND Core_MDF_Status__c IN:claimReservationStatusSet ORDER BY CreatedDate]);
            // Create Map<ClaimId, currentAllocationNodeId>
            Map<Id,Id> claimIdToAutoTransferNodeId = new Map<Id,Id>();
            
            // Create Map<ClaimId, currentAllocationBudgetId>
            Map<Id,Id> claimIdTocurrentAllocationBudgetId = new Map<Id,Id>();
            
            // Create Map<AllocationId, currentAllocationNodeId>
            Map<PartnerFundAllocation,Id> allocationIdToNodeMap = new Map<PartnerFundAllocation,Id>();
            
            // Create Map<ClaimId, AutoTransferAllocation>
            Map<Id,PartnerFundAllocation> claimIdToAutoTransferAllocationMap = new Map<Id,PartnerFundAllocation>();
            
            // Create the List of Claims according to their Account Node
            List<List<PartnerFundClaim>> claimListGroupedByAccountNode = new List<List<PartnerFundClaim>>();
            
            //List of budgetTransferWrapper objects to be sent to TransferAllocation Method
            List<Core_MDF_BudgetTransferWrapper> budgetTransferWrapperList = new List<Core_MDF_BudgetTransferWrapper>();            
            
            //List of fundAllocationWrapper objects to be sent to TransferAllocation Method
            List<PartnerFundClaim> autoTransferedClaimList = new List<PartnerFundClaim>();
            
            //List of MainWrapperToBeProcessed Class:
            List<MainWrapperToBeProcessed> mainWrapperList =  new List<MainWrapperToBeProcessed>();
            
            // Create the Set of AccountIds associated with the Claims to be processed
            Set<ID> accountNodeSet = new Set<ID>();
            
            for(PartnerFundClaim pfc : claimsTobeProcessed.values()){
                accountNodeSet.add(pfc.ChannelPartnerId);
            }
            
            // Get all the Claims, Account-Node of which supports Auto Transfer
            for(PartnerFundClaim pfc : claimsTobeProcessed.values()){
                
                if(pfc.ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c){
                    claimIdToAutoTransferNodeId.put(pfc.Id,pfc.ChannelPartner.Core_MDF_Auto_Transfer_Account__c);
                    claimIdTocurrentAllocationBudgetId.put(pfc.Id,pfc.BudgetId);
                }
            }
            
            if(claimIdToAutoTransferNodeId != NULL && claimIdToAutoTransferNodeId.size() > 0)
            {   
                for(PartnerFundAllocation pfa : [SELECT Id, Amount, BudgetId, ChannelPartnerId, TotalApprovedFcs FROM PartnerFundAllocation 
                                                 WHERE ChannelPartnerId IN: claimIdToAutoTransferNodeId.values() 
                                                 AND BudgetId IN: claimIdTocurrentAllocationBudgetId.values()]){
                                                     
                                                     allocationIdToNodeMap.put(pfa,pfa.ChannelPartnerId);
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
            for(ID acc : accountNodeSet)
            {   
                MainWrapperToBeProcessed mainWrapperInstance =  new MainWrapperToBeProcessed();
                
                for(PartnerFundClaim claim : claimsTobeProcessed.values())
                {   
                    if(claim.ChannelPartnerId == acc){
                        
                        mainWrapperInstance.accNodeOfClaim = acc;
                        mainWrapperInstance.associatedClaims.add(claim);
                        mainWrapperInstance.currentAllocationAmount = (claim.Allocation.Amount - claim.Allocation.TotalApprovedFcs);
                        
                    }
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
                        originalClaimsTobeProcessed.get(claim.ID).Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
                        
                        currentAllocationRemainingAmount = (currentAllocationRemainingAmount - claim.Amount) < 0 ? 0 : (currentAllocationRemainingAmount - claim.Amount);
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
                                                                                            autoTransferAllocation.BudgetId,transferAmount, Label.Core_MDF_Budget_Transfer_Type_Auto));
                                    
                                    originalClaimsTobeProcessed.get(claim.ID).Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
                                    autoTransferedClaimList.add(claim);
                                    
                                    currentAllocationRemainingAmount = 0;
                                    // we cannot use the below field as its formula, going with the field update of the fields used in formula
                                    //autoTransferAllocation.Core_MDF_Available_Allocation_Amount__c -= transferAmount
                                    // The below change in Amount ensures that the Reference to the Allocation --> Amount in the Map is changed, not the value
                                    autoTransferAllocation.Amount = (autoTransferAllocation.Amount - transferAmount ) < 0 ? 0 : (autoTransferAllocation.Amount - transferAmount );

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
        List<partnerFundClaim> cancelledORHoldPFCList = new List<partnerFundClaim> ();
        for(partnerFundClaim pfcRecord: claimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(pfcRecord, Label.Core_MDF_Claim_Adjustment_Type))
            {continue;}
            if((oldClaimMap.get(pfcRecord.Id).Status!=Label.Core_MDF_Status_Rejected  && pfcRecord.Status == Label.Core_MDF_Status_Rejected) 
               || (oldClaimMap.get(pfcRecord.Id).Core_MDF_Status__c !=Label.Core_MDF_Status_Hold && pfcRecord.Core_MDF_Status__c == Label.Core_MDF_Status_Hold)
               || (oldClaimMap.get(pfcRecord.Id).Core_MDF_Status__c !=Label.Core_MDF_Status_Denied && pfcRecord.Core_MDF_Status__c == Label.Core_MDF_Status_Denied)
               || (oldClaimMap.get(pfcRecord.Id).Core_MDF_Status__c !=Label.Core_MDF_Status_Adjusted && pfcRecord.Core_MDF_Status__c == Label.Core_MDF_Status_Adjusted))
            {
                cancelledORHoldPFCList.add(pfcRecord);
            }  
            
        }
        if(!cancelledORHoldPFCList.isEmpty() && cancelledORHoldPFCList.size()>0)
        {
            //Core_MDF_Process_PAF_Claim.fetchAccountIdsbyCancelledClaims(cancelledORHoldPFCList); 
        } 
    }

    /**
      * @description : Method to check the claim's liability for Fund Reservation and thereby calling it if eligible
      * @param newclaimMap : Map containing the claimId as key and new claims (updated) as value
      * @param oldClaimMap : Map containing the claimId as key and claims (not updated) as value
      */
    public static void fundReservationCheckOnUpdate(Map<Id,PartnerFundClaim> newclaimMap,Map<Id,PartnerFundClaim> oldClaimMap){
        
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_MDF_PFCServiceHandler.mapFunctionalityNameTriggerExecution;
        // flag saying whether the Audit functionality is ON or OFF
        Boolean isAuditRequired = (mapFunctionalityNameTriggerExecution.containsKey('checkAndSendClaimsToAudit') 
                                  && mapFunctionalityNameTriggerExecution.get('checkAndSendClaimsToAudit').Core_Active__c)
                                  ? true : false;
        
        // Map containing the claims to be sent for Fund Reservation
        Map<Id,PartnerFundClaim> claimsToBeReserved = new Map<Id,PartnerFundClaim>();

        for(PartnerFundClaim pfc : newclaimMap.values()){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility_Clone.isType(pfc, Label.Core_MDF_Claim_Adjustment_Type)){continue;}
            if(!recursiveCheckStop && oldClaimMap != null && isClaimEligible(pfc,oldClaimMap.get(pfc.Id),isAuditRequired)){
                PartnerFundClaim newpfc = new PartnerFundClaim();
                newpfc.Id = pfc.Id;
                claimsToBeReserved.put(newpfc.Id,newpfc);
            }
            else{
                if(!recursiveCheckStop && oldClaimMap == null && isClaimEligible(pfc,null,isAuditRequired)){
                    PartnerFundClaim newpfc = new PartnerFundClaim();
                    newpfc.Id = pfc.Id;
                    claimsToBeReserved.put(newpfc.Id,newpfc);
                }
            }    
        }
        if(claimsToBeReserved != null && claimsToBeReserved.size()>0){
            fundReservation(claimsToBeReserved); 
            system.debug('claimsToBeReserved.values()::'+claimsToBeReserved.values());
            Database.update(claimsToBeReserved.values());
        }
    }

    /**
      * @description : Method to check the claim's liability for Fund Reservation and thereby calling it if eligible
      * @param newclaim : new claims (updated) 
      * @param oldClaim : claims (not updated) 
      */
    public static Boolean isClaimEligible(PartnerFundClaim newclaim,PartnerFundClaim oldClaim, Boolean isAuditRequired){
        // if AuditInProgress is True; Don't Process the Claim for Fund Reservation
        if(newclaim != null && newclaim.Core_MDF_AuditSelectionInProgress__c == true){
            return false;
        }
        else{
            // if Audit is ON
            if(isAuditRequired && oldClaim != null){
                // if method called from Service Handler if Audit selection is turned off or in case of Release Hold 
                //  
                if(oldClaim !=null && (
                    (newclaim.Core_MDF_AuditSelectionInProgress__c == false && oldClaim.Core_MDF_AuditSelectionInProgress__c == true) || (newclaim.Core_MDF_Audit_Hold__c == false && oldClaim.Core_MDF_Audit_Hold__c == true) 
                    || (newclaim.Core_MDF_ESD_Hold__c == false && oldClaim.Core_MDF_ESD_Hold__c == true) || (newclaim.Core_MDF_Payment_Hold_ind__c == false && oldClaim.Core_MDF_Payment_Hold_ind__c == true)||(newclaim.Core_MDF_Member_Manual_Hold_Ind__c == false && oldClaim.Core_MDF_Member_Manual_Hold_Ind__c == true) 
                    || (newclaim.Core_MDF_Intel_Manual_Hold_Ind__c == false && oldClaim.Core_MDF_Intel_Manual_Hold_Ind__c == true)||(newclaim.Core_MDF_Criteria_Hold_Ind__c == false && oldClaim.Core_MDF_Criteria_Hold_Ind__c == true)||(newclaim.Core_MDF_Audit_Adjustment_Amount__c != oldClaim.Core_MDF_Audit_Adjustment_Amount__c)
                    || newclaim.Core_MDF_To_Be_Audited_Ind__c
                )
                   && (newclaim.Core_MDF_Status__c == Label.Core_MDF_Status_Submitted || newclaim.Core_MDF_Status__c == Label.Core_MDF_Status_Pending_Available_Fund)){
                        return true;
                }else{return false;}
            }else{
                // if Audit OFF / ON and if method is called from Cancelled Claim / Update Allocation Method
                if(newclaim.Core_MDF_Status__c == Label.Core_MDF_Status_Submitted || newclaim.Core_MDF_Status__c == Label.Core_MDF_Status_Pending_Available_Fund){
                            return true;
                }else{return false;}
            }
        }
    }
    /**
      * @description : Method to check the claim's liability for Fund Reservation and thereby calling it if eligible
      * @param newclaimMap : Map containing the claimId as key and new claims (updated) as value
      */
    public static void fundReservationCheckOnInsert(Map<Id,PartnerFundClaim> newclaimMap){
        // Map containing the claims to be sent for Fund Reservation
       
        Map<Id,PartnerFundClaim> claimsToBeReserved = new Map<Id,PartnerFundClaim>();
        for(PartnerFundClaim pfc : newclaimMap.values()){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(pfc, Label.Core_MDF_Claim_Adjustment_Type))
            {continue;}
            if(!recursiveCheckStop && pfc.Core_MDF_AuditSelectionInProgress__c == false 
                                   && (pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Submitted
                                       || pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Pending_Available_Fund
                                       )){
                                           
                                           PartnerFundClaim newpfc = new PartnerFundClaim();
                                           newpfc.Id = pfc.Id;
                                           claimsToBeReserved.put(newpfc.Id,newpfc);
                                       }
        }
        if(claimsToBeReserved != null && claimsToBeReserved.size()>0){
            fundReservation(claimsToBeReserved); 
            Database.update(claimsToBeReserved.values());
        }
         
    }
}