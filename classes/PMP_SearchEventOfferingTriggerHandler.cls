/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchEventOfferingTriggerHandler
* Description : PMP_SearchEventOfferingTriggerHandler is called from the trigger PMP_SearchEventOfferingTrigger 
* Version     : 1.0 
* Created Date: 07-April-2021
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/

public class PMP_SearchEventOfferingTriggerHandler extends TriggerHandler{
      public static Boolean isWorking() {
        return true;
    }
    
    // public override void beforeInsert(){
    //     PMP_SearchEventTriggerHelper.validateEventOffering((List<PMP_Marketplace_Event_Offering__c>) trigger.new);
    // }   
    
    // //after insert trigger event logic
    // public override void afterInsert(){
    //     Set<Id> eventIds= new Set<Id>();
    //     for(PMP_Marketplace_Event_Offering__c eventOffering : (List<PMP_Marketplace_Event_Offering__c>) trigger.new){
    //         eventIds.add(eventOffering.PMP_Event_Id__c);
    //     }
    //     PMP_SearchEventTriggerHelper.clearCache(eventIds);
    // } 
    
    // //after delete trigger event logic
    // public override void afterDelete(){
    //     Set<Id> eventIds= new Set<Id>();
    //     for(PMP_Marketplace_Event_Offering__c eventOffering : (List<PMP_Marketplace_Event_Offering__c>) trigger.old){
    //         eventIds.add(eventOffering.PMP_Event_Id__c);
    //     }
    //     PMP_SearchEventTriggerHelper.clearCache(eventIds);
    // }
    
}