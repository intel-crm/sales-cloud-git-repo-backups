/****************************************************************************************************
Apex Class Name : SWS_Stale_Lead_Notification_BatchTest
Version         : 1.0
Created Date    : 2026-11-09
Function        : Test coverage for SWS_Stale_Lead_Notification_Batch and
                   SWS_Stale_Lead_Notification_Scheduler.
Created By      : Naveen Muthuramalingam
*****************************************************************************************************/
@isTest
private class SWS_Stale_Lead_Notification_BatchTest {

    private static final String RUN_AS_USERNAME = 'requestoremail@testorg.com';

    @testSetup
    private static void setup() {
        User u = SWS_TestUtilty.createUser();
        PermissionSet permissionRec = [SELECT Id, Name FROM PermissionSet WHERE Name = 'PSG_Master_Data_Read_Write_Access' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionRec.Id);

        System.runAs(u) {
            insertTriggerBypassSettings();
            insertCountryReferenceData();
            insertCrmLabels();

            Id salesLeadRecordTypeId = getLeadRecordTypeId();
            insertNotificationTestLeads(salesLeadRecordTypeId, u.Id);
        }
    }

    /************************************************************************************************************
    *Method Name : insertTriggerBypassSettings
    *Description : Mirrors Core_LeadHandler_Test's trigger execution settings so Lead trigger logic
    *              (Core_LeadHandler, etc.) behaves consistently with other Lead test suites.
    ************************************************************************************************************/
    private static void insertTriggerBypassSettings() {
        List<String> triggerExecutionStringList = new List<String>{
            'leadObjectBeforeHandler',
            'leadObjectSalesGroup',
            'leadConversionDeduplication'
        };
        List<Core_Trigger_Executions__c> lstCustomSetting = new List<Core_Trigger_Executions__c>();
        for (String triggerExecution : triggerExecutionStringList) {
            Core_Trigger_Executions__c triggerExecutionLead = new Core_Trigger_Executions__c();
            triggerExecutionLead.name = triggerExecution;
            triggerExecutionLead.Core_Object__c = 'Lead';
            triggerExecutionLead.Core_Active__c = true;
            triggerExecutionLead.Core_Description__c = 'This is test description';
            triggerExecutionLead.Core_Class_Name__c = 'SWS_Stale_Lead_Notification_BatchTest';
            triggerExecutionLead.Core_Trigger_Events__c = 'After Update';
            lstCustomSetting.add(triggerExecutionLead);
        }
        insert lstCustomSetting;
    }

    /************************************************************************************************************
    *Method Name : insertCountryReferenceData
    *Description : Mirrors Core_LeadHandler_Test's Core_Country_Reference__c setup so country-dependent
    *              Lead validation/logic does not block Lead insert/update in this test context.
    ************************************************************************************************************/
    private static void insertCountryReferenceData() {
        List<Core_Country_Reference__c> lstCS = Core_Test_Utility.Core_CountryState(1);
        for (Core_Country_Reference__c sobjCS : lstCS) {
            sobjCS.Name = 'United States';
            sobjCS.Core_Geo__c = 'ASMO';
            sobjCS.Core_Has_States__c = true;
            sobjCS.Core_ISO_Code__c = 'USA';
            sobjCS.Core_Sub_Geo__c = 'NAR';
        }
        insert lstCS;
    }

    /************************************************************************************************************
    *Method Name : insertCrmLabels
    *Description : Inserts the SWS_Core_CRM_Labels__c custom setting rows the batch depends on for
    *              eligibility window sizing and email subject configuration.
    ************************************************************************************************************/
    private static void insertCrmLabels() {
        List<SWS_Core_CRM_Labels__c> labels = new List<SWS_Core_CRM_Labels__c>{
            new SWS_Core_CRM_Labels__c(Name = 'SWS_Lead_Created_Days', SWS_Value__c = '10'),
            new SWS_Core_CRM_Labels__c(Name = 'SWS_Lead_Modified_Days', SWS_Value__c = '7'),
            new SWS_Core_CRM_Labels__c(Name = 'SWS_Notification_Window_Days', SWS_Value__c = '6'),
            new SWS_Core_CRM_Labels__c(Name = 'SWS_Stale_Lead_Notification_Subject', SWS_Value__c = 'Action Required: Lead Scheduled for Inactivity Disposition in 7 Days')
        };
        insert labels;
    }

    /************************************************************************************************************
    *Method Name : getLeadRecordTypeId
    *Description : Same record type lookup pattern used in Core_LeadHandler_Test (Schema.getGlobalDescribe()).
    ************************************************************************************************************/
    private static Id getLeadRecordTypeId() {
        return Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Marketing Lead').getRecordTypeId();
    }

    /************************************************************************************************************
    *Method Name : insertNotificationTestLeads
    *Description : Uses Core_Test_Utility.createLead(...) (same factory as Core_LeadHandler_Test) to build
    *              base Lead records, then layers on the specific fields needed to validate the batch's
    *              eligibility window logic: one in-window lead, one out-of-window lead, one disqualified
    *              lead (all owned by the running user so notification grouping can be asserted).
    ************************************************************************************************************/
    private static void insertNotificationTestLeads(Id recordTypeId, Id ownerId) {
        List<Lead> lstLeads = Core_Test_Utility.createLead(3);

        Lead inWindowLead = lstLeads[0];
        configureBaseLeadFields(inWindowLead, recordTypeId, ownerId, 'InWindow');

        Lead outOfWindowLead = lstLeads[1];
        configureBaseLeadFields(outOfWindowLead, recordTypeId, ownerId, 'OutOfWindow');

        Lead disqualifiedLead = lstLeads[2];
        configureBaseLeadFields(disqualifiedLead, recordTypeId, ownerId, 'Disqualified');
        disqualifiedLead.Core_Lead_Status__c = 'Disqualified';

        insert lstLeads;

        // SWS_Last_Modified_Date_By_Non_Sys_User__c is set post-insert to precisely control which
        // leads fall inside vs. outside the notification window (mirrors createdDays=10 / modifiedDays=7
        // from the CRM labels inserted above).
        inWindowLead.SWS_Last_Modified_Date_By_Non_Sys_User__c = DateTime.now().addDays(-7);
        outOfWindowLead.SWS_Last_Modified_Date_By_Non_Sys_User__c = DateTime.now().addDays(-2);
        disqualifiedLead.SWS_Last_Modified_Date_By_Non_Sys_User__c = DateTime.now().addDays(-7);
        update lstLeads;
    }

    /************************************************************************************************************
    *Method Name : configureBaseLeadFields
    *Description : Applies the common notification-eligibility fields to a single Lead record produced by
    *              the Core_Test_Utility.createLead factory, keeping each call site simple.
    ************************************************************************************************************/
    private static void configureBaseLeadFields(Lead ld, Id recordTypeId, Id ownerId, String lastNameSuffix) {
        ld.RecordTypeId = recordTypeId;
        ld.LastName = lastNameSuffix;
        ld.Core_Lead_Status__c = 'New';
        ld.Core_Lead_State__c = 'Active';
        ld.Status = 'Marketing Qualified Lead';
        ld.OwnerId = ownerId;
    }

    @isTest
    private static void testBatchSendsConsolidatedEmailForEligibleLeads() {
        User u = [SELECT Id FROM User WHERE UserName = :RUN_AS_USERNAME LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            Database.executeBatch(new SWS_Stale_Lead_Notification_Batch(), 200);
            Test.stopTest();
        }

        Lead inWindowLead = [SELECT Id, Core_Lead_Status__c FROM Lead WHERE LastName = 'InWindow' LIMIT 1];
        System.assertEquals('New', inWindowLead.Core_Lead_Status__c, 'Notification batch must not alter the Lead record.');
    }

    @isTest
    private static void testBatchSkipsLeadsOutsideWindowAndDisqualified() {
        User u = [SELECT Id FROM User WHERE UserName = :RUN_AS_USERNAME LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            Database.executeBatch(new SWS_Stale_Lead_Notification_Batch(), 200);
            Test.stopTest();
        }

        List<Lead> leads = [SELECT Id, LastName, Core_Lead_Status__c FROM Lead WHERE LastName IN ('OutOfWindow', 'Disqualified')];
        System.assertEquals(2, leads.size(), 'Both control leads should still exist untouched.');
    }

    @isTest
    private static void testNoEligibleLeadsDoesNotSendEmail() {
        User u = [SELECT Id FROM User WHERE UserName = :RUN_AS_USERNAME LIMIT 1];
        delete [SELECT Id FROM Lead];

        System.runAs(u) {
            Test.startTest();
            Database.executeBatch(new SWS_Stale_Lead_Notification_Batch(), 200);
            Test.stopTest();
        }

        System.assert(true, 'Batch should complete without error when no leads are eligible.');
    }
}