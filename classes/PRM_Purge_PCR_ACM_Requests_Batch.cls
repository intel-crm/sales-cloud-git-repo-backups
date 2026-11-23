/***********************************************************************************************************************************************
Apex Class Name:  PRM_Purge_PCR_ACM_Requests_Batch
Version     : 1.0 
Created Date: 17 October 2022
Function    : Schedular Class for Batch for 'PRM_Purge_PCR_ACM_Requests_Batch' Batch class

Modification Log :
* Developer          Date                  Description                                               TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Tanya Rajesh       17/10/2022            Batch Class and Schedular class for batch                PRM_Purge_Registration_Requests_Test
                                           for Purging ACM and ACR records
*************************************************************************************************************************************************/	
public with sharing class PRM_Purge_PCR_ACM_Requests_Batch implements Database.Batchable<sObject>, Schedulable{
    //Batch Methods
    public static Database.QueryLocator start(Database.BatchableContext context){
        String statusPending = 'Pending Action';
        Integer purgeDays = Integer.valueOf(System.Label.PRM_PurgeDays) +1;
        String purgeACRRecs = 'SELECT id, PRM_Relationship_Id__r.Name, PRM_Status_Nm__c, LastModifiedDate, CreatedBy.Name, CreatedBy.IsActive FROM PRM_Account_Contact_Relationship__c WHERE CreatedDate < LAST_N_DAYS:'+purgeDays+' AND PRM_Status_Nm__c =: statusPending order by PRM_Contact_Id__c , LastModifiedDate';
        return Database.getQueryLocator(purgeACRRecs);
    }
    public void execute(Database.BatchableContext context, List<PRM_Account_Contact_Relationship__c> scope){
        PRM_Purge_PCR_ACM_Requests.purgeRecords(scope);
    }
    public void finish(Database.BatchableContext context){
    }

    //Schedular Method
    public void execute(SchedulableContext sc)
    {
        //Id batchJobId = 
            Database.executeBatch(new PRM_Purge_PCR_ACM_Requests_Batch()); 
    }
}