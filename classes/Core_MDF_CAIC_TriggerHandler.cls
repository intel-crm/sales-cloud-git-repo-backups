/****************************************************************************************************************************************
* Class Name  : Core_MDF_CAIC_TriggerHandler 
* Version     : 1.0 
* Created Date: 03-10-2020
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - NZ       03-10-2020         Created for extending Trigger framework to process 
                                          CAIC object business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_CAIC_TriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        if (isActive('Core_MDF_CIACOnBeforeInsert')) {
            System.debug('beforeInsert');
            Core_MDF_CAIC_ServiceHandler.beforeInsertCIACRec((List<Core_MDF_CoMarketing_Activity_Inc_Rule__c>) Trigger.new);
        }
    }
    
    public override void afterInsert(){
        if (isActive('Core_MDF_CIACOnAfterInsert')) {
            
           }
    }
    
    public override void beforeUpdate(){
        if (isActive('Core_MDF_CIACOnBeforeUpdate')) {
        
            Core_MDF_CAIC_ServiceHandler.beforeInsertCIACRec((List<Core_MDF_CoMarketing_Activity_Inc_Rule__c>) Trigger.new);
        }
    }
    
    public override void afterUpdate(){
        if (isActive('Core_MDF_CIACOnAfterUpdate')) {
            
            }
    }
    
    
    public override void beforeDelete(){
        if (isActive('Core_MDF_CIACOnBeforeDelete')) {
            
        }
    }
    
    public override void afterDelete(){
        if (isActive('Core_MDF_CIACOnAfterDelete')) {
        
            
        }        
    }

    public override void afterUndelete(){        
    }
}