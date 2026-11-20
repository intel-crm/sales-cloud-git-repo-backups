public class Core_Product_Access_Dispatcher{
    public static void beforeMethod(List<Core_IPS_MAP_PAR__c> oldList, List<Core_IPS_MAP_PAR__c> newList, 
                            Map<Id,Core_IPS_MAP_PAR__c> oldMap,Map<Id,Core_IPS_MAP_PAR__c> newMap){
         if(trigger.isInsert){
            Core_Product_Access_Handler.changeOwner(newList); //IPS - Changing Ownership to the Owner Id of related Support org for MAP/PAR
         }
         if(trigger.isUpdate){
             
         }
         if(trigger.isDelete){

         }
    }  
    
    public static void afterMethod(List<Core_IPS_MAP_PAR__c> oldList, List<Core_IPS_MAP_PAR__c> newList, 
                            Map<Id,Core_IPS_MAP_PAR__c> oldMap,Map<Id,Core_IPS_MAP_PAR__c> newMap){
         if(trigger.isInsert){
             Core_Product_Access_Handler.shareProductAccessRecords(newList);             
         }
         if(trigger.isUpdate){
         
         }
         if(trigger.isDelete){

         }
    }
}