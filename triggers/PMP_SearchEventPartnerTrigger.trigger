/****************************************************************************************************************************************
* Class Name  : PMP_SearchEventPartnerTrigger 
* Version     : 1.0 
* Created Date: 17-FEB-2020
* Modification Log :
* Created By : Tanzanite Team Infosys
* * Developer                 Date         Description
* ----------------------------------------------------------------------------
* Prabuddh                  02/17/2020     Created ver 1.0
*****************************************************************************************************************************************/

trigger PMP_SearchEventPartnerTrigger on PMP_Marketplace_Event_Partner__c (before insert) {

    //Map to hold event Id as key and partner Ids as value
    Map<String, List<String>> evePartnerMap = new Map<String,List<String>>();
    //List to hold the newly associated partner Ids
    List<String> partnerIds = new List<String>();
    //Iterating over new List and getting newly associated partner ids
    for(PMP_Marketplace_Event_Partner__c evePartner : Trigger.new){
        partnerIds.add(evePartner.PMP_Company_Id__c);
    }

    //Iterating over the existing event_partner records having the partner ids from partnerIds
    for(PMP_Marketplace_Event_Partner__c evePartner : [SELECT id, PMP_Event_Id__c,PMP_Company_Id__c
                                                 FROM PMP_Marketplace_Event_Partner__c
                                                 WHERE PMP_Company_Id__c in: partnerIds]){
        //Populating the evePartnerMap with eventId as key and the associated partner Ids as value
        List<String> partnerIds = new List<String>();
        if(!evePartnerMap.containsKey(evePartner.PMP_Event_Id__c)){
            partnerIds.add(evePartner.PMP_Company_Id__c);
            evePartnerMap.put(evePartner.PMP_Event_Id__c, partnerIds);
        }else{
            evePartnerMap.get(evePartner.PMP_Event_Id__c).add(evePartner.PMP_Company_Id__c);
        }
    }
    //Iterating over the Trigger.new List and marking the record where the same partner is associated again
    for(PMP_Marketplace_Event_Partner__c evePartner : Trigger.new){
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