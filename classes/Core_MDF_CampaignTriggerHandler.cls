public without sharing class Core_MDF_CampaignTriggerHandler extends TriggerHandler {     
    
    public override void beforeInsert() { 
        if(isActive('Core_MDF_Campaign_Trigger_Before_Insert')){
            
            Core_MDF_CampaignServiceHandler.determineProgram(Trigger.isInsert,Trigger.isUpdate,
                                                             (List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, 
                                                             'beforeInsert');
           
        } 
    }
    
    public override void beforeUpdate() {
        if(isActive('Core_MDF_Campaign_Trigger_Before_Update')){
           
            Core_MDF_CampaignServiceHandler.determineProgram(Trigger.isInsert,Trigger.isUpdate,
                                                             (List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, 
                                                             'beforeUpdate');
           
        }      
    }
    
    public override void afterInsert(){
        if(isActive('Core_MDF_Campaign_Trigger_After_Insert')){
           
            Core_MDF_CampaignServiceHandler.determineProgram(Trigger.isInsert,Trigger.isUpdate,
                                                             (List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, 
                                                             'afterInsert');
           
        }
    }
    
    public override void afterUpdate(){
        if(isActive('Core_MDF_Campaign_Trigger_After_Update')){
           
            Core_MDF_CampaignServiceHandler.determineProgram(Trigger.isInsert,Trigger.isUpdate,
                                                             (List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, 
                                                             'afterUpdate');
           
        }
    }  
    
    public override void beforeDelete(){
        if(isActive('Core_MDF_Campaign_Trigger_Before_Delete')){
           
            Core_MDF_CampaignServiceHandler.determineProgram(Trigger.isInsert,Trigger.isUpdate,
                                                             (List<Campaign>) Trigger.old, null, 
                                                             'beforeDelete');
           
        }
    }

}