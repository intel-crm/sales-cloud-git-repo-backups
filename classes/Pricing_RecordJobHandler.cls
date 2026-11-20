/**
 * @description       : Handler Class for Record Job object Trigger
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 05-13-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_RecordJobHandler extends TriggerHandler {

    /**
    * @description Overridden method for before update Trigger
    * @author Sandeep Chamate | 06-13-2024 
    **/
    public static Boolean isStopCalculatorForBulkWon = false;
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
                        isCalculationPending = true;
                        }
                    }
                }
                if(!isCalculationPending) {
                    apexJobIds.add(quoteIdToRecordJobMap.get(qId).SBQQ__JobId__c);
                }
            }

            for(AsyncApexJob queue: [Select Id,CreatedBy.Profile.Name,Status,ApexClass.Name from AsyncApexJob WHERE Id IN: apexJobIds AND Status NOT IN ('Aborted','Completed') and JobType = 'Queueable']) {
                if(queue.CreatedBy.Profile.Name == 'Integration' || isStopCalculatorForBulkWon){
                	System.AbortJob(queue.Id);
                }
            }
            isStopCalculatorForBulkWon = false;
        }
        catch(Exception ex) {
            Pricing_Tender_Utility.logError(ex);
        }

    }
}