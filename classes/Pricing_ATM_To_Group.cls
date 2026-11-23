public class Pricing_ATM_To_Group implements Queueable {
    public List<AccountTeamMember> accTeamMembersList = new List<AccountTeamMember>();
    public Map<Id,Set<Id>> accIdToMemberIdMap = new Map<Id,Set<Id>>();
    public Boolean isDeleteATM;
    
    public Pricing_ATM_To_Group(List<AccountTeamMember> accountTeamMembersList, Boolean isDelete,Map<Id,Set<Id>> accIdToMemberIdMap){
        if(!accountTeamMembersList.isEmpty()){
            this.accTeamMembersList = accountTeamMembersList;
            this.accIdToMemberIdMap = accIdToMemberIdMap;
            this.isDeleteATM = isDelete;
        }
    }
    public void execute(QueueableContext context) {
        List<GroupMember> groupMember =new List<GroupMember>();
        Set<Id> userIds = new Set<Id>(); 
        List<Core_MDF_Partner_Group_Mapping__c> listPartnerGroup = [select Core_MDF_Group_Name__c,Core_MDF_Group_Id__c,Core_MDF_Account__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c in : accIdToMemberIdMap.keySet() and Core_MDF_Group_Id__c!=null];
        for(Core_MDF_Partner_Group_Mapping__c partnerGroup : listPartnerGroup){
            for(Id userId : accIdToMemberIdMap.get(partnerGroup.Core_MDF_Account__c) ){
                    userIds.add(userId);
            }
        }
        if(!isDeleteATM){
		  for(Core_MDF_Partner_Group_Mapping__c partnerGroup : listPartnerGroup){
            for(Id userId : userIds ){
                    GroupMember gm= new GroupMember(); 
                    gm.GroupId = partnerGroup.Core_MDF_Group_Id__c;
                    gm.UserOrGroupId = userId;
                    groupMember.add(gm);
            }
        }
        insert groupMember;
        }
        else{
            Set<Id> grpIds = new Set<Id>();
            for(Core_MDF_Partner_Group_Mapping__c partnerGroup : listPartnerGroup){
                grpIds.add(partnerGroup.Core_MDF_Group_Id__c);
            }
            groupMember=[ Select Id from GroupMember where UserOrGroupID in :userIds and GroupId in :grpIds];
        	delete groupMember;
        }
        System.debug(Limits.getCpuTime());
    }
}