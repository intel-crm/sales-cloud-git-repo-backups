/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_Cancel 
* Version     : 1.0 
* Created Date: 11-20-2018
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         11/20/2018                    This class hold the Utility methods for the Cancel Claim Scenario  
* Intel - SM         10/13/2020                    Added Vat Information cancellation scenarios 
*****************************************************************************************************************************************/
public with sharing class Core_MDF_PFC_Cancel {

    /***************************************************************************************************** 
Method Name:        isClaimEligibleForCancel
@return  :          CancellationDecision
@parameters:        claimId
Description:        This is a Method to check whether the Cancel button should be visible on a Claim Record
Added By:           Intel - SM - 11/20/2018
Modified By:  Accenture - Krishna Kulkarni      Date:  20-06-2019     Changes: 
Alekhya                                                25-02-2025     Included CSC Claim submitter to restrict the claim cancellation 
******************************************************************************************************/   
    
        @AuraEnabled
        public static CancellationDecision isClaimEligibleForCancel(Id claimId){
            
            try{
                //Check if the logged in user has Edit Permission on the PartnerFundClaim Object
                boolean hasCancelAccess = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CancelClaim'));  //Label.Core_MDF_CancelClaim
                //Get the status in which Cancelling a claim is allowed
                List<string> validStatus = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_allowed_for_Cancel_Claim'); //Label.Core_MDF_Status_allowed_for_Cancel_Claim.split(';');
                string userType = UserInfo.getUserType();
                PartnerFundClaim claimObj = [SELECT Id,Core_MDF_Type_Txt__c, Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_Status__c,Core_MDF_Total_Claim_Recovery_Amount__c, Core_MDF_Audit_Hold__c,Core_MDF_VAT_Hold_Ind__c, Core_MDF_ESD_Hold__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Has_Sub_Claims_Ind__c FROM PartnerFundClaim where Id = :claimId]; 
                
                //getting custom permission value from custom setting
                String pRCRMFClaimOperationCustPerName = Core_MDF_Configuration__c.getValues('PRC_CLAIM_OPERATION_CUSTOM_PERMISSION').Core_MDF_Value__c;  
                String partnerUserType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type');
                Boolean isRMFPRCClaimOperation = FeatureManagement.checkPermission(pRCRMFClaimOperationCustPerName);//added by vaishali to check if user is RMF PRC Internal claim submitter
                String cSCClaimSubmitterCustPerName = Core_MDF_Configuration__c.getValues('CSC_CLAIM_SUBMITTER_CUSTOM_PERMISSION').Core_MDF_Value__c;  //Added by Alekhya
                Boolean isCSCClaimSubmitter = FeatureManagement.checkPermission(cSCClaimSubmitterCustPerName);
                
                return getCancellationDecision(claimObj,claimId,hasCancelAccess,validStatus,userType,partnerUserType,isRMFPRCClaimOperation,isCSCClaimSubmitter);
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
        }
    
    /****************************************************************************************************** 
Class Name:        CancellationDecision
@parameters:        N/A
Description:        Holds cancellation eligibility, restriction, audit and reason decisions
Added By:           Accenture - Krishna Kulkarni - 14/06/2019
Modified By:        Date:      Changes: 
******************************************************************************************************/
    public class CancellationDecision{
        @AuraEnabled
        public Boolean claimEligibleForCancel = false;
        @AuraEnabled
        public Boolean restrictClaimOperator = false;
        @AuraEnabled
        public Boolean claimHasRecovery = false;
        @AuraEnabled
        public Boolean claimSelectedForAudit=false;
        @AuraEnabled
        public Boolean requiresCancellationReason = false;
        @AuraEnabled
        public Boolean isSuperClaimOnHold = false;
    }

    /*****************************************************************************************************
Method Name:        getCancellationDecision
@return  :          CancellationDecision
@parameters:        Claim, claim id, cancel access, valid statuses and user context
Description:        Determines whether a claim can be cancelled and the reason for any restriction
******************************************************************************************************/
    public static CancellationDecision getCancellationDecision(PartnerFundClaim claimObj,Id claimId,Boolean hasCancelAccess,List<String> validStatus,String userType,String partnerUserType,Boolean isRMFPRCClaimOperation,Boolean isCSCClaimSubmitter){
        CancellationDecision decision = new CancellationDecision();
        if(!hasCancelAccess || !validStatus.contains(String.valueOf(claimObj.Core_MDF_Status__c))){
            return decision;
        }
        Set<String> requiresReasonHoldList = new Set<String>{'Core_MDF_Bank_Doc_Hold_Ind__c','Core_MDF_Payment_Hold_ind__c','Core_MDF_ESD_Hold__c'};
        Set<String> blockingHoldList = new Set<String>{'Core_MDF_VAT_Hold_Ind__c','Core_MDF_Intel_Manual_Hold_Ind__c','Core_MDF_Member_Manual_Hold_Ind__c','Core_MDF_Criteria_Hold_Ind__c','Core_MDF_Document_Hold_Ind__c'};
        Boolean isPartnerUser = userType == partnerUserType;
        Boolean hasPrivilegedSubmitterPermission = isRMFPRCClaimOperation || isCSCClaimSubmitter;
        Boolean isAdjustment = Core_MDF_Claim_Utility.isType(claimObj,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type'));
        Boolean claimIsOnHold = claimObj.Core_MDF_Status__c == Label.Core_MDF_Status_Hold;
        Boolean hasSubClaims = claimObj.Core_MDF_Has_Sub_Claims_Ind__c == true;
        List<PartnerFundClaim> claimsToEvaluate = new List<PartnerFundClaim>();
        if(hasSubClaims){
            decision.isSuperClaimOnHold = claimIsOnHold;
            claimsToEvaluate.addAll(
                new cancelClaimInnerClass().getActiveSubClaims(claimId)
            );
            if (hasIrreversibleSubClaim(claimsToEvaluate)) {
                decision.claimEligibleForCancel = false;
                return decision;
            }
        }else{
            claimsToEvaluate.add(claimObj);
        }
        if(isAdjustment){
            List<Core_MDF_Claim_Offset__c> offsetRecordList = [SELECT Id FROM Core_MDF_Claim_Offset__c WHERE Core_MDF_Adjustment_Claim_Nbr__c = :claimId];
            Boolean hasOffset = !offsetRecordList.isEmpty();
            decision.restrictClaimOperator = hasOffset;
            if(!isPartnerUser && !isRMFPRCClaimOperation){
                decision.claimEligibleForCancel = !hasOffset;
            }        
        }else if(isPartnerUser || hasPrivilegedSubmitterPermission){
            if(claimObj.Core_MDF_Audit_Hold__c == true || claimObj.Core_MDF_Claim_Review_Case__c != null){
                decision.claimSelectedForAudit = true;
            }else{
                Boolean requiresReasonHold = claimIsOnHold && hasAnyClaimHold(claimsToEvaluate, requiresReasonHoldList);
                Boolean hasBlockingHold = claimIsOnHold && hasAnyClaimHold(claimsToEvaluate, blockingHoldList);
                if(hasSubClaims && isPartnerUser){
                    Boolean hasParentBlockingHold = claimIsOnHold && hasAnyHold(claimObj, blockingHoldList);
                    hasBlockingHold = hasBlockingHold || (!requiresReasonHold && hasParentBlockingHold);
                }
                decision.requiresCancellationReason = isPartnerUser && requiresReasonHold;
                decision.claimEligibleForCancel = !hasBlockingHold;
            }
        }else if(claimObj.Core_MDF_Claim_Review_Case__c != null
            && claimObj.Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c == Core_MDF_CCP_ConstantClass.REVIEW_COMPLETED){
            decision.claimSelectedForAudit = true;
        }else{
            decision.claimEligibleForCancel = true;
        }

        if(claimObj.Core_MDF_Total_Claim_Recovery_Amount__c > 0){
            decision.claimEligibleForCancel = false;
            decision.claimHasRecovery = true;
        }
        return decision;
    }    
    
    /***************************************************************************************************** 
Method Name:        hasAnyClaimHold
@return  :          boolean
@parameters:        claims (sub-claims), Set of Hold
Description:        checks if any of the claims is on any of the hold
Added By:           HP - 10/21/2026
******************************************************************************************************/ 
    public static Boolean hasAnyClaimHold(List<PartnerFundClaim> claims, Set<String> holdFields) {
        if (claims == null) {
            return false;
        }
        for (PartnerFundClaim claim : claims) {
            if (hasAnyHold(claim, holdFields)) {
                return true;
            }
        }
        return false;
    }

    /***************************************************************************************************** 
Method Name:        hasAnyHold
@return  :          boolean
@parameters:        claim, Set of Hold
Description:        checks if the claim is on any of the hold
Added By:           HP - 16/10/2026
******************************************************************************************************/ 
    public static Boolean hasAnyHold(PartnerFundClaim claim, Set<String> holdFields) {
        if (claim == null) {
            return false;
        }
        
        for (String fieldName : holdFields) {
            Boolean isOnHold = (Boolean) claim.get(fieldName);
            if(isOnHold == true){
                return true;
            }           
        }        
        return false;
    }
/***************************************************************************************************** 
Method Name:        hasIrreversibleSubClaim
@return  :          boolean
@parameters:        sub claim list
Description:        checks if the claim is on irrevrsibleStatus
Added By:           HP - 23/10/2026
******************************************************************************************************/        
    public static Boolean hasIrreversibleSubClaim(List<PartnerFundClaim> subClaims) {
        if (subClaims == null || subClaims.isEmpty()) {
            return false;
        }        
        List<String> irreversibleStatuses = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_IrreversibleSubClaimStatuses');
        
        for (PartnerFundClaim subClaim : subClaims) {
            if (subClaim != null && irreversibleStatuses.contains(subClaim.Core_MDF_Status__c)) {
                return true;
            }
        }
        return false;
    }

    /***************************************************************************************************** 
Method Name:        cancelClaimsWithReason
@return  :          boolean
@parameters:        claimIdList, cancellationReason
Description:        Cancels a list of claims and stores the entered reason on Core_MDF_Claim_Cancellation_Reason_txt__c
Added By:           HP - 12/10/2026
******************************************************************************************************/    
    @AuraEnabled
    public static boolean cancelClaimsWithReason(List<Id> claimIdList, String cancellationReason){
        try{
            cancelClaimInnerClass cancelClaimInner = new cancelClaimInnerClass();
            return cancelClaimInner.cancelClaimsWithoutSharing(claimIdList, cancellationReason);
        }
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw e ;}
    }
    
    /***************************************************************************************************** 
Method Name:        cancelVatInformation
@return  :          void
@parameters:        vatClaimsToBeCancelled
Description:        This is a Method to be used to Cancel a list of Vat Information
Added By:           Intel - SM - 08/10/2020
Modified By:        Date:       Changes: 
******************************************************************************************************/   
    public static void cancelVatInformation(Set<Id> vatClaimsToBeCancelled){
        
        
        List<Core_MDF_Claim_VAT_Info__c> vatInfoList = [Select Core_MDF_Claim_Id__c, Id, Core_MDF_Status_Txt__c from Core_MDF_Claim_VAT_Info__c 
                                                        where Core_MDF_Claim_Id__c IN :vatClaimsToBeCancelled OR Core_MDF_Sub_Claim_Id__c IN :vatClaimsToBeCancelled];  //Roshan - added subclaim check
        List<Id> vatIdsToBeRejected = new List<Id>();
        if(vatInfoList != NULL && vatInfoList.size() > 0)
        {
            for(Core_MDF_Claim_VAT_Info__c vat : vatInfoList){
                //set the status of the vat to Cancelled
                vat.Core_MDF_Status_Txt__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled');// Label.Core_MDF_Status_Cancelled;
                vatIdsToBeRejected.add(vat.Id);
            }
            Core_MDF_VAT_ApprovalQueueRemoval.removeRecordsFromApprovalQueue(vatIdsToBeRejected);
            Database.update(vatInfoList);
            
        }
    }
    
  /***************************************************************************************************** 
Method Name:        cancelClaimsWithoutSharing
@return  :          string
@parameters:        claimIdList
Description:        This is a without sharing inner class to be used to Cancel a list of claims
Added By:           SP - 1/19/2025
Modified By:        Date:       Changes: 
******************************************************************************************************/     
    public without sharing class cancelClaimInnerClass{

        public boolean cancelClaimsWithoutSharing(List<Id> claimIdList, String cancellationReason){
        //Integer i= 5/0;
        //Get the status in which Cancelling a claim is allowed. Added this additional check in case the method is called from backend
        //List<string> validStatus = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_EditClaimStatusValues'); //Label.Core_MDF_Status_allowed_for_Cancel_Claim.split(';');
        List<string> validStatus = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_allowed_for_Cancel_Claim');//Added as part New Status values like PIC Pending,Pending Documents,Resubmission Required
        Boolean success = true;
        try{
            List<PartnerFundClaim> claimList = [SELECT Id, ChannelPartnerId, Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Claim_Id__c,Core_MDF_Claim_Cancellation_Reason_txt__c, Core_MDF_Bank_Doc_Hold_Ind__c, Core_MDF_Payment_Hold_ind__c 
                                                FROM PartnerFundClaim 
                                                where (Id IN :claimIdList or Core_MDF_Claim_Id__c IN :claimIdList)];
            List<PartnerFundClaim> claimToBeCancelled = new List<PartnerFundClaim>();
            Set<Id> vatClaimsToBeCancelled = new Set<Id>();
            //Set<Id> accountIds = new Set<Id>();
                        
            if(claimList != NULL && claimList.size() > 0)
            {
                for(PartnerFundClaim claim : claimList)
                {
                    if(validStatus.contains(string.valueof(claim.Core_MDF_Status__c)))
                    {
                        
                        //set the status of the claim to Cancelled
                        claim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled'); //Label.Core_MDF_Status_Cancelled; 
                        claim.Core_MDF_Claim_Cancellation_Reason_txt__c = cancellationReason;                        
                        //claim.Core_MDF_VAT_Hold_Ind__c=false; // If Adj get cancelling, Corresponding Claim and VAt also should get cancel and VAt hold should be false
                        //add to the list of claims to be cancelled
                        //claim.Core_MDF_ESD_Hold__c=false;
                        claimToBeCancelled.add(claim);
                    }
                    if(claim.Core_MDF_VAT_Eligibility_Ind__c){ vatClaimsToBeCancelled.add(claim.Id);  
                                                             }
                    
                }
            }

            Database.update(claimToBeCancelled); 
            if(vatClaimsToBeCancelled != NULL && vatClaimsToBeCancelled.size() > 0){cancelVatInformation(vatClaimsToBeCancelled);}            
            return success;}
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw e ;}
        }
        
        /***************************************************************************************************** 
Method Name:        getActiveSubClaims
@return  :          List<PartnerFundClaim>
@parameters:        superClaimIds
Description:        Returns the non-cancelled sub-claims (Payment Breakdown items) of the given Super Claims.
                    Runs without sharing to match the cancellation scope; callers must have already read the Super Claim.
Added By:           HP - 10/21/2026
******************************************************************************************************/
        public List<PartnerFundClaim> getActiveSubClaims(Id superClaimId){
            if(superClaimId == null){
                return new List<PartnerFundClaim>();
            }
            String cancelledStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled');
            return [SELECT Id, Core_MDF_Claim_Id__c, Core_MDF_Status__c, Core_MDF_Bank_Doc_Hold_Ind__c, Core_MDF_Payment_Hold_ind__c, Core_MDF_ESD_Hold__c,
                    Core_MDF_VAT_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c, Core_MDF_Member_Manual_Hold_Ind__c, Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Document_Hold_Ind__c
                    FROM PartnerFundClaim WHERE Core_MDF_Claim_Id__c =: superClaimId AND Core_MDF_Status__c != :cancelledStatus];
        }
    }
}