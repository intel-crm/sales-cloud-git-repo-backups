/****************************************************************************************************
Apex Class Name : DistributorMarginTriggerHandler
Version         : 1.0 
Created Date    : 07/07/2021
Function        : Trigger handler class for Distiributor margin trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sushmita                  07/07/2021                 Created
*****************************************************************************************************/
public class DistributorMarginTriggerHandler extends TriggerHandler {
    /************************************************************************************************************
	*Method Name : beforeInsert
	*Created Date: 08/13/2021
	*Author: Sushmita
	*Description : Performs operations on before insert context of trigger.
	************************************************************************************************************/
    public override void beforeInsert(){
        PSG_DistributorMarginBusinessLogic.beforeInsertUpdateOperations((List<core_cpq_distributor_margin__c>)Trigger.new,(Map<Id,core_cpq_distributor_margin__c>)Trigger.oldMap,Trigger.isInsert);
    }
}