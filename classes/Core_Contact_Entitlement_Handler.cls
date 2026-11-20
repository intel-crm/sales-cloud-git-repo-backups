/******************************************************************************************************************************************
Class Name  : Core_Contact_Entitlement_Handler
Version     : 1.0 
Created Date: 08 Nov 2021
Function    : Handles all trigger logic for the object Contact Entitlement. This implements the new trigger framework agreed on in Q3 2015.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Harshitha D              11/08/2021              Original version 
* Sankarshana              11/10/2021              Original version 
Akshay [Team Draco]       13/11/2023              Updated code to perform consolidated DML on Account from "updateMembershipChangeInd" and "updateB2BFlagOnAccount" methods
*****************************************************************************************************************************************/
public without sharing class Core_Contact_Entitlement_Handler extends triggerHandler{
        
    // Map of our Trigger execution flags
   public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution;
   
   //Method includes logic which executes after insertion of records
   public override void afterInsert(){
      //if(Core_ContactEntitlementHelper.triggerAfterMethodFirstEntry){
           List<Account> updateMembChngIndAccounts = Core_ContactEntitlementHelper.updateMembershipChangeInd(Trigger.new, null, 'AFTER_INSERT');
           List<Account> updateB2BFlagAccounts = Core_ContactEntitlementHelper.updateB2BFlagOnAccount(Trigger.new, null, 'AFTER_INSERT');
           Core_ContactEntitlementHelper.updateAccountFields(updateMembChngIndAccounts,updateB2BFlagAccounts);
           //Core_ContactEntitlementHelper.triggerAfterMethodFirstEntry=false;
    //}
        if(Core_ContactEntitlementValidation.isAddContactEntitlementTriggerAgain < 1){
            Core_ContactEntitlementValidation.addContactEntitlementSubordinates(Trigger.new);
       }
       Core_ContactEntitlementHelper.updateIntegrationStatusAfterDataLoad(Trigger.new);
       Core_ContactEntitlementHelper.updateIPSActiveOnContact(Trigger.new,Trigger.old,Trigger.IsInsert,Trigger.IsUpdate);
       
       
   }
   //Method includes logic which executes after updation of records
   public override void afterUpdate(){
       Map<Id,Core_Contact_Entitlement__c> oldMap = (Map<Id,Core_Contact_Entitlement__c>)Trigger.oldMap;
       List<Core_Contact_Entitlement__c> lstNewList = new List<Core_Contact_Entitlement__c>();      
       //if(Core_ContactEntitlementHelper.triggerAfterMethodFirstEntry){
       List<Account> updateMembChngIndAccounts = Core_ContactEntitlementHelper.updateMembershipChangeInd(Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, 'AFTER_UPDATE');
       List<Account> updateB2BFlagAccounts = Core_ContactEntitlementHelper.updateB2BFlagOnAccount(Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, 'AFTER_UPDATE');
       Core_ContactEntitlementHelper.updateAccountFields(updateMembChngIndAccounts,updateB2BFlagAccounts);               
       //Core_ContactEntitlementHelper.triggerAfterMethodFirstEntry=false;
       //}    
       Core_ContactEntitlementHelper.removeSharingForStorefronts(Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, 'AFTER_UPDATE');
       for(Core_Contact_Entitlement__c conEntRef : (List<Core_Contact_Entitlement__c>)trigger.new){
           Core_Contact_Entitlement__c conEntRefOld = oldMap.get(conEntRef.Id);
           if(conEntRef.Core_Selected__c != conEntRefOld.Core_Selected__c){
               lstNewList.add(conEntRef);
           }
           
       }
       
       //Update PRM_IPA_Integration_Status__c Integration status to Pending whenever Entitlements are added 
       if(mapFunctionalityNameTriggerExecution.containsKey('Core_ContactEntPublishToSvcCld') &&
          mapFunctionalityNameTriggerExecution.get('Core_ContactEntPublishToSvcCld').Core_Active__c)
       {
           
          Core_ContactEntitlementHelper.publishContactMsgOnEnttl((List<Core_Contact_Entitlement__c>)Trigger.new, (Map<Id,Core_Contact_Entitlement__c>)Trigger.oldMap);
       }
     
       if(lstNewList.size()>0 && Core_ContactEntitlementValidation.isAddContactEntitlementTriggerAgain < 4){
           Core_ContactEntitlementValidation.addContactEntitlementSubordinates(lstNewList);
       }
       Boolean triggerExecution = [Select Active__c from Trigger_Execution__mdt where MasterLabel ='assignRemovePermissionSetsPublicGroups' Limit 1].Active__c;
       if(triggerExecution) {
           Core_ContactEntitlementHelper.assignRemovePermissionSetsPublicGroups(Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap);
       }
       Core_ContactEntitlementHelper.updateIntegrationStatusAfterDataLoad(Trigger.new);
       //Core_ContactEntitlementHelper.updateACR((Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap);     
       Core_ContactEntitlementHelper.updateIPSActiveOnContact(Trigger.new,Trigger.old,Trigger.IsInsert,Trigger.IsUpdate);
   }
   //Method includes logic which executes before updation of records
   public override void beforeUpdate() {
       Core_ContactEntitlementHelper.updateStatusofAssign(trigger.new, (Map<Id,Core_Contact_Entitlement__c>)Trigger.oldMap);  //Shashwat Changes 27/4/2022
       Core_ContactEntitlementHelper.updateCEStatusChangeDateTime(Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap,'BEFORE_UPDATE');
       Core_ContactEntitlementValidation.validateB2BFlaggedContactEntitlement(Trigger.new);
       if(Core_ContactEntitlementHelper.triggerMethodFirstEntry || Core_IntegrationInboundMessageAGS.retryInboundMessageProcessing){ // Draco Change [30-05-2022] - Added variable Core_IntegrationInboundMessageAGS.retryInboundMessageProcessing to do contact entitlement validation in case of retrying IIM reprocessing
           mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
           if(mapFunctionalityNameTriggerExecution.containsKey('Core_ContactEntValidationSwitch') &&
              mapFunctionalityNameTriggerExecution.get('Core_ContactEntValidationSwitch').Core_Active__c){
                  Core_ContactEntitlementValidation.validateContactEntitlementModified(Trigger.old, Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap);
              }
           else{
               Core_ContactEntitlementValidation.validateContactEntitlement(Trigger.old, Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap);
           }
           Core_ContactEntitlementHelper.triggerMethodFirstEntry=false;
       }
       // Map<Id,Core_Contact_Entitlement__c> oldMap = (Map<Id,Core_Contact_Entitlement__c>)Trigger.oldMap;
       // set<string> conEmails=new set<string>();
       // for(Core_Contact_Entitlement__c conEntRef : (List<Core_Contact_Entitlement__c>)trigger.new){
       //     Core_Contact_Entitlement__c conEntRefOld = oldMap.get(conEntRef.Id);
       // if(conEntRef.core_status__c != conEntRefOld.core_status__c && conEntRef.core_status__c=='Complete'){
       //     conEmails.add(conEntRef.Core_Contact_Id__r.email );
       //   }
       // }
       // system.debug('conEmails'+conEmails);
       // set< string> regids=new set<string>();
       // PRM_Registration_Request__c reg=[select id,name,PRM_Email_ID__c from PRM_Registration_Request__c where PRM_Email_ID__c in: conEmails order by createddate desc limit 1];
       //     regids.add(reg.id);
       
       // 	if(regids!=null){
       // 		PRM_RegistrationTrackerUtility.getregistrationWithTrackers(regids,'Core_Contact_Entitlement_Handler','self',null);
       // 	}

          // system.debug('regids'+regids);
   }

   public override void beforeInsert() {
       Core_ContactEntitlementHelper.updateStatusofAssign(trigger.new);  //Shashwat changes 12/04/2022 
       Core_ContactEntitlementHelper.updateCEStatusChangeDateTime(trigger.new, null,'BEFORE_INSERT');
       Core_ContactEntitlementValidation.validateB2BFlaggedContactEntitlement(Trigger.new);
   if(Core_ContactEntitlementHelper.triggerMethodFirstEntry){
       mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
         if(mapFunctionalityNameTriggerExecution.containsKey('Core_ContactEntValidationSwitch') &&
                                              mapFunctionalityNameTriggerExecution.get('Core_ContactEntValidationSwitch').Core_Active__c){
                                                  Core_ContactEntitlementValidation.validateContactEntitlementModified(Trigger.old, Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap);
                                              }
                                           else{
                                               Core_ContactEntitlementValidation.validateContactEntitlement(Trigger.old, Trigger.new, (Map<Id,Core_Contact_Entitlement__c>) Trigger.oldMap, (Map<Id,Core_Contact_Entitlement__c>) Trigger.newMap);
                                           }
           Core_ContactEntitlementHelper.triggerMethodFirstEntry=false;
       }
}
   //Method includes logic which executes before deletion of records
   public override void beforeDelete(){
       List<Account> updateMembChngIndAccounts = Core_ContactEntitlementHelper.updateMembershipChangeInd(Trigger.old, null, 'AFTER_DELETE'); 
	   Core_ContactEntitlementHelper.removeSharingForStorefronts(Trigger.old, null, 'AFTER_DELETE');
       Core_ContactEntitlementHelper.updateAccountFields(updateMembChngIndAccounts,null); 
   }      
}