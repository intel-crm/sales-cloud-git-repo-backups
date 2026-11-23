/*****************************************************************************************************
Class Name          :    Core_MDF_IUPGMReqStaging_ServiceHandler
Test Class Name     :    Core_MDF_IUPGMReqStaging_SH_Test
Description         :    Service layer for the IUPGM staging workflow.
Created By          :    Ramapriya  
******************************************************************************************************/
public without sharing class Core_MDF_IUPGMReqStaging_ServiceHandler
    implements Schedulable {

    
    private static Map<String, Core_MDF_IUPGM_Rule_Config__mdt> configCache;
    private static final String COMMON_PROGRAM = 'COMMON';
 /******************************************************************************************************
    Method Name:        initiateAsync
    Description:        Performs the first-pass validation and routes staging records into the next processing step.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public static void initiateAsync(Set<Id> stagingIds) {

       

        List<Core_MDF_IUPGM_Request_Staging__c> records = [
            SELECT  Id,
                    Core_MDF_IUPGM_User__c,
                    Core_MDF_IUPGM_Program__c,
                    Core_MDF_IUPGM_Role_nm__c,
                    Core_MDF_IUPGM_Region_Sub_Region_nm__c,
                    Core_MDF_IUPGM_All_Account_Access__c,
                    Core_MDF_IUPGM_Account__c,
                    Core_MDF_IUPGM_Budget_Type_nm__c,
                    Core_MDF_IUPGM_All_Budget_Type_Access__c,
                    Core_MDF_GeoSubGeo_Budget_Type_nm__c,
                    Core_MDF_Approval_Region_nm__c,
                    Core_MDF_Activity_Classification_nm__c,
                    Core_MDF_Request_Status_nm__c,
                    Core_MDF_AGS_Status_nm__c,
                    Core_MDF_Is_IUPGM_Processed__c,
                    Core_MDF_Error_Message_txt__c,
                    Core_MDF_AGS_Role_Name__c,
                    Core_MDF_Request_Type_nm__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id IN :stagingIds
        ];

        if (records.isEmpty()) {
            System.debug('No records found. Exiting.');
            return;
        }

        process(records);
       
    }

   /******************************************************************************************************
    Method Name:        process
    Description:        Evaluates a batch of staging records and determines the next action for each one.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public static void process(
        List<Core_MDF_IUPGM_Request_Staging__c> records
    ) {

        if (records == null || records.isEmpty()) return;

        List<Core_MDF_IUPGM_Request_Staging__c> revokeRecords =
            new List<Core_MDF_IUPGM_Request_Staging__c>();
        List<Core_MDF_IUPGM_Request_Staging__c> grantRecords =
            new List<Core_MDF_IUPGM_Request_Staging__c>();
        for (Core_MDF_IUPGM_Request_Staging__c rec : records) {
            if (rec.Core_MDF_Request_Type_nm__c == 'REVOKE') {
                revokeRecords.add(rec);
            } else {
                grantRecords.add(rec);
            }
        }

        Set<Id> userIds = new Set<Id>();
        for (Core_MDF_IUPGM_Request_Staging__c rec : grantRecords) {
            if (rec.Core_MDF_IUPGM_User__c != null) {
                userIds.add(rec.Core_MDF_IUPGM_User__c);
            }
        }

        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Name, UserType, FederationIdentifier, IsActive
            FROM User
            WHERE Id IN :userIds
        ]);
      

        
        loadConfigCache();

        
        Set<String> neededPS = new Set<String>();
        for (Core_MDF_IUPGM_Request_Staging__c rec : grantRecords) {
            Core_MDF_IUPGM_Rule_Config__mdt c = getRuleConfig(
                rec.Core_MDF_IUPGM_Role_nm__c,
                rec.Core_MDF_IUPGM_Program__c,
                rec.Core_MDF_AGS_Role_Name__c
            );
            if (c != null && String.isNotBlank(c.Core_MDF_Permission_Set_Name__c)) {
                neededPS.add(c.Core_MDF_Permission_Set_Name__c);
            }
        }

        Map<Id, Set<String>> userPSMap = new Map<Id, Set<String>>();
        if (!neededPS.isEmpty()) {
            for (PermissionSetAssignment psa : [
                SELECT AssigneeId, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId IN :userIds
                  AND IsActive = true
                  AND PermissionSet.Name IN :neededPS
            ]) {
                if (!userPSMap.containsKey(psa.AssigneeId)) {
                    userPSMap.put(psa.AssigneeId, new Set<String>());
                }
                userPSMap.get(psa.AssigneeId).add(psa.PermissionSet.Name);
            }
        }
       
        List<Core_MDF_IUPGM_Request_Staging__c> stagingUpdates =
            new List<Core_MDF_IUPGM_Request_Staging__c>();

        
        Set<Id> agsCalloutIds = new Set<Id>();


        Map<String, List<Core_MDF_IUPGM_Request_Staging__c>> iupgmBatch =
            new Map<String, List<Core_MDF_IUPGM_Request_Staging__c>>();

        for (Core_MDF_IUPGM_Request_Staging__c rec : grantRecords) {



            try {

               
                User usr = userMap.get(rec.Core_MDF_IUPGM_User__c);

                if (usr == null) {
                    rec.Core_MDF_Request_Status_nm__c = 'AGS_User_Creation_Pending';
                    rec.Core_MDF_AGS_Request_Type__c  = 'CREATE_USER';
                    rec.Core_MDF_Error_Message_txt__c =
                        'User not found in Salesforce. '
                        + 'AGS user creation request submitted.';
                    stagingUpdates.add(rec);
                    agsCalloutIds.add(rec.Id);
                    continue;
                }


                if (usr.UserType != 'Standard') {
                    rec.Core_MDF_Request_Status_nm__c = 'External_User_Blocked';
                    rec.Core_MDF_Error_Message_txt__c =
                        'User [' + usr.Name + '] has a non-standard profile ('
                        + usr.UserType + '). '
                        + 'IUPGM access cannot be provisioned for external users.';
                    stagingUpdates.add(rec);
                    continue;
                }

                Core_MDF_IUPGM_Rule_Config__mdt cfg = getRuleConfig(
                    rec.Core_MDF_IUPGM_Role_nm__c,
                    rec.Core_MDF_IUPGM_Program__c,
                    rec.Core_MDF_AGS_Role_Name__c
                );
                String configKey = cfg == null ? buildKey(
                    rec.Core_MDF_IUPGM_Role_nm__c,
                    rec.Core_MDF_IUPGM_Program__c
                ) : buildKey(cfg.Core_MDF_Permission_Set_Name__c, cfg.Core_MDF_Program__c);

               

                if (cfg == null) {
                    rec.Core_MDF_Request_Status_nm__c = 'Error';
                    rec.Core_MDF_Error_Message_txt__c =
                        'No role configuration found for ['
                        + rec.Core_MDF_IUPGM_Role_nm__c
                        + '] in program [' + rec.Core_MDF_IUPGM_Program__c + ']. '
                        + 'Please contact your administrator.';
                    stagingUpdates.add(rec);
                    continue;
                }

                // REVOKE records are handled separately by processRevokeRequests() and
                // never reach this loop (it only iterates grantRecords).
                sanitizeInputs(rec, cfg);

                // COPY requests never collect account/region/budget/approval-region
                Boolean isCopyRequest = rec.Core_MDF_Request_Type_nm__c == 'COPY';
                List<String> validationErrors = isCopyRequest
                    ? new List<String>()
                    : validateInputs(rec, cfg);

                if (!validationErrors.isEmpty()) {
                    String errMsg = String.join(validationErrors, ' | ');
                    rec.Core_MDF_Request_Status_nm__c = 'Validation_Failed';
                    rec.Core_MDF_Error_Message_txt__c = errMsg;
                    stagingUpdates.add(rec);
                    continue;
                }

              
                String requiredPS = cfg.Core_MDF_Permission_Set_Name__c;
                Boolean skipPSCheck = cfg.Core_MDF_Skip_PS_Check__c;

                if (String.isBlank(requiredPS) && !skipPSCheck) {
                    rec.Core_MDF_Request_Status_nm__c = 'Error';
                    rec.Core_MDF_Error_Message_txt__c =
                        'Permission Set name not configured for role ['
                        + rec.Core_MDF_IUPGM_Role_nm__c + ']. '
                        + 'Contact your administrator.';
                    stagingUpdates.add(rec);
                    continue;
                }

                Boolean hasPS;
                if (skipPSCheck) {
                    hasPS = false;
                } else {
                    Set<String> userPS = userPSMap.get(usr.Id);
                    hasPS = userPS != null && userPS.contains(requiredPS);
                }

                if (!hasPS) {
                    rec.Core_MDF_Request_Status_nm__c = 'AGS_PS_Pending';
                    rec.Core_MDF_AGS_Status_nm__c     = 'Submitted';
                    rec.Core_MDF_AGS_Request_Type__c  = 'PERMISSION_SET_REQUEST';
                    rec.Core_MDF_Error_Message_txt__c = skipPSCheck
                        ? 'AGS role [' + rec.Core_MDF_AGS_Role_Name__c
                            + '] assignment request submitted.'
                        : 'User does not have required Permission Set ['
                            + requiredPS + ']. AGS assignment request submitted.';
                    stagingUpdates.add(rec);
                    agsCalloutIds.add(rec.Id);
                    continue;
                }

               
                if (!cfg.Core_MDF_IUPGM_Required__c || isCopyRequest) {
                    rec.Core_MDF_Request_Status_nm__c  = 'Completed';
                    rec.Core_MDF_Is_IUPGM_Processed__c = true;
                    rec.Core_MDF_Error_Message_txt__c  = isCopyRequest
                        ? 'Access provisioned via Permission Set / AGS role as part of a '
                            + 'Copy User Access request. Matching IUPGM combinations for this '
                            + 'role are copied from the source user once the whole operation completes.'
                        : 'Access provisioned via Permission Set / AGS role. '
                            + 'No IUPGM record required for this role.';
                    stagingUpdates.add(rec);
                    continue;
                }

              

                //  Collect for batched IUPGM processing (executed after loop) 
                String iupgmKey = buildKey(
                    cfg.Core_MDF_Permission_Set_Name__c,
                    cfg.Core_MDF_Program__c
                );
                if (!iupgmBatch.containsKey(iupgmKey)) {
                    iupgmBatch.put(iupgmKey,
                        new List<Core_MDF_IUPGM_Request_Staging__c>());
                }
                iupgmBatch.get(iupgmKey).add(rec);
                // Status is set after the loop inside the batch processor below.

            } catch (Exception e) {
                String corrId = Core_MDF_CCP_ConstantClass.newIupgmCorrelationId();
                rec.Core_MDF_Request_Status_nm__c = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR;
                rec.Core_MDF_Error_Message_txt__c =
                    '[' + corrId + '] ' + e.getMessage();
                stagingUpdates.add(rec);
            }
        }

       
        for (String cfgKey : iupgmBatch.keySet()) {
            Core_MDF_IUPGM_Rule_Config__mdt iupgmCfg = configCache.get(cfgKey);
            List<Core_MDF_IUPGM_Request_Staging__c> batchRecs =
                iupgmBatch.get(cfgKey);
            try {
                Core_MDF_IUPGM_AccessModelService.processRequests(batchRecs, iupgmCfg);
            } catch (Exception batchEx) {
                String corrId = Core_MDF_CCP_ConstantClass.newIupgmCorrelationId();
                System.debug('[' + corrId + '] Batch IUPGM error: '
                    + batchEx.getMessage());
                for (Core_MDF_IUPGM_Request_Staging__c bRec : batchRecs) {
                    bRec.Core_MDF_Request_Status_nm__c =
                        Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR;
                    bRec.Core_MDF_Error_Message_txt__c =
                        '[' + corrId + '] IUPGM batch error: ' + batchEx.getMessage();
                }
            }
            for (Core_MDF_IUPGM_Request_Staging__c bRec : batchRecs) {
                if (bRec.Core_MDF_Request_Status_nm__c
                       != Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR) {
                    bRec.Core_MDF_Request_Status_nm__c =
                        bRec.Core_MDF_Action_nm__c == Core_MDF_CCP_ConstantClass.IUPGM_ACTION_SKIP
                            ? Core_MDF_CCP_ConstantClass.IUPGM_STATUS_SKIPPED
                            : Core_MDF_CCP_ConstantClass.IUPGM_STATUS_COMPLETED;
                    if (bRec.Core_MDF_Action_nm__c == Core_MDF_CCP_ConstantClass.IUPGM_ACTION_SKIP
                        && String.isBlank(bRec.Core_MDF_Error_Message_txt__c)) {
                        bRec.Core_MDF_Error_Message_txt__c =
                            'User already has access provisioned with this or broader scope.';
                    }
                    bRec.Core_MDF_Is_IUPGM_Processed__c = true;
                }
                stagingUpdates.add(bRec);
            }
        }

        processRevokeRequests(revokeRecords, stagingUpdates);

        if (!stagingUpdates.isEmpty()) {
            update stagingUpdates;
        }

      
        if (!agsCalloutIds.isEmpty()) {
         
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(agsCalloutIds));
        }

    }

    /** Deactivates every active IUPGM row for each requested user/role/program. */
    private static void processRevokeRequests(
        List<Core_MDF_IUPGM_Request_Staging__c> revokeRecords,
        List<Core_MDF_IUPGM_Request_Staging__c> stagingUpdates
    ) {
        if (revokeRecords == null || revokeRecords.isEmpty()) return;

        Map<Id, Core_MDF_IUPGM_Rule_Config__mdt> configByRequest =
            new Map<Id, Core_MDF_IUPGM_Rule_Config__mdt>();
        Set<Id> userIds = new Set<Id>();
        Set<String> roleNames = new Set<String>();
        Set<String> programNames = new Set<String>();

        for (Core_MDF_IUPGM_Request_Staging__c rec : revokeRecords) {
            Core_MDF_IUPGM_Rule_Config__mdt cfg = getRuleConfig(
                rec.Core_MDF_IUPGM_Role_nm__c,
                rec.Core_MDF_IUPGM_Program__c,
                rec.Core_MDF_AGS_Role_Name__c
            );
            if (cfg == null || rec.Core_MDF_IUPGM_User__c == null) {
                rec.Core_MDF_Action_nm__c = 'ERROR';
                rec.Core_MDF_Request_Status_nm__c = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR;
                rec.Core_MDF_Is_IUPGM_Processed__c = true;
                rec.Core_MDF_Error_Message_txt__c = cfg == null
                    ? 'No role configuration found. Cannot deactivate IUPGM access.'
                    : 'A Salesforce user is required to deactivate IUPGM access.';
                stagingUpdates.add(rec);
                continue;
            }

            String roleName = String.isNotBlank(cfg.Core_MDF_Permission_Set_Name__c)
                ? cfg.Core_MDF_Permission_Set_Name__c
                : cfg.Core_MDF_IUPGM_Role_Name__c;
            String programName = toIupgmProgramName(cfg.Core_MDF_Program__c);
            if (String.isBlank(roleName) || String.isBlank(programName)) {
                rec.Core_MDF_Action_nm__c = 'ERROR';
                rec.Core_MDF_Request_Status_nm__c = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR;
                rec.Core_MDF_Is_IUPGM_Processed__c = true;
                rec.Core_MDF_Error_Message_txt__c =
                    'Role or program configuration is missing. Cannot deactivate IUPGM access.';
                stagingUpdates.add(rec);
                continue;
            }

            configByRequest.put(rec.Id, cfg);
            userIds.add(rec.Core_MDF_IUPGM_User__c);
            roleNames.add(roleName);
            programNames.add(programName);
        }

        if (configByRequest.isEmpty()) return;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> activeMappings = [
            SELECT Id, Core_MDF_User_id__c, Core_MDF_Role_nm__c,
                   Core_MDF_Program_nm__c, Core_MDF_Active_Ind__c
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Core_MDF_User_id__c IN :userIds
              AND Core_MDF_Role_nm__c IN :roleNames
              AND Core_MDF_Program_nm__c IN :programNames
              AND Core_MDF_Active_Ind__c = true
        ];

        Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> mappingsByKey =
            new Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();
        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c mapping : activeMappings) {
            String key = buildRevokeKey(
                mapping.Core_MDF_User_id__c,
                mapping.Core_MDF_Role_nm__c,
                mapping.Core_MDF_Program_nm__c
            );
            if (!mappingsByKey.containsKey(key)) {
                mappingsByKey.put(key,
                    new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>());
            }
            mappingsByKey.get(key).add(mapping);
        }

        Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> mappingsToUpdate =
            new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        for (Core_MDF_IUPGM_Request_Staging__c rec : revokeRecords) {
            Core_MDF_IUPGM_Rule_Config__mdt cfg = configByRequest.get(rec.Id);
            if (cfg == null) continue;
            String roleName = String.isNotBlank(cfg.Core_MDF_Permission_Set_Name__c)
                ? cfg.Core_MDF_Permission_Set_Name__c
                : cfg.Core_MDF_IUPGM_Role_Name__c;
            String programName = toIupgmProgramName(cfg.Core_MDF_Program__c);
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> matches = mappingsByKey.get(
                buildRevokeKey(rec.Core_MDF_IUPGM_User__c, roleName, programName)
            );

            if (matches == null || matches.isEmpty()) {
                rec.Core_MDF_Action_nm__c = Core_MDF_CCP_ConstantClass.IUPGM_ACTION_SKIP;
                rec.Core_MDF_Request_Status_nm__c = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_SKIPPED;
                rec.Core_MDF_Is_IUPGM_Processed__c = true;
                rec.Core_MDF_Error_Message_txt__c =
                    'No active IUPGM access exists for this role. Nothing to deactivate.';
            } else {
                for (Core_MDF_Int_Users_Partner_Geo_Mapping__c mapping : matches) {
                    mapping.Core_MDF_Active_Ind__c = false;
                    mappingsToUpdate.put(mapping.Id, mapping);
                }
                rec.Core_MDF_Action_nm__c = 'DEACTIVATE';
                rec.Core_MDF_Request_Status_nm__c = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_COMPLETED;
                rec.Core_MDF_Is_IUPGM_Processed__c = true;
                rec.Core_MDF_IUPGM_Record__c = matches[0].Id;
                rec.Core_MDF_Error_Message_txt__c =
                    'All active IUPGM access for this role and program has been deactivated.';
            }
            stagingUpdates.add(rec);
        }

        if (!mappingsToUpdate.isEmpty()) {
            update mappingsToUpdate.values();
        }
    }

    private static String buildRevokeKey(Id userId, String roleName, String programName) {
        return String.valueOf(userId) + '|' + roleName + '|' + programName;
    }

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

    /******************************************************************************************************
    Method Name:        handleUserCreatedAsync
    Description:        Marks user-creation approved records ready for permission-set submission.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public static void handleUserCreatedAsync(Set<Id> stagingIds) {


        List<Core_MDF_IUPGM_Request_Staging__c> toUpdate =
            new List<Core_MDF_IUPGM_Request_Staging__c>();

        for (Id sid : stagingIds) {
            toUpdate.add(new Core_MDF_IUPGM_Request_Staging__c(
                Id                            = sid,
                Core_MDF_Request_Status_nm__c = 'AGS_PS_Pending',
                Core_MDF_AGS_Status_nm__c     = 'Submitted',
                Core_MDF_AGS_Request_Type__c  = 'PERMISSION_SET_REQUEST',
                Core_MDF_Error_Message_txt__c =
                    'User created in Salesforce. '
                    + 'Requesting Permission Set assignment via AGS.'
            ));
        }

        if (!toUpdate.isEmpty()) update toUpdate;

       
        System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(stagingIds));

    }

/******************************************************************************************************
    Method Name:        submitPendingDependentRoles
    Description:        Called by Core_MDF_IUPGMReqStaging_TriggerHandler.afterUpdate() whenever a
                         Core-Access prerequisite staging record (see the chaining logic in
                         Core_MDF_IUPGM_RequestAPI.createStagingFromSummary()) reaches Completed with a
                         parked Core_MDF_Pending_Dependent_Role_txt__c JSON payload. Deserializes that
                         payload and raises the real role the user originally asked for as its own,
                         brand-new, independent staging record - it then runs through the entire normal
                         GRANT pipeline from scratch, exactly like any other request. Only ever called
                         for records that reached Completed; if the Core-Access record is rejected/errors
                         out instead, this method is never invoked for it and the parked role is simply
                         never requested. Uses Database.insert(allOrNone=false) so a malformed/legacy
                         payload on one record never blocks the others in the same trigger batch.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Raises the parked dependent role (if any) for each completed Core-Access staging record. */
    public static void submitPendingDependentRoles(Set<Id> completedCoreAccessIds) {
        if (completedCoreAccessIds == null || completedCoreAccessIds.isEmpty()) return;

        List<Core_MDF_IUPGM_Request_Staging__c> coreAccessRows = [
            SELECT Id, Core_MDF_IUPGM_User__c, Core_MDF_Requestor_Email__c,
                   Core_MDF_Requested_By__c, Core_MDF_Pending_Dependent_Role_txt__c,
                   Core_MDF_Copy_Operation_Id__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id IN :completedCoreAccessIds
        ];
        if (coreAccessRows.isEmpty()) return;

        List<Core_MDF_IUPGM_Request_Staging__c> toInsert =
            new List<Core_MDF_IUPGM_Request_Staging__c>();

        for (Core_MDF_IUPGM_Request_Staging__c coreAccessRow : coreAccessRows) {
            try {
            if (String.isBlank(coreAccessRow.Core_MDF_Pending_Dependent_Role_txt__c)) continue;
            Map<String, Object> pending;
            try {
                pending = (Map<String, Object>) JSON.deserializeUntyped(
                    coreAccessRow.Core_MDF_Pending_Dependent_Role_txt__c);
            } catch (Exception e) {
                // Malformed/unexpected payload - skip this one, never block the rest.
                System.debug('submitPendingDependentRoles: could not parse pending role JSON on '
                    + coreAccessRow.Id + ': ' + e.getMessage());
                continue;
            }

            // COPY-originated bootstrap: a list of eligible roles was parked (not a single role) when
            // the COPY target had no active Salesforce account - see
            // Core_MDF_IUPGM_RequestAPI.handleCopyTargetNeedsCreation(). Raise EVERY parked role as its
            // own independent staging record, all sharing the Core Access row's
            // Core_MDF_Copy_Operation_Id__c so the existing copy-completion email groups them exactly
            // like an ordinary (non-bootstrap) Copy User Access operation.
            Object eligibleRolesRaw = pending.get('eligibleRoles');
            if (eligibleRolesRaw instanceof List<Object>) {
                String copySourceUserName = (String) pending.get('sourceUserName');
                for (Object roleObj : (List<Object>) eligibleRolesRaw) {
                    try {
                        Map<String, Object> role = (Map<String, Object>) roleObj;
                        Core_MDF_IUPGM_Request_Staging__c copyDependent =
                            new Core_MDF_IUPGM_Request_Staging__c();
                        copyDependent.Core_MDF_IUPGM_User__c      = coreAccessRow.Core_MDF_IUPGM_User__c;
                        copyDependent.Core_MDF_Requested_By__c    = coreAccessRow.Core_MDF_Requested_By__c;
                        copyDependent.Core_MDF_Requestor_Email__c = coreAccessRow.Core_MDF_Requestor_Email__c;
                        copyDependent.Core_MDF_Request_Type_nm__c = 'COPY';
                        copyDependent.Core_MDF_IUPGM_Program__c   = (String) role.get('program');
                        copyDependent.Core_MDF_IUPGM_Role_nm__c   = (String) role.get('permissionSetName');
                        copyDependent.Core_MDF_AGS_Role_Name__c   = (String) role.get('agsRoleName');
                        if (String.isNotBlank(coreAccessRow.Core_MDF_Copy_Operation_Id__c)) {
                            copyDependent.Core_MDF_Copy_Operation_Id__c = coreAccessRow.Core_MDF_Copy_Operation_Id__c;
                            copyDependent.Core_MDF_Copy_Source_User_txt__c = copySourceUserName;
                        }

                        Map<String, Object> existingCopyRole = Core_MDF_IUPGM_RequestAPI.findExistingRequest(
                            String.valueOf(copyDependent.Core_MDF_IUPGM_User__c),
                            copyDependent.Core_MDF_IUPGM_Role_nm__c,
                            copyDependent.Core_MDF_IUPGM_Program__c,
                            null, null, null, null, null, null
                        );
                        if (existingCopyRole != null) {
                            System.debug('submitPendingDependentRoles: skipped duplicate copied role '
                                + copyDependent.Core_MDF_IUPGM_Role_nm__c + ' for ' + coreAccessRow.Id);
                            continue;
                        }
                        toInsert.add(copyDependent);
                    } catch (Exception roleEx) {
                        System.debug('submitPendingDependentRoles: could not build copied role for '
                            + coreAccessRow.Id + ': ' + roleEx.getMessage());
                    }
                }
                continue;
            }

            Core_MDF_IUPGM_Request_Staging__c dependent =
                new Core_MDF_IUPGM_Request_Staging__c();
            dependent.Core_MDF_IUPGM_User__c    = coreAccessRow.Core_MDF_IUPGM_User__c;
            dependent.Core_MDF_Requested_By__c  = coreAccessRow.Core_MDF_Requested_By__c;
            dependent.Core_MDF_Requestor_Email__c = coreAccessRow.Core_MDF_Requestor_Email__c;
            dependent.Core_MDF_Request_Type_nm__c = 'GRANT';
            dependent.Core_MDF_IUPGM_Program__c   = (String) pending.get('program');
            dependent.Core_MDF_IUPGM_Role_nm__c   = (String) pending.get('permissionSetName');
            dependent.Core_MDF_AGS_Role_Name__c   = (String) pending.get('agsRoleName');
            Object accountIdVal = pending.get('accountId');
            if (accountIdVal != null && String.isNotBlank((String) accountIdVal)) {
                dependent.Core_MDF_IUPGM_Account__c = (Id) (String) accountIdVal;
            }
            if (pending.get('allAccountAccess') != null) {
                dependent.Core_MDF_IUPGM_All_Account_Access__c =
                    (Boolean) pending.get('allAccountAccess');
            }
            dependent.Core_MDF_IUPGM_Region_Sub_Region_nm__c = (String) pending.get('geo');
            if (pending.get('allBudgetAccess') != null) {
                dependent.Core_MDF_IUPGM_All_Budget_Type_Access__c =
                    (Boolean) pending.get('allBudgetAccess');
            }
            dependent.Core_MDF_GeoSubGeo_Budget_Type_nm__c   = (String) pending.get('geoBudgetType');
            dependent.Core_MDF_Approval_Region_nm__c         = (String) pending.get('approvalRegion');
            dependent.Core_MDF_Activity_Classification_nm__c = (String) pending.get('activityClassification');

            // Same duplicate guard the request API uses: skip if an open or completed
            // GRANT for this user/role/program already exists.
            Map<String, Object> existing = Core_MDF_IUPGM_RequestAPI.findExistingRequest(
                String.valueOf(dependent.Core_MDF_IUPGM_User__c),
                dependent.Core_MDF_IUPGM_Role_nm__c,
                dependent.Core_MDF_IUPGM_Program__c,
                (String) pending.get('accountId'),
                dependent.Core_MDF_IUPGM_Region_Sub_Region_nm__c,
                dependent.Core_MDF_GeoSubGeo_Budget_Type_nm__c,
                dependent.Core_MDF_IUPGM_All_Account_Access__c,
                dependent.Core_MDF_IUPGM_All_Budget_Type_Access__c,
                null
            );
            if (existing != null) {
                System.debug('submitPendingDependentRoles: skipped duplicate role '
                    + dependent.Core_MDF_IUPGM_Role_nm__c + ' for ' + coreAccessRow.Id);
                continue;
            }

            toInsert.add(dependent);
            } catch (Exception e) {
                // Bad payload value (e.g. malformed account Id) - skip only this row.
                System.debug('submitPendingDependentRoles: could not build dependent role for '
                    + coreAccessRow.Id + ': ' + e.getMessage());
            }
        }

        if (!toInsert.isEmpty()) {
            Database.insert(toInsert, false);
        }
    }

/******************************************************************************************************
    Method Name:        process
    Description:        Completes IUPGM processing after permission-set approval and writes the final record state.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public static void handlePSApprovedAsync(Set<Id> stagingIds) {


        List<Core_MDF_IUPGM_Request_Staging__c> records = [
            SELECT  Id,
                    Core_MDF_Request_Status_nm__c,
                    Core_MDF_Error_Message_txt__c,
                    Core_MDF_IUPGM_User__c,
                    Core_MDF_IUPGM_Program__c,
                    Core_MDF_IUPGM_Role_nm__c,
                    Core_MDF_IUPGM_Region_Sub_Region_nm__c,
                    Core_MDF_IUPGM_All_Account_Access__c,
                    Core_MDF_IUPGM_Account__c,
                    Core_MDF_IUPGM_Budget_Type_nm__c,
                    Core_MDF_IUPGM_All_Budget_Type_Access__c,
                    Core_MDF_GeoSubGeo_Budget_Type_nm__c,
                    Core_MDF_Approval_Region_nm__c,
                    Core_MDF_Activity_Classification_nm__c,
                    Core_MDF_AGS_Role_Name__c,
                    Core_MDF_Request_Type_nm__c,
                    Core_MDF_IUPGM_Record__c,
                    Core_MDF_New_User_Email__c,
                    Core_MDF_New_User_Federation_Id__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Id IN :stagingIds
        ];

        if (records.isEmpty()) return;

        loadConfigCache();

        List<Core_MDF_IUPGM_Request_Staging__c> toUpdate =
            new List<Core_MDF_IUPGM_Request_Staging__c>();

        // ── Collect IUPGM-ready records grouped by config key ─────────────
        Map<String, List<Core_MDF_IUPGM_Request_Staging__c>> psIupgmBatch =
            new Map<String, List<Core_MDF_IUPGM_Request_Staging__c>>();

        // REVOKE records whose PS removal is confirmed and whose role requires
        // an IUPGM record to be deactivated (collected separately - handled by
        // direct DML below, not by AccessModelService, since deactivation is a
        // simple flip of Core_MDF_Active_Ind__c rather than the CREATE/UPDATE/
        // duplicate-detection logic that only applies to granting access).
        List<Core_MDF_IUPGM_Request_Staging__c> revokeIupgmDeactivations =
            new List<Core_MDF_IUPGM_Request_Staging__c>();

        for (Core_MDF_IUPGM_Request_Staging__c rec : records) {

            Core_MDF_IUPGM_Rule_Config__mdt cfg = getRuleConfig(
                rec.Core_MDF_IUPGM_Role_nm__c,
                rec.Core_MDF_IUPGM_Program__c,
                rec.Core_MDF_AGS_Role_Name__c
            );

            if (cfg == null) {
                toUpdate.add(new Core_MDF_IUPGM_Request_Staging__c(
                    Id                            = rec.Id,
                    Core_MDF_Request_Status_nm__c = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR,
                    Core_MDF_Error_Message_txt__c =
                        'Role config not found after PS approval. Cannot process IUPGM.'
                ));
                continue;
            }

            /*
            ========================================================
            REVOKE BRANCH
            --------------------------------------------------------
            AGS has confirmed the Permission Set removal is complete
            (this method only runs once AGS_Status flips to Approved
            for an AGS_PS_Pending record). For AGS-only roles there is
            nothing further to do - mark Completed immediately (email
            fires from the same terminal-status hook used today). For
            IUPGM-required roles, the IUPGM record must be deactivated
            BEFORE the request is marked Completed, so the completion
            email is only ever sent after the deactivation has actually
            happened.
            ========================================================
            */
            if (rec.Core_MDF_Request_Type_nm__c == 'REVOKE') {
                if (!cfg.Core_MDF_IUPGM_Required__c) {
                    toUpdate.add(new Core_MDF_IUPGM_Request_Staging__c(
                        Id                             = rec.Id,
                        Core_MDF_Request_Status_nm__c  = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_COMPLETED,
                        Core_MDF_Is_IUPGM_Processed__c = true,
                        Core_MDF_Error_Message_txt__c  =
                            'AGS role access removed successfully. No IUPGM record '
                            + 'was associated with this role.'
                    ));
                } else {
                    revokeIupgmDeactivations.add(rec);
                }
                continue;
            }

            sanitizeInputs(rec, cfg);

            // AGS-only roles, or any COPY request (never creates IUPGM - see note
            // in process() above) - mark complete without creating IUPGM record.
            Boolean isCopyRequest = rec.Core_MDF_Request_Type_nm__c == 'COPY';
            if (!cfg.Core_MDF_IUPGM_Required__c || isCopyRequest) {
                toUpdate.add(new Core_MDF_IUPGM_Request_Staging__c(
                    Id                             = rec.Id,
                    Core_MDF_Request_Status_nm__c  = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_COMPLETED,
                    Core_MDF_Is_IUPGM_Processed__c = true,
                    Core_MDF_Error_Message_txt__c  = isCopyRequest
                        ? 'Access provisioned via Permission Set / AGS role as part of a '
                            + 'Copy User Access request. Matching IUPGM combinations for this '
                            + 'role are copied from the source user once the whole operation completes.'
                        : 'Access provisioned via Permission Set / AGS role. '
                            + 'No IUPGM record required for this role.'
                ));
                continue;
            }

            // Collect for batched processing below.
            String iupgmKey = buildKey(
                cfg.Core_MDF_Permission_Set_Name__c,
                cfg.Core_MDF_Program__c
            );
            if (!psIupgmBatch.containsKey(iupgmKey)) {
                psIupgmBatch.put(iupgmKey,
                    new List<Core_MDF_IUPGM_Request_Staging__c>());
            }
            psIupgmBatch.get(iupgmKey).add(rec);
        }

        for (String k : psIupgmBatch.keySet()) {
            Core_MDF_IUPGM_Rule_Config__mdt iupgmCfg = configCache.get(k);
            List<Core_MDF_IUPGM_Request_Staging__c> batch = psIupgmBatch.get(k);
            try {
                Core_MDF_IUPGM_AccessModelService.processRequests(batch, iupgmCfg);
            } catch (Exception ex) {
                String corrId = Core_MDF_CCP_ConstantClass.newIupgmCorrelationId();
                System.debug('[' + corrId + '] Batch IUPGM error in handlePSApproved: '
                    + ex.getMessage());
                for (Core_MDF_IUPGM_Request_Staging__c bRec : batch) {
                    bRec.Core_MDF_Request_Status_nm__c =
                        Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR;
                    bRec.Core_MDF_Error_Message_txt__c =
                        '[' + corrId + '] IUPGM processing failed after PS approval: '
                        + ex.getMessage();
                }
            }
            for (Core_MDF_IUPGM_Request_Staging__c bRec : batch) {
                if (bRec.Core_MDF_Request_Status_nm__c
                       != Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR) {
                    // Set appropriate status based on action
                    if (bRec.Core_MDF_Action_nm__c == 'SKIP') {
                        bRec.Core_MDF_Request_Status_nm__c = 'Skipped';
                        // Preserve the specific skip message set by AccessModelService (e.g. All Accounts).
                        // Fall back to generic message only if no message was set.
                        if (String.isBlank(bRec.Core_MDF_Error_Message_txt__c)) {
                            bRec.Core_MDF_Error_Message_txt__c =
                                'User already has access provisioned with this or broader scope.';
                        }
                    } else {
                        bRec.Core_MDF_Request_Status_nm__c  =
                            Core_MDF_CCP_ConstantClass.IUPGM_STATUS_COMPLETED;
                    }
                    bRec.Core_MDF_Is_IUPGM_Processed__c = true;
                }
                toUpdate.add(bRec);
            }
        }

        Set<Id> resumedRoleIds = resumePendingRolesAfterCoreAccess(records, toUpdate);

        /*
        ========================================================
        REVOKE DEACTIVATION
        --------------------------------------------------------
        For confirmed REVOKE requests on IUPGM-required roles, find the
        matching active IUPGM record(s) for this user+role+program (using
        the same user/role/program keying AccessModelService already uses,
        plus the direct Core_MDF_IUPGM_Record__c lookup captured when the
        role was originally granted, as a fast-path) and deactivate them
        directly - this is a plain Salesforce record update, no AGS
        callout involved. Per business requirement: "remove from all
        scopes at once" - every currently active IUPGM record matching
        this user+role+program is deactivated, not just one.
        The staging record is only marked Completed AFTER this DML
        succeeds, so the completion email (fired from the same terminal-
        status hook as every other status) is never sent before the
        IUPGM record has actually been deactivated.
        ========================================================
        */
        if (!revokeIupgmDeactivations.isEmpty()) {
            Set<Id> revokeUserIds = new Set<Id>();
            Set<String> revokeRoleNames = new Set<String>();
            for (Core_MDF_IUPGM_Request_Staging__c rec : revokeIupgmDeactivations) {
                if (rec.Core_MDF_IUPGM_User__c != null) revokeUserIds.add(rec.Core_MDF_IUPGM_User__c);
                if (String.isNotBlank(rec.Core_MDF_IUPGM_Role_nm__c)) revokeRoleNames.add(rec.Core_MDF_IUPGM_Role_nm__c);
            }

            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmToDeactivate =
                revokeUserIds.isEmpty() || revokeRoleNames.isEmpty()
                    ? new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>()
                    : [
                        SELECT Id, Core_MDF_User_id__c, Core_MDF_Role_nm__c, Core_MDF_Active_Ind__c
                        FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                        WHERE Core_MDF_User_id__c IN :revokeUserIds
                          AND Core_MDF_Role_nm__c IN :revokeRoleNames
                          AND Core_MDF_Active_Ind__c = true
                    ];

            Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> activeIupgmByKey =
                new Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();
            for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmToDeactivate) {
                String k2 = iupgm.Core_MDF_User_id__c + '|' + iupgm.Core_MDF_Role_nm__c;
                if (!activeIupgmByKey.containsKey(k2)) {
                    activeIupgmByKey.put(k2, new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>());
                }
                activeIupgmByKey.get(k2).add(iupgm);
            }

            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmUpdates =
                new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

            for (Core_MDF_IUPGM_Request_Staging__c rec : revokeIupgmDeactivations) {
                String k2 = rec.Core_MDF_IUPGM_User__c + '|' + rec.Core_MDF_IUPGM_Role_nm__c;
                List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> matches = activeIupgmByKey.get(k2);

                if (matches == null || matches.isEmpty()) {
                    // Nothing active to deactivate - AGS said the PS was removed, but
                    // there was no active IUPGM record to begin with. Still complete
                    // the request rather than leaving it stuck.
                    toUpdate.add(new Core_MDF_IUPGM_Request_Staging__c(
                        Id                             = rec.Id,
                        Core_MDF_Request_Status_nm__c  = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_COMPLETED,
                        Core_MDF_Is_IUPGM_Processed__c = true,
                        Core_MDF_Error_Message_txt__c  =
                            'Access removed successfully. No active IUPGM record was found to deactivate.'
                    ));
                    continue;
                }

                for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : matches) {
                    iupgm.Core_MDF_Active_Ind__c = false;
                    iupgmUpdates.add(iupgm);
                }

                toUpdate.add(new Core_MDF_IUPGM_Request_Staging__c(
                    Id                             = rec.Id,
                    Core_MDF_Request_Status_nm__c  = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_COMPLETED,
                    Core_MDF_Is_IUPGM_Processed__c = true,
                    Core_MDF_Error_Message_txt__c  =
                        'Access removed successfully. The associated IUPGM record has been deactivated.'
                ));
            }

            if (!iupgmUpdates.isEmpty()) {
                update iupgmUpdates;
            }
        }

        if (!toUpdate.isEmpty()) update toUpdate;

        if (!resumedRoleIds.isEmpty()) {
            System.enqueueJob(new Core_MDF_AGS_CalloutQueueable(resumedRoleIds));
        }

    }

    /** Resumes sibling new-user role requests once the Core Access PS is approved. */
    private static Set<Id> resumePendingRolesAfterCoreAccess(
        List<Core_MDF_IUPGM_Request_Staging__c> approvedRecords,
        List<Core_MDF_IUPGM_Request_Staging__c> pendingUpdates
    ) {
        Set<Id> coreUserIds = new Set<Id>();
        Set<String> federationIds = new Set<String>();
        Set<String> emails = new Set<String>();

        for (Core_MDF_IUPGM_Request_Staging__c rec : approvedRecords) {
            if (!isCoreAccessRequest(rec)) continue;
            if (rec.Core_MDF_IUPGM_User__c != null) coreUserIds.add(rec.Core_MDF_IUPGM_User__c);
            String fed = getStagingValue(rec, 'Core_MDF_New_User_Federation_Id__c');
            String email = getStagingValue(rec, 'Core_MDF_New_User_Email__c');
            if (String.isNotBlank(fed)) federationIds.add(fed.trim().toLowerCase());
            if (String.isNotBlank(email)) emails.add(email.trim().toLowerCase());
        }
        if (coreUserIds.isEmpty() && federationIds.isEmpty() && emails.isEmpty()) {
            return new Set<Id>();
        }

        List<Core_MDF_IUPGM_Request_Staging__c> siblings = [
            SELECT Id, Core_MDF_IUPGM_User__c, Core_MDF_Request_Status_nm__c,
                   Core_MDF_AGS_Status_nm__c, Core_MDF_Is_IUPGM_Processed__c,
                   Core_MDF_IUPGM_Role_nm__c, Core_MDF_AGS_Role_Name__c,
                   Core_MDF_New_User_Email__c, Core_MDF_New_User_Federation_Id__c
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Core_MDF_Is_IUPGM_Processed__c = false
              AND Core_MDF_Request_Status_nm__c = 'AGS_User_Creation_Pending'
                AND (Core_MDF_IUPGM_User__c IN :coreUserIds
                    OR Core_MDF_New_User_Email__c IN :emails
                    OR Core_MDF_New_User_Federation_Id__c IN :federationIds)
        ];

        Set<Id> resumedIds = new Set<Id>();
        for (Core_MDF_IUPGM_Request_Staging__c sibling : siblings) {
            if (isCoreAccessRequest(sibling)) continue;
            sibling.Core_MDF_IUPGM_User__c = coreUserIds.isEmpty()
                ? sibling.Core_MDF_IUPGM_User__c : coreUserIds.iterator().next();
            sibling.Core_MDF_Request_Status_nm__c = 'AGS_PS_Pending';
            sibling.Core_MDF_AGS_Status_nm__c = 'Submitted';
            sibling.Core_MDF_AGS_Request_Type__c = 'PERMISSION_SET_REQUEST';
            sibling.Core_MDF_Error_Message_txt__c =
                'Core Access is complete. Resuming the requested business role via AGS.';
            pendingUpdates.add(sibling);
            resumedIds.add(sibling.Id);
        }
        return resumedIds;
    }

    private static Boolean isCoreAccessRequest(Core_MDF_IUPGM_Request_Staging__c rec) {
        // Null-guarded: roles with no mapped Permission Set (e.g. "CCF Operations Admin")
        // leave Core_MDF_IUPGM_Role_nm__c blank, and String.valueOf(null) returns null,
        // which previously crashed this bulk-processed method with a NullPointerException.
        String role = rec.Core_MDF_IUPGM_Role_nm__c == null
            ? '' : rec.Core_MDF_IUPGM_Role_nm__c.trim().toLowerCase();
        String agsRole = rec.Core_MDF_AGS_Role_Name__c == null
            ? '' : rec.Core_MDF_AGS_Role_Name__c.trim().toLowerCase();
        String coreRole = Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL.toLowerCase();
        return role == coreRole || agsRole == coreRole;
    }

    private static String getStagingValue(
        Core_MDF_IUPGM_Request_Staging__c rec,
        String fieldName
    ) {
        return Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(rec, fieldName);
    }
        
         /******************************************************************************************************
    Method Name:        sanitizeInputs
    Description:        Normalizes staging values before validation or downstream processing.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    private static void sanitizeInputs(
        Core_MDF_IUPGM_Request_Staging__c rec,
        Core_MDF_IUPGM_Rule_Config__mdt   cfg
    ) {
        String allAccOpt = cfg.Core_MDF_All_Accounts__c;
        Boolean isAccountRequired = cfg.Core_MDF_Account_Required__c;
        Boolean isGenericAgsOnlyRole = isGenericAgsOnlyRole(cfg);
        Boolean isRegionMappedAgsOnlyRole = isRegionMappedAgsOnlyRole(cfg);

        if (!isAccountRequired) {
            // Account is not applicable for this role (e.g. AGS-only roles).
            rec.Core_MDF_IUPGM_All_Account_Access__c = true;
            rec.Core_MDF_IUPGM_Account__c            = null;
        } else if (allAccOpt == 'YES_ONLY') {
            rec.Core_MDF_IUPGM_All_Account_Access__c = true;
            rec.Core_MDF_IUPGM_Account__c            = null;
        } else if (allAccOpt == 'NO_ONLY') {
            rec.Core_MDF_IUPGM_All_Account_Access__c = false;
        } else {
            if (rec.Core_MDF_IUPGM_All_Account_Access__c) {
                rec.Core_MDF_IUPGM_Account__c = null;
            }
        }

        if (cfg.Core_MDF_WW_Only__c) {
            rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW';
        } else if (isGenericAgsOnlyRole) {
            // Generic AGS-only role with no region map: region is not applicable.
            rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c = null;
        } else if (isRegionMappedAgsOnlyRole
            && String.isNotBlank(rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c)) {
            // Region-mapped AGS-only roles support exactly one region per request.
            rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c =
                rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c.trim();
        }

        if (!cfg.Core_MDF_All_Budget_Type_Available__c) {
            // Checkbox cannot be null in DML - use false when budget type is not applicable
            rec.Core_MDF_IUPGM_All_Budget_Type_Access__c = false;
            rec.Core_MDF_GeoSubGeo_Budget_Type_nm__c     = null;
        }

        if (!cfg.Core_MDF_Approval_Region_Required__c) {
            rec.Core_MDF_Approval_Region_nm__c = null;
        }

        if (!cfg.Core_MDF_Activity_Classification_Req__c) {
            rec.Core_MDF_Activity_Classification_nm__c = null;
        }
    }

    /******************************************************************************************************
    Method Name:        validateInputs
    Description:        Validates the request against the active rule configuration and collects user-facing errors.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    private static List<String> validateInputs(
        Core_MDF_IUPGM_Request_Staging__c rec,
        Core_MDF_IUPGM_Rule_Config__mdt   cfg
    ) {
        List<String> errors = new List<String>();
        String allAccOpt    = cfg.Core_MDF_All_Accounts__c;
        Boolean isAccountRequired = cfg.Core_MDF_Account_Required__c;
        Boolean isGenericAgsOnlyRole = isGenericAgsOnlyRole(cfg);

        if (isAccountRequired
            && allAccOpt == 'YES_ONLY'
            && !rec.Core_MDF_IUPGM_All_Account_Access__c) {
            errors.add('This role requires All Account Access = true.');
        }
        if (isAccountRequired
            && allAccOpt == 'NO_ONLY'
            && rec.Core_MDF_IUPGM_All_Account_Access__c) {
            errors.add('This role does not support All Account Access. '
                + 'Please select a specific account.');
        }

        if (!rec.Core_MDF_IUPGM_All_Account_Access__c
            && isAccountRequired
            && rec.Core_MDF_IUPGM_Account__c == null) {
            errors.add('Account is required for this role '
                + 'when All Account Access is not selected.');
        }

        if (cfg.Core_MDF_WW_Only__c
            && String.valueOf(rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c).trim() != 'WW') {
            errors.add('This role only supports WW region. Received: '
                + rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c);
        } else if (!cfg.Core_MDF_WW_Only__c && !isGenericAgsOnlyRole
            && String.isBlank(rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c)) {
            errors.add('Region is required.');
        } else if (!cfg.Core_MDF_WW_Only__c
            && !isGenericAgsOnlyRole
            && String.isNotBlank(cfg.Core_MDF_Region_Options__c)) {
            Set<String> validRegions = new Set<String>();
            for (String r : cfg.Core_MDF_Region_Options__c.split(';')) {
                validRegions.add(r.trim());
            }
            for (String r : rec.Core_MDF_IUPGM_Region_Sub_Region_nm__c.split(';')) {
                String trimmed = r.trim();
                if (!validRegions.contains(trimmed)) {
                    errors.add('Invalid region [' + trimmed + ']. '
                        + 'Valid: ' + cfg.Core_MDF_Region_Options__c);
                }
            }
        }

        if (cfg.Core_MDF_All_Budget_Type_Available__c) {
            if (rec.Core_MDF_IUPGM_All_Budget_Type_Access__c == null) {
                errors.add('Please specify allBudgetAccess (true/false) for this role.');
            }
            if (rec.Core_MDF_IUPGM_All_Budget_Type_Access__c == false
                && cfg.Core_MDF_Budget_Required_When_False__c
                && String.isBlank(rec.Core_MDF_GeoSubGeo_Budget_Type_nm__c)) {
                errors.add('Budget type per region is required when '
                    + 'All Budget Type Access is false. '
                    + 'Format: Region->BudgetType e.g. APJ->Account Plan');
            }
            if (rec.Core_MDF_IUPGM_All_Budget_Type_Access__c == false
                && String.isNotBlank(rec.Core_MDF_GeoSubGeo_Budget_Type_nm__c)
                && String.isNotBlank(cfg.Core_MDF_Geo_Budget_Mapping__c)) {
                errors.addAll(validateGeoBudgetEntries(
                    rec.Core_MDF_GeoSubGeo_Budget_Type_nm__c,
                    cfg.Core_MDF_Geo_Budget_Mapping__c
                ));
            }
        }

        if (cfg.Core_MDF_Approval_Region_Required__c) {
            if (String.isBlank(rec.Core_MDF_Approval_Region_nm__c)) {
                String hintRegion = String.isNotBlank(cfg.Core_MDF_Approval_Region_Options__c)
                    ? ' Valid: ' + cfg.Core_MDF_Approval_Region_Options__c : '';
                errors.add('Approval Region is mandatory for this role.' + hintRegion);
            } else if (String.isNotBlank(cfg.Core_MDF_Approval_Region_Options__c)) {
                Set<String> validAR = new Set<String>();
                for (String r : cfg.Core_MDF_Approval_Region_Options__c.split(';')) {
                    validAR.add(r.trim());
                }
                for (String r : rec.Core_MDF_Approval_Region_nm__c.split(';')) {
                    if (!validAR.contains(r.trim())) {
                        errors.add('Invalid Approval Region [' + r.trim() + ']. '
                            + 'Valid: ' + cfg.Core_MDF_Approval_Region_Options__c);
                    }
                }
            }
        }

        if (cfg.Core_MDF_Activity_Classification_Req__c) {
            if (String.isBlank(rec.Core_MDF_Activity_Classification_nm__c)) {
                errors.add('Activity Classification is mandatory. '
                    + 'Valid values: Marketing, Sales');
            } else {
                Set<String> validAC = new Set<String>{ 'Marketing', 'Sales' };
                List<String> badAC = new List<String>();
                for (String v : rec.Core_MDF_Activity_Classification_nm__c.split(';')) {
                    String trimmed = v.trim();
                    if (String.isBlank(trimmed)) continue;
                    if (!validAC.contains(trimmed)) badAC.add(trimmed);
                }
                if (!badAC.isEmpty()) {
                    errors.add('Invalid Activity Classification ['
                        + String.join(badAC, ', ') + ']. '
                        + 'Valid: Marketing, Sales');
                }
            }
        }

        return errors;
    }

    /** True when role is AGS-only and no region-to-AGS-role map is configured. */
    private static Boolean isGenericAgsOnlyRole(Core_MDF_IUPGM_Rule_Config__mdt cfg) {
        return !cfg.Core_MDF_IUPGM_Required__c
            && String.isBlank(cfg.Core_MDF_Region_AGS_Role_Map__c);
    }

    /** True when role is AGS-only and region decides the AGS role via region map. */
    private static Boolean isRegionMappedAgsOnlyRole(Core_MDF_IUPGM_Rule_Config__mdt cfg) {
        return !cfg.Core_MDF_IUPGM_Required__c
            && String.isNotBlank(cfg.Core_MDF_Region_AGS_Role_Map__c);
    }

  /******************************************************************************************************
    Method Name:        loadConfigCache
    Description:        Loads the active rule configuration metadata into a static in-memory cache.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    private static void loadConfigCache() {
        if (configCache != null) return;
        configCache = new Map<String, Core_MDF_IUPGM_Rule_Config__mdt>();
        for (Core_MDF_IUPGM_Rule_Config__mdt cfg : [
            SELECT  MasterLabel,
                    Core_MDF_Role_Label__c,
                    Core_MDF_Permission_Set_Name__c,
                    Core_MDF_IUPGM_Role_Name__c,
                    Core_MDF_Program__c,
                    Core_MDF_All_Accounts__c,
                    Core_MDF_Account_Required__c,
                    Core_MDF_Region_AGS_Role_Map__c,
                    Core_MDF_Region_Options__c,
                    Core_MDF_WW_Only__c,
                    Core_MDF_All_Budget_Type_Available__c,
                    Core_MDF_Budget_Required_When_False__c,
                    Core_MDF_Geo_Budget_Mapping__c,
                    Core_MDF_IUPGM_Required__c,
                    Core_MDF_Approval_Region_Required__c,
                    Core_MDF_Approval_Region_Options__c,
                    Core_MDF_Activity_Classification_Req__c,
                    Core_MDF_Skip_PS_Check__c,
                    Core_MDF_AGS_Role_Name__c,
                    Core_MDF_Is_Active__c
            FROM Core_MDF_IUPGM_Rule_Config__mdt
            WHERE Core_MDF_Is_Active__c = true
        ]) {
            configCache.put(
                buildKey(cfg.Core_MDF_Permission_Set_Name__c, cfg.Core_MDF_Program__c),
                cfg
            );
            if (String.isBlank(cfg.Core_MDF_Permission_Set_Name__c)
                && String.isNotBlank(cfg.Core_MDF_AGS_Role_Name__c)) {
                configCache.put(
                    buildKey(cfg.Core_MDF_AGS_Role_Name__c, cfg.Core_MDF_Program__c),
                    cfg
                );
            }
        }
    }

    private static String buildKey(String psName, String program) {
        return (String.isNotBlank(psName)  ? psName  : '') + '|'
             + (String.isNotBlank(program) ? program : '');
    }

    /** Resolves active rule config by exact program first, then COMMON fallback. */
    private static Core_MDF_IUPGM_Rule_Config__mdt getRuleConfig(
        String permissionSetName,
        String program
    ) {
        return getRuleConfig(permissionSetName, program, null);
    }

    /**
     * Resolves active rule config by exact program first, then COMMON fallback.
     * When permissionSetName is blank (AGS-only / skip-PS-check roles), falls back
     * to resolving by agsRoleName instead, since that field is always populated on
     * the staging record for these roles even though Role_nm__c/PS name is not.
     */
    private static Core_MDF_IUPGM_Rule_Config__mdt getRuleConfig(
        String permissionSetName,
        String program,
        String agsRoleName
    ) {
        if (String.isBlank(permissionSetName)) {
            return String.isNotBlank(agsRoleName)
                ? getRuleConfig(agsRoleName, program)
                : null;
        }
        Core_MDF_IUPGM_Rule_Config__mdt exact =
            configCache.get(buildKey(permissionSetName, program));
        if (exact != null) return exact;

        if (String.isNotBlank(program)
            && program.trim().equalsIgnoreCase(COMMON_PROGRAM)) {
            return null;
        }
        return configCache.get(buildKey(permissionSetName, COMMON_PROGRAM));
    }

   /******************************************************************************************************
    Method Name:        execute
    Description:        Scheduled entry point that polls AGS for pending request updates.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public void execute(SchedulableContext sc) {
        pollAgsPending();
    }
/******************************************************************************************************
    Method Name:        pollAgsPending
    Description:        Polls pending AGS records and advances them when approval results are available.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public static void pollAgsPending() {

        String baseSelectClause = 'SELECT Id, Core_MDF_IUPGM_User__c, '
            + 'Core_MDF_IUPGM_Role_nm__c, Core_MDF_AGS_Request_Type__c, '
            + 'Core_MDF_Request_Status_nm__c, Core_MDF_AGS_Request_Id__c, '
            + 'Core_MDF_Request_Type_nm__c, Core_MDF_Pending_Dependent_Role_txt__c, '
            + 'Core_MDF_IUPGM_User__r.IsActive, '
            + 'Core_MDF_IUPGM_User__r.FederationIdentifier, '
            + 'Core_MDF_IUPGM_User__r.Email, Core_MDF_Error_Message_txt__c';
        String optionalSelectClause = ', Core_MDF_New_User_Name__c'
            + ', Core_MDF_New_User_Email__c'
            + ', Core_MDF_New_User_Federation_Id__c';
        List<Core_MDF_IUPGM_Request_Staging__c> pending;
        try {
            pending = Database.query(
                baseSelectClause + optionalSelectClause
                + ' FROM Core_MDF_IUPGM_Request_Staging__c'
                + ' WHERE Core_MDF_Is_IUPGM_Processed__c = false'
                + '   AND Core_MDF_AGS_Status_nm__c = \'Submitted\''
                + '   AND Core_MDF_Request_Status_nm__c IN'
                + '       (\'AGS_User_Creation_Pending\', \'AGS_PS_Pending\')'
                + ' LIMIT 2000'
            );
        } catch (QueryException qe) {
            pending = Database.query(
                baseSelectClause
                + ' FROM Core_MDF_IUPGM_Request_Staging__c'
                + ' WHERE Core_MDF_Is_IUPGM_Processed__c = false'
                + '   AND Core_MDF_AGS_Status_nm__c = \'Submitted\''
                + '   AND Core_MDF_Request_Status_nm__c IN'
                + '       (\'AGS_User_Creation_Pending\', \'AGS_PS_Pending\')'
                + ' LIMIT 2000'
            );
        }

        pollAgsPendingBatch(pending);
    }
/******************************************************************************************************
    Method Name:        pollAgsPendingQueryLocator
    Description:        Query locator for staging records awaiting an AGS outcome, used by the scheduled
                         Core_MDF_AGS_PollStatus_Batch batch job to chunk records safely across executions.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Query locator for staging records awaiting an AGS outcome. */
    public static Database.QueryLocator pollAgsPendingQueryLocator() {
        String baseSelectClause = 'SELECT Id, Core_MDF_IUPGM_User__c, '
            + 'Core_MDF_IUPGM_Role_nm__c, Core_MDF_AGS_Request_Type__c, '
            + 'Core_MDF_Request_Status_nm__c, Core_MDF_AGS_Request_Id__c, '
            + 'Core_MDF_Request_Type_nm__c, Core_MDF_Pending_Dependent_Role_txt__c, '
            + 'Core_MDF_IUPGM_User__r.IsActive, '
            + 'Core_MDF_IUPGM_User__r.FederationIdentifier, '
            + 'Core_MDF_IUPGM_User__r.Email, Core_MDF_Error_Message_txt__c';
        String optionalSelectClause = ', Core_MDF_New_User_Name__c'
            + ', Core_MDF_New_User_Email__c'
            + ', Core_MDF_New_User_Federation_Id__c';
        try {
            return Database.getQueryLocator(
                baseSelectClause + optionalSelectClause
                + ' FROM Core_MDF_IUPGM_Request_Staging__c'
                + ' WHERE Core_MDF_Is_IUPGM_Processed__c = false'
                + '   AND Core_MDF_AGS_Status_nm__c = \'Submitted\''
                + '   AND Core_MDF_Request_Status_nm__c IN'
                + '       (\'AGS_User_Creation_Pending\', \'AGS_PS_Pending\')'
            );
        } catch (QueryException qe) {
            return Database.getQueryLocator(
                baseSelectClause
                + ' FROM Core_MDF_IUPGM_Request_Staging__c'
                + ' WHERE Core_MDF_Is_IUPGM_Processed__c = false'
                + '   AND Core_MDF_AGS_Status_nm__c = \'Submitted\''
                + '   AND Core_MDF_Request_Status_nm__c IN'
                + '       (\'AGS_User_Creation_Pending\', \'AGS_PS_Pending\')'
            );
        }
    }
/******************************************************************************************************
    Method Name:        pollAgsPendingBatch
    Description:        Core AGS polling logic operating on a caller-supplied chunk of staging records.
                         Shared by pollAgsPending() (ad-hoc) and Core_MDF_AGS_PollStatus_Batch (scheduled).
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Processes a chunk of pending AGS staging records and advances their status. */
    public static void pollAgsPendingBatch(
        List<Core_MDF_IUPGM_Request_Staging__c> pending
    ) {

        if (pending == null || pending.isEmpty()) {
            return;
        }

        // Bulk load ACTIVE permission set assignments for all pending users.
        Set<Id> userIds = new Set<Id>();
        for (Core_MDF_IUPGM_Request_Staging__c rec : pending) {
            if (rec.Core_MDF_IUPGM_User__c != null) {
                userIds.add(rec.Core_MDF_IUPGM_User__c);
            }
        }

        Map<Id, Set<String>> userPSMap = new Map<Id, Set<String>>();
        for (PermissionSetAssignment psa : [
            SELECT AssigneeId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId IN :userIds
              AND IsActive = true
        ]) {
            if (!userPSMap.containsKey(psa.AssigneeId)) {
                userPSMap.put(psa.AssigneeId, new Set<String>());
            }
            userPSMap.get(psa.AssigneeId).add(psa.PermissionSet.Name);
        }

        Set<String> pendingFedIds = new Set<String>();
        Set<String> pendingEmails = new Set<String>();
        Map<Id, Map<String, String>> metadataByStaging = new Map<Id, Map<String, String>>();
        for (Core_MDF_IUPGM_Request_Staging__c rec : pending) {
            if (rec.Core_MDF_Request_Status_nm__c != 'AGS_User_Creation_Pending'
                || rec.Core_MDF_IUPGM_User__c != null) {
                continue;
            }
            Map<String, String> meta = parseNewUserMetadata(rec);
            metadataByStaging.put(rec.Id, meta);
            if (String.isNotBlank(meta.get('fed'))) {
                pendingFedIds.add(meta.get('fed'));
            }
            if (String.isNotBlank(meta.get('email'))) {
                pendingEmails.add(meta.get('email'));
            }
        }

        Map<String, User> userByFed = new Map<String, User>();
        Map<String, User> userByEmail = new Map<String, User>();
        if (!pendingFedIds.isEmpty()) {
            for (User u : [
                SELECT Id, FederationIdentifier, Email, IsActive
                FROM User
                WHERE FederationIdentifier IN :pendingFedIds
            ]) {
                if (String.isNotBlank(u.FederationIdentifier)) {
                    userByFed.put(u.FederationIdentifier.toLowerCase(), u);
                }
            }
        }
        if (!pendingEmails.isEmpty()) {
            for (User u : [
                SELECT Id, FederationIdentifier, Email, IsActive
                FROM User
                WHERE Email IN :pendingEmails
            ]) {
                if (String.isNotBlank(u.Email)) {
                    userByEmail.put(u.Email.toLowerCase(), u);
                }
            }
        }

        List<Core_MDF_IUPGM_Request_Staging__c> toApprove =
            new List<Core_MDF_IUPGM_Request_Staging__c>();

        // Reuse a single queueable instance (and its cached OAuth token) across
        // all AGS status callouts in this run to stay within callout/token limits.
        Core_MDF_AGS_CalloutQueueable agsClient = new Core_MDF_AGS_CalloutQueueable(
            new Set<Id>(),
            Core_MDF_AGS_CalloutQueueable.CalloutType.PERMISSION_SET_REQUEST
        );

        // Governor limits allow at most 100 callouts per transaction; cap AGS
        // status polling below that to leave headroom for the OAuth token call.
        Integer maxAgsStatusCallouts  = 90;
        Integer agsStatusCalloutsMade = 0;

        for (Core_MDF_IUPGM_Request_Staging__c rec : pending) {

            if (rec.Core_MDF_Request_Status_nm__c == 'AGS_PS_Pending') {

                Boolean resolvedViaAgs = false;

                // Ask AGS directly for the real approval/provisioning status
                // using the request "name" captured in Core_MDF_AGS_Request_Id__c.
                if (String.isNotBlank(rec.Core_MDF_AGS_Request_Id__c)
                    && agsStatusCalloutsMade < maxAgsStatusCallouts) {

                    agsStatusCalloutsMade++;
                    Core_MDF_AGS_CalloutQueueable.AgsStatusResult status =
                        agsClient.checkRequestStatus(rec.Core_MDF_AGS_Request_Id__c);

                    if (status.success) {
                        resolvedViaAgs = true;
                        String approval     = status.approvalStatus;
                        String provisioning = status.provisioningStatus;

                        if (approval == 'Rejected' || approval == 'Denied') {
                            toApprove.add(new Core_MDF_IUPGM_Request_Staging__c(
                                Id                             = rec.Id,
                                Core_MDF_AGS_Status_nm__c      = 'Rejected',
                                Core_MDF_Request_Status_nm__c  = 'AGS_Rejected',
                                Core_MDF_Error_Message_txt__c  =
                                    'AGS rejected the permission set request. approvalStatus=' + approval
                                    + (String.isNotBlank(provisioning)
                                        ? ', provisioningStatus=' + provisioning : '')
                            ));
                        } else if (provisioning == 'Failed' || approval == 'Failed') {
                            toApprove.add(new Core_MDF_IUPGM_Request_Staging__c(
                                Id                             = rec.Id,
                                Core_MDF_AGS_Status_nm__c      = 'Error',
                                Core_MDF_Request_Status_nm__c  = 'Error',
                                Core_MDF_Error_Message_txt__c  =
                                    'AGS provisioning failed. approvalStatus=' + approval
                                    + ', provisioningStatus=' + provisioning
                            ));
                        } else if (approval == 'Approved') {
                            toApprove.add(new Core_MDF_IUPGM_Request_Staging__c(
                                Id                        = rec.Id,
                                Core_MDF_AGS_Status_nm__c = 'Approved'
                            ));
                        }
                        // else: still Pending/InProgress at AGS - leave as is.

                    } else {
                        System.debug('AGS status check failed for staging '
                            + rec.Id + ': ' + status.error);
                    }
                }

                if (!resolvedViaAgs) {
                    // Fallback for legacy records with no captured AGS request
                    // name, or when the AGS status callout itself failed: use
                    // the local PermissionSetAssignment check as a best-effort
                    // signal (same behavior as before this change).
                    // For REVOKE requests the meaning is inverted: "done" means
                    // the Permission Set is now ABSENT (successfully removed),
                    // not present.
                    Set<String> ps = userPSMap.get(rec.Core_MDF_IUPGM_User__c);
                    Boolean hasPsLocally = ps != null
                        && String.isNotBlank(rec.Core_MDF_IUPGM_Role_nm__c)
                        && ps.contains(rec.Core_MDF_IUPGM_Role_nm__c);
                    Boolean done = rec.Core_MDF_Request_Type_nm__c == 'REVOKE'
                        ? !hasPsLocally
                        : hasPsLocally;
                    if (done) {
                        toApprove.add(new Core_MDF_IUPGM_Request_Staging__c(
                            Id                        = rec.Id,
                            Core_MDF_AGS_Status_nm__c = 'Approved'
                        ));
                    }
                }

            } else if (rec.Core_MDF_Request_Status_nm__c
                       == 'AGS_User_Creation_Pending') {

                Boolean rejectedOrFailed = false;

                // Chained Core-Access rows only: ask AGS whether the request was
                // rejected, so the parked dependent role is never raised. Other
                // user-creation rows keep the existing existence-based check below.
                if (String.isNotBlank(rec.Core_MDF_Pending_Dependent_Role_txt__c)
                    && String.isNotBlank(rec.Core_MDF_AGS_Request_Id__c)
                    && agsStatusCalloutsMade < maxAgsStatusCallouts) {

                    agsStatusCalloutsMade++;
                    Core_MDF_AGS_CalloutQueueable.AgsStatusResult status =
                        agsClient.checkRequestStatus(rec.Core_MDF_AGS_Request_Id__c);

                    if (status.success) {
                        String approval     = status.approvalStatus;
                        String provisioning = status.provisioningStatus;

                        if (approval == 'Rejected' || approval == 'Denied') {
                            rejectedOrFailed = true;
                            toApprove.add(new Core_MDF_IUPGM_Request_Staging__c(
                                Id                             = rec.Id,
                                Core_MDF_AGS_Status_nm__c      = 'Rejected',
                                Core_MDF_Request_Status_nm__c  = 'AGS_Rejected',
                                Core_MDF_Error_Message_txt__c  =
                                    'AGS rejected the user creation request. approvalStatus=' + approval
                                    + (String.isNotBlank(provisioning)
                                        ? ', provisioningStatus=' + provisioning : '')
                            ));
                        } else if (provisioning == 'Failed' || approval == 'Failed') {
                            rejectedOrFailed = true;
                            toApprove.add(new Core_MDF_IUPGM_Request_Staging__c(
                                Id                             = rec.Id,
                                Core_MDF_AGS_Status_nm__c      = 'Error',
                                Core_MDF_Request_Status_nm__c  = 'Error',
                                Core_MDF_Error_Message_txt__c  =
                                    'AGS user creation failed. approvalStatus=' + approval
                                    + ', provisioningStatus=' + provisioning
                            ));
                        }
                        // else: still Pending/InProgress at AGS - fall through to
                        // the existence-based check below, unchanged.
                    } else {
                        System.debug('AGS status check failed for staging '
                            + rec.Id + ': ' + status.error);
                    }
                }

                if (rejectedOrFailed) continue;

                // User created by AGS should now exist and be active.
                if (rec.Core_MDF_IUPGM_User__c != null
                    && rec.Core_MDF_IUPGM_User__r.IsActive == true) {
                    toApprove.add(new Core_MDF_IUPGM_Request_Staging__c(
                        Id                        = rec.Id,
                        Core_MDF_AGS_Status_nm__c = 'Approved'
                    ));
                } else if (rec.Core_MDF_IUPGM_User__c == null) {
                    Map<String, String> meta = metadataByStaging.get(rec.Id);
                    User resolved = null;
                    if (meta != null && String.isNotBlank(meta.get('fed'))) {
                        resolved = userByFed.get(meta.get('fed').toLowerCase());
                    }
                    if (resolved == null && meta != null && String.isNotBlank(meta.get('email'))) {
                        resolved = userByEmail.get(meta.get('email').toLowerCase());
                    }
                    if (resolved != null && resolved.IsActive) {
                        toApprove.add(new Core_MDF_IUPGM_Request_Staging__c(
                            Id                        = rec.Id,
                            Core_MDF_IUPGM_User__c    = resolved.Id,
                            Core_MDF_AGS_Status_nm__c = 'Approved'
                        ));
                    }
                }
            }
        }

        if (!toApprove.isEmpty()) {
            
            update toApprove;
        }

    }
/******************************************************************************************************
    Method Name:        parseNewUserMetadata
    Description:        Parses the encoded new-user metadata blob into a key/value map.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Reads structured new-user staging fields. */
    private static Map<String, String> parseNewUserMetadata(
        Core_MDF_IUPGM_Request_Staging__c rec
    ) {
        String newUserName = Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
            rec, 'Core_MDF_New_User_Name__c'
        );
        String newUserEmail = Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
            rec, 'Core_MDF_New_User_Email__c'
        );
        String newUserFed = Core_MDF_AGS_CalloutQueueable.getStagingFieldStringIfPresent(
            rec, 'Core_MDF_New_User_Federation_Id__c'
        );
        return new Map<String, String>{
            'name' => String.isNotBlank(newUserName) ? newUserName.trim() : null,
            'email' => String.isNotBlank(newUserEmail) ? newUserEmail.trim().toLowerCase() : null,
            'fed' => String.isNotBlank(newUserFed) ? newUserFed.trim() : null
        };
    }

    private static final Set<String> SUCCESS_STATUSES =
        new Set<String>{ 'Completed' };
    private static final Set<String> SKIPPED_STATUSES =
        new Set<String>{ 'Skipped' };
    private static final Set<String> FAILURE_STATUSES =
        new Set<String>{ 'Error', 'Validation_Failed',
                         'External_User_Blocked', 'AGS_Rejected' };
    @TestVisible private static Id notificationOrgWideEmailIdOverride;
    @TestVisible private static String notificationOrgWideEmailDisplayNameOverride;
/******************************************************************************************************
    Method Name:        notifyRequestedUsers
    Description:        Sends the request completion email to the user tied to the supplied staging records.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public static void notifyRequestedUsers(Set<Id> stagingIds) {
        System.debug('IUPGM_EMAIL [notifyRequestedUsers] called. stagingIds size: '
            + (stagingIds != null ? stagingIds.size() : 0) + ' | ids: ' + stagingIds);
        if (stagingIds == null || stagingIds.isEmpty()) return;

        try {
            List<String> selectFields = new List<String>{
                'Id', 'Name',
                'Core_MDF_Request_Status_nm__c',
                'Core_MDF_Error_Message_txt__c',
                'Core_MDF_IUPGM_Role_nm__c',
                'Core_MDF_IUPGM_Program__c',
                'Core_MDF_AGS_Request_Type__c',
                'Core_MDF_Requestor_Email__c',
                'Core_MDF_AGS_Role_Name__c',
                'Core_MDF_Request_Type_nm__c',
                'Core_MDF_IUPGM_User__r.FirstName',
                'Core_MDF_IUPGM_User__r.Name',
                'Core_MDF_IUPGM_User__r.Email'
            };
            if (hasStagingField('Core_MDF_New_User_Name__c')) {
                selectFields.add('Core_MDF_New_User_Name__c');
            }
            if (hasStagingField('Core_MDF_New_User_Email__c')) {
                selectFields.add('Core_MDF_New_User_Email__c');
            }
            if (hasStagingField('Core_MDF_New_User_Federation_Id__c')) {
                selectFields.add('Core_MDF_New_User_Federation_Id__c');
            }
            List<Core_MDF_IUPGM_Request_Staging__c> recs = Database.query(
                'SELECT ' + String.join(selectFields, ', ')
                + ' FROM Core_MDF_IUPGM_Request_Staging__c'
                + ' WHERE Id IN :stagingIds'
            );
            System.debug('IUPGM_EMAIL [notifyRequestedUsers] SOQL returned ' + recs.size() + ' records.');

            Map<String, String> roleLabelMap = buildActiveRoleLabelMap();

            List<Messaging.SingleEmailMessage> emails =
                new List<Messaging.SingleEmailMessage>();

            for (Core_MDF_IUPGM_Request_Staging__c rec : recs) {
                String status = rec.Core_MDF_Request_Status_nm__c;
                Boolean isSuccess = SUCCESS_STATUSES.contains(status);
                Boolean isSkipped = SKIPPED_STATUSES.contains(status);
                Boolean isFailure = FAILURE_STATUSES.contains(status);
                System.debug('IUPGM_EMAIL [notifyRequestedUsers] rec=' + rec.Id
                    + ' | status=' + status
                    + ' | isSuccess=' + isSuccess
                    + ' | isSkipped=' + isSkipped
                    + ' | isFailure=' + isFailure);
                if (!isSuccess && !isSkipped && !isFailure) {
                    System.debug('IUPGM_EMAIL [notifyRequestedUsers] SKIPPED rec=' + rec.Id + ' — status not in SUCCESS/SKIPPED/FAILURE sets.');
                    continue;
                }

                
                String targetName = resolveNotificationTargetName(rec);
                String toAddr = String.isNotBlank(rec.Core_MDF_Requestor_Email__c)
                    ? rec.Core_MDF_Requestor_Email__c.trim()
                    : null;
                System.debug('IUPGM_EMAIL [notifyRequestedUsers] rec=' + rec.Id
                    + ' | targetName=' + targetName
                    + ' | toAddr=' + toAddr
                    + ' | Core_MDF_Requestor_Email__c=' + rec.Core_MDF_Requestor_Email__c);
                if (String.isBlank(toAddr)) {
                    System.debug('IUPGM_EMAIL [notifyRequestedUsers] SKIPPED rec=' + rec.Id + ' — Core_MDF_Requestor_Email__c is blank.');
                    continue;
                }

                String roleLabel = resolveNotificationRoleLabel(rec, roleLabelMap);
                String programLine = buildNotificationProgramLine(rec, roleLabel);
                Boolean isRevoke = rec.Core_MDF_Request_Type_nm__c == 'REVOKE';
                Boolean isCopy   = rec.Core_MDF_Request_Type_nm__c == 'COPY';
                String subjectPrefix = isCopy ? '[Copy User Access] ' : '';

                String greeting  = 'Dear Intel employee,';

                String subject;
                String body;
                if (isSuccess) {
                    subject = subjectPrefix + (isRevoke ? 'Access Removed - ' : 'Access Granted - ') + roleLabel
                        + ' (' + rec.Name + ')';
                    body = greeting + '\n\n'
                        + 'The access request you submitted for ' + targetName
                        + (isRevoke
                            ? ' has had its IUPGM access deactivated successfully. AGS access was not changed.\n\n'
                            : ' has been provisioned successfully.\n\n')
                        + 'Request Number : ' + rec.Name + '\n'
                        + 'User           : ' + targetName + '\n'
                        + 'Role           : ' + roleLabel + '\n'
                        + programLine
                        + 'Status         : ' + status + '\n\n'
                        + 'Thank you,\nIntel® Partner Investment Center';
                } else if (isSkipped) {
                    subject = subjectPrefix + 'Access Request - ' + roleLabel
                        + ' (' + rec.Name + ')';
                    body = greeting + '\n\n'
                        + 'The access request you submitted for ' + targetName
                        + ' has been processed.\n\n'
                        + 'Request Number : ' + rec.Name + '\n'
                        + 'User           : ' + targetName + '\n'
                        + 'Role           : ' + roleLabel + '\n'
                        + programLine
                        + 'Status         : Skipped\n'
                        + 'Reason         : ' + (String.isNotBlank(rec.Core_MDF_Error_Message_txt__c)
                            ? humanizeError(rec.Core_MDF_Error_Message_txt__c, targetName)
                            : (isRevoke
                                ? targetName + ' does not currently have this access.'
                                : targetName + ' already has this access provisioned.')) + '\n\n'
                        + 'Thank you,\nIntel® Partner Investment Center';
                } else {
                    subject = subjectPrefix + (isRevoke ? 'Access Removal Failed - ' : 'Access Request Failed - ')
                        + roleLabel + ' (' + rec.Name + ')';
                    body = greeting + '\n\n'
                        + 'The ' + (isRevoke ? 'access removal request' : 'access request')
                        + ' you submitted for ' + targetName
                        + ' could not be completed.\n\n'
                        + 'Request Number : ' + rec.Name + '\n'
                        + 'User           : ' + targetName + '\n'
                        + 'Role           : ' + roleLabel + '\n'
                        + programLine
                        + 'Status         : ' + status + '\n'
                        + 'Reason         : ' + (String.isNotBlank(rec.Core_MDF_Error_Message_txt__c)
                            ? humanizeError(rec.Core_MDF_Error_Message_txt__c, targetName)
                            : 'An error occurred while processing the request.') + '\n\n'
                        + 'Please submit a new request, or contact your administrator for help.\n\n'
                        + 'Thank you,\nIntel® Partner Investment Center';
                }

                Messaging.SingleEmailMessage msg =
                    new Messaging.SingleEmailMessage();
                msg.setToAddresses(new List<String>{ toAddr });
                msg.setSubject(subject);
                msg.setPlainTextBody(body);
                msg.setSaveAsActivity(false);
                applyNotificationSender(msg);
                emails.add(msg);
                System.debug('IUPGM_EMAIL [notifyRequestedUsers] email queued for rec=' + rec.Id + ' | to=' + toAddr + ' | subject=' + subject);
            }

            System.debug('IUPGM_EMAIL [notifyRequestedUsers] total emails to send: ' + emails.size());
            if (!emails.isEmpty()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails, false);
                System.debug('IUPGM_EMAIL [notifyRequestedUsers] Messaging.sendEmail completed. results.size()=' + results.size());
                for (Integer i = 0; i < results.size(); i++) {
                    Messaging.SendEmailResult r = results[i];
                    System.debug('IUPGM_EMAIL [notifyRequestedUsers] email[' + i + '] isSuccess=' + r.isSuccess()
                        + ' | errors=' + r.getErrors());
                }
            }
        } catch (Exception e) {
            System.debug('IUPGM_EMAIL [notifyRequestedUsers] EXCEPTION: ' + e.getMessage()
                + ' | stack: ' + e.getStackTraceString());
        }
    }

/******************************************************************************************************
    Method Name:        buildActiveRoleLabelMap
    Description:        Builds the Core_MDF_Role_Label__c lookup map keyed by permissionSetName|program
                         (and agsRoleName|program for AGS-only roles with no permission set), sourced
                         from active Core_MDF_IUPGM_Rule_Config__mdt rows. Extracted unchanged from the
                         inline block that used to live directly in notifyRequestedUsers(), so both that
                         method and notifyCopyOperationIfComplete() share one identical implementation.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static Map<String, String> buildActiveRoleLabelMap() {
        Map<String, String> roleLabelMap = new Map<String, String>();
        for (Core_MDF_IUPGM_Rule_Config__mdt cfg : [
            SELECT Core_MDF_Permission_Set_Name__c, Core_MDF_Role_Label__c,
                   Core_MDF_Program__c, Core_MDF_AGS_Role_Name__c
            FROM Core_MDF_IUPGM_Rule_Config__mdt
            WHERE Core_MDF_Is_Active__c = true
        ]) {
            roleLabelMap.put(
                buildKey(cfg.Core_MDF_Permission_Set_Name__c, cfg.Core_MDF_Program__c),
                cfg.Core_MDF_Role_Label__c
            );
            if (String.isBlank(cfg.Core_MDF_Permission_Set_Name__c)
                && String.isNotBlank(cfg.Core_MDF_AGS_Role_Name__c)) {
                roleLabelMap.put(
                    buildKey(cfg.Core_MDF_AGS_Role_Name__c, cfg.Core_MDF_Program__c),
                    cfg.Core_MDF_Role_Label__c
                );
            }
        }
        return roleLabelMap;
    }

/******************************************************************************************************
    Method Name:        notifyCopyOperationIfComplete
    Description:        For each given Copy Operation Id, re-queries every staging record sharing it
                         and, only once ALL of them have reached a terminal status, sends ONE
                         consolidated completion email listing every role's outcome to the original
                         requester. Operations where at least one role is still unresolved are skipped
                         entirely (no partial email) - the next role to resolve re-triggers this check
                         via Core_MDF_IUPGMReqStaging_TriggerHandler.afterUpdate(), which also guards
                         against ever calling this for GRANT/REVOKE records.
    Added By:           Ramapriya
    *******************************************************************************************************/
    public static void notifyCopyOperationIfComplete(Set<String> copyOperationIds) {
        if (copyOperationIds == null || copyOperationIds.isEmpty()) return;

        try {
        List<Core_MDF_IUPGM_Request_Staging__c> allRows = [
            SELECT Id, Name, Core_MDF_Copy_Operation_Id__c, Core_MDF_Request_Status_nm__c,
                   Core_MDF_Error_Message_txt__c, Core_MDF_IUPGM_Role_nm__c, Core_MDF_IUPGM_Program__c,
                   Core_MDF_AGS_Role_Name__c, Core_MDF_Requestor_Email__c,
                   Core_MDF_Copy_Source_User_txt__c, Core_MDF_IUPGM_User__c, Core_MDF_IUPGM_User__r.Name
            FROM Core_MDF_IUPGM_Request_Staging__c
            WHERE Core_MDF_Copy_Operation_Id__c IN :copyOperationIds
        ];
        if (allRows.isEmpty()) return;

        Map<String, List<Core_MDF_IUPGM_Request_Staging__c>> byOperation =
            new Map<String, List<Core_MDF_IUPGM_Request_Staging__c>>();
        for (Core_MDF_IUPGM_Request_Staging__c rec : allRows) {
            String opId = rec.Core_MDF_Copy_Operation_Id__c;
            if (!byOperation.containsKey(opId)) {
                byOperation.put(opId, new List<Core_MDF_IUPGM_Request_Staging__c>());
            }
            byOperation.get(opId).add(rec);
        }

        Map<String, String> roleLabelMap = buildActiveRoleLabelMap();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (String opId : byOperation.keySet()) {
            List<Core_MDF_IUPGM_Request_Staging__c> rows = byOperation.get(opId);

            Boolean allTerminal = true;
            for (Core_MDF_IUPGM_Request_Staging__c r : rows) {
                if (!Core_MDF_CCP_ConstantClass.IUPGM_TERMINAL_STATUSES.contains(
                        r.Core_MDF_Request_Status_nm__c)) {
                    allTerminal = false;
                    break;
                }
            }
            // At least one role in this copy operation is still unresolved - wait for
            // it to complete before sending anything. The next role to reach a
            // terminal status re-triggers this check for the whole operation.
            if (!allTerminal) continue;

            String toAddr = null;
            String targetName = 'the requested user';
            String sourceName = null;
            Id targetUserId = null;
            for (Core_MDF_IUPGM_Request_Staging__c r : rows) {
                if (String.isBlank(toAddr) && String.isNotBlank(r.Core_MDF_Requestor_Email__c)) {
                    toAddr = r.Core_MDF_Requestor_Email__c.trim();
                }
                if (String.isBlank(sourceName) && String.isNotBlank(r.Core_MDF_Copy_Source_User_txt__c)) {
                    sourceName = r.Core_MDF_Copy_Source_User_txt__c;
                }
                if (r.Core_MDF_IUPGM_User__r != null && String.isNotBlank(r.Core_MDF_IUPGM_User__r.Name)) {
                    targetName = r.Core_MDF_IUPGM_User__r.Name;
                }
                if (targetUserId == null) targetUserId = r.Core_MDF_IUPGM_User__c;
            }
            if (String.isBlank(toAddr)) continue;

            // Replicate the source user's active IUPGM combinations onto the target now that every
            // AGS role in this copy operation has reached a terminal status. This call only happens
            // once per operation because this entire method only reaches here once per operation
            // (see the allTerminal guard above), so no extra tracking field is required to avoid
            // duplicate processing. The outcome is intentionally not surfaced in the completion
            // email (kept exactly as before) - it is only available via debug logs.
            Core_MDF_IUPGM_CopyService.CopyOutcome iupgmOutcome =
                Core_MDF_IUPGM_CopyService.copyForOperation(targetUserId, sourceName);
            System.debug('IUPGM_COPY [notifyCopyOperationIfComplete] op=' + opId
                + ' identified=' + iupgmOutcome.sourceCount
                + ' created=' + iupgmOutcome.createdCount
                + ' skipped=' + iupgmOutcome.skippedCount
                + ' failed=' + iupgmOutcome.failedCount
                + ' note=' + iupgmOutcome.message);

            Boolean anyFailed = false;
            List<String> tableRows = new List<String>();
            for (Core_MDF_IUPGM_Request_Staging__c r : rows) {
                String roleLabel = resolveNotificationRoleLabel(r, roleLabelMap);
                String status = r.Core_MDF_Request_Status_nm__c;
                Boolean passed = SUCCESS_STATUSES.contains(status) || SKIPPED_STATUSES.contains(status);
                if (!passed) anyFailed = true;
                tableRows.add(roleLabel + ' | ' + (passed ? 'Pass' : 'Fail'));
            }

            // One subject for every outcome, per the copy completion email spec.
            String subject = 'Sandbox: Access Request Completed - ' + targetName;
            String tableHtml = '<table border="1" cellpadding="6" cellspacing="0">'
                + '<tr><th align="left">Role</th><th align="left">Status</th></tr>';
            String tableText = 'Role | Status\n';
            for (String rowText : tableRows) {
                List<String> cells = rowText.split(' \\| ');
                tableHtml += '<tr><td>' + cells[0] + '</td><td>' + cells[1] + '</td></tr>';
                tableText += rowText + '\n';
            }
            tableHtml += '</table>';

            String supportLine = anyFailed
                ? 'One or more roles could not be assigned. Please reach out to the support team '
                    + 'for assistance with the failed roles.'
                : '';

            String sourceSentence = String.isNotBlank(sourceName)
                ? 'Access was copied from ' + sourceName + '. ' : '';

            String body = 'Dear Intel employee,\n\n'
                + 'Your Copy User Access request for ' + targetName + ' has completed. '
                + sourceSentence
                + 'Summary of all requested roles:\n\n'
                + tableText + '\n'
                + supportLine + (anyFailed ? '\n\n' : '')
                + 'Thank you,\nIntel\u00AE Partner Investment Center';

            String htmlBody = '<p>Dear Intel employee,</p>'
                + '<p>Your Copy User Access request for ' + targetName + ' has completed. '
                + sourceSentence + 'Summary of all requested roles:</p>'
                + tableHtml
                + (anyFailed ? '<p>' + supportLine + '</p>' : '')
                + '<p>Thank you,<br/>Intel&reg; Partner Investment Center</p>';

            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setToAddresses(new List<String>{ toAddr });
            msg.setSubject(subject);
            msg.setPlainTextBody(body);
            msg.setHtmlBody(htmlBody);
            msg.setSaveAsActivity(false);
            applyNotificationSender(msg);
            emails.add(msg);
        }

        if (!emails.isEmpty()) {
            System.debug('IUPGM_EMAIL [notifyCopyOperationIfComplete] sending '
                + emails.size() + ' consolidated email(s) for operations: ' + byOperation.keySet());
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails, false);
            for (Integer i = 0; i < results.size(); i++) {
                System.debug('IUPGM_EMAIL [notifyCopyOperationIfComplete] email[' + i
                    + '] isSuccess=' + results[i].isSuccess() + ' | errors=' + results[i].getErrors());
            }
        } else {
            System.debug('IUPGM_EMAIL [notifyCopyOperationIfComplete] no operations fully '
                + 'terminal yet among: ' + copyOperationIds);
        }
        } catch (Exception e) {
            // Never let an email-sending failure roll back the staging record status
            // updates that already succeeded as real business outcomes - same
            // defensive pattern as notifyRequestedUsers().
            System.debug('IUPGM_EMAIL [notifyCopyOperationIfComplete] EXCEPTION: '
                + e.getMessage() + ' | stack: ' + e.getStackTraceString());
        }
    }

    @TestVisible
    private static Boolean hasStagingField(String fieldApiName) {
        if (String.isBlank(fieldApiName)) {
            return false;
        }
        return Schema.getGlobalDescribe()
            .get('Core_MDF_IUPGM_Request_Staging__c')
            .getDescribe()
            .fields.getMap()
            .containsKey(fieldApiName);
    }

    @TestVisible
    private static String resolveNotificationTargetName(
        Core_MDF_IUPGM_Request_Staging__c rec
    ) {
        if (rec != null && rec.Core_MDF_IUPGM_User__r != null
            && String.isNotBlank(rec.Core_MDF_IUPGM_User__r.Name)) {
            return rec.Core_MDF_IUPGM_User__r.Name;
        }
        Map<String, String> meta = parseNewUserMetadata(rec);
        if (String.isNotBlank(meta.get('name'))) {
            return meta.get('name');
        }
        if (String.isNotBlank(meta.get('email'))) {
            return meta.get('email');
        }
        return 'the requested user';
    }

    @TestVisible
    private static String resolveNotificationRoleLabel(
        Core_MDF_IUPGM_Request_Staging__c rec,
        Map<String, String> roleLabelMap
    ) {
        String roleLabel = roleLabelMap == null
            ? null
            : roleLabelMap.get(
                buildKey(rec.Core_MDF_IUPGM_Role_nm__c, rec.Core_MDF_IUPGM_Program__c)
            );
        if (String.isBlank(roleLabel)
            && String.isNotBlank(rec.Core_MDF_AGS_Role_Name__c)
            && roleLabelMap != null) {
            roleLabel = roleLabelMap.get(
                buildKey(rec.Core_MDF_AGS_Role_Name__c, rec.Core_MDF_IUPGM_Program__c)
            );
        }
        if (String.isBlank(roleLabel) && String.isNotBlank(rec.Core_MDF_IUPGM_Role_nm__c)) {
            roleLabel = rec.Core_MDF_IUPGM_Role_nm__c;
        }
        if (String.isBlank(roleLabel)
            && isCreateUserNotification(rec)
            && String.isNotBlank(rec.Core_MDF_AGS_Role_Name__c)) {
            roleLabel = Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL;
        }
        return String.isNotBlank(roleLabel) ? roleLabel : 'Requested Access';
    }

    @TestVisible
    private static String buildNotificationProgramLine(
        Core_MDF_IUPGM_Request_Staging__c rec,
        String roleLabel
    ) {
        if (isCreateUserNotification(rec)
            || roleLabel == Core_MDF_CCP_ConstantClass.IUPGM_CORE_ACCESS_ROLE_LABEL
            || String.isBlank(rec.Core_MDF_IUPGM_Program__c)
            || rec.Core_MDF_IUPGM_Program__c.trim().equalsIgnoreCase(COMMON_PROGRAM)) {
            return '';
        }
        return 'Program        : ' + rec.Core_MDF_IUPGM_Program__c + '\n';
    }

    @TestVisible
    private static Boolean isCreateUserNotification(
        Core_MDF_IUPGM_Request_Staging__c rec
    ) {
        return rec != null
            && String.isNotBlank(rec.Core_MDF_AGS_Request_Type__c)
            && (rec.Core_MDF_AGS_Request_Type__c == 'CREATE_USER'
                || rec.Core_MDF_AGS_Request_Type__c == 'USER_CREATION');
    }

    @TestVisible
    private static void applyNotificationSender(Messaging.SingleEmailMessage msg) {
        if (msg == null) {
            return;
        }

        Id orgWideEmailId = resolveNotificationOrgWideEmailAddressId();
        if (orgWideEmailId != null) {
            msg.setOrgWideEmailAddressId(orgWideEmailId);
        }
    }

    @TestVisible
    private static Id resolveNotificationOrgWideEmailAddressId() {
        if (Test.isRunningTest() && notificationOrgWideEmailIdOverride != null) {
            return notificationOrgWideEmailIdOverride;
        }

        String displayName = Test.isRunningTest()
            ? notificationOrgWideEmailDisplayNameOverride
            : System.Label.Core_MDF_IUPGM_OrgWide_Email_Display_Name;
        System.debug('IUPGM_EMAIL [resolveNotificationOrgWideEmailAddressId] displayName=' + displayName);
        if (String.isBlank(displayName)) {
            System.debug('IUPGM_EMAIL [resolveNotificationOrgWideEmailAddressId] displayName is blank — OrgWideEmailAddress will NOT be set.');
            return null;
        }

        List<OrgWideEmailAddress> orgWideEmails = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE DisplayName = :displayName
            LIMIT 2
        ];
        System.debug('IUPGM_EMAIL [resolveNotificationOrgWideEmailAddressId] orgWideEmails.size()=' + orgWideEmails.size() + ' for displayName=' + displayName);
        if (orgWideEmails.size() == 1) {
            System.debug('IUPGM_EMAIL [resolveNotificationOrgWideEmailAddressId] resolved orgWideEmailId=' + orgWideEmails[0].Id);
            return orgWideEmails[0].Id;
        }

        System.debug('IUPGM_EMAIL [resolveNotificationOrgWideEmailAddressId] no unique match found (size=' + orgWideEmails.size() + ') — returning null.');
        return null;
    }

   /******************************************************************************************************
    Method Name:        humanizeError
    Description:        Converts internal exception text into a safer message for user-facing responses.
    Added By:           Ramapriya
    *******************************************************************************************************/
    @TestVisible
    
    public static String humanizeError(String rawError, String targetName) {

        String fallback = 'The request could not be completed because of a '
            + 'system issue. Our support team has been notified. '
            + 'Please try again later or contact your administrator.';

        if (String.isBlank(rawError)) {
            return fallback;
        }

        String lower = rawError.toLowerCase();
        if (lower.contains('iupgm_new_user')) {
            return fallback;
        }

        // ── AGS business-rule rejections ────────────────────────────────────────
        // MUST be checked BEFORE the generic connectivity patterns below because
        // the raw error text often contains both "ags ps request" (from the
        // callout context) AND a specific business reason like "pending add request".
        // Checking specific patterns first ensures the meaningful message wins.
        if (lower.contains('pending add request')) {
            return targetName + ' already has an active access request pending '
                + 'for approval. Please wait for the existing request to be '
                + 'processed before submitting a new one.';
        }

        // ── Integration / connectivity ──────────────────────────────────────────
        if (lower.contains('ags user creation')) {
            return 'We could not create the Salesforce account for '
                + targetName + ' because the user provisioning service '
                + 'is currently unavailable. Your request has been logged '
                + 'and the support team will follow up.';
        }
        if (lower.contains('ags ps request') || lower.contains('ags pS'.toLowerCase())) {
            return 'We could not assign the required system access for '
                + targetName + ' because the access provisioning service '
                + 'is currently unavailable. Your request has been logged '
                + 'and the support team will follow up.';
        }
        if (lower.contains('http 401') || lower.contains('http 403')
            || lower.contains('unauthorized') || lower.contains('forbidden')) {
            return 'The request could not be completed due to a system '
                + 'authorisation issue. The support team has been notified.';
        }
        if (lower.contains('http 404') || lower.contains('path not found')) {
            return 'The request could not be completed because a required '
                + 'system service could not be reached. The support team '
                + 'has been notified.';
        }
        if (lower.contains('http 5') || lower.contains('timed out')
            || lower.contains('timeout') || lower.contains('unable to connect')
            || lower.contains('read timed out')) {
            return 'The request could not be completed because an external '
                + 'system did not respond in time. Please try again later.';
        }
        if (lower.contains('callout') || lower.contains('http ')) {
            return 'The request could not be completed because an external '
                + 'system returned an unexpected response. The support team '
                + 'has been notified.';
        }

        // ── Apex / platform errors ───────────────────────────────────
        if (lower.contains('system.') || lower.contains('exception')
            || lower.contains('null pointer')
            || lower.contains('list has no rows')
            || lower.contains('stack trace')
            || lower.contains('dml') || lower.contains('sobject')
            || lower.contains('field_custom_validation')
            || lower.contains('insufficient_access')
            || lower.contains('string_too_long')) {
            return fallback;
        }

        if (rawError.contains('{') && rawError.contains('}')) {
            return fallback;
        }

        return rawError;
    }


    /** Splits a semicolon-delimited string into a normalized set of values. */
    private static Set<String> splitToSet(String val) {
        Set<String> result = new Set<String>();
        if (String.isBlank(val)) return result;
        for (String s : val.split(';')) {
            String t = s.trim();
            if (String.isNotBlank(t)) result.add(t);
        }
        return result;
    }
/******************************************************************************************************
    Method Name:        parseGeoBudgetJson
    Description:        Parses region-to-budget JSON into a normalized map.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    private static Map<String, List<String>> parseGeoBudgetJson(String jsonString) {
        if (String.isBlank(jsonString)) return null;
        Map<String, List<String>> result = new Map<String, List<String>>();
        try {
            Map<String, Object> raw =
                (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            for (String key : raw.keySet()) {
                List<Object> rawList = (List<Object>) raw.get(key);
                List<String> budgets = new List<String>();
                for (Object b : rawList) budgets.add((String) b);
                result.put(key, budgets);
            }
        } catch (Exception ex) {
            System.debug('parseGeoBudgetJson error: ' + ex.getMessage());
        }
        return result;
    }
/******************************************************************************************************
    Method Name:        validateGeoBudgetEntries
    Description:        Validates region and budget combinations against the configured allowance map.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
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
        for (String entry : geoBudgetInput.split(';')) {
            String e = entry.trim();
            if (String.isBlank(e)) continue;
            if (!e.contains('->')) {
                errors.add('Invalid format [' + e + ']. Use Region->BudgetType');
                continue;
            }
            String[] parts  = e.split('->');
            String   region = parts[0].trim();
            String   bType  = parts.size() > 1 ? parts[1].trim() : '';
            if (!allowed.containsKey(region)) {
                errors.add('Region [' + region + '] not valid for geo-budget mapping. '
                    + 'Valid: ' + String.join(new List<String>(allowed.keySet()), ', '));
                continue;
            }
            if (!allowed.get(region).contains(bType)) {
                errors.add('Budget [' + bType + '] not valid for region ['
                    + region + ']. Allowed: '
                    + String.join(allowed.get(region), ', '));
            }
        }
        return errors;
    }

  /******************************************************************************************************
    Method Name:        logChatbotCall
    Description:        Persists the chatbot call audit trail for request validation and submission flows.
    Added By:           Ramapriya
    *******************************************************************************************************/
    
    public static void logChatbotCall(
        String  endpoint,
        String  requestBody,
        String  responseBody,
        Integer httpStatusCode,
        Id      userId,
        String  program,
        String  roleRequested,
        Id      stagingRecordId,
        Long    elapsedMs,
        String  errorDetail
    ) {
        try {
            Core_MDF_AI_Recommendation_Tracking__c rec =
                new Core_MDF_AI_Recommendation_Tracking__c();

            rec.Core_MDF_AI_Source_Type__c            = 'IUPGM_Chatbot';
            rec.Core_MDF_AI_Recommendation__c         = cap(endpoint, 255);
            rec.Core_MDF_AI_Recommendation_Details__c = cap(requestBody, 32768);
            rec.Core_MDF_AI_Suggested_Value__c        = cap(responseBody, 32768);
            rec.Core_MDF_Recommendation_Used__c       = (httpStatusCode != null && httpStatusCode == 200);
            rec.Core_MDF_AI_Confidence_Score__c       = httpStatusCode != null ? (Decimal) httpStatusCode : null;
            rec.Core_MDF_User__c                      = userId;
            rec.Core_MDF_IUPGM_Program__c             = cap(program, 255);
            rec.Core_MDF_IUPGM_Role_Requested__c      = cap(roleRequested, 255);
            rec.Core_MDF_IUPGM_Staging_Record__c      = stagingRecordId;
            rec.Core_MDF_IUPGM_Response_Time_ms__c    = elapsedMs != null ? (Decimal) elapsedMs : null;
            rec.Core_MDF_IUPGM_Error_Detail__c        = cap(errorDetail, 32768);

            insert rec;

        } catch (Exception ex) {
            System.debug('logChatbotCall (non-fatal): ' + ex.getMessage());
        }
    }

    /** Truncates text to the supplied maximum length for safe audit persistence. */
    private static String cap(String s, Integer maxLen) {
        if (s == null) return null;
        return s.length() <= maxLen ? s : s.left(maxLen);
    }
}