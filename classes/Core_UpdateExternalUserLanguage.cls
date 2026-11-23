public class Core_UpdateExternalUserLanguage implements Queueable {
    
    Set<Id> setContactIds = new set<Id>();
    Map<Id, Contact> mapNewContacts = new Map<Id, Contact>();
    
    public Core_UpdateExternalUserLanguage(set<Id> setContactIds, Map<Id, Contact> mapNewContacts) {
        this.setContactIds = setContactIds;
        this.mapNewContacts = mapNewContacts;
    }
    
    public void execute(QueueableContext context) {
        
        List<User> lstUsers = [SELECT Id, LanguageLocaleKey, ProfileId, ContactId, LocaleSidKey FROM User WHERE ContactId IN: setContactIds];
        if(!lstUsers.isEmpty()){
            system.debug('****assign Language****'+lstUsers);
            List<string> lstInvalidEntitlements = Label.Core_Entitlements_To_Ignore_for_Language_Update.split(';');
            List<string> lstProfiles = Label.Core_Profiles_For_Language_Update.split(';');
            List<Id> lstInvalidEntitlementIDs = new List<Id>();
            List<Id> lstProfileIDs = new List<Id>();
            boolean updateUserLanguage;
            List<ID> lstContactIds = new List<ID>();
            Map<Id, String> mapContactErpmLang = new Map<Id, String>();
            Map<String,String> mapERPMLangCodeRefs = new Map<String,String>();
            Map<String,String> mapERPMLocaleCodeRefs = new Map<String,String>();
            Map<Id,List<String>> mapContactEntitlements = new Map<Id, List<String>>();
            
            //To get the ID's of the Profiles for which Language Update should be updated
            for(Schema.Profile p : [SELECT Id FROM Profile WHERE Name IN :lstProfiles])
            {
                lstProfileIDs.add(p.Id);
            }
            system.debug('lstProfileIDs: '+lstProfileIDs);
            //Check if there are any users who have the Partner Profile and add them to the ContactList
            for(User usr : lstUsers)
            {
                if(lstProfileIDs.contains(usr.ProfileId))
                {  
                    lstContactIds.add(usr.ContactId);
                }
            }
            //If there are no user's with Partner Profile in the given List, then exit
            if(lstContactIds.isEmpty())
            {
                return;
            } 
            
            Map<String,eRPM_Language_Reference__mdt> langRefs = new Map<String,eRPM_Language_Reference__mdt>([SELECT eRPM_Language_Code__c, LanguageCode2__c, Locale_Code__c FROM eRPM_Language_Reference__mdt]);
            
            //To store the LanguageLocaleKey and LocaleSidKey values into the respective maps 
            for (String lang : langRefs.keySet()) {
                mapERPMLangCodeRefs.put(langRefs.get(lang).eRPM_Language_Code__c, langRefs.get(lang).LanguageCode2__c);
                mapERPMLocaleCodeRefs.put(langRefs.get(lang).eRPM_Language_Code__c, langRefs.get(lang).Locale_Code__c);
            }
            
            //To get the corresponding eRPM Language Code for each contact and store into a map.
            //List<Contact> contactErpmList = [Select Id, Core_eRPM_Language_Code__c from Contact where Id IN :lstContactIds];
            for(Id conId : lstContactIds)
            {
                mapContactErpmLang.put(conId,mapNewContacts.get(conId).Core_eRPM_Language_Code__c);
            }
            
            //To get the ID's of the Entitlements for which Language Update should not be done
            for(Core_Entitlement__c ent : [SELECT Id FROM Core_Entitlement__c WHERE Name IN :lstInvalidEntitlements])
            {
                lstInvalidEntitlementIDs.add(ent.Id);
            }
            system.debug('lstInvalidEntitlementIDs: '+lstInvalidEntitlementIDs);
            //To get the List of Entitlements a contact has and store into a map.
            List<Id> newEntitlementList;
            for(Core_Contact_Entitlement__c cntEnt : [SELECT Id, Core_Contact_Id__c, Core_Entitlement_Id__r.Name, Core_Entitlement_Id__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c IN :lstContactIds])
            {
                List<String> entitlementNames = mapContactEntitlements.get(cntEnt.Core_Contact_Id__c);
                if(entitlementNames == NULL)
                {
                    newEntitlementList = new List<Id>();
                    newEntitlementList.add(cntEnt.Core_Entitlement_Id__c);
                    mapContactEntitlements.put(cntEnt.Core_Contact_Id__c,newEntitlementList);
                }
                else
                {
                    entitlementNames.add(cntEnt.Core_Entitlement_Id__c);
                    mapContactEntitlements.put(cntEnt.Core_Contact_Id__c,entitlementNames);
                }    
            }
            //To check each user's entitlement and update the language(based on eRPM Language Code) 
            //only if they belong to CCF/DCF and have Partner Profile
            
            List<Id> userEntitlement = new List<Id>();
            for(User u : lstUsers)
            {
                if(lstProfileIDs.contains(u.ProfileId))
                {
                    updateUserLanguage = true;
                    userEntitlement = mapContactEntitlements.get(u.ContactId);
                    if(userEntitlement != null)
                    {
                        for(ID usrEnt : userEntitlement)
                        {	
                            if(lstInvalidEntitlementIDs.contains(usrEnt))
                            {
                                updateUserLanguage = false;
                                break;
                            }
                        }
                        if(updateUserLanguage)
                        {
                            //Check if the Contact has a eRPM Language Code and a corresponding mapping of the LanguageLocaleKey 
                            //and LocaleSidKey is available and assign it to the user.
                            string lang = mapContactErpmLang.get(u.ContactId);
                            if(lang != null && mapERPMLangCodeRefs.containsKey(lang) && mapERPMLocaleCodeRefs.containsKey(lang))
                            {
                                u.LanguageLocaleKey = mapERPMLangCodeRefs.get(lang);  
                                u.LocaleSidKey = mapERPMLocaleCodeRefs.get(lang);
                            }
                            //If no eRPM Language Code and corresponding mapping is available, assign English by default.
                            else
                            {
                                u.LanguageLocaleKey = Label.Core_English_Language_Locale_Key;
                                u.LocaleSidKey = Label.Core_English_Locale_Sid_Key;
                            }
                        }
                    }
                }
                
            }
        }
        if(!Test.isRunningTest()){
        	update lstUsers;           
        }
    }

}