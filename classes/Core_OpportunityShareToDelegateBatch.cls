/**************************************************************************************
Apex Class Name: Core_OpportunityShareToDelegateBatch
Version     : 1.0 
Created Date: 24 AUG 2022
Function    : Batch class for the sharing of the exixting opportunity of the manger to delegate approver
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Megha Kumari             24/08/20222              Original Version               
*************************************************************************************/
global class Core_OpportunityShareToDelegateBatch implements Database.Batchable<sObject>, Database.Stateful {
    Map<Id,String> delegateOppMap = new Map<Id,String>();
    List<Id> delegateOppList = new List<Id>();
   	Map<Id,Id> userId=new Map<Id,Id>();
    Map<Id,String> delegateDealMap = new Map<Id,String>();
    List< opportunityShare> oppShareList = new List<opportunityShare>();
    global  Core_OpportunityShareToDelegateBatch(Map<Id,String> delegateOppMapNew,   Map<Id,Id> userIdNew, Map<id,String> delegateDealMapNew ){
        delegateOppMap=delegateOppMapNew;
        delegateOppList.addAll(delegateOppMapNew.keySet());
        userId=userIdNew;
        delegateDealMap=delegateDealMapNew;
        //System.debug('user Id'+delegateOppMap);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id from Opportunity where id In : delegateOppList';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Opportunity> scope){
        /*System.debug('delegateOppMap--'+ delegateOppMap);
        System.debug('delegateOppList--'+delegateOppList);
        System.debug('delegateOppMap--'+ delegateOppMap.size());
        System.debug('delegateOppList--'+delegateOppList.size());*/
        List<Core_Delegate_Approver__c> dele = new List<Core_Delegate_Approver__c>();
        Set<Id> delegateOppDetails= new Set<Id>();
        //System.debug('Scope--'+scope);
        String oppId='';
        for(Opportunity opp: scope){
            if( delegateOppMap.keySet().contains(opp.Id)){
                opportunityShare oppShare=new opportunityShare();
                oppShare.OpportunityId= opp.Id;
                oppShare.UserOrGroupId = (Id)delegateOppMap.get(opp.Id);
                oppShare.OpportunityAccessLevel= 'Edit';
                oppShare.RowCause = Schema.opportunityShare.RowCause.Manual;
                oppShareList.add(oppShare);
                //System.debug('DelegateId--'+delegateOppMap.get(opp.Id));
                delegateOppDetails.add((Id)delegateOppMap.get(opp.Id));
            }
        }
         List<Database.SaveResult> oppShareResults = Database.insert(oppShareList,false);
         for (Integer i = 0;i<oppShareResults.size();i++) {
            //saveResultByField.put((String)sObjects.get(i).get(field),results.get(i));
            //System.debug('i--'+oppShareResults.get(i).getId());
             if(oppShareResults.get(i).getId()!=null){
             if(oppId=='')
                 oppId=oppShareResults.get(i).getId();
             else
            	oppId=oppId+','+oppShareResults.get(i).getId();
             //System.debug('Error--'+oppShareResults.get(i).getErrors());
             }
        }
        
        /*System.debug('oppId--'+oppId);
        System.debug('delegateOppDetails- opp Share '+ delegateOppDetails);*/
        List<Core_Delegate_Approver__c> deleList =[Select id,Core_Opportunity_ID__c,Core_User__c,Core_Active__c,Core_Manager__c from Core_Delegate_Approver__c where
                                                   Core_User__c In:delegateOppDetails and 	Core_Manager__c In: userId.values() ];
        //System.debug('Delegate Approver list size--'+deleList.size());
        Map<id,Core_Delegate_Approver__c> deleMap= new Map<id,Core_Delegate_Approver__c>();
        if(!deleList.isEmpty()){
        for(Core_Delegate_Approver__c deleObj : deleList){
            deleMap.put(deleObj.Core_User__c,deleObj);
        }
        }
        
        //System.debug('deleMap--'+deleMap.size());
            for(Id deleObj : delegateOppDetails){
                Core_Delegate_Approver__c delegate = new Core_Delegate_Approver__c();
                if(deleMap.keySet().contains(deleObj) && deleMap.get(deleObj).Core_Manager__c==userId.get(deleObj))
                   {
                    delegate=deleMap.get(deleObj);
                    if(delegate.Core_Opportunity_ID__c!=null)
                    	delegate.Core_Opportunity_ID__c+=','+oppId;
                    else
                        delegate.Core_Opportunity_ID__c=oppId;                        
                    //delegate.Core_User__c=deleObj;
                    delegate.Core_Active__c=true;
                    dele.add(delegate);
                }
                else{
                    delegate.Core_User__c=deleObj;
                    delegate.Core_Opportunity_ID__c=oppId;
                    delegate.Core_Active__c=true;
                    delegate.Core_Manager__c=userId.get(deleObj);
                    dele.add(delegate);
                }
                
            } 
        
        //System.debug('Dele--'+dele);
          List<Database.upsertResult>  delegateResults = Database.upsert(dele,false);
        //TWC3123-5299 Commented as part of code scan issue
        /*for(Integer index = 0, size = delegateResults.size(); index < size; index++) {
            if(delegateResults[index].isSuccess()) {
                if(delegateResults[index].isCreated()) {
                    System.debug(dele[index] +' was created');
                } else {
                    System.debug(dele[index] +' was updated');
                }
               
        }
            else{
                System.debug('Error---'+delegateResults[index].getErrors());
            }
    }*/
        
       
    }
    global void finish(Database.BatchableContext BC){
       /* List<Database.SaveResult> oppShareResults = Database.insert(oppShareList,false);
         for (Integer i = 0;i<oppShareResults.size();i++) {
            //saveResultByField.put((String)sObjects.get(i).get(field),results.get(i));
            System.debug('i--'+oppShareResults.get(i).getId());
        }*/
       //if(!delegateDealMap.isEmpty())
           //DWG EOL Temporary fix - switch to be added | Permanent fix - code to be re-configured
      //database.executebatch(new Core_dealWinGoalShareToDelegateBatch(delegateDealMap, userId),50);
}
}