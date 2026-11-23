/******************************************************************************************************
 * Class Name  : Core_MDF_PartnerFundClaim_Edit
 * Version     : 1.0
 * Created Date: 11-27-2018
 * Modification Log :
 * Developer  AH          Date               Description : This class is called from Edit switch lightning component
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/

public with sharing class Core_MDF_PartnerFundClaim_Edit_Opal {
    /******************************************************************************************************
       Method Name:        fetchClaimById
       @return  :          PartnerFundClaim object
       @parameters:        <String>claim record ID
       Description:        This method is used to fetch claim data by passing claim record ID, in case of edit
       Added By:           Accenture - AD - 11/16/2018
       Modified By:        Date:       Changes:
     *******************************************************************************************************/
    @AuraEnabled
    public static ClaimCountryDetailsWrapper fetchClaimById(String recordId){

        Id recId = recordId;
        PartnerFundClaim pfc = [SELECT Id,Title,Core_MDF_Status__c,Core_MDF_Audit_Hold__c,Request.Title,Request.Core_MDF_Activity_Number__c,Core_MDF_AccountCompany__c,ChannelPartner.Id,ChannelPartner.name,Core_MDF_Country_Location_nm__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Activity_Category__c,
                                Core_MDF_Activity_Types__c,Core_MDF_Activity_Start_Date__c,Core_MDF_Activity_End_Date__c,/*Request.Core_MDF_Budget_Type_txt__c,*/ 
                                Core_MDF_Target_Audience__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,
                                Core_MDF_Media_Vehicle__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Name,Core_MDF_Bank__r.Core_MDF_Bank_Status__c,Core_MDF_Bank__r.Core_MDF_Bank_Alias_Name__c,Core_MDF_Invoice_Number__c,Core_MDF_Invoice_Date__c,
                                Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Currency__c,toLabel(Core_MDF_Currency__c) Currency_Label,
                                Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Taxes_Local__c,Core_MDF_Claim_Comments__c,Core_MDF_Duplicate_Claim__c,Core_MDF_FlaggedForAudit__c,Core_MDF_NoOfImpressions_Nbr__c,Core_MDF_NoOfEngagements_Nbr__c,Core_MDF_NoOfTrialActivations_Nbr__c,RecordType.DeveloperName,
                                Core_MDF_VAT_Hold_Ind__c,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Escalation_Id__c,Core_MDF_Escalation_Id__r.Name,Core_MDF_Type_Txt__c,Request.Core_MDF_Fund_Request_Status__c,RequestId, Request.Core_MDF_Country_nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Claim_Review_Case__c,Core_MDF_Program__c,
                                Request.Campaign.Name,Request.Campaign.Description,Core_MDF_Activity_SubType_nm__c,toLabel(Core_MDF_Activity_SubType_nm__c) LocalizedActivitySubType,Request.Core_MDF_POP_Requirements_txt__c,Core_MDF_Claim_Submitter_Id__c,Core_MDF_Claim_Submitter_Id__r.name,Core_MDF_Claim_Submitter_Id__r.contact.Email,Core_MDF_Claim_Submitter_Id__r.Email,
                                Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id,Core_MDF_VAT_Opt_In__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c
                                FROM PartnerFundClaim WHERE Id=:recId LIMIT 1];
        //added querying 2 fields by Vaishali for owner change//Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id
        system.debug('pfc fetchClaimById:::>'+pfc);

        return prepareWrapper(pfc);
    }
    /******************************************************************************************************
       Method Name:        isClaimEligibleForClone
       @return  :          Boolean value
       Description:        This class copy the Claim record data .
       Added By:           Intel - AB         01/03/2019
       Modified By:        Date:       Changes:
     *******************************************************************************************************/

    @AuraEnabled
    public static boolean isClaimEligibleForClone(String recordId){
        Id recId = recordId;        
        try{
            //check user is having access to create and Edit claim Permission on the PartnerFundClaim Object
            boolean hasCreatAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectCreatePermission('PartnerFundClaim');
            boolean hasEditAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectEditPermission('PartnerFundClaim');
            //getting custom permission value from custom setting
            String pRCRMFClaimOperationCustPerName = Core_MDF_Configuration__c.getValues('PRC_CLAIM_OPERATION_CUSTOM_PERMISSION').Core_MDF_Value__c;            
            Boolean isRMFPRCClaimOperation = FeatureManagement.checkPermission(pRCRMFClaimOperationCustPerName);//added by vaishali to check if user is RMF PRC Internal claim submitter
            //checking if user is partner user or PRC claim operation user, to block cloning of claim when CCR ind is true
            if(isPartner() || isRMFPRCClaimOperation){
                //query the CRR positive indicator to restrict the clone action
               /* PartnerFundClaim pfc = [SELECT Id,Core_MDF_CRR_Positive_Ind__c FROM PartnerFundClaim WHERE Id=:recId LIMIT 1];
                if(pfc.Core_MDF_CRR_Positive_Ind__c){
                    return false;
                }
                else{*/
                    if(hasCreatAccess & hasEditAccess)
                    {   return true;  }
                    else
                    {   return false; } 
               // } 
            }
            else{
                if(hasCreatAccess & hasEditAccess)
                {   return true;  }
                else
                {   return false; } } }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e; }
    }
    /******************************************************************************************************
       Method Name:        prepareCloneData
       @return  :          PartnerFundClaim object
       @parameters:        <String>claim record ID
       Description:        This method is used to fetch claim data by passing claim record ID, in case of clone
       Added By:           Accenture - AD - 3/11/2018
       Modified By:        Date:       Changes:
     *******************************************************************************************************/
    @AuraEnabled
    public static ClaimCountryDetailsWrapper prepareCloneData(String recordId){

        Id recId = recordId;
        PartnerFundClaim pfc = [SELECT Id,Title,Request.Title,Request.Core_MDF_Activity_Number__c,Core_MDF_AccountCompany__c,ChannelPartner.Id,ChannelPartner.name,Core_MDF_Reimbursement_Percent__c,Core_MDF_Activity_Category__c,
                                Core_MDF_Activity_Types__c,Core_MDF_Activity_Start_Date__c,Core_MDF_Activity_End_Date__c,/*Request.Core_MDF_Budget_Type_txt__c,*/
                                Core_MDF_Target_Audience__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,
                                Core_MDF_Media_Vehicle__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Name,Core_MDF_Bank__r.Core_MDF_Bank_Status__c,Core_MDF_Bank__r.Core_MDF_Bank_Alias_Name__c,Core_MDF_Invoice_Number__c,Core_MDF_Invoice_Date__c,
                                Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Currency__c,toLabel(Core_MDF_Currency__c) Currency_Label,
                                Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Taxes_Local__c,Core_MDF_Claim_Comments__c,Core_MDF_NoOfImpressions_Nbr__c,Core_MDF_NoOfEngagements_Nbr__c,Core_MDF_NoOfTrialActivations_Nbr__c,RecordType.DeveloperName,
                                Core_MDF_Type_Txt__c,Core_MDF_Country_Location_nm__c,Request.Core_MDF_Country_nm__c,RequestId,Core_MDF_Program__c,Core_MDF_Claim_Submitter_Id__c,Core_MDF_Claim_Submitter_Id__r.name,
                                Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id,
                                Request.Campaign.Name,Request.Campaign.Description,Core_MDF_Activity_SubType_nm__c,toLabel(Core_MDF_Activity_SubType_nm__c) LocalizedActivitySubType,Request.Core_MDF_POP_Requirements_txt__c,Core_MDF_VAT_Opt_In__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c FROM PartnerFundClaim WHERE Id=:recId LIMIT 1];
        //added querying 2 fields by Vaishali for owner change//Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id
        system.debug('pfc prepareCloneData:::>'+pfc);        
        return prepareWrapper(pfc);
    }

    /******************************************************************************************************
       Method Name:        prepareWrapper
       @return  :          ClaimCountryDetailsWrapper
       @parameters:        partnerfundclaim object
       Description:        This method is used to prepare wrapper, in case of Clone & Edit
       Added By:           Accenture - KK - 2/10/2020
       Modified By:        Date:       Changes:
     *******************************************************************************************************/
    public static ClaimCountryDetailsWrapper prepareWrapper(partnerfundclaim pfc){
        PartnerFundRequest pfr = [SELECT Id,toLabel(Core_MDF_Country_nm__c) countryNameLocalized,Core_MDF_Country_nm__c from PartnerFundRequest where Id =:pfc.RequestId];
        Map<String,String> countryNewMap = new Map<String,String>();
        countryNewMap.put(String.valueOf(pfr.Core_MDF_Country_nm__c),String.valueOf(pfr.get('countryNameLocalized')));
        ClaimCountryDetailsWrapper claimCountryDetailsWrap = new ClaimCountryDetailsWrapper();
        claimCountryDetailsWrap.claimObj = pfc;
        claimCountryDetailsWrap.countryMap = countryNewMap;
        return claimCountryDetailsWrap;
    }
    /***************************************************************************************************** 
    Method Name:        isPartner
    @return  :          Boolean
    @parameters:         
    Description:        Identify whether it is an External User
    @Added By:          HA
    ******************************************************************************************************/
    public static boolean isPartner(){
        string userType = UserInfo.getUserType();       
        if(userType == Label.Core_MDF_Partner_User_Type)
        { return true;}
        else {return false; }
    }
    
    public class ClaimCountryDetailsWrapper {
        @AuraEnabled
        public PartnerFundClaim claimObj;
        @AuraEnabled
        public Map<String,String> countryMap;
    }
}