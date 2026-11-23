/**
 * @description       : Handler Class for Record Job object Trigger
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 05-11-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_RecordJobHandler extends TriggerHandler {

    /**
    * @description Overridden method for before update Trigger
    * @author Sandeep Chamate | 06-13-2024 
    **/
    public static Boolean isStopCalculatorForBulkWon = false;
    private static final String INTEGRATION_JOB_PERMISSION_SET = 'Pricing_Abort_Calculator_Integration_User';
    public override void beforeUpdate() {

        Set<Id> quoteIds = new Set<Id>();
        Map<Id, SBQQ__RecordJob__c> quoteIdToRecordJobMap = new Map<Id, SBQQ__RecordJob__c>();
        
        for(SBQQ__RecordJob__c recordJob: (List<SBQQ__RecordJob__c>)Trigger.new) {
            if((recordJob.SBQQ__RecordId__c).contains('QuoteCalculator')) {
                List<String> recordIdList = recordJob.SBQQ__RecordId__c.split('::');
                quoteIds.add(recordIdList[0]);
                quoteIdToRecordJobMap.put(recordIdList[0], recordJob);
            }
        }

        if(isActive('Pricing_Abort_Queueable_Job') && quoteIds.size() > 0) {
            checkCalculatorFailure(quoteIds, quoteIdToRecordJobMap);
        }
    }

    /**
    * @description Method to abort Queueable Jobs for Quotelines
    * @author Sandeep Chamate | 06-13-2024 
    * @param quoteIds 
    * @param quoteIdToRecordJobMap 
    **/
    public static void checkCalculatorFailure(Set<Id> quoteIds, Map<Id, SBQQ__RecordJob__c> quoteIdToRecordJobMap) {

        Map<Id, List<SBQQ__QuoteLine__c>> quoteIdToQLIMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        Set<Id> apexJobIds = new Set<Id>();

        try{
            for(SBQQ__QuoteLine__c qli: [SELECT Id,SBQQ__Quote__c,Pricing_Save_After_Calculation_cb__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: quoteIds]) {
                if(quoteIdToQLIMap.containsKey(qli.SBQQ__Quote__c)) {
                    quoteIdToQLIMap.get(qli.SBQQ__Quote__c).add(qli);
                }
                else {
                    quoteIdToQLIMap.put(qli.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>{qli});
                }
            }

            for(Id qId: quoteIds) {
                Boolean isCalculationPending = false;
                
                if(quoteIdToQLIMap.size() > 0 && quoteIdToQLIMap.get(qId) != null){
                for(SBQQ__QuoteLine__c qli: quoteIdToQLIMap.get(qId)) {
                    if(!qli.Pricing_Save_After_Calculation_cb__c) {
                        system.debug('isCalculationPending:'+isCalculationPending);
                        isCalculationPending = true;
                        }
                    }
                }
                system.debug('isCalculationPendingiff:'+isCalculationPending);
                if(!isCalculationPending) {
                    apexJobIds.add(quoteIdToRecordJobMap.get(qId).SBQQ__JobId__c);
                }
            }

            system.debug('apexJobIds:'+apexJobIds);
            system.debug('isStopCalculatorForBulkWon:'+isStopCalculatorForBulkWon);
            List<AsyncApexJob> queueableJobs = [SELECT Id, CreatedById, Status, ApexClass.Name FROM AsyncApexJob WHERE Id IN: apexJobIds AND Status NOT IN ('Aborted','Completed') AND JobType = 'Queueable'];
            Set<Id> jobCreatorIds = new Set<Id>();
            for(AsyncApexJob queue : queueableJobs) {
               jobCreatorIds.add(queue.CreatedById);
            }
            Set<Id> integrationUserIds = getIntegrationUserIds(jobCreatorIds);
            for(AsyncApexJob queue : queueableJobs) {
               system.debug('enter#:'+isStopCalculatorForBulkWon);
               if(integrationUserIds.contains(queue.CreatedById) || isStopCalculatorForBulkWon){
                   system.debug('if entering');
                	System.AbortJob(queue.Id);
               }
            }
        }
        catch(Exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }

    }

    @TestVisible
    private static Set<Id> getIntegrationUserIds(Set<Id> userIds) {
        Set<Id> integrationUserIds = new Set<Id>();
        for(PermissionSetAssignment assignment : [
            SELECT AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId IN :userIds
            AND PermissionSet.Name = :INTEGRATION_JOB_PERMISSION_SET
        ]) {
            integrationUserIds.add(assignment.AssigneeId);
        }
        return integrationUserIds;
    }
}