/*******************************************************************************************************************************************************************
* Class Name  : Core_MDF_PGM_ServiceHandler 
* Version     : 1.0 
* Created Date: 01-10-2019
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       01-10-2019         Service Class for handling trigger related functions on Partner Group Mapping object.
* Intel - NP(11630236) 09-10-2019         Introduced logic to add the CCP subgroup to the corresponding CCP Master group
* Intel - NP(11630236) 15-10-2019         Introduced PB logic of updating Group ID on Before Insert/Update
* Intel - NP(11630236) 28-11-2019         DE61641 fix: IUPGM Groups are not getting added to Master groups when we select more than Geo while creating IUPGM record
* Intel - NP(11630236) 06-12-2019         DE62015 fix: IUPGM | Users are not getting added to APJ and WW IUPGM group when we create an IUPGM for all 5 Geos
**********************************************************************************************************************************************************************/
public with sharing class Core_MDF_PGM_ServiceHandler {

    public static Map<string,string> channelProgramAcessToMasterGroupName = new Map<string,string>();
    public static List<string> groupNames = new List<string>();
    public static Map<string,ID> groupNameToGroupId = new Map<string,ID>();
    

    //Method populates AccountIdGroupName and GroupId on PGM record insert/update
    public static void populateAccountIdGroupNameAndGroupId(List<Core_MDF_Partner_Group_Mapping__c> newPGMList, Map<id,Core_MDF_Partner_Group_Mapping__c> oldPGMList){
        
        List<string> subGroupNames = new List<string>();
        Map<string,ID> groupNametoGroupIdMap = new Map<string,ID>();

        try{
            for(Core_MDF_Partner_Group_Mapping__c pgmRecord : newPGMList){
                    pgmRecord.Core_MDF_AccountIdGroupName__c = pgmRecord.Core_MDF_Account__c + '_' + pgmRecord.Core_MDF_Group_Name__c;
                    
                    //Add to list if Group ID is null or if the Group Name has been changed
                    if(pgmRecord.Core_MDF_Group_Id__c == null || pgmRecord.Core_MDF_Group_Name__c != oldPGMList.get(pgmRecord.id).Core_MDF_Group_Name__c){
                        subGroupNames.add(pgmRecord.Core_MDF_Group_Name__c);
                    }
            }
            if(subGroupNames.size()>0){
                //Query the Group object for the Group Ids
                groupNametoGroupIdMap = queryForGroupIds(subGroupNames);
                
                for(Core_MDF_Partner_Group_Mapping__c record : newPGMList){
                    if(record.Core_MDF_Group_Id__c == null || record.Core_MDF_Group_Name__c != oldPGMList.get(record.id).Core_MDF_Group_Name__c){
                        //Update the Group id to the corresponding Group name in PGM record
                        record.Core_MDF_Group_Id__c = groupNametoGroupIdMap.get(record.Core_MDF_Group_Name__c);
                        system.debug('record.Core_MDF_Group_Id__c' + record.Core_MDF_Group_Id__c);
                    }
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }

    //Method checks if Channel Program, Type of Access or Group Name is changed on PGM record update
    public static void checkIfValidUpdate(List<Core_MDF_Partner_Group_Mapping__c> newPGMList, Map<id,Core_MDF_Partner_Group_Mapping__c> oldPGMList){
        List<Core_MDF_Partner_Group_Mapping__c> toBeProcessed = new List<Core_MDF_Partner_Group_Mapping__c>();
        List<id> toBeRemoved = new List<id>();

        try{
            for(Core_MDF_Partner_Group_Mapping__c record: newPGMList){
                if(record.Core_MDF_Channel_Program__c != oldPGMList.get(record.id).Core_MDF_Channel_Program__c 
                    || record.Core_MDF_Type_of_Access__c != oldPGMList.get(record.id).Core_MDF_Type_of_Access__c
                    || record.Core_MDF_Group_Name__c != oldPGMList.get(record.id).Core_MDF_Group_Name__c){  
                        toBeProcessed.add(record); 
                }
            }
            if(toBeProcessed.size()>0){
                system.debug('To be Processed');
                //Send identified PGM records for processing
                Core_MDF_PGM_ServiceHandler.identifyMasterGroup(toBeProcessed);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
    }

    // Method helps in identifying the Master CCP group for the sub CCP group based on Channel Program, Type of Access
    public static void identifyMasterGroup(List<Core_MDF_Partner_Group_Mapping__c> pgmList){

        Map<string,List<string>> channelProgramAccessToSubGroupNameExternalList = new Map<string,List<string>>();
        Map<string,List<string>> channelProgramAccessToSubGroupNameInternalList = new Map<string,List<string>>();
        Map<id,id> toBeInserted = new Map<id,id>();          

        try{
            //1. Populate the Map containing key: Channel Program + Type of Access ; value : Master CCP group name
            if(channelProgramAcessToMasterGroupName.size()==0){queryMetadataForMasterGroup();}

            //2. Create a Map with key : Channel Program + Type of Access ; value : Sub CCP group Name
            for(Core_MDF_Partner_Group_Mapping__c pgmRecord: pgmList){
                system.debug('pgmRecord.Core_MDF_Type_of_Access__c' + pgmRecord.Core_MDF_Type_of_Access__c);
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

            system.debug('channelProgramAccessToSubGroupNameExternalList' + channelProgramAccessToSubGroupNameExternalList);
            system.debug('channelProgramAccessToSubGroupNameInternalList' + channelProgramAccessToSubGroupNameInternalList);

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
            system.debug('toBeInserted' + toBeInserted);

            //Commented out due to lock issue (ONLY FOR INTERNAL)
            //5. Check if the internal groups are already part of the Master group, else add them to the toBeInserted list
            /*if(channelProgramAccessToSubGroupNameInternalList.size()>0){
                Map<id,id> internalRecordsToBeInserted = checkIfSubGroupAlreadyMappedToMaster(channelProgramAccessToSubGroupNameInternalList);
                system.debug(internalRecordsToBeInserted);
                toBeInserted.putall(internalRecordsToBeInserted);
            }*/
            
            //6. Insert the Groupmember records
            if(toBeInserted.size()>0){
                updateGroupMember(toBeInserted);
            }
        }

        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }

    //Method queries the custom metadata for all the CCP Master group names and creates a map with key: Channel Program + Type of Access ; value: Master group name
    public static void queryMetadataForMasterGroup(){

        try{

            for(Core_MDF_ClaimActAllocRecTypeMapping__mdt record: [select Core_MDF_Channel_Program_txt__c,Core_MDF_Internal_Master_Group_Name_Txt__c,Core_MDF_External_Master_Group_Name_Txt__c 
                                                                   from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){ 
                string key = record.Core_MDF_Channel_Program_txt__c;
                key+= 'Internal';
                channelProgramAcessToMasterGroupName.put(key,record.Core_MDF_Internal_Master_Group_Name_Txt__c);

                key = record.Core_MDF_Channel_Program_txt__c;
                key+= 'External';
                channelProgramAcessToMasterGroupName.put(key,record.Core_MDF_External_Master_Group_Name_Txt__c);    

                groupNames.add(record.Core_MDF_Internal_Master_Group_Name_Txt__c);
                groupNames.add(record.Core_MDF_External_Master_Group_Name_Txt__c);                                              
                }
                system.debug('channelProgramAcessToMasterGroupName' + channelProgramAcessToMasterGroupName);
                system.debug('groupNames' + groupNames);
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

            system.debug('groupNameToGroupIdMap'+groupNameToGroupIdMap);
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
            //system.debug('delay');
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
            system.debug('internalRecordsToBeInserted' + internalRecordsToBeInserted);
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return internalRecordsToBeInserted;
    }*/

    //Future method to insert the Groupmember records
    @future 
    public static void updateGroupMember(Map<id,id> toBeUpdated){

        List<GroupMember> toBeInserted = new List<GroupMember>();
        List<id> checkIfAlreadyPartOfOtherGroup = new List<id>();
        List<id> toBeRemoved = new List<id>();

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
            List<groupmember> gm = [select id,UserOrGroupId,GroupId 
                                    from groupmember 
                                    where userorgroupid in :checkIfAlreadyPartOfOtherGroup 
                                    and group.developername in :channelProgramAcessToMasterGroupName.values()
                                   	];
            
            //If Sub group is part of other Master groups, remove them from all the Master Groups 
            if(gm.size()>0){
                for(GroupMember record:gm){
                    toBeRemoved.add(record.id);
                }
                //Remove Sub group from All Master Groups
                Database.DeleteResult[] deleteList = Database.delete(toBeRemoved,true); 
                system.debug('deleteList' + deleteList);
            }
            //Add Sub Group to the intended Master Group
            system.debug('toBeInserted' + toBeInserted);
            Database.SaveResult[] saveList = Database.insert(toBeInserted,true);
            system.debug('saveList' +saveList);    
        }

        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }

    //Future method to delete Sub Group from all the Master Groups on delete of the PGM record
    @future
    public static void removeGroupFromGroupMember(list<id> groupIdsToBeRemoved){

        List<id> toBeRemoved = new List<id>();

        try{
             //Populate the Map containing key: Channel Program + Type of Access ; value : Master CCP group name 
            if(channelProgramAcessToMasterGroupName.size()==0){queryMetadataForMasterGroup();}
            //Query GroupMember to identify which groups the Sub group is part of
            for(groupmember gm:[select id,UserOrGroupId,GroupId from groupmember where userorgroupid in :groupIdsToBeRemoved and group.developername in :channelProgramAcessToMasterGroupName.values()]){
                toBeRemoved.add(gm.id);
            }
            system.debug('groupIdsToBeRemoved' + toBeRemoved);
            //Delete Sub Group from all the Master Groups on delete of the PGM record
            Database.DeleteResult[] deleteList = Database.delete(toBeRemoved,true); 
            system.debug('deleteList' + deleteList);      
        }
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}

    }
}