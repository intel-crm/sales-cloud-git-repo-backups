/*************************************************************************************************
Class Name  : Core_CampaignTaskDeletion_Batch
Created Date: Dec 02, 2015
Function    : Asychronous batch process to delete tasks for a Sales Campaign when it's cancelled.
Modification Log :
* Developer         Date          Description
* ---------------------------------------------------------------------------- 
* Dave Hood         12/02/2015    Original version
**************************************************************************************************/

global class Core_CampaignTaskDeletion_Batch implements Database.Batchable<sObject> {
    
    /*private static final String BATCH_FLAGGED_TO_START = 'Deletion Flagged to Start';
    private static final String BATCH_STARTED = 'Deletion Started';
    private static final String BATCH_COMPLETE = 'Deletion Complete';
    private static final String BATCH_ERROR = 'Deletion Error';
    
    private static final String TASK_NOT_STARTED = 'Not Started';*/

    /*@InvocableMethod(label='Delete Tasks for a Campaign')
    public static void deleteTasksForCampaign(List<Id> campaignIds) {
        
        List<Campaign> campaignsToDeleteTasks = [select Id, Core_Task_Batch_Status__c from Campaign where Id in :campaignIds];
                    
        // Flag the campaigns indicating that batch task deletion needs to start
        for (Campaign c : campaignsToDeleteTasks)
          c.Core_Task_Batch_Status__c = BATCH_FLAGGED_TO_START;
        update campaignsToDeleteTasks;
        
        // Fire off the batch process
        Database.executeBatch(new Core_CampaignTaskDeletion_Batch());
    }*/
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        // Pull tasks for the campaign(s) flagged for batch deletion
        /*List<Campaign> campaigns = [select Id from Campaign where Core_Task_Batch_Status__c = :BATCH_FLAGGED_TO_START];
        List<Id> campaignIds = new List<Id>();
        for (Campaign c : campaigns)
            campaignIds.add(c.Id);
            
        Database.QueryLocator tasksToDelete = Database.getQueryLocator([select Id from Task where Status = :TASK_NOT_STARTED and WhatId in :campaignIds]);
        
        // Update the campaigns to indicate deletion is in progress
        for (Campaign c : campaigns) {
            c.Core_Task_Batch_Status__c = BATCH_STARTED;
            c.Core_Task_Batch_Job_ID__c = bc.getJobId();
        }
        update campaigns;
        
        return tasksToDelete;*/
        return null;
    }
    
    global void execute(Database.BatchableContext bc, List<Task> tasks) {
        //delete tasks;
    }
    
    global void finish(Database.BatchableContext bc) {
        
        // Get the batch job information
        /*AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        
        // Shoot an email to the user who cancelled the campaign, if total batches was > 1
        String strEmailBody = 'You recently cancelled a sales campaign with a large number of tasks associated with it. ' +
            'Salesforce has just finished deleting all "Not Started" tasks for that campaign.\n\n' +
            'Status: ' + a.Status + '\n' +
            'Total batches processed: ' + a.TotalJobItems + '\n' +
            'Batches with errors: ' + a.NumberOfErrors + '\n';
        
        String batchStatus = BATCH_COMPLETE;
        
        if (a.NumberOfErrors > 0) {
            strEmailBody += '\n\nPlease contact a System Administrator to re-process the failures.';
            batchStatus = BATCH_ERROR;
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Salesforce task cancellation for sales campaign has finished. Batch status: ' + a.Status + '.');
        mail.setPlainTextBody(strEmailBody);
        mail.setToAddresses(new String[]{a.CreatedBy.Email});
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        
        // Update the batch status flag and clear the task generation flag for the campaign(s) we deleted tasks for
        List<Campaign> campaigns = [select Id, Core_Task_Batch_Status__c, Core_Tasks_Generated__c
                                    from Campaign where Core_Task_Batch_Job_ID__c = :bc.getJobId()];
        
        for (Campaign c : campaigns) {
            c.Core_Task_Batch_Status__c = batchStatus;
            c.Core_Tasks_Generated__c = false;
        }
        
        update campaigns;*/
    }
}