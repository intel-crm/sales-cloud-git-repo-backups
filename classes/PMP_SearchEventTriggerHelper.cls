/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchEventTriggerHelper
* Description : PMP_SearchEventTriggerHelper is used in the trigger handler PMP_SearchEventPartnerTriggerHandler,PMP_SearchEventOfferingTriggerHandler
* Version     : 1.0 
* Created Date: 07-April-2021
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/

public With Sharing class PMP_SearchEventTriggerHelper {
    public static Boolean isWorking() {
        return true;
    }
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal

    /*public static void clearCache(Set<Id> eventIds){
        try{
        String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        String langKeys=PMP_StaticConstants_Partner.supportedLanguagesForPlatformCache;
        Map<String,String> langMap= new Map<string,string>();
        for(String languageCode : langKeys.split('\\;')){
            langMap.put(languageCode,languageCode.replace('_', '').replace('-', ''));
        }
            
            for(Id evtId: eventIds){
                String key1 = 'Event'+evtId+langMap.values()[0];
                String key2 = 'Event'+evtId+langMap.values()[1];
                String key3 = 'Event'+evtId+langMap.values()[2];
                Cache.Org.remove(partitionInput+'.'+key1);
                Cache.Org.remove(partitionInput+'.'+key2);
                Cache.Org.remove(partitionInput+'.'+key3);
            }
        } catch(Exception error){
            PMP_Utility.logError(error,'PMP_SearchEventPartnerTriggerHandler');   
        }
    }


    
    public static void validateEventPartner(List<PMP_Marketplace_Event_Partner__c> eventPartners){
        //Map to hold event Id as key and partner Ids as value
        Map<String, List<String>> evePartnerMap = new Map<String,List<String>>();
        //List to hold the newly associated partner Ids
        List<String> partnerIds = new List<String>();
        //Iterating over new List and getting newly associated partner ids
        for(PMP_Marketplace_Event_Partner__c evePartner :eventPartners){//changed from List<PMP_Marketplace_Event_Partner__c>)Trigger.new to eventPartners
            partnerIds.add(evePartner.PMP_Company_Id__c);
        }
        
        //Iterating over the existing event_partner records having the partner ids from partnerIds
        for(PMP_Marketplace_Event_Partner__c evePartner : [SELECT id, PMP_Event_Id__c,PMP_Company_Id__c
                                                           FROM PMP_Marketplace_Event_Partner__c
                                                           WHERE PMP_Company_Id__c in: partnerIds]){
                                                               //Populating the evePartnerMap with eventId as key and the associated partner Ids as value
                                                               List<String> partnerIdData = new List<String>();
                                                               if(!evePartnerMap.containsKey(evePartner.PMP_Event_Id__c)){
                                                                   partnerIdData.add(evePartner.PMP_Company_Id__c);
                                                                   evePartnerMap.put(evePartner.PMP_Event_Id__c, partnerIdData);
                                                               }else{
                                                                   evePartnerMap.get(evePartner.PMP_Event_Id__c).add(evePartner.PMP_Company_Id__c);
                                                               }
                                                           }
        //Iterating over the Trigger.new List and marking the record where the same partner is associated again
        for(PMP_Marketplace_Event_Partner__c evePartner : eventPartners){ //changed from List<PMP_Marketplace_Event_Partner__c>)Trigger.new to eventPartners
            //Checking if there is an exiating event with the same event Id
            if(evePartnerMap.containsKey(evePartner.PMP_Event_Id__c)){
                //Checking if the existing event already has the newly associated partner id
                if(evePartnerMap.get(evePartner.PMP_Event_Id__c).contains(evePartner.PMP_Company_Id__c)){
                    //if yes the add error to the record , to restric the insert !
                    evePartner.addError('Partner is already associated to this Event');
                }
            }
        }
        
    }
    
    
   public static void validateEventOffering(List<PMP_Marketplace_Event_Offering__c> eventOfferings){
        //Map to hold event Id as key and offering Ids as value
        Map<String, List<String>> eveOffMap = new Map<String, List<String>>();
        //List to hold the event offering ids associated with its approved offering Ids
        List<PMP_Marketplace_Event_Offering__c> eventOffList = new  List<PMP_Marketplace_Event_Offering__c>();
        //List to hold the newly associated offering Ids
        List<String> offIds = new List<String>();
        Set<String> mpEventIds= new  Set<String>(); 
        Set<String> publishedOffIds= new  Set<String>(); 
 
        //Iterating over new List and getting newly associated offering ids
        for(PMP_Marketplace_Event_Offering__c eveOff : eventOfferings){
            offIds.add(eveOff.PMP_Offering_Id__c);
            mpEventIds.add(eveOff.PMP_Event_Id__c);
        }
        
        
        //Iterating over the existing event_offering records having the offering ids from offids
        for(PMP_Marketplace_Event_Offering__c eveOff : [SELECT id,PMP_Offering_Id__c, PMP_Event_Id__c
                                                        from PMP_Marketplace_Event_Offering__c
                                                        WHERE PMP_Offering_Id__c in: offIds]){
        //Populating the eveOffIdMap with eventId as key and the associated offering Ids as value                                                
        List<String> offIdData = new List<String>();
        if(!eveOffMap.containsKey(eveOff.PMP_Event_Id__c)){
            offIdData.add(eveOff.PMP_Offering_Id__c);
            eveOffMap.put(eveOff.PMP_Event_Id__c, offIdData);
        }else{
            eveOffMap.get(eveOff.PMP_Event_Id__c).add(eveOff.PMP_Offering_Id__c);
        }
    }
    //Iterating over the Trigger.new List and marking the record where the same offering is associated again
    for(PMP_Marketplace_Event_Offering__c eveOff : eventOfferings){  //changed from Trigger.new to eventOfferings
        //Checking if there is an exiating event with the same event Id
        if(eveOffMap.containsKey(eveOff.PMP_Event_Id__c)){
            //Checking if the existing event already has the newly associated offering id
            if(eveOffMap.get(eveOff.PMP_Event_Id__c).contains(eveOff.PMP_Offering_Id__c)){
                publishedOffIds.add(eveOff.PMP_Offering_Id__c);
                //if yes the add error to the record , to restric the insert !
                eveOff.addError('Offering is already associated to this Event');
            }
        }
    }
       // Added by Yashasvi Aggarwal        
           if(Schema.sObjectType.PMP_Marketplace_Event_Offering__c.isAccessible())
           {          
               //query all the events offerings associated to offeringIds recieved
               eventOffList=[Select Id from PMP_Marketplace_Event_Offering__c 
                             where (PMP_Offering_Id__r.PMP_Working_Copy_Id__c in : offIds or 
                                    PMP_Offering_Id__r.PMP_Published_Copy_Id_Txt__c in : offIds)
                             and PMP_Event_Id__c in:mpEventIds];
           }
           for(PMP_Marketplace_Event_Offering__c eveOff : eventOfferings){ 
               if(eventOffList.size()>0 && !publishedOffIds.contains(eveOff.PMP_Offering_Id__c))
               {
                   //if approved working copy's published copy is already attached or vice verca then, to restrict the insert !
                   eveOff.addError(System.label.PMP_EventApprovedOfferingInsertRestrictionMsg);
               }
           }
       }*/
}