/****************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimReviewCaseProcessHelper
* Version     : 1.0
* Created Date: 03-28-2019
* Modification Log :
* Developer                                   Date                                             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture K Alka                          03/28/2019                    Created Core_MDF_ClaimReviewCaseProcessHelper for Case creation for claims flagged for review
* Accenture Kumar Thakur,Ankit A            06/12/2019                    Based on US374024, replaced Request.Campaign.Core_MDF_Reimbursement_Rate__c with Core_MDF_Reimbursement_Percent__c.
* Accenture Manasa                          07/16/2019                    As per US399543, setting Channel Partner Led on Case
* Intel - NP                                01/08/2019                    Added lines of code to populate Checklist items on Case creation
* Accenture Manasa                          08/22/2019                    As per US439129, setting Total Offset Amount on Case
* Intel - NP(11630236)                      09/13/2019                    In createChecklistItems(), #265 and #282 were removed from inside the For() loop
* Accenture - VK                            09/19/2019                    Modified #79 to update case with Claim's country instead of Activity
* Accenture - Manasa                        09/23/2019                    As per US420255, populating Channel Program on Case so that Program field can be added on New Case List View and sort LV based on Programs
* Accenture - Manasa                        09/26/2019                    As per US311550, populating Region value on Case so that Region field can be added on New Case List View and sort LV based on Region
* Accenture - Sugathri                      09/26/2019                    As per US296735, populating Invoice/Receipt Number on Case
* Accenture - Sugathri                      11/12/2019                    As per US499686, setting Account(Company) field on Case by fetching from Claim
* NP - 11630236(NP)                         12/11/2019                    US527098: Checklist based on Programs
* NP - 11630236(NP)                         7/02/2020                     US591129, US591133: Case SLA, Submission SLA Program Based
* NP - 11630236(NP)                         26/06/2020                    US700310: Sync up of Activity fields on Case
***************************************************************************************************************************************/
global class Core_MDF_ClaimReviewCaseProcessHelper implements Database.Batchable<sObject> {
    
    List<PartnerFundClaim> csList = new List<PartnerFundClaim>();
    public List<PartnerFundClaim> claimListObj;
    String executionReason;
    List<Id> claimOwnerIdList;
    
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
        String strQuery = '';
        strQuery = 'SELECT Id,ChannelPartnerId,Core_MDF_Invoice_Date__c,Core_MDF_Audit_Type__c,CreatedDate,Amount, Core_MDF_Claim_Ref_Number__c,Core_MDF_Exchange_rate__c,'
            + 'Core_MDF_Currency__c, Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Taxes_Local__c,CreatedById, Core_MDF_Program__c,Core_MDF_Audit_Adjustment_Amount__c,'
            + 'Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Invoice_Number__c, RequestId,Request.CampaignId,Core_MDF_Country_Location_nm__c,Request.Core_MDF_Start_Date__c,'
            + 'Request.Core_MDF_End_Date__c,Request.Core_MDF_ActivityCategory__c,Request.Core_MDF_TargetAudience__c,Request.Core_MDF_Priorities__c,Request.Core_MDF_Brand__c,'
            + 'Request.Core_MDF_ProductType__c,Request.Core_MDF_Activity_Types__c, Request.Title, Request.Core_MDF_Channel_Partner_Led__c, Request.Campaign.Core_MDF_Technology__c,'
            + 'Request.Campaign.StartDate,Request.Campaign.EndDate,Request.Campaign.Name, Core_MDF_Total_Claim_Offsets__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Claim_Review_Case__c,'
            + 'OwnerId,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_AccountCompany__c, Core_MDF_Status__c, Request.Core_MDF_Budget_Type_txt__c, Request.Core_MDF_Activity_SubType_nm__c,'
            + 'ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Region_Cd__c, Core_MDF_Sub_Region_Cd__c,'
            + 'Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c '
            + 'FROM PartnerFundClaim '+'WHERE Id IN :claimListObj';
        system.debug('strQuery@@@'+strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext batchContext, List<PartnerFundClaim> scope) {
        // logic starts
        try{
            // for creating a case
            if(executionReason == 'CreateCases') {
                List<Id> claimIdList = new List<Id>();
                List<PartnerFundClaim> pfcListWithActivityCampaign = new List<PartnerFundClaim>();
                Map<Id,PartnerFundClaim> pfcMapWithActivityCampaign;
                List<Case> reviewCasesToBeCreatedList = new List<Case>();
                List<PartnerFundClaim> claimListToBeUpdatedWithCaseId = new List<PartnerFundClaim>();
                Id reviewCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
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
                //system.debug('wmap@@@'+wMap);
                // checking review case on claim is null
                for(PartnerFundClaim pfc: scope) {
                    system.debug('pfc@@@'+pfc);
                    if(pfc.Core_MDF_Claim_Review_Case__c == NULL) {
                        claimIdList.add(pfc.id);
                        accountIdSet.add(pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
                        programIdSet.add(pfc.ChannelPartner.Core_MDF_Channel_Program__c);
                    }
                    
                }
                
                Map<Id,List<Core_MDF_Audit_Document__c> > claimIdWithConDocId = new Map<Id,List<Core_MDF_Audit_Document__c> >(); //POP
                //Based on US374024, replaced Request.Campaign.Core_MDF_Reimbursement_Rate__c with Core_MDF_Reimbursement_Percent__c inside SOQL.
                if(claimIdList.size()>0) {
                    List<ContentDocumentLink> docLink = [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN:claimIdList]; //POP
                    pfcListWithActivityCampaign =  [SELECT Id,ChannelPartnerId,Core_MDF_Invoice_Date__c,Core_MDF_Audit_Type__c,CreatedDate,Amount,
                                                    Core_MDF_Claim_Ref_Number__c,Core_MDF_Exchange_rate__c,Core_MDF_Currency__c,
                                                    Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Taxes_Local__c,CreatedById, Core_MDF_Program__c,
                                                    Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Invoice_Number__c,
                                                    RequestId,Request.CampaignId,Core_MDF_Country_Location_nm__c,Request.Core_MDF_Start_Date__c,
                                                    Request.Core_MDF_End_Date__c,Request.Core_MDF_ActivityCategory__c,Request.Core_MDF_TargetAudience__c,
                                                    Request.Core_MDF_Priorities__c,Request.Core_MDF_Brand__c, Request.Core_MDF_ProductType__c,
                                                    Request.Core_MDF_Activity_Types__c, Request.Title, Request.Core_MDF_Channel_Partner_Led__c, Request.Campaign.Core_MDF_Technology__c,
                                                    Request.Campaign.StartDate,Request.Campaign.EndDate,Request.Campaign.Name, Core_MDF_Total_Claim_Offsets__c,
                                                    Core_MDF_Reimbursement_Percent__c, Core_MDF_Claim_Review_Case__c,OwnerId,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_AccountCompany__c, Core_MDF_Status__c,
                                                    Request.Core_MDF_Budget_Type_txt__c, Request.Core_MDF_Activity_SubType_nm__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__c,
                                                    Core_MDF_Region_Cd__c, Core_MDF_Sub_Region_Cd__c, Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c
                                                    FROM PartnerFundClaim where Id IN:claimIdList];                                                                            
                    
                    pfcMapWithActivityCampaign = new Map<Id,PartnerFundClaim>(pfcListWithActivityCampaign);
                    
                    for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id,Core_MDF_Group_Id__c, Core_MDF_Account__c,
                                                                 Core_MDF_Type_of_Access__c, Core_MDF_Channel_Program__c, 
                                                                 Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c
                                                                 FROM Core_MDF_Partner_Group_Mapping__c 
                                                                 WHERE Core_MDF_Account__c IN : accountIdSet AND
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
                    
                    System.debug('geoGroupIdMap---' + geoGroupIdMap);
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
                    System.debug('claimIdWithConDocId: '+claimIdWithConDocId);
                }
                
                if(pfcListWithActivityCampaign.size() > 0) {
                    
                    //Ealisha-start
                    Map<string,integer> daysSLAInputMap = new Map<string,integer>{};
                    Map<string,integer> daysSLAOutputMap = new Map<string,integer>{};
                    Map<string,date> closureDateInputMap = new Map<string,date>{};
                    Map<string,date> closureDateOutputMap = new Map<string,date>{};
                    Map<id,string> claimIdToKeyMap = new Map<id,string>{};
                    for(PartnerFundClaim claim: pfcListWithActivityCampaign){
                        string key = claim.Core_MDF_Program__c+':'+
                            (claim.Request.Core_MDF_Budget_Type_txt__c == '' || claim.Request.Core_MDF_Budget_Type_txt__c == NULL ? 'NA': claim.Request.Core_MDF_Budget_Type_txt__c)+':'+
                            wMap.get(claim.Core_MDF_Country_Location_nm__c).geo+':'+
                            wMap.get(claim.Core_MDF_Country_Location_nm__c).subGeo+':'+
                            claim.Core_MDF_Country_Location_nm__c+':';
                        

                        if(claim.Request.Core_MDF_Budget_Type_txt__c!='RSA MD'){
							key=key+system.now().date().format();
						}
						else{
							key=key+claim.Request.Core_MDF_End_Date__c.format();
						}
                        key = key.deleteWhitespace();
                        system.debug('key-console----------------      '+key);
                        closureDateInputMap.put(key,null);
                        daysSLAInputMap.put(key,0);
                        claimIdToKeyMap.put(claim.Id,key);
                    }
                    closureDateOutputMap = Core_MDF_ProcessClaimSubmissionClosure.getDocSubDueDate(closureDateInputMap); 
                    daysSLAOutputMap = Core_MDF_ProcessClaimSubmissionClosure.getDaysSLA(daysSLAInputMap);
                    system.debug('closureDateOutputMap-----------    '+closureDateOutputMap);
                    system.debug('daysSLAOutputMap-----------    '+daysSLAOutputMap);
                    //Ealisha-end
                    
                    //US591129, US591133: Case SLA, Submission SLA Program Based
                    //Query the Claim Window Metadata to populate the Case SLA and Submission SLA values based on programs
                    //if(programBudgetTypeToSubmissionSLAMap.size()==0 || programBudgetTypeToCaseSLAMap.size()==0) {queryForProgramBasedSLAs();}
                    
                    for(PartnerFundClaim pfc: pfcListWithActivityCampaign) {
                        //Ealisha-start
                        string key = claimIdToKeyMap.get(pfc.Id);
                        //Ealisha-end
                        
                        System.debug('request data***'+pfc);
                        Case caseObj = new Case();
                        caseObj.RecordTypeId = reviewCaseRecordTypeId;
                        //caseObj.Core_MDF_Status__c = 'Pending Documents';
                        caseObj.AccountId = pfc.ChannelPartnerId;
                        caseObj.Core_MDF_Country_Region__c = pfc.Core_MDF_Country_Location_nm__c;
                        caseObj.Core_MDF_Claim_ID__c = pfc.Id;
                        caseObj.Core_MDF_Activity_Start_and_End_Date__c = getActivityStartAndEndDate(pfc.Request.Core_MDF_Start_Date__c,pfc.Request.Core_MDF_End_Date__c);
                        caseObj.Core_MDF_Invoice_Date__c = pfc.Core_MDF_Invoice_Date__c;
                        caseObj.Origin = getCaseOrigin(pfc.Core_MDF_Audit_Type__c);
                        caseObj.Core_MDF_Campaign_Start_Date__c = pfc.Request.Campaign.StartDate;
                        caseObj.Core_MDF_Campaign_End_Date__c = pfc.Request.Campaign.EndDate;
                        caseObj.Core_MDF_Activity_Start_Date__c = pfc.Request.Core_MDF_Start_Date__c;
                        caseObj.Core_MDF_Activity_End_Date__c = pfc.Request.Core_MDF_End_Date__c;
                        caseObj.Core_MDF_Activity_Category__c = pfc.Request.Core_MDF_ActivityCategory__c;
                        caseObj.Core_MDF_Target_Audience__c = pfc.Request.Core_MDF_TargetAudience__c;
                        caseObj.Core_MDF_Priority__c = pfc.Request.Core_MDF_Priorities__c;
                        caseObj.Core_MDF_Brand__c = pfc.Request.Core_MDF_Brand__c;
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
                        caseObj.Core_MDF_Total_Offset_Amount_amt__c = pfc.Core_MDF_Total_Claim_Offsets__c;
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
                        caseObj.Core_MDF_Budget_Type_Txt__c = pfc.Request.Core_MDF_Budget_Type_txt__c;
                        //string programAndBudget = pfc.Core_MDF_Program__c + (pfc.Request.Core_MDF_Budget_Type_txt__c == null? 'NA': pfc.Request.Core_MDF_Budget_Type_txt__c);
                        
                        //Ealisha-start
                        caseObj.Core_MDF_Document_Submission_DueDate_dtm__c =
                            (closureDateOutputMap!=null && closureDateOutputMap.containsKey(key)) ? 
                            DateTime.newInstance(Date.valueOf(closureDateOutputMap.get(key)), system.now().time()) : 
                            null; 
                        system.debug('Core_MDF_Document_Submission_DueDate_dtm__c:'+caseObj.Core_MDF_Document_Submission_DueDate_dtm__c);
                        
                        //caseObj.Core_MDF_Document_Submission_DueDate_dtm__c = datetime.now() + programBudgetTypeToSubmissionSLAMap.get(programAndBudget);                        
                        caseObj.Core_MDF_SLA_Days_Nbr__c = 
                            (daysSLAOutputMap!=null && daysSLAOutputMap.containsKey(key)) ? 
                            daysSLAOutputMap.get(key) : 
                            null;
                        system.debug('caseObj.Core_MDF_SLA_Days_Nbr__c:'+caseObj.Core_MDF_SLA_Days_Nbr__c);

                        //caseObj.Core_MDF_SLA_Days_Nbr__c = programBudgetTypeToCaseSLAMap.get(programAndBudget);
                        
                        //Ealisha-end
                        
                        //As per US689618, populating Activity sub type on Case.
                        if(pfc.Request.Core_MDF_Activity_SubType_nm__c != null){
                            caseObj.Core_MDF_Activity_Sub_Type_nm__c = pfc.Request.Core_MDF_Activity_SubType_nm__c;
                        }
                        
                        accCPSubGeo = pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)pfc.ChannelPartner.Core_MDF_Channel_Program__c + pfc.Core_MDF_Region_Cd__c + pfc.Core_MDF_Sub_Region_Cd__c;
                        accCPGeo = pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)pfc.ChannelPartner.Core_MDF_Channel_Program__c +pfc.Core_MDF_Region_Cd__c;
                        accCP = pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)pfc.ChannelPartner.Core_MDF_Channel_Program__c;
						List<String> groupIdList = new List<String>();
						                        
                        if(geoGroupIdMap.containsKey(accCPSubGeo) && geoGroupIdMap.get(accCPSubGeo) != NULL){
                            groupIdList.add(geoGroupIdMap.get(accCPSubGeo));
                        }
                        
                        if(geoGroupIdMap.containsKey(accCPGeo) && geoGroupIdMap.get(accCPGeo) != NULL){
                            groupIdList.add(geoGroupIdMap.get(accCPGeo));
                        }
                        
                        if(geoGroupIdMap.containsKey(accCP) && geoGroupIdMap.get(accCP) != NULL){
                            groupIdList.add(geoGroupIdMap.get(accCP));
                        }
                        
                        caseObj.Core_MDF_PGM_Internal_Group_Id_txt__c = String.join(groupIdList, ';');
                        
                        System.debug('caseObj***'+caseObj);
                        reviewCasesToBeCreatedList.add(caseObj);
                    }
                }
                
                if(reviewCasesToBeCreatedList.size() > 0) {
                    
                    //calling this method to validate document types and set case status based on doctypes selected
                    validateAuditDocuments(reviewCasesToBeCreatedList, claimIdWithConDocId, 'CreateCases');
                    
                    Database.SaveResult[] srList = Database.insert(reviewCasesToBeCreatedList, false);
                    System.debug('reviewCasesToBeCreatedList@@@ after case insertion'+reviewCasesToBeCreatedList);
                    //Calling insertLogEntryRecord method to insert log entry for failed record
                    insertLogEntryRecord(srList);
                    
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
                            pfcObj.Core_MDF_Audit_Type__c = 'Random';            
                            pfcObj.Core_MDF_FlaggedForAudit__c = TRUE;
                            pfcObj.Core_MDF_Status__c = 'Hold';
                            pfcObj.Core_MDF_Audit_Hold__c = TRUE;
                        }
                        claimListToBeUpdatedWithCaseId.add(pfcObj);
                        system.debug('claimListToBeUpdatedWithCaseId claim id to be updated:'+pfcObj.Id);
                        
                    }
                    if(caseIdList.size()>0) {
                        Core_MDF_AuditCaseProcess.auditCaseAssignment(caseIdList);
                    }
                    System.debug('reviewCasesToBeCreatedList***'+reviewCasesToBeCreatedList);
                    
                }
                System.debug('claimListToBeUpdatedWithCaseId***'+claimListToBeUpdatedWithCaseId);
                if(claimListToBeUpdatedWithCaseId.size() > 0) {
                    Database.SaveResult[] srLst = Database.update(claimListToBeUpdatedWithCaseId, false);
                    system.debug('srLst:'+srLst);
                    //Calling insertLogEntryRecord method to insert log entry for failed record
                    insertLogEntryRecord(srLst);
                }
            }
            // for updating a case
            if(executionReason == 'UpdateCases') {
                Map<Id,Case> claimIDWithCase = new Map<Id,Case>();
                List<Id> claimIdList = new List<Id>();
                List<Case> caseListForUpdation = new List<Case>();
                
                //Collecting user LanguageLocaleKey to update claim submitter language
                Map<Id,User> userIdLocaleMap = new Map<Id,User>();
                Map<Id,List<Core_MDF_Audit_Document__c> > claimIdWithConDocId = new Map<Id,List<Core_MDF_Audit_Document__c> >(); //POP
                if(claimOwnerIdList.size()>0) {
                    userIdLocaleMap = new Map<Id, User>([SELECT Id,LanguageLocaleKey FROM User where Id in: claimOwnerIdList]);
                }
                system.debug('userIdLocaleMap***'+userIdLocaleMap);
                
                //Collecting all claim id's
                for(PartnerFundClaim pfc: scope) {
                    claimIdList.add(pfc.id);
                }
                
                //Constructing map of claim and case
                if(claimIdList.size() > 0) {
                    List<ContentDocumentLink> docLink = [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN:claimIdList]; //POP
                    for(Case cs: [SELECT Id,Core_MDF_Claim_ID__c,Core_MDF_Status__c,Core_MDF_Claim_Amount_USD__c,Core_MDF_Claim_Conversion_Exchange_Rate__c,
                                  Core_MDF_Channel_Program_txt__c,Core_MDF_Claim_Local_Currency__c,Core_MDF_Claim_Taxes_Local__c,Core_MDF_Invoice_Date__c,Core_MDF_OtherCostsnotReimbursableLocal__c,
                                  Core_MDF_TotalTransactionAmountLocal__c,Core_MDF_Total_Offset_Amount_amt__c, Core_MDF_Claim_Submitter__c, Core_MDF_Invoice_Number_txt__c,
                                  Core_MDF_Claim_Number__c,Core_MDF_More_Documentation_Required__c FROM Case WHERE Core_MDF_Claim_ID__c IN :claimIdList]) {
                                      
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
                    if(claimIDWithCase.containsKey(pfc.Id)) {
                        Case caseObj = claimIDWithCase.get(pfc.Id);
                        System.debug('caseObj@@@'+caseObj);
                        if(caseObj.Core_MDF_Status__c != 'Compliant' && caseObj.Core_MDF_Status__c != 'Non-compliant' && caseObj.Core_MDF_Status__c != 'Cancelled') {
                            if(pfc.Core_MDF_Status__c == 'Cancelled') {
                                caseObj.Core_MDF_Status__c = pfc.Core_MDF_Status__c;
                            }
                            if(pfc.OwnerId != caseObj.Core_MDF_Claim_Submitter__c) {
                                caseObj.Core_MDF_Claim_Submitter__c = pfc.OwnerId;
                                caseObj.Core_MDF_Claim_Submitter_Language__c = userIdLocaleMap.get(pfc.OwnerId).LanguageLocaleKey;
                            }
                            caseObj.Core_MDF_Claim_Amount_USD__c = pfc.Amount;
                            caseObj.Core_MDF_Claim_Conversion_Exchange_Rate__c = pfc.Core_MDF_Exchange_rate__c;
                            caseObj.Core_MDF_Claim_Local_Currency__c = pfc.Core_MDF_Currency__c;
                            caseObj.Core_MDF_Claim_Taxes_Local__c = pfc.Core_MDF_Taxes_Local__c;
                            caseObj.Core_MDF_Invoice_Date__c = pfc.Core_MDF_Invoice_Date__c;
                            caseObj.Core_MDF_OtherCostsnotReimbursableLocal__c = pfc.Core_MDF_OtherCostsnotReimbursable_Local__c;
                            caseObj.Core_MDF_TotalTransactionAmountLocal__c = pfc.Core_MDF_Total_Invoice_Amount_Local__c;
                            //added to populate the updated offset Amount on case
                            caseObj.Core_MDF_Total_Offset_Amount_amt__c = pfc.Core_MDF_Total_Claim_Offsets__c;
                            //added to populate updated Invoice Number on case
                            caseObj.Core_MDF_Invoice_Number_txt__c = pfc.Core_MDF_Invoice_Number__c;
                            // SN-Accenture: added to populate updated Claim Number on Case as per US535226
                            caseObj.Core_MDF_Claim_Number__c = pfc.Core_MDF_Claim_Ref_Number__c;
                            // JV-Accenture: Populating the new field Requested Amount USD on Case same as the Requested Amount on the Claim:
                            caseObj.Core_MDF_Requested_Amount_USD_Amt__c = pfc.Core_MDF_Requested_Reimbursement_Amt__c;
                            
                            //NP - US700310: Sync up Activity fields on Case
                            caseObj.Core_MDF_Activity_Start_Date__c = pfc.Request.Core_MDF_Start_Date__c;
                            caseObj.Core_MDF_Activity_End_Date__c =pfc.Request.Core_MDF_End_Date__c;
                            caseObj.Core_MDF_ActivityName__c= pfc.Request.Title;
                            
                            //caseObj.Core_MDF_Channel_Program_nm__c = pfc.Core_MDF_Program__c;
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
                }
                System.debug('caseListForUpdation***'+caseListForUpdation);
                
                //Updating cases
                if(caseListForUpdation.size() > 0) {
                    
                    //calling this method to validate document types and set case status based on doctypes selected
                    validateAuditDocuments(caseListForUpdation, claimIdWithConDocId, 'UpdateCases');
                    System.debug('caseListForUpdation@@'+caseListForUpdation);
                    
                    Database.SaveResult[] srList = Database.update(caseListForUpdation, false);
                    //Calling insertLogEntryRecord method to insert log entry for failed record
                    insertLogEntryRecord(srList);
                    
                    //calling this method to attach documents while case updation
                    insertAuditDocuments(caseListForUpdation, claimIdWithConDocId);
                    
                    
                }
                
                //Updating claims which does not have case id
                if(toBeUpdatedPfcList.size() > 0) {
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
    
    // This method will return the type od audit selection as a string
    // input parameters : audit type
    public static String getCaseOrigin(String auditType){
        System.debug('auditType***'+auditType);
        if(auditType == 'Manual') {
            return 'Manual Selection';
        }
        if(auditType == 'Random') {
            return 'Random Selection';
        }
        if(auditType == 'CAP') {
            return 'Predictive Selection';
        }
        return null;
    }
    
    //This method is for populating the Checklist values on Case creation
    public static void createChecklistItems(List<case> cases){
        List<Core_MDF_Claim_Case_Checklist__c> toBeInserted = new List<Core_MDF_Claim_Case_Checklist__c>();
        
        set<string> channelProgram = new set<string>();
        
        try{
            //US527098: Checklist based on Programs
            for(case record: cases) {channelProgram.add(record.Core_MDF_Channel_Program_txt__c);}
            
            Map<string,List<Core_MDF_Checklist_Items__mdt> > channelProgramToChecklistMetadataMap = queryChecklistMetadata(channelProgram);
            
            for(case caseRecord: cases) {
                
                //Get Checklist Items based on Program & Budget
                string key = caseRecord.Core_MDF_Channel_Program_txt__c + caseRecord.Core_MDF_Budget_Type_Txt__c;
                system.debug('key' + key);
                List<Core_MDF_Checklist_Items__mdt> checklistMetadata = channelProgramToChecklistMetadataMap.get(key);
                
                
                //Loop through checklist records which are Program specific
                for(Core_MDF_Checklist_Items__mdt checklistItem : checklistMetadata) {
                    Core_MDF_Claim_Case_Checklist__c record = new Core_MDF_Claim_Case_Checklist__c();
                    record.Core_MDF_Case_ID__c = caseRecord.id;
                    record.Core_MDF_Checklist_Category__c = checklistItem.Core_MDF_Checklist_Type__c;
                    record.Core_MDF_Checklist_Item__c= checklistItem.Core_MDF_Checklist_Label__c;
                    record.Core_MDF_Checklist_Description__c= checklistItem.Core_MDF_Description__c;
                    record.Core_MDF_Checklist_Line_Number__c= checklistItem.Core_MDF_Line_Number__c;
                    record.Core_MDF_Claim_Case_Review_Findings__c = checklistItem.Core_MDF_Claim_Case_Review_Findings__c;
                    toBeInserted.add(record);
                }
            }
            
            if(toBeInserted.size() > 0) {
                Database.SaveResult[] srList = Database.insert(toBeInserted, false);
                system.debug('srList' + srList);
            }
        }
        
        catch(exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
        
    }
    
    //Query the Checklist Metadata
    public static Map<string,List<Core_MDF_Checklist_Items__mdt> > queryChecklistMetadata(set<string> channelPrograms){
        List<Core_MDF_Checklist_Items__mdt> result = new List<Core_MDF_Checklist_Items__mdt>();
        Map<string,List<Core_MDF_Checklist_Items__mdt> > channelProgramtoChecklistMap = new Map<string,List<Core_MDF_Checklist_Items__mdt> >();
        
        try{
            //US527098: Added Program + Budget filter
            result = [select Core_MDF_Line_Number__c,Core_MDF_Checklist_Label__c,Core_MDF_Checklist_Type__c,Core_MDF_Description__c,toLabel(Core_MDF_Claim_Case_Review_Findings__c),Core_MDF_Checklist_Channel_Program_Txt__c, Core_MDF_Budget_Type_Txt__c
                      from Core_MDF_Checklist_Items__mdt
                      where Core_MDF_Active__c=true
                      and Core_MDF_Checklist_Channel_Program_Txt__c in :channelPrograms
                      order by Core_MDF_Line_Number__c];
            
            //Creating Map for Channel Program + Budget to Checklist Records
            for(Core_MDF_Checklist_Items__mdt metadataRecord:result) {
                string key = metadataRecord.Core_MDF_Checklist_Channel_Program_Txt__c + metadataRecord.Core_MDF_Budget_Type_Txt__c;
                List<Core_MDF_Checklist_Items__mdt> checklistList = channelProgramtoChecklistMap.get(key);
                if(checklistList == null) {
                    checklistList = new List<Core_MDF_Checklist_Items__mdt>();
                    checklistList.add(metadataRecord);
                }
                else{
                    checklistList.add(metadataRecord);
                }
                channelProgramtoChecklistMap.put(key,checklistList);
            }
            system.debug('channelProgramtoChecklistMap'+ channelProgramtoChecklistMap);
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
        catch(exception ex) {
            System.debug('ex.getMessage(): '+ex.getMessage());
        }
    }
    
    //This method is for populating the Audit Documents on Case creation and Claim Edit
    public static void insertAuditDocuments(List<Case> cases, Map<Id,List<Core_MDF_Audit_Document__c> > claimIdWithConDocId){
        List<Core_MDF_Audit_Document__c> auditDocsToBeUpdted = new List<Core_MDF_Audit_Document__c>();
        List<ContentDocumentLink> conDocLinksToBeInserted = new List<ContentDocumentLink>();
        Set<Case> caseListToBeUpdated = new Set<Case>();
        
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
            if(auditDocsToBeUpdted.size() >0) {
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
        List<Core_MDF_Audit_Document__c> auditDocsToBeUpdted = new List<Core_MDF_Audit_Document__c>();
        List<ContentDocumentLink> conDocLinksToBeInserted = new List<ContentDocumentLink>();
        Set<Case> caseSetToBeUpdated = new Set<Case>();
        List<Case> caseListToBeUpdated = new List<Case>();
        
        Map<Id,String> caseIdwithStatus = new Map<Id,String>();
        
        //pop values
        /*Boolean proofofcost = false;
        Boolean proofofexecution = false;
        Boolean proofofbranding = false;*/
        // Stores selected document types
        Set<String> selDocTypesSet = new Set<String>();
        // Stores Program, Document Type in a Map
        Map<String, Set<String>> popDocTypesMap = new Map<String, Set<String>>();
        // Stores the required document types for POP submission
        Set<String> reqDocTypesForSubmission = new Set<String>();
        
        //get the requiredDocTypes for POP Submission, Selected DocTypes, Active fields program wise from the metadata.
        for(Core_MDF_POP_Document_Types__mdt popDocTypes : [SELECT Core_MDF_Program_nm__c, Core_MDF_Active_ind__c, Core_MDF_ReqforPOPSubmission_ind__c, 
                                                            Core_MDF_Document_Type_nm__c FROM Core_MDF_POP_Document_Types__mdt WHERE 
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
                if(caseObj.Core_MDF_Status__c !='Cancelled' && popDocTypesMap.containsKey(caseObj.Core_MDF_Channel_Program_txt__c)) {
                    
                    caseIdwithStatus.put(caseObj.Id,caseObj.Core_MDF_Status__c);
                    
                    //Set Case Status when Claim is saved with documents
                    if(claimIdWithConDocId.size() > 0 && claimIdWithConDocId != null &&
                       claimIdWithConDocId.containsKey(caseObj.Core_MDF_Claim_ID__c) &&
                       claimIdWithConDocId.get(caseObj.Core_MDF_Claim_ID__c) != null) {
                           for(Core_MDF_Audit_Document__c conDoc: claimIdWithConDocId.get(caseObj.Core_MDF_Claim_ID__c)) {
                               /*
                                if(conDoc.Core_MDF_Proof_of_Cost__c) {proofofcost = true;}
                                if(conDoc.Core_MDF_Proof_of_Branding__c) {proofofbranding= true;}
                                if(conDoc.Core_MDF_Proof_of_Execution__c) {proofofexecution= true;}*/
                                                               
                               // adding the document type values to set
                               selDocTypesSet.addAll(conDoc.Core_MDF_Document_Types__c.split(';'));
                               system.debug('selDocTypesSet' + selDocTypesSet);
                               // adding the required document types for POP submission to a set
                               reqDocTypesForSubmission = popDocTypesMap.get(caseObj.Core_MDF_Channel_Program_txt__c);
                           } 
                           if(((executionReason == 'UpdateCases'  && caseObj.Core_MDF_More_Documentation_Required__c == false)
                               || executionReason == 'CreateCases') && reqDocTypesForSubmission.size() > 0 && 
                              (selDocTypesSet.containsAll(reqDocTypesForSubmission))){ 
                                  caseObj.Core_MDF_Status__c = 'Under Review';
                                  caseObj.Core_MDF_More_Documentation_Required__c = false;
                                  if( caseIdwithStatus.get(caseObj.Id) == 'Pending Documents' || executionReason == 'CreateCases'){
                                      //Modified by Ealisha - US499699: [Case: SLA Calculation] - Refresh "Days SLA Remaining" at 5 am PST
                                      //caseObj.Core_MDF_SLA_Start_Date__c = setSLAStartDate();
                                      caseObj.Core_MDF_SLA_Start_Date__c = System.now();
                                  }
                              }
                           else if(executionReason == 'CreateCases'){
                               caseObj.Core_MDF_Status__c = 'Pending Documents';
                           }
                           
                       }   //end of if
                    //Set Case Status when Claim is saved without any documents uploaded
                    else{
                        caseObj.Core_MDF_Status__c = 'Pending Documents';
                    }
                    caseSetToBeUpdated.add(caseObj);
                    caseListToBeUpdated.addAll(caseSetToBeUpdated);
                }
            }//end of for loop
            
        }//end of try block
        catch(exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
        return caseListToBeUpdated;
    }
        
    global void finish(Database.BatchableContext batchContext) {
        
    }
}