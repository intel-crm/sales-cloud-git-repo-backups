/******************************************************************************************************************************
Apex Class Name:  PRM_Bulk_DataLoad_Trigger
Version     : 1.0 
Created Date: 01 OCT 2021
Function    : Trigger for Bulk Data Upload Records 

Modification Log :
* Developer                     Date                Description
* ----------------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/10/2021           Trigger Logic for Bulk Data Upload Records 
****************************************************************************************************************************************/
trigger PRM_Bulk_DataLoad_Trigger on PRM_Bulk_Data_Upload__c (before Insert,after insert,after update) {
    system.debug('Bulk DataLoad trigger entry');
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_Bulk_DataLoad_TriggerHandler().run();
    }
}