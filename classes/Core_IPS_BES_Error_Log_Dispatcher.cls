public with sharing class Core_IPS_BES_Error_Log_Dispatcher {
    public static void afterMethod(List<Core_IPS_BES_Error_Log__c> newList){
        if(trigger.isInsert){
            Core_IPS_BES_Error_Log_Handler.insertbackendIntegrationEvents(newList); 
        }     
    }
}