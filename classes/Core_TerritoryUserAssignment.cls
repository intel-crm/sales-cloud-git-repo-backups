public class Core_TerritoryUserAssignment {
    
    public static void createTerritoryUser(){
        List<String> grpIds = new List<String>(); 
        grpIds.add('00Go0000001t47aEAA');
		grpIds.add('00Go0000001t47QEAQ');
        
        Map<String,String> publiGrpIdToTerrIdMap = New Map<String,String>();
        
        
        publiGrpIdToTerrIdMap.put('00Go0000001t47aEAA', '0MIo0000000LBbM');
        publiGrpIdToTerrIdMap.put('00Go0000001t47QEAQ', '0MIo0000000LBKY');
        
        System.debug('grpIds ='+grpIds);
        Map<Id,List<Id>> publicGrpIdToUserIdsMap = new Map<Id,List<Id>>();
        List<UserTerritory2Association> userAsso = new List<UserTerritory2Association>();
           
            for(GroupMember grpMems : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember Where GroupId IN :grpIds]){
                
                if(publicGrpIdToUserIdsMap.containsKey(grpMems.GroupId)){
                    publicGrpIdToUserIdsMap.get(grpMems.GroupId).add(grpMems.UserOrGroupId);
                    
                }
                else{
                    List<Id> grpMem = new List<Id>();
                    grpMem.add(grpMems.UserOrGroupId);
                    publicGrpIdToUserIdsMap.put(grpMems.GroupId,grpMem);
                }
            }
        System.debug('publicGrpIdToUserIdsMap ='+publicGrpIdToUserIdsMap);
        
        List<UserTerritory2Association> userAssocs = new List<UserTerritory2Association>();
        for(Id publicGrpId : publicGrpIdToUserIdsMap.keySet()){
            
            
            if(publicGrpId!=null && publiGrpIdToTerrIdMap.containsKey(publicGrpId)){
                String terrId = null;
                terrId = publiGrpIdToTerrIdMap.get(publicGrpId);
                List<Id> userIds = publicGrpIdToUserIdsMap.get(publicGrpId);
                for(Id userId:userIds){
                	UserTerritory2Association userAssoc = new UserTerritory2Association();
            		userAssoc.Territory2Id = terrId;
                    userAssoc.UserId = userId;
                    userAssocs.add(userAssoc);
                    
            	}
            }
            
            
        }
        System.debug('userAssocs ='+userAssocs);
            Database.insert(userAssocs,false);
             
    	}
  }