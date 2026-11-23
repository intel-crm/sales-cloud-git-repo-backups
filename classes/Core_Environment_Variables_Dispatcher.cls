public class Core_Environment_Variables_Dispatcher{
    public static void beforeMethod(List<Core_IPS_Environment_Variables__c> oldList, List<Core_IPS_Environment_Variables__c> newList, 
                            Map<Id,Core_IPS_Environment_Variables__c> oldMap,Map<Id,Core_IPS_Environment_Variables__c> newMap){
         if(trigger.isInsert){
            //use Core_Environment_Variables_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isUpdate){
             //use Core_Environment_Variables_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isDelete){
             //use Core_Environment_Variables_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Environment_Variables__c> oldList, List<Core_IPS_Environment_Variables__c> newList, 
                            Map<Id,Core_IPS_Environment_Variables__c> oldMap,Map<Id,Core_IPS_Environment_Variables__c> newMap){
         if(trigger.isInsert){
           //use Core_Environment_Variables_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isUpdate){
             Core_Environment_Variables_Handler.Core_Environment_VariableUpdate(oldMap,newList);
             //use Core_Environment_Variables_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isDelete){
             //use Core_Environment_Variables_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }
}