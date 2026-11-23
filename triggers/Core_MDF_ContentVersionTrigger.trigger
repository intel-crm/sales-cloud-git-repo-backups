/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_ContentVersionTrigger
* Version           : 1.0 
* Created Date      : 29-JAN-2021
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - TS       29-JAN-2021        Trigger on Content Version object
*****************************************************************************************************************************************/
trigger Core_MDF_ContentVersionTrigger on ContentVersion (after insert, before update) {
    //Invoke handler methods
    Core_MDF_ContentVersionTriggerHandler contentVersionTriggerHandler = new Core_MDF_ContentVersionTriggerHandler();
    contentVersionTriggerHandler.run();
}