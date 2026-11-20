/******************************************************************************************************************************
Apex Class Name:  PRM_AccountContactRel_Trigger
    Version     : 1.0
    Created Date: 21 NOV 2018
    Function    : Trigger for the object PRM_Account_Contact_Relationship__c
     *******************************************************************************************************************************/
trigger PRM_AccountContactRel_Trigger on PRM_Account_Contact_Relationship__c (after insert, before insert, before update, after update) {
    Boolean triggerhandlerSwitch;
    triggerhandlerSwitch = Boolean.valueof(System.label.PRM_OptimizedTriggerHandler);
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        if(triggerhandlerSwitch){
            new PRM_AcctContRel_TriggerHandlerNew().run();
        }else{
            new PRM_AcctContRel_TriggerHandler().run();
        }
    }
}