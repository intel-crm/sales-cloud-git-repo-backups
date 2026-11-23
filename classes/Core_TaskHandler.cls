/**************************************************************************************
Apex Class Name:  Core_TaskHandler
Version     : 1.0 
Created Date: 30 SEP 2014
Function    : Handler Class for trigger on Task object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             30/09/2014              Original Version
*************************************************************************************/
public class Core_TaskHandler
{
    /*
    * Method name  : lastActivityDateHandler
    * Description  : Method to call the activity handler to update the Last Activity Date field on related lead record on creation/updation of task. 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap
    */
    public static void tasklastActivityUpdateOnLeadUpsert(Map<Id,sObject> mapIdOldSobject,Map<Id,sObject> mapIdNewSobject)
    {
        Core_ActivityHandler.lastActivityDateUpdate(mapIdOldSobject,mapIdNewSobject);
    }
    
    /*
    * Method name  : lastActivityDateHandler
    * Description  : Method to call the activity handler to update the Last Activity Date field on related lead record on deletion of task. 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap
    */
    public static void tasklastActivityUpdateOnLeadDelete(Map<Id,sObject> mapIdOldSobject)
    {
        Core_ActivityHandler.lastActivityDateUpdateOnDelete(mapIdOldSobject);
    }
}