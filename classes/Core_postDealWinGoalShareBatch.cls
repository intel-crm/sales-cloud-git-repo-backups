global class Core_postDealWinGoalShareBatch implements Database.Batchable<sObject>, Database.Stateful  {
Map<Id,Core_Goal__c> delegateDealIdMap=new Map<Id,Core_Goal__c>();
    List<Id> dealShareIdList = new List<Id>();
    Map<Id,Id> userId=new Map<Id,Id>();
    global Core_postDealWinGoalShareBatch(Map<Id,Core_Goal__c> delegateDealId,List<Id> dealShareId, Map<Id,Id> userIdNew){
		delegateDealIdMap=delegateDealId;
        dealShareIdList.addAll(dealShareId);
        userId.putAll(userIdNew);
    }
    //DWG EOL Temporary fix - switch to be added | Permanent fix - code to be re-configured
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('dealShareIdList--'+dealShareIdList);
        System.debug('delegateDealIdMap--'+delegateDealIdMap);
        String query = 'Select id,ParentId,UserOrGroupId,AccessLevel from Core_Goal__Share  where id In : dealShareIdList';
        System.debug('querry--'+ Database.getQueryLocator(query));
          return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Core_Goal__Share> scope){
        System.debug('scope--');
        Map<Id,Id> deleDealShareMap= new Map<Id,Id>();
        for(Core_Goal__Share goalShare: scope){
            if(delegateDealIdMap.containsKey(goalShare.UserOrGroupId)){
                deleDealShareMap.put(goalShare.UserOrGroupId,goalShare.Id);
            }
        }
        List<Core_Delegate_Approver__c> deleList =[Select id,Core_Opportunity_ID__c,Core_User__c,Core_Active__c,Core_Deal_win_Goal_Share_Id__c,Core_Manager__c from Core_Delegate_Approver__c where
                                                   Core_User__c In:deleDealShareMap.keySet() and Core_Manager__c In: userId.values()];
        System.debug('Delegate Approver list size--'+deleList.size());
         Map<id,Core_Delegate_Approver__c> deleMap= new Map<id,Core_Delegate_Approver__c>();
        if(!deleList.isEmpty()){
        for(Core_Delegate_Approver__c deleObj : deleList){
            deleMap.put(deleObj.Core_User__c,deleObj);
        }
        }
         List<Core_Delegate_Approver__c> updateDelegate = new List<Core_Delegate_Approver__c>();
        for(Id deleApp : deleDealShareMap.keySet()){
            Core_Delegate_Approver__c delegateAppObj= new Core_Delegate_Approver__c();
             if( deleMap.containsKey(deleApp)){
                    delegateAppObj=deleMap.get(deleApp);
                    if(delegateAppObj.Core_Active__c==true)
					  delegateAppObj.Core_Deal_win_Goal_Share_Id__c=delegateAppObj.Core_Deal_win_Goal_Share_Id__c+','+deleDealShareMap.get(deleApp);
                    else
                    {
                        delegateAppObj.Core_Deal_win_Goal_Share_Id__c=deleDealShareMap.get(deleApp);
                        delegateAppObj.Core_Active__c=true;
                    }
                    System.debug(' delegateAppObj.Core_Deal_win_Goal_Share_Id__c--'+ delegateAppObj.Core_Deal_win_Goal_Share_Id__c);
                     updateDelegate.add(delegateAppObj);
                }
            else{
                delegateAppObj.Core_User__c=deleApp;
                delegateAppObj.Core_Deal_win_Goal_Share_Id__c=deleDealShareMap.get(deleApp);
                delegateAppObj.Core_Active__c=true;
                delegateAppObj.Core_Manager__c=userId.get(deleApp);
                updateDelegate.add(delegateAppObj);
            }
        }
         List<Database.upsertResult>  delegateResults = Database.upsert(updateDelegate,false);
        for(Integer index = 0, size = delegateResults.size(); index < size; index++) {
            if(delegateResults[index].isSuccess()) {
                if(delegateResults[index].isCreated()) {
                    System.debug(updateDelegate[index] +' was created');
                } else {
                    System.debug(updateDelegate[index] +' was updated');
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC){
    
    }
}