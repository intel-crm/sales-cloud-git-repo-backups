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
    global set<string> contids=new set<string>();
    global string logentires;
    global set<id> accIdSetAssoc=new set<Id>();
    global set<id> accIdSetRemove=new set<Id>();
   
    /*This method fetches all the batch entitlements records which has status as new*/
    global static Database.QueryLocator start(Database.BatchableContext context){
        return database.getQueryLocator('Select id,Name, PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Contact_Id__r.AccountId,PRM_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c, PRM_Contact_Id__r.Core_Login_Status__c,PRM_Entitlement_Id__c,PRM_IsRemove_Ind__c,PRM_Contact_Id__r.PRM_Wechat_Union_Id__c,PRM_Status_Reason_Txt__c from PRM_Batch_Entitlement__c where PRM_Entitlement_Id__c != null AND PRM_Status_Nm__c = \'New\' and (PRM_Contact_Id__r.Core_Login_Status__c != null or PRM_Contact_Id__r.PRM_Wechat_Union_Id__c!=null)');
    }
    /*This method passes all batch entitlements record fetch by query locator to PRM_EntitlementUtility class*/
    global void execute(Database.BatchableContext context, List<PRM_Batch_Entitlement__c> scope){ 
        for(PRM_Batch_Entitlement__c be: scope){
            if(!be.PRM_IsRemove_Ind__c){
            contids.add(be.PRM_Contact_Id__c);
        }
        }
        //Update the Status of the Batch Entitelments records to In-Progress
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        beList = PRM_EntitlementUtility.updateBatchEntitelmentStatus(scope);
        PRM_EntitlementUtility.accIdAssocSet.addAll(accIdSetAssoc);
        PRM_EntitlementUtility.accIdRemoveSet.addAll(accIdSetRemove);
        //Assign or Update Entitelment records to respective contacts 
        PRM_EntitlementUtility.assignContactEntitlements(beList);
        accIdSetAssoc.clear();
        accIdSetRemove.clear();
        
        accIdSetAssoc.addAll(PRM_EntitlementUtility.accIdAssocSet);
        accIdSetRemove.addAll(PRM_EntitlementUtility.accIdRemoveSet);
       
        if(getlogentries.logentries!=null)
        this.logentires=getlogentries.logentries;
        system.debug('---logentry '+getlogentries.logentries);
        system.debug('---logenry '+ this.logentires);
    }
    global void finish(Database.BatchableContext context){
    //getlogentries log=new getlogentries();
    if(contids.size()>0 && System.Label.PRM_Tracker_Enabled=='true')
     System.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps (null,contids,this.logentires,'PRM_EntitlementUtility','Admin'));
    
    } 
}