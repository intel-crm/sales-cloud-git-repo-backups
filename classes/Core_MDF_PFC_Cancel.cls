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
@return  :          UserInfoWrapper
@parameters:        claimId
Description:        This is a Method to check whether the Cancel button should be visible on a Claim Record
Added By:           Intel - SM - 11/20/2018
Modified By:  Accenture - Krishna Kulkarni      Date:  20-06-2019     Changes: 
Alekhya                                                25-02-2025     Included CSC Claim submitter to restrict the claim cancellation 
******************************************************************************************************/   
    
    @AuraEnabled
    public static UserInfoWrapper isClaimEligibleForCancel(Id claimId){
        
        try{
            
            //boolean claimEligibleForCancel = false;      // From Wrapper by defualt we are stopping claim to get cancel.if we want to allow make explicetly to "True" to get cancel.       
            UserInfoWrapper userInfoWrap = new UserInfoWrapper();
            //Check if the logged in user has Edit Permission on the PartnerFundClaim Object
            boolean hasCancelAccess = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CancelClaim'));  //Label.Core_MDF_CancelClaim
            //Get the status in which Cancelling a claim is allowed
            List<string> validStatus = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_allowed_for_Cancel_Claim'); //Label.Core_MDF_Status_allowed_for_Cancel_Claim.split(';');
            string userType = UserInfo.getUserType();
            PartnerFundClaim claimObj = [SELECT Id,Core_MDF_Type_Txt__c, Core_MDF_Claim_Review_Case__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_Status__c,Core_MDF_Total_Claim_Recovery_Amount__c, Core_MDF_Audit_Hold__c,Core_MDF_VAT_Hold_Ind__c, Core_MDF_ESD_Hold__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Payment_Hold_ind__c FROM PartnerFundClaim where Id = :claimId]; 
            
            //getting custom permission value from custom setting
            String pRCRMFClaimOperationCustPerName = Core_MDF_Configuration__c.getValues('PRC_CLAIM_OPERATION_CUSTOM_PERMISSION').Core_MDF_Value__c;  
            String partnerUserType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type');
            Boolean isRMFPRCClaimOperation = FeatureManagement.checkPermission(pRCRMFClaimOperationCustPerName);//added by vaishali to check if user is RMF PRC Internal claim submitter
            String cSCClaimSubmitterCustPerName = Core_MDF_Configuration__c.getValues('CSC_CLAIM_SUBMITTER_CUSTOM_PERMISSION').Core_MDF_Value__c;  //Added by Alekhya
            Boolean isCSCClaimSubmitter = FeatureManagement.checkPermission(cSCClaimSubmitterCustPerName);
            
            //String externalClaimSubmitterCustPerName = Core_MDF_Configuration__c.getValues('EXT_CLAIM_SUBMITTER_CUSTOM_PER').Core_MDF_Value__c;  
            //Boolean isExternalClaimSubmitter = FeatureManagement.checkPermission(externalClaimSubmitterCustPerName);
            //set the cancelClaimVisibility to true only if user has edit access and the status is one of the allowed statuses.
            //set the cancelClaimVisibility to false if its an External User and the claim is on Audit Hold, Or Intel Hold or Criteria Hold                       
            if(hasCancelAccess && validStatus.contains(string.valueof(claimObj.Core_MDF_Status__c)))
            {
                //check claim type  
                            
                if(Core_MDF_Claim_Utility.isType(claimObj, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type'))) // Label.Core_MDF_Claim_Adjustment_Type
                { //Adj Type
                    List<Core_MDF_Claim_Offset__c> offsetRecordList = [select id,Core_MDF_Adjustment_Claim_Nbr__c from Core_MDF_Claim_Offset__c where Core_MDF_Adjustment_Claim_Nbr__c= :claimId];                        
                    //if(userType != Label.Core_MDF_Partner_User_Type && !isRMFPRCClaimOperation){ 
                    if(userType != partnerUserType && !isRMFPRCClaimOperation){  
                          
                        if(offsetRecordList != null && offsetRecordList.size() > 0){
                            userInfoWrap.restrictClaimOperator = true; //Restrict Internal User for Partail Offset claim to Cancel                                                                                                                              
                            
                        }else{
                            userInfoWrap.claimEligibleForCancel =  true; 
                        }// If there is No offset,Allow internal user to cancel claim
                    } else{
                        if(offsetRecordList != null && offsetRecordList.size() > 0){
                            userInfoWrap.restrictClaimOperator = true; 
                        } //Restrict External User for Partail Offset claim to Cancel 
                    }               
                }
                else { 
                    
                    //claims
                        //For External User & Mistry shop
                        //If claim is "Not on Vat Hold ,Not on intel Hold,Not on Criteria Hold, Not on Document Hold" Or "Out of Audit ,Vat ,intel,Criteria Hold" can cancel Claim.
                        if(userType == partnerUserType || isRMFPRCClaimOperation || isCSCClaimSubmitter){

                            if(claimObj.Core_MDF_Audit_Hold__c==true|| claimObj.Core_MDF_Claim_Review_Case__c!=null)
                            {   //If audit for claim is in progress or completed, it cannot be cancelled
                                userInfoWrap.claimSelectedForAudit=true;
                            }
                            else if(!isClaimOnHold(claimObj)){
                                userInfoWrap.claimEligibleForCancel = true;
                            }
                        }//Internal user(CCR/CCRM) should able to cancel claim at any point of time. No restriction to internal user
                        else{
                            //Add Case check is present and not closed
                            if(claimObj.Core_MDF_Claim_Review_Case__c!=null && claimObj.Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c == Core_MDF_CCP_ConstantClass.REVIEW_COMPLETED )
                            {   //If audit for claim is in progress or completed, it cannot be cancelled
                                userInfoWrap.claimSelectedForAudit=true;
                            }
                            else{
                                userInfoWrap.claimEligibleForCancel = true;
                            }
                        } 
                        
                        
                    
                    
                }	
                
                if(claimObj.Core_MDF_Total_Claim_Recovery_Amount__c > 0){
                    userInfoWrap.claimEligibleForCancel = false;
                    userInfoWrap.claimHasRecovery = true;
                }
            }
           
            return userInfoWrap;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
    }
    
    /****************************************************************************************************** 
Class Name:        UserInfoWrapper
@parameters:        N/A
Description:        Wrapper which will hold logged in user information
Added By:           Accenture - Krishna Kulkarni - 14/06/2019
Modified By:        Date:      Changes: 
******************************************************************************************************/
    public class UserInfoWrapper{
        @AuraEnabled
        public Boolean claimEligibleForCancel = false;
        @AuraEnabled
        public Boolean restrictClaimOperator = false;
        @AuraEnabled
        public Boolean claimHasRecovery = false;
        @AuraEnabled
        public Boolean claimSelectedForAudit=false;
    }
    
    /***************************************************************************************************** 
Method Name:        cancelClaims
@return  :          string
@parameters:        claimIdList
Description:        This is a Method to be used to Cancel a list of claims
Added By:           Intel - SM - 11/20/2018
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    @AuraEnabled
    public static boolean cancelClaims(List<Id> claimIdList){
        //Integer i= 5/0;
        //Get the status in which Cancelling a claim is allowed. Added this additional check in case the method is called from backend
        //List<string> validStatus = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_EditClaimStatusValues'); //Label.Core_MDF_Status_allowed_for_Cancel_Claim.split(';');
        List<string> validStatus = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_allowed_for_Cancel_Claim');//Added as part New Status values like PIC Pending,Pending Documents,Resubmission Required
        Boolean success = true;
        try{
            List<PartnerFundClaim> claimList = [SELECT Id, ChannelPartnerId, Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_VAT_Eligibility_Ind__c 
                                                FROM PartnerFundClaim 
                                                where Id IN :claimIdList];
            List<PartnerFundClaim> claimToBeCancelled = new List<PartnerFundClaim>();
            Set<Id> vatClaimsToBeCancelled = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            
            
            if(claimList != NULL && claimList.size() > 0)
            {
                for(PartnerFundClaim claim : claimList)
                {
                    
                    if(validStatus.contains(string.valueof(claim.Core_MDF_Status__c)))
                    {
                        //set the status of the claim to Cancelled
                        claim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled'); //Label.Core_MDF_Status_Cancelled; 
                        //claim.Core_MDF_VAT_Hold_Ind__c=false; // If Adj get cancelling, Corresponding Claim and VAt also should get cancel and VAt hold should be false
                        //add to the list of claims to be cancelled
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
Method Name:        cancelVatInformation
@return  :          void
@parameters:        vatClaimsToBeCancelled
Description:        This is a Method to be used to Cancel a list of Vat Information
Added By:           Intel - SM - 08/10/2020
Modified By:        Date:       Changes: 
******************************************************************************************************/   
    public static void cancelVatInformation(Set<Id> vatClaimsToBeCancelled){
        
        
        List<Core_MDF_Claim_VAT_Info__c> vatInfoList = [Select Core_MDF_Claim_Id__c, Id, Core_MDF_Status_Txt__c from Core_MDF_Claim_VAT_Info__c 
                                                        where Core_MDF_Claim_Id__c IN :vatClaimsToBeCancelled];
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
Method Name:        isClaimOnHold
@return  :          boolean
@parameters:        claimIdList
Description:        This is a Method to check whether a claim is on Vat Hold/Intel Manual Hold/Criteria Hold/Document Hold
Added By:           Intel - SM - 10/05/2020
Modified By:      Date:       Changes: 
Alekhya           20/02/2025   Added Member Manual Hold, ESD Hold,Payment Hold
******************************************************************************************************/   
    public static boolean isClaimOnHold(PartnerFundClaim claimObj){
        if((claimObj.Core_MDF_VAT_Hold_Ind__c || 
           claimObj.Core_MDF_Intel_Manual_Hold_Ind__c || 
           claimObj.Core_MDF_Member_Manual_Hold_Ind__c ||
           claimObj.Core_MDF_Criteria_Hold_Ind__c || 
           claimObj.Core_MDF_Document_Hold_Ind__c ||
           claimObj.Core_MDF_ESD_Hold__c ||
           claimObj.Core_MDF_Payment_Hold_ind__c) && claimObj.Core_MDF_Status__c == Label.Core_MDF_Status_Hold)       
        {    
            return true; 
        }else {
            return false; 
        }
    }

    
}