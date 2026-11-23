/****************************************************************************************************** 
Class Name:         Core_MDF_Process_PartnerFundRequest
@parameters:        N/A
Description:        Before Insert/Upadte call these functions and update the activity to be closed date
Added By:           Harshadeep   06-27-2022
Modified By:        Date:           Changes:
Shivaprasad         08-29-2019      Added the condition to check closed status of PFR records in populateBackEndFieldsUpdate method.
Mohit Sharma        02-28-2024      Update condition in this method deriveRRandAmt to populate Amount field on proposal based activity
*******************************************************************************************************/
public without sharing class Core_MDF_Process_PartnerFundRequest {
    public class CustomException extends Exception{}
    public static Boolean stopStatusUpdate = false;
    public static Boolean emailSendOnce = true;
    public static Boolean emailSendOnceL1 = true;
    public static Boolean sendNotificationByFlowOnce = true;
    public static Boolean noAction = false;
    public static Map<String, Boolean> pfrApprovalSendMap = new Map<String, Boolean>();
    public static Boolean plannedEmailSendOnce = true;
    public static Map<Id, PartnerFundRequest> oldStaticPFRMap = new Map<Id, PartnerFundRequest>();
    public static Map<Id,String> accIdRegionMap = new Map<Id,String>();
    public static Boolean sendEmailOnce = true;
    public static Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosById();
    //Avoid Using Empty Schema Methods
    public static final string pfrPrefixKey = PartnerFundRequest.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix();
    //Added by Sai
    public static Map<Id,String> nodeAccIdRegionMap = new Map<Id,String>();
    public static Map<Id,String> accIdCountryMap = new Map<Id,String>();
    
    
    
    //Added By Sai
    //Need to re-look at it - will static works fine here?
    public static CustomPermissionsWrapper cusPerm = getCustomPermissions();
    //ruleEngine Map
    public static Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>> ruleEngineResult = new  Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>>();
    public static Map<PartnerFundRequest,Core_MDF_Rules_Engine.RulesEngineParams> pfrToRuleEngineMap = new Map<PartnerFundRequest,Core_MDF_Rules_Engine.RulesEngineParams>();
    public static Map<String, List<String>> approversFromIUPGMMap = new Map<String, List<String>>();
    /****************************************************************************************************** 
Method Name:        populateBackEndFieldsUpdate
@return  :          void
@parameters:        PFR Map
Description:        This method is used to update the to be closed date before update trigger
Added By:           Sridhar - 06/17/2019
Modified By:        Date:         Changes: 
Shivaprasad         08-29-2019    Added the condition to check closed status of PFR records.
*******************************************************************************************************/
    
    public static void populateBackEndFieldsUpdate(Map<Id,PartnerFundRequest> newMap, Map<Id,PartnerFundRequest> oldMap)
    {
        try
        {
            if(oldMap != NULL && oldMap.size() > 0){
                oldStaticPFRMap = oldMap;
            }
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            List<PartnerFundRequest> budgetCurrencyExchangeRatePFRList = new List<PartnerFundRequest>();
            if(newMap != NULL && newMap.size() > 0){
                pfrList.addAll(newMap.values());
            }
            if (pfrList != NULL && pfrList.size() > 0)
            {
                processPFRRecords(pfrList,oldMap);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    /****************************************************************************************************** 
Method Name:        populateBackEndFieldsInsert
@return  :          void
@parameters:        PFR Map
Description:        This method is used to update the to be closed date in before insert
Added By:           Sridhar - 06/17/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public static void populateBackEndFieldsInsert(List<PartnerFundRequest> newList)
    {
        try
        {
            if (newList != NULL && newList.size() > 0)
            {
                //close activity & activity event rules method call
                processPFRRecords(newList,NULL); 
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    /****************************************************************************************************** 
Method Name:        populatePfrFields
@return  :          void
@parameters:        list of old and new PFR
Description:        update pfr fields
Added By:           Khushi - 06/16/2023
Modified By:        Date:      Changes: 
*******************************************************************************************************/  
    
    
    public static void populatePfrFields(List<PartnerFundRequest> pfrList,Map<Id,PartnerFundRequest> oldMap,Boolean isInsert,Boolean isBefore){
        
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_PFR_Field_Update_Bypass')){
            for(PartnerFundRequest pfr: pfrList){
                
                populateEcosystemPartner(pfr,oldMap,isInsert,isBefore);
            }
        }
        
    }
    
    public static void populateEcosystemPartner(PartnerFundRequest pfr,Map<Id,PartnerFundRequest> oldMap,Boolean isInsert,Boolean isBefore){
        
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_PFR_Bypass_EcosystemUpdate')){
            if((isInsert ||(oldMap!=null && oldMap.get(pfr.Id).Core_MDF_EcosystemPartner_nm__c != pfr.Core_MDF_EcosystemPartner_nm__c)) 
               && pfr.Core_MDF_Program__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA')){
                   pfr.Core_MDF_Channel_Partner__c=pfr.Core_MDF_EcosystemPartner_nm__c;
                   
               }
            
        }
        
    }
    
    
    /****************************************************************************************************** 
Method Name:        processPFRRecords
@return  :          void
@parameters:        list of PFR
Description:        proess all the records and update the to be closed date and event activity validation
Added By:           Sridhar - 06/17/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    
    public static void processPFRRecords(List<PartnerFundRequest> pfrList, Map<Id,PartnerFundRequest> oldPfrMap)
    {
        
        try{
            Id coGtmRecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
            Core_MDF_PartnerFundRequest_Utility.ClaimActAllocRecTypeMappingWrapper claimActAllocRecTypeMapWrapInstance = Core_MDF_PartnerFundRequest_Utility.getMetaDataValues();
            
            // Mapping Of RecordType and associated close date
            Map<String,Integer> activityRecordTypeCloseDateMap = new Map<String,Integer>();
            activityRecordTypeCloseDateMap = claimActAllocRecTypeMapWrapInstance.activityRecordTypeCloseDateMap;
            
            
            //Program and supported Geo Map 
            Map<String, List<String>> activityRecordTypeGeoListMap = new Map<String,List<String>>();
            activityRecordTypeGeoListMap = claimActAllocRecTypeMapWrapInstance.activityRecordTypeGeoListMap;
            
            // RecordTypeId and RecordType DeveloperName Map 
            Map<Id,String> ccpRecordTypeIds = new Map<Id,String>();
            ccpRecordTypeIds = Core_MDF_PartnerFundRequest_Utility.getCCPRTNames(activityRecordTypeCloseDateMap);
            
            //loop meta data and form Map --> Record type id, list of metadata //Record type restrict
            
            //Attributes Map metadata
            Map<String, List<Core_MDF_CCP_Custom_Metadata_Utility__c>> pfrRecordTypeAttributeMetadataMap = new Map<String, List<Core_MDF_CCP_Custom_Metadata_Utility__c>>();
            
            //Auto closure Maps to get from submission winodw meta data
            Map<String, Date> quarterEndRsltMap = new Map<String, Date>();
            Map<String, Date> closeDateExtensionMap = new Map<String, Date>();
            //Country Geo Map
            Map<String, String> countryGeoMap = new Map <String, String>();
            Map<String, String> countrySubGeoMap = new Map <String, String>();
            
            //EEF custom permissions
            Boolean isEEFActivatingUser = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_EEF_Activating_Account_Manager');
            Boolean isEEFPrimaryUser = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_EEF_Primary_Account_Manager');
            Set<Id> campaignIds = new Set<Id>();
            
            //List of SPIF Activity Types
            List<String> spifActivityTypesList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPIF_Activity_Types').Split(';');
            List<String> otherActivityTypesList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Other_Activity_Types').Split(';');
            List<String> buSplitProgramList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BUSplit_Program_Types').Split(';');
            Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> brandFAProductTypeBUMap = new Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>>();
            Map<String,Decimal> buRankingMap = new Map<String,Decimal>();
            
            
            List<PartnerFundRequest> pendingApprovalPfrList = new List<PartnerFundRequest>();
            List<PartnerFundRequest> externalPendingApprovalPfrList = new List<PartnerFundRequest>();
            Set<Id> accIdSet = new Set<Id>();
            
            Map<Id, Id> crtdByIdPfrIdMap = new Map<Id, Id>();
            Map<Id, Id> pfrIdMgrIdMap = new Map<Id, Id>();
            Set<Id> userIdSet = new Set<Id>(); 
            Map<Id,Id> userIdManagerMap = new Map<Id,Id>();
            
            Set<String> brandSet = new Set<String>();
            List<String> brandList = new List<String>();
            Set<String> productTypeSet = new Set<String>();
            Set<String> focusAreaSet = new Set<String>();
            Set<String> businessUnitSet = new Set<String>();
            
            //ATF Flags
            String atfDate = System.Label.Core_MDF_ATF_Insertion_Status;
            String atfPlannedStatus = System.Label.Core_MDF_ATF_Planned_Status;
            String atfRRStatus = System.Label.Core_MDF_ATF_RR_Status;
            String atfClosedStatus = System.Label.Core_MDF_ATF_Closed_Status;
            
            //Fetch Product Category
            Map<String, String> prodTypeCategoryMap = new Map<String, String>();
            
            String programForProdCategorySplits = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AppliPrgmsFor_Product_Cat_Split');
            
            prodTypeCategoryMap = productTypeCatSplitMap();
            
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaDataList = Core_MDF_CCP_Country_Geo_Mapping__mdt.getAll().values();
            
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : countryGeoMetaDataList){
                countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
                countrySubGeoMap.put(countryGeoMetaData.MasterLabel, countryGeoMetaData.Core_MDF_Sub_Geo__c);
            }
            
            if(pfrList != NULL && pfrList.size() > 0 ){
                
                //Get the Qtr start and end dates based on PFR date
                Map<Id,List<Date>> pfrDateMap = new Map<Id,List<Date>>();
                pfrDateMap = getQtrStartAndEndDates(pfrList,ccpRecordTypeIds); 
                
                Set<Id> accountIdSet = new Set<Id>();
                Map<Id, Id> pfrIdCampIdMap = new Map<Id, Id>();
                Map<Id, Id> pfrIdAccountIdMap = new Map<Id, Id>();
                Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
                
                Map<String, Date> quarterEndDateMap = new Map<String, Date>();
                Boolean bypassFlag = false;
                Boolean bypassFlagBatch = Core_MDF_Utility.byPassFeature('Core_MDF_EnableATFFlagUpdateBatch');
                Boolean bypassFlagATFUpdate=Core_MDF_Utility.byPassFeature('Core_MDF_BypassATFFlagUpdate');
                if(!bypassFlagBatch && bypassFlagATFUpdate){
                    bypassFlag = true;
                }
                else if(!System.isBatch() && bypassFlagATFUpdate)
                {
                    bypassFlag = true;
                }
                else if(System.isBatch() && !bypassFlagBatch)
                {
                    bypassFlag = true;
                }
                else
                {
                    bypassFlag = false;
                }
                
                List<PartnerFundRequest> coGtmActivityList = new List<PartnerFundRequest>();
                Set<String> coGtmCampaignSet = new Set<String>();
                Set<String> coGtmBudgetIdSet = new Set<String>();
                Set<String> coGtmAccountIdSet = new Set<String>();
                
                /// This loop collects the campiagn Ids, Account Ids   
                for(PartnerFundRequest pfr: pfrList){
                    /* if(!bypassFlag) // need to move this code
{
setATFFlag(pfr,oldPfrMap);                 
}     */ 
                    
                    if(oldPfrMap == null && pfr.RecordTypeId == coGtmRecordTypeId){
                        coGtmActivityList.add(pfr);
                        coGtmCampaignSet.add(pfr.CampaignId);
                        coGtmBudgetIdSet.add(pfr.BudgetId);
                        coGtmAccountIdSet.add(pfr.ChannelPartnerId);
                    }
                    
                    //Ayush - Setting pfr.Core_MDF_Is_Activity_Shared_EXT_Ind__c to true once the NRE Activity is in Pending Approval status for external user visibility
                    //Akash - Latest commented because we want to share records to external user in draft status.
                    /*if(pfr.RecordTypeId == coGtmRecordTypeId && oldPfrMap != null && !oldPfrMap.isEmpty() && oldPfrMap.containsKey(pfr.Id) && pfr.Core_MDF_Is_Activity_Shared_EXT_Ind__c == false 
&& pfr.Core_MDF_Fund_Request_Status__c != oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS){
pfr.Core_MDF_Is_Activity_Shared_EXT_Ind__c = true;
}*/
                    
                    if(String.isNotBlank(pfr.CampaignId)){
                        campaignIds.add(pfr.CampaignId);
                        pfrIdCampIdMap.put(pfr.Id, pfr.CampaignId);
                    }
                    accountIdSet.add(pfr.ChannelPartnerId);
                    pfrIdAccountIdMap.put(pfr.Id, pfr.ChannelPartnerId);
                    
                    // clone scenario
                    if(oldPfrMap == null || pfr.Id == null){
                        
                        pfr.Core_MDF_Approval_Stage__c = null;
                        pfr.Core_MDF_Completed_Approval_Level_Name__c = null;
                    } 
                    //Update OOTB amount field as 0 if its null to avoid salesforce error
                    if(pfr.Amount == null){
                        pfr.Amount = 0;
                    }
                    
                    //populate the user type for EEF program & created by internal user during the create/clone
                    //Avoid Deeply Nested IF Statements
                    if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_EEF_PROGRAM && 
                       (oldPfrMap == null || pfr.Id == null) && 
                       isEEFPrimaryUser) {
                           pfr.Core_MDF_CreatedByIntUsrType__c = Core_MDF_CCP_ConstantClass.PFR_EEF_PRIMARYPARTNER;
                       }
                    if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_EEF_PROGRAM && 
                       (oldPfrMap == null || pfr.Id == null) && 
                       isEEFActivatingUser) {
                           pfr.Core_MDF_CreatedByIntUsrType__c = Core_MDF_CCP_ConstantClass.PFR_EEF_ACTIVATINGPARTNER;
                       }
                    if(programForProdCategorySplits.contains(pfr.Core_MDF_Program__c) && pfr.Core_MDF_ProductType__c != null && 
                       prodTypeCategoryMap.containsKey(pfr.Core_MDF_ProductType__c)){
                           if(oldPfrMap == null ||
                              (oldPfrMap != null && !oldPfrMap.isEmpty() && oldPfrMap.containsKey(pfr.Id) && 
                               pfr.Core_MDF_ProductType__c != oldPfrMap.get(pfr.Id).Core_MDF_ProductType__c)){
                                   pfr.Core_MDF_Product_Category_txt__c = prodTypeCategoryMap.get(pfr.Core_MDF_ProductType__c);
                               }
                       }
                    
                    if(buSplitProgramList.contains(pfr.Core_MDF_Program__c) && String.isNotBlank(pfr.Core_MDF_Brand_nm__c) 
                       && String.isNotBlank(pfr.Core_MDF_ProductType__c) && String.isNotBlank(pfr.Core_MDF_Focus_Area_nm__c))
                    {
                        brandList = pfr.Core_MDF_Brand_nm__c.split(';');
                        brandSet.addAll(brandList);
                        //productTypeSet.add(pfr.Core_MDF_ProductType__c);
                        productTypeSet.addAll(pfr.Core_MDF_ProductType__c.split(';'));
                        focusAreaSet.add(pfr.Core_MDF_Focus_Area_nm__c);
                    }
                    
                }
                
                if(!coGtmActivityList.isEmpty()){
                    populateCoGtmFields(coGtmActivityList, coGtmCampaignSet, coGtmBudgetIdSet, coGtmAccountIdSet);
                }
                
                if(!brandSet.isEmpty() && !productTypeSet.isEmpty() && !focusAreaSet.isEmpty())
                {
                    
                    // Creating sets for focus area, product type and brand to be used in the where clause
                    String focusAreaSetStr = '\'' + String.join(new List<String>(focusAreaSet), '\', \'') + '\'';
                    String productTypeSetStr = '\'' + String.join(new List<String>(productTypeSet), '\', \'') + '\'';
                    String brandSetStr = '\'' + String.join(new List<String>(brandSet), '\', \'') + '\'';
                    
                    // Query to extract the records for the BU Split Metadata
                    String query = 'SELECT Core_MDF_Field_5_txt__c, ' +
                        'Core_MDF_Date_1_dt__c, ' +
                        'Core_MDF_Date_2_dt__c, ' +
                        'Core_MDF_Field_1_txt__c, ' +
                        'Core_MDF_Field_3_txt__c, ' +
                        'Core_MDF_Field_2_txt__c ' +
                        'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +
                        'WHERE Core_MDF_Field_2_txt__c IN (' + focusAreaSetStr + ') ' +
                        'AND Core_MDF_Field_3_txt__c IN (' + productTypeSetStr + ') ' +
                        'AND Core_MDF_Field_1_txt__c IN (' + brandSetStr + ') ' +
                        'AND Core_MDF_Program__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.IPA_PROGRAM) + '\' ' +
                        'AND Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.BU_SPLIT) + '\' ' +
                        'AND Core_MDF_Is_Active_Ind__c = TRUE';
                    
                    
                    List<Core_MDF_CCP_Custom_Metadata_Utility__c> customMetadataUtilityRecords = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);
                    
                    if(customMetadataUtilityRecords != NULL && customMetadataUtilityRecords.size() > 0){
                        for(Core_MDF_CCP_Custom_Metadata_Utility__c rec : customMetadataUtilityRecords)
                        {
                            String key = rec.Core_MDF_Field_2_txt__c+'_'+rec.Core_MDF_Field_3_txt__c+'_'+rec.Core_MDF_Field_1_txt__c;
                            businessUnitSet.add(rec.Core_MDF_Field_5_txt__c);
                            if(brandFAProductTypeBUMap.containsKey(key))
                            {
                                List<Core_MDF_CCP_Custom_Metadata_Utility__c> recList = brandFAProductTypeBUMap.get(key);
                                recList.add(rec);
                                brandFAProductTypeBUMap.put(key,recList);
                            }
                            else
                            {
                                List<Core_MDF_CCP_Custom_Metadata_Utility__c> recList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
                                recList.add(rec);
                                brandFAProductTypeBUMap.put(key,recList);
                            }
                        }
                    }
                }
                
                if(!businessUnitSet.isEmpty())
                {
                    for(Core_MDF_BUPriorityRanking__c metadataRec : [SELECT Core_MDF_Label__c,Core_MDF_Ranking_nbr__c,Core_MDF_Program_Name__c from Core_MDF_BUPriorityRanking__c where Core_MDF_Label__c in :businessUnitSet AND Core_MDF_Program_Name__c = :Core_MDF_CCP_ConstantClass.IPA_PROGRAM])
                    {
                        buRankingMap.put(metadataRec.Core_MDF_Label__c,metadataRec.Core_MDF_Ranking_nbr__c);
                    }
                }
                
                
                //moved from below
                //Mohit - Commenting Below code to Align JAPAN cycle to three months quarter
                /*if(pfrIdAccountIdMap != null && !pfrIdAccountIdMap.isEmpty()){// not required in In Progress or execute only when channel Id is changed
Set<Id> accsIdSet = new Set<Id>();
accsIdSet.addAll(pfrIdAccountIdMap.values());

for(Account accObj : [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c, toLabel(Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode),
Core_MDF_Parent_Fund_Account__c, Core_MDF_Parent_Fund_Account__r.Core_Geo__c 
FROM Account WHERE Id IN :accsIdSet]) {
if(accObj.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c != null){
accIdRegionMap.put(accObj.Id, accObj.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c);
}
if(accObj.Core_MDF_Parent_Fund_Account__r.Core_Geo__c != null){
nodeAccIdRegionMap.put(accObj.Id, accObj.Core_MDF_Parent_Fund_Account__r.Core_Geo__c);  //to store the node account geo
}  
if(accObj.Core_MDF_Parent_Fund_Account__r.Core_Geo__c != null){
accIdCountryMap.put(accObj.Id,  accObj.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode);  
}                     
}
}*/
                for(PartnerFundRequest pfr: pfrList){
                    String progName = ccpRecordTypeIds.get(pfr.recordTypeId);
                    String key = '';
                    key = buildKeyForActivityClosure(pfr, progName);
                    if (!String.isEmpty(key)){
                        quarterEndDateMap.put(key, null);
                    }
                }
                if(quarterEndDateMap != null && !quarterEndDateMap.isEmpty()){
                    quarterEndRsltMap = getActivitySubDueDate(quarterEndDateMap);
                }
                if(quarterEndDateMap != null && !quarterEndDateMap.isEmpty()){
                    closeDateExtensionMap = getActClosureExtensionDate(quarterEndDateMap);
                }
                
                // Get the campiagn and campaign budget details
                Set<Id> opalcampaignids = new Set<Id>();
                Map<string,Core_MDF_Campaign_Budgets__c> campbudgetMap = new Map<string,Core_MDF_Campaign_Budgets__c>();
                for(Campaign camp : [Select id, Core_MDF_Proposal_Based_Ind__c,Core_MDF_Reimbursement_Rate__c, Core_MDF_Budget_Type_txt__c,
                                     Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Supports_legacy_program__c,Recordtype.DeveloperName,
                                     Core_MDF_ReimbursementRate_pct__c,Core_MDF_Technology__c from Campaign where id in : campaignIds]){
                                         campaignMap.put(camp.id, camp);
                                         if(camp.Core_MDF_Opal_Budget_Type_Txt__c != null && (camp.Core_MDF_Opal_Budget_Type_Txt__c.contains(Core_MDF_CCP_ConstantClass.OEM_CMP_BUDGET_TYPE)|| 
                                                                                              camp.Core_MDF_Opal_Budget_Type_Txt__c.contains(Core_MDF_CCP_ConstantClass.SPCMP_BUDGET_TYPE) ||
                                                                                              camp.Core_MDF_Opal_Budget_Type_Txt__c.contains(Core_MDF_CCP_ConstantClass.MDF_BUDGET_TYPE) || 
                                                                                              camp.Core_MDF_Opal_Budget_Type_Txt__c.contains(Core_MDF_CCP_ConstantClass.MDFPLUS_BUDGET_TYPE))){
                                                                                                  opalcampaignids.add(camp.id);
                                                                                              }      
                                     }
                // get campaign budget for Opal campaigns
                if(!opalcampaignids.isEmpty()){
                    for(Core_MDF_Campaign_Budgets__c cmpBudget : [select id, Core_MDF_Budget_Name_Id__c, Core_MDF_Budget_Type_Nm__c,Core_MDF_Campaign_Id__c, 
                                                                  Core_MDF_Reimbursement_Rate_Pct__c from  Core_MDF_Campaign_Budgets__c
                                                                  WHERE Core_MDF_Campaign_Id__c IN :opalcampaignids]){
                                                                      if (cmpBudget.Core_MDF_Budget_Type_Nm__c != NULL && cmpBudget.Core_MDF_Budget_Type_Nm__c != '' && cmpBudget.Core_MDF_Budget_Name_Id__c != NULL){
                                                                          String CampBudgetkey = cmpBudget.Core_MDF_Campaign_Id__c+''+cmpBudget.Core_MDF_Budget_Name_Id__c;
                                                                          campbudgetMap.put(CampBudgetkey, cmpBudget); 
                                                                      }        
                                                                  }
                }
                // This is main loop which populates the backend fields of PFR like close date, RR calcaulation, Amount, reimbursmeent amount etc..
                for(PartnerFundRequest pfr: pfrList){  
                    
                    // Method to calculate requestedAmount field
                    recalculateSpendingLimit(pfr,oldPfrMap);
                    Boolean isPropBasedCamp = false;
                    pfr.Core_MDF_Email_body_Field_Values_txt__c = getInternalEmailContent(pfr);
                    
                    //we are populating the value for this field for ipa outcome based
                    if(!pfr.Core_MDF_Is_Outcome_Based_Ind__c){
                        pfr.Core_MDF_Technology_txt__c= '';
                    }
                    
                    Boolean isOutcomeBased = false;
                    
                    if(campaignMap != null && campaignMap.containsKey(pfr.CampaignId) && campaignMap.size() > 0){
                        isPropBasedCamp = campaignMap.get(pfr.CampaignId).Core_MDF_Proposal_Based_Ind__c;
                    }
                    if(pfr.CampaignId ==null){
                        isOutcomeBased =pfr.Core_MDF_Is_Outcome_Based_Ind__c;
                    }
                    
                    if((oldPfrMap == null || pfr.Id == null) && (!isPropBasedCamp || isOutcomeBased)){
                        pfr.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS;
                    }
                    Boolean errorthrown = regionSubRegionChecks(pfr, activityRecordTypeGeoListMap, ccpRecordTypeIds, countryGeoMap, countrySubGeoMap, isPropBasedCamp,oldPfrMap);
                    if(errorthrown){
                        break;
                    }
                    //Update Price reviewer check and program office check fields if the activity type is of SPIF type and other type respectively
                    updatePctAndPorChecks(pfr, spifActivityTypesList, otherActivityTypesList,oldPfrMap);
                    
                    //call set ATF Flag
                    if(!bypassFlag && pfr.Core_MDF_Program__c != Label.Core_MDF_Co_GTM_program_name) { //Ayush - added NRE check to bypass ATF logic for NRE
                        setATFFlag(pfr,oldPfrMap);                 
                    } 
                    
                    //Set the to be closed date based on the values configured in meta data - closed date validations
                    String progName = ccpRecordTypeIds.get(pfr.recordTypeId);
                    String autoClosurekeyStr = '';
                    
                    if(isAutoClosureDateToBeUpdated(pfr, progName, oldPfrMap)){
                        if((quarterEndRsltMap != null)){
                            autoClosurekeyStr = buildKeyForActivityClosure(pfr, progName);
                            if(pfr.Core_MDF_ToBeClosedDate__c != quarterEndRsltMap.get(autoClosurekeyStr) && (pfr.Core_MDF_ATF_Flag_nm__c == null || pfr.Core_MDF_ATF_Flag_nm__c != null)){
                                pfr.Core_MDF_ToBeClosedDate__c = quarterEndRsltMap.get(autoClosurekeyStr);
                            }
                            if(oldPfrMap == NULL && pfr.Core_MDF_ToBeClosedDate__c < System.today())
                            {
                                pfr.Core_MDF_ToBeClosedDate__c = closeDateExtensionMap.get(autoClosurekeyStr);
                                if(pfr.Core_MDF_Program__c != Label.Core_MDF_Co_GTM_program_name){
                                    pfr.Core_MDF_ATF_Flag_nm__c=atfClosedStatus;
                                } 
                            }
                        }
                    }
                    
                    
                    // Derive any status update need
                    deriveActivityStatuses(pfr,oldPfrMap);
                    
                    //to update amt = 0 on BT change to Certain BTs
                    if(!Core_MDF_Utility.byPassFeature('Amount_Zero_Update')){
                        
                        updateAmountOnBudgetTypeChange(pfr,oldPfrMap);
                    }
                    // Derive the RR and Amount                    
                    deriveRRandAmt(pfr,campaignMap.get(pfr.CampaignId),campbudgetMap.get(pfr.campaignId+''+pfr.BudgetId),oldPfrMap);
                    
                    executeEventRule(pfr, ccpRecordTypeIds, oldPfrMap, progName, pfrDateMap, pfrRecordTypeAttributeMetadataMap, 
                                     pfrIdMgrIdMap);
                    if(isEligibleForBUSplit(pfr,oldPfrMap))
                    {
                        
                        populateBUSplit(pfr,oldPfrMap,brandFAProductTypeBUMap,buRankingMap);
                    }
                    
                    
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /****************************************************************************************************** 
Method Name:        populateCoGtmFields
@return  :          void
@parameters:        coGtmPfrList, campaignIdSet
Description:        Populate Co-GTM fields
Added By:           JB - 04/07/2025
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public static void populateCoGtmFields(List<PartnerFundRequest> coGtmPfrList, Set<String> campaignIdSet, Set<String> coGtmBudgetIdSet, Set<String> coGtmAccountIdSet){
        //Akash - Camapaign Status field added in query
        Map<Id,Campaign> campaignIdTocoGtmCampaignMap = new Map<Id,Campaign>([SELECT Id, Name, StartDate, Core_MDF_Opal_Budget_Type_Txt__c, Core_MDF_Account__c, Core_MDF_Region_cd__c, Core_MDF_Activity_Category_Type__c,Status FROM Campaign WHERE Id IN: campaignIdSet]);
        
        Map<String, String> uniqueKeyToAllocationIdMap = new Map<String, String>();
        for(PartnerFundAllocation allocation : [SELECT Id, BudgetId, ChannelPartnerId FROM PartnerFundAllocation WHERE BudgetId IN: coGtmBudgetIdSet AND ChannelPartnerId IN: coGtmAccountIdSet]){
            String uniqueKey = String.valueOf(allocation.BudgetId) + String.valueOf(allocation.ChannelPartnerId);
            uniqueKeyToAllocationIdMap.put(uniqueKey, allocation.Id);
        }
        
        List<PartnerFundRequest> pfrToCreateAllocation = new List<PartnerFundRequest>();
        Set<String> budgetIdSet = new Set<String>();
        for(PartnerFundRequest pfr : coGtmPfrList){
            Id allocationId;
            String uniqueKey = String.valueOf(pfr.BudgetId) + String.valueOf(pfr.ChannelPartnerId);
            if(uniqueKeyToAllocationIdMap != null && uniqueKeyToAllocationIdMap.containsKey(uniqueKey)){
                allocationId = uniqueKeyToAllocationIdMap.get(uniqueKey);
            }
            
            if(campaignIdTocoGtmCampaignMap != null && campaignIdTocoGtmCampaignMap.containsKey(pfr.CampaignId)){
                Campaign camp = campaignIdTocoGtmCampaignMap.get(pfr.CampaignId);
                
                //Populate Activity Category and Type from Campaign
                String activityCategory;
                String activityType;
                if(String.isNotBlank(camp.Core_MDF_Activity_Category_Type__c)){
                    List<String> activityCategoryTypeList = camp.Core_MDF_Activity_Category_Type__c.split(';');
                    List<String> activityCategoryType = (!activityCategoryTypeList.isEmpty() && activityCategoryTypeList[0].contains('->')) ? activityCategoryTypeList[0].split('->') : new List<String>();
                    activityCategory = (activityCategoryType.size() == 2) ? activityCategoryType[0].trim() : null;
                    activityType = (activityCategoryType.size() == 2) ? activityCategoryType[1].trim() : null;
                }
                pfr.Core_MDF_ActivityCategory__c = activityCategory;
                pfr.Core_MDF_Activity_Types__c = activityType;
                
                pfr.Core_MDF_Start_Date__c = camp.StartDate;
                pfr.Title = camp.Name;
                pfr.Core_MDF_Budget_Type_nm__c = camp.Core_MDF_Opal_Budget_Type_Txt__c;
                pfr.ChannelPartnerId = camp.Core_MDF_Account__c;
                pfr.AllocationId = allocationId;
                pfr.Core_MDF_Region_nm__c = 'APJ;ASMO;EMEA;PRC';
                pfr.Core_MDF_Budget_Currency_cd__c = 'USD';
                pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
                //Akash - Based on Campaign status change activity status
                if(camp.Status.contains('Planned') || camp.Status.contains('In Progress')){
                    pfr.Core_MDF_Fund_Request_Status__c = 'Revision Required';
                }
                else{
                    pfr.Core_MDF_Fund_Request_Status__c = 'Draft';
                }
                pfr.Status = 'Approved';
                
                if(String.isBlank(pfr.AllocationId)){
                    pfrToCreateAllocation.add(pfr);
                    budgetIdSet.add(pfr.BudgetId);
                }
            }
        }
        
        if(!pfrToCreateAllocation.isEmpty()){
            createCoGtmAllocation(pfrToCreateAllocation, budgetIdSet);
        }
    }
    
    /****************************************************************************************************** 
Method Name:        createCoGtmAllocation
@return  :          void
@parameters:        pfrToCreateAllocation
Description:        Create Co-GTM Allocation and Stamp on Activity
Added By:           JB - 04/10/2025
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public static void createCoGtmAllocation(List<PartnerFundRequest> pfrToCreateAllocation, Set<String> budgetIdSet){
        List<PartnerFundAllocation> allocationListToCreate = new List<PartnerFundAllocation>();
        Map<String, PartnerFundAllocation> uniqueKeyToAllocationMap = new Map<String, PartnerFundAllocation>();
        Id recordtypeId = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        Map<Id,PartnerMarketingBudget> budgetIdToRecordMap = new Map<Id, PartnerMarketingBudget>([SELECT Id, Title FROM PartnerMarketingBudget WHERE Id IN: budgetIdSet]);
        for(PartnerFundRequest pfr : pfrToCreateAllocation){
            if(budgetIdToRecordMap != null && budgetIdToRecordMap.containsKey(pfr.BudgetId)){
                PartnerFundAllocation partnerFndAllocation = new PartnerFundAllocation(RecordTypeId = recordtypeId, Title = budgetIdToRecordMap.get(pfr.BudgetId).Title, BudgetId = pfr.BudgetId, ChannelPartnerId = pfr.ChannelPartnerId, Amount = 0);
                uniqueKeyToAllocationMap.put('' + pfr.BudgetId + pfr.ChannelPartnerId ,partnerFndAllocation);
            }
        }
        
        //Create $0 Allocation Records
        if(uniqueKeyToAllocationMap != null && !uniqueKeyToAllocationMap.isEmpty()){
            insert uniqueKeyToAllocationMap.values();
        }
        
        for(PartnerFundRequest pfr : pfrToCreateAllocation){
            String uniqueKey = '' + pfr.BudgetId + pfr.ChannelPartnerId;
            if(uniqueKeyToAllocationMap != null && uniqueKeyToAllocationMap.containsKey(uniqueKey)){
                //Populate Allocation Id in Activity
                pfr.AllocationId = uniqueKeyToAllocationMap.get(uniqueKey).Id;
            }
        }
    }
    
    /****************************************************************************************************** 
Method Name:        buildKeyForActivityClosure
@return  :          String
@parameters:        pfr and program name
Description:        Build the key based on the PFR values
Added By:           Sridhar - 06/30/2020
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    
    public static String buildKeyForActivityClosure(PartnerFundRequest pfr, String progName){
        
        String key = '';
        String rmfLabel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name');
        String ipaLabel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
        String japanCntry;
        String ultimateAccGeo;
        //Mohit - Commenting Below code to Align JAPAN cycle to three months quarter
        /*if (progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program')) //&& pfr.Core_MDF_Budget_Type_nm__c == Label.Core_MDF_Retail_RSA_MD_Budget_Type
{
//Based on US846955-US849167, getting Ultimate Account's Country and its Geo
if(pfr != null && accIdCountryMap.get(pfr.ChannelPartnerId) != null && accIdRegionMap.get(pfr.ChannelPartnerId) != null){
japanCntry = accIdCountryMap.get(pfr.ChannelPartnerId);
ultimateAccGeo = accIdRegionMap.get(pfr.ChannelPartnerId);                    
}
if(String.isNotBlank(japanCntry)) {
japanCntry = japanCntry.toUpperCase();
} 
//US949836 : New Budget Type field changes replaced txt field with new global picklist field
if(pfr.Core_MDF_Budget_Type_nm__c == Label.Core_MDF_Retail_RSA_MD_Budget_Type ||
pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RetailMDF_BudgetType')){
//Based on US846955-US849167 checking if Country is JAPAN and its Geo from Ultimate Acc to form key
if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Country_JAPAN').equals(japanCntry)){
key = rmfLabel + ':' +
pfr.Core_MDF_Budget_Type_nm__c + ':' +
ultimateAccGeo + ':' + //pfr.Core_MDF_Region_cd__c
'null' + ':' +
japanCntry + ':';  //pfr.Core_MDF_Country_nm__c + ':';
}else{
key = rmfLabel + ':' +
pfr.Core_MDF_Budget_Type_nm__c + ':' +
'null' + ':' +
'null' + ':' +
'null' + ':';                        
}
}
else{
key = rmfLabel + ':' +
pfr.Core_MDF_Budget_Type_nm__c + ':' +
'null' + ':' +
'null' + ':' +
'null' + ':';
}
}
else*/ if (progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')){
    key = ipaLabel + ':' +
        'NA' + ':' +
        'null' + ':' +
        'null' + ':' +
        'null' + ':';
}
        
        else{
            key = pfr.Core_MDF_Program__c + ':' +
                pfr.Core_MDF_Budget_Type_nm__c + ':' +
                'null' + ':' +
                'null' + ':' +
                'null' + ':';
        }
        //preparing endDate by splitting it by /
        String pfrEndDateStr = pfr.Core_MDF_End_Date__c.Day()+'/'+pfr.Core_MDF_End_Date__c.Month()+'/'+pfr.Core_MDF_End_Date__c.Year();
        key += pfrEndDateStr;
        key = key.deleteWhitespace();
        
        
        return key;
    }
    
    /****************************************************************************************************** 
Method Name:        isAutoClosureDateToBeUpdated
@return  :          boolean
@parameters:        pfr, program name and oldpfrmap
Description:        check if auto closure is required
Added By:           Sridhar - 08/03/2020
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    
    private static Boolean isAutoClosureDateToBeUpdated(PartnerFundRequest pfr, String progName, Map<Id,PartnerFundRequest> oldPfrMap){
        
        // US949836 : New Budget Type field changes replaced txt field with new global picklist field  
        if (((cusPerm.isGeoApprover && pfr.Core_MDF_Fund_Request_Status__c ==Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS) || 
             (pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS && pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS))
            && (oldPfrMap == null 
                || (progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program') && oldPfrMap != null && (oldPfrMap.get(pfr.Id).Core_MDF_End_Date__c != pfr.Core_MDF_End_Date__c 
                                                                                                                             || oldPfrMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c != pfr.Core_MDF_Budget_Type_nm__c || oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c))
                || (progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && oldPfrMap != null && (oldPfrMap.get(pfr.Id).Core_MDF_End_Date__c != pfr.Core_MDF_End_Date__c))
                || (oldPfrMap != null && progName != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && progName != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program') && (oldPfrMap.get(pfr.Id).Core_MDF_End_Date__c != pfr.Core_MDF_End_Date__c))       
               )){
                   return true;
               }
        return false;
    }
    
    /****************************************************************************************************** 
Method Name:        getQtrstartenddates
@return  :          Map<Id,List<Date>>
@parameters:        list of PFR and Map <id ,String> to get record type names by ids
Description:        Fetch Qtr start and end dates
Added By:           Vivek - 09/29/2020
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    private static Map<Id,List<Date>> getQtrStartAndEndDates(List<PartnerFundRequest> pfrList, Map<Id,String> ccpRecordTypeIds){        
        Map<String,List<date>> dateMapRes = new Map<String,List<date>>(); //Date Map returned from ClaimSubmissionClosure class method
        Map<String,date> dueDateMap=new Map<String,date>{}; //Map of key and null to be passed to ClaimSubmissionClosure class method            
            Map<String,Id> pfrkeymap = new Map<String,Id>();
        Map<Id,List<date>> pfrdatemap = new Map<Id,List<date>>();
        
        for(PartnerFundRequest pfr: pfrList){
            String progName = ccpRecordTypeIds.get(pfr.recordTypeId);
            String key = '';
            // if(progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program') || ){
            key = buildKeyForActivityClosure(pfr,progName);
            // }
            if (!String.isEmpty(key))
            {
                dueDateMap.put(key, null);
                pfrkeymap.put(key,pfr.Id);
            }
        }
        if(dueDateMap!=null && !dueDateMap.isEmpty()){
            dateMapRes = Core_MDF_ProcessClaimSubmissionClosure.getQuarterStartAndEndDate(dueDateMap);
        }
        if(dateMapRes!= null && dateMapRes.size() > 0){
            for(String key:dateMapRes.keySet()){
                for(String pfrkey:pfrkeymap.keySet()){
                    if(key==pfrkey){
                        pfrdatemap.put(pfrkeymap.get(pfrkey),dateMapRes.get(key));
                    }
                }
            }
        }
        return pfrdatemap;
    }
    
    /****************************************************************************************************** 
Method Name:        validateJapanCycleDates
@return  :          String
@parameters:        PFR and Map <id ,List<Date>> 
Description:        Validate activity start date and end date validations for Japan cycle
Added By:           Vivek - 09/29/2020
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @TestVisible 
    private static String validateJapanCycleDates(PartnerFundRequest pfr,Map<Id,List<Date>> pfrDateMap){
        List<Date> datelst = new List<Date>(); 
        Date qtrstartdate;
        Date qtrenddate;
        String errormsg = '';
        if(pfrDateMap!=null && pfrDateMap.size()>0){
            datelst = pfrDateMap.get(pfr.Id);
        }
        if(datelst!= null && datelst.size()>0){
            qtrstartdate = datelst.get(0);
            qtrenddate = datelst.get(1);
        }
        if((qtrstartdate!= null && qtrenddate!= null) && (!(pfr.Core_MDF_Start_Date__c >= qtrstartdate && pfr.Core_MDF_Start_Date__c <= qtrenddate) || !(pfr.Core_MDF_End_Date__c >= qtrstartdate && pfr.Core_MDF_End_Date__c <= qtrenddate))) {
            errormsg =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_JPN_Dates_Validation');
        } 
        return errormsg;
    }   
    
    
    /****************************************************************************************************** 
Method Name:        deriveRRandAmt
@return  :          
@parameters:        
Description:        
Added By:           
*******************************************************************************************************/
    public static void deriveRRandAmt(PartnerFundRequest pfr, Campaign camp,Core_MDF_Campaign_Budgets__c campbudget,Map<Id,PartnerFundRequest> oldPfrMap){
        String reimursmentRate, rRate;
        Decimal decimalRR;
        String ccfProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name');
        String dcfProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name');
        List<String> budgetTypeCCFDCF1_0 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetTypeToExclude').split(';');
        
        List<String> budgetTypesList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bdgt_Types_For_Amount_Update').split(';');
        List<String> cmpBudgetType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP_BudgetType').split(';');
        
        Decimal amount = 0;
        Decimal activityReimbursementAmount = 0;
        Boolean isIPAProposalBased = pfr.Core_MDF_Proposal_Based_Ind__c == true && rtMapById.get(pfr.RecordTypeId).getDeveloperName() == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType'); //Indu IPA Proposal
        //Populate the budget type for CCF1.0 and DCF 1.0 if the prf budget type is blank
        if((pfr.Core_MDF_Program__c == ccfProgramName || pfr.Core_MDF_Program__c == dcfProgramName) && 
           String.isBlank(pfr.Core_MDF_Budget_Type_nm__c) &&
           budgetTypeCCFDCF1_0.contains(camp.Core_MDF_Opal_Budget_Type_Txt__c)){
               if( oldPfrMap == null){//entry criteria
                   pfr.Core_MDF_Budget_Type_nm__c = camp.Core_MDF_Opal_Budget_Type_Txt__c;
               }
           }
        // Derive the Reimbursement rate for the PFR based on the program or UI values
        if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
            if(oldPfrMap == null 
               || (oldPfrMap!= null && (oldPfrMap.get(pfr.Id).Core_MDF_Reimbursement_Rate_pct__c != pfr.Core_MDF_Reimbursement_Rate_pct__c ))){
                   
                   pfr.Core_MDF_Reimbursement_Rate_txt__c = pfr.Core_MDF_Reimbursement_Rate_pct__c;  
                   if(pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RetailMDF_BudgetType')){
                       pfr.Amount = ((pfr.RequestedAmount * Decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_txt__c.removeEnd('%')))/100).setScale(2,RoundingMode.HALF_UP);
                   }
               }
            
        }
        else if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        }
        if(pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.OEM_CMP_BUDGET_TYPE || pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.SPCMP_BUDGET_TYPE){
            if(oldPfrMap == null 
               || (oldPfrMap!= null && (oldPfrMap.get(pfr.Id).Core_MDF_ActivityCategory__c != pfr.Core_MDF_ActivityCategory__c 
                                        || oldPfrMap.get(pfr.Id).Core_MDF_Activity_Types__c != pfr.Core_MDF_Activity_Types__c
                                        || oldPfrMap.get(pfr.Id).Core_MDF_Competitive_Elements__c != pfr.Core_MDF_Competitive_Elements__c
                                        || oldPfrMap.get(pfr.Id).Core_MDF_Incentive_pct__c != pfr.Core_MDF_Incentive_pct__c
                                        || oldPfrMap.get(pfr.Id).Core_MDF_Reimbursement_Rate_txt__c != pfr.Core_MDF_Reimbursement_Rate_txt__c))){ 
                                            
                                            Decimal pfrInc = (pfr.Core_MDF_Incentive_pct__c != NULL? (pfr.Core_MDF_Incentive_pct__c) : 0);
                                            if(String.isNotBlank(pfr.BudgetId)){
                                                //Ayush - RR changes
                                                //reimursmentRate = campbudget.Core_MDF_Reimbursement_Rate_Pct__c;
                                                reimursmentRate = pfr.Core_MDF_Reimbursement_Rate_txt__c;
                                            }   
                                            //To remove '%' from Campaign.Core_MDF_Reimbursement_Rate__c
                                            Decimal rrWoPercentage = Decimal.valueof(reimursmentRate.left(reimursmentRate.length()-1));      
                                            if((pfr.Core_MDF_ActivityCategory__c == Core_MDF_CCP_ConstantClass.PFR_EVENT_CATEGORY || pfr.Core_MDF_ActivityCategory__c==Core_MDF_CCP_ConstantClass.PFR_EVENT_2025_CATEGORY) && (pfr.Core_MDF_Activity_Types__c == Core_MDF_CCP_ConstantClass.PFR_JOINT_EVENT_CATEGORY 
                                                                                                                                                                                                                               || pfr.Core_MDF_Activity_Types__c == Core_MDF_CCP_ConstantClass.PFR_THIRD_PARTY_CATEGORY) && pfr.Core_MDF_Competitive_Elements__c == 'Yes'){
                                                                                                                                                                                                                                   decimalRR = (rrWoPercentage + pfrInc)/ 2; 
                                                                                                                                                                                                                               }else {                                
                                                                                                                                                                                                                                   decimalRR = (rrWoPercentage + pfrInc);
                                                                                                                                                                                                                               }
                                            rRate = String.valueOf(decimalRR);
                                            
                                            if(rRate.endswith('.0')){   
                                                rRate = rRate.removeEnd('.0'); 
                                            }
                                            if(rRate.endswith('.00')){
                                                rRate = rRate.removeEnd('.00'); 
                                            }         
                                            //To append '%' for RR                              
                                            if(String.isNotBlank(rRate) && !rRate.endsWith('%')){
                                                rRate = rRate + '%';
                                            } 
                                            pfr.Core_MDF_Reimbursement_Rate_txt__c = rRate;  
                                        } 
            //activityReimbursementAmount = (pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_txt__c.removeEnd('%')))/100;
            //amount = activityReimbursementAmount;
            if(cmpBudgetType.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS){
                    pfr.Status = Core_MDF_CCP_ConstantClass.PFR_REJECTED_STATUS;
                }
            }
            
        }
        else {
            //add to stamp amount
            //MDF;MDF+;IPA Account Based;Channel MDF Account Based;IPA Proposal Based
            if((pfr.Core_MDF_Budget_Type_nm__c != NULL && budgetTypesList.contains(pfr.Core_MDF_Budget_Type_nm__c))|| 
               (pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM  || pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM)){
                   if(pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS && pfr.Core_MDF_Proposal_Based_Ind__c == false && pfr.Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.EEF_PROGRAM ){
                       pfr.Status = Core_MDF_CCP_ConstantClass.PFR_APPROVED_STATUS;
                   }      
                   
                   if((oldPfrMap == NULL)  ||
                      ((oldPfrMap != NULL && oldPfrMap.containsKey(pfr.Id) && oldPfrMap.get(pfr.Id) != NULL) &&
                       (pfr.RequestedAmount != oldPfrMap.get(pfr.Id).RequestedAmount ||
                        pfr.Core_MDF_MDFReimbursement_Amt__c != oldPfrMap.get(pfr.Id).Core_MDF_MDFReimbursement_Amt__c ||
                        pfr.Core_MDF_Reimbursement_Rate_txt__c != oldPfrMap.get(pfr.Id).Core_MDF_Reimbursement_Rate_txt__c ||
                        pfr.Core_MDF_Budget_Type_nm__c != oldPfrMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c)))                        
                   {
                       //TWC702-4881: Calculate for Reimbursement Rate
                       if(pfr.Core_MDF_MDFReimbursement_Amt__c != null && pfr.Core_MDF_MDFReimbursement_Amt__c > 0 && pfr.RequestedAmount !=null && pfr.RequestedAmount > 0){
                           decimalRR = ((pfr.Core_MDF_MDFReimbursement_Amt__c / pfr.RequestedAmount )*100).setScale(2,RoundingMode.HALF_UP);
                           rRate = String.valueOf(decimalRR);
                           
                           if(rRate.endswith('.0')){   
                               rRate = rRate.removeEnd('.0'); 
                           }
                           if(rRate.endswith('.00')){
                               rRate = rRate.removeEnd('.00'); 
                           }         
                           //To append '%' for RR                              
                           if(String.isNotBlank(rRate) && !rRate.endsWith('%')){
                               rRate = rRate + '%';
                           } 
                           pfr.Core_MDF_Reimbursement_Rate_txt__c = rRate;
                           amount = pfr.Core_MDF_MDFReimbursement_Amt__c;
                       }
                       else if(pfr.RequestedAmount != NULL && pfr.Core_MDF_Reimbursement_Rate_txt__c != NULL &&
                               pfr.Core_MDF_Reimbursement_Rate_txt__c != NULL && pfr.Core_MDF_Reimbursement_Rate_txt__c != ''){
                                   //Akash - changes      
                                   if(pfr.Core_MDF_Is_Outcome_Based_Ind__c != true && pfr.Core_MDF_Activity_Level_nm__c != 'Sub Activity') {
                                       activityReimbursementAmount = ((pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_txt__c.removeEnd('%')))/100).setScale(2,RoundingMode.HALF_UP);
                                       amount = activityReimbursementAmount;
                                   }
                               }
                       //special handling for IPA
                       else if(pfr.RequestedAmount != NULL && (pfr.Core_MDF_Reimbursement_Rate_txt__c == NULL || 
                                                               pfr.Core_MDF_Reimbursement_Rate_txt__c == '' && pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM)){
                                                                   activityReimbursementAmount = ((pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Campaign_Reimbursement_Rate_txt__c.removeEnd('%')))/100).setScale(2,RoundingMode.HALF_UP);
                                                                   amount =activityReimbursementAmount;
                                                               }
                   }         
               }
        }
        /*if(amount !=0){
            pfr.Amount = amount;
        }*/
        if(isIPAProposalBased && pfr.Core_MDF_Maximum_Intel_Investment_amt__c != null && pfr.Core_MDF_Maximum_Intel_Investment_amt__c > 0){
    pfr.Amount = pfr.Core_MDF_Maximum_Intel_Investment_amt__c;
     }else if(amount != 0){
    pfr.Amount = amount;
     } // Indu IPA Proposal
    } 
    /********************************************************************************************************* 
Method Name:        updateAmountOnBudgetTypeChange
@return  :          null
@parameters:        
Description:       Update amount field to zero on budget type change from MDF/ MDF+ to OEM CMP/SPCMP/CCF1.0/DCF1.0 
or from Retail MDF to RSA MD
Added By:                       
**********************************************************************************************************/
    public static void updateAmountOnBudgetTypeChange(PartnerFundRequest pfr,Map<Id,PartnerFundRequest> oldPfrMap){
        List<String> budgetTypesList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActivityBudgetTypesForAmtUpdate').split(';');
        if(oldPfrMap!= null && oldPfrMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c != pfr.Core_MDF_Budget_Type_nm__c){ 
            if(budgetTypesList != null && budgetTypesList.contains(pfr.Core_MDF_Budget_Type_nm__c) 
               && ( pfr.Amount != 0 || oldPfrMap.get(pfr.Id).Amount != 0)){ 
                   pfr.Amount=0;
               }
        } 
    }  
    /****************************************************************************************************** 
Method Name:        getCustomPermissions
@return  :          customPermissionsWrapper
@parameters:        
Description:        [KIIT]: W Revamp of Activity Trigger to support FE and new approval flow using IUPGM 
Added By:           Accenture - Sai
Date:               12/04/2022
*******************************************************************************************************/
    public static CustomPermissionsWrapper getCustomPermissions(){
        CustomPermissionsWrapper cusPermissions = new CustomPermissionsWrapper();
        Boolean isEditable = false;
        List<String>  permissionSetName = Label.Core_MDF_ClaimCaseReviewer.split(',');
        cusPermissions.isInternalAccountManager = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM'));
        cusPermissions.isRetailInternalAccountManager = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM_Retail'));
        //cusPermissions.hasGeoApproverCustomPermission = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Geo_Lead_Custom_Perm'));
        cusPermissions.isCCFFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Owner'));
        cusPermissions.isDCFFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Owner'));
        cusPermissions.isCCFMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Marketing_Owner'));
        cusPermissions.isDCFMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Marketing_Owner'));
        cusPermissions.isGeoApprover = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver');
        //are the below one and isRetailInternalAccountManager different? - Names are different, but does the functionalities different? Relook at it
        cusPermissions.isRetailAccMgr = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_RMF_Account_Manager'); 
        //cusPermissions.isAfterTheFactUser  = FeatureManagement.checkPermission('Core_MDF_AfterTheFact');
        cusPermissions.isPriceReviewer = FeatureManagement.checkPermission('Core_MDF_PriceReviewer');
        
        //Checking if user has Auditor permission
        
        for(String permissionName : permissionSetName){
            isEditable = FeatureManagement.checkPermission(permissionName);
            if(isEditable){
                break;
            }
        }
        cusPermissions.isEditable = isEditable;
        return cusPermissions;  
    }
    
    public class CustomPermissionsWrapper {
        public Boolean isInternalAccountManager = false;
        public Boolean isRetailInternalAccountManager = false;
        //public Boolean hasGeoApproverCustomPermission = false;
        public Boolean isCCFFieldOwner = false;
        public Boolean isDCFFieldOwner = false;
        public Boolean isCCFMarketingOwner = false;
        public Boolean isDCFMarketingOwner = false;
        public Boolean isGeoApprover = false;
        public Boolean isRetailAccMgr = false;
        public Boolean isAfterTheFactUser = false;
        public Boolean isPriceReviewer = false;
        public Boolean isEditable = false;//added H
    }
    
    /****************************************************************************************************** 
Method Name:        getInternalEmailContent
@return  :          String
@parameters:        
Description:        [KIIT]: W Revamp of Activity Trigger to support FE and new approval flow using IUPGM 
Returns the internal email content.
Added By:           Accenture - Sai 
Date:               21/04/2022
*******************************************************************************************************/
    public static String getInternalEmailContent(PartnerFundRequest pfr){
        String emailBody = 'Activity Type: '+ pfr.Core_MDF_Activity_Types__c +'\n\n';
        emailBody +='      Status History: '+ pfr.Core_MDF_Fund_Request_Status__c +'\n\n';
        emailBody +='      Countries/Locations: '+ pfr.Core_MDF_Country_nm__c +'\n';
        
        return emailBody;   
    }
    
    /****************************************************************************************************** 
Method Name:        regionSubRegionChecks
@return  :          Boolean
@parameters:        
Description:        [KIIT]: W Revamp of Activity Trigger to support FE and new approval flow using IUPGM 
regionSubRegionChecks - throws errors for multiple geo/sub geo's else update region fields
Added By:           Accenture - Sai 
Date:               21/04/2022
*******************************************************************************************************/
    public static Boolean regionSubRegionChecks(PartnerFundRequest pfr, Map<String, List<String>> activityRecordTypeGeoListMap, 
                                                Map<Id,String> ccpRecordTypeIds, Map<String, String> countryGeoMap,
                                                Map<String, String> countrySubGeoMap, Boolean isPropBasedCamp, Map<Id,PartnerFundRequest> oldPfrMap){
                                                    
                                                    Boolean errorThrown = false;
                                                    Set<String> geoSet = new Set<String>();
                                                    Set<String> subGeoSet = new Set<String>();
                                                if(oldPfrMap == null || (oldPfrMap!= null && (oldPfrMap.get(pfr.Id).Core_MDF_Country_nm__c != pfr.Core_MDF_Country_nm__c ))){         
                                                    if(pfr.Core_MDF_Country_nm__c != NULL){
                                                        List<String> splitCountry = pfr.Core_MDF_Country_nm__c.split(';');
                                                        for(String Country : splitCountry){
                                                            if(countryGeoMap.containsKey(Country)){
                                                                if(countrySubGeoMap.containsKey(Country)){
                                                                    if(pfr.Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM){
                                                                        subGeoSet.add(countrySubGeoMap.get(Country));
                                                                    }
                                                                }
                                                                geoSet.add(countryGeoMap.get(Country));
                                                            }                                
                                                        }
                                                       
                                                        if(pfr.Core_MDF_Program__c != Null && pfr.Core_MDF_Program__c != '') {
                                                            if(geoSet != NULL && geoSet.size() > 1 ){
                                                                errorThrown = true;
                                                                pfr.addError(Label.Core_MDF_Country_Multiple_Geo_Error);
                                                                //break; --> Break statement must be in loop
                                                            }
                                                            else if(subGeoSet != NULL && subGeoSet.size() > 1 && (activityRecordTypeGeoListMap != NULL && activityRecordTypeGeoListMap.size() > 0 &&
                                                                                                                  activityRecordTypeGeoListMap.containsKey(ccpRecordTypeIds.get(pfr.RecordTypeId)) &&
                                                                                                                  activityRecordTypeGeoListMap.get(ccpRecordTypeIds.get(pfr.RecordTypeId)).contains(new List<String>(geoSet)[0]))){
                                                                                                                      errorThrown = true;
                                                                                                                      pfr.addError(Label.Core_MDF_Country_Multiple_SubGeo_Error);
                                                                                                                      //break; --> Break statement must be in loop
                                                                                                                  }               
                                                            else{
                                                                errorThrown = false;
                                                                List<String> geoSetList = new List<String>();                                
                                                                geoSetList.addAll(geoSet);
                                                                //US1098882
                                                                /*pfr.Core_MDF_Region_cd__c =  geoSetList[0];*/
                                                                pfr.Core_MDF_Region_nm__c =  geoSetList[0];
                                                                if(activityRecordTypeGeoListMap != NULL && activityRecordTypeGeoListMap.size() > 0 && 
                                                                   ccpRecordTypeIds.containsKey(pfr.RecordTypeId) && 
                                                                   activityRecordTypeGeoListMap.containsKey(ccpRecordTypeIds.get(pfr.RecordTypeId))){
                                                                       List<String> geoProgramList = activityRecordTypeGeoListMap.get(ccpRecordTypeIds.get(pfr.RecordTypeId));
                                                                       if(geoProgramList != NULL && geoProgramList.contains(geoSetList[0])){
                                                                           List<String> subGeoSetList = New List<String>();
                                                                           //US1098882
                                                                           if(pfr.Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM){
                                                                               subGeoSetList.addAll(subGeoSet);
                                                                               /*pfr.Core_MDF_Sub_Region_cd__c = subGeoSetList[0];//CHECK VALUE*/
                                                                               pfr.Core_MDF_Sub_Region_nm__c = subGeoSetList[0];//CHECK VALUE
                                                                           }
                                                                       }
                                                                       else{
                                                                           //US1098882
                                                                           /*pfr.Core_MDF_Sub_Region_cd__c = NULL;//CHECK VALUE*/
                                                                           pfr.Core_MDF_Sub_Region_nm__c = NULL;//CHECK VALUE
                                                                       }
                                                                   }
                                                                else{
                                                                    //US1098882
                                                                    /*pfr.Core_MDF_Sub_Region_cd__c = NULL;//CHECK VALUE*/
                                                                    pfr.Core_MDF_Sub_Region_nm__c = NULL;//CHECK VALUE
                                                                }    
                                                            }
                                                        }
                                                            
                                                    }
                                                }
                                                    return errorThrown;          
                                                }
    
    /****************************************************************************************************** 
Method Name:        updatePctAndPorChecks
@return  :          
@parameters:        
Description:        [KIIT]: W Revamp of Activity Trigger to support FE and new approval flow using IUPGM 
Updates Price Reviewer and Program office review indicators
Added By:           Accenture - Sai 
Date:               28/04/2022
*******************************************************************************************************/
    public static void updatePctAndPorChecks(PartnerFundRequest pfr, List<String> spifActivityTypesList, List<String> otherActivityTypesList,Map<Id,PartnerFundRequest> oldPfrMap){
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>{pfr}; // Joshua 15182
        Map<Id, Boolean> Camp_Approval_checkMap = retrieveApprovalField(pfrList); // Joshua 15182
        Boolean CCF_DCFCheck = (pfr.Core_MDF_Program__c == Label.Core_MDF_CCF_Program_Name || pfr.Core_MDF_Program__c == Label.Core_MDF_DCF_Program_Name); //Joshua 15182 program check for CCF/DCF
        List<String> outcomeEligiblePrograms = label.Core_MDF_Program_Enabled_Tactics.split(',');
        Boolean isOtherActivity = otherActivityTypesList.contains(pfr.Core_MDF_Activity_Types__c); // Joshua 15182
	Boolean isspifActivity = spifActivityTypesList.contains(pfr.Core_MDF_Activity_Types__c); // Joshua 15182
        Boolean isCMP = pfr.Core_MDF_Budget_Type_nm__c == Label.Core_MDF_BudgetType_CMP; // Joshua 15182
        Boolean Camp_Approval_check= Camp_Approval_checkMap.containsKey(pfr.CampaignId)? Camp_Approval_checkMap.get(pfr.CampaignId): false; // Joshua 15182
        Boolean CMP_threshold_value = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c > Decimal.valueOf(Label.CMP_Threshold_value); // Joshua 15182
        Boolean CMPcheck = isCMP && Camp_Approval_check && CMP_threshold_value && isOtherActivity; // Joshua 15182
        Boolean CMPcheckforSPIF = isCMP && Camp_Approval_check && CMP_threshold_value && isspifActivity; // Joshua 15182  
        //Added Core_MDF_Skip_PCT_Approval_ind__c condition for outcomebased on edit 
        if(oldPfrMap == null ||(oldPfrMap!= null  && ((oldPfrMap.get(pfr.Id).Core_MDF_Activity_Types__c != pfr.Core_MDF_Activity_Types__c) || (outcomeEligiblePrograms.contains(pfr.Core_MDF_Program__c) && ((oldPfrMap.get(pfr.Id).Core_MDF_Tactics_nm__c != pfr.Core_MDF_Tactics_nm__c) || (oldPfrMap.get(pfr.Id).Core_MDF_Skip_PCT_Approval_ind__c != pfr.Core_MDF_Skip_PCT_Approval_ind__c))))) || CCF_DCFCheck ){ //Added CCF_DCFCheck check Joshua 15182
            Boolean isSpifTactic= checkTactics(pfr);
            //Added this Core_MDF_Skip_PCT_Approval_ind__c condition to skip PCT Approval
            if(((spifActivityTypesList.contains(pfr.Core_MDF_Activity_Types__c) && !(CCF_DCFCheck)) || (CCF_DCFCheck && CMPcheckforSPIF) || (CCF_DCFCheck && (spifActivityTypesList.contains(pfr.Core_MDF_Activity_Types__c) && !isCMP))) || (isSpifTactic && !pfr.Core_MDF_Skip_PCT_Approval_ind__c)){    
                pfr.Core_MDF_Price_reviewer_check_ind__c = true;//CHECK VALUE
            }else{
                pfr.Core_MDF_Price_reviewer_check_ind__c = false;
            }
            if((isOtherActivity && !(CCF_DCFCheck)) || (CCF_DCFCheck && CMPcheck)|| (CCF_DCFCheck && (isOtherActivity && !isCMP))){ // Joshua 15182 Added (CMPcheck)
                pfr.Core_MDF_Program_Office_Check_ind__c = true;//CHECK VALUE
            }else{
                pfr.Core_MDF_Program_Office_Check_ind__c = false;
            }   
        }
    }
    
    /****************************************************************************************************** 
Method Name:        getActivitySubDueDate
@return  :          Map<String, Date>
@parameters:        
Description:        [KIIT]: W Revamp of Activity Trigger to support FE and new approval flow using IUPGM 
get activity's sub due date from custom meta data
Added By:           Accenture - Sai 
Date:               29/04/2022
*******************************************************************************************************/
    public static Map<String, Date> getActivitySubDueDate(Map<String, Date> dueDateMap){
        Map<String, Date> actSubDueDateMap = getDueDate(dueDateMap,'ActSubDueDate');
        return actSubDueDateMap;
    }
    public static map<string,date> getActClosureExtensionDate(map<string,date> dueDateMap){
        map<string,date> actSubDueDateMap = getDueDate(dueDateMap,'ActClosureDate');
        return actSubDueDateMap;
    }
    private static Map<String, Date> getDueDate(Map<String, Date> submissionDueDateMap, String window){
        Map<String, Date> dueDateMap = new Map<String, Date>();
        date ActivityEndDateInstance;
        Map<String, List<InternalMetdata>> ruleToMtdMap = new Map<String, List<InternalMetdata>>{};
            
            // the key will be-> pgm:budgettype:geo:subgeo:country:date
            // date will be input and parsed as per user locale. input date = date.format()(may need to change after discussion)
            
            Set<String> keySet = new Set<String>{};
                for(String strKey : submissionDueDateMap.keySet()){
                    String key = strKey.substringbeforelast(':');
                    keySet.add(key);
                }
        Map<String, Core_MDF_CCP_Submission_Window__mdt> inputKeyToMtdMap = getMetadataValuesForKeyApplied(keySet);
        
        if(submissionDueDateMap != null && !submissionDueDateMap.isEmpty()){
            for(String strKey : submissionDueDateMap.keySet()){
                
                if(dueDateMap.containsKey(strKey)){
                    continue;
                }
                //strKey -->eg, DCF:MDF:null:null:10/17/2022
                //key --> DCF:MDF:null:null
                String key = strKey.substringbeforelast(':');
                //ActivityEndDateInstanceStr -->10/17/2022
                String ActivityEndDateInstanceStr = strKey.substringafterlast(':');
                List<String> formattedDateList = ActivityEndDateInstanceStr.split('/');
                String pfrEndDateDay = formattedDateList[0];
                String pfrEndDateMonth = formattedDateList[1];
                String pfrEndDateYear = formattedDateList[2];
                
                ActivityEndDateInstance  = Date.newInstance(Integer.valueOf(pfrEndDateYear),Integer.valueOf(pfrEndDateMonth),Integer.valueOf(pfrEndDateDay));
                if(ActivityEndDateInstance != null){
                    Core_MDF_CCP_Submission_Window__mdt mtd = inputKeyToMtdMap.get(key);
                    // get quarter value from metadata
                    if(mtd != null && mtd.Core_MDF_Quarter__c != null){
                        integer qtrVal = integer.valueOf(mtd.Core_MDF_Quarter__c);
                        date qtrEndDate = getQuarterEndDate(ActivityEndDateInstance,qtrVal);
                        
                        if(window.equalsIgnoreCase('ActSubDueDate')){
                            InternalMetdata intMtd = new InternalMetdata();
                            intMtd.rule=mtd.Core_MDF_Activity_Auto_Closure_Rule__c;
                            intMtd.mtd=mtd;
                            intMtd.dt=qtrEndDate;
                            dueDateMap.put(strKey, getDate(intMtd));                                
                        }
                        if(window.equalsIgnoreCase('ActClosureDate')){
                            InternalMetdata intMtd = new InternalMetdata();
                            intMtd.rule=mtd.Core_MDF_Closure_date_Extension_Rule__c;
                            intMtd.mtd=mtd;
                            intMtd.dt=qtrEndDate;
                            dueDateMap.put(strKey, getDate(intMtd));                                
                        } 
                    }
                }
            }
        } 
        
        
        return dueDateMap;
    }
    
    private static Map<String,Core_MDF_CCP_Submission_Window__mdt> getMetadataValuesForKeyApplied(Set<String> keySet){
        Map<String,Core_MDF_CCP_Submission_Window__mdt> keyToAppliedMetadataMap = new Map<String,Core_MDF_CCP_Submission_Window__mdt>{};  
            Map<String,Core_MDF_CCP_Submission_Window__mdt> ncClosureMap = createSubmissionAndClosureMap();       
        for(String key : keySet){
            Core_MDF_CCP_Submission_Window__mdt mtd;
            if(ncClosureMap != null && !ncClosureMap.isEmpty()){
                String keyApplied;
                // get the metadata as per the key pgm:budgettype:geo:subgeo:country
                if(ncClosureMap.containsKey(key)){
                    keyApplied=key;
                    mtd = ncClosureMap.get(key);
                }else{
                    // if no metadata as per above, then keep checking the metdatda by subgeo, geo, budgettype, programme
                    list<String> keyList = key.split(':');
                    String programme = keyList[0];
                    String budgetType = keyList[1];
                    String geo = keyList[2];
                    String subGeo = keyList[3];
                    
                    String keySubGeo = programme +':'+ budgetType +':'+ geo +':'+ subGeo +':'+ 'null';
                    String keyGeo = programme +':'+ budgetType +':'+ geo +':'+ 'null' +':'+ 'null';
                    String keyPgmBudget = programme +':'+ budgetType +':'+ 'null' +':'+ 'null' +':'+ 'null';
                    String keyPgm = programme +':'+ 'null' +':'+ 'null' +':'+ 'null' +':'+ 'null';
                    
                    
                    if(ncClosureMap.containsKey(keySubGeo)){
                        keyApplied = keySubGeo;
                    }else if(ncClosureMap.containsKey(keyGeo)){
                        keyApplied = keyGeo;
                    }else if(ncClosureMap.containsKey(keyPgmBudget)){
                        keyApplied = keyPgmBudget;
                    }else if(ncClosureMap.containsKey(keyPgm)){
                        keyApplied = keyPgm;
                    }
                    
                    
                    if(String.isNotBlank(keyApplied)){
                        mtd = ncClosureMap.get(keyApplied);
                    }
                }
            }
            keyToAppliedMetadataMap.put(key,mtd);
        }
        
        return keyToAppliedMetadataMap;
    }
    
    private static Map<String,Core_MDF_CCP_Submission_Window__mdt> createSubmissionAndClosureMap(){
        Map<String,Core_MDF_CCP_Submission_Window__mdt> submissionAndClosureMap = new Map<String,Core_MDF_CCP_Submission_Window__mdt>();
        List<Core_MDF_CCP_Submission_Window__mdt> ncClosureMtdList = [SELECT Core_MDF_Program__c, Core_MDF_Budget_Type__c, 
                                                                      Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, Core_MDF_Country__c,
                                                                      Core_MDF_Quarter__c,Core_MDF_Case_SLA__c, Core_MDF_Claim_Submission_Window_mnth__c, Core_MDF_Claim_Submission_Window_days__c,
                                                                      Core_MDF_Doc_Submission_Window__c,Core_MDF_Doc_Submission_Rule__c,
                                                                      Core_MDF_Escalation_Submission_Window__c,Core_MDF_Escalation_Submission_Rule__c,
                                                                      Core_MDF_Activity_Auto_Closure_SLA__c,Core_MDF_Closure_date_Extension_Rule__c,Core_MDF_Closure_Date_Extension__c,Core_MDF_Activity_Auto_Closure_SLA_Month__c,
                                                                      Core_MDF_Activity_Auto_Closure_Rule__c    
                                                                      FROM Core_MDF_CCP_Submission_Window__mdt
                                                                      WHERE Core_MDF_Active__c = TRUE
                                                                      AND Core_MDF_Program__c != NULL 
                                                                      //AND Core_MDF_Budget_Type__c != NULL
                                                                     ];
        for(Core_MDF_CCP_Submission_Window__mdt mtd : ncClosureMtdList){
            String key = mtd.Core_MDF_Program__c +':'+mtd.Core_MDF_Budget_Type__c+':'+mtd.Core_MDF_Geo__c +':'+mtd.Core_MDF_Sub_Geo__c +':'+mtd.Core_MDF_Country__c; 
            key = key.deleteWhitespace();
            submissionAndClosureMap.put(key,mtd);
        }
        return submissionAndClosureMap;
    }
    
    private static Date getDate(InternalMetdata intMtd){
        List<String> rulesplit = new List<String>();
        Date returnDate = intMtd.dt;
        if(intMtd != null){
            if(intMtd.rule.contains('+')){
                rulesplit = intMtd.rule.split('\\+');
            }
            else{
                rulesplit.add(intMtd.rule);
            }
        }
        if(rulesplit!=null){
            for(String rule : rulesplit){
                if(rule=='Core_MDF_Activity_Auto_Closure_SLA__c'){
                    returnDate = getActSubDueDate(returnDate,intMtd.mtd);
                }
                if(rule=='Core_MDF_Activity_Auto_Closure_SLA_Month__c'){
                    returnDate = getActSubDueDate(returnDate,intMtd.mtd);
                }
                if(rule=='Core_MDF_Closure_Date_Extension__c'){
                    returnDate = getcloseExtensionDate(returnDate,intMtd.mtd); 
                }
                
            }
        }
        return returnDate;
    }
    
    private static date getQuarterEndDate(date dt, integer qtrVal){
        date qtrEndDate;
        if(qtrVal == 0){
            qtrEndDate = dt;
        }
        else{
            integer noOfMonthsPerQtr = 12/qtrVal;
            date firstDayCurrentYear = date.newinstance(dt.year(),1,1);
            date claimSubmissionDueDt;
            for(integer i=noOfMonthsPerQtr; i<=12; i+=noOfMonthsPerQtr){
                qtrEndDate = firstDayCurrentYear.addmonths(i);
                qtrEndDate = qtrEndDate.addDays(-1);
                if(dt <= qtrEndDate){
                    break;
                }
            }
        }
        return qtrEndDate;
    }
    
    private class InternalMetdata {
        //String key;
        String rule;
        Core_MDF_CCP_Submission_Window__mdt mtd;
        Date dt;
    }
    
    public static date getActSubDueDate(date dt, Core_MDF_CCP_Submission_Window__mdt mtd){
        date actSubDueDate;
        if(dt != null && mtd != null){
            if(mtd.Core_MDF_Activity_Auto_Closure_SLA_Month__c != null && mtd.Core_MDF_Activity_Auto_Closure_SLA_Month__c > 0 ){
                integer actSubClosureWindowAddMnths = integer.valueOf(mtd.Core_MDF_Activity_Auto_Closure_SLA_Month__c);
                actSubDueDate = dt.addMonths(actSubClosureWindowAddMnths);
                //submissionDueDate = submissionDueDate.addMonths(submissionAddMonths).toStartofMonth().addDays(-1);
                if(mtd.Core_MDF_Quarter__c > 0){
                    integer numberOfDays = Date.daysInMonth(actSubDueDate.year(), actSubDueDate.month());
                    actSubDueDate = Date.newInstance(actSubDueDate.year(), actSubDueDate.month(), numberOfDays);
                }
            }else if(mtd.Core_MDF_Activity_Auto_Closure_SLA__c != null && mtd.Core_MDF_Activity_Auto_Closure_SLA__c > 0 ){
                integer actSubClosureWindowAddDays = integer.valueOf(mtd.Core_MDF_Activity_Auto_Closure_SLA__c);
                actSubDueDate = dt.addDays(actSubClosureWindowAddDays);
            }
            
        }
        
        return actSubDueDate;
    }
    
    public static date getcloseExtensionDate(date dt, Core_MDF_CCP_Submission_Window__mdt mtd){
        date actSubDueDate;
        
        if(dt != null && mtd != null){
            if(mtd.Core_MDF_Closure_Date_Extension__c != null && mtd.Core_MDF_Closure_Date_Extension__c > 0 ){
                integer actSubClosureWindowAddDays =  integer.valueOf(mtd.Core_MDF_Closure_Date_Extension__c);
                actSubDueDate = system.today().addDays(actSubClosureWindowAddDays);
            }else
            {
                actSubDueDate = getActSubDueDate(dt, mtd);
            }
        }
        return actSubDueDate;
    }
    
    /****************************************************************************************************** 
Method Name:        deriveActivityStatuses
@return  :          
@parameters:        
Description:        [KIIT]: W Revamp of Activity Trigger to support FE and new approval flow using IUPGM 
Generic Method to update all activity statuses
Added By:           Sai 
Date:               10/05/2022
*******************************************************************************************************/
    public static void deriveActivityStatuses(PartnerFundRequest pfr,Map<Id,PartnerFundRequest> oldPfrMap){
        
        if(oldPfrMap != null && oldPfrMap.size() > 0){
            
            //Updating prior status value when activity status is changed
            if(oldPfrMap != NULL && oldPfrMap.size() > 0 && pfr.Core_MDF_Fund_Request_Status__c != oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c){ 
                pfr.Core_MDF_PriorValueOfStatus__c =  oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c ;
                if(pfr.Core_MDF_Activity_CreatedByExternalUsr__c){
                    pfr.Core_MDF_PriorValueStatusForExternalUser__c = oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c; 
                    //Updating prior status value when status changed by external user
                }
            }
            //Updating Budget Local Amount and Budget Currency     
            if(String.isBlank(pfr.Core_MDF_Budget_Currency_cd__c)
               && pfr.Core_MDF_Budget_Amount_Local_amt__c == null
               && pfr.Core_MDF_Fund_Request_Status__c != oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c && 
               (pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_CCP_Planned_Status 
                || pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Revision_Required 
                || oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_PendingReview)){
                    pfr.Core_MDF_Budget_Amount_Local_amt__c = pfr.RequestedAmount;
                    pfr.Core_MDF_Budget_Currency_cd__c = Core_MDF_CCP_ConstantClass.PFR_CURRENCY_USD;
                }
            if(oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS
               && pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS){
                   pfr.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS;
                   pfr.Status = Core_MDF_CCP_ConstantClass.PFR_REJECTED_STATUS;
               }
            if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS){
                pfr.Status = Core_MDF_CCP_ConstantClass.PFR_REJECTED_STATUS;
            }
        }
        if(oldPfrMap == null && Pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS 
           &&   pfr.AllocationId != null && pfr.core_MDF_budget_type_nm__c == Label.Core_MDF_Retail_RSA_MD_Budget_Type ){
               
               pfr.status = Core_MDF_CCP_ConstantClass.PFR_APPROVED_STATUS;
               
           }
    }
    
    
    /****************************************************************************************************** 
Method Name:        executeEventRule
@return  :          
@parameters:        PartnerFundRequest, pfrRecordTypeEventMetadataMap, ccpRecordTypeIds, oldPfrMap, progName
pfrDateMap, pfrRecordTypeAttributeMetadataMap, pfrIdMgrIdMap
Description:        [KIIT]: W Revamp of Activity Trigger to support FE and new approval flow using IUPGM 

Added By:           Accenture - Sai 
Date:               18/05/2022
Modified By:        Mohit Sharma; removed pfrRecordTypeEventMetadataMap from parameter 
*******************************************************************************************************/
    public static void executeEventRule(PartnerFundRequest pfr, Map<Id, String> ccpRecordTypeIds, Map<Id, PartnerFundRequest> oldPfrMap, String progName,
                                        Map<Id,List<Date>> pfrDateMap, Map<String, List<Core_MDF_CCP_Custom_Metadata_Utility__c>> pfrRecordTypeAttributeMetadataMap, 
                                        Map<Id, Id> pfrIdMgrIdMap){
                                            
                                            Boolean errorthrown = false;
                                            Date startDate = pfr.Core_MDF_Start_Date__c;
                                            
                                            Date todayDate = System.today();
                                            
                                            Integer daysDifference = todayDate.daysBetween(startDate);
                                            String dayDifference = String.valueOf(daysDifference);
                                            
                                            String amount = String.valueOf(pfr.RequestedAmount);
                                            
                                            
                                            
                                            //closed date validations
                                            if(!errorthrown){
                                                
                                                //Populating Activity Pillar and Secondary Pillar values from the CCP Attributes Metadata
                                                
                                                Core_MDF_PartnerFundRequest_Utility.getActivityPillarAndActivitySecondaryPillar(pfr, ccpRecordTypeIds.get(pfr.RecordTypeId));
                                                
                                            }   
                                            
                                        }
    /****************************************************************************************************** 
Method Name:        getFakeId
@return  :          
@parameters:        
Description:        Generates fakeIds for a record.

Added By:           Harshadeep 
Date:               05/07/2022
*******************************************************************************************************/                                       
    
    
    public static String getFakeId(Schema.SObjectType sot, Integer s_num){
        String result = String.valueOf(s_num++);
        return  pfrPrefixKey + '0'.repeat(12-result.length()) + result;
    }  
    /****************************************************************************************************** 
Method Name:        setATFFlag
@return  :          
@parameters:        pfr list, oldpfr map
Description:        Setting of ATF Flag in different statuses 

Added By:           Bishanka        Date: 16/08/2022
Modified By:        Ramapriya       Date: 25/07/2025    Added new ATF Flag value for In-progress activity edit
*******************************************************************************************************/
    public static void setATFFlag(PartnerFundRequest pfr,Map<Id,PartnerFundRequest> oldPfrMap)
    {
        //ATF Flag
        String atfDate = System.Label.Core_MDF_ATF_Insertion_Status;
        String atfPlannedStatus = System.Label.Core_MDF_ATF_Planned_Status;
        String atfRRStatus = System.Label.Core_MDF_ATF_RR;
        String atfInProgressStatus=System.Label.Core_MDF_ATF_In_Progress_Status;
        String atfClosedStatus = System.Label.Core_MDF_ATF_Closed_Status;
        Boolean isfieldModified;
        
        if(oldPfrMap != NULL && (oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_RR_STATUS 
                                 || oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS 
                                 || oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_STATUS )){
                                     isfieldModified = isfieldModified('PartnerFundRequest', 'Core_MDF_Activity_UI_Fieldset', pfr, oldPfrMap);
                                 }
        
        
        // Insert Record
        if((oldPfrMap == NULL && pfr.Core_MDF_Start_Date__c < System.today()) || 
           (oldPfrMap != NULL && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c && pfr.Core_MDF_Start_Date__c < System.today())){
               if(String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c)){
                   pfr.Core_MDF_ATF_Flag_nm__c= atfDate ;
               }
               else if(!pfr.Core_MDF_ATF_Flag_nm__c.contains(atfDate)){
                   pfr.Core_MDF_ATF_Flag_nm__c=pfr.Core_MDF_ATF_Flag_nm__c+';'+atfDate ;
               }
           }
        
        // Update Record
        if((oldPfrMap !=NULL && pfr.Core_MDF_Start_Date__c < System.today() && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c < System.today()) ||
           (oldPfrMap != NULL && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c < System.today()
            && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c ))
        {
            //Avoid Deeply Nested IF Statements
            if(oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_RR_STATUS && isfieldModified == true && String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c)){
                pfr.Core_MDF_ATF_Flag_nm__c = atfRRStatus;
            }
            if(oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_RR_STATUS && isfieldModified == true && !String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c) && !pfr.Core_MDF_ATF_Flag_nm__c.contains(atfRRStatus)){
                pfr.Core_MDF_ATF_Flag_nm__c = pfr.Core_MDF_ATF_Flag_nm__c + ';' + atfRRStatus;
            }
            // Setting ATF Flag for edit in Planned Status
            if(oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS && isfieldModified == true && String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c)){
                pfr.Core_MDF_ATF_Flag_nm__c = atfPlannedStatus;
            }
            if(oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS && isfieldModified == true && !String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c) && !pfr.Core_MDF_ATF_Flag_nm__c.contains(atfPlannedStatus)){
                pfr.Core_MDF_ATF_Flag_nm__c = pfr.Core_MDF_ATF_Flag_nm__c + ';' + atfPlannedStatus;
            }
            // Ramapriya - Setting ATF Flag for edit in In-Progress Sttaus for IPA Program
            if(oldPfrMap.get(pfr.Id).Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_STATUS && isfieldModified == true && String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c)){
                pfr.Core_MDF_ATF_Flag_nm__c = atfInProgressStatus;
            }
            if(oldPfrMap.get(pfr.Id).Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_STATUS && isfieldModified == true && !String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c) && !pfr.Core_MDF_ATF_Flag_nm__c.contains(atfInProgressStatus)){
                pfr.Core_MDF_ATF_Flag_nm__c = pfr.Core_MDF_ATF_Flag_nm__c + ';' + atfInProgressStatus;
            }
        }
        
    }
    
    /****************************************************************************************************** 
Method Name:        isfieldModified
@return  :          Boolean
@parameters:        objectName, fieldSetName, newObject, oldObjectmap
Description:        Get boolean value if any field modified from oldObjRecord to newObjeRecord using fieldset
Added By:           Saikat 
Date:               29/08/2022
*******************************************************************************************************/    
    
    public static Boolean isfieldModified(String objectName, String fieldSetName, 
                                          SObject newObject, Map<Id, SObject> oldObjectmap){        
                                              Boolean isFldModified = false;    
					      					  // ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
                                              List<Schema.FieldSetMember> fieldSetMemberList = Schema.describeSObjects(new List<String>{objectName})[0].FieldSets.getMap().get(fieldSetName).getFields();
                                              if(!fieldSetMemberList.isEmpty()){
                                                  for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                                                      String fieldAPIName = (String)fieldSetMemberObj.getFieldPath();
                                                      String fieldType = String.valueOf(fieldSetMemberObj.getType());
                                                      if((fieldType == 'STRING' || fieldType == 'TEXTAREA') && 
                                                         oldObjectmap.get(newObject.Id).get(fieldAPIName) != NULL &&  newObject.get(fieldAPIName) != NULL){
                                                             string oldFieldVal = (string)oldObjectmap.get(newObject.Id).get(fieldAPIName);
                                                             string newFieldVal = (string)newObject.get(fieldAPIName);
                                                             if(!oldFieldVal.equals(newFieldVal)){
                                                                 isFldModified = true;
                                                                 break;
                                                             }
                                                         } else {
                                                             if(oldObjectmap.get(newObject.Id).get(fieldAPIName) != newObject.get(fieldAPIName)){
                                                                 isFldModified = true;
                                                                 break;
                                                             } 
                                                         }
                                                  }
                                              }
                                              return isFldModified;
                                          }
    
    public static String getRecordTypeDevloperNameById(String objName, Id recTypeId){
        return (string)rtMapById.get(recTypeId).getDeveloperName();
        
    } 
    
    /****************************************************************************************************** 
Method Name:        callRuleEngine
@return  :          
@parameters:        
Description:        [KIIT]: W Revamp of Activity Trigger to support FE and new approval flow using RuleEngine data 

Added By:           Sai           Date:  30/05/2022
Modified By:        Ramapriya     Date:  25/07/2025     Added status check as part of "In-Progress Activity Edit"

*******************************************************************************************************/
    public static void callRuleEngine(List<PartnerFundRequest> pfrList,Map<Id,PartnerFundRequest> oldMap,Boolean isInsert,Boolean isBefore){
    Map<Id, Boolean> Camp_Approval_checkMap = retrieveApprovalField(pfrList); // Joshua 15182
        Map<String, List<sobject>> inputMap = new Map<String, List<sobject>>();
        
        List<PartnerFundRequest> pfrRuleList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrRuleListClone = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrCalcList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrToUpdateWithApprovalCriteriaList = new List<PartnerFundRequest>();
        Map<String, String> pfrIdToApprovalCriteriaIdMap = new Map<String, String>();
        Map<String, String> pfrIdToApprovalProcessMap = new Map<String, String>();
        Integer recordIdCount =1;
        Set<String> userIdSet = new Set<String>(); 
        Map<String,String> userIdManagerMap = new Map<String,String>();
        Map<String,String> userIdManagersManagerIdMap = new Map<String,String>();
        Map<String,String> pfrIdToUserIdMap = new Map<String,String>();
        
        List<PartnerFundRequest> pfrManagerLevelApprovalList = new List<PartnerFundRequest>();
        
        Core_MDF_PartnerFundRequest_Utility.ClaimActAllocRecTypeMappingWrapper claimActAllocRecTypeMapWrapInstance = Core_MDF_PartnerFundRequest_Utility.getMetaDataValues();
        // Mapping Of RecordType and associated close date
        Map<String,Integer> activityRecordTypeCloseDateMap = new Map<String,Integer>();
        activityRecordTypeCloseDateMap = claimActAllocRecTypeMapWrapInstance.activityRecordTypeCloseDateMap;
        // RecordTypeId and RecordType DeveloperName Map 
        Map<Id,String> ccpRecordTypeIds = new Map<Id,String>();
        ccpRecordTypeIds = Core_MDF_PartnerFundRequest_Utility.getCCPRTNames(activityRecordTypeCloseDateMap);
        List<String> budgetTypeCCFDCF1_0 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetTypeToExclude').split(';');
        
        List<String> budgetTypesList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_CustomerAutoApprBudgetType').split(';');//
        
        Set<String> accntIdSet = new Set<String>();
        Set<String> programSet = new Set<String>();
        Set<String> geoStrSet = new Set<String>();
        Set<String> budgetTypeSet = new Set<String>();
        
        try{
            if(Trigger.isBefore){
                Set<Id> accIdSet = new Set<Id>();
                for(PartnerFundRequest pfr: pfrList){
                    String region = (String.isNotBlank(pfr.Core_MDF_Host_Region_txt__c)) ? pfr.Core_MDF_Host_Region_txt__c : pfr.Core_MDF_Region_nm__c;
                    if((pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_PENDING_REVIEW_STATUS || (pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS && pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM)) 
                       && ((isInsert || oldMap.get(pfr.Id).Core_MDF_Approval_Step_Completed__c != pfr.Core_MDF_Approval_Step_Completed__c || oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c 
                            || (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name').equals(pfr.Core_MDF_Program__c) && (pfr.Core_MDF_Region_nm__c == Core_MDF_CCP_ConstantClass.PFR_REGION_EMEA && pfr.Core_MDF_Approval_Step_Completed__c == 0) 
                                || oldMap.get(pfr.Id).Core_MDF_Region_nm__c != pfr.Core_MDF_Region_nm__c)))&& (pfr.Core_MDF_Proposal_Based_Ind__c   == false)){
                                    
                                    if(isInsert && pfr.Id ==null){
                                        String randomNumber =getFakeId( pfr.getSObjectType(),recordIdCount);
                                        pfr.Id =randomNumber;
                                        recordIdCount++;
                                    }
                                    if(pfr.Core_MDF_Approval_Step_Completed__c != 0){
                                        pfr.Core_MDF_Completed_Approval_Level_Name__c    = pfr.Core_MDF_Approval_Stage__c;// move to approval process
                                    }
                                    
                                    accntIdSet.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                                    programSet.add(pfr.Core_MDF_Program__c);
                                    geoStrSet.add(region);
                                    budgetTypeSet.add(pfr.Core_MDF_Budget_Type_nm__c);
                                    
                                    pfrRuleListClone.add(pfr.clone(true));
                                    pfrRuleList.add(pfr);
                                }
                }
                //Copy Ecosystem Partner from Multiselect to Text area field for IPA
                populatePfrFields(pfrList,oldMap,isInsert,isBefore);
                
                
                
                List<System.FormulaRecalcResult> calcPFRFormulas = Formula.recalculateFormulas(pfrRuleListClone);
                
                for(System.FormulaRecalcResult calcPFRFormulasRecord : calcPFRFormulas){
                    if(calcPFRFormulasRecord.isSuccess()){
                        pfrCalcList.add((PartnerFundRequest)calcPFRFormulasRecord.getSObject());
                    }
                }
                
                
                if(!pfrCalcList.isEmpty()){
                    inputMap.put(Core_MDF_CCP_ConstantClass.RULE_ENGINE_FRONT_END_REVIEW, pfrCalcList);
                    ruleEngineResult = Core_MDF_Rules_Engine.executeRulesByObjects(inputMap);
                    
                }
                
                
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_IUPGMAssignment')){
                    approversFromIUPGMMap = getApproversFromIUPGM(accntIdSet,programSet,geoStrSet,budgetTypeSet);
                }
                
                // Collect PFR record Ids //Joshua 15182 start
                   /* Set<Id> pfrIds = new Set<Id>();
                    for (PartnerFundRequest pfr : pfrRuleList) {
                        pfrIds.add(pfr.Id);
                    }
                    // Get ProcessInstance records for all PFRs
                    Map<Id, ProcessInstance> processInstanceMap = new Map<Id, ProcessInstance>();
                    for (ProcessInstance pi : [
                        SELECT Id, Status, TargetObjectId,CreatedDate
                        FROM ProcessInstance
                        WHERE TargetObjectId IN :pfrIds  ORDER BY CreatedDate DESC
                    ]) {
                        processInstanceMap.put(pi.TargetObjectId, pi);
                    }*/ //Joshua 15182 End
                //sets data we get from rules:
                for(PartnerFundRequest pfr: pfrRuleList){//pfrRuleList Works both on insert & Update
            Boolean isCMP = pfr.Core_MDF_Budget_Type_nm__c == Label.Core_MDF_BudgetType_CMP; // Joshua 15182
            Boolean Camp_Approval_check = Camp_Approval_checkMap.get(pfr.CampaignId); // Joshua 15182
            Boolean CMP_threshold_value = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c > Decimal.valueOf(Label.CMP_Threshold_value); // Joshua 15182
            Boolean ISCMP_with_Threshold = isCMP && Camp_Approval_check && CMP_threshold_value; // Joshua 15182
            Boolean CCF_DCFCheck = (pfr.Core_MDF_Program__c == Label.Core_MDF_CCF_Program_Name || pfr.Core_MDF_Program__c == Label.Core_MDF_DCF_Program_Name); //Joshua 15182 program check for CCF/DCF
                    String region = (String.isNotBlank(pfr.Core_MDF_Host_Region_txt__c)) ? pfr.Core_MDF_Host_Region_txt__c : pfr.Core_MDF_Region_nm__c;
                    String userId;
                    if(!ruleEngineResult.isEmpty() &&  ruleEngineResult.containsKey(Core_MDF_CCP_ConstantClass.RULE_ENGINE_FRONT_END_REVIEW)){
                        
                        Map<String,Core_MDF_Rules_Engine.RulesEngineParams> rule1 = ruleEngineResult.get(Core_MDF_CCP_ConstantClass.RULE_ENGINE_FRONT_END_REVIEW);//gets the rule
                        
                        Core_MDF_Rules_Engine.RulesEngineParams ruleEngineParam = rule1.get(pfr.Id);
                        if(ruleEngineParam != null && ruleEngineParam.ruleRecord != null){
                            Boolean isNoAction = false;
                            pfrToRuleEngineMap.put(pfr,ruleEngineParam);
                            if(ruleEngineParam.result){//gets the RuleEngineParam and checks the result attribute
                                if(ruleEngineParam.actionOnTrue != Core_MDF_CCP_ConstantClass.RULE_ENGINE_NO_ACTION){
                                    pfr.Core_MDF_Approval_Stage__c = ruleEngineParam.actionOnTrue;  
                                    pfr.Core_MDF_Approver_Source_nm__c = (ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_on_True_nm__c;
                                    String key = pfr.Core_MDF_Program__c + pfr.Core_MDF_Budget_Type_nm__c + pfr.Core_MDF_Region_nm__c + pfr.Core_MDF_Approval_Stage__c;
                                    pfrApprovalSendMap.put(key, false);
                                }else{
                                    isNoAction = true;
                                    noAction = true;
                                    String key = pfr.Core_MDF_Program__c + pfr.Core_MDF_Budget_Type_nm__c + pfr.Core_MDF_Region_nm__c + pfr.Core_MDF_Approval_Stage__c;
                                    pfrApprovalSendMap.put(key, true);
                                }
                            }else{
                                if(ruleEngineParam.actionOnFalse != Core_MDF_CCP_ConstantClass.RULE_ENGINE_NO_ACTION){
                                    pfr.Core_MDF_Approval_Stage__c = ruleEngineParam.actionOnFalse;  
                                    
                                    pfr.Core_MDF_Approver_Source_nm__c = (ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_on_False_nm__c;
                                    String key = pfr.Core_MDF_Program__c + pfr.Core_MDF_Budget_Type_nm__c + pfr.Core_MDF_Region_nm__c + pfr.Core_MDF_Approval_Stage__c;
                                    pfrApprovalSendMap.put(key, false);
                                }else{
                                    isNoAction = true;
                                    noAction = true;
                                    String key = pfr.Core_MDF_Program__c + pfr.Core_MDF_Budget_Type_nm__c + pfr.Core_MDF_Region_nm__c + pfr.Core_MDF_Approval_Stage__c;
                                    pfrApprovalSendMap.put(key, true);
                                }
                            }  
                            if(isNoAction == false){
                    if(pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS){ 
                                     if(CCF_DCFCheck && ISCMP_with_Threshold){ //  Joshua 15182 Added check (CCF_DCFCheck && ISCMP_with_Threshold)
                                        pfr.Core_MDF_Approval_Stage__c = Core_MDF_CCP_ConstantClass.PFR_L1_APPROVAL;
                                        String key = pfr.Core_MDF_Program__c + pfr.Core_MDF_Budget_Type_nm__c + pfr.Core_MDF_Region_nm__c + pfr.Core_MDF_Approval_Stage__c;
                                        pfrApprovalSendMap.put(key, false); 
                                              /* ProcessInstance pi = processInstanceMap.get(pfr.Id);
                                                if(pi != null && pi.Status == 'Removed'){
                                               // if(pi.Status == 'Removed'){
                                                    // Approval request recalled
                                                    pfr.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_RR_STATUS;
                                                }*/
                                    }else if(!ISCMP_with_Threshold){
                                        pfr.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS;
                                            }
                                    
                                }else if(pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PFR_CUSTOMER_ACCEPTANCE 
                                         || pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER
                                         || pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_ACTIVATING_PARTNER){
                                             //Ramapriya - set status to In-Progress Pending Approval
                                             if(pfr.Core_MDF_PriorValueOfStatus__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_PENDING_REVIEW_STATUS || pfr.Core_MDF_PriorValueOfStatus__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_STATUS || pfr.Core_MDF_PriorValueOfStatus__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_REVISION_REQUIRED_STATUS){
                                                 pfr.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_PENDING_APPROVAL_STATUS;
                                             }
                                             else{
                                                 pfr.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS; 
                                             }  
                                         }
                                
                                String recordTypeName = getRecordTypeDevloperNameById('PartnerFundRequest',pfr.RecordTypeId);//Core_MDF_Service_Provider_CoMarketing_Fund
                                
                                
                                if((ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_on_False_nm__c != null || (ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_on_True_nm__c != null){
                                    
                                    clearAllApprovers(pfr);
                                    
                                    
                                    if(ruleEngineParam.result == true && (ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_on_True_nm__c != null 
                                       && (ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_on_True_nm__c == Core_MDF_CCP_ConstantClass.RULE_ENGINE_OBJECT_FIELD){
                                           
                                           userId = (String)pfr.get((ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_Value_on_True__c);
                                           
                                       }else if(ruleEngineParam.result == false && (ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_on_False_nm__c != null 
                                                && (ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_on_False_nm__c == Core_MDF_CCP_ConstantClass.RULE_ENGINE_OBJECT_FIELD){
                                                    
                                                    userId = (String)pfr.get((ruleEngineParam.ruleRecord).Core_MDF_Approver_Source_Value_on_False__c);
                                                }  
                                }
                                
                                //end
                                if((isInsert || (oldMap!=null && oldMap.get(pfr.Id).Core_MDF_Approval_Step_Completed__c != pfr.Core_MDF_Approval_Step_Completed__c)) 
                                   && pfr.Core_MDF_Approval_Step_Completed__c == 1 && pfr.Core_MDF_Proposal_Based_Ind__c == false){
                                       pfr.Core_MDF_Activity_First_Approver_txt__c  = UserInfo.getUserId();  
                                   }
                                //setting the L1 approverId to send the rejection mail,when rejected by POR,PCT or Additional Reviewer
                                if(oldMap != NULL && oldMap.get(pfr.Id).Core_MDF_Approval_Step_Completed__c != pfr.Core_MDF_Approval_Step_Completed__c && pfr.Core_MDF_Approval_Step_Completed__c == 1 
                                   &&(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS) && UserInfo.getUserType() == 'Standard' 
                                   && pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true 
                                   && (recordTypeName == Core_MDF_CCP_ConstantClass.PFR_CCF_RECORDTYPE || recordTypeName == Core_MDF_CCP_ConstantClass.PFR_DCF_RECORDTYPE || recordTypeName == Core_MDF_CCP_ConstantClass.PFR_EEF_RECORDTYPE
                                       || (recordTypeName == Core_MDF_CCP_ConstantClass.PFR_IPA_RECORDTYPE) && pfr.Core_MDF_Proposal_Based_Ind__c == false)){     
                                           pfr.Core_MDF_L1_Approver_Id__c = UserInfo.getUserId();
                                       }
                                
                                //setting the L1 Primary approverId to send the rejection mail,when rejected by POR,PCT,L2 Approver,Primary Partner Customer Acceptance or Activating Partner Customer Acceptance
                                if(oldMap != NULL && recordTypeName == Core_MDF_CCP_ConstantClass.PFR_EEF_RECORDTYPE && oldMap.get(pfr.Id).Core_MDF_Approval_Step_Completed__c != pfr.Core_MDF_Approval_Step_Completed__c && pfr.Core_MDF_Approval_Step_Completed__c == 2 
                                   &&(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS) && UserInfo.getUserType() == 'Standard' 
                                   && pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true ){
                                       pfr.Core_MDF_L1_Primary_Approver_Id__c = UserInfo.getUserId();
                                       if(pfr.Core_MDF_L1_Approver_Id__c==null){
                                           pfr.Core_MDF_L1_Approver_Id__c = pfr.Core_MDF_Activity_First_Approver_txt__c!=null?pfr.Core_MDF_Activity_First_Approver_txt__c:null;
                                       }
                                   }        
                                //do we need this if block-- start
                                if(pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PFR_L1_APPROVAL || pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PFR_L2_APPROVAL){
                                    //below code would be needed after rule engine -- start
                                    if(!String.isBlank(userId)){
                                        pfr.Core_MDF_Approver_1__c =userId;
                                        setAllApprovers(pfr);
                                    }   
                                }//do we need this if block-- end
                                else if(pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PFR_FIRST_LEVEL_MGR || pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PFR_SECOND_LEVEL_MGR){
                                    if(!String.isBlank(userId)){
                                        pfrIdToUserIdMap.put(pfr.id,userId);
                                        userIdSet.add(userId);
                                        pfrManagerLevelApprovalList.add(pfr);
                                    }else{
                                        userId = UserInfo.getUserId();  
                                        pfrIdToUserIdMap.put(pfr.id,userId);
                                        userIdSet.add(userId);
                                        pfrManagerLevelApprovalList.add(pfr);  
                                    }   
                                }
                            }
                        }   
                    }
                    deriveActivityStatuses(pfr,oldMap);
                }
                
                ///copied code-- start
                if(userIdSet != null && userIdSet.size() > 0){
                    for(User usr: [Select Id, ManagerId,Manager.ManagerId  FROM User WHERE Id =: userIdSet and ManagerId != NULL]){
                        userIdManagerMap.put(usr.Id, usr.ManagerId); 
                        userIdManagersManagerIdMap.put(usr.Id, usr.Manager.ManagerId); 
                    }  
                }
                for(PartnerFundRequest pfr : pfrManagerLevelApprovalList){
                    if(userIdManagerMap.containsKey((pfrIdToUserIdMap.get(pfr.Id)))){
                        pfr.Core_MDF_Approver_1__c = userIdManagerMap.get(pfrIdToUserIdMap.get(pfr.Id));
                        //setAllApprovers(pfr);
                    }else{
                        pfr.addError('No manager record found'); 
                    }
                    
                }
                
                
                Boolean isUpdate = !isInsert;
                
            }
            
            if(Trigger.isAfter){
                List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
                Set<String>pfrInPendingReviewIdSet = new Set<String>();
                Set<String>recordsInApprovalProcessIdSet = new Set<String>();
                List<PartnerFundRequest> pfrInPendingReviewList = new List<PartnerFundRequest>();
                List<PartnerFundRequest> pendingApprovalPFR = new List<PartnerFundRequest>();
                List<String> pfrAccntList = new List<String>();
                List<String> pfrProgramList = new List<String>();
                List<String> pfrGeoList = new List<String>();
                List<String> pfrApprovalStageStatusList = new List<String>();
                List<String> pfrBudgetTypeList = new List<String>();
                List<PartnerFundRequest> pendingApprovalRMFPfrList = new List<PartnerFundRequest>();
                List<PartnerFundRequest> plannedPfrList = new List<PartnerFundRequest>();
                
                //list and sets for email notification
                List<PartnerFundRequest> pendingApprovalPfrList = new List<PartnerFundRequest>();
                List<PartnerFundRequest> externalPendingApprovalPfrList = new List<PartnerFundRequest>();
                List<PartnerFundRequest> ipaAccPendingApprovalPfrList = new List<PartnerFundRequest>();
                List<PartnerFundRequest> revRqdPfrList = new List<PartnerFundRequest>();
                List<PartnerFundRequest> pendingApprovalOPALPfrList = new List<PartnerFundRequest>();
                List<PartnerFundRequest> pendingApprovalEEFPPfrList = new List<PartnerFundRequest>();
                List<PartnerFundRequest> pendingReviewMarketingPfrList = new List<PartnerFundRequest>();
                List<PartnerFundRequest> pendingReviewFieldPfrList = new List<PartnerFundRequest>();
                Set<Id> accIdSet = new Set<Id>();
                Set<Id> campAccIdSet = new Set<Id>();
                //Price Reviewer notification
                List<PartnerFundRequest> pendingPCTApprovalPFR = new List<PartnerFundRequest>();
                List<PartnerFundRequest> pendingGeoApprovalPFR = new List<PartnerFundRequest>();
                List<String> geoList = new List<String>();
                List<String> accntList = new List<String>();
                List<String> programList = new List<String>();
                //rejection notification by POR,PCT ,Additional reviewer to L1 Approver
                List<PartnerFundRequest> revReqPfrList = new List<PartnerFundRequest>();
                
                if(Trigger.isInsert){
                    
                    for(PartnerFundRequest pfr: pfrList){
                        
                        string region = pfr.Core_MDF_Host_Region_or_Region_txt__c;//For IPA & !PCT it stores Host Geo, else Transaction geo.
                        if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS){
                            
                            String recordTypeName = getRecordTypeDevloperNameById('PartnerFundRequest',pfr.RecordTypeId);//Core_MDF_Service_Provider_CoMarketing_Fund
                            String approvalProcessVersion = getApprovalProcessVersion(pfr,recordTypeName,budgetTypeCCFDCF1_0,budgetTypesList);
                            String key = pfr.Core_MDF_Program__c + pfr.Core_MDF_Budget_Type_nm__c + pfr.Core_MDF_Region_nm__c + pfr.Core_MDF_Approval_Stage__c;
                            
                            if(approvalProcessVersion != '' && !pfrApprovalSendMap.isEmpty() 
                               && pfrApprovalSendMap.containsKey(key) && !pfrApprovalSendMap.get(key)){
                                   Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                                   appObj.setObjectId(pfr.id);
                                   appObj.setProcessDefinitionNameOrId(approvalProcessVersion);
                                   appObj.setComments('Record submitted for approval');
                                   appRequests.add(appObj);
                               }
                            if((pfr.Core_MDF_Approval_Stage__c != Null && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PFR_PRICE_REVIEWER )  
                               && pfr.Core_MDF_Approver_Source_nm__c == Core_MDF_CCP_ConstantClass.PFR_APP_SOURCE_IUPGM && sendEmailOnce == true && pfr.Core_MDF_Activity_Level_nm__c != Core_MDF_CCP_ConstantClass.PFR_SUB_ACTIVITY) {
                                   pendingPCTApprovalPFR.add(pfr);
                                   accntList.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                                   programList.add(pfr.Core_MDF_Program__c);
                                   geoList.add(region);
                               }
                            //For GeoLead
                            else if((pfr.Core_MDF_Approval_Stage__c != Null && pfr.Core_MDF_Approval_Stage__c == 'Geo Lead Approval' )  
                                    && pfr.Core_MDF_Approver_Source_nm__c == Core_MDF_CCP_ConstantClass.PFR_APP_SOURCE_IUPGM && sendEmailOnce == true && pfr.Core_MDF_Activity_Level_nm__c != Core_MDF_CCP_ConstantClass.PFR_SUB_ACTIVITY) {
                                        pendingGeoApprovalPFR.add(pfr);
                                        accntList.add(pfr.ChannelPartnerId);
                                        programList.add(pfr.Core_MDF_Program__c);
                                        geoList.add(region);
                                        pfrApprovalStageStatusList.add(pfr.Core_MDF_Approval_Stage__c);
                                        pfrBudgetTypeList.add(pfr.Core_MDF_Budget_Type_nm__c);
                                    }
                            
                            else if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS
                                    && pfr.Core_MDF_Approver_Source_nm__c == Core_MDF_CCP_ConstantClass.PFR_APP_SOURCE_IUPGM 
                                    && pfr.Core_MDF_Approval_Stage__c != Null && sendEmailOnce == true && pfr.Core_MDF_Activity_Level_nm__c != Core_MDF_CCP_ConstantClass.PFR_SUB_ACTIVITY) {//Pending Review check needed
                                        pendingApprovalPFR.add(pfr);
                                        if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM 
                                           && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL){
                                               pfrAccntList.add(pfr.Core_MDF_Campaign_Ultimate_Account_Id__c);
                                           } else {
                                               pfrAccntList.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                                           }
                                        pfrProgramList.add(pfr.Core_MDF_Program__c);
                                        pfrGeoList.add(region);
                                        
                                        pfrApprovalStageStatusList.add(pfr.Core_MDF_Approval_Stage__c);
                                        pfrBudgetTypeList.add(pfr.Core_MDF_Budget_Type_nm__c);
                                    }
                            //notify ext Approvers in RMF when status is pending Approval
                            if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name') 
                               && pfr.Core_MDF_Fund_Request_Status__c != label.Core_MDF_PFR_Status_Closed //is this condition needed?
                               && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm')){                                
                                   pendingApprovalRMFPfrList.add(pfr);
                                   accIdSet.add(pfr.ChannelPartnerId);
                               }   
                            
                            //Added a code below to send the email notifacation to Additional Reviewer
                            if((pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.CCF_PROGRAM || pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.DCF_PROGRAM) 
                               && pfr.Core_MDF_Require_Additional_Review_ind__c && (pfr.Core_MDF_Approval_Step_Completed__c == 1 || pfr.Core_MDF_Approval_Step_Completed__c== 2 || pfr.Core_MDF_Approval_Step_Completed__c == 3)){
                                   if(pfr.Core_MDF_Additional_Review_Type_txt__c == 'Marketing Review'){
                                       pendingReviewMarketingPfrList.add(pfr);
                                   }else if(pfr.Core_MDF_Additional_Review_Type_txt__c == 'Field Review'){
                                       pendingReviewFieldPfrList.add(pfr);
                                   }
                                   pfrAccntList.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                                   pfrProgramList.add(pfr.Core_MDF_Program__c);
                                   pfrGeoList.add(region);
                                   pfrApprovalStageStatusList.add(pfr.Core_MDF_Approval_Stage__c);
                                   pfrBudgetTypeList.add(pfr.Core_MDF_Budget_Type_nm__c);
                               }
                            
                        }
                        //external mail for planned activity
                        if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
                            if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Planned_Status')){                                
                                plannedPfrList.add(pfr);
                                accIdSet.add(pfr.ChannelPartnerId);
                            }
                        }
                        //External mail for Pending Approval OPAL Activity
                        if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS 
                           && pfr.Core_MDF_Member_Acceptor_Id__c != NULL
                           && pfr.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER){
                               pendingApprovalOPALPfrList.add(pfr); 
                           }
                        //Send Approval notification to EEF External Primary Partner
                        if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM
                           && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS
                           && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER){
                               pendingApprovalEEFPPfrList.add(pfr);
                               campAccIdSet.add(pfr.Core_MDF_Campaign_Account_Id__c);
                           }
                        //IPA AccountBased Send Email on Pending Approval status during creation 
                        if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM && pfr.Core_MDF_Proposal_Based_Ind__c == false 
                           && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS && pfr.Core_MDF_Activity_Level_nm__c != Core_MDF_CCP_ConstantClass.PFR_SUB_ACTIVITY){
                               ipaAccPendingApprovalPfrList.add(pfr);
                           }
                        
                    } 
                    
                    //To call the email notification flow
                    if(ipaAccPendingApprovalPfrList != NULL && ipaAccPendingApprovalPfrList.Size() > 0 && sendNotificationByFlowOnce){
                        
                        sendNotificationByFlowOnce = false;                 
                        sendNotificationByFlow(ipaAccPendingApprovalPfrList);
                    }
                    if (appRequests.size()> 0){
                        Approval.ProcessResult[] result = Approval.process(appRequests);
                    }
                    if(pendingApprovalPFR != NULL && pendingApprovalPFR.Size() > 0){
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(pendingApprovalPFR, pfrAccntList, pfrGeoList, pfrProgramList,pfrApprovalStageStatusList,pfrBudgetTypeList);
                        emailSendOnce = false;
                        sendEmailOnce = false;
                    }
                    
                    if(pendingPCTApprovalPFR != NULL && pendingPCTApprovalPFR.Size() > 0){
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyPCTApprovers(pendingPCTApprovalPFR, accntList, geoList, programList);
                        emailSendOnce = false;
                        sendEmailOnce = false;
                    }            
                    //Added a code below to send the email notifacation to Additional Reviewer
                    if(pendingReviewMarketingPfrList != NULL && pendingReviewMarketingPfrList.Size() > 0){                  
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(pendingReviewMarketingPfrList, pfrAccntList, pfrGeoList, pfrProgramList,pfrApprovalStageStatusList,pfrBudgetTypeList);
                        emailSendOnce = false;
                        sendEmailOnce = false;
                    }
                    //Added a code below to send the email notifacation to Additional Reviewer
                    if(pendingReviewFieldPfrList != NULL && pendingReviewFieldPfrList.Size() > 0){                  
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(pendingReviewFieldPfrList, pfrAccntList, pfrGeoList, pfrProgramList,pfrApprovalStageStatusList,pfrBudgetTypeList);
                        emailSendOnce = false;
                        sendEmailOnce = false;
                    }           
                    if(pendingGeoApprovalPFR != NULL && pendingGeoApprovalPFR.Size() > 0){
                        
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(pendingGeoApprovalPFR, accntList, geoList, programList,pfrApprovalStageStatusList,pfrBudgetTypeList);
                        emailSendOnce = false;
                        sendEmailOnce = false;
                    }
                    //Send email when memeber acceptance is not null
                    if( pendingApprovalOPALPfrList != NULL && !pendingApprovalOPALPfrList.isEmpty() && emailSendOnce){
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyCCFDCFExternalReviewer(pendingApprovalOPALPfrList);
                        emailSendOnce = false;
                    } 
                    if(pendingApprovalEEFPPfrList != NULL && pendingApprovalEEFPPfrList.Size() > 0 
                       && campAccIdSet != NULL && campAccIdSet.Size() > 0 && emailSendOnce){
                           Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pendingApprovalEEFPPfrList, campAccIdSet);
                           emailSendOnce = false;
                       }
                }
                if(Trigger.isUpdate){
                    
                    for(PartnerFundRequest pfr: pfrList){
                        String progName = ccpRecordTypeIds.get(pfr.recordTypeId);
                        
                        string region = pfr.Core_MDF_Host_Region_or_Region_txt__c;//For IPA & !PCT it stores Host Geo, else Transaction geo.
                        if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS || pfr.Core_MDF_Fund_Request_Status__c ==Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_PENDING_REVIEW_STATUS || pfr.Core_MDF_Fund_Request_Status__c==Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_PENDING_APPROVAL_STATUS){
                            pfrInPendingReviewIdSet.add(pfr.Id);
                            pfrInPendingReviewList.add(pfr); 
                            
                            if((pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_PENDING_REVIEW_STATUS) && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.PFR_PRICE_REVIEWER 
                               && (pfr.Core_MDF_Approval_Stage__c != oldMap.get(pfr.Id).Core_MDF_Approval_Stage__c) && pfr.Core_MDF_Approver_Source_nm__c == Core_MDF_CCP_ConstantClass.PFR_APP_SOURCE_IUPGM && sendEmailOnce == true && pfr.Core_MDF_Activity_Level_nm__c != Core_MDF_CCP_ConstantClass.PFR_SUB_ACTIVITY) {
                                   pendingPCTApprovalPFR.add(pfr);
                                   accntList.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                                   programList.add(pfr.Core_MDF_Program__c);
                                   geoList.add(region);
                               }
                            else if((pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_PENDING_REVIEW_STATUS) && (pfr.Core_MDF_Approval_Stage__c != oldMap.get(pfr.Id).Core_MDF_Approval_Stage__c) && pfr.Core_MDF_Approver_Source_nm__c == Core_MDF_CCP_ConstantClass.PFR_APP_SOURCE_IUPGM && sendEmailOnce == true && pfr.Core_MDF_Activity_Level_nm__c != Core_MDF_CCP_ConstantClass.PFR_SUB_ACTIVITY) {//Pending Review check needed
                                
                                pendingApprovalPFR.add(pfr);
                                if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM 
                                   && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL){
                                       pfrAccntList.add(pfr.Core_MDF_Campaign_Ultimate_Account_Id__c);
                                   } else {
                                       pfrAccntList.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                                   }
                                pfrProgramList.add(pfr.Core_MDF_Program__c);
                                pfrGeoList.add(region);
                                pfrApprovalStageStatusList.add(pfr.Core_MDF_Approval_Stage__c);
                                pfrBudgetTypeList.add(pfr.Core_MDF_Budget_Type_nm__c);
                            }
                            
                            
                            //notify ext Approvers in RMF when status is pending Approval
                            if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name') 
                               && pfr.Core_MDF_Fund_Request_Status__c != label.Core_MDF_PFR_Status_Closed //is this condition needed?
                               && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm')){                                
                                   pendingApprovalRMFPfrList.add(pfr);
                                   accIdSet.add(pfr.ChannelPartnerId);
                               }
                        }
                        //external mail for planned activity
                        if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
                            if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Planned_Status')){                                
                                plannedPfrList.add(pfr);
                                accIdSet.add(pfr.ChannelPartnerId);
                            }
                        }
                        
                        
                        if(((oldMap != NULL && oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c
                             && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS) 
                            || (oldMap != NULL && oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS 
                                && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS))){
                                    if(pfr.Core_MDF_Member_Acceptor_Id__c != NULL
                                       && pfr.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER){
                                           externalPendingApprovalPfrList.add(pfr); 
                                       }                                                                              
                                }
                        // Activity Status change Notifications to L1 Approver when rejected by POR, PCT & L2 Approver
                        if(pfr.Core_MDF_Approval_Step_Completed__c == 0 && (pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_RR_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_REVISION_REQUIRED_STATUS)&&
                           pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true && pfr.Core_MDF_L1_Approver_Id__c != NULL && pfr.Core_MDF_L1_Approver_Id__c != pfr.CreatedById &&
                           (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name').equals(pfr.Core_MDF_Program__c) ||  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name').equals(pfr.Core_MDF_Program__c) || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name').equals(pfr.Core_MDF_Program__c) || (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA').equals(pfr.Core_MDF_Program__c) && pfr.Core_MDF_Proposal_Based_Ind__c == false)) && pfr.Core_MDF_Activity_Level_nm__c != Core_MDF_CCP_ConstantClass.PFR_SUB_ACTIVITY){                           
                               revReqPfrList.add(pfr);                       
                           }
                        // Activity Status change Notifications to L1 Primary Approver for EEF program,when rejected by POR,PCT,L2 Approver,Primary Partner Customer Acceptance or Activating Partner Customer Acceptance
                        if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name').equals(pfr.Core_MDF_Program__c) && pfr.Core_MDF_Approval_Step_Completed__c == 0 && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_RR_STATUS &&
                           pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true && pfr.Core_MDF_L1_Primary_Approver_Id__c != NULL && pfr.Core_MDF_L1_Primary_Approver_Id__c != pfr.CreatedById){
                               if(!revReqPfrList.contains(pfr)){revReqPfrList.add(pfr); } 
                           }
                        //Send Email on Revision Required and Pending Approval status when Activity is updated by External user
                        // send Email on In-Progress Revision Required  and In-Progress Pending Approval status
                        if(oldMap != NULL && oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c
                           && ((pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM && pfr.Core_MDF_Proposal_Based_Ind__c == false 
                                && (pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_PENDING_APPROVAL_STATUS))
                               || sendRevRqdEmailToExtUser(pfr)) && pfr.Core_MDF_Activity_Level_nm__c != Core_MDF_CCP_ConstantClass.PFR_SUB_ACTIVITY){
                                   
                                   revRqdPfrList.add(pfr);
                               }
                        if(oldMap != NULL && oldMap.get(pfr.Id).Core_MDF_Approval_Stage__c != pfr.Core_MDF_Approval_Stage__c
                           && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_PENDING_APPROVAL_STATUS
                           && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER){
                               pendingApprovalEEFPPfrList.add(pfr);
                               campAccIdSet.add(pfr.Core_MDF_Campaign_Account_Id__c);
                           }
                        //Added a code below to send the email notifacation to Additional Reviewer
                        if((pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.CCF_PROGRAM || pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.DCF_PROGRAM) 
                           && pfr.Core_MDF_Require_Additional_Review_ind__c && (pfr.Core_MDF_Approval_Step_Completed__c == 1 || pfr.Core_MDF_Approval_Step_Completed__c== 2 || pfr.Core_MDF_Approval_Step_Completed__c == 3)){
                               if(pfr.Core_MDF_Additional_Review_Type_txt__c == 'Marketing Review'){
                                   pendingReviewMarketingPfrList.add(pfr);
                               }else if(pfr.Core_MDF_Additional_Review_Type_txt__c == 'Field Review'){
                                   pendingReviewFieldPfrList.add(pfr);
                               }
                               pfrAccntList.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                               pfrProgramList.add(pfr.Core_MDF_Program__c);
                               pfrGeoList.add(region);
                               pfrApprovalStageStatusList.add(pfr.Core_MDF_Approval_Stage__c);
                               pfrBudgetTypeList.add(pfr.Core_MDF_Budget_Type_nm__c);
                           }
                    }
                    
                    
                    for(ProcessInstance processInstanceRec : [Select TargetObjectId,Status from ProcessInstance where TargetObjectId = :pfrInPendingReviewIdSet and Status=: Core_MDF_CCP_ConstantClass.PFR_PENDING_STATUS]){
                        recordsInApprovalProcessIdSet.add(processInstanceRec.TargetObjectId);
                    }
                    
                    for(PartnerFundRequest pfr: pfrInPendingReviewList){
                        String recordTypeName = getRecordTypeDevloperNameById('PartnerFundRequest',pfr.RecordTypeId);//Core_MDF_Service_Provider_CoMarketing_Fund
                        String approvalProcessVersion = getApprovalProcessVersion(pfr,recordTypeName,budgetTypeCCFDCF1_0,budgetTypesList);
                        String region = (String.isNotBlank(pfr.Core_MDF_Host_Region_txt__c)) ? pfr.Core_MDF_Host_Region_txt__c : pfr.Core_MDF_Region_nm__c;
                        String key = pfr.Core_MDF_Program__c + pfr.Core_MDF_Budget_Type_nm__c + pfr.Core_MDF_Region_nm__c + pfr.Core_MDF_Approval_Stage__c;
                        if(!recordsInApprovalProcessIdSet.contains(pfr.Id) && approvalProcessVersion != '' && ((!pfrApprovalSendMap.isEmpty() 
                                                                                                                && pfrApprovalSendMap.containsKey(key) && !pfrApprovalSendMap.get(key)) || ruleEngineResult.isEmpty())){
                                                                                                                    
                                                                                                                    
                                                                                                                    Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                                                                                                                    appObj.setObjectId(pfr.id);
                                                                                                                    appObj.setProcessDefinitionNameOrId(approvalProcessVersion);
                                                                                                                    appObj.setComments('Record submitted for approval');
                                                                                                                    appRequests.add(appObj);  
                                                                                                                }
                    }
                    if (appRequests.size()> 0){
                        Approval.ProcessResult[] result = Approval.process(appRequests);
                    }
                    
                    if(revReqPfrList != NULL && revReqPfrList.Size() > 0 && emailSendOnceL1){
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyInternalApproversOnRejection(revReqPfrList);
                        emailSendOnce = false;
                        emailSendOnceL1=false;
                        sendEmailOnce = false;
                    }
                    
                    
                    
                    //Added a code below to send the email notifacation to Additional Reviewer
                    if(pendingReviewMarketingPfrList != NULL && pendingReviewMarketingPfrList.Size() > 0){                  
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(pendingReviewMarketingPfrList, pfrAccntList, pfrGeoList, pfrProgramList,pfrApprovalStageStatusList,pfrBudgetTypeList);
                        emailSendOnce = false;
                        sendEmailOnce = false;
                    }
                    //Added a code below to send the email notifacation to Additional Reviewer
                    if(pendingReviewFieldPfrList != NULL && pendingReviewFieldPfrList.Size() > 0){                  
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(pendingReviewFieldPfrList, pfrAccntList, pfrGeoList, pfrProgramList,pfrApprovalStageStatusList,pfrBudgetTypeList);
                        emailSendOnce = false;
                        sendEmailOnce = false;
                    }
                    
                    if(pendingApprovalPFR != NULL && pendingApprovalPFR.Size() > 0){                  
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(pendingApprovalPFR, pfrAccntList, pfrGeoList, pfrProgramList,pfrApprovalStageStatusList,pfrBudgetTypeList);
                        emailSendOnce = false;
                        sendEmailOnce = false;
                    }
                    
                    if(pendingPCTApprovalPFR != NULL && pendingPCTApprovalPFR.Size() > 0){                  
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyPCTApprovers(pendingPCTApprovalPFR, accntList, geoList, programList);
                        emailSendOnce = false;
                        sendEmailOnce = false;
                    }  
                    
                    
                    //send email when memeber acceptance is not null
                    if( externalPendingApprovalPfrList != NULL && externalPendingApprovalPfrList.Size() > 0 && emailSendOnce){                 
                        Core_MDF_ProcessCCP_PartnerFundRequest.notifyCCFDCFExternalReviewer(externalPendingApprovalPfrList);
                        emailSendOnce = false;
                    } 
                    if(pendingApprovalEEFPPfrList != NULL && pendingApprovalEEFPPfrList.Size() > 0 
                       && campAccIdSet != NULL && campAccIdSet.Size() > 0 && emailSendOnce){
                           Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pendingApprovalEEFPPfrList, campAccIdSet);
                           emailSendOnce = false;
                       }
                    
                }
                
                //Send RMf Email for Planned Activity                 
                if(plannedEmailSendOnce && plannedPfrList != NULL && plannedPfrList.Size() > 0 && accIdSet != NULL && accIdSet.Size() > 0){
                    Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(plannedPfrList,accIdSet);
                    plannedEmailSendOnce = false;
                }
                //DE115127// notify RMF for pending Approval activity//check emailSendOnce since calling class
                if(emailSendOnce && pendingApprovalRMFPfrList != NULL && pendingApprovalRMFPfrList.Size() > 0 && accIdSet != NULL && accIdSet.Size() > 0){
                    Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pendingApprovalRMFPfrList,accIdSet);
                    emailSendOnce = false;
                }   
                if(pendingGeoApprovalPFR != NULL && pendingGeoApprovalPFR.Size() > 0){
                    
                    Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(pendingGeoApprovalPFR, accntList, geoList, programList,pfrApprovalStageStatusList,pfrBudgetTypeList);
                    emailSendOnce = false;
                    sendEmailOnce = false;
                }
                
                //To call the email notification flow
                if(revRqdPfrList != NULL && revRqdPfrList.Size() > 0 && sendNotificationByFlowOnce){
                    sendNotificationByFlowOnce = false;
                    sendNotificationByFlow(revRqdPfrList);                 
                }
            }
            
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new CustomException(e.getMessage());
            
        }
    }
    /****************************************************************************************************** 
Method Name:        sendRevRqdEmailToExtUser
@return  :          Boolean
@parameters:        PartnerFundRequest
Description:        To Check the condtion for Revision Required/In-Progress Revision Required Email Notification  
Added By:           Saikat          Date:  30/08/2023
Modified By:        Ramapriya       Date:  25/07/2025
*******************************************************************************************************/
    public static Boolean sendRevRqdEmailToExtUser(PartnerFundRequest pfr){
        Boolean isRRSendEmail = false;
        if((pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_RR_STATUS || pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CCP_ConstantClass.PFR_IN_PROGRESS_REVISION_REQUIRED_STATUS) && pfr.Core_MDF_Activity_CreatedByExternalUsr__c 
           && (((pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.MDF_BUDGET_TYPE 
                 || pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.MDFPLUS_BUDGET_TYPE
                 || pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.OEM_CMP_BUDGET_TYPE
                 || pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.SPCMP_BUDGET_TYPE
                 || pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_EEF_PROGRAM)
                && pfr.Core_MDF_Member_Acceptor_Id__c != null)
               || (pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM && pfr.Core_MDF_Proposal_Based_Ind__c == false))){
                   isRRSendEmail = true;
                   
               }
        return isRRSendEmail;
    }
    
    /****************************************************************************************************** 
Method Name:        sendNotificationByFlow
@return  :          void
@parameters:        List<PartnerFundRequest>
Description:        To call the 5 min delayed email notification flow 
Added By:           Saikat 
Date:               31/08/2023
*******************************************************************************************************/
    public static void sendNotificationByFlow(List<PartnerFundRequest> pfrList){
        List<Core_MDF_FlowInputWrapper> inputWrapperList = new List<Core_MDF_FlowInputWrapper>();
        for(PartnerFundRequest pfr: pfrList){
            Core_MDF_FlowInputWrapper inputParams = new Core_MDF_FlowInputWrapper(pfr.Core_MDF_Activity_CreatedByExternalUsr__c,
                                                                                  pfr.CreatedById, pfr.Core_MDF_Member_Acceptor_Id__c, pfr.Id, pfr.Core_MDF_Fund_Request_Status__c,
                                                                                  pfr.Core_MDF_Program__c, pfr.Core_MDF_Proposal_Based_Ind__c);
            inputWrapperList.add(inputParams);
        }
        
        if(inputWrapperList != NULL && inputWrapperList.Size() > 0){
            Flow.Interview.Core_MDF_Send_Email_Notification_in_Pending_Approval_And_Revision_Required sendEmailForRRPAFlow = new Flow.Interview.Core_MDF_Send_Email_Notification_in_Pending_Approval_And_Revision_Required(new Map<String, Object>{'inputWrapperList' => inputWrapperList});
            sendEmailForRRPAFlow.start();
        }
    }
    
    public static void setAllApprovers(PartnerFundRequest pfr){
        pfr.Core_MDF_Approver_2__c = pfr.Core_MDF_Approver_1__c;
        pfr.Core_MDF_Approver_3__c = pfr.Core_MDF_Approver_1__c;
        pfr.Core_MDF_Approver_4__c = pfr.Core_MDF_Approver_1__c;
        pfr.Core_MDF_Approver_5__c = pfr.Core_MDF_Approver_1__c;
        pfr.Core_MDF_Approver_6__c = pfr.Core_MDF_Approver_1__c;
        pfr.Core_MDF_Approver_7__c = pfr.Core_MDF_Approver_1__c;
        pfr.Core_MDF_Approver_8__c = pfr.Core_MDF_Approver_1__c;
        pfr.Core_MDF_Approver_9__c = pfr.Core_MDF_Approver_1__c;
        pfr.Core_MDF_Approver_10__c = pfr.Core_MDF_Approver_1__c;
    }
    
    public static void clearAllApprovers(PartnerFundRequest pfr){
        pfr.Core_MDF_Approver_1__c = null;
        pfr.Core_MDF_Approver_2__c = null;
        pfr.Core_MDF_Approver_3__c = null;
        pfr.Core_MDF_Approver_4__c = null;
        pfr.Core_MDF_Approver_5__c = null;
        pfr.Core_MDF_Approver_6__c = null;
        pfr.Core_MDF_Approver_7__c = null;
        pfr.Core_MDF_Approver_8__c = null;
        pfr.Core_MDF_Approver_9__c = null;
        pfr.Core_MDF_Approver_10__c = null;
    }
    
    
    
    
    
    
    /*****************************************************************************************************************************************
Method Name:                                             recallApprovalProcess
@return  :                                               return boolean
@parameters:                                             PFR List to be recalled , pfr Old Map
Description:                                             To recall activities from approval process when closed or cancelled.
Modifies :                                               1.Added code to recall the Approval Process when Activity is closed.
2.Added Recall PlatformEvent for cancelled, to bypass recall access issue.
**************************************************************************************************************************************************/
    
    public static boolean recallApprovalActivities(List<PartnerFundRequest> pfrList, Map<Id,PartnerFundRequest> oldPfrMap)
    {
        String logEntryMsg = '';
        list<Id> recallPFRId = new list<Id>();
        list<ProcessInstanceWorkitem>  piList = new list<ProcessInstanceWorkitem>();        
        boolean res = false;
        List<Id> pfrsToBeSubmittedForATFApproval = new List<Id>();
        List<Core_MDF_Recall_Approval__e> eventList = new List<Core_MDF_Recall_Approval__e>();
        
        try
        { 
            for(PartnerFundRequest pfr: pfrList)
            {     
                if(oldPfrMap.containsKey(pfr.Id) && oldPfrMap.get(pfr.Id) != NULL){          
                    if(pfr.Core_MDF_Fund_Request_Status__c == 'Closed' && pfr.Core_MDF_Activity_Closure_Type__c != 'No Internal Approval'){
                        recallPFRId.add(pfr.Id);  
                    } 
                    else if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status')){
                        eventList.add(createRecallApprovalPEInstance(pfr));
                    }    
                }
                
            } 
            //Publish Event to recall ProcessWorkItem in Pending status
            if(!eventList.isEmpty()){
                List<Database.SaveResult> results = EventBus.publish(eventList);
            }
            
            //Check the size of recallPFRId , remove the Activities from Approval Queue
            if(recallPFRId.size()>0){
                List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();                         
                for(ProcessInstanceWorkitem PIns: [SELECT Id,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem  WHERE ProcessInstance.TargetObjectId IN :recallPFRId AND ProcessInstance.Status = 'Pending']){
                    Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                    pwr.setAction('Removed');
                    pwr.setWorkItemId(PIns.id);
                    pwrList.add(pwr);   
                }
                
                Integer index = 0;
                List<Approval.ProcessResult> resultList = Approval.process(pwrList);
                for(Approval.ProcessResult result : resultList){
                    if(result.isSuccess()){res = true;
                                          }
                    else{
                        logEntryMsg = 'Approval Error: '+pwrList[index]; 
                        Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Recal_Exception_Origin'));
                    }
                    index++;
                }  
            }  
        }
        catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
                            Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Label.Core_MDF_Activity_Recall_Exception_Origin);         
                           }         
        return res;
    }
    
    
    /*************************************************************************************
Description: Method to create Platform Event instance for approver recall
@Param      : PFR
@return     : PlatformEvent Instance
**************************************************************************************/
    public static Core_MDF_Recall_Approval__e createRecallApprovalPEInstance(PartnerFundRequest pfr){
        Core_MDF_Recall_Approval__e eventObj =  new Core_MDF_Recall_Approval__e();
        eventObj.Core_MDF_Target_Object_Id__c = pfr.Id;
        eventObj.Core_MDF_Request_Status_nm__c = pfr.Core_MDF_Fund_Request_Status__c;
        return eventObj;
    }
    
    /*****************************************************************************************************
Method Name :   getApproversFromIUPGM
@return     :   Map<String, list<String>> resultMap
@parameters :   accntIdSet,programSet,geoStrSet,budgetTypeSet
Description :   determines and stamps the approvers from IUPGM
Added By    :   
US          :   
Modified By :                      Date:                    Changes:None
******************************************************************************************************/  
    public static Map<String, list<String>> getApproversFromIUPGM(Set<String> accntIdSet, Set<string> programSet, Set<string> geoStrSet, Set<String> budgetTypeSet){
        
        Map<String, list<String>> resultMap = new Map<String, list<String>>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Map<string, List<string>> subMap = new Map<string, List<string>>();
        List<String> geoList = new List<String>(geoStrSet);
        List<String> budgetTypeList = new List<String>(budgetTypeSet);
        String qryStr;
        String geoStr= '';
        String budgetStr = '';
        List<string> accountManagerPermissionSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Account_Mgr_Permission_Sets').split(',');
        
        
        geoList.add('WW');
        
        if(!geoList.isEmpty()){
            geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
        }  
        if(String.isNotBlank(geoStr)){
            geoStr = String.escapeSingleQuotes(geoStr);
            geoStr = geoStr.replaceAll('\\\\','');
        }
        if(budgetTypeList != null && !budgetTypeList.isEmpty()){
            budgetStr ='(\'' + String.join(budgetTypeList, '\', \'') + '\')';
        }  
        if(String.isNotBlank(budgetStr)){
            budgetStr = String.escapeSingleQuotes(budgetStr);
            budgetStr = budgetStr.replaceAll('\\\\','');
        }
        
        qryStr = 'SELECT Id, Core_MDF_User_id__c,Core_MDF_Region_cd__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c, '+
            ' Core_MDF_Channel_Program_id__r.Name, Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, Core_MDF_Budget_Type_nm__c,' +
            ' Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c, Core_MDF_All_Budget_Type_Access_Ind__c' +
            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
            ' WHERE Core_MDF_Channel_Program_id__r.Name IN: programSet' +
            ' and Core_MDF_Region_cd__c INCLUDES ' + geoStr  +
            ' and Core_MDF_Role_nm__c IN: accountManagerPermissionSet'+
            ' and Core_MDF_is_User_Active_ind__c = true'+
            ' and Core_MDF_Active_Ind__c = true'+
            ' and Core_MDF_Is_Not_an_Approver_Ind__c = false ';
        
        
        
        try{
            if(String.isNotBlank(qryStr)){
                iupgmList = Database.Query(qryStr);
            }
            
            
            if(!iupgmList.isEmpty()){
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmObj : iupgmList){
                    List<string> geoBudgetTypeList = new List<string> ();
                    if(iupgmObj.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                        for(String geoBudgetTypeStr : iupgmObj.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){
                            String geo = geoBudgetTypeStr.split('->')[0] ;                             
                            String budtype = geoBudgetTypeStr.split('->')[1] ;
                            if(geo == 'ASMO-LAR' || geo == 'ASMO-NAR' || geo == 'ASMO'){
                                geo = 'ASMO';
                            }
                            geoBudgetTypeList.add(geo + budtype);
                        }
                    }
                    else if(iupgmObj.Core_MDF_Region_cd__c != NULL){
                        for(String geo:iupgmObj.Core_MDF_Region_cd__c.split(';')){
                            geoBudgetTypeList.add(geo);
                        }
                    }
                    
                    
                    for(String geo: geoBudgetTypeList){
                        if(iupgmObj.Core_MDF_All_Accounts_cd__c == 'NO' && accntIdSet.contains(iupgmObj.Core_MDF_Account_id__c)){  
                            String mapKey = iupgmObj.Core_MDF_Channel_Program_id__r.Name + geo + iupgmObj.Core_MDF_Account_id__c;                   
                            if(resultMap.containsKey(mapKey)){
                                resultMap.get(mapKey).add(iupgmObj.Core_MDF_User_id__c);
                            } else {
                                resultMap.put(mapKey, new List<string>{iupgmObj.Core_MDF_User_id__c});
                            }
                        }
                    }
                }
            }
            
        }
        catch(exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return resultMap;
    }    
    /*****************************************************************************************************
Method Name :   getApprovalProcessVersion
@return     :   String
@parameters :   pfr, recordTypeName, budgetTypeCCFDCF1_0, budgetTypesList
Description :   to get the approval process version
Added By    :   Saikat Manna
Modified By :                      Date:20/12/2022                    
******************************************************************************************************/ 
    public static String getApprovalProcessVersion(PartnerFundRequest pfr, String recordTypeName, List<String> budgetTypeCCFDCF1_0, List<String> budgetTypesList){
        String approvalProcessVersion = '';
        if(recordTypeName == Core_MDF_CCP_ConstantClass.PFR_RMF_RECORDTYPE){
            //Core_MDF_Retail_Program_Name
            approvalProcessVersion  = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_Approval_Process');
        }else if(recordTypeName == Core_MDF_CCP_ConstantClass.PFR_IPA_RECORDTYPE && pfr.Core_MDF_Proposal_Based_Ind__c == false){
            approvalProcessVersion = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Approval_Process');
        }else if(budgetTypesList.contains(pfr.Core_MDF_Budget_Type_nm__c) ){//MDF;MDF+;Service Provider CMP;OEM CMP  
            approvalProcessVersion = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Approval_Process');
        }else if(recordTypeName == Core_MDF_CCP_ConstantClass.PFR_EEF_RECORDTYPE){
            //Core_MDF_EEF_Program_Name
            approvalProcessVersion  = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Approval_Process');
        }
        return approvalProcessVersion;
    }
    /*****************************************************************************************************
Method Name :   populateBUSplit
@return     :   N/A
@parameters :   pfr, oldPfrMap
Description :   to get revenue segment of activity
Added By    :   Bishanka Dassarma
Modified By :   Date:7/02/2023                    
******************************************************************************************************/ 
    /*public static void populateBUSplit(PartnerFundRequest pfr, Map<Id,PartnerFundRequest> oldPfrMap,Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> brandFAProductTypeMap,Map<String,Decimal> buPriorityMap)
{
pfr.Core_MDF_BU_Split__c = '';
if(String.isNotBlank(pfr.Core_MDF_Brand_nm__c))
{
List<String> pfrBrandList = pfr.Core_MDF_Brand_nm__c.split(';');

if(pfrBrandList.size()==1)
{
String faPTBrandKey = pfr.Core_MDF_Focus_Area_nm__c+'_'+pfr.Core_MDF_ProductType__c+'_'+pfr.Core_MDF_Brand_nm__c;

if(brandFAProductTypeMap.containsKey(faPTBrandKey))
{
List<Core_MDF_CCP_Custom_Metadata_Utility__c> buRecList = brandFAProductTypeMap.get(faPTBrandKey);

for(Core_MDF_CCP_Custom_Metadata_Utility__c buRec : buRecList)
{
if(buRec.Core_MDF_Date_1_dt__c<=pfr.Core_MDF_Start_Date__c && buRec.Core_MDF_Date_2_dt__c>=pfr.Core_MDF_Start_Date__c)
{
pfr.Core_MDF_BU_Split__c = buRec.Core_MDF_Field_5_txt__c;
pfr.Core_MDF_BU1_Split_Percent_nbr__c= 100;
pfr.Core_MDF_BU2_Split_Percent_nbr__c= 0;
pfr.Core_MDF_BU3_Split_Percent_nbr__c= 0;
pfr.Core_MDF_BU4_Split_Percent_nbr__c= 0;
pfr.Core_MDF_BU5_Split_Percent_nbr__c= 0;
}
}
}
}
else if(pfrBrandList.size()>1)
{
Set<String> buSet = new Set<String>();
List<Core_MDF_CCP_Custom_Metadata_Utility__c> buRecList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
for(String brand : pfrBrandList)
{
String faPTBrandKey = pfr.Core_MDF_Focus_Area_nm__c+'_'+pfr.Core_MDF_ProductType__c+'_'+brand;
if(brandFAProductTypeMap.containsKey(faPTBrandKey))
{
buRecList.addAll(brandFAProductTypeMap.get(faPTBrandKey));
}
}

if(!buRecList.isEmpty())
{
for(Core_MDF_CCP_Custom_Metadata_Utility__c buRec : buRecList)
{
if(buRec.Core_MDF_Date_1_dt__c<=pfr.Core_MDF_Start_Date__c && buRec.Core_MDF_Date_2_dt__c>=pfr.Core_MDF_Start_Date__c)
{
buSet.add(buRec.Core_MDF_Field_5_txt__c);
}
}


Decimal sortingCounter = Decimal.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BU_SortingValue'));
String pfrBu;
for(String businessUnit : buSet)
{
if(buPriorityMap.get(businessUnit)<sortingCounter)
{
sortingCounter = buPriorityMap.get(businessUnit);
pfrBu = businessUnit;
}

}
pfr.Core_MDF_BU_Split__c = pfrBu;
pfr.Core_MDF_BU1_Split_Percent_nbr__c= 100;
pfr.Core_MDF_BU2_Split_Percent_nbr__c= 0;
pfr.Core_MDF_BU3_Split_Percent_nbr__c= 0;
pfr.Core_MDF_BU4_Split_Percent_nbr__c= 0;
pfr.Core_MDF_BU5_Split_Percent_nbr__c= 0;
}
}


}
}*/
    public static void populateBUSplit(PartnerFundRequest pfr, 
                                       Map<Id,PartnerFundRequest> oldPfrMap,
                                       Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> brandFAProductTypeMap,
                                       Map<String,Decimal> buPriorityMap)
    {
        pfr.Core_MDF_BU_Split__c = '';
        
        if(String.isNotBlank(pfr.Core_MDF_Brand_nm__c) && 
           String.isNotBlank(pfr.Core_MDF_ProductType__c))
        {
            List<String> pfrBrandList = pfr.Core_MDF_Brand_nm__c.split(';');
            List<String> productTypeList = pfr.Core_MDF_ProductType__c.split(';');
            // CASE A: Brand = 1 AND Product = 1
            if(pfrBrandList.size() == 1 && productTypeList.size() == 1)
            {
                String faPTBrandKey = pfr.Core_MDF_Focus_Area_nm__c + '_' +
                    productTypeList[0] + '_' +
                    pfrBrandList[0];
                
                if(brandFAProductTypeMap.containsKey(faPTBrandKey))
                {
                    List<Core_MDF_CCP_Custom_Metadata_Utility__c> buRecList =
                        brandFAProductTypeMap.get(faPTBrandKey);
                    
                    for(Core_MDF_CCP_Custom_Metadata_Utility__c buRec : buRecList)
                    {
                        if(buRec.Core_MDF_Date_1_dt__c <= pfr.Core_MDF_Start_Date__c &&
                           buRec.Core_MDF_Date_2_dt__c >= pfr.Core_MDF_Start_Date__c)
                        {
                            pfr.Core_MDF_BU_Split__c = buRec.Core_MDF_Field_5_txt__c;
                            pfr.Core_MDF_BU1_Split_Percent_nbr__c = 100;
                            pfr.Core_MDF_BU2_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU3_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU4_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU5_Split_Percent_nbr__c = 0;
                            break;
                        }
                    }
                }
            }
            
            // CASE B: Brand >1 AND Product = 1
            else if(pfrBrandList.size() > 1 && productTypeList.size() == 1)
            {
                Set<String> buSet = new Set<String>();
                List<Core_MDF_CCP_Custom_Metadata_Utility__c> buRecList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
                
                for(String brand : pfrBrandList)
                {
                    String faPTBrandKey = pfr.Core_MDF_Focus_Area_nm__c + '_' +
                        productTypeList[0] + '_' +
                        brand;
                    
                    if(brandFAProductTypeMap.containsKey(faPTBrandKey))
                    {
                        buRecList.addAll(brandFAProductTypeMap.get(faPTBrandKey));
                    }
                }
                
                if(!buRecList.isEmpty())
                {
                    for(Core_MDF_CCP_Custom_Metadata_Utility__c buRec : buRecList)
                    {
                        if(buRec.Core_MDF_Date_1_dt__c <= pfr.Core_MDF_Start_Date__c &&
                           buRec.Core_MDF_Date_2_dt__c >= pfr.Core_MDF_Start_Date__c)
                        {
                            buSet.add(buRec.Core_MDF_Field_5_txt__c);
                        }
                    }
                    if(!buSet.isEmpty())
                    {
                        Decimal sortingCounter =
                            Decimal.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BU_SortingValue'));
                        String pfrBu;
                        
                        for(String businessUnit : buSet)
                        {
                            if(buPriorityMap.containsKey(businessUnit) && buPriorityMap.get(businessUnit) < sortingCounter)
                            {
                                sortingCounter = buPriorityMap.get(businessUnit);
                                pfrBu = businessUnit;
                            }
                        }
                        
                        if(pfrBu != null)
                        {
                            pfr.Core_MDF_BU_Split__c = pfrBu;
                            pfr.Core_MDF_BU1_Split_Percent_nbr__c = 100;
                            pfr.Core_MDF_BU2_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU3_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU4_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU5_Split_Percent_nbr__c = 0;
                        }
                    }
                }
            }
            
            // CASE C: Brand = 1 AND Product >1 (NO CHANGE)
            else if(pfrBrandList.size() == 1 && productTypeList.size() > 1)
            {
                Set<String> buSet = new Set<String>();
                List<Core_MDF_CCP_Custom_Metadata_Utility__c> buRecList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
                
                for(String prodType : productTypeList)
                {
                    String faPTBrandKey = pfr.Core_MDF_Focus_Area_nm__c + '_' +
                        prodType + '_' +
                        pfrBrandList[0].trim();
                    
                    if(brandFAProductTypeMap.containsKey(faPTBrandKey))
                    {
                        buRecList.addAll(brandFAProductTypeMap.get(faPTBrandKey));
                    }
                }
                
                if(!buRecList.isEmpty())
                {
                    for(Core_MDF_CCP_Custom_Metadata_Utility__c buRec : buRecList)
                    {
                        if(buRec.Core_MDF_Date_1_dt__c <= pfr.Core_MDF_Start_Date__c &&
                           buRec.Core_MDF_Date_2_dt__c >= pfr.Core_MDF_Start_Date__c)
                        {
                            buSet.add(buRec.Core_MDF_Field_5_txt__c);
                        }
                    }
                    if(!buSet.isEmpty())
                    {
                        Decimal sortingCounter =
                            Decimal.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BU_SortingValue'));
                        String pfrBu;
                        
                        for(String businessUnit : buSet)
                        {
                            if(buPriorityMap.containsKey(businessUnit) && buPriorityMap.get(businessUnit) < sortingCounter)
                            {
                                sortingCounter = buPriorityMap.get(businessUnit);
                                pfrBu = businessUnit;
                            }
                        }
                        
                        if(pfrBu != null)
                        {
                            pfr.Core_MDF_BU_Split__c = pfrBu;
                            pfr.Core_MDF_BU1_Split_Percent_nbr__c = 100;
                            pfr.Core_MDF_BU2_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU3_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU4_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU5_Split_Percent_nbr__c = 0;
                        }
                        
                    }
                }
            }
            
            // CASE D: Brand >1 AND Product >1 (NO CHANGE)
            else if(pfrBrandList.size() > 1 && productTypeList.size() > 1)
            {
                Set<String> buSet = new Set<String>();
                List<Core_MDF_CCP_Custom_Metadata_Utility__c> buRecList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
                
                for(String brand : pfrBrandList)
                {
                    for(String prodType : productTypeList)
                    {
                        String faPTBrandKey = pfr.Core_MDF_Focus_Area_nm__c + '_' +
                            prodType + '_' +
                            brand;
                        
                        if(brandFAProductTypeMap.containsKey(faPTBrandKey))
                        {
                            buRecList.addAll(brandFAProductTypeMap.get(faPTBrandKey));
                        }
                    }
                }
                
                if(!buRecList.isEmpty())
                {
                    for(Core_MDF_CCP_Custom_Metadata_Utility__c buRec : buRecList)
                    {
                        if(buRec.Core_MDF_Date_1_dt__c <= pfr.Core_MDF_Start_Date__c &&
                           buRec.Core_MDF_Date_2_dt__c >= pfr.Core_MDF_Start_Date__c)
                        {
                            buSet.add(buRec.Core_MDF_Field_5_txt__c);
                        }
                    }
                    if(!buSet.isEmpty())
                    {
                        Decimal sortingCounter =
                            Decimal.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BU_SortingValue'));
                        String pfrBu;
                        
                        for(String businessUnit : buSet)
                        {
                            if(buPriorityMap.containsKey(businessUnit) && buPriorityMap.get(businessUnit) < sortingCounter)
                            {
                                sortingCounter = buPriorityMap.get(businessUnit);
                                pfrBu = businessUnit;
                            }
                        }
                        
                        if(pfrBu != null)
                        {
                            pfr.Core_MDF_BU_Split__c = pfrBu;
                            pfr.Core_MDF_BU1_Split_Percent_nbr__c = 100;
                            pfr.Core_MDF_BU2_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU3_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU4_Split_Percent_nbr__c = 0;
                            pfr.Core_MDF_BU5_Split_Percent_nbr__c = 0;
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    
    /*****************************************************************************************************
Method Name :   isEligibleForBUSplit
@return     :   Boolean
@parameters :   pfr, oldPfrMap
Description :   to decide whether BUSplit is required or not
Added By    :   Bishanka Dassarma
Modified By :   Date:7/02/2023                    
******************************************************************************************************/ 
    public static Boolean isEligibleForBUSplit(PartnerFundRequest pfr,Map<Id,PartnerFundRequest> oldPfrMap)
    {
        List<String> buEligibleProgramList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BUSplit_Program_Types').Split(';');
        if(buEligibleProgramList.contains(pfr.Core_MDF_Program__c) && !Core_MDF_Utility.byPassFeature('Bypass_PopulateBUSplit') && 
           (oldPfrMap == NULL ||(oldPfrMap!= NULL && (pfr.Core_MDF_Focus_Area_nm__c!=oldPfrMap.get(pfr.id).Core_MDF_Focus_Area_nm__c || 
                                                      pfr.Core_MDF_ProductType__c!=oldPfrMap.get(pfr.id).Core_MDF_ProductType__c || 
                                                      pfr.Core_MDF_Brand_nm__c!=oldPfrMap.get(pfr.id).Core_MDF_Brand_nm__c ||
                                                      pfr.Core_MDF_Start_Date__c!=oldPfrMap.get(pfr.id).Core_MDF_Start_Date__c ))))
        {
            return true;
        }
        return false;
    }
    
    /*****************************************************************************************************
Method Name :   recalculateSpendingLimit
@return     :   Void
@parameters :   pfr, oldPfrMap
Description :   To update pfr spending limit field
Added By    :   Ayush Raj
Modified By :   Date:19/07/2023                    
******************************************************************************************************/    
    public static void recalculateSpendingLimit(PartnerFundRequest pfr, Map<Id,PartnerFundRequest> oldPfrMap){
        if((oldPfrMap == null) || (oldPfrMap != null 
                                   && (oldPfrMap.get(pfr.Id).Core_MDF_Budget_Amount_Local_amt__c != pfr.Core_MDF_Budget_Amount_Local_amt__c
                                       || oldPfrMap.get(pfr.Id).Core_MDF_Budget_Currency_cd__c != pfr.Core_MDF_Budget_Currency_cd__c))){
                                           pfr.RequestedAmount = (pfr.Core_MDF_Budget_Amount_Local_amt__c * pfr.Core_MDF_Exchange_Rate_ptc__c).setScale(2,RoundingMode.HALF_UP);
                                       }
    }    
    
    /*****************************************************************************************************
Method Name :   autoBudgetTransferonPFRApproval
@parameters :   pfrList,oldPFRMap
Description :   To Ensure Required Amount is there at Allocation node when Activity is created/approved/edited by Primary Account Manager for EEF program
Added By    :   Keerthi
Modified By :                 Date:22/02/2024               
******************************************************************************************************/ 
    public static Map<Id,Decimal> primaryAccIdToActAvailableAmt = new Map<Id,Decimal>();
    public static void activityAutoBudgetTransferForward(List<PartnerFundRequest> newPfrList , Map<Id,PartnerFundRequest> oldPFRMap ,Boolean isbefore ,Boolean isAfter) {
        
        Set<Id> accountIds = new Set<Id>();
        List<PartnerFundRequest> pfrToEvaluate = new List<PartnerFundRequest>();
        Set<Id> budgetIds = new Set<Id>();
        Map<string,Decimal> accIdBudIdToIntelConMap = new Map<string,Decimal>();
        Map<string,decimal> activatingAccIdBudIdToAllocAvailAmtMap = new Map<string,decimal>();
        Map<Id,PartnerMarketingBudget> pmbIdToPmbMap = new Map<Id,PartnerMarketingBudget>();
        try{
            for(PartnerFundRequest pfr:newPfrList){
                if((isAfter && isEEFActivityAutoBdgtFwdTransferReqAfterCon(pfr,oldPFRMap) ) || (isBefore && isEEFActivityAutoBdgtFwdTransferReqBeforeCon(pfr,oldPFRMap))){
                    budgetIds.add(pfr.BudgetId);
                    accountIds.add(pfr.ChannelPartnerId);
                    pfrToEvaluate.add(pfr);
                    Decimal IntelConToConsider = getIntelContributionToValidate(pfr,oldPFRMap);
                    string accIdBudgetIdKey = (string)pfr.ChannelPartnerId + (string)pfr.BudgetId;
                    Decimal intelContribution = oldPFRMap!=null ? IntelConToConsider : 
                    ((pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_txt__c.removeEnd('%')))/100).setScale(2,RoundingMode.HALF_UP);
                    
                    //creating Map for incoming PFR's AccountId ,BudgetId To Intel Contribution
                    if(accIdBudIdToIntelConMap.containsKey(accIdBudgetIdKey)){
                        decimal totalAmt = accIdBudIdToIntelConMap.get(accIdBudgetIdKey) + intelContribution;
                        accIdBudIdToIntelConMap.put(accIdBudgetIdKey,totalAmt);
                    }else{
                        accIdBudIdToIntelConMap.put(accIdBudgetIdKey,intelContribution);
                    }
                    
                }
                
            }
            //limits check
        
        // ✅ FIX: Use Map Constructor instead of manual FOR loop + put()
        List<PartnerMarketingBudget> pmbList = [SELECT id, Core_MDF_Budget_Partner__c 
                                                 FROM PartnerMarketingBudget 
                                                 WHERE id IN: budgetIds];
        
        // ✅ Map built using constructor - resolves the PMD issue
        pmbIdToPmbMap = new Map<Id, PartnerMarketingBudget>(pmbList);
        
        // ✅ Separate loop ONLY for accountIds - single responsibility
        for(PartnerMarketingBudget pmb : pmbList) {
            accountIds.add(pmb.Core_MDF_Budget_Partner__c);
        }
            
            getActAvailAmountOnAllocationForPfr(budgetIds , accountIds ,pfrToEvaluate ,accIdBudIdToIntelConMap,pmbIdToPmbMap,oldPFRMap,isbefore);
            
            
        } Catch(Exception Ex) {
            
            
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw Ex;
        }
        
    }
    /*****************************************************************************************************
Method Name :   getActAvailAmountOnAllocationForPfr
@parameters :   pfrList,oldPFRMap
Description :   To get Activity Available Amount on allocation for Pfr's Account and Primary Account
Added By    :   Keerthi
Modified By :                 Date:10/03/2024               
******************************************************************************************************/
    Public static void getActAvailAmountOnAllocationForPfr(Set<Id> budgetIds ,Set<Id> accountIds,List<PartnerFundRequest> pfrToEvaluate,Map<string,Decimal> accIdBudIdToIntelConMap,Map<Id,PartnerMarketingBudget> pmbIdToPmbMap , Map<Id,PartnerFundRequest> oldPFRMap,Boolean isbefore){
        Map<string,decimal> activatingAccIdBudIdToAllocAvailAmtMap = new Map<string,decimal>();
        
        if(!budgetIds.isEmpty() && !accountIds.isEmpty() && !pfrToEvaluate.isEmpty()) {
            
            //make sure allocation is present on PFR , if it's not there - hardstop for approval
            for(PartnerFundAllocation pfa : [SELECT Id,Amount,Core_MDF_Total_Activity_Allocated_Amount__c,ChannelPartnerId,BudgetId,Core_MDF_Available_Activity_Alloc_Amt__c
                                             FROM PartnerFundAllocation
                                             WHERE ChannelPartnerId IN: accountIds AND BudgetId IN: budgetIds]){
                                                 string accIdBudgetIdKey = (string)pfa.ChannelPartnerId + (string)pfa.BudgetId;
                                                 
                                                 if(accIdBudIdToIntelConMap.containsKey(accIdBudgetIdKey)){
                                                     //To get activity Avail Amt on Allocation before incoming PFR's intel Contribution is considered into Reserved amt
                                                     Decimal actAvailAmtOnAlloc =  (isBefore ==  true) ? (pfa.Amount - pfa.Core_MDF_Total_Activity_Allocated_Amount__c) : (pfa.Amount - pfa.Core_MDF_Total_Activity_Allocated_Amount__c) + accIdBudIdToIntelConMap.get(accIdBudgetIdKey);
                                                     
                                                     Decimal actualActAvailAmt =  actAvailAmtOnAlloc < 0 ? 0 :actAvailAmtOnAlloc ;
                                                     activatingAccIdBudIdToAllocAvailAmtMap.put(accIdBudgetIdKey,actualActAvailAmt);
                                                     
                                                 }else{
                                                     //Mapping Primary Account's allocation's Activity Available amount
                                                     primaryAccIdToActAvailableAmt.put(pfa.ChannelPartnerId,(pfa.Amount - pfa.Core_MDF_Total_Activity_Allocated_Amount__c));
                                                     
                                                 }
                                             }
            
            enableAutoBudgetTransfer(pfrToEvaluate,oldPFRMap,activatingAccIdBudIdToAllocAvailAmtMap,primaryAccIdToActAvailableAmt,pmbIdToPmbMap,isbefore);
        } 
        
        
        
    }
    /*****************************************************************************************************
Method Name :   enableAutoBudgetTransfer
@parameters :   pfrList,oldPFRMap
Description :   To Validate whether Auto Budget Transfer is required ot not
Added By    :   Keerthi
Modified By :                 Date:10/03/2024               
******************************************************************************************************/
    
    public static void enableAutoBudgetTransfer(List<PartnerFundRequest> pfrToEvaluate ,  Map<Id,PartnerFundRequest> oldPFRMap,Map<string,Decimal> activatingAccIdBudIdToAllocAvailAmtMap,Map<Id,Decimal> primaryAccIdToActAvailableAmt,Map<Id,PartnerMarketingBudget> pmbIdToPmbMap, Boolean isbefore) {
        Map<Id,Decimal> pfrIdToAmtToTransfer = new Map<Id,Decimal>();
        List<Core_MDF_BudgetTransferWrapper> budgetTransferWrapperList = new List<Core_MDF_BudgetTransferWrapper>();
        Map<Id,BudgetTranferLogWrapper> pfrIdToBudTransferWrapperMap = new Map<Id,BudgetTranferLogWrapper>();
        
        Set<Id> pfrIdsSet = new Set<Id>();
        //pfrIdsSet.addAll(pfrToEvaluate);
        for(PartnerFundRequest pfr : pfrToEvaluate){
            pfrIdsSet.add(pfr.Id);
        }
        pfrIdToBudTransferWrapperMap=getBudgetTransferHistory(pfrIdsSet);
        
        for(PartnerFundRequest pfr : pfrToEvaluate) {
            Decimal IntelConToConsider = getIntelContributionToValidate(pfr,oldPFRMap);
            Decimal intCon = oldPFRMap!=null ? IntelConToConsider : 
            ((pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_txt__c.removeEnd('%')))/100).setScale(2,RoundingMode.HALF_UP);
            Decimal amountToTransfer = 0;
            Decimal differenceInAmount = 0;
            string accIdBudgetIdKey = (string)pfr.ChannelPartnerId + (string)pfr.BudgetId;
            
            
            if(!activatingAccIdBudIdToAllocAvailAmtMap.isEmpty() && activatingAccIdBudIdToAllocAvailAmtMap.containsKey(accIdBudgetIdKey) && activatingAccIdBudIdToAllocAvailAmtMap.get(accIdBudgetIdKey) != NULL && activatingAccIdBudIdToAllocAvailAmtMap.get(accIdBudgetIdKey) >=0) {
                //If Activity Avail Amt on pfr Allocation is less than incoming PFR's Intel Contrubition
                
                if(activatingAccIdBudIdToAllocAvailAmtMap.get(accIdBudgetIdKey) < intCon) {
                    
                    if(pfrIdToBudTransferWrapperMap!=null && pfrIdToBudTransferWrapperMap.containskey(pfr.id) && pfrIdToBudTransferWrapperMap.get(pfr.id)!= Null ) {
                        
                        differenceInAmount = pfrIdToBudTransferWrapperMap.get(pfr.id).sumOfForwardTransferredAmt - pfrIdToBudTransferWrapperMap.get(pfr.id).sumOfReverseTransferredAmt;
                        amountToTransfer = intCon - differenceInAmount; //zero
                        
                    }
                    else{
                        //If Activity Avail Amt on pfr Allocation is Zero , Considering PFR's IC as the amount to transfer
                        if(activatingAccIdBudIdToAllocAvailAmtMap.get(accIdBudgetIdKey) == 0) {
                            amountToTransfer = intCon;
                        } else { //partial amt transfer
                            if(activatingAccIdBudIdToAllocAvailAmtMap.get(accIdBudgetIdKey) > 0 ) {
                                amountToTransfer = intCon - activatingAccIdBudIdToAllocAvailAmtMap.get(accIdBudgetIdKey);
                                activatingAccIdBudIdToAllocAvailAmtMap.put(accIdBudgetIdKey,0);
                            }
                        }
                    }
                    if(pfr.Id != null){
                        pfrIdToAmtToTransfer.put(pfr.Id,amountToTransfer);
                    }
                    
                    if(isbefore){
                        validateAvailAmtAtPrimaryAccount(pfr,primaryAccIdToActAvailableAmt,amountToTransfer,pmbIdToPmbMap);
                    }else{
                        budgetTransferWrapperList.addAll(autoBudgetTranfer(pfr,primaryAccIdToActAvailableAmt,pfrIdToAmtToTransfer,pmbIdToPmbMap));
                    }
                }
                else {
                    Decimal amountAfterConsumed = activatingAccIdBudIdToAllocAvailAmtMap.get(accIdBudgetIdKey) - intCon;
                    activatingAccIdBudIdToAllocAvailAmtMap.put(accIdBudgetIdKey,amountAfterConsumed);
                    if(pfr.status !='Approved' && isbefore){
                        pfr.status ='Approved' ;
                    }
                    
                }
                
            }
        }
        
        if(!budgetTransferWrapperList.isEmpty() && budgetTransferWrapperList.size()>0) {
            String result = Core_MDF_BudgetTransferUtility.budgetTransfer(budgetTransferWrapperList);
            
        }
    }
    /*****************************************************************************************************
Method Name :   getIntelContributionToValidate
@parameters :   pfrList,oldPFRMap
Description :   To get the Intel Contribution or difference of intel contribution if there's any change
Added By    :   Keerthi
Modified By :                 Date:10/03/2024               
******************************************************************************************************/
    public static Decimal getIntelContributionToValidate (PartnerFundRequest pfr, Map<Id,PartnerFundRequest> oldPFRMap){
        Decimal IntelConToConsider = 0 ;
        
        IntelConToConsider = pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c ;
        
        return IntelConToConsider ;
    }
    /*****************************************************************************************************
Method Name :   autoBudgetTranfer
@parameters :   pfrList,oldPFRMap
Description :   Prepare wrapper for Auto Budget Transfer
Added By    :   Keerthi
Modified By :                 Date:10/03/2024               
******************************************************************************************************/
    
    public static List<Core_MDF_BudgetTransferWrapper> autoBudgetTranfer(PartnerFundRequest pfr, Map<Id,Decimal> primaryAccIdToActAvailableAmt,Map<Id,Decimal> pfrIdToAmtToTransfer,Map<Id,PartnerMarketingBudget> pmbIdToPmbMap){      
        String AUTO_ACTIVITY_TRANSFER_TYPE = Core_MDF_CCP_ConstantClass.AUTO_ACTIVITY_TRANSFER_TYPE; 
        List<Core_MDF_BudgetTransferWrapper> budgetTransferWrapperList = new List<Core_MDF_BudgetTransferWrapper>();
        
        if(pfr.status == 'Approved' && !pfrIdToAmtToTransfer.isEmpty() && pfrIdToAmtToTransfer.containskey(pfr.id)) {
            
            budgetTransferWrapperList.add(new Core_MDF_BudgetTransferWrapper(pmbIdToPmbMap.get(pfr.BudgetId).Core_MDF_Budget_Partner__c,pfr.ChannelPartnerId, pfr.BudgetId, pfrIdToAmtToTransfer.get(pfr.id),AUTO_ACTIVITY_TRANSFER_TYPE,pfr.id,false));
        }
        return budgetTransferWrapperList;
    }
    /*****************************************************************************************************
Method Name :   validateAvailAmtAtPrimaryAccount
@parameters :   pfrList,oldPFRMap
Description :   To Validate whether amount is present at Primary Partner Account or Not
Added By    :   Keerthi
Modified By :                 Date:10/03/2024               
******************************************************************************************************/
    
    public static void validateAvailAmtAtPrimaryAccount(PartnerFundRequest pfr, Map<Id,Decimal> primaryAccIdToActAvailableAmt,Decimal amountToTransfer,Map<Id,PartnerMarketingBudget> pmbIdToPmbMap) {
        if(primaryAccIdToActAvailableAmt.get(pmbIdToPmbMap.get(pfr.BudgetId).Core_MDF_Budget_Partner__c) < amountToTransfer) {
            
            pfr.addError(Label.Core_MDF_AutoBudgetTransfer_ErrorMsg);
        }else{
            pfr.status = 'Approved';
            Decimal amtAvailable = primaryAccIdToActAvailableAmt.get(pmbIdToPmbMap.get(pfr.BudgetId).Core_MDF_Budget_Partner__c) - amountToTransfer;
            primaryAccIdToActAvailableAmt.put(pmbIdToPmbMap.get(pfr.BudgetId).Core_MDF_Budget_Partner__c,amtAvailable);
            
        }
        
    }
    /*****************************************************************************************************
Method Name :   isEEFActivityAutoBdgtFwdTransferReqAfterCon
@parameters :   pfrList,oldPFRMap
Description :   To Validate whether incoming PFR us valid one or not to Proceed for After context
Added By    :   Keerthi
Modified By :                 Date:10/03/2024               
******************************************************************************************************/ 
    public static Boolean isEEFActivityAutoBdgtFwdTransferReqAfterCon(PartnerFundRequest pfr, Map<Id,PartnerFundRequest> oldPFRMap ) { //isEEFActivityAutoBdgtFwdTransferReq
        Boolean isValidRecord = false;
        Boolean primaryAccManEEF = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_EEF_Primary_Account_Manager') ;
        
        if(primaryAccManEEF && pfr.AllocationId!=null && pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && (oldPFRMap == NULL || 
                                                                                                                               (oldPFRMap != NULL &&((pfr.Core_MDF_Completed_Approval_Level_Name__c == 'L1 Approval (Primary Partner)' &&  
                                                                                                                                                      oldPFRMap.get(pfr.Id).Core_MDF_Completed_Approval_Level_Name__c != pfr.Core_MDF_Completed_Approval_Level_Name__c &&
                                                                                                                                                      oldPFRMap.get(pfr.Id).Core_MDF_Approval_Stage__c == pfr.Core_MDF_Completed_Approval_Level_Name__c) || checkForEditCondition(pfr,oldPFRMap)
                                                                                                                                                    )))) {
                                                                                                                                                        isValidRecord = true;
                                                                                                                                                    }
        
        return isValidRecord;
    }
    /*****************************************************************************************************
Method Name :   isEEFActivityAutoBdgtFwdTransferReqBeforeCon
@parameters :   pfrList,oldPFRMap
Description :   To Validate whether incoming PFR us valid one or not to Proceed for Before context
Added By    :   Keerthi
Modified By :                 Date:10/03/2024               
******************************************************************************************************/ 
    public static Boolean isEEFActivityAutoBdgtFwdTransferReqBeforeCon(PartnerFundRequest pfr, Map<Id,PartnerFundRequest> oldPFRMap ) { //isEEFActivityAutoBdgtFwdTransferReq
        Boolean isValidRecord = false;
        Boolean primaryAccManEEF = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_EEF_Primary_Account_Manager') ;
        
        
        if(primaryAccManEEF && pfr.AllocationId!=null && pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && (oldPFRMap == NULL ||
                                                                                                                               (oldPFRMap != NULL &&(pfr.Core_MDF_Approval_Stage__c == 'L1 Approval (Primary Partner)' && oldPFRMap.get(pfr.Id).Core_MDF_Approval_Step_Completed__c != pfr.Core_MDF_Approval_Step_Completed__c ||  checkForEditCondition(pfr,oldPFRMap)
                                                                                                                                                    )))) {
                                                                                                                                                        isValidRecord = true;
                                                                                                                                                        
                                                                                                                                                    }
        
        
        return isValidRecord;
    }
    
    /*To Check whether EEF activity is getting edited by Primary Account Manager*/
    public static Boolean checkForEditCondition (PartnerFundRequest pfr ,Map<Id,PartnerFundRequest> oldPFRMap){
        Boolean validEditAction = false ;
        if((oldPFRMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Planned' && 
            oldPFRMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c !=pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c &&
            pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c > oldPFRMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c) ||
           (oldPFRMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Revision Required' && pfr.Core_MDF_Approval_Step_Completed__c !=0 )){
               validEditAction = true;
           }
        return validEditAction ;
    }
    
    /*****************************************************************************************************
Method Name :   activityBudgetTransferReversalForEEF
@parameters :   pfrList,oldPFRMap
Description :   To Enable Budget Transfer Reversal on Cancelling / Closing / Rejecting / Recalling / Decreasing the Amount of activity If Auto Budget Transfer happened
Added By    :   Keerthi
Modified By :                 Date:28/03/2024               
******************************************************************************************************/
    
    public static void activityAutoBudgetTransferReversal(Map<Id,PartnerFundRequest> newPfrMap , Map<Id,PartnerFundRequest> oldPFRMap ) {
        List<Core_MDF_BudgetTransferWrapper> budgetTransferWrapperList = new List<Core_MDF_BudgetTransferWrapper>();
        //Map to store PFR Id to Auto Budget Transefer Details
        Map<Id,BudgetTranferLogWrapper> pfrIdToBudTransferWrapperMap = new Map<Id,BudgetTranferLogWrapper>();
        Map<Id,Decimal> pfrIdToAmtToTransfer = new Map<Id,Decimal>();
        Map<Id,PartnerMarketingBudget> pmbIdToPmbMap = new Map<Id,PartnerMarketingBudget>();
        set<id> budgetIds = new set<id>();
        //Check whether Auto Budget Transfer Happened or not for incoming PFR's
        pfrIdToBudTransferWrapperMap = isValidDataForReverseAutoBdgtTransfer(newPfrMap.values() ,oldPFRMap);
        String AUTO_ACTIVITY_TRANSFER_TYPE = Core_MDF_CCP_ConstantClass.AUTO_ACTIVITY_TRANSFER_TYPE; 
        
        
        if(pfrIdToBudTransferWrapperMap != null && !pfrIdToBudTransferWrapperMap.isEmpty()){
            //check for Entry Criteria - Cancelling Activity /Activity Closure (Manual) /Activity Reject and Activity Recall /Activity Edit(Decreasing the Amount)
            for(PartnerFundRequest pfr :newPfrMap.Values()){
                if(pfrIdToBudTransferWrapperMap.containskey(pfr.id) && pfrIdToBudTransferWrapperMap.get(pfr.id)!= Null ) {
                    pfrIdToAmtToTransfer = calculateReversalAmtToBeTransferred(pfr,oldPFRMap,pfrIdToBudTransferWrapperMap) ;
                    
                    
                    if(!pfrIdToAmtToTransfer.isEmpty() &&  pfrIdToAmtToTransfer.containsKey(pfr.id) &&pfrIdToAmtToTransfer.get(pfr.id) !=null  ){
                        budgetTransferWrapperList.add(new Core_MDF_BudgetTransferWrapper(pfr.ChannelPartnerId,pfrIdToBudTransferWrapperMap.get(pfr.id).pfrBudgetAccId, pfr.BudgetId, pfrIdToAmtToTransfer.get(pfr.id),AUTO_ACTIVITY_TRANSFER_TYPE,pfr.id,true));
                    }
                }
            }
            if(!budgetTransferWrapperList.isEmpty() && budgetTransferWrapperList.size()>0) {
                String result = Core_MDF_BudgetTransferUtility.budgetTransfer(budgetTransferWrapperList);
                
            }
            
            
            
        }
        
    }
    /*****************************************************************************************************
Method Name :   isValidDataForReverseAutoBdgtTransfer
@parameters :   pfrIdSet
Description :   To validate whether incoming pfr is eligible to check whether Auto Budget Tranfer happened or not
Added By    :   Keerthi
Modified By :                 Date:28/03/2024               
******************************************************************************************************/
    public static Map<Id,BudgetTranferLogWrapper> isValidDataForReverseAutoBdgtTransfer(List<PartnerFundRequest> pfrList ,Map<Id,PartnerFundRequest> oldPFRMap){
        Map<Id,BudgetTranferLogWrapper> pfrIdToBudTransferWrapperMap = new Map<Id,BudgetTranferLogWrapper>();
        Set<Id> pfrIds = new Set<Id> ();
        
        for(PartnerFundRequest pfr : pfrList){
            if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && 
               (isCancelledactivity(pfr,oldPFRMap) || isActivityRejectOrRecall(pfr,oldPFRMap) || isActivityManualClosure(pfr,oldPFRMap) || isActivityAmtDecreased(pfr,oldPFRMap))) {
                   pfrIds.add(pfr.id);
               }
        }
        
        //Check whether Auto Budget Transfer Happened or not for incoming PFR's
        if(!pfrIds.isEmpty()){
            pfrIdToBudTransferWrapperMap = getBudgetTransferHistory(pfrIds);
        }
        return pfrIdToBudTransferWrapperMap;
    }
    
    /*****************************************************************************************************
Method Name :   getBudgetTransferHistory
@parameters :   pfrIdSet
Description :   To Check whether Forward Budget Transfer happened or not for incoming pfrs
Added By    :   Keerthi
Modified By :                 Date:28/03/2024               
******************************************************************************************************/
    public static Map<Id,BudgetTranferLogWrapper> getBudgetTransferHistory(Set<Id> pfrIdSet) {
        Map<Id,BudgetTranferLogWrapper> pfrIdTobudgetTransferWrapper = new Map<Id,BudgetTranferLogWrapper>();
        String AUTO_ACTIVITY_TRANSFER_TYPE = Core_MDF_CCP_ConstantClass.AUTO_ACTIVITY_TRANSFER_TYPE ;
        
        List<Core_MDF_Budget_Transfer_Log__c> budTransLogList =[SELECT id,Core_MDF_Target_Account__c,Core_MDF_Source_Account__c,Core_MDF_Partner_Marketing_Budget__c,
                                                                Core_MDF_Transferred_Amount__c,Core_MDF_Transfer_Type__c,Core_MDF_Co_Marketing_Activity__c,Core_MDF_Partner_Marketing_Budget__r.Core_MDF_Budget_Partner__c,Core_MDF_Activity_Reverse_Transfer_Ind__c from Core_MDF_Budget_Transfer_Log__c WHERE 
                                                                Core_MDF_Co_Marketing_Activity__c!=NULL AND Core_MDF_Co_Marketing_Activity__c iN :pfrIdSet AND  Core_MDF_Transfer_Type__c =:AUTO_ACTIVITY_TRANSFER_TYPE ]; 
        
        if(!budTransLogList.isEmpty()){
            for(Core_MDF_Budget_Transfer_Log__c budTransLog : budTransLogList){
                BudgetTranferLogWrapper btLogWrapper = new BudgetTranferLogWrapper();
                
                if(!pfrIdTobudgetTransferWrapper.containsKey(budTransLog.Core_MDF_Co_Marketing_Activity__c)) {
                    if(budTransLog.Core_MDF_Activity_Reverse_Transfer_Ind__c == false) {
                        btLogWrapper.sumOfForwardTransferredAmt = budTransLog.Core_MDF_Transferred_Amount__c;
                    }else{
                        btLogWrapper.sumOfReverseTransferredAmt = budTransLog.Core_MDF_Transferred_Amount__c ;
                    }
                    
                }else{
                    btLogWrapper = pfrIdTobudgetTransferWrapper.get(budTransLog.Core_MDF_Co_Marketing_Activity__c);
                    if(budTransLog.Core_MDF_Activity_Reverse_Transfer_Ind__c == false) {
                        btLogWrapper.sumOfForwardTransferredAmt += budTransLog.Core_MDF_Transferred_Amount__c;
                    }else{
                        btLogWrapper.sumOfReverseTransferredAmt += budTransLog.Core_MDF_Transferred_Amount__c ;
                    }
                }
                btLogWrapper.pfrBudgetAccId = budTransLog.Core_MDF_Partner_Marketing_Budget__r.Core_MDF_Budget_Partner__c;          
                pfrIdTobudgetTransferWrapper.put(budTransLog.Core_MDF_Co_Marketing_Activity__c,btLogWrapper);
                
                
            }
            
            
        }
        return pfrIdTobudgetTransferWrapper;
    }
    /*****************************************************************************************************
Method Name :   checkForReversalAmountTobeTransferred
@parameters :   pfrIdSet
Description :   To Check whether Forward Budget Transfer happened or not for incoming pfrs
Added By    :   Keerthi
Modified By :                 Date:28/03/2024               
******************************************************************************************************/
    public static Map<Id,Decimal> calculateReversalAmtToBeTransferred (partnerFundRequest pfr , Map<Id,PartnerFundRequest> oldPFRMap ,Map<Id,BudgetTranferLogWrapper> pfrIdToBudTransferWrapperMap) {
        
        Map<Id,Decimal> pfrIdToAmtToTransfer = new Map<Id,Decimal>();
        Decimal amtToBeTransfered = 0;
        //Checking for Entry Criteria of Reject,Recall and  Cancelling Activity 
        if(isCancelledactivity(pfr,oldPFRMap) || isActivityRejectOrRecall(pfr,oldPFRMap)) {
            amtToBeTransfered = pfrIdToBudTransferWrapperMap.get(pfr.id).sumOfForwardTransferredAmt - pfrIdToBudTransferWrapperMap.get(pfr.id).sumOfReverseTransferredAmt ;
        }
        //Entry Criteria for Activity Closure (Manual)
        if(isActivityManualClosure(pfr,oldPFRMap)) {
            amtToBeTransfered = pfrIdToBudTransferWrapperMap.get(pfr.id).sumOfForwardTransferredAmt - pfrIdToBudTransferWrapperMap.get(pfr.id).sumOfReverseTransferredAmt -pfr.Amount;
        }
        //Activity Edit(Decreasing the Amount)
        if(isActivityAmtDecreased(pfr,oldPFRMap)) {
            Decimal diffInIntelCon =  oldPFRMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c - pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c ;
            Decimal budgetTransAmt = pfrIdToBudTransferWrapperMap.get(pfr.id).sumOfForWardTransferredAmt - pfrIdToBudTransferWrapperMap.get(pfr.id).sumOfReverseTransferredAmt ;
            amtToBeTransfered = (diffInIntelCon <= budgetTransAmt)? diffInIntelCon : budgetTransAmt;
        }
        
        if(amtToBeTransfered > 0){
            pfrIdToAmtToTransfer.put(pfr.id,amtToBeTransfered);
        }
        
        return pfrIdToAmtToTransfer;
        
        
        
    }
    
    
    
    public static Boolean isCancelledactivity(PartnerFundRequest pfr , Map<Id,PartnerFundRequest> oldPFRMap ) {
        
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ABTRev_ActCancel') && oldPFRMap.get(pfr.id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c && pfr.Core_MDF_Fund_Request_Status__c == 'Cancelled'){
            return True;
        }
        return false;
        
    }
    
    public static Boolean isActivityManualClosure(PartnerFundRequest pfr , Map<Id,PartnerFundRequest> oldPFRMap ){
        
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ABTRev_ActManClosure') && oldPFRMap.get(pfr.id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c && pfr.Core_MDF_Fund_Request_Status__c == 'Closed' && pfr.Core_MDF_Activity_Closure_Type__c == 'Manual'){
            return True;
        }
        return false ;
        
    }
    public static Boolean isActivityRejectOrRecall(PartnerFundRequest pfr , Map<Id,PartnerFundRequest> oldPFRMap ){
        
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ABTRev_ActRejectRecall') && oldPFRMap.get(pfr.id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c && pfr.Core_MDF_Fund_Request_Status__c == 'Revision Required'){
            return true;
        }
        
        return false;
    }
    public static Boolean isActivityAmtDecreased(PartnerFundRequest pfr , Map<Id,PartnerFundRequest> oldPFRMap ){
        
        List<String> ELIGIBLE_PFRSTATUS_FOR_REVERSAL = Core_MDF_CCP_ConstantClass.ELIGIBLE_PFRSTATUS_FOR_REVERSAL;
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_Bypass_ABTRev_ActAmtDecrease') && ELIGIBLE_PFRSTATUS_FOR_REVERSAL.contains(oldPFRMap.get(pfr.id).Core_MDF_Fund_Request_Status__c) &&
           oldPFRMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c !=pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c &&
           pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c < oldPFRMap.get(pfr.Id).Core_MDF_Activity_Reimbursement_Amt_nbr__c /*&& pfr.Core_MDF_Approval_Step_Completed__c !=0*/){
               return True;
           }
        
        return False ;
        
    }
    
    public Class BudgetTranferLogWrapper{
        
        Decimal sumOfForwardTransferredAmt = 0 ;
        Decimal sumOfReverseTransferredAmt = 0 ;
        Id pfrBudgetAccId ;
        
    }
    
    //Mohit - Metadata Cleanup 
    public static Map<String, String> productTypeCatSplitMap(){
        Map<String, String> prodTypeCatMap = new Map<String, String>();
        String query = 'Select Core_MDF_Field_1_txt__c, Core_MDF_Field_2_txt__c From Core_MDF_CCP_Custom_Metadata_Utility__c '+
            'Where Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.PRODUCT_CAT_TYPE_SPLIT) + '\' '  +
            'AND Core_MDF_Is_Active_Ind__c = TRUE ';
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> prdTypeCategoryList = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);
        //Refer Core_MDF_Metadata_Utility_mapping__c for field mapping of Core_MDF_Field_1_txt__c & Core_MDF_Field_2_txt__c
        if(!prdTypeCategoryList.isEmpty()){
            for(Core_MDF_CCP_Custom_Metadata_Utility__c prodTypeCat : prdTypeCategoryList){                                 
                prodTypeCatMap.put(prodTypeCat.Core_MDF_Field_1_txt__c, prodTypeCat.Core_MDF_Field_2_txt__c);
            } 
        }	
        return prodTypeCatMap;	
        
    }
    /*****************************************************************************************************
Method Name :   validatePNUMForExternalUsers
@parameters :   pfrIdSet
Description :   Validate the PNUM for the activity submitter
Added By    :   Akanksha
Modified By :                 Date:20/Jan/2025               
******************************************************************************************************/
    public static void validatePNUMForExternalUsers(List<PartnerFundRequest> newPFRList, Map<Id, PartnerFundRequest> oldPFRMap) {
        Set<Id> pfrAccountId = new Set<Id>();
        Map<String, List<Core_MDF_Partner_Node_User_Mapping__c>> mapOfAccountIdAndPNUM = new Map<String, List<Core_MDF_Partner_Node_User_Mapping__c>>();
        String userId = UserInfo.getUserId();
        //Collect the AccountIds based on the beforeInsert or beforeUpdate context
        for (PartnerFundRequest itrPFR : newPFRList) {
            // Only check for differences if it's a beforeUpdate context
            if (oldPFRMap == null || (oldPFRMap != null && oldPFRMap.containsKey(itrPFR.Id) && itrPFR.ChannelPartnerId != oldPFRMap.get(itrPFR.Id).ChannelPartnerId)) {
                pfrAccountId.add(itrPFR.ChannelPartnerId);
            }
        }  
        // Query Core_MDF_Partner_Node_User_Mapping__c to fetch the active mappings
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = [SELECT  Id,Core_MDF_Active_Ind__c, Core_MDF_User__c, Core_MDF_User__r.isActive ,Core_MDF_Account__c
                                                                FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__c IN :pfrAccountId AND   
                                                                /*Core_MDF_Active_Ind__c = true AND*/ Core_MDF_User__r.isActive = true AND Core_MDF_User__c = :userId
                                                               ];
        
        
        
        if(pnumList.size() > 0){
            //creating a map of unique key and pnums
            for (Core_MDF_Partner_Node_User_Mapping__c itrPnum : pnumList) {
                String uniqueKey = String.valueOf(itrPnum.Core_MDF_Account__c)+'_'+itrPnum.Core_MDF_Active_Ind__c;
                if (!mapOfAccountIdAndPNUM.containsKey(uniqueKey)) {
                    mapOfAccountIdAndPNUM.put(uniqueKey, new List<Core_MDF_Partner_Node_User_Mapping__c>{itrPnum});
                }else{
                    mapOfAccountIdAndPNUM.get(uniqueKey).add(itrPnum);
                }   
            }
            // Check if the partner fund request contains a valid mapping for the user
            for (PartnerFundRequest itrPfr : newPFRList) {
                String uniquePFRKey = String.valueOf(itrPfr.ChannelPartnerId)+'_'+'true';
                if (!mapOfAccountIdAndPNUM.containsKey(uniquePFRKey)) {
                    itrPfr.addError(Label.Core_MDF_NoClaimCreatePermissionText);
                }
            }
        }
    }
    public static boolean checkTactics(PartnerFundRequest pfr){
        List<String> tacticIncentive = Label.Core_MDF_Spif_Tactics.split(';');
        List<String> tacticsList = pfr.Core_MDF_Tactics_nm__c != null ? pfr.Core_MDF_Tactics_nm__c.split(';') : new List<String>();
        if(!tacticsList.isEmpty()){
            for (String incentive : tacticIncentive) {
                if (tacticsList.contains(incentive)) {
                    return true;
                }
            }}
        return false;
    }
    
    /*****************************************************************************************************
Method Name :   validateBudgetType
@parameters :   pfrlist,oldpfrMap
Description :   Validate the budgetType of Campaign and Activity
Added By    :   Akash
Modified By :   Date:26/June/2025               
******************************************************************************************************/
    public static void validateBudgetType(List<PartnerFundRequest> pfrlist,Map<Id,PartnerFundRequest> oldpfrMap){
        Set<Id> setofCampaignIds = new Set<Id>();
        List<PartnerFundRequest> pfrNewList = new List<PartnerFundRequest>();
        
        for(PartnerFundRequest pfr : pfrList){
            //Checking if activity budget type is not null and oldpfrmap
            if(pfr.Core_MDF_Budget_Type_nm__c != null && (oldpfrMap == null || (oldpfrMap != null && oldpfrMap.containsKey(pfr.Id) && pfr.core_MDF_budget_type_nm__c != oldpfrMap.get(pfr.Id).core_MDF_budget_type_nm__c))){
                setofCampaignIds.add(pfr.CampaignId);
                pfrNewList.add(pfr);
            }
            
            if(setofCampaignIds != null && setofCampaignIds.size() > 0 && pfrNewList != null && pfrNewList.size() > 0){
                //Query on campaign object to get Id and budget type from campign by passing campaign id from activity.
                Map<Id,Campaign> campMap = new Map<Id,Campaign>([Select Id,Core_MDF_Opal_Budget_Type_Txt__c from Campaign WHERE Id IN : setofCampaignIds]);
                if(campMap != null){
                    for(PartnerFundRequest newpfr : pfrNewList){
                        if(campMap.containsKey(newpfr.CampaignId) && campMap.get(newpfr.CampaignId).Core_MDF_Opal_Budget_Type_Txt__c != null){
                            //Checking if activity budget type is matching with campaign budget type.
                            if(!campMap.get(newpfr.CampaignId).Core_MDF_Opal_Budget_Type_Txt__c.contains(newpfr.core_MDF_budget_type_nm__c)){
                                newpfr.addError(Label.Core_MDF_Budget_Type_Error_Message);
                            }
                        }
                    }
                }
            }
        }
    }
    /*****************************************************************************************************
Method Name :   validateInprogressPFRUpdates
@parameters :   oldpfrMap,newpfrMap
Description :   Validate the In-Progress activity field value update against associated claims
Added By    :   Ramapriya           08/08/2025 
Modified By :              
******************************************************************************************************/
    public static void validateInprogressPFRUpdates(Map<Id, PartnerFundRequest> oldMap, Map<Id, PartnerFundRequest> newMap) {
        String IN_PROGRESS_STATUS = System.Label.Core_MDF_In_Progress_Status;
        String IN_PROGRESS_PENDING_REVIEW_STATUS = System.Label.Core_MDF_PFR_Status_InProgress_PendingReview;
        String IN_PROGRESS_PENDING_APPROVAL_STATUS = System.Label.Core_MDF_PFR_Status_InProgress_PendingApproval;
        String IN_PROGRESS_REVISION_REQUIRED_STATUS = System.Label.Core_MDF_PFR_In_Progress_Revision_Required;
        
        Boolean hasPermission = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Account_Manager_PS'));
        
        if (hasPermission) {
            
            Map<Id, PartnerFundRequest> modifiedInProgressPFRs = new Map<Id, PartnerFundRequest>();
            
            
            for (Id pfrId : newMap.keySet()) {
                
                
                if ((oldMap.get(pfrId).Core_MDF_End_Date__c != newMap.get(pfrId).Core_MDF_End_Date__c || oldMap.get(pfrId).Core_MDF_Activity_Reimbursement_Amt_nbr__c != newMap.get(pfrId).Core_MDF_Activity_Reimbursement_Amt_nbr__c) && (oldMap.get(pfrId).Core_MDF_Fund_Request_Status__c == IN_PROGRESS_STATUS || oldMap.get(pfrId).Core_MDF_Fund_Request_Status__c == IN_PROGRESS_REVISION_REQUIRED_STATUS) &&
                    (newMap.get(pfrId).Core_MDF_Fund_Request_Status__c == IN_PROGRESS_PENDING_REVIEW_STATUS || newMap.get(pfrId).Core_MDF_Fund_Request_Status__c == IN_PROGRESS_PENDING_APPROVAL_STATUS || (newMap.get(pfrId).Core_MDF_Fund_Request_Status__c == IN_PROGRESS_REVISION_REQUIRED_STATUS && newMap.get(pfrId).Core_MDF_Proposal_Based_Ind__c==true ))) {
                        
                        modifiedInProgressPFRs.put(pfrId, newMap.get(pfrId));
                    }
            }
            
            List<PartnerFundClaim> claims = [SELECT Id, RequestId, Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, Amount,Core_MDF_Status__c   
                                             FROM PartnerFundClaim
                                             WHERE RequestId IN :modifiedInProgressPFRs.keySet()
                                             AND Core_MDF_Status__c!='Cancelled'];
            
            Map<Id, List<PartnerFundClaim>> activityClaimMap = new Map<Id, List<PartnerFundClaim>>();
            for (PartnerFundClaim claim : claims) {
                if (!activityClaimMap.containsKey(claim.RequestId)) {
                    activityClaimMap.put(claim.RequestId, new List<PartnerFundClaim>{claim});
                }
                else{
                    activityClaimMap.get(claim.RequestId).add(claim);
                }
            }
            
            for (Id pfrId : activityClaimMap.keySet()) {
                PartnerFundRequest newPFR = newMap.get(pfrId);
                Decimal totalClaimAmount = 0;
                if (activityClaimMap.containsKey(pfrId)) {
                    for (PartnerFundClaim claim : activityClaimMap.get(pfrId)) {
                        if (newPFR.Core_MDF_End_Date__c < claim.Core_MDF_Ad_Run_End_Date__c) {
                            newPFR.addError(Label.Core_MDF_Validate_InProgress_Enddate_Edit_Error);
                            break;
                        }
                        
                        totalClaimAmount += claim.Amount;
                    }
                    if (newPFR.Core_MDF_Activity_Reimbursement_Amt_nbr__c < totalClaimAmount) {
                        newPFR.addError(Label.Core_MDF_Validate_InProgress_Amount_Edit_Error);
                    }
                    
                }
                
                
            }
        }
    }
    /*****************************************************************************************************
Method Name :   oneActivityperCampaign
@parameters :   pfrlist
Description :    create only one Activity per Campaign for IPA Outcome Proposal Based
Added By    :   Rishabh
Modified By :   Date:15/Jan/2026   // YYYY-MM-DD HH:MM:SS            
******************************************************************************************************/
    public static void oneActivityPerCampaign(List<PartnerFundRequest> pfrList) {
        
        if (pfrList == null || pfrList.isEmpty()) return;
        
        // ---------- Read Feature Date ----------
        Datetime featureStartDate;
        try {
            String labelValue = System.Label.Core_MDF_One_Activityper_Cmpgn;
            
            if (String.isBlank(labelValue)) return;
            
            featureStartDate = Datetime.valueOfGmt(labelValue.trim());
            
        } catch (Exception e) {
            return;
        }
        
        List<String> listValidBudgetTypes = Core_MDF_CCP_ConstantClass.IPA_PROPOSAL_BUDGET_TYPE;
        
        Map<Id, Integer> MapOfTxnCountByCampaign = new Map<Id, Integer>();
        Set<Id> SetOfCampaignIds = new Set<Id>();
        Set<Id> SetOfTxnPfrIds = new Set<Id>();
        
        // ---------- Filter Valid PFRs ----------
        List<PartnerFundRequest> ListOfPfrs = new List<PartnerFundRequest>();
        
        for (PartnerFundRequest pfr : pfrList) {
            
            if (pfr.CampaignId != null && pfr.Core_MDF_Proposal_Based_Ind__c && listValidBudgetTypes.contains(pfr.Core_MDF_Budget_Type_nm__c) && pfr.Core_MDF_ActivityCategory__c == 'Outcome-Based') {
                
                ListOfPfrs.add(pfr);
                SetOfCampaignIds.add(pfr.CampaignId);
                
                if (pfr.Id != null) {
                    SetOfTxnPfrIds.add(pfr.Id);
                }
            }
        }
        
        if (SetOfCampaignIds.isEmpty()) return;
        
        // ---------- Query Campaign ----------
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([SELECT Id, CreatedDate FROM Campaign WHERE Id IN :SetOfCampaignIds AND Core_MDF_CampOutcomeOpt_In_Ind__c = true]);
        // ---------- Transaction Count ----------
        for (PartnerFundRequest pfr : ListOfPfrs) {
            
            if(campaignMap.containsKey(pfr.CampaignId)){
                Campaign camp = campaignMap.get(pfr.CampaignId);
                if (camp.CreatedDate < featureStartDate) continue;
                if (MapOfTxnCountByCampaign.containsKey(pfr.CampaignId)) {
                    Integer count = MapOfTxnCountByCampaign.get(pfr.CampaignId);
                    MapOfTxnCountByCampaign.put(pfr.CampaignId, count + 1);
                } else {
                    MapOfTxnCountByCampaign.put(pfr.CampaignId, 1);
                }
            } 
        }
        
        if (MapOfTxnCountByCampaign.isEmpty()) return;
        
        // ---------- Database Count ----------
        Map<Id, Integer> MapOfDbCountByCampaign = new Map<Id, Integer>();
        
        for (AggregateResult ar : [
            SELECT CampaignId, COUNT(Id) cnt
            FROM PartnerFundRequest
            WHERE CampaignId IN :MapOfTxnCountByCampaign.keySet()
            AND Core_MDF_Fund_Request_Status__c != 'Cancelled'
            AND Id NOT IN :SetOfTxnPfrIds
            GROUP BY CampaignId
        ]) {
            MapOfDbCountByCampaign.put((Id) ar.get('CampaignId'), (Integer) ar.get('cnt'));
        }
        
        // ---------- Final Validation ----------
        for (PartnerFundRequest pfr : ListOfPfrs) {
            
            if (!MapOfTxnCountByCampaign.containsKey(pfr.CampaignId)) continue;
            
            Integer dbCount = MapOfDbCountByCampaign.get(pfr.CampaignId);
            Integer txnCount = MapOfTxnCountByCampaign.get(pfr.CampaignId);
            
            dbCount = dbCount == null ? 0 : dbCount;
            
            if (dbCount + txnCount > 1) {
                pfr.addError(Label.Core_MDF_OneActivityperCmpgn_Errormsg);
            }
        }
    }
	    //Joshua 15182 Start
     public static Map<Id, Boolean> retrieveApprovalField(List<PartnerFundRequest> pfrList){
       Map<Id, Boolean> pfrApprovalMap = new Map<Id, Boolean>();
            Set<Id> campaignIds = new Set<Id>();
            // Collect Campaign Ids
            for(PartnerFundRequest pfr : pfrList){
                if(pfr.CampaignId != null){
                    campaignIds.add(pfr.CampaignId);
                }
            }
            // Query Campaigns
            Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([SELECT Id,Core_MDF_Activity_Approval_Required_Ind__c FROM Campaign WHERE Id IN :campaignIds]);
            // Map PFR Id -> Campaign Approval Checkbox
            for(PartnerFundRequest pfr : pfrList){
                Boolean approvalRequired = false;
                if(pfr.CampaignId != null && campaignMap != null && campaignMap.containsKey(pfr.CampaignId)){
                    approvalRequired = campaignMap.get(pfr.CampaignId).Core_MDF_Activity_Approval_Required_Ind__c;
                }
                pfrApprovalMap.put(pfr.CampaignId, approvalRequired);
            }

            return pfrApprovalMap;
     }
     //Joshua 15182 End
}