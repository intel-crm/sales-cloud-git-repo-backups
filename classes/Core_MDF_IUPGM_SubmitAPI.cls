/*****************************************************************************************************
Class Name        	:    Core_MDF_IUPGM_SubmitAPI
Test Class Name 	:    Core_MDF_IUPGM_SubmitAPI_Test
Description         :    REST endpoint that converts validated chatbot request summaries into
                          persistent IUPGM staging records and returns submission status.
Created By          :    Ramapriya
******************************************************************************************************/
@RestResource(urlMapping='/access/submitRequest')
global without sharing class Core_MDF_IUPGM_SubmitAPI {
    private static final String COMMON_PROGRAM = 'COMMON';
   /** Inserts a staging request from a validated summary payload and returns the created request number. */
   @HttpPost
   global static String submitRequest() {

        RestRequest  req = RestContext.request;
        RestResponse res = RestContext.response;

        Long   startMs      = System.currentTimeMillis();
        String logResponse  = null;
        Id     logUserId    = null;
        String logProgram   = null;
        String logRole      = null;
        Id     logStagingId = null;
        String logError     = null;
        String logBody      = null;

        try {

            /*
            ================================================================
            STEP 1 â€” PARSE PAYLOAD
            Chatbot sends back the requestSummary from validateRequest.
            ================================================================
            */
            String body = req.requestBody != null ? req.requestBody.toString() : null;
            logBody = body;
            System.debug('submitRequest payload: ' + body);

            if (String.isBlank(body)) {
                res.statusCode = 400;
                return err('Request body is empty.');
            }

            Map<String, Object> p =
                (Map<String, Object>) JSON.deserializeUntyped(body);

            // â”€â”€ Bulk mode detection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // If the payload contains a "requestSummaries" array the chatbot is
            // submitting multiple users validated in a prior bulk validateRequest.
            if (p.containsKey('requestSummaries')) {
                return handleBulkSubmit(p, res);
            }

            // The chatbot may send the whole validateRequest response,
            // or just the requestSummary block. Handle both.
            Map<String, Object> summary = p;
            if (p.containsKey('requestSummary')) {
                summary = (Map<String, Object>) p.get('requestSummary');
            }

            /*
            ================================================================
            STEP 2 â€” EXTRACT ALL VALUES FROM SUMMARY
            All values were resolved by validateRequest. We read them directly.
            ================================================================
            */
            String userId                = str(summary, 'userId');
            String accountIdStr          = str(summary, 'accountId');
            String program               = str(summary, 'program');
            String permissionSetName     = str(summary, 'permissionSetName');
            String agsRoleName           = str(summary, 'agsRoleName');
            Boolean allAccountAccess     = parseBool(summary.get('allAccountAccess'));
            String  geo                  = str(summary, 'geo');
            Boolean allBudgetAccess      = parseBoolNullable(summary.get('allBudgetAccess'));
            String  geoBudgetType        = str(summary, 'geoBudgetType');
            String  approvalRegion       = str(summary, 'approvalRegion');
            String  activityClass        = str(summary, 'activityClassification');
            String  userName             = str(summary, 'userName');
            String  requestorEmail       = str(summary, 'requestorEmail'); // human who raised via chatbot
            String  agsRoleComments      = approverComments(summary);
            String  newUserFullName      = str(summary, 'newUserFullName');
            String  newUserFederationId  = str(summary, 'newUserFederationId');
            String  newUserEmail         = str(summary, 'newUserEmail');
            if (String.isBlank(newUserEmail)) newUserEmail = str(summary, 'userEmail');

            Boolean userNeedsCreation = parseBool(summary.get('userNeedsCreation'));
            if (userNeedsCreation && String.isBlank(newUserFederationId)) {
                newUserFederationId = deriveFederationFromEmail(newUserEmail);
            }

            // Capture for logging (before any early-exit returns)
            logUserId  = String.isNotBlank(userId) ? (Id) userId : null;
            logProgram = program;
            logRole    = permissionSetName;

            // Basic integrity check â€” these must always be present.
            // userId may be blank only when userNeedsCreation=true (user doesn't exist in SF yet).
            if ((String.isBlank(userId) && !userNeedsCreation)
                || String.isBlank(program) || String.isBlank(permissionSetName)) {
                res.statusCode = 400;
                return err('Invalid or incomplete requestSummary. '
                    + 'Please call /access/validateRequest first '
                    + 'and send the returned requestSummary.');
            }
            String accountValidationError = validateAccountRequirementForSummary(summary);
            if (String.isNotBlank(accountValidationError)) {
                res.statusCode = 400;
                return err(accountValidationError);
            }

            Id userId_Id    = String.isNotBlank(userId) ? (Id) userId : null;
            Id accountId_Id = String.isNotBlank(accountIdStr)
                              ? (Id) accountIdStr : null;

            /*
            ================================================================
            STEP 3 â€” SAFETY DUPLICATE CHECK
            In case the user submitted twice or time elapsed.
            Skip when userId is null (new user pending creation â€” no prior record possible).
            ================================================================
            */
            if (userId_Id != null) {
                List<Core_MDF_IUPGM_Request_Staging__c> inflight = [
                    SELECT Id, Name, Core_MDF_Request_Status_nm__c
                    FROM Core_MDF_IUPGM_Request_Staging__c
                    WHERE Core_MDF_IUPGM_User__c    = :userId_Id
                      AND Core_MDF_IUPGM_Role_nm__c = :permissionSetName
                      AND Core_MDF_IUPGM_Program__c  = :program
                      AND Core_MDF_IUPGM_Account__c  = :accountId_Id
                      AND Core_MDF_IUPGM_Region_Sub_Region_nm__c = :geo
                      AND Core_MDF_Is_IUPGM_Processed__c = false
                      AND Core_MDF_Request_Status_nm__c NOT IN (
                          'Error', 'Validation_Failed', 'External_User_Blocked', 'AGS_Rejected'
                      )
                    LIMIT 1
                ];

                if (!inflight.isEmpty()) {
                    String currentStatus =
                        inflight[0].Core_MDF_Request_Status_nm__c
                            .replace('_', ' ').toLowerCase();
                    res.statusCode = 409;
                    return JSON.serialize(new Map<String, Object>{
                        'success'       => false,
                        'duplicate'     => true,
                        'requestNumber' => inflight[0].Name,
                        'status'        => inflight[0].Core_MDF_Request_Status_nm__c,
                        'message'       => (String.isNotBlank(userName) ? userName : 'This user')
                            + ' already has an active request for this role '
                            + '(currently ' + currentStatus + '). '
                            + 'Request: ' + inflight[0].Name
                    });
                }
            }

            /*
            ================================================================
            STEP 4 â€” CREATE STAGING RECORD
            Role fields populated:
              Core_MDF_IUPGM_Role_nm__c   = PS Name (config lookup key)
              Core_MDF_AGS_Role_Name__c   = AGS Role(s) (sent to AGS)
              Core_MDF_Requested_By__c    = running user (audit)
            ================================================================
            */
            Core_MDF_IUPGM_Request_Staging__c staging =
                new Core_MDF_IUPGM_Request_Staging__c();

            // Identity
            staging.Core_MDF_IUPGM_User__c              = userId_Id;
            staging.Core_MDF_IUPGM_Program__c            = program;
            staging.Core_MDF_Requested_By__c             = UserInfo.getUserId(); // integration/service account
            // Prefer explicit requestorEmail from chatbot payload; fall back to the connected user's email.
            staging.Core_MDF_Requestor_Email__c          = String.isNotBlank(requestorEmail)
                ? requestorEmail : UserInfo.getUserEmail();
            Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
                staging,
                'Core_MDF_AGS_Role_Comments__c',
                agsRoleComments
            );

            // Role fields â€” separate values from MDT
            staging.Core_MDF_IUPGM_Role_nm__c            = permissionSetName;   // key for config cache
            staging.Core_MDF_AGS_Role_Name__c        = agsRoleName;         // sent to AGS

            // Account
            if (allAccountAccess != null) {
                staging.Core_MDF_IUPGM_All_Account_Access__c = allAccountAccess;
            }
            staging.Core_MDF_IUPGM_Account__c            = accountId_Id;

            // Region
            staging.Core_MDF_IUPGM_Region_Sub_Region_nm__c = geo;

            // Budget
            if (allBudgetAccess != null) {
                staging.Core_MDF_IUPGM_All_Budget_Type_Access__c = allBudgetAccess;
            }
            staging.Core_MDF_GeoSubGeo_Budget_Type_nm__c     = geoBudgetType;

            // Special fields
            staging.Core_MDF_Approval_Region_nm__c         = approvalRegion;
            staging.Core_MDF_Activity_Classification_nm__c = activityClass;

            // Status â€” always New on insert
            staging.Core_MDF_Request_Status_nm__c          = 'New';
            if (userNeedsCreation) {
                Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
                    staging,
                    'Core_MDF_New_User_Name__c',
                    newUserFullName
                );
                Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
                    staging,
                    'Core_MDF_New_User_Email__c',
                    newUserEmail
                );
                Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
                    staging,
                    'Core_MDF_New_User_Federation_Id__c',
                    newUserFederationId
                );
            }

            insert staging;

            /*
            ================================================================
            STEP 5 â€” RE-QUERY FOR AUTO-NUMBER NAME
            ================================================================
            */
            staging = [
                SELECT Id, Name, Core_MDF_Request_Status_nm__c
                FROM Core_MDF_IUPGM_Request_Staging__c
                WHERE Id = :staging.Id
                LIMIT 1
            ];

            System.debug('Staging created: ' + staging.Name);

            // Capture staging Id for logging
            logStagingId = staging.Id;

            /*
            ================================================================
            STEP 6 â€” SUCCESS RESPONSE
            ================================================================
            */
            res.statusCode = 200;
            logResponse = JSON.serialize(new Map<String, Object>{
                'success'          => true,
                'requestNumber'    => staging.Name,
                'status'           => staging.Core_MDF_Request_Status_nm__c,
                'notificationInfo' => 'An email notification will be sent to you (the person who submitted this request) once provisioning is complete. The target user will NOT receive the email.',
                'message'          => 'Request submitted successfully (Request No: '
                    + staging.Name + '). '
                    + 'Processing is underway. '
                    + 'You will receive an email notification once the access '
                    + 'provisioning is complete. '
                    + 'You can check status anytime using: '
                    + '?requestNumber=' + staging.Name
            });
            return logResponse;

        } catch (Exception e) {
            System.debug('submitRequest ERROR: ' + e.getMessage()
                + ' line ' + e.getLineNumber());
            res.statusCode = 500;
            logError = e.getMessage();
            String friendlyMsg = Core_MDF_IUPGMReqStaging_ServiceHandler.humanizeError(e.getMessage(), 'the requested user');
            logResponse = JSON.serialize(new Map<String, Object>{
                'success'    => false,
                'message'    => friendlyMsg
            });
            return logResponse;
        } finally {
            Core_MDF_IUPGMReqStaging_ServiceHandler.logChatbotCall(
                '/access/submitRequest',
                logBody,
                logResponse,
                res.statusCode,
                logUserId,
                logProgram,
                logRole,
                logStagingId,
                System.currentTimeMillis() - startMs,
                logError
            );
        }
    }
	/******************************************************************************************************
    Method Name:        handleBulkSubmit
    Description:       
    Added By:           Ramapriya
    *******************************************************************************************************/
   
    /** Handles bulk submission payloads by inserting multiple staging records in one transaction. */
    private static String handleBulkSubmit(
        Map<String, Object> p,
        RestResponse res
    ) {
        List<Object> summariesRaw;
        try {
            summariesRaw = (List<Object>) p.get('requestSummaries');
        } catch (Exception ex) {
            res.statusCode = 400;
            return err('"requestSummaries" must be a JSON array.');
        }
        if (summariesRaw == null || summariesRaw.isEmpty()) {
            res.statusCode = 400;
            return err('"requestSummaries" array is required and cannot be empty.');
        }

        // â”€â”€ Enterprise #1: one batchRequestId groups the whole submission â”€â”€â”€â”€â”€
        // Requires org field Core_MDF_Batch_Request_Id__c (Text 36) on staging.
        String batchRequestId = 'BATCH-'
            + EncodingUtil.convertToHex(
                Crypto.generateAESKey(128)).left(10).toUpperCase();

        // â”€â”€ Build per-entry summary map and collect all user IDs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        List<Map<String, Object>> summaries = new List<Map<String, Object>>();
        Set<Id> allUserIds = new Set<Id>();
        for (Object raw : summariesRaw) {
            Map<String, Object> summary = (Map<String, Object>) raw;
            summaries.add(summary);
            String uid = str(summary, 'userId');
            if (String.isNotBlank(uid)) allUserIds.add((Id) uid);
        }

        // â”€â”€ Bulk duplicate check (ONE SOQL for all users) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        // Key: userId|permissionSetName|program
        Map<String, Core_MDF_IUPGM_Request_Staging__c> inflightByKey =
            new Map<String, Core_MDF_IUPGM_Request_Staging__c>();
        if (!allUserIds.isEmpty()) {
            for (Core_MDF_IUPGM_Request_Staging__c stg : [
                SELECT Id, Name, Core_MDF_IUPGM_User__c,
                       Core_MDF_IUPGM_Role_nm__c, Core_MDF_IUPGM_Program__c,
                       Core_MDF_Request_Status_nm__c
                FROM Core_MDF_IUPGM_Request_Staging__c
                WHERE Core_MDF_IUPGM_User__c IN :allUserIds
                  AND Core_MDF_Is_IUPGM_Processed__c = false
                  AND Core_MDF_Request_Status_nm__c NOT IN
                      :Core_MDF_CCP_ConstantClass.IUPGM_NON_ACTIVE_STATUSES
            ]) {
                String dupKey = String.valueOf(stg.Core_MDF_IUPGM_User__c)
                    + '|' + stg.Core_MDF_IUPGM_Role_nm__c
                    + '|' + stg.Core_MDF_IUPGM_Program__c;
                if (!inflightByKey.containsKey(dupKey)) {
                    inflightByKey.put(dupKey, stg);
                }
            }
        }

        // â”€â”€ Build staging records and per-entry result stubs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        List<Core_MDF_IUPGM_Request_Staging__c> toInsert =
            new List<Core_MDF_IUPGM_Request_Staging__c>();
        List<Integer> insertToResultIndex = new List<Integer>();
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        for (Integer i = 0; i < summaries.size(); i++) {
            Map<String, Object> summary = summaries[i];
            String userId         = str(summary, 'userId');
            String prog           = str(summary, 'program');
            String psName         = str(summary, 'permissionSetName');
            String agsRoleName    = str(summary, 'agsRoleName');
            String userName       = str(summary, 'userName');
            String userEmail      = str(summary, 'userEmail');
            String requestorEmail = str(summary, 'requestorEmail'); // human who raised via chatbot
            String agsRoleComments = approverComments(summary);
            String geoVal         = str(summary, 'geo');
            String acctIdStr      = str(summary, 'accountId');
            String approvalReg    = str(summary, 'approvalRegion');
            String actClass       = str(summary, 'activityClassification');
            String geoBudget      = str(summary, 'geoBudgetType');
            Boolean allAcct       = parseBool(summary.get('allAccountAccess'));
            Boolean allBudget     = parseBoolNullable(summary.get('allBudgetAccess'));
            Boolean userNeedsCreation = parseBool(summary.get('userNeedsCreation'));
            String newUserFullName    = str(summary, 'newUserFullName');
            String newUserFedId       = str(summary, 'newUserFederationId');
            String newUserEmail       = str(summary, 'newUserEmail');
            if (String.isBlank(newUserEmail)) newUserEmail = userEmail;
            if (userNeedsCreation && String.isBlank(newUserFedId)) {
                newUserFedId = deriveFederationFromEmail(newUserEmail);
            }

            Map<String, Object> result = new Map<String, Object>{
                'userEmail' => userEmail,
                'userName'  => userName
            };

            if ((String.isBlank(userId) && !userNeedsCreation)
                || String.isBlank(prog) || String.isBlank(psName)) {
                result.put('success', false);
                result.put('error', 'Incomplete requestSummary at index ' + i
                    + '. Call /validateRequest first.');
                results.add(result);
                continue;
            }
            String accountValidationError = validateAccountRequirementForSummary(summary);
            if (String.isNotBlank(accountValidationError)) {
                result.put('success', false);
                result.put('error', accountValidationError);
                results.add(result);
                continue;
            }

            Id userId_Id  = String.isNotBlank(userId) ? (Id) userId : null;
            Id acctId_Id  = String.isNotBlank(acctIdStr) ? (Id) acctIdStr : null;

            if (userId_Id != null) {
                String dupKey = String.valueOf(userId_Id) + '|' + psName + '|' + prog;
                if (inflightByKey.containsKey(dupKey)) {
                    Core_MDF_IUPGM_Request_Staging__c dup = inflightByKey.get(dupKey);
                    result.put('success',       false);
                    result.put('duplicate',     true);
                    result.put('requestNumber', dup.Name);
                    result.put('status',        dup.Core_MDF_Request_Status_nm__c);
                    result.put('message',
                        (String.isNotBlank(userName) ? userName : 'This user')
                        + ' already has an active request (' + dup.Name + ').');
                    results.add(result);
                    continue;
                }
            }

            // â”€â”€ Enterprise #2: idempotency key â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            String idempotencyKey = Core_MDF_CCP_ConstantClass.buildIupgmIdempotencyKey(
                userId_Id, prog, psName, geoVal, acctId_Id, allAcct,
                approvalReg, actClass
            );

            Core_MDF_IUPGM_Request_Staging__c staging =
                new Core_MDF_IUPGM_Request_Staging__c();
            staging.Core_MDF_IUPGM_User__c                   = userId_Id;
            staging.Core_MDF_IUPGM_Program__c                = prog;
            staging.Core_MDF_Requested_By__c                 = UserInfo.getUserId();
            staging.Core_MDF_Requestor_Email__c              = String.isNotBlank(requestorEmail)
                ? requestorEmail : UserInfo.getUserEmail();
            Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
                staging,
                'Core_MDF_AGS_Role_Comments__c',
                agsRoleComments
            );
            staging.Core_MDF_IUPGM_Role_nm__c                = psName;
            staging.Core_MDF_AGS_Role_Name__c                = agsRoleName;
            if (allAcct != null) {
                staging.Core_MDF_IUPGM_All_Account_Access__c = allAcct;
            }
            staging.Core_MDF_IUPGM_Account__c                = acctId_Id;
            staging.Core_MDF_IUPGM_Region_Sub_Region_nm__c   = geoVal;
            if (allBudget != null) {
                staging.Core_MDF_IUPGM_All_Budget_Type_Access__c = allBudget;
            }
            staging.Core_MDF_GeoSubGeo_Budget_Type_nm__c     = geoBudget;
            staging.Core_MDF_Approval_Region_nm__c           = approvalReg;
            staging.Core_MDF_Activity_Classification_nm__c   = actClass;
            staging.Core_MDF_Request_Status_nm__c            =
                Core_MDF_CCP_ConstantClass.IUPGM_STATUS_NEW;
            if (userNeedsCreation) {
                Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
                    staging,
                    'Core_MDF_New_User_Name__c',
                    newUserFullName
                );
                Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
                    staging,
                    'Core_MDF_New_User_Email__c',
                    newUserEmail
                );
                Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
                    staging,
                    'Core_MDF_New_User_Federation_Id__c',
                    newUserFedId
                );
            }
            // TODO: Enterprise fields (add these fields to staging object when needed)
            // staging.Core_MDF_Batch_Request_Id__c             = batchRequestId;
            // staging.Core_MDF_Idempotency_Key__c              = idempotencyKey;

            toInsert.add(staging);
            insertToResultIndex.add(i);

            result.put('success', true);
            result.put('queued',  true);
            results.add(result);
        }

        // â”€â”€ Bulk insert (partial success allowed) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        List<Database.SaveResult> saveResults =
            Database.insert(toInsert, false);

        // Re-query to get auto-number names
        Set<Id> insertedIds = new Set<Id>();
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (saveResults[i].isSuccess()) {
                insertedIds.add(saveResults[i].getId());
            } else {
                Integer ri = insertToResultIndex[i];
                results[ri].put('success', false);
                results[ri].put('queued',  null);
                results[ri].put('error',
                    saveResults[i].getErrors()[0].getMessage());
            }
        }
        Map<Id, String> stagingNames = new Map<Id, String>();
        if (!insertedIds.isEmpty()) {
            for (Core_MDF_IUPGM_Request_Staging__c s : [
                SELECT Id, Name
                FROM Core_MDF_IUPGM_Request_Staging__c
                WHERE Id IN :insertedIds
            ]) {
                stagingNames.put(s.Id, s.Name);
            }
        }
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (saveResults[i].isSuccess()) {
                Id   recId = saveResults[i].getId();
                Integer ri = insertToResultIndex[i];
                results[ri].put('requestNumber', stagingNames.get(recId));
                results[ri].put('status',        Core_MDF_CCP_ConstantClass.IUPGM_STATUS_NEW);
            }
        }

        // â”€â”€ Tally counts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Integer submitted = 0, dupes = 0, failed = 0;
        for (Map<String, Object> r : results) {
            if (r.get('success') == true && r.get('queued') == true) submitted++;
            else if (r.get('duplicate') == true) dupes++;
            else failed++;
        }

        res.statusCode = 200;
        return JSON.serialize(new Map<String, Object>{
            'success'        => true,
            'bulkMode'       => true,
            'batchRequestId' => batchRequestId,
            'totalUsers'     => summaries.size(),
            'submitted'      => submitted,
            'duplicates'     => dupes,
            'failed'         => failed,
            'results'        => results,
            'message'        => submitted + ' request(s) submitted. '
                + (dupes   > 0 ? dupes   + ' duplicate(s) skipped. ' : '')
                + (failed  > 0 ? failed  + ' failed. ' : '')
                + (submitted > 0
                    ? 'You will receive email notifications once provisioning completes.'
                    : '')
        });
    }

   /******************************************************************************************************
    Method Name:        str
    Description:       
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Safely reads a trimmed string value from the supplied payload map. */
    private static String str(Map<String, Object> m, String key) {
        Object val = m.get(key);
        return val != null ? String.valueOf(val).trim() : null;
    }
/******************************************************************************************************
    Method Name:        parseBool
    Description:       
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Converts flexible truthy payload values into a Boolean flag. */
    private static Boolean parseBool(Object val) {
        if (val == null) return false;
        if (val instanceof Boolean) return (Boolean) val;
        String s = String.valueOf(val).trim().toLowerCase();
        return (s == 'true' || s == 'yes' || s == '1');
    }
    /******************************************************************************************************
    Method Name:        parseBoolNullable
    Description:       // Returns null if not present (for budget checkbox which can be N/A)
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Converts a payload value into a nullable Boolean, preserving missing values. */
    private static Boolean parseBoolNullable(Object val) {
        if (val == null) return null;
        if (val instanceof Boolean) return (Boolean) val;
        String s = String.valueOf(val).trim().toLowerCase();
        if (s == 'null' || s == '') return null;
        return (s == 'true' || s == 'yes' || s == '1');
    }

    /** Reads optional chatbot approver comments using supported payload aliases. */
    private static String approverComments(Map<String, Object> payload) {
        if (payload == null) return null;
        String comments = str(payload, 'agsRoleComments');
        if (String.isBlank(comments)) comments = str(payload, 'approverComments');
        if (String.isBlank(comments)) comments = str(payload, 'Approver comments');
        return comments;
    }
	/******************************************************************************************************
    Method Name:        deriveFederationFromEmail
    Description:       
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Derives a federation identifier from the local part of an email address. */
    private static String deriveFederationFromEmail(String email) {
        if (String.isBlank(email) || !email.contains('@')) return null;
        String fed = email.substringBefore('@');
        return String.isNotBlank(fed) ? fed.trim() : null;
    }
/******************************************************************************************************
    Method Name:        err
    Description:       
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Serializes a standard error response payload for the REST endpoint. */
    private static String err(String message) {
        return JSON.serialize(new Map<String, Object>{
            'success' => false,
            'message' => message
        });
    }

    /** Revalidates account requirements for confirmed summaries before staging insert. */
    private static String validateAccountRequirementForSummary(
        Map<String, Object> summary
    ) {
        String program = str(summary, 'program');
        String psName  = str(summary, 'permissionSetName');
        if (String.isBlank(program) || String.isBlank(psName)) {
            return null;
        }
        Set<String> programCandidates = getProgramCandidates(program);

        List<Core_MDF_IUPGM_Rule_Config__mdt> cfgRows = [
            SELECT Core_MDF_Role_Label__c,
                   Core_MDF_Program__c,
                   Core_MDF_All_Accounts__c,
                   Core_MDF_Account_Required__c
            FROM Core_MDF_IUPGM_Rule_Config__mdt
            WHERE Core_MDF_Program__c IN :programCandidates
              AND Core_MDF_Permission_Set_Name__c = :psName
              AND Core_MDF_Is_Active__c = true
        ];
        if (cfgRows.isEmpty()) {
            return null;
        }

        Core_MDF_IUPGM_Rule_Config__mdt cfg = pickPreferredConfig(cfgRows, program);
        if (!cfg.Core_MDF_Account_Required__c) {
            return null;
        }

        String allAccOpt = cfg.Core_MDF_All_Accounts__c;
        Boolean hasAllAccountAccess = summary.containsKey('allAccountAccess')
            && summary.get('allAccountAccess') != null;
        Boolean allAccountAccess = hasAllAccountAccess
            ? parseBool(summary.get('allAccountAccess')) : null;

        if (allAccOpt == 'YES_NO' && allAccountAccess == null) {
            return 'Invalid requestSummary â€” missing allAccountAccess for role ['
                + cfg.Core_MDF_Role_Label__c + ']. Please re-run validateRequest.';
        }

        Boolean accountWillBeNeeded =
            (allAccOpt == 'NO_ONLY')
            || (allAccOpt == 'YES_NO' && allAccountAccess == false);
        if (accountWillBeNeeded && String.isBlank(str(summary, 'accountId'))) {
            return 'Invalid requestSummary â€” accountId is required for role ['
                + cfg.Core_MDF_Role_Label__c + ']. Please provide accountName and re-validate.';
        }
        return null;
    }

    /** Returns candidate programs for lookup: exact program + COMMON fallback. */
    private static Set<String> getProgramCandidates(String program) {
        Set<String> candidates = new Set<String>();
        if (String.isNotBlank(program)) {
            candidates.add(program.trim());
        }
        candidates.add(COMMON_PROGRAM);
        return candidates;
    }

    /** Picks exact-program config first, otherwise returns first available row. */
    private static Core_MDF_IUPGM_Rule_Config__mdt pickPreferredConfig(
        List<Core_MDF_IUPGM_Rule_Config__mdt> rows,
        String requestedProgram
    ) {
        if (rows == null || rows.isEmpty()) return null;
        if (String.isBlank(requestedProgram)) return rows[0];
        for (Core_MDF_IUPGM_Rule_Config__mdt row : rows) {
            if (String.isNotBlank(row.Core_MDF_Program__c)
                && row.Core_MDF_Program__c.trim().equalsIgnoreCase(requestedProgram)) {
                return row;
            }
        }
        return rows[0];
    }
	/******************************************************************************************************
    Method Name:        resolveOption
    Description:       
    Added By:           Ramapriya
    *******************************************************************************************************/
   
    /** Resolves a chatbot option by number, exact text, or partial text match. */
    private static String resolveOption(
        String userInput,
        List<String> validOptions
    ) {
        if (String.isBlank(userInput) || validOptions == null || validOptions.isEmpty()) {
            throw new IllegalArgumentException('Invalid input or options list.');
        }

        userInput = userInput.trim();

        // Try numeric resolution first (1-based indexing)
        if (userInput.isNumeric()) {
            try {
                Integer idx = Integer.valueOf(userInput) - 1;
                if (idx >= 0 && idx < validOptions.size()) {
                    return validOptions[idx];
                }
            } catch (Exception e) {
                // Fall through to text matching
            }
        }

        // Try exact match (case-insensitive)
        String inputLower = userInput.toLowerCase();
        for (String opt : validOptions) {
            if (opt.toLowerCase() == inputLower) {
                return opt;
            }
        }

        // Try partial match if no exact match found
        for (String opt : validOptions) {
            if (opt.toLowerCase().contains(inputLower)
                || inputLower.contains(opt.toLowerCase())) {
                return opt;
            }
        }

        // No match found
        throw new IllegalArgumentException(
            'Invalid selection [' + userInput + ']. '
            + 'Valid options: ' + String.join(validOptions, ', ')
        );
    }
}