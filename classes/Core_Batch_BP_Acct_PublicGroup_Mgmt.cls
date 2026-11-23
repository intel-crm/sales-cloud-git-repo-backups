global without sharing class Core_Batch_BP_Acct_PublicGroup_Mgmt implements Database.Batchable<SObject>,Database.Stateful {
    private static final String TARGET_PUBLIC_GROUP = 'ER_cmfGroup';
    private static final Set<String> TARGET_PERMISSION_SETS = new Set<String>{
        'ER_Search_to_CMF_Admin',
        'ER_Search_to_CMF_Read_Only'
    };
    private Boolean isRemovalOperation;
    private Id publicGroupId;
    global Core_Batch_BP_Acct_PublicGroup_Mgmt(){
        this.isRemovalOperation=false;
    }
    global Core_Batch_BP_Acct_PublicGroup_Mgmt(Boolean isRemoval){
         this.isRemovalOperation=isRemoval;
    }
    global Database.QueryLocator start(Database.BatchableContext bC){
        List<Group> groups=[SELECT Id FROM Group WHERE DeveloperName = :TARGET_PUBLIC_GROUP];
        publicGroupId=groups[0].Id;
        if(isRemovalOperation){
            return Database.getQueryLocator([Select Id, UserOrGroupId From GroupMember Where GroupId=:publicGroupId]);
        }
        else{
            return Database.getQueryLocator([SELECT AssigneeId, Assignee.Name, Assignee.IsActive, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name IN :TARGET_PERMISSION_SETS AND Assignee.IsActive = true]);
        }
    }
    global void execute(Database.BatchableContext bC, List<SObject> records){
        try{
            if(isRemovalOperation){
                executeRemoveUsers((List<GroupMember>) records);
            }
            else{
                executeAddUsers((List<PermissionSetAssignment>) records);
            }
        }
        catch(Exception ex){
            UCD_ACM_Logger.error('Core_Batch_BP_Acct_PublicGroup_Mgmt','execute','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        } 
    }
    global void finish(Database.BatchableContext bc){
        try{
            if(!isRemovalOperation){
                if (Test.isRunningTest()) {
                    return;
                }
                Core_Batch_BP_Acct_PublicGroup_Mgmt removalBatch = new Core_Batch_BP_Acct_PublicGroup_Mgmt(true);
                Database.ExecuteBatch(removalBatch,100);
            }

        }
        catch(Exception ex){
            UCD_ACM_Logger.error('Core_Batch_BP_Acct_PublicGroup_Mgmt','finish','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        } 
    }
    private void executeAddUsers(List<PermissionSetAssignment> permissionSetAssignments) {
        Set<Id> userWithPermisionSet=new Set<Id>();
        Set<Id> currentGroupMemeber = new Set<Id>();
        Set<Id> usersToAdd = new Set<Id>();
        for (PermissionSetAssignment psa : permissionSetAssignments) {
            userWithPermisionSet.add(psa.AssigneeId);
        }
        currentGroupMemeber=getCurrentGroupMember(userWithPermisionSet);

        for(Id usrId:userWithPermisionSet){
            if(!currentGroupMemeber.contains(usrId)){
                usersToAdd.add(usrId);
            }
        }
       
        if (!usersToAdd.isEmpty()) {
            addUserToGroup(usersToAdd);
        }
    }

    private void executeRemoveUsers(List<GroupMember> groupMembers) {
        List<GroupMember> membersToRemove = new List<GroupMember>();
        Set<Id> usersWithPermissionSets=new Set<Id>();
        Set<Id> groupMemberUser=new Set<Id>();
        Set<Id> usersToRemove=new Set<Id>();
        for (GroupMember gm : groupMembers) {
            groupMemberUser.add(gm.UserOrGroupId);
        }
        usersWithPermissionSets=getUsersWithPermissionSets(groupMemberUser);

        for(Id userId : groupMemberUser){
            if (!usersWithPermissionSets.contains(userId)) {
                usersToRemove.add(userId);
            }
        }

        if (!usersToRemove.isEmpty()) {
            removeUserFromGroup(usersToRemove);
        }
    }
    
    private Set<Id> getCurrentGroupMember(Set<Id> userIds){
        Set<Id> groupMemeber = new Set<Id>();
        try{
            List<Groupmember> grpMembers=[SELECT UserOrGroupId 
                FROM GroupMember 
                WHERE Group.DeveloperName = :TARGET_PUBLIC_GROUP
                AND UserOrGroupId IN :userIds];
            for(GroupMember grpMeber : grpMembers){
                groupMemeber.add(grpMeber.UserOrGroupId);
            }
        }
        catch(Exception ex){
            UCD_ACM_Logger.error('Core_Batch_BP_Acct_PublicGroup_Mgmt','getCurrentGroupMember','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        } 
        return groupMemeber;
    }

    private void addUserToGroup(Set<Id> usersToAdds){
        List<GroupMember> grpMemberToInsert=new List<Groupmember>();
        for(Id usrId:usersToAdds){
            grpMemberToInsert.add(new GroupMember(GroupId=publicGroupId, UserOrGroupId=usrId));
        }
        if(!grpMemberToInsert.isEmpty()){
            Database.SaveResult[] insertResults = Database.insert(grpMemberToInsert, false);
        }
    }

    private Set<Id> getUsersWithPermissionSets(Set<Id> userIds) {
        Set<Id> usersWithPS = new Set<Id>();
        try {
            for (PermissionSetAssignment psa : [
                SELECT AssigneeId 
                FROM PermissionSetAssignment 
                WHERE PermissionSet.Name IN :TARGET_PERMISSION_SETS 
                AND Assignee.IsActive = true
                AND AssigneeId IN :userIds
            ]) {
                usersWithPS.add(psa.AssigneeId);
            }
        }catch (Exception ex) {
            UCD_ACM_Logger.error('Core_Batch_BP_Acct_PublicGroup_Mgmt','getUsersWithPermissionSets','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }
        finally{
            UCD_ACM_Logger.setLogDetails();
        } 
        return usersWithPS;
    }
    private void removeUserFromGroup(Set<Id> usersToRemoves){
        List<Groupmember> grpMemberToDelete=new List<GroupMember>();
        grpMemberToDelete=[Select Id From Groupmember Where UserOrGroupId=:usersToRemoves];
        if(!grpMemberToDelete.isEmpty()){
            Database.DeleteResult[] deleteResults = Database.delete(grpMemberToDelete, false);
        }
    }
}