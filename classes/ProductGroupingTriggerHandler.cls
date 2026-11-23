public class ProductGroupingTriggerHandler extends TriggerHandler {
    public override void beforeInsert(){
        Retail_CPQ_ProductGroupingBusinessLogic.beforeInsertUpdateOperations(Trigger.new, (Map<id,Core_CPQ_Product_Group__c>)Trigger.oldMap,Trigger.isInsert);
    }
}