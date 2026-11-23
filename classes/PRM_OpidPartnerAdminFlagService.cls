/*************************************************************************************************
 * Maintains Account.Is_Partner_Admin_Exist__c on OPID (partner group) accounts.
 * True while an active "Partner Admin" ACR (Complete, or Pending Action created in the last
 * PENDING_DAYS days) exists on an IPA Intel account in the OPID hierarchy.
 *
 * Single-PA-per-OPID decision (self registration and admin registration), no SOQL:
 *  - read: hasPartnerAdmin(acc) uses the group-member subquery already loaded on the Account.
 *  - claim: claim(opid) marks the OPID in memory for the current transaction and flushClaims()
 *    persists the flag through one Queueable, so Account triggers never run in the caller.
 *  - SyncJob (Queueable, self-chaining) re-syncs every OPID in pages: SET phase then CLEAR phase.
 *
 * SyncJob phases, each page in its own transaction so limits never accumulate:
 *  - SET: pages through qualifying Partner Admin ACRs and flags their OPIDs. OPIDs already
 *    true are filtered out, so repeat onboardings cause no DML.
 *  - CLEAR: pages through OPIDs currently true and clears those whose last PA is gone.
 *
 * Run:
 *   System.enqueueJob(new PRM_OpidPartnerAdminFlagService.SyncJob());
 *************************************************************************************************/
public without sharing class PRM_OpidPartnerAdminFlagService {

    private static final Integer PENDING_DAYS = 30;
    private static final String PENDING_STATUS = 'Pending Action';
    private static final Integer SET_PAGE_SIZE = 1000;
    private static final Integer CLEAR_PAGE_SIZE = 100;

    private static Set<Id> claimedOpids = new Set<Id>();
    private static Set<Id> unflushedOpids = new Set<Id>();

    /*
     * OPID of a registration account: the primary group membership, or the only one.
     * Works for non-IPA accounts. Requires Partner_Account_Group_Members1__r on the Account.
     */
    public static Id resolveOpid(Account acc) {
        if (acc == null) {
            return null;
        }
        List<SObject> members = acc.getSObjects('Partner_Account_Group_Members1__r');
        if (members == null) {
            return null;
        }
        Id primaryOpid;
        Set<Id> allOpids = new Set<Id>();
        for (SObject m : members) {
            Id opidId = (Id) m.get('Core_Partner_Account_Id__c');
            allOpids.add(opidId);
            if ((Boolean) m.get('Primary_Account__c') == true) {
                primaryOpid = opidId;
            }
        }
        return primaryOpid != null ? primaryOpid : (allOpids.size() == 1 ? new List<Id>(allOpids)[0] : null);
    }

    /* True when the account's OPID already has a Partner Admin, persisted or claimed in this transaction. */
    public static Boolean hasPartnerAdmin(Account acc) {
        Id opidId = resolveOpid(acc);
        if (opidId == null) {
            return false;
        }
        if (claimedOpids.contains(opidId)) {
            return true;
        }
        for (SObject m : acc.getSObjects('Partner_Account_Group_Members1__r')) {
            if ((Id) m.get('Core_Partner_Account_Id__c') == opidId) {
                SObject opid = m.getSObject('Core_Partner_Account_Id__r');
                return opid != null && (Boolean) opid.get('Is_Partner_Admin_Exist__c') == true;
            }
        }
        return false;
    }

    /* Reserves the single Partner Admin slot of the OPID; call flushClaims() once afterwards. */
    public static void claim(Id opidId) {
        if (opidId != null && claimedOpids.add(opidId)) {
            unflushedOpids.add(opidId);
        }
    }

    public static void flushClaims() {
        if (unflushedOpids.isEmpty() || System.isFuture()
            || Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
            return;
        }
        System.enqueueJob(new ClaimJob(unflushedOpids));
        unflushedOpids = new Set<Id>();
    }

    public without sharing class ClaimJob implements Queueable {
        private final Set<Id> opids;

        public ClaimJob(Set<Id> opids) {
            this.opids = new Set<Id>(opids);
        }

        public void execute(QueueableContext qc) {
            List<Account> toUpdate = new List<Account>();
            for (Id opidId : opids) {
                toUpdate.add(new Account(Id = opidId, Is_Partner_Admin_Exist__c = true));
            }
            updateWithLogging(toUpdate);
        }
    }

    /*
     * Called from the ACR trigger (no SOQL). A new ACR, or one whose active flag, status,
     * relationship or account changed, is re-checked in a Queueable that recomputes the flag
     * of its whole OPID in both directions (set when a PA exists, clear when none is left).
     */
    public static void handleAcrChanges(
        List<PRM_Account_Contact_Relationship__c> newList,
        Map<Id, PRM_Account_Contact_Relationship__c> oldMap
    ) {
        if (newList == null || !canEnqueue()) {
            return;
        }
        Set<Id> acrIds = new Set<Id>();
        Set<Id> extraAccountIds = new Set<Id>();
        for (PRM_Account_Contact_Relationship__c acr : newList) {
            if (acr.Id == null || acr.PRM_Account_Id__c == null) {
                continue;
            }
            PRM_Account_Contact_Relationship__c old = oldMap == null ? null : oldMap.get(acr.Id);
            if (old == null) {
                if (acr.PRM_InActive_Ind__c != true) {
                    acrIds.add(acr.Id);
                }
            } else if (old.PRM_InActive_Ind__c != acr.PRM_InActive_Ind__c
                || old.PRM_Status_Nm__c != acr.PRM_Status_Nm__c
                || old.PRM_Relationship_Id__c != acr.PRM_Relationship_Id__c
                || old.PRM_Account_Id__c != acr.PRM_Account_Id__c) {
                acrIds.add(acr.Id);
                // The relationship name is unknown here, so the old/new accounts are always re-checked.
                extraAccountIds.add(acr.PRM_Account_Id__c);
                if (old.PRM_Account_Id__c != null) {
                    extraAccountIds.add(old.PRM_Account_Id__c);
                }
            }
        }
        if (!acrIds.isEmpty()) {
            System.enqueueJob(new AcrJob(acrIds, extraAccountIds));
        }
    }

    /* Deleted ACRs can't be queried later, so their accounts are passed straight to the job. */
    public static void handleAcrDeletes(List<PRM_Account_Contact_Relationship__c> deletedList) {
        if (deletedList == null || !canEnqueue()) {
            return;
        }
        Set<Id> accountIds = new Set<Id>();
        for (PRM_Account_Contact_Relationship__c acr : deletedList) {
            if (acr.PRM_Account_Id__c != null && acr.PRM_InActive_Ind__c != true) {
                accountIds.add(acr.PRM_Account_Id__c);
            }
        }
        if (!accountIds.isEmpty()) {
            System.enqueueJob(new AcrJob(new Set<Id>(), accountIds));
        }
    }

    /*
     * Called from the group member trigger (no SOQL). Insert, delete (pass Trigger.old and a null
     * oldMap), and any change of active flag, IPA flag, Intel account or OPID refreshes the
     * affected OPIDs, old and new.
     */
    public static void handleGroupMemberChanges(
        List<Core_Account_Group_Member__c> newList,
        Map<Id, Core_Account_Group_Member__c> oldMap
    ) {
        if (newList == null || !canEnqueue()) {
            return;
        }
        Set<Id> opids = new Set<Id>();
        for (Core_Account_Group_Member__c cag : newList) {
            Core_Account_Group_Member__c old = (oldMap == null || cag.Id == null) ? null : oldMap.get(cag.Id);
            if (old == null) {
                if (cag.Core_Inactive_Ind__c != true && cag.Core_Partner_Account_Id__c != null) {
                    opids.add(cag.Core_Partner_Account_Id__c);
                }
            } else if (old.Core_Inactive_Ind__c != cag.Core_Inactive_Ind__c
                || old.Core_Intel_Partner_Alliance_PartnerGroup__c != cag.Core_Intel_Partner_Alliance_PartnerGroup__c
                || old.Core_Intel_Account_Id__c != cag.Core_Intel_Account_Id__c
                || old.Core_Partner_Account_Id__c != cag.Core_Partner_Account_Id__c) {
                if (cag.Core_Partner_Account_Id__c != null) {
                    opids.add(cag.Core_Partner_Account_Id__c);
                }
                if (old.Core_Partner_Account_Id__c != null) {
                    opids.add(old.Core_Partner_Account_Id__c);
                }
            }
        }
        if (!opids.isEmpty()) {
            System.enqueueJob(new OpidRefreshJob(opids));
        }
    }

    /* Async contexts allow a single job that existing code may need, so the scheduled SyncJob covers them. */
    private static Boolean canEnqueue() {
        return !System.isFuture() && !System.isBatch() && !System.isQueueable()
            && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();
    }

    public without sharing class OpidRefreshJob implements Queueable {
        private final Set<Id> opids;

        public OpidRefreshJob(Set<Id> opids) {
            this.opids = new Set<Id>(opids);
        }

        public void execute(QueueableContext qc) {
            refreshOpids(opids);
        }
    }

    public without sharing class AcrJob implements Queueable {
        private final Set<Id> acrIds;
        private final Set<Id> extraAccountIds;

        public AcrJob(Set<Id> acrIds, Set<Id> extraAccountIds) {
            this.acrIds = new Set<Id>(acrIds);
            this.extraAccountIds = new Set<Id>(extraAccountIds);
        }

        public void execute(QueueableContext qc) {
            String partnerAdmin = System.Label.PRM_Primary_Contact;
            Set<Id> intelAccountIds = new Set<Id>(extraAccountIds);
            if (!acrIds.isEmpty()) {
                for (PRM_Account_Contact_Relationship__c acr : [
                    SELECT PRM_Account_Id__c
                    FROM PRM_Account_Contact_Relationship__c
                    WHERE Id IN :acrIds
                    AND PRM_Relationship_Id__r.Name = :partnerAdmin
                    AND PRM_Account_Id__c != null
                ]) {
                    intelAccountIds.add(acr.PRM_Account_Id__c);
                }
            }
            refreshOpidsOfAccounts(intelAccountIds);
        }
    }

    /* Recomputes the flag of every IPA OPID the given Intel accounts belong to. */
    public static void refreshOpidsOfAccounts(Set<Id> intelAccountIds) {
        if (intelAccountIds == null || intelAccountIds.isEmpty()) {
            return;
        }
        Set<Id> opids = new Set<Id>();
        for (Core_Account_Group_Member__c cag : [
            SELECT Core_Partner_Account_Id__c
            FROM Core_Account_Group_Member__c
            WHERE Core_Intel_Account_Id__c IN :intelAccountIds
            AND Core_Intel_Partner_Alliance_PartnerGroup__c = true
            AND Core_Inactive_Ind__c = false
            AND Core_Partner_Account_Id__c != null
        ]) {
            opids.add(cag.Core_Partner_Account_Id__c);
        }
        refreshOpids(opids);
    }

    /* Sets or clears the flag of each OPID to match its current active Partner Admin ACRs. */
    public static void refreshOpids(Set<Id> opids) {
        if (opids == null || opids.isEmpty()) {
            return;
        }
        Set<Id> qualified = qualifiedOpids(opids);
        List<Account> toUpdate = new List<Account>();
        for (Account opid : [
            SELECT Id, Is_Partner_Admin_Exist__c
            FROM Account
            WHERE Id IN :opids
        ]) {
            Boolean shouldBeSet = qualified.contains(opid.Id);
            if (opid.Is_Partner_Admin_Exist__c != shouldBeSet) {
                toUpdate.add(new Account(Id = opid.Id, Is_Partner_Admin_Exist__c = shouldBeSet));
            }
        }
        updateWithLogging(toUpdate);
    }

    /* OPIDs that still have an active Partner Admin ACR on any IPA Intel account in their hierarchy. */
    private static Set<Id> qualifiedOpids(Set<Id> opids) {
        String partnerAdmin = System.Label.PRM_Primary_Contact;
        String completeStatus = System.Label.PRM_ACR_Status;
        Datetime pendingSince = System.now().addDays(-PENDING_DAYS);
        Set<Id> qualified = new Set<Id>();
        for (Core_Account_Group_Member__c cag : [
            SELECT Core_Partner_Account_Id__c
            FROM Core_Account_Group_Member__c
            WHERE Core_Partner_Account_Id__c IN :opids
            AND Core_Intel_Partner_Alliance_PartnerGroup__c = true
            AND Core_Inactive_Ind__c = false
            AND Core_Intel_Account_Id__c IN (
                SELECT PRM_Account_Id__c
                FROM PRM_Account_Contact_Relationship__c
                WHERE PRM_Relationship_Id__r.Name = :partnerAdmin
                AND (PRM_Status_Nm__c = :completeStatus
                    OR (PRM_Status_Nm__c = :PENDING_STATUS AND CreatedDate >= :pendingSince))
                AND PRM_InActive_Ind__c = false
            )
        ]) {
            qualified.add(cag.Core_Partner_Account_Id__c);
        }
        return qualified;
    }

    /*
     * Full re-sync in pages. Each page runs in its own transaction and chains the next one,
     * so no limit accumulates. Phase 1 (SET) walks Partner Admin ACRs, phase 2 (CLEAR) walks
     * currently flagged OPIDs.
     */
    public without sharing class SyncJob implements Queueable {
        private final Boolean clearPhase;
        private final Id cursor;

        public SyncJob() {
            this(false, null);
        }

        public SyncJob(Boolean clearPhase, Id cursor) {
            this.clearPhase = clearPhase == true;
            this.cursor = cursor;
        }

        public void execute(QueueableContext qc) {
            if (clearPhase) {
                clearPage();
            } else {
                setPage();
            }
        }

        private void setPage() {
            String partnerAdmin = System.Label.PRM_Primary_Contact;
            String completeStatus = System.Label.PRM_ACR_Status;
            String pendingStatus = PENDING_STATUS;
            Datetime pendingSince = System.now().addDays(-PENDING_DAYS);
            Id after = cursor;
            String soql = 'SELECT Id, PRM_Account_Id__c FROM PRM_Account_Contact_Relationship__c'
                + ' WHERE PRM_Relationship_Id__r.Name = :partnerAdmin'
                + ' AND (PRM_Status_Nm__c = :completeStatus'
                + ' OR (PRM_Status_Nm__c = :pendingStatus AND CreatedDate >= :pendingSince))'
                + ' AND PRM_InActive_Ind__c = false AND PRM_Account_Id__c != null'
                + (after == null ? '' : ' AND Id > :after')
                + ' ORDER BY Id LIMIT ' + SET_PAGE_SIZE;
            List<PRM_Account_Contact_Relationship__c> page = Database.query(soql);
            Set<Id> intelAccountIds = new Set<Id>();
            for (PRM_Account_Contact_Relationship__c acr : page) {
                intelAccountIds.add(acr.PRM_Account_Id__c);
            }
            markOpidsWithPartnerAdmin(intelAccountIds);
            if (page.size() == SET_PAGE_SIZE) {
                chain(new SyncJob(false, page[page.size() - 1].Id));
            } else {
                chain(new SyncJob(true, null));
            }
        }

        private void clearPage() {
            Id after = cursor;
            String soql = 'SELECT Id FROM Account WHERE Is_Partner_Admin_Exist__c = true'
                + (after == null ? '' : ' AND Id > :after')
                + ' ORDER BY Id LIMIT ' + CLEAR_PAGE_SIZE;
            List<Account> page = Database.query(soql);
            clearStaleFlags(new Map<Id, Account>(page).keySet());
            if (page.size() == CLEAR_PAGE_SIZE) {
                chain(new SyncJob(true, page[page.size() - 1].Id));
            }
        }

        private void chain(SyncJob next) {
            if (!Test.isRunningTest()) {
                System.enqueueJob(next);
            }
        }
    }

    /*
     * SET: Intel accounts with an onboarded PA -> their IPA OPIDs -> flag = true where
     * not already true. Repeat onboardings on a flagged OPID cause no DML.
     */
    public static void markOpidsWithPartnerAdmin(Set<Id> intelAccountIds) {
        if (intelAccountIds == null || intelAccountIds.isEmpty()) {
            return;
        }
        Set<Id> opids = new Set<Id>();
        for (Core_Account_Group_Member__c cag : [
            SELECT Core_Partner_Account_Id__c
            FROM Core_Account_Group_Member__c
            WHERE Core_Intel_Account_Id__c IN :intelAccountIds
            AND Core_Intel_Partner_Alliance_PartnerGroup__c = true
            AND Core_Inactive_Ind__c = false
            AND Core_Partner_Account_Id__c != null
        ]) {
            opids.add(cag.Core_Partner_Account_Id__c);
        }
        if (opids.isEmpty()) {
            return;
        }
        List<Account> toUpdate = new List<Account>();
        for (Account opid : [
            SELECT Id
            FROM Account
            WHERE Id IN :opids
            AND Is_Partner_Admin_Exist__c = false
        ]) {
            toUpdate.add(new Account(Id = opid.Id, Is_Partner_Admin_Exist__c = true));
        }
        updateWithLogging(toUpdate);
    }

    /*
     * CLEAR: for flagged OPIDs, verify an active Complete Partner Admin ACR still exists
     * somewhere in the IPA hierarchy; clear the flag where it does not.
     */
    public static void clearStaleFlags(Set<Id> opids) {
        if (opids == null || opids.isEmpty()) {
            return;
        }
        Set<Id> stillQualified = qualifiedOpids(opids);
        List<Account> toUpdate = new List<Account>();
        for (Id opidId : opids) {
            if (!stillQualified.contains(opidId)) {
                toUpdate.add(new Account(Id = opidId, Is_Partner_Admin_Exist__c = false));
            }
        }
        updateWithLogging(toUpdate);
    }

    private static void updateWithLogging(List<Account> toUpdate) {
        if (toUpdate.isEmpty()) {
            return;
        }
        Database.SaveResult[] results = Database.update(toUpdate, false);
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                System.debug(LoggingLevel.ERROR, 'PRM_OpidPartnerAdminFlagService update failed for '
                    + toUpdate[i].Id + ': ' + results[i].getErrors());
            }
        }
    }
}