public without sharing class Core_MDF_ReverseAuditDecision{
    public static Set<String> nodeAccountSupportedProgramsSet = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    
    
    @AuraEnabled
    public static string reverseAuditDecision(id caseId, Core_MDF_Scorecard__c scorecardRecord){
        string result;
        string quarter;
        string preClosedDateQuarter;
        string currentQuarterYear;
        Boolean surePayInd;
        
        
        Id caseOpenRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Core_MDF_CCP_ConstantClass.CASE_OPEN_RECORDTYPE_NAME).getRecordTypeId();
        Savepoint sp;
        try {
            Case caseRec = [select id,CreatedDate,ClosedDate,Core_MDF_Claim_Lookup_Id__c,Core_MDF_Claim_Lookup_Id__r.Core_MDF_SurePay_Processed_Ind__c,Core_MDF_Previous_Closed_Dt__c,Core_MDF_Earlier_Quarter_Closed_Dt__c, AccountId, Account.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program_txt__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Claim_ID__c,Core_MDF_Audit_Reversal_Count_Nbr__c,Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c,Core_MDF_Claim_Lookup_Id__r.Core_MDF_Processing_Preference_nm__c,Account.Core_MDF_Channel_Program__c, Account.Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Region_SubRegion_txt__c
                            from Case where id =: caseId];
            
            if(caseRec.Core_MDF_Previous_Closed_Dt__c != null){
				preClosedDateQuarter = determineQuartYear(date.newinstance(caseRec.Core_MDF_Previous_Closed_Dt__c.year(), caseRec.Core_MDF_Previous_Closed_Dt__c.month(), caseRec.Core_MDF_Previous_Closed_Dt__c.day()));
            }
            quarter = determineQuartYear(date.newinstance(caseRec.ClosedDate.year(), caseRec.ClosedDate.month(), caseRec.ClosedDate.day()));
            Date currDate = System.today();
            currentQuarterYear = determineQuartYear(date.newinstance(currDate.year(), currDate.month(), currDate.day()));
            surePayInd = caseRec.Core_MDF_Claim_Lookup_Id__r.Core_MDF_SurePay_Processed_Ind__c;
            List<String> quarterList = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            List<String> finalQuarterList = new List<String>();
            List<String> qtrLstForPSDUpdateOnCaseReopen = new List<String>();
            for(String quarterYear : quarterList){
                if(quarterYear != currentQuarterYear) {
                finalQuarterList.add(quarterYear);
                }
                qtrLstForPSDUpdateOnCaseReopen.add(quarterYear);
                if(quarter == quarterYear) 
                    break;
            }

            //Decimal recoveredAmount = 0.0;
            
            String query = 'SELECT Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Recovered_Amt__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Recovery_Offset_Amt__c, Core_MDF_Recovered_Amt__c, Core_MDF_Recovery_Offset_Amt__c, Core_MDF_Region_Cd__c, Core_MDF_Budget_Type_Nm__c FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_Program_Nm__c =\'' + String.escapeSingleQuotes(caseRec.Core_MDF_Channel_Program_txt__c) + '\' AND Core_MDF_Quarter_Year_Nm__c IN: finalQuarterList AND Core_MDF_Region_Cd__c = \'' + String.escapeSingleQuotes(caseRec.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c) + '\'';
            
            query += String.isNotBlank(caseRec.Core_MDF_Budget_Type_nm__c) ? ' AND Core_MDF_Budget_Type_Nm__c = \'' + String.escapeSingleQuotes(caseRec.Core_MDF_Budget_Type_nm__c) + '\'' : '';

            //Check Recovery Offset amount if we reopen a RSA MD/PRC region Case
            query += (caseRec.Core_MDF_Budget_Type_nm__c == 'RSA MD' && caseRec.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c == 'PRC') ? ' AND (Core_MDF_Recovered_Amt__c > 0 OR Core_MDF_Recovery_Offset_Amt__c > 0)' : ' AND Core_MDF_Recovered_Amt__c > 0';

            if(nodeAccountSupportedProgramsSet.contains(caseRec.Core_MDF_Channel_Program_txt__c)){
                query += ' AND Core_MDF_Node_Account_Id__c = \'' + String.escapeSingleQuotes(caseRec.AccountId) + '\'';
            }else{
                query += ' AND Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c = \'' + String.escapeSingleQuotes(caseRec.Account.Core_MDF_CoMarketing_Ultimate_Account__c) + '\'';
            }

            //Check if Case has Recovered amount for the Account (Node Account for IPA and RMF), Program and Quarter
            List<Core_MDF_Partnership_Score_Detail__c> psdList = Database.query(query);
            
           //If recovery is present, do not reverse audit

            if(currentQuarterYear != quarter && !psdList.isEmpty()){
                result = psdList[0].Core_MDF_Partnership_Score_Id__r.Core_MDF_Recovered_Amt__c > 0 ? Label.Core_MDF_Reverse_Audit_Error_Message : Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Reverse_Audit_Offset_Error_Msg');
            }else if(currentQuarterYear == quarter && surePayInd){
                result = Label.Core_MDF_Reverse_Audit_Error_Message;
            }
            //Reverse Audit
            else{
                caseRec.Core_MDF_Status__c = Core_MDF_CCP_ConstantClass.CASE_OPEN_STATUS;
                caseRec.Core_MDF_Review_Case_Status__c = '';
                caseRec.Status = Core_MDF_CCP_ConstantClass.CASE_OPEN;
                caseRec.Core_MDF_SLA_Start_Date__c = system.now();
                caseRec.RecordTypeId  = caseOpenRecordId;       
                caseRec.Core_MDF_Audit_Reversal_Count_Nbr__c = caseRec.Core_MDF_Audit_Reversal_Count_Nbr__c == null ? 1 : ++ caseRec.Core_MDF_Audit_Reversal_Count_Nbr__c ;
                if(preClosedDateQuarter != quarter && case.Core_MDF_Previous_Closed_Dt__c != null){
                	caseRec.Core_MDF_Earlier_Quarter_Closed_Dt__c = caseRec.Core_MDF_Previous_Closed_Dt__c;
                }
                caseRec.Core_MDF_Previous_Closed_Dt__c = caseRec.ClosedDate;
                if(caseRec.Core_MDF_Earlier_Quarter_Closed_Dt__c == null){
                    caseRec.Core_MDF_Earlier_Quarter_Closed_Dt__c = caseRec.Core_MDF_Previous_Closed_Dt__c;
                }
                if(caseRec.Core_MDF_Region_SubRegion_txt__c != null && caseRec.Core_MDF_Region_SubRegion_txt__c  == 'INDIA - INDIA'){
                    Core_MDF_CCP_Country_Geo_Mapping__mdt cgm = [SELECT Core_MDF_Geo__c, Core_MDF_Sub_Geo__c FROM Core_MDF_CCP_Country_Geo_Mapping__mdt WHERE MasterLabel = 'INDIA' LIMIT 1];
                    if(cgm != null){
                        caseRec.Core_MDF_Region_SubRegion_txt__c = cgm.Core_MDF_Geo__c +' - '+ cgm.Core_MDF_Sub_Geo__c;
                    }
                }
                
                sp = Database.setSavepoint();
				
                //Update Case
                Database.SaveResult srCase = Database.update(caseRec);

                if(srCase.isSuccess()){
                    //Audit AI change
                    Set<Id> caseIdForAudit = new Set<Id>();
                    caseIdForAudit.add(srCase.getId());
                    //Audit AI change end

                    Id virtualCorpAccountId = String.isNotBlank(caseRec.Account.Core_MDF_Virtual_Corp_Account_Id__c) ? caseRec.Account.Core_MDF_Virtual_Corp_Account_Id__c : caseRec.AccountId;
                    String budgetType = String.isNotBlank(caseRec.Core_MDF_Budget_Type_nm__c) ? caseRec.Core_MDF_Budget_Type_nm__c : 'null';
                    //Swati- Exclude RSA MD 
                    Boolean isRetailMarketingFunds = caseRec.Core_MDF_Channel_Program_txt__c == Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
                    Boolean isBudgetRsaMd =caseRec.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.RMF_RSA_MD_BUDGET_TYPE;
                    Boolean iscaseClosedDate = (caseRec.Core_MDF_Previous_Closed_Dt__c.date() >= Date.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exclude_RSA_MD')));
                    Boolean skipRSA_MD = isRetailMarketingFunds && isBudgetRsaMd && iscaseClosedDate;

                    if(!skipRSA_MD){
                        extIdDataWrapper extIdExtIdListwrapper = prepareExtIdKeyList(caseRec.Account.Core_MDF_Channel_Program__c, virtualCorpAccountId, caseRec.AccountId, budgetType ,caseRec.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c,qtrLstForPSDUpdateOnCaseReopen,quarter,caseRec.Core_MDF_Channel_Program_txt__c);
    
                        Boolean isIPAorRMFPrgm = nodeAccountSupportedProgramsSet.contains(caseRec.Core_MDF_Channel_Program_txt__c) ? true : false;
                        String psdExternalId = '' + String.valueOf(caseRec.Account.Core_MDF_Channel_Program__c) + String.valueOf(virtualCorpAccountId) + quarter + (isIPAorRMFPrgm ? String.valueOf(caseRec.AccountId) : '') + budgetType  + caseRec.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Region_Cd__c;
    
                        //TWC3117-18331
                        List<Core_MDF_Partnership_Score_Detail__c> currentQuarterPsdRecords = [SELECT Id,Core_MDF_Total_Recovery_Amt__c, Core_MDF_Balance_Amount_Amt__c, Core_MDF_Carry_Over_Amt__c, Core_MDF_Recovery_Offset_Amt__c, Core_MDF_Recovery_Offset_Comments_txt__c, Core_MDF_Offset_Comment_Details_txt__c FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_External_ID__c =: psdExternalId LIMIT 1];
                        Core_MDF_Partnership_Score_Detail__c currentQuarterPsdRecord = currentQuarterPsdRecords.isEmpty() ? null : currentQuarterPsdRecords[0];
                        
                        updateRecoveryDashboardRec(caseRec.id);			
                        //TWC3117-9689 - Do not consider current quarter PSD for carry over amount adjustment during case reopen
                        if (!quarter.equals(quarterList[0])) {
                            //TWC3117-18331
                            if (currentQuarterPsdRecord != null) { updatePSDRecords(extIdExtIdListwrapper, currentQuarterPsdRecord); }
                        }
                    }//Skip RSA MD end
                    // Inactivate recovery request when case is reopened
                    Core_MDF_ReverseAuditDecision.RequestInput input = new Core_MDF_ReverseAuditDecision.RequestInput();
                    input.claimId = caseRec.Core_MDF_Claim_Lookup_Id__c;
                    List<Core_MDF_ReverseAuditDecision.RequestInput> inputList = new List<Core_MDF_ReverseAuditDecision.RequestInput>();
                    inputList.add(input);
                    
                    // Call method
                    Core_MDF_ReverseAuditDecision.inactivateRecoveryRequests(inputList);
                    
                    PartnerFundClaim claimRec = new PartnerFundClaim(id = caseRec.Core_MDF_Claim_ID__c);
                    claimRec.Core_MDF_Audit_Hold__c = true;
                    //Update Claim
                    Database.SaveResult srClaim = Database.update(claimRec);
                    if(srClaim.isSuccess()){result = 'Success';} 

                    //Audit AI Change
                    try{
                    Date aiEnableDate = Date.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_AI_Audit_Enable_Date')?.Core_MDF_Value_Txt__c);//WW16.4 date
                    Integer auditBatchsize = Integer.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_AI_Audit_Batch_Size')?.Core_MDF_Value_Txt__c);//Audit Batch size
            	
                        if(scorecardRecord!=null && (scorecardRecord.Core_MDF_AI_Processing_Status_Nm__c == '' || scorecardRecord.Core_MDF_AI_Processing_Status_Nm__c == null) && caseIdForAudit.size()>0 && caseRec.CreatedDate >=aiEnableDate){
                                if(!(Core_MDF_Claim_Utility.bypassCDBCalloutValidationCheck('Core_MDF_ProcessCasesWithAIForAudit','Core_MDF_Bypass_AI_CDB_CallForAudit'))) {
                                        Core_MDF_Audit_AI_Integration auditAIIntegrationBatch = new Core_MDF_Audit_AI_Integration(caseIdForAudit);
                                        Database.executeBatch(auditAIIntegrationBatch, auditBatchsize);
                                }
                        }
                    }
                    catch(Exception e){
                        Core_MDF_CCP_UtilityClass.logError(e);
                    }
                }
            }
            
        } catch (Exception e) {
            result = Label.Core_MDF_ApplicationErrorMessage;
            Database.rollback(sp);
            Core_MDF_CCP_UtilityClass.logError(e);}
        return result;
    }
    public static void updateRecoveryDashboardRec(Id caseRecId){
        List<Core_MDF_Recovery_Dashboard__c> recdashboardRecList = new List<Core_MDF_Recovery_Dashboard__c>();
        for(Core_MDF_Recovery_Dashboard__c recDashboardRec:[select id, Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__c,Core_MDF_Is_Active_Ind__c from Core_MDF_Recovery_Dashboard__c where Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__c  =:caseRecId and Core_MDF_Is_Active_Ind__c = true ]){
             recdashboardRecList.add(new Core_MDF_Recovery_Dashboard__c(Id = recDashboardRec.Id, Core_MDF_Is_Active_Ind__c = false));
        }
        if(recdashboardRecList != null && recdashboardRecList.size() > 0){
             Database.update(recdashboardRecList);
        }

    }
    
    public static extIdDataWrapper prepareExtIdKeyList(Id channelProgramId,Id virtualCorpAccountId,Id AccountId, String budType,String region,List<String> qtrLstForPSDUpdateOnCaseReopen,string quarter,string programName){
        Map<String, List<String>> extIdForCurrCaseClosedateToExtIdList = new Map<String, List<String>>();
        String extIdkey;
        String extIdKeyForCaseCloseDtQtr; 
        List<String> extIdKeyList = new List<String>();
        if(qtrLstForPSDUpdateOnCaseReopen.size()>0 && qtrLstForPSDUpdateOnCaseReopen != null){
        	qtrLstForPSDUpdateOnCaseReopen.remove(0);
        }
        
        for(string qtr :qtrLstForPSDUpdateOnCaseReopen){
        	if(nodeAccountSupportedProgramsSet.contains(programName)){
            	extIdkey=channelProgramId +'' + virtualCorpAccountId + qtr + AccountId + budType + region;
                            
             }else{
                extIdkey=channelProgramId +'' + virtualCorpAccountId + qtr + budType + region;
                       		
             }
             if(qtr == quarter){extIdKeyForCaseCloseDtQtr = extIdkey;}
                        
             extIdKeyList.add(extIdkey);
        }
        extIdDataWrapper extIdExtIdListwrapper = new extIdDataWrapper();
        extIdExtIdListwrapper.extIdKeyForCaseCloseDtQtr = extIdKeyForCaseCloseDtQtr;
        extIdExtIdListwrapper.extIdKeyList = extIdKeyList;
        return extIdExtIdListwrapper;
    }
    
    public static void updatePSDRecords(extIdDataWrapper extIdExtIdListwrapper, Core_MDF_Partnership_Score_Detail__c currentQuarterPsdRecord){

        //TWC3117-18331
        if (currentQuarterPsdRecord == null) { return; }
        
        //set<String> extIdKeyForCaseCloseDtQtrSet = extIdForCurrCaseClosedateToExtIdList.keySet();
        list<String> extIdKeyList = extIdExtIdListwrapper.extIdKeyList;
        String extIdKeyForCaseCloseDtQtr = extIdExtIdListwrapper.extIdKeyForCaseCloseDtQtr; 
                            
        Decimal carryOverAmount =0.0;
        Decimal amtToBeDeductedForFutureQtrPSD =0.0;
        Decimal totalAmt = 0.0;
        
        			
        List<Core_MDF_Partnership_Score_Detail__c> psdToUpdate = new List<Core_MDF_Partnership_Score_Detail__c>();
        
        Map<Id, Core_MDF_Partnership_Score_Detail__c> psdIdToPsdRecMap = new Map<Id, Core_MDF_Partnership_Score_Detail__c>();
                    
        for(Core_MDF_Partnership_Score_Detail__c psd : [SELECT Id, Core_MDF_Total_Recovery_Amt__c, Core_MDF_Balance_Amount_Amt__c, Core_MDF_Carry_Over_Amt__c, Core_MDF_Recovery_Offset_Amt__c, Core_MDF_Recovery_Offset_Comments_txt__c, Core_MDF_Offset_Comment_Details_txt__c, Core_MDF_External_ID__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Region_Cd__c FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_External_ID__c IN: extIdKeyList]){

            if(psd.Core_MDF_External_ID__c == extIdKeyForCaseCloseDtQtr){
                //psdForCurrClosedCaseQtr = psd;
                totalAmt = psd.Core_MDF_Total_Recovery_Amt__c;
                amtToBeDeductedForFutureQtrPSD = (currentQuarterPsdRecord.Core_MDF_Total_Recovery_Amt__c != null ? currentQuarterPsdRecord.Core_MDF_Total_Recovery_Amt__c : 0.0) - (psd.Core_MDF_Total_Recovery_Amt__c != null ? psd.Core_MDF_Total_Recovery_Amt__c : 0.0);
            }else{
                psdIdToPsdRecMap.put(psd.id,psd);
            }
        }
        
        for(Core_MDF_Partnership_Score_Detail__c psd : psdIdToPsdRecMap.values()){
            carryOverAmount = (psd.Core_MDF_Carry_Over_Amt__c != null ? psd.Core_MDF_Carry_Over_Amt__c : 0.0) - amtToBeDeductedForFutureQtrPSD;
            carryOverAmount = carryOverAmount > 0 ? carryOverAmount : 0.0;
            psdToUpdate.add(new Core_MDF_Partnership_Score_Detail__c(Id = psd.Id, Core_MDF_Carry_Over_Amt__c = carryOverAmount));                                                  
         }
         if(!psdToUpdate.isEmpty()){
               Database.update(psdToUpdate, false);
         }
    }
    

    public static string determineQuartYear(date dateToBeconverted){
        string result;
            Integer quarter = dateToBeconverted.month();
            Integer year = dateToBeconverted.year();
            Set<Integer> qtr123 = new set<Integer>{1,2,3};
            Set<Integer> qtr456 = new set<Integer>{4,5,6};
            Set<Integer> qtr789 = new set<Integer>{7,8,9};
            if(qtr123.contains(quarter)){result = 'Q1 '+ year;}
            
            else if(qtr456.contains(quarter)){result = 'Q2 '+ year;}
            
            else if (qtr789.contains(quarter)){result = 'Q3 '+ year;}
            
            else{result = 'Q4 '+ year;}
            
        
        return result;
    }

     //Audit AI changes
    @AuraEnabled(cacheable=true)
    public static Core_MDF_Scorecard__c getScorecardRecord(Id caseId) {
        try {
            Core_MDF_Scorecard__c scorecardRecord = [SELECT Id, Name, Core_MDF_Case_Id__c,Core_MDF_AI_Processing_Status_Nm__c FROM Core_MDF_Scorecard__c WHERE Core_MDF_Case_Id__c = :caseId LIMIT 1];
            return scorecardRecord;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return null;
        }
    }

    public class extIdDataWrapper {
        public String extIdKeyForCaseCloseDtQtr;
        public List<string> extIdKeyList;
    }
    
    public class RequestInput {
        @InvocableVariable(required=true)
        public Id claimId;
    }
    
    @InvocableMethod
    public static void inactivateRecoveryRequests(List<RequestInput> inputs) {
        
        Set<Id> claimIds = new Set<Id>();
        for(RequestInput inp : inputs){
            claimIds.add(inp.claimId);
        }
        List<Core_MDF_Recovery_Request__c> recReqUpdateList = new List<Core_MDF_Recovery_Request__c>();
        List<Core_MDF_Recovery_Request__c> recList = [SELECT Id,Core_MDF_Active_Ind__c FROM Core_MDF_Recovery_Request__c WHERE Core_MDF_Claim_Id__r.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid' AND Core_MDF_Claim_Id__c IN :claimIds AND Core_MDF_Active_Ind__c = true AND Core_MDF_Recovery__c = ''];
        if(!recList.isEmpty()){
            for(Core_MDF_Recovery_Request__c rec : recList){
                Core_MDF_Recovery_Request__c tempRR = new Core_MDF_Recovery_Request__c();
                tempRR.Id = rec.Id;            
                tempRR.Core_MDF_Active_Ind__c = false;
                recReqUpdateList.add(tempRR);
            }
        }
        if(!recReqUpdateList.isEmpty()){
            update recReqUpdateList;
        }
    }
}