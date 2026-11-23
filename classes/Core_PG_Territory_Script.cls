public without sharing class Core_PG_Territory_Script{

 //String scope = 'SELECT Core_Public_Group_Name_txt__c, Core_Territory_Name_txt__c FROM Core_PublicGroup_Territory_Mapping__mdt';
  public static Map<String,String> publicGroupTerritoriesIdMap = new Map<String , String>();
  public static Map<String,String> publicGroupNameToIdMap = new Map<String , String>();
  public static Map<String,String> territoriesNameToIdMap = new Map<String , String>();
  public static Set<String> publicGroupNameSet = new Set<String>();
  public static Set<String> territoryNameSet = new Set<String>();
  public static Map<String,List<GroupMember>> publicGroupIdToUsersMap = new Map<String,List<GroupMember>>();
    public static Map<String,List<UserTerritory2Association>> territoryIdToUsersMap = new Map<String,List<UserTerritory2Association>>();
	 public static void initializePublicGroupTerritoriesMap(List<Core_PublicGroup_Territory_Mapping__mdt> scope){
        for(Core_PublicGroup_Territory_Mapping__mdt pgt: scope)
        {
            publicGroupNameSet.add(pgt.Core_Public_Group_Name_txt__c);
            territoryNameSet.add(pgt.Core_Territory_Name_txt__c);
        }
        
        for(Group pGroup: [ SELECT Id, Name FROM Group WHERE Name In :publicGroupNameSet ]){
             publicGroupNameToIdMap.put(pGroup.Name, pGroup.Id);
        }
        
        for(Territory2 territory: [ SELECT Id, name FROM Territory2 WHERE name In :territoryNameSet ]){
            territoriesNameToIdMap.put(territory.name, territory.Id);
        }
        
        for(Core_PublicGroup_Territory_Mapping__mdt pgt: scope)
        {
            String publicGroupId = publicGroupNameToIdMap.get(pgt.Core_Public_Group_Name_txt__c);
            String territoryId = territoriesNameToIdMap.get(pgt.Core_Territory_Name_txt__c);            
            publicGroupTerritoriesIdMap.put(publicGroupId, territoryId);
        }   
    }
	public static void initializeTerritoryIdToUsersMap(){
        Map<String,List<UserTerritory2Association>> allTerritoryUsersMap = new Map<String,List<UserTerritory2Association>>();
        Set<String> territoryIdSet = new Set<String>();
        for(String key : publicGroupTerritoriesIdMap.keySet()){
            territoryIdSet.add(publicGroupTerritoriesIdMap.get(key));
        }
        for(UserTerritory2Association territoryUser : [ SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE Territory2Id In :territoryIdSet ]) {
            if(!allTerritoryUsersMap.containsKey(territoryUser.Territory2Id)){
                allTerritoryUsersMap.put(territoryUser.Territory2Id, new List<UserTerritory2Association>());
            }
            allTerritoryUsersMap.get(territoryUser.Territory2Id).add(territoryUser);
        }     
        for(String publicGroupId : publicGroupTerritoriesIdMap.keySet()){
            String territoryId = publicGroupTerritoriesIdMap.get(publicGroupId);
            if(allTerritoryUsersMap.containsKey(territoryId)){
                territoryIdToUsersMap.put(territoryId, allTerritoryUsersMap.get(territoryId));
            } else {
                territoryIdToUsersMap.put(territoryId, new List<UserTerritory2Association>());
            }
        }
    }
    public static void initializePublicGroupIdToUsersMap(){
        Map<String,List<GroupMember>> allPublicGroupUsersMap = new Map<String,List<GroupMember>>();
        for(GroupMember grpMember : [ SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId In :publicGroupTerritoriesIdMap.keySet() ]) {
            if(!allPublicGroupUsersMap.containsKey(grpMember.GroupId)){
                allPublicGroupUsersMap.put(grpMember.GroupId, new List<GroupMember>());
            }
            allPublicGroupUsersMap.get(grpMember.GroupId).add(grpMember);
        }
        for(String publicGroupId : publicGroupTerritoriesIdMap.keySet()){
            if(allPublicGroupUsersMap.containsKey(publicGroupId)){
                publicGroupIdToUsersMap.put(publicGroupId, allPublicGroupUsersMap.get(publicGroupId));
            } else {
                publicGroupIdToUsersMap.put(publicGroupId, new List<GroupMember>());
            }
        }
    }
    
	 public static void addOrRemoveUsers(List<Core_PublicGroup_Territory_Mapping__mdt> scope){
        initializePublicGroupTerritoriesMap(scope);
        addUsersFromTerritory();
        //removeUsers();
    }
	 public static void addUsersFromTerritory(){
        initializePublicGroupIdToUsersMap();
        initializeTerritoryIdToUsersMap();
        List<GroupMember> publicGroupUsersToBeAdded = new List<GroupMember>();
        for(String publicGroupId: publicGroupTerritoriesIdMap.keySet() ){
            String TerritoryId = publicGroupTerritoriesIdMap.get(publicGroupId);
            
            List<GroupMember> publicGroupUsers = publicGroupIdToUsersMap.get(publicGroupId);
            System.debug('publicGroupUsers size = ' + publicGroupUsers.size());
            List<UserTerritory2Association> territoryUsers = territoryIdToUsersMap.get(territoryId);
            
            Set<String> publicGroupUsersSet = new Set<String>();
            for(GroupMember member : publicGroupUsers) {
                publicGroupUsersSet.add(member.UserOrGroupId);
            }
            
            for(UserTerritory2Association user: Territoryusers){
                if(!publicGroupUsersSet.contains(user.UserId)){
                   GroupMember groupMember = new GroupMember();
                    groupMember.UserOrGroupId = user.UserId;
                    groupMember.GroupId = publicGroupId;
                    publicGroupUsersToBeAdded.add(groupMember);
                }
            }
        }
        if(publicGroupUsersToBeAdded != null && publicGroupUsersToBeAdded.size() > 0){
            System.debug('publicGroupUsersAdded from territory: size = ' + publicGroupUsersToBeAdded.size());
            insert publicGroupUsersToBeAdded;   
        }            
        
    }
}