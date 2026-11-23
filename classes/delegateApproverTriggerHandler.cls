public class delegateApproverTriggerHandler {
    /*public static void updateUserRole(Map<Id,Core_DelegateApproverDetails__c> oldMap, Map<Id,Core_DelegateApproverDetails__c> newMap){
        List<Core_DelegateApproverDetails__c> detailsList =[select id,Core_user__c,Core_isActive__c,Core_oldRole__c,Core_newRole__c,Core_name__c from
                      Core_DelegateApproverDetails__c where id In: newMap.KeySet() ];
        Set<Id> userId=new Set<Id>();
        for(Core_DelegateApproverDetails__c details: detailsList){
            userId.add(details.Core_User__c);
        }
        Map<Id,User> delegatedUser=new Map<Id,User>([select  id ,name, DelegatedApproverId, UserRoleId, UserRole.name,UserRole.ParentRoleId 
                                                     from User where id In : userId]);
        System.debug('Details List New Map--'+ detailsList);
        List<User> user= new List<User>();
        For(Core_DelegateApproverDetails__c details: detailsList){
            System.debug('Old map value--'+oldMap);
            if(details.Core_isActive__c==true && oldMap==null){
                User u =delegatedUser.get(details.Core_user__c);
                u.UserRoleId= details.Core_newRole__c;
                user.add(u);
            }
            else if(details.Core_isActive__c!=oldMap.get(details.id).Core_isActive__c && details.Core_isActive__c==false){
                User u =delegatedUser.get(details.Core_user__c);
                u.UserRoleId= details.Core_oldRole__c;
                user.add(u);
            }
            
        }
        System.debug('User size--'+user.size());
        if(!user.isEmpty())
        update user;
    }*/
}