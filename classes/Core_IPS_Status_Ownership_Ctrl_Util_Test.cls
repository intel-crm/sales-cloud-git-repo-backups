/***************************************************************************************************
* @Name Core_IPS_Status_Ownership_Ctrl_Util
* @Test Class Name : Core_IPS_Status_Ownership_Ctrl_Util_Test
* @ Description : This class is being used for creating the Status & Ownership Duration records(STOWD).
* @User Story - TWC777-2882
* @Created Date 25/11/2024 
* @Author: Accellor
***************************************************************************************************/

@isTest
public class Core_IPS_Status_Ownership_Ctrl_Util_Test {
    
    //Added by Vishal As part Of STOWD implementation -TWC777-2514 - 08/08/2024
    
    @isTest
    static void handleBeforeUpdateSTOWDTest() {
        
        Core_Trigger_Executions__c triggerExecutionObj =new Core_Trigger_Executions__c();
        triggerExecutionObj.Name='isCustomSTOWDEnabled';
        triggerExecutionObj.Core_Active__c=true;
        triggerExecutionObj.Core_Class_Name__c='ICS_Status_Ownership_Ctrl_Util';
        triggerExecutionObj.Core_Object__c='Case';
        triggerExecutionObj.Core_Description__c='Use to Enable and Disable the STOWD Custom Logic';
        triggerExecutionObj.Core_Trigger_Events__c='before update';
        insert triggerExecutionObj;
        
        
        Map<String, STOWD_Tracking_Field__mdt> metadataMap = new Map<String, STOWD_Tracking_Field__mdt>(
            [SELECT MasterLabel, IsActive__c, FieldType__c, RecordType__c 
             FROM STOWD_Tracking_Field__mdt]
        );
        
        String recordTypeName = 'IPS_Closed_Case';
        RecordType caseRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = :recordTypeName LIMIT 1];
        System.assertNotEquals(null, caseRecordType, 'Expected a record type with DeveloperName = ' + recordTypeName);
        
        Case oldCase = new Case(
            RecordTypeId = caseRecordType.Id,
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Core_IPS_Escalated_Level__c = 'Level 1 / Front Line',
            Core_Sub_Status__c = 'Fixed',
            Core_IPS_Assigned_Queue__c = 'Channel Sustaining_ISVC'
        );
        insert oldCase;
        
        List<Case> cases = [SELECT Id, Status, OwnerId, Core_IPS_Escalated_Level__c, Core_Sub_Status__c, Core_IPS_Assigned_Queue__c FROM Case];
        
        Map<Id, Case> oldCaseMap = new Map<Id, Case>(cases);
        
        for (Case caseRec : cases) {
            caseRec.Status = 'In Progress'; 
            caseRec.Core_IPS_Assigned_Queue__c = 'Queue 1';
            
        }
        
        Test.startTest();
        Core_IPS_Status_Ownership_Ctrl_Util.handleBeforeUpdate(cases, oldCaseMap);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void testCreateStatusOwnershipRecord() {
        Core_Trigger_Executions__c triggerExecutionObj =new Core_Trigger_Executions__c();
        triggerExecutionObj.Name='isCustomSTOWDEnabled';
        triggerExecutionObj.Core_Active__c=true;
        triggerExecutionObj.Core_Class_Name__c='ICS_Status_Ownership_Ctrl_Util';
        triggerExecutionObj.Core_Object__c='Case';
        triggerExecutionObj.Core_Description__c='Use to Enable and Disable the STOWD Custom Logic';
        triggerExecutionObj.Core_Trigger_Events__c='before update';
        insert triggerExecutionObj;
        
        User testUser = [SELECT Id, Name FROM User WHERE IsActive = true LIMIT 1];
        System.assertNotEquals(null, testUser, 'No active user found to assign as Owner.');
        
        Case testCase = new Case(
            Status = 'New',
            Core_Sub_Status__c = 'Initial',
            Core_IPS_Assigned_Queue__c = 'Queue A',
            Core_IPS_Escalated_Level__c = 'Level 1',
            OwnerId = testUser.Id
        );
        insert testCase;
        
        testCase.Status = 'In Progress';
        update testCase;
        
        Test.startTest();
        Core_IPS_Status_Ownership_Ctrl_Util.createStatusOwnershipRecord(new List<Id> { testCase.Id });
        Test.stopTest();
        
    }
    
}