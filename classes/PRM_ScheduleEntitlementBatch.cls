/*********************************************************************************************************************
Class Name    : PRM_ScheduleEntitlementBatch 
Version       : 1.0
Created Date  : May 2020
Function      : Scheduler class for 'PRM_Contact_Entitlements_Insert_batch'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Utkarsh                  May,2020              Scheduler class for 'PRM_Contact_Entitlements_Insert_batch'
*********************************************************************************************************************/
global with sharing class PRM_ScheduleEntitlementBatch implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        PRM_BatchCustomSetting__c bm = [Select Id, Name, PRM_NoOfRecords__c,PRM_SchedulingHour__c,PRM_NoOfBatchEntRecords__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues LIMIT 1];
        Integer a=bm.PRM_NoOfBatchEntRecords__c.intValue();
        Id batchJobId = Database.executeBatch(new PRM_Contact_Entitlements_Insert_batch(), a);
    }
}