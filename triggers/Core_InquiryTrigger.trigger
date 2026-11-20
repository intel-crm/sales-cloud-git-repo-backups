/******************************************************************************************************************************************
Trigger Name:  Core_InquiryTrigger
Version     : 1.0 
Created Date: 29 Jun 2020
Function    : Trigger for the object Inquiry
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda            29/06/2020              Original Version
*******************************************************************************************************************************************/
trigger Core_InquiryTrigger on Core_Inquiry__c (after insert, after update, after delete, before insert, before update, before delete) {
    
    // Fetching "Custom Setting" containing details to trigger switch on/off
   /*Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(trigger.isBefore && trigger.isInsert){
        
        if (mapFunctionalityNameTriggerExecution.containsKey('InquiryRegionUpdate') &&
            mapFunctionalityNameTriggerExecution.get('InquiryRegionUpdate').Core_Active__c){
                Core_InquiryTrigger_Handler.UpdateRegionValue(Trigger.New,Trigger.oldMap,true);
            }  
        
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        if (mapFunctionalityNameTriggerExecution.containsKey('InquiryRegionUpdate') &&
            mapFunctionalityNameTriggerExecution.get('InquiryRegionUpdate').Core_Active__c){
                Core_InquiryTrigger_Handler.UpdateRegionValue(Trigger.New,Trigger.oldMap,false);
            }  
        
    }
    
    
    if(trigger.isAfter && trigger.isInsert){
        if (mapFunctionalityNameTriggerExecution.containsKey('SendInquiryEmailNotification') &&
            mapFunctionalityNameTriggerExecution.get('SendInquiryEmailNotification').Core_Active__c){
                Core_InquiryTrigger_Handler.SendInquiryEmailNotification(Trigger.New); 
            }    
        if (mapFunctionalityNameTriggerExecution.containsKey('SendInquiryContactEmailNotification') &&
            mapFunctionalityNameTriggerExecution.get('SendInquiryContactEmailNotification').Core_Active__c){
                Core_InquiryTrigger_Handler.SendInquiryContactEmailNotification(Trigger.New); 
            }  
        
    }*/
    
       
    
    
}