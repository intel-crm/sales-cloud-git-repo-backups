/********************************************************************************************************************
Apex Test Class Name:  Core_IPS_OpportunityPAR_Controller_Test
Version     : 1.0
Function    : called in Core_IPS_OppOrgAdmin_Trigger_Dispatcher 
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Farooq 							  /10/2024				 Modified the approval prcess as part of ATHR (TWC745-6578)
*******************************************************************************************************************/
public without sharing class Core_IPS_OrgAdminTriggerHandler {
    public final static String GROUPMEMBER = 'GroupMember';
    public static void submitForApproval(List<Core_IPS_Product_Organization_Admin__c> newList, Map<Id,Core_IPS_Product_Organization_Admin__c> oldMap){
        Core_IPS_OpportunityParApproval opppar= new Core_IPS_OpportunityParApproval(GROUPMEMBER, newList, oldMap);
        ID jobID = System.enqueueJob(opppar);
    }
}