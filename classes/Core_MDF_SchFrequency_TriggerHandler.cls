public class Core_MDF_SchFrequency_TriggerHandler extends TriggerHandler {

    
    public override void beforeInsert() {
        Core_MDF_SchFrequency_ServiceHandler.schedulerFrequencyOnBeforeInsert((List<Core_MDF_Scheduler_Frequency__c>) Trigger.NEW);
    }
    
    public override void afterInsert(){        
        Core_MDF_SchFrequency_ServiceHandler.schedulerFrequencyOnAfterInsert((List<Core_MDF_Scheduler_Frequency__c>) Trigger.NEW);
    }
        
    public override void beforeUpdate() {
        
    }
    
   
    public override void afterUpdate(){
                
    }
    
}