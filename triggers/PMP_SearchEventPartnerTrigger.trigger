/****************************************************************************************************************************************
* Class Name  : PMP_SearchEventPartnerTrigger 
* Version     : 1.0 
* Created Date: 17-FEB-2020
* Modification Log :
* Created By : Tanzanite Team Infosys
* * Developer                 Date         Description
* ----------------------------------------------------------------------------
* Prabuddh                  02/17/2020     Created ver 1.0
*****************************************************************************************************************************************/

trigger PMP_SearchEventPartnerTrigger on PMP_Marketplace_Event_Partner__c (before insert, after insert, after delete) {
   new PMP_SearchEventPartnerTriggerHandler().run();
}