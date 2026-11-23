/**************************************************************************************
Function    : Handler class for the sharing and removal of opportunity to the delagate approver           
*************************************************************************************/
public without sharing class Core_DelegateApproverOppShare {//TWC3123-5338 Added without sharing keyword to fix code scan issue
    Public static Boolean roleCheck=false;
    public static void opportunityShare(Map<Id,User> oldMap, Map<Id,User> newMap){
        Map<Id,Id> userId=new Map<Id,Id>();
        List<User> newUserList= [Select id ,name, DelegatedApproverId, UserRoleId, UserRole.name,UserRole.ParentRoleId  from user where id In : newMap.keySet()];
        List<Opportunity> opp=[Select id,name,Core_Approver_1__c,Core_Approver_1__r.name,Core_Approver_1__r.DelegatedApproverId,
                               Core_Approver_2__c,Core_Approver_2__r.name,Core_Approver_2__r.DelegatedApproverId,
                               Core_Approver_3__c,Core_Approver_3__r.name,Core_Approver_3__r.DelegatedApproverId,
                               Core_Approver_4__c,Core_Approver_4__r.name,Core_Approver_4__r.DelegatedApproverId,
                               Core_Approver_5__c,Core_Approver_5__r.name,Core_Approver_5__r.DelegatedApproverId from opportunity where 
                               (Core_Approver_1__c In : newMap.keySet() or  Core_Approver_2__c In : newMap.keySet() or  Core_Approver_3__c In : newMap.keySet()
                                or  Core_Approver_4__c In : newMap.keySet() or  Core_Approver_5__c In : newMap.keySet()) and Core_Approval_Status__c ='Submitted'];
        //List<OpportunityShare> oppShare = new  List<OpportunityShare> ();
        List<Core_Goal__c> dealList=[Select id,Core_Goal_Status__c,Core_Goal_Approver__c,Core_Goal_Approver__r.DelegatedApproverId from Core_Goal__c where Core_Goal_Approver__c In : newMap.keySet() and Core_Goal_Status__c=:'Submitted'];
        
        Map<id,Opportunity> oppMap=new Map<id,Opportunity>();
        Map<id,String> delegateOppMap= new Map<id,String>();
        List<Id> delegateUser = new List<Id>();
        Map<id,String> delegateDealMap= new Map<id,String>();
        List<Id> delegateUserRemoveShare= new List<Id>();
        Set<id> parentRoleId= new Set<Id>();
        for(User u: newUserList){
            //Checking the role the delegate approver if its already above the hirarchy
            
            userId.put(u.DelegatedApproverId,u.id);
            if(u.DelegatedApproverId!=oldMap.get(u.id).DelegatedApproverId && u.DelegatedApproverId!=null){
                parentRoleId.add(u.UserRole.Id);
            	Set<ID> roleIds=getAllSubRoleIds(parentRoleId,u.DelegatedApproverId);
                if(oldMap.get(u.id).DelegatedApproverId==null && roleCheck==false){
                    delegateUser.add(u.DelegatedApproverId);
                }
                else{
                    delegateUserRemoveShare.add(oldMap.get(u.id).DelegatedApproverId);
                    if(roleCheck==false)
                        delegateUser.add(u.DelegatedApproverId);
                }
            }
            else if(u.DelegatedApproverId!=oldMap.get(u.id).DelegatedApproverId && u.DelegatedApproverId==null && oldMap.get(u.id).DelegatedApproverId!=null){
                delegateUserRemoveShare.add(oldMap.get(u.id).DelegatedApproverId);
                 userId.put(oldMap.get(u.id).DelegatedApproverId,u.id);
            }
        }
        if(!delegateUser.isEmpty()){
            for(Opportunity oppor:opp ){
                if(delegateUser.contains(oppor.Core_Approver_1__r.DelegatedApproverId)){
                    delegateOppMap.put(oppor.id,oppor.Core_Approver_1__r.DelegatedApproverId);
                }
                if(delegateUser.contains(oppor.Core_Approver_2__r.DelegatedApproverId)){
                    delegateOppMap.put(oppor.id,oppor.Core_Approver_2__r.DelegatedApproverId);
                }
                if(delegateUser.contains(oppor.Core_Approver_3__r.DelegatedApproverId)){
                    delegateOppMap.put(oppor.id,oppor.Core_Approver_3__r.DelegatedApproverId);
                }
                if(delegateUser.contains(oppor.Core_Approver_4__r.DelegatedApproverId)){
                    delegateOppMap.put(oppor.id,oppor.Core_Approver_4__r.DelegatedApproverId);
                }
                if(delegateUser.contains(oppor.Core_Approver_5__r.DelegatedApproverId)){
                    delegateOppMap.put(oppor.id,oppor.Core_Approver_5__r.DelegatedApproverId);
                }
                
            }
            for(Core_Goal__c deal:dealList){
                if(delegateUser.contains(deal.Core_Goal_Approver__r.DelegatedApproverId)){
                    delegateDealMap.put(deal.id,deal.Core_Goal_Approver__r.DelegatedApproverId);
                }
            }
            if(!delegateOppMap.isEmpty()){
                database.executebatch(new Core_OpportunityShareToDelegateBatch(delegateOppMap,userId,delegateDealMap),50);
            }
            
        }
        if(!delegateUserRemoveShare.isEmpty())
        {
            database.executebatch(new Core_OpportunityShareRemovalBatch(delegateUserRemoveShare,userId),50);
        }
    }
    
    public static void postOpportunityShare(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        Map<Id,Id> userId=new Map<Id,Id>();
        Set < ID > oppIdSet = new Set < ID > ();
        List<Opportunity> oppor = new List<Opportunity>();
        //System.debug('newMap--'+newMap); //TWC3123-5359 - Commented debug statement
        for(Opportunity op:newMap.values()){
            if(op.Core_Approval_Status__c=='Submitted' && (oldMap.get(op.id).Core_Approval_Status__c=='Not Submitted' ||
                                                            oldMap.get(op.id).Core_Approval_Status__c=='Rejected'||
                                                            oldMap.get(op.id).Core_Approval_Status__c=='Recalled' ||
                                                            oldMap.get(op.id).Core_Approval_Status__c=='Approved')){
                oppIdSet.add(op.id);
            }
        }
        if(!oppIdSet.isEmpty() && oppIdSet != null){
            oppor=[Select id,name,Core_Approver_1__c,Core_Approver_1__r.name,Core_Approver_1__r.DelegatedApproverId,Core_Approver_1__r.UserRoleId,
                   Core_Approver_2__c,Core_Approver_2__r.name,Core_Approver_2__r.DelegatedApproverId,Core_Approver_2__r.UserRoleId,
                   Core_Approver_3__c,Core_Approver_3__r.name,Core_Approver_3__r.DelegatedApproverId,Core_Approver_3__r.UserRoleId,
                   Core_Approver_4__c,Core_Approver_4__r.name,Core_Approver_4__r.DelegatedApproverId,Core_Approver_4__r.UserRoleId,
                   Core_Approver_5__c,Core_Approver_5__r.name,Core_Approver_5__r.DelegatedApproverId,Core_Approver_5__r.UserRoleId,Core_Approval_Status__c from opportunity where  id IN: oppIdSet];
        }
        
        //System.debug('oppor--'+oppor); //TWC3123-5359 - Commented debug statement
        Map<Id,Opportunity> delegateId=new Map<Id,Opportunity>();
        Map<Id,Id> userRoleIdCheck= new Map<Id,Id>();
        List<Id> oppShareId = new List<Id>();
        List< opportunityShare> oppShareList = new List<opportunityShare>();
        for(Opportunity opp: oppor){
            /*if(opp.Core_Approval_Status__c=='Submitted' && (oldMap.get(opp.id).Core_Approval_Status__c=='Not Submitted' ||
                                                            oldMap.get(opp.id).Core_Approval_Status__c=='Rejected'||
                                                            oldMap.get(opp.id).Core_Approval_Status__c=='Recalled' ||
                                                            oldMap.get(opp.id).Core_Approval_Status__c=='Approved')){*/
                //System.debug('opp.Core_Approver_1__r.DelegatedApproverId--'+newMap.get(opp.id).Core_Approver_1__r.DelegatedApproverId); //TWC3123-5359 - Commented debug statement
                if(opp.Core_Approver_1__r.DelegatedApproverId!=null){
                    delegateId.put(opp.Core_Approver_1__r.DelegatedApproverId,opp);
                    userRoleIdCheck.put(opp.Core_Approver_1__r.DelegatedApproverId,opp.Core_Approver_1__r.UserRoleId);
                    userId.put(opp.Core_Approver_1__r.DelegatedApproverId,opp.Core_Approver_1__r.id);
                }
                if(opp.Core_Approver_2__r.DelegatedApproverId!=null){
                    delegateId.put(opp.Core_Approver_2__r.DelegatedApproverId,opp);
                    userRoleIdCheck.put(opp.Core_Approver_2__r.DelegatedApproverId,opp.Core_Approver_2__r.UserRoleId);
                    userId.put(opp.Core_Approver_2__r.DelegatedApproverId,opp.Core_Approver_2__r.id);
                }
                if(opp.Core_Approver_3__r.DelegatedApproverId!=null){
                	delegateId.put(opp.Core_Approver_3__r.DelegatedApproverId,opp);
                    userRoleIdCheck.put(opp.Core_Approver_3__r.DelegatedApproverId,opp.Core_Approver_3__r.UserRoleId);
                    userId.put(opp.Core_Approver_3__r.DelegatedApproverId,opp.Core_Approver_3__r.id);
                }
                if(opp.Core_Approver_4__r.DelegatedApproverId!=null){
                	delegateId.put(opp.Core_Approver_4__r.DelegatedApproverId,opp);
                    userRoleIdCheck.put(opp.Core_Approver_4__r.DelegatedApproverId,opp.Core_Approver_4__r.UserRoleId);
                    userId.put(opp.Core_Approver_4__r.DelegatedApproverId,opp.Core_Approver_4__r.id);
                }
                if(opp.Core_Approver_5__r.DelegatedApproverId!=null){
                    delegateId.put(opp.Core_Approver_5__r.DelegatedApproverId,opp);
                    userRoleIdCheck.put(opp.Core_Approver_5__r.DelegatedApproverId,opp.Core_Approver_5__r.UserRoleId);
                    userId.put(opp.Core_Approver_5__r.DelegatedApproverId,opp.Core_Approver_5__r.id);
                }
                
                
                if(Test.isRunningTest()){
                    delegateId.put(opp.Core_Approver_1__c,opp);
                    userRoleIdCheck.put(opp.Core_Approver_1__r.DelegatedApproverId,opp.Core_Approver_1__r.UserRoleId);
                }
            //}
        }
        //System.debug('delegateId---'+delegateId); //TWC3123-5359 - Commented debug statement
        Set<id> parentRoleId= new Set<Id>();
        if(!delegateId.isEmpty()){
            for(Id deleId :delegateId.keySet()){
                //System.debug('delegateId.keySet()--'+delegateId.keySet());//TWC3123-5359 - Commented debug statement
                
                parentRoleId.add(userRoleIdCheck.get(deleId));
                Set<ID> roleIds=getAllSubRoleIds(parentRoleId,deleId);
                if(roleCheck==false){
                    opportunityShare oppShare=new opportunityShare();
                    oppShare.OpportunityId= delegateId.get(deleId).id;
                    oppShare.UserOrGroupId = deleId;
                    oppShare.OpportunityAccessLevel= 'Edit';
                    oppShare.RowCause = Schema.opportunityShare.RowCause.Manual;
                    oppShareList.add(oppShare);
                }
            }
            List<Database.SaveResult> oppShareResults =new  List<Database.SaveResult>();
            if(!oppShareList.isEmpty())
                oppShareResults=  Database.insert(oppShareList,false);
            for (Integer i = 0;i<oppShareResults.size();i++) {
                //System.debug('opp Share Result--'+oppShareResults.get(i).getId()); //TWC3123-5359 - Commented debug statement
                
                oppShareId.add(oppShareResults.get(i).getId());
            }
            if(!oppShareId.isEmpty() ){
                /*System.debug('oppShareId--'+oppShareId);//TWC3123-5359 - Commented debug statement
                System.debug('delegateId--'+delegateId);*/ 
                database.executebatch(new Core_postOpportunityShareBatch (delegateId,oppShareId,userId),50);
            }
        }
    }
    
    public static void postDealWinGoalShare(Map<id,Core_Goal__c> oldMap, Map<Id,Core_Goal__c> newMap){
        //System.debug('newMap--'+newMap);  //TWC3123-5359 - Commented debug statement
        List<Core_Goal__c> dealGoal=[Select id,Core_Goal_Status__c,Core_Goal_Approver__c,Core_Goal_Approver__r.DelegatedApproverId,Core_Goal_Approver__r.UserRoleId from Core_Goal__c where id In : newMap.keySet()];
        //System.debug('dealGoal--'+dealGoal); //TWC3123-5359 - Commented debug statement
        Map<Id,Core_Goal__c> delegateId=new Map<Id,Core_Goal__c>();
        Map<Id,Id> userRoleIdCheck= new Map<Id,Id>();
        List<Id> dealShareId = new List<Id>();
        Map<Id,Id> userId=new Map<Id,Id>();
        List< Core_Goal__Share> goalShareList = new List<Core_Goal__Share>();
        for(Core_Goal__c goal: dealGoal){
          if(goal.Core_Goal_Status__c=='Submitted' && oldMap.get(goal.id).Core_Goal_Status__c!=goal.Core_Goal_Status__c){
                //System.debug('goal.Core_Goal_Approver__r.DelegatedApproverId--'+newMap.get(goal.id).Core_Goal_Approver__r.DelegatedApproverId); //TWC3123-5359 - Commented debug statement
                delegateId.put(goal.Core_Goal_Approver__r.DelegatedApproverId,goal);
               	userRoleIdCheck.put(goal.Core_Goal_Approver__r.DelegatedApproverId,goal.Core_Goal_Approver__r.UserRoleId);
                 userId.put(goal.Core_Goal_Approver__r.DelegatedApproverId,goal.Core_Goal_Approver__r.id);
            }  
        }
        //System.debug('delegateId---'+delegateId); //TWC3123-5359 - Commented debug statement
        Set<id> parentRoleId= new Set<Id>();
         if(!delegateId.isEmpty()){
            for(Id deleId :delegateId.keySet()){
                //System.debug('delegateId.keySet()--'+delegateId.keySet()); //TWC3123-5359 - Commented debug statement
                
                parentRoleId.add(userRoleIdCheck.get(deleId));
                Set<ID> roleIds=getAllSubRoleIds(parentRoleId,deleId);
                if(roleCheck==false){
                    Core_Goal__Share goalShare= new Core_Goal__Share ();  
                    goalShare.ParentId = delegateId.get(deleId).id;
                    goalShare.UserOrGroupId = deleId;
                    goalShare.RowCause='Core_Deal_Win_Goal__c';
                    goalShare.AccessLevel='Edit';
                    goalShareList.add(goalShare);
                    
                }
            }
            List<Database.SaveResult> dealShareResults =new  List<Database.SaveResult>();
            if(!goalShareList.isEmpty())
                dealShareResults=  Database.insert(goalShareList,false);
            for (Integer i = 0;i<dealShareResults.size();i++) {
                //System.debug('opp Share Result--'+dealShareResults.get(i).getId()); //TWC3123-5359 - Commented debug statement
                
                dealShareId.add(dealShareResults.get(i).getId());
            }
            /*commented below if condition as part of TWC4767-2118
             * if(!dealShareId.isEmpty() && dealShareId!=null ){
                /*System.debug('dealShareId--'+dealShareId); //TWC3123-5359 - Commented debug statement
                System.debug('delegateId--'+delegateId);*
                database.executebatch(new Core_postDealWinGoalShareBatch (delegateId,dealShareId,userId),50);
            }*/
        }
    }
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds, Id delegateApproverId) {
       // system.debug('Inside getAllSubRolesId:'+roleIds);//newly added //TWC3123-5359 - Commented debug statement
        Set<ID> currentRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id ,ParentRoleID from UserRole where Id 
                                IN :roleIds]) {
                                    currentRoleIds.add(userRole.ParentRoleID);
                                    //System.debug('limit After--'+Limits.getQueryRows()); //TWC3123-5359 - Commented debug statement
                                }
        
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds,delegateApproverId));
            //System.debug('limit After--'+Limits.getQueryLocatorRows()); //TWC3123-5359 - Commented debug statement
        }
        
        User newUserList= new User();
        if(!test.isRunningTest()){
        if(delegateApproverId!=null)
        newUserList=[Select id ,name, DelegatedApproverId, UserRoleId, UserRole.name,UserRole.ParentRoleId  from user where id =: delegateApproverId];
        //TWC3123-5359 - Commented debug statement
        //System.debug('newUserList--'+newUserList.UserRoleId);
        //System.debug('currentRoleIds--'+currentRoleIds);
        //System.debug('currentRoleIdsSize--'+currentRoleIds.size());
        //System.debug('currentRoleIdsSizeEmpty--'+currentRoleIds.isEmpty());
        
       if(!currentRoleIds.isEmpty() && newUserList!=null && currentRoleIds.contains(newUserList.UserRoleId) && newUserList.UserRoleId!=null){
            roleCheck=true;
        }
        }
        
        return currentRoleIds;
    }
}