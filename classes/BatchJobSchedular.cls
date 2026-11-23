global without sharing class BatchJobSchedular implements Schedulable {
    
    List<Apex_Batch_Job__c> apexJobs = new List<Apex_Batch_Job__c>();
    
    global void execute(SchedulableContext sc) {
        apexJobs = [SELECT Id FROM Apex_Batch_Job__c ORDER BY Execution_Order__c ASC];
    }
    
 }