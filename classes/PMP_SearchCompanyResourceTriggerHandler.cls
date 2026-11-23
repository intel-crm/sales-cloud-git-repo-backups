/**************************************************************************************
Apex Class Name : PMP_SearchCompanyResourceTriggerHandler
Version     : 1.0 
Created Date: 04/07/2019 
Description : Trigger handler for PMP_SearchPartnerTierTrigger
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Prabuddh                  04/07/2019               Original Version
*************************************************************************************/

public class PMP_SearchCompanyResourceTriggerHandler extends TriggerHandler {
	Map<Id,PMP_Company_Resource__c> oldMap = (Map<Id,PMP_Company_Resource__c>) Trigger.oldMap;
    Map<Id,PMP_Company_Resource__c> newMap = (Map<Id,PMP_Company_Resource__c>) Trigger.newMap;
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public override void afterUpdate(){
        if(mapFunctionalityNameTriggerExecution.containsKey('Comp_Resource_Handler') && 
           mapFunctionalityNameTriggerExecution.get('Comp_Resource_Handler').Core_Active__c){        
               PMP_SearchCompanyResourceTriggerActions.updateCompanyResource(Trigger.new, newMap, oldMap, Trigger.isUpdate);
        }
    }
    
    public override void afterInsert(){
        
        if(mapFunctionalityNameTriggerExecution.containsKey('Comp_Resource_Handler') && 
           mapFunctionalityNameTriggerExecution.get('Comp_Resource_Handler').Core_Active__c){        
               //PMP_SearchCompanyResourceTriggerActions.insertCompanyResource(Trigger.new, newMap,  Trigger.isInsert);
               PMP_SearchCompanyResourceTriggerActions.createContentDistribution(Trigger.new); // Uday: added as Thumbnail images are not showing in Community.
               PMP_SearchCompanyResourceTriggerActions.createContentAsset(Trigger.new); //Manasa : US 524658 - Content Asset 
           }
    }
}