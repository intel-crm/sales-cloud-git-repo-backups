public without sharing class Core_MDF_PGM_ServiceHandler {
    
    public static Map<string,string> channelProgramAcessToMasterGroupName = new Map<string,string>();
    public static List<string> groupNames = new List<string>();
    public static Map<string,ID> groupNameToGroupId = new Map<string,ID>();
    private static string externalType=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External');
    public static String ipaTechnicalProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
    
    //Method populates AccountIdGroupName and GroupId on PGM record insert/update
    public static void populateAccountIdGroupNameAndGroupId(List<Core_MDF_Partner_Group_Mapping__c> newPGMList, Map<id,Core_MDF_Partner_Group_Mapping__c> oldPGMList){
        
        List<string> subGroupNames = new List<string>();
        Map<string,ID> groupNametoGroupIdMap = new Map<string,ID>();
        Map<string,ID>  allAccessGroupNametoGroupIdMap = new Map<string,ID>();
        Map<String,ID> groupNametoVirtualCorpIdMap = new Map<String,ID>();
        List<String> extPGMGrpNames = new List<String>();
        Set<Id> pgmGrpIds = new Set<Id>();
        List<id> cpId = new List<id>();
        List<Core_MDF_ChannelProgram__mdt> cpList = [Select Core_MDF_Program_ID__c from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c in :Core_MDF_CCP_ConstantClass.allAccessGroupSupportedPrograms];

        for(Core_MDF_ChannelProgram__mdt cp : cpList){
            cpId.add(cp.Core_MDF_Program_ID__c);
        }
        Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmGrpAllAccessGrpIdNameMap = new  Map<Id,Core_MDF_Partner_Group_Mapping__c>();
        List<string> subGrps = new List<string>();
        Map<Id,String> comarketingAccIds = new Map<Id,String>();
        Map<Id,Id> ultimateAccToVCIdMap = new Map<Id,Id>();
        String ccpProgramName = System.Label.Core_MDF_CCP_Program_Names; 
        List<String> channelProgramNames = new List<String>(ccpProgramName.split(';'));
	Map<String,ID> grpNameToVCIdMap = new Map<String,ID>();
        try{
            for(Core_MDF_Partner_Group_Mapping__c pgmRecord : newPGMList){
                //throw validation error when virtual corp is provided for non CCP programs
                if(!channelProgramNames.contains(pgmRecord.Core_MDF_Channel_Program_Name_Txt__c) && pgmRecord.Core_MDF_Virtual_Corp_Nm__c != null){
                    pgmRecord.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_VirtualCorpError'));
                }
                pgmRecord.Core_MDF_AccountIdGroupName__c = pgmRecord.Core_MDF_Account__c + '_' + pgmRecord.Core_MDF_Group_Name__c;                    
                 //Add to list if Group ID is null or if the Group Name has been changed                                    	
                if(pgmRecord.Core_MDF_Group_Id__c == null || pgmRecord.Core_MDF_Virtual_Corp_nm__c == null || (oldPGMList!= NULL && oldPGMList.get(pgmRecord.id) != NULL && (pgmRecord.Core_MDF_Group_Name__c != oldPGMList.get(pgmRecord.id).Core_MDF_Group_Name__c || pgmRecord.Core_MDF_Virtual_Corp_nm__c != oldPGMList.get(pgmRecord.id).Core_MDF_Virtual_Corp_nm__c))){
                    subGroupNames.add(pgmRecord.Core_MDF_Group_Name__c);
                    extPGMGrpNames.add(pgmRecord.Core_MDF_Group_Name__c);
                }
                //Add to list if All Access Group ID is null when it has All Access Group Name or if the All Acces Group Name has been changed -- added by Alekhya
                if(cpId.contains(pgmRecord.Core_MDF_Channel_Program__c) && pgmRecord.Core_MDF_All_Access_Group_Nm__c!= null && (pgmRecord.Core_MDF_All_Access_Group_Id__c == null || (oldPGMList!= NULL && oldPGMList.get(pgmRecord.id) != NULL && pgmRecord.Core_MDF_All_Access_Group_Nm__c != oldPGMList.get(pgmRecord.id).Core_MDF_All_Access_Group_Nm__c))){
                    subGroupNames.add(pgmRecord.Core_MDF_All_Access_Group_Nm__c);
                }
                //To blank out All Access Group Name on clone/edit of PGM
                if(pgmRecord.Core_MDF_All_Access_Group_Nm__c == null || (pgmRecord.Core_MDF_All_Access_Group_Id__c != null && pgmRecord.Core_MDF_All_Access_Group_Nm__c != oldPGMList.get(pgmRecord.id).Core_MDF_All_Access_Group_Nm__c ) || (oldPGMList!= NULL && oldPGMList.get(pgmRecord.id) != NULL && pgmRecord.Core_MDF_Group_Name__c != oldPGMList.get(pgmRecord.id).Core_MDF_Group_Name__c) || !cpId.contains(pgmRecord.Core_MDF_Channel_Program__c)){
                    pgmRecord.Core_MDF_All_Access_Group_Nm__c = null;
                    pgmRecord.Core_MDF_All_Access_Group_Id__c = null;
                    subGrps.add(pgmRecord.Core_MDF_Group_Name__c);
                }
                if(pgmRecord.Core_MDF_Type_Of_Access__c == 'Internal'){
                    comarketingAccIds.put(pgmRecord.Core_MDF_Account__c,pgmRecord.Core_MDF_Channel_Program__c);
                }
                if(pgmRecord.Core_MDF_Group_Name__c != null && pgmRecord.Core_MDF_Virtual_Corp_nm__c != null){
                    grpNameToVCIdMap.put(pgmRecord.Core_MDF_Group_Name__c,pgmRecord.Core_MDF_Virtual_Corp_nm__c);
                }
            }
            if(subGroupNames.size()>0 || comarketingAccIds.size()>0 || extPGMGrpNames.size()>0){
                //Query the Group object for the Group Ids
                groupNametoGroupIdMap = queryForGroupIds(subGroupNames);
                groupNametoVirtualCorpIdMap = queryForVCIds(extPGMGrpNames);
                if(comarketingAccIds!=null){
                    ultimateAccToVCIdMap =  queryForVCIdsfromUltimateAcc(comarketingAccIds);
                }
                for(Core_MDF_Partner_Group_Mapping__c record : newPGMList){
                    if(record.Core_MDF_Group_Id__c == null || record.Core_MDF_Virtual_Corp_nm__c == null || (oldPGMList!= null && oldPGMList.get(record.id) != NULL && (record.Core_MDF_Group_Name__c != oldPGMList.get(record.id).Core_MDF_Group_Name__c || record.Core_MDF_Virtual_Corp_nm__c != oldPGMList.get(record.id).Core_MDF_Virtual_Corp_nm__c))){
                        //Update the Group id to the corresponding Group name in PGM record
                        record.Core_MDF_Group_Id__c = groupNametoGroupIdMap.get(record.Core_MDF_Group_Name__c);
                        //add one condition to check only channel programs are CCP programs (create one custom field)
                        if(groupNametoVirtualCorpIdMap.get(record.Core_MDF_Group_Name__c)!=null){
                            record.Core_MDF_Virtual_Corp_Nm__c = groupNametoVirtualCorpIdMap.get(record.Core_MDF_Group_Name__c);
                        }else if(record.Core_MDF_Virtual_Corp_Nm__c == null && grpNameToVCIdMap.containsKey(record.Core_MDF_Group_Name__c) && grpNameToVCIdMap.get(record.Core_MDF_Group_Name__c) != null){
                            record.Core_MDF_Virtual_Corp_Nm__c = grpNameToVCIdMap.get(record.Core_MDF_Group_Name__c);
                        }
                    }
                    //To map Virtual Corp on Internal PGMs
                    if(record.Core_MDF_Type_Of_Access__c == 'Internal' && ultimateAccToVCIdMap.get(record.Core_MDF_Account__c)!=null){
                        record.Core_MDF_Virtual_Corp_Nm__c = ultimateAccToVCIdMap.get(record.Core_MDF_Account__c);
                    }
                    //Update the All Access Group id to the corressponding All Access Group name in PGM record 
                    if(cpId.contains(record.Core_MDF_Channel_Program__c ) && record.Core_MDF_All_Access_Group_Nm__c!= null && (record.Core_MDF_All_Access_Group_Id__c == null || record.Core_MDF_All_Access_Group_Nm__c != oldPGMList.get(record.id).Core_MDF_All_Access_Group_Nm__c)){
                        record.Core_MDF_All_Access_Group_Id__c = groupNametoGroupIdMap.get(record.Core_MDF_All_Access_Group_Nm__c);
                    }
                }
            }
            if(subGrps.size()>0){
                for(Core_MDF_Partner_Group_Mapping__c record : newPGMList){
                    if(cpId.contains(record.Core_MDF_Channel_Program__c) && (record.Core_MDF_Group_Id__c != null || (oldPGMList!= NULL && oldPGMList.get(record.id) != NULL && record.Core_MDF_Group_Id__c!= oldPGMList.get(record.id).Core_MDF_Group_Id__c))){
                        pgmGrpIds.add(record.Core_MDF_Group_Id__c);
                    }
                }
            }
                if(pgmGrpIds.size()>0){
                    for(Core_MDF_Partner_Group_Mapping__c pgm : [select Core_MDF_Group_Id__c,Core_MDF_All_Access_Group_Id__c,Core_MDF_All_Access_Group_Nm__c
                            from Core_MDF_Partner_Group_Mapping__c 
                            where Core_MDF_Group_Id__c in : pgmGrpIds
                            and Core_MDF_Inactive_Ind__c = false 
                            and Core_MDF_Type_of_Access__c='External'
                            and Core_MDF_All_Access_Group_Id__c != null
                            and Core_MDF_All_Access_Group_Nm__c != null
                            and Core_MDF_Account__r.Core_MDF_CoMarketingActive__c = true]){
    
                        Id key = pgm.Core_MDF_Group_Id__c;
                        pgmGrpAllAccessGrpIdNameMap.put(key,pgm);
                    }
                }
            if(pgmGrpAllAccessGrpIdNameMap.size()>0){
                for(Core_MDF_Partner_Group_Mapping__c record : newPGMList){
                    //Update the All Access Group id to the corressponding All Access Group name in PGM record 
                    if(cpId.contains(record.Core_MDF_Channel_Program__c) && (record.Core_MDF_Group_Id__c!= null || (oldPGMList!= NULL && oldPGMList.get(record.id) != NULL && record.Core_MDF_Group_Id__c != oldPGMList.get(record.id).Core_MDF_Group_Id__c))){
                        record.Core_MDF_All_Access_Group_Id__c = pgmGrpAllAccessGrpIdNameMap.get(record.Core_MDF_Group_Id__c).Core_MDF_All_Access_Group_Id__c!= null ? pgmGrpAllAccessGrpIdNameMap.get(record.Core_MDF_Group_Id__c).Core_MDF_All_Access_Group_Id__c:null;
                        record.Core_MDF_All_Access_Group_Nm__c = pgmGrpAllAccessGrpIdNameMap.get(record.Core_MDF_Group_Id__c).Core_MDF_All_Access_Group_Nm__c!=null ? pgmGrpAllAccessGrpIdNameMap.get(record.Core_MDF_Group_Id__c).Core_MDF_All_Access_Group_Nm__c : null;
                    }
                    
                }
            }
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    //Method checks if Channel Program, Type of Access or Group Name is changed on PGM record update
    public static void checkIfValidUpdate(List<Core_MDF_Partner_Group_Mapping__c> newPGMList, Map<id,Core_MDF_Partner_Group_Mapping__c> oldPGMList){
        Map<Id, Core_MDF_Partner_Group_Mapping__c> pgmToBeProcessedMap = new Map<Id, Core_MDF_Partner_Group_Mapping__c>();
        List<Id> toBeRemoved = new List<Id>();
        Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmMap = new Map<Id,Core_MDF_Partner_Group_Mapping__c>();
        try{
            for(Core_MDF_Partner_Group_Mapping__c record: newPGMList){
                if(record.Core_MDF_Inactive_Ind__c != oldPGMList.get(record.id).Core_MDF_Inactive_Ind__c && record.Core_MDF_Type_of_Access__c == externalType){
                    pgmMap.put(record.Id,record);
                }
                if(record.Core_MDF_Channel_Program__c != oldPGMList.get(record.id).Core_MDF_Channel_Program__c 
                   || record.Core_MDF_Type_of_Access__c != oldPGMList.get(record.id).Core_MDF_Type_of_Access__c
                   || record.Core_MDF_Group_Name__c != oldPGMList.get(record.id).Core_MDF_Group_Name__c
                   || record.Core_MDF_All_Access_Group_Nm__c != oldPGMList.get(record.id).Core_MDF_All_Access_Group_Nm__c){  
                        pgmToBeProcessedMap.put(record.Id, record); 
                   }
            }
            if(((pgmMap != null && !pgmMap.isEmpty()) || (pgmToBeProcessedMap != null && !pgmToBeProcessedMap.isEmpty())) && Core_MDF_Utility.byPassFeature('Core_MDF_AddOrRemoveUserFromPgmGrp')){
                isInactiveIndicatorUpdated(pgmMap, pgmToBeProcessedMap);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
    }
    
    // Method helps in identifying the Master CCP group for the sub CCP group based on Channel Program, Type of Access
    public static void identifyMasterGroup(List<Core_MDF_Partner_Group_Mapping__c> pgmList, Set<Id> groupMemberIdToRemove){
        
        Map<string,List<string>> channelProgramAccessToSubGroupNameExternalList = new Map<string,List<string>>();
        Map<string,List<string>> channelProgramAccessToSubGroupNameInternalList = new Map<string,List<string>>();
        Map<id,id> toBeInserted = new Map<id,id>();          
        
        try{
            //1. Populate the Map containing key: Channel Program + Type of Access ; value : Master CCP group name
            if(channelProgramAcessToMasterGroupName.size()==0){queryMetadataForMasterGroup();}
            
            //2. Create a Map with key : Channel Program + Type of Access ; value : Sub CCP group Name
            for(Core_MDF_Partner_Group_Mapping__c pgmRecord: pgmList){
                if(pgmRecord.Core_MDF_Source_Txt__c != 'ProcessEntitlement'){
                    //DE62015 fix: Separate the Internal groups
                    if(pgmRecord.Core_MDF_Type_of_Access__c == 'Internal'){
                        string key = pgmRecord.Core_MDF_Channel_Program_Name_Txt__c;
                        key+= pgmRecord.Core_MDF_Type_of_Access__c;
                        
                        //DE61641 fix: Creating a list of group names for a single Channel Program + Type of Access
                        List<string> subGroupNames = channelProgramAccessToSubGroupNameInternalList.get(key);
                        if(subGroupNames == null){
                            subGroupNames = new List<string>();
                            subGroupNames.add(pgmRecord.Core_MDF_Group_Name__c);
                        }
                        else{
                            subGroupNames.add(pgmRecord.Core_MDF_Group_Name__c);
                        }
                        channelProgramAccessToSubGroupNameInternalList.put(key,subGroupNames);
                        
                    }
                    else if(pgmRecord.Core_MDF_Type_of_Access__c == 'External'){
                        string key = pgmRecord.Core_MDF_Channel_Program_Name_Txt__c;
                        key+= pgmRecord.Core_MDF_Type_of_Access__c;
                        
                        //DE61641 fix: Creating a list of group names for a single Channel Program + Type of Access
                        List<string> subGroupNames = channelProgramAccessToSubGroupNameExternalList.get(key);
                        if(subGroupNames == null){
                            subGroupNames = new List<string>();
                            subGroupNames.add(pgmRecord.Core_MDF_Group_Name__c);
                        }
                        else{
                            subGroupNames.add(pgmRecord.Core_MDF_Group_Name__c);
                        }
                        channelProgramAccessToSubGroupNameExternalList.put(key,subGroupNames);
                    }
                    groupNames.add(pgmRecord.Core_MDF_Group_Name__c);
                }
            }
            
            //3. Query all the Sub and Master group names and obtain the groupID
            if(groupNames.size()>0){groupNameToGroupId = queryForGroupIds(groupNames);}
            
            //4. Compare both the maps and create groupmember records containing the subgroupID and mastergroupID for External Records
            for(string channelProgramAccess : channelProgramAccessToSubGroupNameExternalList.keyset()){
                
                List<string> subGroupNameList = channelProgramAccessToSubGroupNameExternalList.get(channelProgramAccess);
                id masterGroupId =groupNameToGroupId.get(channelProgramAcessToMasterGroupName.get(channelProgramAccess));
                
                //DE61641 fix
                for(string subGroupName: subGroupNameList){
                    id subGroupId = groupNameToGroupId.get(subGroupName);
                    toBeInserted.put(subGroupId,masterGroupId);
                }
            }
            
            //Commented out due to lock issue (ONLY FOR INTERNAL)
            //5. Check if the internal groups are already part of the Master group, else add them to the toBeInserted list
            /*if(channelProgramAccessToSubGroupNameInternalList.size()>0){
Map<id,id> internalRecordsToBeInserted = checkIfSubGroupAlreadyMappedToMaster(channelProgramAccessToSubGroupNameInternalList);
toBeInserted.putall(internalRecordsToBeInserted);
}*/
            
            //6. Insert the Groupmember records
            if(toBeInserted.size()>0 || !groupMemberIdToRemove.isEmpty()){
                updateGroupMember(toBeInserted, groupMemberIdToRemove);
            }
        }
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    //Method queries the custom metadata for all the CCP Master group names and creates a map with key: Channel Program + Type of Access ; value: Master group name
    public static void queryMetadataForMasterGroup(){
        
        try{
            
            for(Core_MDF_ObjRecType_Budget_FieldSetMap__mdt record: [select Core_MDF_Channel_Program_txt__c,Core_MDF_Internal_Master_Group_Name_Txt__c,Core_MDF_External_Master_Group_Name_Txt__c 
                                                                   from Core_MDF_ObjRecType_Budget_FieldSetMap__mdt LIMIT 1000]){ //TWC3117-18333
                                                                       string key = record.Core_MDF_Channel_Program_txt__c;
                                                                       key+= 'Internal';
                                                                       channelProgramAcessToMasterGroupName.put(key,record.Core_MDF_Internal_Master_Group_Name_Txt__c);
                                                                       
                                                                       key = record.Core_MDF_Channel_Program_txt__c;
                                                                       key+= 'External';
                                                                       channelProgramAcessToMasterGroupName.put(key,record.Core_MDF_External_Master_Group_Name_Txt__c);    
                                                                       
                                                                       groupNames.add(record.Core_MDF_Internal_Master_Group_Name_Txt__c);
                                                                       groupNames.add(record.Core_MDF_External_Master_Group_Name_Txt__c);                                              
                                                                   }
        }
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    //Method queries the Group table for all the sub/master groupnames
    public static Map<string,ID> queryForGroupIds(List<string> groupNames){
        Map<string,ID> groupNameToGroupIdMap = new Map<string,ID>();  
        
        try{
            for(Group record: [select DeveloperName,id from group where DeveloperName in : groupNames]){
                groupNameToGroupIdMap.put(record.DeveloperName,record.id);
            }
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return groupNameToGroupIdMap;
    }
    
    //Commented out due to lock issue (ONLY FOR INTERNAL)
    //Method to check if Internal subgroup already part of Master group (ONLY FOR INTERNAL)
    /*
public static Map<id,id> checkIfSubGroupAlreadyMappedToMaster(Map<string,List<string>> channelProgramInternalToSubGroupNameList){
Map<id,id> subGroupToMasterGroupIDMap = new Map<id,id>();
Map<id,id> subGroupToMasterGroupIDFromGMMap = new Map<id,id>();
set<id> subgroupIds = new set<id>();
Map<id,id> internalRecordsToBeInserted = new Map<id,id>();
try{
//Find the Master groups to which the Sub groups need to be added
for(string channelProgramInternal : channelProgramInternalToSubGroupNameList.keyset()){       
List<string> subGroupNameList = channelProgramInternalToSubGroupNameList.get(channelProgramInternal);
id masterGroupId =groupNameToGroupId.get(channelProgramAcessToMasterGroupName.get(channelProgramInternal));

for(string subGroupName: subGroupNameList){
id subGroupId = groupNameToGroupId.get(subGroupName);
subGroupToMasterGroupIDMap.put(subGroupId,masterGroupId);
subgroupIds.add(subGroupId);
}    
}


//Introduce Delay
Long startingTime = System.now().getTime();
Integer delayInMilliseconds = 10000; // 10-second delay
while (System.now().getTime() - startingTime < delayInMilliseconds)  {
// Do nothing until desired delay has passed
}

//Query the GM for the Sub groups to check if they are part of any other Master Groups
List<groupmember> gm = [select id,UserOrGroupId,GroupId 
from groupmember 
where userorgroupid in :subgroupIds 
and group.developername in :channelProgramAcessToMasterGroupName.values()
];

//Create a map of the Sub Group and Master Group
for(groupmember record:gm){
subGroupToMasterGroupIDFromGMMap.put(record.userorgroupid,record.GroupId);
}

//Check if the Sub groups are part of the right Master Group
for(id subgroupid: subGroupToMasterGroupIDMap.keyset()){
id masterGroupFromGM = subGroupToMasterGroupIDFromGMMap.get(subgroupid);
if(masterGroupFromGM != subGroupToMasterGroupIDMap.get(subgroupid)){
internalRecordsToBeInserted.put(subgroupid,subGroupToMasterGroupIDMap.get(subgroupid));
}
}
}
catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
return internalRecordsToBeInserted;
}*/
    
    //Future method to insert the Groupmember records
    @future 
    public static void updateGroupMember(Map<Id,Id> toBeUpdated, Set<Id> groupIdToRemove){
        
        List<GroupMember> toBeInserted = new List<GroupMember>();
        List<Id> checkIfAlreadyPartOfOtherGroup = new List<Id>();
        Set<Id> toBeRemoved = new Set<Id>();
        
        try{
            //Populate the Map containing key: Channel Program + Type of Access ; value : Master CCP group name 
            if(channelProgramAcessToMasterGroupName.size()==0){queryMetadataForMasterGroup();}
            for(id subGroupId : toBeUpdated.keyset()){
                GroupMember record = new GroupMember();
                
                record.UserOrGroupId = subGroupId;
                record.GroupId = toBeUpdated.get(subGroupId);
                
                toBeInserted.add(record);
                checkIfAlreadyPartOfOtherGroup.add(subGroupId);
            }
            
            //Query Groupmember to check if the Sub Group is part of any other Master Group
            //If Sub group is part of other Master groups, remove them from all the Master Groups 
            for(GroupMember record : [select id,UserOrGroupId,GroupId 
                                        from groupmember 
                                        where userorgroupid in :checkIfAlreadyPartOfOtherGroup 
                                        and group.developername in :channelProgramAcessToMasterGroupName.values()]){
                toBeRemoved.add(record.id);
            }

            if(!groupIdToRemove.isEmpty()){
                toBeRemoved.addAll(groupIdToRemove);
            }

            if(!toBeRemoved.isEmpty()){
                //Remove Sub group from All Master Groups
                Database.DeleteResult[] deleteList = Database.delete(new List<Id>(toBeRemoved),true); 
            }

            //Add Sub Group to the intended Master Group
            //US930209 - Added extra condition to fix checkmarx related issues
            if(Schema.sObjectType.GroupMember.isCreateable()){
                Database.SaveResult[] saveList = Database.insert(toBeInserted,true);
            } 
        }
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }

    public static void addUsersToPGMAccountGroupForExternal(Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmMap){
        Map<Id,Id> accountIdToGroupIdToAddUsersMap = new Map<Id,Id>();
        Map<Id, List<String>> activePgmAccountIdToPrgmsMap = new Map<Id,List<String>>();
        Set<String> prgmNameToFetchSet = new Set<String>();
        List<Core_MDF_UserGroupMapping_Log__c> userGroupMappingList = new List<Core_MDF_UserGroupMapping_Log__c>();

        for(Core_MDF_Partner_Group_Mapping__c record: [SELECT Id, Core_MDF_Virtual_Corp_nm__c,Core_MDF_Group_Id__c, Core_MDF_Group_Name__c, Core_MDF_Inactive_Ind__c, Core_MDF_Type_of_Access__c, Core_MDF_Channel_Program_Name_Txt__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketingActive__c, Core_MDF_Channel_Program__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c 
                                                        FROM Core_MDF_Partner_Group_Mapping__c WHERE Id IN: pgmMap.keySet() AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: ipaTechnicalProgramName AND
                                                        Core_MDF_Account__r.Core_MDF_CoMarketingActive__c = false AND Core_MDF_Inactive_Ind__c = false AND 
                                                        Core_MDF_Type_of_Access__c =: externalType]){
            userGroupMappingList.add(new Core_MDF_UserGroupMapping_Log__c(Core_MDF_Error_Message_txt__c = record.Id, Core_MDF_Group_id__c = record.Core_MDF_Group_Id__c, Core_MDF_Account_id__c = record.Core_MDF_Account__c, Core_MDF_Channel_Program_id__c = record.Core_MDF_Channel_Program__c, Core_MDF_Action_nm__c= 'PGM User Addition', Core_MDF_Status_nm__c = 'In Progress'));
            userGroupMappingList.add(new Core_MDF_UserGroupMapping_Log__c(Core_MDF_Error_Message_txt__c = record.Id, Core_MDF_Virtual_Account_id__c = record.Core_MDF_Virtual_Corp_nm__c, Core_MDF_Account_id__c = record.Core_MDF_Account__c, Core_MDF_Channel_Program_id__c = record.Core_MDF_Channel_Program__c, Core_MDF_Action_nm__c= 'PNUM Addition', Core_MDF_Status_nm__c = 'In Progress'));                                                
        }

        //Create User Group mapping log record to add users to PGM Account Group(By using Batch)
        if(!userGroupMappingList.isEmpty()){
            Database.insert(userGroupMappingList, false);
        }
    }
    
    //Method queries the PGM Groups to be removed
    public static void isInactiveIndicatorUpdated(Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmMap, Map<Id,Core_MDF_Partner_Group_Mapping__c> pgmToBeProcessedMap){
        List<ID> groupsToBeRemoved = new List<ID>();
        Map<String,Id> grpIdToAccForUsrRemoval = new Map<String,Id>();
        Map<String,Id> grpIdToAccForUsrAddition = new Map<String,Id>();

        Set<Id> groupMemberIdToRemove = new Set<Id>();
        Map<Id,Set<Id>> groupIdToAccountIdsToRemoveUsersMap = new Map<Id,Set<Id>>();
        Map<Id,Id> accountIdToGroupIdToAddUsersMap = new Map<Id,Id>();
        Set<Id> accountIdRemoveUserSet = new Set<Id>();
        //Set<Id> accountIdAddUserSet = new Set<Id>();

        Map<Id, List<String>> activePgmAccountIdToPrgmsMap = new Map<Id,List<String>>();
        Map<Id, List<String>> inactivePgmAccountIdToPrgmsMap = new Map<Id,List<String>>();
        Set<String> prgmNameToFetchSet = new Set<String>();
        List<Core_MDF_UserGroupMapping_Log__c> userGroupMappingList = new List<Core_MDF_UserGroupMapping_Log__c>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> groupIdSet = new Set<Id>();
        Map<String, Core_MDF_UserGroupMapping_Log__c> keyAndUGM = new Map<String, Core_MDF_UserGroupMapping_Log__c>();

        List<Core_MDF_Partner_Group_Mapping__c> groupsToBeAdded = new List<Core_MDF_Partner_Group_Mapping__c>();
        try{
            for(Core_MDF_Partner_Group_Mapping__c record: [SELECT Id,Core_MDF_Virtual_Corp_nm__c, Core_MDF_Group_Id__c, Core_MDF_Group_Name__c, Core_MDF_Inactive_Ind__c, Core_MDF_Type_of_Access__c, Core_MDF_Channel_Program_Name_Txt__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketingActive__c, Core_MDF_Channel_Program__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Source_Txt__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Id IN: pgmMap.keySet() AND Core_MDF_Type_of_Access__c =: externalType ORDER BY Core_MDF_Type_of_Access__c desc]){
                if(record.Core_MDF_Inactive_Ind__c){
                    if(record.Core_MDF_Account__r.Core_MDF_CoMarketingActive__c){
                        groupsToBeRemoved.add(record.Core_MDF_Group_Id__c);
                    }else if(record.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c == ipaTechnicalProgramName){
                        Core_MDF_UserGroupMapping_Log__c userGroupMappingRecord = new Core_MDF_UserGroupMapping_Log__c(Core_MDF_Error_Message_txt__c = record.Id, Core_MDF_Group_id__c = record.Core_MDF_Group_Id__c, Core_MDF_Account_id__c = record.Core_MDF_Account__c, Core_MDF_Channel_Program_id__c = record.Core_MDF_Channel_Program__c, Core_MDF_Action_nm__c= 'PGM User Removal', Core_MDF_Status_nm__c = 'In Progress');
                        userGroupMappingList.add(userGroupMappingRecord);
		
                        accountIdSet.add(record.Core_MDF_Account__c);
                        programIdSet.add(record.Core_MDF_Channel_Program__c);
                        groupIdSet.add(record.Core_MDF_Group_Id__c);
                        String key = '' + record.Core_MDF_Account__c + record.Core_MDF_Channel_Program__c + record.Core_MDF_Group_Id__c;
                        keyAndUGM.put(key, userGroupMappingRecord);
                        
                        accountIdRemoveUserSet.add(record.Core_MDF_Account__c);
                        
                        if(inactivePgmAccountIdToPrgmsMap.containsKey(record.Core_MDF_Account__c)){
                            inactivePgmAccountIdToPrgmsMap.get(record.Core_MDF_Account__c).add(record.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                        }else{
                            inactivePgmAccountIdToPrgmsMap.put(record.Core_MDF_Account__c, new List<String>{record.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c});
                        }
                    }
                }else{
                    if(record.Core_MDF_Account__r.Core_MDF_CoMarketingActive__c){
                        pgmToBeProcessedMap.put(record.Id, record);
                    }else if(record.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c == ipaTechnicalProgramName){
                        Core_MDF_UserGroupMapping_Log__c userGroupMappingRecord = new Core_MDF_UserGroupMapping_Log__c(Core_MDF_Error_Message_txt__c = record.Id, Core_MDF_Group_id__c = record.Core_MDF_Group_Id__c, Core_MDF_Account_id__c = record.Core_MDF_Account__c, Core_MDF_Channel_Program_id__c = record.Core_MDF_Channel_Program__c, Core_MDF_Action_nm__c= 'PGM User Addition', Core_MDF_Status_nm__c = 'In Progress');
                        userGroupMappingList.add(userGroupMappingRecord);						
                        accountIdSet.add(record.Core_MDF_Account__c);
                        programIdSet.add(record.Core_MDF_Channel_Program__c);
                        groupIdSet.add(record.Core_MDF_Group_Id__c);
                        String key = '' + record.Core_MDF_Account__c + record.Core_MDF_Channel_Program__c + record.Core_MDF_Group_Id__c;
                        keyAndUGM.put(key, userGroupMappingRecord);
                        Core_MDF_UserGroupMapping_Log__c ugmRecordForPNUMUpdation = new Core_MDF_UserGroupMapping_Log__c(Core_MDF_Error_Message_txt__c = record.Id, Core_MDF_Virtual_Account_id__c = record.Core_MDF_Virtual_Corp_nm__c, Core_MDF_Account_id__c = record.Core_MDF_Account__c, Core_MDF_Channel_Program_id__c = record.Core_MDF_Channel_Program__c, Core_MDF_Action_nm__c= 'PNUM Addition', Core_MDF_Status_nm__c = 'In Progress');
                        userGroupMappingList.add(ugmRecordForPNUMUpdation);
                        String key1 = '' + record.Core_MDF_Account__c + record.Core_MDF_Channel_Program__c + record.Core_MDF_Virtual_Corp_nm__c;
                        keyAndUGM.put(key1, ugmRecordForPNUMUpdation);
                    }
                }                
            }
			if(inactivePgmAccountIdToPrgmsMap != null && !inactivePgmAccountIdToPrgmsMap.isEmpty()){

                //To get User details
                Map<Id,Id> userIdToAccountIdMap = new Map<Id,Id>();
                if(!accountIdRemoveUserSet.isEmpty()){
                    userIdToAccountIdMap = getUserDetails(accountIdRemoveUserSet, inactivePgmAccountIdToPrgmsMap);
                }

                //Inactivate PNUM records
                inactivatePnumRecords(userIdToAccountIdMap, inactivePgmAccountIdToPrgmsMap);

            }

            List<Core_MDF_UserGroupMapping_Log__c> userGroupMappingListToUpdate = new List<Core_MDF_UserGroupMapping_Log__c>();
            for(Core_MDF_UserGroupMapping_Log__c record : [SELECT Id, Core_MDF_Action_nm__c, Core_MDF_Status_nm__c, Core_MDF_Account_id__c, Core_MDF_Group_id__c, Core_MDF_Channel_Program_id__c, Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c 
                                                            FROM Core_MDF_UserGroupMapping_Log__c 
                                                            WHERE Core_MDF_Action_nm__c IN ('PGM User Addition', 'PGM User Removal') AND Core_MDF_Status_nm__c = 'In Progress' AND 
                                                            Core_MDF_Account_id__c IN: accountIdSet AND Core_MDF_Channel_Program_id__c IN: programIdSet AND Core_MDF_Group_id__c IN: groupIdSet]){
                String key = '' + record.Core_MDF_Account_id__c + record.Core_MDF_Channel_Program_id__c + record.Core_MDF_Group_id__c;
                if(keyAndUGM.containsKey(key)){
                    userGroupMappingListToUpdate.add(new Core_MDF_UserGroupMapping_Log__c(Id = record.Id, Core_MDF_Action_nm__c = keyAndUGM.get(key).Core_MDF_Action_nm__c));
                    keyAndUGM.remove(key);
                }
            }
            //Create User Group mapping log record to add and remove users from PGM Account Group(By using Batch)
            if(keyAndUGM != null && !keyAndUGM.isEmpty()){
                Database.insert(keyAndUGM.values(), false);
            }

            //Update User Group mapping log record to add and remove users from PGM Account Group(By using Batch)
            if(!userGroupMappingListToUpdate.isEmpty()){
                Database.update(userGroupMappingListToUpdate, false);
            }
            
            if(groupsToBeRemoved.size() >0){
                groupMemberIdToRemove.addAll(removeGroupFromGroupMember(groupsToBeRemoved));
            }
            if((pgmToBeProcessedMap != null && !pgmToBeProcessedMap.isEmpty()) || !groupMemberIdToRemove.isEmpty()){
                identifyMasterGroup(pgmToBeProcessedMap.values(), groupMemberIdToRemove);
            }

            
            
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}        
    }

    /*****************************************************************************************************                              
    Method Name   :        getUserDetails                                
    @return       :        void                          
    @parameters   :        Set<Id>
    Description   :        To get user deatils based on Account Ids
    Added By      :        JB - Accenture - 02/24/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/24/2023      To get user deatils based on Account Ids
    ******************************************************************************************************/
    public static Map<Id,Id> getUserDetails(Set<Id> accountIdSet, Map<Id, List<String>> inactivePgmAccountIdToPrgmsMap){

        Map<String, String> permissionSetToPrgmNameMapping = new Map<String, String>();
        Map<String, String> prgmNameToPermissionSetMapping = new Map<String, String>();
        for(String  prgmAndPS: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Program_PermissionSetMapping').split(';')){
            List<String> prgmandPSList = prgmAndPS.split(':');
            if(String.isNotBlank(prgmAndPS) && prgmandPSList.size() == 2){
                permissionSetToPrgmNameMapping.put(prgmandPSList[1], prgmandPSList[0]);
                //prgmNameToPermissionSetMapping.put(prgmandPSList[0], prgmandPSList[1]);
                prgmNameToPermissionSetMapping.put(prgmandPSList[0], prgmandPSList[1].replace(',', ';'));  //Roshan - added for PNUM inactivation defect fix TWC3117-13707
            }
        }
		Set<String> prgms = new Set<String>();
        for(List<String> programNameList : inactivePgmAccountIdToPrgmsMap.values()){
            prgms.addAll(programNameList);
        }
		
        Set<String> psName = new Set<String>();
        for(String programName : prgms){
            if(prgmNameToPermissionSetMapping.containsKey(programName)){
                psName.add(prgmNameToPermissionSetMapping.get(programName));
            }
        }
		Set<Id> contactIds = new Set<Id>();
        for(Core_Contact_Entitlement__c conEntitlement : [SELECT Core_Contact_Id__c,Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c FROM Core_Contact_Entitlement__c WHERE Core_Status__c = 'Complete' AND Core_Selected__c = true AND Core_Contact_Id__r.AccountId IN: accountIdSet AND Core_Entitlement_Id__r.Core_Permission_Set_API_Nm__c IN: psName ]){
            contactIds.add(conEntitlement.Core_Contact_Id__c);
        }

        Map<Id,Id> userIdToAccountIdMap = new Map<Id,Id>();
        for(User usr : [SELECT Id,AccountId FROM User WHERE ContactId IN: contactIds]){
            userIdToAccountIdMap.put(usr.Id, usr.AccountId);
        }
        return userIdToAccountIdMap;
    }

    /*****************************************************************************************************                              
    Method Name   :        inactivatePnumRecords                                
    @return       :        void                          
    @parameters   :        Map<Id,Id>
    Description   :        Used to inactivate PNUM records
    Added By      :        JB - Accenture - 02/24/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         02/24/2023      Used to inactivate PNUM records
    ******************************************************************************************************/
    public static void inactivatePnumRecords(Map<Id,Id> userIdToAccountIdMap, Map<Id,List<String>> inactivePgmAccountIdToPrgmsMap){
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumListToInactivate = new List<Core_MDF_Partner_Node_User_Mapping__c>();

        Map<Id,Core_MDF_Partner_Node_User_Mapping__c> pnumIdToPnumMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>([SELECT Id, Core_MDF_User__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,
                                                                                                                            Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.Name
                                                                                                                            FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                                                                                            WHERE Core_MDF_User__c IN: userIdToAccountIdMap.keySet() AND
                                                                                                                            Core_MDF_Active_Ind__c = true ORDER BY Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c]);
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : pnumIdToPnumMap.values()){
            if(String.isNotBlank(userIdToAccountIdMap.get(pnum.Core_MDF_User__c)) && 
                inactivePgmAccountIdToPrgmsMap.containsKey(userIdToAccountIdMap.get(pnum.Core_MDF_User__c)) && inactivePgmAccountIdToPrgmsMap.get(userIdToAccountIdMap.get(pnum.Core_MDF_User__c)).size() > 0 && 
                (inactivePgmAccountIdToPrgmsMap.get(userIdToAccountIdMap.get(pnum.Core_MDF_User__c)).contains(pnum.Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c))){

                    Core_MDF_Partner_Node_User_Mapping__c newPnum = new Core_MDF_Partner_Node_User_Mapping__c(Id = pnum.Id, Core_MDF_Active_Ind__c = false);

                    if(pnum.Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c == ipaTechnicalProgramName)
                        newPnum.Core_MDF_Action_Needed_nm__c = 'Owner Update';
                    
                    pnumListToInactivate.add(newPnum);
            }                                                    
        }
		if(!pnumListToInactivate.isEmpty()){
            
            List<Database.SaveResult> sResults = Database.update(pnumListToInactivate, false);

        }
    }
    
    //Method to delete Sub Group from all the Master Groups on delete of the PGM record
    public static Set<Id> removeGroupFromGroupMember(list<id> groupIdsToBeRemoved){
        
        Set<id> toBeRemoved = new Set<id>();
        
        try{
            //Populate the Map containing key: Channel Program + Type of Access ; value : Master CCP group name 
            if(channelProgramAcessToMasterGroupName.size()==0){queryMetadataForMasterGroup();}
            //Query GroupMember to identify which groups the Sub group is part of
            for(groupmember gm:[select id,UserOrGroupId,GroupId from groupmember where userorgroupid in :groupIdsToBeRemoved and group.developername in :channelProgramAcessToMasterGroupName.values()]){
                toBeRemoved.add(gm.id);
            }
            //Delete Sub Group from all the Master Groups on delete of the PGM record     
        }
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return toBeRemoved;
    } 
/****************************************************************************************************************************************
Method Name:                                             populateAccountProgramId
@return  :                                               --
@parameters:                                             List of PGM records, PGM oldMap
Description:                                             Method populates Account program on PGM record insert/update for External Type of Access
Added By:                                                Accenture – Nirmala K  -  13/09/2021
Modified By:                  Date:                      Changes: 
Accenture – Nirmala K       13/09/2021                   Created.
*****************************************************************************************************************************************/ 

    public static void populateAccountProgramId(List<Core_MDF_Partner_Group_Mapping__c> newPGMList, Map<id,Core_MDF_Partner_Group_Mapping__c> oldPGMList){
        try{
            
            //to update AccountProgramid in PGM for external type of access
            for(Core_MDF_Partner_Group_Mapping__c pgmRecord : newPGMList){
                if((pgmRecord.Core_MDF_Type_of_Access__c == externalType)){
                    //Concatenate AccountId,Program id and populate AccountProgramid field if PGM is created or accountid/program id updated or type of access is upated from internal to External
                    if((oldPGMList==null)||((oldPGMList.get(pgmRecord.id) != NULL) && ((pgmRecord.Core_MDF_Type_of_Access__c != oldPGMList.get(pgmRecord.id).Core_MDF_Type_of_Access__c) || (pgmRecord.Core_MDF_Account__c != oldPGMList.get(pgmRecord.id).Core_MDF_Account__c)  || (pgmRecord.Core_MDF_Channel_Program__c != oldPGMList.get(pgmRecord.id).Core_MDF_Channel_Program__c)))){
                        pgmRecord.Core_MDF_AccountProgramId_Txt__c = pgmRecord.Core_MDF_Account__c + '_' + pgmRecord.Core_MDF_Channel_Program__c;                        
                    }
                    if(oldPGMList==null || (oldPGMList.get(pgmRecord.id) != NULL && pgmRecord.Core_MDF_Inactive_Ind__c != oldPGMList.get(pgmRecord.id).Core_MDF_Inactive_Ind__c)){
                        pgmRecord.Core_MDF_AccProgInactiveInd_Txt__c = pgmRecord.Core_MDF_Account__c + '_' + pgmRecord.Core_MDF_Channel_Program__c + '_' + pgmRecord.Core_MDF_Inactive_Ind__c;
                    }
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    public static void restrictDeletion(Map<Id,Core_MDF_Partner_Group_Mapping__c> oldMap){ 
        for(Core_MDF_Partner_Group_Mapping__c pgmObj: oldMap.values() ){           
            pgmObj.addError('Record is not allowed to delete. Please deactivate the record.');
        }
    }
/****************************************************************************************************** 
Method Name:        queryForVCIds
@return  :          N/A
@parameters:        list of PGM groupIds
Description:        This method is used to get the Virtual corps of the respective Comarketing account
Added By:           Accenture - AN - 02/02/2024
Modified By:        Date:       Changes: 

******************************************************************************************************/ 
    public static Map<String,Id> queryForVCIds(List<String> pgmGroupNames){
        Map<String,Id> pgmGroupNmToVCIdMap = new Map<String,Id>();  
        
        try{
            //Program check using custom label and inactive indicator check
            for(Core_MDF_Partner_Group_Mapping__c record: [select id,Core_MDF_Group_Name__c,Core_MDF_Virtual_Corp_Nm__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Group_Name__c in : pgmGroupNames and Core_MDF_Virtual_Corp_Nm__c != null and Core_MDF_CoMarketingActive_Ind__c = true and Core_MDF_Type_of_Access__c = 'External' and Core_MDF_Inactive_Ind__c = false]){
                pgmGroupNmToVCIdMap.put(record.Core_MDF_Group_Name__c,record.Core_MDF_Virtual_Corp_Nm__c);
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return pgmGroupNmToVCIdMap;

    }
/****************************************************************************************************** 
Method Name:        queryForVCIdsfromUltimateAcc
@return  :          N/A
@parameters:        list of PGM groupIds
Description:        This method is used to get the Virtual corps of the respective Comarketing account
Added By:           Accenture - AN - 02/02/2024
Modified By:        Date:       Changes: 

******************************************************************************************************/ 
    public static Map<Id,Id> queryForVCIdsfromUltimateAcc(Map<Id,Id> ultimateAccIds){
        Map<Id,Id> ultimateAccToVCMap = new Map<Id,Id>();  
        
        try{
            //Program check using custom label and inactive indicator check
            for(Account record: [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Core_MDF_Parent_Fund_Account__c in : ultimateAccIds.keyset() and Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketingActive__c = true]){
                if(ultimateAccIds.get(record.Core_MDF_Parent_Fund_Account__c) == record.Core_MDF_Channel_Program__c){
                    ultimateAccToVCMap.put(record.Core_MDF_Parent_Fund_Account__c,record.id);
                }
            }
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return ultimateAccToVCMap;

    }
}