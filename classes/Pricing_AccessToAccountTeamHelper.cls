public class Pricing_AccessToAccountTeamHelper {
    
    public static void getAccountTeamMem(List<PermissionSetAssignment> fseusersList){
        set<Id> fseuserId = New set<Id>(); 
        for(PermissionSetAssignment psa : fseusersList){
            fseuserId.add(psa.AssigneeId);
        }
        if(fseuserId.size()>0){
            for(Core_Account_Team__c  accountTeam : [Select Id, Core_Account__c, Core_IPS_Access_For_User__c, Core_Team_Member__c from Core_Account_Team__c  where Core_Team_Member__c in:fseuserId]){
                if(fseuserId.contains(accountTeam.Core_Team_Member__c)){
                    fseuserId.remove(accountTeam.Core_Team_Member__c); 
                }
            }
            if(fseuserId.size()>0){
                addUsersToPublicGroup(fseuserId);  
            }   
        }
    }
    
    public static void addUsersToPublicGroup(Set<Id> fseuserIds){
        List<SBQQ__Quote__c> quotesList =New List<SBQQ__Quote__c>();
        quotesList = [Select Id,SBQQ__Account__c,SBQQ__Account__r.Name,SBQQ__SalesRep__c from SBQQ__Quote__c where SBQQ__SalesRep__c in : fseuserIds];
        if(quotesList.size()>0){
            set<Id> accountIds = New set<Id>();
            for(SBQQ__Quote__c quote : quotesList){
                if(quote.SBQQ__Account__c!=Null){
                    accountIds.add(quote.SBQQ__Account__c);
                }
            }
            if(accountIds.size()>0){
                Map<Id,Set<Id>> accountToGroupIdMap = new  Map<Id,Set<Id>>();
                Map<Id,Set<Id>> accountToGroupIdMapInter = new  Map<Id,Set<Id>>();                
                for(Core_MDF_Partner_Group_Mapping__c partnerGroup : [select Id,Core_MDF_Account__c,Core_MDF_Channel_Program_Name_Txt__c,Core_MDF_Channel_Program__c,Core_MDF_AccountIdGroupName__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c from Core_MDF_Partner_Group_Mapping__c where
                                                                      Core_MDF_Channel_Program_Name_Txt__c =: Label.Pricing_Tender_PGM_Channel and   Core_MDF_Account__c in : accountIds and Core_MDF_Group_Id__c!=null]){
                                                                          if(!accountToGroupIdMap.containsKey(partnerGroup.Core_MDF_Account__c)){
                                                                              accountToGroupIdMap.put(partnerGroup.Core_MDF_Account__c,new Set<Id>{partnerGroup.Core_MDF_Group_Id__c});
                                                                          }
                                                                          else {
                                                                              accountToGroupIdMap.get(partnerGroup.Core_MDF_Account__c).add(partnerGroup.Core_MDF_Group_Id__c);
                                                                          }
                                                                          if(!accountToGroupIdMapInter.containsKey(partnerGroup.Core_MDF_Account__c) && partnerGroup.Core_MDF_Type_of_Access__c == Label.Pricing_Tender_PGM_Type){
                                                                              accountToGroupIdMapInter.put(partnerGroup.Core_MDF_Account__c,new Set<Id>{partnerGroup.Core_MDF_Group_Id__c});
                                                                          }
                                                                          else if(partnerGroup.Core_MDF_Type_of_Access__c == Label.Pricing_Tender_PGM_Type) {
                                                                              accountToGroupIdMapInter.get(partnerGroup.Core_MDF_Account__c).add(partnerGroup.Core_MDF_Group_Id__c);
                                                                          }                                                                          
                                                                      }                            
                List<GroupMember> GMlist = new List<GroupMember>();
                for(SBQQ__Quote__c quotes:quotesList){                
                    if(accountToGroupIdMap.containsKey(quotes.SBQQ__Account__c) && !(accountToGroupIdMap.get(quotes.SBQQ__Account__c)).isEmpty()){ 
                        for(id grpId : accountToGroupIdMap.get(quotes.SBQQ__Account__c)){
                            GroupMember GM = new GroupMember();
                            GM.GroupId = quotes.SBQQ__SalesRep__c;
                            GM.UserOrGroupId = grpId;
                            GMList.add(GM); 
                        }
                    }                
                }
                if(GMList.size()>0) {
                    Database.insert(GMList,false);
                }	                
            }
        }
    }    
    
}