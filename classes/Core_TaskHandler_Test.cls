/***********************************************************************************************************
Apex Class Name:  Core_TaskHandler_Test
Version     : 1.0 
Created Date: 17 DEC 2014
Function    : Test class for "Core_Task" Trigger, "Core_TaskHandler" Class and "Core_ActivityHandler" Class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kunal Mehta             17/12/2014              Original Version
* Harshith M L            17/12/2014              Original Version
************************************************************************************************************/
@isTest
private class Core_TaskHandler_Test {

    // List to store leads to be inserted
    Static List<lead> lstLeadInsertion;

    // List to store tasks to be inserted
    Static List<Task> lstTaskInsertion;


    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data ( Leads)
     * Return Type  : None
     * Parameter    : None
     */
    static void setupTestData() {
        // List to store trigger executions to be inserted
        List<Core_Trigger_Executions__c> lstTriggerExecution = new List<Core_Trigger_Executions__c>();

        // Trigger execution instance for lastactivitydateupdate functionality
        Core_Trigger_Executions__c tasklastActivityUpdateOnLeadUpsert = new Core_Trigger_Executions__c();
        tasklastActivityUpdateOnLeadUpsert.name = 'tasklastActivityUpdateOnLeadUpsert';
        tasklastActivityUpdateOnLeadUpsert.Core_Object__c = 'Task';
        tasklastActivityUpdateOnLeadUpsert.Core_Trigger_Events__c = 'After insert';
        tasklastActivityUpdateOnLeadUpsert.Core_Active__c = TRUE;
        tasklastActivityUpdateOnLeadUpsert.Core_Description__c = 'This is test description';
        tasklastActivityUpdateOnLeadUpsert.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(tasklastActivityUpdateOnLeadUpsert);

        // Trigger execution instance for lastactivitydateupdate on lead delete functionality
        Core_Trigger_Executions__c tasklastActivityUpdateOnLeadDelete = new Core_Trigger_Executions__c();
        tasklastActivityUpdateOnLeadDelete.name = 'tasklastActivityUpdateOnLeadDelete';
        tasklastActivityUpdateOnLeadDelete.Core_Object__c = 'Task';
        tasklastActivityUpdateOnLeadDelete.Core_Trigger_Events__c = 'After insert';
        tasklastActivityUpdateOnLeadDelete.Core_Active__c = TRUE;
        tasklastActivityUpdateOnLeadDelete.Core_Description__c = 'This is test description';
        tasklastActivityUpdateOnLeadDelete.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(tasklastActivityUpdateOnLeadDelete);

        insert lstTriggerExecution;

        // Inserting leads for testing
        lstLeadInsertion = new List<Lead>();
        lstLeadInsertion = Core_Test_Utility.createLead(200);
        insert lstLeadInsertion;
    }

    /*
     * Method name  : createTasks
     * Description  : Method to insert Tasks
     * Return Type  : None
     * Parameter    : None
     */
    static void createTasks() {
        // populating and inserting tasks related to lead
        lstTaskInsertion = new List<Task>();
        lstTaskInsertion = Core_Test_Utility.createTask(200);

        for (Integer i = 0; i < lstTaskInsertion.size(); i++) {
            lstTaskInsertion.get(i).whoId = lstLeadInsertion.get(i).Id;
        }

        System.runAs(Core_Test_Utility.systemAdminUser) {            
            insert lstTaskInsertion;
        }
    }




    /*
     * Method name  : lastActivityDateUpdate
     * Description  : Testmethod method for testing "Core_Task" trigger, "Core_Event" trigger and "Core_Activity_Handler" Class
     * Return Type  : None
     * Parameter    : None
     */

    static testMethod void lastActivityDateUpdate() {
    
        // Setting up the environment for testing
        System.runAs(Core_Test_Utility.systemAdminUser) {
            setupTestData();
        }

        Test.startTest();

            // inserting tasks
            createTasks();
    
            // Fetching all the leads which were inserted with updated details
            List<Lead> lstLeadInserted = [SELECT Id, Core_Last_Activity_Date__c, (SELECT Id, LastModifiedDate From Tasks) FROM Lead];
    
            System.debug(lstLeadInserted);
    
            // Asserting lead's activity date is within 60 seconds of tasks last modified date related to lead
            for (Lead leadInstance: lstLeadInserted) {
                System.debug('##### ' + Math.abs(leadInstance.Core_Last_Activity_Date__c.getTime() - leadInstance.tasks.get(0).LastModifiedDate.getTime()));
                System.assert(Math.abs(leadInstance.Core_Last_Activity_Date__c.getTime() - leadInstance.tasks.get(0).LastModifiedDate.getTime()) < (60*1000));
                // [DH 8/10/15] This assertion was failing because an exact match can't be expected when there is slight latency in the system
                //System.assertEquals(leadInstance.Core_Last_Activity_Date__c, leadInstance.tasks.get(0).LastModifiedDate);
            }
    
            Core_ActivityHandler.blastActivityDateUpdateOnUpsert = true;
    
            // Creating task instance
            Task taskInstance;
    
            // Updating tasks related to leads
            for (Integer i = 0; i < lstTaskInsertion.size(); i++) {
                taskInstance = (Task) lstTaskInsertion.get(i);
                taskInstance.ActivityDate = System.Today().addDays(2);
            }
    
            System.runAs(Core_Test_Utility.systemAdminUser) {            
                update lstTaskInsertion;
            }    
    
            // Fetching all the leads which were updated
            lstLeadInserted = [SELECT Id, Core_Last_Activity_Date__c, (SELECT Id, LastModifiedDate From Tasks) FROM Lead];
    
            // Asserting lead's activity date with tasks last modified date related to lead
            for (Lead leadInstance: lstLeadInserted) {
                System.debug('##### ' + Math.abs(leadInstance.Core_Last_Activity_Date__c.getTime() - leadInstance.tasks.get(0).LastModifiedDate.getTime()));
                System.assert(Math.abs(leadInstance.Core_Last_Activity_Date__c.getTime() - leadInstance.tasks.get(0).LastModifiedDate.getTime()) < (60*1000));
                // [DH 8/10/15] This assertion was failing because an exact match can't be expected when there is slight latency in the system
                //System.assertEquals(leadInstance.Core_Last_Activity_Date__c, leadInstance.tasks.get(0).LastModifiedDate);
            }
    
            // Deleting tasks related to lead
            System.runAs(Core_Test_Utility.systemAdminUser) {            
                delete lstTaskInsertion;
            }
    
            Core_ActivityHandler.bLastActivityDateUpdateOnDelete = true;
    
            // Fetching all the leads which were updated
            lstLeadInserted = [SELECT Id, Core_Last_Activity_Date__c, (SELECT Id, LastModifiedDate From Tasks) FROM Lead];
    
            // Asserting lead's activity date with NUll since related tasks were deleted
            for (Lead leadInstance: lstLeadInserted) {
                System.assertEquals(leadInstance.Core_Last_Activity_Date__c, NULL);
            }

        Test.stopTest();


    }
}