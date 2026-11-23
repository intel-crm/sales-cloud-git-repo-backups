/* Trail run Class to check case owner queue has the active uer or not,only in devcase -Gangadhar */
public with sharing class Core_IPS_CaseOwnerQueueActiveUserCheck {

    // Define the structured inputs coming from your Flow
    public class FlowInput {
        @InvocableVariable(label='Case Record ID' required=true)
        public Id caseId;
        
        @InvocableVariable(label='Case Owner ID' required=true)
        public Id ownerId;
    }

    // Define the structured outputs going back to your Flow
    public class FlowOutput {
        @InvocableVariable(label='Has Active Members' description='Returns true if the Queue has at least one active user.')
        public Boolean hasActiveMembers;
    }

    @InvocableMethod(label='Check Queue Active Members' description='Verifies if a Case Owner Queue has any active users.')
    public static List<FlowOutput> checkQueueMembers(List<FlowInput> inputs) {
        List<FlowOutput> outputs = new List<FlowOutput>();
        Set<Id> queueIds = new Set<Id>();
        
        // 1. Gather all Queue IDs from the Flow requests (Queue IDs start with 00G)
        for (FlowInput input : inputs) {
            if (input.ownerId != null && String.valueOf(input.ownerId).startsWith('00G')) {
                queueIds.add(input.ownerId);
            }
        }

        // 2. Fetch all Group Members for these Queues
        Map<Id, Set<Id>> queueToUserIdsMap = new Map<Id, Set<Id>>();
        Set<Id> totalUserIds = new Set<Id>();
        
        if (!queueIds.isEmpty()) {
            for (GroupMember gm : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :queueIds]) {
                totalUserIds.add(gm.UserOrGroupId);
                if (!queueToUserIdsMap.containsKey(gm.GroupId)) {
                    queueToUserIdsMap.put(gm.GroupId, new Set<Id>());
                }
                queueToUserIdsMap.get(gm.GroupId).add(gm.UserOrGroupId);
            }
        }

        // 3. Find which users from the queues are completely active
        Map<Id, User> activeUsersMap = new Map<Id, User>();
        if (!totalUserIds.isEmpty()) {
            activeUsersMap = new Map<Id, User>([
                SELECT Id FROM User WHERE Id IN :totalUserIds AND IsActive = true
            ]);
        }

        // 4. Map the safe/unsafe results back to the individual Flow inputs in the correct list order
        for (FlowInput input : inputs) {
            FlowOutput out = new FlowOutput();
            out.hasActiveMembers = false; // Default fallback to safe-skip email

            // If it's a queue, check if any of its members are inside our activeUsersMap
            if (input.ownerId != null && String.valueOf(input.ownerId).startsWith('00G')) {
                Set<Id> memberIds = queueToUserIdsMap.get(input.ownerId);
                if (memberIds != null) {
                    for (Id memberId : memberIds) {
                        if (activeUsersMap.containsKey(memberId)) {
                            out.hasActiveMembers = true;
                            break; // Found one active user, this queue is clear to email
                        }
                    }
                }
            } else if (input.ownerId != null && String.valueOf(input.ownerId).startsWith('005')) {
                // Optional: If the case happens to be owned by a direct User, you can pass true
                out.hasActiveMembers = true;
            }

            outputs.add(out);
        }

        return outputs;
    }
}