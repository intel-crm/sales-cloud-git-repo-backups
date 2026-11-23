public without sharing class PCC_fetchDealPermissionSet {
    @AuraEnabled(cacheable=true)
    public static List<userPermissionsWrapper> hasDealPermissionSet(){
        List<String> permissionSetList = new List<String>();
        List<userPermissionsWrapper> wrapList = new List<userPermissionsWrapper>();
        String userId = UserInfo.getUserId();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
         if(!String.isBlank(userId)){
                for(PermissionSetAssignment ps:[Select Id,Assignee.name,AssigneeId,PermissionSet.Name from PermissionSetAssignment Where AssigneeId =:userId]){
                    if(ps!=null){
                    	permissionSetList.add(String.valueOf(ps.PermissionSet.Name));
                    	system.debug('permissionSetList---'+permissionSetList);
                    }
                }
                wrapList.add(new userPermissionsWrapper(profileName,permissionSetList));
             	system.debug('wrapList---'+wrapList);
            }
           
        return wrapList;
    }
    public class userPermissionsWrapper {
        @AuraEnabled public String profile{get;set;}
        @AuraEnabled public List<String> permissionSets{get;set;}
        public userPermissionsWrapper(String profile, List<String> permissionSets){
            this.profile = profile;
            this.permissionSets = permissionSets;
        }
    }
}