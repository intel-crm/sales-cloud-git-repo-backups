/******************************************************************************************************
 * Class Name  : Core_MDF_PartnerFundClaim_Edit
 * Version     : 1.0
 * Created Date: 11-27-2018
 * Modification Log :
 * Developer  AH          Date               Description : This class is called from Edit switch lightning component
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/

 public with sharing class Core_MDF_PartnerFundClaim_Edit {
    public static String declinedStatus = Core_MDF_CCP_ConstantClass.CAMPAIGN_DECLINED;
     public static String ipaProgram = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
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
		 try{
        Id recId = recordId;
        PartnerFundClaim claim;
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        if(recId != NULL){
        claimList = [SELECT Id,Title,Core_MDF_Status__c,Core_MDF_Audit_Hold__c,Request.Title,Request.Core_MDF_Region_nm__c,Request.Core_MDF_Activity_Number__c,Core_MDF_AccountCompany__c,ChannelPartner.Id,ChannelPartner.name,Core_MDF_Country_Location_nm__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Activity_Category__c,
                                Core_MDF_Activity_Types__c,Core_MDF_Activity_Start_Date__c,Core_MDF_Activity_End_Date__c,Request.Core_MDF_Budget_Type_nm__c,
                                Core_MDF_Brand_nm__c,Core_MDF_Target_Audience__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,
                                Core_MDF_Media_Vehicle__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Name,Core_MDF_Bank__r.Core_MDF_Bank_Status__c,Core_MDF_Bank__r.Core_MDF_Bank_Alias_Name__c,Core_MDF_Invoice_Number__c,Core_MDF_Invoice_Date__c,
                                Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Currency__c,toLabel(Core_MDF_Currency__c) Currency_Label,
                                Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Taxes_Local__c,Core_MDF_Claim_Comments__c,Core_MDF_Duplicate_Claim__c,Core_MDF_FlaggedForAudit__c,Core_MDF_NoOfImpressions_Nbr__c,Core_MDF_NoOfEngagements_Nbr__c,Core_MDF_No_of_Leads_nbr__c,Core_MDF_NoOfTrialActivations_Nbr__c,RecordType.DeveloperName,
                                Core_MDF_VAT_Hold_Ind__c,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Escalation_Id__c,Core_MDF_Escalation_Id__r.Name,Core_MDF_Type_Txt__c,Request.Core_MDF_Fund_Request_Status__c,RequestId, Request.Core_MDF_Country_nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Claim_Review_Case__c,Core_MDF_Program__c,
                                Request.Campaign.Name,Request.Campaign.Description,Core_MDF_Activity_SubType_nm__c,toLabel(Core_MDF_Activity_SubType_nm__c) LocalizedActivitySubType,Request.Core_MDF_POP_Requirements_txt__c,Core_MDF_Claim_Submitter_Id__c,Core_MDF_Claim_Submitter_Id__r.name,Core_MDF_Claim_Submitter_Id__r.contact.Email,Core_MDF_Claim_Submitter_Id__r.Email,Core_MDF_Proposal_Based_Ind__c,
                                Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Request.Core_MDF_Brand_nm__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id,Core_MDF_VAT_Opt_In__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Document_Hold_Ind__c, Core_MDF_Document_Hold_Eligibility_Ind__c, Core_MDF_PIC_Review_Completed__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Ultimate_Account_ID__c, Core_MDF_Log_Info_txt__c,
                                Request.ChannelPartner.Core_MDF_Channel_Program__r.Name, Core_MDF_Legacy_Claim_Ind__c, Createddate, Core_MDF_Applicable_VAT_Percentage_nm__c, Core_MDF_Paid_By_Payment_Type_nm__c, Core_MDF_Campaign_Id__r.Core_MDF_Terminal_Rejection_Ind__c, Request.Core_MDF_NEX_Ind__c, Request.Core_MDF_Key_Marketing_Indicator_nm__c, Request.Core_MDF_Deployment_Quantity_nbr__c, Request.Core_MDF_Lead_Quantity_nbr__c, Request.Core_MDF_Other_Quantity_nbr__c, Core_MDF_OutcomeBased_Ind__c,Request.Core_MDF_Proposal_Based_Ind__c,
				Core_MDF_CSP_Intel_Based_Revenue_amt__c, Core_MDF_Processing_Preference_nm__c, Request.Core_MDF_Is_Outcome_Based_Ind__c,Request.Core_MDF_Activity_Description__c,Request.Core_MDF_Parent_Activity_Id__c,Request.Core_MDF_Activity_Level_nm__c,Core_MDF_Claim_Id__c
                                FROM PartnerFundClaim WHERE Id=:recId LIMIT 1];
        //added querying 2 fields by Vaishali for owner change//Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id
        }
        if(!claimList.isEmpty() && claimList.Size() > 0){
            claim = claimList[0];
         }
         else{
            claim = null;     
         }

        return prepareWrapper(claim);
        }catch(Exception e)
        {Core_MDF_CCP_UtilityClass.logError(e);
            return null;
        }
    }
    /******************************************************************************************************
       Method Name:        isClaimEligibleForClone
       @return  :          Boolean value
       Description:        This class copy the Claim record data .
       Added By:           Intel - AB         01/03/2019
       Modified By:        Date:       Changes:
     *******************************************************************************************************/

    @AuraEnabled
    public static claimAccessWrapper isClaimEligibleForClone(String recordId) {
        Id recId = recordId;
        Boolean hasAccessToCloneClaim = false;
        claimAccessWrapper accessWrapper = new claimAccessWrapper();
        try {
            //check user is having access to create and Edit claim Permission on the PartnerFundClaim Object
            boolean hasCreateAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectCreatePermission(
                'PartnerFundClaim'
            );
            boolean hasEditAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectEditPermission(
                'PartnerFundClaim'
            );
            ClaimCountryDetailsWrapper wrapper = prepareCloneData(recordId);

            if (wrapper != null) {
                if (hasEditAccess && hasCreateAccess && wrapper.isValidCloneOrEditUser) {
                    hasAccessToCloneClaim = true;
                } else {
                    hasAccessToCloneClaim = false;
                }
                accessWrapper.hasAccessToCloneClaim = hasAccessToCloneClaim;
                accessWrapper.isAssociatedPFRNotDeclined = wrapper.isAssociatedPFRNotDeclined;
                accessWrapper.hasRestrictedStatusToCreateClaim = wrapper.hasRestrictedStatusToCreateClaim;
                accessWrapper.program = wrapper.claimObj.Core_MDF_Program__c;
            }
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
        return accessWrapper;
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
        PartnerFundClaim pfc = [SELECT Id,Title,Request.Title,Request.Core_MDF_Region_nm__c,Request.Core_MDF_Activity_Number__c,Core_MDF_AccountCompany__c,ChannelPartner.Id,ChannelPartner.name,Core_MDF_Reimbursement_Percent__c,Core_MDF_Activity_Category__c,
                                Core_MDF_Activity_Types__c,Core_MDF_Activity_Start_Date__c,Core_MDF_Activity_End_Date__c,Request.Core_MDF_Budget_Type_nm__c,
                                Core_MDF_Brand_nm__c,Core_MDF_Target_Audience__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,Core_MDF_Proposal_Based_Ind__c,
                                Core_MDF_Media_Vehicle__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Name,Core_MDF_Bank__r.Core_MDF_Bank_Status__c,Core_MDF_Bank__r.Core_MDF_Bank_Alias_Name__c,Core_MDF_Invoice_Number__c,Core_MDF_Invoice_Date__c,
                                Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Currency__c,toLabel(Core_MDF_Currency__c) Currency_Label,
                                Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Taxes_Local__c,Core_MDF_Claim_Comments__c,Core_MDF_NoOfImpressions_Nbr__c,Core_MDF_NoOfEngagements_Nbr__c,Core_MDF_No_of_Leads_nbr__c,Core_MDF_NoOfTrialActivations_Nbr__c,RecordType.DeveloperName,
                                Core_MDF_Type_Txt__c,Core_MDF_Country_Location_nm__c,Request.Core_MDF_Country_nm__c,RequestId,Core_MDF_Program__c,Core_MDF_Claim_Submitter_Id__c,Core_MDF_Claim_Submitter_Id__r.name,
                                Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id,Core_MDF_Ultimate_Account_ID__c,
                                Request.Campaign.Name,Request.Core_MDF_Brand_nm__c,Request.Campaign.Description,Core_MDF_Activity_SubType_nm__c,toLabel(Core_MDF_Activity_SubType_nm__c) LocalizedActivitySubType,Request.Core_MDF_POP_Requirements_txt__c,Core_MDF_VAT_Opt_In__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Request.ChannelPartner.Core_MDF_Channel_Program__r.Name,
                                Core_MDF_Paid_By_Payment_Type_nm__c, Request.ChannelPartner.Core_MDF_Payment_Type_nm__c, Request.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c,Core_MDF_Campaign_Id__r.Core_MDF_Terminal_Rejection_Ind__c, Request.Core_MDF_Fund_Request_Status__c,
				Request.Core_MDF_NEX_Ind__c, Request.Core_MDF_Key_Marketing_Indicator_nm__c, Request.Core_MDF_Deployment_Quantity_nbr__c, Request.Core_MDF_Lead_Quantity_nbr__c, Request.Core_MDF_Other_Quantity_nbr__c,Core_MDF_CSP_Intel_Based_Revenue_amt__c, Core_MDF_Processing_Preference_nm__c, Request.Core_MDF_Is_Outcome_Based_Ind__c,Core_MDF_OutcomeBased_Ind__c,Request.Core_MDF_Activity_Description__c,Request.Core_MDF_Parent_Activity_Id__c,Request.Core_MDF_Activity_Level_nm__c FROM PartnerFundClaim WHERE Id=:recId LIMIT 1];
        //added querying 2 fields by Vaishali for owner change//Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id  
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
        ClaimCountryDetailsWrapper claimCountryDetailsWrap = new ClaimCountryDetailsWrapper();
        claimCountryDetailsWrap.isValidCloneOrEditUser = false;
        List<String> restrictedPFRStatusesToCreateClaim = Core_MDF_CCP_ConstantClass.NRE_RESTRICTED_PFR_STATUSES_TO_CREATE_CLAIM;
        Map<String, String> countryOptionsMap = new Map<String, string>();
       countryOptionsMap = Core_MDF_PartnerFundClaim.getPickListvalues('PartnerFundClaim','Core_MDF_Country_Location_nm__c');
        if(pfc != NULL){
           for(PartnerFundRequest pfr : [SELECT Id,toLabel(Core_MDF_Country_nm__c) countryNameLocalized,Core_MDF_Country_nm__c,toLabel(Core_MDF_Activity_SubType_nm__c) LocalizedActivitySubType, Core_MDF_Activity_SubType_nm__c,toLabel(Core_MDF_Budget_Type_nm__c) LocalizedBudgetType, Core_MDF_Program__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Id =:pfc.RequestId limit 1]){
               if(pfr.Core_MDF_Program__c != 'Co-GTM') {
                   Map<String,String> countryNewMap = new Map<String,String>();
                   List<String> localizedCountryValues = new List<String>();
                   List<String> countryList = pfr.Core_MDF_Country_nm__c.split(';');
                   countryList.sort();
                   if(countryList != null && countryList.size() > 0 && !countryOptionsMap.isEmpty()) {
                       for(String country: countryList) {
                           if(countryOptionsMap.containsKey(country) && countryOptionsMap.get(country) != null) {
                               localizedCountryValues.add(countryOptionsMap.get(country));
                           }
                       }
                   }
                   countryNewMap.put(String.join(countryList,';'),String.join(localizedCountryValues,';'));
                   Map<String,String> activitySubTypeNewMap = new Map<String,String>();
                   activitySubTypeNewMap.put(String.valueOf(pfr.Core_MDF_Activity_SubType_nm__c),String.valueOf(pfr.get('LocalizedActivitySubType')));
                   claimCountryDetailsWrap.countryMap = countryNewMap;
                   claimCountryDetailsWrap.activitySubTypeMap = activitySubTypeNewMap;
               }
                String activityBudgetType = String.valueOf(pfr.get('LocalizedBudgetType'));
                Boolean isValidCloneOrEditUser = isValidCloneOrEditUser(pfc);
                claimCountryDetailsWrap.claimObj = pfc;
                claimCountryDetailsWrap.activityBudgetType = activityBudgetType;
                claimCountryDetailsWrap.isValidCloneOrEditUser = isValidCloneOrEditUser;
                if(pfc.Request.Core_MDF_Fund_Request_Status__c != declinedStatus){
                    claimCountryDetailsWrap.isAssociatedPFRNotDeclined = true;
                }
                else{
                    claimCountryDetailsWrap.isAssociatedPFRNotDeclined = false;
                }
               if(pfr.Core_MDF_Program__c == ipaProgram  && restrictedPFRStatusesToCreateClaim.contains(pfr.Core_MDF_Fund_Request_Status__c)) {
                   claimCountryDetailsWrap.hasRestrictedStatusToCreateClaim = true;
               }
            }
        }
        return claimCountryDetailsWrap;
        
    }
    /***************************************************************************************************** 
Method Name:        isPartner
@return  :          Boolean
@parameters:         
Description:        Identify whether it is an External User
@Added By:          HA
******************************************************************************************************/
    public static boolean isPartner() {
        string userType = UserInfo.getUserType();
        if (
            userType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type') //Label.Core_MDF_Partner_User_Type
        ) {
            return true;
        } else {
            return false;
        }
    }
    
      /******************************************************************************************************
       Method Name:        isValidCloneOrEditUser
       @return  :          Boolean
       @parameters:        PartnerFundClaim Obj record
       Description:        This method is used to decide the clone/edit access
       Added By:           Accenture - VB - 17/04/2023
       Modified By:        Date:       Changes:
     *******************************************************************************************************/
    public static Boolean isValidCloneOrEditUser(PartnerFundClaim pfc) {
        Boolean isValidCloneOrEditUser = false;
        if (pfc != null && pfc.Core_MDF_Program__c == Label.Core_MDF_IPA_Program_Name) {
            if (isPartner()) {
                isValidCloneOrEditUser = isPartnerValidCloneOrEditUser(pfc);
            } 
            else {
                isValidCloneOrEditUser = true;
            }
        } 
        else {
            isValidCloneOrEditUser = true;
        }
        
        return isValidCloneOrEditUser;
    }

    public static Boolean isPartnerValidCloneOrEditUser(PartnerFundClaim pfc){
        Boolean haseAccess = false;
        Boolean isProposalBasedClaim = pfc.Core_MDF_Proposal_Based_Ind__c;
        String recordTypeDeveloperName = pfc.RecordType.DeveloperName;
        if ((recordTypeDeveloperName == Label.Core_MDF_IPA_AccountBased_RecType_DevName && !isProposalBasedClaim && FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Account_Based_User')) ||
            (recordTypeDeveloperName == Label.Core_MDF_IPA_RecordType && isProposalBasedClaim && FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Based_User'))) {
                haseAccess = true;
        } 
        else {
            haseAccess = false;
        }
        return haseAccess;
    }
    
     /******************************************************************************************************
       Method Name:        hasAccessToEditClaim
       @return  :          Boolean
       @parameters:        Claim recordId
       Description:        This method is used to decide the edit claim access
       Added By:           Accenture - VB - 17/04/2023
       Modified By:        Date:       Changes:
     *******************************************************************************************************/
    @AuraEnabled
    public static Boolean hasAccessToEditClaim(Id recordId) {
        Boolean hasAccessToEditClaim = false;
        try {
            ClaimCountryDetailsWrapper wrapper = fetchClaimById(recordId);
            Boolean hasObjEditAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectEditPermission(
                'PartnerFundClaim'
            );
            if (wrapper != null) {
                if (hasObjEditAccess && wrapper.isValidCloneOrEditUser) {
                    hasAccessToEditClaim = true;
                } else {
                    hasAccessToEditClaim = false;
                }
            }
        } catch (Exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
        return hasAccessToEditClaim;
    }
    
    public class ClaimCountryDetailsWrapper {
        @AuraEnabled
        public PartnerFundClaim claimObj;
        @AuraEnabled
        public Map<String,String> countryMap;
        @AuraEnabled
        public Map<String,String> activitySubTypeMap;
        @AuraEnabled
        public String activityBudgetType;
        @AuraEnabled
        public Boolean isValidCloneOrEditUser;
        public Boolean isAssociatedPFRNotDeclined;
        @AuraEnabled
        public Boolean hasRestrictedStatusToCreateClaim;
    }

    public class claimAccessWrapper {
        @AuraEnabled
        public Boolean hasAccessToCloneClaim;
        @AuraEnabled
        public Boolean isAssociatedPFRNotDeclined;
        @AuraEnabled
        public Boolean hasRestrictedStatusToCreateClaim;
        @AuraEnabled
        public String program;
    }
}