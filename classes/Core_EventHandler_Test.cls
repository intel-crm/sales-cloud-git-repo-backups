/************************************************************************************************************
Apex Class Name:  Core_EventHandler_Test
Version     : 1.0 
Created Date: 17 DEC 2014
Function    : Test class for "Core_Event" trigger, "Core_EvenHandler"Class and "Core_ActivityHandler"Class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kunal Mehta             17/12/2014              Original Version
* Harshith M L            17/12/2014              Original Version
*************************************************************************************************************/
@isTest
private class Core_EventHandler_Test {

    // List to store leads to be inserted
    Static List <lead> lstLeadInsertion;

    // List to store Events to be inserted
    Static List<Event> lstEventInsertion;


    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data ( Leads)
     * Return Type  : None
     * Parameter    : None
     */
    static void setupTestData() {
        // List to store trigger executions to be inserted
        List<Core_Trigger_Executions__c> lstTriggerExecution = new List<Core_Trigger_Executions__c>();

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

        // Inserting leads for testing
        lstLeadInsertion = new List<Lead>();
        lstLeadInsertion = Core_Test_Utility.createLead(200);
        insert lstLeadInsertion;
    }

    /*
     * Method name  : createEvents
     * Description  : Method to insert Events
     * Return Type  : None
     * Parameter    : None
     */
    static void createEvents() {
        // populating and inserting Events related to lead
        lstEventInsertion = new List<Event>();
        lstEventInsertion = Core_Test_Utility.createEvent(200);

        for (Integer i = 0; i < lstEventInsertion.size(); i++) {
            lstEventInsertion.get(i).whoId = lstLeadInsertion.get(i).Id;
        }
        insert lstEventInsertion;

        System.debug(lstEventInsertion);
    }




    /*
     * Method name  : changeRequestCreate
     * Description  : Testmethod method for testing "Core_Event" trigger, "Core_Event" trigger and "Core_Activity_Handler" Class
     * Return Type  : None
     * Parameter    : None
     */

    static testMethod void runTest() {
        // Setting up the environment for testing`
        System.runAs(Core_Test_Utility.systemAdminUser) {
            setupTestData();
        }

        Test.startTest();

        // inserting Events
        System.runAs(Core_Test_Utility.systemAdminUser) {
            createEvents();
        }

        // Fetching all the leads which were inserted with updated details
        List < Lead > lstLeadInserted = [SELECT Id, Core_Last_Activity_Date__c, (SELECT Id, LastModifiedDate From Events) FROM Lead];

        // Asserting lead's activity date is within 60 seconds of Events last modified date related to lead
        for (Lead leadInstance: lstLeadInserted) {
            System.debug('##### ' + Math.abs(leadInstance.Core_Last_Activity_Date__c.getTime() - leadInstance.Events.get(0).LastModifiedDate.getTime()));
            System.assert(Math.abs(leadInstance.Core_Last_Activity_Date__c.getTime() - leadInstance.Events.get(0).LastModifiedDate.getTime()) < (60*1000));
            // [DH 8/10/15] This assertion was failing because an exact match can't be expected when there is slight latency in the system
            //System.assertEquals(leadInstance.Core_Last_Activity_Date__c, leadInstance.Events.get(0).LastModifiedDate);
        }

        Core_ActivityHandler.blastActivityDateUpdateOnUpsert = true;

        // Creating Event instance
        Event EventInstance;

        // Updating Events related to leads
        for (Integer i = 0; i < lstEventInsertion.size(); i++) {
            EventInstance = (Event) lstEventInsertion.get(i);
            EventInstance.ActivityDate = System.Today().addDays(2);
        }

        System.runAs(Core_Test_Utility.systemAdminUser) {
            update lstEventInsertion;
        }

        // Fetching all the leads which were updated
        lstLeadInserted = [SELECT Id, Core_Last_Activity_Date__c, (SELECT Id, LastModifiedDate From Events) FROM Lead];

        // Asserting lead's activity date with Events last modified date related to lead
        for (Lead leadInstance: lstLeadInserted) {
            System.debug('##### ' + Math.abs(leadInstance.Core_Last_Activity_Date__c.getTime() - leadInstance.Events.get(0).LastModifiedDate.getTime()));
            System.assert(Math.abs(leadInstance.Core_Last_Activity_Date__c.getTime() - leadInstance.Events.get(0).LastModifiedDate.getTime()) < (60*1000));
            // [DH 8/10/15] This assertion was failing because an exact match can't be expected when there is slight latency in the system
            //System.assertEquals(leadInstance.Core_Last_Activity_Date__c, leadInstance.Events.get(0).LastModifiedDate);
        }

        // Deleting Events related to lead
        System.runAs(Core_Test_Utility.systemAdminUser) {
            delete lstEventInsertion;
        }    

        // Fetching all the leads which were updated
        lstLeadInserted = [SELECT Id, Core_Last_Activity_Date__c, (SELECT Id, LastModifiedDate From Events) FROM Lead];

        // Asserting lead's activity date with NUll since related Events were deleted
        for (Lead leadInstance: lstLeadInserted) {
            System.assertEquals(leadInstance.Core_Last_Activity_Date__c, NULL);
        }

        Test.stopTest();


    }
}