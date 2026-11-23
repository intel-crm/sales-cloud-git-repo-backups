public class Core_ProductAccess_Product_Dispatcher{
    
    public static boolean MAPProducttLineItemCreate = true;
    public static boolean DontExecuteTrigger=false;
    
    public static void beforeMethod(List<Core_IPS_MAP_Product__c> oldList, List<Core_IPS_MAP_Product__c> newList, 
                            Map<Id,Core_IPS_MAP_Product__c> oldMap,Map<Id,Core_IPS_MAP_Product__c> newMap){
         if(trigger.isInsert){
            Core_ProductAccess_Product_Handler.DuplicateRecordprevention(newList);
         }
         if(trigger.isUpdate){
             //use Core_ProductAccess_Product_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isDelete){
             Core_ProductAccess_Product_Handler.DeleteLineItems(oldList);
         }
    }  
    
    public static void afterMethod(List<Core_IPS_MAP_Product__c> oldList, List<Core_IPS_MAP_Product__c> newList, 
                            Map<Id,Core_IPS_MAP_Product__c> oldMap,Map<Id,Core_IPS_MAP_Product__c> newMap){
         if(trigger.isInsert){
             Core_ProductAccess_Product_Handler.createLineItems(newList);
         }
         if(trigger.isUpdate){
             //use Core_ProductAccess_Product_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isDelete){
             //use Core_ProductAccess_Product_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }
}