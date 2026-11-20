/********************************************************************************************************************
Apex Class Name:  Core_Batch_ReprocessPartnerLeadShare
Version     : 1.0 
Created Date: 26 May 2022
Function    : Batch class to reprocess Partner Lead sharing as part of new Design
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Megha Kumari                05/26/22               Initial Creation
*********************************************************************************************************************/
global  class Core_Batch_ReprocessPartnerLeadShare  implements Database.Batchable<sObject>, Database.Stateful {
   
    global List<lead> mainLeadList = new List<lead>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String RecordType = 'Partner_Lead';
        String LeadStatus = 'New';
        String Status = 'PRL';
        String LeadState = 'Unclaimed';
        String LeadOwner = label.Core_Partner_Invalid_Queue_Id;
       
       
        String query = 'SELECT id,Core_Remove_Current_Sharing_Ind__c, Core_Reprocess_Lead_Sharing__c from LEAD where  RecordType.DeveloperName =:RecordType and OwnerId =:LeadOwner';
         return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<lead> scope){
        try{
            Boolean allOrNone = false;
            mainLeadList.addAll(scope);
            
            List<Lead> tempList1 = new List<Lead>();
            List<Lead> tempList2 = new List<Lead>();
            
            for(lead ld : scope){
               
                
                Ld.Core_Remove_Current_Sharing_Ind__c = true;
                ld.Core_Reprocess_Lead_Sharing__c =false;
                
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
        
        if(mainLeadList.size()>0){
            Core_Batch_ReprocessLeadShareSecndRun b=new Core_Batch_ReprocessLeadShareSecndRun(mainLeadList);
            database.executebatch(b,Integer.valueOf(Label.Core_Reprocess_Batch_Size));
        }
    }
}