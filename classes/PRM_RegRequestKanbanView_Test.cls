/*********************************************************************************************************************
Class Name  : PRM_RegRequestKanbanView_Test
Version       : 1.0
Created Date  : OCT 2018
Function      : Test Class for 'PRM_RegRequestKanbanView'

Modification Log :
* Developer                 Date                    Description
* -------------------------------------------------------------------------------------------------------------------
* Rahul Kainth              10/30/2018              Test Method for 'PRM_RegRequestKanbanView'

*********************************************************************************************************************/
@isTest
public class PRM_RegRequestKanbanView_Test{
    
    static testMethod void testPicklistValuesKanbanView(){
        List<Schema.FieldSetMember> fieldSetFSM = Schema.SObjectType.PRM_Registration_Request__c.FieldSets.PRM_Kanban_View.getFields();
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        insert newRequest;
        Test.startTest();
        // PRM_RegRequestKanbanView.getRegRecord(newRequest.Id);
        PRM_RegRequestKanbanView.getFieldMembers();
        Test.stopTest();
        System.assertEquals(newRequest.PRM_First_Name__c, 'Test Request','Value does not match');
    }
    
    // to pass process instance work item record
    
    static testMethod void approvalRequest() {
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        insert newRequest;
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(newRequest.id);
        Approval.ProcessResult result = Approval.process(req1);
        Test.startTest();
        if(result.getNewWorkitemIds() != null && result.getNewWorkitemIds().size()>0){
        PRM_RegRequestKanbanView.getRegRecord(result.getNewWorkitemIds()[0]);
        }
        Test.stopTest();
        System.assertEquals(newRequest.PRM_First_Name__c, 'Test Request','Value does not match');
    }
}