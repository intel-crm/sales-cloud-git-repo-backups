public class Core_Sales_Assist_Stageing_Handler extends TriggerHandler{
    
    public override void afterInsert(){
        
        Core_Sales_Assist_Stageing_ServieHandler.addingSalesAssistAccounts(trigger.new);
    }
    public override void afterUpdate(){
        Core_Sales_Assist_Stageing_ServieHandler.removingSalesAssistAccounts(trigger.new);
        Core_Sales_Assist_Stageing_ServieHandler.addingSalesAssistAccounts(trigger.new);
    }

}