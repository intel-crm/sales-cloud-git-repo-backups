/*********************************************************************************************************************
Class Name    : PRM_ScheduleBenefitBatch
Version       : 1.0
Created Date  : Feb 2019
Function      : Scheduler class for 'PRM_BenefitsUpdateBatch'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Utkarsh                  Feb,2019              Scheduler class for 'PRM_BenefitsUpdateBatch'
*********************************************************************************************************************/
global with sharing class PRM_ScheduleBenefitBatch implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        PRM_BatchCustomSetting__c bm = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues LIMIT 1];
        Integer a=bm.PRM_NoOfRecords__c.intValue();
        //Id batchJobId = 
            Database.executeBatch(new PRM_BenefitsUpdateBatch(), a); 
    }
}