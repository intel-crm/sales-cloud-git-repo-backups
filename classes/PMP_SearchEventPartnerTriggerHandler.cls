/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchEventPartnerTriggerHandler
* Description : PMP_SearchEventPartnerTriggerHandler is called from the trigger PMP_SearchEventPartnerTrigger 
* Version     : 1.0 
* Created Date: 07-April-2021
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/

public class PMP_SearchEventPartnerTriggerHandler extends TriggerHandler{
public static Boolean isWorking() {
        return true;
    }
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    /*public override void beforeInsert(){
        PMP_SearchEventTriggerHelper.validateEventPartner((List<PMP_Marketplace_Event_Partner__c>) trigger.new);
	}   
    //after insert trigger event logic
    public override void afterInsert(){
        Set<Id> eventIds= new Set<Id>();
        for(PMP_Marketplace_Event_Partner__c eventPartner : (List<PMP_Marketplace_Event_Partner__c>) trigger.new){
            eventIds.add(eventPartner.PMP_Event_Id__c);
        }
        PMP_SearchEventTriggerHelper.clearCache(eventIds);
    } 
    //after delete trigger event logic
    public override void afterDelete(){
        Set<Id> eventIds= new Set<Id>();
        for(PMP_Marketplace_Event_Partner__c eventPartner : (List<PMP_Marketplace_Event_Partner__c>) trigger.old){
            eventIds.add(eventPartner.PMP_Event_Id__c);
        }
        PMP_SearchEventTriggerHelper.clearCache(eventIds);
    }*/
    
}