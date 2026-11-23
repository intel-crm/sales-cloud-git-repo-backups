/***************************************************************************************************
Class Name:  Core_IPS_CalcDurationsHandler_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 10 Jun 2019
Function    : This class contains test coverage for Core_IPS_Calc_Durations_Trigger_Handler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Calc_Durations_Trigger_Handler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sneha       10/06/2019                 Created
****************************************************************************************************/
@isTest
public class Core_IPS_CalcDurationsHandler_Test {
    
    static List<User> ListOfUser = new List<User> ();
    static Group grp = new Group();
    static Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
    static  Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
    
    /***************************************************************************************************
    Method Name:  getRecords()
    Method Type: void
    Version     : 1.0 
    Created Date: 16 Jun 2019
    Description:  Common Test data used for all test methods
    ****************************************************************************************************/
      static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.runAs(ListOfUser.get(0)){
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            //Create Group Members
            List<GroupMember> ListGM = new List<GroupMember>();
            for(User usr:ListOfUser){
                GroupMember GM = new GroupMember();
                GM.GroupId = grp.Id;
                GM.UserOrGroupId = usr.Id;
                ListGM.add(GM);
            }
            //insert Group Memebers
            if(!ListGM.isEmpty()){
                insert ListGM;
            }
            List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
            insert ListofIpsLables;
            System.assert(ListofIpsLables[0].Id != null, 'Records not created');
            //Custom Setting - Ips Error Codes
            List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
            insert ListofIpsErrorCodes;
            System.assert(ListofIpsErrorCodes[0].Id != null, 'Records not created');
            //Custom Setting - Trigger Executions
            List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
            insert ListOfTriggerExecutions;
            System.assert(ListOfTriggerExecutions[0].Id != null, 'Records not created');
            
                    }
    }
    
    /* 
     * The STOWD package runs on every After Update and has it's own private logic on
     * when to create a STOWD record.  It is difficult to determine a scenario where the number
     * of STOWD records and the field values will stable as the system evolves.  Therefore, 
     * this test class only considers code coverage and does not have a negative test.
    */   
    //test the main method.  It is not possible to test where the feature toggle is off.  The package must run from a trigger.
    testmethod public static void test_calcDurations() {          
       /*    getRecords();
     System.runAs(ListOfUser.get(0)){
            Test.startTest();
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            insert ListOfCases;
            for(Case CaseRec : ListOfCases){
                CaseRec.OwnerId = ListOfUser.get(0).Id;
                CaseRec.Status = 'Open';
                CaseRec.core_sub_status__c= 'Waiting for Customer';
            }
                        Core_CaseTrigger_Dispatcher.triggerAssignmentRule=true;

            update ListOfCases;

            Test.stopTest();
        }*/
        
        
        List<Case> caseList = new List<Case>();
         
        Account acct =  new Account();
        Contact con =  new Contact();
        Entitlement ent = new Entitlement();
        acct = TestUtilities.getAccountRecord();
        acct.Core_CNDA_Number__c ='1691';
        insert acct;
         
        Contact contactRecord;
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acct.id;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'runTestClass@test.com';
        insert contactRecord;
        
        //Custom Setting - Trigger Executions
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        TriggerExecution.Name = 'insertCommentUSAMinds';
        TriggerExecution.Core_Active__c = true;
        TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        TriggerExecution.Core_Description__c = 'Used for adding Private to Intel comment for USA-Minds cases';
        TriggerExecution.Core_Object__c = 'Case';
        TriggerExecution.Core_Trigger_Events__c = 'after insert';
        insert TriggerExecution;   
        
        
        //Custom Setting - Trigger Executions
        Core_Trigger_Executions__c  TriggerExecution2 = new Core_Trigger_Executions__c();
        TriggerExecution2.Name = 'calcDurations';
        TriggerExecution2.Core_Active__c = true;
        TriggerExecution2.Core_Class_Name__c ='Core_IPS_Calc_Durations_Trigger_Handler';
        TriggerExecution2.Core_Description__c = 'Used for adding Private to Intel comment for USA-Minds cases when Updated';
        TriggerExecution2.Core_Object__c = 'Case';
        TriggerExecution2.Core_Trigger_Events__c = 'After update';
        insert TriggerExecution2;  
        Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
        TriggerExecution1.Name = 'UpdateCommentUSAMinds';
        TriggerExecution1.Core_Active__c = true;
        TriggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        TriggerExecution1.Core_Description__c = 'Used for adding Private to Intel comment for USA-Minds cases when Updated';
        TriggerExecution1.Core_Object__c = 'Case';
        TriggerExecution1.Core_Trigger_Events__c = 'after update';
        insert TriggerExecution1;   
       
        List<Core_IPS_Labels__c> ListofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables0 = new Core_IPS_Labels__c(Name = 'PRIVATE_TO_INTEL',Value__c = 'Private to Intel');
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'USA',Value__c = 'United States');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Core_IPS_USAMinds_Comment',Value__c = 'By working this case, you are agreeing to comply with regulatory requirements here: <a href = "http://goto.intel.com/mindsipsguardrails">http://goto.intel.com/mindsipsguardrails</a> ');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Core_IPS_USAMindsComment_Author',Value__c = '005o0000001g5FC');
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Agent',Value__c = 'Agent');
        Core_IPS_Labels__c ipsLables5 = new Core_IPS_Labels__c(Name = 'GEC_Status_Approved_WithG',Value__c = 'Approved with Guardrails');
        ListofIpsLables.add(ipsLables0);
        ListofIpsLables.add(ipsLables1);
        ListofIpsLables.add(ipsLables2);
        ListofIpsLables.add(ipsLables3); 
        ListofIpsLables.add(ipsLables4);
        ListofIpsLables.add(ipsLables5);
       
        insert ListofIpsLables;
               
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
        Case c= new case(recordtypeId=devRecordTypeId,contactId=contactRecord.id,subject='testing case', Type='Test case', Origin='phone', Reason='Testing',Status='new',Priority='high',Core_Severity__c='1234',Core_IPS_Minds__c=true,Core_IPS_Country_Region__c = 'United States',Core_IPS_GEC_Status__c = 'Approved with Guardrails');
      
        caseList.add(c);
        insert caseList;
                    Core_CaseTrigger_Dispatcher.recursivetrigger1=true;            
            Core_CaseTrigger_Dispatcher.updatestowd=true;            

        caseList[0].Status = 'Open';
                caseList[0].core_sub_status__c= 'Waiting for Customer';
                update caseList[0];
                                caseList[0].Core_IPS_Assigned_Queue__c ='new queue';
update caseList[0];
 //   Core_IPS_Calc_Durations_Trigger_Handler.calcDurations(caseList);

     
    }   
    /* 
     * The STOWD package runs on every After Update and has it's own private logic on
     * when to create a STOWD record.  It is difficult to determine a scenario where the number
     * of STOWD records and the field values will stable as the system evolves.  Therefore, 
     * this test class only considers code coverage and does not have a negative test.
    */ 
    testmethod public static void test_calcDurations_forceException() {
        //When called from a trigger, Trigger.New should always be passed.
        //But, call from test class without it will generate an exception.
    Core_IPS_Calc_Durations_Trigger_Handler.calcDurations(null);
    }
}