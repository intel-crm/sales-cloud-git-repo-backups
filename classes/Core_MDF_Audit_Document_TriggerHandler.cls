/****************************************************************************************************************************************
* Class Name  : Core_MDF_Audit_Document_TriggerHandler 
* Version     : 1.0 
* Created Date: 15-02-2022   
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – NK    		15-02-2022                   Trigger handler for on Core_MDF_Audit_Document trigger
*****************************************************************************************************************************************/

public class Core_MDF_Audit_Document_TriggerHandler extends TriggerHandler{

    	public override void beforeInsert() {
             if (isActive('Core_MDF_Audit_Doc_Duplicate_Check')) {
                Core_MDF_Audit_Document_ServiceHandler.dulpicateCheck((List<Core_MDF_Audit_Document__c>) Trigger.new);
            }
        }
    
    public override void afterInsert(){
         if (isActive('Core_MDF_Audit_Doc_Sharing_After_Insert')) {
        	Core_MDF_Audit_Document_ServiceHandler.auditDocProcessesOnAfterInsert((List<Core_MDF_Audit_Document__c>) Trigger.new);
         }
    }
    
    public override void afterUpdate(){
        if (isActive('Core_MDF_Audit_Doc_Sharing_After_Update')) {
        	Core_MDF_Audit_Document_ServiceHandler.auditDocProcessesOnAfterUpdate((List<Core_MDF_Audit_Document__c>) Trigger.new);
        }
    }
}