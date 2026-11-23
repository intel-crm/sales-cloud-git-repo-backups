public class Core_IPS_SupportedProduct_Dispatcher{
    
    public static boolean stopReentraceOnPlatformUpdate = false;
    
    public static void beforeMethod(List<Core_IPS_Supported_Product__c> oldList, List<Core_IPS_Supported_Product__c> newList, 
                            Map<Id,Core_IPS_Supported_Product__c> oldMap,Map<Id,Core_IPS_Supported_Product__c> newMap){
         if(trigger.isInsert){
             
         }
         if(trigger.isUpdate){             
             //added by kishore on 5/5              
             Core_IPS_SupportedProduct_Handler.updateAliasName(newList);                
         }
         if(trigger.isDelete){
         
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Supported_Product__c> oldList, List<Core_IPS_Supported_Product__c> newList, 
                            Map<Id,Core_IPS_Supported_Product__c> oldMap,Map<Id,Core_IPS_Supported_Product__c> newMap){
         if(trigger.isInsert){
             Core_IPS_SupportedProduct_Handler.updatePlatformName(newList);
             //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
             Core_IPS_SupportedProduct_Handler.createGlobalAsset(newList,null);
             //End
         }
         if(trigger.isUpdate){
             Core_IPS_SupportedProduct_Handler.updatedEOIStrue(newList,oldMap);
             
             //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
             Core_IPS_SupportedProduct_Handler.createGlobalAsset(newList,oldMap);             
             //End
             
            if(!stopReentraceOnPlatformUpdate){  
                stopReentraceOnPlatformUpdate=true;                
                 Core_IPS_SupportedProduct_Handler.updatePlatformName(newList);
            } 
            //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
            Core_IPS_SupportedProduct_Handler.updateGlobalAssetStatus(newList);
            //End
         }
         if(trigger.isDelete){
            
         }
    }  
}