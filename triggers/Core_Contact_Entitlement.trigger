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
*****************************************************************************************************************************************/
trigger Core_Contact_Entitlement on Core_Contact_Entitlement__c (before insert,after update,after insert, before update) {
              
            if(Trigger.isBefore) {
                Core_ContactEntitlementHandler.beforeMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            if(Trigger.isAfter) {
                Core_ContactEntitlementHandler.afterMethod(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
                if(Trigger.isInsert || Trigger.isUpdate) {
                    Core_ContactEntitlementHandler.updateIntegrationStatusAfterDataLoad(Trigger.new);
                }
             }
           if((Trigger.isUpdate || Trigger.isInsert)&& Trigger.isAfter){
             Core_ContactEntitlementHandler.updateIPSActiveOnContact(Trigger.new,Trigger.old,Trigger.IsInsert,Trigger.IsUpdate);
           }
   //     core_contact_ent_Trigger_exc_handler.count++;  Commented by Mohan
   //     system.debug('Prem == Count trigger call '+core_contact_ent_Trigger_exc_handler.count);
   

       // Added by Saif to incorporate new Trigger framework
       new Core_Contact_EntitlementTriggerHandler().run();    
   
   
}