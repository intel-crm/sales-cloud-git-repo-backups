public class Core_MDF_BatchApexErrorEvent_Handler extends TriggerHandler {
    
    public override void afterInsert(){
        System.debug('Inside Trigger Handler');    
        Core_MDF_BatchErrorEvent_ServiceHandler.insertLogEntryRecord((List<BatchApexErrorEvent>) Trigger.new);
    }
    
}