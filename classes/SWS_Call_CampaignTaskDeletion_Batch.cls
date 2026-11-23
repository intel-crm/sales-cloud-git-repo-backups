public class SWS_Call_CampaignTaskDeletion_Batch{
    
    private static final String BATCH_FLAGGED_TO_START = 'Deletion Flagged to Start';


    @InvocableMethod(label='Delete Tasks for a Campaign')
    public static void deleteTasksForCampaign(List<Id> campaignIds) {
        system.debug('@@campaignIds==>'+campaignIds);
        
        List<Campaign> campaignsToDeleteTasks = [select Id, Core_Task_Batch_Status__c from Campaign where Id in :campaignIds];
        system.debug('@@campaignsToDeleteTasks==>'+campaignsToDeleteTasks);            
        // Flag the campaigns indicating that batch task deletion needs to start
        for (Campaign c : campaignsToDeleteTasks)
        	c.Core_Task_Batch_Status__c = BATCH_FLAGGED_TO_START;
        update campaignsToDeleteTasks;
        
        // Fire off the batch process
       Database.executeBatch(new Core_CampaignTaskDeletion_Batch());
    }
}