/******************************************************************************************************************************************
Class Name  : Core_ProductHandler
Version     : 1.0 
Created Date: 16 OCT 2015
Function    : Handles all trigger logic for the object Product2. This implements the new trigger framework agreed on in Q3 2015.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 10/16/2015              Original version
*****************************************************************************************************************************************/
public class Core_ProductHandler {

    // Static variables to prevent unwanted re-entry
    public static Boolean alreadyUpdatedOppProductField = false;
    
    // DML static variables to perform all DML in consolidated operations at the end
    public static Map<Id,sObject> objectsToInsert = new Map<Id,sObject>();
    public static Boolean objectsToInsertCounter = false;
    
    public static Map<Id,sObject> objectsToUpdate = new Map<Id,sObject>();
    public static Boolean objectsToUpdateCounter = false;
    
    public static Map<Id,sObject> objectsToDelete = new Map<Id,sObject>();
    public static Boolean objectsToDeleteCounter = false;

	// Map of our Trigger execution flags
	public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution;
    
    
    // Handle all "After" logic on Products
    public static void afterMethod(List<Product2> oldList, List<Product2> newList, Map<Id,Product2> oldMap, Map<Id,Product2> newMap)
    {        
        mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
    	//if (Trigger.isInsert) {
        	// Placeholder for future code
        //}
        if (Trigger.isUpdate) {
            Core_ProductOpportunity.oppProductConcatenatedFieldUpdate(oldList, newList, oldMap, newMap);
        }
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
        if (!objectsToUpdateCounter) {
            objectsToUpdateCounter = true;
            
            if (objectsToUpdate.size() > 0) {
                update objectsToUpdate.values();
                objectsToUpdate.clear();
            }
        }
        
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