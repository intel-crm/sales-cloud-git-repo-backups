public class Core_Sales_Assist_Stageing_Handler extends TriggerHandler { 
    
    /*TWC3123-5360- this class was having all commented codes; running this class in Core_Sales_Assist_Stageing Trigger
     */
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public override void afterInsert() { 
        if(mapFunctionalityNameTriggerExecution.containsKey('updateSalesAssistStatus') &&
            mapFunctionalityNameTriggerExecution.get('updateSalesAssistStatus').Core_Active__c) { 
                Core_Sales_Assist_Stageing_ServieHandler.salesAssistInsertUpdateCheck(trigger.new);
            }
        //Core_Sales_Assist_Stageing_ServieHandler.addingSalesAssistAccounts(trigger.new);
        //Core_Sales_Assist_Stageing_ServieHandler.salesAssistInsertUpdate(trigger.new, true);
    }
    
    public override void afterUpdate() { 
        if (mapFunctionalityNameTriggerExecution.containsKey('updateSalesAssistStatus') &&
            mapFunctionalityNameTriggerExecution.get('updateSalesAssistStatus').Core_Active__c) { 
                Core_Sales_Assist_Stageing_ServieHandler.salesAssistInsertUpdateCheck(trigger.new);
            }
        //Core_Sales_Assist_Stageing_ServieHandler.removingSalesAssistAccounts(trigger.new);
        //Core_Sales_Assist_Stageing_ServieHandler.addingSalesAssistAccounts(trigger.new);
        //Core_Sales_Assist_Stageing_ServieHandler.salesAssistInsertUpdate(trigger.new, false);
    }
}