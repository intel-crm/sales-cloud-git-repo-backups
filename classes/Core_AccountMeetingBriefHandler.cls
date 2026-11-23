/******************************************************************************************************************************************
Class Name  : Core_AccountMeetingBriefHandler
Version     : 1.0 
Created Date: 05 OCT 2015
Function    : Handles all trigger logic for the object Account Meeting Brief.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------    
* Dave Hood                 03/18/2015              Original version
*****************************************************************************************************************************************/
public class Core_AccountMeetingBriefHandler {

    // Static variables to prevent unwanted re-entry
    public static Boolean accountTeamMembersAdded = false;
    
    // DML static variables to perform all DML in consolidated operations at the end
    public static List<sObject> objectsToInsert = new List<sObject>();
    public static Boolean objectsToInsertCounter = false;
    
    public static Map<Id,sObject> objectsToUpdate = new Map<Id,sObject>();
    public static Boolean objectsToUpdateCounter = false;
    
    public static Map<Id,sObject> objectsToDelete = new Map<Id,sObject>();
    public static Boolean objectsToDeleteCounter = false;

	// Map of our Trigger execution flags
	public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution;
    
    // Handle all "Before" logic on Account Meeting Briefs
    public static void beforeMethod(List<Account_Meeting_Brief__c> oldList, List<Account_Meeting_Brief__c> newList,
                                   Map<Id,Account_Meeting_Brief__c> oldMap, Map<Id,Account_Meeting_Brief__c> newMap)
    {
        //mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
    	//if (Trigger.isInsert) {
        	// Placeholder for future code
        //}
        //if (Trigger.isUpdate) {
        	// Placeholder for future code
        //}
        //if (Trigger.isDelete) {
        	// Placeholder for future code
        //}
        
        // Perform any inserts, if we have anything to insert
        /*if (!objectsToInsertCounter) {
            objectsToInsertCounter = true;
            
            if (objectsToInsert.size() > 0) {
                insert objectsToInsert.values();
                objectsToInsert.clear();
            }
        }*/
        
        // Perform any updates, if we have anything to update
        /*if (!objectsToUpdateCounter) {
            objectsToUpdateCounter = true;
            
            if (objectsToUpdate.size() > 0) {
                update objectsToUpdate.values();
                objectsToUpdate.clear();
            }
        }*/
        
        // Perform any deletions, if we have anything to delete
        /*if (!objectsToDeleteCounter) {
            objectsToDeleteCounter = true;
            
            if (objectsToDelete.size() > 0) {
                delete objectsToDelete.values();
                objectsToDelete.clear();
            }
        }*/
    }
    
    // Handle all "After" logic on Account Meeting Briefs
    public static void afterMethod(List<Account_Meeting_Brief__c> oldList, List<Account_Meeting_Brief__c> newList,
                                   Map<Id,Account_Meeting_Brief__c> oldMap, Map<Id,Account_Meeting_Brief__c> newMap)
    {        
        mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
    	if (Trigger.isInsert) {
            Core_AccountMeetingBriefAccountTeam.addAccountOwnerAndTeam(oldList, newList, oldMap, newMap);
        }
        //if (Trigger.isUpdate) {
        	// Placeholder for future code
        //}
        //if (Trigger.isDelete) {
        	// Placeholder for future code
        //}
        
        // Perform any inserts, if we have anything to insert
        if (!objectsToInsertCounter) {
            objectsToInsertCounter = true;
            
            if (objectsToInsert.size() > 0) {
                insert objectsToInsert;
                objectsToInsert.clear();
            }
        }
        
        // Perform any updates, if we have anything to update
        /*if (!objectsToUpdateCounter) {
            objectsToUpdateCounter = true;
            
            if (objectsToUpdate.size() > 0) {
                update objectsToUpdate.values();
                objectsToUpdate.clear();
            }
        }*/
        
        // Perform any deletions, if we have anything to delete
        /*if (!objectsToDeleteCounter) {
            objectsToDeleteCounter = true;
            
            if (objectsToDelete.size() > 0) {
                delete objectsToDelete.values();
                objectsToDelete.clear();
            }
        }*/
    }
}