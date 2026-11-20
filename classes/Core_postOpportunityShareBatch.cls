/**************************************************************************************
Apex Class Name: Core_postOpportunityShareBatch
Version     : 1.0 
Created Date: 24 AUG 2022
Function    : Batch class for the sharing of the new opportunity of the manger to delegate approver
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Megha Kumari             24/08/20222              Original Version               
*************************************************************************************/
global class Core_postOpportunityShareBatch implements Database.Batchable<sObject>, Database.Stateful {
	Map<Id,Opportunity> delegateOppIdMap=new Map<Id,Opportunity>();
    List<Id> oppShareIdList = new List<Id>();
    Map<Id,Id> userId=new Map<Id,Id>();
    global Core_postOpportunityShareBatch(Map<Id,Opportunity> delegateOppId,List<Id> oppShareId,Map<Id,Id> userIdNew ){
		delegateOppIdMap=delegateOppId;
        oppShareIdList.addAll(oppShareId);
        userId.putAll(userIdNew);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
     
    
        String query = 'Select id,OpportunityId,UserOrGroupId,OpportunityAccessLevel from OpportunityShare where id In : oppShareIdList';
       
          return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<OpportunityShare> scope){
      
        Map<Id,Id> deleOppShareMap= new Map<Id,Id>();
        for(OpportunityShare oppShare: scope){
            if(delegateOppIdMap.containsKey(oppShare.UserOrGroupId)){
                deleOppShareMap.put(oppShare.UserOrGroupId,oppShare.Id);
            }
        }
        List<Core_Delegate_Approver__c> deleList =[Select id,Core_Opportunity_ID__c,Core_User__c,Core_Active__c,Core_Manager__c from Core_Delegate_Approver__c where
                                                   Core_User__c In:deleOppShareMap.keySet() and Core_Manager__c In: userId.values()];
        
         Map<id,Core_Delegate_Approver__c> deleMap= new Map<id,Core_Delegate_Approver__c>();
        if(!deleList.isEmpty()){
        for(Core_Delegate_Approver__c deleObj : deleList){
            deleMap.put(deleObj.Core_User__c,deleObj);
        }
        }
        List<Core_Delegate_Approver__c> updateDelegate = new List<Core_Delegate_Approver__c>();
        for(Id deleApp : deleOppShareMap.keySet()){
            Core_Delegate_Approver__c delegateAppObj= new Core_Delegate_Approver__c();
                if( deleMap.containsKey(deleApp) && deleMap.get(deleApp).Core_Manager__c==userId.get(deleApp)){
                    delegateAppObj=deleMap.get(deleApp);
                    if(delegateAppObj.Core_Active__c==true)
					  delegateAppObj.Core_Opportunity_ID__c=delegateAppObj.Core_Opportunity_ID__c+','+deleOppShareMap.get(deleApp);
                    else
                    {
                        delegateAppObj.Core_Opportunity_ID__c=deleOppShareMap.get(deleApp);
                        delegateAppObj.Core_Active__c=true;
                    }
                
                     updateDelegate.add(delegateAppObj);
                }
            else{
                delegateAppObj.Core_User__c=deleApp;
                delegateAppObj.Core_Opportunity_ID__c=deleOppShareMap.get(deleApp);
                delegateAppObj.Core_Active__c=true;
                delegateAppObj.Core_Manager__c=userId.get(deleApp);
                updateDelegate.add(delegateAppObj);
            }
        }
         List<Database.upsertResult>  delegateResults = Database.upsert(updateDelegate,false);
        for(Integer index = 0, size = delegateResults.size(); index < size; index++) {
            if(delegateResults[index].isSuccess()) {
                if(delegateResults[index].isCreated()) {
                  
                } else {
                   
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC){
    
    }
}