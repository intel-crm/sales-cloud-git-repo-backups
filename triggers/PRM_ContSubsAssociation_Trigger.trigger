/******************************************************************************************************************************
Apex Class Name : PRM_ContSubsAssociation_Trigger 
Version         : 1.0 
Created Date    : 10 Dec 2018
Created By      : Anupam Agarwal
Function        : Trigger for the object PRM_ContactSubscriptionAssociation__c
*******************************************************************************************************************************/
trigger PRM_ContSubsAssociation_Trigger on PRM_ContactSubscriptionAssociation__c (before insert, after insert, before update,after update) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
    new PRM_CSA_TriggerHandler().run();
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        //ContactERPMIntegrationStatusHandler.parseInputList(Trigger.new);
    }    
}