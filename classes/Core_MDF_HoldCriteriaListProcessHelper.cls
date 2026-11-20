/****************************************************************************************************************************************
* Class Name  : Core_MDF_HoldCriteriaListProcessHelper
* Version     : 1.0 
* Created Date: 05/10/2019
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture -JV    05/10/2019         This class process claims for criteria Hold functionality and update claim records.
* NP(11630236)     04/03/2020         Querying Core_MDF_Budget_Type_Options_Nm__c to enable RMF Case creation
*****************************************************************************************************************************************/
public without sharing class Core_MDF_HoldCriteriaListProcessHelper {
    /***************************************************************************************************** 
    Method Name:        processClaimsForCriteriaHold
    @return  :          void
    @parameters:        newClaimsMap - This will contain all new claims which to be processed
    Description:        This function is used to process claims for criteria hold
    @Added By:          Accenture - JV - 05/10/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    public static List<PartnerFundClaim> processClaimsForCriteriaHold(List<PartnerFundClaim> newClaimList) {
        List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>(); 
        try{
            if(newClaimList!=null && newClaimList.size()>0){
            claimsToBeUpdated = recalculateClaimsForCriteriaHold(newClaimList);
            }
            return claimsToBeUpdated;
        }catch(Exception e){
		Core_MDF_CCP_UtilityClass.logError(e); 
		return newClaimList;
	}
        
    }


    /***************************************************************************************************** 
    Method Name:        recalculateClaimsForCriteriaHold
    @return  :          List<PartnerFundClaim> :
    @parameters:        newClaimsTobeProcessed - This will contain all  claims to be processed for critera hold
    Description:        This function is used to recalculate claims for critria hold for Create and Edit scenario of Claim
    @Added By:          Accenture - JV - 05/10/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
     public static List<PartnerFundClaim> recalculateClaimsForCriteriaHold(List<PartnerFundClaim> newClaimsTobeProcessed) {
        
        // Generate collections to filter the Criteria Records 
        //To hold claim ultimate account
        Set<Id> ultimateAccSet = new Set<Id>();
        //To hold geo->country 
        Set<String> geoCountrySet = new Set<String>();
        //To hold channel program
        Set<Id> channelProgramSet = new Set<Id>();
        //To hold activity category
        Set<String> activityCategorySet = new Set<String>();
        //To hold Geo Set
        Set<String> geoSet = new Set<String>();
        //map of criteria and list of claims
        Map<Id,List<PartnerFundClaim>> criteriaIdToClaimListMap = new Map<Id,List<PartnerFundClaim>>();
        //Map of category and category->Type
        Set<String> activityCategoryTypeSet = new Set<String>();
        //Map<String,String> categorytoCategoryTypeMap = new Map<String,String>();// DE83250, to fix this defect we are using set now instead of this map
        //Map of country and Geo
        // hold final list of claims which will be processed for update
        List<PartnerFundClaim> claimsToBeProcessedForCriteriaHold = new List<PartnerFundClaim>();
        
        Set<Id> clmIds = new Set<Id>();

        for(PartnerFundClaim clm : newClaimsTobeProcessed){
            clmIds.add(clm.Id);
        }

        //fetch current claims 
         Map<Id,PartnerFundClaim> newClaimMap = new Map<Id,PartnerFundClaim>([SELECT Id,Core_MDF_IsClaimReviewEscalation_Ind__c,requestId,Amount,
                                                                              Core_MDF_Criteria_Hold_No_Id__c,
                                                                              Core_MDF_Criteria_Hold_Ref_No_Txt__c,ChannelPartnerId,
                                                                              Core_MDF_Country_Location_nm__c,Core_MDF_Activity_Types__c,
                                                                              Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Status__c,
                                                                              LastModifiedDate,request.ChannelPartner.Core_MDF_Channel_Program__c,
                                                                              CreatedById,Core_MDF_Program__c,
                                                                              request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
                                                                              Core_MDF_Activity_Category__c,Core_MDF_Claim_Ref_Number__c,
                                                                              CreatedDate,Core_MDF_Audit_Type__c,
                                                                              Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Hold__c,
                                                                              Core_MDF_AuditSelectionInProgress__c,Core_MDF_Predictive_Audit_Error__c,
                                                                              Core_MDF_Predictive_Audit_Retries__c,Core_MDF_Pred_ModelTimeStamp__c,
                                                                              Core_MDF_Pred_PredictionResult__c,Core_MDF_Pred_PredictionScore__c,
                                                                              Core_MDF_Pred_Probability__c,Core_MDF_Pred_ThresholdFlag__c,
                                                                              Core_MDF_Pred_IdealModelResult__c,Core_MDF_AccountCompany__c,
                                                                              Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Claim_Submitter_Id__c,
                                                                              Core_MDF_Escalation_Id__c, Core_MDF_Escalation_Id__r.RecordTypeId,
                                                                              Core_MDF_Escalation_Id__r.Core_MDF_Claim_Submitter_Id__c, OwnerId,
                                                                              Core_MDF_Escalation_Id__r.Core_MDF_Escalation_Type_nm__c,
                                                                              Core_MDF_Escalation_Id__r.Core_MDF_Do_not_Auto_Create_Claim_Ind__c,
                                                                              Core_MDF_VAT_Hold_Ind__c,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Bank__c,Core_MDF_Aud_chk_completed_Ind__c,
									      Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c, Core_MDF_Document_Hold_Ind__c, Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c, Request.Core_MDF_Is_Outcome_Based_Ind__c //Roshan
                                                                              FROM partnerfundClaim where ID IN:clmIds]);
        
        //creating all sets based on incoming claims newClaimsTobeProcessed
        for(PartnerFundClaim claimRecord :newClaimMap.values()){
            if(isClaimEligibleForCriteriaHold(claimRecord)){
                ultimateAccSet.add(String.escapeSingleQuotes(claimRecord.request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                channelProgramSet.add(String.escapeSingleQuotes(claimRecord.request.ChannelPartner.Core_MDF_Channel_Program__c));
                activityCategorySet.add(String.escapeSingleQuotes(claimRecord.Core_MDF_Activity_Category__c));
                //categorytoCategoryTypeMap.put(String.escapeSingleQuotes(claimRecord.Core_MDF_Activity_Types__c),String.escapeSingleQuotes(claimRecord.Core_MDF_Activity_Category__c)+'->'+String.escapeSingleQuotes(claimRecord.Core_MDF_Activity_Types__c)); 
                activityCategoryTypeSet.add(String.escapeSingleQuotes(claimRecord.Core_MDF_Activity_Category__c)+'->'+String.escapeSingleQuotes(claimRecord.Core_MDF_Activity_Types__c));
                geoCountrySet.add(String.escapeSingleQuotes(claimRecord.Core_MDF_Region_Cd__c) +'->'+ String.escapeSingleQuotes(claimRecord.Core_MDF_Country_Location_nm__c));
                geoSet.add(String.escapeSingleQuotes(claimRecord.Core_MDF_Region_Cd__c)); 
                }
        }

        // Prepare Strings for all the MultiSelect fields 
        String actCategoryString = getCommaSeperatedStringFromSet(activityCategorySet);
        String categorytoCategoryTypeString = getCommaSeperatedStringFromSet(activityCategoryTypeSet); //getCommaSeperatedStringFromMap(categorytoCategoryTypeMap);
        String geoString = getCommaSeperatedStringFromSet(geoSet);
        String geoCountryString = getCommaSeperatedStringFromSet(geoCountrySet);
        
        //Dynamic SOQL for filtering all the Criteria Rules
        String criteriaRuleQuery = 'SELECT Id,Name,Core_MDF_UltimateAccount_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Ineffective_Dt__c,Core_MDF_Program_id__c,Core_MDF_Threshold_Amt__c,Core_MDF_Activity_Category_Txt__c,Core_MDF_Region_Country_txt__c,Core_MDF_Activity_Category_Type_Txt__c,Core_MDF_Geo_Txt__c FROM Core_MDF_Hold_Criteria__c WHERE (Core_MDF_UltimateAccount_Id__c IN:ultimateAccSet OR Core_MDF_Program_id__c IN:channelProgramSet OR Core_MDF_Activity_Category_Txt__c INCLUDES('+actCategoryString+') OR Core_MDF_Activity_Category_Type_Txt__c INCLUDES('+categorytoCategoryTypeString+') OR Core_MDF_Region_Country_txt__c INCLUDES('+geoCountryString+') OR Core_MDF_Geo_Txt__c INCLUDES('+geoString+') ) AND (Core_MDF_Effective_Dt__c <= TODAY AND Core_MDF_Ineffective_Dt__c > TODAY )';
        
        List<Core_MDF_Hold_Criteria__c> filteredCriteriaRecordsList = new List<Core_MDF_Hold_Criteria__c>();
        // Query the Criteria Rule Records only if the above prepared collections are not empty
        if(ultimateAccSet.size() > 0 || activityCategorySet.size() > 0 || channelProgramSet.size() > 0 || geoCountrySet.size() > 0 || activityCategoryTypeSet.size() > 0 || geoSet.size() > 0)
        {
            filteredCriteriaRecordsList = Database.query(criteriaRuleQuery);
        } 
         
        for(PartnerFundClaim claimRecord : newClaimMap.values())
        {    
            if(isClaimEligibleForCriteriaHold(claimRecord))
            {
                for(Core_MDF_Hold_Criteria__c criteria : filteredCriteriaRecordsList)
                {
                    if(
                        ((claimRecord.Core_MDF_Criteria_Hold_Ref_No_Txt__c != null && !((claimRecord.Core_MDF_Criteria_Hold_Ref_No_Txt__c).contains(criteria.name)))
                          || (claimRecord.Core_MDF_Criteria_Hold_Ref_No_Txt__c == null)
                        )
                    ){
                        if(
                            (   
                                (claimRecord.LastModifiedDate).date() >= criteria.Core_MDF_Effective_Dt__c 
                                &&
                                (claimRecord.LastModifiedDate).date() <= criteria.Core_MDF_Ineffective_Dt__c
                            )  
                            &&
                            (   (criteria.Core_MDF_UltimateAccount_Id__c == null || claimRecord.request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c == criteria.Core_MDF_UltimateAccount_Id__c) 
                                &&
                                (criteria.Core_MDF_Region_Country_txt__c == null || (criteria.Core_MDF_Region_Country_txt__c != null &&(criteria.Core_MDF_Region_Country_txt__c).contains(claimRecord.Core_MDF_Country_Location_nm__c)))
                                &&
                                (criteria.Core_MDF_Program_id__c == null || (claimRecord.request.ChannelPartner.Core_MDF_Channel_Program__c == criteria.Core_MDF_Program_id__c))
                                &&
                                (criteria.Core_MDF_Threshold_Amt__c == null || claimRecord.Amount > criteria.Core_MDF_Threshold_Amt__c) 
                                &&
                                (criteria.Core_MDF_Activity_Category_Txt__c == null || (criteria.Core_MDF_Activity_Category_Txt__c != null
                                    &&(criteria.Core_MDF_Activity_Category_Txt__c).contains(claimRecord.Core_MDF_Activity_Category__c)))
                                &&
                                (criteria.Core_MDF_Activity_Category_Type_Txt__c == null || (criteria.Core_MDF_Activity_Category_Type_Txt__c != null
                                    &&(criteria.Core_MDF_Activity_Category_Type_Txt__c).contains(claimRecord.Core_MDF_Activity_Category__c+'->'+claimRecord.Core_MDF_Activity_Types__c)))
                                &&
                                (criteria.Core_MDF_Geo_Txt__c == null || (criteria.Core_MDF_Geo_Txt__c != null
                                    &&(criteria.Core_MDF_Geo_Txt__c).contains(claimRecord.Core_MDF_Region_Cd__c)))
                            )
                        )
                        {
                            prepareClaimForCriteriaHold(claimRecord,criteria);
                            break;
                        }
                    }            
                } 
            }          
        }
        return newClaimMap.values();
     
     
 }

    /***************************************************************************************************** 
    Method Name:        prepareClaimForCriteriaHold
    @return  :          PartnerFundClaim
    @parameters:        pfc - claim record
                        criteria - hold criteria record
    Description:        This function is used to update all claims
    @Added By:          Accenture - JV - 05/08/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static PartnerFundClaim prepareClaimForCriteriaHold(PartnerFundClaim pfc,Core_MDF_Hold_Criteria__c criteria)
    {          
        //change status to hold
        pfc.Core_MDF_Status__c = Label.Core_MDF_Hold_Status;
        //Change criteria hold flag to true
        pfc.Core_MDF_Criteria_Hold_Ind__c = true;
        //Stamp criteria hold #
        pfc.Core_MDF_Criteria_Hold_No_Id__c = criteria.Id;
        //Cheking criteria hold ref no for null
        if(pfc.Core_MDF_Criteria_Hold_Ref_No_Txt__c == null){
            //stamp criteria hold ref 
            pfc.Core_MDF_Criteria_Hold_Ref_No_Txt__c  = criteria.name;                  
        }
        else
        {   //checking hold list ref no , if its contains current criteria Id take other criteria ID and update the ref field,
            pfc.Core_MDF_Criteria_Hold_Ref_No_Txt__c  = pfc.Core_MDF_Criteria_Hold_Ref_No_Txt__c+','+criteria.name;                 
        }
        return pfc;
    }

    /***************************************************************************************************** 
    Method Name:        isClaimEligibleForCriteriaHold
    @return  :          Boolean
    @parameters:        pfc - claim record
    Description:        This function is used to check if the Claim is eligible for Criteria Hold
    @Added By:          Accenture - JV - 05/16/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static Boolean isClaimEligibleForCriteriaHold(PartnerFundClaim pfc)
    {         
        // valid claim status to filter (Pending Due, Submitted, Pending available fund)
        List<String> validClaimStatusForCriteriaHold = (Label.Core_MDF_ValidClaimStatusForCriteriaHold).split(',');
         
        if(!pfc.Core_MDF_Criteria_Hold_Ind__c && validClaimStatusForCriteriaHold.contains(pfc.Core_MDF_Status__c)){
            return true;
        }else{return false;}
    } 

    /***************************************************************************************************** 
    Method Name:        getCommaSeperatedStringFromSet
    @return  :          String
    @parameters:        Set - Activity Category, Geo, GeoCountry
    Description:        This function is used to return the comma seperated string based on the input Set;
                        which is used to query the Criteria Rule Records
    @Added By:          Accenture - JV - 05/20/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static String getCommaSeperatedStringFromSet(Set<String> inputSet)
    {         
        String commaSeperatedString = '';
        for(String input : inputSet){
            commaSeperatedString += '\''+String.escapeSingleQuotes(input)+'\',';
        }
        commaSeperatedString = commaSeperatedString.removeEnd(',');
        return commaSeperatedString;
    } 
}