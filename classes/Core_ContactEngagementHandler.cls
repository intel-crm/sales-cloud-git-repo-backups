/******************************************************************************************************************************************
Class Name  : Core_ContactEngagementHandler
Version     : 1.0 
Created Date: 26 APR 2016
Function    : Provides methods for the object Core_Contact_Engagement__c.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------    
* Troy Hofeling             04/27/2016              Original versionhttps://intel--crmdevint3.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
*****************************************************************************************************************************************/

public class Core_ContactEngagementHandler {
    
    public static void validateUniqueEngagement(List<Core_Contact_Engagement__c> contactEngagementList) {
        // unfortunately, in order to avoid SOQL limits, we need to load contacts and contact engagements into memory for unique checks
        String[] contactIds = new String[]{};
            String[] contactEngagementIds = new String[]{};
                Map<String,Core_Engagement__c> engagementMap = getEngagementsHavingProfiles();
        for (Core_Contact_Engagement__c contactEngagement : contactEngagementList) {
            contactIds.add(contactEngagement.Core_Contact__c);
        }
        Map<String,Contact> contactMap = getContactMap(contactIds);
        Map<String,String> contactEngagementMap = getContactEngagementMap(contactIds, engagementMap);
        // only need to do this check if we are ADDING a new engagement OR Making existing engagement ACTIVE
        for (Core_Contact_Engagement__c contactEngagement : contactEngagementList) {
            
            // Check is needed ONLY if making an ACTIVE engagement
            if (contactEngagement.Core_Active__c == true) {
                // Does the user already have an IPS Engagement?
                Contact contact = contactMap.get(contactEngagement.Core_Contact__c);
                if (contact != null && contact.Core_IPS_Active__c == true && contactEngagement.Core_Engagement_Code__c != 'IPS' ) {
                    contactEngagement.addError(contact.Firstname + ' ' + contact.LastName + ' is already assigned a user profile for IPS engagement! Only one profile can be assigned to a user account');
                    return;
                }
                
                if (contactEngagementMap.containsKey(contactEngagement.Core_Contact__c) && contactEngagementMap.get(contactEngagement.Core_Contact__c) != contactEngagement.Core_Engagement_Code__c) {
                    contactEngagement.addError(contact.Firstname + ' ' + contact.LastName + ' already has a user profile for engagement [ ' + contactEngagementMap.get(contactEngagement.Core_Contact__c) + ' ]! Only one profile can be assigned to a user account');
                    return;
                }
            }
            
            // Does the contact already have an engagement requiring a SF Profile
            
        }
    }
    
    private static Map<String,Contact> getContactMap(String[] contactIds) {
        Map<String,Contact> contactMap = new Map<String,Contact>();
        
        List<Contact> contactList = [SELECT Id, FirstName, LastName, Core_IPS_Active__c from Contact WHERE Id in :contactIds];
        for (Contact contact : contactList) {
            contactMap.put(contact.Id, contact);
        }
        return contactMap;
    }
    
    private static Map<String,String> getContactEngagementMap(String[] contactIds, Map<String,Core_Engagement__c> engagementMap) {
        Map<String,String> contactEngagementMap = new Map<String,String>();
        List<Core_Contact_Engagement__c> contactEngagementList = [SELECT Core_Contact__c, Core_Engagement_Label__c, Core_Engagement_Code__c FROM Core_Contact_Engagement__c WHERE Core_Contact__c in :contactIds AND Core_Engagement_Code__c in :engagementMap.keySet() AND Core_Active__c = true];
        for (Core_Contact_Engagement__c contactEngagement : contactEngagementList) {
            contactEngagementMap.put(contactEngagement.Core_Contact__c, contactEngagement.Core_Engagement_Code__c);
        }
        return contactEngagementMap;
    }
    
    private static Map<String,Core_Engagement__c> getEngagementsHavingProfiles() {
        Map<String,Core_Engagement__c> engagementMap = new Map<String,Core_Engagement__c>();
        List<Core_Engagement__c> engagementList = [SELECT Core_Engagement_Code__c FROM Core_Engagement__c WHERE Core_Editable__c = true];
        for (Core_Engagement__c engagement : engagementList){
            engagementMap.put(engagement.Core_Engagement_Code__c, engagement);
        }
        return engagementMap;
    }
    
    public static void checkEngagementExistsInMaster(List<Core_Contact_Engagement__c> oldList, List<Core_Contact_Engagement__c> newList, Map<Id,Core_Contact_Engagement__c> oldMap, Map<Id,Core_Contact_Engagement__c> newMap) {
        Map<String, List<sObject>> listsMap = new Map<String, List<sObject>>();
        List<sObject> insertList; 
        List<sObject> updateList; 
        
        // Is ERPM (via Integration Profile) doing the INSERT
        List<Profile> profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        Boolean isIntegration = profile[0].Name.equalsIgnoreCase('Integration');
        if (isIntegration) {
            // Integration will provide the Latest Enagement Name (Label) as Core_Engagement_Name__c and Engagement Code as the Core_ExtId__c (second token after splitting by ';')
            // We need to make sure that the supplied Engagement Code / Label exists in the Engagement (Core_Engagement__c) Master.
            listsMap = getEngagementsToInsert(newList);
        } 
        
        updateList = listsMap.get('UPDATE');
        if ( updateList != null && updateList.size() > 0 ) {
            update updateList;
        }
        
        insertList = listsMap.get('INSERT');
        if ( insertList != null && insertList.size() > 0 ) {
            insert insertList;
        }
        
        return;
    }
    
    
    private static Map<String, List<sObject>> getEngagementsToInsert(List<Core_Contact_Engagement__c> contactEngagementList) {
        Map<String, List<sObject>> listsMap = new Map<String, List<sObject>>();
        List<sObject> insertList= new List<sObject>(); 
        List<sObject> updateList= new List<sObject>();
        Map<String,Core_Engagement__c> insertMap= new Map<String,Core_Engagement__c>(); 
        Map<String,Core_Engagement__c> updateMap= new Map<String,Core_Engagement__c>();
        Core_Engagement__c engagement;
        Map<String,Core_Engagement__c> engagementMap = getEngagementMap();
        for ( Core_Contact_Engagement__c contactEngagement : contactEngagementList ) {
            // Get the engagement Code from the contactEngagement
            if (contactEngagement.Core_ExtId__c !=null && contactEngagement.Core_ExtId__c.split(';').size() > 1) {
                String engagementCode = contactEngagement.Core_ExtId__c.split(';')[1];
                
                if ( engagementMap.containsKey(engagementCode) ) {
                    // If the engagement Label or upper/lower case of code was changed in ERPM we need to update the engagement master
                    engagement = engagementMap.get(engagementCode);
                    if ( engagement.Name != contactEngagement.Core_Engagement_Name__c ) {
                        engagement.Name = contactEngagement.Core_Engagement_Name__c;
                        updateMap.put( engagementCode, engagement );
                    }
                } else {
                    // New Contact Engagement code/label does not already exist in the Engagement master so we need to insert it
                    engagement = new Core_Engagement__c();
                    engagement.Core_Engagement_Code__c = engagementCode;
                    engagement.Core_Editable__c = false;
                    engagement.Name = contactEngagement.Core_Engagement_Name__c;
                    insertMap.put( engagementCode, engagement );
                } 
                contactEngagement.Core_Engagement__c = engagement.Id;
            }
        }
        for (Core_Engagement__c item : updateMap.values()) {
            updateList.add(item);
        }
        for (Core_Engagement__c item : insertMap.values()) {
            insertList.add(item);
        }
        listsMap.put('INSERT',insertList);
        listsMap.put('UPDATE',updateList);
        return listsMap; 
    }
    
    public static void createExternalId(List<Core_Contact_Engagement__c> newList) {
        // Is ERPM (via Integration Profile) doing the modification
        List<Profile> profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        if ( profile[0].Name.equalsIgnoreCase('Integration') == false ) {
            for ( Core_Contact_Engagement__c contactEngagement : newList ) {
                contactEngagement.Core_ExtId__c = contactEngagement.Core_Contact__c + ';' + contactEngagement.Core_Engagement_Code__c;
            }  
        }
    }
    
    private static Map<String,Core_Engagement__c> getEngagementMap() {
        // Put all the unique engagements into a map for fast lookup
        List<Core_Engagement__c> engagementList = [Select Id, Core_Engagement_Code__c, Name FROM Core_Engagement__c];
        Map<String,Core_Engagement__c> engagementMap = new Map<String,Core_Engagement__c>();
        
        for (Core_Engagement__c engagement : engagementList) {
            engagementMap.put(engagement.Core_Engagement_Code__c, engagement);
        }
        return engagementMap;
    }
    
}