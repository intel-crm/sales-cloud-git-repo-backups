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
                 Core_IPS_Case_Comments_Handler.UpdateCaseField(newList);
             }
             if(isLoggeInUserMigrationUser || isLoggeInUserIntegrationUser)
             Core_IPS_Case_Comments_Handler.RerenderRTF(newList);
             //By Farooq
             if(!isLoggeInUserMigrationUser || !isLoggeInUserIntegrationUser ){
                 Core_IPS_Case_Comments_Handler.sendComment(newList);  
             }
         }
         if(trigger.isUpdate){
             //use Core_IPS_Case_Comments_Handler class for your business logic for IPS specific code, others can use their own handler    
             // Core_IPS_CaseComments_Handler.completeActiveMileStone(newList);  
             if(!isUpdated && (isLoggeInUserMigrationUser || isLoggeInUserIntegrationUser)){
             Core_IPS_Case_Comments_Handler.RerenderRTF(newList);       
             }
             //Added by Chandra -- Manual Promotion of Comment.
             if(!isLoggeInUserIntegrationUser) {
                 List<Core_IPS_Case_Comments__c> commentsToSend = new List<Core_IPS_Case_Comments__c>();
                 for(Core_IPS_Case_Comments__c comment : newList) {
                     if(oldMap.get(comment.Id).Core_IPS_BES_Promote_Status__c!= comment.Core_IPS_BES_Promote_Status__c && comment.Core_IPS_BES_Promote_Status__c == 'In Progress') {
                         commentsToSend.add(comment);
                     }
                 }
                 if(!commentsToSend.isEmpty()) {
                  	Core_IPS_Case_Comments_Handler.sendComment(commentsToSend);     
                 }
             }
             // End - Manual Promotion of Comment
         }
         if(trigger.isDelete){
             //use Core_IPS_Case_Comments_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }
    
}