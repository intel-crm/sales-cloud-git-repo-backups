/*************************************************************************************************
Class Name  : Core_CampaignTaskDeletion_Batch
Created Date: Dec 02, 2015
Function    : Asychronous batch process to delete tasks for a Sales Campaign when it's cancelled.
Test Class  : Core_CampaignTaskDeletion_Batch_Test
Modification Log :
* Developer         Date          Description
* ---------------------------------------------------------------------------- 
* Dave Hood         12/02/2015    Original version
**************************************************************************************************/

global class Core_CampaignTaskDeletion_Batch implements Database.Batchable<sObject> {
    
    private static final String BATCH_FLAGGED_TO_START = 'Deletion Flagged to Start';
    private static final String BATCH_STARTED = 'Deletion Started';
    private static final String BATCH_COMPLETE = 'Deletion Complete';
    private static final String BATCH_ERROR = 'Deletion Error';    
    private static final String TASK_NOT_STARTED = 'Not Started';    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        deleteTasksForCampaign();
        // Pull tasks for the campaign(s) flagged for batch deletion
        List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Core_Task_Batch_Status__c = :BATCH_FLAGGED_TO_START];
        List<Id> campaignIds = new List<Id>();
        for (Campaign c : campaigns)
            campaignIds.add(c.Id);
            
        Database.QueryLocator tasksToDelete = Database.getQueryLocator([SELECT Id FROM Task WHERE Status = :TASK_NOT_STARTED AND WhatId IN :campaignIds]);

        // Update the campaigns to indicate deletion is in progress
        for (Campaign c : campaigns) {
            c.Core_Task_Batch_Status__c = BATCH_STARTED;
            c.Core_Task_Batch_Job_ID__c = bc.getJobId();
        }
        update campaigns;
        
        return tasksToDelete;
    }
    
    global void execute(Database.BatchableContext bc, List<Task> tasks) {
        delete tasks;   
    }
    
    global void finish(Database.BatchableContext bc) {        
        // Get the batch job information
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        
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
        List<Campaign> campaigns = [SELECT Id, Core_Task_Batch_Status__c, Core_Tasks_Generated__c FROM Campaign WHERE Core_Task_Batch_Job_ID__c = :bc.getJobId()];
        
        for (Campaign c : campaigns) {
            c.Core_Task_Batch_Status__c = batchStatus;
            c.Core_Tasks_Generated__c = false;
        }
        update campaigns;
        
        SWS_Core_CRM_Labels__c  lastRunDate = SWS_Core_CRM_Labels__c.getValues('Last_Task_Deletion_Run_Date');
		DateTime dt = DateTime.now();
        lastRunDate.SWS_Value__c = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'+0000\'');
        update lastRunDate;
    }

    public static void deleteTasksForCampaign(){
        SWS_Core_CRM_Labels__c  lastBatchRunDate = SWS_Core_CRM_Labels__c.getValues('Last_Task_Deletion_Run_Date');
        String formattedDateTime = lastBatchRunDate.SWS_Value__c;
        String DTime = formattedDateTime.replace('T', ' ');
        DateTime lastRunDate = DateTime.valueOf(DTime);
        List<Campaign> campaignsToDeleteTasks = [SELECT Id, Core_Task_Batch_Status__c, RecordType.DeveloperName, Status FROM Campaign WHERE Campaign.RecordType.DeveloperName = 'Core_Sales_Campaign' AND Campaign.Status = 'Cancelled' AND LastModifiedDate >: lastRunDate];
        // Flag the campaigns indicating that batch task deletion needs to start
        for (Campaign c : campaignsToDeleteTasks)
        	c.Core_Task_Batch_Status__c = BATCH_FLAGGED_TO_START;
        update campaignsToDeleteTasks;
    }
}