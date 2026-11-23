/***************************************************************************************************
* Apex Class Name : Core_ProductAccess_Product_Dispatcher
* Test Class Name : Core_ProductAccess_Product_Test
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rickey Flores               15/2/2016               Created
* Ganapati                    22/11/2019              Modified for US517859 
  Prasad                      23/04/2020              Fix pmd issues     
****************************************************************************************************/
 
public class Core_ProductAccess_Product_Dispatcher{
    
    public static boolean mAPProducttLineItemCreate = true;
    public static boolean dontExecuteTrigger=false;
    
    public static void beforeMethod(List<Core_IPS_MAP_Product__c> oldList, List<Core_IPS_MAP_Product__c> newList, 
                            Map<Id,Core_IPS_MAP_Product__c> oldMap,Map<Id,Core_IPS_MAP_Product__c> newMap){
         if(trigger.isInsert){
            Core_ProductAccess_Product_Handler.duplicateRecordprevention(newList);
         }
         if(trigger.isUpdate){
             //use Core_ProductAccess_Product_Handler class for your business logic for IPS specific code, others can use their own handler
            }
         if(trigger.isDelete){
             Core_ProductAccess_Product_Handler.deleteLineItems(oldList);
         }
    }  
    
    public static void afterMethod(List<Core_IPS_MAP_Product__c> oldList, List<Core_IPS_MAP_Product__c> newList, 
                            Map<Id,Core_IPS_MAP_Product__c> oldMap,Map<Id,Core_IPS_MAP_Product__c> newMap){
         if(trigger.isInsert){
             Core_ProductAccess_Product_Handler.createLineItems(newList);
             Core_ProductAccess_Product_Handler.setAccessFlagOnMAP(newList);    // Added by Ganapati for - US517859
             //Core_ProductAccess_Product_Handler.getMapProdChangeCount(newList);
         }
         if(trigger.isUpdate){
             //use Core_ProductAccess_Product_Handler class for your business logic for IPS specific code, others can use their own handler
             //commented by ranjini for US767983 

           // Core_ProductAccess_Product_Handler.setAccessFlagOnMAP(newList);    // Added by Ganapati for - US517859
         }
         if(trigger.isDelete){
             //Core_ProductAccess_Product_Handler.setAccessFlagOnMAP(oldList);    // Added by Ganapati for - US517859
             //Core_ProductAccess_Product_Handler.getMapProdChangeCount(oldList);
             //use Core_ProductAccess_Product_Handler class for your business logic for IPS specific code, others can use their own handler
         }
    }
}