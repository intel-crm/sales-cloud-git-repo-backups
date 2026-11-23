public without sharing class Core_OpptySupportMappingTriggerHandler extends TriggerHandler {
public override void beforeInsert() { 
    Core_OpptyMappingSupportServiceHandler.determinecountofAprovers(Trigger.new);} public override void beforeUpdate() { Core_OpptyMappingSupportServiceHandler.determinecountofAprovers(Trigger.new);

}  
}