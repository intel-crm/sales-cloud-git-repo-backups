//Core_MDF_Prop_Based_Camp_Process_Test
public without sharing class Core_MDF_Proposal_Based_Campaign_Process {
    public class CustomException extends Exception{}
    public static Map<Id,List<PartnerFundRequest>> propBasedCampIdPfrListIdMap = new Map<Id,List<PartnerFundRequest>>();
    public static List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>(); 
    public static Map<Id,set<String>> campIdActSubTypeSet = new Map<Id,set<String>>();
    public static Map<Id,set<String>> campIdActCatTypesSet = new Map<Id,set<String>>();
    public static Map<Id,set<String>> campIdActCatSet = new Map<Id,set<String>>();
    public static Map<Id,set<String>> campIdActTypeSet = new Map<Id,set<String>>();
    public static Boolean runOnce = true;
    public static Boolean camprunonce = true;
    public static Boolean flag = true;
    public static Map<Id,Decimal> budgetAmtMap = new Map<Id,Decimal>();
    public static List<Id> ipaCampaignRecordTypeID  = new List<Id>();   
    public static Id ipaCampRecTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    public static Id dcfRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_CoMarketing_Fund').getRecordTypeId();
    public static Id ccfRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId(); 
    public static Id retailRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(); 
    public static Id eefRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();    
    public static Map<String, List<String>> cmpToActClassificationMap = new Map<String, List<String>>();
    public static Set<Id> setOfValidMarketingActivity = new Set<Id>();
    public static Map<Id,List<PartnerFundRequest>> propBasedCampIdCancelledPfrListIdMap = new Map<Id,List<PartnerFundRequest>>();
    public static Map<Id,List<PartnerFundRequest>> propBasedCampIdClosedPfrListIdMap = new Map<Id,List<PartnerFundRequest>>();
    public static List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>(); 
    public static Map<Id,List<PartnerFundClaim>> propBasedCampIdPfcListIdMap = new Map<Id,List<PartnerFundClaim>>();
    public static Map<Id,List<PartnerFundClaim>> propBasedCampIdCancelledPfcListIdMap = new Map<Id,List<PartnerFundClaim>>();
    public static Map<Id,Decimal> budgetIdInProgCompPfrListIdMap = new Map<Id,Decimal>();
    public static String pendingReview = Core_MDF_CCP_ConstantClass.CAMPAIGN_PENDING_REVIEW;
    public static String proposalAccepted =  Core_MDF_CCP_ConstantClass.CAMPAIGN_PROPOSAL_ACCEPTED;
    public static String inProgressStatus= Core_MDF_CCP_ConstantClass.CAMPAIGN_IN_PROGRESS;
    public static String plannedStatus = Core_MDF_CCP_ConstantClass.CAMPAIGN_PLANNED;
    public static String revisionRequiredStatus =  Core_MDF_CCP_ConstantClass.CAMPAIGN_REVISION_REQUIRED;
    public static String declinedStatus = Core_MDF_CCP_ConstantClass.CAMPAIGN_DECLINED;
    public static String cancelledStatus = Core_MDF_CCP_ConstantClass.CAMPAIGN_CANCELLED;
    public static String campaignAccepted =  Core_MDF_CCP_ConstantClass.CAMPAIGN_ACCEPTED;  // Roshan - CoGTM Intermediate status
    //added by JK to replace prime id field with UCD field
    public static boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
    public static List<Core_MDF_BudgetType_Benefit_Mapping__mdt> budgetTypeBenefitMapping = new List<Core_MDF_BudgetType_Benefit_Mapping__mdt>();
    public static  String objectApiName = 'Core_MDF_BudgetType_Benefit_Mapping__mdt';
    public static Set<Id> campsWithActiveEscalations = new Set<Id>();
    public static Map<Id, List<Core_MDF_Contract_Line_Item__c>> campaignIdToContractsMap = new Map<Id, List<Core_MDF_Contract_Line_Item__c>>();  //Roshan - to store Campaigns with Contract records
    public static Map<Id,set<String>> campIdActTacticsSet = new Map<Id,set<String>>();  //Roshan - Tactics for IPA Approval
    public static String ipaProgram = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
    public static String cogtmProgram = Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM;

    //Query PFR records on Campaigns
    public static void queryPFRRecords(List<Campaign> newCampList) {
        
        List<string> excludedActivityStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Excluded_Activity_Statuses').split(',');
        //US830850: [IPA] : Validation for edits made to Total Campaign cost - include Closed - No approval submission
        List<string> excludedActivityClosureTypes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Excluded_Act_Closure_Types').split(',');
        //US774498: [IPA] : Validation for edits made to Total Campaign cost WW46
        Set<Id> campId = new Set<Id>();

        for(Campaign camp : newCampList) {
            campId.add(camp.Id);
        }

        for(PartnerFundRequest propBasedPfr : [SELECT Id,Title,CampaignId,Core_MDF_Fund_Request_Status__c, Core_MDF_ActivityCategory__c, Core_MDF_Activity_SubType_nm__c,Core_MDF_Price_reviewer_check_ind__c,Core_MDF_SPIF_Modified_ind__c,
                                         Core_MDF_Activity_Types__c, RequestedAmount, Core_MDF_Start_Date__c, Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c,Core_MDF_BU_Split__c,Core_MDF_BU1_Split_Percent_nbr__c,Core_MDF_BU2_Split_Percent_nbr__c,Core_MDF_BU3_Split_Percent_nbr__c,Core_MDF_BU4_Split_Percent_nbr__c, 
                                         ChannelPartnerId, Core_MDF_Country_nm__c, Core_MDF_Reimbursement_Rate_pct__c, Core_MDF_Activity_Reimbursement_Amt_nbr__c, Core_MDF_SPIF_Segments_Available_ind__c,
                                         Core_MDF_Activity_Closure_Type__c,RecordType.DeveloperName, Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c,Core_MDF_Focus_Area_nm__c,Core_MDF_TargetAudience_nm__c,Core_MDF_TargetAudience__c,Core_MDF_Priorities__c,
                                         Core_MDF_Priority_nm__c, Core_MDF_Technology_txt__c, Core_MDF_Industry_Multi_nm__c,Core_MDF_Initiative_nm__c,Core_MDF_ProductType__c,Core_MDF_Brand_nm__c,
                                         Core_MDF_EcosystemPartner_nm__c,Core_MDF_Activity_Classification_nm__c, Campaign.Core_MDF_Budget_Cap__c, Campaign.Status, Core_MDF_Tactics_nm__c  
                                         FROM PartnerFundRequest 
                                         WHERE CampaignId IN: campId AND 
                                         Core_MDF_Fund_Request_Status__c != 'Declined' AND
                                         Core_MDF_Activity_Closure_Type__c NOT IN :excludedActivityClosureTypes
                                         ORDER BY Core_MDF_Activity_Reimbursement_Amt_nbr__c DESC]) {
            if(propBasedPfr.Core_MDF_Activity_Classification_nm__c == 'Marketing' && propBasedPfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c >= Core_MDF_CustomLabelConfig.getDoubleValues('Core_MDF_Camp_ActBudgetAmt_Limit') && propBasedPfr.Core_MDF_Fund_Request_Status__c != 'Cancelled') {
                setOfValidMarketingActivity.add(propBasedPfr.CampaignId);
            } 
            if(Core_MDF_CCP_ConstantClass.VALID_PFR_STATUSES.contains(propBasedPfr.Core_MDF_Fund_Request_Status__c)) {
                if(propBasedPfr.CampaignId != null && (propBasedPfr.Core_MDF_Fund_Request_Status__c == 'In-Progress' || propBasedPfr.Core_MDF_Fund_Request_Status__c == 'Completed')) {
                    if(!budgetIdInProgCompPfrListIdMap.containsKey(propBasedPfr.CampaignId)) {
                        budgetIdInProgCompPfrListIdMap.put(propBasedPfr.CampaignId, 0); 
                    }
                    budgetIdInProgCompPfrListIdMap.put(propBasedPfr.CampaignId,budgetIdInProgCompPfrListIdMap.get(propBasedPfr.CampaignId)+propBasedPfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c);   
                }
                
                if(propBasedCampIdPfrListIdMap.containsKey(propBasedPfr.CampaignId)){
                    propBasedCampIdPfrListIdMap.get(propBasedPfr.CampaignId).add(propBasedPfr);
                    campIdActCatTypesSet.get(propBasedPfr.CampaignId).add(propBasedPfr.Core_MDF_ActivityCategory__c+'->'+propBasedPfr.Core_MDF_Activity_Types__c);
                    campIdActSubTypeSet.get(propBasedPfr.CampaignId).add(propBasedPfr.Core_MDF_Activity_SubType_nm__c);
                    campIdActCatSet.get(propBasedPfr.CampaignId).add(propBasedPfr.Core_MDF_ActivityCategory__c);
                    campIdActTypeSet.get(propBasedPfr.CampaignId).add(propBasedPfr.Core_MDF_Activity_Types__c);
                    cmpToActClassificationMap.get(propBasedPfr.CampaignId).add(propBasedPfr.Core_MDF_Activity_Classification_nm__c);
                    populateCampIdActTacticsSet(propBasedPfr.CampaignId, propBasedPfr.Core_MDF_ActivityCategory__c, propBasedPfr.Core_MDF_Tactics_nm__c);
    
                } else {
                    propBasedCampIdPfrListIdMap.put(propBasedPfr.CampaignId, new List<PartnerFundRequest>{propBasedPfr});
                    campIdActCatTypesSet.put(propBasedPfr.CampaignId, new set<String>{propBasedPfr.Core_MDF_ActivityCategory__c+'->'+propBasedPfr.Core_MDF_Activity_Types__c});
                    campIdActSubTypeSet.put(propBasedPfr.CampaignId, new set<String>{propBasedPfr.Core_MDF_Activity_SubType_nm__c});
                    campIdActCatSet.put(propBasedPfr.CampaignId, new set<String>{propBasedPfr.Core_MDF_ActivityCategory__c});
                    campIdActTypeSet.put(propBasedPfr.CampaignId, new set<String>{propBasedPfr.Core_MDF_Activity_Types__c});
                    budgetAmtMap.put(propBasedPfr.CampaignId,propBasedPfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
                    cmpToActClassificationMap.put(propBasedPfr.CampaignId, new List<String>{propBasedPfr.Core_MDF_Activity_Classification_nm__c});
                    populateCampIdActTacticsSet(propBasedPfr.CampaignId, propBasedPfr.Core_MDF_ActivityCategory__c, propBasedPfr.Core_MDF_Tactics_nm__c);
                }
            } else if (propBasedPfr.Core_MDF_Fund_Request_Status__c == 'Closed') {
                if(propBasedCampIdClosedPfrListIdMap.containsKey(propBasedPfr.CampaignId)) {
                    propBasedCampIdClosedPfrListIdMap.get(propBasedPfr.CampaignId).add(propBasedPfr);
                    campIdActCatTypesSet.get(propBasedPfr.CampaignId).add(propBasedPfr.Core_MDF_ActivityCategory__c+'->'+propBasedPfr.Core_MDF_Activity_Types__c);
                    populateCampIdActTacticsSet(propBasedPfr.CampaignId, propBasedPfr.Core_MDF_ActivityCategory__c, propBasedPfr.Core_MDF_Tactics_nm__c);
                } else {
                    propBasedCampIdClosedPfrListIdMap.put(propBasedPfr.CampaignId, new List<PartnerFundRequest>{propBasedPfr});
                    campIdActCatTypesSet.put(propBasedPfr.CampaignId, new set<String>{propBasedPfr.Core_MDF_ActivityCategory__c+'->'+propBasedPfr.Core_MDF_Activity_Types__c});
                    populateCampIdActTacticsSet(propBasedPfr.CampaignId, propBasedPfr.Core_MDF_ActivityCategory__c, propBasedPfr.Core_MDF_Tactics_nm__c);
                }
            } else {
                if(propBasedCampIdCancelledPfrListIdMap.containsKey(propBasedPfr.CampaignId)){
                    propBasedCampIdCancelledPfrListIdMap.get(propBasedPfr.CampaignId).add(propBasedPfr);
                } else {
                    propBasedCampIdCancelledPfrListIdMap.put(propBasedPfr.CampaignId, new List<PartnerFundRequest>{propBasedPfr});
                }
            }
            pfrList.add(propBasedPfr);
        }    
    }

    //Roshan - Tactics for IPA Approval
    public static void populateCampIdActTacticsSet(Id campaignId, String activityCategory, String tacticsField) {
        if (String.isNotBlank(tacticsField)) {
            if (!campIdActTacticsSet.containsKey(campaignId)) {
                campIdActTacticsSet.put(campaignId, new Set<String>());
            }

            List<String> tactics = tacticsField.split(';');
            for (String tactic : tactics) {
                if (String.isNotBlank(tactic)) {
                    campIdActTacticsSet.get(campaignId).add(activityCategory + '->' + tactic);
                }
            }
        }
    }
    
    //Query PFC records on Campaign
    public static void queryPFCRecords(List<Campaign> newCampList) {
        List<PartnerFundClaim> propBasedPfcList = [Select Id, Title, Core_MDF_Campaign_Id__c, Core_MDF_Status__c FROM PartnerFundClaim WHERE Core_MDF_Campaign_Id__c IN :newCampList];
        for(PartnerFundClaim propBasedPfc : propBasedPfcList) {
            if(propBasedPfc.Core_MDF_Status__c != Label.Core_MDF_Status_Cancelled && propBasedPfc.Core_MDF_Status__c != Label.Core_MDF_Claim_Status_Resubmission_Window_Closed) {
                if(propBasedCampIdPfcListIdMap.containsKey(propBasedPfc.Core_MDF_Campaign_Id__c)) {
                    propBasedCampIdPfcListIdMap.get(propBasedPfc.Core_MDF_Campaign_Id__c).add(propBasedPfc);
                } else {
                    propBasedCampIdPfcListIdMap.put(propBasedPfc.Core_MDF_Campaign_Id__c, new List<PartnerFundClaim>{propBasedPfc});
                }
            } else {
                if(propBasedCampIdCancelledPfcListIdMap.containsKey(propBasedPfc.Core_MDF_Campaign_Id__c)) {
                    propBasedCampIdCancelledPfcListIdMap.get(propBasedPfc.Core_MDF_Campaign_Id__c).add(propBasedPfc);
                } else {
                    propBasedCampIdCancelledPfcListIdMap.put(propBasedPfc.Core_MDF_Campaign_Id__c, new List<PartnerFundClaim>{propBasedPfc});
                }
            }
            pfcList.add(propBasedPfc);
        }
    }

    //Query Escalation records on Campaign
    public static void queryEscalationRecords(List<Campaign> newCampList) {
        Set<Id> activityIdSet = new Set<Id>();
        Map<Id, Id> pfrToCampaignMap = new Map<Id, Id>();
    
        for (Campaign campaign : newCampList) {
            if (propBasedCampIdClosedPfrListIdMap.containsKey(campaign.Id)) {
                for (PartnerFundRequest pfr : propBasedCampIdClosedPfrListIdMap.get(campaign.Id)) {
                    activityIdSet.add(pfr.Id);  //used to query the escalation records
                    pfrToCampaignMap.put(pfr.Id, campaign.Id);  //lookup from activity to campaign, used to populate campsWithActiveEscalations
                }
            }
        }
    
        if (!activityIdSet.isEmpty()) {
            List<AggregateResult> escResults = [SELECT Core_MDF_Co_Marketing_Activity_id__c Id, COUNT(Id) escCount FROM Core_MDF_Escalation__c 
                                                WHERE Core_MDF_Escalation_Status_nm__c IN ('Approved', 'Pending Review') 
                                                AND Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Fund_Request_Status__c = :Label.Core_MDF_PFR_Status_Closed
                                                AND Core_MDF_Co_Marketing_Activity_id__c IN :activityIdSet 
                                                GROUP BY Core_MDF_Co_Marketing_Activity_id__c];
    
            for (AggregateResult escMap : escResults) {
                Id pfrId = (Id)escMap.get('Id');
                if (pfrToCampaignMap.containsKey(pfrId)) {
                    campsWithActiveEscalations.add(pfrToCampaignMap.get(pfrId));
                }
            }
        }
    }

    //Query New Contract Section records on Campaign
    public static void queryContractRecords(List<Campaign> newCampList) {

        //campaignIdToContractsMap.clear();
        Set<Id> campaignIds = new Set<Id>();
        for (Campaign cmp : newCampList) {
            if (cmp.Id != null) {
                campaignIds.add(cmp.Id);
            }
        }

        if (!campaignIds.isEmpty()) {
            for (Core_MDF_Contract_Line_Item__c contract : [SELECT Id, Name, Core_MDF_Campaign_Id__c, Core_MDF_Inactive_Ind__c FROM Core_MDF_Contract_Line_Item__c WHERE Core_MDF_Campaign_Id__c IN :campaignIds and Core_MDF_Inactive_Ind__c = false]) {
                if (!campaignIdToContractsMap.containsKey(contract.Core_MDF_Campaign_Id__c)) {
                    campaignIdToContractsMap.put(contract.Core_MDF_Campaign_Id__c, new List<Core_MDF_Contract_Line_Item__c>());
                }
                campaignIdToContractsMap.get(contract.Core_MDF_Campaign_Id__c).add(contract);
            }
        }
    }
    
    //Called in Before Insert & Before Update
    public static void processPropBasedCampaignsBeforeInsertUpdate(List<Campaign> newCampList, Map<Id, Campaign> oldCampMap, boolean isInsert, boolean isUpdate) {
        
        Map<Id, Campaign> newCampMap = new Map<Id, Campaign>();
        List<Campaign> ipaCampaignList = new List<Campaign>();
        Map<Campaign,Id> ipaCampToacctIdMap = new Map<Campaign,Id>{};
        Map<String, Id> programtype = new Map<String, Id>();
        List<Id> campListForApproval = new List<Id>();
        Set<String> budgetTypeSet = new Set <String>();
        Date CampEarliestStartDate = Date.today();
        Date CampEarliestFutureStartDate = Date.today();
        Map<String,List<Core_MDF_Budget_Cap__c>> budgetCapListMap = new Map<String,List<Core_MDF_Budget_Cap__c>>();
        List<Campaign> campToBeUpdatedIPA = new List<Campaign>();
        Boolean cloneProposal = false;
        List<Id> campId = new List<Id>();
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        List<Campaign> IPACampList = new List<Campaign>();
        List<String> geoList = new List<String>();
        List<String> accntList = new List<String>();
        Map<String, List<String>> iupgmUserMap = new Map<String, List<String>>();
        List<String> budgetList= new List<string>();
        Boolean isStageChange = false;
        List<string> validStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Campaign_RR_ValidStatuses').split(';');
        List<Campaign> campaignsToProcess = new List<Campaign>();    //List to store inprogress and cancelled campaigns

        List<Campaign> coGtmCampList = new List<Campaign>();  //Roshan - Co-GTM campaign setup
        List<Campaign> proposalBasedCampaignList = new List<Campaign>();  //To store both IPA and CoGTM campaigns
        
        try{
            List<ChannelProgram> program = [select id , Core_MDF_Technical_Program_Name__c from ChannelProgram where isActive = TRUE LIMIT 100];

            //Query all PFRs for the Campaigns
            if(propBasedCampIdPfrListIdMap.isEmpty()) {
                queryPFRRecords(newCampList);
            }
            
            for(ChannelProgram cp : program){
                programtype.put(cp.Core_MDF_Technical_Program_Name__c, cp.id);
            }
            
            for(Campaign cmp : newCampList) {

                proposalBasedCampaignList.add(cmp);  //To store both IPA and CoGTM campaigns

                if (cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM) {
                    coGtmCampList.add(cmp);  //Will contain only CoGTM campaigns
                }
                
                //Query all PFCs for the Campaigns
           	    if (Core_MDF_CCP_ConstantClass.CAMPAIGN_STATUSES_TO_QUERY_CLAIMS.contains(cmp.Status)) {
                    campaignsToProcess.add(cmp);
                }
                
                // Roshan - Removed IPA check as this is also needed for CoGTM
                if(isUpdate && cmp.Core_MDF_Total_Campaign_Cost_Amt__c <= 0) {  
                    if(propBasedCampIdPfrListIdMap.containsKey(cmp.id)) {
                        cmp.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Proposal_TotalCost_Error'));
                    } 
                    else if(validStatuses.contains(cmp.Status) && propBasedCampIdCancelledPfrListIdMap.containsKey(cmp.id)) {
                        cmp.Status = 'Revision Required'; 
                    }
                }

                if(isInsert){
                    cmp.Core_MDF_Channel_Program__c = programtype.get(cmp.Core_MDF_Program__c);
                    cmp.Core_MDF_Terminal_Rejection_Ind__c = false;
                }else{
                    newCampMap.put(cmp.id,cmp);  // Will contain both IPA and CoGTM campaigns   
                }

                Integer startYear = cmp.startDate.year();
                Integer endYear = cmp.EndDate.year();
                cmp.Core_MDF_Supports_legacy_program__c = Core_MDF_ProcessCCP_Campaign.setSupportLegacyProgramField(startYear,cmp.Core_MDF_Opal_Budget_Type_Txt__c,cmp.Core_MDF_Program__c,endYear);

                if(isUpdate && oldCampMap != null && (oldCampMap.get(cmp.Id).Core_MDF_Approval_Stage_nm__c == '' || oldCampMap.get(cmp.Id).Core_MDF_Approval_Stage_nm__c == null)){
                      isStageChange = true;
                }

                if (cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM) {
                    if(cmp.Status == 'Pending Review') {
                        if(cmp.Core_MDF_Approval_Step_Counter_nbr__c == 0) {
                            IPACampList.add(cmp);  // Will contain IPA campaign only
                            accntList.add(cmp.Core_MDF_Ultimate_Account_txt__c);
                            geoList.add(cmp.Core_MDF_Host_Region_cd__c);
                            budgetList.add(cmp.Core_MDF_Budget_Type_txt__c);
                        }
                        if(campIdActCatTypesSet.containsKey(cmp.Id) && campIdActCatTypesSet.get(cmp.Id) != null){
                            String strVal = String.join(new List<String>(campIdActCatTypesSet.get(cmp.Id)), ';');
                            cmp.Core_MDF_Activity_Category_Type__c = strVal;
                        }

                        //Roshan - Tactics for IPA Approval
                        List<String> finalRecordsToEvaluate = new List<String>();
                        //Set<String> allEntries = new Set<String>();

                        if (campIdActCatTypesSet.containsKey(cmp.Id)) {
                            finalRecordsToEvaluate.addAll(campIdActCatTypesSet.get(cmp.Id));
                        }
                        if (campIdActTacticsSet.containsKey(cmp.Id)) {
                            finalRecordsToEvaluate.addAll(campIdActTacticsSet.get(cmp.Id));
                        }
                            //Invoke method to check for SPIF/Non-SPIF approvals
                            Map<string,boolean> mapSpifAppr = updateSPIFApprInd(finalRecordsToEvaluate);
                            if(mapSpifAppr!=null && mapSpifAppr.size()>0){
                                cmp.Core_MDF_IPA_SPIF_Apprval_Ind__c = mapSpifAppr.get('SPIF');
                                cmp.Core_MDF_IPA_NonSPIF_Apprval_Ind__c = mapSpifAppr.get('NonSPIF');
                            }                    
                        }
                    if(isUpdate && oldCampMap != null && oldCampMap.get(cmp.Id).Status != cmp.Status && (cmp.Status == 'Revision Required' || cmp.Status == 'Pending Review' || cmp.Status == 'Pending Approval') && cmp.Core_MDF_Outcome_Detail_Edited_Ind__c){
                        cmp.Core_MDF_Outcome_Detail_Edited_Ind__c = false;
                    }

                    // Roshan - IPA (budget cap code)
                    if (cmp.Core_MDF_Budget_Cap__c == null ||(oldCampMap!=null &&(  cmp.Core_MDF_Opal_Budget_Type_Txt__c != oldCampMap.get(cmp.Id).Core_MDF_Opal_Budget_Type_Txt__c || cmp.startDate!=oldCampMap.get(cmp.Id).startDate||cmp.EndDate!=oldCampMap.get(cmp.Id).EndDate))) {
                        budgetTypeSet.add(cmp.Core_MDF_Opal_Budget_Type_Txt__c);
                        if(cmp.StartDate < CampEarliestFutureStartDate ) {
                            if(cmp.StartDate < CampEarliestStartDate ) {   
                                CampEarliestStartDate =cmp.StartDate;
                            }
                        } else {
                            CampEarliestFutureStartDate = cmp.StartDate;
                            if(cmp.StartDate < CampEarliestFutureStartDate) {   
                                CampEarliestFutureStartDate =cmp.StartDate;     
                            }
                        }
                        campToBeUpdatedIPA.add(cmp);
                    }

                    // Start - US1085667 - Technical: Blank out the IPA Budget CAP when IPA campiagn is cancelled
                    if(String.isNotBlank(cmp.Status) && cmp.Status == 'Cancelled') {
                        cmp.Core_MDF_Budget_Cap__c = null;
                    }

                    ipaCampaignList.add(cmp);

                    if(isInsert || (isUpdate && cmp.Core_MDF_Opal_Budget_Type_Txt__c != oldCampMap.get(cmp.Id).Core_MDF_Opal_Budget_Type_Txt__c)) {
                        ipaCampToacctIdMap.put(cmp,cmp.Core_MDF_Account__c);  //Will contain only IPA campaigns
                    }
                }
            }

            //Roshan - IPACampList will contain only IPA campaigns
            //Added by Saikat
            if(IPACampList != NULL && IPACampList.Size() > 0 && Core_MDF_CampaignPFR_Controller.isCustomPermissionAssigned('Core_MDF_CCP_Int_IPA_ProposalL1_Approver')) {
                String role = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
                String programName = 'Intel Partner Alliance';
                String geoStr='';
                String budgetStr='';
                if(!geoList.isEmpty()){
                    geoList.add('WW');
                    geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
                }
                if(!budgetList.isEmpty()){
                    budgetStr ='(\'' + String.join(budgetList, '\', \'') + '\')';
                }
                String userId = UserInfo.getUserId();
                String query ='SELECT Id, Core_MDF_User_id__c, Core_MDF_Region_cd__c, Core_MDF_GeoSubGeo_Budget_Type_nm__c, Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c ,Core_MDF_Budget_Type_nm__c'+
                        ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                        ' WHERE Core_MDF_Program_nm__c  =: programName  and Core_MDF_Region_cd__c INCLUDES '+ geoStr +
                        ' and (Core_MDF_All_Budget_Type_Access_Ind__c = true or Core_MDF_Budget_Type_nm__c INCLUDES '+budgetStr +'  )'+
                        ' and Core_MDF_Role_nm__c =:role ' +
                        'and Core_MDF_User_id__c = : userId '+
                        ' and Core_MDF_is_User_Active_ind__c ='+ true +
                        ' and Core_MDF_Active_Ind__c ='+ true  +
                        ' and Core_MDF_Is_Not_an_Approver_Ind__c='+ false ;
                    
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord : Database.Query(query)){
                    String key;
                    String geo;
                    String budtype;
                    if(iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                        for(String regionStr : iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){
                            geo = regionStr.split('->')[0];
                            budtype = regionStr.split('->')[1];
                                
                            if (geo == 'ASMO-LAR' || geo == 'ASMO-NAR' || geo == 'ASMO'){
                                geo = 'ASMO';
                                key = geo + '->' + budtype;
                            }
                            else{
                                key = regionStr;
                            }
                            if((iupgmRecord.Core_MDF_All_Accounts_cd__c).equalsIgnoreCase('Yes')){
                                key = key;
                            }
                            else{
                                key = key + iupgmRecord.Core_MDF_Account_id__c ;
                            }
                            if(iupgmUserMap.containsKey(key)){
                                iupgmUserMap.get(key).add(iupgmRecord.Core_MDF_User_id__c);
                            }else{
                                iupgmUserMap.put(key, new List<String>{iupgmRecord.Core_MDF_User_id__c});
                            }
                        }
                    }
                    else{
                        for(String regionStr : iupgmRecord.Core_MDF_Region_cd__c.split(';')){
                            if((iupgmRecord.Core_MDF_All_Accounts_cd__c).equalsIgnoreCase('Yes')){
                                //key = iupgmRecord.Core_MDF_Region_cd__c;
                                key = regionStr;
                            }
                            else{
                                // key = iupgmRecord.Core_MDF_Region_cd__c + iupgmRecord.Core_MDF_Account_id__c ;
                                key = regionStr + iupgmRecord.Core_MDF_Account_id__c ;
                            }
                            if(iupgmUserMap.containsKey(key)){
                                iupgmUserMap.get(key).add(iupgmRecord.Core_MDF_User_id__c);
                            }else{
                                iupgmUserMap.put(key, new List<String>{iupgmRecord.Core_MDF_User_id__c});
                            }
                        }
                    }
                }
            }

            if (!coGtmCampList.isEmpty() && campaignIdToContractsMap.isEmpty()) {
                queryContractRecords(coGtmCampList);
            }

            // Approval logic moved into separate methods
            for(Campaign cmp : newCampList) {
                if(cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM) {
                    // IPA approval flow
                    processIPACampaignApproval(cmp, iupgmUserMap, oldCampMap, isStageChange, cmpToActClassificationMap, setOfValidMarketingActivity);
                }
                // Roshan -  Logic for Co-GTM campaign setup
                else if (cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM) {
                    populateCoGTMFields(cmp, oldCampMap, isInsert, isUpdate);
                    // CoGTM approval flow
                    processProjectBasedApproval(cmp, oldCampMap);
                }
            }

            // IPA: ipaCampaignList
            // CoGTM: coGtmCampList

            if(proposalBasedCampaignList.size()>0) {  //Roshan - Segregating logic later based on program list

                //Campaign Before Insert
                //Roshan - IPA specific logic
                if(isInsert && ipaCampaignList.size()>0) {  //Roshan - added ipaCampaignList check
                    if(mapFunctionalityNameTriggerExecution != null && mapFunctionalityNameTriggerExecution.containsKey('BypassCampaignBenefitValidation') && !mapFunctionalityNameTriggerExecution.get('BypassCampaignBenefitValidation').Core_Active__c){
                        isMDFBenefitApplicable(ipaCampToacctIdMap);  //Roshan - ipaCampToacctIdMap will be populated only for ipa
                    }

                    //Check if only one Geo is selected
                    validateSingleGeoOnCampaign(ipaCampaignList);
                }
                
                //Campaign Before Update
                if(isUpdate){
                    Map<String, String> cmpProgWithPLfieldsMap = new Map<String, String>();
                    Map<String, String> cmpProgWithCampNotEditFieldsMap = new Map<String, String>();
                    Map<String, Schema.DisplayType> cmpFieldtoFieldDataType = new Map<String, Schema.DisplayType>();
                    Map<String, String> cmpFieldtoFieldLabel = new Map<String, String>();

                    if (!campaignsToProcess.isEmpty() && propBasedCampIdPfcListIdMap.isEmpty()) {
                        queryPFCRecords(campaignsToProcess);
                    }
                    
                    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Campaign').getDescribe().fields.getMap();

                    //Roshan - IPA specific logic: added ipaCampaignList check
                    //Added by Ealisha: US635575: Determine if an account is eligible for MDF benefit
                    if(ipaCampaignList.size()>0 && ipaCampToacctIdMap != NULL && ipaCampToacctIdMap.Size() > 0 && mapFunctionalityNameTriggerExecution != null && mapFunctionalityNameTriggerExecution.containsKey('BypassCampaignBenefitValidation') && !mapFunctionalityNameTriggerExecution.get('BypassCampaignBenefitValidation').Core_Active__c){
                        isMDFBenefitApplicable(ipaCampToacctIdMap);  //Roshan - ipaCampToacctIdMap will be populated only for ipa (method logic is specifc to ipa)
                    }
                    
                    //Check if Date, Amount, Geo are changed and if Date and Amount comply with the activities
                    if(proposalBasedCampaignList.size()>0) {
                        checkCampaignFieldChanges(newCampMap,oldCampMap);  //Roshan - needs to be handled for coGTM also as part of edit scenario
                    }

                    // Roshan - method called for both IPA and CoGTM (determineCampaignAttributes)
                    if (!proposalBasedCampaignList.isEmpty()) {
                        determinePropBasedCampaignAttributes(proposalBasedCampaignList, oldCampMap, newCampMap);
                    }

                    //Roshan - Logic specific to ipa uses ipa fieldset
                    if(proposalBasedCampaignList.size()>0) {
                        checkIfCampaignNeedsStatusChange(proposalBasedCampaignList, oldCampMap);  //Roshan - needs to be handled for coGTM also as part of edit scenario
                    }

                    //US946767 :: [IPA - Budget CAP]  - [OOC - P8] - L2 Approver - Terminate Approvals if Reimbursement amount exceeds Budget Cap
                    //checkifCampaignReimbursementAmountExceedsBudgetCap(ipaCampaignList,oldCampMap, isStageChange);
                    //NP - WW33 Do not allow removal of country if used in an active activity
                    
                    //Roshan - Below logic is needed for CoGTM as part of edit scenario
                    for(Core_MDF_ChannelProgram__mdt cp : [Select Id, Core_MDF_Technical_Program_Name__c,Core_MDF_Campaign_Picklist_Fields__c,
                                               Core_MDF_Campaign_Text_Fields__c,Core_MDF_CampNotEditFieldsWhenPFRExists__c
                                               FROM Core_MDF_ChannelProgram__mdt LIMIT 1000]) {
                        String key = cp.Core_MDF_Technical_Program_Name__c;
                        cmpProgWithPLfieldsMap.put(key, cp.Core_MDF_Campaign_Picklist_Fields__c);
                        cmpProgWithCampNotEditFieldsMap.put(key, cp.Core_MDF_CampNotEditFieldsWhenPFRExists__c);
                    }
                                            
                    for(String strField: cmpProgWithPLfieldsMap.get('Intel Partner Alliance').Split(',')) {
                        Schema.DisplayType campFieldDataType = fieldMap.get(strField).getDescribe().getType();
                        if(campFieldDataType != null){
                            cmpFieldtoFieldDataType.put(strField,campFieldDataType);
                        }
                        String labelValue = fieldMap.get(strField).getDescribe().getLabel();
                        if(labelValue != null){
                            cmpFieldtoFieldLabel.put(strField,labelValue);
                        }
                    }

                    if(cmpProgWithPLfieldsMap.size()>0 && cmpFieldtoFieldDataType.size()>0 &&  cmpFieldtoFieldLabel.size()>0 && cmpProgWithCampNotEditFieldsMap.size()>0){
                        checkIfFieldsUsedInActivityNotRemoved(newCampList,oldCampMap,'Intel Partner Alliance',cmpProgWithPLfieldsMap,cmpFieldtoFieldDataType,cmpFieldtoFieldLabel,cmpProgWithCampNotEditFieldsMap);
                    }
                }
            }
            
            //US1023028-Budget Cap stamped on the campiagn when the campaign is created/edited
            if(!campToBeUpdatedIPA.isEmpty()) {
                budgetCapListMap = queryBudgetCapRecords(budgetTypeSet,CampEarliestStartDate,CampEarliestFutureStartDate);
                mapBudgetToCampaign(campToBeUpdatedIPA,budgetCapListMap);
            }
            if(ipaCampaignList != null && ipaCampaignList.size()>0 && isUpdate) {
                checkifCampaignReimbursementAmountExceedsBudgetCap(ipaCampaignList,oldCampMap, isStageChange);
            } 

        }
        catch(Exception e) {
		    Core_MDF_CCP_UtilityClass.logError(e);
	    }   
    }
    
    public static void populateCoGTMFields(Campaign newCampaign, Map<Id, Campaign> oldCampaignMap, Boolean isInsert, Boolean isUpdate) {
        TimeZone userTz = UserInfo.getTimeZone();
    	String formattedDate = System.now().format('yyyy-MM-dd', userTz.getID());
    	Date userTodayDate = Date.valueOf(formattedDate); // today's date in the user's time zone
        
        newCampaign.Core_MDF_Activity_Category_Type__c = Core_MDF_CCP_ConstantClass.CO_ENGINEERING_DEFAULT_ACT_CAT_TYPE;
        List<String> parts = Core_MDF_CCP_ConstantClass.CO_ENGINEERING_DEFAULT_ACT_CAT_TYPE.split('->');
        if(parts != null && parts.size() == 2){
            newCampaign.Core_MDF_Activity_Category__c = parts[0].trim();
            newCampaign.Core_MDF_Activity_Type__c = parts[1].trim();
        }
        if (isInsert) {
            newCampaign.Core_MDF_Region_cd__c = Core_MDF_CCP_ConstantClass.CAMPAIGN_ALL_REGION;
            if(newCampaign.StartDate != null && newCampaign.StartDate < userTodayDate){
                newCampaign.Core_MDF_ATF_Flag_Nm__c = Core_MDF_CCP_ConstantClass.CAMPAIGN_ATF_DATE;
            }
            if (newCampaign.Core_MDF_External_Visibility_Date__c == null) {
                newCampaign.Core_MDF_External_Visibility_Date__c = Date.today();
            }
        }
        
        if (isUpdate && oldCampaignMap != null && oldCampaignMap.containsKey(newCampaign.Id)) {
            Campaign oldCampaign = oldCampaignMap.get(newCampaign.Id);
            if (newCampaign.StartDate != oldCampaign.StartDate || !String.isEmpty(newCampaign.Core_MDF_Reason_for_Back_Dating_Nm__c)) {
                
                if (newCampaign.StartDate != null && newCampaign.StartDate < userTodayDate) {
                    newCampaign.Core_MDF_ATF_Flag_Nm__c = Core_MDF_CCP_ConstantClass.CAMPAIGN_ATF_DATE;
                } else if (oldCampaign.StartDate != null && oldCampaign.StartDate < userTodayDate && newCampaign.StartDate != null && newCampaign.StartDate >= userTodayDate) {
                    newCampaign.Core_MDF_ATF_Flag_Nm__c = null;
                    newCampaign.Core_MDF_Reason_for_Back_Dating_Nm__c = null;
                    newCampaign.Core_MDF_Other_Reason_Name_txt__c = null;
                }
            }
        }
    }
    
    //Called in After Update
    public static void processPropBasedCamapignsAfterUpdate(Map<Id, Campaign> newCampMap, Map<Id, Campaign> oldCampMap){
        
        List<Campaign> ipaCampListForFieldUpdates = new List<Campaign>();
        set<String> fieldSet = new Set<String>();
        Map<id, Campaign> campaignThatNeedsToBeSyncedWithPFR = new Map<id, Campaign>();
        Map<id,Campaign> TotalCampaignCostUpdate = new Map<id, Campaign>();
        Set<String> ipaFieldSet = new Set<String>();
        Set<String> coGTMFieldSet = new Set<String>();
        Map<String, Set<String>> programToFieldSetMap = new Map<String, Set<String>>();
        
        
        List<Campaign> cmpToBeSendForApproval = new List<Campaign>();
        try{
            //Query all PFRs for the Campaigns
            if(propBasedCampIdPfrListIdMap.isEmpty()){
                queryPFRRecords(newCampMap.values());
            }
            
            List<Campaign> propBasedCampList = newCampMap.values();  //Roshan - updated variable name
            
            if(propBasedCampList.size()>0){                     
                
                //IPA - Country and Reimbursement Rate
                for(Schema.FieldSetMember fields :Schema.SObjectType.Campaign.fieldSets.getMap().get('Core_MDF_IPA_CampaignFieldsToBeSynced').getFields()){
                    ipaFieldSet.add(fields.getFieldPath());
                }

                if(ipaFieldSet != null && ipaFieldSet.size() > 0) {
                    programToFieldSetMap.put(Core_MDF_CCP_ConstantClass.IPA_PROGRAM, ipaFieldSet);
                }
                //COGTM - Start Date
                for(Schema.FieldSetMember fields :Schema.SObjectType.Campaign.fieldSets.getMap().get('Core_MDF_CoGTM_CampaignFieldsToBeSynced').getFields()){
                    coGTMFieldSet.add(fields.getFieldPath());
                }

                if(coGTMFieldSet != null && coGTMFieldSet.size() > 0) {
                    programToFieldSetMap.put(Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM, coGTMFieldSet);
                }

                
                //Once Approved, check if the field change requires Campaign Status change
                for(Campaign cmp: propBasedCampList){
                   //if(cmp.Status == 'Pending Review' || cmp.Status == 'Pending Approval'){ 
                     if((cmp.Status != oldCampMap.get(cmp.Id).Status && (cmp.Status == 'Pending Approval' || cmp.Status == 'Pending Review')) 
                     || ((cmp.Status == 'Pending Approval' || cmp.Status == 'Pending Review') && cmp.Core_MDF_Approval_Step_Counter_nbr__c != oldCampMap.get(cmp.Id).Core_MDF_Approval_Step_Counter_nbr__c 
                            && ((cmp.Core_MDF_Program__c == 'Intel Partner Alliance' && cmp.Core_MDF_IPA_Approval_Status_nm__c !='Pending Approval') || cmp.Core_MDF_Program__c == 'CoGTM'))  // Roshan - program check added to include CoGTM
                     || (cmp.Status == 'Pending Review' && cmp.Core_MDF_IPA_Approval_Status_nm__c =='Pending Approval' && cmp.Core_MDF_Approval_Stage_nm__c =='L1 Approval' 
                            && cmp.Core_MDF_Approval_Stage_nm__c != oldCampMap.get(cmp.Id).Core_MDF_Approval_Stage_nm__c)) {

                        cmpToBeSendForApproval.add(cmp);

                    }
                    boolean ischanged =false;
                    Set<String> fldSet = programToFieldSetMap.get(cmp.Core_MDF_Program__c);
                    for(string s: fldSet){
                        if(cmp.get(s) != oldCampMap.get(cmp.Id).get(s)){
                            ischanged = true;
                        }
                    }
                    if(ischanged){
                        campaignThatNeedsToBeSyncedWithPFR.put(cmp.id,cmp); 
                    }                    
                }
            }
            if(cmpToBeSendForApproval != NULL && cmpToBeSendForApproval.Size() > 0){
                //Call Approval Process
                callApprovalProcess(cmpToBeSendForApproval, oldCampMap);
            }
            if(campaignThatNeedsToBeSyncedWithPFR.size()>0){
                pfrUpdates(campaignThatNeedsToBeSyncedWithPFR,true);
            }
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}         
    }
    
    public static void validateSingleGeoOnCampaign(List<Campaign> newCampList){
        
        try{
            for(Campaign cmp : newCampList){
                
                if(cmp.Core_MDF_Market__c != null){
                String geo = Core_MDF_ProcessCCP_Campaign.returnsGeoForCampaign(cmp.Core_MDF_Market__c.split(';'));
                if(String.isNotBlank(geo) && (geo.contains('ASMO-LAR') || geo.contains('ASMO-NAR'))){
                    geo= geo.replace('ASMO-LAR','ASMO');
                    geo= geo.replace('ASMO-NAR','ASMO'); 
                }
                
		    Set<String> geoSet = new Set<String>(geo.split(';'));
		    geo = String.join(new List<String>(geoSet), ';');
                //multiipashare
                String region = '';
                
                for(String geoStr : geo.split(';')) {
                    region += geoStr+';';
                }
                
                
                region = region.removeEnd(';');
                cmp.Core_MDF_Region_cd__c = region;

                
                if(cmp.Core_MDF_Region_cd__c != NULL && cmp.Core_MDF_Region_cd__c.split(';').size()>1){
                    cmp.Core_MDF_Multi_Geo_Approval_Ind__c = True ;

                }
                else{
                    cmp.Core_MDF_Multi_Geo_Approval_Ind__c = False ;
                }
                
                } 
                else{
                    if(cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM){
                        cmp.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Campaign_Country_Field_Error'));
                    }
                }
            }  
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}  
    }
     //Query Budget Cap records on Campaigns
    public static Map <String,List<Core_MDF_Budget_Cap__c>> queryBudgetCapRecords(Set<String> Budgettypes , Date EarliestStartDate,Date CampEarliestFutureStartDate){
         Map <String,List<Core_MDF_Budget_Cap__c>> BudgetCapListMap = new Map <String,List<Core_MDF_Budget_Cap__c>> ();
        
         List<Core_MDF_Budget_Cap__c> CapList=[Select Name,Core_MDF_Effective_Start_Date_Dt__c,Core_MDF_Effective_End_Date_Dt__c,Core_MDF_Budget_Type_nm__c, 
                                               Core_MDF_Program_txt__c,Core_MDF_Region_nm__c from Core_MDF_Budget_Cap__c where Core_MDF_Cap_Status_nm__c ='Active' 
                                               and Core_MDF_Budget_Type_nm__c  IN: Budgettypes and 
                                               ((Core_MDF_Effective_Start_Date_Dt__c <=: EarliestStartDate 
                                               and Core_MDF_Effective_End_Date_Dt__c >=: EarliestStartDate)
                                                or Core_MDF_Effective_Start_Date_Dt__c <=: CampEarliestFutureStartDate) order by Core_MDF_Effective_Start_Date_Dt__c  ];
        
        
        for (Core_MDF_Budget_Cap__c budgetCap :CapList) {
         
            if(BudgetCapListMap.get(budgetCap.Core_MDF_Budget_Type_nm__c) == null)
            {
                
                List <Core_MDF_Budget_Cap__c> BCapList = new List <Core_MDF_Budget_Cap__c> ();
                BCapList.add(budgetCap);
                BudgetCapListMap.put(budgetCap.Core_MDF_Budget_Type_nm__c,BCapList);
              
                
            }
            else{
                    
                     BudgetCapListMap.get(budgetCap.Core_MDF_Budget_Type_nm__c).add(budgetCap);
                    
                }
        }
     
        return BudgetCapListMap ;
        }
   
    //Map the BudgetRecord on Campaign
    public static void mapBudgetToCampaign(List<Campaign> campToBeUpdatedIPA,Map<String,List<Core_MDF_Budget_Cap__c>> budgetCapListMap)
    {
        try
        {
               for (Campaign cmp : campToBeUpdatedIPA)
                {
                     
                     if (budgetCapListMap.containsKey(cmp.Core_MDF_Opal_Budget_Type_Txt__c))
                     {
                        Id budgetCapId = null;
                        for( Core_MDF_Budget_Cap__c budgetCap : budgetCapListMap.get(cmp.Core_MDF_Opal_Budget_Type_Txt__c) )
                         {
                            
                           if(cmp.Core_MDF_Opal_Budget_Type_Txt__c == budgetCap.Core_MDF_Budget_Type_nm__c && cmp.StartDate >= budgetCap.Core_MDF_Effective_Start_Date_Dt__c && cmp.StartDate <= budgetCap.Core_MDF_Effective_End_Date_Dt__c)
                            {
							if(cmp.Core_MDF_Host_Region_cd__c == budgetCap.Core_MDF_Region_nm__c || budgetCap.Core_MDF_Region_nm__c == 'WW')
								{
                                    budgetCapId = budgetCap.Id;
									cmp.Core_MDF_Budget_Cap__c = budgetCap.Id;
								}
                            }
                            
                        }
                        cmp.Core_MDF_Budget_Cap__c = budgetCapId;
                    }
                    
                    
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
        
    }
        
        
    

    /*public static CampaignShare createCampaignShare(Id campaignId, Id groupId){
        
        try{
            CampaignShare shareRecord = new CampaignShare();
            shareRecord.CampaignId = campaignId;
            shareRecord.RowCause = 'Manual';
            shareRecord.CampaignAccessLevel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Edit_Label');
            shareRecord.UserOrGroupId = groupId;
            return shareRecord;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);return null;}
    }*/
    
    /*public static void shareIPACampaign(List<Campaign> newCampList, Map<Id,Campaign> campOldMap, boolean isInsert, boolean isUpdate){
    
    Map<Id, Id> campAccUltAcc = new Map<Id, Id>();
    Set<Id> accIdSet = new Set<Id>();
    Set<Id> channelProgIdSet = new Set<Id>();
    Set<Id> ultAccIdSet = new Set<Id>();
    Set<String> budTypeSet = new Set<String>();
    Map<String,Id> geoGroupIdMap = new Map<String,Id>(); 
    Map<String,Id> externalMap = new Map<String,Id>();
    String pgmSubRegion;
    String pgmRegion;
    String accCPGeo;
    String accCPSubGeo;
    String accCP;
    
    String accCPGeoBudgetType;
    String accCPSubGeoBudgetType;
    String accCPBudgetType;
    
    //Map<Id, String> cpIdNameMap = new Map<Id, String>();
    Map<Id, Set<Id>> accIdWithPFAIdSetMap = new Map<Id,Set<Id>>();
    Set<Id> allAccIdsSet = new Set<Id>();
    Map<Id,Id> accIdWithGroupIdMap = new Map<Id,Id>();
    Map<Id, Set<Id>> accIdPnumUsrIdMap = new Map<Id,Set<Id>>();
    Map<Id, List<Id>> cmpIdUserIdMap = new Map<Id,List<Id>>();
    
    List<CampaignShare> cmpShareList = new List<CampaignShare>();
    List<Campaign> campaignToBeShared = new List<Campaign>();
    List<Campaign> cmpToBeUpdated = new List <Campaign>();
    
    List<Id> campaignShareToBeDeleted = new List<Id>();
    List<CampaignShare> campaignShareList = new List<CampaignShare>();
    List<Core_MDF_RecordGeoShare> recGeoShrLst = new List<Core_MDF_RecordGeoShare>();
    
    Map<Id,Id> accountIdExternalGroupIdMap = new Map<Id,Id>();
    Map<Id, List<Id>> campIdExternalGroupIdMap = new Map<Id,List<Id>>();
    
    for(Campaign cmp : newCampList){
        accIdSet.add(cmp.Core_MDF_Account__c);
        channelProgIdSet.add(cmp.Core_MDF_Channel_Program__c);
        budTypeSet.add(cmp.Core_MDF_Opal_Budget_Type_Txt__c);
        if(isInsert || (isUpdate && (cmp.Core_MDF_Region_cd__c != campOldMap.get(cmp.Id).Core_MDF_Region_cd__c || 
                                        cmp.OwnerId != campOldMap.get(cmp.Id).OwnerId || 
                                        cmp.Core_MDF_Opal_Budget_Type_Txt__c != campOldMap.get(cmp.Id).Core_MDF_Opal_Budget_Type_Txt__c ||
                                        //cmp.Core_MDF_SudReg_karan__c != campOldMap.get(cmp.Id).Core_MDF_SudReg_karan__c))){
                                        cmp.Core_MDF_Sub_Region_cd__c != campOldMap.get(cmp.Id).Core_MDF_Sub_Region_cd__c))){
                                            campaignToBeShared.add(cmp);
                                        }
        //multiipashare
        if(isUpdate && (cmp.Core_MDF_Region_cd__c != campOldMap.get(cmp.Id).Core_MDF_Region_cd__c ||
                        cmp.Core_MDF_Account__c != campOldMap.get(cmp.Id).Core_MDF_Account__c || 
                        cmp.Core_MDF_Opal_Budget_Type_Txt__c != campOldMap.get(cmp.Id).Core_MDF_Opal_Budget_Type_Txt__c ||
                        //cmp.Core_MDF_SudReg_karan__c != campOldMap.get(cmp.Id).Core_MDF_SudReg_karan__c)){
                        cmp.Core_MDF_Sub_Region_cd__c != campOldMap.get(cmp.Id).Core_MDF_Sub_Region_cd__c)){
                            campaignShareToBeDeleted.add(cmp.Id);
                        }
    }
    
    //Delete share records
    if(campaignShareToBeDeleted.size() > 0){
        for(CampaignShare cmpShare : [SELECT Id, CampaignId, UserOrGroupId, Campaign.Core_MDF_Program__c, Campaign.Core_MDF_Account__c
                                        FROM CampaignShare
                                        WHERE CampaignId IN : campaignShareToBeDeleted AND 
                                        RowCause =: Schema.CampaignShare.RowCause.Manual]){
                                            if(String.valueOf(cmpShare.UserOrGroupId).startsWith('00G')){
                                                CampaignShareList.add(cmpShare);
                                            }                            
                                        }
    }
    
    if(campaignShareList != NULL && campaignShareList.size() > 0){
        database.delete(campaignShareList);
    }
    
    // Account Id, Ultimate Account Id Map
    if(accIdSet != NULL && accIdSet.size() > 0){
        for(Account acc : [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c, Core_MDF_Channel_Program__r.Name,Core_MDF_Parent_Fund_Account__c,
                            Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Group_Id__c, Core_MDF_External_Group_Id__c
                            FROM Account 
                            WHERE Id IN: accIdSet]){
                                ultAccIdSet.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                                campAccUltAcc.put(acc.Id, acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                                //For Ext sharing
                                //Getting all Parent Accounts
                                accIdWithPFAIdSetMap.put(acc.Id, new Set<Id> {acc.Id, acc.Core_MDF_Parent_Fund_Account__c, acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c});  
                                //Add all Parent Accounts
                                allAccIdsSet.addAll(accIdWithPFAIdSetMap.get(acc.Id)); 
                                
                                if(acc.Core_MDF_External_Group_Id__c != null){
                                    accountIdExternalGroupIdMap.put(acc.Id, acc.Core_MDF_External_Group_Id__c);
                                }
                            }
    }
    for(Campaign cmp : newCampList){
        if(accIdWithPFAIdSetMap.containsKey(cmp.Core_MDF_Account__c) && accIdWithPFAIdSetMap.get(cmp.Core_MDF_Account__c) != null){
            for(Id acctId: accIdWithPFAIdSetMap.get(cmp.Core_MDF_Account__c)){
                if(campIdExternalGroupIdMap.containsKey(cmp.Id)){
                    if(accountIdExternalGroupIdMap.get(acctId) != null){
                        campIdExternalGroupIdMap.get(cmp.Id).add(accountIdExternalGroupIdMap.get(acctId));
                    }
                }
                else{
                    if(accountIdExternalGroupIdMap.get(acctId) != null){
                        campIdExternalGroupIdMap.put(cmp.Id, new List<Id> {accountIdExternalGroupIdMap.get(acctId)});
                    }
                }
            }
        }
        }
        if(campIdExternalGroupIdMap.size() > 0){
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass extShare = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Campaign',campIdExternalGroupIdMap, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(extShare);
        }
        
        //Preparing Maps: Key- Acc+ Prog+ Geo/Sub Geo Value: GroupId
        for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id,Core_MDF_Group_Id__c, Core_MDF_Account__c,
                                                     Core_MDF_Type_of_Access__c, Core_MDF_Channel_Program__c, 
                                                     Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_BudgetType_nm__c
                                                     FROM Core_MDF_Partner_Group_Mapping__c 
                                                     WHERE Core_MDF_Account__c IN : ultAccIdSet AND
                                                     Core_MDF_Inactive_Ind__c = false AND
                                                     Core_MDF_Channel_Program__c IN : channelProgIdSet AND 
                                                     Core_MDF_Type_of_Access__c = 'INTERNAL']){ //AND (Core_MDF_BudgetType_nm__c IN : budTypeSet OR Core_MDF_Region_cd__c = 'WW')]){  
            if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && pgm.Core_MDF_Region_cd__c == 'WW'){
                                                             
                pgmRegion = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                                                             if(pgm.Core_MDF_BudgetType_nm__c == NULL){
                geoGroupIdMap.put(pgmRegion,pgm.Core_MDF_Group_Id__c);
                                                                }else{
                                                                pgmRegion = pgmRegion + pgm.Core_MDF_BudgetType_nm__c;
                                                                geoGroupIdMap.put(pgmRegion,pgm.Core_MDF_Group_Id__c);
                                                                }
            }
            if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                pgmSubRegion = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c; 
                if(pgm.Core_MDF_BudgetType_nm__c == NULL){
                geoGroupIdMap.put(pgmSubRegion,pgm.Core_MDF_Group_Id__c);
                                                                }else{
                                                                    pgmSubRegion = pgmSubRegion + pgm.Core_MDF_BudgetType_nm__c;
                                                                    geoGroupIdMap.put(pgmSubRegion,pgm.Core_MDF_Group_Id__c); 
                                                                }
            }
                else{
                pgmRegion = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                                                                if(pgm.Core_MDF_BudgetType_nm__c == NULL){
                                                                    geoGroupIdMap.put(pgmRegion,pgm.Core_MDF_Group_Id__c);
                                                                }else{
                                                                    
                                                                    pgmRegion = pgmRegion + pgm.Core_MDF_BudgetType_nm__c;
                geoGroupIdMap.put(pgmRegion,pgm.Core_MDF_Group_Id__c);
            }
                                                            } //For IPA AM
                                                         
                                                         
        }
        //multiipashare
        String region = '';
        String subRegion = '';        
        for(Campaign cmp : campaignToBeShared){
            List<Id> groupIdList = new List<Id>();
            Set<Id> groupIdSet = new Set<Id>();
            //String geoIPA = Core_MDF_ProcessCCP_Campaign.returnsGeoForCampaign(cmp.Core_MDF_Market__c.split(';'));
            List<String> marketList = new List<String>();
            if(cmp.Core_MDF_Market__c != null){
                marketList = cmp.Core_MDF_Market__c.split(';');
            }
            String geoIPA = Core_MDF_ProcessCCP_Campaign.returnsGeoForCampaign(marketList);
            if(String.isNotBlank(geoIPA) && (geoIPA.contains('ASMO-LAR') || geoIPA.contains('ASMO-NAR'))){
                geoIPA= geoIPA.replaceAll('ASMO-LAR','ASMO');
                geoIPA= geoIPA.replaceAll('ASMO-NAR','ASMO'); 
            }
            if(geoIPA != null){
            Set<String> geoSet = new Set<String>(geoIPA.split(';'));
            geoIPA = String.join(new List<String>(geoSet), ';');
            }
            //List<String> geoLst = geoIPA.split(';');
            
            List<String> geoLst = new List<String>();
            if(geoIPA != null){
                geoLst = geoIPA.split(';');
            }
            
            //multiipashare 
            if(!geoLst.isEmpty()){
            for(String geo : geoLst){
			region = geo;
                    
                
             //multiipashare   
           
            accCPSubGeo = campAccUltAcc.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + region + subRegion;
            accCPGeo = campAccUltAcc.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c +region;
            accCP = campAccUltAcc.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c;
            //If Campaign has SubGeo
           if(geoGroupIdMap.containsKey(accCPSubGeo) && geoGroupIdMap.get(accCPSubGeo) != NULL){
                groupIdSet.add(geoGroupIdMap.get(accCPSubGeo));
                cmpShareList.add(createCampaignShare(cmp.Id, geoGroupIdMap.get(accCPSubGeo)));
            }          
            if(geoGroupIdMap.containsKey(accCPGeo) && geoGroupIdMap.get(accCPGeo) != NULL){
                groupIdSet.add(geoGroupIdMap.get(accCPGeo));
                cmpShareList.add(createCampaignShare(cmp.Id, geoGroupIdMap.get(accCPGeo)));
            }
            if(geoGroupIdMap.containsKey(accCP) && geoGroupIdMap.get(accCP) != NULL){
                groupIdSet.add(geoGroupIdMap.get(accCP));
                cmpShareList.add(createCampaignShare(cmp.Id, geoGroupIdMap.get(accCP)));
            }
                   // accCPSubGeoBudgetType = campAccUltAcc.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + region + subRegion + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
                    accCPGeoBudgetType = campAccUltAcc.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c +region + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
                    accCPBudgetType = campAccUltAcc.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
            
//To share with Budget type groups
if(geoGroupIdMap.containsKey(accCPSubGeoBudgetType) && geoGroupIdMap.get(accCPSubGeoBudgetType) != NULL){
groupIdList.add(geoGroupIdMap.get(accCPSubGeoBudgetType));
cmpShareList.add(createCampaignShare(cmp.Id, geoGroupIdMap.get(accCPSubGeoBudgetType)));
}                      
if(geoGroupIdMap.containsKey(accCPGeoBudgetType) && geoGroupIdMap.get(accCPGeoBudgetType) != NULL){
groupIdList.add(geoGroupIdMap.get(accCPGeoBudgetType));
cmpShareList.add(createCampaignShare(cmp.Id, geoGroupIdMap.get(accCPGeoBudgetType)));
}
if(geoGroupIdMap.containsKey(accCPBudgetType) && geoGroupIdMap.get(accCPBudgetType) != NULL){
groupIdList.add(geoGroupIdMap.get(accCPBudgetType));
cmpShareList.add(createCampaignShare(cmp.Id, geoGroupIdMap.get(accCPBudgetType)));
}
             
                 if(cmp.Core_MDF_Opal_Budget_Type_Txt__c != NULL){
               if(subRegion != NULL){
                    Core_MDF_RecordGeoShare recGeoShrIPA = new Core_MDF_RecordGeoShare(cmp.Id,region , subRegion, cmp.Core_MDF_Program__c, cmp.Core_MDF_Opal_Budget_Type_Txt__c);
                    recGeoShrLst.add(recGeoShrIPA);
                }else{
                    Core_MDF_RecordGeoShare recGeoShrIPA = new Core_MDF_RecordGeoShare(cmp.Id,region, null, cmp.Core_MDF_Program__c, cmp.Core_MDF_Opal_Budget_Type_Txt__c);
                    recGeoShrLst.add(recGeoShrIPA);
                }
            }
             
        }
    }

            
            if(groupIdList != NULL && groupIdList.Size() > 0){//&& cmp.Core_MDF_PGM_Internal_Group_Id_txt__c == NULL
                Campaign cmpIst = new Campaign();
                cmpIst.Id = cmp.Id;
                cmpIst.Core_MDF_PGM_Internal_Group_Id_txt__c = String.join(groupIdList, ';');
                cmpToBeUpdated.add(cmpIst);
            }
            
        if(groupIdSet != NULL && groupIdSet.Size() > 0){
                String groupIds = '';                              
                for(String ids: groupIdSet){                               
                    groupIds = groupIds + ids +';';                              
                } 
                Campaign cmpIst = new Campaign();
                cmpIst.Id = cmp.Id;
                cmpIst.Core_MDF_PGM_Internal_Group_Id_txt__c = groupIds;
                cmpToBeUpdated.add(cmpIst);
            }
           
            
        }
        
        if(cmpToBeUpdated.size() > 0){
            Database.update(cmpToBeUpdated,false);
        }
        
        if(cmpShareList.Size() > 0){
            Database.insert(cmpShareList);
        }
        if(recGeoShrLst.size() > 0){
            Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Campaign', recGeoShrLst);
        }
    }*/
    
    public static void checkCampaignFieldChanges(Map<Id, Campaign> newCampMap, Map<Id, Campaign> oldCampMap){
        
        Map<Id,Campaign> toBeValidatedCampaignMap = new Map<Id,Campaign>();
        Map<Id, Campaign> toBeValidatedCoGTMCampaignMap = new Map<Id,Campaign>();
        Map<Id,Campaign> toBeValidatedReimbAmtMap = new Map<Id,Campaign>();
        List<Campaign> budgetToBeUpdatedForCamp = new List<Campaign>();
        List<PartnerFundRequest> relatedPFR = new List<PartnerFundRequest>();
        
        try {
            //US774498: [IPA] : Validation for edits made to Total Campaign cost WW46
            for(Campaign camp:newCampMap.values()) {

                if(camp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM) { //Roshan - added program check for ipa
                                    
                    if(oldCampMap.get(camp.ID).startDate != camp.startDate || oldCampMap.get(camp.ID).endDate != camp.endDate 
                            || oldCampMap.get(camp.ID).Core_MDF_Market__c != camp.Core_MDF_Market__c || oldCampMap.get(camp.ID).Core_MDF_Reimbursement_Amt__c != camp.Core_MDF_Reimbursement_Amt__c) {
                        toBeValidatedCampaignMap.put(camp.id,camp);
                    }
                    
                    //DE119505: WW28 | DevINT3 | System is taking longer time to Save IPA Campaign record, when user edits the Campaign and saves the record
                    if((oldCampMap.get(camp.ID).Description != camp.Description || oldCampMap.get(camp.ID).Core_MDF_Opal_Budget_Type_Txt__c != camp.Core_MDF_Opal_Budget_Type_Txt__c && camp.Core_MDF_Budget__c != null) && (camp.status == 'Planned' || camp.status == 'In Progress')) {
                        budgetToBeUpdatedForCamp.add(camp);  
                    }
                }

                else if(Camp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM) {
                    if(oldCampMap.get(camp.ID).startDate != camp.startDate || oldCampMap.get(camp.ID).endDate != camp.endDate) {
                        toBeValidatedCoGTMCampaignMap.put(camp.id, camp);
                    }

                }
            }
    
            if(budgetToBeUpdatedForCamp.size()>0) {
                Map<Campaign,PartnerMarketingBudget> campaignToBudgetMap = Core_MDF_Create_Budget.manageBudget(budgetToBeUpdatedForCamp);
            }
            
            if(toBeValidatedCampaignMap.size()>0) {
                validateCampaignDateAndAmountAgainstActivity(toBeValidatedCampaignMap, oldCampMap);
                validateSingleGeoOnCampaign(toBeValidatedCampaignMap.values()); 
            }

            if(toBeValidatedCoGTMCampaignMap != null && toBeValidatedCoGTMCampaignMap.size() > 0) {
                validateCampaignDateAndAmountAgainstActivity(toBeValidatedCoGTMCampaignMap, oldCampMap);

            }
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}    
    }
    
    public static void validateCampaignDateAndAmountAgainstActivity(Map<Id,Campaign> newCampMap, Map<Id, Campaign> oldCampMap){
        
        Map<Id,Decimal> cmpIdTotalPfrAmountMap = new Map<Id,Decimal>();
        
        try{
            for(Id CampaignId : newCampMap.keySet()){
                List<PartnerFundRequest> activeAndClosedPfrList = new List<PartnerFundRequest>();
                // Add active PFRs
                if (propBasedCampIdPfrListIdMap.containsKey(campaignId) && propBasedCampIdPfrListIdMap.get(campaignId) != null) {
                    activeAndClosedPfrList.addAll(propBasedCampIdPfrListIdMap.get(campaignId));
                }
                // Add closed PFRs
                if (propBasedCampIdClosedPfrListIdMap.containsKey(campaignId) && propBasedCampIdClosedPfrListIdMap.get(campaignId) != null) {
                    activeAndClosedPfrList.addAll(propBasedCampIdClosedPfrListIdMap.get(campaignId));
                }
                //Get related PFR for the campaign
                if(activeAndClosedPfrList != NULL && activeAndClosedPfrList.size()>0){
                    for(PartnerFundRequest pfr : activeAndClosedPfrList){
                        //Check for date validation
                        if(newCampMap.get(CampaignId).Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM && oldCampMap.get(CampaignId).startDate != newCampMap.get(CampaignId).startDate){
                            if(newCampMap.get(CampaignId).startDate > pfr.Core_MDF_End_Date__c || newCampMap.get(CampaignId).endDate < pfr.Core_MDF_End_Date__c){
                                newCampMap.get(CampaignId).addError(Label.Core_MDF_Campaign_Date_Check_Error); 
                            }
                            //Active Claim then
                            if(checkIfActiveClaimsExists(oldCampMap.get(CampaignId).id) && oldCampMap.get(CampaignId).startDate != newCampMap.get(CampaignId).startDate){
                                newCampMap.get(CampaignId).addError(Label.Core_MDF_Campaign_Active_Claim_error);
                            }
                        }
                        else{
                        if(newCampMap.get(CampaignId).startDate > pfr.Core_MDF_Start_Date__c ||
                           newCampMap.get(CampaignId).endDate < pfr.Core_MDF_End_Date__c){
                            newCampMap.get(CampaignId).addError(Label.Core_MDF_Campaign_Date_Check_Error); //Campaign date range must comply with Activity date range.
                        }
                    }
                }
            } 
            } 
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }

    public static void determinePropBasedCampaignAttributes(List<Campaign> newCmpList, Map<Id,Campaign> campOldMap, Map<Id,Campaign> newCampMap) {
        
        List<Id> ipaCampaignIdSet = new List<Id>();
        Map<id, Campaign> campaignIdStatusMap = new Map<id, Campaign>();
        List<Campaign> campaignsForBudgetCreation = new List<Campaign>();
        List<Campaign> onSubmitForApprovalCampaignList = new List<Campaign>();
        List<Campaign> cancelledCampaignList = new List<Campaign>();
        try{
            for(Campaign cmp: newCmpList){               
                
                switch on cmp.Status {
	            when 'Proposal Accepted', 'Campaign Accepted' {  // Roshan - CoGTM Intermediate status
		   	campaignIdStatusMap.put(cmp.id,cmp);
                        if(cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM) {
                            campaignsForBudgetCreation.add(cmp);   
                        }                         
                    }
                    when 'Revision Required' {
                        campaignIdStatusMap.put(cmp.id,cmp); 
                    }
                    when 'Pending Review' {
                        onSubmitForApprovalCampaignList.add(cmp);
                    }
                    when 'Cancelled' {
                        cancelledCampaignList.add(cmp);  
                    }
                }
            }
            
            //When Campaign is Proposal Accepted/Revision Required
            if(campaignIdStatusMap.size()>0){
                campaignUpdates(campaignIdStatusMap);  //Roshan - Terminal Rejection (not needed for CoGTM)
                pfrUpdates(campaignIdStatusMap, false);
            }
            
            //When Campaign is submitted for Approval
            if(onSubmitForApprovalCampaignList.size()>0){
                onSubmitForApproval(onSubmitForApprovalCampaignList, campOldMap);
            }

            //Roshan - not needed for now for CoGTM
            //When Campaign is cancelled
            if(cancelledCampaignList.size()>0) {
                queryEscalationRecords(cancelledCampaignList);  //query escalation records to populate campsWithActiveEscalations
                onCampaignCancel(cancelledCampaignList,campOldMap);
            } 
            
            //Create Budget records for Approved Campaigns
            //Uncommented by Ealisha to test budget creation for IPA after proper MDF selecting budget type.
            if(campaignsForBudgetCreation.size()>0){
                Map<Campaign,PartnerMarketingBudget> campaignToBudgetMap = Core_MDF_Create_Budget.manageBudget(campaignsForBudgetCreation);                 
                for(Campaign campRecord : campaignsForBudgetCreation){
                    if(campaignToBudgetMap != NULL && campaignToBudgetMap.Size() > 0 && campaignToBudgetMap.containsKey(campRecord) && campaignToBudgetMap.get(campRecord) != NULL && campaignToBudgetMap.get(campRecord).Id != NULL){ 
                        campRecord.Core_MDF_Budget__c = campaignToBudgetMap.get(campRecord).Id;
                    }
                    if(campRecord.Core_MDF_Budget__c == NULL){
                        campRecord.addError(Label.Core_MDF_ApplicationErrorMessage);
                    }
                }                                              
            }        
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            //Added error if any error occurs while budget creation
            campaignsForBudgetCreation[0].addError(Label.Core_MDF_ApplicationErrorMessage);
        }  
    }
    
    public static void campaignUpdates(Map<id, Campaign> campaignIdStatusMap){
        boolean isActiveClaimExist=false;
        //campList : List of Campaign Ids which are marked for terminal rejection
        List<Id> campList = new List<Id>();
	    List<Campaign> campDeclinedStatusList = new List<Campaign>();
        for(Campaign campId:campaignIdStatusMap.values()){
            if(campId.Core_MDF_Terminal_Rejection_Ind__c && campId.Status == revisionRequiredStatus){
                campList.add(campId.Id);
            }
        }
        Map<Id,List<PartnerFundClaim>> campClaimAssocMap =  checkClaimsAssociatedToCampaign(campList);
        try{
            for(Campaign campId:campaignIdStatusMap.values()){
                if(campId.Status == proposalAccepted || campId.Status == campaignAccepted){  // Roshan - CoGTM Intermediate status
                    campId.Status = campId.StartDate <= system.today() ? inProgressStatus: plannedStatus;
                }
                if(campId.Status == revisionRequiredStatus && campId.Core_MDF_Terminal_Rejection_Ind__c){
                    //campClaimAssocMap => If it contains the respective campId, there's an active claim association
                    if(campClaimAssocMap!=null && campClaimAssocMap.size()>0 && campClaimAssocMap.containsKey(campId.Id) && campClaimAssocMap.get(campId.Id)!=null && campClaimAssocMap.get(campId.Id).size()>0){
                        campId.addError(Label.Core_MDF_Restrict_Terminal_Rejection_On_Active_Claim_Association);
                    }
                    else{
                        //When Campaign is terminally rejected and there's no active claim association
                        campId.Status = declinedStatus;
                        if(campId.Core_MDF_Budget__c != null) {
                            campDeclinedStatusList.add(campId);
						}
                    }
                }         
            }
            if(campDeclinedStatusList != null && !campDeclinedStatusList.isEmpty()) {
                Core_MDF_Create_Budget.cancelBudget(campDeclinedStatusList);
			}
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }

    //Method to check if an active claim is associated with Campaigns
    public static Map<Id,List<PartnerFundClaim>> checkClaimsAssociatedToCampaign(List<Id> campList){
        Boolean isClaimsAssociated = false;
        //campClaimAssociationMap : Map of CampId and List of Associated Claim Ids
        Map<Id,List<PartnerFundClaim>> campClaimAssociationMap = new Map<Id,List<PartnerFundClaim>>();
        try{
            //Querying if there's any active PartnerFundClaim is associated with the list of campaign Ids
            List<PartnerFundClaim> pfcList=[Select Id, Request.CampaignId from PartnerFundClaim where Core_MDF_Status__c !=:cancelledStatus and Core_MDF_Campaign_Id__c in :campList];
            if(pfcList!=null && pfcList.size()>0){
            for(PartnerFundClaim pfc:pfcList){
                if(campClaimAssociationMap.containsKey(pfc.Request.CampaignId)){
                    campClaimAssociationMap.get(pfc.Request.CampaignId).add(pfc);
                    
                } else {
                    campClaimAssociationMap.put(pfc.Request.CampaignId, new List<PartnerFundClaim>{pfc});
                    }
                    
                }
            }
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
        return campClaimAssociationMap;
    }
      
    //Roshan - edit scenario for CoGTM - needs to be updated as part of edit
    public static void pfrUpdates(Map<id, Campaign> campaignIdStatusMap, boolean pfrFieldSync){
        
        List<PartnerFundRequest> pfrListToBeUpdated = new List<PartnerFundRequest>();
        try{  
            if(campaignIdStatusMap != NULL && campaignIdStatusMap.size() > 0){
                for(id cmpid: campaignIdStatusMap.keyset()){
                    if(propBasedCampIdPfrListIdMap.containsKey(cmpid) && propBasedCampIdPfrListIdMap.get(cmpid) != NULL){
                        for(PartnerFundRequest pfr: propBasedCampIdPfrListIdMap.get(cmpid)){                  
                            if(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval' || (pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && pfr.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval')){
                                if(campaignIdStatusMap.get(pfr.CampaignId).Status == 'Planned' || campaignIdStatusMap.get(pfr.CampaignId).Status == 'In Progress'){
                                    if(pfr.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval'){
                                        pfr.Core_MDF_Fund_Request_Status__c = 'In-Progress';
                                    }else {
                                        pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
                                    }
                                    pfrListToBeUpdated.add(pfr);
                                }
                                else if(campaignIdStatusMap.get(pfr.CampaignId).Status == 'Revision Required'){
                                    if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && pfr.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval'){
                                        pfr.Core_MDF_Fund_Request_Status__c = 'In-Progress Revision Required';
                                    }
                                    else{
                                        pfr.Core_MDF_Fund_Request_Status__c = 'Revision Required';
                                    }
                                    pfrListToBeUpdated.add(pfr);
                                }
                            }
                            else{ 
                                    if(campaignIdStatusMap.get(pfr.CampaignId).Status == 'Revision Required' && pfr.Core_MDF_Fund_Request_Status__c != 'Revision Required' && pfr.Core_MDF_Fund_Request_Status__c != 'In-Progress Revision Required' &&
                                    pfr.Core_MDF_Fund_Request_Status__c != 'In-Progress' && pfr.Core_MDF_Fund_Request_Status__c != 'Closed'){  
                                        if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && pfr.Core_MDF_Fund_Request_Status__c.contains('In-Progress')){
                                            pfr.Core_MDF_Fund_Request_Status__c = 'In-Progress Revision Required';
                                        }
                                        else{
                                            pfr.Core_MDF_Fund_Request_Status__c = 'Revision Required';
                                        }
                                        pfrListToBeUpdated.add(pfr);
                                    }
                                   //Update PFR status during terminal rejection
                                   if(campaignIdStatusMap.get(pfr.CampaignId).Status == declinedStatus && pfr.Core_MDF_Fund_Request_Status__c != declinedStatus){
                                    pfr.Core_MDF_Fund_Request_Status__c = declinedStatus;
                                    pfrListToBeUpdated.add(pfr);
                                }
                            }
                            
                            if(pfrFieldSync){
                                pfr.Core_MDF_Country_nm__c = campaignIdStatusMap.get(pfr.CampaignId).Core_MDF_Market__c;
                                if(pfr.Core_MDF_Program__c != 'Intel Partner Alliance' && pfr.Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM){
                                	pfr.Core_MDF_Reimbursement_Rate_txt__c  = campaignIdStatusMap.get(pfr.CampaignId).Core_MDF_ReimbursementRate_pct__c;
                                }
                                if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM) {
                                	pfr.Core_MDF_Start_Date__c  = campaignIdStatusMap.get(pfr.CampaignId).StartDate;
                                }
                                //Updating new Activty Budget type field as part of defect DE119207 fix
                                pfr.Core_MDF_Budget_Type_nm__c = campaignIdStatusMap.get(pfr.CampaignId).Core_MDF_Opal_Budget_Type_Txt__c;
                                pfrListToBeUpdated.add(pfr);
                            }
                        }
                    }
                }
            }
            if(pfrListToBeUpdated != NULL && pfrListToBeUpdated.size()>0){
                Database.update(pfrListToBeUpdated);
            }
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    } 
    
    //Method to check if SPIF/Non-SPIF approvals are required
    private static Map<string,boolean> updateSPIFApprInd(List<String> actCatTypeLst){
        string strNonSpif = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_NonSPIF_Approval');
        string strSpif = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_SPIF_Approval');
        String outcomeBasedSpif = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_OutcomeBased_SPIF_Approval');  //Roshan - Tactics for IPA Approval
        Map<string,boolean> mapApprvFlag = new Map<string,boolean>();
        boolean isNonSPIFApproval = false;
        boolean isSPIFApproval = false;      
        
        if(actCatTypeLst!=null && actCatTypeLst.size()>0){
            for(integer i=0;i<actCatTypeLst.size();i++){
                if(strNonSpif.containsIgnoreCase(actCatTypeLst[i])){isNonSPIFApproval = true; 
                }
                if(strSpif.containsIgnoreCase(actCatTypeLst[i]) || outcomeBasedSpif.containsIgnoreCase(actCatTypeLst[i])){ isSPIFApproval = true;   
                }
                if(isNonSPIFApproval && isSPIFApproval){break;}
            }
        }
                
        mapApprvFlag.put('NonSPIF',isNonSPIFApproval);
        mapApprvFlag.put('SPIF',isSPIFApproval);
        
        return mapApprvFlag;
    }    
    
    public static void onSubmitForApproval(List<Campaign> cmpList, Map<Id,Campaign> campOldMap){
        
        try {
            List<String> supportedSpifTypes = Label.Core_MDF_SPIF_Activity_Types.split(';');
            Set<String> supportedOutcomeBasedSpifTactics = new Set<String>();
            Core_MDF_Custom_Label_Configration__mdt mdtRec = [SELECT Core_MDF_Value2_Txt__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE DeveloperName = 'Core_MDF_IPA_OutcomeBased_SPIF_Approval' LIMIT 1];
            if (mdtRec != null && String.isNotBlank(mdtRec.Core_MDF_Value2_Txt__c)) {
                for (String tactic : mdtRec.Core_MDF_Value2_Txt__c.split(';')) {
                    supportedOutcomeBasedSpifTactics.add(tactic);
                }
            }
            
            for(Campaign cmp: cmpList) {
                
                If(cmp.Status == 'Pending Review' && campOldMap.get(cmp.Id).Status != 'Planned' && campOldMap.get(cmp.Id).Status !='In Progress'){
                    //Check if Activities are present in the Campaign                    
                    if(propBasedCampIdPfrListIdMap.get(cmp.Id) == NULL && !propBasedCampIdPfrListIdMap.containsKey(cmp.Id)){
                        if(campOldMap.get(cmp.Id).Status != cmp.Status) {
                            cmp.addError(Label.Core_MDF_IPA_Submit_Approval_Error);//Please create activities in order to submit Campaign for Approval
                        }
                    }    
                    

                    //TWC702-10 - restrict activities created from clone proposal if it do not contains spif section on approval
                    if(cmp.Status == 'Pending Review'  && campOldMap.get(cmp.Id).Status != 'Planned' && campOldMap.get(cmp.Id).Status !='In Progress' && (cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM)) {
                        List<String> actNameLst =  new  List<String>();
                        if(propBasedCampIdPfrListIdMap != null && propBasedCampIdPfrListIdMap.containsKey(cmp.id)) {
                            for(PartnerFundRequest pfr : propBasedCampIdPfrListIdMap.get(cmp.Id)){
                                Boolean tacticMatched = false;
                                if (String.isNotBlank(pfr.Core_MDF_Tactics_nm__c)) {
                                    List<String> pfrTacticsList = pfr.Core_MDF_Tactics_nm__c.split(';');
                                    
                                    for (String tactic : pfrTacticsList) {
                                        if (supportedOutcomeBasedSpifTactics.contains(tactic)) {
                                            tacticMatched = true;
                                            break;
                                        }
                                    }
                                }
                                if(((supportedSpifTypes.contains(pfr.Core_MDF_Activity_Types__c) || tacticMatched) && !pfr.Core_MDF_SPIF_Segments_Available_ind__c) && pfr.Core_MDF_SPIF_Modified_ind__c == false) {
                                    actNameLst.add(pfr.Title);     
                                }
                            } 
                        }

                        if(actNameLst!= null && actNameLst.size()>0){ String actNm = String.join(actNameLst, ', ');
                            cmp.addError(Label.Core_MDF_NoSpif_Validation+' \'' + actNm + '\' ');
                        }
                    }
                } else {
                    cmp.addError(Label.Core_MDF_IPA_Campaign_Status_Check_Error1 + ' \'' + campOldMap.get(cmp.Id).Status + '\' ' + Label.Core_MDF_IPA_Campaign_Status_Check_Error2);
                }
                
                if (cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM) {  // Roshan - added ipa check

                    if(campIdActSubTypeSet.containsKey(cmp.Id) && campIdActSubTypeSet.get(cmp.Id) != null){
                        String strVal = String.join(new List<String>(campIdActSubTypeSet.get(cmp.Id)), ';');
                        cmp.Core_MDF_Activity_Sub_Type_nm__c = strVal;
                    }
                    
                    if(campIdActCatSet.containsKey(cmp.Id) && campIdActCatSet.get(cmp.Id) != null){
                        String strVal = String.join(new List<String>(campIdActCatSet.get(cmp.Id)), ';');
                        cmp.Core_MDF_Activity_Category__c = strVal;
                    }
                    
                    if(campIdActTypeSet.containsKey(cmp.Id) && campIdActTypeSet.get(cmp.Id) != null){
                        String strVal = String.join(new List<String>(campIdActTypeSet.get(cmp.Id)), ';');
                        cmp.Core_MDF_Activity_Type__c = strVal;
                    }
                    
                    if(budgetAmtMap.containsKey(cmp.Id) && budgetAmtMap.get(cmp.Id) != null){
                        cmp.Core_MDF_Activity_Budget_Amount_amt__c = budgetAmtMap.get(cmp.Id);
                    }
                }

                if(campOldMap != null && campOldMap.size() > 0 && (campOldMap.get(cmp.Id).Status =='Revision Required' || campOldMap.get(cmp.Id).Status =='Draft')){
                    cmp.Core_MDF_Comments_Appvr_Only_txt__c = '';
                    cmp.Core_MDF_No_of_Reapprovals_nbr__c = cmp.Core_MDF_No_of_Reapprovals_nbr__c == null ? 1 : cmp.Core_MDF_No_of_Reapprovals_nbr__c + 1;
                }
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}  
    }
    
    //Campaign cancellation logic starts
    public static void onCampaignCancel(List<Campaign> campList,Map<Id,Campaign> campOldMap){
        try{
            
            Boolean isValidationBypassed = isValidationBypassed();
            
            List<Campaign> cancelledCampaignsList = new List<Campaign>();
            List<Campaign> ipaCancelledCampaignsList = new List<Campaign>();
            for(Campaign cmp: campList){   
                boolean isValidationPassed = false;             
                if (campOldMap.get(cmp.Id).Status == Core_MDF_CCP_ConstantClass.CAMPAIGN_COMPLETED) {
                    isValidationPassed = handleCompletedCampaigns(cmp, cancelledCampaignsList, isValidationBypassed);
                } else {
                    isValidationPassed = handleActiveCampaigns(cmp, cancelledCampaignsList, isValidationBypassed);
                } 
                if(isValidationPassed && cmp.Core_MDF_Program__c == ipaProgram) {
                    ipaCancelledCampaignsList.add(cmp);
                } 
            }
            
            //Cancel the corresponding Budgets
            if(ipaCancelledCampaignsList != null && !ipaCancelledCampaignsList.isEmpty()) {
                Core_MDF_Create_Budget.cancelBudget(ipaCancelledCampaignsList);
            }            

        } catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    } 

    //Validation bypass for specific users
    private static Boolean isValidationBypassed() {
        List<String> validationBypassUsersList = new List<String>();
        String validationBypassUsers = Core_MDF_Configuration__c.getValues('CAMPAIGN_BYPASS_USERS').Core_MDF_Value__c;
    
        if (String.isNotBlank(validationBypassUsers)) {
            validationBypassUsersList = validationBypassUsers.split(';');
        }
    
        String validationBypassAllowedString = Core_MDF_Configuration__c.getValues('CAMPAIGN_BYPASS_ALLOWED').Core_MDF_Value__c;
        String validationBypassAllowed = String.isNotBlank(validationBypassAllowedString) ? validationBypassAllowedString.toLowerCase() : null;
    
        if (validationBypassAllowed != null && validationBypassAllowed.equals('true') && !validationBypassUsersList.isEmpty() && validationBypassUsersList.contains(UserInfo.getUserName())) {
            return true;
        }
        return false;  
    }

    //Logic for cancelling campaigns in Completed status
    private static boolean handleCompletedCampaigns(Campaign cmp, List<Campaign> cancelledCampaignsList, Boolean isValidationBypassed) {
        if (checkIfActivePFRExist(cmp.Id) && !isValidationBypassed) {
           if(cmp.Core_MDF_Program__c == ipaProgram){
            cmp.addError(Label.Core_MDF_IPA_Cancel_Campaign_With_Activities_Error); //Proposal with active activities associated to it cannot be cancelled.
           }
           else if(cmp.Core_MDF_Program__c == cogtmProgram){
            cmp.addError('Campaign with active activities associated to it cannot be cancelled.'); //Campaign with active activities associated to it cannot be cancelled.
           }
        } else {
           cmp.Status = Core_MDF_CCP_ConstantClass.CAMPAIGN_CANCELLED;
           cancelledCampaignsList.add(cmp);
           return true;
       }
       return false;
    }

    //Logic for cancelling active campaigns
    private static boolean handleActiveCampaigns(Campaign cmp, List<Campaign> cancelledCampaignsList, Boolean isValidationBypassed) {
        if ((checkIfActiveClaimsExists(cmp.Id) || campsWithActiveEscalations.contains(cmp.Id)) && !isValidationBypassed) {
            if(cmp.Core_MDF_Program__c == ipaProgram){
                cmp.addError(Label.Core_MDF_IPA_Cancel_Campaign_With_Claims_Error); //Proposal with active claim or active escalation cannot be cancelled.
            }
            else if(cmp.Core_MDF_Program__c == cogtmProgram){
                cmp.addError('Campaign with active claim or escalation cannot be cancelled. Please cancel claims or escalation to cancel Campaign.'); //Campaign with active claim or active escalation cannot be cancelled.
            }
            } else {
            cmp.Status = Core_MDF_CCP_ConstantClass.CAMPAIGN_CANCELLED;
            cancelledCampaignsList.add(cmp);
            return true;
        }
        return false;
    }

    //Logic to check for active PFRs on a campaign
    private static boolean checkIfActivePFRExist(Id campaignId) {
        boolean activePFRExists = false;

        if((propBasedCampIdPfrListIdMap != null && !propBasedCampIdPfrListIdMap.isEmpty() && propBasedCampIdPfrListIdMap.containsKey(campaignId) && propBasedCampIdPfrListIdMap.get(campaignId) != null)
            || ((propBasedCampIdClosedPfrListIdMap != null && !propBasedCampIdClosedPfrListIdMap.isEmpty() && propBasedCampIdClosedPfrListIdMap.containsKey(campaignId) && propBasedCampIdClosedPfrListIdMap.get(campaignId) != null))) {
            activePFRExists = true;
        }   
        return activePFRExists;
    }

     //Logic to check for active claims on a campaign
    private static boolean checkIfActiveClaimsExists(Id campaignId) {
        boolean activeClaimExists = false;
        if(propBasedCampIdPfcListIdMap != null && !propBasedCampIdPfcListIdMap.isEmpty()) {
            if(propBasedCampIdPfcListIdMap.containsKey(campaignId) && propBasedCampIdPfcListIdMap.get(campaignId) != null) {
                activeClaimExists = true;
            }   
        }
        return activeClaimExists;
    }
    //Campaign cancellation logic ends
 
        public static void callApprovalProcess(List<Campaign> cmpList, Map<Id, Campaign> oldCampMap){
        
        Map<String, Map<String,List<Id>>> sObjResultMap = new Map<String, Map<String,List<Id>>>();
        Map<String,List<id>> approvalRequiredmap = new Map<String,List<id>>();
        Set<Campaign> toBeUpdatedApproval = new Set<Campaign>();
        List<Campaign> toBeUpdatedApprovalList = new List<Campaign>();
        Map<Id,Campaign> cmpMap = new Map<Id,Campaign>();
        //Added by Sarah
        Boolean priceReviewer = FeatureManagement.checkPermission('Core_MDF_PriceReviewer');
        List<Campaign> pendingPCTApprovalCamp = new List<Campaign>();
        List<String> geoList = new List<String>();
        List<String> accntList = new List<String>();
        List<String> programList = new List<String>();
        //Added by Saikat
        List<Campaign> pendingApprovalCamp = new List<Campaign>();
        List<String> approvalStageStatusList = new List<String>();
        List<String> budgetTypeList = new List<String>();
        List<Campaign> pendingCustomerAcceptanceApproval = new List<Campaign>();
        Boolean isSetApprovers = false;
        String pctRole;
        try{
            
            //added by Sarah
            for(Campaign cmp : cmpList){
                // ROshan - added ipa and cogtm check
                if(cmp.Status == 'Pending Review' && (cmp.Core_MDF_Approval_Stage_nm__c == 'Price Reviewer' || cmp.Core_MDF_Approval_Stage_nm__c == 'Business Approver' ) && ((cmp.Core_MDF_Program__c == 'Intel Partner Alliance' && cmp.Core_MDF_IPA_SPIF_Apprval_Ind__c) || cmp.Core_MDF_Program__c == 'CoGTM') && !priceReviewer ){
                    pendingPCTApprovalCamp.add(cmp);
                    accntList.add(cmp.Core_MDF_Ultimate_Account_txt__c);
                    programList.add(cmp.Core_MDF_Program__c);
                    geoList.addAll(getGeoRegions(cmp));
                    if(cmp.Core_MDF_Program__c == 'Intel Partner Alliance' && cmp.Core_MDF_Proposal_Based_Ind__c == true) {
                        pctRole = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Price_Reviewer_Roles');
                    } else if(cmp.Core_MDF_Program__c == 'CoGTM') {
                        pctRole = 'Core_MDF_CCP_Internal_Co_GTM_Business_Approver';
                    }

                }
                //added by Saikat //Navneet added change// will add the new Approval Stage Name for POR since it is budget type based
                else if(cmp.Status == 'Pending Review' && (cmp.Core_MDF_Approval_Stage_nm__c == 'L1 Approval' 
                                                            || cmp.Core_MDF_Approval_Stage_nm__c == 'L2 Regional Marketing' 
                                                            || cmp.Core_MDF_Approval_Stage_nm__c == 'L2 Regional Sales' 
                                                            || cmp.Core_MDF_Approval_Stage_nm__c == 'Program Office Reviewer'
                                                            //Roshan - added Legal Reviewer and L2 for Cogtm
                                                            || cmp.Core_MDF_Approval_Stage_nm__c == 'Legal Reviewer' 
                                                            || cmp.Core_MDF_Approval_Stage_nm__c == 'L2 Approval' )){
                    pendingApprovalCamp.add(cmp);
                    accntList.add(cmp.Core_MDF_Ultimate_Account_txt__c);
                    programList.add(cmp.Core_MDF_Program__c);
                    
                    geoList.addAll(getGeoRegions(cmp));

                    approvalStageStatusList.add(cmp.Core_MDF_Approval_Stage_nm__c);

                    //budgetTypeList.add(cmp.Core_MDF_Budget_Type_txt__c);
                    // Roshan - added for CoGTM as Core_MDF_Budget_Type_txt__c is not populated
                    if(cmp.Core_MDF_Program__c == 'Intel Partner Alliance' && cmp.Core_MDF_Proposal_Based_Ind__c == true) {
                        budgetTypeList.add(cmp.Core_MDF_Budget_Type_txt__c);
                    } else if(cmp.Core_MDF_Program__c == 'CoGTM') {
                        budgetTypeList.add(cmp.Core_MDF_Opal_Budget_Type_Txt__c);  //Roshan - Using OPAL budget type for CoGTM
                    }

                    
                }
                else if(cmp.Status == 'Pending Approval' && cmp.Core_MDF_Approval_Stage_nm__c == 'Customer Acceptance'){
                    pendingCustomerAcceptanceApproval.add(cmp);
                }
            }
            if(pendingPCTApprovalCamp != NULL && pendingPCTApprovalCamp.Size() > 0){
                Core_MDF_CampaignUtility.notificationWrapper wrapper = new Core_MDF_CampaignUtility.notificationWrapper(pendingPCTApprovalCamp, accntList, geoList, programList);
                Core_MDF_CampaignUtility.notifyPCTApprovers(wrapper,pctRole);
            }
            if(pendingApprovalCamp != NULL && pendingApprovalCamp.Size() > 0){
             
                Core_MDF_CampaignUtility.notificationForAllApproversWrapper wrapper = new Core_MDF_CampaignUtility.notificationForAllApproversWrapper(pendingApprovalCamp,
                                                                                      accntList, geoList, programList, approvalStageStatusList, budgetTypeList);
                Core_MDF_CampaignUtility.notifyAllApprovers(wrapper);
            }
            if(pendingCustomerAcceptanceApproval != NULL && pendingCustomerAcceptanceApproval.Size() > 0){
                notifyExternalReviewers(pendingCustomerAcceptanceApproval);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }

    // Roshan - WW24 - Get applicable Geo based on program
    public static List<String> getGeoRegions(Campaign cmp) {
        List<String> geoRegions = new List<String>();
        
        if (cmp.Core_MDF_Program__c == 'Intel Partner Alliance' && cmp.Core_MDF_Proposal_Based_Ind__c == true) {
            geoRegions.add(cmp.Core_MDF_Host_Region_cd__c);
        } else if (cmp.Core_MDF_Program__c == 'CoGTM') {
            if (cmp.Core_MDF_Region_cd__c != null) {
                for (String geoRec : cmp.Core_MDF_Region_cd__c.split(';')) {
                    geoRegions.add(geoRec);
                }
            }
        }
    
        return geoRegions;
    }
    
    // Roshan - need to be edited for cogtm
    public static void checkIfCampaignNeedsStatusChange(List<Campaign> campaignNewList, Map<Id, Campaign> campaignOldMap) {
        
        set<String> ipaFieldSet = new Set<String>();
        set<String> coGTMFieldSet = new Set<String>();
        List<Campaign> campaignsThatNeedStatusChange  = new List<Campaign>();
        List<Campaign> toBeUpdated = new List<Campaign>();
        List<string> ipaInternalFieldsEditNotForReApproval = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_IntFldEdit_NotForReApproval').split(';');
        List<String> coGTMInternalFieldsEditNotForReApproval = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_GTM_IntFldEdit_NotForReApproval').split(';');
        Boolean hasIntAcctManagerPS  = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Account_Manager');
        Map<id, Campaign> campaignIdCampaignMap = new Map<id, Campaign>();
        Map<String, Set<String>>  programToFieldsListMap = new Map<String, Set<String>>();
     
        try{
         //Dynamically get the fields from the field set and then use the same for comparison in the trigger. 
            for(Schema.FieldSetMember fields :Schema.SObjectType.Campaign.fieldSets.getMap().get('Core_MDF_IPA_CampaignStatusChangeFields').getFields()) {
                ipaFieldSet.add(fields.getFieldPath());
            }
            if(ipaFieldSet != null && ipaFieldSet.size() > 0) {
                programToFieldsListMap.put(Core_MDF_CCP_ConstantClass.IPA_PROGRAM, ipaFieldSet);
            }
            for(Schema.FieldSetMember fields :Schema.SObjectType.Campaign.fieldSets.getMap().get('Core_MDF_GTM_CampaignStatusChangeFields').getFields()) {
                coGTMFieldSet.add(fields.getFieldPath());
            }

            if(coGTMFieldSet != null && coGTMFieldSet.size() > 0) {
                programToFieldsListMap.put(Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM, coGTMFieldSet);
            }


         
            for(Campaign cmp: campaignNewList){
                    if(cmp.Core_MDF_Proposal_Based_Ind__c == true) {  //Roshan - added ipa check
                    if(cmp.status == 'Planned' || cmp.status == 'In Progress') {
                        boolean ischanged =false;
                        Set<String> fieldSet = programToFieldsListMap.get(cmp.Core_MDF_Program__c);
                        for(string s: fieldSet){
                            if(cmp.get(s) != campaignOldMap.get(cmp.Id).get(s)) {
				if(cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && ((s == 'Description' && cmp.status == 'In Progress') || ((UserInfo.getUserType() != 'PowerPartner') && ipaInternalFieldsEditNotForReApproval.contains(s)))) {
                                    Continue;
                                }
                                ischanged = true;
                            }
                        }
                        if(ischanged){
                            campaignsThatNeedStatusChange.add(cmp);
                        } 
                    }
                    
                    if(cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && cmp.status == 'In Progress' && checkIfActiveClaimsExists(cmp.Id) && cmp.EndDate != campaignOldMap.get(cmp.Id).EndDate) {
                        campaignsThatNeedStatusChange.add(cmp);
                    }
                }
            }
         
            if(campaignsThatNeedStatusChange.size()>0) {
                for(Campaign cmp: campaignsThatNeedStatusChange) {
                    cmp.Status='Revision Required';
                    if(cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM) {
                        cmp.Core_MDF_ContractLineItem_Update_Ind__c = false;
                    }
                    campaignIdCampaignMap.put(cmp.id,cmp);
                }
                //Update the corresponding PFR as Revision Required
                pfrUpdates(campaignIdCampaignMap, false);
            }
        }
    catch(Exception e) {
        Core_MDF_CCP_UtilityClass.logError(e);
    } 
}
    @testVisible
//Added by Ealisha: US635575: Determine if an account is eligible for MDF benefit
    private static Map<Campaign,Set<String>> checkMDFBenefits(Map<Campaign,Id> ipaCampToacctIdMap){
        
        Map<Campaign,Set<String>> benefitsApplicable = new Map<Campaign,Set<String>>{};
            Map<Id,Id> coMktAcctToIntelAcctMap = new Map<Id,Id>{};
                Map<Id,Id> intelAcctToCoMktAcctMap = new Map<Id,Id>{};  
                Set<String> unifiedIdSet =new Set<String>();//changed from primeIdSet to unifiedIdSet
        Set<Id> setOfAccIds=new Set<Id>();
        Map<Id,String> coMktAcctToUnifiedIdMap = new Map<Id,String>();//changed from coMktAcctToPrimeIdMap to coMktAcctToUnifiedIdMap
        Map<Campaign,Boolean> containsBenefit = new Map<Campaign,Boolean>{};
            Map<String,Set<String>> unifiedIdToBenefitList = new Map<String,Set<String>>();//changed from primeIdToBenefitList to unifiedIdToBenefitList
        Map<Id,String> mapOfIntelAccountandUnifiedId = new Map<Id,String>();//changed from mapOfIntelAccountandPrimeId to mapOfIntelAccountandUnifiedId
        //Map of Unified Id and related List of Intel Accounts
        Map<String, Set<Id>> mapOfUnifiedIdSetofAccountId = new Map<String, Set<Id>>();//changed from mapOfPrimeIdSetofAccountId to mapOfUnifiedIdSetofAccountId
        
        for(Campaign cmp:ipaCampToacctIdMap.keySet()){
            coMktAcctToIntelAcctMap.put(ipaCampToacctIdMap.get(cmp),cmp.Core_MDF_Ultimate_Account_txt__c);
            intelAcctToCoMktAcctMap.put(cmp.Core_MDF_Ultimate_Account_txt__c,ipaCampToacctIdMap.get(cmp));                
        } 
        //added by JK to replace prime id field
       Set<Id> accountId = new Set<Id>(ipaCampToacctIdMap.values());
       String unifiedIdOrPrimeIdField =  ' AND Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c!= null';
       String accIdListQuery = '(\''+String.join(new List<Id>(accountId), '\', \'') + '\')';
        String whereClause = ' Id IN '+accIdListQuery+unifiedIdOrPrimeIdField;
       List<Account> accounts = Core_MDF_Account_Utility.fetchAccounts(whereClause);  
                   
    for(Account acc : accounts/*Database.Query(ultiAccountQuery)/*[SELECT Id,Name, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_CoMarketing_Ultimate_Account__r.Core_Prime_Id__c FROM Account WHERE Id IN :ipaCampToacctIdMap.values() AND Core_MDF_CoMarketing_Ultimate_Account__r.Core_Prime_Id__c != null]*/){
            //String accIsPrimeIdOrUnifiedField = isUnifiedIdEnabled?acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c:acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Prime_Id__c;
            String accIsPrimeIdOrUnifiedField = acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c;
            coMktAcctToUnifiedIdMap.put(acc.Id, accIsPrimeIdOrUnifiedField);
            unifiedIdSet.add(accIsPrimeIdOrUnifiedField/*acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Prime_Id__c*/);    
        }
        if(!unifiedIdSet.isEmpty())
        {
        
            List<Account> unifiedIdAccounts = Core_MDF_Account_Utility.fetchUnifiedIdAccounts(unifiedIdSet);
            for(Account acc : unifiedIdAccounts/*Database.Query(accountQuery) /*[SELECT Id,Core_Prime_Id__c,Core_MDF_CoMarketingActive__c from Account WHERE Core_Prime_Id__c IN: primeIdSet 
               AND ((RecordType.DeveloperName =: 'Mastered_Account' AND Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE)
               OR RecordType.DeveloperName =: 'Core_Partner_Account_Group' )]*/){
                //String IsPrimeIdOrUnifiedField = isUnifiedIdEnabled?acc.Core_Unified_Global_Customer_BP_Id__c:acc.Core_Prime_Id__c;
                String IsPrimeIdOrUnifiedField = acc.Core_Unified_Global_Customer_BP_Id__c;
                //creating a map of Intel Account Id/OPID Account Ids and Prime Ids
                mapOfIntelAccountandUnifiedId.put(acc.Id,IsPrimeIdOrUnifiedField/*acc.Core_Prime_Id__c*/);
                setOfAccIds.add(acc.Id);
                                   }
                //Get the select benefits for all accounts in Unified ID
                //for(PRM_AccountBenefitAssociation__c benefit : [SELECT Id,PRM_Partner_Benefit_Id__r.name, PRM_Account_Id__c,PRM_Account_Id__r.name FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c in : allAccIdsSet AND PRM_Status_Nm__c='Active']){
        for(PRM_Account_Specialty_Association__c asa : [SELECT ID, PRM_Account_Id__c, PRM_Specialty_Id__r.name from PRM_Account_Specialty_Association__c 
                                                                WHERE PRM_Account_Id__c IN:setOfAccIds and PRM_InActive_Ind__c = FALSE ]){
                                                                    
                                                                    if(mapOfIntelAccountandUnifiedId.containsKey(asa.PRM_Account_Id__c) && mapOfIntelAccountandUnifiedId.get(asa.PRM_Account_Id__c) != NULL && unifiedIdToBenefitList.containsKey(mapOfIntelAccountandUnifiedId.get(asa.PRM_Account_Id__c))){
                                                                        unifiedIdToBenefitList.get(mapOfIntelAccountandUnifiedId.get(asa.PRM_Account_Id__c)).add(asa.PRM_Specialty_Id__r.name);
                    }else{
                                                                        unifiedIdToBenefitList.put(mapOfIntelAccountandUnifiedId.get(asa.PRM_Account_Id__c), new Set<String> {asa.PRM_Specialty_Id__r.name});
                    }
                                                            
                                                                }
        }        
        for(Campaign c:ipaCampToacctIdMap.keySet()){
          
            Set<String> benList = new Set<String>{};
            String unifiedId ='';//changed from primeId to unifiedId
            Id accId = ipaCampToacctIdMap.get(c);
            if(coMktAcctToUnifiedIdMap.containsKey(accId) && coMktAcctToUnifiedIdMap.get(accId) !=Null){
                unifiedId = coMktAcctToUnifiedIdMap.get(accId);
            }
           if(String.isNotBlank(unifiedId) && unifiedIdToBenefitList.containsKey(unifiedId) && unifiedIdToBenefitList.get(unifiedId) !=Null){
                benList.addAll(unifiedIdToBenefitList.get(unifiedId));
            }
            benefitsApplicable.put(c,benList);
        }  
        return benefitsApplicable;
    }
    
    //Added by Ealisha: US635575: Determine if an account is eligible for MDF benefit
    public static void isMDFBenefitApplicable(Map<Campaign,Id> ipaCampToacctIdMap){
        Map<Id,String> ipaCampToacctNameMap = new Map<Id,String>{};
        Map<Campaign,Boolean> containsBenefit = new Map<Campaign,Boolean>{};
        Map<String,Set<String>> applicableBenefitsFromMdt = new Map<String,Set<String>>{};
        
            for(Account acc:[Select id,Name from Account where id in :ipaCampToacctIdMap.values()]){
                ipaCampToacctNameMap.put(acc.Id,acc.Name);
            }
        
        String program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
        String whereClauseForBudgetType = ' Core_MDF_Program_Nm__c =\''+program+'\' '+' AND Core_MDF_IsActive__c=true';
        budgetTypeBenefitMapping = Core_MDF_GenericMetadata.getObjectRecords(objectApiName, whereClauseForBudgetType);  
        for(Core_MDF_BudgetType_Benefit_Mapping__mdt budToBenMdt:budgetTypeBenefitMapping/*[select Core_MDF_Budget_Type__c,Core_MDF_RecordType__c,Core_MDF_Partner_Benefit__c  from Core_MDF_BudgetType_Benefit_Mapping__mdt where Core_MDF_IsActive__c=true and Core_MDF_Program_Nm__c =:program]*/){
        
            
            if(applicableBenefitsFromMdt.containsKey(budToBenMdt.Core_MDF_Budget_Type__c))
            {
                applicableBenefitsFromMdt.get(budToBenMdt.Core_MDF_Budget_Type__c).add(budToBenMdt.Core_MDF_Partner_Benefit__c);
                    }
            else {
                applicableBenefitsFromMdt.put(budToBenMdt.Core_MDF_Budget_Type__c,new Set<String> {budToBenMdt.Core_MDF_Partner_Benefit__c});
            }    
            
        }
    
        Map<Campaign,Set<String>> benefitsApplicable = checkMDFBenefits(ipaCampToacctIdMap);
     
        if(benefitsApplicable!=null && !benefitsApplicable.isEmpty()){
        for(Campaign c:benefitsApplicable.keySet()){
            Set<String> benFromQuery = benefitsApplicable.get(c);
          
            Set<String> benFromMdt = applicableBenefitsFromMdt.get(c.Core_MDF_Opal_Budget_Type_Txt__c);
            for(String ben:benFromMdt){
                            
                if(benFromQuery.contains(ben)){
                
                    containsBenefit.put(c,true);
                    break;
                                
                }
                else{
                    
                    containsBenefit.put(c,false);
                }
            }
        }

        }
        for(Campaign cmp:ipaCampToacctIdMap.keySet()){
            if((containsBenefit==null || containsBenefit.isEmpty() || !containsBenefit.containsKey(cmp) ||
              (containsBenefit.containsKey(cmp) && !containsBenefit.get(cmp))) && (cmp.Core_MDF_Program__c != 'Channel MDF' && cmp.Core_MDF_Proposal_Based_Ind__c == true)){
                  String error = Label.Core_MDF_IPA_Campaign_Budget_Type_Error1 + ' \'' +ipaCampToacctNameMap.get(cmp.Core_MDF_Account__c)+ '\' ' +Label.Core_MDF_IPA_Campaign_Budget_Type_Error2;
                //cmp.addError(error);
            }
        }
    }
    
   /* @InvocableMethod
    public static void updateIPACampaignToClosedRecordType(List<Campaign> campaignList){
        
        try{
            List<Campaign> updatedCampaignList = new List<Campaign>();
            for(Campaign cmp : campaignList){
                Campaign cmpInst = new Campaign();
                cmpInst.Id = cmp.Id;
                cmpInst.RecordTypeId = ipaCampaignClosedRecordId;
                updatedCampaignList.add(cmpInst);            
            }
            
            if(updatedCampaignList != NULL && updatedCampaignList.Size() > 0){
                database.update(updatedCampaignList);
            }
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}   
    }*/
     //Added as part of US946767: To show error message if Campaign Reimbursement Amount exceeds Budget Cap Amount 
    //when L1 Proposal Approver tries to approve the record
    public static void checkifCampaignReimbursementAmountExceedsBudgetCap(List<Campaign> cmpList, Map<Id,Campaign> oldCmpMap, Boolean isStageChange){
        Boolean hasL2ProposalApproverPS  = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver');
        try{          
            Map<Id,Campaign> cmpMap = new Map<Id,Campaign>();
            Map<Id,Campaign> cmpWithoutBudgetCapMap = new Map<Id,Campaign>();
            List<Campaign> campaignList = new List<Campaign>();
            if(cmpList != null && cmpList.size() > 0 && hasL2ProposalApproverPS){
	    	campaignList = reCalculateCampaignFormulaFields(cmpList);              
                for(Campaign cmp: campaignList){                    
                    if(oldCmpMap != null && oldCmpMap.size() > 0){
                        //To validate Campaign with Budget Cap Amt and Reimbursement Amt    
                        if(String.isNotBlank(cmp.Core_MDF_Budget_Cap__c) && cmp.Core_MDF_Available_BudgetCap_amt__c != null && cmp.Core_MDF_Program__c != 'Channel MDF'){
                            Decimal cmpReimbursementAmount = cmp.Core_MDF_Reimbursement_Amt__c;
                            Decimal budgetCapAmount = cmp.Core_MDF_Available_BudgetCap_amt__c;
         
                            if(cmpReimbursementAmount > budgetCapAmount
                               && cmp.Core_MDF_Approval_Stage_nm__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE && cmp.Core_MDF_Completed_Approval_Level_Nm__c == Core_MDF_CCP_ConstantClass.L2_REGIONAL_SALES && (cmp.Status == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS && oldCmpMap.get(cmp.Id).Status == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS)){
                                   cmpMap.put(cmp.Id,cmp);
                                   
                               }
                        }//new if: To validate Campaign without Budget Cap 
                        //US1055998: [IPA - Budget CAP]  - L1 Approver - Terminate Approvals if Budget CAP is not loaded 
                        //Roshan - added cogtm check
                        else if(String.isBlank(cmp.Core_MDF_Budget_Cap__c) && (cmp.Core_MDF_Program__c != 'Channel MDF' && cmp.Core_MDF_Program__c != 'CoGTM') && (cmp.Status == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS && oldCmpMap.get(cmp.Id).Status == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS) 
                                 && cmp.Core_MDF_Completed_Approval_Level_Nm__c == Core_MDF_CCP_ConstantClass.L2_REGIONAL_SALES && cmp.Core_MDF_Approval_Stage_nm__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE){
                                    cmpWithoutBudgetCapMap.put(cmp.Id, cmp);
                                }// new else if
                    }
                }// End of for loop
                if((cmpMap != null && cmpMap.size() > 0) || (cmpWithoutBudgetCapMap != NULL && cmpWithoutBudgetCapMap.size() > 0)){
                    /*for (ProcessInstance pi : [SELECT TargetObjectId FROM ProcessInstance WHERE Status = 'Pending' AND
                                               (TargetObjectId IN :cmpMap.keySet() OR TargetObjectId IN :cmpWithoutBudgetCapMap.keySet())]){
                                                   if(cmpMap.containsKey(pi.TargetObjectId)){
                                                       
                                                       cmpMap.get(pi.TargetObjectId).addError(Label.Core_MDF_BudgetCap_Error);                            
                                                   }
                                                   //US1055998: [IPA - Budget CAP]  - L1 Approver - Terminate Approvals if Budget CAP is not loaded                            
                                                   else if(cmpWithoutBudgetCapMap.containsKey(pi.TargetObjectId)){
                                                       cmpWithoutBudgetCapMap.get(pi.TargetObjectId).addError(Label.Core_MDF_CampaignWithoutBudgetCap_Error); 
                                                       //Throw error msg: There is not enough budget to support this proposal. Budget cap must be loaded or proposal must be declined.
                                                   }                     
                                               }*/
                    if(!isStageChange){
                        for (ProcessInstance pi : [SELECT TargetObjectId FROM ProcessInstance WHERE Status = 'Pending' AND
                                                   (TargetObjectId IN :cmpMap.keySet() OR TargetObjectId IN :cmpWithoutBudgetCapMap.keySet())]){
                                                       if(cmpMap.containsKey(pi.TargetObjectId)){
                                                           cmpMap.get(pi.TargetObjectId).addError(Label.Core_MDF_BudgetCap_Error);                            
                                                       }
                                                       //US1055998: [IPA - Budget CAP]  - L2 Approver - Terminate Approvals if Budget CAP is not loaded                            
                                                       else if(cmpWithoutBudgetCapMap.containsKey(pi.TargetObjectId)){
                                                           cmpWithoutBudgetCapMap.get(pi.TargetObjectId).addError(Label.Core_MDF_CampaignWithoutBudgetCap_Error); 
                                                           //Throw error msg: There is not enough budget to support this proposal. Budget cap must be loaded or proposal must be declined.
                                                       }                     
                                                   }
                    }
                    else {
                        for(Campaign camp : cmpList){
                            if(cmpMap.containsKey(camp.Id)){
                                cmpMap.get(camp.Id).addError(Label.Core_MDF_BudgetCap_Error);                            
                            }
                            //US1055998: [IPA - Budget CAP]  - L2 Approver - Terminate Approvals if Budget CAP is not loaded                            
                            else if(cmpWithoutBudgetCapMap.containsKey(camp.Id)){
                                cmpWithoutBudgetCapMap.get(camp.Id).addError(Label.Core_MDF_CampaignWithoutBudgetCap_Error); 
                                //Throw error msg: There is not enough budget to support this proposal. Budget cap must be loaded or proposal must be declined.
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
		Core_MDF_CCP_UtilityClass.logError(e);
		throw new CustomException(e);
	}
    }
    
    public static List<Campaign> reCalculateCampaignFormulaFields(List<Campaign> cmpList) {
        List<Campaign> campaignList = new List<Campaign>();
        List<System.FormulaRecalcResult> calcCampaignFormulas = Formula.recalculateFormulas(cmpList);
        for(System.FormulaRecalcResult calcCampaignFormulasRecord : calcCampaignFormulas){
            if(calcCampaignFormulasRecord.isSuccess()){
                campaignList.add((Campaign)calcCampaignFormulasRecord.getSObject());
            }
            else{
                throw new CustomException('There is some issue with the formula calculation. Please check the logs for more details.');
            }
        }
        return campaignList;
    }
    
    // US947863 - [IPA Budget Cap]  - [OOC - P8] - Budget Cap Consumption
    // US1019897 - [IPA Proposal] - [OOC - P8] - Proposal rejection reverts budget cap consumption
    public static void budgetCapConsumption(Map<Id, Campaign> campaignOldMap,List<Campaign> campaignList) {
        try {
            Set<Id> budgetCapIdSet = new Set<Id>();
            
            for(Campaign cmpObj : campaignList) {
                if(campaignOldMap != null && cmpObj.Core_MDF_Program__c == 'Intel Partner Alliance') {
                    
                    switch on cmpObj.Status {
                        when 'Planned', 'In Progress', 'Completed', 'Pending Review' {
                            if(campaignOldMap.get(cmpObj.Id).Core_MDF_Reimbursement_Amt__c != cmpObj.Core_MDF_Reimbursement_Amt__c 
                                && cmpObj.Core_MDF_Budget__c != null) {
                                if(String.isNotBlank(cmpObj.Core_MDF_Budget_Cap__c)) {
                                    budgetCapIdSet.add(cmpObj.Core_MDF_Budget_Cap__c);
                                }
                            }
                        }
                        
                        when 'Revision Required' {
                            
                            if((campaignOldMap.get(cmpObj.Id).Status != cmpObj.Status || campaignOldMap.get(cmpObj.Id).Core_MDF_Reimbursement_Amt__c != cmpObj.Core_MDF_Reimbursement_Amt__c) 
                            && (cmpObj.Core_MDF_Budget__c != null || (cmpObj.Core_MDF_Budget__c == null && cmpObj.Core_MDF_Completed_Approval_Level_Nm__c == Core_MDF_CCP_ConstantClass.L2_REGIONAL_SALES))) {
                                    
                                    if(String.isNotBlank(cmpObj.Core_MDF_Budget_Cap__c)) {
                                        budgetCapIdSet.add(cmpObj.Core_MDF_Budget_Cap__c);
                                }
                            }
                        }
                        
                        when 'Cancelled' { 
                            if(campaignOldMap.get(cmpObj.Id).Status != cmpObj.Status && cmpObj.Core_MDF_Budget__c != null)  {
                                if(String.isNotBlank(campaignOldMap.get(cmpObj.Id).Core_MDF_Budget_Cap__c)) {
                                    budgetCapIdSet.add(campaignOldMap.get(cmpObj.Id).Core_MDF_Budget_Cap__c);
                                }
                            }
                        }
                        
                        when 'Pending Approval' {
                            if(campaignOldMap.get(cmpObj.Id).Status != cmpObj.Status) {
                                if(String.isNotBlank(cmpObj.Core_MDF_Budget_Cap__c)) {
                                    budgetCapIdSet.add(cmpObj.Core_MDF_Budget_Cap__c);
                                }
                            }   
                        } 

                        when 'Declined' {
                            if (campaignOldMap.get(cmpObj.Id).Status != cmpObj.Status && cmpObj.Core_MDF_Budget__c != null) {
                                if (String.isNotBlank(cmpObj.Core_MDF_Budget_Cap__c)) {
                                    budgetCapIdSet.add(cmpObj.Core_MDF_Budget_Cap__c);
                                }
                            }
                        }
                    } 
                }
            }

            Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
            List<Core_MDF_Bulk_Transaction__e> updateRecordList = new List<Core_MDF_Bulk_Transaction__e>();   
            Map<Id,Decimal> budgetCapIDtoCampSumMap = new Map<Id,Decimal>();
                
            if(budgetCapIdSet != null && !budgetCapIdSet.isEmpty()) {
                for(AggregateResult aggRes : [SELECT Campaign.Core_MDF_Budget_Cap__c, SUM(Core_MDF_Activity_Reimbursement_Amt_nbr__c) TotalClaimedAmt FROM PartnerFundrequest 
                                                WHERE ((Campaign.Status = 'Pending Approval' AND Core_MDF_Fund_Request_Status__c = 'Pending Review' AND Campaign.Core_MDF_Completed_Approval_Level_Nm__c = 'L2 Regional Sales') 
                                                OR (Campaign.Status IN ('Pending Review', 'Pending Approval', 'Planned', 'In Progress', 'Completed', 'Revision Required') 
                                                AND ((Core_MDF_Fund_Request_Status__c IN ('Pending Approval', 'Planned', 'In-Progress', 'In-Progress Pending Approval', 'In-Progress Pending Review', 'In-Progress Revision Required')) OR (Core_MDF_Fund_Request_Status__c IN ('Closed') AND Core_MDF_Activity_Closure_Type__c NOT IN ('Auto - Missed Approval')))))
                                                AND Campaign.Core_MDF_Budget_Cap__c IN :budgetCapIdSet GROUP BY Campaign.Core_MDF_Budget_Cap__c]) {
                    budgetCapIDtoCampSumMap.put((Id)aggRes.get('Core_MDF_Budget_Cap__c'),(Decimal)aggRes.get('TotalClaimedAmt'));
                }
            }
            
            for(Id budgetCapId : budgetCapIdSet) {
                if(budgetCapIDtoCampSumMap.containsKey(budgetCapId)){
                    final Decimal claimedCapAmount = budgetCapIDtoCampSumMap.get(budgetCapId);
                    Core_MDF_Budget_Cap__c budgetCapObj = new Core_MDF_Budget_Cap__c();
                    budgetCapObj.Id = budgetCapId;
                    budgetCapObj.Core_MDF_Claimed_Cap_amt__c = claimedCapAmount;
                    Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e();
                    evtObj.Core_MDF_JSON_Data__c = JSON.serialize(budgetCapObj);
                    evtObj.Core_MDF_Object_Name__c = 'Core_MDF_Budget_Cap__c';
                    updateRecordList.add(evtObj);
                } else {
                    Core_MDF_Budget_Cap__c budgetCapObj = new Core_MDF_Budget_Cap__c();
                    budgetCapObj.Id = budgetCapId;
                    budgetCapObj.Core_MDF_Claimed_Cap_amt__c = 0;
                    Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e();
                    evtObj.Core_MDF_JSON_Data__c = JSON.serialize(budgetCapObj);
                    evtObj.Core_MDF_Object_Name__c = 'Core_MDF_Budget_Cap__c';
                    updateRecordList.add(evtObj);
                }
            }
            

                
            if(updateRecordList != null && !updateRecordList.isEmpty()){              
                List<Database.SaveResult> results = EventBus.publish(updateRecordList);
                for(Database.SaveResult sr : results) {
                    if(sr.isSuccess()) {
                      
                    } else { 
                        for(Database.Error err : sr.getErrors()) { 
                        
                        }
                    }
                }  
            }
        }
        catch(Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
        }
    }
       
   /****************************************************************************************************************************************
    * Method Name           : notifyExternalReviewers
    * Created Date          : 20-8-2021
    * @return               : void
    * @parameters           : List of all the Campaign Records 
    * Modification Log
    * Developer             Date                Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
      Accenture-Karan       20-8-2021           US1048034-[IPA MDF] - Notifications- Show comments in notifications
      Accenture-Sai     22-1-2022       TWC702-932: WW02 | DEVINT3 | Multiple emails of status change are triggered to IPA external user for Asynchronous approval flow fix (Code optimization)
      Accenture-Roshan    19-01-2025     Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
    *****************************************************************************************************************************************/

    public static void notifyExternalReviewers(list<Campaign> campaignList){
        
        Set<Id> campAccIdSet =new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
        Map<Id, Set<Id>> pnumAccountIdUserIdsMap = new Map<Id,Set<Id>>();
        Map<Id,Id> externalUsersIdMap = new Map<Id,Id>();
        try{
            if(campaignList!= null && campaignList.size() > 0){
                for(Campaign camp : campaignList){
                    campAccIdSet.add(camp.Core_MDF_Account__c);
                }
            }

            Map<Id,Set<Id>> pnumAccIdUserMap = new Map<Id,Set<Id>>();
            Map<Id, Set<Id>> pnumAccIdUserIdMap = new Map<Id,Set<Id>>();
            if(campAccIdSet != null && campAccIdSet.size() > 0){
                for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_Account__c, Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                                  WHERE Core_MDF_Account__c IN : campAccIdSet AND (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE) AND Core_MDF_Active_Ind__c = TRUE]){
                                                                      userIdSet.add(pnum.Core_MDF_User__c);
                                                                      if(pnumAccountIdUserIdsMap.containsKey(pnum.Core_MDF_Account__c)){
                                                                          pnumAccountIdUserIdsMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
                                                                      }else{
                                                                          pnumAccountIdUserIdsMap.put(pnum.Core_MDF_Account__c, new Set<Id> {pnum.Core_MDF_User__c});
                                                                      } 
                                                                  }                                                        
            }
            if(userIdSet != NULL  && userIdSet.size() > 0){
                List<String> extPermSetsList = new List<String>();
                String extPermSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Extrnl_Prposl_Mgr_Prmsn_Set');  //Roshan - added CoGTM PS
                if(extPermSet != null){
                    extPermSetsList = extPermSet.split(','); 
                }
                for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                      FROM PermissionSetAssignment WHERE AssigneeId IN :userIdSet 
                                                      AND PermissionSet.Name = : extPermSetsList]){
                                                          externalUsersIdMap.put(usrPer.AssigneeId, usrPer.AssigneeId);
                                                      }
            }
            if(campaignList!= null && campaignList.size() > 0){
                for(Campaign camp : campaignList){
                    List<Id> extUserIdList = new List<Id>();

                    //Roshan - added CoGTM program check for sending email to Member Acceptor only
                    if (camp.Core_MDF_Program__c == 'CoGTM') {
                        if (camp.Core_MDF_Member_Acceptor_id__c != null && pnumAccountIdUserIdsMap.containsKey(camp.Core_MDF_Account__c) && pnumAccountIdUserIdsMap.get(camp.Core_MDF_Account__c) != null 
                            && pnumAccountIdUserIdsMap.get(camp.Core_MDF_Account__c).contains(camp.Core_MDF_Member_Acceptor_id__c) && externalUsersIdMap.containsKey(camp.Core_MDF_Member_Acceptor_id__c)) {
                            extUserIdList.add(camp.Core_MDF_Member_Acceptor_id__c);
                        }
                    } else {
                        Set<Id> externalUserIds = pnumAccountIdUserIdsMap.get(camp.Core_MDF_Account__c); 
                        if(externalUserIds != NULL  && externalUserIds.size() > 0){
                            for(Id externalUserId : externalUserIds){
                                if(externalUsersIdMap.get(externalUserId) != null){
                                    extUserIdList.add(externalUsersIdMap.get(externalUserId));
                                }    
                            }    
                        } 
                    }
                    if(extUserIdList != NULL  && extUserIdList.size() > 0){                   
                        for(Id extUsrId : extUserIdList){
                            List<Id> extUList = new List<Id>();
                            extUList.add(extUsrId);
                            Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
                            sendEmailToExt.recordId = camp.Id;
                            if(camp.Core_MDF_Program__c == 'Intel Partner Alliance' || camp.Core_MDF_Program__c == 'CoGTM'){
                                sendEmailToExt.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NotifyExtUsrOnProposalApproval');
                            }
                            sendEmailToExt.userIdList = extUList;
                            sendEmailToExt.sendDiff = false;
                            inputList.add(sendEmailToExt);
                        }     
                    }     
                }
                //system.debug('inputList@@@' + inputList);   //ATHR
                if(inputList != NULL && inputList.size() >0){
                    Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
	//NP - WW33 Do not allow removal of country if used in an active activity
    public static boolean checkIfFieldsUsedInActivityNotRemoved(List<Campaign> newCmpList, Map<Id,Campaign> campOldMap,string program, Map<String, String> cmpProgWithPLfieldsMap,Map<String, Schema.DisplayType> cmpFieldtoFieldDataType,Map<String, String> cmpFieldtoFieldLabel,Map<String, String> cmpProgWithCampNotEditFieldsMap){
        List<Core_MDF_ProcessCCP_Campaign.campaignEditWrapper> wrapperList = new List<Core_MDF_ProcessCCP_Campaign.campaignEditWrapper>();
         Map<Id,List<String>> cmpIdfieldListMap = new Map<Id,List<String>>();
        Set<Id> campIdSet = new Set<Id>();  
        Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
        String errorpickfields =''; 
        boolean error = false;
        Map<Id, List<String>> campIdAndCampFieldMap = new Map<Id,List<String>>();
        Map<String, Object> campFieldAPINameAndActivityFieldAPINameJSON = new Map<String, Object>();//(Map<String, Object>) JSON.deserializeUntyped(Core_MDF_CCP_ConstantClass.CAMPAIGN_FIELD_AND_ACTIVITY_FIELD_APINAMES);
        Map<string,string> campFieldAPINameAndActivityFieldAPINameMap= new Map<string,string>();
        List<Campaign> cmpListwithoutPRF = new List<Campaign>();
        //get Json based on program
        for(Campaign cmp: newCmpList){
            
            if(cmp.RecordTypeId  == ipaCampRecTypeId ){
                campFieldAPINameAndActivityFieldAPINameJSON = (Map<String, Object>) JSON.deserializeUntyped(Core_MDF_CCP_ConstantClass.CAMPAIGN_FIELD_AND_ACTIVITY_FIELD_APINAMES);
            }
            else if(cmp.RecordTypeId  == dcfRecordTypeId || cmp.RecordTypeId == ccfRecordTypeId || cmp.RecordTypeId == retailRecordTypeId || cmp.RecordTypeId == eefRecordTypeId){
                campFieldAPINameAndActivityFieldAPINameJSON = (Map<String, Object>) JSON.deserializeUntyped(Core_MDF_CCP_ConstantClass.CCP_CAMPAIGN_FIELD_AND_ACTIVITY_FIELD_APINAMES);
            }
            
            if(!propBasedCampIdPfrListIdMap.containsKey(cmp.Id) && !propBasedCampIdClosedPfrListIdMap.containsKey(cmp.Id)){
                cmpListwithoutPRF.add(cmp);
            }
        }
        for(String strKey: campFieldAPINameAndActivityFieldAPINameJSON.keyset())
        {
            campFieldAPINameAndActivityFieldAPINameMap.put(strKey, String.valueof(campFieldAPINameAndActivityFieldAPINameJSON.get(strKey)));
        }
        
        // check if PFR record is already query
        if(cmpListwithoutPRF != NULL && cmpListwithoutPRF.Size() > 0){
        	queryPFRRecords(cmpListwithoutPRF);
        }
        
        
        for(Campaign cmp: newCmpList){
           // System.debug('@@@v1'+program); System.debug('@@@v2'+cmpProgWithPLfieldsMap); System.debug('@@@v3'+cmpProgWithPLfieldsMap.get(program)); //ATHR
            for(String strField: cmpProgWithPLfieldsMap.get(program).Split(',')){
                if(campOldMap.get(cmp.Id).get(strField) != cmp.get(strField)){
                    Core_MDF_ProcessCCP_Campaign.campaignEditWrapper wrapper = new Core_MDF_ProcessCCP_Campaign.campaignEditWrapper();
                    wrapper.field = strField;
                    wrapper.newCmp = cmp;
                    wrapper.oldCmp = campOldMap.get(cmp.Id);
                    wrapperList.add(wrapper);
                }    
            }
        }
        
        if(wrapperList != NULL && wrapperList.Size() > 0){
            
            for(Core_MDF_ProcessCCP_Campaign.campaignEditWrapper wrapper : wrapperList){
                Boolean isRemoved = Core_MDF_ProcessCCP_Campaign.checkEdit(wrapper.newCmp, wrapper.oldCmp, wrapper.field);
               
                String labelValue = cmpFieldtoFieldLabel.get(wrapper.field); //fieldMap.get(wrapper.field).getDescribe().getLabel();
                if(isRemoved){
                    campIdSet.add(wrapper.newCmp.Id);
                    if(campIdAndCampFieldMap.containsKey(wrapper.newCmp.Id)){
                        //cmpIdfieldListMap.get(wrapper.newCmp.Id).add(labelValue);
                        campIdAndCampFieldMap.get(wrapper.newCmp.Id).add(wrapper.field);
                    }else{
                        //cmpIdfieldListMap.put(wrapper.newCmp.Id, new List<String>{labelValue});
                        campIdAndCampFieldMap.put(wrapper.newCmp.Id, new List<String>{wrapper.field});
                    }
                }
            }
        }
        
        
        
        for(campaign cmp: newCmpList) {
            //Integer newCampYear = cmp.startDate.year();
            //Integer oldCampYear = campOldMap.get(cmp.Id).startDate.year();
  
            if((propBasedCampIdPfrListIdMap.containsKey(cmp.id) || propBasedCampIdClosedPfrListIdMap.containsKey(cmp.id)) && campIdAndCampFieldMap.containsKey(cmp.Id)) {
             
                for(String campField : campIdAndCampFieldMap.get(cmp.Id)) {
                    String labelValue = cmpFieldtoFieldLabel.get(campField); //fieldMap.get(campField).getDescribe().getLabel();
                    Schema.DisplayType campFieldDataType = cmpFieldtoFieldDataType.get(campField); //fieldMap.get(campField).getDescribe().getType();
                    if(campFieldDataType == Schema.DisplayType.MULTIPICKLIST && !campFieldAPINameAndActivityFieldAPINameMap.isEmpty()) {
                        if(campFieldAPINameAndActivityFieldAPINameMap.get(campField) != null) {
                            Set<string> actPicklistValues = new Set<string>();
                            String campPicklistValues = (String)cmp.get(campField);
                            //check if field Acivity Category Type as its using '->'
                            if(campField == 'Core_MDF_Activity_Category_Type__c'){
                                // if(oldCampYear == newCampYear) {
                                if(campIdActCatTypesSet != null && campIdActCatTypesSet.size() > 0) {
                                    for(String actCatType: campIdActCatTypesSet.get(cmp.Id)){
                                        if(String.isNotBlank(actCatType)){
                                        actPicklistValues.addAll(new Set<string>(actCatType.split(';')));
                                     }
                                    }
                                }
                            }
                            else{
                                /*for(PartnerFundRequest pfr: propBasedCampIdPfrListIdMap.get(cmp.Id))
                                {	String valuesFromActivityAsString = (String)pfr.get(campFieldAPINameAndActivityFieldAPINameMap.get(campField));
                                 if(String.isNotBlank(valuesFromActivityAsString)){
                                     actPicklistValues.addAll(new Set<string>(valuesFromActivityAsString.split(';')));
                                 }
                                }*/
                                actPicklistValues.addAll(getSelectedPickValFromAct(campFieldAPINameAndActivityFieldAPINameMap, campField, cmp.Id));
                            }
                            if(actPicklistValues.size() > 0){
                                
                                    errorpickfields = errorpickfields == '' ? getRemovedPicklistValue(campPicklistValues, actPicklistValues, labelValue, program) : errorpickfields + '<br>' + getRemovedPicklistValue(campPicklistValues,actPicklistValues, labelValue, program);
                                
                        	}
                        }
                    } else {
                        Campaign oldCamp = campOldMap.get(cmp.Id);
                       String campPicklistValues = (String)oldCamp.get(campField);
                        if(cmpProgWithCampNotEditFieldsMap.containsKey(program) && cmpProgWithCampNotEditFieldsMap.get(program) != null && cmpProgWithCampNotEditFieldsMap.get(program).contains(campField)){
                             //errorpickfields = errorpickfields == ''  ? labelValue + ' - '+ campField : errorpickfields + '<br>' + labelValue + ' - '+ campField;
                              errorpickfields = errorpickfields == ''  ? labelValue + ' - '+ campPicklistValues : errorpickfields + '<br>' + labelValue + ' - '+ campPicklistValues;

                        }else{
                       
                       Set<string> actPicklistValues = new Set<string>();
                            /*for(PartnerFundRequest pfr: propBasedCampIdPfrListIdMap.get(cmp.Id)){
                                String valuesFromActivityAsString = (String)pfr.get(campFieldAPINameAndActivityFieldAPINameMap.get(campField));
                                if(String.isNotBlank(valuesFromActivityAsString)){
                                    actPicklistValues.addAll(new Set<string>(valuesFromActivityAsString.split(';')));
                                }
                            }*/
                            actPicklistValues.addAll(getSelectedPickValFromAct(campFieldAPINameAndActivityFieldAPINameMap, campField, cmp.Id));
                            if(String.isNotBlank(campPicklistValues) && actPicklistValues.size() > 0){
                            if(actPicklistValues.contains(campPicklistValues)){
                                
                        errorpickfields = errorpickfields == ''  ? labelValue + ' - '+ campPicklistValues : errorpickfields + '<br>' + labelValue + ' - '+ campPicklistValues;
                            	
                            }   
                        }
                        }
                    }
                }
            }
            
            if(String.IsNotBlank(errorpickfields)) {
          
                ///errorpickfields.replaceall('<br>','');
                //String pattern = '(<br>\\s*)+';

				// Replace consecutive <br> tags with a single <br>
			    //errorpickfields = errorpickfields.replaceAll(pattern, '<br>');
             
                errorpickfields = Label.Core_MDF_IPA_Edit_PicklistValue_Removal_Error + '<br>'+ errorpickfields+'#';
            
                cmp.addError(errorpickfields);
                error = true;
            } 
        }
        return error;
    }
    
    
    
    public static String getRemovedPicklistValue (String valuesFromCampaign, Set<String> valuesFromActivity, String labelValue, String program) {
        String removedPickListValueFromCampaign = '';
        String errorpickfields = '';

       	List<string> valuesofCampList = new List<string>();
        if(String.isNotBlank(valuesFromCampaign)){
            valuesofCampList = valuesFromCampaign.split(';');
        }

        for(string picklistValue: valuesFromActivity){
            if(!valuesofCampList.isEmpty() && valuesofCampList.size()>0){
                if(!valuesofCampList.contains(picklistValue)){
                    removedPickListValueFromCampaign = removedPickListValueFromCampaign == ''?picklistValue : removedPickListValueFromCampaign + ',' + picklistValue;
                }
            }
            else{
                removedPickListValueFromCampaign = removedPickListValueFromCampaign == ''?picklistValue : removedPickListValueFromCampaign + ',' + picklistValue;
            }
        }
        
        if(String.isNotBlank(removedPickListValueFromCampaign)){

        	errorpickfields =  labelValue + ' - '+ removedPickListValueFromCampaign +'<br>';  
        }
        return errorpickfields;
    }

    //method to add picklist values from the map
    public static Set<String> addPicklistValuesFromMap(Map<Id, List<PartnerFundRequest>> pfrMap, Map<String, String> campFieldAPINameAndActivityFieldAPINameMap, String campField, Id campId) {
        Set<String> actPicklistValues = new Set<String>();
        if (pfrMap != null && pfrMap.size() > 0 && pfrMap.containsKey(campId)) {
            for (PartnerFundRequest pfr : pfrMap.get(campId)) {
                String valuesFromActivityAsString = (String) pfr.get(campFieldAPINameAndActivityFieldAPINameMap.get(campField));
                if (String.isNotBlank(valuesFromActivityAsString)) {
                    actPicklistValues.addAll(new Set<String>(valuesFromActivityAsString.split(';')));
                }
            }
     
        }
        return actPicklistValues;
    }

    public static Set<String> getSelectedPickValFromAct(Map<String, String> campFieldAPINameAndActivityFieldAPINameMap, String campField, Id campId) {
        Set<String> selActPicklistValues = new Set<String>();
        if (propBasedCampIdPfrListIdMap != null && propBasedCampIdPfrListIdMap.size() > 0) {
            selActPicklistValues.addAll(addPicklistValuesFromMap(propBasedCampIdPfrListIdMap, campFieldAPINameAndActivityFieldAPINameMap, campField, campId));
        }
        if (propBasedCampIdClosedPfrListIdMap != null && propBasedCampIdClosedPfrListIdMap.size() > 0) {
            selActPicklistValues.addAll(addPicklistValuesFromMap(propBasedCampIdClosedPfrListIdMap, campFieldAPINameAndActivityFieldAPINameMap, campField, campId));
        }
        return selActPicklistValues;
    }

    //Roshan - IPA campaign approval
    public static void processIPACampaignApproval(Campaign cmp, Map<String, List<String>> iupgmUserMap, Map<Id, Campaign> oldCampMap, Boolean isStageChange, Map<String, List<String>> cmpToActClassificationMap, Set<Id> setOfValidMarketingActivity) {

        if(cmp.Core_MDF_Host_Region_cd__c !=null) {
            Integer count=0;
            List<String> regionList= new List<String>();
            regionList.add(cmp.Core_MDF_Host_Region_cd__c);
            regionList.add('WW');
            for(String region: regionList) {
                String ultimateAccount = (String)cmp.Core_MDF_Ultimate_Account_txt__c;
                Id ultAccount= ultimateAccount;
                String geoAccIdBudTypeKey = region+ '->' +cmp.Core_MDF_Opal_Budget_Type_Txt__c + ultAccount ;
                String geoKey= region;
                String geoAcctKey= region + ultAccount;
                String geoBudTypeKey= region+ '->' + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
                List<String> userIdList = new List<String> ();
            
                if(iupgmUserMap.containsKey(geoAccIdBudTypeKey)){
                    userIdList = iupgmUserMap.get(geoAccIdBudTypeKey);
                }else if(iupgmUserMap.containsKey(geoAcctKey)){
                    userIdList = iupgmUserMap.get(geoAcctKey);
                }else if(iupgmUserMap.containsKey(geoBudTypeKey)){
                    userIdList = iupgmUserMap.get(geoBudTypeKey);
                }else if(iupgmUserMap.containsKey(geoKey)){
                    userIdList = iupgmUserMap.get(geoKey);
                }
                
                if(userIdList.Contains(UserInfo.getUserId()) && isStageChange && oldCampMap.get(cmp.Id).Core_MDF_Approval_Step_Counter_nbr__c == 0){
                    cmp.Core_MDF_Approval_Step_Counter_nbr__c = 1;
                    cmp.Core_MDF_Completed_Approval_Level_Nm__c = Core_MDF_CCP_ConstantClass.COMPLETED_APPROVAL_LEVEL; //L1 Approval
                }   
            }
        }          
        if(cmp.Status == 'Pending Review' && cmp.Core_MDF_Proposal_Based_Ind__c == true) {
            if (cmp.Core_MDF_Approval_Step_Counter_nbr__c == 0 && cmp.Core_MDF_Approval_Stage_nm__c != 'L1 Approval' && cmp.Core_MDF_IPA_Approval_Status_nm__c !='Pending Approval') {
                cmp.Core_MDF_Approval_Stage_nm__c = 'L1 Approval';
            }
            if(cmp.Core_MDF_Approval_Step_Counter_nbr__c != oldCampMap.get(cmp.Id).Core_MDF_Approval_Step_Counter_nbr__c ) {
                if(cmp.Core_MDF_Total_Campaign_Cost_Amt__c==0 && oldCampMap.get(cmp.Id).Core_MDF_Total_Campaign_Cost_Amt__c==0) {
                    cmp.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Proposal_Approval_Error'));
                } else {
                    if(cmp.Core_MDF_Approval_Step_Counter_nbr__c == 1 && cmp.Core_MDF_IPA_NonSPIF_Apprval_Ind__c && cmp.Core_MDF_Approval_Stage_nm__c != 'Program Office Reviewer') {
                        cmp.Core_MDF_Approval_Stage_nm__c = 'Program Office Reviewer';
                    } else if (cmp.Core_MDF_IPA_SPIF_Apprval_Ind__c && ((cmp.Core_MDF_Approval_Step_Counter_nbr__c == 2) || (cmp.Core_MDF_Approval_Step_Counter_nbr__c == 1)) && cmp.Core_MDF_Approval_Stage_nm__c != 'Price Reviewer') {
                        cmp.Core_MDF_Approval_Stage_nm__c = 'Price Reviewer';
                    } else if ((cmp.Core_MDF_Approval_Step_Counter_nbr__c == 1 ||cmp.Core_MDF_Approval_Step_Counter_nbr__c == 2||cmp.Core_MDF_Approval_Step_Counter_nbr__c == 3) && cmp.Core_MDF_Approval_Stage_nm__c != 'L2 Regional Marketing' 
                                && cmpToActClassificationMap.containsKey(cmp.Id) && cmpToActClassificationMap.get(cmp.Id).contains('Marketing') 
                                && (cmp.Core_MDF_Reimbursement_Amt__c >= Core_MDF_CustomLabelConfig.getDoubleValues('Core_MDF_Camp_Reimb_Amt_Limit') || setOfValidMarketingActivity.contains(cmp.Id))) {
                        cmp.Core_MDF_Approval_Stage_nm__c = 'L2 Regional Marketing';
                    } else if ((cmp.Core_MDF_Approval_Step_Counter_nbr__c >= 1 && cmp.Core_MDF_Approval_Stage_nm__c != 'L2 Regional Sales' && cmp.Core_MDF_Approval_Stage_nm__c != 'Customer Acceptance')) {
                        cmp.Core_MDF_Approval_Stage_nm__c = 'L2 Regional Sales';
                    } 
                }
            }
        } else if ((oldCampMap != null && oldCampMap.size() > 0 && cmp.Core_MDF_Approval_Step_Counter_nbr__c != oldCampMap.get(cmp.Id).Core_MDF_Approval_Step_Counter_nbr__c) 
                    && cmp.Status == 'Pending Approval' && cmp.Core_MDF_Proposal_Based_Ind__c == true && cmp.Core_MDF_Approval_Step_Counter_nbr__c >= 2 && cmp.Core_MDF_Approval_Stage_nm__c == 'L2 Regional Sales') { 
            if(cmp.Core_MDF_Total_Campaign_Cost_Amt__c==0 && oldCampMap.get(cmp.Id).Core_MDF_Total_Campaign_Cost_Amt__c==0) {
                cmp.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Proposal_Approval_Error'));
            } else {
                cmp.Core_MDF_Approval_Stage_nm__c = 'Customer Acceptance';
            }
        } else if(cmp.Core_MDF_IPA_Approval_Status_nm__c !='Pending Approval'){
            cmp.Core_MDF_Approval_Stage_nm__c = '';
        }
    }
    
    //Roshan - Co-GTM campaign setup
    public static void processProjectBasedApproval(Campaign cmp, Map<Id, Campaign> oldCampMap) {
        Campaign oldCmp = oldCampMap != null ? oldCampMap.get(cmp.Id) : null;
        Boolean isStepChanged = oldCmp != null && oldCmp.Core_MDF_Approval_Step_Counter_nbr__c != cmp.Core_MDF_Approval_Step_Counter_nbr__c;
        Boolean hasContract = campaignIdToContractsMap.containsKey(cmp.Id) && !campaignIdToContractsMap.get(cmp.Id).isEmpty();

        if (cmp.Status == 'Pending Review') {
              
            if (cmp.Core_MDF_Approval_Step_Counter_nbr__c == 0) {
                if (cmp.Core_MDF_Total_Campaign_Cost_Amt__c == 0 && oldCmp.Core_MDF_Total_Campaign_Cost_Amt__c == 0) {
                    cmp.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Proposal_Approval_Error'));
                } else {
                    if (hasContract) {
                    cmp.Core_MDF_Approval_Stage_nm__c = 'Legal Reviewer';
                    } else {
                        cmp.Core_MDF_Approval_Stage_nm__c = 'Business Approver';
                    }
                }
            }

            if (isStepChanged && cmp.Core_MDF_Approval_Step_Counter_nbr__c > 0) {
                    if (cmp.Core_MDF_Approval_Step_Counter_nbr__c == 1 && cmp.Core_MDF_Approval_Stage_nm__c != 'Business Approver') {
                        cmp.Core_MDF_Approval_Stage_nm__c = 'Business Approver';
                    } else if ((cmp.Core_MDF_Approval_Step_Counter_nbr__c == 1 || cmp.Core_MDF_Approval_Step_Counter_nbr__c == 2) 
                                && cmp.Core_MDF_Reimbursement_Amt__c >= Core_MDF_CustomLabelConfig.getDoubleValues('Core_MDF_CoGTM_Camp_Reimb_Amt_Limit') 
                                && cmp.Core_MDF_Approval_Stage_nm__c != 'L2 Approval') {
                        cmp.Core_MDF_Approval_Stage_nm__c = 'L2 Approval';
                    } else if (cmp.Core_MDF_Approval_Step_Counter_nbr__c >= 1) {
                        cmp.Core_MDF_Approval_Stage_nm__c = 'Customer Acceptance';
                        cmp.Status = 'Pending Approval';
                    }

            }
        }
    }
}