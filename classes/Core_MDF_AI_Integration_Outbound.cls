/****************************************************************************************************************************************************
 * Class Name      : Core_MDF_AI_Integration_Outbound
 * Version               : 1.0
 * Created Date          : 09-18-2025
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Sham                09-18-2025        class for CDB Outbound Integartion for MDF AI PIC Process.
 ******************************************************************************************************************************************************/
public without sharing class Core_MDF_AI_Integration_Outbound {
     Public static Integer LONG_TEXT_AREA_LIMIT = Core_MDF_CCP_ConstantClass.LONG_TEXT_AREA_LIMIT;
    
    /*****************************************************************************************************************************************
    Method Name:        generateAIResponseForPICProcess
        Description:        To Check claim status change for MDF AI PIC Process.
        @Added By:          Sham - 10-06-2025
    Modified By:        Date:       Changes:
         ******************************************************************************************************************************************/
    
    public static void generateAIResponseForPICProcess(Map<Id,PartnerFundClaim> newClaimMap, String Context)//Map<Id,PartnerFundClaim> oldClaimMap
    {
        try {
            Map<Id,PartnerFundClaim> claimRecordsMap = new Map<Id,PartnerFundClaim>();
            //Added by VB
            for (Id claimId : newClaimMap.keySet()) {
                PartnerFundClaim newClaim = newClaimMap.get(claimId);
                // Process only if status is 'PIC Pending'
                if (Context == 'insert' || newClaim.Core_MDF_Status__c == 'PIC Pending') {
                    claimRecordsMap.put(claimId, newClaim);
                }
            }
            
            if (!claimRecordsMap.isEmpty()) {
                fetchClaimDocAndPICReviewDetails(claimRecordsMap, new Map<Id, Map<Id,Core_CDB_Integration_Log__c>>(),new Map<Id,Core_MDF_PIC_Review__c>());
            }
        } catch (Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
        }
    }
    /*****************************************************************************************************************************************
    Method Name:        fetchClaimDocAndPICReviewDetails
        Description:        To Fetch Claim, Questions and Document Details, then serialize it into a JSON string for Integration outbound.
        @Added By:          Sham - 09-18-2025
    Modified By:        Date:       Changes:
         ******************************************************************************************************************************************/
    @AuraEnabled
    public static String fetchClaimDocAndPICReviewDetails(Map<Id,PartnerFundClaim> claimRecordsMap, Map<Id, Map<Id,Core_CDB_Integration_Log__c>> claimIdToPicReviewIdToFinalCDBLog ,  Map<Id, Core_MDF_PIC_Review__c> picReviewMap)
    {
        try{
            Map<Id,CDBOutboundWrapper> claimIdToCDBObmWrapMap = new Map<Id,CDBOutboundWrapper>();
            Map<String,String> compKeyToJsonMap = new Map<String,String>();
            Map<Id, List<QuestionsWrapper>> claimIdToQnLstMap = new Map<Id, List<QuestionsWrapper>>();
            Map<id,List<DocumentWrapper>> claimIdToDocLstMap =new Map<id,List<DocumentWrapper>>();
            Map<Id, Integer> claimIdToNxtMnlCycleNbrMap = new Map<Id, Integer>();
            Map<Id, Integer> claimIdToLastAICycleNbrMap = new Map<Id, Integer>();
            Map<Id,Core_MDF_PIC_Review__c> claimIdToOldAndNewPICReviewMap = new Map<Id,Core_MDF_PIC_Review__c>();
            Set<Id> finalizedClaims = new Set<Id>();
            Map<String, Integer> recordIdToPrevRetryCount = new Map<String, Integer>();
            Map<Id, Core_CDB_Integration_Log__c> reviewIdToPrevCDBLog = new Map<Id, Core_CDB_Integration_Log__c>();
            Boolean isRetryInvocation = (claimIdToPicReviewIdToFinalCDBLog != null && !claimIdToPicReviewIdToFinalCDBLog.isEmpty());
            String compositeKey;
            Set<Id> claimIds = claimRecordsMap.keySet();
            List<PartnerFundClaim> claimRecords = claimRecordsMap.values();
            Map<Id,Core_MDF_PIC_Review__c> claimIdToExsistingPICReviewMap = new Map<Id,Core_MDF_PIC_Review__c>();// MDF POP Schema Change 
            
            // Get all Questions for all claims
            claimIdToQnLstMap = fetchQuestionRecords(claimRecords);
            
            // Process documents
            for(Core_MDF_Audit_Document__c document:[SELECT id,Core_MDF_SFT_File_Download_URL__c,Core_MDF_Old_Document_Id__c,Core_MDF_Claim__c,Core_MDF_SFT_File_Download_Ind__c,Core_MDF_Document_Types__c,Core_MDF_Download_Document_Title_txt__c,Core_MDF_Document_Title__c
                                                     FROM Core_MDF_Audit_Document__c 
                                                     WHERE Core_MDF_Claim__c IN:claimIds])
            {
                DocumentWrapper wrappedDocument = new DocumentWrapper(document);
                if(document.Core_MDF_Claim__c != null)
                {
                    if(!claimIdToDocLstMap.containsKey(document.Core_MDF_Claim__c)) {
                        claimIdToDocLstMap.put(document.Core_MDF_Claim__c, new List<DocumentWrapper>());
                    }
                    claimIdToDocLstMap.get(document.Core_MDF_Claim__c).add(wrappedDocument);
                }
            }
            
            // Process PIC reviews for Next PIC Review
            if (!isRetryInvocation){
                for (Core_MDF_PIC_Review__c picReview : [ SELECT Core_MDF_Claim_ID_id__c,Core_MDF_CycleNumber_nbr__c,Core_MDF_AI_PIC_Review_Ind__c,Core_MDF_AI_CycleNumber_nbr__c,CreatedDate,Core_MDF_External_Id__c,Core_MDF_Review_Status_nm__c
                                                 FROM Core_MDF_PIC_Review__c
                                                 WHERE Core_MDF_Claim_ID_id__c IN :claimIds
                                                 ORDER BY Core_MDF_Claim_ID_id__c, Core_MDF_CycleNumber_nbr__c DESC, CreatedDate DESC])
                {
                    Id claimId = picReview.Core_MDF_Claim_ID_id__c;
                    if (finalizedClaims.contains(claimId)){
                        continue;
                    }
                    
                    Boolean isAIReview = picReview.Core_MDF_AI_PIC_Review_Ind__c;
                    Integer manualCycleNbr = (Integer) picReview.Core_MDF_CycleNumber_nbr__c;
                    Integer aiCycleNbr = (Integer) picReview.Core_MDF_AI_CycleNumber_nbr__c;
                    
                    //POP Schema Changes Mapping latest/exsisting PIC Review to claim
                    claimIdToExsistingPICReviewMap.put(claimId,picReview); 
                    
                    if (isAIReview) { // AI review: Update both maps, manualCycleNbr as is
                        if (manualCycleNbr != null)
                        {
                            claimIdToNxtMnlCycleNbrMap.put(claimId, manualCycleNbr);
                        }
                        if (aiCycleNbr != null)
                        {
                            claimIdToLastAICycleNbrMap.put(claimId, aiCycleNbr);
                        }
                    }
                    else
                    { // Manual review: only manual map with +1
                        if (manualCycleNbr != null)
                        {
                            claimIdToNxtMnlCycleNbrMap.put(claimId, manualCycleNbr + 1);
                        } // aiCycleNbr is not present when manual
                    }
                    
                    finalizedClaims.add(claimId);
                }
            }
            
            // Creating mainWrapper for each claim
            for(PartnerFundClaim claimRecord:claimRecords)
            {
                // Build Claim wrapper
                ClaimWrapper claimWrap = new ClaimWrapper();
                claimWrap.executionStartDate = claimRecord.Core_MDF_Ad_Run_Start_Date__c;
                claimWrap.executionEndDate   = claimRecord.Core_MDF_Ad_Run_End_Date__c;
                claimWrap.reimbAmtLocal      = claimRecord.Core_MDF_Reimbursable_TransactionAmt_Loc__c;
                claimWrap.totalAmountLocal   = claimRecord.Core_MDF_Total_Invoice_Amount_Local__c;
                claimWrap.pocCurrency        = claimRecord.Core_MDF_Currency__c;
                claimWrap.activityType       = claimRecord.Core_MDF_Activity_Types__c;
                claimWrap.claimId            = claimRecord.Id;
                
                // Build outbound wrapper
                CDBOutboundWrapper mainWrapper = new CDBOutboundWrapper();
                mainWrapper.claimDetails   = claimWrap;
                if(!claimIdToDocLstMap.isEmpty()) {
                    mainWrapper.documentDetails = claimIdToDocLstMap.get(claimRecord.Id);
                }
                if(!claimIdToQnLstMap.isEmpty()){
                mainWrapper.questions       = claimIdToQnLstMap.get(claimRecord.Id);
                }
                
                // Handle retry
                if (isRetryInvocation && claimIdToPicReviewIdToFinalCDBLog.containsKey(claimRecord.Id)) {
                    Map<Id, Core_CDB_Integration_Log__c> innerMap = claimIdToPicReviewIdToFinalCDBLog.get(claimRecord.Id);
                    if (innerMap != null && !innerMap.isEmpty()) {
                        Id retryPICReviewId = innerMap.keySet().iterator().next();
                        Core_CDB_Integration_Log__c prevLog = innerMap.get(retryPICReviewId);
                        
                        mainWrapper.picReviewId = retryPICReviewId;
                        //POP Schema Changes -Start
                        //Adding externalId present in retryPICReviewId rec to payload for AI PIC Review record processing  
                        Core_MDF_PIC_Review__c picReviewRec = picReviewMap.get(retryPICReviewId);
                        if(picReviewRec!=null && picReviewRec.Core_MDF_External_Id__c!=null){
                            mainWrapper.picReviewExternalId = picReviewRec.Core_MDF_External_Id__c;
                        }
                        //Adding externalId to payload for AI PIC Review Detail records processing 
                        if(mainWrapper.questions!=null ){
                            addExternalId(retryPICReviewId,mainWrapper);
                        }
                        //POP Schema Changes -End
                        compositeKey = prevLog?.Core_Record_Id__c;
                        
                        Integer prevRetry = (Integer) prevLog?.Core_Retry_Number_Nbr__c;
                        if (compositeKey != null && prevRetry != null) {
                            recordIdToPrevRetryCount.put(compositeKey, prevRetry);
                        }
                        claimIdToCDBObmWrapMap.put(claimRecord.Id, mainWrapper);
                        String jsonPayload = JSON.serialize(mainWrapper);
                        if (String.isNotBlank(compositeKey)) {
                            compKeyToJsonMap.put(compositeKey, jsonPayload);
                        }
                    }
                }
                
                // Handle non-retry
                else {
                    // Compute next cycles and stage a new AI PIC Review
                    Integer lastMnlCycle = claimIdToNxtMnlCycleNbrMap.get(claimRecord.Id);
                    Integer nxtMnlCycle  = (lastMnlCycle != null) ? lastMnlCycle : 1;
                    
                    Integer lastAICycle = claimIdToLastAICycleNbrMap.get(claimRecord.Id);
                    Integer nxtAICycle  = (lastAICycle != null) ? lastAICycle + 1 : 1;
                    
                    // POP Schema Changes
                    Core_MDF_PIC_Review__c newOrExsistingPICReview = claimIdToExsistingPICReviewMap.get(claimRecord.Id);
                    String externalIdCompKey = String.valueOf(claimRecord.Id) + String.valueOf(nxtMnlCycle);
                    
                    // POP Schema Changes - For AI Cycle = 1 → create a new PIC Review record.
                    // For AI Cycle > 1 → update the previously created record
                    // to maintain a single record per manual cycle.
                    
                    if((nxtAICycle != null && nxtAICycle == 1)){ 
                        
                        newOrExsistingPICReview = new Core_MDF_PIC_Review__c(
                            Core_MDF_CycleNumber_nbr__c       = nxtMnlCycle,
                            Core_MDF_AI_CycleNumber_nbr__c    = nxtAICycle,
                            Core_MDF_AI_PIC_Review_Ind__c     = true,
                            Core_MDF_Claim_ID_id__c           = claimRecord.Id,
                            Core_MDF_StartTime_dtm__c         = System.now(),
                            Core_MDF_External_Id__c           = externalIdCompKey);
                        
                    }else {
                       
                        newOrExsistingPICReview.Core_MDF_CycleNumber_nbr__c       = nxtMnlCycle;
                        newOrExsistingPICReview.Core_MDF_AI_CycleNumber_nbr__c    = nxtAICycle;
                        newOrExsistingPICReview.Core_MDF_StartTime_dtm__c         = System.now();
                        newOrExsistingPICReview.Core_MDF_Review_Status_nm__c      = '';
                        
                    }
                    
                    claimIdToOldAndNewPICReviewMap.put(claimRecord.Id, newOrExsistingPICReview);
                    
                    //POP Schema Changes- Adding the external Id for Pic Review record in CDBOutboundWrapper
                    mainWrapper.picReviewExternalId = externalIdCompKey;
                    
                    claimIdToCDBObmWrapMap.put(claimRecord.Id, mainWrapper);
                }
            }
            
            if (!isRetryInvocation)
            {
                if (!claimIdToOldAndNewPICReviewMap.isEmpty()) {
                    List<Core_MDF_PIC_Review__c> newOrExsisitngPICReviews = new List<Core_MDF_PIC_Review__c>();
                    List<id> picClaimIds = new List<id>();
                    for (Id claimId : claimIdToOldAndNewPICReviewMap.keySet())
                    {
                        newOrExsisitngPICReviews.add(claimIdToOldAndNewPICReviewMap.get(claimId));
                        picClaimIds.add(claimId);
                    }
                    
                    //POP Schema Changes - Upsert
                    Database.UpsertResult[] upsertResultList = Database.upsert(newOrExsisitngPICReviews,Core_MDF_PIC_Review__c.Core_MDF_External_Id__c, false);
                    
                    // Process only successful inserts/updates to build wrappers/json
                    Map<String, List<Database.Error>> claimIdToInsertErrors = new Map<String, List<Database.Error>>();
                    Map<String, String> claimIdToBaseMessage = new Map<String, String>();
                    for (Integer i = 0; i < upsertResultList.size(); i++) {
                        Id claimId = picClaimIds[i];
                        Database.UpsertResult result = upsertResultList[i];
                        
                        if (result.isSuccess()) {
                            Id picReviewId = result.getId();
                            if (claimIdToCDBObmWrapMap.containsKey(claimId)) {
                                CDBOutboundWrapper mainWrapper = claimIdToCDBObmWrapMap.get(claimId);
                                mainWrapper.picReviewId = picReviewId;
                                // POP Schema Changes- Method call to update externalId in question/Subquestion wrapper inside mainWrapper
                                addExternalId(picReviewId,mainWrapper); 
                                
                                String jsonPayload = JSON.serialize(mainWrapper);
                                compositeKey = String.valueOf(claimId) + '-' + String.valueOf(picReviewId);
                                compKeyToJsonMap.put(compositeKey, jsonPayload);
                               
                            }
                        } else {
                            String recordKey = String.valueOf(claimId);
                            List<Database.Error> erros = claimIdToInsertErrors.containsKey(recordKey) ? claimIdToInsertErrors.get(recordKey) : new List<Database.Error>();
                            erros.addAll(result.getErrors());
                            claimIdToInsertErrors.put(recordKey, erros);
                            claimIdToBaseMessage.put(recordKey, 'PIC Review insert/update failed for Claim: ' + recordKey);
                        }
                    }
                    
                    if (!claimIdToInsertErrors.isEmpty()) {
                        collectAndLogDbErrors( claimIdToInsertErrors, claimIdToBaseMessage, 'Core_MDF_PIC_Review__c');
                    }
                }
            }
            
            if(!compKeyToJsonMap.isEmpty())
            {  
               /*Request reqInfo = Request.getCurrent();
               Quiddity executionContext = reqInfo.getQuiddity();
               System.debug('exceution context'+executionContext+'  '+Trigger.isExecuting);*/
                
                if(System.isBatch()) {//Trigger.isExecuting - future
                    makeCDBCallout(compKeyToJsonMap,recordIdToPrevRetryCount);
                } else {
                    makeCDBCalloutWithFuture(compKeyToJsonMap,recordIdToPrevRetryCount);
                }
                return 'SUCCESS';
            }
            // No payload to send, treat it as no outbound sent.
            return 'ERROR'; 
        } catch (Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
            return 'ERROR';
        }
    }
    
    @Future(callout=true)
    public static void makeCDBCalloutWithFuture(Map<String, String> compositeKeyToJsonMap, Map<String, Integer> recordIdToPrevRetryCount) {
        makeCDBCallout(compositeKeyToJsonMap, recordIdToPrevRetryCount);
    }
    
    /***********************************************************************************************************
    Method Name:        makeCDBCallout
        Description:        To call sendCDBPayload method with CDB Payload and handle retry logic.
        @Added By:          Sham - 09-30-2025
    Modified By:        Date:       Changes:
         ************************************************************************************************************/
    public static void makeCDBCallout( Map<String, String> compositeKeyToJsonMap, Map<String, Integer> recordIdToPrevRetryCount)
    {
        try {
            List<Core_CDB_Integration_Log__c> cdbLogList = new List<Core_CDB_Integration_Log__c>();
            // Local aggregation of exceptions for one-shot logging
            List<Exception> calloutExceptions = new List<Exception>();
            //Track PIC Review Ids to mark failed upon 3rd retry failure
            Set<Id> picReviewIds = new Set<Id>();
            
            // Process each payload
            for (String compositeKey : compositeKeyToJsonMap.keySet()) {
                String payload = compositeKeyToJsonMap.get(compositeKey);
                if (String.isBlank(payload)) {
                    continue;
                }
                
                // Send payload to CDB
               
                HttpResponse res = sendCDBPayload(payload);
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
                    Integer prevRetryCounter = recordIdToPrevRetryCount.get(compositeKey);
                    if (prevRetryCounter != null) {
                        newRetryCounter = prevRetryCounter + 1;
                    }
                }
                //Collect PIC Review Id when this is a retry reaching 3 and callout failed
                if (!isSuccess && newRetryCounter == 3 && String.isNotBlank(compositeKey)) {
                    List<String> claimAndPicReviewIds = compositeKey.split('-');
                    if (claimAndPicReviewIds != null && claimAndPicReviewIds.size() == 2 && String.isNotBlank(claimAndPicReviewIds[1])) {
                            Id picReviewId = (Id)claimAndPicReviewIds[1];
                            picReviewIds.add(picReviewId);
                    }
                }
                // Create log record
                Core_CDB_Integration_Log__c logRec = new Core_CDB_Integration_Log__c();
                logRec.Core_Integration_Type__c = 'MDF AI PIC Review';
                logRec.Core_Record_Id__c = compositeKey;
                logRec.Core_Log_Status_Nm__c = isSuccess ? 'Successful' : 'Failed';
                logRec.Core_Retry_Number_Nbr__c = newRetryCounter;
                logRec.Core_Status_Code__c = (res != null) ? String.valueOf(res.getStatusCode()) : '';
                logRec.Core_Status_Message__c = (res != null) ? res.getStatus() : '';
                logrec.Core_Integration_Direction_Nm__c ='Outbound';
                cdbLogList.add(logRec);
            }
            // Bulk log Exceptions
            if(!calloutExceptions.isEmpty()) {
                Core_MDF_CCP_UtilityClass.logErrors(calloutExceptions);
            }

            // Upsert log records if we have any
            if (!cdbLogList.isEmpty()) {
                Database.UpsertResult[] upsertResultList = Database.upsert(cdbLogList, Core_CDB_Integration_Log__c.Core_Record_Id__c, false);
                
                // Process upsert errors with consolidated logging
                Map<String, List<Database.Error>> compKeyToUpsertErrorsMap = new Map<String, List<Database.Error>>();
                Map<String, String> compKeyToBaseMessageMap = new Map<String, String>();
                for (Integer i = 0; i < upsertResultList.size(); i++) {
                    Database.UpsertResult upsertResult = upsertResultList[i];
                     if (!upsertResult.isSuccess()) {
                        String compositeKeyForError = cdbLogList[i].Core_Record_Id__c;
                        List<Database.Error> erros = compKeyToUpsertErrorsMap.containsKey(compositeKeyForError) ? compKeyToUpsertErrorsMap.get(compositeKeyForError) : new List<Database.Error>();
                        erros.addAll(upsertResult.getErrors());
                        compKeyToUpsertErrorsMap.put(compositeKeyForError, erros);
                        compKeyToBaseMessageMap.put(compositeKeyForError, 'CDB Integration Log upsert failed for record: ' + compositeKeyForError);
                    }
                }
                if (!compKeyToUpsertErrorsMap.isEmpty()) {
                    collectAndLogDbErrors( compKeyToUpsertErrorsMap, compKeyToBaseMessageMap,'Core_CDB_Integration_Log__c');
                }
            }
           
            if (!picReviewIds.isEmpty()) {
                
                List<Core_MDF_PIC_Review__c> picReviewUpdtLst = [
                    SELECT Id, Core_MDF_Review_Status_nm__c
                    FROM Core_MDF_PIC_Review__c
                    WHERE Id IN :picReviewIds
                ];
                for (Core_MDF_PIC_Review__c picReview : picReviewUpdtLst) {
                    picReview.Core_MDF_Review_Status_nm__c = 'AI Processing Failed';
                }
                if (!picReviewUpdtLst.isEmpty()) {
                    Database.SaveResult[] updateResults = Database.update(picReviewUpdtLst, false);
                    Map<String, List<Database.Error>> picReviewIdToUpdateErrors = new Map<String, List<Database.Error>>();
                    Map<String, String> picReviewIdToBaseMessage = new Map<String, String>();
                    for (Integer i = 0; i < updateResults.size(); i++) {
                        Database.SaveResult updateResult = updateResults[i];
                        if (!updateResult.isSuccess()) {
                            String picReviewKeyForError = String.valueOf(picReviewUpdtLst[i].Id);
                            List<Database.Error> updateErrors = picReviewIdToUpdateErrors.containsKey(picReviewKeyForError) ? picReviewIdToUpdateErrors.get(picReviewKeyForError) : new List<Database.Error>();
                            updateErrors.addAll(updateResult.getErrors());
                            picReviewIdToUpdateErrors.put(picReviewKeyForError, updateErrors);
                            picReviewIdToBaseMessage.put(picReviewKeyForError, 'PIC Review status update failed for PIC Review: ' + picReviewKeyForError);
                        }
                    }
                    if (!picReviewIdToUpdateErrors.isEmpty()) {
                        collectAndLogDbErrors(picReviewIdToUpdateErrors, picReviewIdToBaseMessage, 'Core_MDF_PIC_Review__c');
                    }
                }
            }
        } catch (Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
        }
    }
    
    
    /***********************************************************************************************************
    Method Name:        sendCDBPayload
        Description:        To send the payload to CDB system
        @Added By:          Sham - 10-03-2025
    Modified By:        Date:       Changes:
         ************************************************************************************************************/
    
    public static HttpResponse sendCDBPayload(String payload)
    {
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:APIGEE_MDF_POP');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');
            req.setBody(payload);
            HttpResponse resp = new Http().send(req);
            return resp;
        }catch(Exception exp){
            HttpResponse errResp = new HttpResponse();
            errResp.setStatusCode(503);
            errResp.setStatus('APEX_EXCEPTION');
            String expnMsg = 'Unhandled CDB callout Apex exception: ' + (exp.getMessage() != null ? exp.getMessage() : '');//always prepend 
            errResp.setBody(expnMsg);
            return errResp;
        }
    }
    
    /***********************************************************************************************************
    Method Name:        fetchQuestionRecords
        Description:        To Fetch all teh questions frm PIC Review Question object
        @Added By:          Sham - 10-01-2025
    Modified By:        Date:       Changes:
         ************************************************************************************************************/
    
    public static Map<Id,List<QuestionsWrapper>> fetchQuestionRecords(List<PartnerFundClaim> claimRecords)
    {
        Map<Id, QuestionsWrapper> parentWrapperMap = new Map<Id, QuestionsWrapper>();
        Map<Id, List<SubQuestionsWrapper>> subQuestionMap = new Map<Id, List<SubQuestionsWrapper>>();
        Map<String, List<QuestionsWrapper>> compositeKeyToWrappedQuestions = new Map<String, List<QuestionsWrapper>>();
        Map<Id, List<QuestionsWrapper>> claimQuestionMap = new Map<Id, List<QuestionsWrapper>>();
        
        
        
        
        if(claimRecords == null || claimRecords.isEmpty())
        {
            return claimQuestionMap;
        }
        // Extract unique Budget Types and Program Types from Claims.
        Set<String> budgetTypes = new Set<String>();
        Set<String> programTypes = new Set<String>();
        
        for (PartnerFundClaim claim : claimRecords) {
            if (claim.Core_MDF_Budget_Type_Nm__c != null) {
                budgetTypes.add(claim.Core_MDF_Budget_Type_Nm__c);
            }
            if (claim.Core_MDF_Program__c != null) {
                programTypes.add(claim.Core_MDF_Program__c);
            }
            
        }
        
        List<core_MDF_PICReviewQuestion__c> allQuestions  = [SELECT id,Core_MDF_Question_English_txt__c,Core_MDF_Question_File_Type_nm__c,Core_MDF_Budget_Type_nm__c,Name, Core_MDF_Parent_Question__r.Name,
                                                             Core_MDF_Sort_Order__c,Core_MDF_Sub_Question_Ind__c,Core_MDF_All_Budget_Types_Ind__c,Core_MDF_Channel_Program__c,Core_MDF_All_Programs_Ind__c,Core_MDF_Third_Party_Ind__c,Core_MDF_Outcome_Based_Indicator_Ind__c
                                                             FROM core_MDF_PICReviewQuestion__c where Core_MDF_EffectiveDate_dt__c <= today 
                                                             AND Core_MDF_IneffectiveDate_dt__c >= today AND Core_MDF_Is_Active_ind__c = true
                                                             AND (Core_MDF_Budget_Type_nm__c IN :budgetTypes OR Core_MDF_All_Budget_Types_Ind__c = true)
                                                             AND (Core_MDF_Channel_Program__c IN :programTypes OR Core_MDF_All_Programs_Ind__c = true)
                                                             AND Core_MDF_Question_File_Type_nm__c!='NEX'
                                                             ORDER BY Core_MDF_Sort_Order__c];
        
        for (core_MDF_PICReviewQuestion__c question : allQuestions){
            if (question.Core_MDF_Parent_Question__c == null) {
                // create wrapper for parent question
                parentWrapperMap.put(question.Id, new QuestionsWrapper(question));
            } else {
                // add Subquestiongroup under parent
                if (!subQuestionMap.containsKey(question.Core_MDF_Parent_Question__c)) {
                    subQuestionMap.put(question.Core_MDF_Parent_Question__c, new List<SubQuestionsWrapper>());
                }
                subQuestionMap.get(question.Core_MDF_Parent_Question__c).add(new SubQuestionsWrapper(question));
            }
        }
        Map<Id, core_MDF_PICReviewQuestion__c> allQuestionsMap = new Map<Id, core_MDF_PICReviewQuestion__c>(allQuestions);
        
        for (Id parentId : parentWrapperMap.keySet()) {
            QuestionsWrapper question = parentWrapperMap.get(parentId);
            
            // Attach subquestions
            if (subQuestionMap.containsKey(parentId)) {
                question.subQuestions.addAll(subQuestionMap.get(parentId));
            }
            // Build composite key from the parent question only
            core_MDF_PICReviewQuestion__c qtn = allQuestionsMap.get(parentId);
            
            String programKey = qtn.Core_MDF_All_Programs_Ind__c ? 'ALL' : qtn.Core_MDF_Channel_Program__c;
            
            Boolean outcomeBasedKey = qtn.Core_MDF_Outcome_Based_Indicator_Ind__c;
            Boolean thirdPartyKey = qtn.Core_MDF_Third_Party_Ind__c;
            String compositeKey = programKey + ':' + outcomeBasedKey + ':' + thirdPartyKey;
            
            if (!compositeKeyToWrappedQuestions.containsKey(compositeKey)) {
                compositeKeyToWrappedQuestions.put(compositeKey, new List<QuestionsWrapper>());
            }
            
            compositeKeyToWrappedQuestions.get(compositeKey).add(question);
            
        }
        
        
        
        // Loop through each claim and add matching questions
        for (PartnerFundClaim claim : claimRecords) {
            List<QuestionsWrapper> wrappers = new List<QuestionsWrapper>();
            
            //Prepare matching key
            Boolean isOutcomeBasedClaim = (claim.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && claim.Core_MDF_OutcomeBased_Ind__c == true );
            
            Boolean isThirdPartyClaim = claim.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c;
            String program = claim.Core_MDF_Program__c;
            
            List<QuestionsWrapper> matchedQuestions = new List<QuestionsWrapper>();
            
            // Add non-3rd party Questions first
            addMatchingQuestions(program, isOutcomeBasedClaim, false, matchedQuestions, compositeKeyToWrappedQuestions);
            
            // If Claim is 3rd party add third-party
            if (isThirdPartyClaim) {
                addMatchingQuestions(program, isOutcomeBasedClaim, true, matchedQuestions, compositeKeyToWrappedQuestions);
            }
            Integer subQuestionCount = 0;
            for (QuestionsWrapper qw : matchedQuestions) {
                subQuestionCount += (qw.subQuestions != null) ? qw.subQuestions.size() : 0;
            }
            
            Integer mainQuestionCount = matchedQuestions.size();
            Integer totalQuestions = mainQuestionCount + subQuestionCount;
            
            
            claimQuestionMap.put(claim.Id, matchedQuestions);
            
        }
        
        
        return claimQuestionMap;
        
    }
/***********************************************************************************************************
    Method Name:        addMatchingQuestions
        Description:        To add matching questions to the list of questions
        @Added By:          Sham - 10-27-2025
    Modified By:        Date:       Changes:
************************************************************************************************************/
     public static void addMatchingQuestions(String program,Boolean isOutcomeBasedClaim,Boolean isThirdParty,List<QuestionsWrapper> matchedQuestions,Map<String, List<QuestionsWrapper>> compositeKeyToWrappedQuestions) 
     {
        String keyProgram = program + ':' + isOutcomeBasedClaim + ':' + isThirdParty;
        String keyAll = 'ALL' + ':' + isOutcomeBasedClaim + ':' + isThirdParty;
        
        if (compositeKeyToWrappedQuestions.containsKey(keyProgram)) {
            matchedQuestions.addAll(compositeKeyToWrappedQuestions.get(keyProgram));
        }
        if (compositeKeyToWrappedQuestions.containsKey(keyAll)) {
            matchedQuestions.addAll(compositeKeyToWrappedQuestions.get(keyAll));
            if (isThirdParty) {
                
            }
        }
    }
    
    /***********************************************************************************************************
    Method Name:        fetchCDBLogRecordsForRetry
        Description:        Method which fetches the CDB Log records that needs to be reprocessed
        Added By:           Bharath - 10-10-2025
        Modified By:        Date:       Changes:
         **********************************************************************************************************/
    public static void fetchCDBLogRecordsForRetry(List<Core_CDB_Integration_Log__c> cdbLogRecords){
        try{
            Set<Id> finalClaimIds = new Set<Id>();
            Map<String, List<String>> claimIdToReviewIdMap = new Map<String, List<String>>();
            Map<String, Core_CDB_Integration_Log__c> compositeKeyToCDBRecordMap = new Map<String, Core_CDB_Integration_Log__c>();
            Map<Id, Map<Id,Core_CDB_Integration_Log__c>> claimIdToPicReviewIdToFinalCDBLog = new Map<Id, Map<Id,Core_CDB_Integration_Log__c>>();
            Map<Id, Core_MDF_PIC_Review__c> picReviewMap = new  Map<Id, Core_MDF_PIC_Review__c>();
            for(Core_CDB_Integration_Log__c log: cdbLogRecords){
                String recIdentifier = log.Core_Record_Id__c;
                
                if (String.isNotBlank(recIdentifier) && recIdentifier.contains('-')) {
                    List<String> parts = recIdentifier.split('-');
                    if (parts.size() == 2) {
                        String claimId = parts[0];
                        String reviewId = parts[1];
                        if(!claimIdToReviewIdMap.containsKey(claimId)){
                            claimIdToReviewIdMap.put(claimId, new List<String>{reviewId});
                        }
                        else{
                            claimIdToReviewIdMap.get(claimId).add(reviewId);
                        }
                        compositeKeyToCDBRecordMap.put(recIdentifier, log);
                    }
                }
            }
            
            if(!claimIdToReviewIdMap.isEmpty()){
                for(Core_MDF_PIC_Review__c review: [SELECT Id, Core_MDF_Claim_ID_id__c,Core_MDF_CycleNumber_nbr__c,Core_MDF_AI_PIC_Review_Ind__c,
                                                    Core_MDF_AI_CycleNumber_nbr__c,Core_MDF_External_Id__c FROM Core_MDF_PIC_Review__c 
                                                WHERE Core_MDF_Claim_ID_id__c IN: claimIdToReviewIdMap.keyset() AND 
                                                Core_MDF_Claim_ID_id__r.Core_MDF_PIC_Review_Completed__c = false and Core_MDF_Claim_ID_id__r.Core_MDF_Status__c = 'PIC Pending'
                                                ORDER BY Core_MDF_Claim_ID_id__c, Core_MDF_CycleNumber_nbr__c Desc, CreatedDate Desc]){
                    if (finalClaimIds.contains(review.Core_MDF_Claim_ID_id__c)){
                        
                        continue;
                    }
                    if(!review.Core_MDF_AI_PIC_Review_Ind__c){
                        finalClaimIds.add(review.Core_MDF_Claim_ID_id__c);
                        
                        continue;
                    }
                    if(claimIdToReviewIdMap.get(review.Core_MDF_Claim_ID_id__c).contains(review.Id)){
                        
                        if(compositeKeyToCDBRecordMap.containsKey(review.Core_MDF_Claim_ID_id__c + '-' + review.Id)){
                            claimIdToPicReviewIdToFinalCDBLog.put(review.Core_MDF_Claim_ID_id__c, new Map<Id,Core_CDB_Integration_Log__c>{review.Id => compositeKeyToCDBRecordMap.get(review.Core_MDF_Claim_ID_id__c + '-' + review.Id)});
                            finalClaimIds.add(review.Core_MDF_Claim_ID_id__c);
                                                                picReviewMap.put(review.Id, review); //POP Schema Changes - To get external Id from exsisting PIC Review Rec 
                            continue;
                        }
                    }
                     finalClaimIds.add(review.Core_MDF_Claim_ID_id__c);
                }
            }
            
            Map<Id, PartnerFundClaim> claimIdToClaimRecordMap = new Map<Id, PartnerFundClaim>([SELECT id,Core_MDF_OutcomeBased_Ind__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Program__c, Core_MDF_Ad_Run_End_Date__c,Core_MDF_Reimbursable_TransactionAmt_Loc__c,Core_MDF_Activity_Types__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Currency__c,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c FROM PartnerFundClaim 
                                                                                           WHERE Id IN: claimIdToPicReviewIdToFinalCDBLog.keyset()]);
            if(!claimIdToClaimRecordMap.isEmpty() && !claimIdToPicReviewIdToFinalCDBLog.isEmpty()){
                fetchClaimDocAndPICReviewDetails(claimIdToClaimRecordMap, claimIdToPicReviewIdToFinalCDBLog,picReviewMap);//POP Schema Changes - Added picReviewMap parameter
            }
        } catch (Exception exp) {
            Core_MDF_CCP_UtilityClass.logError(exp);
        }
    }
    
    
    /***********************************************************************************************************
    Method Name:        collectAndLogDbErrors
        Description:       Method to log database errors from both Insert and Upert operations
        Added By:           Sham - 10-23-2025
    Modified By:        Date:       Changes:
    **********************************************************************************************************/

     public static void collectAndLogDbErrors( Map<String, List<Database.Error>> errorsByRecordKeyMap,Map<String, String> baseMessageByRecordKeyMap, String sObjectApiName ) {
        if (errorsByRecordKeyMap == null || errorsByRecordKeyMap.isEmpty()) {
            return;
        }
        List<Map<String, String>> coreLogMaps = new List<Map<String, String>>();
        for (String recordIdentifier : errorsByRecordKeyMap.keySet()) {
            List<Database.Error> errors = errorsByRecordKeyMap.get(recordIdentifier);
            if (errors == null || errors.isEmpty()) {
                continue;
            }
            List<String> errorMessages = new List<String>();
            for (Database.Error err : errors) {
                String errorMessage = String.valueOf(err.getStatusCode()) + ': ' +
                    String.valueOf(err.getFields()) + ': ' +
                    String.valueOf(err.getMessage());
                errorMessages.add(errorMessage);
            }
            if (errorMessages.isEmpty()) {
                continue;
            }
            List<String> errorMsgs = new List<String>{
                'Record ' + recordIdentifier + ' | ' + String.join(errorMessages, ' | ')
            };
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Origin__c', 'Core_MDF_AI_Integration_Outbound');
            coreLogMap.put('Core_Severity__c', 'Critical');
            coreLogMap.put('Core_sObjectType__c', sObjectApiName);
            coreLogMap.put('Core_Project__c', 'Consolidated Co-Marketing Program (CCP)');
            coreLogMap.put('Core_Message__c', baseMessageByRecordKeyMap != null ? baseMessageByRecordKeyMap.get(recordIdentifier) : null);
            
            String serialized = JSON.serialize(errorMsgs);
            Integer strLength = serialized.length();
            String details = strLength < LONG_TEXT_AREA_LIMIT ? serialized : serialized.substring(0, LONG_TEXT_AREA_LIMIT);
            coreLogMap.put('Core_Details__c', details);
            coreLogMaps.add(coreLogMap);
        }
        if (!coreLogMaps.isEmpty()) {
           Core_MDF_CCP_UtilityClass.createLogEntries(coreLogMaps);
        }
    }
    /***********************************************************************************************************
Method Name:       addExternalId
Description:       POP Schema Changes - Method to assign the external Id for all the questions and sub questions in wrapper 
Added By:          Shubhra - 27-02-2026
Modified By:       Date:       Changes:
**********************************************************************************************************/
    public static void addExternalId(Id picReviewId,CDBOutboundWrapper mainWrapper) {
        
        List<SubQuestionsWrapper> allSubQues = new List<SubQuestionsWrapper>();
        String picReviewIdStr = String.valueOf(picReviewId);
        
        if (mainWrapper == null || mainWrapper.questions == null) return;
        
        for (QuestionsWrapper ques : mainWrapper.questions) {
            
            ques.picRRExternalId = picReviewIdStr + String.valueOf(ques.questionId);
            allSubQues.addAll(ques.subQuestions);
        }
        
        for (SubQuestionsWrapper subQues : allSubQues) {
            subQues.picRRExternalId = picReviewIdStr +String.valueOf(subQues.questionId);
        }
    }  
    //All Wrappers
    public class CDBOutboundWrapper {
        public Id picReviewId;
        public ClaimWrapper claimDetails;
        public List<QuestionsWrapper> questions;
        public List<DocumentWrapper> documentDetails;
        public String picReviewExternalId; //POP Schema Changes - External Id for Pic Review Rec 
    }
    public class ClaimWrapper
    {
        public String claimId;
        public Date executionStartDate;//Just claimStartDt, claimEndDt or startDtOfClaim?
        public Date executionEndDate;
        public Decimal reimbAmtLocal;
        public Decimal totalAmountLocal;
        public String pocCurrency;//claimCurrency ?
        public String activityType;
    }
    
    public class DocumentWrapper
    {
        public String appFileId;
        public Boolean sftFileAvailableInd;
        public String documentType;
        public String downloadDocumentTitle;
        public String documentTitle;
        public DocumentWrapper(Core_MDF_Audit_Document__c document)
        {
            this.appFileId = document.Core_MDF_Old_Document_Id__c;
            this.sftFileAvailableInd = document.Core_MDF_SFT_File_Download_Ind__c;
            this.documentType = document.Core_MDF_Document_Types__c;
            this.downloadDocumentTitle = document.Core_MDF_Download_Document_Title_txt__c;
            this.documentTitle = document.Core_MDF_Document_Title__c;
            
        }
    }
    
    public class QuestionsWrapper {
        public Id questionId;
        public String question;//qnText?
        public List<subQuestionsWrapper> subQuestions;
        public String picRRExternalId;//POP Schema Changes - External Id for parent ques
        public QuestionsWrapper(core_MDF_PICReviewQuestion__c picQn)
        {
            this.questionId=picQn.id;
            this.question=picQn.Core_MDF_Question_English_txt__c;
            this.subQuestions=new List<SubQuestionsWrapper>();
        }
    }
    public class SubQuestionsWrapper {
        public id questionId;
        public String question;//qnText or subQntext?
        public String picRRExternalId;//POP Schema Changes - External Id for subQues 
        public SubQuestionsWrapper(core_MDF_PICReviewQuestion__c picQn)
        {
            this.questionId=picQn.id;
            this.question=picQn.Core_MDF_Question_English_txt__c;
        }
    }
    // Custom exception for callout errors that can be instantiated anywhere
     public class CDBCalloutException extends Exception {}
       
    
}