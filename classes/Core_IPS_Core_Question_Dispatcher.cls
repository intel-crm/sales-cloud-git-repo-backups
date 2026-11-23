public class Core_IPS_Core_Question_Dispatcher {
    public static void beforeMethod(List<Core_IPS_Question__c> oldList, List<Core_IPS_Question__c> newList, 
                            Map<Id,Core_IPS_Question__c> oldMap,Map<Id,Core_IPS_Question__c> newMap){
         if(trigger.isInsert){
            Core_IPS_Core_Question_Handler.copyOwnerFromSupportOrgToEnvironmentalDetailQuestion(newList);
            Core_IPS_Core_Question_Handler.preventToCreateEnvironmentalDetailQuestion(newList);
            Core_IPS_Core_Question_Handler.preventToCreateGrandChildEDQ(newList); //Added by Karthick - US102274 - 16/04/2018
            Core_IPS_Core_Question_Handler.preventToCreateThousandEDQ(newList,new Map < Id, Core_IPS_Question__c> {}); //Added by Karthick - US113740- 05/09/2018
         }
         if(trigger.isUpdate){
            Core_IPS_Core_Question_Handler.preventToCreateGrandChildEDQ(newList); //Added by Karthick - US102274 - 16/04/2018
            Core_IPS_Core_Question_Handler.preventToUpdateParentEDQDataType(newList,oldMap); //Added by Karthick - US101342 - 20/04/2018
            Core_IPS_Core_Question_Handler.preventToCreateThousandEDQ(newList,OldMap); //Added by Karthick - US113740- 05/09/2018
         }
         if(trigger.isDelete){ 
            Core_IPS_Core_Question_Handler.preventToDeletetheEnvironmentalDetailQuestion(oldList,oldMap);
         }
    }   
    
    public static void afterMethod(List<Core_IPS_Question__c> oldList, List<Core_IPS_Question__c> newList, 
                            Map<Id,Core_IPS_Question__c> oldMap,Map<Id,Core_IPS_Question__c> newMap){
         if(trigger.isInsert){
         }
         if(trigger.isUpdate){
             Core_IPS_Core_Question_Handler.updateAssignedEnvironmentVariablesFromCoreQuestion(newList,oldMap);
             Core_IPS_Core_Question_Handler.updateEDQfilteringFieldOnCase(newList,oldMap);              //added by Aayushi US95468 06/04/2018
         }
         if(trigger.isDelete){
         }
    }
}