/******************************************************************************************************************************************
Class Name  : Core_ContactEngagement_Dispatcher
Version     : 1.0 
Created Date: 26 APR 2016
Function    : Handles all trigger logic for the object Core_Contact_Engagement__c.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------    
* Troy Hofeling             04/27/2016              Original version
*****************************************************************************************************************************************/
public class Core_ContactEngagement_Dispatcher {
    
    // "Before" logic
    public static void beforeMethod(List<Core_Contact_Engagement__c> oldList, List<Core_Contact_Engagement__c> newList, Map<Id,Core_Contact_Engagement__c> oldMap, Map<Id,Core_Contact_Engagement__c> newMap) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            //if (Trigger.isInsert) {
                Core_ContactEngagementHandler.validateUniqueEngagement(newList);
            //}
            Core_ContactEngagementHandler.createExternalId(newList);
            Core_ContactEngagementHandler.checkEngagementExistsInMaster(oldList, newList, oldMap, newMap);
        }

    }
    
    public static void afterMethod(List<Core_Contact_Engagement__c> oldList, List<Core_Contact_Engagement__c> newList, Map<Id,Core_Contact_Engagement__c> oldMap, Map<Id,Core_Contact_Engagement__c> newMap) {
        

    }
   
}