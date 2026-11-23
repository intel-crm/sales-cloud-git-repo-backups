/******************************************************************************************************************************************
Trigger Name: Core_Contact_Entitlement
Version     : 1.0 
Created Date: 03 NOV 2016
Function    : Trigger for the object Core_Contact_Entitlement__c.
NOTE: this is using the new trigger framework agreed upon in the technical governance meetings,
which is why it may look a little different than other triggers.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Zay Montalbo              11/03/2016              Original version
* Saif Alam                 9/20/2018            Added trigger handler for new framework
* Sankarshana				11/08/2021			 Added trigger handler for new framework
*****************************************************************************************************************************************/
trigger Core_Contact_Entitlement on Core_Contact_Entitlement__c (before insert,after update,after insert, before update, before delete) {
    Boolean isUpdate = false;
    //public static boolean ceUpdate = false;  
	
	//Added by Draco - new trigger framework
	new Core_Contact_Entitlement_Handler().run();
    
    /*if(Trigger.isBefore) {
        //if(Core_ContactEntitlementHandler.beforeMethodFirstEntry){
            system.debug('Value of First Entry into beforeMethod (before entry): ' + Core_ContactEntitlementHandler.beforeMethodFirstEntry);
            Core_ContactEntitlementHandler.beforeMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            Core_ContactEntitlementHandler.beforeMethodFirstEntry = false;
            system.debug('Value of First Entry into beforeMethod(after leaving): ' + Core_ContactEntitlementHandler.beforeMethodFirstEntry);
        //}
    }
    if(Trigger.isAfter) {
        Core_ContactEntitlementHandler.afterMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        //if(Core_ContactEntitlementHandler.afterMethodFirstEntry){
            system.debug('Value of First Entry into afterMethod (before entry): ' + Core_ContactEntitlementHandler.afterMethodFirstEntry);
        	system.debug(Trigger.new.size());
            if(Trigger.isInsert || Trigger.isUpdate) {
                system.debug('inside insert and update: '+Trigger.new.size());
                Core_ContactEntitlementHandler.updateIntegrationStatusAfterDataLoad(Trigger.new);
            }
            if(Trigger.isUpdate) {
                Map<Id,Core_Contact_Entitlement__c> conEntNewMap = new Map<Id,Core_Contact_Entitlement__c>();
                Map<Id,Core_Contact_Entitlement__c> conEntOldMap = new Map<Id,Core_Contact_Entitlement__c>();
                for(Core_Contact_Entitlement__c contactEntRec: Trigger.new){
                    if((Trigger.oldMap.get(contactEntRec.id).Core_Status__c != contactEntRec.Core_Status__c ) && Trigger.oldMap.get(contactEntRec.id).Core_Selected__c == True && contactEntRec.Core_Selected__c == False){
                        conEntNewMap.put(contactEntRec.id,contactEntRec);
                        conEntOldMap.put(contactEntRec.id,Trigger.oldMap.get(contactEntRec.id));
                    }                 
                } 
                Core_ContactEntitlementHandler.updateACR(Trigger.newMap, Trigger.oldMap);                 
            }
            Core_ContactEntitlementHandler.afterMethodFirstEntry = false;
            system.debug('Value of First Entry into afterMethod(after leaving): ' + Core_ContactEntitlementHandler.afterMethodFirstEntry);
            */
            /*  if(!ceUpdate && Trigger.isUpdate && Trigger.isAfter){ //Moved to Core_Contact_EntitlementTriggerHandler class
                    ceUpdate = true;
                    Core_ContactEntitlementHandler.sendEmailOnCEUpdateToComplete((Map<Id,Core_Contact_Entitlement__c>)Trigger.newMap,(Map<Id,Core_Contact_Entitlement__c>)Trigger.OldMap);
                }*/
        //}
    //}
    /*if((Trigger.isUpdate || Trigger.isInsert)&& Trigger.isAfter){
        Core_ContactEntitlementHandler.updateIPSActiveOnContact(Trigger.new,Trigger.old,Trigger.IsInsert,Trigger.IsUpdate);
    }*/
    
    //     core_contact_ent_Trigger_exc_handler.count++;  Commented by Mohan
    //     system.debug('Prem == Count trigger call '+core_contact_ent_Trigger_exc_handler.count);
    
    
    
    // Added by Saif to incorporate new Trigger framework
    new Core_Contact_EntitlementTriggerHandler().run();        
}