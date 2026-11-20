//global class Core_MDF_ProcessEntitlements implements Database.Batchable<sObject>, Database.Stateful {
//US949837 - Added without sharing keyword to fix checkmarx issue
global without sharing class Core_MDF_ProcessEntitlements implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    public set<string> userOrGroupIdSet = new set<string>();
    public Map<String,Core_Trigger_Executions__c> customSettingsMap = Core_Trigger_Executions__c.getAll();
    public List<Core_MDF_UserGroupMapping_Log__c> logObjectList = new List<Core_MDF_UserGroupMapping_Log__c>();
    public List<id> gmIdsToBeDeleted = new List<Id>();
    public Map<id,boolean> marketingUserId = new Map<id,boolean>();
    public List<Core_MDF_UserGroupMapping_Log__c> existingLogRecTobeUpdated = new List<Core_MDF_UserGroupMapping_Log__c>();
    public List<Core_MDF_Partner_Group_Mapping__c> toBeAddedPGM = new List<Core_MDF_Partner_Group_Mapping__c>();
    public List<Core_MDF_Partner_Group_Mapping__c> toBeUpdatedPGM = new List<Core_MDF_Partner_Group_Mapping__c>();                    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        Datetime rangeToBeSelected;
        Core_MDF_Configuration__c configClassName = Core_MDF_Configuration__c.getValues('Core_MDF_ProcessEntitlements_Class');         
        String processEntitlementsClass = String.valueOf(configClassName.Core_MDF_Value__c);
        List<AsyncApexJob> processEntitlementsJob = new List<AsyncApexJob>();
        Set<Id> reprocessContacts = new Set<Id>();
        if(!Test.isRunningTest()){
            processEntitlementsJob = [select id,CompletedDate,CreatedDate,JobType from AsyncApexJob where ApexClass.name =:processEntitlementsClass and Status ='Completed' and jobtype = 'BatchApex' order by CompletedDate desc limit 1];
        }
        if(processEntitlementsJob!= Null && processEntitlementsJob.size()>0){
            rangeToBeSelected = processEntitlementsJob[0].CreatedDate;
        }else{
            rangeToBeSelected = System.now().addHours(integer.valueOf(Label.Core_MDF_Entitlements_Group_TimeFrame));
        }
        
        //get the last 50 contacts from logobject where action = user inactive(store in list) for reprocessing
        for(Core_MDF_UserGroupMapping_Log__c uGMLog : [Select Id, Core_MDF_Contact_id__c,Core_MDF_Status_nm__c from Core_MDF_UserGroupMapping_Log__c where Core_MDF_Action_nm__c = 'Inactive User' and Core_MDF_Status_nm__c = 'Action Required' order by createdDate desc LIMIT 50]){
            reprocessContacts.add(uGMLog.Core_MDF_Contact_id__c);
            uGMLog.Core_MDF_Status_nm__c = 'Completed';
            existingLogRecTobeUpdated.add(uGMLog);
        }
        
        strQuery='select Core_Contact_Id__c,Core_Contact_Id__r.Email,Core_Entitlement_Nm__c,Core_Selected__c, Core_Status__c from Core_Contact_Entitlement__c ';
        strQuery +='where Core_Type__c = \'Entitlement\' and Core_Status__c=\'Complete\' and (LastModifiedDate >= :rangeToBeSelected OR Core_Contact_Id__c in :reprocessContacts) ' ;
        strQuery += 'and Core_Entitlement_Nm__c in (';
        for(string entitlements : Label.Core_MDF_User_Group_Mapping_Automation_Audience_List.split(';')){
            List<string> entitlementList = entitlements.split(':');
            strQuery += '\'' + entitlementList[0] + '\',';
        }
        for(string marketingUserEntitlements : Label.Core_MDF_Marketing_User_Entitlements.split(';')){
            strQuery += '\'' + marketingUserEntitlements + '\',';
        }
        strQuery = strQuery.removeend(',');
        strQuery += ')';
        
        return Database.getQueryLocator(strQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Core_Contact_Entitlement__c> newContactEntitlementList) {      
        Map<id,List<string>> newEntitlementAssigned = new Map<id,List<string>>();
        Map<id,List<string>> entitlementRemoved = new Map<id,List<string>>();
        Map<id,id> contactToUserMap = new Map<id,id>();
        Map<id,id> contactToAccountMap = new Map<id,id>();
        Map<id,string> contactToDomainMap = new Map<id,string>();
        Map<id,id> worksForToAccountMap = new Map<id,id>();        
        Map<string,id> accountChannelProgramToGroupIDMap = new Map<string,id>();
        Map<string,id> accountChannelProgramToAllAccessGroupIDMap = new Map<String,Id>();
        Map<string,id> accountProgGroupIdToPGMIdMap = new Map<string,id>();
        set<id> contactIds = new set<id>();
        Map<string,string> ccpEntitlementToCPMap = new Map<string,string>();        
        Map<string,id> channelProgramToCPIdMap = new Map<string,id>();        
        Map<id,List<id>> toBeInsertedLogs = new Map<id,List<id>>();
        Map<id,List<id>> toBeDeletedLogs = new Map<id,List<id>>();        
        Map<id,List<id>> addFalloutLogs = new Map<id,List<id>>();
        Map<id,List<id>> removeFalloutLogs = new Map<id,List<id>>();
        Map<id,List<id>> addFalloutLogsForInactiveUsr = new Map<id,List<id>>();        
        List<id> existingGroupIDs = new List<id>();
        ContactToAccUserWarpper conToAccUsrWrap = new ContactToAccUserWarpper();
        List<id> userCreationFailedContacts = new List<id>();
        PGMWrapper pgmWrap = new PGMWrapper();
        Map<string,id> accProgToVirtualCorpIdMap = new Map<string,id>();
        Map<id,id> userToVirtualCorpMap = new Map<id,id>();
        Map<id,id> groupIdToCPmap = new Map<id,id>();
        Map<id,List<id>> accToWorksforMap = new Map<id,List<id>>();
        Set<String> programIdSet = new Set<String>();
        Set<String> domainSet = new Set<String>();
        Map<String, String> pgdmMap = new Map<String, String>();
        try{         
            //Create Map of Entitlements to Channel Program Name - CCF USER => Client Co-Marketing Fund
            for(string entitlementToChannelProgram : Label.Core_MDF_User_Group_Mapping_Automation_Audience_List.split(';')){
                List<string> record = entitlementToChannelProgram.split(':');
                ccpEntitlementToCPMap.put(record[0].toUpperCase(),record[1]);
            }
            
            //Create Map of Channel Program Name to Channel Program ID - Client Co-Marketing Fund => id
            for(ChannelProgram cp : [select Name, id from ChannelProgram where name in: ccpEntitlementToCPMap.values()]){
                channelProgramToCPIdMap.put(cp.Name, cp.id);
            }
            
            if(newContactEntitlementList.size()>0){
                String requestString ='"Core_MDF_Contact_id__c","Core_MDF_Status_nm__c","Core_MDF_Action_nm__c"'+'\r\n';
                //1. Loop through the inputs and segregate Entitlement Addition and Removal
                for(Core_Contact_Entitlement__c ce: newContactEntitlementList){
                    requestString+='"'+ce.Core_Contact_Id__c + '","In Progress","PGM Initial Log"'+'\r\n';                    
                    contactIds.add(ce.Core_Contact_Id__c);                    
                    //If Entitlement is added
                    if(ce.Core_Selected__c == true){
                        if(newEntitlementAssigned.containsKey(ce.Core_Contact_Id__c)){
                            newEntitlementAssigned.get(ce.Core_Contact_Id__c).add((ce.Core_Entitlement_Nm__c).toUpperCase());
                        }
                        else{
                            newEntitlementAssigned.put(ce.Core_Contact_Id__c, new List<string>{ (ce.Core_Entitlement_Nm__c).toUpperCase() });
                        }
                        String email = ce.Core_Contact_Id__r.Email;
                        String domain = (email != null && email.contains('@')) ? email.split('@')[1]: NULL;
                        if(domain != NULL){
                            domainSet.add(domain);
                        }
                        string channelProgram = ccpEntitlementToCPMap.containsKey((ce.Core_Entitlement_Nm__c).toUpperCase()) && ccpEntitlementToCPMap.get((ce.Core_Entitlement_Nm__c).toUpperCase()) != 'Intel Partner Alliance'?channelProgramToCPIdMap.get(ccpEntitlementToCPMap.get((ce.Core_Entitlement_Nm__c).toUpperCase())) : null;
                        if(channelProgram != NULL){
                            programIdSet.add(channelProgram);
                        }
                    }                    
                    //If Entitlement is removed
                    else{
                        if(entitlementRemoved.containsKey(ce.Core_Contact_Id__c)){
                            entitlementRemoved.get(ce.Core_Contact_Id__c).add((ce.Core_Entitlement_Nm__c).toUpperCase());
                        }
                        else{
                            entitlementRemoved.put(ce.Core_Contact_Id__c, new List<string>{ (ce.Core_Entitlement_Nm__c).toUpperCase() });
                        }
                    }
                }
                if(!domainSet.isEmpty() && !programIdSet.isEmpty()){
                    pgdmMap = pgdmCheck(domainSet,programIdSet);
                }
                if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_UGM_Log_switch')=='true'){
                    bulkAPILog(requestString);
                }
                
                //2. Prepare all Maps to identify the Group to be added/removed
                if(newEntitlementAssigned.size()>0 || entitlementRemoved.size()>0){                    
                    //Preapre Contact -> User Map and Contact -> Account Map 
                    conToAccUsrWrap = getUserAndAccountForContact(contactIds);
                    //Prepare Contact -> User Map
                    //Prepare Contact -> Account Map
                    contactToUserMap = conToAccUsrWrap.contactToUserMap;
                    contactToAccountMap = conToAccUsrWrap.contactToAccountMap;
                    contactToDomainMap = conToAccUsrWrap.contactToDomainMap;
                    userCreationFailedContacts = conToAccUsrWrap.userCreationFailedContacts;
                    //Prepare AccountChannelProgram -> GroupID Map
                    pgmWrap = getAccountGroupsFromPGM(contactToAccountMap.values());
                    accountChannelProgramToGroupIDMap = pgmWrap.accountChannelProgramToGroupIDMap;
                    accountChannelProgramToAllAccessGroupIDMap = pgmWrap.accountChannelProgramToAllAccessGrpIDMap;
                    accProgToVirtualCorpIdMap = pgmWrap.accProgToVirtualCorpIdMap;
                    groupIdToCPmap = pgmWrap.groupIdToChannelProgramId;
                    accToWorksforMap = pgmWrap.accToWorksforMap;
                    accountProgGroupIdToPGMIdMap = pgmWrap.accountProgGroupIdToPGMIdMap;
                }
                
                //3. Query Existing Group Member records for the user
                Map<id, List<id>> existingGMmapping = queryGroupMemeberRecords(contactToUserMap.values());
                List<GroupMember> groupMemList = new List<GroupMember>();
                List<String> recoveryEntitlements = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_RecoveryAdminEntitlements');
                //4. Adding to user to Group
                if(newEntitlementAssigned.size()>0){
                    List<GroupMember> toBeAddedGM = new List<GroupMember>();                    
                    Map<id,List<id>> userToGroupList = new Map<id,List<id>>();
					Set<String> processedPGMKeys = new Set<String>();                    
                    for(id contactRecord: newEntitlementAssigned.keyset()){
                        for(string entitlementRecord: newEntitlementAssigned.get(contactRecord)){
                            string channelProgram = ccpEntitlementToCPMap.containsKey(entitlementRecord)?channelProgramToCPIdMap.get(ccpEntitlementToCPMap.get(entitlementRecord)) : null;
                            id groupID = channelProgram!=null? accountChannelProgramToGroupIDMap.get(contactToAccountMap.get(contactRecord) + channelProgram.trim()) : null;
                            id allAccessGroupId =  channelProgram != null? accountChannelProgramToAllAccessGroupIDMap.get(contactToAccountMap.get(contactRecord) + channelProgram.trim()) : null;
                            
                            //Check if Marketing User needs to be enabled
                            //if(entitlementRecord == Label.Core_MDF_Marketing_User_Entitlements.toUpperCase('en')){
                            if((Label.Core_MDF_Marketing_User_Entitlements.toUpperCase().split(';')).contains(entitlementRecord)){
                                marketingUserId.put(contactToUserMap.get(contactRecord), true);  
                            }                            
                            //Get existing group details for the user
                            existingGroupIDs = existingGMmapping.containsKey(contactToUserMap.get(contactRecord))? existingGMmapping.get(contactToUserMap.get(contactRecord)) : null;
                            //User creation failure scenario, need to log - NA
                            if(userCreationFailedContacts.contains(contactRecord)){
                                if(addFalloutLogsForInactiveUsr.containsKey(contactRecord)){
                                    addFalloutLogsForInactiveUsr.get(contactRecord).add(channelProgram);    
                                }else{
                                    addFalloutLogsForInactiveUsr.put(contactRecord,new List<id> {channelProgram});  
                                }
                                continue;                                
                            }
                            //If User is not part of the desired group already, create group member mappings                          
                            if(existingGroupIDs != null && !existingGroupIDs.contains(groupID) && ccpEntitlementToCPMap.containsKey(entitlementRecord) && !recoveryEntitlements.contains(entitlementRecord)){//restrict CCF DCF EEF Recovery adm entitlement                                
                                //Create Group Member Records for records having GroupID
                                if(contactToUserMap.get(contactRecord)!=null && groupID != null){
                                    GroupMember gm = new GroupMember();
                                    gm.UserOrGroupId = contactToUserMap.get(contactRecord);
                                    gm.GroupId = groupID;
                                    userOrGroupIdSet.add(contactToUserMap.get(contactRecord));
                                    toBeAddedGM.add(gm);                                     
                                    if(toBeInsertedLogs.containsKey(contactRecord)){
                                        toBeInsertedLogs.get(contactRecord).add(groupID);  
                                    }else{
                                        toBeInsertedLogs.put(contactRecord,new List<id> {groupID});  
                                    }
                                }else if(contactToUserMap.get(contactRecord)!=null && groupID == null && ccpEntitlementToCPMap.get(entitlementRecord) != 'Intel Partner Alliance'){
                                    String domain = contactToDomainMap.get(contactRecord);
                                    String key = domain + channelProgram;
                                    if(pgdmMap != NULL && pgdmMap.containsKey(key) && pgdmMap.get(key)!= NULL){
                                        List<String> grpValList = pgdmMap.get(key).split(':');
                                        String pgmGroupName = grpValList[0];
                                        String pgmGroupId = grpValList[1];
                                        String accProgGrpIdKey =  String.valueOf(contactToAccountMap.get(contactRecord)) + channelProgram + pgmGroupId;                                         
                                        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
                                        if(!processedPGMKeys.contains(accProgGrpIdKey)){
                                            processedPGMKeys.add(accProgGrpIdKey);
                                            if(accountProgGroupIdToPGMIdMap != NULL && accountProgGroupIdToPGMIdMap.size() > 0 && accountProgGroupIdToPGMIdMap.containsKey(accProgGrpIdKey)){
                                                pgm.Id = accountProgGroupIdToPGMIdMap.get(accProgGrpIdKey);
                                                pgm.Core_MDF_Inactive_Ind__c = False;
                                                pgm.Core_MDF_Source_Txt__c = 'ProcessEntitlement';
                                                toBeUpdatedPGM.add(pgm);
                                            }else{
                                                pgm.Core_MDF_Account__c = contactToAccountMap.get(contactRecord);
                                                pgm.Core_MDF_Group_Name__c = pgmGroupName;
                                                pgm.Core_MDF_Channel_Program__c = channelProgram;
                                                pgm.Core_MDF_Type_of_Access__c = 'External';
                                                pgm.Core_MDF_Source_Txt__c = 'ProcessEntitlement';                                            
                                                toBeAddedPGM.add(pgm);
                                            }
                                        }
                                        GroupMember gm = new GroupMember();
                                        gm.UserOrGroupId = contactToUserMap.get(contactRecord);
                                        gm.GroupId = pgmGroupId;
                                        userOrGroupIdSet.add(contactToUserMap.get(contactRecord));
                                        toBeAddedGM.add(gm); 
                                        if(toBeInsertedLogs.containsKey(contactRecord)){
                                            toBeInsertedLogs.get(contactRecord).add(pgmGroupId);  
                                        }else{
                                            toBeInsertedLogs.put(contactRecord,new List<id> {pgmGroupId});  
                                        }
                                    }else{
                                        if(addFalloutLogs.containsKey(contactRecord)){
                                            addFalloutLogs.get(contactRecord).add(channelProgram);    
                                        }else{
                                            addFalloutLogs.put(contactRecord,new List<id> {channelProgram});  
                                        }
                                    }
                                }								                                
                                //Create fallout logs for Users that have No Group IDs
                                else{
                                    if(addFalloutLogs.containsKey(contactRecord)){
                                        addFalloutLogs.get(contactRecord).add(channelProgram);    
                                    }else{
                                        addFalloutLogs.put(contactRecord,new List<id> {channelProgram});  
                                    }
                                }                                
                            }
                            //To add CCF/DCF recovery admins to ALL ACCESS program specific groups                            
                            else if(existingGroupIDs != null && !existingGroupIDs.contains(allAccessGroupId) && recoveryEntitlements.contains(entitlementRecord)){
                                if(contactToUserMap.get(contactRecord)!=null && allAccessGroupId != null){
                                    GroupMember recoveryGrpMem = new GroupMember();
                                    recoveryGrpMem.groupId = allAccessGroupId;//account specific All Access Group
                                    recoveryGrpMem.userOrGroupId = contactToUserMap.get(contactRecord);
                                    toBeAddedGM.add(recoveryGrpMem); 
                                    if(toBeInsertedLogs.containsKey(contactRecord)){
                                        toBeInsertedLogs.get(contactRecord).add(allAccessGroupId);  
                                    }else{
                                        toBeInsertedLogs.put(contactRecord,new List<id> {allAccessGroupId});  
                                    }
                                }else{
                                    if(addFalloutLogs.containsKey(contactRecord)){
                                        addFalloutLogs.get(contactRecord).add(channelProgram);    
                                    }else{
                                        addFalloutLogs.put(contactRecord,new List<id> {channelProgram});  
                                    }
                                }
                            }                            
                            //For IPA PNUM Insertion filtering out contacts that have IPA USER
                            if(entitlementRecord==Label.Core_MDF_ProcessEntitlements_PNUMCreation.toUpperCase('en')){                                
                                if(userToGroupList.containsKey(contactToUserMap.get(contactRecord))){
                                    userToGroupList.get(contactToUserMap.get(contactRecord)).add(groupID);
                                }else{
                                    userToGroupList.put(contactToUserMap.get(contactRecord), new List<Id>{ groupID });
                                }  
                                //userId to VC Map creation - NA
                                String accProgKey = String.valueOf(contactToAccountMap.get(contactRecord)) + channelProgram;
                                userToVirtualCorpMap.put(contactToUserMap.get(contactRecord),accProgToVirtualCorpIdMap.get(accProgKey));
                            } 
                        }
                    }                    
                    if(toBeAddedGM.size()>0){
                        List<id> insertedGMIds = new List<id>();
                        boolean successFlag = false;
                        Database.SaveResult[] saveList = Database.insert(toBeAddedGM,true);
                        
                        for(Database.SaveResult sr : saveList) {
                            if(sr.isSuccess()){
                                successFlag= true;
                            }
                        }
                        if(successFlag){
                            //Log the successful GroupMember addition
                            loggingRecords(toBeInsertedLogs, 'Add', 'Completed',conToAccUsrWrap,pgmWrap);                            
                            //Send for IPA PNUM Creation if IPA Users exist                            
                            if(userToVirtualCorpMap.size() > 0 && customSettingsMap.containsKey('Core_MDF_PNUM_Addition') && customSettingsMap.get('Core_MDF_PNUM_Addition').Core_Active__c){                                
                                ID jobID = System.enqueueJob(new Core_MDF_IPA_AccountUserMapping(userToVirtualCorpMap));
                            }
                        }                        
                    }else{                        
                        if(userToVirtualCorpMap.size() > 0 && customSettingsMap.containsKey('Core_MDF_PNUM_Addition') && customSettingsMap.get('Core_MDF_PNUM_Addition').Core_Active__c){
                            ID jobID = System.enqueueJob(new Core_MDF_IPA_AccountUserMapping(userToVirtualCorpMap));
                        }
                    }                    
                }
                
                //5. Removing user from Group
                if(entitlementRemoved !=null){
                    List<GroupMember> toBeDeleted = new List<GroupMember>();
                    Map<id,List<id>> userToGroupIdMap = new Map<id,List<id>>();
                    Map<id,List<id>> contactToGroupIdMap = new Map<id,List<id>>();
                    Map<string,id> userGroupIDToGMIDMap = new Map<String,Id>();
                    
                    for(id contactRecord: entitlementRemoved.keyset()){                        
                        for(string entitlementRecord: entitlementRemoved.get(contactRecord)){
                            string channelProgram = ccpEntitlementToCPMap.containsKey(entitlementRecord)? channelProgramToCPIdMap.get(ccpEntitlementToCPMap.get(entitlementRecord)) : null;
                            id groupID = channelProgram!=null? accountChannelProgramToGroupIDMap.get(contactToAccountMap.get(contactRecord) + channelProgram.trim()) : null;
                            id allAccessGroupId =  channelProgram != null? accountChannelProgramToAllAccessGroupIDMap.get(contactToAccountMap.get(contactRecord) + channelProgram.trim()) : null;
                            
                            //Check if Marketing User needs to be disabled
                            //if(entitlementRecord == Label.Core_MDF_Marketing_User_Entitlements.toUpperCase('en')){
                            if((Label.Core_MDF_Marketing_User_Entitlements.toUpperCase().split(';')).contains(entitlementRecord)){
                                marketingUserId.put(contactToUserMap.get(contactRecord), false);  
                            }
                            
                            if(ccpEntitlementToCPMap.containsKey(entitlementRecord)){
                                if(groupID!=null || allAccessGroupId != null){
                                    if(recoveryEntitlements.contains(entitlementRecord)){                                        
                                        //for recovery adm
                                        if(allAccessGroupId != null && userToGroupIdMap.containsKey(contactToUserMap.get(contactRecord))){
                                            userToGroupIdMap.get(contactToUserMap.get(contactRecord)).add(allAccessGroupId);
                                        }else{
                                            userToGroupIdMap.put(contactToUserMap.get(contactRecord), new List<id>{allAccessGroupId});
                                        }
                                        //For logging
                                        if(contactToGroupIdMap.containsKey(contactRecord)){
                                            contactToGroupIdMap.get(contactRecord).add(allAccessGroupId);
                                        }else{
                                            contactToGroupIdMap.put(contactRecord, new List<id>{allAccessGroupId});
                                        }                                        
                                    }else{
                                        if(userToGroupIdMap.containsKey(contactToUserMap.get(contactRecord))){
                                            userToGroupIdMap.get(contactToUserMap.get(contactRecord)).add(groupID);
                                        }else{
                                            userToGroupIdMap.put(contactToUserMap.get(contactRecord), new List<id>{groupID});
                                        }                                        
                                        //For logging
                                        if(contactToGroupIdMap.containsKey(contactRecord)){
                                            contactToGroupIdMap.get(contactRecord).add(groupID);
                                        }else{
                                            contactToGroupIdMap.put(contactRecord, new List<id>{groupID});
                                        }                                        
                                    }                                    
                                }
                                //Create fallout logs for Users that have No Group IDs
                                else{
                                    if(removeFalloutLogs.containsKey(contactRecord)){
                                        removeFalloutLogs.get(contactRecord).add(channelProgram);
                                    }else{
                                        removeFalloutLogs.put(contactRecord, new List<id>{channelProgram});
                                    }   
                                }                                
                            } 
                        }
                    }
                    
                    //6. Query GroupMember to get the record Ids
                    for(GroupMember gm: [select id,UserOrGroupId,GroupId from GroupMember where userorgroupid in :userToGroupIdMap.keyset()]){
                        string key = gm.UserOrGroupId;
                        key += gm.GroupId;
                        userGroupIDToGMIDMap.put(key, gm.id);
                    }
                    
                    //7. Identify the GroupMember records to be deleted
                    for(id userRecord: userToGroupIdMap.keySet()){
                        for(id groupID : userToGroupIdMap.get(userRecord)){                            
                            string key = userRecord;
                            key += groupID;
                            id gmRecord = userGroupIDToGMIDMap.get(key) == null ? null : userGroupIDToGMIDMap.get(key);
                            if(gmRecord != null){
                                gmIdsToBeDeleted.add(gmRecord);
                            }
                        }
                    }
                    
                    //8. Log the Deleted GroupMember records
                    if(gmIdsToBeDeleted.size()>0){
                        loggingRecords(contactToGroupIdMap, 'Remove', 'Completed',conToAccUsrWrap,pgmWrap);
                    }                    
                }
                
                //9. Log the fallout records
                if(addFalloutLogs.size()>0){
                    loggingRecords(addFalloutLogs, 'Add', 'Action Required',conToAccUsrWrap,pgmWrap); 
                }
                if(removeFalloutLogs.size()>0){
                    loggingRecords(removeFalloutLogs, 'Remove', 'Action Required',conToAccUsrWrap,pgmWrap); 
                }
                
                //10. Log the user creation failure contact records
                if(addFalloutLogsForInactiveUsr.size()>0){
                    loggingRecords(addFalloutLogsForInactiveUsr, 'Inactive User', 'Action Required',conToAccUsrWrap,pgmWrap); 
                }                
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    public void finish(Database.BatchableContext bc) {
        //Enable/Disable Marketing user check on User
        //US1029823: Marketing user set up automation
        //if(marketingUserId.size() > 0 && customSettingsMap.containsKey('Core_MDF_MarketingUser_Update') && customSettingsMap.get('Core_MDF_MarketingUser_Update').Core_Active__c){
        if(customSettingsMap.containsKey('Core_MDF_MarketingUser_Update') && customSettingsMap.get('Core_MDF_MarketingUser_Update').Core_Active__c){
            marketingUserOnOff(marketingUserId);
        }  
        
        //Deletion of GroupMembers
        if(gmIdsToBeDeleted.size()>0){
            Database.executeBatch(new Core_MDF_UserGroupMapping_Deletion(gmIdsToBeDeleted), 50);    
        }
        
        //Create Usershare records for the users added to groups
        if(customSettingsMap.containsKey('callExtUsrSharingFrmUGMAutomation') && customSettingsMap.get('callExtUsrSharingFrmUGMAutomation').Core_Active__c && userOrGroupIdSet.size()>0){
            Database.executeBatch(new Core_MDF_ExternalUserSharing(true,userOrGroupIdSet));
        }
        
        if(toBeUpdatedPGM.size()>0){
            Core_MDF_Batch_Bulk_CRUD_Operations updatePGMRec = new Core_MDF_Batch_Bulk_CRUD_Operations(toBeUpdatedPGM,'update',false);
            database.executeBatch(updatePGMRec,200);
        }
        if(toBeAddedPGM.size()>0){
            Core_MDF_Batch_Bulk_CRUD_Operations insertPGMRec = new Core_MDF_Batch_Bulk_CRUD_Operations(toBeAddedPGM,'insert',false);
            database.executeBatch(insertPGMRec,200);
        }
        
        //Logging of UserGroupMapping Records
        if(logObjectList.size()>0){
            Database.executeBatch(new Core_MDF_UGMLog(logObjectList), 250);
        } 
        //Update the reprocessed log records to Completed status, so that the reprocessed records will be skipped in the next run
        if(existingLogRecTobeUpdated.size()>0){
            Database.update(existingLogRecTobeUpdated);
        }
    }
    
    public static ContactToAccUserWarpper getUserAndAccountForContact(set<id> contactList/*, boolean userDetails*/){       
        
        Map<id,id> contactToUserMap = new Map<id,id>(); //Contact to user id Map
        Map<id,id> contactToAccountMap = new Map<id,id>(); //Contact to Account id Map
        Map<Id,String> contactToDomainMap = new Map<Id,String>();
        List<id> userCreationFailedContacts =new List<id>(); //User creation failed contacts
        ContactToAccUserWarpper conWrap = new ContactToAccUserWarpper();        
        
        try{
            for(User u:[select id,Email, AccountId,ContactId from user where (IsActive = true or Partner_License_Reclaimed__c = true) and ContactId in: contactList]){
                contactToUserMap.put(u.ContactId, u.id);
                contactToAccountMap.put(u.ContactId,u.AccountId);
                String email = u.Email;
                String domain = (email != null && email.contains('@')) ? email.split('@')[1]: NULL;
                contactToDomainMap.put(u.ContactId,domain);
            }
            conWrap.contactToUserMap = contactToUserMap;
            conWrap.contactToAccountMap = contactToAccountMap;
            conWrap.contactToDomainMap = contactToDomainMap;
            Set<Id> set1 = new Set<Id>(contactList);
            Set<Id> set2 = new Set<Id>(contactToUserMap.keySet());
            set1.removeAll(set2);
            userCreationFailedContacts = new List<Id>(set1);  
            conWrap.userCreationFailedContacts = userCreationFailedContacts;  
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}      
        return conWrap;
    }
    
    public static PGMWrapper getAccountGroupsFromPGM(List<id> accountIds){
        
        Map<string,id> accountChannelProgramToGroupIDMap = new Map<String,Id>();
        Map<string,Id> accountProgGroupIdToPGMIdMap = new Map<String,Id>();
        Map<id,List<id>> accountToWorksForMap = new Map<id,List<id>>();
        Map<string,id> accProgToVirtualCorpIdMap = new Map<string,id>();
        Map<id,id> groupIdToCPMap = new Map<id,id>();
        Set<id> multipleWorksFor = new Set<id>();
        string key;
        PGMWrapper pgmWrap = new PGMWrapper();
        Map<string,id> accountChannelProgramToAllAccessGroupIDMap = new Map<String,id>();  
        
        try{            
            for(Core_MDF_Partner_Group_Mapping__c pgm : [select Core_MDF_Account__c,Core_MDF_Works_For__c,Core_MDF_Group_Id__c,Core_MDF_Channel_Program__c,Core_MDF_Type_of_Access__c,Core_MDF_All_Access_Group_Id__c,Core_MDF_Virtual_Corp_nm__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Inactive_Ind__c 
                                                         from Core_MDF_Partner_Group_Mapping__c 
                                                         where Core_MDF_Account__c in : accountIds
                                                         and Core_MDF_Type_of_Access__c='External'])
            {
                if(pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c != 'Intel Partner Alliance' && pgm.Core_MDF_Inactive_Ind__c == true){
                    String uniquekey = String.valueOf(pgm.Core_MDF_Account__c) + String.valueOf(pgm.Core_MDF_Channel_Program__c) + String.valueOf(pgm.Core_MDF_Group_Id__c);
                    accountProgGroupIdToPGMIdMap.put(uniquekey,pgm.Id);
                }
                if(pgm.Core_MDF_Inactive_Ind__c == false){
                    key =pgm.Core_MDF_Account__c;
                    key += pgm.Core_MDF_Channel_Program__c;
                    accountChannelProgramToGroupIDMap.put(key,pgm.Core_MDF_Group_Id__c);
                    //Prepare Map with Key as GroupId and value as Channel Program
                    groupIdToCPMap.put(pgm.Core_MDF_Group_Id__c,pgm.Core_MDF_Channel_Program__c);
                    //If All Access Group applicable i.e., CCF,DCF,EEF
                    if(pgm.Core_MDF_All_Access_Group_Id__c!= null){
                        accountChannelProgramToAllAccessGroupIDMap.put(key,pgm.Core_MDF_All_Access_Group_Id__c);
                        //Prepare Map with Key as All Access GroupId and value as Channel Program
                        groupIdToCPMap.put(pgm.Core_MDF_All_Access_Group_Id__c,pgm.Core_MDF_Channel_Program__c);
                    }
                    if(pgm.Core_MDF_Virtual_Corp_nm__c!=null){
                        String accProgKey = String.valueOf(pgm.Core_MDF_Account__c) + String.valueOf(pgm.Core_MDF_Channel_Program__c);
                        accProgToVirtualCorpIdMap.put(accProgKey,pgm.Core_MDF_Virtual_Corp_nm__c);
                    }
                    //to store account+channel program specific PGM group id
                    if(pgm.Core_MDF_Works_For__c != null){
                        if(accountToWorksForMap.containskey(pgm.Core_MDF_Account__c)){
                            List<id> worksFor = accountToWorksForMap.get(pgm.Core_MDF_Account__c);
                            if(!worksFor.contains(pgm.Core_MDF_Works_For__c)){
                                multipleWorksFor.add(pgm.Core_MDF_Account__c);
                                accountToWorksForMap.get(pgm.Core_MDF_Account__c).add(pgm.Core_MDF_Works_For__c); 
                            }
                        }else{
                            accountToWorksForMap.put(pgm.Core_MDF_Account__c, new List<id>{pgm.Core_MDF_Works_For__c});
                        }  
                    }
                }
            }
            
            //Loop through the multipleWorksFor and remove the Account so that user does not get added to any group
            if(multipleWorksFor.size()>0){
                for(id worksFor : multipleWorksFor){
                    for(string accountChannelProgram : accountChannelProgramToGroupIDMap.keyset()){
                        string accountID = accountChannelProgram.left(18);
                        if(accountID == worksFor){
                            //Remove key
                            accountChannelProgramToGroupIDMap.remove(accountChannelProgram);                            
                        }
                    }  
                }  
            }            
            pgmWrap.accountChannelProgramToGroupIDMap = accountChannelProgramToGroupIDMap;
            pgmWrap.accountChannelProgramToAllAccessGrpIDMap =  accountChannelProgramToAllAccessGroupIDMap;
            pgmWrap.accProgToVirtualCorpIdMap = accProgToVirtualCorpIdMap; 
            pgmWrap.groupIdToChannelProgramId = groupIdToCPMap;
            pgmWrap.accToWorksforMap = accountToWorksForMap; 
            pgmWrap.accountProgGroupIdToPGMIdMap = accountProgGroupIdToPGMIdMap;
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return pgmWrap;
    }
    
    public void loggingRecords(Map<id,List<id>> contactToGroupMap, string action, string status,ContactToAccUserWarpper conWrap,PGMWrapper pgmWrap){
        
        Map<id,id> contactToAccountMap = new Map<id,id>();
        Map<id,id> contactToUserMap = new Map<id,id>();
        Map<id,List<id>> accountToWorksForMap = new Map<id,List<id>>();
        Map<id,id> groupToChannelProgram = new Map<id,id>();
        List<id> multipleWorksFor = new List<id>();
        Map<id,id> groupToAccount = new Map<id,id>();
        Map<id,id> allAccessGroupToChannelProgram = new Map<id,id>();
        
        try{
            contactToAccountMap = conWrap.contactToAccountMap;
            contactToUserMap = conWrap.contactToUserMap;
            accountToWorksForMap = pgmWrap.accToWorksforMap;
            groupToChannelProgram = pgmWrap.groupIdToChannelProgramId;
            
            for(id contactID: contactToGroupMap.keyset()){
                List<id> groupIdList = contactToGroupMap.get(contactID);
                for(id groupID : groupIdList){
                    Core_MDF_UserGroupMapping_Log__c logobject = new Core_MDF_UserGroupMapping_Log__c();
                    
                    logobject.Core_MDF_User_id__c= contactToUserMap.get(contactID);
                    // logobject.Core_MDF_Group_id__c = String.valueOf(groupID).startsWith('00G') ? groupID: null;
                    //Exception Fix
                    logobject.Core_MDF_Group_id__c = (groupID != null && String.valueOf(groupID).startsWith('00G')) ? groupID: null;
                    logobject.Core_MDF_Contact_id__c = contactID;
                    logobject.Core_MDF_Account_id__c =contactToAccountMap.get(contactID);
                    if(accountToWorksForMap.containskey(contactToAccountMap.get(contactID)) && accountToWorksForMap.get(contactToAccountMap.get(contactID)).size() == 1){
                        logobject.Core_MDF_Works_For_Account_id__c = accountToWorksForMap.get(contactToAccountMap.get(contactID))[0];                            
                    }
                    //logobject.Core_MDF_Channel_Program_id__c =String.valueOf(groupID).startsWith('00G')?groupToChannelProgram.get(groupID): groupID;  
                    logobject.Core_MDF_Channel_Program_id__c =(groupID != null && String.valueOf(groupID).startsWith('00G'))?groupToChannelProgram.get(groupID): groupID;  
                    logObject.Core_MDF_Processed_dtm__c = system.now();
                    logobject.Core_MDF_Action_nm__c = action;
                    logObject.Core_MDF_Status_nm__c= status;
                    
                    if(accountToWorksForMap.containskey(contactToAccountMap.get(contactID)) && accountToWorksForMap.get(contactToAccountMap.get(contactID)).size() > 1){
                        logobject.Core_MDF_Error_Message_txt__c = 'Multiple Works For';
                    }else{
                        if(string.isEmpty(contactToUserMap.get(contactID))){
                            logobject.Core_MDF_Error_Message_txt__c = String.isEmpty(logobject.Core_MDF_Error_Message_txt__c) ? 'User is inactive' :logobject.Core_MDF_Error_Message_txt__c + '; User is inactive';
                        }else if(!String.valueOf(groupID).startsWith('00G')){
                            logobject.Core_MDF_Error_Message_txt__c = String.isEmpty(logobject.Core_MDF_Error_Message_txt__c) ? 'PGM does not exist' : logobject.Core_MDF_Error_Message_txt__c + '; PGM does not exist' ;    
                        }  
                    }                    
                    logObjectList.add(logobject);
                }    
            } 
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }   
    
    public Map<id,List<id>> queryGroupMemeberRecords(List<id> userIds){
        Map<id,List<id>> existingGMRecords = new Map<id,List<id>>();
        
        for(groupmember gm: [select GroupId, UserOrGroupId FROM GroupMember where UserOrGroupId in :userIds]){
            if(gm.GroupId != null){
                if(existingGMRecords.containsKey(gm.UserOrGroupId)){
                    existingGMRecords.get(gm.UserOrGroupId).add(gm.GroupId);
                }else{
                    existingGMRecords.put(gm.UserOrGroupId, new List<id>{gm.GroupId});
                }    
            }
        }
        return existingGMRecords;
    }
    
    public static void marketingUserOnOff(Map<id,boolean> userToSwitch){
        
        Map<id,boolean> existingUserRecords = new Map<id,boolean>();
        List<User> userListForUpdate = new List<User>();
        List<Core_MDF_Bulk_Transaction__e> toBeUpdatedUserList = new List<Core_MDF_Bulk_Transaction__e>();
        //US1029823: Marketing user set up automation
        List<String> marketingUserPS = Label.Core_MDF_Account_Manager_Permission_Sets.Split(',');
        marketingUserPS.add('Core_MDF_CCP_External_IPA_Proposal_Manager');
        marketingUserPS.add(Label.Core_MDF_CCP_Co_GTM_Project_Submitter);
        //Jahnavi K -- Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
        for(PermissionSetAssignment record: [select AssigneeId from PermissionSetAssignment where PermissionSet.name in :marketingUserPS and (Assignee.IsActive= true or Assignee.Partner_License_Reclaimed__c = true)]){
            userToSwitch.put(record.AssigneeId, true);
        }
        //US1029823: Marketing user set up automation
        
        for(user userRecord: [select id,UserPermissionsMarketingUser from User where id in: userToSwitch.keyset() and IsActive=true]){
            existingUserRecords.put(userRecord.id,userRecord.UserPermissionsMarketingUser);
        }
        
        for(Id userId : userToSwitch.keyset()){   
            if(userToSwitch.get(userId) != existingUserRecords.get(userId)){
                User userInstance = new User();
                userInstance.Id = userId;
                userInstance.UserPermissionsMarketingUser = userToSwitch.get(userId)? TRUE : FALSE;
                Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e();
                evtObj.Core_MDF_JSON_Data__c = JSON.serialize(userInstance); 
                evtObj.Core_MDF_Object_Name__c = 'User';
                toBeUpdatedUserList.add(evtObj);
            } 
        }
        
        //US1073355 - Marketing User to be updated through Platform Event
        if(toBeUpdatedUserList != null && !toBeUpdatedUserList.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(toBeUpdatedUserList);
            /*for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    //System.debug('Process Entitlements Marketing User Update:: Successfully published event');
                }else{ 
                    for(Database.Error err : sr.getErrors()) { 
                        // System.debug('Error returned: ' + err.getStatusCode() ); 
                    }
                }
            }*/ 
        }
        //US1073355 Changes End
    }
    public static void bulkAPILog(String reqString){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        String endPointUrl = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest';
        //request.setEndpoint('callout:Bulk_API');
        request.setEndpoint(endPointUrl);
        
        request.setHeader('content-type', 'application/json' );
        String body = '{'+  
            '"lineEnding": "CRLF",'+ 
            '"operation": "insert",'+ 
            '"object": "Core_MDF_UserGroupMapping_Log__c",'+ 
            '"contentType": "CSV"'+
            '}';
        
        request.setBody(body);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        if(resp.getStatusCode() <= 299) {
            Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
            String jobId = (String)respMap.get('id');
            
            //second request to store data
            HttpRequest request1 = new HttpRequest();
            request1.setMethod('PUT');
            String endPointUrl1 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/' + jobId+'/batches';
            request1.setEndpoint(endPointUrl1);
            request1.setHeader('content-type', 'text/csv' );
            
            request1.setBody(reqString);
            request1.setTimeout(20000);
            Http h1 = new Http();
            HttpResponse resp1 = h1.send(request1);
            if(resp1.getStatusCode() <= 299) {
                
                HttpRequest request2 = new HttpRequest();
                request2.setMethod('PATCH');
                String endPointUrl2 = 'callout:PicklistNamedCredentialForGVS/services/data/v56.0/jobs/ingest/' + jobId;
                request2.setEndpoint(endPointUrl2);
                request2.setHeader('content-type', 'application/json' );				
                request2.setBody('{ "state" : "UploadComplete" }');
                Http h2 = new Http();
                HttpResponse resp2 = h2.send(request2);
            }            
        }
    }
    public static Map<String, String> pgdmCheck(Set<String>domainSet,Set<String> programIdSet){
        Map<String, Set<String>> activeGroupSet = new Map<String, Set<String>>();
        Map<String, Set<String>> inactiveGroupSet = new Map<String, Set<String>>();
        List<Core_MDF_Partner_Group_Domain_Mapping__c> pgdmList = [SELECT Id,Name,Core_MDF_Partner_Group_Mapping_Id__c, Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Account__c, Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Channel_Program__c, Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Group_Name__c, Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Group_Id__c,Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_CoMarketingActive_Ind__c FROM Core_MDF_Partner_Group_Domain_Mapping__c WHERE Name IN:domainSet AND Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Channel_Program__c IN:programIdSet AND Core_MDF_Active_Ind__c = TRUE ORDER BY Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_CoMarketingActive_Ind__c DESC];
        for(Core_MDF_Partner_Group_Domain_Mapping__c pgdm : pgdmList){
            String nameProgKey = pgdm.Name + pgdm.Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Channel_Program__c;
            String grpNameIdVal = pgdm.Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Group_Name__c + ':' + pgdm.Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Group_Id__c;
            if(pgdm.Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_CoMarketingActive_Ind__c){
                if(!activeGroupSet.containsKey(nameProgKey)){
                    activeGroupSet.put(nameProgKey, new Set<String>());
                }
                activeGroupSet.get(nameProgKey).add(grpNameIdVal);
            }else {                
                if (!inactiveGroupSet.containsKey(nameProgKey)) {
                    inactiveGroupSet.put(nameProgKey, new Set<String>());
                }
                inactiveGroupSet.get(nameProgKey).add(grpNameIdVal);
            }
        }
        Map<String,String> result = new Map<String,String>();
        Set<String> allKeys = new Set<String>();
        allKeys.addAll(activeGroupSet.keySet());
        allKeys.addAll(inactiveGroupSet.keySet());        
        for(String key : allKeys){                
            Set<String> actives = activeGroupSet.get(key);
            Set<String> inactives = inactiveGroupSet.get(key);            
            if(actives != null && !actives.isEmpty()) {
                result.put(key, actives.size() == 1 ? actives.iterator().next() : NULL);
            }else if(inactives != null && !inactives.isEmpty()) {
                result.put(key, inactives.size() == 1 ? inactives.iterator().next() : NULL);
            }else{
                result.put(key, NULL);
            }
        }       
        return result;
    }
    public class ContactToAccUserWarpper {
        public Map<Id,Id> contactToUserMap {get; set;}
        public Map<Id,Id> contactToAccountMap {get; set;}
        public Map<Id,String> contactToDomainMap {get; set;}
        public List<id> userCreationFailedContacts {get;set;}       
    }
    public class PGMWrapper {
        public Map<string,id> accountChannelProgramToGroupIDMap{get; set;}
        public Map<string,id> accountProgGroupIdToPGMIdMap{get; set;}
        public Map<string,id> accountChannelProgramToAllAccessGrpIDMap {get; set;}
        public Map<string,id> accProgToVirtualCorpIdMap {get;set;}
        public Map<id,id> groupIdToChannelProgramId {get;set;}
        public Map<id,List<id>> accToWorksforMap {get;set;}       
    }
}