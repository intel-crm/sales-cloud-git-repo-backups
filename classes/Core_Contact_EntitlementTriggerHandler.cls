public class Core_Contact_EntitlementTriggerHandler extends TriggerHandler {
    public override void afterUpdate(){
        if(isActive('Core_ContactEntitlementAudienceUpdate')){
          Core_ContactEntitlementAudienceUpdate.updateContactAudience((List<Core_Contact_Entitlement__c>)Trigger.old,
                                                                      (List<Core_Contact_Entitlement__c>)Trigger.new, 
                                                                      (Map<Id,Core_Contact_Entitlement__c>)Trigger.oldMap,
                                                                      (Map<Id, Core_Contact_Entitlement__c>)Trigger.newMap);  
        }
    }
}