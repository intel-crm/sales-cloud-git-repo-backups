public class Sarah_testclass_claimActBudget {
    
    public static void checkBudgetSum(List<PartnerFundClaim> inputClaims)
    {
        List<String> claimStatusToBeIncluded = Label.Core_MDF_Claim_Status_For_Account_Inactive.split(';');
        System.debug('claimStatusToBeIncluded:'+claimStatusToBeIncluded);
        //Map to store the Activity as key and list of its new claims to be inserted
        Map<Id, List<PartnerFundClaim>> mapNewClaimwithAct = new Map<Id,List<PartnerFundClaim>>();
        for(PartnerFundClaim pfc : inputClaims)
        {
            if(mapNewClaimwithAct.containsKey(pfc.RequestId)){
                mapNewClaimwithAct.get(pfc.RequestId).add(pfc);
            }
            else{
                mapNewClaimwithAct.put(pfc.RequestId, new List<PartnerFundClaim>{pfc});
            }
        }
        //Map to store the Activity as key and its Requested Budget Amount.
        Map<Id,Decimal> mapofActwithBudget = new Map<Id,Decimal>();
        //Map to store the Activity as key and sum of its Claims Amount.
        Map<Id, Decimal> mapActwithSumofClaimAmt = new Map<Id,Decimal>();
        List<PartnerFundRequest> pfrList = [Select Id, RequestedAmount from PartnerFundRequest where Id IN : mapNewClaimwithAct.keySet()];
        for(PartnerFundRequest pfr : pfrList)
        {
            mapActwithSumofClaimAmt.put(pfr.Id,0); 
            mapofActwithBudget.put(pfr.Id, pfr.RequestedAmount);
        }
        List<PartnerFundClaim> existingClaimList = [Select Id, Amount, Request.RequestedAmount from PartnerFundClaim where RequestId IN :mapNewClaimwithAct.keySet()
                                                    AND Core_MDF_Status__c IN: claimStatusToBeIncluded AND Core_MDF_Type_Txt__c = :Label.Core_MDF_Claim_Type];
        //Map to store the Activity as key and list of its existing claims
        Map<Id, List<PartnerFundClaim>> mapExistingClaimwithAct = new Map<Id,List<PartnerFundClaim>>();
       
       if(existingClaimList != null && existingClaimList.size()>0)
       {
            for(PartnerFundClaim pfc : existingClaimList)
            {
                if(mapExistingClaimwithAct.containsKey(pfc.RequestId)){
                    mapExistingClaimwithAct.get(pfc.RequestId).add(pfc);
                }
                else{
                    mapExistingClaimwithAct.put(pfc.RequestId, new List<PartnerFundClaim>{pfc});
                }
            }            
            for(Id reqId : mapExistingClaimwithAct.keySet())
            {
                Decimal sumOfClaimAmount = 0.00;
                List<PartnerFundClaim> claimLst = mapExistingClaimwithAct.get(reqId);
                for(PartnerFundClaim pfc : claimLst)
                {
                    sumOfClaimAmount = sumOfClaimAmount+pfc.Amount;
                }
                mapActwithSumofClaimAmt.put(reqId, sumOfClaimAmount);
                
            }
        }
        
        List<PartnerFundClaim> listOfClaimsToBeProcessed = new List<PartnerFundClaim>();
        List<PartnerFundClaim> listOfClaimsToBeErrored = new List<PartnerFundClaim>();
        for(Id reqId : mapNewClaimwithAct.keySet())
        {
            Decimal sumOfClaimAmount2 = 0.00;
            Decimal requestedAmount;
            List<PartnerFundClaim> claimLst = mapNewClaimwithAct.get(reqId);
            requestedAmount = mapofActwithBudget.get(reqId);
            sumOfClaimAmount2 = mapActwithSumofClaimAmt.get(reqId);
            for(PartnerFundClaim pfc : claimLst)
            {
                System.debug('sumOfClaimAmount2 - 0 ' +sumOfClaimAmount2);
                System.debug('requestedAmount ' + requestedAmount);
                sumOfClaimAmount2 = sumOfClaimAmount2 + pfc.Amount;
                System.debug('pfc.Amount ' +pfc.Amount);
                System.debug('sumOfClaimAmount2 - 1 ' +sumOfClaimAmount2);
                if(sumOfClaimAmount2 <= requestedAmount)
                {
                    system.debug('inside if');
                    listOfClaimsToBeProcessed.add(pfc); 
                    System.debug('pfc:'+pfc);
                }
                else if(sumOfClaimAmount2 > requestedAmount)
                {
                    system.debug('inside else if');
                    listOfClaimsToBeErrored.add(pfc);
                }
               // System.debug('listOfClaimsToBeProcessed:'+listOfClaimsToBeProcessed);
                
            }
            
        }
        for(PartnerFundClaim pfc : listOfClaimsToBeErrored)
        {
            System.debug('Error Claim:'+pfc);
            pfc.addError('Insufficient funds');
            pfc.Core_MDF_Claim_Comments__c = 'Insufficient funds';
        }
        System.debug('listOfClaimsToBeErrored:'+listOfClaimsToBeErrored);
    }   
    
}