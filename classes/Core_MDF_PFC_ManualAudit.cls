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
******************************************************************************************************/   
    
    @AuraEnabled
    public static string isClaimEligibleForManualAudit(Id claimId){
        
        try{
            string message = null;
            boolean claimEligibleForAudit = false;
            //To check if the user has access to set claims for Manual Audit
            if(!isInternalAuditUser(Label.Core_MDF_ClaimEditAccessToAuditUser))
            {
                return message = Label.Core_MDF_Manual_Audit_Access_Error;
            }
            else
            {
                //Get the status in which Manually Auditing a claim is allowed
                List<string> validStatus = Label.Core_MDF_Status_allowed_for_Manual_Audit.split(';');
                //  string userType = UserInfo.getUserId();
                PartnerFundClaim claimObj = [SELECT Id, Core_MDF_Type_Txt__c, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c FROM PartnerFundClaim where Id = :claimId];
                //check claim type
                if(Core_MDF_Claim_Utility.isType(claimObj, Label.Core_MDF_Claim_Adjustment_Type))
                {
                    return message = Label.Core_MDF_Negative_Claim_Error;
                }else{
                    //set the claimEligibleForAudit to true only if user has edit access and the status is one of the allowed statuses.
                    if(validStatus.contains(string.valueof(claimObj.Core_MDF_Status__c)))
                    {					
                        //set the claimEligibleForAudit to false if the claim is on Audit Hold
                        if((Label.Core_MDF_Status_Hold.equals(claimObj.Core_MDF_Status__c) && claimObj.Core_MDF_Audit_Hold__c))
                        {
                            claimEligibleForAudit = false;	
                        }
                        //set the claimEligibleForAudit to false if the claim is already Audited
                        else if(claimObj.Core_MDF_FlaggedForAudit__c)
                        {
                            return message = Label.Core_MDF_Claim_Reviewed_Previously;
                        }
                        else
                        {
                            claimEligibleForAudit =  true;
                            return message = Label.Core_MDF_Success;
                        }
                    }
                    
                }
                //make this else
                //If the claim is not a valid status
                /*                if(!claimEligibleForAudit)
{
return message = Label.Core_MDF_Claim_Cannot_be_set_for_Manual_Audit;
}*/
            }
            //If the claim is not a valid status
            return message = Label.Core_MDF_Claim_Cannot_be_set_for_Manual_Audit; 
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(''+e.getMessage());}
    }
    
    /***************************************************************************************************** 
Method Name:        assignClaimsForManualAudit
@return  :          string
@parameters:        claimIdList
Description:        This is a Method to be used to Manually Audit a list of claims
Added By:           Intel - SM - 11/20/2018
Modified By:        Date:       Changes: 
Shridhar Accenture	13/08/2019	Added condition to update of claim status for post payment claims
******************************************************************************************************/    
    @AuraEnabled
    public static boolean assignClaimsForManualAudit(List<Id> claimIdList){
        //Get the status in which Manually Auditing a claim is allowed. Added this additional check in case the method is called from backend
        List<string> validStatus = Label.Core_MDF_Status_allowed_for_Manual_Audit.split(';');
        Boolean success = true;
        try{
            List<PartnerFundClaim> claimList = [SELECT Id, ChannelPartnerId, Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c FROM PartnerFundClaim where Id = :claimIdList];
            List<PartnerFundClaim> claimToBeAudited = new List<PartnerFundClaim>();
            Set<Id> accountIds = new Set<Id>();
            
            if(claimList != NULL && claimList.size() > 0)
            {
                for(PartnerFundClaim claim : claimList)
                {
                    if(validStatus.contains(string.valueof(claim.Core_MDF_Status__c)) && !claim.Core_MDF_FlaggedForAudit__c)
                    {
                        claim.Core_MDF_Audit_Type__c = Label.Core_MDF_Manual_Audit_Type;            
                        claim.Core_MDF_FlaggedForAudit__c = true; 
                        claim.Core_MDF_Audit_Hold__c = true;
                        
                        //Below condition is added by Shridhar to prevent status update for Post Payment Claims 13/08/2019
                        List<String> claimStatusFromHoldList = Label.Core_MDF_Prevent_Claim_Status_From_Hold.split(';');
                        if(!claimStatusFromHoldList.contains(claim.Core_MDF_Status__c)){
                            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Hold;
                        }
                        
                        //add to the list of claims to be audited
                        claimToBeAudited.add(claim);
                    }
                    
                }
            }
            Database.update(claimToBeAudited); //throw exception and check
            
            return success;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           System.debug('Exception:'+e.getMessage());
                           throw new AuraHandledException(''+e.getMessage());} 
    } 
}