public class Core_IPS_Case_Comments_Dispatcher{
    public static boolean isLoggeInUserMigrationUser=false;
    public static boolean isLoggeInUserIntegrationUser=false;
    public static boolean isUpdated=false;
    public static void beforeMethod(List<Core_IPS_Case_Comments__c> oldList, List<Core_IPS_Case_Comments__c> newList, 
                            Map<Id,Core_IPS_Case_Comments__c> oldMap,Map<Id,Core_IPS_Case_Comments__c> newMap){
         if(trigger.isInsert){
            Core_IPS_Case_Comments_Handler.replaceFormatting(newList);
            
         }
         if(trigger.isUpdate){
             system.debug('<<<<<<<<<<<<<<<<<<<<');
             if(!isUpdated)
             Core_IPS_Case_Comments_Handler.replaceFormatting(newList);
         }
         if(trigger.isDelete){
             //use Core_IPS_Case_Comments_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Case_Comments__c> oldList, List<Core_IPS_Case_Comments__c> newList, 
                            Map<Id,Core_IPS_Case_Comments__c> oldMap,Map<Id,Core_IPS_Case_Comments__c> newMap){
         isLoggeInUserMigrationUser = Core_IPS_CaseTriggerHandler.isMigrationUser(string.valueof(userinfo.getuserId()));
         isLoggeInUserIntegrationUser = Core_IPS_Case_Comments_Handler.isIntegrationUser(string.valueof(userinfo.getuserId())); 
         if(trigger.isInsert){
             if(!isLoggeInUserMigrationUser){
                 Core_IPS_Case_Comments_Handler.completeActiveMileStone(newList);
                 System.debug('After method************');
                 Core_IPS_Case_Comments_Handler.UpdateCaseField(newList);
             }
             if(isLoggeInUserMigrationUser || isLoggeInUserIntegrationUser)
             Core_IPS_Case_Comments_Handler.RerenderRTF(newList);
         }
         if(trigger.isUpdate){
             //use Core_IPS_Case_Comments_Handler class for your business logic for IPS specific code, others can use their own handler    
             // Core_IPS_CaseComments_Handler.completeActiveMileStone(newList);  
             if(!isUpdated && (isLoggeInUserMigrationUser || isLoggeInUserIntegrationUser))
             Core_IPS_Case_Comments_Handler.RerenderRTF(newList);       
         }
         if(trigger.isDelete){
             //use Core_IPS_Case_Comments_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }
    
}