/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_Payment_TriggerHandler 
* Version           : 1.0 
* Created Date      : 03-24-2020
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AD       03-24-2020        Trigger Handler class.
*****************************************************************************************************************************************/
public class Core_MDF_Payment_TriggerHandler extends TriggerHandler {       
    /**
    * @description : Method to execute the actions in after update context of Core_MDF_Payment_Trigger
    */
    public override void afterUpdate(){
        if (isActive('Core_MDF_ClaimsToPaidOnAfterUpdate')) {
            //invoke service handler function to update claims to paid
            Core_MDF_Payment_ServiceHandler.updateClaimsToPaid(Trigger.NEW,(Map<Id,Core_MDF_Payment__c>)Trigger.OldMap); 
        }
    }
}