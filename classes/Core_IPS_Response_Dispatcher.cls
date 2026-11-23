public class Core_IPS_Response_Dispatcher {
    public static void beforeMethod(List<Core_IPS_Response__c> oldList, List<Core_IPS_Response__c> newList, 
                            Map<Id,Core_IPS_Response__c> oldMap,Map<Id,Core_IPS_Response__c> newMap){
         if(trigger.isInsert){
             Core_IPS_Response_Handler.assignCoreResponseFields(newList);
         }
         if(trigger.isUpdate){
             Core_IPS_Response_Handler.assignCoreResponseFields(newList);
         }
         if(trigger.isDelete){
         }
    }  
     
    public static void afterMethod(List<Core_IPS_Response__c> oldList, List<Core_IPS_Response__c> newList, 
                            Map<Id,Core_IPS_Response__c> oldMap,Map<Id,Core_IPS_Response__c> newMap){
         if(trigger.isInsert){
             Core_IPS_Response_Handler.updateEnvironmentDetailsOnCase(newList); 
             Core_IPS_Response_Handler.updateEDQfilteringFieldOnCase(newList);				//added by Aayushi US95468 06/04/2018
			 Core_IPS_Response_Handler.updateSurveySubmitFieldOnCase(newList);  //added by amritesh - US104141 - 02/25/2018
         }
         if(trigger.isUpdate){ 
            Core_IPS_Response_Handler.updateEDQfilteringFieldOnCase(newList);				//added by Aayushi US95468 06/04/2018
         }
         if(trigger.isDelete){
         }
    }
}