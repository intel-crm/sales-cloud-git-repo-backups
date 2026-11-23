public without sharing class Core_IPS_OrgAdminTrigger_Dispatcher {
    /*public static void beforeMethod(List<Core_IPS_Product_Organization_Admin__c> oldList, List<Core_IPS_Product_Organization_Admin__c> newList, Map<Id,Core_IPS_Product_Organization_Admin__c> oldMap,Map<Id,Core_IPS_Product_Organization_Admin__c> newMap){
        
    }*/
    public static Integer count = 0;
    public static void afterMethod(List<Core_IPS_Product_Organization_Admin__c> newList, Map<Id,Core_IPS_Product_Organization_Admin__c> oldMap){
            System.debug('from dispatcher');
            for(Core_IPS_Product_Organization_Admin__c  orgAdmin: newList){
                if((orgAdmin.Core_IPS_Supported_Org_Admin__c!=null && oldMap!= null) && oldMap.get(orgAdmin.Id).Core_IPS_Supported_Org_Admin__c != orgAdmin.Core_IPS_Supported_Org_Admin__c){
                    Core_IPS_OrgAdminTriggerHandler.submitForApproval(newList, oldMap);
                }
            }
            
     
    }
}