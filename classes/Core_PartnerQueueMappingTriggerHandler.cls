/********************************************************************************************************************
Apex Class Name:  Core_PartnerQueueMappingTriggerHandler
Version     : 1.0 
Created Date: 26 May 2022
Function    : Getting all the updated and newly inserted record in Core_Partner_Queue_Mapping__c object for further routing process.
Modification Log :
* Developer                   Date                   
* ----------------------------------------------------------------------------                 
*Megha Kumari                05/26/22               
*********************************************************************************************************************/
public class Core_PartnerQueueMappingTriggerHandler extends TriggerHandler{
    
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    /*
    * new record Insertion
    */
    public override void afterInsert() 
    {
        
        if(Trigger.isInsert)
        {
            if(mapFunctionalityNameTriggerExecution.containsKey('reprocessPartnerLeadSharing') && 
               mapFunctionalityNameTriggerExecution.get('reprocessPartnerLeadSharing').Core_Active__c ){
                   Core_PartnerLeadRoutingHandler.reprocessLeadRoutingOnInsert(Trigger.New);
               }
            if(mapFunctionalityNameTriggerExecution.containsKey('updateStorefrontNameAndId') && 
               mapFunctionalityNameTriggerExecution.get('updateStorefrontNameAndId').Core_Active__c ){
                   Core_PartnerLeadRoutingHandler.updateStoreFront(Trigger.New);
               }
            
        }
    }
    
    /*
    * updation of the record
    */
    public override void afterUpdate() 
    {
        boolean runOnce=Core_checkRecursion.runOnce();
        Map<Id,Core_Partner_Queue_Mapping__c> oldMapLead = (Map<Id,Core_Partner_Queue_Mapping__c>) Trigger.oldMap; 
        if(mapFunctionalityNameTriggerExecution.containsKey('reprocessPartnerLeadSharing') && 
           mapFunctionalityNameTriggerExecution.get('reprocessPartnerLeadSharing').Core_Active__c && runOnce){
               Core_PartnerLeadRoutingHandler.reprocessLeadRoutingOnUpdate(Trigger.New,oldMapLead);
           }
        if(mapFunctionalityNameTriggerExecution.containsKey('updateStorefrontNameAndId') && 
           mapFunctionalityNameTriggerExecution.get('updateStorefrontNameAndId').Core_Active__c && runOnce
          ){
              Core_PartnerLeadRoutingHandler.updateStoreFront(Trigger.New);
          }
    }
}