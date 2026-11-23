/***********************************************************************************************************************************
* Class Name  : Core_MDF_ClaimRecovery_ServiceHandler 
* Version     : 1.0    
* Created Date: 06-02-2022
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - Nirmala      06/02/2022      This class Updates amount and Status of Claims whenever related claim Recovery is inserted
*************************************************************************************************************************************/
public without sharing class Core_MDF_ClaimRecovery_ServiceHandler {
    // Map of claim id to recovery object
    
    //list to store claim statuses to process(i.e Pending available funds,Payment Due and Hold)
  //Public static List<String> statusesAllowedForRecovery=new List<String> {'Pending Available Fund', 'Payment Due'};
    Public static List<String> statusesAllowedForRecovery= Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_allowed_for_Recovery');
    Public static String claimType=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Type');
    Public static String statusError=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_Status_Error');
    Public static String amountError=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_Amount_Error');
    
    /*****************************************************************************************************
Method Name:        validateClmAmtOnClmRecoveryIns
@return  :          void
@parameters:        claimRecoveryList
Description:        validate the claim recovery amount and claim amount before inserting Claim Recovery records
Added By:           Accenture - Nirmala - 06/02/2022
Modified By:        Date:       Changes:
******************************************************************************************************/  
    
    public static void validateClmAmtOrStatusOnClmRecoveryIns(List<Core_MDF_Recovery__c> claimRecoveryList){
       Map<ID,List<Core_MDF_Recovery__c>> clmIdToClmRecovery=new Map<ID,List<Core_MDF_Recovery__c>>();
        if(!claimRecoveryList.isEmpty()){
            for(Core_MDF_Recovery__c clmRecoveryRec:claimRecoveryList){
                if(!clmIdToClmRecovery.containsKey(clmRecoveryRec.Core_MDF_Claim_Id__c)){
                    clmIdToClmRecovery.put(clmRecoveryRec.Core_MDF_Claim_Id__c,new List<Core_MDF_Recovery__c>());
                }
                clmIdToClmRecovery.get(clmRecoveryRec.Core_MDF_Claim_Id__c).add(clmRecoveryRec);
            }
        }
        // system.debug('Claimids'+claimIds);
        if(!clmIdToClmRecovery.isEmpty()){
            //Map of claims to process for amount and status update
            Map<Id,PartnerFundClaim> mapOfClaims=new Map<Id,PartnerFundClaim> ([SELECT Id,Amount,Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Total_Claim_Recovery_Amount__c from PartnerFundClaim where Id IN :clmIdToClmRecovery.KeySet() AND Core_MDF_Type_Txt__c=:claimType AND Core_MDF_Status__c IN: statusesAllowedForRecovery]);
            
            if(!mapOfClaims.isEmpty()){
               for(PartnerFundClaim claim:mapOfClaims.values()){
                    if(claim.Amount!=Null && claim.Amount>0 && clmIdToClmRecovery.containsKey(claim.id)){
                        Decimal clmReducedAmt=claim.Amount;
                         for(Core_MDF_Recovery__c recovery:clmIdToClmRecovery.get(claim.id)){
                            if(recovery.Core_MDF_Amount_Amt__c>clmReducedAmt){
                                recovery.addError(amountError);
                                }
                            else{
                                clmReducedAmt -= recovery.Core_MDF_Amount_Amt__c;
                            }
                        }
                        
                    }
                }
            }
            for(Core_MDF_Recovery__c clmRecoveryRec:claimRecoveryList){
                //throw error when claim status is not Pending Available fund/Payment Due or claim is Adjustment claim
                if(!mapOfClaims.Keyset().Contains(clmRecoveryRec.Core_MDF_Claim_Id__c)){
                    clmRecoveryRec.addError(statusError);
                }
            }
            
        }
    }
    /*****************************************************************************************************
Method Name:        updateClmAmtOnClaimRecoveryIns
@return  :          void
@parameters:        claimRecoveryList
Description:        update the claim amount based on claim recovery amount while after inserting Claim Recovery record
Added By:           Accenture - Nirmala - 06/02/2022
Modified By:        Date:       Changes:
******************************************************************************************************/  
    
    public static void updateClmAmtOnClaimRecoveryIns(List<Core_MDF_Recovery__c> claimRecoveryList){
        Map<ID,List<Core_MDF_Recovery__c>> clmIdToClmRecovery=new Map<ID,List<Core_MDF_Recovery__c>>();
        //list to store the updated claims
        List<PartnerFundClaim> updatedClaimList=new List<PartnerFundClaim>();
        //map to store the claims for Fundreservation
        Map<Id,PartnerFundClaim> mapOfPartnerFundClaim = new Map<Id,PartnerFundClaim>();
        try{
            if(!claimRecoveryList.isEmpty()){
                for(Core_MDF_Recovery__c clmRecoveryRec:claimRecoveryList){
                    if(!clmIdToClmRecovery.containsKey(clmRecoveryRec.Core_MDF_Claim_Id__c)){
                        clmIdToClmRecovery.put(clmRecoveryRec.Core_MDF_Claim_Id__c,new List<Core_MDF_Recovery__c>());
                    }
                    clmIdToClmRecovery.get(clmRecoveryRec.Core_MDF_Claim_Id__c).add(clmRecoveryRec);
                }
                }
            if(!clmIdToClmRecovery.isEmpty() && clmIdToClmRecovery.size()>0){
               Map<Id,PartnerFundClaim> mapOfUpdatedClaims=new Map<Id,PartnerFundClaim>();
                List<PartnerFundClaim> updatedClaimsList=new List<PartnerFundClaim>();
                //Map of claims to process for amount and status update
                Map<Id,PartnerFundClaim> mapOfClaims=new Map<Id,PartnerFundClaim> ([SELECT Id,Amount,Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Total_Claim_Recovery_Amount__c from PartnerFundClaim where Id IN :clmIdToClmRecovery.KeySet() AND Core_MDF_Type_Txt__c=:claimType AND Core_MDF_Status__c IN: statusesAllowedForRecovery]);
                if(!mapOfClaims.isEmpty()){
                    for(PartnerFundClaim claim:mapOfClaims.values()){
                        //checking if claim amount is greater that recovery amount,reducing recovery amount from claim amount
                        if(claim.Amount!=Null && claim.Amount>0 && clmIdToClmRecovery.containsKey(claim.id)){
                           // Decimal clmReducedAmt=claim.Amount;
                            
                            for(Core_MDF_Recovery__c recovery:clmIdToClmRecovery.get(claim.id)){
                                
                                if(claim.Amount>=recovery.Core_MDF_Amount_Amt__c){
                                    claim.Amount =(claim.Amount - recovery.Core_MDF_Amount_Amt__c);
                                    system.debug('**inside**'+claim.Amount);
                                    //system.debug('**inside1**'+claim.Core_MDF_Status__c);
                                    if(claim.Amount==0){
                                        claim.Core_MDF_Status__c=Label.Core_MDF_Status_Paid;
                                       }
                                }
                                
                            }
                           updatedClaimsList.add(claim); 
                        }
                        
                    }
                    system.debug('list'+updatedClaimsList);
                    if(!updatedClaimsList.isempty()){
                        update updatedClaimsList;
                        
                    }
                    
                }
                
            }
        }Catch(Exception e){system.debug(e.getMessage());}
    }
    
}