/*********************************************************************************************************************
Class Name    : Sales_License_SwitchTriggerHandler
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           13-May-2021              Switch Trigger Handler
* *********************************************************************************************************************/
public class Sales_License_Gen_SwitchTriggerHandler extends TriggerHandler{
    public override void beforeDelete() {
            Sales_License_Gen_SwitchTriggerutil.blockLicenseSwitchDeletion((List<Sales_License_Generator_Switch__c>)Trigger.Old);
    }
}