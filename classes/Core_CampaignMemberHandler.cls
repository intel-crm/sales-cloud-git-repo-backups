/******************************************************************************************************************************************
Class Name  : Core_CampaignMemberHandler
Version     : 1.0 
Created Date: 05 OCT 2015
Function    : Handles all trigger logic for the object Campaign Member. This implements the new trigger framework agreed on in Q3 2015.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 10/05/2015              Original version
* Dave Hood                 03/02/2016              Extended to support "Assign To User ID" lookup as records are inserted
*****************************************************************************************************************************************/
public class Core_CampaignMemberHandler {

    // Static variables to prevent unwanted re-entry
    public static Boolean memberDeletionTaskCleanup = false;
    public static Boolean assignToUserLookup = false;
    
    // DML static variables to perform all DML in consolidated operations at the end
    public static Map<Id,sObject> objectsToInsert = new Map<Id,sObject>();
    public static Boolean objectsToInsertCounter = false;
    
    public static Map<Id,sObject> objectsToUpdate = new Map<Id,sObject>();
    public static Boolean objectsToUpdateCounter = false;
    
    public static Map<Id,sObject> objectsToDelete = new Map<Id,sObject>();
    public static Boolean objectsToDeleteCounter = false;

	// Map of our Trigger execution flags
	public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution;
    
    // Handle all "Before" logic on Campaign Members
    public static void beforeMethod(List<CampaignMember> oldList, List<CampaignMember> newList,
                                   Map<Id,CampaignMember> oldMap, Map<Id,CampaignMember> newMap)
    {
        mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
    	if (Trigger.isInsert) {
        	Core_CampaignMemberInfoLookup.assignToUserLookup(oldList, newList, oldMap, newMap);
        }
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
    
    // Handle all "After" logic on Campaign Members
    public static void afterMethod(List<CampaignMember> oldList, List<CampaignMember> newList,
                                   Map<Id,CampaignMember> oldMap, Map<Id,CampaignMember> newMap)
    {        
        mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
    	//if (Trigger.isInsert) {
        	// Placeholder for future code
        //}
        //if (Trigger.isUpdate) {
        	// Placeholder for future code
        //}
        if (Trigger.isDelete) {
            Core_CampaignMemberTask.memberDeletionTaskCleanup(oldList, newList, oldMap, newMap);
        }
        
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
        if (!objectsToDeleteCounter) {
            objectsToDeleteCounter = true;
            
            if (objectsToDelete.size() > 0) {
                delete objectsToDelete.values();
                objectsToDelete.clear();
            }
        }
    }
}