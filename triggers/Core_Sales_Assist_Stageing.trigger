trigger Core_Sales_Assist_Stageing on Core_Sales_Assist_Staging__c (after insert,after Update) {
    //uncommented for the TWC3123-5360
    new Core_Sales_Assist_Stageing_Handler().run();
    
    /*Start- Added by Kavyashree HR(Infosys Team) for US1048740 
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    if(trigger.isAfter){
        if(trigger.IsInsert){
            if(mapFunctionalityNameTriggerExecution.containsKey('updateSalesAssistStatus') &&
            mapFunctionalityNameTriggerExecution.get('updateSalesAssistStatus').Core_Active__c){
                Core_Sales_Assist_Stageing_ServieHandler.salesAssistInsertUpdateCheck(trigger.new);
            }
        }
        if(trigger.IsUpdate){
            if (mapFunctionalityNameTriggerExecution.containsKey('updateSalesAssistStatus') &&
            mapFunctionalityNameTriggerExecution.get('updateSalesAssistStatus').Core_Active__c){
                Core_Sales_Assist_Stageing_ServieHandler.salesAssistInsertUpdateCheck(trigger.new);
            }
        }
    }
    End- Added by Kavyashree HR(Infosys Team) for US1048740*/ 
}