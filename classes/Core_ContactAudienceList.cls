public with sharing class Core_ContactAudienceList {
    	//Getting the contacts whose audience list has to be updated
        public static List<Contact> populateAudienceList(List <Core_Contact_Entitlement__c> contactEntitlementList){
		List<Contact> finalAudienceList = new List<Contact>();
        List<Contact> returnedAudienceList = new List<Contact>();
		Map<String, Contact> contactIdContactMap = new Map<String, Contact>();
        try{
        //fetching the Entitlements ids from custom label
        String Core_Entitlement_Id_Label = System.Label.Core_Entitlement_Id;
        List<String> lstEntitlementIds = new List<String>();
        List<Core_Entitlement__c> testEntitlementDetails = new List<Core_Entitlement__c>();
        //Test is not running
        if(!Test.isRunningTest()){
            lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
        }else{
            testEntitlementDetails = [Select Id, Name, Core_Display_Name__c from Core_Entitlement__c];
            for(Core_Entitlement__c coreEntitlement : testEntitlementDetails){
                lstEntitlementIds.add(coreEntitlement.Id);
            }
        } 
 
        List<Core_Entitlement__c> entitlementDetails = [Select Id, Name, Core_Display_Name__c from Core_Entitlement__c where 
                                                     Id in :lstEntitlementIds ];
        
        Map<String, String> entitlementIdtoNameMap = new Map<String, String>();
        for(Core_Entitlement__c entitlementVal : entitlementDetails){
            entitlementIdtoNameMap.put(entitlementVal.Id, entitlementVal.Core_Display_Name__c);     
        }
        
        Map<String, List<Core_Contact_Entitlement__c>> entIdToContactEntitlementsMap = new Map<String, List<Core_Contact_Entitlement__c>>();
        
        for(Core_Contact_Entitlement__c contactEntitlementValue : contactEntitlementList){
            if(entIdToContactEntitlementsMap.get(contactEntitlementValue.Core_Entitlement_Id__c) == null){
                List<Core_Contact_Entitlement__c> tempContactEntitlementList = new List<Core_Contact_Entitlement__c>();
                tempContactEntitlementList.add(contactEntitlementValue);
                entIdToContactEntitlementsMap.put(contactEntitlementValue.Core_Entitlement_Id__c,tempContactEntitlementList);
            }else{
                entIdToContactEntitlementsMap.get(contactEntitlementValue.Core_Entitlement_Id__c).add(contactEntitlementValue);
            }
        } 
        for(String entitlementId : entIdToContactEntitlementsMap.keySet()){
            if(!String.isBlank(entitlementId) && entitlementIdtoNameMap.get(entitlementId) != null)
                //Calling setAudience method
                contactIdContactMap = setAudienceList(entitlementId, entitlementIdtoNameMap.get(entitlementId), entIdToContactEntitlementsMap.get(entitlementId),contactIdContactMap);
        }
        }catch(Exception e){
            System.debug('Exception = '+e.getMessage());
        }
		
		finalAudienceList = contactIdContactMap.values();
        return finalAudienceList;
    }
    
      //Updating the audience list of those contacts who are having Partner Portal - Leads,Partner Portal - IPS,Intel Partner FAE,Partner Portal - DDR
      private static Map<String, Contact> setAudienceList(String entitlementId, String entitlementName, List<Core_Contact_Entitlement__c>contactEntitlementList,
	  Map<String, Contact> contactIdContactMap){
        
        List<Id> contactIds = new List<Id>();
        
        for(Core_Contact_Entitlement__c contactEntitlementValues : contactEntitlementList){
            contactIds.add(contactEntitlementValues.Core_Contact_Id__c);    
        }
        List<Contact> contactListToBeUpdated = new List<Contact>();
        for(Contact contactDetail: [Select Id,Core_Audience_List__c from Contact where Id IN :contactIds] ){
            if(String.isBlank(contactDetail.Core_Audience_List__c)){ // Scenraio for handling contacts with no audience list populated 
                contactDetail.Core_Audience_List__c = entitlementName;
                contactListToBeUpdated.add(contactDetail);
            }
            
            if(!String.isBlank(contactDetail.Core_Audience_List__c) && !contactDetail.Core_Audience_List__c.contains(entitlementName)){
                contactDetail.Core_Audience_List__c = contactDetail.Core_Audience_List__c+';'+entitlementName;
                contactListToBeUpdated.add(contactDetail);
        
            }
        }
		
		for(Contact contactToBeUpdated : contactListToBeUpdated){
			if(!contactIdContactMap.containsKey(contactToBeUpdated.Id)){
				contactIdContactMap.put(contactToBeUpdated.Id, contactToBeUpdated);
 
			}else{
				if(contactIdContactMap.get(contactToBeUpdated.Id) != null){
                    if(!String.isBlank(contactIdContactMap.get(contactToBeUpdated.Id).Core_Audience_List__c) 
                       	&& !contactIdContactMap.get(contactToBeUpdated.Id).Core_Audience_List__c.contains(entitlementName)){
                            contactToBeUpdated.Core_Audience_List__c = contactIdContactMap.get(contactToBeUpdated.Id).Core_Audience_List__c +';'+ 
                                entitlementName;
                        	contactIdContactMap.put(contactToBeUpdated.Id, contactToBeUpdated);
                    }
                    
				}
			}
			
		}
        return contactIdContactMap;
       
    }
}