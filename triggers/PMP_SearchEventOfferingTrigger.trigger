/****************************************************************************************************************************************
* Class Name  : PMP_SearchEventOfferingTrigger 
* Version     : 1.0 
* Created Date: 17-FEB-2020
* Modification Log :
* Created By : Tanzanite Team Infosys
* * Developer                 Date         Description
* ----------------------------------------------------------------------------
* Prabuddh                  02/17/2020     Created ver 1.0
*****************************************************************************************************************************************/

trigger PMP_SearchEventOfferingTrigger on PMP_Marketplace_Event_Offering__c (before insert) {
    //Map to hold event Id as key and offering Ids as value
    Map<String, List<String>> eveOffMap = new Map<String, List<String>>();
    //List to hold the newly associated offering Ids
    List<String> offIds = new List<String>();
    //Iterating over new List and getting newly associated offering ids
    for(PMP_Marketplace_Event_Offering__c eveOff : Trigger.new){
        offIds.add(eveOff.PMP_Offering_Id__c);
    }
    
    
    //Iterating over the existing event_offering records having the offering ids from offids
    for(PMP_Marketplace_Event_Offering__c eveOff : [SELECT id,PMP_Offering_Id__c, PMP_Event_Id__c
                                                    from PMP_Marketplace_Event_Offering__c
                                                    WHERE PMP_Offering_Id__c in: offIds]){
        //Populating the eveOffIdMap with eventId as key and the associated offering Ids as value                                                
        List<String> offIds = new List<String>();
        if(!eveOffMap.containsKey(eveOff.PMP_Event_Id__c)){
            offIds.add(eveOff.PMP_Offering_Id__c);
            eveOffMap.put(eveOff.PMP_Event_Id__c, offIds);
        }else{
            eveOffMap.get(eveOff.PMP_Event_Id__c).add(eveOff.PMP_Offering_Id__c);
        }
    }
    //Iterating over the Trigger.new List and marking the record where the same offering is associated again
    for(PMP_Marketplace_Event_Offering__c eveOff : Trigger.new){
        //Checking if there is an exiating event with the same event Id
        if(eveOffMap.containsKey(eveOff.PMP_Event_Id__c)){
            //Checking if the existing event already has the newly associated offering id
            if(eveOffMap.get(eveOff.PMP_Event_Id__c).contains(eveOff.PMP_Offering_Id__c)){
                //if yes the add error to the record , to restric the insert !
                eveOff.addError('Offering is already associated to this Event');
            }
        }
    }
    
    
}