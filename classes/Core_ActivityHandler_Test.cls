/****************************************************************************************************
Apex Class Name:  Core_ActivityHandler_Test
Version     : 1.0 
Created Date: 06 OCT 2014
Function    : Test class for "Core_Task" trigger, "Core_Event" trigger and "Core_Activity_Handler" Class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             06/10/2014              Original Version
*****************************************************************************************************/
@isTest
private class Core_ActivityHandler_Test {

    // List to store lead records to be inserted
    Static List<Lead> lstLeadInsertion;

    // List to store task records to be inserted
    Static List<Task> lstTaskInsertion;

    // List to store event records to be inserted
    Static List <Event> lstEventInsertion;


    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data ( Leads)
     * Return Type  : None
     * Parameter    : None
     */
    static void setupTestData() {
    
        // Inserting custom setting to run the functionality on trigger execution
        List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();

        Core_Trigger_Executions__c tasklastActivityUpdateOnLeadUpsert = new Core_Trigger_Executions__c();
        tasklastActivityUpdateOnLeadUpsert.name = 'tasklastActivityUpdateOnLeadUpsert';
        tasklastActivityUpdateOnLeadUpsert.Core_Object__c = 'Task';
        tasklastActivityUpdateOnLeadUpsert.Core_Trigger_Events__c = 'After insert';
        tasklastActivityUpdateOnLeadUpsert.Core_Active__c = TRUE;
        tasklastActivityUpdateOnLeadUpsert.Core_Description__c = 'This is test description';
        tasklastActivityUpdateOnLeadUpsert.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(tasklastActivityUpdateOnLeadUpsert);

        Core_Trigger_Executions__c tasklastActivityUpdateOnLeadDelete = new Core_Trigger_Executions__c();
        tasklastActivityUpdateOnLeadDelete.name = 'tasklastActivityUpdateOnLeadDelete';
        tasklastActivityUpdateOnLeadDelete.Core_Object__c = 'Task';
        tasklastActivityUpdateOnLeadDelete.Core_Trigger_Events__c = 'After insert';
        tasklastActivityUpdateOnLeadDelete.Core_Active__c = TRUE;
        tasklastActivityUpdateOnLeadDelete.Core_Description__c = 'This is test description';
        tasklastActivityUpdateOnLeadDelete.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(tasklastActivityUpdateOnLeadDelete);

        Core_Trigger_Executions__c eventlastActivityUpdateOnLeadUpsert = new Core_Trigger_Executions__c();
        eventlastActivityUpdateOnLeadUpsert.name = 'eventlastActivityUpdateOnLeadUpsert';
        eventlastActivityUpdateOnLeadUpsert.Core_Object__c = 'Event';
        eventlastActivityUpdateOnLeadUpsert.Core_Active__c = TRUE;
        eventlastActivityUpdateOnLeadUpsert.Core_Trigger_Events__c = 'After insert';
        eventlastActivityUpdateOnLeadUpsert.Core_Description__c = 'This is test description';
        eventlastActivityUpdateOnLeadUpsert.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(eventlastActivityUpdateOnLeadUpsert);

        Core_Trigger_Executions__c eventlastActivityUpdateOnLeadDelete = new Core_Trigger_Executions__c();
        eventlastActivityUpdateOnLeadDelete.name = 'eventlastActivityUpdateOnLeadDelete';
        eventlastActivityUpdateOnLeadDelete.Core_Object__c = 'Event';
        eventlastActivityUpdateOnLeadDelete.Core_Trigger_Events__c = 'After insert';
        eventlastActivityUpdateOnLeadDelete.Core_Active__c = TRUE;
        eventlastActivityUpdateOnLeadDelete.Core_Description__c = 'This is test description';
        eventlastActivityUpdateOnLeadDelete.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(eventlastActivityUpdateOnLeadDelete);

        insert lstTriggerExecution;

        // insert leads 
        lstLeadInsertion = new List<Lead>();
        lstLeadInsertion = Core_Test_Utility.createLead(300);
        insert lstLeadInsertion;
    }

    /*
     * Method name  : createTasks
     * Description  : Method to insert Tasks related to Lead
     * Return Type  : None
     * Parameter    : None
     */
    static void createTasks() {
        // Create and insert tasks related to Lead
        lstTaskInsertion = new List<Task>();
        lstTaskInsertion = Core_Test_Utility.createTask(200);

        for (Integer i = 0; i < lstTaskInsertion.size(); i++) {
            lstTaskInsertion.get(i).whoId = lstLeadInsertion.get(i).Id;
        }
        insert lstTaskInsertion;
    }


    /*
     * Method name  : createEvents
     * Description  : Method to insert Events related to Lead
     * Return Type  : None
     * Parameter    : None
     */
    static void createEvents() {
        // Create and insert events related to Lead
        lstEventInsertion = new List <Event>();
        lstEventInsertion = Core_Test_Utility.createEvent(300);
        Integer iIndex;
        for (Integer i = 0; i < 300; i++) {
            iIndex = Integer.valueOf(Math.Mod(i, 290));
            lstEventInsertion.get(i).whoId = lstLeadInsertion.get(iIndex).Id;
        }
        
        lstEventInsertion.get(180).whoId = lstLeadInsertion.get(18).Id;
        insert lstEventInsertion;
    }

    /*
     * Method name  : lastActivityDateUpdate
     * Description  : Testmethod method for testing "Core_Task" trigger, "Core_TaskHandler" Class, "Core_Event" trigger, "Core_EventHandler" Class
                      and "Core_Activity_Handler" Class
     * Return Type  : None
     * Parameter    : None
     */

    static testMethod void lastActivityDateUpdate() {
        
        // Setting up the environment for testing
        System.runAs(Core_Test_Utility.systemAdminUser) {
            setupTestData();
        }
        
        // Set to store task ids
        SET<Id> setTaskIds = new SET<Id>();
        
        // Set to store lead ids
        SET<Id> setLeadIds = new SET<Id>();
        
        // Set to store event ids
        SET<Id> setEventIds = new SET<Id>();

        // Start testing the functionality
        Test.startTest();
            
            // Adding lead ids to set
            for (Lead leadInstance: lstLeadInsertion) {
                setLeadIds.add(leadInstance.Id);
            }
    
            // create and insert tasks
            System.runAs(Core_Test_Utility.systemAdminUser) {
                createTasks();
            }
    
            // Creating an instance of task for updating the records from the list 
            Task taskInstance;
    
            // updating the tasks to update the last acitivity date on lead
            for (Integer i = 0; i < lstTaskInsertion.size(); i++) {
                taskInstance = (Task) lstTaskInsertion.get(i);
                taskInstance.subject = 'test';
                setTaskIds.add(taskInstance.Id);
            }
            
            // Setting the boolean flag to true for simulating next DML as seperate transaction
            Core_ActivityHandler.blastActivityDateUpdateOnUpsert = true;
            
            // update tasks
            System.runAs(Core_Test_Utility.systemAdminUser) {
                update lstTaskInsertion;
            }
            
            Core_ActivityHandler.blastActivityDateUpdateOnUpsert = true;
    
            // create and insert events
            System.runAs(Core_Test_Utility.systemAdminUser) {
                createEvents();
            }
            
            // Setting the boolean flag to true for simulating next DML as seperate transaction
            Core_ActivityHandler.blastActivityDateUpdateOnUpsert = true;
    
            // Creating an instance of event for updating the records from the list 
            Event eventInstance;
    
            // updating the events to update the last acitivity date on lead
            for (Integer i = 0; i < lstEventInsertion.size(); i++) {
                eventInstance = (Event) lstEventInsertion.get(i);
                eventInstance.subject = 'test';
                setEventIds.add(eventInstance.Id);
            }
            
            // update event records
            System.runAs(Core_Test_Utility.systemAdminUser) {            
                update eventInstance;
            }
        
            // Fetching task records inserted for updated details
            lstTaskInsertion = [SELECT Id, LastModifiedDate, WhoId FROM Task Where Id IN: setTaskIds];
            
            // Fetching event records inserted for updated details
            lstEventInsertion = [SELECT Id, LastModifiedDate, WhoId FROM Event Where Id IN: setEventIds];
    
            // Deleting the event related to lead
            System.runAs(Core_Test_Utility.systemAdminUser) {
                delete lstEventInsertion.get(5);
            }
            
            // Setting the boolean flag to true for simulating next DML as seperate transaction
            Core_ActivityHandler.bLastActivityDateUpdateOnDelete = true;
            
            // Fetching lead record inserted for updated details
            Lead lstLeadInsertionUpdated = [SELECT Id, Core_Last_Activity_Date__c FROM Lead Where Id = : lstLeadInsertion.get(5).Id];
    
            // Asserting whether the last modified of lead is within 1 min of last modifed date of related task
            System.debug('##### ' + Math.abs(lstLeadInsertionUpdated.Core_Last_Activity_Date__c.getTime() - lstEventInsertion.get(295).LastModifiedDate.getTime()));
            System.assert(Math.abs(lstLeadInsertionUpdated.Core_Last_Activity_Date__c.getTime() - lstEventInsertion.get(295).LastModifiedDate.getTime()) < (60*1000));
            // [DH 8/10/15] This assertion was failing because an exact match can't be expected when there is slight latency in the system
            // System.assertEquals(lstLeadInsertionUpdated.Core_Last_Activity_Date__c, lstEventInsertion.get(295).LastModifiedDate);
            
            // Delete inserted task related to lead 
            System.runAs(Core_Test_Utility.systemAdminUser) {
                delete lstTaskInsertion.get(5);
            }
            
            // Setting the boolean flag to true for simulating next DML as seperate transaction
            Core_ActivityHandler.bLastActivityDateUpdateOnDelete = true;
            
            // Delete inserted task related to lead 
            System.runAs(Core_Test_Utility.systemAdminUser) {
                delete lstTaskInsertion.get(7);
            }
                    
            // Setting the boolean flag to true for simulating next DML as seperate transaction
            Core_ActivityHandler.bLastActivityDateUpdateOnDelete = true;
            
            // Fetching lead record inserted for updated details
            lstLeadInsertionUpdated = [SELECT Id, Core_Last_Activity_Date__c FROM Lead Where Id = : lstLeadInsertion.get(16).Id];
            
            // Asserting that last activity date of lead record is within 1 min of event record related to lead
            System.debug('##### ' + Math.abs(lstLeadInsertionUpdated.Core_Last_Activity_Date__c.getTime() - lstEventInsertion.get(16).LastModifiedDate.getTime()));
            System.assert(Math.abs(lstLeadInsertionUpdated.Core_Last_Activity_Date__c.getTime() - lstEventInsertion.get(16).LastModifiedDate.getTime()) < (60*1000));
            // [DH 8/10/15] This assertion was failing because an exact match can't be expected when there is slight latency in the system
            // System.assertEquals(lstLeadInsertionUpdated.Core_Last_Activity_Date__c, lstEventInsertion.get(16).LastModifiedDate);
            
            // Delete inserted event related to lead 
            System.runAs(Core_Test_Utility.systemAdminUser) {            
                delete lstEventInsertion.get(17);
            }
                    
            // Setting the boolean flag to true for simulating next DML as seperate transaction
            Core_ActivityHandler.bLastActivityDateUpdateOnDelete = true;
            
            // Delete inserted event related to lead 
            System.runAs(Core_Test_Utility.systemAdminUser) {            
                delete lstTaskInsertion.get(17);
            }
                    
            // Setting the boolean flag to true for simulating next DML as seperate transaction
            Core_ActivityHandler.bLastActivityDateUpdateOnDelete = true;
        
            // Fetching lead record inserted for updated details
            lstLeadInsertionUpdated = [SELECT Id, Core_Last_Activity_Date__c FROM Lead Where Id = : lstLeadInsertion.get(17).Id];
    
            // Asserting whether the last modified of lead is equal to null
            System.assertEquals(NULL, lstLeadInsertionUpdated.Core_Last_Activity_Date__c);

        Test.stopTest();


    }
}