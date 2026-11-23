/****************************************************************************************************
Apex Class Name : TPTInnovationHandler
Version         : 1.0 
Created Date    : 24/04/2024
Function        : Handler class for the trigger 'TPTInnovation'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Utkarsh                  24/04/2024                Created
*****************************************************************************************************/
public class TPTInnovationHandler extends TriggerHandler{
   public override void beforeInsert() {
        
    }
    //public override void beforeUpdate() {}
    public override void afterInsert() {
        TPT_Tracker.CreateUpdateTPTTracker(Trigger.New);                
    }
    public override void afterUpdate() {TPT_Tracker.updateTPTTracker(Trigger.New,(Map<Id,InnovationTracker__c>)Trigger.oldMap);
    }
}