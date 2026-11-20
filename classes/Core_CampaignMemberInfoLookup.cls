/******************************************************************************************************************************************
Class Name  : Core_CampaignMemberInfoLookup
Version     : 1.0 
Created Date: 02 MAR 2016
Function    : Used to look up information to populate onto Campaign Member records as they're inserted
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 03/02/2016              Original version
*****************************************************************************************************************************************/
public class Core_CampaignMemberInfoLookup {

    public static void assignToUserLookup(List<CampaignMember> oldList, List<CampaignMember> newList,
                                          Map<Id,CampaignMember> oldMap, Map<Id,CampaignMember> newMap)
    {
        if (!Core_CampaignMemberHandler.assignToUserLookup) {
            
            // Ensure no re-entry
            //Core_CampaignMemberHandler.assignToUserLookup = true;
            
            // Only execute this logic if the trigger is turned on
            if (!Core_CampaignMemberHandler.mapFunctionalityNameTriggerExecution.isEmpty()) {
                if (Core_CampaignMemberHandler.mapFunctionalityNameTriggerExecution.containsKey('assignToUserLookup') && 
                   Core_CampaignMemberHandler.mapFunctionalityNameTriggerExecution.get('assignToUserLookup').Core_Active__c)
                {
                    // Pull all User IDs & Email addresses for records being inserted, where a lookup needs to be done, and place them 
                    // in a map of Email to User ID (sorting by IsActive, so if there are multiple, the active one ends up in the map)
                    Set<String> emailAddresses = new Set<String>();
                    for (CampaignMember cm : newList) {
                        if (((cm.Core_Assigned_To_User_ID__c == '') || (cm.Core_Assigned_To_User_ID__c == null)) &&
                            (cm.Core_Assigned_To_User_Email__c != '') && (cm.Core_Assigned_To_User_Email__c != null)) {
                            emailAddresses.add(cm.Core_Assigned_To_User_Email__c);
                            System.debug('##### For Contact ID: ' + cm.ContactId + ', looking up email address: ' + cm.Core_Assigned_To_User_Email__c);
                        }
                    }
                    List<User> usersForLookup = [select Id, Email, IsActive from User where Email in :emailAddresses order by Email, IsActive, Id];
                    Map<String,Id> emailToUserIdMap = new Map<String,Id>();
                    for (User u : usersForLookup) {
                        emailToUserIdMap.put(u.Email, u.Id);
                    }
                    
                    // Iterate through CampaignMembers being inserted, and for each that needed a lookup, where we have a value,
					// update Assigned To User ID based on it
                    for (CampaignMember cm : newList) {
                        if (((cm.Core_Assigned_To_User_ID__c == '') || (cm.Core_Assigned_To_User_ID__c == null)) &&
                            (cm.Core_Assigned_To_User_Email__c != '') && (cm.Core_Assigned_To_User_Email__c != null) &&
                            (emailToUserIdMap.containsKey(cm.Core_Assigned_To_User_Email__c))) {
                                cm.Core_Assigned_To_User_ID__c = emailToUserIdMap.get(cm.Core_Assigned_To_User_Email__c);
                                System.debug('##### For Contact ID: ' + cm.ContactId + ', assigning user ID: ' + cm.Core_Assigned_To_User_ID__c);
                            }
                    }
                }
            }
        }
    }
}