/*****************************************************************************************************
Class Name          :    Core_MDF_IUPGM_AccessModelService
Test Class Name     :    Core_MDF_IUPGM_AccessModelService_Test
Description         :    Applies the IUPGM access-model resolution rules to staging records and creates or updates
                         Core_MDF_Int_Users_Partner_Geo_Mapping__c records 
Created By          :    Ramapriya  
******************************************************************************************************/
public without sharing class Core_MDF_IUPGM_AccessModelService {

    // Geos that together are equivalent to worldwide access.
    private static final Set<String> WW_EQUIVALENT_GEOS = new Set<String>{
        'APJ', 'EMEA', 'PRC', 'ASMO'
    };

    private static final Map<String, String> PROG_TO_RT = new Map<String, String>{
        'Intel Partner Alliance'   => 'Intel Partner Alliance',
        'Client Co-Marketing Fund' => 'Client',
        'Retail Marketing Funds'   => 'Retail Marketing Funds',
        'Co-GTM'                   => 'Co-GTM',
        'Datacenter'               => 'Datacenter'
    };

    // Maps MDT/staging program name → IUPGM Core_MDF_Program_nm__c picklist value
    private static final Map<String, String> PROG_TO_IUPGM_PROG = new Map<String, String>{
        'Client'                 => 'Client CoMarketing Fund',
        'Intel Partner Alliance' => 'Intel Partner Alliance',
        'Retail Marketing Funds' => 'Retail Marketing Funds',
        'Co-GTM'                 => 'CoGTM',
        'Datacenter'             => 'Data Center CoMarketing Fund'
    };

    private static Map<String, Id> rtCache;
    // Cache: ChannelProgram.Name → ChannelProgram.Id (populated once per processRequests call)
    private static Map<String, Id> channelProgramCache;

     /******************************************************************************************************
    Method Name:        processRequests
    Description:        Checks whether an existing active access model already fully satisfies the incoming staging request.
    Added By:           Ramapriya
    *******************************************************************************************************/
    /** Processes a batch of staging requests against the active IUPGM rule configuration. */
    public static void processRequests(
        List<Core_MDF_IUPGM_Request_Staging__c> requests,
        Core_MDF_IUPGM_Rule_Config__mdt cfg
    ) {
        

        if (requests == null || requests.isEmpty()) return;

        loadRecordTypeCache();

        // Collect all unique program names in this batch and resolve ChannelProgram Ids in one SOQL.
        // These are needed so Core_MDF_Channel_Program_id__c is populated on new IUPGM records,
        // which is required by the sharing trigger (checkPGM) to build group membership keys.
        Set<String> batchProgramNames = new Set<String>();
        for (Core_MDF_IUPGM_Request_Staging__c req : requests) {
            if (String.isNotBlank(req.Core_MDF_IUPGM_Program__c)) {
                batchProgramNames.add(req.Core_MDF_IUPGM_Program__c);
            }
        }
        channelProgramCache = new Map<String, Id>();
        if (!batchProgramNames.isEmpty()) {
            for (ChannelProgram cp : [
                SELECT Id, Name
                FROM   ChannelProgram
                WHERE  Name IN :batchProgramNames
                LIMIT  200
            ]) {
                channelProgramCache.put(cp.Name, cp.Id);
            }
        }
        System.debug('ChannelProgram cache: ' + channelProgramCache);

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> toInsert =
            new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> toUpdate =
            new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        // Resulting IUPGM record per staging request Id — used to write
        // Core_MDF_IUPGM_Record__c back onto staging after DML.
        Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c> reqToIupgm =
            new Map<Id, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

      
        Set<Id>     batchUserIds = new Set<Id>();
        Set<String> batchRoles   = new Set<String>();
        for (Core_MDF_IUPGM_Request_Staging__c req : requests) {
            if (req.Core_MDF_IUPGM_User__c != null) {
                batchUserIds.add(req.Core_MDF_IUPGM_User__c);
            }
            if (String.isNotBlank(req.Core_MDF_IUPGM_Role_nm__c)) {
                batchRoles.add(req.Core_MDF_IUPGM_Role_nm__c);
            }
        }

        // Determine the program from the config (all requests in this batch
        // share the same program).
        String batchProgram = PROG_TO_IUPGM_PROG.containsKey(cfg.Core_MDF_Program__c)
            ? PROG_TO_IUPGM_PROG.get(cfg.Core_MDF_Program__c)
            : cfg.Core_MDF_Program__c;

        Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> existingByKey =
            new Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();
        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c ex : [
            SELECT  Id,
                    RecordTypeId,
                    Core_MDF_User_id__c,
                    Core_MDF_Role_nm__c,
                    Core_MDF_Program_nm__c,
                    Core_MDF_Region_Sub_Region_nm__c,
                    Core_MDF_Budget_Type_nm__c,
                    Core_MDF_All_Accounts_cd__c,
                    Core_MDF_Account_id__c,
                    Core_MDF_All_Budget_Type_Access_Ind__c,
                    Core_MDF_GeoSubGeo_Budget_Type_nm__c,
                    Core_MDF_Approval_Region_nm__c,
                    Core_MDF_Activity_Classification_nm__c,
                    Core_MDF_Active_Ind__c
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Core_MDF_User_id__c IN :batchUserIds
              AND Core_MDF_Role_nm__c IN :batchRoles
              AND Core_MDF_Program_nm__c = :batchProgram
            ORDER BY Core_MDF_Active_Ind__c DESC NULLS LAST,
                     LastModifiedDate DESC
        ]) {
            // Key includes account to differentiate multiple accounts for same role
           
            String k = String.valueOf(ex.Core_MDF_User_id__c) + '|'
                + ex.Core_MDF_Role_nm__c + '|'
                + (ex.Core_MDF_Account_id__c != null
                   ? String.valueOf(ex.Core_MDF_Account_id__c)
                   : 'ALL');

            if (!existingByKey.containsKey(k)) {
                existingByKey.put(k,
                    new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>());
            }
            existingByKey.get(k).add(ex);
        }

        for (Core_MDF_IUPGM_Request_Staging__c req : requests) {
            try {
                System.debug('Processing: ' + req.Id
                    + ' | User=' + req.Core_MDF_IUPGM_User__c
                    + ' | Role=' + req.Core_MDF_IUPGM_Role_nm__c
                    + ' | Program=' + req.Core_MDF_IUPGM_Program__c);

                
                String key = String.valueOf(req.Core_MDF_IUPGM_User__c) + '|'
                    + req.Core_MDF_IUPGM_Role_nm__c + '|'
                    + (req.Core_MDF_IUPGM_Account__c != null
                       ? String.valueOf(req.Core_MDF_IUPGM_Account__c)
                       : 'ALL');

                List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> existingList =
                    existingByKey.containsKey(key)
                        ? existingByKey.get(key)
                        : new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

                System.debug('Existing records found: ' + existingList.size());

                if (existingList.isEmpty()) {
                    System.debug('ACTION: CREATE');
                    Core_MDF_Int_Users_Partner_Geo_Mapping__c newRec =
                        buildNewRecord(req, cfg);
                    toInsert.add(newRec);
                    reqToIupgm.put(req.Id, newRec);
                    req.Core_MDF_Action_nm__c = 'CREATE';

                } else {
                    Core_MDF_Int_Users_Partner_Geo_Mapping__c activeRec   = null;
                    Core_MDF_Int_Users_Partner_Geo_Mapping__c inactiveRec = null;

                    for (Core_MDF_Int_Users_Partner_Geo_Mapping__c ex : existingList) {
                        if (ex.Core_MDF_Active_Ind__c == true && activeRec == null) {
                            activeRec = ex;
                        } else if (ex.Core_MDF_Active_Ind__c != true && inactiveRec == null) {
                            inactiveRec = ex;
                        }
                    }

                    
                    String activeIdStr   = activeRec   != null ? String.valueOf(activeRec.Id)   : 'none';
                    String inactiveIdStr = inactiveRec != null ? String.valueOf(inactiveRec.Id) : 'none';
                    System.debug('Active: ' + activeIdStr + ' | Inactive: ' + inactiveIdStr);

                    if (activeRec != null) {

                       
                        if (activeRec.Core_MDF_All_Accounts_cd__c == 'Yes'
                            && !req.Core_MDF_IUPGM_All_Account_Access__c) {
                            System.debug('ACTION: SKIP (all-accounts supersedes specific account)');
                            String skipRegion = String.isNotBlank(
                                activeRec.Core_MDF_Region_Sub_Region_nm__c)
                                ? activeRec.Core_MDF_Region_Sub_Region_nm__c : 'all regions';
                            req.Core_MDF_Action_nm__c         = 'SKIP';
                            req.Core_MDF_Error_Message_txt__c =
                                'This user already has access as '
                                + req.Core_MDF_IUPGM_Role_nm__c
                                + ' for All Accounts in region: ' + skipRegion
                                + '. Specific account access is already covered by '
                                + 'the existing All Accounts grant and no new record is needed.';
                            reqToIupgm.put(req.Id, activeRec);
                            continue;
                        }

                       
                        if (!req.Core_MDF_IUPGM_All_Account_Access__c
                            && activeRec.Core_MDF_All_Accounts_cd__c == 'No'
                            && activeRec.Core_MDF_Account_id__c != null
                            && req.Core_MDF_IUPGM_Account__c != null
                            && activeRec.Core_MDF_Account_id__c != req.Core_MDF_IUPGM_Account__c) {
                            System.debug('ACTION: CREATE (different account E1)');
                            Core_MDF_Int_Users_Partner_Geo_Mapping__c newRec =
                                buildNewRecord(req, cfg);
                            toInsert.add(newRec);
                            reqToIupgm.put(req.Id, newRec);
                            req.Core_MDF_Action_nm__c = 'CREATE';
                            continue;
                        }

                        
                        if (isExactDuplicate(activeRec, req, cfg)) {
                            System.debug('ACTION: SKIP (exact duplicate)');
                            reqToIupgm.put(req.Id, activeRec);
                            req.Core_MDF_Action_nm__c = 'SKIP';
                            continue;
                        }

                        // Update
                        System.debug('ACTION: UPDATE');
                        applyDeltas(activeRec, req, cfg);
                        toUpdate.add(activeRec);
                        reqToIupgm.put(req.Id, activeRec);
                        req.Core_MDF_Action_nm__c = 'UPDATE';

                    } else if (inactiveRec != null) {
                        System.debug('ACTION: ACTIVATE');
                        inactiveRec.Core_MDF_Active_Ind__c = true;
                        applyDeltas(inactiveRec, req, cfg);
                        toUpdate.add(inactiveRec);
                        reqToIupgm.put(req.Id, inactiveRec);
                        req.Core_MDF_Action_nm__c = 'ACTIVATE';
                    }
                }

            } catch (Exception e) {
                
                System.debug('EXCEPTION on req ' + req.Id + ': '
                    + e.getMessage() + ' line ' + e.getLineNumber());
                req.Core_MDF_Request_Status_nm__c = Core_MDF_CCP_ConstantClass.IUPGM_STATUS_ERROR;
                req.Core_MDF_Error_Message_txt__c = e.getMessage()
                    + ' (line ' + e.getLineNumber() + ')';
                
            }
        }

        if (!toInsert.isEmpty()) {
            System.debug('INSERT: ' + toInsert.size());
            insert toInsert;
        }
        if (!toUpdate.isEmpty()) {
            System.debug('UPDATE: ' + toUpdate.size());
            update toUpdate;
        }

       
        for (Core_MDF_IUPGM_Request_Staging__c req : requests) {
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = reqToIupgm.get(req.Id);
            if (iupgm != null && iupgm.Id != null) {
                req.Core_MDF_IUPGM_Record__c = iupgm.Id;
            }
        }

     
    }

   /******************************************************************************************************
    Method Name:        isExactDuplicate
    Description:        Applies account/region/budget/approval/activity deltas from staging onto an existing active mapping record.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static Boolean isExactDuplicate(
        Core_MDF_Int_Users_Partner_Geo_Mapping__c ex,
        Core_MDF_IUPGM_Request_Staging__c req,
        Core_MDF_IUPGM_Rule_Config__mdt cfg
    ) {
        Boolean reqAllAcct = req.Core_MDF_IUPGM_All_Account_Access__c;
        Boolean exAllAcct  = (ex.Core_MDF_All_Accounts_cd__c == 'Yes');

        if (reqAllAcct != exAllAcct) return false;
        if (!reqAllAcct && ex.Core_MDF_Account_id__c != req.Core_MDF_IUPGM_Account__c) return false;

        if (!isRegionCovered(ex.Core_MDF_Region_Sub_Region_nm__c,
                             req.Core_MDF_IUPGM_Region_Sub_Region_nm__c)) {
            return false;
        }

        
        if (ex.Core_MDF_Region_Sub_Region_nm__c == 'WW'
            && String.isNotBlank(req.Core_MDF_IUPGM_Region_Sub_Region_nm__c)
            && req.Core_MDF_IUPGM_Region_Sub_Region_nm__c != 'WW') {
            return false;  // Not exact duplicate — allow UPDATE
        }

        if (cfg.Core_MDF_All_Budget_Type_Available__c) {
            Boolean reqAllBudget = (req.Core_MDF_IUPGM_All_Budget_Type_Access__c == true);
            Boolean exAllBudget  = (ex.Core_MDF_All_Budget_Type_Access_Ind__c == true);
            if (reqAllBudget != exAllBudget) return false;
            if (!reqAllBudget
                && String.isNotBlank(req.Core_MDF_GeoSubGeo_Budget_Type_nm__c)
                && !isGeoBudgetCovered(
                    ex.Core_MDF_GeoSubGeo_Budget_Type_nm__c,
                    req.Core_MDF_GeoSubGeo_Budget_Type_nm__c)) {
                return false;
            }
        }

        if (cfg.Core_MDF_Approval_Region_Required__c
            && String.isNotBlank(req.Core_MDF_Approval_Region_nm__c)
            && !isMultiselectCovered(ex.Core_MDF_Approval_Region_nm__c,
                             req.Core_MDF_Approval_Region_nm__c)) {
            return false;
        }

        if (cfg.Core_MDF_Activity_Classification_Req__c
            && ex.Core_MDF_Activity_Classification_nm__c
               != req.Core_MDF_Activity_Classification_nm__c) {
            return false;
        }

        return true;
    }

     /******************************************************************************************************
    Method Name:        applyDeltas
    Description:        Applies account/region/budget/approval/activity deltas from staging onto an existing active mapping record.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static void applyDeltas(
        Core_MDF_Int_Users_Partner_Geo_Mapping__c ex,
        Core_MDF_IUPGM_Request_Staging__c req,
        Core_MDF_IUPGM_Rule_Config__mdt cfg
    ) {
        if (req.Core_MDF_IUPGM_All_Account_Access__c) {
            ex.Core_MDF_All_Accounts_cd__c = 'Yes';
            ex.Core_MDF_Account_id__c      = null;
        } else {
            ex.Core_MDF_All_Accounts_cd__c = 'No';
            if (ex.Core_MDF_Account_id__c == null && req.Core_MDF_IUPGM_Account__c != null) {
                ex.Core_MDF_Account_id__c = req.Core_MDF_IUPGM_Account__c;
            }
        }

        ex.Core_MDF_Region_Sub_Region_nm__c = mergeRegions(
            ex.Core_MDF_Region_Sub_Region_nm__c,
            req.Core_MDF_IUPGM_Region_Sub_Region_nm__c
        );

        if (cfg.Core_MDF_All_Budget_Type_Available__c) {
            Boolean reqAllBudget = (req.Core_MDF_IUPGM_All_Budget_Type_Access__c == true);
            if (reqAllBudget) {
                ex.Core_MDF_All_Budget_Type_Access_Ind__c = true;
                ex.Core_MDF_GeoSubGeo_Budget_Type_nm__c   = null;
            } else if (ex.Core_MDF_All_Budget_Type_Access_Ind__c != true) {
                ex.Core_MDF_All_Budget_Type_Access_Ind__c = false;
                ex.Core_MDF_GeoSubGeo_Budget_Type_nm__c   = mergeGeoBudget(
                    ex.Core_MDF_GeoSubGeo_Budget_Type_nm__c,
                    req.Core_MDF_GeoSubGeo_Budget_Type_nm__c
                );
            }
        }

        if (cfg.Core_MDF_Approval_Region_Required__c
            && String.isNotBlank(req.Core_MDF_Approval_Region_nm__c)) {
            ex.Core_MDF_Approval_Region_nm__c = mergeMultiselect(
                ex.Core_MDF_Approval_Region_nm__c,
                req.Core_MDF_Approval_Region_nm__c
            );
        }

        if (cfg.Core_MDF_Activity_Classification_Req__c
            && String.isNotBlank(req.Core_MDF_Activity_Classification_nm__c)) {
            ex.Core_MDF_Activity_Classification_nm__c =
                req.Core_MDF_Activity_Classification_nm__c;
        }
    }

    /******************************************************************************************************
    Method Name:        buildNewRecord
    Description:        Creates a new active IUPGM mapping record from staging and rule configuration values.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static Core_MDF_Int_Users_Partner_Geo_Mapping__c buildNewRecord(
        Core_MDF_IUPGM_Request_Staging__c req,
        Core_MDF_IUPGM_Rule_Config__mdt cfg
    ) {
        Core_MDF_Int_Users_Partner_Geo_Mapping__c rec =
            new Core_MDF_Int_Users_Partner_Geo_Mapping__c();

        String rtName = PROG_TO_RT.get(req.Core_MDF_IUPGM_Program__c);
        if (rtName != null && rtCache.containsKey(rtName)) {
            rec.RecordTypeId = rtCache.get(rtName);
        }

        rec.Core_MDF_User_id__c    = req.Core_MDF_IUPGM_User__c;
        rec.Core_MDF_Role_nm__c    = req.Core_MDF_IUPGM_Role_nm__c;
        rec.Core_MDF_Program_nm__c = PROG_TO_IUPGM_PROG.containsKey(req.Core_MDF_IUPGM_Program__c)
            ? PROG_TO_IUPGM_PROG.get(req.Core_MDF_IUPGM_Program__c)
            : req.Core_MDF_IUPGM_Program__c;
        rec.Core_MDF_Active_Ind__c = true;

        // Populate Channel Program Id so the IUPGM sharing trigger (checkPGM)
        // can build the correct group membership key (Program+Geo+BudgetType).
        if (channelProgramCache != null
            && channelProgramCache.containsKey(req.Core_MDF_IUPGM_Program__c)) {
            rec.Core_MDF_Channel_Program_id__c = channelProgramCache.get(req.Core_MDF_IUPGM_Program__c);
        }

        if (req.Core_MDF_IUPGM_All_Account_Access__c) {
            rec.Core_MDF_All_Accounts_cd__c = 'Yes';
            rec.Core_MDF_Account_id__c      = null;
        } else {
            rec.Core_MDF_All_Accounts_cd__c = 'No';
            rec.Core_MDF_Account_id__c      = req.Core_MDF_IUPGM_Account__c;
        }

        rec.Core_MDF_Region_Sub_Region_nm__c =
            resolveRegion(req.Core_MDF_IUPGM_Region_Sub_Region_nm__c);

        if (cfg.Core_MDF_All_Budget_Type_Available__c) {
            Boolean allBudget = (req.Core_MDF_IUPGM_All_Budget_Type_Access__c == true);
            rec.Core_MDF_All_Budget_Type_Access_Ind__c = allBudget;
            rec.Core_MDF_GeoSubGeo_Budget_Type_nm__c   =
                allBudget ? null : req.Core_MDF_GeoSubGeo_Budget_Type_nm__c;
        } else {
            // Checkbox cannot be null in DML — use false when budget type is not applicable
            rec.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            rec.Core_MDF_GeoSubGeo_Budget_Type_nm__c   = null;
        }

        rec.Core_MDF_Budget_Type_nm__c = req.Core_MDF_IUPGM_Budget_Type_nm__c;

        if (cfg.Core_MDF_Approval_Region_Required__c) {
            rec.Core_MDF_Approval_Region_nm__c = req.Core_MDF_Approval_Region_nm__c;
        }

        if (cfg.Core_MDF_Activity_Classification_Req__c) {
            rec.Core_MDF_Activity_Classification_nm__c =
                req.Core_MDF_Activity_Classification_nm__c;
        }

        

        return rec;
    }

    /******************************************************************************************************
    Method Name:        loadRecordTypeCache
    Description:        Loads and caches record type ids for Core_MDF_Int_Users_Partner_Geo_Mapping__c.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static void loadRecordTypeCache() {
        if (rtCache != null) return;
        rtCache = new Map<String, Id>();
        for (RecordTypeInfo rti :
            Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByName().values()) {
            rtCache.put(rti.getName(), rti.getRecordTypeId());
        }
       
    }
/******************************************************************************************************
    Method Name:        splitToSet
    Description:        Splits a semicolon-delimited string into a non-empty set of values.
    Added By:           Ramapriya
    *******************************************************************************************************/

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
    Method Name:        resolveRegion
    Description:        Normalizes requested region values and collapses WW-equivalent combinations to WW.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static String resolveRegion(String requestedRegion) {
        if (String.isBlank(requestedRegion)) return requestedRegion;
        if (requestedRegion.trim() == 'WW') return 'WW';
        Set<String> reqSet = splitToSet(requestedRegion);
        if (reqSet.containsAll(WW_EQUIVALENT_GEOS)) return 'WW';
        return requestedRegion.trim();
    }
/******************************************************************************************************
    Method Name:        mergeRegions
    Description:        Merges existing and requested regions into a consolidated semicolon-delimited value.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static String mergeRegions(String existing, String requested) {
        if (String.isBlank(requested)) return existing;
        String reqTrimmed = requested.trim();
        if (reqTrimmed == 'WW') return 'WW';
        Set<String> existSet = splitToSet(existing);
        Set<String> reqSet   = splitToSet(reqTrimmed);
        if (existSet.contains('WW') && !reqSet.contains('WW')) return reqTrimmed;
        Set<String> merged = new Set<String>();
        merged.addAll(existSet);
        merged.addAll(reqSet);
        if (merged.containsAll(WW_EQUIVALENT_GEOS)) return 'WW';
        List<String> regions = new List<String>(merged);
        regions.sort();
        return String.join(regions, ';');
    }
/******************************************************************************************************
    Method Name:        isRegionCovered
    Description:        Verifies whether existing regions already cover all requested regions.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static Boolean isRegionCovered(String existing, String requested) {
        if (String.isBlank(requested)) return true;
        if (String.isBlank(existing))  return false;
        Set<String> existSet = splitToSet(existing);
        if (existSet.contains('WW')) return true;
        for (String r : splitToSet(requested)) {
            if (!existSet.contains(r)) return false;
        }
        return true;
    }
/******************************************************************************************************
    Method Name:        mergeGeoBudget
    Description:        Merges existing and requested geo-budget entries into a deduplicated value.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static String mergeGeoBudget(String existing, String requested) {
        Set<String> entries = new Set<String>();
        entries.addAll(splitToSet(existing));
        entries.addAll(splitToSet(requested));
        if (entries.isEmpty()) return null;
        List<String> budgets = new List<String>(entries);
        budgets.sort();
        return String.join(budgets, ';');
    }
/******************************************************************************************************
    Method Name:        isGeoBudgetCovered
    Description:        Verifies whether existing geo-budget entries already cover requested entries.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static Boolean isGeoBudgetCovered(String existing, String requested) {
        if (String.isBlank(requested)) return true;
        if (String.isBlank(existing))  return false;
        Set<String> existSet = splitToSet(existing);
        for (String r : splitToSet(requested)) {
            if (!existSet.contains(r)) return false;
        }
        return true;
    }
/******************************************************************************************************
    Method Name:        mergeMultiselect
    Description:        Merges two multiselect-style values into a deduplicated semicolon-delimited string.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static String mergeMultiselect(String existing, String requested) {
        Set<String> values = new Set<String>();
        values.addAll(splitToSet(existing));
        values.addAll(splitToSet(requested));
        if (values.isEmpty()) return null;
        List<String> finalValues = new List<String>(values);
        finalValues.sort();
        return String.join(finalValues, ';');
    }
/******************************************************************************************************
    Method Name:        isMultiselectCovered
    Description:        Verifies whether existing multiselect values already contain requested values.
    Added By:           Ramapriya
    *******************************************************************************************************/
    private static Boolean isMultiselectCovered(String existing, String requested) {
        if (String.isBlank(requested)) return true;
        if (String.isBlank(existing))  return false;
        Set<String> existSet = splitToSet(existing);
        for (String v : splitToSet(requested)) {
            if (!existSet.contains(v)) return false;
        }
        return true;
    }
}