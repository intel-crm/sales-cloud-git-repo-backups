/*************************************************************************************************
Class Name  : Core_CampaignTaskGeneration_Batch
Created Date: Dec 02, 2015
Function    : Asychronous batch process to generate tasks for a Sales Campaign when the number
              of campaign members exceeds 6000. Emails the campaign owner when complete.
Modification Log :
* Developer         Date          Description
* ---------------------------------------------------------------------------- 
* Dave Hood         12/02/2015    Original version
**************************************************************************************************/

global class Core_CampaignTaskGeneration_Batch implements Database.Batchable<sObject> {
    
    private static final String BATCH_FLAGGED_TO_START = 'Generation Flagged to Start';
    private static final String BATCH_STARTED = 'Generation Started';
    private static final String BATCH_COMPLETE = 'Generation Complete';
    private static final String BATCH_ERROR = 'Generation Error';
    
    private static String fromEmailAddress = System.Label.Core_SetFromEmailAddress;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        // Pull campaign members for the campaign(s) flagged for batch generation
        List<Campaign> campaignsToGenerateTasks = [select Id from Campaign where Core_Task_Batch_Status__c = :BATCH_FLAGGED_TO_START];
        Database.QueryLocator campaignMembers = Database.getQueryLocator([select Id from CampaignMember where CampaignId in :campaignsToGenerateTasks]);
        
        // Update the campaigns to indicate generation is in progress
        for (Campaign c : campaignsToGenerateTasks) {
            c.Core_Task_Batch_Status__c = BATCH_STARTED;
            c.Core_Task_Batch_Job_ID__c = bc.getJobId();
        }
        update campaignsToGenerateTasks;
        
        return campaignMembers;
    }
    
    global void execute(Database.BatchableContext bc, List<CampaignMember> campaignMembers) {
        
        List<Id> campaignMemberIds = new List<Id>();
        for (CampaignMember cm : campaignMembers)
            campaignMemberIds.add(cm.Id);
         
        Core_CampaignTaskGeneration_Controller.generateTasksForSpecificMembers(campaignMemberIds);
        
    }
    
    global void finish(Database.BatchableContext bc) {
       
        // Get the batch job information
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        
        // Shoot an email to the user who kicked off the batch
        String strEmailBody = 'Salesforce has just completed task generation for your sales campaign!\n\n' +
            'Status: ' + a.Status + '\n' +
            'Total batches processed: ' + a.TotalJobItems + '\n' +
            'Batches with errors: ' + a.NumberOfErrors + '\n';
        
        String batchStatus = BATCH_COMPLETE;
        
        if (a.NumberOfErrors > 0) {
            strEmailBody += '\nPlease contact a System Administrator to re-process the failures.';
            batchStatus = BATCH_ERROR;
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Salesforce task generation for sales campaign has finished. Batch status: ' + a.Status + '.');
        mail.setPlainTextBody(strEmailBody);
        mail.setToAddresses(new String[]{a.CreatedBy.Email});
        mail.setOrgWideEmailAddressId(fromEmailAddress);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
         
        // Update the batch generation flag for the campaign(s) we generated tasks for
        List<Campaign> campaigns = [select Id, Core_Task_Batch_Status__c
                                    from Campaign where Core_Task_Batch_Job_ID__c = :bc.getJobId()];
        
        for (Campaign c : campaigns)
            c.Core_Task_Batch_Status__c = batchStatus;
        
        update campaigns;
    }
}