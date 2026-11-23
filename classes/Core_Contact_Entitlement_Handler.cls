/******************************************************************************************************************************************
Class Name  : Core_Contact_Entitlement_Handler
Version     : 1.0 
Created Date: 08 Nov 2021
Function    : Handles all trigger logic for the object Contact Entitlement. This implements the new trigger framework agreed on in Q3 2015.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Zay Montalbo              11/08/2021              Original version 
*****************************************************************************************************************************************/
public without sharing class Core_Contact_Entitlement_Handler extends triggerHandler{
    
     // Map of our Trigger execution flags
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public override void afterInsert(){
       
        Core_ContactEntitlementHelper.updateMembershipChangeInd(Trigger.new, null, 'AFTER_INSERT');
         if(Core_ContactEntitlementValidation.isAddContactEntitlementTriggerAgain < 1){
             Core_ContactEntitlementValidation.addContactEntitlementSubordinates(Trigger.new);
        }
        Core_ContactEntitlementHelper.updateIntegrationStatusAfterDataLoad(Trigger.new);
        Core_ContactEntitlementHelper.updateIPSActiveOnContact(Trigger.new,Trigger.old,Trigger.IsInsert,Trigger.IsUpdate);
     //Update PRM_IPA_Integration_Status__c Integration status to Pending whenever Entitlements are added 
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_ContactEntPublishToSvcCld') &&
           mapFunctionalityNameTriggerExecution.get('Core_ContactEntPublishToSvcCld').Core_Active__c){
            Core_ContactEntitlementHelper.publishContactMsgOnEnttl(Trigger.new);
           }
        
        
    }
    
    public override void afterUpdate(){
        
        Map<Id,Core_Contact_Entitlement__c> oldMap = (Map<Id,Core_Contact_Entitlement__c>)Trigger.oldMap;
        Core_ContactEntitlementHelper.updateMembershipChangeInd(Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, 'AFTER_UPDATE'); 
       List<Core_Contact_Entitlement__c> lstNewList = new List<Core_Contact_Entitlement__c>();
        System.debug('Zay - Inside After Update Contact Entitlement Trigger');
        for(Core_Contact_Entitlement__c conEntRef : (List<Core_Contact_Entitlement__c>)trigger.new){
            Core_Contact_Entitlement__c conEntRefOld = oldMap.get(conEntRef.Id);
            if(conEntRef.Core_Selected__c != conEntRefOld.Core_Selected__c){
                lstNewList.add(conEntRef);
            }
        }
        if(lstNewList.size()>0 && Core_ContactEntitlementValidation.isAddContactEntitlementTriggerAgain < 4){
            Core_ContactEntitlementValidation.addContactEntitlementSubordinates(lstNewList);
        }
        Boolean triggerExecution = [Select Active__c from Trigger_Execution__mdt where MasterLabel ='assignRemovePermissionSetsPublicGroups' Limit 1].Active__c;
        if(triggerExecution) {
            Core_ContactEntitlementHelper.assignRemovePermissionSetsPublicGroups(Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap);
        }
        Core_ContactEntitlementHelper.updateIntegrationStatusAfterDataLoad(Trigger.new);
        Core_ContactEntitlementHelper.updateACR((Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap);     
        Core_ContactEntitlementHelper.updateIPSActiveOnContact(Trigger.new,Trigger.old,Trigger.IsInsert,Trigger.IsUpdate);
     }
   
    public override void beforeUpdate() {
        Core_ContactEntitlementHelper.updateStatusofAssign(trigger.new, (Map<Id,Core_Contact_Entitlement__c>)Trigger.oldMap);  //Shashwat Changes 27/4/2022
        if(Core_ContactEntitlementHelper.triggerMethodFirstEntry || Core_IntegrationInboundMessageAGS.retryInboundMessageProcessing){ // Draco Change [30-05-2022] - Added variable Core_IntegrationInboundMessageAGS.retryInboundMessageProcessing to do contact entitlement validation in case of retrying IIM reprocessing
            mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_ContactEntValidationSwitch') &&
               mapFunctionalityNameTriggerExecution.get('Core_ContactEntValidationSwitch').Core_Active__c){
                   system.debug('new code called');
                   Core_ContactEntitlementValidation.validateContactEntitlementModified(Trigger.old, Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap);
               }
            else{
                system.debug('old code called');
                Core_ContactEntitlementValidation.validateContactEntitlement(Trigger.old, Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap);
            }
            Core_ContactEntitlementHelper.triggerMethodFirstEntry=false;
        }
        
    }
 
    public override void beforeInsert() {
         Core_ContactEntitlementHelper.updateStatusofAssign(trigger.new);  //Shashwat changes 27/04/2022
   	    mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
          if(mapFunctionalityNameTriggerExecution.containsKey('Core_ContactEntValidationSwitch') &&
                                               mapFunctionalityNameTriggerExecution.get('Core_ContactEntValidationSwitch').Core_Active__c){
                                                   system.debug('new code called');
                                                   Core_ContactEntitlementValidation.validateContactEntitlementModified(Trigger.old, Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap);
                                               }
                                            else{
                                                system.debug('old code called');
                                                Core_ContactEntitlementValidation.validateContactEntitlement(Trigger.old, Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap);
                                            }
         
}
    public override void beforeDelete(){
         Core_ContactEntitlementHelper.updateMembershipChangeInd(Trigger.old, null, 'AFTER_DELETE'); 
             //Update PRM_IPA_Integration_Status__c Integration status to Pending whenever Entitlements are removed 
              /*   if(mapFunctionalityNameTriggerExecution.containsKey('Core_ContactEntPublishToSvcCld') &&
                  mapFunctionalityNameTriggerExecution.get('Core_ContactEntPublishToSvcCld').Core_Active__c){
                   Core_ContactEntitlementHelper.publishContactMsgOnEnt(Trigger.old);
                  }*/
         
        }
    
}