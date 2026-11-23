/****************************************************************************************************** 
Class Name:         Core_MDF_PFR_Grid
@parameters:        N/A
Description:        Handler class for Core_MDF_PFR_Grid LWC Component
Added By:           JB - 04/02/2025
Modified By:        Date:           Changes:
JB                  04/02/2025      Created
*******************************************************************************************************/
public without sharing class Core_MDF_PFR_Grid {
    /****************************************************************************************************** 
    Method Name:        getExistingActivityDetails
    @return  :          List<Sobject>
    @parameters:        campaignId
    Description:        To get activity list based on campaign Id Provided for NRE Program
    Added By:           JB - 04/02/2025
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static ActivityDetailsWrapper getExistingActivityDetails(String campaignId){
        return new Core_MDF_PFR_Grid_InnerClass().getExistingActivityDetails(campaignId);
        
    }
    
    /****************************************************************************************************** 
    Method Name:        getBudgetDetails
    @return  :          List<PartnerMarketingBudget>
    @parameters:        campaignId
    Description:        To get Budget Details
    Added By:           JB - 04/02/2025
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<PartnerMarketingBudget> getBudgetDetails(String campaignId){
        Set<String> budgetIdSet = new Set<String>();
        List<PartnerMarketingBudget> budgetDetails = new List<PartnerMarketingBudget>();
        try {
            if(String.isNotBlank(campaignId)){
                String sanitizedCampaignId = String.escapeSingleQuotes(campaignId);
                for(Core_MDF_Campaign_Budgets__c campaignBudgets : [SELECT Id, Core_MDF_Budget_Name_Id__c, Core_MDF_Budget_Name_Id__r.Title,Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c, Core_MDF_Budget_Name_Id__r.Amount, Core_MDF_Start_Date_Dt__c, Core_MDF_End_Date_Dt__c FROM Core_MDF_Campaign_Budgets__c WHERE Core_MDF_Campaign_Id__c =: sanitizedCampaignId AND Core_MDF_Active_ind__c = true]){
                    budgetIdSet.add(campaignBudgets.Core_MDF_Budget_Name_Id__c);
                }
                
                if(!budgetIdSet.isEmpty()){
                    budgetDetails = [SELECT Id, Title, StartDate, EndDate, Core_MDF_budget_ref_nbr__c, Amount, Core_MDF_Budget_Partner__r.name, Core_MDF_Ultimate_Account_Id__c, Core_MDF_AccountCompany__c FROM PartnerMarketingBudget WHERE Id IN: budgetIdSet ORDER BY CreatedDate DESC];
                }
            }
        }catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
           

        return budgetDetails;
    }

    /****************************************************************************************************** 
    Method Name:        insertRecords
    @return  :          Boolean
    @parameters:        insertRecordList
    Description:        To insert a record
    Added By:           JB - 04/02/2025
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static Boolean insertRecords(List<PartnerFundRequest> insertRecordList){
        Boolean recordInserted = false;
        try {
            if(!insertRecordList.isEmpty()){
                Database.insert(insertRecordList, true);
                recordInserted = true;
            }
        } catch (Exception e) {
            recordInserted = false;
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return recordInserted;
    }

    /****************************************************************************************************** 
    Method Name:        getCampaignDetails
    @return  :          Boolean
    @parameters:        campaignId
    Description:        To get Campaign Details
    Added By:           JB - 04/02/2025
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static Boolean getCampaignDetails(String campaignId){
        Boolean allowToCreate = false;
        try {
            if(String.isNotBlank(campaignId)){
                String sanitizedCampaignId = String.escapeSingleQuotes(campaignId);
                List<String> allowedStatusList = Core_MDF_CCP_ConstantClass.NRE_ALLOWED_STATUSES_TO_CREATE_ACTIVITY;
                List<Campaign> campList = [SELECT Id, Status, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c FROM Campaign WHERE Id =: sanitizedCampaignId];
                if(!campList.isEmpty() && allowedStatusList.contains(campList[0].Status)){
                    Id currentUserId = UserInfo.getUserId();
                    List<String> accMgrRolesList = new List<String>{Label.Core_MDF_CCP_NRE_Account_Manager};
                    
                    if(FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Account_Manager')){
                        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = [SELECT Id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                                    WHERE Core_MDF_Active_Ind__c = TRUE and Core_MDF_User_id__c =: currentUserId AND 
                                                                                    Core_MDF_Account_id__c =: campList[0].Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c AND 
                                                                                    Core_MDF_Program_nm__c ='CoGTM' AND Core_MDF_Role_nm__c IN: accMgrRolesList];
                        if(!iupgmList.isEmpty()){
                            allowToCreate = true;
                        }
                    }
                    //Akash - Added else if condition.
                    else if(FeatureManagement.checkPermission('Core_MDF_CCP_External_Co_GTM_Project_Submitter')){
                        List<Core_MDF_Partner_Node_User_Mapping__c> pnum = [SELECT Id,Core_MDF_Account__c, Core_MDF_User__c
                                                                            FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                                            WHERE Core_MDF_Account__c =: campList[0].Core_MDF_Account__c AND
                                                                            Core_MDF_Active_Ind__c = TRUE AND Core_MDF_User__c =: currentUserId
                                                                            and Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = 'CoGTM'];
                        if(!pnum.isEmpty()){
                            allowToCreate = true;
                        }
                    }
                }
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }

        return allowToCreate;
    }

    public class ActivityDetailsWrapper{
        @AuraEnabled public List<Sobject> activityOrCampaignList { get; set; }
        @AuraEnabled public String recordBaseUrl { get; set; }
    }

    public with sharing class Core_MDF_PFR_Grid_InnerClass {
        public ActivityDetailsWrapper getExistingActivityDetails(String campaignId){
            try {
                if(String.isNotBlank(campaignId)){
                    ActivityDetailsWrapper activityDetials = new ActivityDetailsWrapper();
                    String sanitizedCampaignId = String.escapeSingleQuotes(campaignId);
                    List<Sobject> activityList = [SELECT Id, Campaign.StartDate, Campaign.EndDate, Campaign.Core_MDF_Account__c, Title, Core_MDF_Activity_Number__c, 
                    Core_MDF_Activity_Classification_nm__c, Core_MDF_Activity_Engineering_Nm__c, Core_MDF_Other_Engineering_Activity_txt__c, 
                    Core_MDF_End_Date__c, BudgetId, Amount, Core_MDF_Budget_Amount_Local_amt__c, Core_MDF_POP_Requirement_nm__c, Core_MDF_Fund_Request_Status__c , Core_MDF_Program__c 
                    FROM PartnerFundRequest WHERE CampaignId =: sanitizedCampaignId AND Core_MDF_Fund_Request_Status__c !=: Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS];
        
                    if(!activityList.isEmpty()){
                        activityDetials.activityOrCampaignList = activityList;
                    }else {
                        List<Campaign> campaignList = [SELECT Id, Status, Name, StartDate, EndDate, Core_MDF_Account__c, Core_MDF_Channel_Program__r.Name FROM Campaign WHERE Id =: sanitizedCampaignId];
                        activityDetials.activityOrCampaignList = campaignList;
                    }
    
                    String userType = UserInfo.getUserType();
                    String recordBaseUrl = '/';
                    if(userType == 'PowerPartner'){
                        recordBaseUrl = Label.Core_MDF_PFRCommunityLink;
                    }
                    activityDetials.recordBaseUrl = recordBaseUrl;
                    return activityDetials;
                }
            }catch (Exception e) {
                Core_MDF_CCP_UtilityClass.logError(e);
            }
    
            return null;
        }
    }
}