/***************************************************************************************************************************************
Apex Class Name     : PRM_PartnerAssistConsent_Trigger 
Version             : 1.0
Created Date        : July 2020
Function            : Trigger for PRM_Partner_Assist_Consent__c
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Tejasree                       10-July-2020                    
*************************************************************************************************************************************/
trigger PRM_PartnerAssistConsent_Trigger on PRM_Partner_Assist_Consent__c (before insert,after insert,before update,after update) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_PartnerAssistConsent_Handler().run();
    }
}