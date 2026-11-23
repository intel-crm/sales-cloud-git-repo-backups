/****************************************************************************************************************************************
* Class Name      : Core_MDF_PICReviewResultHelper
* Version               : 1.0 
* Created Date          : 12-21-2021
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - BD     12-21-2021        PIC Review Result Duplicate Handler class. 
*****************************************************************************************************************************************/
public class Core_MDF_PICReviewResultHelper {
    
    
   /***************************************************************************************************** 
    Method Name:        claimStatusChangeOnInsert
    Description:        Changes Status of Claim/marks claim as PIC Review Completed on PIC review response
    submission
    @Added By:          Accenture - BD - 12-21-2021
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    /*public static void claimStatusChangeOnInsert(list<core_MDF_PICReviewResult__c> picReviewResultsToBeProcessed){
        
        map<String,list<String>> claimResponseMap = new map<String,list<String>>();
        set<ID> claimIDSet = new set<ID>();
        set<ID> claimReviewCompleteSet = new set<ID>();
        set<ID> claimRevisionRequired = new set<ID>();
        list<PartnerFundClaim> updatedClaimList = new list<PartnerFundClaim>();
        map<ID,double> claimReviewDurationMap = new map<ID,double>();   
        map<ID,ID> claimLastReviewerMap = new map<ID,ID>();
        
        
        for(core_MDF_PICReviewResult__c reviewResult : picReviewResultsToBeProcessed)
        {
            claimIDSet.add(reviewResult.Core_MDF_Claim_ID_id__c);
            //Map which will store the review duration of the latest cycle
            claimReviewDurationMap.put(reviewResult.Core_MDF_Claim_ID_id__c,reviewResult.Core_MDF_Review_Duration_in_Minutes__c);
            //Map to store the reviewer of the claim
            claimLastReviewerMap.put(reviewResult.Core_MDF_Claim_ID_id__c,reviewResult.Core_MDF_ReviewedBy_id__c);
            list<String> reviewResponseList = new list<String>();
            //Creation of map of claim ID as key and list of responses(yes/no) of child review results as value
            if(claimResponseMap.containsKey(reviewResult.Core_MDF_Claim_ID_id__c))
            {
                reviewResponseList = claimResponseMap.get(reviewResult.Core_MDF_Claim_ID_id__c);
                reviewResponseList.add(reviewResult.Core_MDF_Response_txt__c);
            }
            else
            {
                reviewResponseList.add(reviewResult.Core_MDF_Response_txt__c);
                claimResponseMap.put(reviewResult.Core_MDF_Claim_ID_id__c,reviewResponseList);
            }
        }
        
        for(ID claimID : claimResponseMap.keySet())
        {
            list<String> responseList = new list<String>();
            responseList = claimResponseMap.get(claimID);
            // Creation of sets for each Claim ID where at least one response is 'No' and one where all responses are 'Yes'
            if(responseList.contains('No'))
            {
                claimRevisionRequired.add(claimID);
            }
            else if(!responseList.contains('No'))
            {
                claimReviewCompleteSet.add(claimID);
            }
        }
        
        for(PartnerFundClaim claim : [select id,Core_MDF_Status__c,Core_MDF_Document_Hold_Ind__c,Core_MDF_Last_Reviewed_By_id__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where id in: claimIDSet])
        {
            claim.Core_MDF_Last_Reviewed_By_id__c = claimLastReviewerMap.get(claim.id);
            
            
            
            if(claimRevisionRequired.contains(claim.id))
            { 
                if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_PIC_Pending){
                    claim.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Resubmission_Required; //If atleast one response is 'No'
                }
                
                if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Paid_and_PIC_Pending)
                {
                    claim.Core_MDF_Status__c = label.Core_MDF_Claim_Status_Paid_and_Resubmission_Required;
                }
                
                
                
            }
            else if(claimReviewCompleteSet.contains(claim.id) && claim.Core_MDF_PIC_Review_Completed__c == false)
            {
                claim.Core_MDF_PIC_Review_Completed__c = true; //If all responses are 'Yes'
            }
            
            // Marking claim status as 'Denied' after 2 review cycles for legacy claims
            if(claimRevisionRequired.contains(claim.id) && (claim.Core_MDF_Budget_Type_Nm__c == 'CCF 1.0'|| claim.Core_MDF_Budget_Type_Nm__c == 'DCF 1.0'))
            {
                claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Denied;
            }
            
            updatedClaimList.add(claim);
            
            
        }
        
        try {
            update updatedClaimList;
        } catch(Exception ex)
        {
            System.debug('Error Occured during Claim updation'+ex.getMessage());
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }*/
    
}