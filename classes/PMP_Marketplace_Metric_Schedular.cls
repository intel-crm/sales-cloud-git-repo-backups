/**************************************************************************************
Apex Class Name : PMP_PAG_Dashboard_Batch
Version     : 1.0 
Description : Batch class for PMP_PAG_Dashboard_Handler
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                                			Original Version
*************************************************************************************/



global class PMP_Marketplace_Metric_Schedular implements Database.Batchable<sObject>,Schedulable{  //PMP_Marketplace_Metric_Schedular
    
    global static Database.QueryLocator start(Database.BatchableContext context)
    {
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;

         return Database.getQueryLocator(
            'Select Id,Name,RecordTypeId FROM Account Where RecordTypeId =:partnerAccRecTypeId');

    }
    global void execute(Database.BatchableContext context, List<Account> records){
        
        PMP_Marketplace_Metric_Handler publicGroupValidation = new PMP_Marketplace_Metric_Handler();
        PMP_Marketplace_Metric_Handler.pagGroupValidation();
        
              
    }
    global void finish(Database.BatchableContext context){
     
               
        
    }
    
    global void execute(SchedulableContext ctx) 
    {
         PMP_Marketplace_Metric_Schedular schduleBatch = new PMP_Marketplace_Metric_Schedular();
         database.executebatch(schduleBatch,100);
		 // Job Name - Pag Dashboard Batch Run
       
    }
    
}