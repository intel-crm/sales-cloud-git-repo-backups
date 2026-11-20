/******************************************************************************************************************************************
Class Name  : Core_CampaignMemberTask
Version     : 1.0 
Created Date: 05 OCT 2015
Function    : Business functions related to handling tasks related to Campaigns, invoked from the Campaign Member trigger/handler class
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 10/05/2015              Original version
*****************************************************************************************************************************************/
public class Core_CampaignMemberTask {

    public static void memberDeletionTaskCleanup(List<CampaignMember> oldList, List<CampaignMember> newList,
                                                 Map<Id,CampaignMember> oldMap, Map<Id,CampaignMember> newMap)
    {
        if (!Core_CampaignMemberHandler.memberDeletionTaskCleanup) {
            
            // Ensure no re-entry
            Core_CampaignMemberHandler.memberDeletionTaskCleanup = true;
            
            // Only execute this logic if the trigger is turned on
            if (!Core_CampaignMemberHandler.mapFunctionalityNameTriggerExecution.isEmpty()) {
                if (Core_CampaignMemberHandler.mapFunctionalityNameTriggerExecution.containsKey('memberDeletionTaskCleanup') && 
                   Core_CampaignMemberHandler.mapFunctionalityNameTriggerExecution.get('memberDeletionTaskCleanup').Core_Active__c)
                {
                    // Only operate on Sales Campaigns
                    Id campRecordTypeId = [select Id from RecordType where DeveloperName = :Label.Core_Campaign_Sales_Record_Type].Id;
                    
                    // Get the Campaign ID. To greatly simplify the code, assume we'll never be deleting Campaign Members
                    // from multiple Campaigns at the same time and need to clean up tasks.
                    Id campId = oldList[0].CampaignId;
                    
                    // Get all of the info we'll need about the Campaign
                    Campaign camp = [select RecordTypeId, Status, Core_Approval_Status__c, Core_Tasks_Generated__c
                                     from Campaign where Id = :campId];
                    
                    // Only execute this if the Campaign is a Sales Campaign, In Progress, and has already had tasks generated
                    if ((camp.RecordTypeId == campRecordTypeId) && (camp.Status == 'In Progress') && (camp.Core_Tasks_Generated__c)) {
                        
                        List<Id> contactIds = new List<Id>();
                        for (CampaignMember campMember : oldList)
                            contactIds.add(campMember.ContactId);
                        
                        // Get any tasks 
                        List<Task> tasksToDelete = [select Id from Task
                                                    where WhatId = :campId and WhoId in :contactIds and Status = :Label.Core_Campaign_Task_Not_Started];
                        
                        // Add them to our collection for consolidated DML deletion at the end of the handler class 
                        for (Task t : tasksToDelete) {
                            Core_CampaignMemberHandler.objectsToDelete.put(t.Id, t);
                        }
                    }
                }
            }
        }
    }
}