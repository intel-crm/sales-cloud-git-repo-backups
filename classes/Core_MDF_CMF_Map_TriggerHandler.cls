/****************************************************************************************************************************************
* Class Name  : Core_MDF_PGM_TriggerHandler 
* Version     : 1.0 
* Created Date: 09/03/2018 
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       09/03/2018         Created for extending Trigger framework to process Partner Group Mapping business logic methods.
* Intel - NP(11630236) 10/14/2019         Introduced After insert,update,delete to add the CCP subgroup to the corresponding CCP Master group   
*****************************************************************************************************************************************/
public class Core_MDF_CMF_Map_TriggerHandler extends TriggerHandler{
    public override void beforeInsert() {
       
           if(isActive('Core_MDF_CMFProcessesOnBeforeInsert')){
            //To update unique key
            Core_MDF_CMF_Map_ServiceHandler.updateUniqueKey((List<Core_MDF_Comarketing_CMF_Map__c>) Trigger.new, null);
           }
    }
    public override void beforeUpdate(){
        
         if (isActive('Core_MDF_CMFProcessesOnBeforeInsert')) {
           
            //To update unique key
            Core_MDF_CMF_Map_ServiceHandler.updateUniqueKey((List<Core_MDF_Comarketing_CMF_Map__c>) Trigger.new, (Map<id,Core_MDF_Comarketing_CMF_Map__c>) Trigger.oldMap);
        }
       
    }
    
    /*public override void afterInsert() {
       
    }*/
    
    /*public override void afterUpdate() {
       
    }*/

    /*public override void beforeDelete(){
        
    }*/ 
}