/****************************************************************************************************************************************
* Class Name  : PMP_SearchEventOfferingTrigger 
* Version     : 1.0 
* Created Date: 17-FEB-2020
* Modification Log :
* Created By : Tanzanite Team Infosys
* * Developer                 Date         Description
* ----------------------------------------------------------------------------
* Prabuddh                  02/17/2020     Created ver 1.0
*****************************************************************************************************************************************/

trigger PMP_SearchEventOfferingTrigger on PMP_Marketplace_Event_Offering__c (before insert, after insert, after delete) {
    //new PMP_SearchEventOfferingTriggerHandler().run(); //IPA2.0:TWC729-8114 Topics Removal/Event Removal
}