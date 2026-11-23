/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PaymentRun_TriggerHandler 
* Version           : 1.0 
* Created Date      : 01-30-2019
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AD       01-30-2019        Trigger Handler class.
*****************************************************************************************************************************************/
public class Core_MDF_PaymentRun_TriggerHandler extends TriggerHandler {
    
    /**
    * @description : Method to execute the actions in before insert context of Core_MDF_PaymentRun_Trigger
    */
    public override void beforeInsert(){
     
        if (isActive('Core_MDF_DuplicateCheckOnBeforeInsert')) {
        Core_MDF_PaymentRunHelper.duplicateCheckOnInsert(Trigger.NEW);
        }
    }
    
    /**
    * @description : Method to execute the actions in before update context of Core_MDF_PaymentRun_Trigger
    */
    public override void beforeUpdate(){
        
        if (isActive('Core_MDF_DuplicateCheckOnBeforeUpdate')) {
           Core_MDF_PaymentRunHelper.duplicateCheckOnUpdate(Trigger.NEW, (Map<Id,Core_MDF_Payment_Run__c>)Trigger.OldMap); 
        }
    }
    
    /**
    * @description : Method to execute the actions in after insert context of Core_MDF_PaymentRun_Trigger
    */
    public override void afterInsert(){
        
        if (isActive('Core_MDF_SchedulePaymentRunOnAfterInsert')) {
            Core_MDF_PaymentRun_ServiceHandler.schedulePaymentRun(Trigger.NEW);
        }
    }
    
    /**
    * @description : Method to execute the actions in after update context of Core_MDF_PaymentRun_Trigger
    */
    public override void afterUpdate() {
        
        if (isActive('Core_MDF_SchedulePaymentRunOnAfterUpdate')) {
            Core_MDF_PaymentRun_ServiceHandler.schedulePaymentRunOnUpdate(Trigger.NEW,(Map<Id,Core_MDF_Payment_Run__c>) Trigger.oldMap);
        }
    }
    
    /**
    * @description : Method to execute the actions in before delete context of Core_MDF_PaymentRun_Trigger
    */
    public override void beforeDelete() {
        
        if (isActive('Core_MDF_AbortPaymentJobOnBeforeDelete')) {
            Core_MDF_PaymentRun_ServiceHandler.abortPaymentJobOnDelete(Trigger.OLD);
        }
       
        if (isActive('Core_MDF_PreventDeleteOnBeforeDelete')) {
            Core_MDF_PaymentRunHelper.preventDeleteWhenNotInScheduledState(Trigger.OLD);
        }
    }
    
}