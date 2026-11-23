/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_Scheduler_RetryCaseCreation 
* Version     : 1.0 
* Created Date: 10-03-2019
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Ealisha 		10-03-2019					  Scheduler class to invoke Core_MDF_Batch_RetryCaseCreation
**************************************************************************************************************************************************************************************/
global without sharing class Core_MDF_Scheduler_RetryCaseCreation implements Schedulable{
   global void execute(SchedulableContext sc) {  
       //get all claim ids from auditHoldClaim object which got created 1 hr before the batch run.  
       //and Createddate <=: todaysDate     
       String query=
            'select Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate from Core_MDF_Audit_Hold_Claim__c where Core_MDF_Status__c in(\'Pending\',\'Processing\') and Core_MDF_Retry_Indicator__c <= 2 and Createddate <=: todaysDate limit 100';
        System.debug('query:'+query); 
        Core_MDF_Batch_RetryCaseCreation caseCreationRetryBatch = new Core_MDF_Batch_RetryCaseCreation();
        caseCreationRetryBatch.queryActive = query;
       
        Database.executeBatch(caseCreationRetryBatch, 100);
     }
}