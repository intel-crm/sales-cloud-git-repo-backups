public class GetOppPOP {
   public static List<Opportunity> getOpportunitiesWithTasksAndNoFiles() {
    // Query for Opportunities that have Tasks with specific criteria
    Set<Id> opportunityIdsWithTasks = new Set<Id>();
    for (Task task : [SELECT WhatId FROM Task WHERE What.Type = 'Opportunity' AND Subject = 'Post Proof of Performance (PoP)' AND WhatId != NULL]) {
        opportunityIdsWithTasks.add(task.WhatId);
    }
    System.debug('Number of opportunities with tasks: ' + opportunityIdsWithTasks.size());

    // Query for Opportunities that have Files attached with specific criteria
    Set<Id> opportunityIdsWithFiles = new Set<Id>();
    if (!opportunityIdsWithTasks.isEmpty()) {
        for (ContentDocumentLink link : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :opportunityIdsWithTasks AND ContentDocument.Title LIKE '%POP%']) {
            opportunityIdsWithFiles.add(link.LinkedEntityId);
        }
    }
    System.debug('Number of opportunities with files: ' + opportunityIdsWithFiles.size());

    // Remove Opportunities that have Files attached from the set of Opportunities with Tasks
    opportunityIdsWithTasks.removeAll(opportunityIdsWithFiles);

    // Query and return the Opportunities that have Tasks but no attached Files
    if (!opportunityIdsWithTasks.isEmpty()) {
        return [SELECT Id, Name, StageName 
                FROM Opportunity 
                WHERE Id IN :opportunityIdsWithTasks 
                AND Core_Commissionable__c = 'yes' 
                AND StageName IN ('Develop', 'Qualify', 'Define', 'Design')];
    } else {
        return new List<Opportunity>(); // Return an empty list if no matches
    }
}

}