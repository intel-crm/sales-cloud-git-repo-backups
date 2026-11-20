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
    Static List<Task> lstoldTaskInsertion;


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
       // lstLeadInsertion = Core_Test_Utility.createLead(200);
       lstLeadInsertion = [Select id from lead limit 1];
        //insert lstLeadInsertion;
    }

    /*
     * Method name  : createTasks
     * Description  : Method to insert Tasks
     * Return Type  : None
     * Parameter    : None
     */
    
     
    static void createTasks() {
        Lead l= new lead();
        // populating and inserting tasks related to lead
        lstTaskInsertion = new List<Task>();
        lstoldTaskInsertion = new List<Task>();
        //lstTaskInsertion = Core_Test_Utility.createTask(200);
        Task taskInstance = new Task();
            taskInstance.ActivityDate = System.Today().addDays(1);
            taskInstance.Priority = 'Medium';
            taskInstance.status = 'Pending';
            taskInstance.Subject = 'Email';
      // l=[Select id from lead limit 1];
	  
	  
        String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
        
              Lead leadInstance = new Lead();
        leadInstance.FirstName = 'Test 123';
        
        leadInstance.lastName = 'CS';
        leadInstance.Company = 'XYZ';
        leadInstance.CountryCode = 'USA';
        leadInstance.StateCode = 'AL';
        leadInstance.City = 'Alabama';
        leadInstance.Street = 'test';
        leadInstance.status = 'Sales Generated Lead';
        leadInstance.leadSource = 'Email';
        leadInstance.email = 'test@infosys.com';
        leadInstance.Core_Last_Activity_Date__c = NULL;
        leadInstance.Core_Lead_Status__c='Accepted';
        leadInstance.PostalCode = '577101';
        leadInstance.Title = 'Hello';
        leadInstance.Core_Current_Architecture__c='Test';
        leadInstance.Phone='9777787888';
        leadInstance.Core_Product_Interest__c='10';
        leadInstance.Core_Project_Phase__c='testing';
        leadInstance.Core_Project_Size__c='4';
        leadInstance.Core_Project_Timeframe__c='12-24 Months';
        leadInstance.Core_Lead_State__c = 'In Pursuit';
        leadInstance.recordtypeid = RId ;  
        leadInstance.Core_Job_Function__c = 'Branch Manager';
        
        insert leadInstance;
           taskInstance.WhoId = leadInstance.id;
            
        system.debug('lead id'+l.Id);

            lstTaskInsertion.add(taskInstance);
        lstoldTaskInsertion.add(taskInstance);
        insert lstTaskInsertion;
        
        /*Core_TaskHandler.updatetaskflag(lstTaskInsertion);
        update lstoldTaskInsertion;
         Core_TaskHandler.UpdateTaskflagOnUpdate(lstTaskInsertion,lstoldTaskInsertion);*/

    }

 static void createTasks1() {
        Lead l= new lead();
        // populating and inserting tasks related to lead
        lstTaskInsertion = new List<Task>();
        lstoldTaskInsertion = new List<Task>();
        Task taskInstance = new Task();
            taskInstance.ActivityDate = System.Today().addDays(1);
            taskInstance.Priority = 'Medium';
            taskInstance.status = 'Pending';
            taskInstance.Subject = 'Meeting';
	  
	  
        String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
        
              Lead leadInstance = new Lead();
        leadInstance.FirstName = 'T 123';
        
        leadInstance.lastName = 'CS123';
        leadInstance.Company = 'XYZ123';
        leadInstance.CountryCode = 'USA';
        leadInstance.StateCode = 'AL';
        leadInstance.City = 'Alabam11a';
        leadInstance.Street = 'test1';
        leadInstance.status = 'Sales Generated Lead';
        leadInstance.leadSource = 'Email';
        leadInstance.email = 'testhjjhh@infosys.com';
        leadInstance.Core_Last_Activity_Date__c = NULL;
        leadInstance.Core_Lead_Status__c='Accepted';
        leadInstance.PostalCode = '577107';
        leadInstance.Title = 'Hello';
        leadInstance.Core_Current_Architecture__c='Test';
        leadInstance.Phone='9777787866';
        leadInstance.Core_Product_Interest__c='10';
        leadInstance.Core_Project_Phase__c='testing';
        leadInstance.Core_Project_Size__c='4';
        leadInstance.Core_Project_Timeframe__c='12-24 Months';
        leadInstance.Core_Lead_State__c = 'In Pursuit';
        leadInstance.recordtypeid = RId ;  
		leadInstance.Core_Job_Function__c = 'Branch Manager';
        
        insert leadInstance;
        taskInstance.WhoId = leadInstance.id;
            
        lstTaskInsertion.add(taskInstance);
        lstoldTaskInsertion.add(taskInstance);
        insert lstTaskInsertion;
        
       /* Core_TaskHandler.updatetaskflag(lstTaskInsertion);
        update lstoldTaskInsertion;
         Core_TaskHandler.UpdateTaskflagOnUpdate(lstTaskInsertion,lstoldTaskInsertion);*/
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
          createTasks1();
    
            // Fetching all the leads which were inserted with updated details
            List<Lead> lstLeadInserted = [SELECT Id, Core_Last_Activity_Date__c, (SELECT Id, LastModifiedDate From Tasks) FROM Lead];
    
            System.debug(lstLeadInserted);
   
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
    
               // Deleting tasks related to lead
            System.runAs(Core_Test_Utility.systemAdminUser) {            
                delete lstTaskInsertion;
            }
    
            Core_ActivityHandler.bLastActivityDateUpdateOnDelete = true;
        System.assertEquals('true', String.valueOf(Core_ActivityHandler.bLastActivityDateUpdateOnDelete));
    
        Test.stopTest();


    }
}