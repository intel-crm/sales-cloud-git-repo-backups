/****************************************************************************************************************************************
* Class Name  : Core_MDF_Escalation_TriggerHandler 
* Created Date: 15-05-2019
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - NP           15-05-2019           Extending Trigger framework for Apex Sharing of Escalation records
*****************************************************************************************************************************************/
public class Core_MDF_Escalation_TriggerHandler extends TriggerHandler{

    boolean initializeEsclations= isActive('Core_MDF_Set_Channel_Program');
    boolean shareEscalationFlag = isActive('Core_MDF_Share_Escalations');
    boolean esclationApprovalAction = isActive('Core_MDF_Escalation_Approval_Action');    
    
    
    

    public override void beforeInsert(){ 
        if(initializeEsclations){
            Core_MDF_Escalation_ServiceHandler.initializeEscalationFields((List<Core_MDF_Escalation__c>) Trigger.new,null,Trigger.isInsert);                      
        }
    }
    
     public override void beforeUpdate(){
         if(initializeEsclations){
             Core_MDF_Escalation_ServiceHandler.initializeEscalationFields((List<Core_MDF_Escalation__c>) Trigger.new,(Map<Id,Core_MDF_Escalation__c>) Trigger.oldMap,Trigger.isInsert);
         }  
    }


    public override void afterInsert(){
        if(shareEscalationFlag ){
            Core_MDF_Escalation_ServiceHandler.shareEscalation((Map<Id,Core_MDF_Escalation__c>) Trigger.newMap,null,Trigger.isInsert);
        
        } 
    }
    
    public override void afterUpdate(){ 
        if(shareEscalationFlag ){
            Core_MDF_Escalation_ServiceHandler.shareEscalation((Map<Id,Core_MDF_Escalation__c>) Trigger.newMap,(Map<Id,Core_MDF_Escalation__c>) Trigger.oldMap,Trigger.isInsert);
        }
        
        if(esclationApprovalAction){
            Core_MDF_Escalation_ServiceHandler.approvalAction((List<Core_MDF_Escalation__c>) Trigger.new,(Map<Id,Core_MDF_Escalation__c>) Trigger.oldMap);
        }          
    }
 
}