global class Core_dealWinGoalShareToDelegateBatch implements Database.Batchable<sObject>, Database.Stateful{
    Map<Id,String> delegateDealMap = new Map<Id,String>();
    List<Id> delegateDealList = new List<Id>();
    Map<Id,Id> userId=new Map<Id,Id>();
    global Core_dealWinGoalShareToDelegateBatch(Map<Id, String> delegateDealMapNew, Map<Id,Id> userIdNew){
        delegateDealMap=delegateDealMapNew;
        delegateDealList.addAll(delegateDealMapNew.keySet());
        userId=userIdNew;
    }
    //DWG EOL Temporary fix - switch to be added | Permanent fix - code to be re-configured
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id from Core_Goal__c where id In : delegateDealList';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Core_Goal__c> scope){
        System.debug('delegateDealMap--'+delegateDealMap);
        System.debug('delegateDealList--'+delegateDealList);
        System.debug('delegateDealList size--'+delegateDealList.size());
        List<Core_Goal__Share> goalShareList= new List<Core_Goal__Share>();
        List<Core_Delegate_Approver__c> dele = new List<Core_Delegate_Approver__c>();
        Set<Id> delegateDealDetails= new Set<Id>();
        System.debug('Scope--'+scope);
        String dealId='';
        for( Core_Goal__c goal: scope){
            if(delegateDealMap.keySet().contains(goal.id)){
             Core_Goal__Share goalShare= new Core_Goal__Share ();  
                goalShare.ParentId = goal.Id;
                goalShare.UserOrGroupId = (Id)delegateDealMap.get(goal.Id);
                goalShare.RowCause='Core_Deal_Win_Goal__c';
                goalShare.AccessLevel='Edit';
                goalShareList.add(goalShare);
                delegateDealDetails.add((Id)delegateDealMap.get(goal.Id));
            }
        }
         List<Database.SaveResult> goalShareResults = Database.insert(goalShareList,false);
         for (Integer i = 0;i<goalShareResults.size();i++) {
            //saveResultByField.put((String)sObjects.get(i).get(field),results.get(i));
            System.debug('i--'+goalShareResults.get(i).getId());
             if(goalShareResults.get(i).getId()!=null){
             if(dealId=='')
                 dealId=goalShareResults.get(i).getId();
             else
              dealId=dealId+','+goalShareResults.get(i).getId();
             System.debug('Error--'+goalShareResults.get(i).getErrors());
             }
        }
        
        System.debug('oppId--'+dealId);
        System.debug('delegateDealDetails- opp Share '+ delegateDealDetails);
        List<Core_Delegate_Approver__c> deleList =[Select id,Core_Opportunity_ID__c,Core_User__c,Core_Active__c,Core_Deal_win_Goal_Share_Id__c,Core_Manager__c from Core_Delegate_Approver__c where
                                                   Core_User__c In:delegateDealDetails and 	Core_Manager__c In: userId.values()];
        System.debug('Delegate Approver list size--'+deleList.size());
        Map<id,Core_Delegate_Approver__c> deleMap= new Map<id,Core_Delegate_Approver__c>();
        if(!deleList.isEmpty()){
        for(Core_Delegate_Approver__c deleObj : deleList){
            deleMap.put(deleObj.Core_User__c,deleObj);
        }
        }
        
        System.debug('deleMap--'+deleMap.size());
            for(Id deleObj : delegateDealDetails){
                Core_Delegate_Approver__c delegate = new Core_Delegate_Approver__c();
                if(deleMap.keySet().contains(deleObj) && deleMap.get(deleObj).Core_Manager__c==userId.get(deleObj)){
                    delegate=deleMap.get(deleObj);
                    if(delegate.Core_Deal_win_Goal_Share_Id__c!=null)
                      delegate.Core_Deal_win_Goal_Share_Id__c+=','+dealId;
                    else
                    delegate.Core_Deal_win_Goal_Share_Id__c=dealId;                        
                    //delegate.Core_User__c=deleObj;
                    delegate.Core_Active__c=true;
                    dele.add(delegate);
                }
                else{
                    delegate.Core_User__c=deleObj;
                    delegate.Core_Deal_win_Goal_Share_Id__c=dealId;
                    delegate.Core_Active__c=true;
                    delegate.Core_Manager__c=userId.get(deleObj);
                    dele.add(delegate);
                }
                
            }   
        System.debug('Dele--'+dele);
          List<Database.upsertResult>  delegateResults = Database.upsert(dele,false);
        for(Integer index = 0, size = delegateResults.size(); index < size; index++) {
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
    }
        
    }
    global void finish(Database.BatchableContext BC){}
}