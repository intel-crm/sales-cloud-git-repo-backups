/******************************************************************************************************************************
Apex Class Name:  PRM_Email_Log_Trigger
    Version     : 1.0
    Created Date: 01 JUN 2021
    Function    : Trigger for the object PRM_EmailLog__c
    
Modification Log :
     * Developer                     Date                       Description
 * ----------------------------------------------------------------------------------------------------------------------------
 * GopiKrishna Vankadari       01/06/2021              It calls the run method of TriggerHandler of 'PRM_EmailLog__c' object

 *******************************************************************************************************************************/
trigger PRM_Email_Log_Trigger on PRM_EmailLog__c (after insert,after update) {
    system.debug('EmailLog trigger entry');
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_Email_Log_TriggerHandler().run();
    }
}