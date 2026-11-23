/****************************************************************************************************************************************
* Class Name        : Core_MDF_IUPGM_ServiceHandler
* Created Date      : 07/29/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       07/29/2019         Service Class for handling trigger related functions on Internal User Partner Geo Mapping object.
* NP(11630236)         06-12-2019         DE62015 fix: IUPGM | Users are not getting added to APJ and WW IUPGM group when we create an IUPGM for all 5 Geos
* NP(11630236)         06-02-2020         US579189 - Setting Source of PGM insert
*****************************************************************************************************************************************/
public without sharing class Core_MDF_IUPGM_ServiceHandler {
    
    //DE62015 fix
    public static Map<string,string> channelProgramToMasterGroupId = new Map<string,string>();
    public static Map<string,string> newGroupNameToChannelProgramMap = new Map<string,string>();
    //key=CCF, value=Client Co-Marketing Fund
    public static Map <String , String> channelProgramAbbreviationToNameMap = new Map<String , String>();
    //key = programId+geo-subGeo, value = RO Group set
    public static Map<String,Id> programGeoSubGeoROGroupSetMap = new Map<String,Id>();
    public static Map<String,Id> programGeoSubGeoRWGroupSetMap = new Map<String,Id>(); 
    
    //Generic Method to prepare RO/ RW Group Ids based on key = Program or Program+Geo+SubGeo
    private static void populateprogramGeoSubGeoGroupSetMaps(){
        set<String> metadataGroupNames = new set<String> ();
        String progGeoSubGeoKey;
        String progKey;
        List<Core_MDF_ProgramGeoGroupMap__mdt> allMetadataRecs = [SELECT Core_MDF_Program__c, Core_MDF_Region__c,Core_MDF_Sub_Region__c,
                                                                  Core_MDF_Check_SubGeo__c, Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c
                                                                  FROM Core_MDF_ProgramGeoGroupMap__mdt];
                                                                  
        for(Core_MDF_ProgramGeoGroupMap__mdt progGeoSubGeoGrp : allMetadataRecs){
            metadataGroupNames.add(progGeoSubGeoGrp.Core_MDF_Group_Name__c);
            metadataGroupNames.add(progGeoSubGeoGrp.Core_MDF_Group_Name_RO__c);
        }
        Map<String,ID> groupNameToGroupIdMap = new Map<String,ID>();
        if(!metadataGroupNames.isEmpty()){
            for(Group gr : [SELECT ID,DeveloperName from Group WHERE DeveloperName IN : metadataGroupNames] ){
                groupNameToGroupIdMap.put(gr.DeveloperName,gr.Id);
            }
            System.debug(groupNameToGroupIdMap);
        }
        if(allMetadataRecs != NULL && !allMetadataRecs.isEmpty()){
            for(Core_MDF_ProgramGeoGroupMap__mdt progGeoSubGeoGrp : allMetadataRecs){
                //Preparing keys                                                  
                if(progGeoSubGeoGrp.Core_MDF_Region__c != NULL){                                                   
                    progGeoSubGeoKey = (String)progGeoSubGeoGrp.Core_MDF_Program__c + progGeoSubGeoGrp.Core_MDF_Region__c +'-'+ progGeoSubGeoGrp.Core_MDF_Sub_Region__c;
                    if(progGeoSubGeoKey.endsWith('-null')){
                        progGeoSubGeoKey = progGeoSubGeoKey.removeEnd('-null');
                    }
                    System.debug('progGeoSubGeoKey@@'+progGeoSubGeoKey);
                }else if(progGeoSubGeoGrp.Core_MDF_Region__c == NULL && progGeoSubGeoGrp.Core_MDF_Sub_Region__c == NULL){
                    progGeoSubGeoKey = (String)progGeoSubGeoGrp.Core_MDF_Program__c;
                    System.debug('progGeoSubGeoKey@@'+progGeoSubGeoKey);
                }  
                //Map with key = ProgGeoSubGeo/Prog value = RO Group Name
                if(progGeoSubGeoGrp.Core_MDF_Group_Name_RO__c != NULL){
                    if(groupNameToGroupIdMap.containsKey(progGeoSubGeoGrp.Core_MDF_Group_Name_RO__c)){
                        programGeoSubGeoROGroupSetMap.put(progGeoSubGeoKey, groupNameToGroupIdMap.get(progGeoSubGeoGrp.Core_MDF_Group_Name_RO__c));
                    }
                }
                //Map with key = ProgGeoSubGeo/Prog value = RW Group Name                   
                if(progGeoSubGeoGrp.Core_MDF_Group_Name__c != NULL){
                    if(groupNameToGroupIdMap.containsKey(progGeoSubGeoGrp.Core_MDF_Group_Name__c)){
                        programGeoSubGeoRWGroupSetMap.put(progGeoSubGeoKey, groupNameToGroupIdMap.get(progGeoSubGeoGrp.Core_MDF_Group_Name__c));
                    }
                }   
            }
        }
    }
    
    /***************************************************************************************************** 
    Method Name   :        checkPGM
    @return       :        void
    @parameters   :        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>
    Description   :        Whenever a record is inserted in IUPGM, check if PGM exists else create new group and PGM
    Added By      :        Accenture - VK - 07/29/2019
    Modified By   :        Date:           Changes: 
    Accenture - VK         03/10/2019    Updated the method to handle multi picklist Geo on IUPGM
    ******************************************************************************************************/  
    public static void checkPGM(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList){
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        list<String> geoList = new list<String>();
        list<String> subGeoList = new list<String>();
        List<String> geoSubGeoList = new List<String>();
        
        //key = accountId+programId+geo-subGeo, value = Set<userIds>
        Map<String,Set<Id>> accountProgramGeoUserIdSetMap = new Map<String,Set<Id>>();
        
        //key = accountId+programId+geo-subGeo, value = accountName+geo-subGeo or accountName+geo
        Map<String,String> accountProgramGeoIdNameMap = new Map<String,String>();
        
        //key = accountId+programId+geo-subGeo, value = Set<groupIds>
        Map<String,Set<Id>> accountProgramGeoGroupIdSetMap = new Map<String,Set<Id>>();
        
        //GroupMember List
        List<GroupMember> newGroupMemberList = new List<GroupMember>();
        
        //key=Client Co-Marketing Fund, value=CCF
        Map <String , String> channelProgramMetadataNameMap = new Map<String , String>();
        
        //key=Id, value=CCF
        Map<String, String> programIdMap = new Map<String, String>();
        
        //key=GroupDeveloperName, value=Group
        Map<String, Group> newGroupMap = new Map<String, Group>();

        
        //PGM List
        List<Core_MDF_Partner_Group_Mapping__c> newPGMList = new List<Core_MDF_Partner_Group_Mapping__c>();
        
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper geoAndSubGeoWrapper = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        
        //List which contains Acc Manager Roles
        List<String> accManagerRoles = Label.Core_MDF_CCP_Account_Manager_Permission_Sets.Split(',');
        
        //User list to update marketing user
        //List<User> updatedUserList = new List<User>();
        
        List<String> roUsrRoleLst = System.Label.Core_MDF_User_Role_with_Read_Only_Access.split(';');
        List<String> rwUsrRoleLst = System.Label.Core_MDF_User_Role_with_Read_Write_Access.split(';');
        Map<String, Id> grpDevNameWithGrpIdMap = new Map<String, Id>();
        String progKey;
        
        try{
            //AllAccount 
            if(programGeoSubGeoROGroupSetMap.isEmpty() || programGeoSubGeoRWGroupSetMap.isEmpty()){
                populateprogramGeoSubGeoGroupSetMaps();
            }
            
            
            //To prepare programId Map
            for(Core_MDF_ChannelProgram__mdt cpm : ([SELECT Core_MDF_Abbreviated_ProgramName_txt__c, MasterLabel
                                                     FROM Core_MDF_ChannelProgram__mdt])){
                channelProgramMetadataNameMap.put(cpm.MasterLabel, cpm.Core_MDF_Abbreviated_ProgramName_txt__c); 
                //DE62015 fix
                channelProgramAbbreviationToNameMap.put(cpm.Core_MDF_Abbreviated_ProgramName_txt__c,cpm.MasterLabel);
            }
            
            for (ChannelProgram cp : [SELECT Id, Name
                                      FROM ChannelProgram
                                      WHERE Name =: channelProgramMetadataNameMap.keySet()]){
                programIdMap.put(cp.Id,channelProgramMetadataNameMap.get(cp.Name));
            }
            
            //Iterate over iupgmList to create accountProgramGeoIdNameMap and accountProgramGeoUserIdSetMap map
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Core_MDF_All_Accounts_cd__c,Core_MDF_Program_nm__c, Core_MDF_Account_id__r.Name, Core_MDF_Channel_Program_id__r.Name,
                                                                   Core_MDF_Region_cd__c, Core_MDF_Account_id__c, Core_MDF_Channel_Program_id__c,
                                                                   Core_MDF_User_id__c,Core_MDF_Sub_Region_cd__c,Core_MDF_Region_Sub_Region_nm__c,
                                                                   Core_MDF_Role_nm__c
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                   WHERE Id IN : iupgmList]){
              if(iupgm.Core_MDF_All_Accounts_cd__c == 'No') {                    
                    accountIdSet.add(iupgm.Core_MDF_Account_id__c);
                    programIdSet.add(iupgm.Core_MDF_Channel_Program_id__c);
                    geoList = iupgm.Core_MDF_Region_cd__c.split(';');
                
                    if(iupgm.Core_MDF_Sub_Region_cd__c != NULL){
                        subGeoList = iupgm.Core_MDF_Sub_Region_cd__c.split(';');
                    }
                    
                    //Checks if the marketing user is false on the User record
                    /*if(!iupgm.Core_MDF_User_id__r.UserPermissionsMarketingUser && accManagerRoles.contains(iupgm.Core_MDF_Role_nm__c)){     
                        User userInstance = new User();
                        userInstance.Id = iupgm.Core_MDF_User_id__c;
                        userInstance.UserPermissionsMarketingUser = TRUE;
                        updatedUserList.add(userInstance);
                    }*/
                    
                    for(String geoSubGeoStr : iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';')){
                        //for geo value with -*
                        if(geoSubGeoStr.endsWith('-*')){
                            geoSubGeoStr = geoSubGeoStr.removeEnd('-*');
                        }
                        //String programIdGeoSubGeo = (String)iupgm.Core_MDF_Channel_Program_id__r.Name + geoSubGeoStr;
                        //18+18+EMEA-META or 18+18+EMEA
                        String accountIdProgramIdGeo = (String)iupgm.Core_MDF_Account_id__c + (String)iupgm.Core_MDF_Channel_Program_id__c + geoSubGeoStr;
                        //AccName#EMEA-META or AccName#EMEA
                        String accountGeoName = iupgm.Core_MDF_Account_id__r.Name + '#' + geoSubGeoStr;                    
                        
                        //Map of accId+ProgramId+Geo and AccName#Geo-SubGeo
                        accountProgramGeoIdNameMap.put(accountIdProgramIdGeo,accountGeoName);
                        
                        //Map of accId+ProgramId+Geo and List of UserId
                        if(accountProgramGeoUserIdSetMap.containsKey(accountIdProgramIdGeo)){
                            accountProgramGeoUserIdSetMap.get(accountIdProgramIdGeo).add(iupgm.Core_MDF_User_id__c);
                        }
                        else{
                            accountProgramGeoUserIdSetMap.put(accountIdProgramIdGeo, new Set<Id>{iupgm.Core_MDF_User_id__c});
                        }
                    } 
              }//End of if iupgm.Core_MDF_All_Accounts_cd__c == 'No'  
              else if(iupgm.Core_MDF_All_Accounts_cd__c == 'Yes'){
                String roGrpDevName;
                String rwGrpDevName; 
                String programGeoSubGeo;
                List<String> geoSubGeoLst = iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';');
                for(String geoSubGeo : geoSubGeoLst){
                    //Creating keys to assign Group Id to insert Group Member
                    if(iupgm.Core_MDF_Region_Sub_Region_nm__c == 'WW'){
                        programGeoSubGeo = (String)iupgm.Core_MDF_Channel_Program_id__r.Name;
                    }else{
                        programGeoSubGeo = (String)iupgm.Core_MDF_Channel_Program_id__r.Name + geoSubGeo;  
                    }
                    System.debug('programGeoSubGeo'+programGeoSubGeo);
                    
                    if(roUsrRoleLst.contains(iupgm.Core_MDF_Role_nm__c)){
                        //Creating Group Member with Group Id = RO Group from mdt
                        if(programGeoSubGeoROGroupSetMap.containsKey(programGeoSubGeo) && programGeoSubGeoROGroupSetMap.get(programGeoSubGeo) != NULL){
                            GroupMember roGrpMem = new GroupMember();
                            roGrpMem.GroupId = programGeoSubGeoROGroupSetMap.get(programGeoSubGeo);
                            roGrpMem.UserOrGroupId = iupgm.Core_MDF_User_id__c;                         
                            newGroupMemberList.add(roGrpMem);
                        }
                    }
                  
                    if(rwUsrRoleLst.contains(iupgm.Core_MDF_Role_nm__c)){
                        //Creating Group Member with Group Id = RW Group from mdt
                        if(programGeoSubGeoRWGroupSetMap.containsKey(programGeoSubGeo) && programGeoSubGeoRWGroupSetMap.get(programGeoSubGeo) != NULL){
                            GroupMember rwGrpMem = new GroupMember();                           
                            rwGrpMem.GroupId = programGeoSubGeoRWGroupSetMap.get(programGeoSubGeo);
                            rwGrpMem.UserOrGroupId = iupgm.Core_MDF_User_id__c;
                            newGroupMemberList.add(rwGrpMem);
                        }
                    }
                 }
              }// end of elseif
           }// end of IUPGM for loop                                                       
            
            //Get PGM based on the Set and create accountProgramGeoGroupIdSetMap Map
            for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c, Core_MDF_Channel_Program__c, 
                                                         Core_MDF_Group_id__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c
                                                         FROM Core_MDF_Partner_Group_Mapping__c
                                                         WHERE Core_MDF_Account__c IN : accountIdSet AND 
                                                         Core_MDF_Channel_Program__c IN : programIdSet AND
                                                         Core_MDF_Type_Of_Access__c = 'Internal' AND
                                                         Core_MDF_Region_cd__c IN : geoList]){
                if(subGeoList.Contains(pgm.Core_MDF_Sub_Region_cd__c) || pgm.Core_MDF_Sub_Region_cd__c == NULL){
                    String accountProgramGeoGroupIdMapKey = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c +'-'+ pgm.Core_MDF_Sub_Region_cd__c;
                    
                    //if sub region is null, then -null has to be removed from the end                                         
                    if(accountProgramGeoGroupIdMapKey.endsWith('-null')){
                        accountProgramGeoGroupIdMapKey = accountProgramGeoGroupIdMapKey.removeEnd('-null'); 
                    }     
                    if(accountProgramGeoGroupIdSetMap.containsKey(accountProgramGeoGroupIdMapKey)){
                        accountProgramGeoGroupIdSetMap.get(accountProgramGeoGroupIdMapKey).add(pgm.Core_MDF_Group_id__c);
                    }
                    else{
                        accountProgramGeoGroupIdSetMap.put(accountProgramGeoGroupIdMapKey, new Set<Id>{pgm.Core_MDF_Group_id__c});
                    }
                }
            }
            
            //Key=Group Developer Name , value = Set<UserId>
            Map<String, Set<Id>> groupNameUserIdsMap = new Map<String, Set<Id>>();
            
            //key=GroupDeveloperName, value=AccId+ProgramId+Geo
            Map<String,String> pgmGroupNameMap = new Map<String,String>();
            
            //Set of GroupDeveloperName
            Set<String> groupNameSet = new Set<String>();
            
            //key=GroupId, value=Set<UserId>
            Map<Id, Set<Id>> groupIdUserIdSetMap = new Map<Id, Set<Id>>();
            
            if(accountProgramGeoUserIdSetMap.size() > 0){
                for(String key : accountProgramGeoUserIdSetMap.keySet()){
                    if(accountProgramGeoGroupIdSetMap.containsKey(key)){
                        //If key is present, that means PGM already exists,so create the Group Member
                        for(Id groupId : accountProgramGeoGroupIdSetMap.get(key)){
                            //if group Id already exists, then we need to add the users from accountProgramGeoUserIdSetMap to the group already present
                            if(groupIdUserIdSetMap.containsKey(groupId)){
                                Set<Id> userIdSet = accountProgramGeoUserIdSetMap.get(key);
                                userIdSet.addAll(groupIdUserIdSetMap.get(groupId));
                                groupIdUserIdSetMap.put(groupId, userIdSet);
                            }
                            else{
                                Set<Id> userIdSet = new Set<Id>();
                                userIdSet.addAll(accountProgramGeoUserIdSetMap.get(key));
                                groupIdUserIdSetMap.put(groupId, userIdSet);
                            }
                        }
                    }
                    //If the key's don't match i.e. there is no group present for respective Acc, Program and Geo
                    //create group,group member and PGM
                    else{ 
                        //Key= AccId+ProgramId+Geo from accountProgramGeoUserIdSetMap
                        
                        String accId = key.left(18);
                        String programId = key.left(36).right(18);

                        if(accountProgramGeoIdNameMap.containsKey(key)){
                            //String accGeoNameFromMap = Store the Account Name and Geo Name
                            String accGeoNameFromMap = accountProgramGeoIdNameMap.get(key);
                            
                            //Remove all the special characters and change to Upper Case
                            String accountName = accGeoNameFromMap.split('#')[0].replaceAll('[^a-zA-Z\\s+]', '').deleteWhitespace().toUpperCase();
                            
                            String programName = programIdMap.get(programId);
                             
                            geoSubGeoList.add(accGeoNameFromMap.split('#')[1].toUpperCase());
                            
                            geoAndSubGeoWrapper = getAccProgramGeoSubGeo(geoSubGeoList,accountName,programName);
                            geoSubGeoList.clear();
                            
                            String groupDeveloperName = geoAndSubGeoWrapper.groupDeveloperName;
                            String groupName = geoAndSubGeoWrapper.groupName;
                            
                            //Check if Developer Name already exists in the Set else create new Group
                            if(!groupNameSet.contains(groupDeveloperName)){
                                Group newGroup = new Group();
                                newGroup.Name = groupName;
                                newGroup.DeveloperName = groupDeveloperName;
                                newGroupMap.put(groupDeveloperName, newGroup);
                                groupNameSet.add(groupDeveloperName);
                            }

                            //DE62015 fix: Create a Map with Group Name and Channel Program
                            string value= channelProgramAbbreviationToNameMap.get(programName);
                            if(value!=null){newGroupNameToChannelProgramMap.put(groupDeveloperName,value);}        
                            system.debug('newGroupNameToChannelProgramMap'+newGroupNameToChannelProgramMap);
                            
                            for(Id userId : accountProgramGeoUserIdSetMap.get(key)){
                                //Create Group and UserId Map
                                if(groupNameUserIdsMap.containsKey(groupDeveloperName)){
                                    Set<Id> userIds = new Set<Id>();
                                    userIds = groupNameUserIdsMap.get(groupDeveloperName);
                                    userIds.add(userId);
                                    groupNameUserIdsMap.put(groupDeveloperName,userIds);
                                }
                                else{
                                    groupNameUserIdsMap.put(groupDeveloperName, new Set<Id> {userId});
                                }
                            }
                            
                            //Check if the pgmGroupNameMap already contains a pgm  created for a particular group else create new PGM
                            if(!pgmGroupNameMap.containsKey(groupDeveloperName)){
                                Core_MDF_Partner_Group_Mapping__c newPGM = new Core_MDF_Partner_Group_Mapping__c();
                                newPGM.Core_MDF_Account__c = accId;
                                newPGM.Core_MDF_Channel_Program__c = programId;
                                newPGM.Core_MDF_Region_cd__c = String.join(new List<String>(geoAndSubGeoWrapper.geo), ';');
                                if(geoAndSubGeoWrapper.subGeo.Size() > 0){newPGM.Core_MDF_Sub_Region_cd__c = String.join(new List<String>(geoAndSubGeoWrapper.subGeo), ';');}  
                                newPGM.Core_MDF_Group_Name__c = groupDeveloperName;
                                newPGM.Core_MDF_Type_of_Access__c = 'Internal';
                                //NP - US579189 - Setting Source of PGM insert
                                newPGM.Core_MDF_Source_Txt__c= 'IUPGM';
                                
                                newPGMList.add(newPGM);
                                pgmGroupNameMap.put(groupDeveloperName,key);
                            }
                        }
                    } 
                }
            }
            
            //key=GroupDeveloperName, value=Group 
            Map<String, Group> groupDevNameGroupMap = new Map<String, Group>();
            
            //Check if Group already exists without PGM, if exists, remove the group and add the group to groupDevNameGroupMap. 
            //Insert the remaining groups
            if(newGroupMap.size() > 0){
                for(Group groupRec : [SELECT Id, DeveloperName, Name
                                      FROM Group
                                      WHERE DeveloperName IN :groupNameSet ]){
                                          newGroupMap.remove(groupRec.DeveloperName);
                                          groupDevNameGroupMap.put(groupRec.DeveloperName, groupRec);
                                      }
                insert newGroupMap.values();
            }
            
            //groupFinalList - contains all the Groups including the groups removed from newGroupMap
            List<Group> groupFinalList = new List<Group>();
            if(newGroupMap.size() > 0){
                groupFinalList.addAll(newGroupMap.values());
            }
            if(groupDevNameGroupMap.size() > 0){
                groupFinalList.addAll(groupDevNameGroupMap.values());
            }
            
            //key=GroupDeveloperName, value=GroupId
            Map<String, Id> groupNameIdMap = new Map<String, Id>();
            
            //Build the map of Name as key and Id as value
            if(groupFinalList.size() > 0){
                for(Group grp : groupFinalList){
                    groupNameIdMap.put(grp.DeveloperName, grp.Id);
                }
            }
            
            //Create GroupMember List
            for(String groupName : groupNameUserIdsMap.keySet()){
                for(Id userId : groupNameUserIdsMap.get(groupName)){
                    //Add all the Group Members by iterating over the Set of User Ids
                    GroupMember newGroupMember = new GroupMember();
                    newGroupMember.GroupId = groupNameIdMap.get(groupName);
                    newGroupMember.UserOrGroupId = userId;
                    newGroupMemberList.add(newGroupMember);
                }
                
            }
            
            //Create groupMember from groupIdUserIdSetMap
            if(groupIdUserIdSetMap.size() > 0){
                for(Id groupId : groupIdUserIdSetMap.keySet()){
                    for(Id userId : groupIdUserIdSetMap.get(groupId)){
                        GroupMember newGroupMember = new GroupMember();
                        newGroupMember.GroupId = groupId;
                        newGroupMember.UserOrGroupId = userId;
                        newGroupMemberList.add(newGroupMember);
                    }
                }
            }

            //DE62015 fix: Create groupMember for Master Group insertion
            if(newGroupNameToChannelProgramMap.size()>0){
                queryMetadataForMasterGroup();
                for(string groupName:newGroupNameToChannelProgramMap.keySet()){
                    GroupMember newGroupMember = new GroupMember();
                    newGroupMember.GroupId = channelProgramToMasterGroupId.get(newGroupNameToChannelProgramMap.get(groupName));
                    newGroupMember.UserOrGroupId = groupNameIdMap.get(groupName);
                    newGroupMemberList.add(newGroupMember);
                    system.debug('newGroupNameToChannelProgramMap.get(groupName)' + newGroupMember.GroupId);
                    system.debug('groupName' + newGroupMember.UserOrGroupId);

                }
            }

            system.debug('newGroupMemberList'+ newGroupMemberList);
            
            /*if(updatedUserList.Size() > 0 && updatedUserList != NULL){
                Database.update(updatedUserList);
            }*/
            
            //To insert GroupMember, Call the createGroupMember method
            if(newGroupMemberList.size() > 0){
                String jsonStringGM = JSON.serialize(newGroupMemberList);
                Core_MDF_IUPGM_ServiceHandler.createGroupMember(jsonStringGM);
            }

            //Insert PGM
            if(newPGMList.size() > 0){
                Database.insert(newPGMList,false);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    /***************************************************************************************************** 
    Method Name   :        createGroupMember
    @return       :        void
    @parameters   :        String jsonString which has new GroupMember
    Description   :        To insert the GroupMember records
    Added By      :        Accenture - VK - 07/29/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    @future
    public static void createGroupMember(String jsonStringGM){
        try{
            List<GroupMember> gmList = (List<GroupMember>)JSON.deserialize(jsonStringGM,List<GroupMember>.class);
            Database.SaveResult[] saveList = Database.insert(gmList,true);
            system.debug('saveList' + saveList); 
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /***************************************************************************************************** 
    Method Name   :        checkUserPermission
    @return       :        void
    @parameters   :        List of Internal Users Partner Geo Mapping records
    Description   :        To validate user permission set and role
    Added By      :        Accenture - VK - 08/19/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public static void checkUserPermission(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList, 
                                           Boolean isInsert, 
                                           Boolean isUpdate,
                                           Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> oldIupgmMap){
        
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> channelProgramIdSet = new Set<Id>();
        Set<String> roleSet = new Set<String>();
        Set<String> channelProgramNameSet = new Set<String>();

        //key=UserId, value=Set<Permission set names>
        Map<Id,Set<String>> userIdPermissionSetNameMap = new Map<Id,Set<String>>();
        
        //key=Role, value=Set<Channel Program>
        Map<String,Set<String>> roleChannelProgramMetadatMap = new Map<String,Set<String>>();
        
        //key=Channel Program Name, value=Channel Program Id
        Map<String,Id> channelProgramNameIdMap = new Map<String,Id>();
        
        //key=channelProgramName, value=Id
        Map<String,Id> programNameIdMap = new Map<String,Id>();
        
      //List to update region and sub region
      List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToBeUpdated = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
      List<String> geoSubGeoList = new List<String>();
        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper geoAndSubGeoWrapper = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
                                               
        try{
            //Iterate over iupgmList, check if new or Core_MDF_Region_Sub_Region_nm__c is updated
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
                if(isInsert || (isUpdate && oldIupgmMap.get(iupgm.Id).Core_MDF_Region_Sub_Region_nm__c != iupgm.Core_MDF_Region_Sub_Region_nm__c)){
                    userIdSet.add(iupgm.Core_MDF_User_id__c);
                    channelProgramNameSet.add(iupgm.Core_MDF_Program_nm__c);
                    roleSet.add(iupgm.Core_MDF_Role_nm__c);
                    iupgmListToBeUpdated.add(iupgm);
                }
            }
            
            //only during insert validate the roles and update the active check and channel program Id
            if(isInsert){
                //Form programIdMap
                if(channelProgramNameSet.Size() > 0){
                    for(ChannelProgram cp : [SELECT Id, Core_MDF_Technical_Program_Name__c
                                            FROM ChannelProgram
                                            WHERE Core_MDF_Technical_Program_Name__c IN : channelProgramNameSet]){
                        programNameIdMap.put(cp.Core_MDF_Technical_Program_Name__c,cp.Id);
                    }
                }
            
                //Form the userIdPermissionSetNameMap
                if(userIdSet.Size() > 0){ 
                    for(PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name,AssigneeId
                                                    FROM PermissionSetAssignment
                                                    WHERE AssigneeId IN :userIdSet]){
                        if(userIdPermissionSetNameMap.containsKey(psa.AssigneeId)){
                            userIdPermissionSetNameMap.get(psa.AssigneeId).add(psa.PermissionSet.Name);
                        }
                        else{
                            userIdPermissionSetNameMap.put(psa.AssigneeId, new Set<String>{psa.PermissionSet.Name});
                        }
                    }
                }
            
                //Iterate over iupgmList
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
                    Set<String> psNameSet = userIdPermissionSetNameMap.get(iupgm.Core_MDF_User_id__c);
                    //Check if the user has any permission set
                    if(psNameSet == NULL){ iupgm.addError(Label.Core_MDF_UserHasNoPermissionSet);//User does not have permission
                    }
                    //Check if the user role and user's permission set matches
                    else if(!psNameSet.contains(iupgm.Core_MDF_Role_nm__c)){
                        iupgm.addError(Label.Core_MDF_UserWithoutAccessToRole);//User does not have access to this role
                    }
                    else{
                        iupgm.Core_MDF_Active_Ind__c = TRUE;
                        iupgm.Core_MDF_Channel_Program_id__c = programNameIdMap.get(iupgm.Core_MDF_Program_nm__c);
                        iupgm.Core_MDF_AccountIdProgramRoleUserId_txt__c = iupgm.Core_MDF_Account_id__c+iupgm.Core_MDF_Program_nm__c+iupgm.Core_MDF_Role_nm__c+iupgm.Core_MDF_User_id__c;
                        iupgmListToBeUpdated.add(iupgm);
                    }
                }
            }
            
            if(iupgmListToBeUpdated.Size() > 0){
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmListToBeUpdated){
                    
                    geoSubGeoList = iupgm.Core_MDF_Region_Sub_Region_nm__c.Split(';');
                    
                    geoAndSubGeoWrapper = getAccProgramGeoSubGeo(geoSubGeoList,null,null);                     
                    
                    if(geoAndSubGeoWrapper.geo != NULL){
                        iupgm.Core_MDF_Region_cd__c = String.join(new List<String>(geoAndSubGeoWrapper.geo), ';');
                    }
                    
                    if(geoAndSubGeoWrapper.subGeo != NULL){
                        iupgm.Core_MDF_Sub_Region_cd__c = String.join(new List<String>(geoAndSubGeoWrapper.subGeo), ';');
                    } 
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    

    /***************************************************************************************************** 
    Method Name   :        removeGroupMember
    @return       :        void
    @parameters   :        newMap - Trigger.newMap for Core_MDF_Int_Users_Partner_Geo_Mapping__c
                 oldMap - Trigger.oldMap for Core_MDF_Int_Users_Partner_Geo_Mapping__c
    Description   :        To remove the user from the group if deactivated or Add the user back to group if activated
    Added By      :        Accenture - VK - 08/20/2019
    Modified By   :        Date:           Changes: 
    Accenture - VK       03/10/2019    Update the method to handle geo update on IUPGM
    ******************************************************************************************************/
    public static void removeGroupMember(Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> newMap,
                                         Map<Id,Core_MDF_Int_Users_Partner_Geo_Mapping__c> OldMap){
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> groupIdSet = new Set<Id>();
        Set<String> groupNameSetFromMdt = new Set<String>();
        Set<Id> userIdSet = new Set<Id>();
                                             
        List<String> geoSubGeoList = new List<String>();
        String progKey; 
        String progGeoSubGeoKey;
        List<GroupMember> groupMemToBeDeleted = new List<GroupMember>();                                                  
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToBeUpdated = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<String> roUsrRoleLst = System.Label.Core_MDF_User_Role_with_Read_Only_Access.split(';');                                            
        List<String> rwUsrRoleLst = System.Label.Core_MDF_User_Role_with_Read_Write_Access.split(';');

        Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper geoAndSubGeoWrapper = new Core_MDF_IUPGM_ServiceHandler.geoSubGeoWrapper();
        Map<String,Set<Id>> groupToUsersMap =new Map<String,Set<Id>>();
        Set<Id> userList = new Set<Id>();
        Set<Id> usrIdforGm = new Set<Id>();                                    
        Map<Id, String> CpNametpCpID = new Map<Id, String>();    
                                             
                                                     
        try{
            populateprogramGeoSubGeoGroupSetMaps();
            Map<Id,ChannelProgram> channelProgramMap = new Map<Id,ChannelProgram>([Select Id,Name, Core_MDF_Technical_Program_Name__c from ChannelProgram]);
            Map<String, Set<Id>> accProgGeoToUsrMap = new Map<String, Set<Id>>();
            for(Id iupgmId : newMap.keySet()){
               for(String geoSubGeo : oldMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c.split(';')){
                    //Check if geo has been removed or Check if the record is inactive
                    if(!newMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c.split(';').Contains(geoSubGeo) || ((oldMap.get(iupgmId).Core_MDF_Active_Ind__c) && !newMap.get(iupgmId).Core_MDF_Active_Ind__c)){
                        
                        if(newMap.get(iupgmId).Core_MDF_All_Accounts_cd__c == 'No'){
                            accountIdSet.add(newMap.get(iupgmId).Core_MDF_Account_id__c);
                            userIdSet.add(newMap.get(iupgmId).Core_MDF_User_id__c);
                            programIdSet.add(newMap.get(iupgmId).Core_MDF_Channel_Program_id__c);
                            geoSubGeoList.add(geoSubGeo);
                            String accProgGeoSubGeo = (String)newMap.get(iupgmId).Core_MDF_Account_id__c + newMap.get(iupgmId).Core_MDF_Channel_Program_id__c + geoSubGeo;
                            if(accProgGeoToUsrMap.containsKey(accProgGeoSubGeo) && accProgGeoToUsrMap.get(accProgGeoSubGeo) != NULL){
                                accProgGeoToUsrMap.get(accProgGeoSubGeo).add(newMap.get(iupgmId).Core_MDF_User_id__c);
                            }
                            else{
                                Set<Id> usrIdSet = new Set<Id>();
                                usrIdSet.add(newMap.get(iupgmId).Core_MDF_User_id__c);
                                accProgGeoToUsrMap.put(accProgGeoSubGeo,usrIdSet);
                            }
                        }
                        //Preparing key to get the RO/RW Group Id and User Id from RO/RW Group
                        else if(newMap.get(iupgmId).Core_MDF_All_Accounts_cd__c == 'Yes'){                              
                            String usrRole = newMap.get(iupgmId).Core_MDF_Role_nm__c;  
                            String localKey ='';
                            if(geoSubGeo != 'WW'){
                                localKey = channelProgramMap.get(newMap.get(iupgmId).Core_MDF_Channel_Program_id__c).Name + geoSubGeo;
                            }else{
                                localKey = channelProgramMap.get(newMap.get(iupgmId).Core_MDF_Channel_Program_id__c).Name;
                            }
                            //Populating RO Group Id and User Id from RO Group             
                            if(roUsrRoleLst.contains(usrRole)){
                                if(programGeoSubGeoROGroupSetMap != NULL && !programGeoSubGeoROGroupSetMap.isEmpty() && programGeoSubGeoROGroupSetMap.containsKey(localKey) && programGeoSubGeoROGroupSetMap.get(localKey) != NULL){
                                    if(groupToUsersMap.containsKey(programGeoSubGeoROGroupSetMap.get(localKey))){
                                        groupToUsersMap.get(programGeoSubGeoROGroupSetMap.get(localKey)).add(oldmap.get(iupgmid).Core_MDF_User_id__c);
                                        usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoROGroupSetMap.get(localKey)));
                                    }
                                    else{
                                        groupToUsersMap.put(programGeoSubGeoROGroupSetMap.get(localKey), new Set<Id>{oldmap.get(iupgmid).Core_MDF_User_id__c});
                                        usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoROGroupSetMap.get(localKey)));
                                    }
                                }
                            }
                            //Populating RW Group Id and User Id from RW Group      
                            else if(rwUsrRoleLst.contains(usrRole)){ 
                                if(programGeoSubGeoRWGroupSetMap != NULL && !programGeoSubGeoRWGroupSetMap.isEmpty() && programGeoSubGeoRWGroupSetMap.containsKey(localKey) && programGeoSubGeoRWGroupSetMap.get(localKey) != NULL){    
                                    if(groupToUsersMap.containsKey(programGeoSubGeoRWGroupSetMap.get(localKey))){
                                        groupToUsersMap.get(programGeoSubGeoRWGroupSetMap.get(localKey)).add(oldmap.get(iupgmid).Core_MDF_User_id__c);
                                        usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoRWGroupSetMap.get(localKey)));
                                    }
                                    else{
                                        groupToUsersMap.put(programGeoSubGeoRWGroupSetMap.get(localKey), new Set<Id>{oldmap.get(iupgmid).Core_MDF_User_id__c});
                                        usrIdforGm.addAll(groupToUsersMap.get(programGeoSubGeoRWGroupSetMap.get(localKey)));
                                    }
                                }                                  
                            }                               
                                
                        }// end of else if
                    }
                }// end of for
                
                //Check if the record is made active or if the Geo-SubGeo has been updated
                if((newMap.get(iupgmId).Core_MDF_Active_Ind__c == TRUE && oldMap.get(iupgmId).Core_MDF_Active_Ind__c == FALSE) || 
                    (newMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c != oldMap.get(iupgmId).Core_MDF_Region_Sub_Region_nm__c && 
                    newMap.get(iupgmId).Core_MDF_Active_Ind__c == TRUE)){             
                    iupgmListToBeUpdated.add(newMap.get(iupgmId));
                }
            }
            
            //Gets the geo and sub geo set
            geoAndSubGeoWrapper = getAccProgramGeoSubGeo(geoSubGeoList,null,null);
            Map<String, Set<Id>> pgmGroupToUserMap = new Map<String, Set<Id>>();
            //Get the groupId from PGM
            if(accountIdSet.Size() > 0 && programIdSet.Size() > 0){
                for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_id__c, 
                                                             Core_MDF_Region_cd__c,Core_MDF_Sub_Region_cd__c
                                                             FROM Core_MDF_Partner_Group_Mapping__c
                                                             WHERE Core_MDF_Account__c IN : accountIdSet AND 
                                                             Core_MDF_Channel_Program__c IN : programIdSet AND
                                                             Core_MDF_Type_Of_Access__c = 'Internal' AND
                                                             Core_MDF_Region_cd__c IN : geoAndSubGeoWrapper.geo]){ 
                    /*if((geoAndSubGeoWrapper.subGeo.Contains(pgm.Core_MDF_Sub_Region_cd__c) || pgm.Core_MDF_Sub_Region_cd__c == NULL)){
                        groupIdSet.add(pgm.Core_MDF_Group_id__c); 
                    }*/
                    String accPGS;                                              
                    if(pgm.Core_MDF_Sub_Region_cd__c == NULL){                                             
                         accPGS = (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;                                      
                    }else{
                         accPGS = (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c +'-'+ pgm.Core_MDF_Sub_Region_cd__c;                                    
                    }
                    if(accProgGeoToUsrMap.containsKey(accPGS) && accProgGeoToUsrMap.get(accPGS) != NULL){
                         pgmGroupToUserMap.put(pgm.Core_MDF_Group_id__c, accProgGeoToUsrMap.get(accPGS));
                    }                                            
                }
            }
            
            //Iterating over Group Member to be deleted 
            //GroupID can be either from PGM or Metadata for IUPGM 
            if((pgmGroupToUserMap.size() > 0  && userIdSet.size() > 0 ) || (groupToUsersMap.size() > 0 && usrIdforGm.size() > 0)){              
                for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE                                      
                                      (GroupId IN: pgmGroupToUserMap.keySet() AND UserOrGroupId IN: userIdSet) OR
                                      (GroupId IN:groupToUsersMap.keySet() AND UserOrGroupId IN: usrIdforGm)]){   //(GroupId IN: groupIdSet AND UserOrGroupId IN: userIdSet) OR
                
                //key = IUPGM Group Id, value = UserId set
                if(groupToUsersMap.containsKey(gm.GroupId) && groupToUsersMap.get(gm.GroupId) != NULL && 
                   groupToUsersMap.get(gm.GroupId).contains(gm.UserOrGroupId)){
                       groupMemToBeDeleted.add(gm);
                 //key = PGM Group Id, value = UserId set
                 }else if(pgmGroupToUserMap.containsKey(gm.GroupId) && pgmGroupToUserMap.get(gm.GroupId) != NULL &&
                            pgmGroupToUserMap.get(gm.GroupId).contains(gm.UserOrGroupId)){
                       groupMemToBeDeleted.add(gm);
                 }
              } 
            }
            
            //Call deleteGroupMember method
            if(groupMemToBeDeleted.size() > 0){
                if(System.isFuture() || System.isBatch()){                    
                    System.enqueueJob(new Core_MDF_DeleteGroupMember(groupMemToBeDeleted));  
                }else{
                    String gmJson = JSON.serialize(groupMemToBeDeleted);
                    Core_MDF_IUPGM_ServiceHandler.deleteGroupMember(gmJson);
                }
            }
            
            //Call checkPGM method to add user back to the group
            if(iupgmListToBeUpdated.size() > 0){
                Core_MDF_IUPGM_ServiceHandler.checkPGM(iupgmListToBeUpdated);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }   
    
    /***************************************************************************************************** 
    Method Name   :        deleteGroupMember
    @return       :        void
    @parameters   :        String jsonString which has GroupMember records to be deleted
    Description   :        To delete the GroupMember records
    Added By      :        Accenture - VK - 08/20/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    @future 
    public static void deleteGroupMember(String jsonString){
        try{
            List<GroupMember> gmListToBeDeleted = (List<GroupMember>)JSON.deserialize(jsonString,List<GroupMember>.class);
            Database.delete(gmListToBeDeleted);
         }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /***************************************************************************************************** 
    Class Name    :        geoSubGeoWrapper
    Description   :        Wrapper with geoSet,subGeoSet,groupName and groupDeveloperName
    Added By      :        Accenture - VK - 10/24/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public class GeoSubGeoWrapper{
        //Preparing set of geo and sub geo which will be used in PGM query of removeGroupMember method
        //The same set is used in checkUserPermission and checkPGM method where the set is converted to a string to update iupgm's and pgm's geo and sub geo field
        Set<String> geo;
        Set<String> subGeo;
        //The strings groupName and groupDeveloperName is used in checkPGM method
        String groupName;
        String groupDeveloperName;
    }
    
    /***************************************************************************************************** 
    Method Name   :        getAccProgramGeoSubGeo
    @return       :        geoSubGeoWrapper
    @parameters   :        List of String with geo-Sub Geo, account name and program name
    Description   :        To split the geo and sub geo values
    Added By      :        Accenture - VK - 10/24/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public static geoSubGeoWrapper getAccProgramGeoSubGeo(List<String> geoSubGeoStringList, String accountName, String programName){
        
        String geo;
        String subGeo;
        Set<String> geoSet = new Set<String>();
        Set<String> subGeoSet = new Set<String>();
        String groupName;
        String groupDeveloperName;
        Integer initalGroupDeveloperName;
        Integer accountNameLength;
        
        for(String geoSubGeo : geoSubGeoStringList){
            if(geoSubGeo.Split('-').Size() >= 2 && !geoSubGeo.endsWith('-*')){
                geo = geoSubGeo.Split('-')[0];
                subGeo = geoSubGeo.Split('-')[1];
            }
            else{
                geo = geoSubGeo.Split('-')[0];
            }
      
            if(geo != NULL){
                geoSet.add(geo);
            }            
            if(subGeo != NULL){subGeoSet.add(subGeo);}            
        }       
        
        if(accountName != NULL && programName != NULL){
            if(!subGeoSet.isEmpty()){
                initalGroupDeveloperName = ('Core_MDF_CCP_'+'_'+programName.left(4)+'_'+geo+'_'+subGeo+'_'+'INTERNAL').length();
                accountNameLength = math.abs(40 - initalGroupDeveloperName);
                groupDeveloperName = 'Core_MDF_CCP_'+accountName.left(accountNameLength)+'_'+programName+'_'+geo+'_'+subGeo+'_'+'INTERNAL';
                groupName = 'CCP '+accountName.left(accountNameLength)+ ' ' + programName + ' ' + geo + ' ' + subGeo + ' INTERNAL';
            }
            else if(subGeoSet.isEmpty()){
                initalGroupDeveloperName = ('Core_MDF_CCP_'+'_'+programName.left(4)+'_'+geo+'_'+'INTERNAL').length();
                accountNameLength = math.abs(40 - initalGroupDeveloperName);
                groupDeveloperName = 'Core_MDF_CCP_'+accountName.left(accountNameLength)+'_'+programName+'_'+geo+'_'+'INTERNAL';
                groupName = 'CCP '+accountName.left(accountNameLength)+ ' ' + programName + ' ' + geo + ' ' + ' INTERNAL';
            }
        }
        
        geoSubGeoWrapper wrapper = new geoSubGeoWrapper();
        wrapper.geo = geoSet;
        wrapper.SubGeo = subGeoSet;
        wrapper.groupDeveloperName = groupDeveloperName;
        wrapper.groupName = groupName;        
        return wrapper;    
    }

    //DE62015 fix
    //Method queries the custom metadata for all the CCP Master group names and creates a map with key: Channel Program ; value: Master group name
    public static void queryMetadataForMasterGroup(){
        try{
            Map<string,ID> groupNameToGroupIdMap = new Map<string,ID>();
            Map<string,string> channelProgramToMasterGroupName = new Map<string,string>();
            List<string> groupNames=new List<string>();

            for(Core_MDF_ClaimActAllocRecTypeMapping__mdt record: [select Core_MDF_Channel_Program_txt__c,Core_MDF_Internal_Master_Group_Name_Txt__c 
                                                                   from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){ 
                string key = record.Core_MDF_Channel_Program_txt__c;
                channelProgramToMasterGroupName.put(key,record.Core_MDF_Internal_Master_Group_Name_Txt__c);  

                groupNames.add(record.Core_MDF_Internal_Master_Group_Name_Txt__c);                                             
                }
            for(Group record: [select DeveloperName,id from group where DeveloperName in : groupNames]){
                groupNameToGroupIdMap.put(record.DeveloperName,record.id);
            }
            for(string channelProgram:channelProgramToMasterGroupName.keyset()){
                 channelProgramToMasterGroupId.put(channelProgram,groupNameToGroupIdMap.get(channelProgramToMasterGroupName.get(channelProgram)));   
            }
                system.debug('channelProgramToMasterGroupName' + channelProgramToMasterGroupName);
                system.debug('channelProgramToMasterGroupId' + channelProgramToMasterGroupId);
        }

        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
}