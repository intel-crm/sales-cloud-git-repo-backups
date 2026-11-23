/****************************************************************************************************
Apex Class Name : DistyVisibilityTriggerHandler
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Trigger Handler class for Disty Visibility trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sushmita                     01/05/2021               Created
*****************************************************************************************************/
public class DistyVisibilityTriggerHandler extends TriggerHandler {
    /************************************************************************************************************
    *Method Name : afterInsert
    *Created Date: 08/13/2021
    *Author: Sushmita
    *Description : Performs operations on after insert context of trigger.
    ************************************************************************************************************/
    /*public override void afterInsert() {
        if(isActive('PSG_Disty_Visibility_After_Insert')){
            PSG_DistyVisibilityBusinessLogic.afterInsertOperations((List<core_cpq_disty_visibility__c>)Trigger.new,(Map<Id,core_cpq_disty_visibility__c>)Trigger.oldMap,Trigger.isInsert);
        }
    }
    
    /************************************************************************************************************
    *Method Name : afterDelete
    *Created Date: 08/13/2021
    *Author: Sushmita
    *Description : Performs operations on after delete context of trigger.
    ************************************************************************************************************/
    /*public override void afterDelete(){
        if(isActive('PSG_Disty_Visibility_After_Delete')){
            PSG_DistyVisibilityBusinessLogic.afterDeleteOperations((List<core_cpq_disty_visibility__c>)Trigger.old,(Map<Id,core_cpq_disty_visibility__c>)Trigger.oldMap,Trigger.isDelete);
        }
    }
    */
}