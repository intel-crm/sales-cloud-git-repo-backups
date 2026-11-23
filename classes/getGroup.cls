public class getGroup {

    public void getGroupsForUser(Id userId){
    Set<Id> groupIdSet = new Set<Id>();
    Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
        
        if(groupIds!=null ){
List<groupmember> gmm = [select group.name,group.id,group.type from GroupMember where UserOrGroupId =: groupIds];
            system.debug('****'+gmm);
}
    }
// return all ids the user belongs to via direct or indirect membership
public Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){
    Set<Id> output = new Set<Id>();
    Set<Id> nestedGroupIds = new Set<Id>();
    // only query actual groups and not roles and queues
    list<GroupMember> records = [
        select id
             , GroupId,Group.Name
             , UserOrGroupId
          from GroupMember
         where UserOrGroupId =: userOrGroupIds
        and UserOrGroupId != null];
    for (GroupMember record:records)
    {
        // found a group, remember for traversal
        if (!(record.UserOrGroupId + '').startsWith('005'))
        {
            nestedGroupIds.add(record.UserOrGroupId);   
        }
        else
        {
            output.add(record.GroupId);
        }
    }

    // call self to get nested groups we found
    if (nestedGroupIds.size() > 0)
    {
        output.addAll(getGroupsForIds(nestedGroupIds));
    }
  system.debug('****'+output);
    return output;
}
}