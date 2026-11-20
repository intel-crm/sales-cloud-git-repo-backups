/********************************************************************************************************************
Apex Test Class Name:  Core_IPS_OpportunityPAR_Controller_Test
Version     : 1.0
Function    : class called from Core_IPS_OppParOrgAdmin_Trigger
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Farooq                              /10/2021               adding approval process
*******************************************************************************************************************/
public without sharing class Core_IPS_OppOrgAdmin_Trigger_Dispatcher {
public static void afterMethod(List<Core_IPS_Opppar_SuppOrgAdmin__c> newList, Map<Id,Core_IPS_Opppar_SuppOrgAdmin__c> oldMap){
            Core_IPS_OppOrgAdminTriggerHandler.submitForApproval(newList, oldMap);
    }
}