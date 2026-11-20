global class PMP_RemoveSharingForPartners implements Database.Batchable<SObject>, Database.Stateful {

    // State tracking
    public Map<Id, Boolean> stagingSuccessMap = new Map<Id, Boolean>();

    // START
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, AccountId__c
            FROM Core_ACM_Account_Staging__c
            WHERE Core_Status__c = 'NEW'
            AND Core_Action__c = 'REMOVE_MPSHARE'
            AND AccountId__c != null //Note: Stores Contact Id
            AND CreatedDate = TODAY
        ]);
    }

    // EXECUTE
    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        if (scope == null || scope.isEmpty()) return;

        String pmpStr = 'PMP_';

        Set<Id> contactIds = new Set<Id>();
        Map<Id, Id> stagingToContact = new Map<Id, Id>();

        // STEP 1: Collect  CONTACT data
        for (Core_ACM_Account_Staging__c rec : (List<Core_ACM_Account_Staging__c>) scope) {
            //Note: Collects Contact IDs from AccountId__c Field
            if (rec.AccountId__c != null) {
                contactIds.add(rec.AccountId__c);
                stagingToContact.put(rec.Id, rec.AccountId__c);

                // Assume success initially
                stagingSuccessMap.put(rec.Id, true);
            }
        }

        if (contactIds.isEmpty()) return;

        // STEP 2: Entitlement filter
        String labelVal = System.Label.PMP_Egligble_Entitlement;
        List<String> entValues = labelVal != null ? labelVal.split(';') : new List<String>();

        Set<Id> protectedContacts = new Set<Id>();

        if (!entValues.isEmpty()) {
            for (Core_Contact_Entitlement__c ent : [
                SELECT Core_Contact_Id__c
                FROM Core_Contact_Entitlement__c
                WHERE Core_Contact_Id__c IN :contactIds
                AND Core_Selected__c = true
                AND Core_Status__c = 'Complete'
                AND Core_Entitlement_Id__r.Name IN :entValues
            ]) {
                protectedContacts.add(ent.Core_Contact_Id__c);
            }
        }

        // STEP 3: Users + OPID (combined)
        Map<String, Set<Id>> opidToUsers = new Map<String, Set<Id>>();
        Map<Id, String> contactToOpid = new Map<Id, String>();
        Set<String> groupNames = new Set<String>();

        for (User u : [
            SELECT Id, ContactId, Contact.Core_IPA_One_Partner_Id__c
            FROM User
            WHERE ContactId IN :contactIds
        ]) {

            if (u.ContactId == null || u.Contact == null) continue;
            if (protectedContacts.contains(u.ContactId)) continue;

            String opid = u.Contact.Core_IPA_One_Partner_Id__c;
            if (String.isBlank(opid)) continue;

            contactToOpid.put(u.ContactId, opid);
            groupNames.add(pmpStr + opid);

            if (!opidToUsers.containsKey(opid)) {
                opidToUsers.put(opid, new Set<Id>());
            }
            opidToUsers.get(opid).add(u.Id);
        }

        if (opidToUsers.isEmpty()) return;
        
        // =========================
        // STEP 4: Fetch Groups
        // =========================
        Map<String, Id> groupNameToId = new Map<String, Id>();
        
        if (!groupNames.isEmpty()) {
            for (Group g : [
                SELECT Id, DeveloperName
                FROM Group
                WHERE DeveloperName IN :groupNames
            ]) {
                groupNameToId.put(g.DeveloperName, g.Id);
            }
        }
        
        
        // Build Mapping + Fetch GroupMembers        
        // Step 5A: Map Group → Staging (for failure tracking)
        Map<Id, Set<Id>> groupToStaging = new Map<Id, Set<Id>>();
        
        for (Id stgId : stagingToContact.keySet()) {
            Id contactId = stagingToContact.get(stgId);
            String opid = contactToOpid.get(contactId);
        
            if (String.isBlank(opid)) continue;
        
            String grpName = pmpStr + opid;
            Id grpId = groupNameToId.get(grpName);
        
            if (grpId == null) continue;
        
            if (!groupToStaging.containsKey(grpId)) {
                groupToStaging.put(grpId, new Set<Id>());
            }
        
            groupToStaging.get(grpId).add(stgId);
        }
        
        
        // Step 5B: Fetch ONLY required GroupMembers (NO nested loop)
        Map<Id, GroupMember> toDeleteMap = new Map<Id, GroupMember>();
        
        Set<Id> allUserIds = new Set<Id>();
        for (Set<Id> usrSet : opidToUsers.values()) {
            allUserIds.addAll(usrSet);
        }
        
        Set<Id> groupIds = new Set<Id>(groupNameToId.values());
        
        if (!groupIds.isEmpty() && !allUserIds.isEmpty()) {
        
            for (GroupMember gm : [
                SELECT Id, GroupId, UserOrGroupId
                FROM GroupMember
                WHERE GroupId IN :groupIds
                AND UserOrGroupId IN :allUserIds
            ]) {
                toDeleteMap.put(gm.Id, gm); // prevents duplicates
            }
        }
        
        
        // STEP 6: Delete + Failure Handling
        if (!toDeleteMap.isEmpty()) {
        
            List<GroupMember> deleteList = new List<GroupMember>(toDeleteMap.values());
            List<Database.DeleteResult> results = Database.delete(deleteList, false);
        
            for (Integer i = 0; i < results.size(); i++) {
        
                if (!results[i].isSuccess()) {
        
                    Id grpId = deleteList[i].GroupId;
        
                    if (groupToStaging.containsKey(grpId)) {
        
                        for (Id stgId : groupToStaging.get(grpId)) {
                            stagingSuccessMap.put(stgId, false);
                        }
                    }
                }
            }
        }

        // STEP 4: Groups + Members
        /*Map<String, Id> groupNameToId = new Map<String, Id>();
        Map<Id, List<GroupMember>> groupMembersMap = new Map<Id, List<GroupMember>>();

        for (Group g : [SELECT Id, DeveloperName,(SELECT Id, UserOrGroupId FROM GroupMembers)
            FROM Group
            WHERE DeveloperName IN :groupNames
        ]) {
            groupNameToId.put(g.DeveloperName, g.Id);
            groupMembersMap.put(g.Id, g.GroupMembers);
        }

        // STEP 5: Identify deletes
        List<GroupMember> toDelete = new List<GroupMember>();
        Map<Id, Set<Id>> groupToStaging = new Map<Id, Set<Id>>();

        for (Id stgId : stagingToContact.keySet()) {

            Id contactId = stagingToContact.get(stgId);
            String opid = contactToOpid.get(contactId);

            if (String.isBlank(opid)) continue;

            String grpName = pmpStr + opid;
            Id grpId = groupNameToId.get(grpName);

            if (grpId == null) continue;

            if (!groupToStaging.containsKey(grpId)) {
                groupToStaging.put(grpId, new Set<Id>());
            }
            groupToStaging.get(grpId).add(stgId);

            Set<Id> users = opidToUsers.get(opid);
            List<GroupMember> members = groupMembersMap.get(grpId);

            if (users == null || members == null) continue;

            for (GroupMember gm : members) {
                if (gm.UserOrGroupId != null && users.contains(gm.UserOrGroupId)) {
                    toDelete.add(gm);
                }
            }
        }
		
        // STEP 6: Delete
        if (!toDelete.isEmpty()) {

            Database.DeleteResult[] results = Database.delete(toDelete, false);

            for (Integer i = 0; i < results.size(); i++) {

                if (!results[i].isSuccess()) {

                    Id grpId = toDelete[i].GroupId;
                    Set<Id> relatedStg = groupToStaging.get(grpId);

                    if (relatedStg != null) {
                        for (Id stgId : relatedStg) {
                            stagingSuccessMap.put(stgId, false);
                        }
                    }
                }
            }
        }*/
    }
    
    // FINISH 
    public void finish(Database.BatchableContext bc) {

        List<Core_ACM_Account_Staging__c> toUpdate = new List<Core_ACM_Account_Staging__c>();

        for (Id stgId : stagingSuccessMap.keySet()) {

            Core_ACM_Account_Staging__c rec =
                new Core_ACM_Account_Staging__c(Id = stgId);

            if (stagingSuccessMap.get(stgId) == true) {
                rec.Core_Status__c = 'COMPLETED';
            } else {
                rec.Core_Status__c = 'FAILED';
            }

            toUpdate.add(rec);
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] res = Database.update(toUpdate, false);
            PMP_Utility.logDmlErrors((Object[]) res,'PMP_RemoveSharingForPartners-Finish');             
        }
    }
}