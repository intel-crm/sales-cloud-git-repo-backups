/*********************************************************************************************************************
Class Name    : Sales_BypassCPQTriggerHandler
Version       : 1.0
Created Date  : Jan 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma          21-Sept-2021              Sales_BypassCPQTriggerHandler
*/
public without sharing class Sales_BypassCPQTriggerHandler extends TriggerHandler {
	public override void afterUpdate(){
        System.debug('SBQQ Trigger Control for disabling from afterUpdate');
        SBQQ.TriggerControl.disable();
        if(!SBQQ.TriggerControl.isEnabled()){
            System.debug('SBQQ Trigger Control is disabled from after updated');
        }
    }
    public override void beforeUpdate(){
        System.debug('SBQQ Trigger Control for disabling from beforeUpdate');
        SBQQ.TriggerControl.disable();
		if(!SBQQ.TriggerControl.isEnabled()){
            System.debug('SBQQ Trigger Control is disabled from before updated');
        }
    }
}