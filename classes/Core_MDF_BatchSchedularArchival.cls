/**********************************************************************************
@Author: Accenture
@Description: Archiving the Batch Line Items records more than 5000 
@CreatedDate: November 12 2021
@Version: <V.1.0>
**********************************************************************************/
public without sharing class Core_MDF_BatchSchedularArchival {    
    @InvocableMethod(label='Invoke BatchArchival')
    public static void scheduleArchival(List<BatchSchedularParams> batchSchedules){
        List<Id> listOfBatchSchedulerIds = new List<Id>();
        for(BatchSchedularParams  batchParam: batchSchedules){
            if(batchParam.inputBatchSchedulers != NULL){
                listOfBatchSchedulerIds.addAll(batchParam.inputBatchSchedulers);
            }
        }
        
        //list for deleting line items
        List<Core_MDF_Batch_Scheduler_Line_Item__c> lineItemsToDelete = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        //Qurying Batch records along with the line items with Failed,Completed, Cancelled Status
        List<Core_MDF_Batch_Scheduler__c> listOfBatchSchedules = [SELECT Id,
                                                                  (SELECT Core_MDF_Batch_Scheduler__c,Core_MDF_Status_Txt__c
                                                                   FROM Batch_Scheduler_Line_Items__r                                                                           
                                                                   WHERE (Core_MDF_Status_Txt__c = 'Completed' 
                                                                          OR Core_MDF_Status_Txt__c = 'Failed'
                                                                          OR Core_MDF_Status_Txt__c = 'Cancelled')
                                                                   ORDER By CreatedDate ASC Limit 1000)
                                                                  FROM Core_MDF_Batch_Scheduler__c
                                                                  WHERE Id IN: listOfBatchSchedulerIds  limit 50000];
        
        //Checking the Schedules list is empty or not                                             
        if(!listOfBatchSchedules.isEmpty()){ 
            //Reading the archival limit from Custom Setting record
            Integer archivalLimit = Core_MDF_Configuration__c.getInstance('Core_MDF_CustomBatch_Archival_Limit')!= null ? 
                Integer.Valueof(Core_MDF_Configuration__c.getInstance('Core_MDF_CustomBatch_Archival_Limit').Core_MDF_Value__c):0;
            
            Integer finalDmlCount = Limits.getLimitDmlRows() - Limits.getDmlRows();
            
            //Looping over schedule records
            for(Core_MDF_Batch_Scheduler__c sch: listOfBatchSchedules){
                
                //Checking Schedule Line Items are empty or not
                if(lineItemsToDelete.size()<finalDmlCount){
                    if(!sch.Batch_Scheduler_Line_Items__r.isEmpty()){
                        
                        //adding (more than Archival Limit) line items to list for deletion
                        for(integer i=0;i<sch.Batch_Scheduler_Line_Items__r.size();i++){
                            if(lineItemsToDelete.size()<finalDmlCount){
                            	lineItemsToDelete.add(sch.Batch_Scheduler_Line_Items__r[i]);  
                            }
                            else{ break; }
                        } 
                    }   
                }else{ break; }
            }
        }
        
        //Checking the list is empty or not and deleting the line items 
        if(!lineItemsToDelete.isEmpty())
        { 
            Database.delete(lineItemsToDelete);
        }
    }
    public class BatchSchedularParams
    {
        @InvocableVariable(label = 'BatchSchedular' required = true)
        public List<Id> inputBatchSchedulers;
        
    }
}