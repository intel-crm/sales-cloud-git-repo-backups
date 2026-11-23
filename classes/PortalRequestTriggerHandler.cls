/****************************************************************************************************
Apex Class Name : PortalRequestTriggerHandler
Version         : 1.0 
Created Date    : 12/16/2022
Function        : Handler Class for PortalRequest Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ranjit                     12/16/2022               Created
*****************************************************************************************************/
public class PortalRequestTriggerHandler extends TriggerHandler{    
    public override void afterInsert() {        
        if(isActive('PSG_Portal_Req_After_Insert')){
        	PSG_PortalRequestController.afterInsertUpdateOperations((List<core_cpq_portalrequest__c>)Trigger.new,(Map<Id,core_cpq_portalrequest__c>)Trigger.oldMap,Trigger.isInsert);
        }
    }
    public override void afterUpdate(){
        if(isActive('PSG_Portal_Req_After_Update')){
        	PSG_PortalRequestController.afterInsertUpdateOperations((List<core_cpq_portalrequest__c>)Trigger.new,(Map<Id,core_cpq_portalrequest__c>)Trigger.oldMap,Trigger.isInsert);
        }
        
    }

}