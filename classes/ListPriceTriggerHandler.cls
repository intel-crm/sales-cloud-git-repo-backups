public class ListPriceTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert(){
        PSG_ListPriceBusinessLogic.beforeInsertUpdateOperations((List<core_cpq_list_price__c>)Trigger.new,(Map<Id,core_cpq_list_price__c>)Trigger.oldMap,Trigger.isInsert);
    }
    public override void beforeUpdate(){
        //PRIDBusinessLogic.beforeInsertUpdateOperations((List<price_prid__c>)Trigger.new,(Map<Id,price_prid__c>)Trigger.oldMap,Trigger.isInsert);
    }
    public override void afterInsert() {
       // PRIDBusinessLogic.afterInsertUpdateOperations((List<price_prid__c>)Trigger.new,(Map<Id,price_prid__c>)Trigger.oldMap,Trigger.isInsert);
    }
    public override void afterUpdate(){
       // PRIDBusinessLogic.afterInsertUpdateOperations((List<price_prid__c>)Trigger.new,(Map<Id,price_prid__c>)Trigger.oldMap,Trigger.isInsert);
    }

}