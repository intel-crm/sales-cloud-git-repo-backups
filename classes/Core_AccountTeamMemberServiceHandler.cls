public class Core_AccountTeamMemberServiceHandler{

public static void sharingAccountTeamList(list<AccountTeamMember> accTeamList, Boolean isDelete){

        String permissionSetName = System.Label.Pricing_Tender_PermissionSets_TenderUser;
        Set<ID> assignedIds=new Set<ID>();
        List<AccountTeamMember> accountTeamMembersList=new List<AccountTeamMember>();
        List<AccountTeamMember> accountTeamMembersDeletedList=new List<AccountTeamMember>();
        List<PermissionSetAssignment> accmtPermisionId = [Select AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =:permissionSetName];
        Map<Id,Set<Id>> accIdToUserIdMap = new Map<Id,Set<Id>>();
        if(accmtPermisionId.size()>0 && accmtPermisionId <> Null){
            for(PermissionSetAssignment psam : accmtPermisionId){
                assignedIds.add(psam.AssigneeId);
            }
        }
    
    //Checking teamMember has tender permissionSet or not.
        if(!accTeamList.isEmpty()){
          for(AccountTeamMember atm: accTeamList){
                if(assignedIds.contains(atm.UserId)){
                    accountTeamMembersList.add(atm);
                    if(accIdToUserIdMap.containsKey(atm.accountId)){
                        accIdToUserIdMap.get(atm.AccountId).add(atm.UserId);
                    }
                    else{
                        accIdToUserIdMap.put(atm.AccountId,new Set<Id>{atm.UserId});
                    }
                }
            }  
        }
    
        //Sending accountTeamMembersList to  tender quote and quoteline sharing batch job.
        if(!accountTeamMembersList.isEmpty() && accountTeamMembersList <> Null){
           System.debug('call batch '+'accountTeamMembersList '+accountTeamMembersList+' isDelete '+' accIdToUserIdMap '+accIdToUserIdMap);
           database.executebatch(new Pricing_BatchQuoteShare_ATM(accountTeamMembersList,isDelete,accIdToUserIdMap),200);
           //System.enqueueJob(new Pricing_ATM_To_Group(accountTeamMembersList,isDelete,accIdToUserIdMap));
        }
}
}