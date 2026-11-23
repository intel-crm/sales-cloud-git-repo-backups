/********************************************************************************************************************
Apex Class Name:  Core_Batch_ReprocessLeadShare
Version     : 1.0 
Created Date: 19 Nov 2021
Function    : Batch class to reprocess Lead sharing as part of new Design
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Sanket Mahajan            11/19/16                 Initial Creation
*********************************************************************************************************************/

global class Core_Batch_ReprocessLeadShare implements Database.Batchable<sObject>, Database.Stateful {
    Set<id> mpIdSetBatch;
    global List<lead> mainLeadList = new List<lead>();
    //constructor
    global Core_Batch_ReprocessLeadShare(Set<id> mpIdSet){
        mpIdSetBatch = new Set<id>();
        mpIdSetBatch = mpIdSet;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String RecordType = 'Partner_Lead';
        String LeadStatus = 'New';
        String Status = 'PRL';
        String LeadState = 'Unclaimed';
        String LeadOwner = '';
        system.debug('mpIdSetBatch_>'+mpIdSetBatch);
        //mainLeadList = [SELECT id,Core_Remove_Current_Sharing_Ind__c, Core_Reprocess_Lead_Sharing__c from LEAD where Core_MPI_Id__c in:mpIdSetBatch and RecordType.DeveloperName =:RecordType and Core_Lead_Status__c =:LeadStatus and Status =:Status and Core_Lead_State__c =:LeadState and Core_Partner_Lead_Owner__c =:LeadOwner ];
        
        //system.debug('mainLeadList size->'+mainLeadList);
        String query = 'SELECT id,Core_Remove_Current_Sharing_Ind__c, Core_Reprocess_Lead_Sharing__c from LEAD where Core_MPI_Id__c in:mpIdSetBatch and RecordType.DeveloperName =:RecordType';
         return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<lead> scope){
        try{
            Boolean allOrNone = false;
            mainLeadList.addAll(scope);
            system.debug('mainLeadList execute'+mainLeadList);
            List<Lead> tempList1 = new List<Lead>();
            List<Lead> tempList2 = new List<Lead>();
            
            for(lead ld : scope){
                //Lead LObject = new Lead();
                //LObject.id = ld.id;
                Ld.Core_Remove_Current_Sharing_Ind__c = true;
                ld.Core_Reprocess_Lead_Sharing__c =false;
                //tempList1.add(LObject);
            }
            
            database.update(scope,allOrNone);
            if(Test.isRunningTest()){
                allOrNone = null;
                database.update(scope,allOrNone);
            }
        }
        Catch(Exception e){
            Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_Batch_ReprocessLeadShare', Core_Exception__c  = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_Login_User_Id__c= userInfo.getUserId());
            insert ExcepLog;
        }
        
    }
    global void finish(Database.BatchableContext BC){
        system.debug('mainLeadList-->'+mainLeadList);
        if(mainLeadList.size()>0){
            Core_Batch_ReprocessLeadShareSecndRun b=new Core_Batch_ReprocessLeadShareSecndRun(mainLeadList);
            database.executebatch(b,100); 
        }
    }
}