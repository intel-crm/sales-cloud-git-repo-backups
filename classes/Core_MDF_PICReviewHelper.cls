/****************************************************************************************************************************************
* Class Name      : Core_MDF_PICReviewHelper
* Version               : 1.0 
* Created Date          : 01-16-2022
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - BD     01-16-2022        PIC Review Duplicate Handler class. 
*****************************************************************************************************************************************/
public class Core_MDF_PICReviewHelper {
    
    /***************************************************************************************************** 
	Method Name:        claimUpdateOperations
	Description:        Claim Status changes(Legacy/Non Legacy/Post Payment) post PIC Review process
						submission
	@Added By:          Accenture - BD - 01-16-2022
	Modified By:        Date:       Changes: 
	******************************************************************************************************/ 
    public static void claimUpdateOperations(list<Core_MDF_PIC_Review__c> picReviewRecordsToBeProcessed) {
        
        set<ID> claimIDSet = new set<ID>();
        map<ID,ID> claimLastReviewerMap = new map<ID,ID>();
        map<ID,String> claimReviewStatusMap = new map<ID,String>();
        Map<ID,Boolean> claimRecommendForReviewMap = new map<ID,Boolean>();
        Map<ID,String> claiminternalCommentsMap = new map<ID,String>();
        list<PartnerFundClaim> updatedClaimList = new list<PartnerFundClaim>();
        for(Core_MDF_PIC_Review__c picReview : picReviewRecordsToBeProcessed)
        {
            
                claimIDSet.add(picReview.Core_MDF_Claim_ID_id__c);
                claimLastReviewerMap.put(picReview.Core_MDF_Claim_ID_id__c,picReview.Core_MDF_ReviewedBy_id__c);
                claimReviewStatusMap.put(picReview.Core_MDF_Claim_ID_id__c,picReview.Core_MDF_Review_Status_nm__c);
            	claimRecommendForReviewMap.put(picReview.Core_MDF_Claim_ID_id__c,picReview.Core_MDF_Recommend_for_Review_Flag_ind__c);
            	
        }
        
        // Creating map for including internal comments from all PIC Review records related to the claim
        for(Core_MDF_PIC_Review__c picReviewRecord : [select id,Core_MDF_InternalComments_txt__c,Core_MDF_Claim_ID_id__c from Core_MDF_PIC_Review__c where Core_MDF_Claim_ID_id__c in: claimIDSet])
        {
            
            if(claiminternalCommentsMap.containsKey(picReviewRecord.Core_MDF_Claim_ID_id__c))
            {
                String internalComments = claiminternalCommentsMap.get(picReviewRecord.Core_MDF_Claim_ID_id__c) + picReviewRecord.Core_MDF_InternalComments_txt__c + '\n';
            	claiminternalCommentsMap.put(picReviewRecord.Core_MDF_Claim_ID_id__c,internalComments);
            }
            else if(!claiminternalCommentsMap.containsKey(picReviewRecord.Core_MDF_Claim_ID_id__c))
            {
                String internalComments = picReviewRecord.Core_MDF_InternalComments_txt__c + '\n';
                claiminternalCommentsMap.put(picReviewRecord.Core_MDF_Claim_ID_id__c,internalComments);
            }
        		
        }
        
        for(PartnerFundClaim claim : [select id,Core_MDF_Status__c,Core_MDF_Recommend_For_ClaimReview__c,Core_MDF_RecentInternalComments_txt__c,Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c,Core_MDF_Document_Submission_Missed_Ind__c,Core_MDF_Program__c,Core_MDF_Latest_Review_Cycle_Number_nbr__c,Core_MDF_Document_Hold_Ind__c,Core_MDF_Last_Reviewed_By_id__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_PIC_Review_Completed__c from PartnerFundClaim where id in: claimIDSet])
        {
            if(claimLastReviewerMap.containsKey(claim.Id))
            {
              claim.Core_MDF_Last_Reviewed_By_id__c = claimLastReviewerMap.get(claim.Id);  
            }
            
            if(claimRecommendForReviewMap.containsKey(claim.Id))
            {
                claim.Core_MDF_Recommend_For_ClaimReview__c = claimRecommendForReviewMap.get(claim.Id);
            }
            
            if(claiminternalCommentsMap.containsKey(claim.Id))
            {
                claim.Core_MDF_RecentInternalComments_txt__c = claiminternalCommentsMap.get(claim.Id);
            }
            
            
            
            //For PIC Failure Scenario
            if(claimReviewStatusMap.get(claim.Id) == label.Core_MDF_PICReview_Status_Failed)
            {
                
                //  For pre payment PIC Review
                if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_PIC_Pending || claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Payment_Clearance_Processing) //Pic-Pop Changes Anushya
                {
                                        
                    if(Core_MDF_PIC_Utility.isLegacy(claim) == true && (claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c < Integer.valueOf(label.Core_MDF_Review_Cycle_Number) || String.isEmpty(String.valueof(claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c))))
                    {
                        claim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = System.now() +Integer.valueOf(Label.Core_MDF_Document_Submission_Days);
                    }
                    
                    // For pre payment PIC Review for legacy claims when PIC Failed 3 times
                    if(Core_MDF_PIC_Utility.isLegacy(claim) == true && claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c == Integer.valueOf(label.Core_MDF_Review_Cycle_Number ))
                    {
                        claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Denied;
                    }
                }
                // For post payment PIC Review
                if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Paid_and_PIC_Pending)
                {
                  
                    
                    if(Core_MDF_PIC_Utility.isLegacy(claim) == true && (claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c < Integer.valueOf(label.Core_MDF_Review_Cycle_Number) || String.isEmpty(String.valueOf(claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c))))
                    {
                        claim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = System.now() + Integer.valueOf(Label.Core_MDF_Document_Submission_Days);
                    }
                    
                    // For Post payment 
                    if(claim.Core_MDF_Latest_Review_Cycle_Number_nbr__c == Integer.valueOf(label.Core_MDF_Review_Cycle_Number))
                    {
                        claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid;
                        claim.Core_MDF_Document_Submission_Missed_Ind__c = true;
                        claim.Core_MDF_Legacy_Reminder_txt__c = Label.Core_MDF_Legacy_Maximum_Attempts_Reached;//To send the Final Information email after 30 days.
                    }
                }
            }
            
            // For PIC Success scenario
            else if(claimReviewStatusMap.get(claim.Id) == label.Core_MDF_PICReview_Status_Completed)
            {
                // For pre payment PIC Review for both Legacy/Non Legacy
                if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_PIC_Pending || claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Payment_Clearance_Processing) //Pic-Pop Changes Anushya
                {
                    claim.Core_MDF_PIC_Review_Completed__c = true;
                }
                
                
                // For Post Payment PIC Review
                if(claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_Paid_and_PIC_Pending)
                {
                    claim.Core_MDF_PIC_Review_Completed__c = true;
                    claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid;
                }
                
                
                
            }
            
            updatedClaimList.add(claim);
            
        }
            
            try {
                update updatedClaimList;
            }   catch(Exception ex)
            {
                System.debug('Error Occured during Claim updation'+ex.getMessage());
                Core_MDF_CCP_UtilityClass.logError(ex);
                throw new AuraHandledException(ex.getMessage());
            }
            
        
    }
    
}