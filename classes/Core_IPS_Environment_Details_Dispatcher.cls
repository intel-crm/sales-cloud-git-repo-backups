public class Core_IPS_Environment_Details_Dispatcher{
    public static void beforeMethod(List<Core_IPS_Environment_Details__c> oldList, List<Core_IPS_Environment_Details__c> newList, 
                            Map<Id,Core_IPS_Environment_Details__c> oldMap,Map<Id,Core_IPS_Environment_Details__c> newMap){
         if(trigger.isInsert){
            //use Core_IPS_Environment_Details_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isUpdate){
             //use Core_IPS_Environment_Details_Handler class for your business logic for IPS specific code, others can use their own handler             
         }
         if(trigger.isDelete){
             //use Core_IPS_Environment_Details_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Environment_Details__c> oldList, List<Core_IPS_Environment_Details__c> newList, 
                            Map<Id,Core_IPS_Environment_Details__c> oldMap,Map<Id,Core_IPS_Environment_Details__c> newMap){
         if(trigger.isInsert){
             Core_IPS_Environment_Details_Handler.updateEnvironmentDetailsOnCase(newList);
         }
         if(trigger.isUpdate){
             //use Core_IPS_Environment_Details_Handler class for your business logic for IPS specific code, others can use their own handler             
         }
         if(trigger.isDelete){
             //use Core_IPS_Environment_Details_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }
}