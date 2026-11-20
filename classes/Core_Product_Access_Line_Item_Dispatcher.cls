public class Core_Product_Access_Line_Item_Dispatcher{
    public static boolean loggedInUser = false;
    public static void beforeMethod(List<Core_IPS_Map_Par_Line_Item__c> oldList, List<Core_IPS_Map_Par_Line_Item__c> newList, 
                            Map<Id,Core_IPS_Map_Par_Line_Item__c> oldMap,Map<Id,Core_IPS_Map_Par_Line_Item__c> newMap){
         if(trigger.isInsert){
            
         }
         if(trigger.isUpdate){
             
         }
         if(trigger.isDelete){
             
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Map_Par_Line_Item__c> oldList, List<Core_IPS_Map_Par_Line_Item__c> newList, 
                            Map<Id,Core_IPS_Map_Par_Line_Item__c> oldMap,Map<Id,Core_IPS_Map_Par_Line_Item__c> newMap){
         loggedInUser = Core_IPS_CaseTriggerHandler.isMigrationUser(string.valueof(userinfo.getuserId())); 
         if(trigger.isInsert){
             Core_Product_Access_Line_Item_Handler.submitPARForApproval(newList);
             Core_Product_Access_Line_Item_Handler.CreateUpdateAssetsonLItemInsert(newList);
             if(loggedInUser){
                 Core_Product_Access_Line_Item_Handler.inactivateLItemmigrationonly(newList);
             }
         }
         if(trigger.isUpdate){
             Core_Product_Access_Line_Item_Handler.CreateUpdateAssetsonLItemUpdate(newList);
         }
         if(trigger.isDelete){

         }
    }
}