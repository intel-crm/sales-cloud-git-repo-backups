public class Core_IPS_ProductTrigger_Dispatcher{
        
     public static void beforeMethod(List<Core_IPS_Product__c> oldList, List<Core_IPS_Product__c> newList, 
                            Map<Id,Core_IPS_Product__c> oldMap,Map<Id,Core_IPS_Product__c> newMap){
         if(trigger.isInsert){
             Core_IPS_ProductTriggerHandler.DuplicateRecordprevention(newList);
             Core_IPS_ProductTriggerHandler.preventAddingInactiveProduct(newList);      //added by Aayushi 14/05/2018 US105268
             Core_IPS_ProductTriggerHandler.partnerAgentAsProjectMember(newList,oldMap); // addded by Sumukh for US240170
         }
         if(trigger.isUpdate){
             Core_IPS_ProductTriggerHandler.updateRecordType(newList,oldMap);
             Core_IPS_ProductTriggerHandler.partnerAgentAsProjectMember(newList,oldMap); // addded by Sumukh for US240170
         }
         
                                if(trigger.isDelete){
                                        Core_IPS_ProductTriggerHandler.PreventDelete(oldList);
                                    
                                }
    }  
    
    public static void afterMethod(List<Core_IPS_Product__c> oldList, List<Core_IPS_Product__c> newList, 
                            Map<Id,Core_IPS_Product__c> oldMap,Map<Id,Core_IPS_Product__c> newMap){
         if(trigger.isInsert){
             Core_IPS_ProductTriggerHandler.UpdateIsSubmittedHeader(newList); 
             Core_IPS_ProductTriggerHandler.addDefaultCaseOwnerToIST(newList,oldMap);
			
			
         }
         if(trigger.isUpdate){
             Core_IPS_ProductTriggerHandler.SumbittingIPSProductforApproval(newList);
             Core_IPS_ProductTriggerHandler.CreateAssetforIPSProduct(newList,oldMap); 
             Core_IPS_ProductTriggerHandler.updateProjectStatus(newList);
             Core_IPS_ProductTriggerHandler.InactivateAssets(newList,oldMap);
             Core_IPS_ProductTriggerHandler.addDefaultCaseOwnerToIST(newList,oldMap);
         }
      
         if(trigger.isDelete){
         //added by Aayushi US109046
         Core_IPS_ProductTriggerHandler.deleteAsset(oldList);
         }
    }  
}