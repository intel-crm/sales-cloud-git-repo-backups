/* Trigger Handler for Audit Rules Trigger */
public class Core_MDF_Audit_Rules_TriggerHandler extends TriggerHandler{
    public override void beforeInsert() {
        //system.debug('Before Insert');
        Core_MDF_Audit_Rules_ServiceHandler.checkForDuplicates((List<Core_MDF_Audit_Rules_Engine__c>) Trigger.new);
    }
    public override void beforeUpdate(){
        //system.debug('Before Update');
        Core_MDF_Audit_Rules_ServiceHandler.checkForDuplicates((List<Core_MDF_Audit_Rules_Engine__c>) Trigger.new);
    }
    
    /*public override void afterInsert() {
    }
    
    public override void afterUpdate() {
    }*/
}