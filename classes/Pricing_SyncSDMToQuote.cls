public without sharing class Pricing_SyncSDMToQuote {
    
    @InvocableMethod(label = 'addCurrentUserToPublicGroups' description = 'Add current user to account specific public groups')
    public static List<String> addCurrentUserToPublicGroups(List<Id> Ids) {
        List<String> errorMsgList = new List<String>();
        try{ 
            // Get the current user
            String currentUserId = UserInfo.getUserId();
            
            List<PermissionSetAssignment> psa = [SELECT Id,PermissionSet.Profile.Name 
                                                 FROM PermissionSetAssignment 
                                                 WHERE AssigneeId = :currentUserId 
                                                 AND PermissionSet.Name = 'Tender_User'];
            
            if (psa.size() > 0) {
                Set<Id> mtdAccIds = new Set<Id>();
                Set<Id> accIds = new Set<Id>();
                set<Id> groupIds = new set<Id>();
                List<Group> groupList = new List<Group>();
                Map<String,Pricing_Account_To_CIM_ID_Mapping__mdt> accToCimIdMtd = Pricing_Account_To_CIM_ID_Mapping__mdt.getAll(); 
                
                for(String id : accToCimIdMtd.keyset()){
                    mtdAccIds.add(id.substringAfter('Id_'));
                }

                if(Test.isRunningTest()){
                    for(AccountTeamMember acc : [SELECT Id,AccountId,Account.Name FROM AccountTeamMember where UserId =: currentUserId and Account.id IN: Ids]){
                        accIds.add(acc.AccountId);
                    }
                }
                else {
                    for(AccountTeamMember acc : [SELECT Id,AccountId,Account.Name FROM AccountTeamMember where UserId =: currentUserId and Account.id IN: mtdAccIds]){
                        accIds.add(acc.AccountId); 
                    }
                }

                if(accIds.size()> 0){
                    for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id, Core_MDF_Group_Name__c, Core_MDF_Group_Id__c FROM Core_MDF_Partner_Group_Mapping__c where Core_MDF_Type_of_Access__c = 'Internal' and Core_MDF_Channel_Program__r.Name = 'Intel Quote Request' and Core_MDF_Account__c =: accIds]){
                        groupIds.add(pgm.Core_MDF_Group_Id__c);  
                    }
                    if(groupIds.size() >0){
                        groupList = [SELECT Id FROM Group WHERE Id =:groupIds];
                    }
                    if(groupList.size() > 0){
                        Map<Id,List<String>> groupIdToUserIdMap = new Map<Id,List<String>>();
                        List<GroupMember> grpMemList = new List<GroupMember>();
                        //froming Existing GroupMembers Map
                        for(GroupMember extstingGrpMemRec : [SELECT Id,UserOrGroupId,GroupId FROM GroupMember WHERE Group.Id =: groupIds]){
                            if(groupIdToUserIdMap.containsKey(extstingGrpMemRec.GroupId)){
                                groupIdToUserIdMap.get(extstingGrpMemRec.GroupId).add(extstingGrpMemRec.UserOrGroupId);
                            }else{
                                groupIdToUserIdMap.put(extstingGrpMemRec.GroupId, new List<String> {extstingGrpMemRec.UserOrGroupId});
                            } 
                        }
                        for(Group grp : groupList){
                            //Checking if user is already present in Group.if not Adding the user to the public group.
                            if(groupIdToUserIdMap.get(grp.Id) != null && !groupIdToUserIdMap.get(grp.Id).contains(currentUserId)){
                                GroupMember grpMember = new GroupMember(GroupId = grp.Id, UserOrGroupId = currentUserId);
                                grpMemList.add(grpMember);
                            }
                        }
                        if(grpMemList.size() > 0){
                            insert grpMemList;
                        }
                        else {
                            errorMsgList.add('Info: your access has been synced.');
                        }
                    } 
                } else {
                    errorMsgList.add('Error: you are not part of any account teams.');
                }
            } else {
                errorMsgList.add('Error: you do not have SDM/FSE role.please request access via AGS');
            }
        } catch (Exception exp) {
            Pricing_Tender_Utility.logError(exp);
        }
        return errorMsgList;     
    }
}