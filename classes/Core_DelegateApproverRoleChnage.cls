public class Core_DelegateApproverRoleChnage {
  /*
    As a part of delegate approver Role change
    public static void delegateApproverRoleChange(Map<Id,User> oldMap, Map<Id,User> newMap){
        
        List<User> newUserList= [Select id ,name, DelegatedApproverId, UserRoleId, UserRole.name,UserRole.ParentRoleId  from user where id In : newMap.keySet() and
                                 UserRoleId!=null ];
        
        Set<Id> delegatedUserId = new Set<Id>();
        for(User u : newUserList){
            System.debug('u.DelegatedApproverId--'+u.DelegatedApproverId);
            if(u.DelegatedApproverId!=null)
                delegatedUserId.add(u.DelegatedApproverId);
        }
        for(Id u : oldMap.keySet()){
            System.debug('u.DelegatedApproverId--'+oldMap.get(u).DelegatedApproverId);
            if(oldMap.get(u).DelegatedApproverId!=null)
                delegatedUserId.add(oldMap.get(u).DelegatedApproverId);
        }
        System.debug('delegatedUserId--'+delegatedUserId);
        
        Map<Id,User> delegatedUser=new Map<Id,User>([select  id ,name, DelegatedApproverId, UserRoleId, UserRole.name,UserRole.ParentRoleId from User where id In : delegatedUserId]);
        Map<Id,Core_DelegateApproverDetails__c> newDelegateDetail=new Map<Id,Core_DelegateApproverDetails__c>();
        List<Core_DelegateApproverDetails__c> details=[select id,Core_user__c,Core_isActive__c,Core_oldRole__c,Core_newRole__c,Core_name__c from
                                                       Core_DelegateApproverDetails__c where Core_user__c In :delegatedUserId ]; 
        System.debug('details--'+details);
        System.debug('details size--'+details.size());
        //  Map<Id,DetailWrapper> delegateWrapper=new Map<Id,DetailWrapper>();
        if(!details.isEmpty()){
            For(Core_DelegateApproverDetails__c det : details){
                newDelegateDetail.put(det.Core_user__c,det);
            }
        }
        System.debug('newDelegateDetail--'+newDelegateDetail);
        
        List<Core_DelegateApproverDetails__c> delegateDetails= new  List<Core_DelegateApproverDetails__c>();
        //List<User> updatedDelegateUser=new List<User>();
        List<ID> updatedDelegateUser=new List<ID>(); 
        for(User u : newUserList){
            Set<id> parentRoleId= new Set<Id>();
            //For changing the delegate user role if the manager is on vacation.
            System.debug('check--'+oldMap.get(u.id).DelegatedApproverId);
            System.debug('check--'+u.DelegatedApproverId);
            System.debug('nullcheck--'+u.DelegatedApproverId!=null);
            System.debug('nullcheck--'+u.DelegatedApproverId!='');
            if(oldMap.get(u.id).DelegatedApproverId!=u.DelegatedApproverId && u.DelegatedApproverId!=null ){
                
                System.debug('User Inside Loop--'+u);
                System.debug('oldMap DelegatedApproverId '+ oldMap.get(u.id).DelegatedApproverId);
                System.debug('NewMap DelegatedApproverId '+ u.DelegatedApproverId);
                
                if(u.UserRoleId!=delegatedUser.get(u.DelegatedApproverId).UserRoleId){
                    parentRoleId.add(u.UserRole.Id);
                    
                    System.debug('limit Before--'+Limits.getQueryRows());
                    Set<ID> roleIds=getAllSubRoleIds(parentRoleId);
                    System.debug('limit After--'+Limits.getQueryRows());
                    System.debug('Sibling and Child--'+ roleIds);
                    System.debug('Sibling and Child size--'+ roleIds.size());
                    System.debug('Contains--'+roleIds.contains(delegatedUser.get(u.DelegatedApproverId).UserRoleId));
                    if(roleIds!=null && !roleIds.contains(delegatedUser.get(u.DelegatedApproverId).UserRoleId)){
                        
                        if(u.UserRole.ParentRoleId==delegatedUser.get(u.DelegatedApproverId).UserRole.ParentRoleId){
                            updatedDelegateUser.add(delegatedUser.get(u.DelegatedApproverId).id);
                            System.debug('Inside Core_DelegateApproverDetails__c update'+ newDelegateDetail.containsKey(u.DelegatedApproverId));        
                            if(newDelegateDetail.containsKey(u.DelegatedApproverId) && newDelegateDetail!=null){
                                
                                Core_DelegateApproverDetails__c createDetails= newDelegateDetail.get(u.DelegatedApproverId);
                                
                                createDetails.Core_isActive__c=true;
                                createDetails.Core_oldRole__c=delegatedUser.get(u.DelegatedApproverId).UserRoleId;
                                createDetails.Core_newRole__c=u.UserRole.ParentRoleId;
                                delegateDetails.add(createDetails);
                            }
                            else{
                                Core_DelegateApproverDetails__c createDetails= new Core_DelegateApproverDetails__c();
                                createDetails.Core_name__c=delegatedUser.get(u.DelegatedApproverId).name;
                                createDetails.Core_user__c=delegatedUser.get(u.DelegatedApproverId).id;
                                createDetails.Core_isActive__c=true;
                                createDetails.Core_oldRole__c=delegatedUser.get(u.DelegatedApproverId).UserRoleId;
                                createDetails.Core_newRole__c=u.UserRole.ParentRoleId;
                                delegateDetails.add(createDetails);
                                
                            }
                        }
                        else{
                            updatedDelegateUser.add(delegatedUser.get(u.DelegatedApproverId).id);
                            
                            System.debug('Inside Core_DelegateApproverDetails__c update'+ newDelegateDetail.containsKey(u.DelegatedApproverId));        
                            if(newDelegateDetail.containsKey(u.DelegatedApproverId) && newDelegateDetail!=null){
                                
                                Core_DelegateApproverDetails__c createDetails= newDelegateDetail.get(u.DelegatedApproverId);
                                
                                createDetails.Core_isActive__c=true;
                                createDetails.Core_oldRole__c=delegatedUser.get(u.DelegatedApproverId).UserRoleId;
                                createDetails.Core_newRole__c=u.UserRoleId;
                                delegateDetails.add(createDetails);
                            }
                            else{
                                Core_DelegateApproverDetails__c createDetails= new Core_DelegateApproverDetails__c();
                                createDetails.Core_name__c=delegatedUser.get(u.DelegatedApproverId).name;
                                createDetails.Core_user__c=delegatedUser.get(u.DelegatedApproverId).id;
                                createDetails.Core_isActive__c=true;
                                createDetails.Core_oldRole__c=delegatedUser.get(u.DelegatedApproverId).UserRoleId;
                                createDetails.Core_newRole__c=u.UserRoleId;
                                delegateDetails.add(createDetails);
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
            //For reverting the delegate user role back to its original role.
            else if(u.DelegatedApproverId==null && oldMap.get(u.id).DelegatedApproverId!=null ){
                System.debug('User Inside else if Loop--'+u);
                if(newDelegateDetail.containsKey(oldMap.get(u.Id).DelegatedApproverId) && newDelegateDetail!=null){
                    {
                        System.debug('User Inside else if Loop--'+newDelegateDetail);
                        
                        updatedDelegateUser.add(oldMap.get(u.Id).DelegatedApproverId);
                        
                        Core_DelegateApproverDetails__c createDetails= newDelegateDetail.get(oldMap.get(u.Id).DelegatedApproverId);
                        
                        createDetails.Core_isActive__c=false;
                        delegateDetails.add(createDetails);
                    }
                    
                }
            }
        }
        System.debug('delegateDetails'+delegateDetails.size());
        System.debug('updatedDelegateUser'+updatedDelegateUser.size());
        System.debug('updatedDelegateUser'+delegateDetails.isEmpty());
        if(!delegateDetails.isEmpty() && !updatedDelegateUser.isEmpty()){
            //update updatedDelegateUser;
            upsert delegateDetails;
            database.executebatch(new Core_DelegateApproverRoleUpdateBatch(updatedDelegateUser),50);
            //updateDelegatedetails(updatedDelegateUser);
        }
        
    }
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        
        Set<ID> currentRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id ,ParentRoleID from UserRole where Id 
                                IN :roleIds ]) {
                                    currentRoleIds.add(userRole.ParentRoleID);
                                    System.debug('limit After--'+Limits.getQueryRows());
                                }
        
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
            System.debug('limit After--'+Limits.getQueryLocatorRows());
        }
        
        return currentRoleIds;
    }
    
    
  */  
}