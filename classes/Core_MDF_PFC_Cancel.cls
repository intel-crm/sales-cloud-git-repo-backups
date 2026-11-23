/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_Cancel 
* Version     : 1.0 
* Created Date: 11-20-2018
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         11/20/2018                    This class hold the Utility methods for the Cancel Claim Scenario     
*****************************************************************************************************************************************/
public with sharing class Core_MDF_PFC_Cancel {
    
    /***************************************************************************************************** 
Method Name:        isClaimEligibleForCancel
@return  :          UserInfoWrapper
@parameters:        claimId
Description:        This is a Method to check whether the Cancel button should be visible on a Claim Record
Added By:           Intel - SM - 11/20/2018
Modified By:  Accenture - Krishna Kulkarni      Date:  20-06-2019     Changes: 
******************************************************************************************************/   
    
    @AuraEnabled
    public static UserInfoWrapper isClaimEligibleForCancel(Id claimId){
        
        try{
            //boolean claimEligibleForCancel = false;            
            UserInfoWrapper userInfoWrap = new UserInfoWrapper();
            //Check if the logged in user has Edit Permission on the PartnerFundClaim Object
            boolean hasCancelAccess = FeatureManagement.checkPermission(Label.Core_MDF_CancelClaim);
            //Get the status in which Cancelling a claim is allowed
            List<string> validStatus = Label.Core_MDF_Status_allowed_for_Cancel_Claim.split(';');
            string userType = UserInfo.getUserType();
            PartnerFundClaim claimObj = [SELECT Id,Core_MDF_Type_Txt__c, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c FROM PartnerFundClaim where Id = :claimId]; 
            system.debug('claimObj-->' +claimObj);
            //set the cancelClaimVisibility to true only if user has edit access and the status is one of the allowed statuses.
            //set the cancelClaimVisibility to false if its an External User and the claim is on Audit Hold, Or Intel Hold or Criteria Hold                        
            if(hasCancelAccess && validStatus.contains(string.valueof(claimObj.Core_MDF_Status__c)))
            {
                //check claim type                
                if(Core_MDF_Claim_Utility.isType(claimObj, Label.Core_MDF_Claim_Adjustment_Type))
                {
                    List<Core_MDF_Claim_Offset__c> offsetRecordList = [select id,Core_MDF_Adjustment_Claim_Nbr__c from Core_MDF_Claim_Offset__c where Core_MDF_Adjustment_Claim_Nbr__c= :claimId];                        
                    if(userType != Label.Core_MDF_Partner_User_Type){                       
                        if(offsetRecordList != null && offsetRecordList.size() > 0){
                            userInfoWrap.restrictClaimOperator = true;
                        }else{                             
                            userInfoWrap.claimEligibleForCancel =  true;
                        }
                    } else{
                        if(offsetRecordList != null && offsetRecordList.size() > 0){
                            userInfoWrap.restrictClaimOperator = true;
                        }
                    }               
                } else{
                    if(!(userType == Label.Core_MDF_Partner_User_Type && (claimObj.Core_MDF_Audit_Hold__c == true || isClaimOnIntelOrCriteiaHold(claimObj)))) 
                    {
                        userInfoWrap.claimEligibleForCancel = true;
                    }
                }                
            }
            return userInfoWrap;}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
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
        //Get the status in which Cancelling a claim is allowed. Added this additional check in case the method is called from backend
        List<string> validStatus = Label.Core_MDF_Status_allowed_for_Cancel_Claim.split(';');
        Boolean success = true;
        try{
            List<PartnerFundClaim> claimList = [SELECT Id, ChannelPartnerId, Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c FROM PartnerFundClaim where Id = :claimIdList];
            List<PartnerFundClaim> claimToBeCancelled = new List<PartnerFundClaim>();
            Set<Id> accountIds = new Set<Id>();
            
            if(claimList != NULL && claimList.size() > 0)
            {
                for(PartnerFundClaim claim : claimList)
                {
                    if(validStatus.contains(string.valueof(claim.Core_MDF_Status__c)))
                    {
                        //set the status of the claim to Cancelled
                        claim.Core_MDF_Status__c = Label.Core_MDF_Status_Cancelled;                        
                        //add to the list of claims to be cancelled
                        claimToBeCancelled.add(claim);
                    }
                    
                }
            }
            Database.update(claimToBeCancelled);
            
            return success;}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                                               //throw new AuraHandledException(''+e.getMessage());
                                               throw e ;
                                              }
    }
    
    /***************************************************************************************************** 
Method Name:        isClaimOnIntelOrCriteiaHold
@return  :          boolean
@parameters:        claimIdList
Description:        This is a Method to be used to Cancel a list of claims
Added By:           Intel - SM - 11/20/2018
Modified By:        Date:       Changes: 
******************************************************************************************************/   
    public static boolean isClaimOnIntelOrCriteiaHold(PartnerFundClaim claimObj){
        if( claimObj.Core_MDF_Intel_Manual_Hold_Ind__c || claimObj.Core_MDF_Criteria_Hold_Ind__c )
        {    return true; }
        else
        {  Return false; }
    }
}