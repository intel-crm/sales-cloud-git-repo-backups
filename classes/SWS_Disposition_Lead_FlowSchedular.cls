/****************************************************************************************************
Apex Class Name : SWS_Disposition_Lead_FlowSchedular
Version         : 1.0 
Created Date    : 2025-02-18
Function        : To run the flow: Stale_Lead_Disposition
Created By      : Pankaj Deshmukh
User Story      : TWC5945-1770.TWC5945-1691
Test Class      : SWS_Disposition_Lead_FlowSchedularTest
*****************************************************************************************************/
global without sharing class SWS_Disposition_Lead_FlowSchedular implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Lead WHERE Core_Lead_Status__c != \'Disqualified\' LIMIT 10');
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        Map<String, Object> inputParam = new Map<String, Object>();
        for (SObject obj : scope) {
            inputParam.put('LeadId', obj.Id);
            Flow.Interview.Stale_Lead_Disposition updateLeadFlow = new Flow.Interview.Stale_Lead_Disposition(inputParam);
            updateLeadFlow.start();
        }
    }

    global void finish(Database.BatchableContext bc) {}
}