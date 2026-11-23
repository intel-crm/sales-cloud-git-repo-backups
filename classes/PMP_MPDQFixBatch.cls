global class PMP_MPDQFixBatch
    implements Database.Batchable<SObject>, Database.Stateful {

    /* =========================================================
       START – Delta ACMs only
       ========================================================= */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, PRM_Account_Id__c
            FROM PRM_AccountChannelMembership__c
            WHERE PRM_Status_Nm__c IN ('Approved','Pending','Inactive')
              AND Id = 'a5j8A000000EG8KQAW'
        ]);//CHECK ON RECORD TYPE OF ACCOUNT AND THE LAST MODIFIED DATE
    }

    /* =========================================================
       EXECUTE
       ========================================================= */
    global void execute(Database.BatchableContext bc,
                        List<PRM_AccountChannelMembership__c> scope) {

        if (scope.isEmpty()) return;

        /* ---------------------------------------------------------
           1. Identify Accounts
           --------------------------------------------------------- */
        Set<Id> accountIds = new Set<Id>();
        for (PRM_AccountChannelMembership__c acm : scope) {
            if (acm.PRM_Account_Id__c != null) {
                accountIds.add(acm.PRM_Account_Id__c);
            }
        }
        if (accountIds.isEmpty()) return;

        /* ---------------------------------------------------------
           2. Query ALL ACMs for Accounts
           --------------------------------------------------------- */
        List<PRM_AccountChannelMembership__c> allAcms = [
            SELECT PRM_Account_Id__c,
                   PRM_Partner_Role__c,
                   PRM_Channel_Program_Level_Id__c,
                   PRM_Status_Nm__c
            FROM PRM_AccountChannelMembership__c
            WHERE PRM_Account_Id__c IN :accountIds
        ];
//CREATE A MAP WHICH STORES ACCOUNT ID AND ALL ACMS //IF ALL ACMS ARE INACTIVE THE OPID ALSO MUST BE DEACTIVE AND THE STOREFRONTS,PAG ALSO
//ONE MORE SCENARIO IS THAT IF THE STOREFRONT HAS MULTIPLE OPIDS ASSOCIATED THEN CHECK ALL OPIDS AND ITS ACMS AND THEN INACTIVATE THE STOREFRONT AND ITS PAG
        /* ---------------------------------------------------------
           3. Resolve Tier Names (CRITICAL FIX)
           --------------------------------------------------------- */
        Set<Id> tierIds = new Set<Id>();
        for (PRM_AccountChannelMembership__c acm : allAcms) {
            if (acm.PRM_Channel_Program_Level_Id__c != null) {
                tierIds.add(acm.PRM_Channel_Program_Level_Id__c);
            }
        }

        Map<Id, String> tierIdToName = new Map<Id, String>();
        if (!tierIds.isEmpty()) {
            for (ChannelProgramLevel t : [
                SELECT Id, Name
                FROM ChannelProgramLevel
                WHERE Id IN :tierIds
            ]) {
                tierIdToName.put(t.Id, t.Name);
            }
        }

        /* ---------------------------------------------------------
           4. Build Account Summary (NO NESTED LOOPS)
           --------------------------------------------------------- */
        Map<String, Integer> tierRank = new Map<String, Integer>{
            'Member'   => 1,
            'Partner'  => 2,
            'Prestige' => 3
        };

        Map<Id, Set<String>> acctRoles = new Map<Id, Set<String>>();
        Map<Id, Integer> acctTierRank = new Map<Id, Integer>();
        Set<Id> accountsWithApproved = new Set<Id>();

        for (PRM_AccountChannelMembership__c acm : allAcms) {

            if (acm.PRM_Status_Nm__c != 'Approved') continue;

            Id acctId = acm.PRM_Account_Id__c;
            accountsWithApproved.add(acctId);

            // Roles
            if (!acctRoles.containsKey(acctId)) {
                acctRoles.put(acctId, new Set<String>());
            }
            if (String.isNotBlank(acm.PRM_Partner_Role__c)) {
                acctRoles.get(acctId).add(acm.PRM_Partner_Role__c);
            }

            // Tier (by NAME, not Id)
            String tierName = tierIdToName.get(acm.PRM_Channel_Program_Level_Id__c);
            Integer rank = tierRank.get(tierName);

            if (rank != null) {
                Integer current = acctTierRank.containsKey(acctId)
                    ? acctTierRank.get(acctId)
                    : 0;
                acctTierRank.put(acctId, Math.max(current, rank));
            }
        }

        Map<Id, String> acctHighestTier = new Map<Id, String>();
        Map<Id, String> acctRoleStr     = new Map<Id, String>();
        Map<Id, String> acctComboStr    = new Map<Id, String>();

        for (Id acctId : accountIds) {

            if (!accountsWithApproved.contains(acctId)) continue;

            Integer rank = acctTierRank.get(acctId);
            String tier = 'Member';

            for (String t : tierRank.keySet()) {
                if (tierRank.get(t) == rank) {
                    tier = t;
                    break;
                }
            }

            List<String> roles = new List<String>(
                acctRoles.containsKey(acctId)
                    ? acctRoles.get(acctId)
                    : new Set<String>()
            );
            roles.sort();

            String roleStr = String.join(roles, ', ');
            acctHighestTier.put(acctId, tier);
            acctRoleStr.put(acctId, roleStr);
            acctComboStr.put(acctId, roleStr + ' - ' + tier);
        }

        /* ---------------------------------------------------------
           5. Fetch OPID / MPI
           --------------------------------------------------------- */
        List<PMP_OPID_MPI_Rel__c> mpiRels = [
            SELECT Id,
                   Is_Active__c,
                   PMP_One_Partner_ID__c,
                   PMP_Marketing_Profile_Id__c,
                   PMP_Marketing_Profile_Id__r.Id,
                   PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c,
                   PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__r.Id
            FROM PMP_OPID_MPI_Rel__c
            WHERE PMP_One_Partner_ID__c IN :accountIds
        ];

        /* ---------------------------------------------------------
           6. Fetch Companies
           --------------------------------------------------------- */
        Set<Id> companyIds = new Set<Id>();
        for (PMP_OPID_MPI_Rel__c r : mpiRels) {
            if (r.PMP_Marketing_Profile_Id__r != null)
                companyIds.add(r.PMP_Marketing_Profile_Id__r.Id);
            if (r.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__r != null)
                companyIds.add(r.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__r.Id);
        }

        Map<Id, PMP_Company__c> companyMap = new Map<Id, PMP_Company__c>([
            SELECT Id,
                   PMP_IPA_Badge_Tier_Txt__c,
                   PMP_Partner_Program_nm__c,
                   PMP_Account_Program_Membership__c,
                   PMP_Benefit_Update_Ind__c
            FROM PMP_Company__c
            WHERE Id IN :companyIds
        ]);

        List<PMP_Company__c> companyUpdates = new List<PMP_Company__c>();
        List<PMP_OPID_MPI_Rel__c> relUpdates = new List<PMP_OPID_MPI_Rel__c>();

        /* ---------------------------------------------------------
           7. Apply summary (SAFE, VALIDATED)
           --------------------------------------------------------- */
        for (PMP_OPID_MPI_Rel__c rel : mpiRels) {

            Id acctId = rel.PMP_One_Partner_ID__c;
            Boolean hasApproved = accountsWithApproved.contains(acctId);

            PMP_Company__c wc = companyMap.get(
                rel.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__r.Id
            );
            PMP_Company__c pc = companyMap.get(
                rel.PMP_Marketing_Profile_Id__r.Id
            );

            if (!hasApproved) {
                if (rel.Is_Active__c) {
                    rel.Is_Active__c = false;
                    relUpdates.add(rel);
                }
                for (PMP_Company__c c : new List<PMP_Company__c>{ wc, pc }) {
                    if (c != null && !c.PMP_Benefit_Update_Ind__c) {
                        c.PMP_Benefit_Update_Ind__c = true;
                        companyUpdates.add(c);
                    }
                }
                continue;
            }

            if (!rel.Is_Active__c) {
                rel.Is_Active__c = true;
                relUpdates.add(rel);
            }

            String tier  = acctHighestTier.get(acctId);
            String role  = acctRoleStr.get(acctId);
            String combo = acctComboStr.get(acctId);

            for (PMP_Company__c c : new List<PMP_Company__c>{ wc, pc }) {
                if (c == null) continue;

                Boolean changed = false;

                if (c.PMP_IPA_Badge_Tier_Txt__c != tier) {
                    c.PMP_IPA_Badge_Tier_Txt__c = tier;
                    changed = true;
                }
                if (c.PMP_Partner_Program_nm__c != role) {
                    c.PMP_Partner_Program_nm__c = role;
                    changed = true;
                }
                if (c.PMP_Account_Program_Membership__c != combo) {
                    c.PMP_Account_Program_Membership__c = combo;
                    changed = true;
                }
                if (c.PMP_Benefit_Update_Ind__c) {
                    c.PMP_Benefit_Update_Ind__c = false;
                    changed = true;
                }

                if (changed) companyUpdates.add(c);
            }
        }

        /* ---------------------------------------------------------
           8. DML
           --------------------------------------------------------- */
        if (!companyUpdates.isEmpty()) update companyUpdates;
        if (!relUpdates.isEmpty()) update relUpdates;
    }

    global void finish(Database.BatchableContext bc) {}
}