public class Core_IPS_Opportunity_PAR_Dispatcher
{
     public static void beforeMethod(Map<Id,Core_IPS_Opportunity_PAR__c> oldMap,Map<Id,Core_IPS_Opportunity_PAR__c> newMap,List<Core_IPS_Opportunity_PAR__c> oldList, List<Core_IPS_Opportunity_PAR__c> newList ) {  
         Core_IPS_Opportunity_PAR_Handler.initApprovalProcess(newMap);  
         //Core_IPS_Opportunity_PAR_Handler.mappingProject(oldMap ,newMap);  
     }
    public static void afterMethod(Map<Id,Core_IPS_Opportunity_PAR__c> oldMap,Map<Id,Core_IPS_Opportunity_PAR__c> newMap,List<Core_IPS_Opportunity_PAR__c> oldList, List<Core_IPS_Opportunity_PAR__c> newList ) {  
         Core_IPS_Opportunity_PAR_Handler.mappingProject(oldMap ,newMap);  
     } 
}