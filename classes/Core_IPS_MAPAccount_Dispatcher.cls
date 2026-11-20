public class Core_IPS_MAPAccount_Dispatcher{
    
    public static boolean MAPAccountLineItemCreate = true;
    public static boolean DontExecuteTrigger=false;
    public static String newListStr; 
        
    public static void beforeMethod(List<Core_IPS_MAP_Account__c> oldList, List<Core_IPS_MAP_Account__c> newList, 
                            Map<Id,Core_IPS_MAP_Account__c> oldMap,Map<Id,Core_IPS_MAP_Account__c> newMap){
         if(trigger.isInsert){
            Core_IPS_MAPAccount_Handler.DuplicateRecordprevention(newList);
         }
         if(trigger.isUpdate){
             
         }
         if(trigger.isDelete){
             Core_IPS_MAPAccount_Handler.DeleteLineItems(oldList);
         }
    }  
    
    public static void afterMethod(List<Core_IPS_MAP_Account__c> oldList, List<Core_IPS_MAP_Account__c> newList, 
                            Map<Id,Core_IPS_MAP_Account__c> oldMap,Map<Id,Core_IPS_MAP_Account__c> newMap){
         if(trigger.isInsert){
             newListStr = JSON.serialize(newList);
             Core_IPS_MAPAccount_Handler.createLineItems(newList);
             Core_IPS_MAPAccount_Handler.SharetoFAE(newListStr);
             Core_IPS_MAPAccount_Handler.getMapAcctChangeCount(newList);
         }
         if(trigger.isUpdate){
             
         }
         if(trigger.isDelete){
             Core_IPS_MAPAccount_Handler.getMapAcctChangeCount(oldList); 
         }
    }
}