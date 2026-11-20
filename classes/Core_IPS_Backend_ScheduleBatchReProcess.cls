/**************************************************************************************
Apex Class Name:  Core_IPS_Backend_ScheduleBatchReProcess 
Version     : 1.0 
Created Date: 25 04 2016
Function    : Scheduler class for the batch to reprocess case logs.
Author      : Tanvi Chauhan
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* IPS Cloud Rel1   Tanvi Chauhan          25/04/2016              Original Version
*
*************************************************************************************/

global without sharing class Core_IPS_Backend_ScheduleBatchReProcess implements Schedulable{
    global void execute(SchedulableContext sc) {
        String query = 'SELECT id, Name, CreatedDate, Core_Project__c, Core_Origin__c, Core_sObjectType__c, Core_sObjectId__c, Core_Severity__c FROM Core_Log_Entry__c WHERE (Core_Project__c=:project AND createdDate <=: d) OR (Core_Project__c=:project AND Core_Origin__c=: origin AND Core_Severity__c =: severity AND Core_sObjectType__c =:sObjectType)';
        Core_IPS_Backend_Batch_ReprocessFailures batch = new Core_IPS_Backend_Batch_ReprocessFailures();
        batch.queryActive = query;
        Database.executeBatch(batch, 100);
     }
}