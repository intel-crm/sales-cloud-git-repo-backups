public class Core_IPS_Opportunity_Dispatcher{
    public static void beforeMethod(List<Core_IPS_Opportunity__c> oldList, List<Core_IPS_Opportunity__c> newList, 
                            Map<Id,Core_IPS_Opportunity__c> oldMap,Map<Id,Core_IPS_Opportunity__c> newMap){
         if(trigger.isInsert){
            Core_IPS_Opportunity_Handler.DuplicateRecordprevention(newList);
         }
         if(trigger.isUpdate){
             // Core_IPS_Opportunity_Handler.updateRecordType(newList,oldMap);
         }
         if(trigger.isDelete){
             // Core_IPS_Opportunity_Handler.PreventDelete(oldList);
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Opportunity__c> oldList, List<Core_IPS_Opportunity__c> newList, 
                            Map<Id,Core_IPS_Opportunity__c> oldMap,Map<Id,Core_IPS_Opportunity__c> newMap){
         if(trigger.isInsert){
             
         }
         if(trigger.isUpdate){
             
         }
         if(trigger.isDelete){
             
         }
    }
}