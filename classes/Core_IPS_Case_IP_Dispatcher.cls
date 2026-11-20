public class Core_IPS_Case_IP_Dispatcher{
    public static boolean DeleteCTM =false;
    
    public static void beforeMethod(List<Core_IPS_Case_Interested_Party__c> oldList, List<Core_IPS_Case_Interested_Party__c> newList, 
                            Map<Id,Core_IPS_Case_Interested_Party__c> oldMap,Map<Id,Core_IPS_Case_Interested_Party__c> newMap){
         if(trigger.isInsert){
            //Core_IPS_Case_Interested_Party_Handler.insertIPToCaseTeam(newList);
         }
         if(trigger.isUpdate){             
                 //Core_IPS_Case_Interested_Party_Handler.deleteIPFromCaseTeamonInactivation(newList);
         }
         if(trigger.isDelete){             
             //Core_IPS_Case_Interested_Party_Handler.deleteIPFromCaseTeam(oldList);
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Case_Interested_Party__c> oldList, List<Core_IPS_Case_Interested_Party__c> newList, 
                            Map<Id,Core_IPS_Case_Interested_Party__c> oldMap,Map<Id,Core_IPS_Case_Interested_Party__c> newMap){
         if(trigger.isInsert){
             Core_IPS_Case_Interested_Party_Handler.insertIPToCaseTeam(newList);
         }
         if(trigger.isUpdate){
             Core_IPS_Case_Interested_Party_Handler.deleteIPFromCaseTeamonInactivation(newList);
         }
         if(trigger.isDelete){
             Core_IPS_Case_Interested_Party_Handler.deleteIPFromCaseTeam(oldList);
         }
    }
}