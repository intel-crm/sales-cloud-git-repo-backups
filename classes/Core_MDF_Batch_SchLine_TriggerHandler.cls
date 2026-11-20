/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_SchLine_TriggerHandler
* Version     : 1.0 
* Created Date: 8-Apr-2021
* Modification Log :
* Developer   Vivek                  Date                          Description
*****************************************************************************************************************************************/
public class Core_MDF_Batch_SchLine_TriggerHandler extends TriggerHandler {
	public override void afterUpdate(){
        if(isActive('Core_MDF_UpdateBatchSchAfterUpdate')){
        	Core_MDF_BatchSchedulerServiceHandler.batchSchLineProcessAfterUpdate((List<Core_MDF_Batch_Scheduler_Line_Item__c>) Trigger.new,(Map<Id,Core_MDF_Batch_Scheduler_Line_Item__c>)Trigger.Oldmap);    
        }        	
    }
}