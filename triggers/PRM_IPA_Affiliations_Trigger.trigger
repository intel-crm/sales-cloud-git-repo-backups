/***********************************************************************************************************************************************
Trigger Name:  PRM_IPA_Affiliations_Trigger
Created Date: 25 Aug 2022
Function    : Trigger for the IPA Affiliation Object

Modification Log :
* Developer                     Date                Description                                     TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Shraddha More                 25/08/2022         Trigger for PRM_IPA_Affiliation__c          PRM_IPA_Affiliations_Trigger
*************************************************************************************************************************************************/


trigger PRM_IPA_Affiliations_Trigger on PRM_IPA_Affiliation__c (before Insert,before update, after insert, after update) {
    
    new PRM_IPA_Affiliation_TriggerHandler().run();
    
}