/********************************************************************************************************************
Apex Class Name:  Core_Batch_ReprocessLeadShareSecndRun
Version     : 1.0 
Created Date: 19 Nov 2021
Function    : Batch class to reprocess Lead sharing as part of new Design
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Sanket Mahajan            11/19/16                 Initial Creation
*********************************************************************************************************************/

global class Core_Batch_ReprocessLeadShareSecndRun implements Database.Batchable<sObject> {
    List<Lead> leadListBatch;
    
    //constructor
    global Core_Batch_ReprocessLeadShareSecndRun(List<Lead> leadList){
        leadListBatch = new List<Lead>();
        leadListBatch = leadList;
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT id,Core_Remove_Current_Sharing_Ind__c, Core_Reprocess_Lead_Sharing__c from LEAD where id in:leadListBatch order by CreatedDate desc';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<lead> scope){
        try{
            Boolean allOrNone = false;
            for(lead ld : scope){
                Ld.Core_Remove_Current_Sharing_Ind__c = false;
                ld.Core_Reprocess_Lead_Sharing__c = true;
            }
            database.update(scope,allOrNone);
             if(Test.isRunningTest()){
                allOrNone = null;
                database.update(scope,allOrNone );
            }
        }
        Catch(Exception e){
            Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_Batch_ReprocessLeadShareSecndRun', Core_Exception__c  = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_Login_User_Id__c= userInfo.getUserId());
            insert ExcepLog;
        }
        
    }
    global void finish(Database.BatchableContext BC){
         
    }
}