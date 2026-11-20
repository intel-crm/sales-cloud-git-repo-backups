/******************************************************************************************************
* Class Name  : Core_MDF_PFC_Budget_CAP_Validations 
* TestClass   : Core_MDF_PFC_CampaignCAP_Test
* Version     : 1.0 
* Created Date: 16-Nov-2020
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Intel - Areefa      16-Nov-2020   check the Claim Amount Against the campaign CAP Amount    
*******************************************************************************************************/

public with sharing class Core_MDF_PFC_Budget_CAP_Validations {


/****************************************************************************************************** 
Method Name:        checkClaimAmtAgainstCampaignCAPtAmt
@return  :          NA
@parameters:        List of input claims
Description:        This method is used to check the Claim Amount Against the campaign CAP Amount
Added By:           Intel - Sridhar  - 16-Nov-2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/
public static void checkClaimAmtAgainstCampaignCAPtAmt(List<PartnerFundClaim> inputClaims)
{

    Set<String> programsForCmpgnBudgetAmtCheck = new Set<String>();
    // crate a list of pfrids to query the campaign ids
    //List<Id> pfrIDs = new List<Id>();

    //To check if the Activity Budget Amount Check is Required for a given Program
    for(Core_MDF_ChannelProgram__mdt program : [Select Label from Core_MDF_ChannelProgram__mdt
                                                where Core_MDF_Cmpgn_CAP_Validation_Required__c= true])
    {
        programsForCmpgnBudgetAmtCheck.add(program.Label);
    }
    List<PartnerFundClaim> listOfClaimsToBeProcessed = new List<PartnerFundClaim>();
    
    for(PartnerFundClaim pfc : inputClaims)
    {
        if(programsForCmpgnBudgetAmtCheck.contains(pfc.Core_MDF_Program__c) && pfc.Core_MDF_Type_Txt__c.equals(Label.Core_MDF_Claim_Type))
        {
            listOfClaimsToBeProcessed.add(pfc); 
            //pfrIDs.add(pfc.RequestId); // Add list of PFR ids to query the list of campaign ids later
        }
    }
    
    if(listOfClaimsToBeProcessed!= null && listOfClaimsToBeProcessed.size() > 0)
    { 
        //Label.Core_MDF_InactiveStatusForClaim = 'Cancelled;Denied;Adjusted'
        List<String> claimStatusToBeExcluded = Label.Core_MDF_InactiveStatusForClaim.split(';');
        //Map to store the Campaign as key and list of its new claims to be inserted
        Map<Id, List<PartnerFundClaim>> mapNewClaimwithCmpgn = new Map<Id,List<PartnerFundClaim>>();
        
        // // // Query all the PFR records to get to know the campaign IDs Map<pfrId,CampaignId>
        // // Map<Id,Id> pfrIdCmpgnId = new Map<Id,Id> ();

        // // for (PartnerFundRequest pfr : [select Id, CampaignId from PartnerFundRequest where id IN: pfrIDs]){
        // //     pfrIdCmpgnId.put(pfr.Id, pfr.CampaignId);
        // // }

        for(PartnerFundClaim pfc : listOfClaimsToBeProcessed)
        {
            //Id cmpgnRecId = pfrIdCmpgnId.get(pfc.RequestId);
            Id cmpgnRecId = pfc.Core_MDF_Campaign_Id__c;
            if(mapNewClaimwithCmpgn.containsKey(cmpgnRecId)){
                mapNewClaimwithCmpgn.get(cmpgnRecId).add(pfc);
            }
            else{
                mapNewClaimwithCmpgn.put(cmpgnRecId, new List<PartnerFundClaim>{pfc});
            }
        }

        //Map to store the Campaign as key and its Available CAP Amount.
        Map<Id,Decimal> mapofCmpgnwithAvailableCAP = new Map<Id,Decimal>();
        
        for(campaign  cmpgn : [select id,Core_MDF_Program__c, Core_MDF_Spending_Cap_Amt__c from Campaign where Id IN : mapNewClaimwithCmpgn.keySet() and Core_MDF_Spending_Cap_Amt__c != null])
        {
            mapofCmpgnwithAvailableCAP.put(cmpgn.Id, cmpgn.Core_MDF_Spending_Cap_Amt__c);
        }

        // Stop processing the claims if there is no campaign with spending cap limits set
        if (mapofCmpgnwithAvailableCAP.size()<0){
            return ;
        }

        //Aggregate result to the Sum of Claims Amount for a list of given campaign
        List<AggregateResult> sumofClaimsAmount = [SELECT Core_MDF_Campaign_Id__c, SUM(Amount) claimedAmt, 
                                                    MAX(Core_MDF_Campaign_Id__r.Core_MDF_Spending_Cap_Amt__c) campaignCAPAmount, 
                                                    MAX(Core_MDF_Campaign_Id__r.Core_MDF_Program__c) Program 
                                                    from PartnerFundClaim 
                                                    WHERE Core_MDF_Campaign_Id__c  IN :mapofCmpgnwithAvailableCAP.keySet()
                                                    AND Core_MDF_Status__c <> :claimStatusToBeExcluded 
                                                    AND Core_MDF_Type_Txt__c = :Label.Core_MDF_Claim_Type 
                                                    AND Id Not IN :inputClaims
                                                    GROUP BY Core_MDF_Campaign_Id__c];

                                                       
        //To Obtain the Available Amount by decducting the sum of the claims Amount from the campaign CAP Amount
        if(sumofClaimsAmount!= null && sumofClaimsAmount.size() > 0){ 
            for(AggregateResult agg:sumofClaimsAmount){ 
                Decimal campaignCAPAmount =(Decimal)agg.get('campaignCAPAmount'); 
                Decimal claimedAmt=(decimal)agg.get('claimedAmt'); 

                mapofCmpgnwithAvailableCAP.put((id)agg.get('Core_MDF_Campaign_Id__c'), campaignCAPAmount - claimedAmt);
            } 
        }
        //Loop throw the Incoming Claims List to check their Amount lies within the corresponding Campaign's CAP Amount
        for(Id CmpgnId : mapofCmpgnwithAvailableCAP.keySet())
        { 
            //get the list of claims for a given campaign from the list of incoming claims 
            List<PartnerFundClaim> claimLst = mapNewClaimwithCmpgn.get(CmpgnId);
            for(PartnerFundClaim pfc : claimLst)
            {
                //Id cmpgnRecId = pfrIdCmpgnId.get(pfc.RequestId);
                Id cmpgnRecId = pfc.Core_MDF_Campaign_Id__c;
                //Get the corresponding Campaigns available Budget Amount


                if (mapofCmpgnwithAvailableCAP.get(cmpgnRecId) != null){
                    Decimal availableAmount = mapofCmpgnwithAvailableCAP.get(cmpgnRecId);

                    if(pfc.Amount > availableAmount)
                    {
                        //Add error if claims amount is more than the activity's available amount
                        pfc.addError(Label.Core_MDF_CampaignCAPAmount_wrt_ClaimAmount_ErrMsg);
                    }
                    else
                    {
                        //If claim amount is lesser than or equal to the campaigns available amount,process it by deducting claim amount from the available amount
                        mapofCmpgnwithAvailableCAP.put(pfc.Core_MDF_Campaign_Id__c, availableAmount - pfc.Amount);
                    }
                }
                
            }
            
        }

    }
    
}  

}