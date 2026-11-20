//US949837 - Added without sharing keyword to fix checkmarx issues
global without sharing class Core_MDF_ClaimReviewCaseProcessHelper implements Database.Batchable<sObject>,Database.Stateful {//Audit change
    
    List<PartnerFundClaim> csList = new List<PartnerFundClaim>();
    public List<PartnerFundClaim> claimListObj;
    String executionReason;
    List<Id> claimOwnerIdList;
    public Map<String,Core_Trigger_Executions__c> customSettingsMap = Core_Trigger_Executions__c.getAll();
    Decimal taxes;
    Decimal othercosts;
    static final String POP_AUDIT_TYPE = 'Document Hold';
    public static Set<id> zvScorecardClaims = new Set<id>();
    public static Id reviewCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
    public static Id reviewCaseClosedRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
    public Set<Id> caseIdSetForAIAudit = new Set<Id>();//Audit changes 
    
    //US591129, US591133: Case SLA, Submission SLA Program Based
    //public static Map<string,integer> programBudgetTypeToSubmissionSLAMap = new Map<string,integer>();
    //public static Map<string,integer> programBudgetTypeToCaseSLAMap = new Map<string,integer>();
    
    // Parameterised contructor to get the List of object to be handled
    global Core_MDF_ClaimReviewCaseProcessHelper(List<PartnerFundClaim> clmList, String executionReason){
        this.claimListObj = clmList;
        this.executionReason = executionReason;
    }
    
    // Parameterised contructor to get the List of object to be handled
    global Core_MDF_ClaimReviewCaseProcessHelper(List<PartnerFundClaim> clmList, String executionReason, List<Id> claimOwnerIds){
        this.claimListObj = clmList;
        this.executionReason = executionReason;
        this.claimOwnerIdList = claimOwnerIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        //US977959: [OEM Integration] - [Case] - Activity Sub Type - Multiselect
        String strQuery = '';
        strQuery = 'SELECT Id,Core_MDF_Excess_Requested_Amount__c,ChannelPartnerId,Core_MDF_Invoice_Date__c,Core_MDF_Audit_Type__c,CreatedDate,Amount, Core_MDF_Claim_Ref_Number__c,Core_MDF_Exchange_rate__c,'
            + 'Core_MDF_Currency__c, Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Taxes_Local__c,CreatedById, Core_MDF_Program__c,Core_MDF_Audit_Adjustment_Amount__c,'
            + 'Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Invoice_Number__c, RequestId,Request.CampaignId,Core_MDF_Country_Location_nm__c,Request.Core_MDF_Start_Date__c,'
            + 'Request.Core_MDF_End_Date__c,Request.Core_MDF_ActivityCategory__c,Request.Core_MDF_TargetAudience__c,Request.Core_MDF_Priorities__c,Core_MDF_Brand_nm__c,'
            + 'Request.Core_MDF_ProductType__c,Request.Core_MDF_Activity_Types__c, Request.Title, Request.Core_MDF_Channel_Partner_Led__c, Request.Campaign.Core_MDF_Technology__c,'
            + 'Request.Campaign.StartDate,Request.Campaign.EndDate,Request.Campaign.Name, Core_MDF_Total_Claim_Offsets__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Claim_Review_Case__c,'
            + 'OwnerId,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_AccountCompany__c, Core_MDF_Status__c, Request.Core_MDF_Budget_Type_nm__c, Request.Core_MDF_Activity_SubType_nm__c,'
            + 'ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Region_Cd__c, Core_MDF_Sub_Region_Cd__c,'
            + 'Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c,Core_MDF_Media_Vehicle__c, Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, LastModifiedById, '
            + 'LastModifiedBy.Profile.Name, ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Document_Hold_Ind__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Document_Submission_Missed_Ind__c '
            + 'FROM PartnerFundClaim '+'WHERE Id IN :claimListObj';
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext batchContext, List<PartnerFundClaim> scope) {
        try{
            // for creating a case
            if(executionReason == 'CreateCases') {
                List<Id> claimIdList = new List<Id>();
                List<PartnerFundClaim> pfcListWithActivityCampaign = new List<PartnerFundClaim>();
                Map<Id,PartnerFundClaim> pfcMapWithActivityCampaign;
                List<Case> reviewCasesToBeCreatedList = new List<Case>();
                List<PartnerFundClaim> claimListToBeUpdatedWithCaseId = new List<PartnerFundClaim>();
                
                //Calling Wrapper class to populate Region on Case.
                Map<String,Core_MDF_GeoBasedGenericSharing.countryGeoSubGeoWrapper> wMap = new Map<String,Core_MDF_GeoBasedGenericSharing.countryGeoSubGeoWrapper>();
                wMap = Core_MDF_GeoBasedGenericSharing.getCountryGeoMap();
                Set<Id> accountIdSet = new Set<Id>();
                Set<Id> programIdSet = new Set<Id>();
                Map<String,Id> geoGroupIdMap = new Map<String,Id>(); 
                String pgmSubRegion;
                String pgmRegion;
                String accCPGeo;
                String accCPSubGeo;
                String accCP;
                List<String> standardProfiles = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_StandardProfiles').split(';');
                
                // checking review case on claim is null
                for(PartnerFundClaim pfc: scope) {
                     // ATHR Fix: TWC3117-18226
                    if(pfc.Core_MDF_Claim_Review_Case__c != NULL) continue;
                        claimIdList.add(pfc.id);   
                        //Prepare the sets to get pgm groups for programs other than RMF
                        Boolean isNodeBasedSharingReqd = Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(pfc.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);                        
                        if(!isNodeBasedSharingReqd){
                            accountIdSet.add(pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
                            programIdSet.add(pfc.ChannelPartner.Core_MDF_Channel_Program__c);
                        }
                }
                
                Map<Id,List<Core_MDF_Audit_Document__c> > claimIdWithConDocId = new Map<Id,List<Core_MDF_Audit_Document__c> >(); //POP
                //Based on US374024, replaced Request.Campaign.Core_MDF_Reimbursement_Rate__c with Core_MDF_Reimbursement_Percent__c inside SOQL.
                //US977959: [OEM Integration] - [Case] - Activity Sub Type - Multiselect
                if(claimIdList.size()>0) {
                    // Highlight Unused Local Variable - TWC3117-18226
                   // List<ContentDocumentLink> docLink = [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN:claimIdList]; //POP                   
                    
                    pfcListWithActivityCampaign =  [SELECT Id,Core_MDF_Excess_Requested_Amount__c,ChannelPartnerId,Core_MDF_Invoice_Date__c,Core_MDF_Audit_Type__c,CreatedDate,Amount,
                                                    Core_MDF_Claim_Ref_Number__c,Core_MDF_Exchange_rate__c,Core_MDF_Currency__c,LastModifiedById,
                                                    Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Taxes_Local__c,CreatedById, Core_MDF_Program__c,
                                                    Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Invoice_Number__c,
                                                    RequestId,Request.CampaignId,Core_MDF_Country_Location_nm__c,Request.Core_MDF_Start_Date__c,
                                                    Request.Core_MDF_End_Date__c,Request.Core_MDF_ActivityCategory__c,Request.Core_MDF_TargetAudience__c,
                                                    Request.Core_MDF_Priorities__c,Core_MDF_Brand_nm__c, Request.Core_MDF_ProductType__c,
                                                    Request.Core_MDF_Activity_Types__c, Request.Title, Request.Core_MDF_Channel_Partner_Led__c,
                                                    Request.Campaign.Core_MDF_Technology__c,Request.Campaign.StartDate,
                                                    Request.Campaign.EndDate, Request.Campaign.Name, Core_MDF_Total_Claim_Offsets__c,
                                                    Core_MDF_Reimbursement_Percent__c, Core_MDF_Claim_Review_Case__c, OwnerId,
                                                    Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_AccountCompany__c, Core_MDF_Status__c,
                                                    Request.Core_MDF_Budget_Type_nm__c, Request.Core_MDF_Activity_SubType_nm__c, 
                                                    ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
                                                    ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Region_Cd__c, 
                                                    Core_MDF_Sub_Region_Cd__c, Core_MDF_Audit_Hold__c,Core_MDF_FlaggedForAudit__c, 
                                                    LastModifiedBy.Profile.Name,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,
                                                    Core_MDF_Media_Vehicle__c, ChannelPartner.Core_MDF_Group_Id__c,
                                                    ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,
                                                    Core_MDF_Reimbursable_TransactionAmt_Loc__c,Core_MDF_Document_Hold_Ind__c,
                                                    Request.Campaign.Core_MDF_Strategic_Marketing_Fund_Ind__c,Core_MDF_Activity_SubType_nm__c,
                                                    Core_MDF_Doc_Hold_to_Review_Hold_Ind__c,Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c,Core_MDF_Document_Submission_Missed_Ind__c 
                                                    FROM PartnerFundClaim where Id IN:claimIdList];  
                    
                    pfcMapWithActivityCampaign = new Map<Id,PartnerFundClaim>(pfcListWithActivityCampaign);
                    
                    if(accountIdSet != NULL && accountIdSet.Size() > 0 && programIdSet != NULL && programIdSet.Size() > 0){
                        for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id,Core_MDF_Group_Id__c, Core_MDF_Account__c,
                                                                     Core_MDF_Type_of_Access__c, Core_MDF_Channel_Program__c, 
                                                                     Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c
                                                                     FROM Core_MDF_Partner_Group_Mapping__c 
                                                                     WHERE Core_MDF_Account__c IN : accountIdSet AND
                                                                     Core_MDF_Inactive_Ind__c = false AND 
                                                                     Core_MDF_Channel_Program__c IN : programIdSet AND 
                                                                     Core_MDF_Type_of_Access__c = 'INTERNAL']){
                                                                         if(pgm.Core_MDF_Region_cd__c == 'WW'){
                                                                             pgmRegion = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                                                                             geoGroupIdMap.put(pgmRegion,pgm.Core_MDF_Group_Id__c);
                                                                         }
                                                                         
                                                                         if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                                                                             pgmSubRegion = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                                                                             geoGroupIdMap.put(pgmSubRegion,pgm.Core_MDF_Group_Id__c);
                                                                         }else{
                                                                             pgmRegion = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                                                                             geoGroupIdMap.put(pgmRegion,pgm.Core_MDF_Group_Id__c);
                                                                         }
                                                                     }
                    }
                    
                    //POP 
                    // Added new Case Review Document Fields
                    for(Core_MDF_Audit_Document__c auditDoc: [SELECT Id, Core_MDF_Document_Id__c, Core_MDF_Document_Title__c, 
                                                              Core_MDF_App_Document_Types_nm__c, Core_MDF_Applicable_Document_Types_txt__c, 
                                                              Core_MDF_Selected_Document_Types_txt__c, Core_MDF_Document_Types__c,
                                                              Core_MDF_Claim__c,Core_MDF_Audit__c
                                                              FROM Core_MDF_Audit_Document__c
                                                              WHERE Core_MDF_Claim__c IN:claimIdList ]){
                                                                  if(claimIdWithConDocId.containsKey(auditDoc.Core_MDF_Claim__c)) {
                                                                      claimIdWithConDocId.get(auditDoc.Core_MDF_Claim__c).add(auditDoc);
                                                                  }
                                                                  else{
                                                                      List<Core_MDF_Audit_Document__c> tempIdList = new List<Core_MDF_Audit_Document__c>();
                                                                      tempIdList.add(auditDoc);
                                                                      claimIdWithConDocId.put(auditDoc.Core_MDF_Claim__c,tempIdList);
                                                                  }   
                                                              }
                }
                //Map to store the IDs of the PartnerFundClaim records and their corresponding Case records.
                Map<Id, Id> claimIdandCaseIdMap = new Map <Id, Id>();

                //Roshan - Manual Audit for Cancelled Case
                Set<Id> cancelledCaseIdSet = new Set<Id>();
                List<Case> cancelledCasesToBeUpdated = new List<Case>();

                if(pfcListWithActivityCampaign.size() > 0) {
                    
                    //quering the case object where claimId should be in the set 
                    for (Case caseRec : [SELECT Id, Core_MDF_Claim_ID__c, Core_MDF_Status__c FROM Case WHERE Core_MDF_Claim_ID__c IN :pfcMapWithActivityCampaign.keySet() limit 50000]) {
                       claimIdandCaseIdMap.put(caseRec.Core_MDF_Claim_ID__c, caseRec.Id);

                       //Roshan - Manual Audit for Cancelled Case
                       if(caseRec.Core_MDF_Status__c == 'Cancelled'){ cancelledCaseIdSet.add(caseRec.Id); }
                    }
                    //Ealisha-start
                    Map<string,integer> daysSLAInputMap = new Map<string,integer>{};
                        Map<string,integer> daysSLAOutputMap = new Map<string,integer>{};
                                    Map<id,string> claimIdToKeyMap = new Map<id,string>{};
                                        
                                        for(PartnerFundClaim claim: pfcListWithActivityCampaign){
                                            string key;
                                            key= claim.Core_MDF_Program__c+':';
                                            //Added for IPA Audit
                                            // ATHR Fix: TWC3117-18226
                                            key += (claim.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')) ? 'NA:' : ((claim.Request.Core_MDF_Budget_Type_nm__c == '' || claim.Request.Core_MDF_Budget_Type_nm__c == NULL ? 'NA' : claim.Request.Core_MDF_Budget_Type_nm__c) + ':');                                            

                                            key += wMap.get(claim.Core_MDF_Country_Location_nm__c).geo + ':' + wMap.get(claim.Core_MDF_Country_Location_nm__c).subGeo + ':' + claim.Core_MDF_Country_Location_nm__c + ':';
                                             // ATHR Fix: TWC3117-18226
                                            key += (claim.Request.Core_MDF_Budget_Type_nm__c == 'RSA MD') ? claim.Request.Core_MDF_End_Date__c.format() : system.now().date().format();

                                            key = key.deleteWhitespace();
                                            
                                            daysSLAInputMap.put(key,0);
                                            claimIdToKeyMap.put(claim.Id,key);
                                        }
                    daysSLAOutputMap = Core_MDF_ProcessClaimSubmissionClosure.getDaysSLA(daysSLAInputMap);
                    //Ealisha-end
                    
                    //US591129, US591133: Case SLA, Submission SLA Program Based
                    //Query the Claim Window Metadata to populate the Case SLA and Submission SLA values based on programs
                    //if(programBudgetTypeToSubmissionSLAMap.size()==0 || programBudgetTypeToCaseSLAMap.size()==0) {queryForProgramBasedSLAs();}
                    
                    for(PartnerFundClaim pfc: pfcListWithActivityCampaign) {
                        if(claimIdandCaseIdMap!=NULL && claimIdandCaseIdMap.containsKey(pfc.Id)){
                            PartnerFundClaim claimToUpdate = new PartnerFundClaim(Id = pfc.Id, Core_MDF_Claim_Review_Case__c = claimIdandCaseIdMap.get(pfc.Id));
                            claimListToBeUpdatedWithCaseId.add(claimToUpdate);

                            //Roshan - Manual Audit for Cancelled Case
                            if(cancelledCaseIdSet.contains(claimIdandCaseIdMap.get(pfc.Id))){
                                cancelledCasesToBeUpdated.add(new Case(Id = claimIdandCaseIdMap.get(pfc.Id), RecordTypeId = reviewCaseRecordTypeId, Status = Core_MDF_CCP_ConstantClass.CASE_OPEN, Core_MDF_Status__c = 'Under Review', Origin = 'Manual'));
                            }

                            continue;
                        }
                        //Ealisha-start
                        string key = claimIdToKeyMap.get(pfc.Id);
                        //Ealisha-end 
                        //String caseOrigin = getCaseOrigin(pfc.Core_MDF_Audit_Type__c);
                        Case caseObj = new Case();
                        caseObj.RecordTypeId = reviewCaseRecordTypeId;
                        //caseObj.Core_MDF_Status__c = 'Pending Documents';
                        caseObj.AccountId = pfc.ChannelPartnerId;
                        caseObj.Core_MDF_Country_Region__c = pfc.Core_MDF_Country_Location_nm__c;
                        caseObj.Core_MDF_Claim_ID__c = pfc.Id;
                        caseObj.Core_MDF_Activity_Start_and_End_Date__c = getActivityStartAndEndDate(pfc.Request.Core_MDF_Start_Date__c,pfc.Request.Core_MDF_End_Date__c);
                        caseObj.Core_MDF_Invoice_Date__c = pfc.Core_MDF_Invoice_Date__c;
                        caseObj.Origin = pfc.Core_MDF_Audit_Type__c;
                        caseObj.Core_MDF_AuditType_nm__c = pfc.Core_MDF_Audit_Type__c;
                        //As per US742525, setting Claim Case Reviewer Field value to claims LastModifiedById if audit type is manual
                        //Added custom setting check to enable/disable functionality
                        if((customSettingsMap.containsKey('Core_MDF_Case_Reviewer_Update') && customSettingsMap.get('Core_MDF_Case_Reviewer_Update').Core_Active__c) 
                           && (('Manual').equals(pfc.Core_MDF_Audit_Type__c)) && (!standardProfiles.contains(Pfc.LastModifiedBy.Profile.Name))){
                               caseObj.Core_MDF_Claim_Case_Reviewer_Lookup__c = pfc.LastModifiedById; 
                           }
                        caseObj.Core_MDF_Campaign_Start_Date__c = pfc.Request.Campaign.StartDate;
                        caseObj.Core_MDF_Campaign_End_Date__c = pfc.Request.Campaign.EndDate;
                        caseObj.Core_MDF_Activity_Start_Date__c = pfc.Request.Core_MDF_Start_Date__c;
                        caseObj.Core_MDF_Activity_End_Date__c = pfc.Request.Core_MDF_End_Date__c;
                        caseObj.Core_MDF_Activity_Category__c = pfc.Request.Core_MDF_ActivityCategory__c;
                        caseObj.Core_MDF_Target_Audience__c = pfc.Request.Core_MDF_TargetAudience__c;
                        caseObj.Core_MDF_Priority__c = pfc.Request.Core_MDF_Priorities__c;
                        caseObj.Core_MDF_Brand_nm__c = pfc.Core_MDF_Brand_nm__c;
                        caseObj.Core_MDF_Product_Type__c = pfc.Request.Core_MDF_ProductType__c;
                        caseObj.Core_MDF_Claim_Date__c = pfc.CreatedDate.date();
                        caseObj.Core_MDF_Claim_Amount_USD__c = pfc.Amount;
                        caseObj.Core_MDF_Activity_Type__c = pfc.Request.Core_MDF_Activity_Types__c;
                        caseObj.Core_MDF_Technology__c = pfc.Request.Campaign.Core_MDF_Technology__c;
                        caseObj.Core_MDF_Claim_Number__c = pfc.Core_MDF_Claim_Ref_Number__c;
                        caseObj.Core_MDF_Activity_ID__c = pfc.RequestId;
                        caseObj.Core_MDF_Campaign_ID__c = pfc.Request.CampaignId;
                        caseObj.Core_MDF_ActivityName__c = pfc.Request.Title;
                        //As per US399543, setting Channel Partner Led on Case
                        caseObj.Core_MDF_Channel_Partner_Led_ind__c = pfc.Request.Core_MDF_Channel_Partner_Led__c;
                        //As per US439129, setting Total Offset Amount on Case
                        //caseObj.Core_MDF_Total_Offset_Amount_amt__c = pfc.Core_MDF_Total_Claim_Offsets__c;
                        //As per US420255, setting Core_MDF_Channel_Program_txt__c on Case
                        caseObj.Core_MDF_Channel_Program_txt__c = pfc.Core_MDF_Program__c;
                        //As per US296735, setting Invoice/Receipt Number on Case
                        caseObj.Core_MDF_Invoice_Number_txt__c = pfc.Core_MDF_Invoice_Number__c;
                        caseObj.Core_MDF_CampaignName__c = pfc.Request.Campaign.Name;
                        caseObj.Core_MDF_Pending_Document_Flag__c = 0;
                        caseObj.Core_MDF_Claim_Conversion_Exchange_Rate__c = pfc.Core_MDF_Exchange_rate__c;
                        caseObj.Core_MDF_Claim_Local_Currency__c = pfc.Core_MDF_Currency__c;
                        caseObj.Core_MDF_OtherCostsnotReimbursableLocal__c = pfc.Core_MDF_OtherCostsnotReimbursable_Local__c;
                        caseObj.Core_MDF_Claim_Taxes_Local__c = pfc.Core_MDF_Taxes_Local__c;
                        caseObj.Core_MDF_Claim_Submitter__c = pfc.OwnerId;
                        caseObj.Core_MDF_Adjustment_Amount_Local__c = pfc.Core_MDF_Audit_Adjustment_Amount__c;
                        //String reimursmentRate = pfc.Request.Campaign.Core_MDF_Reimbursement_Rate__c;
                        //Based on US374024, replaced "Request.Campaign.Core_MDF_Reimbursement_Rate__c" with "Core_MDF_Reimbursement_Percent__c".
                        String reimursmentRate = pfc.Core_MDF_Reimbursement_Percent__c;
                        //Based on DE46820, replaced "Integer" with "Decimal"
                        caseObj.Core_MDF_Reimbursement_Rate__c = Decimal.valueof(reimursmentRate.left(reimursmentRate.length()-1));
                        caseObj.Core_MDF_TotalTransactionAmountLocal__c = pfc.Core_MDF_Total_Invoice_Amount_Local__c;
                        //US952018: [Opal & SPCF] - Case- Display Strategic Marketing Fund Checkbox
                        caseObj.Core_MDF_Strategic_Marketing_Fund_Ind__c=pfc.Request.Campaign.Core_MDF_Strategic_Marketing_Fund_Ind__c;
                        //US1100385: [OEM Integration] - [POP Selection] - Edit of Doc Hold Claim
                        caseObj.Core_MDF_Doc_Hold_to_Review_Hold_Ind__c = pfc.Core_MDF_Doc_Hold_to_Review_Hold_Ind__c;
                        //US1107779: [WW42] - [PIC Review Process] - New intermediate Status in Case
                        caseObj.Core_MDF_Claim_Lookup_Id__c = pfc.id;
                        //NK:2022WW42 - Populate the excess Reimbursement Amt in Case from Claim
                        caseObj.Core_MDF_Excess_Requested_Amt__c = pfc.Core_MDF_Excess_Requested_Amount__c;
                        
                        //As per US311550, populating Region on Case.
                        if(pfc.Core_MDF_Country_Location_nm__c != null && 
                           wMap.containsKey(pfc.Core_MDF_Country_Location_nm__c) && 
                           wMap.get(pfc.Core_MDF_Country_Location_nm__c) != NULL) {
                               caseObj.Core_MDF_Region_SubRegion_txt__c = wMap.get(pfc.Core_MDF_Country_Location_nm__c).geo+' - '+wMap.get(pfc.Core_MDF_Country_Location_nm__c).subGeo;
                           }
                        // JV-Accenture: Populating the new field Requested Amount USD on Case same as the Requested Amount on the Claim:
                        caseObj.Core_MDF_Requested_Amount_USD_Amt__c = pfc.Core_MDF_Requested_Reimbursement_Amt__c;
                        //SN-Accenture: As per US499686, setting Account(Company) field on Case by fetching from Claim
                        caseObj.Core_MDF_AccountCompany_txt__c  = pfc.Core_MDF_AccountCompany__c;
                        
                        // US591129, US591133: Case SLA, Submission SLA Program Based
                        // US949927, NK : Budget type consolidation for case
                        caseObj.Core_MDF_Budget_Type_nm__c = pfc.Request.Core_MDF_Budget_Type_nm__c;
                         // ATHR Fix: TWC3117-18226
                        taxes = (pfc.Core_MDF_Taxes_Local__c == NULL) ? 0.00 : pfc.Core_MDF_Taxes_Local__c;
                        othercosts = (pfc.Core_MDF_OtherCostsnotReimbursable_Local__c == NULL) ? 0.00 : pfc.Core_MDF_OtherCostsnotReimbursable_Local__c;

                        //NK-Intel : Populating the mutilplication of reimbtransactamt and rr and storing it in variable to avoid the validation erro
                        caseObj.Core_MDF_CalcReimbursableAmountLocal_amt__c = (pfc.Core_MDF_Total_Invoice_Amount_Local__c - taxes - othercosts) * (caseObj.Core_MDF_Reimbursement_Rate__c/100);                 
                        caseObj.Core_MDF_SLA_Days_Nbr__c = (daysSLAOutputMap!=null && daysSLAOutputMap.containsKey(key)) ? daysSLAOutputMap.get(key) : null;                        
                        //Ealisha-end
                        
                        //As per US689618, populating Activity sub type on Case.
                        //US977959: [OEM Integration] - [Case] - Activity Sub Type - Multiselect - Populating Activity Sub Type from Claim
                        if(pfc.Core_MDF_Activity_SubType_nm__c != null){
                            caseObj.Core_MDF_Activity_Sub_Type_nm__c = pfc.Core_MDF_Activity_SubType_nm__c;
                        }
                        
                        //Update PGM group on Case
                        List<String> groupIdList = new List<String>();
                        Boolean isNodeBasedSharingReqd = Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(pfc.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                        if(!isNodeBasedSharingReqd){
                            accCPSubGeo = pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)pfc.ChannelPartner.Core_MDF_Channel_Program__c + pfc.Core_MDF_Region_Cd__c + pfc.Core_MDF_Sub_Region_Cd__c;
                            accCPGeo = pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)pfc.ChannelPartner.Core_MDF_Channel_Program__c +pfc.Core_MDF_Region_Cd__c;
                            accCP = pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)pfc.ChannelPartner.Core_MDF_Channel_Program__c;
                            
                            if(geoGroupIdMap.containsKey(accCPSubGeo) && geoGroupIdMap.get(accCPSubGeo) != NULL){
                                groupIdList.add(geoGroupIdMap.get(accCPSubGeo));
                            }
                            
                            if(geoGroupIdMap.containsKey(accCPGeo) && geoGroupIdMap.get(accCPGeo) != NULL){
                                groupIdList.add(geoGroupIdMap.get(accCPGeo));
                            }
                            
                            if(geoGroupIdMap.containsKey(accCP) && geoGroupIdMap.get(accCP) != NULL){
                                groupIdList.add(geoGroupIdMap.get(accCP));
                            }
                        }else if(pfc.ChannelPartner.Core_MDF_Group_Id__c != NULL){
                            groupIdList.add(pfc.ChannelPartner.Core_MDF_Group_Id__c);
                        }
                        
                        if(groupIdList != NULL && groupIdList.Size() > 0){
                            caseObj.Core_MDF_PGM_Internal_Group_Id_txt__c = String.join(groupIdList, ';');
                        }
                        
                        /*US726293 Show Media Vehicle, Ad Run Start and Ad run end date in Case START */ 
                        caseObj.Core_MDF_Media_Vehicle_txt__c = pfc.Core_MDF_Media_Vehicle__c;
                        caseObj.Core_MDF_Ad_Run_Start_Date_dt__c = pfc.Core_MDF_Ad_Run_Start_Date__c;
                        caseObj.Core_MDF_Ad_Run_End_Date_dt__c = pfc.Core_MDF_Ad_Run_End_Date__c;
                        /*US726293 Show Media Vehicle, Ad Run Start and Ad run end date in Case END */
                        
                        
                        reviewCasesToBeCreatedList.add(caseObj);  
                        
                        //WW09 - Scorecard Changes
                        if(pfc.Core_MDF_Document_Submission_Missed_Ind__c){
                            zvScorecardClaims.add(pfc.id);
                            caseObj.RecordTypeId = reviewCaseClosedRecordTypeId;
                            caseObj.Core_MDF_Status__c= 'Review Completed';
                            caseObj.Core_MDF_Review_Case_Status__c= 'Review Completed';
                            caseObj.Status= 'Closed';
                            caseObj.Core_MDF_Closure_Note_txt__c = caseObj.Core_MDF_Channel_Program_txt__c == 'Intel Partner Alliance'?Label.Core_MDF_Case_Closure_Notes_for_IPA : caseObj.Core_MDF_Channel_Program_txt__c == 'Retail Marketing Funds'?Label.Core_MDF_Case_Closure_Notes_for_Retail:Label.Core_MDF_NonCompliantStatusReason;
                            caseObj.Core_MDF_Right_to_Recover_Amt__c = pfc.Core_MDF_Requested_Reimbursement_Amt__c;
                        }
                        
                       
                    }
                }

                //Roshan - Manual Audit for Cancelled Case
                if(cancelledCasesToBeUpdated.size() > 0) {
                    Database.SaveResult[] cancelledCaseUpdateResults = Database.update(cancelledCasesToBeUpdated, false);
                    //Added for CDB Changes
                     for (Database.SaveResult sr : cancelledCaseUpdateResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            caseIdSetForAIAudit.add(sr.getId());
                        }
                    }      
                    insertLogEntryRecord(cancelledCaseUpdateResults);
                }

                if(reviewCasesToBeCreatedList.size() > 0) {
                    
                    //calling this method to validate document types and set case status based on doctypes selected
                    validateAuditDocuments(reviewCasesToBeCreatedList, claimIdWithConDocId, 'CreateCases');
                    //US949837 - Added extra condition to fix checkmarx issues
                    // if(Schema.sObjectType.Case.isCreateable()){
                    Database.SaveResult[] srList = Database.insert(reviewCasesToBeCreatedList, false);
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            caseIdSetForAIAudit.add(sr.getId());
                        }
                    }             
                    //Calling insertLogEntryRecord method to insert log entry for failed record
                    insertLogEntryRecord(srList);
                    // }
                    //Creating Scorecard
                    createScoreCard(reviewCasesToBeCreatedList);
                    
                    //Creating Checklist Items for Case
                    createChecklistItems(reviewCasesToBeCreatedList);
                    
                    //calling this method to attach documents while case creation
                    insertAuditDocuments(reviewCasesToBeCreatedList, claimIdWithConDocId);
                    
                    List<Id> caseIdList = new List<Id>();
                    
                    for(Case caseObj : reviewCasesToBeCreatedList) {
                        caseIdList.add(caseObj.id);
                        PartnerFundClaim pfcObj = pfcMapWithActivityCampaign.get(caseObj.Core_MDF_Claim_ID__c);
                        pfcObj.Core_MDF_Claim_Review_Case__c = caseObj.Id;
                        if(!pfcMapWithActivityCampaign.get(caseObj.Core_MDF_Claim_ID__c).Core_MDF_FlaggedForAudit__c){
                            //WW09 - Scorecard Changes
                            //pfcObj.Core_MDF_Audit_Type__c = 'Random';            
                            pfcObj.Core_MDF_FlaggedForAudit__c = TRUE;
                            //pfcObj.Core_MDF_Status__c = 'Hold';
                            pfcObj.Core_MDF_Audit_Hold__c = pfcObj.Core_MDF_Document_Submission_Missed_Ind__c ? FALSE : TRUE;
                        }
                        claimListToBeUpdatedWithCaseId.add(pfcObj);  
                    }
                    if(caseIdList.size()>0) {
                        Core_MDF_AuditCaseProcess.auditCaseAssignment(caseIdList);
                    }
                    
                }
               
                //US949837 - Added extra condition to fix checkmarx issues
                //  if(claimListToBeUpdatedWithCaseId.size() > 0 && Schema.sObjectType.PartnerFundClaim.isUpdateable()) {
                if(claimListToBeUpdatedWithCaseId.size() > 0) {
                    Database.SaveResult[] srLst = Database.update(claimListToBeUpdatedWithCaseId, false);
                    
                    //Calling insertLogEntryRecord method to insert log entry for failed record
                    insertLogEntryRecord(srLst);
                }
            }
            // for updating a case
            if(executionReason == 'UpdateCases') {
                Map<Id,Case> claimIDWithCase = new Map<Id,Case>();
                List<Id> claimIdList = new List<Id>();
                List<Case> caseListForUpdation = new List<Case>();
                Set<Id> activityEndDateUpdatedCaseIds = new Set<Id>();//Audit changes
                Date aiEnableDate = Date.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_AI_Audit_Enable_Date')?.Core_MDF_Value_Txt__c);//Audit changes
                
                //Collecting user LanguageLocaleKey to update claim submitter language
                Map<Id,User> userIdLocaleMap = new Map<Id,User>();
                Map<Id,List<Core_MDF_Audit_Document__c> > claimIdWithConDocId = new Map<Id,List<Core_MDF_Audit_Document__c> >(); //POP
                if(claimOwnerIdList != NULL && claimOwnerIdList.size()>0) { 
                    userIdLocaleMap = new Map<Id, User>([SELECT Id,LanguageLocaleKey FROM User where Id in: claimOwnerIdList]);
                }
                
                //Collecting all claim id's
                for(PartnerFundClaim pfc: scope) {
                    claimIdList.add(pfc.id);
                }
                
                //Constructing map of claim and case
                if(claimIdList.size() > 0) {
                  // Highlight Unused Local Variable - TWC3117-18226 
                  //  List<ContentDocumentLink> docLink = [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN:claimIdList]; //POP
                    for(Case cs: [SELECT Id,RecordTypeId,Core_MDF_Claim_ID__c,Core_MDF_Status__c,Core_MDF_Claim_Amount_USD__c,Core_MDF_Claim_Conversion_Exchange_Rate__c,
                                  Core_MDF_Channel_Program_txt__c,Core_MDF_Claim_Local_Currency__c,Core_MDF_Claim_Taxes_Local__c,Core_MDF_Invoice_Date__c,Core_MDF_OtherCostsnotReimbursableLocal__c,
                                  Core_MDF_TotalTransactionAmountLocal__c,Core_MDF_Total_Offset_Amount_amt__c, Core_MDF_Claim_Submitter__c, Core_MDF_Invoice_Number_txt__c,
                                  Core_MDF_Claim_Number__c,Core_MDF_More_Documentation_Required__c,Core_MDF_Activity_End_Date__c,CreatedDate FROM Case WHERE Core_MDF_Claim_ID__c IN :claimIdList]) {
                                      
                                      claimIDWithCase.put(cs.Core_MDF_Claim_ID__c, cs);
                                  }
                    
                    // Added new Case Review Document Fields
                    //POP
                    for(Core_MDF_Audit_Document__c auditDoc: [SELECT Id, Core_MDF_Document_Id__c, Core_MDF_Document_Title__c, 
                                                              Core_MDF_App_Document_Types_nm__c, Core_MDF_Applicable_Document_Types_txt__c, 
                                                              Core_MDF_Selected_Document_Types_txt__c, Core_MDF_Document_Types__c, 
                                                              Core_MDF_Claim__c,Core_MDF_Audit__c
                                                              FROM Core_MDF_Audit_Document__c
                                                              WHERE Core_MDF_Claim__c IN:claimIdList ]){
                                                                  // If any docs is uploaded from Claim Edit/Insert
                                                                  //if(auditDoc.Core_MDF_Claim__c != null && auditDoc.Core_MDF_Audit__c == null){
                                                                  if(claimIdWithConDocId.containsKey(auditDoc.Core_MDF_Claim__c)) {
                                                                      claimIdWithConDocId.get(auditDoc.Core_MDF_Claim__c).add(auditDoc);
                                                                  }
                                                                  else{
                                                                      List<Core_MDF_Audit_Document__c> tempIdList = new List<Core_MDF_Audit_Document__c>();
                                                                      tempIdList.add(auditDoc);
                                                                      claimIdWithConDocId.put(auditDoc.Core_MDF_Claim__c,tempIdList);
                                                                  }
                                                                  // }
                                                              }   
                }
                
                List<PartnerFundClaim> toBeUpdatedPfcList = new List<PartnerFundClaim>();
                
                //Iterating all the claims
                for(PartnerFundClaim pfc: scope) {
                     // ATHR Fix: TWC3117-18226
                    if(!claimIDWithCase.containsKey(pfc.Id)) continue;
                        Case caseObj = claimIDWithCase.get(pfc.Id);
                        
                        //WW09 - Scorecard Changes
                        if(caseObj.Core_MDF_Status__c != 'Compliant' && caseObj.Core_MDF_Status__c != 'Non-compliant' && caseObj.Core_MDF_Status__c != 'Cancelled' && caseObj.Core_MDF_Status__c != 'Review Completed') {
                         // ATHR fix - TWC3117-18226
                       caseObj.Core_MDF_Status__c = (pfc.Core_MDF_Status__c == 'Cancelled') ? pfc.Core_MDF_Status__c : caseObj.Core_MDF_Status__c;
                       caseObj.Core_MDF_Claim_Submitter__c = (pfc.OwnerId == caseObj.Core_MDF_Claim_Submitter__c) ? caseObj.Core_MDF_Claim_Submitter__c : pfc.OwnerId;
                       caseObj.Core_MDF_Claim_Submitter_Language__c = (pfc.OwnerId == caseObj.Core_MDF_Claim_Submitter__c) ? caseObj.Core_MDF_Claim_Submitter_Language__c : userIdLocaleMap.get(pfc.OwnerId).LanguageLocaleKey;
                            caseObj.Core_MDF_Claim_Amount_USD__c = pfc.Amount;
                            caseObj.Core_MDF_Claim_Conversion_Exchange_Rate__c = pfc.Core_MDF_Exchange_rate__c;
                            caseObj.Core_MDF_Claim_Local_Currency__c = pfc.Core_MDF_Currency__c;
                            caseObj.Core_MDF_Claim_Taxes_Local__c = pfc.Core_MDF_Taxes_Local__c;
                            caseObj.Core_MDF_Invoice_Date__c = pfc.Core_MDF_Invoice_Date__c;
                            caseObj.Core_MDF_OtherCostsnotReimbursableLocal__c = pfc.Core_MDF_OtherCostsnotReimbursable_Local__c;
                            caseObj.Core_MDF_TotalTransactionAmountLocal__c = pfc.Core_MDF_Total_Invoice_Amount_Local__c;
                            
                            //added to populate the updated offset Amount on case
                            //caseObj.Core_MDF_Total_Offset_Amount_amt__c = pfc.Core_MDF_Total_Claim_Offsets__c;
                            //added to populate updated Invoice Number on case
                            caseObj.Core_MDF_Invoice_Number_txt__c = pfc.Core_MDF_Invoice_Number__c;
                            // SN-Accenture: added to populate updated Claim Number on Case as per US535226
                            caseObj.Core_MDF_Claim_Number__c = pfc.Core_MDF_Claim_Ref_Number__c;
                            // JV-Accenture: Populating the new field Requested Amount USD on Case same as the Requested Amount on the Claim:
                            caseObj.Core_MDF_Requested_Amount_USD_Amt__c = pfc.Core_MDF_Requested_Reimbursement_Amt__c;
                            //NP - US700310: Sync up Activity fields on Case
                            caseObj.Core_MDF_Activity_Start_Date__c = pfc.Request.Core_MDF_Start_Date__c;
                            if(caseObj.Core_MDF_Activity_End_Date__c != pfc.Request.Core_MDF_End_Date__c && caseObj.CreatedDate>= aiEnableDate){
                                activityEndDateUpdatedCaseIds.add(caseObj.Id);
                            }
                            caseObj.Core_MDF_Activity_End_Date__c =pfc.Request.Core_MDF_End_Date__c;
                            caseObj.Core_MDF_ActivityName__c= pfc.Request.Title;
                            /*US726293 Show Media Vehicle, Ad Run Start and Ad run end date in Case START */ 
                            caseObj.Core_MDF_Media_Vehicle_txt__c = pfc.Core_MDF_Media_Vehicle__c;
                            caseObj.Core_MDF_Ad_Run_Start_Date_dt__c = pfc.Core_MDF_Ad_Run_Start_Date__c;
                            caseObj.Core_MDF_Ad_Run_End_Date_dt__c = pfc.Core_MDF_Ad_Run_End_Date__c;
                            /*US726293 Show Media Vehicle, Ad Run Start and Ad run end date in Case END */
                            caseObj.Core_MDF_Channel_Partner_Led_ind__c = pfc.Request.Core_MDF_Channel_Partner_Led__c;
                            caseObj.Core_MDF_Country_Region__c = pfc.Core_MDF_Country_Location_nm__c;
                            String reimursmentRate = pfc.Core_MDF_Reimbursement_Percent__c;
                            caseObj.Core_MDF_Reimbursement_Rate__c = Decimal.valueof(reimursmentRate.left(reimursmentRate.length()-1));
                            //US977959: [OEM Integration] - [Case] - Activity Sub Type - Multiselect
                            caseObj.Core_MDF_Activity_Sub_Type_nm__c = pfc.Core_MDF_Activity_SubType_nm__c;
                            //NK:2022WW42 - Populate the excess Reimbursement Amt in Case from Claim
                            caseObj.Core_MDF_Excess_Requested_Amt__c = pfc.Core_MDF_Excess_Requested_Amount__c;
                             // ATHR Fix: TWC3117-18226
                        taxes = (pfc.Core_MDF_Taxes_Local__c == NULL) ? 0.00 : pfc.Core_MDF_Taxes_Local__c;
                        othercosts = (pfc.Core_MDF_OtherCostsnotReimbursable_Local__c == NULL) ? 0.00 : pfc.Core_MDF_OtherCostsnotReimbursable_Local__c;
                            //caseObj.Core_MDF_Channel_Program_nm__c = pfc.Core_MDF_Program__c;
                            //NK-Intel : Populating the mutilplication of reimbtransactamt and rr and storing it in variable to avoid the validation error
                            caseObj.Core_MDF_CalcReimbursableAmountLocal_amt__c = (pfc.Core_MDF_Total_Invoice_Amount_Local__c - taxes - othercosts) * (caseObj.Core_MDF_Reimbursement_Rate__c/100);
                            caseListForUpdation.add(caseObj);
                        }
                        
                        //Check if the case id is not popupated on claim
                        //Create instnace of claim and update claim with case id
                        if(pfc.Core_MDF_Claim_Review_Case__c == null) {
                            PartnerFundClaim tempPfc = new PartnerFundClaim();
                            tempPfc.Id =  pfc.Id;
                            tempPfc.Core_MDF_Claim_Review_Case__c = claimIDWithCase.get(pfc.Id).Id;
                            toBeUpdatedPfcList.add(tempPfc);
                        }

                }
                
                //Updating cases
                if(caseListForUpdation.size() > 0) {
                    
                    //calling this method to validate document types and set case status based on doctypes selected
                    validateAuditDocuments(caseListForUpdation, claimIdWithConDocId, 'UpdateCases');
                   
                    //US949837 - Added extra condition to fix checkmarx issues
                    // if(Schema.sObjectType.Case.isUpdateable()){
                    Database.SaveResult[] srList = Database.update(caseListForUpdation, false);
                    //Audit changes start
                    for (Database.SaveResult sr : srList) {
                         // ATHR Fix: TWC3117-18226
                        if(sr.isSuccess() && activityEndDateUpdatedCaseIds.contains(sr.getId())){
                             // Operation was successful, so get the ID of the record that was processed where Activity end date was updated
                                caseIdSetForAIAudit.add(sr.getId());
                            }
                        
                    } 
                    //Audit changes end
                    //Calling insertLogEntryRecord method to insert log entry for failed record
                    insertLogEntryRecord(srList);
                    //}                    
                    //calling this method to attach documents while case updation
                    insertAuditDocuments(caseListForUpdation, claimIdWithConDocId);
                    
                    
                }
                
                //Updating claims which does not have case id
                //US949837 - Added extra condition to fix checkmarx issues
                // if(toBeUpdatedPfcList.size() > 0 && Schema.sObjectType.PartnerFundClaim.isUpdateable()) {
                if (toBeUpdatedPfcList.size() > 0){
                    Database.SaveResult[] srList = Database.update(toBeUpdatedPfcList, false);
                    //Calling insertLogEntryRecord method to insert log entry for failed record
                    insertLogEntryRecord(srList);
                }
            }
        }
        catch(exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    // This method will return merged start date and end date as a string
    // input parameters : start date, end date
    public static String getActivityStartAndEndDate(Date activityStartDate, Date activityEndDate){
        return String.valueOf(activityStartDate.month()) + '/' + String.valueOf(activityStartDate.Day()) + '/' + String.valueOf(activityStartDate.year()) + ' and ' + String.valueOf(activityEndDate.month()) + '/' + String.valueOf(activityEndDate.Day()) + '/' + String.valueOf(activityEndDate.year());
    }
        
     /************************************************************************************************************
        Moved from Custom Metadata (Core_MDF_Checklist_Items__mdt) to Custom Object (Core_MDF_CCP_Custom_Metadata_Utility__c)
 
        Below are the field Mapping :
        DeveloperName  : Core_MDF_Name_Criteria__c
        Core_MDF_Category__c  : Check List
        Core_MDF_Active__c  : Core_MDF_Is_Active_Ind__c
        Core_MDF_Budget_Type_txt__c  : Core_MDF_Sub_Category__c
        Core_MDF_Checklist_Channel_Program_Txt__c  : Core_MDF_Program__c
        Core_MDF_Checklist_Label__c  : Core_MDF_Field_1_txt__c
        Core_MDF_Checklist_Type__c  : Core_MDF_Field_2_txt__c
        Core_MDF_Claim_Case_Review_Findings__c  :  Core_MDF_Field_3_txt__c
        Core_MDF_Description__c  : Core_MDF_Field_10_txt__c
        Core_MDF_Line_Number__c   : Core_MDF_Sort_Order_Nbr__c
       
        To Identity the Check Claim records in Core_MDF_CCP_Custom_Metadata_Utility__c Custom object used Core_MDF_Category__c
        Core_MDF_Category__c  : Check List
 
     *************************************************************************************************************/
    public static void createChecklistItems(List<case> cases){
        List<Core_MDF_Claim_Case_Checklist__c> toBeInserted = new List<Core_MDF_Claim_Case_Checklist__c>();
        set<string> channelProgram = new set<string>();
        //WW09 - Scorecard Changes
        List<Case> checklistCreationCases = new List<Case>();
        //WW09 - Generic Checklist Changes
        Trigger_Execution__mdt switchOnOrOff = Trigger_Execution__mdt.getInstance('Core_MDF_Generic_Checklist_Switch');
       
        try{
            //US527098: Checklist based on Programs
            for(case record: cases) {
                //WW09 - Scorecard Changes
                if(!zvScorecardClaims.contains(record.Core_MDF_Claim_Lookup_Id__c)){
                    channelProgram.add(record.Core_MDF_Channel_Program_txt__c);
                    checklistCreationCases.add(record);
                }
            }
           
            Map<string,List<Core_MDF_CCP_Custom_Metadata_Utility__c> > channelProgramToChecklistMetadataMap = queryChecklistMetadata(channelProgram);
           
            for(case caseRecord: checklistCreationCases) {
               
                //Get Checklist Items based on Program & Budget
                //WW09 - Generic Checklist Changes
                string programBTKey = caseRecord.Core_MDF_Channel_Program_txt__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')? caseRecord.Core_MDF_Channel_Program_txt__c+'null' : caseRecord.Core_MDF_Channel_Program_txt__c + caseRecord.Core_MDF_Budget_Type_Nm__c;
                string key = switchOnOrOff.Active__c ? 'All'+'null' : programBTKey;
                List<Core_MDF_CCP_Custom_Metadata_Utility__c> checklistMetadata = channelProgramToChecklistMetadataMap.get(key);
               
                //Loop through checklist records which are Program specific
                for(Core_MDF_CCP_Custom_Metadata_Utility__c checklistItem : checklistMetadata) {
                    Core_MDF_Claim_Case_Checklist__c record = new Core_MDF_Claim_Case_Checklist__c();
                    record.Core_MDF_Case_ID__c = caseRecord.id;
                    record.Core_MDF_Checklist_Category__c = checklistItem.Core_MDF_Field_2_txt__c;
                    record.Core_MDF_Checklist_Item__c= checklistItem.Core_MDF_Field_1_txt__c;
                    record.Core_MDF_Checklist_Description__c= checklistItem.Core_MDF_Field_10_txt__c;
                    record.Core_MDF_Checklist_Line_Number__c= checklistItem.Core_MDF_Sort_Order_Nbr__c;
                    record.Core_MDF_Claim_Case_Review_Findings__c = checklistItem.Core_MDF_Field_3_txt__c;
                    toBeInserted.add(record);
                }
            }
            //US949837 - Added extra condition to fix checkmarx issue
            //if(toBeInserted.size() > 0 && Schema.sObjectType.Core_MDF_Claim_Case_Checklist__c.isCreateable()) {
            if(toBeInserted.size() > 0 ){
                Database.SaveResult[] srList = Database.insert(toBeInserted, false);
            }
        }
       
        catch(exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
       
    }
    
    //This method is for creating ScoreCard record on Case creation
    public static void createScoreCard(List<Case> cases){
        //List<Core_MDF_Bulk_Transaction__e> updateRecordList = new List<Core_MDF_Bulk_Transaction__e>();
        List<Core_MDF_Scorecard__c> scorecardList = new List<Core_MDF_Scorecard__c>();
        try{
            for(case record: cases){
                if(record.id !=null)
                {
                Core_MDF_Scorecard__c scoreCard = new Core_MDF_Scorecard__c(Core_MDF_Case_Id__c=record.id);
                //WW09 - Scorecard Changes
                if(zvScorecardClaims.contains(record.Core_MDF_Claim_Lookup_Id__c)){
                    scoreCard.Core_MDF_Attribution_Nbr__c = '0';
                    scoreCard.Core_MDF_POP__c ='0';
                    scoreCard.Core_MDF_Engagement_Nbr__c='0';
                }
                scorecardList.add(scoreCard);
            }
               
            }
            if(scorecardList!=null && scorecardList.size()>0){
                Database.SaveResult[] srList = Database.insert(scorecardList, false);
                insertLogEntryRecord(srList); 
            }
            
        }
        catch(exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    //Ealay
    /************************************************************************************************************
        Moved from Custom Metadata (Core_MDF_Checklist_Items__mdt) to Custom Object (Core_MDF_CCP_Custom_Metadata_Utility__c)
 
        Below are the field Mapping :
        DeveloperName  : Core_MDF_Name_Criteria__c
        Core_MDF_Category__c  : Check List
        Core_MDF_Active__c  : Core_MDF_Is_Active_Ind__c
        Core_MDF_Budget_Type_txt__c  : Core_MDF_Sub_Category__c
        Core_MDF_Checklist_Channel_Program_Txt__c  : Core_MDF_Program__c
        Core_MDF_Checklist_Label__c  : Core_MDF_Field_1_txt__c
        Core_MDF_Checklist_Type__c  : Core_MDF_Field_2_txt__c
        Core_MDF_Claim_Case_Review_Findings__c  :  Core_MDF_Field_3_txt__c
        Core_MDF_Description__c  : Core_MDF_Field_10_txt__c
        Core_MDF_Line_Number__c   : Core_MDF_Sort_Order_Nbr__c
       
        To Identity the Bulk Claim records in Core_MDF_CCP_Custom_Metadata_Utility__c Custom object used Core_MDF_Category__c
        Core_MDF_Category__c  : Check List
 
     *************************************************************************************************************/
    public static Map<string,List<Core_MDF_CCP_Custom_Metadata_Utility__c> > queryChecklistMetadata(set<string> channelPrograms){
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> result = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        Map<string,List<Core_MDF_CCP_Custom_Metadata_Utility__c> > channelProgramtoChecklistMap = new Map<string,List<Core_MDF_CCP_Custom_Metadata_Utility__c> >();
        set<string> dynamicParam = new set<string>();
       
        try{
            //WW09 - Generic Checklist Changes
            Trigger_Execution__mdt switchOnOrOff = Trigger_Execution__mdt.getInstance('Core_MDF_Generic_Checklist_Switch');
           
            if(switchOnOrOff.Active__c){dynamicParam.add('All');}
            else{dynamicParam = new Set<string>(channelPrograms);}
           
            //US527098: Added Program + Budget filter
            result = [select Core_MDF_Category__c, Core_MDF_Sort_Order_Nbr__c,Core_MDF_Field_2_txt__c,Core_MDF_Name_Criteria__c,Core_MDF_Field_10_txt__c,Core_MDF_Field_3_txt__c
                      ,Core_MDF_Program__c
                      ,Core_MDF_Sub_Category__c, Core_MDF_Field_1_txt__c
                      from Core_MDF_CCP_Custom_Metadata_Utility__c
                      where Core_MDF_Is_Active_Ind__c=true
                      and Core_MDF_Category__c = 'CheckList'
                      and Core_MDF_Program__c in :dynamicParam
                      order by Core_MDF_Sort_Order_Nbr__c];
           
            //Creating Map for Channel Program + Budget to Checklist Records
            for(Core_MDF_CCP_Custom_Metadata_Utility__c metadataRecord:result) {
                string key = metadataRecord.Core_MDF_Program__c + metadataRecord.Core_MDF_Sub_Category__c;
                List<Core_MDF_CCP_Custom_Metadata_Utility__c> checklistList = channelProgramtoChecklistMap.get(key);
                if(checklistList == null) {
                    checklistList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
                    checklistList.add(metadataRecord);
                }
                else{
                    checklistList.add(metadataRecord);
                }
                channelProgramtoChecklistMap.put(key,checklistList);
            }
        }
       
        catch(exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
       
        return channelProgramtoChecklistMap;
    }
    
    // This method will insert log entry records for failed records
    public static void insertLogEntryRecord(Database.SaveResult[] srList){
        try{
            String errorMessage = '';
            for(Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage = errorMessage + err.getMessage()+ '\t';
                    }
                    errorMessage = errorMessage + '\n';
                }
            }
            if(!String.isBlank(errorMessage)) {
                String trimmedString = '';
                if(errorMessage.getChars().size() > 30000) {
                    trimmedString = errorMessage.substring(0, 30000);
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject(trimmedString,'Core_MDF_ClaimReviewCaseProcessHelper.execute');
                }
                else{
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorMessage,'Core_MDF_ClaimReviewCaseProcessHelper.execute');
                }
                
            }
        }
        catch(exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    //This method is for populating the Audit Documents on Case creation and Claim Edit
    public static void insertAuditDocuments(List<Case> cases, Map<Id,List<Core_MDF_Audit_Document__c> > claimIdWithConDocId){
        List<Core_MDF_Audit_Document__c> auditDocsToBeUpdted = new List<Core_MDF_Audit_Document__c>();
        List<ContentDocumentLink> conDocLinksToBeInserted = new List<ContentDocumentLink>();
         // Highlight Unused Local Variable - TWC3117-18226
      //  Set<Case> caseListToBeUpdated = new Set<Case>();
        
        try{
            //if(claimIdWithConDocId.size() > 0 && claimIdWithConDocId != null){
            for(Case caseObj : cases) {
                if(claimIdWithConDocId.containsKey(caseObj.Core_MDF_Claim_ID__c) &&
                   claimIdWithConDocId.get(caseObj.Core_MDF_Claim_ID__c) != null) {
                       //Create Audit Documents
                       //Create ContentDocument Link
                       for(Core_MDF_Audit_Document__c conDoc: claimIdWithConDocId.get(caseObj.Core_MDF_Claim_ID__c)) {
                           conDoc.Core_MDF_Audit__c = caseObj.Id;
                           auditDocsToBeUpdted.add(conDoc);
                           
                           ContentDocumentLink conDocLink = new ContentDocumentLink();
                           conDocLink.ContentDocumentId = conDoc.Core_MDF_Document_Id__c;
                           conDocLink.LinkedEntityId = caseObj.Id;
                           conDocLink.ShareType='I';
                           conDocLink.Visibility='AllUsers';
                           conDocLinksToBeInserted.add(conDocLink);
                       }   //end of inner for loop
                   }   //end of if
            }//end of for loop
            
            //Update Audit Document with Case Id :POP
            //US949837 - Added extra condition to fix checkmarx issues
            //if(auditDocsToBeUpdted.size() >0 && Schema.sObjectType.Core_MDF_Audit_Document__c.isUpdateable()) {
            if(auditDocsToBeUpdted.size() >0){
                Database.SaveResult[] srList1 = Database.update(auditDocsToBeUpdted, false);
            }
            //Insert Content Document Link for Cases :POP
            if(conDocLinksToBeInserted.size()>0) {
                Database.SaveResult[] srList2 = Database.insert(conDocLinksToBeInserted,false);
            }
            
        }//end of try block
        catch(exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    //This method is for validating the ddocument types of the Audit Documents on Case creation and Claim Edit and updating the status
    public static List<Case> validateAuditDocuments(List<Case> cases, Map<Id,List<Core_MDF_Audit_Document__c> > claimIdWithConDocId, String executionReason){
       // Highlight Unused Local Variable - TWC3117-18226
      //  List<Core_MDF_Audit_Document__c> auditDocsToBeUpdted = new List<Core_MDF_Audit_Document__c>();
      //  List<ContentDocumentLink> conDocLinksToBeInserted = new List<ContentDocumentLink>();
        Set<Case> caseSetToBeUpdated = new Set<Case>();
        List<Case> caseListToBeUpdated = new List<Case>();
        Map<Id,String> caseIdwithStatus = new Map<Id,String>();
        // Stores selected document types
        Set<String> selDocTypesSet = new Set<String>();
        // Stores Program, Document Type in a Map
        Map<String, Set<String>> popDocTypesMap = new Map<String, Set<String>>();
        // Stores the required document types for POP submission
        Set<String> reqDocTypesForSubmission = new Set<String>();
        
        //get the requiredDocTypes for POP Submission, Selected DocTypes, Active fields program wise from the metadata.
        for(Core_MDF_POP_Document_Types_Revamp__mdt popDocTypes : [SELECT Core_MDF_Program_nm__c, Core_MDF_Active_ind__c, Core_MDF_ReqforPOPSubmission_ind__c, 
                                                            Core_MDF_Document_Type_nm__c FROM Core_MDF_POP_Document_Types_Revamp__mdt WHERE 
                                                            Core_MDF_ReqforPOPSubmission_ind__c= true AND Core_MDF_Active_ind__c= true LIMIT 10000]){
                                                                if(popDocTypesMap.containsKey(popDocTypes.Core_MDF_Program_nm__c)){
                                                                    popDocTypesMap.get(popDocTypes.Core_MDF_Program_nm__c).add(popDocTypes.Core_MDF_Document_Type_nm__c);
                                                                }
                                                                else{
                                                                    popDocTypesMap.put(popDocTypes.Core_MDF_Program_nm__c, new Set<String>{popDocTypes.Core_MDF_Document_Type_nm__c});
                                                                }
                                                            }
        try{
            for(Case caseObj : cases) {
                        // Guard clause: skip cancelled cases or cases not in popDocTypesMap
                        // ATHR Fix: TWC3117-18226
                if(caseObj.Core_MDF_Status__c == 'Cancelled' || !popDocTypesMap.containsKey(caseObj.Core_MDF_Channel_Program_txt__c)) continue;
                    caseIdwithStatus.put(caseObj.Id,caseObj.Core_MDF_Status__c);
                    
                    //Set Case Status when Claim is saved with documents
                    if(claimIdWithConDocId.size() > 0 && claimIdWithConDocId != null &&
                       claimIdWithConDocId.containsKey(caseObj.Core_MDF_Claim_ID__c) &&
                       claimIdWithConDocId.get(caseObj.Core_MDF_Claim_ID__c) != null) {
                           for(Core_MDF_Audit_Document__c conDoc: claimIdWithConDocId.get(caseObj.Core_MDF_Claim_ID__c)) {                               
                               // adding the document type values to set
                               selDocTypesSet.addAll(conDoc.Core_MDF_Document_Types__c.split(';'));
                               
                               // adding the required document types for POP submission to a set
                               reqDocTypesForSubmission = popDocTypesMap.get(caseObj.Core_MDF_Channel_Program_txt__c);
                           } 
                           if(((executionReason == 'UpdateCases'  && caseObj.Core_MDF_More_Documentation_Required__c == false)
                               || executionReason == 'CreateCases') && reqDocTypesForSubmission.size() > 0 && 
                              (selDocTypesSet.containsAll(reqDocTypesForSubmission))){ 
                                  caseObj.Core_MDF_Status__c = caseObj.RecordTypeId == reviewCaseRecordTypeId?'Under Review': 'Review Completed';
                                  caseObj.Core_MDF_More_Documentation_Required__c = false;
                                  // ATHR fix - TWC3117-18226
                                  caseObj.Core_MDF_SLA_Start_Date__c = (caseIdwithStatus.get(caseObj.Id) == 'Pending Documents' || executionReason == 'CreateCases') ? System.now() : caseObj.Core_MDF_SLA_Start_Date__c;
                                      //Modified by Ealisha - US499699: [Case: SLA Calculation] - Refresh "Days SLA Remaining" at 5 am PST
                                      //caseObj.Core_MDF_SLA_Start_Date__c = setSLAStartDate();
                                     
                                  
                              }
                           //WW09 - Scorecard Changes
                           else if(executionReason == 'CreateCases'){caseObj.Core_MDF_Status__c = caseObj.RecordTypeId == reviewCaseRecordTypeId?'Pending Documents':'Review Completed';}
                           
                       }   //end of if
                    //Set Case Status when Claim is saved without any documents uploaded
                    else{
                        //WW09 - Scorecard Changes
                        caseObj.Core_MDF_Status__c = caseObj.RecordTypeId == reviewCaseRecordTypeId?'Pending Documents':'Review Completed';
                    }
                    caseSetToBeUpdated.add(caseObj);
                    caseListToBeUpdated.addAll(caseSetToBeUpdated);
                
            }//end of for loop
            
        }//end of try block
        catch(exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
        return caseListToBeUpdated;
    }
    
    global void finish(Database.BatchableContext batchContext) {    
        try{
            if(!caseIdSetForAIAudit.isEmpty()) {
	     Integer auditBatchsize = Integer.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_AI_Audit_Batch_Size')?.Core_MDF_Value_Txt__c);//Audit batch size
        
              //Invoke Audit AI Batch
                  if(!(Core_MDF_Claim_Utility.bypassCDBCalloutValidationCheck('Core_MDF_ProcessCasesWithAIForAudit','Core_MDF_Bypass_AI_CDB_CallForAudit'))) {
                        Core_MDF_Audit_AI_Integration auditAIIntegrationBatch = new Core_MDF_Audit_AI_Integration(caseIdSetForAIAudit);
                        Database.executeBatch(auditAIIntegrationBatch, auditBatchsize);
                    }
                }
        }
        catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
}