public class Core_IPS_CaseOwnerGroup_Dispatcher{
        
    public static void beforeMethod(List<Core_IPS_Case_Owner_Group__c> oldList, List<Core_IPS_Case_Owner_Group__c> newList, Map<Id,Core_IPS_Case_Owner_Group__c> oldMap,Map<Id,Core_IPS_Case_Owner_Group__c> newMap){
        
        if(trigger.isInsert){
            Core_IPS_CaseOwnerGroup_TriggerHandler.assignUserValues(newList);
        }
        if(trigger.isUpdate){  
       
            Core_IPS_CaseOwnerGroup_TriggerHandler.updateCOGRecords(oldMap,newMap);
        }
 
    }
    
    /*Can be used as per the requirement in future for COG --> COG Trigger also should be modified to accomodate the afterMethod
     
    public static void afterMethod(List<Core_IPS_Case_Owner_Group__c> oldList, List<Core_IPS_Case_Owner_Group__c> newList,Map<Id,Core_IPS_Case_Owner_Group__c> oldMap,Map<Id,Core_IPS_Case_Owner_Group__c> newMap){
    
    }
    */
}