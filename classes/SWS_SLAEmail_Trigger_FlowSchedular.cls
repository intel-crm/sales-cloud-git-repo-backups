/****************************************************************************************************
Apex Class Name : SWS_SLAEmail_Trigger_FlowSchedular
Version         : 1.0 
Created Date    : 2025-05-14
Function        : To run the flow: Lead_SLA_Email_Trigger
Created By      : Naveen Muthuramalingam
User Story      : TWC5945-2043
Test Class      : SWS_SLAEmail_Trigger_FlowSchedular_Test
*****************************************************************************************************/
global without sharing class SWS_SLAEmail_Trigger_FlowSchedular implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id FROM Lead WHERE Core_Lead_Status__c != \'Disqualified\' LIMIT 10'
        );
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        Map<String, Object> inputParam = new Map<String, Object>();
        for (SObject obj : scope) {
            inputParam.put('LeadId', obj.Id);
            Flow.Interview.Lead_SLA_Email_Trigger updateLeadFlow = new Flow.Interview.Lead_SLA_Email_Trigger(inputParam);
            updateLeadFlow.start();
        }
    }

    global void finish(Database.BatchableContext bc) {}
}