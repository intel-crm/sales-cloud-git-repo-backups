/*****************************************************************************************************
Class Name          :    Core_MDF_IUPGM_RequestAPI
Test Class Name     :    Core_MDF_IUPGM_RequestAPI_Test
Description         :    REST endpoint that validates chatbot requests, resolves user-facing options, and builds therequestSummary payload that later becomes an IUPGM staging record.
Created By          :    Ramapriya  
******************************************************************************************************/
@RestResource(urlMapping='/access/validateRequest')
global without sharing class Core_MDF_IUPGM_RequestAPI {
    private static final String COMMON_PROGRAM = 'COMMON';
    /** Captures the raw request body for audit logging in the finally block. */
    private static String capturedRequestBody;

    /** Validates the incoming chatbot payload and returns a fully resolved request summary. */
    @HttpPost
    global static String validateRequest() {

        RestRequest  req = RestContext.request;
        RestResponse res = RestContext.response;

        Long   startMs      = System.currentTimeMillis();
        String logBody      = null;
        String logError     = null;
        String responseJson = null;

        try {
            responseJson = doValidateRequest(req, res);
            logBody = capturedRequestBody;
            return responseJson;
        } catch (Exception e) {
            
            res.statusCode = 500;
            logBody  = capturedRequestBody;
            logError = e.getMessage();
            String friendlyMsg = Core_MDF_IUPGMReqStaging_ServiceHandler.humanizeError(e.getMessage(), 'the requested user');
            responseJson = JSON.serialize(new Map<String, Object>{
                'success'    => false,
                'message'    => friendlyMsg
            });
            return responseJson;
        } finally {
            Core_MDF_IUPGMReqStaging_ServiceHandler.logChatbotCall(
                '/access/validateRequest',
                logBody,
                responseJson,
                res.statusCode,
                null,   // userId not resolved at validate time
                null,   // program captured in request body
                null,   // role captured in request body
                null,   // no staging record for validate
                System.currentTimeMillis() - startMs,
                logError
            );
        }
    }

    /** Performs the main validation flow for a single request payload. */
    @testVisible
    private static String doValidateRequest(RestRequest req, RestResponse res) {

            /*
            ================================================================
            STEP 1 - PARSE PAYLOAD
            Chatbot sends only human-friendly values.
            ================================================================
            */
            String body = req.requestBody != null ? req.requestBody.toString() : null;
            capturedRequestBody = body;
            
            if (String.isBlank(body)) {
                res.statusCode = 400;
                return err('Request body is empty.');
            }

            Map<String, Object> p =
                (Map<String, Object>) JSON.deserializeUntyped(body);
            String rawUserQuery = str(p, 'userQuery');
            if (String.isBlank(rawUserQuery)) {
                rawUserQuery = str(p, 'query');
            }
            Boolean inferredConfirmedFromQuery =
                isAffirmativeConfirmation(rawUserQuery);

            //  Bulk mode detection 
            // If the payload contains a "users" array the chatbot is requesting
            // bulk validation.  Route to the dedicated handler which resolves
            // all users and duplicate checks in two SOQLs (not N).
            if (p.containsKey('users')) {
                return handleBulkValidate(p, res);
            }

            // â”€â”€ Confirmed submit shortcut â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // Chatbot sends back: { "requestSummary": { ...from Call 1... }, "userConfirmed": true }
            // No need to re-send the original raw payload - the requestSummary already
            // has all resolved values. Skip validation entirely and create staging.
            if (p.containsKey('requestSummary')
                && (parseBool(p.get('userConfirmed')) || inferredConfirmedFromQuery)) {
                Map<String, Object> confirmedSummary =
                    (Map<String, Object>) p.get('requestSummary');
                String cUserId = str(confirmedSummary, 'userId');
                String cProg   = str(confirmedSummary, 'program');
                String cPs     = str(confirmedSummary, 'permissionSetName');
                Boolean cUserNeedsCreation = parseBool(confirmedSummary.get('userNeedsCreation'));
                if ((String.isBlank(cUserId) && !cUserNeedsCreation)
                    || String.isBlank(cProg) || String.isBlank(cPs)) {
                    res.statusCode = 400;
                    return err('Invalid requestSummary - missing userId, program, or permissionSetName. '
                        + 'Please ensure you are sending the requestSummary returned by the previous validateRequest call.');
                }
                // A brand-new user (no Salesforce record yet) must carry a Federation ID
                // (Worldwide ID) - it cannot be looked up from the org and is required
                // verbatim in the AGS user-creation payload. Never guess it here.
                if (cUserNeedsCreation
                    && String.isBlank(str(confirmedSummary, 'newUserFederationId'))) {
                    res.statusCode = 400;
                    return err('Invalid requestSummary - missing newUserFederationId. '
                        + 'A Federation ID (Worldwide ID) is required to create a new user via AGS.');
                }
                
                String cRequestAction = str(confirmedSummary, 'requestAction');
                Boolean cIsRevoke = String.isNotBlank(cRequestAction)
                    && cRequestAction.trim().toUpperCase() == 'REVOKE';
                // Account requirements apply only to grants. REVOKE operates on every
                // matching IUPGM scope and intentionally carries no grant fields.
                if (!cUserNeedsCreation && !cIsRevoke) {
                    String accountValidationError =
                        validateAccountRequirementForSummary(confirmedSummary);
                    if (String.isNotBlank(accountValidationError)) {
                        res.statusCode = 400;
                        return err(accountValidationError);
                    }
                }
                // Safety duplicate check before inserting
                // Request-type aware: an in-flight GRANT must never block a REVOKE
                // (and vice versa) for the same role/program - they are opposite
                // operations. Legacy records (Request_Type_nm__c = null, created
                // before this field existed) are treated as GRANT.
                if (String.isNotBlank(cUserId)) {
                    Id cUserIdId = (Id) cUserId;
                    List<Core_MDF_IUPGM_Request_Staging__c> cInflight = cIsRevoke
                        ? [
                            SELECT Id, Name, Core_MDF_Request_Status_nm__c
                            FROM Core_MDF_IUPGM_Request_Staging__c
                            WHERE Core_MDF_IUPGM_User__c    = :cUserIdId AND Core_MDF_IUPGM_Role_nm__c = :cPs AND Core_MDF_IUPGM_Program__c  = :cProg
                              AND Core_MDF_Is_IUPGM_Processed__c = false
                              AND Core_MDF_Request_Type_nm__c = 'REVOKE'
                              AND Core_MDF_Request_Status_nm__c NOT IN (
                                  'Error', 'Validation_Failed', 'External_User_Blocked', 'AGS_Rejected'
                              )
                            LIMIT 1
                        ]
                        : [
                            SELECT Id, Name, Core_MDF_Request_Status_nm__c
                            FROM Core_MDF_IUPGM_Request_Staging__c
                            WHERE Core_MDF_IUPGM_User__c    = :cUserIdId
                              AND Core_MDF_IUPGM_Role_nm__c = :cPs
                              AND Core_MDF_IUPGM_Program__c  = :cProg
                              AND Core_MDF_Is_IUPGM_Processed__c = false
                              AND (Core_MDF_Request_Type_nm__c = 'GRANT' OR Core_MDF_Request_Type_nm__c = null)
                              AND Core_MDF_Request_Status_nm__c NOT IN (
                                  'Error', 'Validation_Failed', 'External_User_Blocked', 'AGS_Rejected'
                              )
                            LIMIT 1
                        ];
                    if (!cInflight.isEmpty()) {
                        String cStatus = cInflight[0].Core_MDF_Request_Status_nm__c
                            .replace('_', ' ').toLowerCase();
                        res.statusCode = 409;
                        return JSON.serialize(new Map<String, Object>{
                            'success'       => false,
                            'duplicate'     => true,
                            'requestNumber' => cInflight[0].Name,
                            'status'        => cInflight[0].Core_MDF_Request_Status_nm__c,
                            'message'       => str(confirmedSummary, 'userName')
                                + ' already has an active request for this role '
                                + '(currently ' + cStatus + '). Request: ' + cInflight[0].Name
                        });
                    }
                }
                Core_MDF_IUPGM_Request_Staging__c cStaging =
                    createStagingFromSummary(confirmedSummary);
                insert cStaging;
                cStaging = [
                    SELECT Id, Name, Core_MDF_Request_Status_nm__c
                    FROM Core_MDF_IUPGM_Request_Staging__c
                    WHERE Id = :cStaging.Id LIMIT 1
                ];
                res.statusCode = 200;
                return JSON.serialize(new Map<String, Object>{
                    'success'       => true,
                    'autoSubmitted' => true,
                    'requestNumber' => cStaging.Name,
                    'status'        => cStaging.Core_MDF_Request_Status_nm__c,
                    'message'       => 'Request submitted successfully. '
                        + 'Request No: ' + cStaging.Name + '. '
                        + str(confirmedSummary, 'userName')
                        + ' will receive an email once provisioning is complete.'
                });
            }

            // â”€â”€ Bulk confirmed submit shortcut â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // Chatbot sends: { "requestSummaries": [...from bulk Call 1 results...], "userConfirmed": true }
            if (p.containsKey('requestSummaries')
                && (parseBool(p.get('userConfirmed')) || inferredConfirmedFromQuery)) {
                return handleBulkConfirmedSubmit(p, res);
            }

            String userInput      = str(p, 'userInput');
            String programInput   = str(p, 'program');
            String roleInput      = str(p, 'roleLabel');
            String requestorEmail = str(p, 'requestorEmail');
            String agsRoleComments = approverComments(p);
            String newUserFullName = str(p, 'newUserFullName');
            String newUserFederationId = str(p, 'newUserFederationId');
            Boolean userConfirmed = parseBool(p.get('userConfirmed'));
            
            // DEBUG: Log all incoming parameters for troubleshooting chatbot parsing issues
            System.debug('=== IUPGM VALIDATE REQUEST - PARAMETERS ===');
            System.debug('userInput: ' + userInput);
            System.debug('programInput: ' + programInput);
            System.debug('roleInput: ' + roleInput);
            System.debug('requestorEmail: ' + requestorEmail);
            System.debug('accountName: ' + str(p, 'accountName'));
            System.debug('geo: ' + str(p, 'geo'));
            System.debug('allAccountAccess: ' + str(p, 'allAccountAccess'));
            System.debug('allBudgetAccess: ' + str(p, 'allBudgetAccess'));
            System.debug('userConfirmed: ' + userConfirmed);
            System.debug('Full payload (first 2000 chars): ' + JSON.serializePretty(p).abbreviate(2000));
            System.debug('=== END PARAMETERS ===');
            
            // Explicit, structured request-intent field (mirrors how roleLabel/program
            // are already sent explicitly) - defaults to GRANT so every existing
            // caller that never sends this field is completely unaffected.
            String requestAction = str(p, 'requestAction');
            String requestActionNorm = String.isNotBlank(requestAction)
                ? requestAction.trim().toUpperCase() : null;
            
            // If no explicit requestAction, infer from natural language keywords in userQuery
            if (String.isBlank(requestActionNorm)) {
                String queryLowercase = String.isNotBlank(rawUserQuery) ? rawUserQuery.toLowerCase() : '';
                // Match patterns: "remove access", "removal", "revoke", "deactivate", "deny access"
                // Simplified: explicitly check for key revoke-related keywords (case-insensitive)
                String lowerQuery = queryLowercase;
                if (lowerQuery.contains('deactivate') 
                    || lowerQuery.contains('remove access') 
                    || lowerQuery.contains('revoke') 
                    || lowerQuery.contains('removal')
                    || lowerQuery.contains('deny access')
                    || lowerQuery.contains('remove the')) {
                    requestActionNorm = 'REVOKE';
                }
            }
            
            Boolean isRevokeRequest = requestActionNorm == 'REMOVE' || requestActionNorm == 'REVOKE';
            
            // REVOKE CONTEXT PRESERVATION: If this is a confirmation request (userConfirmed=true or affirmative response)
            // and we detected "deactivate" anywhere in the query, treat it as REVOKE confirmation.
            // This handles the case where chatbot sends confirmation without explicit requestAction.
            if (!isRevokeRequest && (userConfirmed || inferredConfirmedFromQuery)) {
                String queryLowercase = String.isNotBlank(rawUserQuery) ? rawUserQuery.toLowerCase() : '';
                if (queryLowercase.contains('deactivate') || queryLowercase.contains('remove access') 
                    || queryLowercase.contains('revoke') || queryLowercase.contains('removal')) {
                    isRevokeRequest = true;
                    requestActionNorm = 'REVOKE';
                }
                // Also check if requestSummary contains requestAction=REVOKE (for confirmation flows
                // where chatbot resends the requestSummary object from prior step)
                if (!isRevokeRequest) {
                    try {
                        Object summaryObj = p.get('requestSummary');
                        if (summaryObj != null) {
                            Map<String, Object> summaryMap = (Map<String, Object>) summaryObj;
                            String summaryAction = str(summaryMap, 'requestAction');
                            if (String.isNotBlank(summaryAction) && summaryAction.trim().toUpperCase() == 'REVOKE') {
                                isRevokeRequest = true;
                                requestActionNorm = 'REVOKE';
                            }
                        }
                    } catch (Exception e) {
                        // Ignore - requestSummary might not be a Map or might not have requestAction
                    }
                }
            }
            List<String> validationErrors = new List<String>();
            // Set true below (Step "user not found") once we have a full name AND
            // federation id for a brand-new user. Used later, at role resolution,
            // to bypass the MDT lookup entirely for the bootstrap Core Access role -
            // see "NEW USER CORE ACCESS BOOTSTRAP" further down.
            Boolean isNewUserFlow = false;

            /*
            ================================================================
            MULTI-VALUE GUARD - USER / ROLE
            ----------------------------------------------------------------
            The chatbot does not support bulk requests yet. If the caller
            packs several users or several roles into one field we process
            the FIRST one and tell the user to raise the rest separately -
            the same behaviour already applied to multiple programs.
            ================================================================
            */
            List<String> deferredUsers = new List<String>();
            List<String> deferredRoles = new List<String>();
            String multiUserNotice = null;
            String multiRoleNotice = null;

            if (String.isNotBlank(userInput)) {
                List<String> allUsers = splitMultiValue(userInput);
                if (allUsers.size() > 1) {
                    userInput = allUsers[0];
                    for (Integer i = 1; i < allUsers.size(); i++) {
                        deferredUsers.add(allUsers[i]);
                    }
                    multiUserNotice =
                        'Multiple users were detected in this request ('
                        + String.join(allUsers, ', ') + '). '
                        + 'Only one user can be processed at a time. '
                        + 'I will continue with [' + userInput + '] now - '
                        + 'please raise a separate request for ['
                        + String.join(deferredUsers, ', ') + '].';
                }
            }

            if (String.isNotBlank(roleInput)) {
                List<String> allRoles = splitRoleInput(roleInput);
                if (allRoles.size() > 1) {
                    roleInput = allRoles[0];
                    for (Integer i = 1; i < allRoles.size(); i++) {
                        deferredRoles.add(allRoles[i]);
                    }
                    multiRoleNotice =
                        'Multiple roles were detected in this request ('
                        + String.join(allRoles, ', ') + '). '
                        + 'Only one role can be processed at a time. '
                        + 'I will continue with [' + roleInput + '] now - '
                        + 'please raise a separate request for ['
                        + String.join(deferredRoles, ', ') + '].';
                }
            }

            /*
            ================================================================
            REVOKE GUARD - CORE ACCESS BOOTSTRAP ROLE
            ----------------------------------------------------------------
            "Sales CRM (Salesforce)--Core Access" (Core_MDF_CCP_ConstantClass.
            IUPGM_CORE_ACCESS_ROLE_LABEL) has no Core_MDF_IUPGM_Rule_Config__mdt
            record - it only ever exists as an in-memory bootstrap config used
            to provision a brand-new Salesforce user. It can never have IUPGM
            records and can never be deactivated. Reject explicitly here with a
            clear, specific message instead of letting it fall through to a
            confusing generic ROLE_NOT_FOUND error later.
            ================================================================
            */
            if (isRevokeRequest && String.isNotBlank(roleInput)
                && roleInput.trim().equalsIgnoreCase(
                    Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL)) {
                res.statusCode = 400;
                return JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => 'Deactivation of '
                        + Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL
                        + ' is not supported. This is an AGS-only bootstrap role with '
                        + 'no IUPGM records to deactivate. Please reach out to the '
                        + 'administration team for further assistance.'
                });
            }

            // â”€â”€ Natural language query parsing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // Accept "query" as a fallback for "userQuery" for chatbot compatibility.
            // Skip userQuery role parsing when roleOptions is present - the user
            // is responding to a role selection prompt (e.g. typing "2"), not
            // describing a new request. Parsing "2" as a role label would break
            // the selection flow.
            String userQuery = str(p, 'userQuery');
            if (String.isBlank(userQuery)) {
                userQuery = str(p, 'query'); // chatbot fallback field name
            }
            // NOTE: isAffirmativeConfirmation is intentionally NOT applied here.
            // We only elevate userConfirmed AFTER all fields are collected and validated
            // (see Step 10 below), to prevent "yes" / "confirm" words in budget/region
            // answers from triggering auto-submit mid-collection.
            List<Object> roleOptionsRaw = (List<Object>) p.get('roleOptions');
            Boolean isRoleSelection = (roleOptionsRaw != null && !roleOptionsRaw.isEmpty());

            if (String.isNotBlank(userQuery)) {
                Map<String, String> extractedIdentity = extractNewUserIdentity(userQuery);
                if (String.isBlank(newUserFullName)
                    && extractedIdentity.get('fullName') != null) {
                    newUserFullName = extractedIdentity.get('fullName');
                }
                if (String.isBlank(newUserFederationId)
                    && extractedIdentity.get('federationId') != null) {
                    newUserFederationId = extractedIdentity.get('federationId');
                }
                // Strip userInput from userQuery before parsing - names and emails
                // in the sentence are not role/program hints, they are the target user.
                // e.g. "access for Rishabh Srivastava for transferring budget"
                //   â†’ "access for  for transferring budget" â†’ role hint = "transferring budget"
                String queryForParsing = String.isNotBlank(userInput)
                    ? userQuery.replaceAll('(?i)' + userInput.trim().replaceAll('\\.', '\\\\.'), ' ')
                    : userQuery;
                Map<String, String> parsed = parseUserQuery(queryForParsing);
                if (String.isBlank(programInput) && parsed.get('program') != null) {
                    programInput = parsed.get('program');
                }
                // NOTE: role label is deliberately NOT guessed from free-text userQuery here.
                // Understanding/resolving a role from natural language, keywords, aliases,
                // or use-case descriptions is owned exclusively by the AI Role Recommendation
                // Agent (GET /access/recommendRole). validateAccessRequest only accepts an
                // already-resolved, exact roleLabel (or a numbered reply to a prior
                // roleOptions prompt - see "Role selection" below).
                // Apply structured query values.
                // If query explicitly includes Region/Budget fields, prefer those
                // over stale carried payload values from prior turns.
                String parsedGeo = parsed.get('geo');
                if (String.isNotBlank(parsedGeo)) {
                    parsedGeo = normalizeGeoString(parsedGeo); // ensure semicolon-separated uppercase
                    String existingGeo = str(p, 'geo');
                    Boolean geoExplicitInQuery = parsed.get('geoExplicit') == 'true';
                    if (geoExplicitInQuery) {
                        if (String.isNotBlank(existingGeo)
                            && !existingGeo.trim().equalsIgnoreCase(parsedGeo.trim())) {
                            // Region changed in the query, so any carried region->budget
                            // selections from previous turn are stale.
                            p.remove('geoBudgetSelections');
                            p.remove('geoBudgetType');
                        }
                        p.put('geo', parsedGeo);
                    } else if (String.isBlank(existingGeo)) { p.put('geo', parsedGeo);
                    }
                }
                if (parsed.get('allAccountAccess') != null
                    && (p.get('allAccountAccess') == null
                        || parsed.get('allAccountExplicit') == 'true')) {
                    p.put('allAccountAccess', Boolean.valueOf(parsed.get('allAccountAccess')));
                }
                // Override allBudgetAccess from userQuery when the user explicitly says
                // "all budget access" - the chatbot may carry a stale allBudgetAccess: false
                // from a prior-turn requestSummary even after the user answers "all".
                if ('true'.equalsIgnoreCase(parsed.get('allBudgetAccess'))
                    && parsed.get('allBudgetExplicit') == 'true') {
                    p.put('allBudgetAccess', true);
                }
                // Use account extracted from userQuery ONLY when chatbot has not
                // already provided accountName as a structured parameter.
                // Never let a parsed value overwrite an explicit structured param -
                // the regex can over-capture (e.g. "Marvel Account and Regions: APJ")
                // when the userQuery confirmation sentence runs fields together.
                if (String.isBlank(str(p, 'accountName'))
                    && String.isNotBlank(parsed.get('accountName'))) {
                    p.put('accountName', parsed.get('accountName'));
                }
                // Build geoBudgetSelections from extracted "Budget Type: X" + geo.
                // Supports multiple budget types: "Account Plan and Proposal I MDF" â†’ cross-product with all regions.
                Boolean budgetExplicitInQuery = parsed.get('budgetTypeExplicit') == 'true';
                if (parsed.get('budgetType') != null
                    && (budgetExplicitInQuery
                        || (p.get('geoBudgetSelections') == null && String.isBlank(str(p, 'geoBudgetType'))))) {
                    String geoForBudget = str(p, 'geo');
                    if (String.isBlank(geoForBudget)) geoForBudget = parsed.get('geo');
                    if (String.isNotBlank(geoForBudget)) {
                        // Expand: each region gets ALL budget types provided (cross-product)
                        String rawBudget = (String) parsed.get('budgetType');
                        String cleanedBudget = rawBudget
                            .replaceAll('(?i)\\s+and\\s+', ';')
                            .replaceAll(',', ';');
                        List<String> budgetTypes = cleanedBudget.split(';');
                        Map<String, Object> budgetMap = new Map<String, Object>();
                        for (String g : geoForBudget.split(';')) {
                            // Store as semicolon-joined so resolution can expand to cross-product
                            budgetMap.put(normalizeRegionKey(g), cleanedBudget.trim());
                        }
                        p.put('geoBudgetSelections', budgetMap);
                    }
                }
                // Also extract userInput from sentence if not provided explicitly
                // Pattern: email addresses already in the query
                if (String.isBlank(userInput)) {
                    Matcher emailMatcher = Pattern.compile(
                        '[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}').matcher(userQuery);
                    if (emailMatcher.find()) {
                        userInput = emailMatcher.group(0);
                        p.put('userInput', userInput);
                    }
                }
            }

            // â”€â”€ Role selection from previous multiple-roles response â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (isRoleSelection && String.isNotBlank(roleInput)) {
                List<String> roleOptions = new List<String>();
                for (Object o : roleOptionsRaw) roleOptions.add(String.valueOf(o));
                try {
                    roleInput = resolveOption(roleInput, roleOptions);
                } catch (IllegalArgumentException ex) {
                    res.statusCode = 400;
                    return JSON.serialize(new Map<String, Object>{
                        'success'       => false,
                        'needsInput'    => true,
                        'multipleRoles' => true,
                        'message'       => ex.getMessage(),
                        'roles'         => roleOptions
                    });
                }
            }

            /*
            ================================================================
            STEP 2 - BASE REQUIRED FIELDS
            ================================================================
            userInput  - who is getting access (always required, separate from query)
            userQuery  - chatbot passes raw user sentence; program + role extracted from it
            program    - explicit override (optional if derivable from userQuery or role)
            roleLabel  - explicit override (optional if derivable from userQuery or program)

            Chatbot should ALWAYS send userQuery with the full user utterance.
            Explicit program / roleLabel are optional overrides or for role selection replies.
            ================================================================
            */
            if (String.isBlank(userInput)) {
                validationErrors.add('Who needs access? Please provide their Intel email address or full name.');
            }
            // After userQuery parsing, if we still have neither program nor role,
            // the user expressed access intent but didn't specify what -
            // ask for more details rather than throwing an error.
            if (String.isBlank(roleInput) && String.isBlank(programInput) && String.isBlank(userQuery)) {
                res.statusCode = 206;
                return JSON.serialize(new Map<String, Object>{
                    'success'    => false,
                    'needsInput' => true,
                    'message'    => 'Which program and role are you requesting access for?',
                    'missingFields' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'field'   => 'program',
                            'label'   => 'Program',
                            'type'    => 'picklist',
                            'prompt'  => 'Which program are you requesting access for?',
                            'options' => new List<String>{ 'IPA', 'Client', 'Datacenter', 'RMF', 'Co-GTM' }
                        },
                        new Map<String, Object>{
                            'field'  => 'roleLabel',
                            'label'  => 'Role',
                            'type'   => 'text',
                            'prompt' => 'Which role do you need? (e.g. "Exception Reviewer", "Account Manager")'
                        }
                    }
                });
            }

            /*
            ================================================================
            STEP 3 - RESOLVE PROGRAM (optional)
            If provided: validates alias and filters role search by program.
            If omitted: role search spans all programs; program is derived
            from the matched MDT record after role resolution.

            When a specific role is ALSO named (roleInput not blank), an
            unrecognised "program" value is NOT treated as a hard error.
            Chatbots often mis-extract part of the role name/acronym as the
            program (e.g. "CCF" from "CCF Operations Admin", or "Salesforce"
            from "Sales CRM (Salesforce) - Core Access"). In these cases the
            role can be resolved by name alone across ALL programs, and its
            correct program is then derived from the matched MDT record
            (see "Derive program from MDT record" below) - so we simply
            ignore the bad program text instead of blocking the request.
            An invalid program is only a hard error when no role was named
            either (pure program browse with nothing else to fall back on).
            ================================================================
            */
            String program = null;
            String multiProgramNotice = null;
            List<String> deferredPrograms = new List<String>();
            if (String.isNotBlank(programInput)) {
                program = resolveProgram(programInput);
                if (program == null) {
                    // The caller may have supplied several programs in one string
                    // (e.g. "Client and Datacenter"). Bulk/multi-program requests
                    // are not supported by the chatbot yet, so we process the first
                    // recognised program and ask the user to raise the rest separately.
                    List<String> detected = detectPrograms(programInput);
                    if (!detected.isEmpty()) {
                        program = detected[0];
                        for (Integer i = 1; i < detected.size(); i++) {
                            deferredPrograms.add(detected[i]);
                        }
                        if (!deferredPrograms.isEmpty()) {
                            multiProgramNotice =
                                'Multiple programs were detected in this request ('
                                + String.join(detected, ', ') + '). '
                                + 'Only one program can be processed at a time. '
                                + 'I will continue with [' + program + '] now - '
                                + 'please raise a separate request for ['
                                + String.join(deferredPrograms, ', ') + '].';
                        }
                    }
                }
                if (program == null) {
                    if (String.isNotBlank(roleInput)) {
                        // Ignore the unrecognised program text - role resolution
                        // below will search across all programs by name and
                        // derive the correct program from the matched MDT record.
                        programInput = null;
                    } else {
                        validationErrors.add('Invalid program [' + programInput + ']. '
                            + 'Valid values: IPA, Client, Datacenter, RMF, Co-GTM');
                    }
                }
            }

            /*
            ================================================================
            STEP 4 - RESOLVE USER
            Search by email (exact) or name (partial, up to 5 results).
            ================================================================
            */
            Id     userId    = null;
            String userName  = 'Requested user';
            String userEmail = null;
            List<User> users = new List<User>();

            if (String.isNotBlank(userInput) && userInput.contains('@')) {
                // Email search - no LIMIT 1; if multiple users share an email
                // (sandbox duplicates) we surface them for selection
                users = [
                    SELECT Id, Name, Email
                    FROM User
                    WHERE Email    = :userInput
                      AND IsActive = true
                    LIMIT 5
                ];
            } else if (String.isNotBlank(userInput)) {
                users = [
                    SELECT Id, Name, Email
                    FROM User
                    WHERE Name LIKE :('%' + userInput + '%')
                      AND IsActive = true
                    LIMIT 5
                ];
            }

            if (String.isNotBlank(userInput) && users.size() > 1) {
                List<String> options = new List<String>();
                for (User u : users) options.add(u.Name + ' (' + u.Email + ')');
                res.statusCode = 300;
                return JSON.serialize(new Map<String, Object>{
                    'success'       => false,
                    'needsInput'    => true,
                    'multipleUsers' => true,
                    'message'       => 'Multiple users found. '
                        + 'Please resend with the exact Intel email.',
                    'users'         => options
                });
            }

            if (String.isNotBlank(userInput) && users.isEmpty()) {
                // The chatbot does not reliably send an explicit userConfirmed=true
                // flag for this flow - it often just resends the request with the
                // full name embedded in userQuery. Treat "we now have a full name
                // AND a federation id" (extracted above, from either a structured
                // field or natural language) as sufficient signal to proceed.
                // Both are mandatory: federation id (Worldwide ID) cannot be looked
                // up from the org for a brand-new user, yet it is the exact value
                // sent in the AGS user-creation payload - so it must be explicitly
                // collected from the requester, never guessed from the email.
                Boolean hasFullName     = String.isNotBlank(newUserFullName);
                Boolean hasFederationId = String.isNotBlank(newUserFederationId);
                Boolean readyToCreateNewUser = hasFullName && hasFederationId;
                isNewUserFlow = readyToCreateNewUser;

                if (isNewUserFlow) {
                    // Creating a brand-new Salesforce user is always a GRANT/
                    // bootstrap action, even when the original request intent was
                    // REVOKE - e.g. the requester asked to deactivate access for
                    // someone who doesn't exist yet, then confirmed they want the
                    // user created instead. Force this to GRANT so downstream
                    // REVOKE-only checks (AGS-only role rejection, IUPGM lookup,
                    // "no AGS changes" behavior) do not apply to user creation.
                    isRevokeRequest = false;
                }

                if (userInput.contains('@') && !readyToCreateNewUser && isRevokeRequest) {
                    // REVOKE requested for a user who does not exist in Salesforce -
                    // there is nothing to deactivate. Offer to create the user
                    // instead (via the Core Access bootstrap role) rather than
                    // just failing. If the requester declines, acknowledge and
                    // stop without creating anything or raising any request.
                    if (isNegativeReply(userQuery)) {
                        res.statusCode = 200;
                        return JSON.serialize(new Map<String, Object>{
                            'success' => false,
                            'message' => 'Understood - no changes have been made. '
                                + 'The deactivation request for [' + userInput + '] '
                                + 'was not processed because this user does not '
                                + 'exist in Salesforce.'
                        });
                    }

                    List<Map<String, Object>> revokeNewUserMissingFields =
                        new List<Map<String, Object>>();
                    if (!hasFullName) {
                        revokeNewUserMissingFields.add(new Map<String, Object>{
                            'field'  => 'newUserFullName',
                            'label'  => 'Full Name (First Last)',
                            'type'   => 'text',
                            'prompt' => 'What is the full name (First and Last) for '
                                + userInput + '?'
                        });
                    }
                    if (!hasFederationId) {
                        revokeNewUserMissingFields.add(new Map<String, Object>{
                            'field'  => 'newUserFederationId',
                            'label'  => 'Federation ID (Worldwide ID / WWID)',
                            'type'   => 'text',
                            'prompt' => 'What is the Worldwide ID (Federation ID) for '
                                + userInput + '?'
                        });
                    }
                    res.statusCode = 206;
                    return JSON.serialize(new Map<String, Object>{
                        'success'             => false,
                        'needsInput'          => true,
                        'userNotFound'        => true,
                        'revokeUserNotFound'  => true,
                        'suggestedRole'       => Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL,
                        'missingFields'       => revokeNewUserMissingFields,
                        'message'             =>
                            'I couldn\'t find a Salesforce user for [' + userInput + ']. '
                            + 'There is no IUPGM access to deactivate for a user who '
                            + 'does not exist.\n\n'
                            + 'Would you like to proceed with creating this user in '
                            + 'Salesforce instead by requesting the '
                            + Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL
                            + ' role?\n\n'
                            + 'If yes, please also provide:\n'
                            + 'Name (First Last):\n'
                            + 'Federation ID (Worldwide ID):\n\n'
                            + 'Reply NO if you do not want to proceed, and no changes '
                            + 'will be made.'
                    });
                }

                if (userInput.contains('@') && !readyToCreateNewUser) {
                    // Email address not found - instead of offering direct AGS user
                    // creation, guide the requester to raise the prerequisite
                    // "Sales CRM (Salesforce) - Core Access" role first. That role
                    // provisions the base Salesforce user; only after it is approved
                    // can application-specific IUPGM roles be requested for this person.
                    List<Map<String, Object>> newUserMissingFields =
                        new List<Map<String, Object>>();
                    if (!hasFullName) {
                        newUserMissingFields.add(new Map<String, Object>{
                            'field'  => 'newUserFullName',
                            'label'  => 'Full Name (First Last)',
                            'type'   => 'text',
                            'prompt' => 'What is the full name (First and Last) for '
                                + userInput + '?'
                        });
                    }
                    if (!hasFederationId) {
                        newUserMissingFields.add(new Map<String, Object>{
                            'field'  => 'newUserFederationId',
                            'label'  => 'Federation ID (Worldwide ID / WWID)',
                            'type'   => 'text',
                            'prompt' => 'What is the Worldwide ID (Federation ID) for '
                                + userInput + '? This cannot be looked up automatically '
                                + 'for a new user and is required to create their access request.'
                        });
                    }
                    res.statusCode = 206;
                    return JSON.serialize(new Map<String, Object>{
                        'success'            => false,
                        'needsInput'         => true,
                        'userNotFound'       => true,
                        'suggestedRole'      => Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL,
                        'missingFields'      => newUserMissingFields,
                        'message'            =>
                            'Please provide the following details:\n'
                            + 'Name (First Last):\n'
                            + 'Federation ID (Worldwide ID):\n'
                            + 'Email: ' + userInput + '\n\n'
                            + 'I couldn\'t find this user in Salesforce.\n\n'
                            + 'To create the user account in Salesforce, please first request the '
                            + Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL + ' role.\n\n'
                            + 'After the role is approved and the user is provisioned in Salesforce, '
                            + 'you\'ll be able to submit requests for additional application-specific roles.\n\n'
                            + 'Would you like me to add the '
                            + Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL
                            + ' role request instead?'
                    });
                } else if (userInput.contains('@') && readyToCreateNewUser) {
                    // We have an email, a full name, and a federation id (Worldwide ID) -
                    // proceed without a Salesforce User record. ServiceHandler Gate 1
                    // will trigger AGS user creation automatically.
                    userName  = newUserFullName;
                    userEmail = userInput;
                    // No fallback to deriveFederationFromEmail() here - the federation
                    // id is mandatory, explicitly collected above, and never guessed,
                    // since it is sent verbatim in the AGS user-creation payload.
                    // userId stays null - staging will have null User lookup
                } else {
                    // Name-based search not found - cannot create without an email
                    validationErrors.add('No active Salesforce user found for ['
                        + userInput + ']. '
                        + 'Please provide the exact Intel email address.');
                }
            } else if (!users.isEmpty()) {
                userId    = users[0].Id;
                userName  = users[0].Name;
                userEmail = users[0].Email;
            }

            /*
            ================================================================
            STEP 5 - RESOLVE ROLE (EXACT METADATA LOOKUP ONLY)
            ----------------------------------------------------------------
            ROLE RESOLUTION OWNERSHIP: validateAccessRequest performs ONLY
            deterministic validation against Core_MDF_IUPGM_Rule_Config__mdt.
            It must NOT search, fuzzy-match, keyword-score, contains-match,
            or suggest roles, and it must NOT fall back to a broader search
            when the exact role is not found.

            All role UNDERSTANDING/RESOLUTION - exact names, incomplete or
            incorrect names, aliases, abbreviations, keywords, business use
            cases, natural-language descriptions, and ambiguity resolution -
            is owned exclusively by the AI Role Recommendation Agent:
            GET /access/recommendRole, backed by
            Core_MDF_IUPGMRoleRecommendationService. The chatbot must call
            that endpoint first and only send validateAccessRequest the
            exact, canonical Role Label the agent returned/the user
            confirmed.

            roleInput reaching this point is therefore expected to already
            be a byte-exact Role Label present in MDT. It is looked up with
            a single exact-equality SOQL query - no LIKE, no substring/
            contains matching, no keyword scoring. If it is not found, a
            deterministic ROLE_NOT_FOUND error is returned immediately -
            never a "closest match" list.
            ================================================================
            */

            /*
            ================================================================
            NEW USER CORE ACCESS BOOTSTRAP
            ----------------------------------------------------------------
            "Sales CRM (Salesforce) - Core Access" is the prerequisite AGS role
            that provisions a brand-new user's base Salesforce account. It is
            requested BEFORE the person exists in Salesforce, so there is
            nothing meaningful for an MDT config record to validate (no
            account/region/budget applicability - those only apply to
            application roles requested AFTER the user is provisioned).
            Do not require an MDT record for it at all: whenever we already
            know this is a brand-new user (full name + federation id were
            collected above) and the role text they typed is this bootstrap
            role, synthesize the config in memory - AGS Role Name is the only
            value that matters here - and skip the MDT lookup entirely. The
            other fields are explicit safe defaults so the normal downstream
            account/region/budget checks are skipped too. This is a single
            hardcoded system bootstrap phrase (not MDT-backed, since no MDT
            record can exist for a role that provisions the user itself) -
            it is not role search/disambiguation over MDT records.
            ================================================================
            */
            Core_MDF_IUPGM_Rule_Config__mdt newUserCoreAccessBootstrap = null;
            if (isNewUserFlow && String.isNotBlank(roleInput)) {
                String roleInputForBootstrap = roleInput.trim().toLowerCase();
                if (roleInputForBootstrap.contains('core access')
                    && (roleInputForBootstrap.contains('sales')
                        || roleInputForBootstrap.contains('crm'))) {
                    newUserCoreAccessBootstrap = new Core_MDF_IUPGM_Rule_Config__mdt(
                        Core_MDF_Role_Label__c   = Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL,
                        Core_MDF_AGS_Role_Name__c = Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL,
                        Core_MDF_IUPGM_Required__c = false,
                        Core_MDF_Skip_PS_Check__c  = true,
                        Core_MDF_Account_Required__c = false,
                        Core_MDF_WW_Only__c        = true,
                        Core_MDF_All_Budget_Type_Available__c = false,
                        Core_MDF_Budget_Required_When_False__c = false,
                        Core_MDF_Approval_Region_Required__c = false,
                        Core_MDF_Activity_Classification_Req__c = false,
                        Core_MDF_Is_Active__c      = true
                    );
                }
            }

            List<String> warnings = new List<String>();

            Core_MDF_IUPGM_Rule_Config__mdt cfg = null;

            if (newUserCoreAccessBootstrap != null) {
                cfg = newUserCoreAccessBootstrap;

            } else if (String.isBlank(roleInput)) {
                /*
                ========================================================
                INTERNAL AUTO-RESOLUTION FROM userQuery
                --------------------------------------------------------
                No explicit/selected roleLabel was given. Rather than
                hard-failing, ask the SAME AI Role Recommendation engine
                (resolveRoleCandidates - identical implementation used by
                the public GET /access/recommendRole agent) to interpret
                userQuery. This keeps role UNDERSTANDING owned by the AI
                agent (validateAccessRequest still never implements its
                own separate search) while letting a single chatbot tool
                call complete the whole request end-to-end.

                - High-confidence single match -> auto-continue with that
                  exact, verified label (still surfaced transparently via
                  a warning + the Role shown in the confirmation summary
                  before anything is ever submitted).
                - Multiple plausible candidates / needs clarification ->
                  return the SAME selectRole/multipleRoles-style prompt
                  used elsewhere in this method, compatible with the
                  existing "reply with a number or name" selection flow.
                - No confident match at all -> a clear, actionable error.
                ========================================================
                */
                if (String.isBlank(userQuery)) {
                    res.statusCode = 400;
                    return JSON.serialize(new Map<String, Object>{
                        'success'   => false,
                        'errorCode' => 'ROLE_NOT_PROVIDED',
                        'message'   => 'A resolved roleLabel is required. Please resolve the '
                            + 'requested role first via the AI Role Recommendation Agent '
                            + '(GET /access/recommendRole'
                            + (program != null ? '?program=' + program : '') + ') '
                            + 'and resend this request with the exact roleLabel it returns.'
                    });
                }

                RoleResolutionOutcome roleOutcome = resolveRoleCandidates(userQuery, program);

                if (roleOutcome.found && roleOutcome.highConfidence
                        && String.isNotBlank(roleOutcome.resolvedRoleLabel)) {
                    // MANDATORY ROLE CONFIRMATION GATE: an inferred role must always be
                    // explicitly confirmed by the user - with the reason it was chosen -
                    // before any other field (account/region/budget) is collected. Do NOT
                    // silently continue. The chatbot resends this same request with
                    // roleLabel explicitly set to the confirmed value once the user agrees.
                    res.statusCode = 200; return JSON.serialize(new Map<String, Object>{
                        'success'           => false,  'needsInput'        => true, 'needsConfirmation' => true, 'errorCode'         => 'ROLE_CONFIRMATION_REQUIRED', 'roleLabel'         => roleOutcome.resolvedRoleLabel,'program'           => displayProgramLabel(roleOutcome.resolvedRoleProgram), 'reason'            => roleOutcome.resolvedRoleReason,'message'           => buildRoleConfirmationMessage( roleOutcome.resolvedRoleLabel, roleOutcome.resolvedRoleReason, roleOutcome.resolvedRolePurpose)
                    });

                } else if (roleOutcome.found && !roleOutcome.recommendations.isEmpty()) {
                    // Multiple plausible candidates - ask the user to choose, phrased as a
                    // forward-looking question (never echoes the original invalid input).
                    // Confidence scores are intentionally NOT exposed to the user.
                    List<String> roleNames = new List<String>();
                    List<Map<String, Object>> rolesDisplay = new List<Map<String, Object>>();
                    Integer idx = 1;
                    for (Map<String, Object> rec : roleOutcome.recommendations) {
                        String lbl = (String) rec.get('roleLabel');
                        roleNames.add(lbl);
                        rolesDisplay.add(new Map<String, Object>{
                            'index'   => idx,
                            'label'   => lbl,
                            'program' => rec.get('program'),
                            'purpose' => rec.get('purpose')
                        });
                        idx++;
                    }
                    res.statusCode = 300;
                    return JSON.serialize(new Map<String, Object>{
                        'success'               => false,
                        'needsInput'            => true,
                        'selectRole'            => true,
                        'errorCode'             => 'ROLE_NEEDS_SELECTION',
                        'message'               => buildRoleOptionsQuestion(rolesDisplay, roleOutcome.clarificationQuestion),
                        'needsClarification'    => roleOutcome.needsClarification,
                        'clarificationQuestion' => roleOutcome.clarificationQuestion,
                        'roles'                 => roleNames,
                        'rolesDisplay'          => rolesDisplay
                    });

                } else {
                    // No confident match at all.
                    res.statusCode = 400;
                    return JSON.serialize(new Map<String, Object>{
                        'success'               => false,
                        'needsInput'            => true,
                        'errorCode'             => 'ROLE_NOT_FOUND',
                        'needsClarification'    => true,
                        'clarificationQuestion' => roleOutcome.clarificationQuestion,
                        'message'               => 'The system requires a specific role to proceed '
                            + 'with this request. Kindly provide the required role for this user.'
                            + (String.isNotBlank(roleOutcome.clarificationQuestion)
                                ? ' ' + roleOutcome.clarificationQuestion
                                : ' If you\'re unsure about the exact role, you can resolve it '
                                    + 'by using the AI Role Recommendation Agent (GET /access/'
                                    + 'recommendRole) or provide more details to help determine '
                                    + 'the correct role.')
                    });
                }
            }

            if (cfg == null) {
                // Bounded self-correction: an explicitly-given roleLabel might be a
                // wrong guess from the CALLER'S own layer (e.g. mistaking the
                // program acronym "IPA" for a role name out of "...for IPA..."),
                // not a genuinely non-existent role. If the exact lookup fails and a
                // richer userQuery is available, consult the SAME AI Role
                // Recommendation engine against the full sentence exactly once
                // before hard-failing - this never masks a truly non-existent role
                // (e.g. "CCP External Activity Submitter"), because the engine
                // itself will also return no confident match for that case (already
                // verified). The loop runs at most twice: the original attempt, and
                // - only if that failed and correction is applicable - one retry
                // with the corrected label.
                Boolean triedQueryFallback = false;
                String  originalRoleInputForMessage = roleInput;

                while (cfg == null) {
                    Set<String> programCandidates = program != null
                        ? getProgramCandidates(program)
                        : null;

                    List<Core_MDF_IUPGM_Rule_Config__mdt> roleRecords = programCandidates != null
                        ? [
                            SELECT  MasterLabel,
                                    Core_MDF_Role_Label__c,
                                    Core_MDF_Permission_Set_Name__c,
                                    Core_MDF_AGS_Role_Name__c,
                                    Core_MDF_Region_AGS_Role_Map__c,
                                    Core_MDF_IUPGM_Role_Name__c,
                                    Core_MDF_IUPGM_Required__c,
                                    Core_MDF_Program__c,
                                    Core_MDF_All_Accounts__c,
                                    Core_MDF_Account_Required__c,
                                    Core_MDF_Region_Options__c,
                                    Core_MDF_WW_Only__c,
                                    Core_MDF_All_Budget_Type_Available__c,
                                    Core_MDF_Budget_Required_When_False__c,
                                    Core_MDF_Geo_Budget_Mapping__c,
                                    Core_MDF_Approval_Region_Required__c,
                                    Core_MDF_Approval_Region_Options__c,
                                    Core_MDF_Activity_Classification_Req__c,
                                    Core_MDF_Skip_PS_Check__c,
                                    Core_MDF_Is_Active__c,
                                    Core_MDF_Role_Purpose__c
                            FROM Core_MDF_IUPGM_Rule_Config__mdt
                            WHERE Core_MDF_Role_Label__c = :roleInput
                              AND Core_MDF_Program__c    IN :programCandidates
                              AND Core_MDF_Is_Active__c  = true
                          ]
                        : [
                            SELECT  MasterLabel,
                                    Core_MDF_Role_Label__c,
                                    Core_MDF_Permission_Set_Name__c,
                                    Core_MDF_AGS_Role_Name__c,
                                    Core_MDF_Region_AGS_Role_Map__c,
                                    Core_MDF_IUPGM_Role_Name__c,
                                    Core_MDF_IUPGM_Required__c,
                                    Core_MDF_Program__c,
                                    Core_MDF_All_Accounts__c,
                                    Core_MDF_Account_Required__c,
                                    Core_MDF_Region_Options__c,
                                    Core_MDF_WW_Only__c,
                                    Core_MDF_All_Budget_Type_Available__c,
                                    Core_MDF_Budget_Required_When_False__c,
                                    Core_MDF_Geo_Budget_Mapping__c,
                                    Core_MDF_Approval_Region_Required__c,
                                    Core_MDF_Approval_Region_Options__c,
                                    Core_MDF_Activity_Classification_Req__c,
                                    Core_MDF_Skip_PS_Check__c,
                                    Core_MDF_Is_Active__c,
                                    Core_MDF_Role_Purpose__c
                            FROM Core_MDF_IUPGM_Rule_Config__mdt
                            WHERE Core_MDF_Role_Label__c = :roleInput
                              AND Core_MDF_Is_Active__c  = true
                          ];

                    if (program != null && !roleRecords.isEmpty()) {
                        roleRecords = collapseRoleRecordsForProgram(roleRecords, program);
                    }

                    if (roleRecords.isEmpty()) {
                        // Try treating the input as an AGS role name instead of the
                        // internal role label (some callers/integrations type the AGS
                        // entitlement name, e.g. "Co-Marketing(Salesforce)-Price
                        // Reviewer"). This MUST be a separate query - Custom Metadata
                        // Type SOQL does not support OR/disjunctions combined with
                        // other filters ("MALFORMED QUERY: Disjunctions not
                        // supported"), so it cannot be merged into the query above.
                        roleRecords = programCandidates != null
                            ? [
                                SELECT  MasterLabel,
                                        Core_MDF_Role_Label__c,
                                        Core_MDF_Permission_Set_Name__c,
                                        Core_MDF_AGS_Role_Name__c,
                                        Core_MDF_Region_AGS_Role_Map__c,
                                        Core_MDF_IUPGM_Role_Name__c,
                                        Core_MDF_IUPGM_Required__c,
                                        Core_MDF_Program__c,
                                        Core_MDF_All_Accounts__c,
                                        Core_MDF_Account_Required__c,
                                        Core_MDF_Region_Options__c,
                                        Core_MDF_WW_Only__c,
                                        Core_MDF_All_Budget_Type_Available__c,
                                        Core_MDF_Budget_Required_When_False__c,
                                        Core_MDF_Geo_Budget_Mapping__c,
                                        Core_MDF_Approval_Region_Required__c,
                                        Core_MDF_Approval_Region_Options__c,
                                        Core_MDF_Activity_Classification_Req__c,
                                        Core_MDF_Skip_PS_Check__c,
                                        Core_MDF_Is_Active__c,
                                        Core_MDF_Role_Purpose__c
                                FROM Core_MDF_IUPGM_Rule_Config__mdt
                                WHERE Core_MDF_AGS_Role_Name__c = :roleInput
                                  AND Core_MDF_Program__c    IN :programCandidates
                                  AND Core_MDF_Is_Active__c  = true
                              ]
                            : [
                                SELECT  MasterLabel,
                                        Core_MDF_Role_Label__c,
                                        Core_MDF_Permission_Set_Name__c,
                                        Core_MDF_AGS_Role_Name__c,
                                        Core_MDF_Region_AGS_Role_Map__c,
                                        Core_MDF_IUPGM_Role_Name__c,
                                        Core_MDF_IUPGM_Required__c,
                                        Core_MDF_Program__c,
                                        Core_MDF_All_Accounts__c,
                                        Core_MDF_Account_Required__c,
                                        Core_MDF_Region_Options__c,
                                        Core_MDF_WW_Only__c,
                                        Core_MDF_All_Budget_Type_Available__c,
                                        Core_MDF_Budget_Required_When_False__c,
                                        Core_MDF_Geo_Budget_Mapping__c,
                                        Core_MDF_Approval_Region_Required__c,
                                        Core_MDF_Approval_Region_Options__c,
                                        Core_MDF_Activity_Classification_Req__c,
                                        Core_MDF_Skip_PS_Check__c,
                                        Core_MDF_Is_Active__c,
                                        Core_MDF_Role_Purpose__c
                                FROM Core_MDF_IUPGM_Rule_Config__mdt
                                WHERE Core_MDF_AGS_Role_Name__c = :roleInput
                                  AND Core_MDF_Is_Active__c  = true
                              ];
                        if (program != null && !roleRecords.isEmpty()) {
                            roleRecords = collapseRoleRecordsForProgram(roleRecords, program);
                        }
                    }

                    if (roleRecords.isEmpty()) {
                        // Fall back to the fuzzy/AI role-resolution engine using the
                        // richest available text - userQuery when the caller sent one,
                        // otherwise the roleLabel the caller typed (it may simply be a
                        // misspelling, partial name, or AGS role name that didn't match
                        // exactly). This ensures a wrong/incomplete role label ALWAYS
                        // gets a suggestion attempt, not just when a separate userQuery
                        // happens to be present.
                        String fallbackQueryText = String.isNotBlank(userQuery)
                            ? userQuery : originalRoleInputForMessage;
                        if (!triedQueryFallback && String.isNotBlank(fallbackQueryText)) {
                            triedQueryFallback = true;
                            RoleResolutionOutcome fallbackOutcome = resolveRoleCandidates(fallbackQueryText, program);

                            if (fallbackOutcome.found && fallbackOutcome.highConfidence
                                    && String.isNotBlank(fallbackOutcome.resolvedRoleLabel)) {
                                // MANDATORY ROLE CONFIRMATION GATE - see note above. Stop and ask
                                // the user to confirm the corrected role before proceeding further.
                                res.statusCode = 200;
                                return JSON.serialize(new Map<String, Object>{
                                    'success'           => false,
                                    'needsInput'        => true,
                                    'needsConfirmation' => true,
                                    'errorCode'         => 'ROLE_CONFIRMATION_REQUIRED',
                                    'roleLabel'         => fallbackOutcome.resolvedRoleLabel,
                                    'program'           => displayProgramLabel(fallbackOutcome.resolvedRoleProgram),
                                    'reason'            => fallbackOutcome.resolvedRoleReason,
                                    'message'           => buildRoleConfirmationMessage(
                                        fallbackOutcome.resolvedRoleLabel, fallbackOutcome.resolvedRoleReason,
                                        fallbackOutcome.resolvedRolePurpose)
                                });

                            } else if (fallbackOutcome.found && !fallbackOutcome.recommendations.isEmpty()) {
                                // Ask as a forward-looking question - never echoes the original
                                // invalid input. Confidence scores are NOT exposed to the user.
                                List<String> roleNames = new List<String>();
                                List<Map<String, Object>> rolesDisplay = new List<Map<String, Object>>();
                                Integer idx = 1;
                                for (Map<String, Object> rec : fallbackOutcome.recommendations) {
                                    String lbl = (String) rec.get('roleLabel');
                                    roleNames.add(lbl);
                                    rolesDisplay.add(new Map<String, Object>{
                                        'index'   => idx,
                                        'label'   => lbl,
                                        'program' => rec.get('program'),
                                        'purpose' => rec.get('purpose')
                                    });
                                    idx++;
                                }
                                res.statusCode = 300;
                                return JSON.serialize(new Map<String, Object>{
                                    'success'               => false,
                                    'needsInput'            => true,
                                    'selectRole'            => true,
                                    'errorCode'             => 'ROLE_NEEDS_SELECTION',
                                    'message'               => buildRoleOptionsQuestion(rolesDisplay, fallbackOutcome.clarificationQuestion),
                                    'needsClarification'    => fallbackOutcome.needsClarification,
                                    'clarificationQuestion' => fallbackOutcome.clarificationQuestion,
                                    'roles'                 => roleNames,
                                    'rolesDisplay'          => rolesDisplay
                                });
                            }
                            // else: AI engine also found nothing confident - fall through to hard fail below.
                        }

                        res.statusCode = 400;
                        return JSON.serialize(new Map<String, Object>{
                            'success'   => false,
                            'errorCode' => 'ROLE_NOT_FOUND',
                            'message'   => 'Role "' + originalRoleInputForMessage + '"'
                                + (program != null
                                    ? ' was not found in program [' + programInput + ']'
                                    : ' was not found')
                                + ' in the active Role Configuration. This exact role either does not '
                                + 'exist or is inactive. Please resolve it via the AI Role Recommendation '
                                + 'Agent (GET /access/recommendRole) instead of resending a different spelling.'
                        });
                    } else if (roleRecords.size() > 1) {
                        // Same exact Role Label is active in more than one program. This is a
                        // deterministic required-field gap (which program?) driven entirely by
                        // MDT data - not a role search. The role name itself is already an
                        // unambiguous, exact match.
                        List<String> programOptions = new List<String>();
                        for (Core_MDF_IUPGM_Rule_Config__mdt r : roleRecords) {
                            String pLabel = displayProgramLabel(r.Core_MDF_Program__c);
                            if (!programOptions.contains(pLabel)) programOptions.add(pLabel);
                        }
                        res.statusCode = 300;
                        return JSON.serialize(new Map<String, Object>{
                            'success'        => false,
                            'needsInput'     => true,
                            'errorCode'      => 'ROLE_AMBIGUOUS_PROGRAM',
                            'message'        => 'The role "' + roleInput + '" is active in multiple '
                                + 'programs. Please specify which program: '
                                + String.join(programOptions, ', '),
                            'programOptions' => programOptions
                        });
                    } else {
                        cfg = roleRecords[0];
                    }
                }
            }

            if (!validationErrors.isEmpty()) {
                res.statusCode = 400;
                return JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => 'Validation failed. Please review all issues.',
                    'errors'  => validationErrors
                });
            }

            // Derive program from MDT record if not supplied by caller
            if (String.isBlank(program)) {
                program = cfg.Core_MDF_Program__c;
            }

            /* REVOKE deactivates IUPGM only; it never checks or removes AGS access. */
            if (isRevokeRequest) {
                if (userId == null) {
                    res.statusCode = 400;
                    return JSON.serialize(new Map<String, Object>{
                        'success' => false,
                        'message' => 'Cannot deactivate IUPGM access for a user that does not exist in Salesforce.'
                    });
                }

                // AGS-ONLY ROLE GUARD: roles configured with Core_MDF_IUPGM_Required__c
                // = false are managed entirely through AGS/Permission Sets and never
                // get an IUPGM record created for them. There is nothing in IUPGM to
                // deactivate for these roles, so reject explicitly in the chatbot
                // response rather than returning a confusing "nothing to deactivate"
                // message further down.
                if (!cfg.Core_MDF_IUPGM_Required__c) {
                    res.statusCode = 400;
                    return JSON.serialize(new Map<String, Object>{
                        'success' => false,
                        'message' => 'Deactivation of ' + cfg.Core_MDF_Role_Label__c
                            + ' is not supported. This is an AGS-only role with no '
                            + 'IUPGM records to deactivate. Please reach out to the '
                            + 'administration team for further assistance.'
                    });
                }

                String iupgmProgram = toIupgmProgramName(cfg.Core_MDF_Program__c);
                String iupgmRole = String.isNotBlank(cfg.Core_MDF_Permission_Set_Name__c)
                    ? cfg.Core_MDF_Permission_Set_Name__c
                    : cfg.Core_MDF_IUPGM_Role_Name__c;
                List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> activeIupgm = [
                    SELECT Id
                    FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                    WHERE Core_MDF_User_id__c = :userId
                      AND Core_MDF_Role_nm__c = :iupgmRole
                      AND Core_MDF_Program_nm__c = :iupgmProgram
                      AND Core_MDF_Active_Ind__c = true
                    LIMIT 1
                ];

                if (activeIupgm.isEmpty()) {
                    res.statusCode = 200;
                    return JSON.serialize(new Map<String, Object>{
                        'success' => false,
                        'message' => userName + ' does not currently have the "'
                            + cfg.Core_MDF_Role_Label__c + '" IUPGM access. Nothing to deactivate.'
                    });
                }

                // REVOKE CONFIRMATION CHECK: If user already confirmed (userConfirmed=true OR
                // query is affirmative like "yes", "proceed"), create staging record immediately
                // instead of returning another confirmation prompt.
                if (userConfirmed || isStartAffirmative(userQuery)) {
                    // This is the CONFIRMED REVOKE submission. Create staging record directly.
                    Map<String, Object> confirmedRevokeSummary = new Map<String, Object>{
                        'requestAction'      => 'REVOKE',
                        'userId'             => userId,
                        'userName'           => userName,
                        'userEmail'          => userEmail,
                        'program'            => program,
                        'roleLabel'          => cfg.Core_MDF_Role_Label__c,
                        'permissionSetName'  => cfg.Core_MDF_Permission_Set_Name__c,
                        'agsRoleName'        => cfg.Core_MDF_AGS_Role_Name__c,
                        'iupgmRequired'      => cfg.Core_MDF_IUPGM_Required__c,
                        'iupgmRoleName'      => cfg.Core_MDF_IUPGM_Role_Name__c,
                        'requestorEmail'     => requestorEmail,
                        'allAccountAccess'   => true
                    };
                    
                    // Create and insert staging record
                    Core_MDF_IUPGM_Request_Staging__c staging = createStagingFromSummary(confirmedRevokeSummary);
                    insert staging;
                    staging = [
                        SELECT Id, Name, Core_MDF_Request_Status_nm__c
                        FROM Core_MDF_IUPGM_Request_Staging__c
                        WHERE Id = :staging.Id LIMIT 1
                    ];
                    
                    res.statusCode = 200;
                    return JSON.serialize(new Map<String, Object>{
                        'success'            => true,
                        'autoSubmitted'      => true,
                        'requestNumber'      => staging.Name,
                        'status'             => staging.Core_MDF_Request_Status_nm__c,
                        'requestSummary'     => confirmedRevokeSummary,
                        'displaySummary'     => new Map<String, Object>{
                            'Action'  => 'Deactivate IUPGM Access',
                            'Role'    => cfg.Core_MDF_Role_Label__c,
                            'Program' => displayProgramLabel(program),
                            'User'    => userName + (String.isNotBlank(userEmail) ? ' (' + userEmail + ')' : '')
                        },
                        'message' => 'Great! Your request for deactivating ' + cfg.Core_MDF_Role_Label__c
                            + ' has been submitted successfully.'
                    });
                }

                // User has not yet confirmed - return confirmation prompt for them to reply YES/NO
                Map<String, Object> revokeSummary = new Map<String, Object>{
                    'requestAction'      => 'REVOKE', 'userId'             => userId,   'userName'           => userName, 'userEmail'          => userEmail, 'program'            => program, 'roleLabel'          => cfg.Core_MDF_Role_Label__c,  'permissionSetName'  => cfg.Core_MDF_Permission_Set_Name__c,   'agsRoleName'        => cfg.Core_MDF_AGS_Role_Name__c, 'iupgmRequired'      => cfg.Core_MDF_IUPGM_Required__c, 'iupgmRoleName'      => cfg.Core_MDF_IUPGM_Role_Name__c, 'requestorEmail'     => requestorEmail
                };
                Map<String, Object> revokeDisplaySummary = new Map<String, Object>{
                    'Action'  => 'Deactivate IUPGM Access', 'Role' => cfg.Core_MDF_Role_Label__c,
                    'Program' => displayProgramLabel(program),
                    'User'    => userName + (String.isNotBlank(userEmail) ? ' (' + userEmail + ')' : '')
                };
                res.statusCode = 200;    return JSON.serialize(new Map<String, Object>{
                    'success'            => true,  'readyForSubmission' => false,
                    'requestSummary'     => revokeSummary,  'displaySummary' => revokeDisplaySummary,
                    'confirmationPrompt' => 'You are about to deactivate all active IUPGM records for "'
                        + cfg.Core_MDF_Role_Label__c + '" in ' + displayProgramLabel(program)
                        + ' for ' + userName + '. No AGS access will be changed. Reply YES to confirm, or NO to cancel.'
                });
            }

            

            /*
            ================================================================
            STEP 6 - DETERMINE ALL FIELD VALUES AND COLLECT ALL MISSING FIELDS
            KEY DESIGN: We do NOT return on the first missing field.
            We collect ALL missing fields and return them together.
            Chatbot shows the user everything they need to provide at once.
            ================================================================
            */
            
            // DEFENSIVE CHECK: REVOKE requests must exit before reaching this step
            // If we somehow get here with isRevokeRequest=true, it's an internal error
            if (isRevokeRequest) {
                res.statusCode = 500;
                return JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => 'Internal error: REVOKE request reached Step 6 (field collection). '
                        + 'REVOKE should have been handled and completed by now. '
                        + 'Please contact support if this error persists.'
                });
            }
            
            List<Map<String, Object>> missingFields = new List<Map<String, Object>>();
            
            if (String.isNotBlank(multiProgramNotice)) { warnings.add(multiProgramNotice);
            }
            if (String.isNotBlank(multiUserNotice)) { warnings.add(multiUserNotice);
            }
            if (String.isNotBlank(multiRoleNotice)) {
                warnings.add(multiRoleNotice);
            }

            // Rescue mis-routed account name: chatbot tool code sometimes puts the
            // account name into allAccountAccess (e.g. allAccountAccess: "Marvel")
            // instead of accountName. Detect any non-boolean string and move it to
            // accountName so Step 6a/6b resolve it correctly.
            // Only runs when allAccountAccess is a non-null, non-Boolean, non-boolean-word
            // string - all other cases (null, true, false, "yes", "all", etc.) are unaffected.
            Object rawAllAcct = p.get('allAccountAccess');
            if (rawAllAcct != null && !(rawAllAcct instanceof Boolean)) {
                String rawStr = String.valueOf(rawAllAcct).trim();Boolean isBooleanWord = rawStr.equalsIgnoreCase('true') || rawStr.equalsIgnoreCase('false')|| rawStr.equalsIgnoreCase('yes')  || rawStr.equalsIgnoreCase('no')  || rawStr.equalsIgnoreCase('all') || rawStr.equalsIgnoreCase('specific');
                if (!isBooleanWord && String.isBlank(str(p, 'accountName'))) {
                    p.put('accountName', rawStr);
                    p.remove('allAccountAccess');
                }
            }

            // â"€â"€ 6a: All Account Access â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
            Boolean allAccountAccess = null;
            String  allAccOpt        = cfg.Core_MDF_All_Accounts__c;

            if (!cfg.Core_MDF_Account_Required__c) {
                // Account access is not applicable to this role at all (e.g. AGS-only
                // roles) - never ask the all/specific question, regardless of how
                // Core_MDF_All_Accounts__c happens to be configured.
                allAccountAccess = true;
            } else if (allAccOpt == 'YES_ONLY') {
                allAccountAccess = true;
            } else if (allAccOpt == 'NO_ONLY') {
                allAccountAccess = false;
                // Note: allAccountAccess is ignored for this role - account is always required.
                // The note is surfaced in the accountName missingField prompt below.
            } else {
                Object rawBool = p.get('allAccountAccess');
                if (rawBool == null) {
                    String inferredAccountName = str(p, 'accountName');
                    if (String.isNotBlank(inferredAccountName)) {
                        allAccountAccess = false;
                    } else {
                        missingFields.add(new Map<String, Object>{
                            'field'   => 'allAccountAccess',
                            'label'   => 'All Account Access',
                            'type'    => 'boolean',
                            'prompt'  => 'Should ' + userName
                                + ' have access to ALL accounts, '
                                + 'or a specific account?',
                            'options' => new List<String>{ 'all', 'specific' },
                            'message' => 'Please reply with: 1) all  or  2) specific'
                        });
                        // Do NOT set allAccountAccess - mark as missing
                    }
                } else {
                    allAccountAccess = parseBool(rawBool);
                }
            }

            // â”€â”€ 6b: Account Name â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // Only required when allAccountAccess = false AND Account_Required = true
            // If allAccountAccess is still null (missing), we tentatively check
            // if an account field would be needed regardless.
            String resolvedAccountName = null;
            Id     accountId           = null;

            // REVOKE REQUESTS: Skip Account/Region validation
            // When revoking access, all accounts/regions should be deactivated without requiring specifics
            Boolean accountWillBeNeeded =
                !isRevokeRequest && (
                    (allAccOpt == 'NO_ONLY')
                    || (allAccOpt == 'YES_NO' && allAccountAccess == false)
                );

            if (accountWillBeNeeded && cfg.Core_MDF_Account_Required__c) { String accountName = str(p, 'accountName');
                // Build prompt - add note when role doesn't support all-account access
                String accountPrompt = allAccOpt == 'NO_ONLY'
                    ? 'Note: "All Account Access" is not applicable for the role "'
                        + cfg.Core_MDF_Role_Label__c + '" - a specific account is always required. '
                        + 'Please provide the Account Name for ' + userName + '\'s access.'
                    : 'Please provide the Account Name for ' + userName + '\'s access. '
                        + '(Type the partner/customer company name or Unified ID - we will look it up for you)';
                if (String.isBlank(accountName)) { missingFields.add(new Map<String, Object>{
                        'field'  => 'accountName',          'label'  => 'Account',  'type'   => 'lookup',  'prompt' => accountPrompt
                    });
                } else {
                    /*
                    â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    ACCOUNT LOOKUP SCOPE
                    An account is an Ultimate Account when its
                    Core_MDF_CoMarketing_Ultimate_Account__c lookup is empty.

                    Every program except Retail Marketing Funds (RMF) may
                    only be mapped at Ultimate Account level, so the lookup
                    itself is restricted to Ultimate Accounts for those
                    programs. RMF is the opposite - it may ONLY map at
                    node / sub-node (Virtual Corp) level, never the Ultimate
                    Account itself, so its lookup is restricted to accounts
                    that DO have an Ultimate Account parent populated.

                    Filtering in the query (rather than validating after)
                    means a wrongly-scoped account simply doesn't resolve
                    via the direct-name/partial-name searches, and falls
                    through to the RMF-specific messaging below.
                    â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    */
                    Boolean nodeAllowed = isNodeLevelAllowed(program); String  programFilter = '';
                    String  programLabel = resolveProgram(program);
                    if (nodeAllowed && String.isNotBlank(programLabel)) { programFilter = ' AND Core_MDF_Channel_Program__r.Name = :programLabel';
                    }

                    String  scopeFilter = nodeAllowed
                        ? ' AND Core_MDF_CoMarketing_Ultimate_Account__c != null'
                            + ' AND Core_MDF_Active_Ind__c = true'
                        : ' AND Core_MDF_CoMarketing_Ultimate_Account__c = null'
                            + ' AND Core_MDF_CoMarketingActive__c = true';

                    String selectClause =
                        'SELECT Id, Name, '
                        + 'Core_Business_Party_Id__c, '
                        + 'Core_MDF_CoMarketing_Ultimate_Account__c, '
                        + 'Core_MDF_CoMarketing_Ultimate_Account__r.Name '
                        + 'FROM Account WHERE ';

                    String nameBind = accountName;
                    String unifiedIdBind = extractUnifiedIdFromAccountInput(accountName);

                    /*
                    ACCOUNT INPUT RESOLUTION
                    The chatbot continues to send only accountName. The value may be:
                      1) Account Name          -> "Marvel"
                      2) Unified ID            -> "12345"
                      3) Display value         -> "Marvel (12345)"
                    Resolve all three forms here in Salesforce. The resolved Account Id
                    remains the actual value used downstream; the display value is built
                    separately by buildAccountDisplayName().
                    */
                    List<Account> accounts = Database.query(
                        selectClause + 'Name = :nameBind'
                        + programFilter
                        + scopeFilter + ' LIMIT 5'
                    );

                    // If the user entered the Unified ID directly, resolve it to the Account.
                    if (accounts.isEmpty()) {
                        accounts = Database.query(
                            selectClause + 'Core_Business_Party_Id__c = :nameBind'
                            + programFilter
                            + scopeFilter + ' LIMIT 5'
                        );
                    }

                    // If the chatbot/user sends the displayed value "Marvel (12345)",
                    // extract the Unified ID and resolve using Core_Business_Party_Id__c.
                    if (accounts.isEmpty() && String.isNotBlank(unifiedIdBind)) {
                        accounts = Database.query(
                            selectClause + 'Core_Business_Party_Id__c = :unifiedIdBind'
                            + programFilter
                            + scopeFilter + ' LIMIT 5'
                        );
                    }

                    // Fallback: user typed the Ultimate Account's name - resolve to its
                    // node/sub-node children instead (RMF only; the child accounts already
                    // satisfy the node-level scope by definition of this relationship match).
                    if (accounts.isEmpty() && nodeAllowed) {
                        accounts = Database.query(
                            selectClause
                            + 'Core_MDF_CoMarketing_Ultimate_Account__r.Name = :nameBind'
                            + programFilter
                            + ' AND Core_MDF_Active_Ind__c = true'
                            + ' LIMIT 2'
                        );
                    }

                    // Partial name search if exact match not found.
                    // Do not use the Unified ID as a partial-name search value because
                    // Unified IDs must resolve exactly to avoid accidental matches.
                    if (accounts.isEmpty() && String.isBlank(unifiedIdBind)) {
                        String likeBind = '%' + accountName + '%';
                        accounts = Database.query(
                            selectClause + 'Name LIKE :likeBind'
                            + programFilter
                            + scopeFilter + ' LIMIT 5'
                        );
                    }

                    if (accounts.isEmpty()) {
                        if (nodeAllowed && isUltimateAccountName(accountName)) {
                            validationErrors.add('"' + accountName + '" is an Ultimate Account. '
                                + 'RMF requires a specific node/sub-node (Virtual Corp) account - '
                                + 'please provide the child account name under "' + accountName
                                + '" instead of the Ultimate Account itself.');
                        } else {  validationErrors.add('No account found matching "'
                                + accountName + '". '
                                + 'Please check the company name and try again.');
                        }
                    }

                    if (accounts.size() > 1) {
                        List<String> names = new List<String>(); String numberedAccounts = 'Multiple accounts found. Please select one:\n'; Integer idx = 1; for (Account a : accounts) { String dispName = buildAccountDisplayName(a, nodeAllowed);names.add(dispName); numberedAccounts += idx + ') ' + dispName + '\n';
                            idx++;
                        }
                        res.statusCode = 300;
                        return JSON.serialize(new Map<String, Object>{
                            'success'          => false,
                            'needsInput'       => true,
                            'multipleAccounts' => true,
                            'message'          => numberedAccounts.trim(),
                            'accounts'         => names
                        });
                    }

                    if (!accounts.isEmpty()) { accountId           = accounts[0].Id; resolvedAccountName = buildAccountDisplayName(accounts[0], nodeAllowed);
                    }
                }
            }

            // â”€â”€ 6c: Region â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            String geo = null;

            // REVOKE REQUESTS: Skip region validation
            // When revoking access, all regions should be deactivated without requiring specifics
            if (isRevokeRequest) {
                geo = 'WW'; // Use WW as placeholder for revoke requests
            } else if (cfg.Core_MDF_WW_Only__c) {
                String providedGeo = str(p, 'geo');
                if (String.isNotBlank(providedGeo) && !providedGeo.trim().equalsIgnoreCase('WW')) {
                    warnings.add(cfg.Core_MDF_Role_Label__c + ' is a WW-only role. '
                        + 'Your region (' + providedGeo.trim() + ') has been overridden to WW.');
                }
                geo = 'WW';
            } else if (!cfg.Core_MDF_IUPGM_Required__c
                       && String.isBlank(cfg.Core_MDF_Region_AGS_Role_Map__c)) {
                // Generic AGS-only role (e.g. CCF Operations Admin) - no IUPGM tracking
                // and no region-specific AGS role mapping, so region is not applicable
                // at all. Program alone is enough; never ask, never validate region.
                geo = null;
            } else {
                geo = normalizeGeoString(str(p, 'geo'));
                // Fallback: chatbot sometimes sends only approvalRegion without geo
                // (e.g. for RMF Geo Marketing Approver). Use it to populate geo
                // so region validation doesn't fail on a missing field.
                if (String.isBlank(geo)) {geo = normalizeGeoString(str(p, 'approvalRegion'));
                }
                if (String.isBlank(geo)) { String opts = String.isNotBlank(cfg.Core_MDF_Region_Options__c)
                        ? cfg.Core_MDF_Region_Options__c.replace(';', ', ')
                        : 'APJ, ASMO, EMEA, PRC, WW';
                    missingFields.add(new Map<String, Object>{
                        'field'   => 'geo',
                        'label'   => 'Region',
                        'type'    => 'picklist',
                        'prompt'  => 'Which region should ' + userName
                            + ' have access to?',
                        'options' => opts.split(', ')
                    });
                } else {
                    // Validate region values even at this stage
                    if (String.isNotBlank(cfg.Core_MDF_Region_Options__c)) { Set<String> validRegions = new Set<String>(); for (String r : cfg.Core_MDF_Region_Options__c.split(';')) { validRegions.add(normalizeRegionKey(r));
                        }  List<String> badRegions = new List<String>(); for (String r : geo.split(';')) { String regionKey = normalizeRegionKey(r);  if (!validRegions.contains(regionKey)) { badRegions.add(regionKey);
                            }
                        }
                        if (!badRegions.isEmpty()) {   validationErrors.add('Invalid region(s): ['
                                + String.join(badRegions, ', ') + ']. '
                                + 'Valid for this role: '
                                + cfg.Core_MDF_Region_Options__c.replace(';', ', '));
                        }
                    }
                }
            }

            /*
            ================================================================
            6c-2 - RESTRICT MULTI-REGION FOR REGION-SPECIFIC-AGS-ROLE ROLES
            ----------------------------------------------------------------
            Roles with Core_MDF_Region_AGS_Role_Map__c populated resolve to a
            DIFFERENT AGS permission-set role per region (e.g. RMF Payment
            Admin). AGS status polling (Core_MDF_AGS_CalloutQueueable.
            checkRequestStatus/extractStatusField) only reads requestItems[0]
            of the AGS response, so a single staging record cannot safely
            track approval/rejection of more than one region-specific AGS
            role at once. Restrict to ONE region per request for these roles
            only - same "process first, defer rest" pattern already used for
            multi-user/multi-role above.
            ================================================================
            */
            String multiRegionNotice = null;
            List<String> deferredRegions = new List<String>();
            if (String.isNotBlank(geo)
                && String.isNotBlank(cfg.Core_MDF_Region_AGS_Role_Map__c)) { List<String> allRegionsForAgs = geo.split(';'); if (allRegionsForAgs.size() > 1) { String firstRegionForAgs = allRegionsForAgs[0];for (Integer i = 1; i < allRegionsForAgs.size(); i++) { deferredRegions.add(allRegionsForAgs[i]);
                    }
                    geo = firstRegionForAgs;   multiRegionNotice = cfg.Core_MDF_Role_Label__c
                        + ' resolves to a different AGS role per region, so only one '
                        + 'region can be requested at a time. I will continue with ['
                        + firstRegionForAgs + '] now - please raise a separate request for ['
                        + String.join(deferredRegions, ', ') + '].';
                    warnings.add(multiRegionNotice);
                }
            }

            // â”€â”€ 6d: All Budget Access â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Boolean allBudgetAccess = null;
            String  geoBudgetType   = null;

            if (cfg.Core_MDF_All_Budget_Type_Available__c) {Object rawBudget = p.get('allBudgetAccess'); if (rawBudget == null) { missingFields.add(new Map<String, Object>{
                        'field'   => 'allBudgetAccess',
                        'label'   => 'All Budget Type Access',
                        'type'    => 'boolean',
                        'prompt'  => 'Should ' + userName
                            + ' have access to ALL budget types?',
                        'options' => new List<String>{ 'yes', 'no' }
                    });
                } else {  allBudgetAccess = parseBool(rawBudget);

                    if (!allBudgetAccess    && cfg.Core_MDF_Budget_Required_When_False__c
                        && shouldCollectBudgetType(program, cfg)) { geoBudgetType = resolveGeoBudgetType(p, geo,  userQuery,  cfg.Core_MDF_Geo_Budget_Mapping__c,validationErrors
                        );

                        if (String.isBlank(geoBudgetType)) {
                            // Can only show per-region options if geo is already known.
                            // If geo is still missing (in missingFields), ask geo first -
                            // budget options depend on which regions were selected.
                            Boolean geoAlreadyMissing = false;
                            for (Map<String, Object> mf : missingFields) {
                                if (mf.get('field') == 'geo') {
                                    geoAlreadyMissing = true; break;
                                }
                            }

                            if (!geoAlreadyMissing && geo != null) {
                                // Build combined budget options across all requested regions.
                                // Single prompt instead of per-region so chatbot asks once
                                // and selected types apply to ALL regions (cross-product).
                                Set<String> combinedOptionsSet = new Set<String>();List<String> regionList = new List<String>(); Map<String, List<String>> allowed = parseGeoBudgetJson(cfg.Core_MDF_Geo_Budget_Mapping__c); if (allowed != null) { for (String r : geo.split(';')) { String rTrim = normalizeRegionKey(r); regionList.add(rTrim);  if (allowed.containsKey(rTrim)) { combinedOptionsSet.addAll(allowed.get(rTrim));
                                        }
                                    }
                                }
                                List<String> combinedOptions = new List<String>(combinedOptionsSet);combinedOptions.sort();String regionsSummary = String.join(regionList, ', '); missingFields.add(new Map<String, Object>{
                                    'field'    => 'geoBudgetSelections',
                                    'label'    => 'Budget Type per Region',
                                    'type'     => 'geo_budget_selection',
                                    'prompt'   => 'Please select the budget type(s) for '
                                        + userName + '. Selected types will apply to ALL regions ('
                                        + regionsSummary + '). You may select multiple:',
                                    'options'  => combinedOptions,
                                    'regions'  => regionList
                                });
                            }
                            // If geo is missing - geo missingField already added above,
                            // chatbot will ask for geo first, then next call returns budget prompts
                        } else {
                            // Validate the resolved geoBudgetType string
                            List<String> budgetErrors = validateGeoBudgetEntries( geoBudgetType, cfg.Core_MDF_Geo_Budget_Mapping__c);
                            if (!budgetErrors.isEmpty()) {   validationErrors.addAll(budgetErrors);
                            }
                        }
                    }
                }
            }

            // â”€â”€ 6e: Approval Region (IPA Price Reviewer only) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            String approvalRegion = null;

            if (cfg.Core_MDF_Approval_Region_Required__c) {
                approvalRegion = str(p, 'approvalRegion');

                // Approval region must be within the selected geo(s)
                // e.g. if geo=PRC, user can only approve for PRC
                String effectiveAROptions;
                if (geo != null) {
                    // Intersect MDT options with the selected geo values
                    Set<String> mdtOptions = new Set<String>();
                    String arOptionsSrc = String.isNotBlank(cfg.Core_MDF_Approval_Region_Options__c)
                        ? cfg.Core_MDF_Approval_Region_Options__c
                        : 'APJ;ASMO;EMEA;PRC;WW';
                    for (String r : arOptionsSrc.split(';')) mdtOptions.add(r.trim());

                    List<String> geoList = new List<String>();
                    for (String g : geo.split(';')) {
                        if (mdtOptions.contains(g.trim())) geoList.add(g.trim());
                    }
                    effectiveAROptions = geoList.isEmpty()
                        ? arOptionsSrc : String.join(geoList, ';');
                } else {
                    effectiveAROptions = String.isNotBlank(cfg.Core_MDF_Approval_Region_Options__c)
                        ? cfg.Core_MDF_Approval_Region_Options__c
                        : 'APJ;ASMO;EMEA;PRC;WW';
                }

                if (String.isBlank(approvalRegion)) {
                    missingFields.add(new Map<String, Object>{
                        'field'   => 'approvalRegion',
                        'label'   => 'Approval Region',
                        'type'    => 'multiselect',
                        'prompt'  => 'Which approval region(s) should '
                            + userName + ' be responsible for?',
                        'options' => effectiveAROptions.split(';')
                    });
                } else {
                    // Validate against effective options (geo-restricted)
                    Set<String> validAR = new Set<String>();
                    for (String r : effectiveAROptions.split(';')) validAR.add(r.trim());
                    List<String> badAR = new List<String>();
                    for (String r : approvalRegion.split(';')) {
                        if (!validAR.contains(r.trim())) badAR.add(r.trim());
                    }
                    if (!badAR.isEmpty()) {
                        validationErrors.add('Invalid approval region(s): ['
                            + String.join(badAR, ', ') + ']. '
                            + 'For the selected region(s) [' + geo + '], '
                            + 'approval region must be one of: '
                            + effectiveAROptions.replace(';', ', '));
                    }
                }
            }

            // â”€â”€ 6f: Activity Classification (IPA L2 Approver only) â”€â”€â”€â”€â”€â”€â”€â”€â”€
            String activityClassification = null;

            if (cfg.Core_MDF_Activity_Classification_Req__c) {
                activityClassification = str(p, 'activityClassification');
                if (String.isBlank(activityClassification)) {
                    missingFields.add(new Map<String, Object>{
                        'field'   => 'activityClassification',
                        'label'   => 'Activity Classification',
                        'type'    => 'multiselect',
                        'prompt'  => 'Should ' + userName
                            + ' be a Marketing approver, Sales approver, or both?',
                        'options' => new List<String>{
                            'Marketing', 'Sales', 'Marketing;Sales'
                        }
                    });
                } else {
                    Set<String> validAC = new Set<String>{ 'Marketing', 'Sales' };
                    List<String> badAC  = new List<String>();
                    for (String v : activityClassification.split(';')) {
                        if (!validAC.contains(v.trim())) badAC.add(v.trim());
                    }
                    if (!badAC.isEmpty()) {
                        validationErrors.add('Invalid activityClassification ['
                            + String.join(badAC, ', ') + ']. '
                            + 'Valid: Marketing, Sales');
                    }
                }
            }

            // AGS approver comments are optional for this workflow. Do not force
            // a missing-field prompt when the user leaves them blank or sends
            // "none" to skip. This is especially important for the bootstrap
            // "Core Access" new-user flow where AGS approval is triggered even
            // without a Salesforce User record.
            // Intentionally keep the field available for optional capture, but do
            // not convert it into a required validation blocker.

            if (!validationErrors.isEmpty()) {
                res.statusCode = 400;
                return JSON.serialize(new Map<String, Object>{
                    'success'       => false,
                    'message'       => 'Validation failed. Please review all issues.',
                    'errors'        => validationErrors,
                    'needsInput'    => !missingFields.isEmpty(),
                    'missingFields' => missingFields
                });
            }

            /*
            ================================================================
            STEP 7 - RETURN MISSING FIELDS IF ANY
            Return ALL at once - chatbot collects all in one go.
            ================================================================
            */
            if (!missingFields.isEmpty()) {
                res.statusCode = 206;
                List<String> fieldLabels = new List<String>();
                for (Map<String, Object> mf : missingFields) {
                    fieldLabels.add((String) mf.get('label'));
                }
                
                // Build partial requestSummary even though some fields are missing.
                // Chatbot will return this with the new fields filled in, and SubmitAPI
                // can use it to create the staging record without re-validation.
                List<String> resolvedAgsRoles = resolveAgsRoles(
                    cfg.Core_MDF_Region_AGS_Role_Map__c,
                    geo,
                    cfg.Core_MDF_AGS_Role_Name__c
                );
                String resolvedAgsRoleName = String.join(resolvedAgsRoles, ';');
                
                Map<String, Object> partialRequestSummary = new Map<String, Object>{
                    'userId'               => userId,
                    'accountId'            => accountId,
                    'userName'             => userName,
                    'userEmail'            => userEmail,
                    'requestorEmail'       => requestorEmail,
                    'agsRoleComments'      => agsRoleComments,
                    'program'              => program,
                    'programAlias'         => (String.isNotBlank(programInput)
                                                  && deferredPrograms.isEmpty())
                                                  ? programInput.toUpperCase().trim()
                                                  : program,
                    'deferredPrograms'     => deferredPrograms,
                    'deferredUsers'        => deferredUsers,
                    'deferredRoles'        => deferredRoles,
                    'deferredRegions'      => deferredRegions,
                    'roleLabel'            => cfg.Core_MDF_Role_Label__c,
                    'permissionSetName'    => cfg.Core_MDF_Permission_Set_Name__c,
                    'agsRoleName'          => resolvedAgsRoleName,
                    'iupgmRoleName'        => cfg.Core_MDF_IUPGM_Role_Name__c,
                    'iupgmRequired'        => cfg.Core_MDF_IUPGM_Required__c
                };
                
                // Add optional fields if already resolved
                if (userId == null && String.isNotBlank(userEmail)) {partialRequestSummary.put('userNeedsCreation', true);partialRequestSummary.put('newUserEmail', userEmail); if (String.isNotBlank(newUserFullName)) { partialRequestSummary.put('newUserFullName', newUserFullName);
                    }  if (String.isNotBlank(newUserFederationId)) {partialRequestSummary.put('newUserFederationId', newUserFederationId);
                    }
                }
                
                if (cfg.Core_MDF_Account_Required__c && String.isNotBlank(resolvedAccountName)) {
                    partialRequestSummary.put('accountName', resolvedAccountName);partialRequestSummary.put('allAccountAccess', allAccountAccess);
                }
                
                if (geo != null) {
                    partialRequestSummary.put('geo', geo);
                }
                
                if (cfg.Core_MDF_All_Budget_Type_Available__c) {
                    partialRequestSummary.put('allBudgetAccess', allBudgetAccess); if (String.isNotBlank(geoBudgetType)) {
                        partialRequestSummary.put('geoBudgetType', geoBudgetType);
                    }
                }if (cfg.Core_MDF_Approval_Region_Required__c && String.isNotBlank(approvalRegion)) { partialRequestSummary.put('approvalRegion', approvalRegion);
                } if (cfg.Core_MDF_Activity_Classification_Req__c && String.isNotBlank(activityClassification)) {
                    partialRequestSummary.put('activityClassification', activityClassification);
                }  return JSON.serialize(new Map<String, Object>{
                    'success'          => false,
                    'needsInput'       => true,
                    'message'          => 'A few more details are needed to complete this request: '
                        + String.join(fieldLabels, ', ') + '.',
                    'requestSummary'   => partialRequestSummary,
                    'missingFields'    => missingFields,
                    'warnings'         => warnings
                });
            }

            /*
            ================================================================
            STEP 8 - EXISTING REQUEST CHECK
            ----------------------------------------------------------------
            Stop the user before a confirmation prompt is even shown when an
            equivalent request already exists for the same
            user + role + program + account + region + budget combination.

            The match is deliberately exact on the access combination: a
            request for a DIFFERENT region, account or budget type is a
            genuinely new request and must be allowed through.

            Errored requests are ignored on purpose - those need to be
            re-raised. Anything else is either already provisioned
            (Completed) or still moving through the pipeline (in progress).
            ================================================================
            */
            if (String.isNotBlank(userId)) {
                Map<String, Object> existing = findExistingRequest(
                    userId,
                    cfg.Core_MDF_Permission_Set_Name__c,
                    program,
                    accountId,
                    geo,
                    geoBudgetType,
                    allAccountAccess,
                    allBudgetAccess,
                    userName
                );
                if (existing != null) { res.statusCode = 200;  return JSON.serialize(existing);
                }
            }

            /*
            ================================================================
            STEP 9 - BUILD RESOLVED REQUEST SUMMARY
            This is what the chatbot shows the user for confirmation.
            Also sent back to submitRequest if user says YES.
            ================================================================
            */
            // Resolve AGS role(s). If the role config has a region -> AGS role
            // map, resolve one AGS role per selected region; otherwise fall
            // back to the single AGS role name. Stored ';'-separated.
            List<String> resolvedAgsRoles = resolveAgsRoles(
                cfg.Core_MDF_Region_AGS_Role_Map__c,
                geo,
                cfg.Core_MDF_AGS_Role_Name__c
            );
            String resolvedAgsRoleName = String.join(resolvedAgsRoles, ';');

            // BUILD REQUEST SUMMARY - ONLY INCLUDE FIELDS APPLICABLE TO THIS ROLE
            Map<String, Object> requestSummary = new Map<String, Object>{
                // Always include: resolved IDs (internal use) + core fields
                'userId'               => userId,
                'accountId'            => accountId,
                'userName'             => userName,
                'userEmail'            => userEmail,
                'requestorEmail'       => requestorEmail,  // human who raised request via chatbot
                'agsRoleComments'      => agsRoleComments,
                'program'              => program,
                // programAlias: use what caller sent; fall back to derived program name.
                // For multi-program input the alias is meaningless, so use the
                // resolved program that we are actually processing.
                'programAlias'         => (String.isNotBlank(programInput)
                                              && deferredPrograms.isEmpty())
                                              ? programInput.toUpperCase().trim()
                                              : program,
                'deferredPrograms'     => deferredPrograms,
                'deferredUsers'        => deferredUsers,
                'deferredRoles'        => deferredRoles,
                'deferredRegions'      => deferredRegions,
                'roleLabel'            => cfg.Core_MDF_Role_Label__c,
                // MDT-resolved technical values (always included)
                'permissionSetName'    => cfg.Core_MDF_Permission_Set_Name__c,
                'agsRoleName'          => resolvedAgsRoleName,
                'iupgmRoleName'        => cfg.Core_MDF_IUPGM_Role_Name__c,
                'iupgmRequired'        => cfg.Core_MDF_IUPGM_Required__c,
                // Request type (GRANT or REVOKE) - critical for distinguishing request operations
                'requestAction'        => isRevokeRequest ? 'REVOKE' : 'GRANT'
            };

            // Flag that the user doesn't exist in SF yet - SubmitAPI relaxes userId check
            if (userId == null && String.isNotBlank(userEmail)) {
                requestSummary.put('userNeedsCreation', true);
                requestSummary.put('newUserEmail', userEmail);
                if (String.isNotBlank(newUserFullName)) {
                    requestSummary.put('newUserFullName', newUserFullName);
                }
                if (String.isNotBlank(newUserFederationId)) {
                    requestSummary.put('newUserFederationId', newUserFederationId);
                }
            }

            // Conditionally include account field only if role requires it
            if (cfg.Core_MDF_Account_Required__c) {
                requestSummary.put('accountName', resolvedAccountName);
                requestSummary.put('allAccountAccess', allAccountAccess);
            }

            // Always include geo when it was resolved (covers both WW-only and region-optional roles)
            if (geo != null) {
                requestSummary.put('geo', geo);
            }

            // Conditionally include budget fields only if role supports budget
            if (cfg.Core_MDF_All_Budget_Type_Available__c) {
                requestSummary.put('allBudgetAccess', allBudgetAccess); if (String.isNotBlank(cfg.Core_MDF_Geo_Budget_Mapping__c)) {requestSummary.put('geoBudgetType', geoBudgetType);
                }
            }

            // Conditionally include approval region only if role requires it
            if (cfg.Core_MDF_Approval_Region_Required__c) {
                requestSummary.put('approvalRegion', approvalRegion);
            }

            // Conditionally include activity classification only if role requires it
            if (cfg.Core_MDF_Activity_Classification_Req__c) { requestSummary.put('activityClassification', activityClassification);
            }

            // Human-readable display lines - only include fields that apply to this role
            Map<String, Object> displaySummary = new Map<String, Object>{
                'User'    => userName + ' (' + userEmail + ')',
                'Program' => displayProgramLabel(program),
                'Role'    => cfg.Core_MDF_Role_Label__c
            };

            // Surface the collected Federation ID (Worldwide ID) for a brand-new
            // user so the requester can visually confirm it before submission -
            // this value is sent verbatim in the downstream AGS user-creation payload.
            if (userId == null && String.isNotBlank(newUserFederationId)) {
                displaySummary.put('Federation ID (Worldwide ID)', newUserFederationId);
            }

            if (cfg.Core_MDF_Account_Required__c) {
                displaySummary.put('Account Access',
                    allAccountAccess == true ? 'All Accounts' : 'Specific Account');
                if (allAccountAccess != true && resolvedAccountName != null) { displaySummary.put('Account', resolvedAccountName);
                }
            }

            if (!deferredPrograms.isEmpty()) {
                displaySummary.put('Multi-Program Notice',
                    'Only [' + program + '] is being processed in this request. '
                    + 'Please raise a separate request for ['
                    + String.join(deferredPrograms, ', ') + '].');
            }

            if (!deferredUsers.isEmpty()) {
                displaySummary.put('Multi-User Notice',
                    'Only [' + userInput + '] is being processed in this request. '
                    + 'Please raise a separate request for ['
                    + String.join(deferredUsers, ', ') + '].');
            }

            if (!deferredRoles.isEmpty()) {
                displaySummary.put('Multi-Role Notice',
                    'Only [' + cfg.Core_MDF_Role_Label__c + '] is being processed in this request. '
                    + 'Please raise a separate request for ['
                    + String.join(deferredRoles, ', ') + '].');
            }

            if (!deferredRegions.isEmpty()) {
                displaySummary.put('Multi-Region Notice', multiRegionNotice);
            }
            if (String.isNotBlank(agsRoleComments)) {
                displaySummary.put('Approver Comments', agsRoleComments);
            }

            if (geo != null) {
                displaySummary.put(pluralizeLabel('Region', 'Regions', geo), geo);
            }

            if (cfg.Core_MDF_All_Budget_Type_Available__c) { displaySummary.put('All Budget Type Access', allBudgetAccess == true ? 'Yes' : 'No');  if (allBudgetAccess != true && String.isNotBlank(geoBudgetType)) { displaySummary.put( pluralizeLabel('Budget Mapping', 'Budget Mappings', geoBudgetType), geoBudgetType);
                }
            }

            if (cfg.Core_MDF_Approval_Region_Required__c) {
                displaySummary.put('Approval Region',
                    approvalRegion != null ? approvalRegion : 'N/A');
            }

            if (cfg.Core_MDF_Activity_Classification_Req__c) { displaySummary.put('Activity Classification', activityClassification != null ? activityClassification : 'N/A');
            }


            /*
            ================================================================
            STEP 10 -” AUTO-SUBMIT (userConfirmed = true)
            Chatbot flow: once validation is complete, infer confirmation from
            the YES/confirm reply and create staging here without a separate
            submit API call.
            ================================================================
            */
            if (!userConfirmed
                && missingFields.isEmpty()
                && validationErrors.isEmpty()
                && isStartAffirmative(userQuery)) { userConfirmed = true;
            }

            if (userConfirmed == true) {
                  Core_MDF_IUPGM_Request_Staging__c staging = createStagingFromSummary(requestSummary); insert staging;   staging = [
                    SELECT Id, Name, Core_MDF_Request_Status_nm__c
                    FROM Core_MDF_IUPGM_Request_Staging__c
                    WHERE Id = :staging.Id LIMIT 1
                ];
                res.statusCode = 200;  return JSON.serialize(new Map<String, Object>{
                    'success'            => true,
                    'autoSubmitted'      => true,
                    'requestNumber'      => staging.Name,
                    'status'             => staging.Core_MDF_Request_Status_nm__c,
                    'requestSummary'     => requestSummary,
                    'displaySummary'     => displaySummary,
                    'warnings'           => warnings,
                    'notificationInfo'   => 'We\'ll notify you once the role has been provisioned. You can use this Request ID to track the status of your request.',
                    'message'            => 'Great! Your request for ' + cfg.Core_MDF_Role_Label__c
                        + ' has been submitted successfully.'
                });
            }

            res.statusCode = 200;
            return JSON.serialize(new Map<String, Object>{
                'success'            => true,
                'readyForSubmission' => true,
                'requestSummary'     => requestSummary,
                'displaySummary'     => displaySummary,
                'warnings'           => warnings,
                'confirmationPrompt' => 'Please review the details above. '
                    + 'Reply YES to submit the request, '
                    + 'or NO if you would like to modify anything.'
            });

    }
/******************************************************************************************************
    Method Name:        handleBulkValidate
    Description:       Validates users in bulk, resolves role/program inputs, and returns per-user request summaries or input prompts.
    Added By:           Ramapriya
    *******************************************************************************************************/
   
    /** Validates a bulk request payload and returns per-user request summaries. */
    @testVisible
    private static String handleBulkValidate(
        Map<String, Object> p,
        RestResponse res
    ) {
        // â”€â”€ 1. Parse and validate users array â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        List<Object> usersRaw;
        try {
            usersRaw = (List<Object>) p.get('users');
        } catch (Exception ex) {
            res.statusCode = 400;
            return err('"users" must be a JSON array of email strings.');
        }
        if (usersRaw == null || usersRaw.isEmpty()) {
            res.statusCode = 400;
            return err('"users" array is required and cannot be empty.');
        }
        if (usersRaw.size() > Core_MDF_CCP_ConstantClass.IUPGM_BULK_USER_LIMIT) {
            res.statusCode = 400;
            return err('Bulk request exceeds the maximum of '
                + Core_MDF_CCP_ConstantClass.IUPGM_BULK_USER_LIMIT + ' users per call. '
                + 'Split into smaller batches.');
        }

        // â”€â”€ 2. Resolve program (shared for all users) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        String programInput    = str(p, 'program');
        String roleInput       = str(p, 'roleLabel');
        String requestorEmail  = str(p, 'requestorEmail');
        String agsRoleComments = approverComments(p);
        Boolean userConfirmed  = parseBool(p.get('userConfirmed'));

        // Parse userQuery if explicit program/role not provided
        // Strip all user values from query before parsing so names/emails don't
        // pollute role/program detection
        String userQuery = str(p, 'userQuery');
        if (String.isNotBlank(userQuery)) {
            String queryForParsing = userQuery;
            for (Object uObj : usersRaw) {
                String uVal = String.valueOf(uObj).trim();
                if (String.isNotBlank(uVal)) {
                    queryForParsing = queryForParsing.replaceAll(
                        '(?i)' + uVal.replaceAll('\\.', '\\\\.'), ' ');
                }
            }
            Map<String, String> parsed = parseUserQuery(queryForParsing);
            if (String.isBlank(programInput) && parsed.get('program') != null) {
                programInput = parsed.get('program');
            }
            // NOTE: role label is deliberately NOT guessed from free-text userQuery
            // here - see ROLE RESOLUTION OWNERSHIP note in Step 3 below. Bulk
            // requests must supply an already-resolved, exact roleLabel (obtained
            // once via the AI Role Recommendation Agent and reused for all users).
        }
        // NOTE: userConfirmed from isAffirmativeConfirmation is applied only after
        // all fields are validated (in the per-user summary step), not here.

        List<String> baseErrors = new List<String>();
        if (String.isBlank(programInput) && String.isBlank(roleInput)) {
            baseErrors.add('Please provide a program, role, or userQuery '
                + 'so we can identify what access is being requested.');
        }
        if (!baseErrors.isEmpty()) {
            res.statusCode = 400;
            return JSON.serialize(new Map<String, Object>{
                'success' => false, 'errors' => baseErrors
            });
        }

        String program = String.isNotBlank(programInput) ? resolveProgram(programInput) : null;
        if (String.isNotBlank(programInput) && program == null) {
            res.statusCode = 400;
            return err('Invalid program [' + programInput
                + ']. Valid values: IPA, Client, Datacenter, RMF, Co-GTM');
        }

        // ── 3. Resolve role (EXACT METADATA LOOKUP ONLY) ────────────────────
        // Same ownership rule as the single-request path: handleBulkValidate
        // performs NO independent role search of its own. If roleLabel wasn't
        // explicitly supplied, ask the SAME AI Role Recommendation engine
        // (resolveRoleCandidates) to interpret userQuery ONCE for the whole
        // batch - the resolved role is then reused for every user, matching
        // the bulk design ("role recommendation should occur once for the
        // common use case, then reused for all users").
        if (String.isBlank(roleInput)) {
            if (String.isBlank(userQuery)) {
                res.statusCode = 400;
                return JSON.serialize(new Map<String, Object>{
                    'success'   => false,
                    'errorCode' => 'ROLE_NOT_PROVIDED',
                    'message'   => 'A resolved roleLabel is required for bulk requests. Please '
                        + 'resolve the requested role first via the AI Role Recommendation Agent '
                        + '(GET /access/recommendRole) and resend with the exact roleLabel it returns.'
                });
            }

            RoleResolutionOutcome roleOutcome = resolveRoleCandidates(userQuery, program);

            if (roleOutcome.found && roleOutcome.highConfidence
                    && String.isNotBlank(roleOutcome.resolvedRoleLabel)) {
                // MANDATORY ROLE CONFIRMATION GATE - same as the single-request path.
                res.statusCode = 200;
                return JSON.serialize(new Map<String, Object>{
                    'success'           => false,
                    'needsInput'        => true,
                    'needsConfirmation' => true,
                    'errorCode'         => 'ROLE_CONFIRMATION_REQUIRED',
                    'roleLabel'         => roleOutcome.resolvedRoleLabel,
                    'program'           => displayProgramLabel(roleOutcome.resolvedRoleProgram),
                    'reason'            => roleOutcome.resolvedRoleReason,
                    'message'           => buildRoleConfirmationMessage(
                        roleOutcome.resolvedRoleLabel, roleOutcome.resolvedRoleReason,
                        roleOutcome.resolvedRolePurpose)
                });

            } else if (roleOutcome.found && !roleOutcome.recommendations.isEmpty()) {
                // Ask as a forward-looking question - never echoes the original invalid
                // input. Confidence scores are NOT exposed to the user.
                List<String> roleNames = new List<String>(); List<Map<String, Object>> rolesDisplay = new List<Map<String, Object>>(); Integer idx = 1; for (Map<String, Object> rec : roleOutcome.recommendations) {String lbl = (String) rec.get('roleLabel');roleNames.add(lbl); rolesDisplay.add(new Map<String, Object>{
                        'index'   => idx,
                        'label'   => lbl,
                        'program' => rec.get('program'),
                        'purpose' => rec.get('purpose')
                    }); idx++;
                }
                res.statusCode = 300;return JSON.serialize(new Map<String, Object>{
                    'success'               => false,
                    'needsInput'            => true,
                    'selectRole'            => true,
                    'errorCode'             => 'ROLE_NEEDS_SELECTION',
                    'message'               => buildRoleOptionsQuestion(rolesDisplay, roleOutcome.clarificationQuestion),
                    'needsClarification'    => roleOutcome.needsClarification,
                    'clarificationQuestion' => roleOutcome.clarificationQuestion,
                    'roles'                 => roleNames,
                    'rolesDisplay'          => rolesDisplay
                });

            } else {
                res.statusCode = 400;
                return JSON.serialize(new Map<String, Object>{
                    'success'               => false,
                    'needsInput'            => true,
                    'errorCode'             => 'ROLE_NOT_FOUND',
                    'needsClarification'    => true,
                    'clarificationQuestion' => roleOutcome.clarificationQuestion,
                    'message'               => 'The system requires a specific role to proceed '
                        + 'with this bulk request. Kindly provide the required role.'
                        + (String.isNotBlank(roleOutcome.clarificationQuestion)
                            ? ' ' + roleOutcome.clarificationQuestion
                            : ' If you\'re unsure about the exact role, you can resolve it '
                                + 'by using the AI Role Recommendation Agent (GET /access/'
                                + 'recommendRole) or provide more details to help determine '
                                + 'the correct role.')
                });
            }
        }

        // Bounded self-correction: same as the single-request path - an
        // explicitly-given roleLabel might be a wrong guess from the caller's own
        // layer, not a genuinely non-existent role. Retry once against userQuery
        // if the exact lookup fails.
        Boolean triedQueryFallbackBulk = false;
        String  originalRoleInputForMessageBulk = roleInput;
        Core_MDF_IUPGM_Rule_Config__mdt cfg = null;

        while (cfg == null) {
            Set<String> programCandidates = program != null ? getProgramCandidates(program) : null;

            List<Core_MDF_IUPGM_Rule_Config__mdt> roleRecords = programCandidates != null
                ? [
                    SELECT  MasterLabel,
                            Core_MDF_Role_Label__c,
                            Core_MDF_Permission_Set_Name__c,
                            Core_MDF_AGS_Role_Name__c,
                            Core_MDF_Region_AGS_Role_Map__c,
                            Core_MDF_IUPGM_Role_Name__c,
                            Core_MDF_IUPGM_Required__c,
                            Core_MDF_Program__c,
                            Core_MDF_All_Accounts__c,
                            Core_MDF_Account_Required__c,
                            Core_MDF_Region_Options__c,
                            Core_MDF_WW_Only__c,
                            Core_MDF_All_Budget_Type_Available__c,
                            Core_MDF_Budget_Required_When_False__c,
                            Core_MDF_Geo_Budget_Mapping__c,
                            Core_MDF_Approval_Region_Required__c,
                            Core_MDF_Approval_Region_Options__c,
                            Core_MDF_Activity_Classification_Req__c,
                            Core_MDF_Skip_PS_Check__c,
                            Core_MDF_Is_Active__c,
                            Core_MDF_Role_Purpose__c
                    FROM Core_MDF_IUPGM_Rule_Config__mdt
                    WHERE Core_MDF_Role_Label__c = :roleInput
                      AND Core_MDF_Program__c    IN :programCandidates
                      AND Core_MDF_Is_Active__c  = true
                  ]
                : [
                    SELECT  MasterLabel,
                            Core_MDF_Role_Label__c,
                            Core_MDF_Permission_Set_Name__c,
                            Core_MDF_AGS_Role_Name__c,
                            Core_MDF_Region_AGS_Role_Map__c,
                            Core_MDF_IUPGM_Role_Name__c,
                            Core_MDF_IUPGM_Required__c,
                            Core_MDF_Program__c,
                            Core_MDF_All_Accounts__c,
                            Core_MDF_Account_Required__c,
                            Core_MDF_Region_Options__c,
                            Core_MDF_WW_Only__c,
                            Core_MDF_All_Budget_Type_Available__c,
                            Core_MDF_Budget_Required_When_False__c,
                            Core_MDF_Geo_Budget_Mapping__c,
                            Core_MDF_Approval_Region_Required__c,
                            Core_MDF_Approval_Region_Options__c,
                            Core_MDF_Activity_Classification_Req__c,
                            Core_MDF_Skip_PS_Check__c,
                            Core_MDF_Is_Active__c,
                            Core_MDF_Role_Purpose__c
                    FROM Core_MDF_IUPGM_Rule_Config__mdt
                    WHERE Core_MDF_Role_Label__c = :roleInput
                      AND Core_MDF_Is_Active__c  = true
                  ];

            if (program != null && !roleRecords.isEmpty()) {     roleRecords = collapseRoleRecordsForProgram(roleRecords, program);
            }

            if (roleRecords.isEmpty()) {
                // Try treating the input as an AGS role name instead of the internal
                // role label - a SEPARATE query, since Custom Metadata Type SOQL does
                // not support OR/disjunctions combined with other filters.
                roleRecords = programCandidates != null
                    ? [
                        SELECT  MasterLabel,
                                Core_MDF_Role_Label__c,
                                Core_MDF_Permission_Set_Name__c,
                                Core_MDF_AGS_Role_Name__c,
                                Core_MDF_Region_AGS_Role_Map__c,
                                Core_MDF_IUPGM_Role_Name__c,
                                Core_MDF_IUPGM_Required__c,
                                Core_MDF_Program__c,
                                Core_MDF_All_Accounts__c,
                                Core_MDF_Account_Required__c,
                                Core_MDF_Region_Options__c,
                                Core_MDF_WW_Only__c,
                                Core_MDF_All_Budget_Type_Available__c,
                                Core_MDF_Budget_Required_When_False__c,
                                Core_MDF_Geo_Budget_Mapping__c,
                                Core_MDF_Approval_Region_Required__c,
                                Core_MDF_Approval_Region_Options__c,
                                Core_MDF_Activity_Classification_Req__c,
                                Core_MDF_Skip_PS_Check__c,
                                Core_MDF_Is_Active__c,
                                Core_MDF_Role_Purpose__c
                        FROM Core_MDF_IUPGM_Rule_Config__mdt
                        WHERE Core_MDF_AGS_Role_Name__c = :roleInput
                          AND Core_MDF_Program__c    IN :programCandidates
                          AND Core_MDF_Is_Active__c  = true
                      ]
                    : [
                        SELECT  MasterLabel,
                                Core_MDF_Role_Label__c,
                                Core_MDF_Permission_Set_Name__c,
                                Core_MDF_AGS_Role_Name__c,
                                Core_MDF_Region_AGS_Role_Map__c,
                                Core_MDF_IUPGM_Role_Name__c,
                                Core_MDF_IUPGM_Required__c,
                                Core_MDF_Program__c,
                                Core_MDF_All_Accounts__c,
                                Core_MDF_Account_Required__c,
                                Core_MDF_Region_Options__c,
                                Core_MDF_WW_Only__c,
                                Core_MDF_All_Budget_Type_Available__c,
                                Core_MDF_Budget_Required_When_False__c,
                                Core_MDF_Geo_Budget_Mapping__c,
                                Core_MDF_Approval_Region_Required__c,
                                Core_MDF_Approval_Region_Options__c,
                                Core_MDF_Activity_Classification_Req__c,
                                Core_MDF_Skip_PS_Check__c,
                                Core_MDF_Is_Active__c,
                                Core_MDF_Role_Purpose__c
                        FROM Core_MDF_IUPGM_Rule_Config__mdt
                        WHERE Core_MDF_AGS_Role_Name__c = :roleInput
                          AND Core_MDF_Is_Active__c  = true
                      ];
                if (program != null && !roleRecords.isEmpty()) {       roleRecords = collapseRoleRecordsForProgram(roleRecords, program);
                }
            }

            if (roleRecords.isEmpty()) {
                // Same fallback-text fix as the single-request path: use userQuery
                // when present, otherwise fall back to the roleLabel the caller
                // actually typed so a misspelled/partial/AGS-role-name input still
                // gets a suggestion attempt instead of a hard failure.
                String fallbackQueryTextBulk = String.isNotBlank(userQuery)
                    ? userQuery : originalRoleInputForMessageBulk;
                if (!triedQueryFallbackBulk && String.isNotBlank(fallbackQueryTextBulk)) {
                    triedQueryFallbackBulk = true;
                    RoleResolutionOutcome fallbackOutcome = resolveRoleCandidates(fallbackQueryTextBulk, program);

                    if (fallbackOutcome.found && fallbackOutcome.highConfidence
                            && String.isNotBlank(fallbackOutcome.resolvedRoleLabel)) {
                        // MANDATORY ROLE CONFIRMATION GATE - same as the single-request path.
                        res.statusCode = 200;
                        return JSON.serialize(new Map<String, Object>{
                            'success'           => false,
                            'needsInput'        => true,
                            'needsConfirmation' => true,
                            'errorCode'         => 'ROLE_CONFIRMATION_REQUIRED',
                            'roleLabel'         => fallbackOutcome.resolvedRoleLabel,
                            'program'           => displayProgramLabel(fallbackOutcome.resolvedRoleProgram),
                            'reason'            => fallbackOutcome.resolvedRoleReason,
                            'message'           => buildRoleConfirmationMessage(
                                fallbackOutcome.resolvedRoleLabel, fallbackOutcome.resolvedRoleReason,
                                fallbackOutcome.resolvedRolePurpose)
                        });

                    } else if (fallbackOutcome.found && !fallbackOutcome.recommendations.isEmpty()) {
                        // Ask as a forward-looking question - never echoes the original
                        // invalid input. Confidence scores are NOT exposed to the user.
                        List<String> roleNames = new List<String>();
                        List<Map<String, Object>> rolesDisplay = new List<Map<String, Object>>();
                        Integer idx = 1;
                        for (Map<String, Object> rec : fallbackOutcome.recommendations) {
                            String lbl = (String) rec.get('roleLabel');
                            roleNames.add(lbl);
                            rolesDisplay.add(new Map<String, Object>{
                                'index'   => idx,
                                'label'   => lbl,
                                'program' => rec.get('program'),
                                'purpose' => rec.get('purpose')
                            });
                            idx++;
                        }
                        res.statusCode = 300;
                        return JSON.serialize(new Map<String, Object>{
                            'success'               => false,
                            'needsInput'            => true,
                            'selectRole'            => true,
                            'errorCode'             => 'ROLE_NEEDS_SELECTION',
                            'message'               => buildRoleOptionsQuestion(rolesDisplay, fallbackOutcome.clarificationQuestion),
                            'needsClarification'    => fallbackOutcome.needsClarification,
                            'clarificationQuestion' => fallbackOutcome.clarificationQuestion,
                            'roles'                 => roleNames,
                            'rolesDisplay'          => rolesDisplay
                        });
                    }
                    // else: AI engine also found nothing confident - fall through to hard fail below.
                }

                res.statusCode = 400;
                return JSON.serialize(new Map<String, Object>{
                    'success'   => false,
                    'errorCode' => 'ROLE_NOT_FOUND',
                    'message'   => 'Role "' + originalRoleInputForMessageBulk + '"'
                        + (program != null
                            ? ' was not found in program [' + programInput + ']'
                            : ' was not found')
                        + ' in the active Role Configuration. Please resolve it via the AI Role '
                        + 'Recommendation Agent (GET /access/recommendRole) instead of resending '
                        + 'a different spelling.'
                });
            } else if (roleRecords.size() > 1) {
                // Same exact Role Label active in more than one program - deterministic
                // required-field gap (which program?), not a role search.
                List<String> programOptions = new List<String>(); for (Core_MDF_IUPGM_Rule_Config__mdt r : roleRecords) { String pLabel = displayProgramLabel(r.Core_MDF_Program__c);  if (!programOptions.contains(pLabel)) programOptions.add(pLabel);
                }
                res.statusCode = 300;  return JSON.serialize(new Map<String, Object>{
                    'success'        => false,
                    'needsInput'     => true,
                    'errorCode'      => 'ROLE_AMBIGUOUS_PROGRAM',
                    'message'        => 'The role "' + roleInput + '" is active in multiple programs. '
                        + 'Please specify which program: ' + String.join(programOptions, ', '),
                    'programOptions' => programOptions
                });
            } else { cfg = roleRecords[0];
            }
        }

        // â”€â”€ 4. Resolve common fields (geo, account, budget, approval region, etc.)
        List<Map<String, Object>> missingFields = new List<Map<String, Object>>();List<String> validationErrors           = new List<String>();

        // All Account Access
        Boolean allAccountAccess = null;String  allAccOpt        = cfg.Core_MDF_All_Accounts__c;  if (!cfg.Core_MDF_Account_Required__c) {
            // Account access is not applicable to this role at all - never ask.
            allAccountAccess = true;
        } else if (allAccOpt == 'YES_ONLY') { allAccountAccess = true; } else if (allAccOpt == 'NO_ONLY')  { allAccountAccess = false; }
        else {
            Object raw = p.get('allAccountAccess'); if (raw == null) {
                String inferredAccountName = str(p, 'accountName');  if (String.isNotBlank(inferredAccountName)) { allAccountAccess = false;
                } else { missingFields.add(new Map<String, Object>{
                        'field'   => 'allAccountAccess', 'type' => 'boolean',
                        'label'   => 'All Account Access',
                        'prompt'  => 'Should users have access to ALL accounts or a specific account?',
                        'options' => new List<String>{ 'all', 'specific' }
                    });
                }
            } else { allAccountAccess = parseBool(raw); }
        }

        // Account
        String resolvedAccountName = null;   Id     accountId           = null; Boolean accountWillBeNeeded =
            (allAccOpt == 'NO_ONLY')
            || (allAccOpt == 'YES_NO' && allAccountAccess == false);
        if (accountWillBeNeeded && cfg.Core_MDF_Account_Required__c) { String accountName = str(p, 'accountName'); if (String.isBlank(accountName)) {
                missingFields.add(new Map<String, Object>{
                    'field' => 'accountName', 'type' => 'lookup',
                    'label' => 'Account',
                    'prompt' => 'Please provide the Account Name or Unified ID.'
                });
            } else {
                // Same Ultimate Account scope rule as the single-request path:
                // only RMF may resolve to a node / sub-node (Virtual Corp) account,
                // and for RMF the Ultimate Account itself must NOT be selectable.
                Boolean nodeAllowed = isNodeLevelAllowed(program); String  nameBind    = accountName; String  selectClause = 'SELECT Id, Name, '
                    + 'Core_Business_Party_Id__c, '
                    + 'Core_MDF_CoMarketing_Ultimate_Account__c, '
                    + 'Core_MDF_CoMarketing_Ultimate_Account__r.Name '
                    + 'FROM Account WHERE ';
                String scopeFilter = nodeAllowed
                    ? ' AND Core_MDF_CoMarketing_Ultimate_Account__c != null'
                    : ' AND Core_MDF_CoMarketing_Ultimate_Account__c = null'; String unifiedIdBind = extractUnifiedIdFromAccountInput(accountName); List<Account> accts = Database.query(
                    selectClause + 'Name = :nameBind' + scopeFilter + ' LIMIT 2'
                );

                // Accept Unified ID as accountName input.
                if (accts.isEmpty()) { accts = Database.query(
                        selectClause + 'Core_Business_Party_Id__c = :nameBind'
                        + scopeFilter + ' LIMIT 2'
                    );
                }

                // Accept the display format "Marvel (12345)" as input.
                if (accts.isEmpty() && String.isNotBlank(unifiedIdBind)) {   accts = Database.query(
                        selectClause + 'Core_Business_Party_Id__c = :unifiedIdBind'
                        + scopeFilter + ' LIMIT 2'
                    );
                }

                if (accts.isEmpty() && nodeAllowed) { accts = Database.query(
                        selectClause
                        + 'Core_MDF_CoMarketing_Ultimate_Account__r.Name = :nameBind'
                        + ' LIMIT 2'
                    );
                }

                if (accts.isEmpty() && String.isBlank(unifiedIdBind)) { String likeBind = '%' + accountName + '%';
                    accts = Database.query(
                        selectClause + 'Name LIKE :likeBind' + scopeFilter + ' LIMIT 5'
                    );
                }

                if (accts.isEmpty()) {  if (nodeAllowed && isUltimateAccountName(accountName)) {
                        validationErrors.add('"' + accountName + '" is an Ultimate Account. '
                            + 'RMF requires a specific node/sub-node (Virtual Corp) account - '
                            + 'please provide the child account name under "' + accountName
                            + '" instead of the Ultimate Account itself.');
                    } else { validationErrors.add('No account found for [' + accountName + '].');
                    }
                } else if (accts.size() > 1) { List<String> names = new List<String>();for (Account a : accts) {
                        names.add(buildAccountDisplayName(a, nodeAllowed));
                    }
                    res.statusCode = 300; return JSON.serialize(new Map<String, Object>{
                        'success' => false, 'needsInput' => true,
                        'multipleAccounts' => true,
                        'accounts' => names
                    });
                } else {
                    accountId           = accts[0].Id; resolvedAccountName = String.isNotBlank(accts[0].Name)
                        ? accts[0].Name
                        : accts[0].Core_MDF_CoMarketing_Ultimate_Account__r.Name;
                }
            }
        }

        // Region (geo)
        String geo = null;  if (cfg.Core_MDF_WW_Only__c) {
            geo = 'WW';
        } else if (!cfg.Core_MDF_IUPGM_Required__c
                   && String.isBlank(cfg.Core_MDF_Region_AGS_Role_Map__c)) {
            // Generic AGS-only role - region not applicable, never ask.
            geo = null;
        } else {  geo = normalizeGeoString(str(p, 'geo')); if (String.isBlank(geo)) {
                String opts = String.isNotBlank(cfg.Core_MDF_Region_Options__c)
                    ? cfg.Core_MDF_Region_Options__c.replace(';', ', ')
                    : 'APJ, ASMO, EMEA, PRC, WW';
                missingFields.add(new Map<String, Object>{
                    'field'   => 'geo', 'type' => 'picklist', 'label' => 'Region',
                    'prompt'  => 'Which region(s) should users have access to?',
                    'options' => opts.split(', ')
                });
            } else if (String.isNotBlank(cfg.Core_MDF_Region_Options__c)) { Set<String> validGeos = new Set<String>(); for (String r : cfg.Core_MDF_Region_Options__c.split(';')) {  validGeos.add(normalizeRegionKey(r));
                }
                for (String r : geo.split(';')) { String regionKey = normalizeRegionKey(r); if (!validGeos.contains(regionKey)) {
                        validationErrors.add('Invalid region [' + regionKey + ']. '
                            + 'Valid: ' + cfg.Core_MDF_Region_Options__c.replace(';',', '));
                    }
                }
            }
        }

        // Restrict multi-region for region-specific-AGS-role roles (bulk).
        // Same reason as single-user path: Core_MDF_Region_AGS_Role_Map__c roles
        // resolve a different AGS role per region, and AGS status polling only
        // reads the first requestItem - so only one region can be requested at
        // a time. Region is shared across the whole bulk batch, so this applies
        // once for all users in this call.
        String bulkRegionNotice = null;  List<String> bulkDeferredRegions = new List<String>(); if (String.isNotBlank(geo)
            && String.isNotBlank(cfg.Core_MDF_Region_AGS_Role_Map__c)) { List<String> allRegionsForAgsBulk = geo.split(';'); if (allRegionsForAgsBulk.size() > 1) {
                String firstRegionForAgsBulk = allRegionsForAgsBulk[0]; for (Integer i = 1; i < allRegionsForAgsBulk.size(); i++) {
                    bulkDeferredRegions.add(allRegionsForAgsBulk[i]);
                }
                geo = firstRegionForAgsBulk;  bulkRegionNotice = cfg.Core_MDF_Role_Label__c
                    + ' resolves to a different AGS role per region, so only one '
                    + 'region can be requested at a time. Continuing with ['
                    + firstRegionForAgsBulk + '] for this batch - please raise a '
                    + 'separate request for [' + String.join(bulkDeferredRegions, ', ') + '].';
            }
        }

        // Budget
        Boolean allBudgetAccess = null;   String  geoBudgetType   = null;  if (cfg.Core_MDF_All_Budget_Type_Available__c) {
            Object rawBudget = p.get('allBudgetAccess');  if (rawBudget == null) {
                missingFields.add(new Map<String, Object>{
                    'field'   => 'allBudgetAccess', 'type' => 'boolean',
                    'label'   => 'All Budget Type Access',
                    'prompt'  => 'Should users have access to ALL budget types?',
                    'options' => new List<String>{ 'yes', 'no' }
                });
            } else {  allBudgetAccess = parseBool(rawBudget); if (!allBudgetAccess
                    && cfg.Core_MDF_Budget_Required_When_False__c
                    && shouldCollectBudgetType(program, cfg)) {

                    geoBudgetType = resolveGeoBudgetType( p,  geo,  userQuery, cfg.Core_MDF_Geo_Budget_Mapping__c, validationErrors );

                    if (String.isBlank(geoBudgetType)) {  Boolean geoAlreadyMissing = false;  for (Map<String, Object> mf : missingFields) { if (mf.get('field') == 'geo') { geoAlreadyMissing = true; break; }
                        }
                        if (!geoAlreadyMissing && geo != null) { Set<String> combinedOptionsSet = new Set<String>(); List<String> regionList = new List<String>();Map<String, List<String>> allowed =
                                parseGeoBudgetJson(cfg.Core_MDF_Geo_Budget_Mapping__c); if (allowed != null) { for (String r : geo.split(';')) {
                                    String rTrim = normalizeRegionKey(r);  regionList.add(rTrim);   if (allowed.containsKey(rTrim)) {
                                        combinedOptionsSet.addAll(allowed.get(rTrim));
                                    }
                                }
                            }
                            List<String> combinedOptions = new List<String>(combinedOptionsSet);  combinedOptions.sort(); String regionsSummary = String.join(regionList, ', ');  missingFields.add(new Map<String, Object>{
                                'field'    => 'geoBudgetSelections',
                                'label'    => 'Budget Type per Region',
                                'type'     => 'geo_budget_selection',
                                'prompt'   => 'Please select the budget type(s). Selected types will apply to ALL regions ('
                                    + regionsSummary + '). You may select multiple:',
                                'options'  => combinedOptions,
                                'regions'  => regionList
                            });
                        }
                        // else: geo missing - geo prompt already added, ask budget next round
                    } else {  List<String> budgetErrors = validateGeoBudgetEntries(   geoBudgetType, cfg.Core_MDF_Geo_Budget_Mapping__c);  validationErrors.addAll(budgetErrors);
                    }
                }
            }
        }

        // Approval Region
        String approvalRegion = null;     if (cfg.Core_MDF_Approval_Region_Required__c) { approvalRegion = str(p, 'approvalRegion');
            if (String.isBlank(approvalRegion)) {  missingFields.add(new Map<String, Object>{
                    'field'   => 'approvalRegion', 'type' => 'multiselect',
                    'label'   => 'Approval Region',
                    'prompt'  => 'Which approval region(s) should users cover?',
                    'options' => (String.isNotBlank(cfg.Core_MDF_Approval_Region_Options__c)
                        ? cfg.Core_MDF_Approval_Region_Options__c
                        : 'APJ;ASMO;EMEA;PRC;WW').split(';')
                });
            }
        }

        // Activity Classification
        String activityClassification = null;  if (cfg.Core_MDF_Activity_Classification_Req__c) {
            activityClassification = str(p, 'activityClassification'); if (String.isBlank(activityClassification)) {
                missingFields.add(new Map<String, Object>{
                    'field'   => 'activityClassification', 'type' => 'multiselect',
                    'label'   => 'Activity Classification',
                    'prompt'  => 'Marketing approver, Sales approver, or both?',
                    'options' => new List<String>{ 'Marketing', 'Sales', 'Marketing;Sales' }
                });
            }
        }

        // Abort if common fields have validation errors
        if (!validationErrors.isEmpty()) { res.statusCode = 400;  return JSON.serialize(new Map<String, Object>{
                'success' => false, 'bulkMode' => true,
                'message' => 'Common field validation failed.',
                'errors'  => validationErrors
            });
        }
        // Return missing fields prompt (same as single-user path)
        if (!missingFields.isEmpty()) {   List<String> fieldLabels = new List<String>(); for (Map<String, Object> mf : missingFields) {fieldLabels.add((String) mf.get('label'));
            } res.statusCode = 206;   return JSON.serialize(new Map<String, Object>{
                'success'       => false, 'bulkMode' => true,
                'needsInput'    => true,
                'message'       => 'A few more details are needed for this bulk request: '
                    + String.join(fieldLabels, ', ') + '.',
                'missingFields' => missingFields
            });
        }

        // â”€â”€ 5. Resolve AGS roles (shared) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        List<String> resolvedAgsRoles = resolveAgsRoles(
            cfg.Core_MDF_Region_AGS_Role_Map__c,
            geo,
            cfg.Core_MDF_AGS_Role_Name__c
        );
        String resolvedAgsRoleName = String.join(resolvedAgsRoles, ';');

        // â”€â”€ 6. Bulk user resolution (email exact + name fuzzy) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        List<String> emailInputs = new List<String>();
        List<String> nameInputs  = new List<String>();
        for (Object uObj : usersRaw) {
            String inp = String.valueOf(uObj).trim();
            if (String.isNotBlank(inp)) {
                if (inp.contains('@')) emailInputs.add(inp.toLowerCase());
                else                   nameInputs.add(inp);
            }
        }

        // Unified map: lowercased input â†’ resolved User
        Map<String, User>         userByInput   = new Map<String, User>();
        // Ambiguous name inputs (multiple matches) â†’ list of display strings for chatbot
        Map<String, List<String>> nameAmbiguous = new Map<String, List<String>>();

        // Email bulk lookup (1 SOQL)
        if (!emailInputs.isEmpty()) {
            for (User u : [
                SELECT Id, Name, Email, IsActive
                FROM User
                WHERE Email IN :emailInputs
                  AND IsActive = true
            ]) {
                userByInput.put(u.Email.toLowerCase(), u);
            }
        }

        // Name lookup - one dynamic SOQL with OR clauses (no per-name queries)
        if (!nameInputs.isEmpty()) {
            List<String> clauses = new List<String>();
            for (String nm : nameInputs) {
                clauses.add('Name LIKE \'%' + String.escapeSingleQuotes(nm) + '%\'');
            }
            String nameFilter = String.join(clauses, ' OR ');
            List<User> nameUsers = Database.query(
                'SELECT Id, Name, Email FROM User WHERE IsActive = true AND ('
                + nameFilter + ') LIMIT 100'
            );
            // Group results by which name input they match
            Map<String, List<User>> matchesByName = new Map<String, List<User>>();
            for (String nm : nameInputs) matchesByName.put(nm.toLowerCase(), new List<User>());
            for (User u : nameUsers) {
                String uNameLower = u.Name.toLowerCase();
                for (String nm : nameInputs) {
                    if (uNameLower.contains(nm.toLowerCase())) {
                        matchesByName.get(nm.toLowerCase()).add(u);
                    }
                }
            }
            for (String nm : nameInputs) {
                List<User> matches = matchesByName.get(nm.toLowerCase());
                if (matches.size() == 1) {
                    userByInput.put(nm.toLowerCase(), matches[0]);
                } else if (matches.size() > 1) {
                    List<String> opts = new List<String>();
                    for (User u : matches) opts.add(u.Name + ' (' + u.Email + ')');
                    nameAmbiguous.put(nm.toLowerCase(), opts);
                }
                // size == 0: no entry â†’ "not found" error surfaced in per-user loop
            }
        }

        // â”€â”€ 7. Bulk duplicate check (ONE SOQL) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Set<Id> resolvedUserIds = new Set<Id>();
        for (User u : userByInput.values()) resolvedUserIds.add(u.Id);

        Map<Id, Core_MDF_IUPGM_Request_Staging__c> inflightByUser =
            new Map<Id, Core_MDF_IUPGM_Request_Staging__c>();
        if (!resolvedUserIds.isEmpty()) {
            for (Core_MDF_IUPGM_Request_Staging__c stg : [
                SELECT Core_MDF_IUPGM_User__c, Name,
                       Core_MDF_Request_Status_nm__c
                FROM Core_MDF_IUPGM_Request_Staging__c
                WHERE Core_MDF_IUPGM_User__c    IN :resolvedUserIds
                  AND Core_MDF_IUPGM_Role_nm__c  = :cfg.Core_MDF_Permission_Set_Name__c
                  AND Core_MDF_IUPGM_Program__c  = :program
                  AND Core_MDF_Is_IUPGM_Processed__c = false
                  AND Core_MDF_Request_Status_nm__c NOT IN
                      :Core_MDF_CCP_ConstantClass.IUPGM_NON_ACTIVE_STATUSES
            ]) {
                inflightByUser.put(stg.Core_MDF_IUPGM_User__c, stg);
            }
        }

        // â”€â”€ 8. Build per-user results â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        Integer readyCount     = 0;
        Integer duplicateCount = 0;
        Integer failedCount    = 0;

        for (Object uObj : usersRaw) {
            String rawInput  = String.valueOf(uObj).trim();
            String inputKey  = rawInput.toLowerCase();

            Map<String, Object> userResult = new Map<String, Object>{
                'userInput' => rawInput
            };

            // Name with multiple matches â†’ ask caller to use exact email
            if (nameAmbiguous.containsKey(inputKey)) {
                userResult.put('success',         false);
                userResult.put('validationFailed', true);
                userResult.put('multipleUsers',    true);
                userResult.put('errors', new List<String>{
                    'Multiple users found for [' + rawInput + ']. '
                    + 'Please resend with the exact Intel email address.'
                });
                userResult.put('options', nameAmbiguous.get(inputKey));
                failedCount++;
                results.add(userResult);
                continue;
            }

            User u = userByInput.get(inputKey);
            if (u == null) {
                userResult.put('success',         false);
                userResult.put('validationFailed', true);
                userResult.put('errors', new List<String>{
                    'No active Salesforce user found for [' + rawInput + ']. '
                    + (rawInput.contains('@')
                        ? 'Please verify the Intel email address.'
                        : 'Please provide the exact Intel email address or full name.')
                });
                failedCount++;
                results.add(userResult);
                continue;
            }

            userResult.put('userId',    u.Id);
            userResult.put('userName',  u.Name);
            userResult.put('userEmail', u.Email);

            Core_MDF_IUPGM_Request_Staging__c inflight = inflightByUser.get(u.Id);
            if (inflight != null) {
                String statusDisplay = inflight.Core_MDF_Request_Status_nm__c
                    .replace('_', ' ').toLowerCase();
                userResult.put('success',        false);
                userResult.put('duplicate',      true);
                userResult.put('requestNumber',  inflight.Name);
                userResult.put('status',         inflight.Core_MDF_Request_Status_nm__c);
                userResult.put('message', u.Name + ' already has an active request '
                    + '(currently ' + statusDisplay + '). Request: ' + inflight.Name);
                duplicateCount++;
                results.add(userResult);
                continue;
            }

            // Ready - build requestSummary for this user
            Map<String, Object> requestSummary = new Map<String, Object>{
                'userId'                => u.Id,
                'accountId'             => accountId,
                'userName'              => u.Name,
                'userEmail'             => u.Email,
                'requestorEmail'        => requestorEmail,
                'agsRoleComments'       => agsRoleComments,
                'accountName'           => resolvedAccountName,
                'program'               => program,
                'programAlias'          => programInput.toUpperCase().trim(),
                'roleLabel'             => cfg.Core_MDF_Role_Label__c,
                'permissionSetName'     => cfg.Core_MDF_Permission_Set_Name__c,
                'agsRoleName'           => resolvedAgsRoleName,
                'iupgmRoleName'         => cfg.Core_MDF_IUPGM_Role_Name__c,
                'iupgmRequired'         => cfg.Core_MDF_IUPGM_Required__c,
                'allAccountAccess'      => allAccountAccess,
                'geo'                   => geo,
                'allBudgetAccess'       => allBudgetAccess,
                'geoBudgetType'         => geoBudgetType,
                'approvalRegion'        => approvalRegion,
                'activityClassification' => activityClassification
            };
            userResult.put('success',           true);
            userResult.put('readyForSubmission', true);
            userResult.put('requestSummary',    requestSummary);
            readyCount++;
            results.add(userResult);
        }

        // â”€â”€ 9. Return bulk response â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        String confirmPrompt = readyCount > 0
            ? readyCount + ' of ' + usersRaw.size() + ' users are ready. '
                + (duplicateCount > 0
                    ? duplicateCount + ' already have active requests. ' : '')
                + (failedCount > 0
                    ? failedCount + ' could not be resolved. ' : '')
                + 'Reply YES to submit for the ready users, or NO to cancel.'
            : 'No users are ready for submission. '
                + (duplicateCount > 0
                    ? duplicateCount + ' already have active requests. ' : '')
                + failedCount + ' could not be resolved.';

        res.statusCode = 200;

        // â”€â”€ AUTO-SUBMIT for bulk (userConfirmed = true) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if (userConfirmed == true && readyCount > 0) {
            List<Core_MDF_IUPGM_Request_Staging__c> toInsert =
                new List<Core_MDF_IUPGM_Request_Staging__c>();
            List<Integer> readyIndexes = new List<Integer>();
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].get('success') == true
                    && results[i].get('readyForSubmission') == true) {
                    toInsert.add(createStagingFromSummary(
                        (Map<String, Object>) results[i].get('requestSummary')));
                    readyIndexes.add(i);
                }
            }
            List<Database.SaveResult> saveResults =
                Database.insert(toInsert, false);
            Set<Id> insertedIds = new Set<Id>();
            for (Integer i = 0; i < saveResults.size(); i++) {
                if (saveResults[i].isSuccess()) {
                    insertedIds.add(saveResults[i].getId());
                } else {
                    results[readyIndexes[i]].put('success', false);
                    results[readyIndexes[i]].put('readyForSubmission', null);
                    results[readyIndexes[i]].put('error',
                        saveResults[i].getErrors()[0].getMessage());
                }
            }
            Map<Id, String> stagingNames = new Map<Id, String>();
            if (!insertedIds.isEmpty()) {
                for (Core_MDF_IUPGM_Request_Staging__c s : [
                    SELECT Id, Name FROM Core_MDF_IUPGM_Request_Staging__c
                    WHERE Id IN :insertedIds
                ]) {
                    stagingNames.put(s.Id, s.Name);
                }
            }
            Integer submitted = 0;
            for (Integer i = 0; i < saveResults.size(); i++) {
                if (saveResults[i].isSuccess()) {
                    Id recId = saveResults[i].getId();
                    results[readyIndexes[i]].put('autoSubmitted',  true);
                    results[readyIndexes[i]].put('requestNumber',  stagingNames.get(recId));
                    results[readyIndexes[i]].put('status',
                        Core_MDF_CCP_ConstantClass.IUPGM_STATUS_NEW);
                    submitted++;
                }
            }
            return JSON.serialize(new Map<String, Object>{
                'success'            => true,
                'bulkMode'           => true,
                'autoSubmitted'      => true,
                'totalUsers'         => usersRaw.size(),
                'readyCount'         => readyCount,
                'submitted'          => submitted,
                'duplicateCount'     => duplicateCount,
                'failedCount'        => failedCount,
                'results'            => results,
                'regionNotice'       => bulkRegionNotice,
                'confirmationPrompt' => submitted + ' of ' + usersRaw.size()
                    + ' users submitted automatically (userConfirmed=true). '
                    + (duplicateCount > 0 ? duplicateCount + ' already had active requests. ' : '')
                    + (failedCount    > 0 ? failedCount    + ' could not be resolved. '       : '')
            });
        }

        return JSON.serialize(new Map<String, Object>{
            'success'            => true,
            'bulkMode'           => true,
            'totalUsers'         => usersRaw.size(),
            'readyCount'         => readyCount,
            'duplicateCount'     => duplicateCount,
            'failedCount'        => failedCount,
            'results'            => results,
            'regionNotice'       => bulkRegionNotice,
            'confirmationPrompt' => confirmPrompt
        });
    }
/******************************************************************************************************
    Method Name:        handleBulkConfirmedSubmit
    Description:       Submits bulk-confirmed request summaries by creating staging records after duplicate checks and returns per-user outcomes.
    Added By:           Ramapriya
    *******************************************************************************************************/
  
    /** Submits a previously validated bulk request set after user confirmation. */
    private static String handleBulkConfirmedSubmit(
        Map<String, Object> p,
        RestResponse res
    ) {
        List<Object> summariesRaw;
        try {
            summariesRaw = (List<Object>) p.get('requestSummaries');
        } catch (Exception ex) {
            res.statusCode = 400;
            return err('"requestSummaries" must be a JSON array of requestSummary objects.');
        }
        if (summariesRaw == null || summariesRaw.isEmpty()) {
            res.statusCode = 400;
            return err('"requestSummaries" array is required and cannot be empty.');
        }

        List<Map<String, Object>> summaries = new List<Map<String, Object>>();
        Set<Id> allUserIds = new Set<Id>();
        for (Object raw : summariesRaw) {
            Map<String, Object> s = (Map<String, Object>) raw;
            summaries.add(s);
            String uid = str(s, 'userId');
            if (String.isNotBlank(uid)) allUserIds.add((Id) uid);
        }

        // Bulk duplicate check (ONE SOQL)
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
                  AND Core_MDF_Request_Status_nm__c NOT IN (
                      'Error', 'Validation_Failed', 'External_User_Blocked', 'AGS_Rejected'
                  )
            ]) {
                String key = String.valueOf(stg.Core_MDF_IUPGM_User__c)
                    + '|' + stg.Core_MDF_IUPGM_Role_nm__c
                    + '|' + stg.Core_MDF_IUPGM_Program__c;
                if (!inflightByKey.containsKey(key)) inflightByKey.put(key, stg);
            }
        }

        List<Core_MDF_IUPGM_Request_Staging__c> toInsert = new List<Core_MDF_IUPGM_Request_Staging__c>();
        List<Integer> insertToIdx = new List<Integer>();
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        for (Integer i = 0; i < summaries.size(); i++) {
            Map<String, Object> s = summaries[i];
            String userId  = str(s, 'userId');
            String prog    = str(s, 'program');
            String psName  = str(s, 'permissionSetName');
            String uName   = str(s, 'userName');
            String uEmail  = str(s, 'userEmail');
            Boolean userNeedsCreation = parseBool(s.get('userNeedsCreation'));

            Map<String, Object> result = new Map<String, Object>{
                'userName'  => uName,
                'userEmail' => uEmail
            };

            if ((String.isBlank(userId) && !userNeedsCreation)
                || String.isBlank(prog) || String.isBlank(psName)) {
                result.put('success', false);
                result.put('error', 'Incomplete requestSummary at index ' + i
                    + '. Ensure you are sending the requestSummary objects from the previous validateRequest response.');
                results.add(result);
                continue;
            }
            // Same rule as the single-user path: a brand-new user's Federation ID
            // (Worldwide ID) cannot be looked up from the org, so it must have been
            // explicitly collected and echoed back - never guessed here.
            if (userNeedsCreation && String.isBlank(str(s, 'newUserFederationId'))) {
                result.put('success', false);
                result.put('error', 'Missing newUserFederationId at index ' + i
                    + '. A Federation ID (Worldwide ID) is required to create a new user via AGS.');
                results.add(result);
                continue;
            }
            String accountValidationError = validateAccountRequirementForSummary(s);
            if (String.isNotBlank(accountValidationError)) {
                result.put('success', false);
                result.put('error', accountValidationError);
                results.add(result);
                continue;
            }

            if (String.isNotBlank(userId)) {
                Id userId_Id = (Id) userId;
                String dupKey = String.valueOf(userId_Id) + '|' + psName + '|' + prog;
                if (inflightByKey.containsKey(dupKey)) {
                    Core_MDF_IUPGM_Request_Staging__c dup = inflightByKey.get(dupKey);
                    result.put('success',       false);
                    result.put('duplicate',     true);
                    result.put('requestNumber', dup.Name);
                    result.put('status',        dup.Core_MDF_Request_Status_nm__c);
                    result.put('message', (String.isNotBlank(uName) ? uName : 'This user')
                        + ' already has an active request (' + dup.Name + ').');
                    results.add(result);
                    continue;
                }
            }

            toInsert.add(createStagingFromSummary(s));
            insertToIdx.add(i);
            result.put('success', true);
            result.put('queued',  true);
            results.add(result);
        }

        // Bulk insert (partial success)
        List<Database.SaveResult> saveResults = Database.insert(toInsert, false);
        Set<Id> insertedIds = new Set<Id>();
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (saveResults[i].isSuccess()) {
                insertedIds.add(saveResults[i].getId());
            } else {
                results[insertToIdx[i]].put('success', false);
                results[insertToIdx[i]].put('queued',  null);
                results[insertToIdx[i]].put('error',
                    saveResults[i].getErrors()[0].getMessage());
            }
        }

        Map<Id, String> stagingNames = new Map<Id, String>();
        if (!insertedIds.isEmpty()) {
            for (Core_MDF_IUPGM_Request_Staging__c s : [
                SELECT Id, Name FROM Core_MDF_IUPGM_Request_Staging__c
                WHERE Id IN :insertedIds
            ]) {
                stagingNames.put(s.Id, s.Name);
            }
        }

        Integer submitted = 0, dupes = 0, failed = 0;
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (saveResults[i].isSuccess()) {
                Id recId = saveResults[i].getId();
                results[insertToIdx[i]].put('autoSubmitted', true);
                results[insertToIdx[i]].put('requestNumber', stagingNames.get(recId));
                results[insertToIdx[i]].put('status',
                    Core_MDF_CCP_ConstantClass.IUPGM_STATUS_NEW);
                submitted++;
            }
        }
        for (Map<String, Object> r : results) {
            if (r.get('duplicate') == true) dupes++;
            else if (r.get('success') != true) failed++;
        }

        res.statusCode = 200;
        return JSON.serialize(new Map<String, Object>{
            'success'        => true,
            'bulkMode'       => true,
            'autoSubmitted'  => true,
            'totalUsers'     => summaries.size(),
            'submitted'      => submitted,
            'duplicates'     => dupes,
            'failed'         => failed,
            'results'        => results,
            'message'        => submitted + ' request(s) submitted successfully. '
                + (dupes  > 0 ? dupes  + ' duplicate(s) skipped. ' : '')
                + (failed > 0 ? failed + ' failed. '               : '')
        });
    }

   /******************************************************************************************************
    Method Name:        createStagingFromSummary
    Description:       Maps a resolved request summary payload into a Core_MDF_IUPGM_Request_Staging__c record instance.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Converts a resolved summary map into a new staging record. */
    @testVisible
    private static Core_MDF_IUPGM_Request_Staging__c createStagingFromSummary(
        Map<String, Object> summary
    ) {
        String  userId        = str(summary, 'userId');
        String  accountIdStr  = str(summary, 'accountId');
        String  program       = str(summary, 'program');
        String  psName        = str(summary, 'permissionSetName');
        String  agsRoleName   = str(summary, 'agsRoleName');
        String  geo           = str(summary, 'geo');
        String  approvalReg   = str(summary, 'approvalRegion');
        String  actClass      = str(summary, 'activityClassification');
        String  geoBudget     = str(summary, 'geoBudgetType');
        String  requestorEmail= str(summary, 'requestorEmail');
        String  agsRoleComments = str(summary, 'agsRoleComments');
        Boolean userNeedsCreation = parseBool(summary.get('userNeedsCreation'));
        String  newUserName   = str(summary, 'newUserFullName');
        String  newUserFedId  = str(summary, 'newUserFederationId');
        String  newUserEmail  = str(summary, 'newUserEmail');
        if (String.isBlank(newUserEmail)) newUserEmail = str(summary, 'userEmail');
        // Use null-safe parsing - checkbox fields cannot accept null in DML
        Boolean allAcct       = summary.get('allAccountAccess') != null
            ? parseBool(summary.get('allAccountAccess')) : null;
        Boolean allBudget     = summary.get('allBudgetAccess') != null
            ? parseBool(summary.get('allBudgetAccess')) : null;

        Core_MDF_IUPGM_Request_Staging__c staging =
            new Core_MDF_IUPGM_Request_Staging__c();
        staging.Core_MDF_IUPGM_User__c                   =
            String.isNotBlank(userId) ? (Id) userId : null;
        staging.Core_MDF_IUPGM_Program__c                = program;
        staging.Core_MDF_Requested_By__c                 = UserInfo.getUserId();
        // Prefer explicit requestorEmail from chatbot payload; fall back to connected user's email.
        staging.Core_MDF_Requestor_Email__c              = String.isNotBlank(requestorEmail)
            ? requestorEmail : UserInfo.getUserEmail();
        Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
            staging,
            'Core_MDF_AGS_Role_Comments__c',
            agsRoleComments
        );
        staging.Core_MDF_IUPGM_Role_nm__c                = psName;
        staging.Core_MDF_AGS_Role_Name__c                = agsRoleName;
        // Only set checkbox fields when value is present - Salesforce rejects null on checkbox DML
        if (allAcct != null) {
            staging.Core_MDF_IUPGM_All_Account_Access__c = allAcct;
        }
        staging.Core_MDF_IUPGM_Account__c                =
            String.isNotBlank(accountIdStr) ? (Id) accountIdStr : null;
        staging.Core_MDF_IUPGM_Region_Sub_Region_nm__c   = geo;
        if (allBudget != null) {
            staging.Core_MDF_IUPGM_All_Budget_Type_Access__c = allBudget;
        }
        staging.Core_MDF_GeoSubGeo_Budget_Type_nm__c     = geoBudget;
        staging.Core_MDF_Approval_Region_nm__c           = approvalReg;
        staging.Core_MDF_Activity_Classification_nm__c   = actClass;
        staging.Core_MDF_Request_Status_nm__c            =
            Core_MDF_CCP_ConstantClass.IUPGM_STATUS_NEW;
        // Explicit request intent (GRANT/REVOKE) - only the REVOKE branch populates
        // 'requestAction' on the summary; everything else defaults to GRANT so
        // every existing GRANT caller is completely unaffected.
        String summaryRequestAction = str(summary, 'requestAction');
        staging.Core_MDF_Request_Type_nm__c               =
            (String.isNotBlank(summaryRequestAction)
                && summaryRequestAction.trim().toUpperCase() == 'REVOKE')
                ? 'REVOKE' : 'GRANT';
        if (userNeedsCreation) {
            if (String.isBlank(newUserFedId) && String.isNotBlank(newUserEmail)) {
                newUserFedId = deriveFederationFromEmail(newUserEmail);
            }
            Core_MDF_AGS_CalloutQueueable.putStagingFieldIfPresent(
                staging,
                'Core_MDF_New_User_Name__c',
                newUserName
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
        return staging;
    }

    /** Reads optional chatbot approver comments using supported payload aliases. */
    @testVisible
    private static String approverComments(Map<String, Object> payload) {
        if (payload == null) return null;
        String comments = str(payload, 'agsRoleComments');
        if (String.isBlank(comments)) comments = str(payload, 'approverComments');
        if (String.isBlank(comments)) comments = str(payload, 'Approver comments');
        if (String.isBlank(comments)) return null;

        String normalized = comments.trim();
        if (normalized.equalsIgnoreCase('none')
            || normalized.equalsIgnoreCase('n/a')
            || normalized.equalsIgnoreCase('na')) {
            return null;
        }
        return normalized;
    }

    /** Revalidates account requirements for a confirmed requestSummary before insert. */
    @testVisible
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
        Core_MDF_IUPGM_Rule_Config__mdt cfg =
            pickPreferredConfig(cfgRows, program);
        if (!cfg.Core_MDF_Account_Required__c) {
            return null;
        }

        String allAccOpt = cfg.Core_MDF_All_Accounts__c;
        Boolean hasAllAccountAccess = summary.containsKey('allAccountAccess')
            && summary.get('allAccountAccess') != null;
        Boolean allAccountAccess = hasAllAccountAccess
            ? parseBool(summary.get('allAccountAccess')) : null;

        if (allAccOpt == 'YES_NO' && allAccountAccess == null) {
            return 'Invalid requestSummary - missing allAccountAccess for role ['
                + cfg.Core_MDF_Role_Label__c + ']. Please re-run validateRequest.';
        }

        Boolean accountWillBeNeeded =
            (allAccOpt == 'NO_ONLY')
            || (allAccOpt == 'YES_NO' && allAccountAccess == false);
        if (accountWillBeNeeded && String.isBlank(str(summary, 'accountId'))) {
            return 'Invalid requestSummary - accountId is required for role ['
                + cfg.Core_MDF_Role_Label__c + ']. Please provide accountName and re-validate.';
        }
        return null;
    }

    /******************************************************************************************************
    Method Name:        resolveProgram
    Description:       Resolves user-entered program text to a supported canonical program value.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Resolves a free-text program input into the canonical program name. */
    @testVisible
    private static String resolveProgram(String input) {
        if (String.isBlank(input)) return null;
        Map<String, String> m = new Map<String, String>{
            // IPA
            'IPA'                         => 'Intel Partner Alliance',
            'INTEL PARTNER ALLIANCE'      => 'Intel Partner Alliance',
            // Client / CCF
            'CCF'                         => 'Client',
            'CLIENT'                      => 'Client',
            'CLIENT CO-MARKETING FUND'    => 'Client',
            'CLIENT CO MARKETING FUND'    => 'Client',
            // Datacenter / DCF
            'DC'                          => 'Datacenter',
            'DCF'                         => 'Datacenter',
            'DATACENTER'                  => 'Datacenter',
            'DATA CENTER'                 => 'Datacenter',
            'DATACENTER CO-MARKETING FUND'  => 'Datacenter',
            'DATACENTER CO MARKETING FUND'  => 'Datacenter',
            'DCF CO-MARKETING FUND'         => 'Datacenter',
            // RMF
            'RMF'                         => 'Retail Marketing Funds',
            'RETAIL MARKETING FUNDS'      => 'Retail Marketing Funds',
            // Co-GTM
            'COGTM'                       => 'Co-GTM',
            'CO-GTM'                      => 'Co-GTM',
            'CO GTM'                      => 'Co-GTM'
        };
        return m.get(input.toUpperCase().trim());
    }

    /**
     * Chatbot/UI-facing label for a program value. COMMON is an internal fallback
     * marker for roles that are not tied to any single program - it must never be
     * shown to the end user verbatim. Everywhere a program name is surfaced in a
     * message, displaySummary, or role-selection list, route it through this method.
     */
    @testVisible
    private static String displayProgramLabel(String program) {
        if (String.isBlank(program) || program.trim().equalsIgnoreCase(COMMON_PROGRAM)) {
            return 'Generic';
        }
        return program;
    }

    /** Maps the chatbot/MDT program value to the IUPGM program picklist value. */
    private static String toIupgmProgramName(String program) {
        Map<String, String> programNames = new Map<String, String>{
            'Client'                 => 'Client CoMarketing Fund',
            'Intel Partner Alliance' => 'Intel Partner Alliance',
            'Retail Marketing Funds' => 'Retail Marketing Funds',
            'Co-GTM'                 => 'CoGTM',
            'Datacenter'             => 'Data Center CoMarketing Fund'
        };
        return programNames.containsKey(program) ? programNames.get(program) : program;
    }

    /** Returns candidate programs for lookup: exact program + COMMON fallback. */
    @testVisible
    private static Set<String> getProgramCandidates(String program) {
        Set<String> candidates = new Set<String>();
        if (String.isNotBlank(program)) {
            candidates.add(program.trim());
        }
        candidates.add(COMMON_PROGRAM);
        return candidates;
    }

    @testVisible
    private static Boolean isProgramMatchOrCommon(String cfgProgram, String requestedProgram) {
        if (String.isBlank(requestedProgram)) return true;
        if (String.isBlank(cfgProgram)) return false;
        String cfg = cfgProgram.trim();
        String req = requestedProgram.trim();
        return cfg.equalsIgnoreCase(req) || cfg.equalsIgnoreCase(COMMON_PROGRAM);
    }

    /** Collapses duplicate role labels by preferring exact-program record over COMMON. */
    @testVisible
    private static List<Core_MDF_IUPGM_Rule_Config__mdt> collapseRoleRecordsForProgram(
        List<Core_MDF_IUPGM_Rule_Config__mdt> records,
        String requestedProgram
    ) {
        if (records == null || records.isEmpty() || String.isBlank(requestedProgram)) {
            return records;
        }
        Map<String, Core_MDF_IUPGM_Rule_Config__mdt> bestByLabel =
            new Map<String, Core_MDF_IUPGM_Rule_Config__mdt>();
        for (Core_MDF_IUPGM_Rule_Config__mdt rec : records) {
            String key = String.valueOf(rec.Core_MDF_Role_Label__c).trim().toLowerCase();
            if (!bestByLabel.containsKey(key)) {
                bestByLabel.put(key, rec);
                continue;
            }
            Core_MDF_IUPGM_Rule_Config__mdt existing = bestByLabel.get(key);
            Boolean existingExact = String.isNotBlank(existing.Core_MDF_Program__c)
                && existing.Core_MDF_Program__c.trim().equalsIgnoreCase(requestedProgram);
            Boolean candidateExact = String.isNotBlank(rec.Core_MDF_Program__c)
                && rec.Core_MDF_Program__c.trim().equalsIgnoreCase(requestedProgram);
            if (candidateExact && !existingExact) {
                bestByLabel.put(key, rec);
            }
        }
        return new List<Core_MDF_IUPGM_Rule_Config__mdt>(bestByLabel.values());
    }

    /** Picks exact-program config first, otherwise returns first available row. */
    @testVisible
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
    Method Name:        detectPrograms
    Description:       Detects one or more program matches from free-form user text using alias and keyword matching.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Detects one or more program aliases mentioned in free text. */
    @testVisible
    private static List<String> detectPrograms(String input) {
        List<String> found = new List<String>();
        if (String.isBlank(input)) return found;

        String upper = ' ' + input.toUpperCase().replaceAll('[^A-Z0-9]+', ' ').trim() + ' ';

        // Longest aliases first so "DATA CENTER" wins over "DC".
        List<String> aliases = new List<String>{
            'DATACENTER CO MARKETING FUND', 'CLIENT CO MARKETING FUND',
            'DCF CO MARKETING FUND', 'INTEL PARTNER ALLIANCE',
            'RETAIL MARKETING FUNDS', 'DATA CENTER', 'DATACENTER',
            'CO GTM', 'COGTM', 'CLIENT', 'RMF', 'IPA', 'CCF', 'DCF', 'DC'
        };

        Map<Integer, String> hits = new Map<Integer, String>();
        String scan = upper;
        for (String alias : aliases) {
            Integer idx = scan.indexOf(' ' + alias + ' ');
            if (idx < 0) continue;
            String resolved = resolveProgram(alias);
            if (resolved == null) continue;
            hits.put(idx, resolved);
            // Blank out the matched token so shorter aliases don't re-match inside it.
            scan = scan.replace(' ' + alias + ' ', ' ' + '#'.repeat(alias.length()) + ' ');
        }

        List<Integer> positions = new List<Integer>(hits.keySet());
        positions.sort();
        for (Integer p : positions) {
            if (!found.contains(hits.get(p))) found.add(hits.get(p));
        }
        return found;
    }
	/******************************************************************************************************
    Method Name:        shouldCollectBudgetType
    Description:       Determines whether budget-type collection is required for the selected role and request context.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Determines whether the flow should prompt for budget type selection. */
    @testVisible
    private static Boolean shouldCollectBudgetType(
        String resolvedProgram,
        Core_MDF_IUPGM_Rule_Config__mdt cfg
    ) {
        String programName = String.isNotBlank(resolvedProgram)
            ? resolvedProgram
            : (cfg == null ? null : cfg.Core_MDF_Program__c);
        if (String.isBlank(programName)) return false;
        String normalized = programName.trim().toUpperCase();
        return normalized == 'INTEL PARTNER ALLIANCE'
            || normalized == 'IPA'
            || normalized == 'CO-GTM'
            || normalized == 'CO GTM'
            || normalized == 'COGTM';
    }
    
    /**
     * Builds the account label shown to the chatbot.
     * RMF uses node/sub-node (Virtual Corp) accounts, so keep its existing
     * account-name-only display. All other programs resolve Ultimate Accounts
     * and display the Account Name together with Unified ID (Core_Business_Party_Id__c).
     * The actual Account Id remains unchanged and is still stored downstream.
     */
    @testVisible
    private static String buildAccountDisplayName(Account a, Boolean nodeAllowed) {
        if (a == null) return null;

        String displayName = String.isNotBlank(a.Name)
            ? a.Name
            : (a.Core_MDF_CoMarketing_Ultimate_Account__r != null
                ? a.Core_MDF_CoMarketing_Ultimate_Account__r.Name
                : null);

        // ISSUE #2 FIX: Always append Business_Party_Id for non-RMF programs
        // RMF (nodeAllowed=true) programs show node account name only
        // Non-RMF programs show: Account Name (Business_Party_Id)
        if (!nodeAllowed && String.isNotBlank(a.Core_Business_Party_Id__c)) {
            displayName += ' (' + a.Core_Business_Party_Id__c + ')';
        }

        return displayName;
    }
    
    /******************************************************************************************************
     Method Name:        extractUnifiedIdFromAccountInput
     Description:       Extracts Unified ID when the chatbot/user sends the display format
                        "Account Name (Unified ID)".
     *******************************************************************************************************/
    @testVisible
    private static String extractUnifiedIdFromAccountInput(String accountInput) {
        if (String.isBlank(accountInput)) return null;

        Matcher m = Pattern.compile(
            '^\\s*.+?\\s*\\(\\s*([^()]+?)\\s*\\)\\s*$'
        ).matcher(accountInput.trim());

        return m.matches() ? m.group(1).trim() : null;
    }

   /******************************************************************************************************
    Method Name:        isNodeLevelAllowed
    Description:       Checks whether node-level gating allows progress for the selected role/program combination.
    Added By:           Ramapriya
    *******************************************************************************************************/

    /** Indicates whether node-level account selection is allowed for the given program. */
    @testVisible
   
    private static Boolean isNodeLevelAllowed(String program) {
        if (String.isBlank(program)) return false;
        String p = program.trim().toUpperCase();
        return p == 'RETAIL MARKETING FUNDS'
            || p == 'RMF';
    }

   /******************************************************************************************************
    Method Name:        isUltimateAccountName
    Description:       Checks whether the given name matches an existing Ultimate Account (no Ultimate
                        Account parent populated). Used to give RMF users a clear message when they type
                        an Ultimate Account name instead of a node/sub-node (Virtual Corp) account.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Returns true when accountName exactly matches an existing Ultimate Account. */
    @testVisible
    private static Boolean isUltimateAccountName(String accountName) {
        if (String.isBlank(accountName)) return false;
        String nameBind = accountName;
        List<Account> ultimateMatch = [
            SELECT Id FROM Account
            WHERE Name = :nameBind
              AND Core_MDF_CoMarketing_Ultimate_Account__c = null
            LIMIT 1
        ];
        return !ultimateMatch.isEmpty();
    }

   /******************************************************************************************************
    Method Name:        findExistingRequest
    Description:       Looks up existing requests for the same user/program/role and returns duplicate context when one is found.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Checks for an equivalent in-flight or completed request to prevent duplicate submissions. */
    @testVisible
    private static Map<String, Object> findExistingRequest(
        String  userId,
        String  permissionSetName,
        String  program,
        String  accountId,
        String  geo,
        String  geoBudgetType,
        Boolean allAccountAccess,
        Boolean allBudgetAccess,
        String  userName
    ) {
        if (String.isBlank(userId) || String.isBlank(permissionSetName)) {
            return null;
        }

        Id userIdVal    = (Id) userId;
        Id accountIdVal = String.isNotBlank(accountId) ? (Id) accountId : null;

        List<Core_MDF_IUPGM_Request_Staging__c> candidates = [
            SELECT Id,
                   Name,
                   CreatedDate,
                   Core_MDF_Request_Status_nm__c,
                   Core_MDF_Request_Type_nm__c,
                   Core_MDF_IUPGM_Account__c,
                   Core_MDF_IUPGM_Region_Sub_Region_nm__c,
                   Core_MDF_GeoSubGeo_Budget_Type_nm__c,
                   Core_MDF_IUPGM_All_Account_Access__c,
                   Core_MDF_IUPGM_All_Budget_Type_Access__c
            FROM   Core_MDF_IUPGM_Request_Staging__c
            WHERE  Core_MDF_IUPGM_User__c    = :userIdVal
              AND  Core_MDF_IUPGM_Role_nm__c = :permissionSetName
              AND  Core_MDF_IUPGM_Program__c = :program
              // This helper is only reached from the GRANT path (REVOKE returns
              // earlier) - exclude in-flight REVOKE records so a pending removal
              // never blocks a brand-new grant for the same role/program.
              AND (Core_MDF_Request_Type_nm__c = 'GRANT' OR Core_MDF_Request_Type_nm__c = null)
              AND  Core_MDF_Request_Status_nm__c NOT IN (
                       'Error', 'Validation_Failed',
                       'External_User_Blocked', 'AGS_Rejected', 'Skipped'
                   )
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];

        for (Core_MDF_IUPGM_Request_Staging__c s : candidates) {
            if (accountIdVal != s.Core_MDF_IUPGM_Account__c)              continue;
            if (!sameFlag(allAccountAccess,
                          s.Core_MDF_IUPGM_All_Account_Access__c))         continue;
            if (!sameFlag(allBudgetAccess,
                          s.Core_MDF_IUPGM_All_Budget_Type_Access__c))     continue;
            if (!sameMultiValue(geo,
                          s.Core_MDF_IUPGM_Region_Sub_Region_nm__c))       continue;
            if (!sameMultiValue(geoBudgetType,
                          s.Core_MDF_GeoSubGeo_Budget_Type_nm__c))         continue;

            String who    = String.isNotBlank(userName) ? userName : 'This user';
            String status = s.Core_MDF_Request_Status_nm__c;
            // Check IUPGM state for terminal statuses (Completed or Skipped)
            // Skipped = blocked because broader access exists, but we need to verify IUPGM state
            Boolean isDone = 'Completed'.equalsIgnoreCase(status) || 'Skipped'.equalsIgnoreCase(status);

            // ✅ UNIFIED LOGIC: Handle both GRANT and REVOKE scenarios with single IUPGM query
            if (isDone) {
                
                // Query IUPGM by user/role/program/account (NOT filtered by region)
                // We need to find ANY IUPGM for this combination, regardless of region
                // So we can reactivate + merge regions if needed
                List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmRecords = [
                    SELECT Id, Core_MDF_Active_Ind__c, Core_MDF_Region_Sub_Region_nm__c
                    FROM   Core_MDF_Int_Users_Partner_Geo_Mapping__c
                    WHERE  Core_MDF_User_id__c = :userIdVal
                      AND  Core_MDF_Role_nm__c = :permissionSetName
                      AND  Core_MDF_Program_nm__c = :program
                      AND  Core_MDF_Account_Id__c = :accountIdVal
                    LIMIT 5
                ];
                
                Boolean isRevoke = 'REVOKE'.equalsIgnoreCase(s.Core_MDF_Request_Type_nm__c);
                
                // ═══════════════════════════════════════════════════════════════════
                // CASE 1: REVOKE request + IUPGM deactivated → Reactivate
                // ═══════════════════════════════════════════════════════════════════
                if (isRevoke && !iupgmRecords.isEmpty()) {
                    Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = iupgmRecords[0];
                    
                    if (iupgm.Core_MDF_Active_Ind__c == false) {
                        // Reactivate the IUPGM record
                        iupgm.Core_MDF_Active_Ind__c = true;
                        update iupgm;
                        
                        return new Map<String, Object>{
                            'success'            => true,
                            'reactivated'        => true,
                            'requestNumber'      => s.Name,
                            'status'             => 'Reactivated',
                            'alreadyProvisioned' => false,
                            'message'            => who + '\'s access for this role has been successfully reactivated. '
                                + 'The IUPGM record from request ' + s.Name + ' (which was deactivated) is now active again.',
                            'nextStep'           => 'Access should be visible immediately.'
                        };
                    } else {
                        // IUPGM already active - shouldn't happen after REVOKE, but handle it
                        String message = who + ' already has this access. '
                            + 'The previous deactivation request ' + s.Name + ' was completed, '
                            + 'but the IUPGM record is already active again.';

                        return new Map<String, Object>{
                            'success'            => false,
                            'duplicate'          => true,
                            'needsInput'         => false,
                            'readyForSubmission' => false,
                            'requestNumber'      => s.Name,
                            'status'             => status,
                            'alreadyProvisioned' => true,
                            'message'            => message,
                            'nextStep'           => 'No new request is needed.'
                        };
                    }
                }
                
                // ═══════════════════════════════════════════════════════════════════
                // CASE 2: GRANT request (or REVOKE with no IUPGM found)
                //         Check if IUPGM is deactivated → Allow new request (AccessModelService will reactivate)
                //         Check if IUPGM is active → Block duplicate
                // ═══════════════════════════════════════════════════════════════════
                if (!isRevoke) {
                    
                    // IUPGM doesn't exist → Allow new request
                    if (iupgmRecords.isEmpty()) {
                        // No IUPGM record - allow new grant to proceed
                        continue;
                    }
                    
                    Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = iupgmRecords[0];
                    
                    if (iupgm.Core_MDF_Active_Ind__c == false) {
                        // IUPGM is DEACTIVATED (via manual removal or prior REVOKE)
                        // Allow new grant to proceed - AccessModelService will detect
                        // the pre-populated IUPGM_Record__c and reactivate it
                        continue;
                    }
                    
                    // IUPGM is ACTIVE → Block (user already has active access)
                    String message = who + ' already has this access. Request ' + s.Name
                        + ' was completed successfully on '
                        + s.CreatedDate.format('dd MMM yyyy')
                        + ', so a new request is not needed. '
                        + 'If the access is not visible, please ask '
                        + (String.isNotBlank(userName) ? userName : 'the user')
                        + ' to log out and log back in.';

                    return new Map<String, Object>{
                        'success'            => false,
                        'duplicate'          => true,
                        'needsInput'         => false,
                        'readyForSubmission' => false,
                        'requestNumber'      => s.Name,
                        'status'             => status,
                        'alreadyProvisioned' => true,
                        'message'            => message,
                        'nextStep'           => 'You can check the live status any time '
                            + 'by asking me for the status of ' + s.Name + '.'
                    };
                }
            }
            
            // In-flight request (not Completed) - always block
            String message = who + ' already has a request for this exact access and it is '
                + 'still being processed. Request ' + s.Name
                + ' was raised on ' + s.CreatedDate.format('dd MMM yyyy')
                + ' and is currently in progress. '
                + 'Access will be granted automatically once it completes - '
                + 'a new request is not needed.';

            return new Map<String, Object>{
                'success'            => false,
                'duplicate'          => true,
                'needsInput'         => false,
                'readyForSubmission' => false,
                'requestNumber'      => s.Name,
                'status'             => status,
                'alreadyProvisioned' => false,
                'message'            => message,
                'nextStep'           => 'You can check the live status any time '
                    + 'by asking me for the status of ' + s.Name + '.'
            };
        }

        return null;
    }

    /******************************************************************************************************
    Method Name:        sameFlag
    Description:       Compares two boolean flags using normalized truthiness semantics.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Compares booleans using effective truthiness so null and false are treated equivalently. */
    @testVisible
    private static Boolean sameFlag(Boolean a, Boolean b) {
        return (a == true) == (b == true);
    }

    /******************************************************************************************************
    Method Name:        sameMultiValue
    Description:       Compares two multi-value strings by normalizing and matching their value sets.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Compares two delimited multi-value strings as normalized sets. */
    @testVisible
    private static Boolean sameMultiValue(String a, String b) {
        Set<String> setA = toValueSet(a);
        Set<String> setB = toValueSet(b);
        return setA.size() == setB.size() && setA.containsAll(setB);
    }
 /******************************************************************************************************
    Method Name:        toValueSet
    Description:       Converts delimited text values into an uppercase normalized set for comparisons.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Converts comma/semicolon-delimited text into an upper-cased value set. */
    @testVisible
    private static Set<String> toValueSet(String raw) {
        Set<String> out = new Set<String>();
        if (String.isBlank(raw)) return out;
        for (String part : raw.split('[;,]')) {
            String v = part == null ? '' : part.trim();
            if (String.isNotBlank(v)) out.add(v.toUpperCase());
        }
        return out;
    }

    /******************************************************************************************************
    Method Name:        splitMultiValue
    Description:       Splits potentially multi-valued user input into cleaned, de-duplicated tokens.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Splits user input containing multiple values into a de-duplicated list. */
    @testVisible
    private static List<String> splitMultiValue(String input) {
        List<String> out = new List<String>();
        if (String.isBlank(input)) return out;

        // Normalise the word separators into a single delimiter first.
        String normalised = input
            .replaceAll('(?i)\\s+and\\s+', ';')
            .replaceAll('\\s*&\\s*',      ';')
            .replaceAll('\\s*,\\s*',      ';');

        for (String part : normalised.split(';')) {
            String v = part == null ? '' : part.trim();
            if (String.isNotBlank(v) && !out.contains(v)) {
                out.add(v);
            }
        }

       
        if (out.isEmpty()) {
            out.add(input.trim());
        }
        return out;
    }

    /******************************************************************************************************
    Method Name:        splitRoleInput
    Description:       Splits role input into candidate role values while preserving known single-role labels.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Splits role input only when it is not an exact single role label from metadata. */
    @testVisible
    private static List<String> splitRoleInput(String input) {
        List<String> single = new List<String>();
        if (String.isBlank(input)) return single;

        String trimmed = input.trim();

        for (Core_MDF_IUPGM_Rule_Config__mdt r :
                [SELECT Core_MDF_Role_Label__c
                 FROM   Core_MDF_IUPGM_Rule_Config__mdt]) {
            if (String.isNotBlank(r.Core_MDF_Role_Label__c)
                && r.Core_MDF_Role_Label__c.trim().equalsIgnoreCase(trimmed)) {
                single.add(trimmed);
                return single;   // genuine single role - never split
            }
        }

        return splitMultiValue(trimmed);
    }

    /******************************************************************************************************
    Method Name:        pluralizeLabel
    Description:       Returns singular/plural wording based on whether the input string contains multiple values.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Returns singular or plural label based on how many values are present. */
    @testVisible
    private static String pluralizeLabel(String singular, String plural, String value) {
        if (String.isBlank(value)) return singular;
        Integer count = 0;
        for (String part : value.split('[;,]')) {
            if (String.isNotBlank(part)) count++;
        }
        return count > 1 ? plural : singular;
    }

     /******************************************************************************************************
    Method Name:        resolveGeoBudgetType
    Description:       Resolves geo-budget selections from payload/query values and normalizes them for validation/storage.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Resolves region-to-budget mapping from structured payload fields and/or natural language query text. */
    @testVisible
    private static String resolveGeoBudgetType(
        Map<String, Object> payload,
        String geo,
        String userQuery,
        String geoBudgetMappingJson,
        List<String> validationErrors
    ) {
        String geoBudgetType = null;

        // Some roles' Geo_Budget_Mapping__c includes a "WW" key alongside real
        // sub-regions (e.g. IPA Exception Reviewer: APJ/ASMO/EMEA/PRC/WW). There is
        // no such thing as a "WW->BudgetType" combo in that case - WW is only a
        // valid Region selection on its own (all-region access), never paired with
        // a specific budget type. When that happens, WW must be expanded into the
        // role's actual sub-regions (data-driven from the mapping itself) so the
        // stored geoBudgetType reads e.g. "APJ->Account Plan;EMEA->Account Plan;...".
        // WW-only roles (e.g. Co-Engineering) whose mapping has ONLY a "WW" key are
        // left untouched - for those, WW->BudgetType is the sole valid combo.
        Set<String> realRegionKeysForWWExpansion = new Set<String>();
        for (String mapKey : parseGeoBudgetJson(geoBudgetMappingJson).keySet()) {
            if (mapKey != 'WW') {
                realRegionKeysForWWExpansion.add(mapKey);
            }
        }

        Object rawSelections = payload.get('geoBudgetSelections');
        if (rawSelections != null) {
            if (rawSelections instanceof String) {
                // LENIENT FORMAT RECOVERY: the caller sent a plain "REGION->BudgetType"
                // (or "REGION->BudgetType;REGION->BudgetType") text string - which is
                // exactly the internal geoBudgetType format - into the geoBudgetSelections
                // field instead of the structured {"REGION": "BudgetType"} object it
                // expects. Rather than hard-failing on a field-name mixup when the VALUE
                // itself is perfectly usable, auto-detect and treat it as geoBudgetType.
                String rawStr = ((String) rawSelections).trim();
                if (rawStr.contains('->')) {
                    List<String> entries = new List<String>();
                    for (String pair : rawStr.split(';')) {
                        pair = pair.trim();
                        if (String.isBlank(pair) || !pair.contains('->')) continue;
                        List<String> parts = pair.split('->');
                        if (parts.size() != 2) continue;
                        String regionPart = parts[0].trim();
                        String budgetPart = parts[1].trim();
                        if (String.isBlank(regionPart) || String.isBlank(budgetPart)) continue;
                        List<String> expandedRegions = expandWWRegionsForBudget(
                            new List<String>{ regionPart }, realRegionKeysForWWExpansion);
                        for (String region : expandedRegions) {
                            entries.add(normalizeRegionKey(region) + '->' + budgetPart);
                        }
                    }
                    if (!entries.isEmpty()) {
                        geoBudgetType = String.join(entries, ';');
                    } else {
                        validationErrors.add('geoBudgetSelections must be an object '
                            + 'like {"APJ": "Account Plan", "EMEA": "Campaign"}, or a '
                            + '"REGION->BudgetType" text value.');
                    }
                } else {
                    validationErrors.add('geoBudgetSelections must be an object '
                        + 'like {"APJ": "Account Plan", "EMEA": "Campaign"}');
                }

            } else {
            try {
                Map<String, Object> selMap = (Map<String, Object>) rawSelections;
                List<String> entries = new List<String>();
                // Collect all unique budget types across all regions first
                // (chatbot may send same types for each region, or one region with all types)
                Set<String> allBudgetTypes = new Set<String>();
                for (String region : selMap.keySet()) {
                    String val = String.valueOf(selMap.get(region)).trim();
                    // Split on semicolon, comma, or " and " to support multi-budget values
                    String cleaned = val.replaceAll('(?i)\\s+and\\s+', ';').replaceAll(',', ';');
                    for (String bt : cleaned.split(';')) {
                        String bTrim = bt.trim();
                        if (String.isNotBlank(bTrim)) {
                            allBudgetTypes.add(bTrim);
                        }
                    }
                }
                // Cross-product: every region Ã— every budget type
                List<String> allRegions = expandWWRegionsForBudget(
                    new List<String>(selMap.keySet()), realRegionKeysForWWExpansion);
                for (String region : allRegions) {
                    for (String bt : allBudgetTypes) {
                        entries.add(normalizeRegionKey(region) + '->' + bt);
                    }
                }
                geoBudgetType = String.join(entries, ';');
            } catch (Exception ex) {
                validationErrors.add('geoBudgetSelections must be an object '
                    + 'like {"APJ": "Account Plan", "EMEA": "Campaign"}');
            }
            }
        }

        if (String.isBlank(geoBudgetType)) {
            geoBudgetType = str(payload, 'geoBudgetType');
        }

        if (String.isBlank(geoBudgetType)) {
            String budgetMappingRaw = str(payload, 'budgetMapping');
            if (String.isBlank(budgetMappingRaw)) {
                budgetMappingRaw = extractBudgetMappingFromQuery(userQuery);
            }
            if (String.isNotBlank(budgetMappingRaw)) {
                geoBudgetType = normalizeGeoBudgetMappingInput(budgetMappingRaw);
            }
        }

        if (String.isBlank(geoBudgetType)) {
            String budgetType = str(payload, 'budgetType');
            if (String.isBlank(budgetType)) budgetType = str(payload, 'budget');
            if (String.isBlank(budgetType) && String.isNotBlank(userQuery)) {
                Map<String, String> parsed = parseUserQuery(userQuery);
                budgetType = parsed.get('budgetType');
            }
            if (String.isBlank(budgetType)) {
                budgetType = tryResolveBareBudgetType(userQuery, geo, geoBudgetMappingJson);
            }
            if (String.isNotBlank(budgetType) && String.isNotBlank(geo)) {
                List<String> entries = new List<String>();
                // Support multiple budget types: "Account Plan;Proposal I MDF" or "Account Plan and Proposal I MDF"
                String budgetTypeCleaned = budgetType
                    .replaceAll('(?i)\\s+and\\s+', ';')
                    .replaceAll(',', ';');
                List<String> budgetTypes = budgetTypeCleaned.split(';');
                List<String> expandedGeoRegions = expandWWRegionsForBudget(
                    new List<String>(geo.split(';')), realRegionKeysForWWExpansion);
                for (String g : expandedGeoRegions) {
                    String gNorm = normalizeRegionKey(g);
                    for (String bt : budgetTypes) {
                        String bTrim = bt.trim();
                        if (String.isNotBlank(bTrim)) {
                            entries.add(gNorm + '->' + bTrim);
                        }
                    }
                }
                geoBudgetType = String.join(entries, ';');
            }
        }

        if (String.isNotBlank(geoBudgetType)) {
            String normalized = normalizeGeoBudgetMappingInput(geoBudgetType);
            if (String.isNotBlank(normalized)) {
                geoBudgetType = normalized;
                payload.put('geoBudgetType', geoBudgetType);
                payload.put('geoBudgetSelections', parseGeoBudgetSelections(geoBudgetType));
            }
        }

        return geoBudgetType;
    }
 /******************************************************************************************************
    Method Name:        expandWWRegionsForBudget
    Description:       Expands a "WW" region token into the role's real sub-regions when building
                        Region->BudgetType entries, since WW is never a valid budget-mapping combo
                        when the role's mapping also defines actual sub-regions. Leaves WW untouched
                        for WW-only roles whose mapping has no other region keys.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Expands "WW" into the role's configured sub-regions for budget-type entries, when applicable. */
    @testVisible
    private static List<String> expandWWRegionsForBudget(
        List<String> regionTokens,
        Set<String> realRegionKeys
    ) {
        List<String> expanded = new List<String>();
        Set<String> seen = new Set<String>();
        for (String token : regionTokens) {
            String norm = normalizeRegionKey(token);
            if (String.isBlank(norm)) continue;
            if (norm == 'WW' && !realRegionKeys.isEmpty()) {
                for (String realRegion : realRegionKeys) {
                    if (seen.add(realRegion)) {
                        expanded.add(realRegion);
                    }
                }
            } else if (seen.add(norm)) {
                expanded.add(norm);
            }
        }
        return expanded;
    }
 /******************************************************************************************************
    Method Name:        extractBudgetMappingFromQuery
    Description:       Extracts region-budget mapping phrases from natural-language request text.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Extracts free-text budget mapping content from user query text when provided. */
    @testVisible
    private static String extractBudgetMappingFromQuery(String query) {
        if (String.isBlank(query)) return null;
        Matcher m = Pattern.compile(
            '(?i)budget\\s+mappings?\\s*(?::|=|\\bis\\b)?\\s*([^\\n]+)'
        ).matcher(query);
        if (!m.find()) return null;
        String extracted = m.group(1);
        if (String.isBlank(extracted)) return null;
        extracted = extracted.replaceAll('[\\.]\\s*$', '').trim();
        return extracted;
    }
 /******************************************************************************************************
    Method Name:        normalizeGeoBudgetMappingInput
    Description:       Normalizes free-form region-budget mapping text into canonical parser-ready format.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Normalizes geo-budget mapping strings into canonical Region->Budget;Region->Budget format. */
    @testVisible
    private static String normalizeGeoBudgetMappingInput(String mappingInput) {
        if (String.isBlank(mappingInput)) return null;
        List<String> normalizedEntries = new List<String>();
        for (String entry : mappingInput.split(';')) {
            String e = entry != null ? entry.trim() : null;
            if (String.isBlank(e)) continue;
            if (e.contains('->')) {
                List<String> parts = e.split('->', 2);
                if (parts.size() == 2
                    && String.isNotBlank(parts[0]) && String.isNotBlank(parts[1])) {
                    normalizedEntries.add(
                        normalizeRegionKey(parts[0]) + '->' + parts[1].trim()
                    );
                }
            }
        }
        return normalizedEntries.isEmpty() ? null : String.join(normalizedEntries, ';');
    }
/******************************************************************************************************
    Method Name:        parseGeoBudgetSelections
    Description:       Parses canonical geo-budget mapping text into a structured region-to-budget map.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Converts normalized geo-budget mapping text into a map used by chatbot response payloads. */
    @testVisible
    private static Map<String, Object> parseGeoBudgetSelections(String geoBudgetType) {
        Map<String, Object> selections = new Map<String, Object>();
        if (String.isBlank(geoBudgetType)) return selections;
        for (String e : geoBudgetType.split(';')) {
            if (String.isBlank(e) || !e.contains('->')) continue;
            List<String> parts = e.split('->', 2);
            if (parts.size() != 2) continue;
            String region = normalizeRegionKey(parts[0]);
            String budget = parts[1] != null ? parts[1].trim() : null;
            if (String.isNotBlank(region) && String.isNotBlank(budget)) {
                selections.put(region, budget);
            }
        }
        return selections;
    }
/******************************************************************************************************
    Method Name:        tryResolveBareBudgetType
    Description:       Attempts to infer a bare budget type from query text when explicit mapping is not provided.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Tries to infer one allowed budget type from free-form query text and selected regions. */
    @testVisible
    private static String tryResolveBareBudgetType(
        String userQuery,
        String geo,
        String geoBudgetMappingJson
    ) {
        if (String.isBlank(userQuery) || String.isBlank(geo)
            || String.isBlank(geoBudgetMappingJson)) {
            return null;
        }
        Map<String, List<String>> allowedByRegion = parseGeoBudgetJson(geoBudgetMappingJson);
        if (allowedByRegion == null || allowedByRegion.isEmpty()) return null;

        List<String> selectedRegions = new List<String>();
        for (String g : geo.split(';')) {
            String key = normalizeRegionKey(g);
            if (String.isNotBlank(key) && allowedByRegion.containsKey(key)) {
                selectedRegions.add(key);
            }
        }
        if (selectedRegions.isEmpty()) return null;

        Set<String> intersection = null;
        Map<String, String> canonicalByNormalized = new Map<String, String>();
        for (String regionKey : selectedRegions) {
            Set<String> regionOptions = new Set<String>();
            for (String opt : allowedByRegion.get(regionKey)) {
                String normalized = normalizeBudgetValue(opt);
                if (String.isNotBlank(normalized)) {
                    regionOptions.add(normalized);
                    if (!canonicalByNormalized.containsKey(normalized)) {
                        canonicalByNormalized.put(normalized, opt);
                    }
                }
            }
            if (intersection == null) {
                intersection = new Set<String>(regionOptions);
            } else {
                intersection.retainAll(regionOptions);
            }
        }
        if (intersection == null || intersection.isEmpty()) return null;

        String normalizedQuery = normalizeBudgetValue(userQuery);
        if (String.isBlank(normalizedQuery)) return null;

        List<String> matches = new List<String>();
        for (String optionNorm : intersection) {
            if (normalizedQuery == optionNorm || normalizedQuery.contains(optionNorm)) {
                matches.add(optionNorm);
            }
        }
        if (matches.size() == 1) {
            return canonicalByNormalized.get(matches[0]);
        }
        return null;
    }

    /******************************************************************************************************
    Method Name:        parseGeoBudgetJson
    Description:       Parses geo-budget mapping metadata JSON into allowed region-to-budget values.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Parses region-to-budget configuration JSON from metadata into an in-memory map. */
    @testVisible
    private static Map<String, List<String>> parseGeoBudgetJson(String jsonStr) {
        Map<String, List<String>> result = new Map<String, List<String>>();
        if (String.isBlank(jsonStr)) return result;
        try {
            Map<String, Object> raw = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
            for (String key : raw.keySet()) {
                List<String> budgets = new List<String>();
                for (Object b : (List<Object>) raw.get(key)) {
                    budgets.add(String.valueOf(b));
                }
                result.put(normalizeRegionKey(key), budgets);
            }
        } catch (Exception ex) {
            System.debug('parseGeoBudgetJson error: ' + ex.getMessage());
        }
        return result;
    }

   /******************************************************************************************************
    Method Name:        validateGeoBudgetEntries
    Description:       Validates requested geo-budget entries against allowed metadata mapping and returns validation errors.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Validates requested Region->Budget entries against the configured allowed mapping. */
    @testVisible
    private static List<String> validateGeoBudgetEntries(
        String geoBudgetInput,
        String geoBudgetMappingJson
    ) {
        List<String> errors = new List<String>();
        if (String.isBlank(geoBudgetInput) || String.isBlank(geoBudgetMappingJson)) {
            return errors;
        }
        Map<String, List<String>> allowed = parseGeoBudgetJson(geoBudgetMappingJson);
        if (allowed == null || allowed.isEmpty()) return errors;
        Map<String, Set<String>> allowedNormalized = new Map<String, Set<String>>();
        for (String regionKey : allowed.keySet()) {
            Set<String> normalizedBudgetSet = new Set<String>();
            for (String budgetOption : allowed.get(regionKey)) {
                normalizedBudgetSet.add(normalizeBudgetValue(budgetOption));
            }
            allowedNormalized.put(normalizeRegionKey(regionKey), normalizedBudgetSet);
        }
        for (String entry : geoBudgetInput.split(';')) {
            String e = entry.trim();
            if (String.isBlank(e)) continue;
            if (!e.contains('->')) {
                errors.add('Invalid budget entry [' + e + ']. Expected Region->BudgetType.');
                continue;
            }
            String[] parts  = e.split('->');
            String   region = normalizeRegionKey(parts[0]);
            String   bType  = parts.size() > 1 ? parts[1].trim() : '';
            if (!allowedNormalized.containsKey(region)) {
                errors.add('Region [' + region + '] not valid for budget mapping. '
                    + 'Valid: ' + String.join(new List<String>(allowed.keySet()), ', '));
                continue;
            }
            String normalizedBType = normalizeBudgetValue(bType);
            if (!allowedNormalized.get(region).contains(normalizedBType)) {
                errors.add('Budget type [' + bType + '] not valid for region ['
                    + region + ']. Allowed: ' + String.join(allowed.get(region), ', '));
            }
        }
        return errors;
    }
/******************************************************************************************************
    Method Name:        normalizeRegionKey
    Description:       Normalizes region names into uppercase comparison keys.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Normalizes region text to uppercase key format for reliable comparisons. */
    @testVisible
    private static String normalizeRegionKey(String region) {
        return String.isBlank(region) ? '' : region.trim().toUpperCase();
    }

   /******************************************************************************************************
    Method Name:        normalizeGeoString
    Description:       Normalizes geo input into a semicolon-delimited uppercase format.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Normalizes geo input into semicolon-delimited uppercase values. */
    @testVisible
    private static String normalizeGeoString(String geo) {
        if (String.isBlank(geo)) return null;
        // Replace commas (with optional spaces) with semicolons
        String normalized = geo.replaceAll('\\s*,\\s*', ';').replaceAll('\\s*;\\s*', ';').trim();
        List<String> parts = new List<String>();
        for (String g : normalized.split(';')) {
            String t = g.trim().toUpperCase();
            if (String.isNotBlank(t)) parts.add(t);
        }
        return parts.isEmpty() ? null : String.join(parts, ';');
    }
  /******************************************************************************************************
    Method Name:        normalizeBudgetValue
    Description:       Normalizes budget labels for case-insensitive validation and matching.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Normalizes budget labels for case-insensitive comparisons. */
    @testVisible
    private static String normalizeBudgetValue(String budgetType) {
        if (String.isBlank(budgetType)) return '';
        String normalized = budgetType.trim();
        normalized = normalized.replaceAll('^[^a-zA-Z0-9]+', '');
        normalized = normalized.replaceAll('[^a-zA-Z0-9]+$', '');
        normalized = normalized.replaceAll('\\s+', ' ');
        return normalized.toLowerCase();
    }

    /******************************************************************************************************
    Method Name:        resolveAgsRoles
    Description:       Resolves AGS role names for the selected role/program/region and handles regional fallbacks.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Resolves AGS role names by selected regions, with fallback to the default AGS role. */
    @testVisible
    private static List<String> resolveAgsRoles(
        String regionAgsRoleMapJson,
        String selectedRegions,
        String defaultAgsRole
    ) {
        List<String> roles = new List<String>();
        if (String.isBlank(regionAgsRoleMapJson)) {
            if (String.isNotBlank(defaultAgsRole)) roles.add(defaultAgsRole.trim());
            return roles;
        }
        Map<String, String> regionToRole = new Map<String, String>();
        try {
            Map<String, Object> raw =
                (Map<String, Object>) JSON.deserializeUntyped(regionAgsRoleMapJson);
            for (String key : raw.keySet()) {
                regionToRole.put(key.trim(), String.valueOf(raw.get(key)).trim());
            }
        } catch (Exception ex) {
            System.debug('resolveAgsRoles parse error: ' + ex.getMessage());
            if (String.isNotBlank(defaultAgsRole)) roles.add(defaultAgsRole.trim());
            return roles;
        }
        Set<String> seen = new Set<String>();
        if (String.isNotBlank(selectedRegions)) {
            for (String r : selectedRegions.split(';')) {
                String region  = r.trim();
                String agsRole = regionToRole.get(region);
                if (String.isNotBlank(agsRole) && !seen.contains(agsRole)) {
                    seen.add(agsRole);
                    roles.add(agsRole);
                }
            }
        }
        if (roles.isEmpty() && String.isNotBlank(defaultAgsRole)) {
            roles.add(defaultAgsRole.trim());
        }
        return roles;
    }

    /******************************************************************************************************
    Method Name:        parseUserQuery
    Description:       Extracts structured request attributes (program, role, geo, budget, account signals) from user query text.
    Added By:           Ramapriya
    *******************************************************************************************************/
    @testVisible
    private static Map<String, String> parseUserQuery(String query) {
        Map<String, String> result = new Map<String, String>{
            'program'            => null,
            'roleLabel'          => null,
            'geo'                => null,
            'geoExplicit'        => 'false',
            'allAccountAccess'   => null,
            'allAccountExplicit' => 'false',
            'accountName'        => null,
            'accountExplicit'    => 'false',
            'budgetType'         => null,
            'budgetTypeExplicit' => 'false',
            'allBudgetAccess'    => null,
            'allBudgetExplicit'  => 'false'
        };
        if (String.isBlank(query)) return result;
        
        query = query.replaceAll(
            '[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}', ' ');

        
        Pattern geoPattern = Pattern.compile(
            '(?i)(?:regions?|geo)\\s*:\\s*(?-i)([A-Z][A-Z0-9\\-]{1,12}(?:\\s*[;,]\\s*[A-Z][A-Z0-9\\-]{1,12})*)');
        Matcher geoMatcher = geoPattern.matcher(query);
        if (geoMatcher.find()) {
            // Normalize to semicolon-separated: "APJ, EMEA, PRC" â†’ "APJ;EMEA;PRC"
            String rawGeo = geoMatcher.group(1).trim();
            rawGeo = rawGeo.replaceAll('\\s*[,;]\\s*', ';');
            result.put('geo', rawGeo);
            result.put('geoExplicit', 'true');
        }

        // Extract allAccountAccess - e.g. "All Accounts: true" or "All Accounts: All Accounts"
        Pattern allAcctPattern = Pattern.compile(
            '(?i)all\\s+accounts?\\s*:\\s*(true|false|yes|no|all|specific)');
        Matcher allAcctMatcher = allAcctPattern.matcher(query);
        if (allAcctMatcher.find()) {
            String val = allAcctMatcher.group(1).trim().toLowerCase();
            result.put('allAccountAccess',
                (val == 'true' || val == 'yes' || val == 'all') ? 'true' : 'false');
            result.put('allAccountExplicit', 'true');
        }

        // Extract accountName - e.g. "Account: Positivo Tecnologia SA"
        // (stop before comma, period, or end of string)
        Pattern acctPattern = Pattern.compile(
            '(?i)account\\s*:\\s*([^,\\.\\n]+)');
        Matcher acctMatcher = acctPattern.matcher(query);
        if (acctMatcher.find()) {
            String acctVal = acctMatcher.group(1).trim();
            // Exclude if it looks like a boolean (already handled by allAccountAccess)
            if (!acctVal.equalsIgnoreCase('true') && !acctVal.equalsIgnoreCase('false')
                && !acctVal.equalsIgnoreCase('all') && !acctVal.equalsIgnoreCase('all accounts')) {
                result.put('accountName', acctVal);
                result.put('accountExplicit', 'true');
            }
        }

        // Extract budget type - e.g. "Budget Type: Account Plan", "Budget Types: Account Plan, Proposal I MDF"
        // Requires an explicit separator (:, =, or "is") so colloquial phrases like
        // "the budget type again as Account Plan for the regions APJ and ASMO" don't
        // capture the whole sentence as the budget type value.
        // Stored as plain string; caller combines with geo to build geoBudgetSelections map.
        Pattern budgetPattern = Pattern.compile(
            '(?i)budget\\s+type(?:s|(?:\\s+access))?\\s*(?::|=|\\bis\\b)\\s*([^\\n]+)');
        Matcher budgetMatcher = budgetPattern.matcher(query);
        if (budgetMatcher.find()) {
            // Trim trailing period/comma and normalize "and" as separator
            String rawBt = budgetMatcher.group(1).trim().replaceAll('[\\.,]+$', '');
            result.put('budgetType', rawBt);
            result.put('budgetTypeExplicit', 'true');
        }

        // Detect "all budget access" / "all budget type(s)" in query text so that
        // a stale allBudgetAccess: false from a prior-turn requestSummary can be
        // overridden when the user explicitly says "all budget access".
        // e.g. "all budget access", "all budget types", "all budget type access"
        if (Pattern.compile('(?i)\\ball\\s+budget(?:\\s+type(?:s|(?:\\s+access))?)?\\b')
                .matcher(query).find()) {
            result.put('allBudgetAccess', 'true');
            result.put('allBudgetExplicit', 'true');
        }

        // Normalise for program/role extraction: lowercase, collapse whitespace, strip punctuation
        String normalised = query.toLowerCase()
            .replaceAll('[^a-z0-9\\- ]', ' ')
            .replaceAll('\\s+', ' ')
            .trim();

        // â”€â”€ 1. Try multi-word program phrases first (longest match wins) â”€â”€â”€â”€
        // Ordered longest â†’ shortest so "data center" doesn't lose to "datacenter"
        List<String> multiWordPhrases = new List<String>{
            'intel partner alliance',
            'retail marketing funds',
            'datacenter co-marketing fund',
            'datacenter co marketing fund',
            'dcf co-marketing fund',
            'client co-marketing fund',
            'client co marketing fund',
            'data center',
            'co-gtm',
            'co gtm'
        };
        Map<String, String> phraseToAlias = new Map<String, String>{
            'intel partner alliance'          => 'IPA',
            'retail marketing funds'          => 'RMF',
            'datacenter co-marketing fund'    => 'DCF',
            'datacenter co marketing fund'    => 'DCF',
            'dcf co-marketing fund'           => 'DCF',
            'client co-marketing fund'        => 'CCF',
            'client co marketing fund'        => 'CCF',
            'data center'                     => 'DCF',
            'co-gtm'                          => 'COGTM',
            'co gtm'                          => 'COGTM'
        };

        String detectedAlias = null;
        String strippedQuery = normalised;

        for (String phrase : multiWordPhrases) {
            if (normalised.contains(phrase)) {
                detectedAlias = phraseToAlias.get(phrase);
                strippedQuery = normalised.replace(phrase, ' ');
                break;
            }
        }

        // â”€â”€ 2. Single-word program tokens if no phrase matched â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if (detectedAlias == null) {
            Map<String, String> singleTokens = new Map<String, String>{
                'ipa'         => 'IPA',
                'ccf'         => 'CCF',
                'dcf'         => 'DCF',
                'rmf'         => 'RMF',
                'cogtm'       => 'COGTM',
                'client'      => 'CCF',
                'datacenter'  => 'DCF',
                'retail'      => 'RMF'
            };
            List<String> tokens = strippedQuery.split(' ');
            List<String> kept   = new List<String>();
            for (String t : tokens) {
                if (detectedAlias == null && singleTokens.containsKey(t)) {
                    detectedAlias = singleTokens.get(t);
                    // Don't add this token to kept - it's the program
                } else {
                    kept.add(t);
                }
            }
            strippedQuery = String.join(kept, ' ');
        }

        result.put('program', detectedAlias);

        // â”€â”€ 3. Strip stop words - what's left is the role hint â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Set<String> stopWords = new Set<String>{
            'i','me','my','we','our','you','he','she','they',
            'want','need','get','give','request','require','have',
            'access','to','for','a','an','the','some','any',
            'please','can','could','would','like','with',
            'role','permission','in','of','and','or','is','be','am','are'
        };

        List<String> roleTokens = new List<String>();
        for (String t : strippedQuery.trim().split('\\s+')) {
            if (String.isNotBlank(t) && !stopWords.contains(t)) {
                roleTokens.add(t);
            }
        }

        if (!roleTokens.isEmpty()) {
            result.put('roleLabel', String.join(roleTokens, ' '));
        }

        return result;
    }
/******************************************************************************************************
    Method Name:        extractNewUserIdentity
    Description:       Extracts potential new-user identity attributes (name/federation/email) from natural-language input.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Extracts prospective user full name and federation id tokens from free-form query text. */
    @testVisible
    private static Map<String, String> extractNewUserIdentity(String query) {
        Map<String, String> result = new Map<String, String>{
            'fullName' => null,
            'federationId' => null
        };
        if (String.isBlank(query)) return result;

        Matcher fedMatcher = Pattern.compile(
            '(?i)(?:federation\\s*id|federation|enterprise\\s*id)\\s*[:=]\\s*([a-zA-Z0-9._\\-]+)'
        ).matcher(query);
        if (fedMatcher.find()) {
            result.put('federationId', fedMatcher.group(1).trim());
        }

        Matcher nameMatcher = Pattern.compile(
            '(?i)(?:full\\s*name|name)\\s*[:=]\\s*([^,\\.\\n\\(]+)'
        ).matcher(query);
        if (nameMatcher.find()) {
            result.put('fullName', nameMatcher.group(1).trim());
        }

        // Fallback: chatbot often phrases requests as
        // "... for Jane Doe (email: jane@intel.com) ..." with no "name:" label.
        // Capture the capitalized word sequence immediately preceding "(email".
        if (result.get('fullName') == null) {
            Matcher nameBeforeEmail = Pattern.compile(
                '([A-Z][A-Za-z.\'\\-]*(?:\\s+[A-Z][A-Za-z.\'\\-]*){0,4})\\s*\\(\\s*(?:email|e-mail)\\s*[:=]'
            ).matcher(query);
            if (nameBeforeEmail.find()) {
                result.put('fullName', nameBeforeEmail.group(1).trim());
            }
        }

        // Fallback: "... for Jane Doe," / "... for Jane Doe to ..." - a
        // capitalized 2-4 word name directly following "for", not already
        // captured above.
        if (result.get('fullName') == null) {
            Matcher nameAfterFor = Pattern.compile(
                '(?i)\\bfor\\s+([A-Z][A-Za-z.\'\\-]*(?:\\s+[A-Z][A-Za-z.\'\\-]*){0,3})' +
                '(?=\\s*(?:\\(|,|\\.|$|\\s+to\\b|\\s+for\\b))'
            ).matcher(query);
            if (nameAfterFor.find()) {
                result.put('fullName', nameAfterFor.group(1).trim());
            }
        }

        return result;
    }
/******************************************************************************************************
    Method Name:        deriveFederationFromEmail
    Description:       Derives federation id from email when explicit federation id is not provided.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Derives federation id from the email local part when explicit federation id is not provided. */
    @testVisible
    private static String deriveFederationFromEmail(String email) {
        if (String.isBlank(email) || !email.contains('@')) return null;
        String fed = email.substringBefore('@');
        return String.isNotBlank(fed) ? fed.trim() : null;
    }
/******************************************************************************************************
    Method Name:        parseBool
    Description:       Converts flexible payload values to Boolean with support for string and typed inputs.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Parses flexible boolean-like values from payload fields. */
    @testVisible
    private static Boolean parseBool(Object val) {
        if (val == null) return false;
        if (val instanceof Boolean) return (Boolean) val;
        String s = String.valueOf(val).trim().toLowerCase();
        return (s == 'true' || s == 'yes' || s == 'all' || s == '1');
    }
/******************************************************************************************************
    Method Name:        isAffirmativeConfirmation
    Description:       Detects affirmative confirmation intent while filtering out negations and unrelated field values.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Detects confirm/submit intent while excluding negations and data-collection replies. */
    @testVisible
    private static Boolean isAffirmativeConfirmation(String query) {
        if (String.isBlank(query)) return false;
        String q = query.toLowerCase();
        Boolean hasAffirmativeToken =
            q.contains('yes')
            || q.contains('confirm')
            || q.contains('proceed')
            || q.contains('submit');
        if (!hasAffirmativeToken) return false;
        // Negation guard
        if (q.contains(' no ')
            || q.startsWith('no ')
            || q.contains(' cancel')
            || q.contains(' do not ')
            || q.contains(' don\'t ')
            || q.contains('dont ')) {
            return false;
        }
       
        if (q.contains('budget type')
            || q.contains('account plan')
            || q.contains('proposal')
            || q.contains(' mdf')
            || q.contains('region:')
            || q.contains('regions:')
            || q.contains('all accounts:')
            || q.contains('approval region')
            || q.contains('activity classif')) {
            return false;
        }
        return true;
    }

    /******************************************************************************************************
    Method Name:        isNegativeReply
    Description:       Detects a clear decline/negative reply (counterpart to isAffirmativeConfirmation).
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Detects a clear "no"/decline reply, e.g. when a user is asked a yes/no follow-up question. */
    @testVisible
    private static Boolean isNegativeReply(String query) {
        if (String.isBlank(query)) return false;
        String q = ' ' + query.toLowerCase().trim() + ' ';
        return q.contains(' no ')
            || q.contains(' nope ')
            || q.contains(' cancel')
            || q.contains(' do not ')
            || q.contains(' don\'t ')
            || q.contains(' dont ')
            || q.contains(' stop ')
            || q.contains(' never mind')
            || q.contains(' nevermind');
    }

   /******************************************************************************************************
    Method Name:        isStartAffirmative
    Description:       Detects leading affirmative action phrases that indicate user confirmation.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Detects affirmative commands at the beginning of a query string. */
    @testVisible
    private static Boolean isStartAffirmative(String query) {
        if (String.isBlank(query)) return false;
        String q = query.trim().toLowerCase();
        // Negation guard first
        if (q.startsWith('no ') || q.equals('no')
            || q.contains(' cancel') || q.contains(' do not ')
            || q.contains(' don\'t ') || q.contains('dont ')) {
            return false;
        }
        return q.startsWith('yes')
            || q.startsWith('confirm')
            || q.startsWith('proceed')
            || q.startsWith('submit')
            || q.startsWith('approved')
            || q.startsWith('agree');
    }

    /** Safely reads and trims a string value from a generic payload map. */
    @testVisible
    private static String str(Map<String, Object> m, String key) {
        Object val = m.get(key);
        return val != null ? String.valueOf(val).trim() : null;
    }

  /******************************************************************************************************
    Method Name:        resolveOption
    Description:       Resolves numeric/label role selections against provided option lists and validates selection.
    Added By:           Ramapriya
    *******************************************************************************************************/
    @testVisible
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
        List<String> partialMatches = new List<String>();
        for (String opt : validOptions) {
            if (opt.toLowerCase().contains(inputLower)
                || inputLower.contains(opt.toLowerCase())) {
                partialMatches.add(opt);
            }
        }
        if (partialMatches.size() == 1) {
            return partialMatches[0];
        }
        if (partialMatches.size() > 1) {
            // Ambiguous partial match - re-ask rather than guess wrong
            throw new IllegalArgumentException(
                'Your input "' + userInput + '" matches multiple options: '
                + String.join(partialMatches, ', ')
                + '. Please reply with the number or the exact name.'
            );
        }

        // No match found
        throw new IllegalArgumentException(
            'Invalid selection [' + userInput + ']. '
            + 'Valid options: ' + String.join(validOptions, ', ')
        );
    }

    /** Serializes a standard error response shape used by this REST API. */
    @testVisible
    private static String err(String message) {
        return JSON.serialize(new Map<String, Object>{
            'success' => false,
            'message' => message
        });
    }

/**
 * Shared outcome DTO for the role-resolution pipeline (RETRIEVAL + AI
 * augmentation/reranking). Used by BOTH the public recommendRole() agent
 * endpoint AND the internal auto-resolution hook inside validateAccessRequest
 * (see resolveRoleCandidates()) so there is a single implementation of "figure
 * out the role from free text" - validateAccessRequest never re-implements
 * its own search, it only ever calls this same engine.
 */

/**
 * Builds the user-facing message for the mandatory role-confirmation gate.
 * Whenever a role is INFERRED (not explicitly given by the caller), the
 * system must stop and ask the user to confirm that specific role before
 * proceeding to collect any other fields. Phrased purely as a forward-
 * looking question - it never echoes back whatever the caller originally
 * typed (e.g. an invalid/partial role phrase), and it deliberately uses the
 * role's own PURPOSE text (a plain description of what the role does) -
 * never the AI's internal matching rationale (e.g. "this explicitly
 * matches your request"), which reads like the system explaining its own
 * reasoning rather than describing the role in natural language.
 */
private static String buildRoleConfirmationMessage(String roleLabel, String reason, String purpose) {
    return 'Could you confirm this is the role you\'re looking for: "' + roleLabel + '"'
        + (String.isNotBlank(purpose) ? ' - ' + purpose : '')
        + '? Reply YES to confirm, or let me know the correct role if this is not what you meant.';
}

/**
 * Builds the user-facing question when MULTIPLE plausible roles are found for a
 * free-text request. Always uses a fixed, natural, generic question - it never
 * echoes back whatever the caller originally typed (e.g. an invalid/partial role
 * phrase like "IPA"), and it does NOT surface the AI's own internal clarification
 * wording (which can read like the system explaining its matching logic).
 * Confidence scores and match-reasoning text are intentionally NOT included -
 * only the role label and its plain-language purpose are shown.
 */
@testVisible
private static String buildRoleOptionsQuestion(List<Map<String, Object>> recommendations, String clarificationQuestion) {
    List<String> lines = new List<String>();
    Integer idx = 1;
    for (Map<String, Object> rec : recommendations) {
        String lbl     = (String) rec.get('label') != null ? (String) rec.get('label') : (String) rec.get('roleLabel');
        String purpose = (String) rec.get('purpose');
        lines.add(idx + '. ' + lbl + (String.isNotBlank(purpose) ? ' - ' + purpose : ''));
        idx++;
    }
    return 'Could you clarify whether you are looking for any of these roles for your request?\n'
        + String.join(lines, '\n')
        + '\nPlease reply with the number or name, or let me know more details if none of these fit.';
}

/**
 * Confidence threshold (as a whole-number percentage, e.g. 80 = 80%) below which
 * an AI role recommendation is discarded before ever being shown to a user.
 * Configurable via Custom Metadata (Core_MDF_Custom_Label_Configration__mdt,
 * label "Core_MDF_IUPGM_RoleReco_Confidence_Threshold") so it can be tuned
 * without a code deployment. Defaults to 80 if the record is missing/invalid.
 */
@testVisible
private static Integer getRoleRecoConfidenceThresholdPercent() {
    try {
        Integer configured = Core_MDF_CustomLabelConfig.getIntegerValues(
            'Core_MDF_IUPGM_RoleReco_MinConf');
        return configured != null ? configured : 80;
    } catch (Exception ex) {
        return 80;
    }
}

private class RoleResolutionOutcome {
    public Boolean found                  = false;
    public Boolean usedAI                 = false;
    public Boolean highConfidence         = false;
    public String  resolvedRoleLabel;     // set only when exactly one confident candidate exists
    public String  resolvedRoleReason;     // AI's stated reason for the resolvedRoleLabel, when available
    public String  resolvedRoleProgram;
    public String  resolvedRolePurpose;
    public String  rewrittenQuery;
    public Boolean needsClarification     = false;
    public String  clarificationQuestion;
    public String  message;               // populated when found = false
    public List<Map<String, Object>> recommendations = new List<Map<String, Object>>();
}

/**
 * RETRIEVAL + AUGMENTATION/GENERATION/RERANKING pipeline shared by
 * recommendRole() and validateAccessRequest's internal auto-resolution hook.
 * Contains no RestResponse/HTTP-status concerns - callers decide the response
 * shape/status code for their own context.
 */
@testVisible
private static RoleResolutionOutcome resolveRoleCandidates(String query, String programFilter) {
    RoleResolutionOutcome outcome = new RoleResolutionOutcome();

    // ── RETRIEVAL: deterministic metadata filter + keyword scoring ──
    // Strip email addresses first - a target user's email embedded in the
    // sentence (e.g. "role access for jane.doe@intel.com for IPA program")
    // is never role-describing content. Left in, it pollutes both the
    // browse-mode detection below (its local-part words look "meaningful")
    // and the keyword scoring itself (e.g. "intel" coincidentally matching
    // unrelated purpose text).
    String queryForTokens = query.replaceAll('(?i)\\S+@\\S+\\.[a-zA-Z]{2,}', ' ');
    List<String> tokens = new List<String>();
    for (String word : queryForTokens.toLowerCase().replaceAll('[^a-z0-9 ]', ' ').split('\\s+')) {
        if (word.length() > 2) tokens.add(word); // skip stop words (the, is, a...)
    }

    if (tokens.isEmpty()) {
        outcome.message = 'Query contains no meaningful keywords. Please describe what you want to do.';
        return outcome;
    }

    List<Core_MDF_IUPGM_Rule_Config__mdt> configs = [
        SELECT  MasterLabel,
                Core_MDF_Role_Label__c,
                Core_MDF_Permission_Set_Name__c,
                Core_MDF_Role_Purpose__c,
                Core_MDF_Use_Cases__c,
                Core_MDF_Keywords__c,
                Core_MDF_AGS_Role_Name__c,
                Core_MDF_Program__c,
                Core_MDF_Account_Required__c,
                Core_MDF_All_Accounts__c,
                Core_MDF_WW_Only__c,
                Core_MDF_Region_Options__c,
                Core_MDF_Budget_Required_When_False__c,
                Core_MDF_Approval_Region_Required__c,
                Core_MDF_Activity_Classification_Req__c,
                Core_MDF_Is_Active__c
        FROM    Core_MDF_IUPGM_Rule_Config__mdt
        WHERE   Core_MDF_Is_Active__c = true
    ];

    /*
    ====================================================================
    BROWSE MODE (program-only request, no distinguishing role details)
    --------------------------------------------------------------------
    If every token left after stripping generic request words ("role",
    "access", "need"...) and the program's own name/aliases is empty,
    the caller hasn't actually described a role at all - they've only
    named a program (e.g. "I want role access for the IPA program").
    Guessing a role via keyword scoring would be wrong here; instead,
    deterministically list every active role for that program so the
    user can pick one - reusing the SAME "multiple candidates" selection
    flow (ROLE_NEEDS_SELECTION) already used elsewhere. Mirrors the
    dedicated browse mode on GET recommendRole(), but reachable from the
    POST validateRequest auto-resolution path that the chatbot actually
    calls.
    ====================================================================
    */
    Set<String> genericRoleSearchTokens = new Set<String>{
        'role', 'roles', 'access', 'need', 'needs', 'want', 'wants',
        'give', 'grant', 'granting', 'provide', 'providing', 'request',
        'requesting', 'requested', 'program', 'user', 'users', 'for',
        'the', 'account', 'permission', 'permissions', 'assign',
        'assigning', 'raise', 'create', 'like', 'would', 'get', 'getting',
        'ipa', 'ccf', 'dcf', 'rmf', 'cogtm', 'client', 'datacenter', 'data',
        'center', 'retail', 'marketing', 'funds', 'fund', 'intel',
        'partner', 'alliance', 'gtm', 'common', 'new', 'this', 'that'
    };
    List<String> meaningfulSearchTokens = new List<String>();
    for (String tok : tokens) {
        if (!genericRoleSearchTokens.contains(tok)) meaningfulSearchTokens.add(tok);
    }

    if (meaningfulSearchTokens.isEmpty() && String.isNotBlank(programFilter)) {
        List<Map<String, Object>> browseResults = new List<Map<String, Object>>();
        for (Core_MDF_IUPGM_Rule_Config__mdt r : configs) {
            // Strict program match only - browse mode must list ONLY roles that
            // explicitly belong to the requested program, not generic/COMMON
            // roles that happen to apply everywhere. (isProgramMatchOrCommon is
            // intentionally NOT used here - that helper is for exact-role
            // lookups, where COMMON roles are legitimately reachable from any
            // program. A "list all roles for this program" browse should stay
            // scoped to that program.)
            if (String.isBlank(r.Core_MDF_Program__c)
                || !r.Core_MDF_Program__c.trim().equalsIgnoreCase(programFilter.trim())) {
                continue;
            }
            browseResults.add(new Map<String, Object>{
                'roleLabel' => r.Core_MDF_Role_Label__c,
                'program'   => displayProgramLabel(r.Core_MDF_Program__c),
                'purpose'   => r.Core_MDF_Role_Purpose__c
            });
        }
        if (!browseResults.isEmpty()) {
            outcome.found              = true;
            outcome.usedAI             = false;
            outcome.recommendations    = browseResults;
            outcome.highConfidence     = browseResults.size() == 1;
            outcome.needsClarification = true;
            outcome.clarificationQuestion = 'Which role would you like for this program?';
            if (outcome.highConfidence) {
                outcome.resolvedRoleLabel   = (String) browseResults[0].get('roleLabel');
                outcome.resolvedRoleProgram = (String) browseResults[0].get('program');
                outcome.resolvedRolePurpose = (String) browseResults[0].get('purpose');
            }
            return outcome;
        }
        // No active roles at all for this program - fall through to the
        // normal keyword flow below (which will also find nothing and
        // return the standard "no roles matched" message).
    }

            // Score each config record
            List<Map<String, Object>> scored = new List<Map<String, Object>>();

    for (Core_MDF_IUPGM_Rule_Config__mdt cfg : configs) {

        // Optional program filter
        if (String.isNotBlank(programFilter)
            && !isProgramMatchOrCommon(cfg.Core_MDF_Program__c, programFilter)) {
            continue;
        }

                // Build searchable text from all recommendation fields, including the
                // AGS role name - some callers type the AGS entitlement name (e.g.
                // "Co-Marketing(Salesforce)-Price Reviewer") instead of the internal
                // role label, and this must resolve just as reliably.
                String searchText = String.join(new List<String>{
                    cfg.Core_MDF_Keywords__c    != null ? cfg.Core_MDF_Keywords__c    : '',
                    cfg.Core_MDF_Role_Purpose__c != null ? cfg.Core_MDF_Role_Purpose__c : '',
                    cfg.Core_MDF_Use_Cases__c    != null ? cfg.Core_MDF_Use_Cases__c    : '',
                    cfg.Core_MDF_Role_Label__c   != null ? cfg.Core_MDF_Role_Label__c   : '',
                    cfg.Core_MDF_AGS_Role_Name__c != null ? cfg.Core_MDF_AGS_Role_Name__c : ''
                }, ' ').toLowerCase();

        // Count matching tokens
        Integer score = 0;
        for (String token : tokens) {
            if (searchText.contains(token) || fuzzyTokenMatches(token, searchText)) score++;
        }

        if (score > 0) {
            scored.add(new Map<String, Object>{ 'score' => score, 'record' => cfg });
        }
    }

    if (scored.isEmpty()) {
        outcome.message = 'No roles matched your query. Try different keywords or browse all '
            + 'roles by calling with a program only (no query parameter).';
        return outcome;
    }

    // Sort by keyword score desc (bubble sort - small list, SOQL already
    // filtered) - this is the best-first candidate order handed to the AI stage.
    for (Integer i = 0; i < scored.size() - 1; i++) {
        for (Integer j = i + 1; j < scored.size(); j++) {
            if ((Integer) scored[j].get('score') > (Integer) scored[i].get('score')) {
                Map<String, Object> tmp = scored[i];
                scored[i] = scored[j];
                scored[j] = tmp;
            }
        }
    }

    List<Core_MDF_IUPGM_Rule_Config__mdt> candidates = new List<Core_MDF_IUPGM_Rule_Config__mdt>();
    for (Map<String, Object> s : scored) {
        candidates.add((Core_MDF_IUPGM_Rule_Config__mdt) s.get('record'));
    }

    // ── AUGMENTATION + GENERATION/RERANKING (AI) ────────────────────
    // The already-narrowed, best-first candidate set is handed to the AI
    // service, which augments each candidate with its full contextual
    // document and asks the existing GenAI endpoint to rank/explain them.
    // It may ONLY select from these verified candidates (enforced both by
    // prompt instruction and by post-response verification in the
    // service).
    Core_MDF_IUPGMRoleRecommendationService.RecommendationResult aiResult =
        Core_MDF_IUPGMRoleRecommendationService.recommend(queryForTokens, candidates);

    Boolean aiReached = aiResult != null && aiResult.calloutSucceeded;

    // CONFIDENCE THRESHOLD FILTER: only recommendations at/above the configured
    // threshold (Custom Metadata "Core_MDF_IUPGM_RoleReco_Confidence_Threshold",
    // default 80%) are ever surfaced. Confidence numbers themselves are used only
    // internally for this filtering/ranking - they are NEVER included in any
    // response returned to the chatbot/user (see topResults construction below,
    // which intentionally omits 'confidence').
    Decimal confidenceThreshold = getRoleRecoConfidenceThresholdPercent() / 100.0;
    List<Core_MDF_IUPGMRoleRecommendationService.RoleRecommendation> qualifyingRecs =
        new List<Core_MDF_IUPGMRoleRecommendationService.RoleRecommendation>();
    if (aiReached && aiResult.success) {
        for (Core_MDF_IUPGMRoleRecommendationService.RoleRecommendation rec : aiResult.recommendations) {
            if (rec.confidence != null && rec.confidence >= confidenceThreshold) {
                qualifyingRecs.add(rec);
            }
        }
    }
    Boolean usedAI = aiReached && !qualifyingRecs.isEmpty();

    /*
    ============================================================
    IMPORTANT: aiReached vs usedAI.
    - aiReached  = the model was actually consulted (HTTP 200 +
      parseable JSON), regardless of what it decided.
    - usedAI     = the model was consulted AND at least one of its
      recommendations met the confidence threshold above.

    If the model WAS reached but legitimately found no match meeting the
    threshold (aiReached && !usedAI) - whether because it found nothing at
    all, or only found candidates it wasn't confident enough about - that is
    a genuine, deliberate "no match" answer - NOT a technical failure - and
    must be respected as-is. Falling back to the broader deterministic
    keyword list in that case would silently override the AI's judgement
    and reintroduce the exact "unrelated roles get suggested" bug this
    design exists to prevent (e.g. a garbage role phrase that only shares
    one generic word, like "Activity", with real roles).

    The deterministic keyword-scored fallback is used ONLY when the
    AI could not be reached at all (network/timeout/parse failure)
    - a true infrastructure outage, not a content judgement. Even
    then, it only surfaces candidates where ALL meaningful query
    tokens match the role label (mirrors the original role-not-
    found fix) - never a loose "any single word matched" list.
    ============================================================
    */
    List<Map<String, Object>> topResults = new List<Map<String, Object>>();

    if (usedAI) {
        for (Core_MDF_IUPGMRoleRecommendationService.RoleRecommendation rec : qualifyingRecs) {
            topResults.add(new Map<String, Object>{
                'roleLabel' => rec.roleLabel,
                'program'   => displayProgramLabel(rec.program),
                'purpose'   => rec.purpose,
                'reason'    => rec.reason
                // 'confidence' intentionally NOT included - internal use only.
            });
        }

    } else if (aiReached) {
        // The AI was consulted and deliberately found nothing that met the
        // confidence threshold.
        outcome.found                 = false;
        outcome.usedAI                = true;
        outcome.rewrittenQuery        = aiResult.rewrittenQuery;
        outcome.needsClarification    = aiResult.needsClarification;
        outcome.clarificationQuestion = aiResult.clarificationQuestion;
        outcome.message               = aiResult.needsClarification && String.isNotBlank(aiResult.clarificationQuestion)
            ? aiResult.clarificationQuestion
            : 'No confident role match was found for your query. '
                + 'Try describing what you want to do differently, or browse '
                + 'all roles by calling with a program only (no query parameter).';
        return outcome;

    } else {
        // True technical failure (AI unreachable) - deterministic fallback,
        // but still gated by the "all meaningful tokens must match" rule so a
        // single generic shared word cannot surface unrelated roles.
        List<String> meaningfulTokens = new List<String>();
        for (String t : tokens) {
            if (String.isNotBlank(t) && t != 'ccp') meaningfulTokens.add(t);
        }
        List<Core_MDF_IUPGM_Rule_Config__mdt> strictMatches = new List<Core_MDF_IUPGM_Rule_Config__mdt>();
        for (Core_MDF_IUPGM_Rule_Config__mdt c : candidates) {
            String labelLower = c.Core_MDF_Role_Label__c != null
                ? c.Core_MDF_Role_Label__c.toLowerCase() : '';
            Boolean allMatch = true;
            for (String t : meaningfulTokens) {
                if (!labelLower.contains(t) && !fuzzyTokenMatches(t, labelLower)) {
                    allMatch = false;
                    break;
                }
            }
            if (allMatch) strictMatches.add(c);
        }

        if (strictMatches.isEmpty()) {
            outcome.usedAI  = false;
            outcome.message = 'No roles matched your query and the AI service was '
                + 'temporarily unavailable. Try different keywords or browse all '
                + 'roles by calling with a program only (no query parameter).';
            return outcome;
        }

        for (Integer i = 0; i < Math.min(5, strictMatches.size()); i++) {
            Core_MDF_IUPGM_Rule_Config__mdt cfg = strictMatches[i];
            topResults.add(new Map<String, Object>{
                'roleLabel' => cfg.Core_MDF_Role_Label__c,
                'program'   => displayProgramLabel(cfg.Core_MDF_Program__c),
                'purpose'   => cfg.Core_MDF_Role_Purpose__c
            });
        }
    }

    // High confidence = exactly one candidate, or the AI gave a strong,
    // clearly-separated top pick. Otherwise the chatbot should present
    // the list and ask the user to select. Uses qualifyingRecs (already
    // threshold-filtered) so a strong-but-below-threshold second option
    // never affects this comparison.
    Decimal topConfidence    = usedAI ? qualifyingRecs[0].confidence : null;
    Decimal secondConfidence = (usedAI && qualifyingRecs.size() > 1)
        ? qualifyingRecs[1].confidence : null;
    Boolean highConfidence = topResults.size() == 1
        || (usedAI && topConfidence != null && topConfidence >= 0.85
            && (secondConfidence == null || (topConfidence - secondConfidence) >= 0.15));

    outcome.found              = true;
    outcome.usedAI             = usedAI;
    outcome.rewrittenQuery     = usedAI ? aiResult.rewrittenQuery : null;
    outcome.recommendations    = topResults;
    outcome.highConfidence     = highConfidence;
    outcome.needsClarification = usedAI ? aiResult.needsClarification : (topResults.size() > 1);
    outcome.clarificationQuestion = usedAI ? aiResult.clarificationQuestion : null;
    if (highConfidence && topResults.size() == 1) {
        outcome.resolvedRoleLabel   = (String) topResults[0].get('roleLabel');
        outcome.resolvedRoleReason  = (String) topResults[0].get('reason');
        outcome.resolvedRoleProgram = (String) topResults[0].get('program');
        outcome.resolvedRolePurpose = (String) topResults[0].get('purpose');
    }
    return outcome;
}

/** Matches a misspelled token against words in a metadata text field. */
@testVisible
private static Boolean fuzzyTokenMatches(String token, String searchableText) {
    if (String.isBlank(token) || String.isBlank(searchableText)) return false;
    String normalizedToken = token.toLowerCase();
    String normalizedText = searchableText.toLowerCase();
    if (normalizedText.contains(normalizedToken)) return true;
    if (normalizedToken.length() < 6) return false;
    for (String searchableWord : normalizedText
        .replaceAll('[^a-z0-9 ]', ' ').split('\\s+')) {
        if (String.isBlank(searchableWord)) continue;
        Integer maxDistance = normalizedToken.length() >= 7 ? 2 : 1;
        if (editDistance(normalizedToken, searchableWord) <= maxDistance) return true;
    }
    return false;
}

/** Computes Levenshtein distance for short role/capability tokens. */
private static Integer editDistance(String left, String right) {
    List<Integer> previousRow = new List<Integer>();
    for (Integer column = 0; column <= right.length(); column++) previousRow.add(column);
    for (Integer row = 1; row <= left.length(); row++) {
        List<Integer> currentRow = new List<Integer>{ row };
        for (Integer column = 1; column <= right.length(); column++) {
            Integer substitutionCost = left.substring(row - 1, row)
                == right.substring(column - 1, column) ? 0 : 1;
            currentRow.add(Math.min(
                Math.min(currentRow[column - 1] + 1, previousRow[column] + 1),
                previousRow[column - 1] + substitutionCost
            ));
        }
        previousRow = currentRow;
    }
    return previousRow[right.length()];
}

/**
 * AI ROLE RECOMMENDATION AGENT - the SOLE component responsible for understanding
 * and resolving a user's requested role from exact names, incomplete/incorrect
 * names, aliases, abbreviations, keywords, business use cases, or natural-language
 * descriptions. validateAccessRequest performs NO independent role search of its
 * own - both it and this endpoint call the SAME underlying resolveRoleCandidates()
 * engine, so there is exactly one implementation of "figure out the role."
 *
 * RAG pipeline:
 *   1. RETRIEVAL    - deterministic metadata filter (program) + keyword scoring
 *                     over Core_MDF_IUPGM_Rule_Config__mdt narrows the full role
 *                     set down to a small, relevant, best-first candidate list.
 *   2. AUGMENTATION
 *      + GENERATION/
 *        RERANKING  - the narrowed candidate list is handed to
 *                     Core_MDF_IUPGMRoleRecommendationService, which builds a rich
 *                     contextual document per candidate and asks the existing CCP
 *                     GenAI chat endpoint to rank/explain them. Every AI-returned
 *                     role is verified against the real candidate set before it is
 *                     ever surfaced (see that class's guardrail).
 *   3. FALLBACK     - if the AI call fails or returns nothing usable, this
 *                     degrades to the deterministic keyword-scored order with
 *                     zero request failure - callers always get a usable response.
 *
 * Also supports browse mode (program only, no query) - a deterministic metadata
 * listing (not a text search) so the chatbot can still say "which role?" for a
 * known program.
 */
@HttpGet
global static String recommendRole() {

        RestRequest  req = RestContext.request;
        RestResponse res = RestContext.response;

        try {

            String query   = req.params.get('query');
            String program = req.params.get('program');
            String programFilter = String.isNotBlank(program)
                ? resolveProgram(program) : null;

            /*
            ============================================================
            BROWSE MODE - no query, program given: list every active role
            for that program (deterministic metadata listing, not a text
            search) so the chatbot can prompt "which role?".
            ============================================================
            */
            if (String.isBlank(query)) {
                if (String.isBlank(programFilter)) {
                    res.statusCode = 400;
                    return err('Either "query" (free-text request) or "program" '
                        + '(to browse all roles for a program) is required. '
                        + 'Example: ?query=approve+budget+for+CCF or ?program=CCF');
                }
                List<Core_MDF_IUPGM_Rule_Config__mdt> allForProgram = [
                    SELECT Core_MDF_Role_Label__c, Core_MDF_Program__c, Core_MDF_Role_Purpose__c
                    FROM   Core_MDF_IUPGM_Rule_Config__mdt
                    WHERE  Core_MDF_Is_Active__c = true
                    ORDER BY Core_MDF_Role_Label__c
                ];
                List<Map<String, Object>> browseResults = new List<Map<String, Object>>();
                for (Core_MDF_IUPGM_Rule_Config__mdt r : allForProgram) {
                    if (!isProgramMatchOrCommon(r.Core_MDF_Program__c, programFilter)) continue;
                    browseResults.add(new Map<String, Object>{
                        'roleLabel' => r.Core_MDF_Role_Label__c,
                        'program'   => displayProgramLabel(r.Core_MDF_Program__c),
                        'purpose'   => r.Core_MDF_Role_Purpose__c
                    });
                }
                if (browseResults.isEmpty()) {
                    res.statusCode = 400;
                    return err('No active roles found for program [' + program + ']. '
                        + 'Please check the program name.');
                }
                res.statusCode = 200;
                return JSON.serialize(new Map<String, Object>{
                    'success'         => true,
                    'found'           => true,
                    'browseMode'      => true,
                    'matchCount'      => browseResults.size(),
                    'recommendations' => browseResults,
                    'nextStep'        => 'Pick a role from the list above and call '
                        + 'POST /access/validateRequest with the exact roleLabel to proceed.'
                });
            }

            if (query.toLowerCase().replaceAll('[^a-z0-9 ]', ' ').trim().length() == 0) {
                res.statusCode = 400;
                return err('Query contains no meaningful keywords. '
                    + 'Please describe what you want to do.');
            }

            RoleResolutionOutcome outcome = resolveRoleCandidates(query, programFilter);

            if (!outcome.found) {
                res.statusCode = 200;
                return JSON.serialize(new Map<String, Object>{
                    'success'               => true,
                    'found'                 => false,
                    'usedAI'                => outcome.usedAI,
                    'errorCode'             => 'ROLE_NOT_FOUND',
                    'query'                 => query,
                    'rewrittenQuery'        => outcome.rewrittenQuery,
                    'needsClarification'    => outcome.needsClarification,
                    'clarificationQuestion' => outcome.clarificationQuestion,
                    'message'               => outcome.message
                });
            }

            res.statusCode = 200;
            return JSON.serialize(new Map<String, Object>{
                'success'               => true,
                'found'                 => true,
                'usedAI'                => outcome.usedAI,
                'query'                 => query,
                'rewrittenQuery'        => outcome.rewrittenQuery,
                'matchCount'            => outcome.recommendations.size(),
                'recommendations'       => outcome.recommendations,
                'highConfidence'        => outcome.highConfidence,
                'needsClarification'    => outcome.needsClarification,
                'clarificationQuestion' => outcome.clarificationQuestion,
                'message'               => (outcome.highConfidence && outcome.recommendations.size() == 1)
                    ? buildRoleConfirmationMessage(
                        (String) outcome.recommendations[0].get('roleLabel'),
                        (String) outcome.recommendations[0].get('reason'),
                        (String) outcome.recommendations[0].get('purpose'))
                    : buildRoleOptionsQuestion(outcome.recommendations, outcome.clarificationQuestion),
                'nextStep'              => 'Pick a role from the list above and call '
                    + 'POST /access/validateRequest with the exact roleLabel to proceed.'
            });

        } catch (Exception e) {
            System.debug('recommendRole ERROR: ' + e.getMessage());
            res.statusCode = 500;
            return err('An internal error occurred: ' + e.getMessage());
        }
    }
}