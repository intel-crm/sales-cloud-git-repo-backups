/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_ManualHold_Claim 
* Version     : 1.0 
* Created Date: 13-04-2019
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Areefa         13/04/2019 
* Intel - Areefa         14/05/2019
* Intel - Areefa         17/05/2019     -   Defect fix for Trim String
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PFC_ManualHold_Claim {
    private static string holdStatus =Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold');
    // wrapper method for Manual Hold Claim
    public class HoldClaimDetails{
        @AuraEnabled   
        public PartnerFundClaim claimObj; 
        @AuraEnabled
        public Boolean isPartner;
        @AuraEnabled
        public Boolean hasAccess;
    }
    
    /***************************************************************************************************** 
    Method Name:        isPartner
    @return  :          Boolean
    @parameters:         
    Description:        Identify weather it is External User or internal user
    @Added By:          Intel   -   Areefa  -   13/04/2019
    ******************************************************************************************************/
    public static boolean isPartner(){
        string userType = UserInfo.getUserType();       
        if(userType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type')) // Label.Core_MDF_Partner_User_Type
        { return true;}
        else {return false; }
    }
    
/***************************************************************************************************** 
    Method Name:        getClaimHoldStatus
    @return  :          PartnerFundClaim
    @parameters:         
    Description:        Get the Manual Hold Claim details
    @Added By:          Intel   -   Areefa  -   13/04/2019
******************************************************************************************************/
    public static PartnerFundClaim getClaimHoldStatus(Id claimId)
    {
       PartnerFundClaim claimObj = [SELECT Id, Core_MDF_Type_Txt__c, Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c,Core_MDF_Intel_Manual_Hold_Ind__c, Core_MDF_Member_Manual_Hold_Ind__c, Core_MDF_Program__c,Core_MDF_Claim_Approval_Dt__c,Core_MDF_Approval_Step_Counter_nbr__c FROM PartnerFundClaim where Id = :claimId]; 
        try
        {   if(claimObj != null)
            {return claimObj;}
            else{return null; }   
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e; } //throw new AuraHandledException(''+e.getMessage()); 
    }
/***************************************************************************************************** 
    Method Name:        getClaimAndHoldDeatils
    @return  :          HoldClaimDetails
    @parameters:         
    Description:        Get the claim and Hold Claim details
    @Added By:          Intel   -   Areefa  -   13/04/2019
******************************************************************************************************/    
    @AuraEnabled
    public static HoldClaimDetails getClaimAndHoldDeatils(Id claimId){
        try {
            HoldClaimDetails chkclaimHold = new HoldClaimDetails();
            chkclaimHold.isPartner= isPartner();
            chkclaimHold.hasAccess = hasAccess();
            chkclaimHold.claimObj=getClaimHoldStatus(claimId); 
            return chkclaimHold;            
        } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e; } //throw new AuraHandledException(''+e.getMessage()); 
    }

  
    
/***************************************************************************************************** 
    Method Name:        updateClaimOnManualHold
    @return  :          Boolean
    @parameters:        ClaimId 
    Description:        Update Claim on Manual Hold
    @Added By:          Intel - Areefa - 13/04/2019
    Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static boolean updateClaimOnManualHold(Id claimId , String holdComments)
    {
        //PartnerFundClaim claimObj =  new PartnerFundClaim(id = claimId);    
        PartnerFundClaim claimObj = getClaimHoldStatus(claimId);
        List<PartnerFundClaim> claimToBeUpdated = new List<PartnerFundClaim>();
        holdComments = (holdComments!= null)?(holdComments.trim()):holdComments;
        
        try{
            
                if(isPartner())
                {	
                    claimObj.Core_MDF_Member_Manual_Hold_Ind__c = true;
                    claimObj.Core_MDF_Member_Manual_Hold_Comments_Txt__c = holdComments;
                    if(claimObj.Core_MDF_PIC_Review_Completed__c || (claimObj.Core_MDF_Program__c ==  Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM && claimObj.Core_MDF_Claim_Approval_Dt__c != null && claimObj.Core_MDF_Approval_Step_Counter_nbr__c == 0)){claimObj.Core_MDF_Status__c = holdStatus;}
                    claimToBeUpdated.add(claimObj);
                }
                else{
                    
                    claimObj.Core_MDF_Intel_Manual_Hold_Ind__c = true;
                    claimObj.Core_MDF_Intel_Manual_Hold_Comments_Txt__c = holdComments;
                    if(claimObj.Core_MDF_PIC_Review_Completed__c || (claimObj.Core_MDF_Program__c ==  Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM && claimObj.Core_MDF_Claim_Approval_Dt__c != null && claimObj.Core_MDF_Approval_Step_Counter_nbr__c == 0)){claimObj.Core_MDF_Status__c = holdStatus;}
                    claimToBeUpdated.add(claimObj);
                }
            Database.update(claimToBeUpdated);
            
            return true; } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e; } //throw new AuraHandledException(''+e.getMessage()); 
    }

/***************************************************************************************************** 
Method Name:        hasAccess
@return  :          Boolean
@parameters:        getClaimAndHoldDeatils
Description:        This method is used to check whether the logged in user has access to Manual Hold Claim.
Added By:           Intel - Areefa   - 03 May,2019
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    Public static Boolean hasAccess(){
        try {
            //Checking User permission from custom permission
            Boolean hasCustomPermission = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Permission_for_Hold_Claim')); //   Label.Core_MDF_Permission_for_Hold_Claim
            return hasCustomPermission;}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e; } //throw new AuraHandledException(''+e.getMessage());  
    } 
    
}