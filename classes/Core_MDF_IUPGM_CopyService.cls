/******************************************************************************************************
* Class Name  : Core_MDF_IUPGM_CopyService
* Test Class  : Core_MDF_IUPGM_CopyService_Test
* Description : Used for COPY Operation from RequestAPI 
* Called From :    Core_MDF_IUPGM_RequestAPI
* Created By  :    Ramapriya
******************************************************************************************************/
public without sharing class Core_MDF_IUPGM_CopyService {

    public class CopyOutcome {
        public Integer sourceCount  = 0;
        public Integer createdCount = 0;
        public Integer skippedCount = 0;
        public Integer failedCount  = 0;
        public String  message;
    }

    private static final Set<String> WW_EQUIVALENT_GEOS = new Set<String>{
        'APJ', 'EMEA', 'PRC', 'ASMO'
    };

    /******************************************************************************************************
        Method Name:        copyForOperation
        Description:        Resolves the source user by name, retrieves their active IUPGM records, and
                             replicates onto the target user every combination not already active for
                             them. Only combinations backed by a Permission Set the target already holds
                             are created, mirroring the fact that AGS/PS assignment is a prerequisite for
                             IUPGM access. Returns an in-memory outcome; does not write to the staging
                             object.
        Added By:           Ramapriya
        *******************************************************************************************************/
    public static CopyOutcome copyForOperation(Id targetUserId, String sourceUserName) {
        CopyOutcome outcome = new CopyOutcome();
        if (targetUserId == null) {
            outcome.message = 'Target user missing; IUPGM records not copied.';
            return outcome;
        }
        if (String.isBlank(sourceUserName)) {
            outcome.message = 'Source user name missing; IUPGM records not copied.';
            return outcome;
        }

        List<User> matches = [
            SELECT Id FROM User WHERE Name = :sourceUserName AND IsActive = true LIMIT 2
        ];
        if (matches.size() != 1) {
            outcome.message = matches.isEmpty()
                ? 'Source user "' + sourceUserName + '" could not be resolved; IUPGM records not copied.'
                : 'Source user name "' + sourceUserName + '" is ambiguous; IUPGM records not copied.';
            return outcome;
        }
        Id sourceUserId = matches[0].Id;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> sourceRecs = [
            SELECT Id, RecordTypeId, Core_MDF_Account_id__c, Core_MDF_All_Accounts_cd__c,
                   Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, Core_MDF_Region_Sub_Region_nm__c,
                   Core_MDF_Budget_Type_nm__c, Core_MDF_All_Budget_Type_Access_Ind__c,
                   Core_MDF_GeoSubGeo_Budget_Type_nm__c, Core_MDF_Approval_Region_nm__c,
                   Core_MDF_Activity_Classification_nm__c, Core_MDF_Channel_Program_id__c
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Core_MDF_User_id__c = :sourceUserId
              AND Core_MDF_Active_Ind__c = true
        ];
        outcome.sourceCount = sourceRecs.size();
        if (sourceRecs.isEmpty()) {
            outcome.message = 'Source user has no active IUPGM records.';
            return outcome;
        }

        Map<String, Core_MDF_Int_Users_Partner_Geo_Mapping__c> targetByKey =
            new Map<String, Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c t : [
            SELECT Id, Core_MDF_Account_id__c, Core_MDF_All_Accounts_cd__c,
                   Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, Core_MDF_Region_Sub_Region_nm__c,
                   Core_MDF_Budget_Type_nm__c, Core_MDF_All_Budget_Type_Access_Ind__c,
                   Core_MDF_GeoSubGeo_Budget_Type_nm__c, Core_MDF_Approval_Region_nm__c,
                   Core_MDF_Activity_Classification_nm__c, Core_MDF_Active_Ind__c
            FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
            WHERE Core_MDF_User_id__c = :targetUserId
        ]) {
            targetByKey.put(keyOf(t), t);
        }

        Set<String> roleNames = new Set<String>();
        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c s : sourceRecs) roleNames.add(s.Core_MDF_Role_nm__c);
        Set<String> heldPermissionSets = new Set<String>();
        for (PermissionSetAssignment psa : [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :targetUserId
              AND PermissionSet.Name IN :roleNames
              AND IsActive = true
        ]) {
            heldPermissionSets.add(psa.PermissionSet.Name);
        }

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> toInsert = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> toUpdate = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<String> notes = new List<String>();

        for (Core_MDF_Int_Users_Partner_Geo_Mapping__c src : sourceRecs) {
            String label = src.Core_MDF_Program_nm__c + '/' + src.Core_MDF_Role_nm__c;
            Core_MDF_Int_Users_Partner_Geo_Mapping__c tgt = targetByKey.get(keyOf(src));

            if (tgt == null) {
                if (!heldPermissionSets.contains(src.Core_MDF_Role_nm__c)) {
                    outcome.failedCount++;
                    notes.add('Missing Permission Set for ' + label);
                    continue;
                }
                toInsert.add(buildCopy(src, targetUserId));
                continue;
            }

            // Same combination (matches GRANT's isExactDuplicate semantics): nothing to do if
            // already active and every field is already covered by the target record.
            if (tgt.Core_MDF_Active_Ind__c == true && isCombinationCovered(src, tgt)) {
                outcome.skippedCount++;
                continue;
            }

            if (!heldPermissionSets.contains(src.Core_MDF_Role_nm__c)) {
                outcome.failedCount++;
                notes.add('Missing Permission Set for ' + label);
                continue;
            }

            // Not an exact match (or currently inactive) - merge the deltas onto the existing
            // record and reactivate, exactly how GRANT's applyDeltas()/ACTIVATE path behaves for
            // the same user requesting the same key again with different region/budget/approval/
            // activity values. Region/budget/approval are unioned (additive), never narrowed.
            applyCopyDeltas(tgt, src);
            tgt.Core_MDF_Active_Ind__c = true;
            toUpdate.add(tgt);
        }

        for (Database.SaveResult sr : Database.insert(toInsert, false)) {
            if (sr.isSuccess()) outcome.createdCount++;
            else { outcome.failedCount++; notes.add(firstError(sr.getErrors())); }
        }
        for (Database.SaveResult sr : Database.update(toUpdate, false)) {
            if (sr.isSuccess()) outcome.createdCount++;
            else { outcome.failedCount++; notes.add(firstError(sr.getErrors())); }
        }

        if (!notes.isEmpty()) outcome.message = notes[0];
        return outcome;
    }

    private static Core_MDF_Int_Users_Partner_Geo_Mapping__c buildCopy(
        Core_MDF_Int_Users_Partner_Geo_Mapping__c src, Id targetUserId
    ) {
        Core_MDF_Int_Users_Partner_Geo_Mapping__c rec = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        rec.RecordTypeId                           = src.RecordTypeId;
        rec.Core_MDF_User_id__c                    = targetUserId;
        rec.Core_MDF_Role_nm__c                     = src.Core_MDF_Role_nm__c;
        rec.Core_MDF_Program_nm__c                  = src.Core_MDF_Program_nm__c;
        rec.Core_MDF_Channel_Program_id__c          = src.Core_MDF_Channel_Program_id__c;
        rec.Core_MDF_All_Accounts_cd__c             = src.Core_MDF_All_Accounts_cd__c;
        rec.Core_MDF_Account_id__c                  = src.Core_MDF_All_Accounts_cd__c == 'Yes' ? null : src.Core_MDF_Account_id__c;
        rec.Core_MDF_Region_Sub_Region_nm__c        = src.Core_MDF_Region_Sub_Region_nm__c;
        rec.Core_MDF_Budget_Type_nm__c              = src.Core_MDF_Budget_Type_nm__c;
        rec.Core_MDF_All_Budget_Type_Access_Ind__c  = src.Core_MDF_All_Budget_Type_Access_Ind__c == true;
        rec.Core_MDF_GeoSubGeo_Budget_Type_nm__c    = src.Core_MDF_GeoSubGeo_Budget_Type_nm__c;
        rec.Core_MDF_Approval_Region_nm__c          = src.Core_MDF_Approval_Region_nm__c;
        rec.Core_MDF_Activity_Classification_nm__c  = src.Core_MDF_Activity_Classification_nm__c;
        rec.Core_MDF_Active_Ind__c                  = true;
        return rec;
    }

    /** Composite identity enforced by the IUPGM unique rule: Account (or ALL), Program, Role. */
    private static String keyOf(Core_MDF_Int_Users_Partner_Geo_Mapping__c rec) {
        String acct = rec.Core_MDF_All_Accounts_cd__c == 'Yes' ? 'ALL' : String.valueOf(rec.Core_MDF_Account_id__c);
        return acct + '|' + rec.Core_MDF_Program_nm__c + '|' + rec.Core_MDF_Role_nm__c;
    }

    /**
     * Mirrors Core_MDF_IUPGM_AccessModelService.isExactDuplicate: true when the target record
     * already covers every field the source combination would otherwise change (region, budget
     * scope, approval region, activity classification). When false, applyCopyDeltas() merges the
     * gap onto the target rather than leaving it (or skipping it) untouched.
     */
    private static Boolean isCombinationCovered(
        Core_MDF_Int_Users_Partner_Geo_Mapping__c src,
        Core_MDF_Int_Users_Partner_Geo_Mapping__c tgt
    ) {
        if (!isRegionCovered(tgt.Core_MDF_Region_Sub_Region_nm__c, src.Core_MDF_Region_Sub_Region_nm__c)) {
            return false;
        }

        Boolean srcAllBudget = (src.Core_MDF_All_Budget_Type_Access_Ind__c == true);
        Boolean tgtAllBudget = (tgt.Core_MDF_All_Budget_Type_Access_Ind__c == true);
        if (srcAllBudget != tgtAllBudget) return false;
        if (!srcAllBudget && !isSetCovered(
                tgt.Core_MDF_GeoSubGeo_Budget_Type_nm__c, src.Core_MDF_GeoSubGeo_Budget_Type_nm__c)) {
            return false;
        }

        if (!isSetCovered(tgt.Core_MDF_Approval_Region_nm__c, src.Core_MDF_Approval_Region_nm__c)) {
            return false;
        }

        if (String.isNotBlank(src.Core_MDF_Activity_Classification_nm__c)
            && src.Core_MDF_Activity_Classification_nm__c != tgt.Core_MDF_Activity_Classification_nm__c) {
            return false;
        }

        return true;
    }

    /**
     * Merges the source combination's region/budget/approval/activity values onto an existing
     * target record - same field-by-field delta semantics as AccessModelService.applyDeltas():
     * region/budget/approval are unioned (additive, never narrowed), activity is overwritten.
     * Account/Program/Role/User/All-Accounts are never touched here since they are the match key
     * and Core_MDF_CannotUpdateIUPGM blocks changing them on an existing record.
     */
    private static void applyCopyDeltas(
        Core_MDF_Int_Users_Partner_Geo_Mapping__c tgt,
        Core_MDF_Int_Users_Partner_Geo_Mapping__c src
    ) {
        tgt.Core_MDF_Region_Sub_Region_nm__c = unionRegion(
            tgt.Core_MDF_Region_Sub_Region_nm__c, src.Core_MDF_Region_Sub_Region_nm__c);

        Boolean srcAllBudget = (src.Core_MDF_All_Budget_Type_Access_Ind__c == true);
        if (srcAllBudget) {
            tgt.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            tgt.Core_MDF_GeoSubGeo_Budget_Type_nm__c = null;
        } else if (tgt.Core_MDF_All_Budget_Type_Access_Ind__c != true) {
            tgt.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            tgt.Core_MDF_GeoSubGeo_Budget_Type_nm__c = mergeSemicolonValues(
                tgt.Core_MDF_GeoSubGeo_Budget_Type_nm__c, src.Core_MDF_GeoSubGeo_Budget_Type_nm__c);
        }

        if (String.isNotBlank(src.Core_MDF_Approval_Region_nm__c)) {
            tgt.Core_MDF_Approval_Region_nm__c = mergeSemicolonValues(
                tgt.Core_MDF_Approval_Region_nm__c, src.Core_MDF_Approval_Region_nm__c);
        }

        if (String.isNotBlank(src.Core_MDF_Activity_Classification_nm__c)) {
            tgt.Core_MDF_Activity_Classification_nm__c = src.Core_MDF_Activity_Classification_nm__c;
        }
    }

    /** True when every semicolon-delimited entry in requested already appears in existing. */
    private static Boolean isSetCovered(String existing, String requested) {
        if (String.isBlank(requested)) return true;
        if (String.isBlank(existing))  return false;
        return splitRegions(existing).containsAll(splitRegions(requested));
    }

    /** Deduplicated union of two semicolon-delimited values (generic budget/approval merge). */
    private static String mergeSemicolonValues(String existing, String requested) {
        Set<String> merged = splitRegions(existing);
        merged.addAll(splitRegions(requested));
        if (merged.isEmpty()) return null;
        List<String> values = new List<String>(merged);
        values.sort();
        return String.join(values, ';');
    }

    private static Set<String> splitRegions(String regions) {
        Set<String> result = new Set<String>();
        if (String.isBlank(regions)) return result;
        for (String r : regions.split(';')) {
            if (String.isNotBlank(r)) result.add(r.trim());
        }
        return result;
    }

    /** True when the existing regions already cover every requested region (WW covers all). */
    private static Boolean isRegionCovered(String existing, String requested) {
        if (String.isBlank(requested)) return true;
        Set<String> existSet = splitRegions(existing);
        if (existSet.isEmpty()) return false;
        if (existSet.contains('WW')) return true;
        return existSet.containsAll(splitRegions(requested));
    }

    private static String unionRegion(String existing, String requested) {
        Set<String> merged = splitRegions(existing);
        merged.addAll(splitRegions(requested));
        if (merged.contains('WW') || merged.containsAll(WW_EQUIVALENT_GEOS)) return 'WW';
        List<String> regions = new List<String>(merged);
        regions.sort();
        return String.join(regions, ';');
    }

    private static String firstError(List<Database.Error> errors) {
        return (errors == null || errors.isEmpty()) ? 'Unknown IUPGM save error' : errors[0].getMessage();
    }
}