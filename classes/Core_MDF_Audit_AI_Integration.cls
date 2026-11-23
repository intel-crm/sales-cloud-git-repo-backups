/****************************************************************************************************************************************************
 * Class Name      : Core_MDF_Audit_AI_Integration
 * Version               : 1.0
 * Created Date          :  01-19-2026 
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Shubhra/Sinduja     01-19-2026        class for CDB Outbound Integartion for MDF AI Audit
 ******************************************************************************************************************************************************/
public class Core_MDF_Audit_AI_Integration implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful {
    
    public static Date aiEnableDate = Date.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_AI_Audit_Enable_Date')?.Core_MDF_Value_Txt__c);//WW16.4 date
            	
    // Add instance variable to store case IDs
    public Set<Id> setOfCaseIds;
    public Map<String,Integer> recordIdToPrevRetryCountMap;
    
    public Map<String, String> caseKeyToFinalJsonMap;
   
    // Parameterized constructor to accept case IDs
    public Core_MDF_Audit_AI_Integration(Set<Id> caseIdSetforAudit) {
        this.setOfCaseIds = caseIdSetforAudit != null ? caseIdSetforAudit : new Set<Id>();
        this.caseKeyToFinalJsonMap = new Map<String, String>(); 
    }
    
    // Parameterized constructor to accept case IDs and retry records
    public Core_MDF_Audit_AI_Integration(Set<Id> caseIdSetforAudit,Map<String,Integer> recordIdToPrevRetryCountMap) {
        this.setOfCaseIds = caseIdSetforAudit;
        this.recordIdToPrevRetryCountMap = recordIdToPrevRetryCountMap != null ? recordIdToPrevRetryCountMap : new Map<String,Integer>();
        this.caseKeyToFinalJsonMap = new Map<String, String>(); 
        
    }
    
   
    // Batch start method
    public Database.QueryLocator start(Database.BatchableContext bc) {
   
        // Default query 
      String query = 'SELECT Id, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Activity_End_Date__c, ' + 
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Activity_Category__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Activity_Types__c, ' +
          'Core_MDF_Strategic_Marketing_Fund_Ind__c, ' + 'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Program__c, ' +
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_OtherCostsnotReimbursable_Local__c, ' + 
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Claim_Lookup_Id__r.Core_MDF_Taxes_Local__c, ' + 
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Reimbursable_TransactionAmt_Loc__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Country_Location_nm__c, ' + 
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Currency__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Brand_nm__c, ' + 
          'Core_Product_Type__c, Core_MDF_Technology__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Requested_Reimbursement_Amt__c, ' + 
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Number_of_Attendees_Nbr__c,Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_ATF_Flag_nm__c,  ' + 
		  'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Invoice_Date__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Invoice_Number__c, ' +          
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_Ad_Run_End_Date__c,' + 
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Duplicate_Claim__c, Core_MDF_Claim_Lookup_Id__r.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,' + 
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Exchange_rate__c,Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Country_nm__c,Core_MDF_Claim_Lookup_Id__r.Amount,' + 
          'Core_MDF_Claim_Lookup_Id__r.Core_MDF_Activity_Start_Date__c,Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Activity_Reimbursement_Amt_nbr__c,' +
          'Core_MDF_Claim_Lookup_Id__r.Request.RequestedAmount,Core_MDF_Claim_Lookup_Id__r.Core_MDF_Excess_Requested_Amount__c,Core_MDF_Claim_Lookup_Id__r.RequestId ' + 
          'FROM Case WHERE Id IN :setOfCaseIds AND CreatedDate>=:aiEnableDate' ;
         
          return Database.getQueryLocator(query);
   
}
    // Batch execute method
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        try {
            
            // Process cases for audit process
        	Map<String, String> resultMap = generateAIResponseforAuditProcess(scope, setOfCaseIds, recordIdToPrevRetryCountMap);
        
            // CHANGE: Add to instance variable
            if (resultMap != null && !resultMap.isEmpty()) {
                caseKeyToFinalJsonMap.putAll(resultMap);
            }

            
        } catch (Exception exp) {Core_MDF_CCP_UtilityClass.logError(exp);
        }
    }
    
    // Batch finish method
    public void finish(Database.BatchableContext bc) {
        // Make callouts if there are payloads to send
        if (!caseKeyToFinalJsonMap.isEmpty()) {
            makeCDBCallout(caseKeyToFinalJsonMap, recordIdToPrevRetryCountMap);
        }
        
    }
   /***********************************************************************************************************
    Method Name:        generateAIResponseforAuditProcess
    Description:        Method to process cases for AI integration 
    Added By:           Sinduja/Shubhra 02-02-2025
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    public static Map<String, String> generateAIResponseforAuditProcess(List<Case> cases, Set<Id> caseIds, Map<String,Integer> recordIdToPrevRetryCountMap) {
        Map<String, String> caseKeyToJsonMap = new Map<String, String>();
        try {
            // Query all related data for the cases
            Map<Id, PartnerFundClaim> caseIdToClaimMap = new Map<Id, PartnerFundClaim>();
            Map<Id, Core_MDF_Scorecard__c> caseIdToScorecardMap = new Map<Id, Core_MDF_Scorecard__c>();
            Map<Id, List<ChecklistWrapper>> caseIdToChecklistWrappersMap = new Map<Id, List<ChecklistWrapper>>();
            Map<Id, List<DocumentWrapper>> caseIdToDocumentWrappersMap = new Map<Id, List<DocumentWrapper>>();

             //map to capture the spif details based on the activity
             Map<Id, List<ActivitySegmentWrapper>> activityIdToActivitySPIF = new Map<Id, List<ActivitySegmentWrapper>>();
            //Map<String, Integer> recordIdToPrevRetryCount = getPreviousRetryCounts(caseIds);
	    
            Map<String, Integer> recordIdToPrevRetryCount = recordIdToPrevRetryCountMap;
                
            //Get Scorecard related to Case
            caseIdToScorecardMap = getScorecardData(caseIds);
            
            //Get Checklist related to Case
            caseIdToChecklistWrappersMap = getChecklistData(caseIds);

            //Get spif related to activity
            activityIdToActivitySPIF = getSpifData(cases);
            
            //Get Audit Document Data related to Case
            caseIdToDocumentWrappersMap = getAuditDocumentData(caseIds);
            
            // Process each case with its related data
            for (Case caseRec : cases) {
                // Get related scorecards and claims for this case
                Core_MDF_Scorecard__c caseScorecard = caseIdToScorecardMap.get(caseRec.Id);//get scorecard related to case
                List<ChecklistWrapper> caseChecklistWrappers = caseIdToChecklistWrappersMap.get(caseRec.Id);//get checkist related to case

                //Aswin
                List<ActivitySegmentWrapper> spifWrappers = activityIdToActivitySPIF.get(caseRec.Core_MDF_Claim_Lookup_Id__r.RequestId);
                List<DocumentWrapper> caseDocumentWrappers = caseIdToDocumentWrappersMap.get(caseRec.Id);//get audit document related to case
                
                //check if scorecard and checklist Exist for the case
                if (caseScorecard == null || caseChecklistWrappers == null || caseChecklistWrappers.isEmpty()) {
                    String errorMessage = 'Case not sent for AI Audit '+ caseRec.Id + ' Missing scorecard or checklist data';
                    
                    //Log in no scorecard or checklist exsist
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorMessage,'Core_MDF_Audit_AI_Integration.execute');
                    continue;
                }
                
                // Create wrapper objects and prepare JSON payload
                String jsonPayload = prepareJsonPayload(caseRec, caseScorecard, caseChecklistWrappers, spifWrappers, caseDocumentWrappers);
                if (String.isNotBlank(jsonPayload)) {
                    caseKeyToJsonMap.put(String.valueOf(caseRec.Id), jsonPayload);
                }
                
            }  
            
        } catch (Exception exp) {Core_MDF_CCP_UtilityClass.logError(exp);
        }
        return caseKeyToJsonMap;
    }
    //Prepare JSON Method
    public static String prepareJsonPayload(Case caseRecord, Core_MDF_Scorecard__c scorecard, List<ChecklistWrapper> ChecklistWrappers, List<ActivitySegmentWrapper> spifWrappers, List<Documentwrapper> documentWrappers) {
        try {
            // Create the main outbound wrapper
        	CDBOutboundWrapper outboundWrapper = new CDBOutboundWrapper();
            
            // Create case wrapper
            ClaimCaseWrapper claimCaseWrapDetails = new ClaimCaseWrapper();
            if(caseRecord != null){
                claimCaseWrapDetails.caseId = caseRecord.Id;
                claimCaseWrapDetails.activityEndDate = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Activity_End_Date__c;
                //Aswin
                claimCaseWrapDetails.activityStartDate = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Activity_Start_Date__c;
                claimCaseWrapDetails.activityIntelContr = caseRecord.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                claimCaseWrapDetails.activitySpendingLimit = caseRecord.Core_MDF_Claim_Lookup_Id__r.Request.RequestedAmount;
                claimCaseWrapDetails.claimExcessReqAmt = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Excess_Requested_Amount__c;
                //
                claimCaseWrapDetails.activityCategory = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Activity_Category__c;
                claimCaseWrapDetails.activityType =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Activity_Types__c;
                claimCaseWrapDetails.strategicMarketingFundInd = caseRecord.Core_MDF_Strategic_Marketing_Fund_Ind__c;
                claimCaseWrapDetails.program =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Program__c;
                claimCaseWrapDetails.budgetType =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Budget_Type_Options_Nm__c;
                claimCaseWrapDetails.totalInvoiceAmountLocal =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Total_Invoice_Amount_Local__c;
                claimCaseWrapDetails.costNotReimbursableLocal =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_OtherCostsnotReimbursable_Local__c;
                claimCaseWrapDetails.claimTaxesLocal= caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Taxes_Local__c;
                claimCaseWrapDetails.reimbursableAmountUSD =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Reimbursable_Transaction_Amount__c;
                claimCaseWrapDetails.reimbursableAmountLocal =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Reimbursable_TransactionAmt_Loc__c;
                claimCaseWrapDetails.claimCurrency =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Currency__c;
                claimCaseWrapDetails.claimCountry =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Country_Location_nm__c;
                claimCaseWrapDetails.brand =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Brand_nm__c;
                claimCaseWrapDetails.productType =  caseRecord.Core_Product_Type__c;
                claimCaseWrapDetails.technology =  caseRecord.Core_MDF_Technology__c;
                claimCaseWrapDetails.invoiceNumber =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Invoice_Number__c;
                claimCaseWrapDetails.invoiceDate =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Invoice_Date__c;
                claimCaseWrapDetails.exchangeRate =  caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Exchange_rate__c;
                claimCaseWrapDetails.claimId = caseRecord.Core_MDF_Claim_Lookup_Id__c;
                claimCaseWrapDetails.claimStartDate = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Ad_Run_Start_Date__c;
                claimCaseWrapDetails.claimEndDate = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Ad_Run_End_Date__c;
                claimCaseWrapDetails.duplicateClaim = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Duplicate_Claim__c;
                claimCaseWrapDetails.thirdPartyPOPDocReqInd = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c;
                claimCaseWrapDetails.reimbursementAmountUSD = caseRecord.Core_MDF_Claim_Lookup_Id__r.Amount; 
                claimCaseWrapDetails.activityCountry = caseRecord.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Country_nm__c;  
                claimCaseWrapDetails.noOfAttendees = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Number_of_Attendees_Nbr__c; 
                claimCaseWrapDetails.requestedAmountUSD = caseRecord.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Requested_Reimbursement_Amt__c;
                claimCaseWrapDetails.atfFlag = caseRecord.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_ATF_Flag_nm__c;
              
            }
            outboundWrapper.claimCaseDetails = claimCaseWrapDetails;

            // Create scorecard wrapper (single scorecard per case)
            if (scorecard != null) {
                ScorecardWrapper scorecardWrap = new ScorecardWrapper();
                scorecardWrap.scorecardId = scorecard.Id;
                
            
            outboundWrapper.scorecardDetails = scorecardWrap;
        	} 
       //ChecklistWrapper
       if (checklistWrappers != null && !checklistWrappers.isEmpty()) {
            outboundWrapper.checklistDetails = checklistWrappers;
        }

       //DocumentWrapper 
       if (documentWrappers != null && !documentWrappers.isEmpty()) {
            outboundWrapper.documentDetails = documentWrappers;
        }  
        //spifWrapper
       if (spifWrappers != null) {
            outboundWrapper.spifDetails = spifWrappers;
        }
      	return JSON.serialize(outboundWrapper);
            
        }
        catch(Exception exp){
            Core_MDF_CCP_UtilityClass.logError(exp);return 'ERROR';
        }
    }
    
    // Generic HTTP callout method
    public static void makeCDBCallout(Map<String, String> caseKeyToJsonMap,Map<String, Integer> recordIdToPrevRetryCount) {
        try{
        List<Core_CDB_Integration_Log__c> cdbLogList = new List<Core_CDB_Integration_Log__c>();
        // Local aggregation of exceptions for one-shot logging
        List<Exception> calloutExceptions = new List<Exception>();
        // APPENDED: Track case Ids to mark failed upon 3rd retry failure
        Set<Id> finalRetrycaseIds = new Set<Id>();
        // Process each payload
        for (String caseKey : caseKeyToJsonMap.keySet()) {
            String payload = caseKeyToJsonMap.get(caseKey);
		System.debug('AUdit Payload'+payload);
            if (String.isBlank(payload)) {
            	continue;
             }
            // Send payload to CDB
            HttpResponse res = Core_MDF_CDB_Utility.sendCDBPayload(payload, 'APIGEE_MDF_AUDIT');
            Boolean isSuccess = (res != null && (res.getStatus() == 'SUCCESS' || res.getStatus() == 'OK')) ? true : false;
            
            // If callout layer returned an Apex exception as response, aggregate it
            if (!isSuccess && res != null && res.getStatusCode() == 503 && res.getStatus() == 'APEX_EXCEPTION') {
                String expnMsg = res.getBody();
                if (String.isBlank(expnMsg)) {
                	expnMsg = 'Unhandled Apex exception during CDB callout';
                }
                calloutExceptions.add(new CDBCalloutException(expnMsg));
             }
            
            // Calculate retry counter
            Integer newRetryCounter = 0;
            if (recordIdToPrevRetryCount != null && !recordIdToPrevRetryCount.isEmpty()) {
            	Integer prevRetryCounter = recordIdToPrevRetryCount.get(caseKey);
                if (prevRetryCounter != null) {
                	newRetryCounter = prevRetryCounter + 1;
                }
            }
            //APPENDED: Collect Case Id when this is a retry reaching 3 and callout failed
            if (!isSuccess && newRetryCounter == 3 && String.isNotBlank(caseKey)) {
            	finalRetrycaseIds.add(caseKey);
             }
            
            //Create a CDB Integration Log Record and add it to a list
			Core_CDB_Integration_Log__c cdbLogRec = Core_MDF_CDB_Utility.createCDBLogInstance('MDF AI Audit', caseKey, res, isSuccess, newRetryCounter);
            if(cdbLogRec!=null){
                cdbLogList.add(cdbLogRec);
            }
        }
            // Bulk log Exceptions
            if(!calloutExceptions.isEmpty()) {
                Core_MDF_CCP_UtilityClass.logErrors(calloutExceptions);
            }
            
            //Upsert CDB Integration Log List
            if (!cdbLogList.isEmpty()) {
                Core_MDF_CDB_Utility.upsertCDBIntegrationLogList(cdbLogList);
            }
            
            List<Core_MDF_Scorecard__c> scorecardUpdtLst = new List<Core_MDF_Scorecard__c>();
            //If Max retry attempt reached Update scorecard status as AI Processing Failed
            if (!finalRetrycaseIds.isEmpty()) {
                scorecardUpdtLst = [ SELECT Id, Core_MDF_AI_Processing_Status_Nm__c,Core_MDF_Case_Id__c FROM Core_MDF_Scorecard__c WHERE Core_MDF_Case_Id__c IN :finalRetrycaseIds];
                for (Core_MDF_Scorecard__c scorecardRec : scorecardUpdtLst) {
                    scorecardRec.Core_MDF_AI_Processing_Status_Nm__c = 'AI Processing Failed';
                }
            }
            //If scorecard update failed create a log record with case Id as key and error as value
            if (!scorecardUpdtLst.isEmpty()) {
                Core_MDF_CDB_Utility.updateRecordsList(scorecardUpdtLst, 'Core_MDF_Case_Id__c', 'Audit status update failed for Case: ', 'Case');
            }
    }
   catch (Exception exp) {Core_MDF_CCP_UtilityClass.logError(exp);
       } 
    }
     /***********************************************************************************************************
    Method Name:        getScorecardData
    Description:        Query and return scorecard data for given case IDs
    Added By:           Sinduja/Shubhra 02-02-2025
    ************************************************************************************************************/
    public static Map<Id, Core_MDF_Scorecard__c> getScorecardData(Set<Id> caseIds) {
        Map<Id, Core_MDF_Scorecard__c> caseIdToScorecardMap = new Map<Id, Core_MDF_Scorecard__c>();
        List<Core_MDF_Scorecard__c>scorecardAIClearUpdateList = new List<Core_MDF_Scorecard__c>();//Clear AI Fields
              
        try {
            // Query and populate map directly
            for (Core_MDF_Scorecard__c scorecard : [
                SELECT Id, Core_MDF_Case_Id__c,
                    Core_MDF_AI_Audit_Summary_Txt__c,Core_MDF_AI_Comments_Txt__c,Core_MDF_AI_Attribution_Comments_Txt__c,
                    Core_MDF_AI_Engagement_Comments_Txt__c,Core_MDF_AI_POP_Comments_Txt__c,Core_MDF_AI_PII_Present_Nm__c,
                    Core_MDF_AI_POC_Strength_Nm__c,Core_MDF_AI_Processing_Status_Nm__c,Core_MDF_AI_Recommend_Investigation_Ind__c,
                    Core_MDF_AI_Attribution_Score_Nm__c,Core_MDF_AI_Engagement_Score_Nm__c,Core_MDF_AI_POP_Score_Nm__c
                FROM Core_MDF_Scorecard__c 
                WHERE Core_MDF_Case_Id__c IN :caseIds
            ]) {
                caseIdToScorecardMap.put(scorecard.Core_MDF_Case_Id__c, scorecard);
                
                //Clear AI Fields start
                if(scorecard.Core_MDF_AI_Processing_Status_Nm__c!=null){
                    scorecard.Core_MDF_AI_Processing_Status_Nm__c = null;
                    scorecard.Core_MDF_AI_Comments_Txt__c = null;
                    scorecard.Core_MDF_AI_Audit_Summary_Txt__c = null;
                    scorecard.Core_MDF_AI_Attribution_Comments_Txt__c = null;
                    scorecard.Core_MDF_AI_Engagement_Comments_Txt__c = null;
                    scorecard.Core_MDF_AI_POP_Comments_Txt__c = null;
                    scorecard.Core_MDF_AI_PII_Present_Nm__c = null;
                    scorecard.Core_MDF_AI_POC_Strength_Nm__c = null;
                    scorecard.Core_MDF_AI_Recommend_Investigation_Ind__c = false;
                    scorecard.Core_MDF_AI_Attribution_Score_Nm__c = null;
                    scorecard.Core_MDF_AI_Engagement_Score_Nm__c = null;
                    scorecard.Core_MDF_AI_POP_Score_Nm__c = null;
                //Clear AI Fields end
                scorecardAIClearUpdateList.add(scorecard);
                }
               
            }
            //Clear AI Fields - Update scorecards using utility method
            if (!scorecardAIClearUpdateList.isEmpty()) {
                Core_MDF_CDB_Utility.updateRecordsList(scorecardAIClearUpdateList, 'Core_MDF_Case_Id__c','Failed to clear AI fields for Scorecard related to Case:', 'Core_MDF_Scorecard__c');
            }
            //Clear AI Fields end
            
        } catch (Exception exp) {Core_MDF_CCP_UtilityClass.logError(exp);
        }
        
        return caseIdToScorecardMap;
    }
    /***********************************************************************************************************
    Method Name:        getChecklistData
    Description:        Query and return checklist data for given case IDs
    Added By:           Sinduja/Shubhra 02-02-2025
    ************************************************************************************************************/
    public static Map<Id, List<ChecklistWrapper>> getChecklistData(Set<Id> caseIds) {
        Map<Id, List<ChecklistWrapper>> caseIdToChecklistWrappersMap = new Map<Id, List<ChecklistWrapper>>();
        List<Core_MDF_Claim_Case_Checklist__c> checklistAIClearUpdateList = new List<Core_MDF_Claim_Case_Checklist__c>();
        
        try {
            // Query and populate map directly
            for (Core_MDF_Claim_Case_Checklist__c checklist : [
                SELECT Id, Core_MDF_Case_ID__c, Core_MDF_Case_Review_Findings__c, 
                       Core_MDF_Checklist_Category__c, Core_MDF_Checklist_Description__c, 
                       Core_MDF_Checklist_Item__c, Core_MDF_Claim_Case_Review_Findings__c,
                	   Core_MDF_AI_Checklist_Status_Nm__c,Core_MDF_AI_Generated_Comments_Txt__c
                FROM Core_MDF_Claim_Case_Checklist__c  
                WHERE Core_MDF_Case_ID__c IN :caseIds
            ]) {
                if (!caseIdToChecklistWrappersMap.containsKey(checklist.Core_MDF_Case_ID__c)) {
                    caseIdToChecklistWrappersMap.put(checklist.Core_MDF_Case_ID__c, new List<ChecklistWrapper>());
                }
                
                // Create ChecklistWrapper
                ChecklistWrapper checklistWrap = new ChecklistWrapper();
                checklistWrap.checklistId = checklist.Id;
                checklistWrap.checklistCategory = checklist.Core_MDF_Checklist_Category__c;
                checklistWrap.checklistDescription = checklist.Core_MDF_Checklist_Description__c;
                checklistWrap.checklistItem = checklist.Core_MDF_Checklist_Item__c;
                checklistWrap.claimCaseReviewFindings = checklist.Core_MDF_Claim_Case_Review_Findings__c;
                
                caseIdToChecklistWrappersMap.get(checklist.Core_MDF_Case_ID__c).add(checklistWrap);
                
                //Clear AI Fields
                if(checklist.Core_MDF_AI_Checklist_Status_Nm__c!=null){
                    checklist.Core_MDF_AI_Checklist_Status_Nm__c = null;
                    checklist.Core_MDF_AI_Generated_Comments_Txt__c = null;
                checklistAIClearUpdateList.add(checklist);
                }
             }
                //Update scorecards using utility method
                if (!checklistAIClearUpdateList.isEmpty()) {
                    Core_MDF_CDB_Utility.updateRecordsList(checklistAIClearUpdateList, 'Core_MDF_Case_Id__c','Failed to clear AI fields for Checklist related to Case:', 'Core_MDF_Claim_Case_Checklist__c');
                }
                //Clear AI Fields end
        } catch (Exception exp) {Core_MDF_CCP_UtilityClass.logError(exp);
        }
    return caseIdToChecklistWrappersMap;
}

 /***********************************************************************************************************
    Method Name:        getSpifData
    Description:        Method to prepare the payload for SPIF products
    Added By:           Aswin Selvaraj 10-Sep-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
public static Map<Id, List<ActivitySegmentWrapper>> getSpifData(List<Case> cases) {

    //map to hold the actiivt spif, Key- Activity Id, value- list of Spif wrapper 
    Map<Id, List<ActivitySegmentWrapper>> resultMap =new Map<Id, List<ActivitySegmentWrapper>>();
    //map to hold the pfr id & its respective case id
    Map<Id, Id> requestIdToCaseId =new Map<Id, Id>();

    try {

        for (Case cse : cases) {

            if (cse.Core_MDF_Claim_Lookup_Id__r != null && cse.Core_MDF_Claim_Lookup_Id__r.RequestId != null) {

                requestIdToCaseId.put(cse.Core_MDF_Claim_Lookup_Id__r.RequestId,cse.Id);
            }
        }

        //Key = SegmentId, map to hold the segment level details for each segment
        Map<Id, ActivitySegmentWrapper> segmentMap = new Map<Id, ActivitySegmentWrapper>();

        //Key = SegmentId,Value = Product Family Map- Key=productfamily name, value- products for each family
        Map<Id, Map<String, spifWrapper>> segmentFamilyMap = new Map<Id, Map<String, spifWrapper>>();

        //main(parent) wrapper to hold the PFRId and the collection of segment details (including the products)
        Map<Id, List<ActivitySegmentWrapper>> requestToSegmentMap = new Map<Id, List<ActivitySegmentWrapper>>();
		
        //Query to fetch the segmentId,productfamily & product based on the PFR id
        for (Core_MDF_Segment_Product_Mapping__c spm : [SELECT Id,Core_MDF_Product_Name_txt__c,Core_MDF_Product_Family__c,
                                                        Core_MDF_Activity_Segment_Mapping_id__c,
                                                        Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c,
                                                        Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Maximum_Bundled_Volume_nbr__c,
                                                        Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Maximum_Cost_of_Bundle_nbr__c,
                                                        Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Estimated_Share_of_SPIF_amt__c,
                                                        Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Partner_Fund_Request_id__c,
                                                        Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_SPIF_Notes_internal_only_txt__c 
                                                        FROM Core_MDF_Segment_Product_Mapping__c WHERE Core_MDF_Active_Ind__c = TRUE AND 
                                                        Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Active_ind__c = TRUE AND 
                                                        Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Partner_Fund_Request_id__c IN :requestIdToCaseId.keySet()
                                                        ]) {

            Id requestId = spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Partner_Fund_Request_id__c;
            Id segmentId = spm.Core_MDF_Activity_Segment_Mapping_id__c;
            String familyName = spm.Core_MDF_Product_Family__c;

            /*
             * Create Activity Segment Wrapper once
             segmentMap = Map to hold the parent segment details(multiple segments)
             key-segment id, value- segment details
             */
            if (!segmentMap.containsKey(segmentId)) {

                ActivitySegmentWrapper segWrap = new ActivitySegmentWrapper();
                segWrap.segmentName = spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Segment_Name_nm__c;
                segWrap.maxBundledVol = spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Maximum_Bundled_Volume_nbr__c;
                segWrap.maxCostBundle = spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Maximum_Cost_of_Bundle_nbr__c;
                segWrap.estShareIncentive = spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_Estimated_Share_of_SPIF_amt__c;
                segWrap.spifInternalNotes =spm.Core_MDF_Activity_Segment_Mapping_id__r.Core_MDF_SPIF_Notes_internal_only_txt__c;
            
                //map-hold the parent segment details
                segmentMap.put(segmentId, segWrap);

                //Set the segmentId only once
                segmentFamilyMap.put(segmentId,new Map<String, spifWrapper>());

                //Final map- Set the key
                if (!requestToSegmentMap.containsKey(requestId)) {
                    requestToSegmentMap.put(requestId,new List<ActivitySegmentWrapper>());
                }
                //Adding the parent segment details based on the Actiivty Id
                //Ex:- if PFR has 2 segments, then this map will hold 1 key with 2 values
                //key-pfrId, value- {Segment 1},{Segment 2}
                requestToSegmentMap.get(requestId).add(segWrap);
            }
            //key- Product family name, value-products wrapper (child wrapper)
            Map<String, spifWrapper> familyMap = segmentFamilyMap.get(segmentId);

            /*
             * Create product family once within segment
             */
            if (!familyMap.containsKey(familyName)) {

                spifWrapper familyWrapper = new spifWrapper();
                familyWrapper.productFamily = familyName;
                //Key- product family name, value-product family wrapper (family name & product list)
                familyMap.put(familyName,familyWrapper);
                
                //Based on the segment (for each segment)- we are adding the respective productsfamily wrapper
                //productfamily wrapper is a list (single segment can have multiple product families)
                //Adding the productfamilyname(Spifwrapper) details to the parent ActivitySegmentWrapper based on the segmentId
                //segmentMap references the parentwrapper
                segmentMap.get(segmentId).productFamilies.add(familyWrapper);
            }
            //Adding the products to the spifwrapper based on the familyname (spifwrapper reference will update the mainwrapper)
            familyMap.get(familyName).productName.add(spm.Core_MDF_Product_Name_txt__c);
        }

        resultMap = requestToSegmentMap;

    } catch (Exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);
    }

    return resultMap;
}

    /***********************************************************************************************************
    Method Name:        getAuditDocumentData
    Description:        Query and return audit document data for given case IDs
    Added By:           Sinduja/Shubhra 02-02-2025
    ************************************************************************************************************/
    public static Map<Id, List<DocumentWrapper>> getAuditDocumentData(Set<Id> caseIds) {
        Map<Id, List<DocumentWrapper>> caseIdToDocumentWrappersMap = new Map<Id, List<DocumentWrapper>>();
        
        try {
            for(Core_MDF_Audit_Document__c document : [
                SELECT Id, Core_MDF_Audit__c, Core_MDF_SFT_File_Download_URL__c, 
                       Core_MDF_Old_Document_Id__c, Core_MDF_Claim__c,
                       Core_MDF_SFT_File_Download_Ind__c, Core_MDF_Document_Types__c, Core_MDF_Download_Document_Title_txt__c, Core_MDF_Document_Title__c
                FROM Core_MDF_Audit_Document__c 
                WHERE Core_MDF_Audit__c IN :caseIds
            ]) {
                DocumentWrapper wrappedDocument = new DocumentWrapper(document);
                
              	if(!caseIdToDocumentWrappersMap.containsKey(document.Core_MDF_Audit__c)) {
                	caseIdToDocumentWrappersMap.put(document.Core_MDF_Audit__c, new List<DocumentWrapper>());
                 }
                caseIdToDocumentWrappersMap.get(document.Core_MDF_Audit__c).add(wrappedDocument);
            }
            
        } catch (Exception exp) {Core_MDF_CCP_UtilityClass.logError(exp);
        }
        
        return caseIdToDocumentWrappersMap;
    }
    public class CDBOutboundWrapper {
        public ClaimCaseWrapper claimCaseDetails;
        public ScorecardWrapper scorecardDetails;
        public List<ChecklistWrapper> checklistDetails;
        public List<DocumentWrapper> documentDetails;
        public List<ActivitySegmentWrapper> spifDetails;
    }
    
    public class ClaimCaseWrapper{
        public Id caseId;
        public Date activityEndDate;
        //Aswin
        public Date activityStartDate;
        public Decimal activityIntelContr;
        public Decimal activitySpendingLimit;
        public Decimal claimExcessReqAmt;

        public String activityCategory;
        public String activityType;
        public Boolean strategicMarketingFundInd;
        public String program;
        public String budgetType;
        public Decimal totalInvoiceAmountLocal;
        public Decimal costNotReimbursableLocal;
        public Decimal claimTaxesLocal;
        public Decimal reimbursableAmountUSD;
        public Decimal reimbursableAmountLocal;
        public String claimCurrency;
        public String claimCountry;
        public String brand;
        public String productType;
        public String technology;
        public String invoiceNumber;
        public Date invoiceDate;
        public Decimal exchangeRate;
        public String claimId;
        public Date claimStartDate;
        public Date claimEndDate;
        public Boolean duplicateClaim;
        public Boolean thirdPartyPOPDocReqInd;
        public Decimal reimbursementAmountUSD;
        public String activityCountry;
        public Decimal noOfAttendees;
        public Decimal requestedAmountUSD;
        public String atfFlag;
        
    }
   
    public class ScorecardWrapper{
        public Id scorecardId;
    }
    public class ChecklistWrapper{
        public Id checklistId;
        public String checklistCategory;
        public String checklistDescription;
        public String checklistItem;
        public String claimCaseReviewFindings;
        
    }
    public class ActivitySegmentWrapper {
        public Decimal maxBundledVol;
        public String segmentName;
        public Decimal maxCostBundle;
        public Decimal estShareIncentive;
        public String spifInternalNotes;
        public List<spifWrapper> productFamilies;

        public ActivitySegmentWrapper() {
            productFamilies = new List<spifWrapper>();
        }
    }

    public class spifWrapper {
        public String productFamily;
        public List<String> productName;

        public spifWrapper() {
            productName = new List<String>();
        }
    }

    public class DocumentWrapper {
        public String appFileId;
        public Boolean sftFileAvailableInd;
        //public String sftFileDownloadURL;
        public String documentType;
        public String downloadDocumentTitle;
        public String documentTitle;
    
        public DocumentWrapper(Core_MDF_Audit_Document__c document) {
            this.appFileId = document.Core_MDF_Old_Document_Id__c;
            this.sftFileAvailableInd = document.Core_MDF_SFT_File_Download_Ind__c;
            //this.sftFileDownloadURL = document.Core_MDF_SFT_File_Download_URL__c;
            this.documentType = document.Core_MDF_Document_Types__c;
            this.downloadDocumentTitle = document.Core_MDF_Download_Document_Title_txt__c;
            this.documentTitle = document.Core_MDF_Document_Title__c;
        }
    }
    // Custom exception for callout errors that can be instantiated anywhere
     public class CDBCalloutException extends Exception {}
    
}