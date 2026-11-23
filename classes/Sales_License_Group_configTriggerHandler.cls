/*********************************************************************************************************************
Class Name    : Sales_License_Group_configTriggerHandler
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           31-May-2021              Sales License Group Switch config Trigger Handler
* *********************************************************************************************************************/
public class Sales_License_Group_configTriggerHandler extends TriggerHandler{
    public override void beforeInsert() {
        Sales_License_Group_configTriggerUtil.checkForDuplicateLicGroupSwitchConfig((List<Sales_License_Group_Switch_config__c>)Trigger.New);
    }
    public override void afterInsert() {
        Sales_License_Group_configTriggerUtil.updateLicenseParameter((List<Sales_License_Group_Switch_config__c>)Trigger.New);
    }
    public override void afterUpdate() {
        Sales_License_Group_configTriggerUtil.updateLicenseParameter((List<Sales_License_Group_Switch_config__c>)Trigger.New);
    }
    public override void afterDelete() {
        Sales_License_Group_configTriggerUtil.updateLicenseParameter((List<Sales_License_Group_Switch_config__c>)Trigger.Old);
    }
}