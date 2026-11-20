/*************************************************************************************************
Class Name  : Core_CampaignTaskGeneration_Controller
Created Date: Oct 01, 2015
Function    : Visualforce controller code for the Campaign Task Generation page, to generate tasks
              for a Sales Campaign, for each Activity Type. This code also contains an invocable method
              which can be called from Process Builder.
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Dave Hood         10/01/2015    Original version
* Dave Hood         12/02/2015    Updated with logic to handle > 6K tasks asynchronously
**************************************************************************************************/

// Note: class needs to run "without sharing" so Tasks can be created and assigned to other users,
// and it will always succeed, even if the running user doesn't have access to their calendars in Salesforce
public without sharing class Core_CampaignTaskGeneration_Controller {

    private static Campaign camp;
    private static Id campId;
    private static String campActivityTypesString;
    private static List<String> campActivityTypes;
    private static String campPriority;
    
    private static String callScriptApiName;
    private static Id taskRecordTypeId;
    private static String taskDescription;
    private static Id uncoveredAccountUserId;
    private static Id vendorSalesCenterUserId;
    
    private static List<CampaignMember> campMembers;
    
    private static Set<Id> assignees;               // Total number of users to which we've assigned tasks
    private static List<Task> generatedTasks;       // Tasks we're generating
    
    private static final String BATCH_FLAGGED_TO_START = 'Generation Flagged to Start';
    
    public Core_CampaignTaskGeneration_Controller() {
    }
    
    public void generateTasks() {
        
        // Page only functions when the ID of the Campaign is passed in
        if (ApexPages.currentPage().getParameters().get('Id') != null) {
            
            // Get the fields we need from the Campaign
            campId = ApexPages.currentPage().getParameters().get('Id');
            
            camp = [select Name, Status, EndDate, OwnerId, Core_Activity_Types__c, Core_Call_Script__c,
                        Core_Tasks_Generated__c, Core_Campaign_Priority__c, Core_Task_Batch_Status__c
                    from Campaign where Id = :campId];
        
            // Hard stop if the Campaign isn't In Progress
            if (camp.Status != 'In Progress') {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Core_Campaign_Not_Approved_And_In_Progress));            
            }
            // Don't generate tasks if they've already been generated
            else if (camp.Core_Tasks_Generated__c == true) {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Core_Campaign_Tasks_Already_Generated));
            }
            else {
                // Get the Campaign Members
                campMembers = [select Id, ContactId, Contact.AccountId, Contact.Account.Name, Core_Account_Owner_ID__c,
                               		Core_Assigned_To_User_ID__c, Core_Last_Touch_Marketing_Activity__c
                               from CampaignMember where CampaignId = :campId];
                
                // If there are more than 50K tasks, we'll hit a governor limit even in an async process, so let the user know
                if ((campMembers.size() * camp.Core_Activity_Types__c.split(';').size()) > 50000) {
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Core_Campaign_Too_Many_Tasks));
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                                                               '<a href="/' + camp.Id + '">Back to Campaign: ' + camp.Name + '</a>'));
                }
                // Based on testing, if there are more than 6K tasks, we should generate them asynchronously, to avoid CPU limits.
                // Note: this section is tested by the Apex tests for the batch process.
                else if ((campMembers.size() * camp.Core_Activity_Types__c.split(';').size()) > 6000) {
                    
                    // Flag the campaign indicating that batch task generation needs to start
                    camp.Core_Task_Batch_Status__c = BATCH_FLAGGED_TO_START;
                    update camp;
                    
                    // Fire off the batch process and display a message to the user - but only if we're not running an Apex test.
                    // If we are running a test, we'll test the actual batch class separately from here, with less than 6K records.
                    if (!Test.isRunningTest())
                    	Database.executeBatch(new Core_CampaignTaskGeneration_Batch());
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Core_Campaign_Batch_Process));
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                                                               '<a href="/' + camp.Id + '">Back to Campaign: ' + camp.Name + '</a>'));
                }
                else {
                    // Build a list of Campaign Member IDs and call the invocable method to generate tasks for them
                    List<Id> campMemberIds = new List<Id>();
                    for (CampaignMember campMember : campMembers)
                        campMemberIds.add(campMember.Id);
                    
                    Core_CampaignTaskGeneration_Controller.generateTasksForSpecificMembers(campMemberIds);
                    
                    // Display useful information about the tasks that were generated, and a link back to the Campaign
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generatedTasks.size() + ' ' +
                                                               Label.Core_Campaign_Tasks_Generated));
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, assignees.size() + ' ' +
                                                               Label.Core_Campaign_Tasks_Assignees));
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                                                               '<a href="/' + camp.Id + '">Back to Campaign: ' + camp.Name + '</a>'));
                }
            }
        }
    }
    
    @InvocableMethod(label='Generate Tasks for Specific Campaign Members')
    public static void generateTasksForSpecificMembers(List<Id> campaignMemberIds) {
        
        // If we don't have the Campaign record yet, it means this code was invoked from Process Builder,
        // so we need to pull the Campaign Members and Campaign
        if (camp == null) {
            
            campMembers = [select Id, CampaignId, ContactId, Contact.AccountId, Contact.Account.Name,
                           		Core_Account_Owner_ID__c, Core_Assigned_To_User_ID__c, Core_Last_Touch_Marketing_Activity__c
                           from CampaignMember where Id in :campaignMemberIds];
            
            campId = campMembers[0].CampaignId;
            
            camp = [select Name, Status, EndDate, OwnerId, Core_Activity_Types__c, Core_Call_Script__c,
                        Core_Tasks_Generated__c, Core_Campaign_Priority__c
                    from Campaign where Id = :campId];
            
            // Pull all existing tasks for this Campaign, and their Account IDs, so we don't create
            // any duplicate tasks for any given Account
            List<Task> existingTasks = [select Id, Core_Account_ID__c from Task where WhatId = :campId];
            
            // Place all of the Account IDs in a set so we can check for existence
            Set<String> existingAccountIds = new Set<String>();
            for (Task t : existingTasks)
                existingAccountIds.add(t.Core_Account_ID__c);
            
            // Loop through the Campaign Members passed in. Only consider members who don't already have a task
            // for their account.
            List<CampaignMember> newCampMembers = new List<CampaignMember>();
            for (CampaignMember campMember : campMembers) {
                if (!existingAccountIds.contains((String) campMember.Contact.AccountId))
                    newCampMembers.add(campMember);
            }
            campMembers = newCampMembers;
        }
        
        // Set all of the variables we'll need for task creation
        campActivityTypesString = camp.Core_Activity_Types__c;
        campActivityTypes = campActivityTypesString.split(';');
            
        campPriority = camp.Core_Campaign_Priority__c;
        if (camp.Core_Campaign_Priority__c == null)
            campPriority = 'Normal';
        
        if (camp.Core_Call_Script__c == null) {
            callScriptApiName = null;
            taskDescription = '';
        }
        else {
            callScriptApiName = [select Core_API_Name__c from Core_Call_Script__c
                                 where Id = :camp.Core_Call_Script__c limit 1].Core_API_Name__c;
            taskDescription = Label.Core_Campaign_Task_Description;
        }
        
        taskRecordTypeId = [select Id from RecordType where DeveloperName = :Label.Core_Campaign_Task_Record_Type limit 1].Id;
        
        uncoveredAccountUserId = Label.Core_Uncovered_Account_ID;
        vendorSalesCenterUserId = Label.Core_Vendor_Sales_Center_ID;
        
        assignees = new Set<Id>();
        
        generatedTasks = new List<Task>();
        
        // Iterate through the activity types
        for (String activityType : campActivityTypes) {
            
            String taskSubject = camp.Name + ' - ' + activityType;
            
            // Iterate through the campaign members, building up our tasks to insert
            for (CampaignMember campMember : campMembers) {
                
                // Assign task owner based on whether or not there's a value in the alternate "Assigned to User ID" field
                Id taskOwnerId;
                if (campMember.Core_Assigned_To_User_ID__c != null) {
                    taskOwnerId = campMember.Core_Assigned_To_User_ID__c;
                }
                else {
                    // If not, owner should be the account owner unless it's uncovered or the generic VSC ID
                    taskOwnerId = campMember.Core_Account_Owner_ID__c;
                    if ((taskOwnerId == uncoveredAccountUserId) || (taskOwnerId == vendorSalesCenterUserId))
                        taskOwnerId = camp.OwnerId;
                }
                
                assignees.add(taskOwnerId);
                
                Task generatedTask = new Task(
                    RecordTypeId = taskRecordTypeId,
                    Subject = taskSubject,
                    Description = taskDescription,
                    OwnerId = taskOwnerId,
                    WhatId = camp.Id,
                    WhoId = campMember.ContactId,
                    Core_Account_ID__c = campMember.Contact.AccountId,
                    Core_Account_Name__c = campMember.Contact.Account.Name,
                    Status = Label.Core_Campaign_Task_Not_Started,
                    Priority = campPriority,
                    Core_Task_Type__c = Label.Core_Campaign_Task_Type,
                    Core_Activity_Type__c = activityType,
                    Core_Call_Script_ID__c = camp.Core_Call_Script__c,
                    Core_Call_Script_API_Name__c = callScriptApiName,
                    ActivityDate = camp.EndDate,
                    IsReminderSet = true,
                    ReminderDateTime = camp.EndDate.addDays(-7),
                    Core_Last_Touch_Marketing_Activity__c = campMember.Core_Last_Touch_Marketing_Activity__c);
                
                generatedTasks.add(generatedTask);
            }
        }
        
        // Perform the actual task insert
        insert generatedTasks;
        
        // Indicate that we've generated tasks for the Campaign, so we don't accidentally do it again
        camp.Core_Tasks_Generated__c = true;
        update camp;
    }
}