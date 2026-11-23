/**************************************************************************************
Apex Class Name: Core_OpportunityShareRemovalBatch
Version     : 1.0 
Created Date: 24 AUG 2022
Function    : Batch class for the removal of shared opportunity to the delegate approver
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Megha Kumari             24/08/20222              Original Version               
*************************************************************************************/
global without sharing class Core_OpportunityShareRemovalBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<Id> delegateUserRemoveShare= new List<Id>();
    Map<Id,Id> userId=new Map<Id,Id>();
    List<Id> uservalue=new List<Id>();
    global Core_OpportunityShareRemovalBatch(List<Id> delegateShareRemoval ,  Map<Id,Id> userIdNew){
        delegateUserRemoveShare.addAll(delegateShareRemoval);
        userId=userIdNew;
        uservalue.addAll(userId.values());
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id,Core_Opportunity_ID__c,Core_User__c,OwnerId,Core_Manager__c,Core_Deal_win_Goal_Share_Id__c from Core_Delegate_Approver__c where Core_User__c In:delegateUserRemoveShare and Core_Manager__c In: uservalue';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Core_Delegate_Approver__c> scope){
        List<String> oppId = new List<String>();
        List<String> opporShareId= new List<String>();
        List<String> dealId = new List<String>();
        List<Core_Delegate_Approver__c> delegateUpdate= new List<Core_Delegate_Approver__c>();
        for(Core_Delegate_Approver__c deleApp : scope){
            if( deleApp.Core_Manager__c==userId.get(deleApp.Core_User__c)){
                if(deleApp.Core_Opportunity_ID__c!=null && deleApp.Core_Opportunity_ID__c!='')  
                    oppId=deleApp.Core_Opportunity_ID__c.split(',');
                if(deleApp.Core_Deal_win_Goal_Share_Id__c!=null && deleApp.Core_Deal_win_Goal_Share_Id__c!='') 
                    dealId=deleApp.Core_Deal_win_Goal_Share_Id__c.split(',');
                deleApp.Core_Opportunity_ID__c='';
                deleApp.Core_Deal_win_Goal_Share_Id__c='';
                deleApp.Core_Active__c=false;
                delegateUpdate.add(deleApp);
                
            }
        }
        List<Core_Delegate_Approver__c> deleAudit= [Select id,Core_Opportunity_ID__c,Core_User__c,OwnerId,Core_Manager__c,Core_Deal_win_Goal_Share_Id__c from Core_Delegate_Approver__c where Core_User__c In:delegateUserRemoveShare and Core_Manager__c Not In: uservalue and Core_Active__c=: true];
        List<String> oppShareId=new List<String>();
        if(deleAudit.size()>0){
            for(Core_Delegate_Approver__c deleObj : deleAudit){
                oppShareId.addAll(deleObj.Core_Opportunity_ID__c.split(','));
            }
            for(String shareId : oppId){
                if(!oppShareId.contains(shareId)){
                    opporShareId.add(shareId);
                }
                
            }
            
        }
        else
            opporShareId.addAll(oppId);
        List<OpportunityShare> oppShare= new List<OpportunityShare>();
        List<Core_Exceptions__c> exceptionList=new List<Core_Exceptions__c>();   
        if(!opporShareId.isEmpty())
            oppShare=[Select id,OpportunityId,UserOrGroupId,OpportunityAccessLevel from OpportunityShare where id In : opporShareId];
        List<Core_Goal__Share> goalShare=[select id,ParentId,UserOrGroupId ,RowCause,AccessLevel from Core_Goal__Share where id In: dealId ];
        Database.Update(delegateUpdate, false);
        List<Database.DeleteResult> drList=Database.Delete(oppShare, false);
        Database.Delete(goalShare, false);
        for(Database.DeleteResult dr : drList) {
            if (!dr.isSuccess()) {
                // Operation failed, so get all errors             
                for(Database.Error err : dr.getErrors()) {
                    Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_DelegateRemovalOfOpportunity', 
                                                                         Core_Exception__c  = 'Error Message: '+ err.getMessage() + ', Error code: '+ err.getStatusCode() +', Field Id: '+ err.getFields(),
                                                                         Core_Login_User_Id__c= userInfo.getUserId());
                    exceptionList.add(ExcepLog);
                    
                }
                
            } 
        }
        //TWC3123-5267
        if(!exceptionList.isEmpty())
        	insert exceptionList;
    }
    global void finish(Database.BatchableContext BC){
        
    }
}