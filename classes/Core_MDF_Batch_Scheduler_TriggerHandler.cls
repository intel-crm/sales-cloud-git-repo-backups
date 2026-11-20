/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_Scheduler_TriggerHandler
* Version     : 1.0 
* Created Date: 8-Apr-2021
* Modification Log :
* Developer   Vivek                  Date                          Description
*****************************************************************************************************************************************/
public class Core_MDF_Batch_Scheduler_TriggerHandler extends TriggerHandler{
    
    public override void beforeInsert(){
        Core_MDF_BatchSchedulerServiceHandler.validateBatchClassNameOnSchedulerRecord((List<Core_MDF_Batch_Scheduler__c>)Trigger.new);
        Core_MDF_BatchSchedulerServiceHandler.updateGMTTime((List<Core_MDF_Batch_Scheduler__c>)Trigger.new);        
    }
    public override void afterInsert(){
        if(isActive('Core_MDF_InsertBatchSchLineAfterInsert')){
        	Core_MDF_BatchSchedulerServiceHandler.batchScheduleProcessAfterInsert((List<Core_MDF_Batch_Scheduler__c>)Trigger.new);    
        }            
    }
    
    public override void afterUpdate(){
        if(isActive('Core_MDF_UpdateBatchSchLineAfterUpdate')){
    		Core_MDF_BatchSchedulerServiceHandler.batchScheduleProcessAfterUpdate((Map<Id,Core_MDF_Batch_Scheduler__c>) Trigger.newMap,(List<Core_MDF_Batch_Scheduler__c>) Trigger.old);
        }
    }

}