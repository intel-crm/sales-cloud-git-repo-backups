/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_ManualAudit 
* Version     : 1.0 
* Created Date: 11-20-2018
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         11/20/2018                    This class hold the Utility methods for the Manual Audit Claim Scenario     
*****************************************************************************************************************************************/
public with sharing class Core_MDF_PFC_ManualAudit {
    
    /****************************************************************************************************** 
Method Name:        isInternalAuditUser
@return  :          Boolean
@parameters:        String userId,String permissionName
Description:        This method is used to check the permission set over logged in user
Added By:           Accenture - AD - 11/26/2018
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean isInternalAuditUser(String custPermissionName){
        Boolean isAuditUser = false;
           try {
            Boolean hasCustomPermission = FeatureManagement.checkPermission(custPermissionName);
            if(hasCustomPermission){              
                isAuditUser=true;
            }
            return isAuditUser;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    /***************************************************************************************************** 
Method Name:        isClaimEligibleForManualAudit
@return  :          boolean
@parameters:        claimId
Description:        This is a Method to check whether the Manual Audit button should be visible on a Claim Record
Added By:           Intel - SM - 11/20/2018
Modified By:        Date:       Changes: 
Accenture - JB      01/10/2022  PIC Changes
Accenture - JB      12/14/2022  Post Payment changes
******************************************************************************************************/   
    
    @AuraEnabled
    public static manualAuditWrapper isClaimEligibleForManualAudit(Id claimId){
       	manualAuditWrapper auditWrap = new manualAuditWrapper(); 
        auditWrap.isPICReviewCompleted = false;
        try{
            string message = null;
            boolean claimEligibleForAudit = false;
            //To check if the user has access to set claims for Manual Audit
            if(!isInternalAuditUser(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEditAccessToAuditUser')))//Label.Core_MDF_ClaimEditAccessToAuditUser
            {
                auditWrap.message = Label.Core_MDF_Manual_Audit_Access_Error;
                return auditWrap;
            }
            else
            {
                //Get the status in which Manually Auditing a claim is allowed
                List<string> validStatus =  Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_allowed_for_Manual_Audit');  //Label.Core_MDF_Status_allowed_for_Manual_Audit.split(';');
                //  string userType = UserInfo.getUserId();
                PartnerFundClaim claimObj = [SELECT Id, Core_MDF_PIC_review_completed__c, Core_MDF_Manaul_Audit_Staging_Ind__c, Core_MDF_Type_Txt__c, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c FROM PartnerFundClaim where Id = :claimId];
                //check claim type
                if(Core_MDF_Claim_Utility.isType(claimObj, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type')))
                {
                    auditWrap.isPICReviewCompleted = claimObj.Core_MDF_PIC_review_completed__c;
                    auditWrap.message = Label.Core_MDF_Negative_Claim_Error;
                    return auditWrap;
                }else{
                    //set the claimEligibleForAudit to true only if user has edit access and the status is one of the allowed statuses.
                    if(validStatus.contains(string.valueof(claimObj.Core_MDF_Status__c)))
                    {                   
                        //set the claimEligibleForAudit to false if the claim is on Audit Hold
                        /*if((Label.Core_MDF_Status_Hold.equals(claimObj.Core_MDF_Status__c) && claimObj.Core_MDF_Audit_Hold__c))
                        {
                            claimEligibleForAudit = false;  
                        }*/
                        //set the claimEligibleForAudit to false if the claim is already Audited
                        if(claimObj.Core_MDF_FlaggedForAudit__c)
                        {
                            auditWrap.isPICReviewCompleted = claimObj.Core_MDF_PIC_review_completed__c;
                    		auditWrap.message = Label.Core_MDF_Claim_Reviewed_Previously;
                            return auditWrap;
                        }
                        // Checking if claim is already selected for manual audit when a claim is in Document hold
                        else if(claimObj.Core_MDF_Manaul_Audit_Staging_Ind__c)
                        {
                            auditWrap.isPICReviewCompleted = claimObj.Core_MDF_PIC_review_completed__c;
                    		auditWrap.message = Label.Core_MDF_ClaimIsAlreadyOnManualHoldMsg;
                            return auditWrap;
                        }
                        else
                        {
                            claimEligibleForAudit =  true;
                            auditWrap.isPICReviewCompleted = claimObj.Core_MDF_PIC_review_completed__c;
                    		auditWrap.message = Label.Core_MDF_Success;
                            return auditWrap;
                        }
                    }
                    
                }
                
            }
            //If the claim is not a valid status
            auditWrap.message = Label.Core_MDF_Claim_Cannot_be_set_for_Manual_Audit;
            return auditWrap;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e;}
    }
    
    /***************************************************************************************************** 
Method Name:        assignClaimsForManualAudit
@return  :          string
@parameters:        claimIdList
Description:        This is a Method to be used to Manually Audit a list of claims
Added By:           Intel - SM - 11/20/2018
Modified By:        Date:       Changes: 
Shridhar Accenture  13/08/2019  Added condition to update of claim status for post payment claims
Accenture - JB      01/10/2022  PIC and Legacy Claim Changes
Accenture - JB      12/14/2022  Post Payment changes
******************************************************************************************************/    
    @AuraEnabled
    public static boolean assignClaimsForManualAudit(List<Id> claimIdList){
        //Get the status in which Manually Auditing a claim is allowed. Added this additional check in case the method is called from backend
        List<string> validStatus = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_allowed_for_Manual_Audit');  //Label.Core_MDF_Status_allowed_for_Manual_Audit.split(';');
        String claimStatusPaid = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Paid'); //Paid
        String rowCauseManual = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual');

        Boolean success = true;
        try{
            Map<Id, PartnerFundClaim> claimsMap = new Map<Id, PartnerFundClaim>([SELECT Id, ChannelPartnerId, Core_MDF_PIC_review_completed__c,
                                                                                Core_MDF_Manaul_Audit_Staging_Ind__c, Core_MDF_Status__c, Core_MDF_Claim_Previous_Status__c,
                                                                                Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c, Core_MDF_Program__c,
                                                                                Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Legacy_Claim_Ind__c, Core_MDF_Eligible_for_PIC__c
                                                                                FROM PartnerFundClaim WHERE Id = :claimIdList]);

            List<PartnerFundClaim> claimToBeAudited = new List<PartnerFundClaim>();
            Set<Id> accountIds = new Set<Id>();

            if(!claimsMap.isEmpty()){
                //To check the documents are uploaded for a Claim
                Map<Id,Boolean> claimIdToDocuemntStatusMap = Core_MDF_Audit_Rules_Processing.checkPOPDocuments(new List<Id>(claimsMap.keySet()));

                for(PartnerFundClaim claim : claimsMap.values()){
                    if(validStatus.contains(string.valueof(claim.Core_MDF_Status__c))){

                        //Only for Legacy Claims when PIC Review is not Completed
                        if(!claim.Core_MDF_PIC_review_completed__c  && claim.Core_MDF_Legacy_Claim_Ind__c){
                            //Update Manual Audit Staging flag.
                            //Paid --> After PIC Review completed update the Audit Hold flag - (logic in the Claim trigger)
                            //Pending Payment --> Once status updated to Paid check the documents and update the status('Paid and Pending Documents' or 'Paid and PIC Pending') - (logic in the Claim trigger)
                            claim.Core_MDF_Manaul_Audit_Staging_Ind__c = true;

                            if(claim.Core_MDF_Status__c == claimStatusPaid){
                                if(!claimIdToDocuemntStatusMap.get(claim.Id)){
                                    claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_Pending_Documents;
                                    claim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = System.now() + Integer.valueOf(Label.Core_MDF_Document_Submission_Days);//For Reminder Notifications
                                }else{
                                    claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
                                    claim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = null;
                                }
                            }
                        }

                        //For Non-legacy, update the Audit hold flag.
                        //For Legacy, update Audit hold flag only if it completed the PIC Review
                        if(!claim.Core_MDF_Legacy_Claim_Ind__c || claim.Core_MDF_PIC_review_completed__c){
                            claim.Core_MDF_Audit_Type__c = rowCauseManual; //Label.Core_MDF_Manual_Audit_Type;
                            claim.Core_MDF_FlaggedForAudit__c = true; 
                            claim.Core_MDF_Audit_Hold__c = true;
                        }

                        claim.Core_MDF_Eligible_for_PIC__c = true;
                        claimToBeAudited.add(claim);
                    }
                    
                }
            }

            Database.update(claimToBeAudited);
            
            return success;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           throw e;} 
    } 
    
    /***************************************************************************************
Class Name:         ManualAuditWrapper
Description:        This wrapper class will be used for holding message and Document hold values
Added By: HP        Accenture - 23-07-2021
Modified By:        Date:      Changes: 
****************************************************************************************/
    public class ManualAuditWrapper{
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public Boolean isPICReviewCompleted{get;set;}
    }
}