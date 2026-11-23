trigger Core_Grant_Edit_Access_On_Lead on Lead (after update) {
    List<LeadShare> leadSharesToUpdate = new List<LeadShare>();
    
    Map<Id, Id> leadIdToOwnerIdMap = new Map<Id, Id>();
    
    // Collect the Lead Ids and their new owner Ids
    for (Lead updatedLead : Trigger.new) {
        // Check if the Core_Partner_Lead_Owner__c field is changing from null to a non-null value
        if (Trigger.oldMap.get(updatedLead.Id).Core_Partner_Lead_Owner__c == null && updatedLead.Core_Partner_Lead_Owner__c != null) {
            leadIdToOwnerIdMap.put(updatedLead.Id, updatedLead.Core_Partner_Lead_Owner__c);
        }
    }
    
    // If there are any ownership changes, create LeadShare records
    if (!leadIdToOwnerIdMap.isEmpty()) {
        for (Id leadId : leadIdToOwnerIdMap.keySet()) {
            LeadShare newOwnerShare = new LeadShare();
            newOwnerShare.LeadId = leadId;
            newOwnerShare.UserOrGroupId = leadIdToOwnerIdMap.get(leadId);
            newOwnerShare.LeadAccessLevel = 'Edit'; // Grant edit access
            newOwnerShare.RowCause = Schema.LeadShare.RowCause.Owner; // Specify the reason for sharing
            
            leadSharesToUpdate.add(newOwnerShare);
        }
        
        // Insert the LeadShare records to grant edit access
        Database.SaveResult[] results = Database.insert(leadSharesToUpdate, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                // Handle any errors here if needed
            }
        }
    }
}