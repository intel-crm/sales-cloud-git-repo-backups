/***************************************************************************************************************************************
Apex Class Name     : PRM_Contact_Entitlements_Insert_batch 
Version             : 1.0
Created Date        : July 2019
Function            : Batch class to assign Contact Entitlements
Maximum Batch Size  : 10
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                       22-July-2019                     Start Method returns all the Benefit_Entitlement object records which are Created by PRM_BenefitsUpdateBatch. 
                        based on the entitlements 
*************************************************************************************************************************************/
global class PRM_Contact_Entitlements_Insert_batch implements Database.Batchable<sObject>,Database.Stateful{
    
    /*This method fetches all the batch entitlements records which has status as new*/
    global static Database.QueryLocator start(Database.BatchableContext context){
        return database.getQueryLocator('Select id,Name, PRM_Account_Id__c,PRM_Contact_Id__c, PRM_Entitlement_Id__c,PRM_IsRemove_Ind__c from PRM_Batch_Entitlement__c where PRM_Entitlement_Id__c != null AND PRM_Status_Nm__c = \'New\'');
    }
    /*This method passes all batch entitlements record fetch by query locator to PRM_EntitlementUtility class*/
    global void execute(Database.BatchableContext context, List<PRM_Batch_Entitlement__c> scope){
        System.debug('scope of second batch--'+scope);
        PRM_EntitlementUtility.assignContactEntitlements(scope);
    }
    global void finish(Database.BatchableContext context){
    } 
}