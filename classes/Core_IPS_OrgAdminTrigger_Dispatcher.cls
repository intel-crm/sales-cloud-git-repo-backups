public without sharing class Core_IPS_OrgAdminTrigger_Dispatcher {
    /*public static void beforeMethod(List<Core_IPS_Product_Organization_Admin__c> oldList, List<Core_IPS_Product_Organization_Admin__c> newList, Map<Id,Core_IPS_Product_Organization_Admin__c> oldMap,Map<Id,Core_IPS_Product_Organization_Admin__c> newMap){
        
    }*/
    public static void afterMethod(List<Core_IPS_Product_Organization_Admin__c> newList, Map<Id,Core_IPS_Product_Organization_Admin__c> oldMap){
      
            Core_IPS_OrgAdminTriggerHandler.submitForApproval(newList, oldMap);
     
    }
}