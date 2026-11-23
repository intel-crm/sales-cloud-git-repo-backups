public class Core_IPS_Opportunity_PAR_Dispatcher
{
     public static void beforeMethod(Map<Id,Core_IPS_Opportunity_PAR__c> oldMap,Map<Id,Core_IPS_Opportunity_PAR__c> newMap,List<Core_IPS_Opportunity_PAR__c> oldList, List<Core_IPS_Opportunity_PAR__c> newList ) {  
         Core_IPS_Opportunity_PAR_Handler.initApprovalProcess(newMap);
         /*START -- TWC745-9085 --- Niyaz 13-10-26 Provide Org Admin the ability to select an "existing Project" when OPAR request is requested for approval. */
         Core_IPS_Opportunity_PAR_Handler.resetAddNewProjectOnProjectChange(oldMap, newList);
         /*END -- TWC745-9085 --- Niyaz 13-10-26 Provide Org Admin the ability to select an "existing Project" when OPAR request is requested for approval. */
         //Core_IPS_Opportunity_PAR_Handler.mappingProject(oldMap ,newMap);  
     }
    public static void afterMethod(Map<Id,Core_IPS_Opportunity_PAR__c> oldMap,Map<Id,Core_IPS_Opportunity_PAR__c> newMap,List<Core_IPS_Opportunity_PAR__c> oldList, List<Core_IPS_Opportunity_PAR__c> newList ) {  
         Core_IPS_Opportunity_PAR_Handler.mappingProject(oldMap ,newMap);  
     } 
}