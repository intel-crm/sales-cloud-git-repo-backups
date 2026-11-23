/****************************************************************************************************
Apex Class Name : ContentVersionTriggerHandler
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Handler class for ContentVersion trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shreyash                     01/05/2021               Created
*****************************************************************************************************/
public class ContentVersionTriggerHandler extends TriggerHandler{	
    public override void afterInsert() {
        //PSG_ContentVersionBusinessLogic.afterInsertUpdateOperations((List<ContentVersion>)Trigger.new,(Map<Id,ContentVersion>)Trigger.oldMap,Trigger.isInsert);
    }
}