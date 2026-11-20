public class Core_Product_Issue_Category_Dispatcher{
    public static void beforeMethod(List<Core_IPS_Product_Issue_Category__c> oldList, List<Core_IPS_Product_Issue_Category__c> newList, 
                            Map<Id,Core_IPS_Product_Issue_Category__c> oldMap,Map<Id,Core_IPS_Product_Issue_Category__c> newMap){
         if(trigger.isInsert){
            //use Core_Product_Issue_Category_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isUpdate){
             //use Core_Product_Issue_Category_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isDelete){
             //use Core_Product_Issue_Category_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Product_Issue_Category__c> oldList, List<Core_IPS_Product_Issue_Category__c> newList, 
                            Map<Id,Core_IPS_Product_Issue_Category__c> oldMap,Map<Id,Core_IPS_Product_Issue_Category__c> newMap){
         if(trigger.isInsert){
           //use Core_Product_Issue_Category_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isUpdate){
             Core_Product_Issue_Category_Handler.Core_Product_Issue_CategoryUpdate(oldMap,newList);
             //use Core_Product_Issue_Category_Handler class for your business logic for IPS specific code, others can use their own handler
         }
         if(trigger.isDelete){
             //use Core_Product_Issue_Category_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }
}