/******************************************************************************************************
* Class Name  : Core_MDF_ReleaseHold 
* Version     : 1.0 
* Created Date: 03-05-2019
* Modification Log :
* Developer           Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - VD     03-05-2019          This class will release Criteria and Manual Hold from Claim
*******************************************************************************************************/    
public with sharing class Core_MDF_ReleaseHold {

/***************************************************************************************
Class Name:         criteriaManualHoldWrapper
Description:        This wrapper class will hold the values of all the variables
Added By: VD        Accenture - 03-05-2019
Modified By:        Date:      Changes: 
****************************************************************************************/
    public with sharing class criteriaManualHoldWrapper{    
        @AuraEnabled
        public Boolean hasAccess=False;
        @AuraEnabled
        public Boolean isOnIntManualHold=False;
        @AuraEnabled
        public Boolean isOnMembManualHold=False;
        @AuraEnabled
        public Boolean isOnCriteriaHold=False;
        @AuraEnabled
        public PartnerFundClaim pfc;
        @AuraEnabled
        public String loggedInUserType;
        @AuraEnabled
        public String exceptionDetails;
        @AuraEnabled
        public Boolean hasAccessForBankDocumentHold=False;   // Added for checking if the user has access for the custom permission or not
       	@AuraEnabled
        public Boolean isOnBankDocumentHold=False;   // Added for checking if the Bank document hold is true or not.
    }
/*********************************************************************************************************
Method Name:        fetchClaimHoldDetails
@parameters:        Claim Id
@return  :          Wrapper which will hold the values of all the variables.
Description:        This method will fetch claim details
Added By: VD        Accenture - 03-05-2019
Modified By:        Date:      Changes: 
**********************************************************************************************************/
    @AuraEnabled 
    public static criteriaManualHoldWrapper fetchClaimHoldDetails(Id pfcId){
        
        criteriaManualHoldWrapper holdWrap = new criteriaManualHoldWrapper();
        try{
            holdWrap.pfc = [SELECT Id, Core_MDF_Member_Manual_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Audit_Hold__c, Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Claim_Previous_Status__c, Core_MDF_Status__c, Status, Core_MDF_ESD_Hold__c,Core_MDF_Bank_Doc_Hold_Ind__c, Core_MDF_Payment_Hold_ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c FROM PartnerFundClaim WHERE Id=: pfcId];
            //Checking for user's permission from custom permission
            holdWrap.hasAccess = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PermToRelease_CritAndManualHold')); 
            holdWrap.hasAccessForBankDocumentHold = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PermToRelease_BankDocumentHold'));
            if(holdWrap.hasAccess){
                //Assigning logged in user userType
                holdWrap.loggedInUserType = UserInfo.getUserType();
                //Assigning Claim Hold field values
                holdWrap.isOnIntManualHold = holdWrap.pfc.Core_MDF_Intel_Manual_Hold_Ind__c;
                holdWrap.isOnMembManualHold = holdWrap.pfc.Core_MDF_Member_Manual_Hold_Ind__c;
                holdWrap.isOnCriteriaHold = holdWrap.pfc.Core_MDF_Criteria_Hold_Ind__c;
                
                holdWrap.exceptionDetails = null;
                
            }
            //If the user has access to custom permission then we are updating isOnBankDocumentHold with the bank document hold.
            if(holdWrap.hasAccessForBankDocumentHold){
             holdWrap.loggedInUserType = UserInfo.getUserType();
			 holdWrap.isOnBankDocumentHold = holdWrap.pfc.Core_MDF_Bank_Doc_Hold_Ind__c;
             holdWrap.exceptionDetails = null;
            }
            return holdWrap;
            
        }  
        catch (Exception e){
	Core_MDF_CCP_UtilityClass.logError(e);
	holdWrap.exceptionDetails = 'Exception: '+e.getMessage();
	return holdWrap;
	}
    }
/******************************************************************************************************************************************************************
Method Name:        updateCriteriaManualFields
@parameters:        PartnerFundClaim , Boolean previousIntelManualHoldFieldValue, Boolean previousIntelManualHoldFieldValue, Boolean previousCriteriaHoldFieldValue
@return  :          void
Description:        This method will update Criteria or Manual Hold fields on claim when 
                    Internal/External user will release claim from Criteria or Manual Hold
Added By: VD        Accenture - 07-05-2019
Modified By:        Date:      Changes:    
******************************************************************************************************************************************************************/
   @AuraEnabled 
    public static String releaseHoldFromClaim(PartnerFundClaim pfclaim, Boolean previousMembHold, Boolean previousIntHold, Boolean previousCriteriaHold, Boolean previousBankDocumentHold){
        try{
            List<PartnerFundClaim> claimsToBeReleasedlist = new List<PartnerFundClaim>();
            List<String> releaseReasonList = new List<String>();
            //Checking old and new Value of Hold fields
            if(previousCriteriaHold && (!pfclaim.Core_MDF_Criteria_Hold_Ind__c)){
                releaseReasonList.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Criteria_Hold')); //Label.Core_MDF_Criteria_Hold
            }   
            if(previousIntHold && (!pfclaim.Core_MDF_Intel_Manual_Hold_Ind__c)){
                releaseReasonList.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Intel_Manual_Hold')); //Label.Core_MDF_Intel_Manual_Hold
                //Wiping off the comments after releasing hold
                pfclaim.Core_MDF_Intel_Manual_Hold_Comments_Txt__c='';
            }
            if(previousMembHold && (!pfclaim.Core_MDF_Member_Manual_Hold_Ind__c)){
                releaseReasonList.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Member_Manual_Hold')); //Label.Core_MDF_Member_Manual_Hold  
                //Wiping off the comments after releasing hold
                pfclaim.Core_MDF_Member_Manual_Hold_Comments_Txt__c='';
            }
            
            if(previousBankDocumentHold && (!pfclaim.Core_MDF_Bank_Doc_Hold_Ind__c)){
               releaseReasonList.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bank_Document_Hold'));  //Label.Core_MDF_Bank_Document_Hold
            }
            claimsToBeReleasedlist.add(pfclaim);
            //Calling releaseHold method to update claim record.
            if(releaseReasonList!=NULL && releaseReasonList.size() > 0){
               Core_MDF_Claim_Utility.releaseHold(claimsToBeReleasedlist, releaseReasonList); 
	       return null;
            }
            else{
                return null;
            }
        }
        catch (Exception e){
	Core_MDF_CCP_UtilityClass.logError(e); 
	return 'Exception: '+e.getMessage();
	}
    }
}