/***********************************************************************************************************************************************
Trigger Name:  PRM_IPA_Affiliations_Trigger
Created Date: 25 Aug 2022
Function    : Trigger for the IPA Affiliation Object

Modification Log :
* Developer                     Date                Description                                     TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Shraddha More                 25/08/2022         Trigger for PRM_IPA_Affiliation__c          PRM_IPA_Affiliations_Trigger
*************************************************************************************************************************************************/


trigger PRM_IPA_Affiliations_Trigger on PRM_IPA_Affiliation__c (before Insert,before update,after Insert,after update) {
    // bypass added by Dinesh as part of IPA2.0 Refresh change
    if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
        new PRM_IPA_Affiliation_TriggerHandler().run();
    }
    
}