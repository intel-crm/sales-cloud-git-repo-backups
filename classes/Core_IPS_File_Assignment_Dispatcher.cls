public class Core_IPS_File_Assignment_Dispatcher{
    public static void beforeMethod(List<Core_IPS_File_Assignment__c> oldList, List<Core_IPS_File_Assignment__c> newList, 
                            Map<Id,Core_IPS_File_Assignment__c> oldMap,Map<Id,Core_IPS_File_Assignment__c> newMap){
         if(trigger.isInsert){
            Core_IPS_File_Assignment_Handler.updateFileDescription(oldList,newList,oldMap,newMap);
         }
         if(trigger.isUpdate){
            Core_IPS_File_Assignment_Handler.updateFileDescription(oldList,newList,oldMap,newMap); 
         }
         if(trigger.isDelete){
             //use Core_IPS_File_Assignment_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }  
    
    public static void afterMethod(List<Core_IPS_File_Assignment__c> oldList, List<Core_IPS_File_Assignment__c> newList, 
                            Map<Id,Core_IPS_File_Assignment__c> oldMap,Map<Id,Core_IPS_File_Assignment__c> newMap){
         if(trigger.isInsert){
             Core_IPS_File_Assignment_Handler.sendEmailNotification(oldList,newList,oldMap,newMap);                 
         }
         if(trigger.isUpdate){
             Core_IPS_File_Assignment_Handler.sendEmailNotification(oldList,newList,oldMap,newMap); 
         }
         if(trigger.isDelete){
             //use Core_IPS_File_Assignment_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }
}