global class DeleteBatchSchedulerLineItemPOC implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc){ 
        system.debug('entered start');
        string query ='select Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c,count(Name) as batchNames from Core_MDF_Batch_Scheduler_Line_Item__c'+'Where Core_MDF_Status_Txt__c = \'Completed\''+'OR Core_MDF_Status_Txt__c = \'Cancelled\''+'OR Core_MDF_Status_Txt__c = \'Failed\''+'GROUP BY Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c ORDER BY COUNT(Name) DESC';
        return Database.getQueryLocator(query);  
    }
   global void execute(Database.BatchableContext bc, List<Core_MDF_Batch_Scheduler_Line_Item__c> records){
       system.debug('records size---'+records.size());
     /*   system.debug('count(Name)--'+records.batchNames);
       if(records.count(Name)>500){

       }*/
        List<Core_MDF_Batch_Scheduler_Line_Item__c> delBatchJobs=new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
      
      
       if(delBatchJobs.size()>0){
           
           system.debug('delBatchJobs.size()'+delBatchJobs.size());
          // delete delBatchJobs;
       }
    }
    global void finish(Database.BatchableContext bc){
       
    }      
    
   }