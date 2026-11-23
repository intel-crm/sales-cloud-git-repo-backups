global class Core_MDF_ProcessEntitlements implements Database.Batchable<sObject>, Database.Stateful {
    
    public set<string> userOrGroupIdSet = new set<string>();
    public Map<String,Core_Trigger_Executions__c> customSettingsMap = Core_Trigger_Executions__c.getAll();
    public List<Core_MDF_UserGroupMapping_Log__c> logObjectList = new List<Core_MDF_UserGroupMapping_Log__c>();
    public List<id> gmIdsToBeDeleted = new List<Id>();
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        List<string> entitlements = new List<string>();
        Datetime rangeToBeSelected = System.now().addHours(integer.valueOf(Label.Core_MDF_Entitlements_Group_TimeFrame));
        
        system.debug('rangeToBeSelected' + rangeToBeSelected);
               
        strQuery='select Core_Contact_Id__c,Core_Entitlement_Nm__c,Core_Selected__c, Core_Status__c from Core_Contact_Entitlement__c ';
        strQuery +='where Core_Type__c = \'Entitlement\' and Core_Status__c=\'Complete\' and LastModifiedDate >= :rangeToBeSelected ' ;
        strQuery += 'and Core_Entitlement_Nm__c in (';
        for(string entitlement : Label.Core_MDF_Entitlements_Group_Automation.split(';')){
             strQuery += '\'' + entitlement + '\',';
        }
        strQuery = strQuery.removeend(',');
        strQuery += ')';
        
        system.debug('strQuery' +strQuery);
        
        return Database.getQueryLocator(strQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Core_Contact_Entitlement__c> newContactEntitlementList) {      
        
        Map<id,List<string>> newEntitlementAssigned = new Map<id,List<string>>();
        Map<id,List<string>> entitlementRemoved = new Map<id,List<string>>();
        Map<id,id> contactToUserMap = new Map<id,id>();
        Map<id,id> contactToAccountMap = new Map<id,id>();
        Map<id,id> worksForToAccountMap = new Map<id,id>();
        
        Map<string,id> accountChannelProgramToGroupIDMap = new Map<string,id>();
        set<id> contactIds = new set<id>();
        Map<string,string> ccpEntitlementToCPMap = new Map<string,string>();
        
        Map<string,id> channelProgramToCPIdMap = new Map<string,id>();
        
        Map<id,List<id>> toBeInsertedLogs = new Map<id,List<id>>();
        Map<id,List<id>> toBeDeletedLogs = new Map<id,List<id>>();
        
        Map<id,List<id>> addFalloutLogs = new Map<id,List<id>>();
        Map<id,List<id>> removeFalloutLogs = new Map<id,List<id>>();
        
        try{
            
            system.debug('newContactEntitlementList'+ newContactEntitlementList.size());
            
            if(newContactEntitlementList.size()>0){
                //1. Loop through the inputs and segregate Entitlement Addition and Removal
                for(Core_Contact_Entitlement__c ce: newContactEntitlementList){
                    contactIds.add(ce.Core_Contact_Id__c);
                    
                    //If Entitlement is added
                    if(ce.Core_Selected__c == true){
                        if(newEntitlementAssigned.containsKey(ce.Core_Contact_Id__c)){
                            newEntitlementAssigned.get(ce.Core_Contact_Id__c).add((ce.Core_Entitlement_Nm__c).toUpperCase());
                        }
                        else{
                            newEntitlementAssigned.put(ce.Core_Contact_Id__c, new List<string>{ (ce.Core_Entitlement_Nm__c).toUpperCase() });
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
                
                //2. Prepare all Maps to identify the Group to be added/removed
                if(newEntitlementAssigned.size()>0 || entitlementRemoved.size()>0){
                    
                    //Create Map of Entitlements to Channel Program Name - CCF USER => Client Co-Marketing Fund
                    for(string entitlementToChannelProgram : Label.Core_MDF_User_Group_Mapping_Automation_Audience_List.split(';')){
                        List<string> record = entitlementToChannelProgram.split(':');
                        ccpEntitlementToCPMap.put(record[0].toUpperCase(),record[1]);
                    }
                    
                    //Create Map of Channel Program Name to Channel Program ID - Client Co-Marketing Fund => id
                    for(ChannelProgram cp : [select Name, id from ChannelProgram where name in: ccpEntitlementToCPMap.values()]){
                        channelProgramToCPIdMap.put(cp.Name, cp.id);
                    }
                    
                    //Prepare Contact -> User Map
                    contactToUserMap = getUserAndAccountForContact(contactIds,true);
                    
                    //Prepare Contact -> Account Map
                    contactToAccountMap = getUserAndAccountForContact(contactIds,false);
                    
                    system.debug('contactToAccountMap' + contactToAccountMap);
                    
                    //Prepare AccountChannelProgram -> GroupID Map
                    accountChannelProgramToGroupIDMap = getAccountGroupsFromPGM(contactToAccountMap.values());
                }
                
                //3. Adding to user to Group
                if(newEntitlementAssigned.size()>0){
                    List<GroupMember> toBeAddedGM = new List<GroupMember>();
                    
                    Map<id,List<id>> userToGroupList = new Map<id,List<id>>();
                    
                    for(id contactRecord: newEntitlementAssigned.keyset()){
                        for(string entitlementRecord: newEntitlementAssigned.get(contactRecord)){
                            string channelProgram = channelProgramToCPIdMap.get(ccpEntitlementToCPMap.get(entitlementRecord));
                            id groupID = accountChannelProgramToGroupIDMap.get(contactToAccountMap.get(contactRecord) + channelProgram.trim());
                            
                            
                            //Create Group Member Records for records having GroupID
                            if(contactToUserMap.get(contactRecord)!=null && groupID != null){
                                GroupMember gm = new GroupMember();
                                gm.UserOrGroupId = contactToUserMap.get(contactRecord);
                                gm.GroupId = groupID;
                                userOrGroupIdSet.add(contactToUserMap.get(contactRecord));
                                toBeAddedGM.add(gm); 
                                
                                if(toBeInsertedLogs.containsKey(contactRecord)){
                                    toBeInsertedLogs.get(contactRecord).add(groupID);  
                                }
                                else{
                                    toBeInsertedLogs.put(contactRecord,new List<id> {groupID});  
                                }
                                
                                /* Part of future releases
                                //For IPA PNUM Insertion filtering out contacts that have IPA USER
                                if(entitlementRecord=='IPA USER'){
                                if(userToGroupList.containsKey(contactToUserMap.get(contactRecord))){
                                userToGroupList.get(contactToUserMap.get(contactRecord)).add(groupID);
                                }
                                else{
                                userToGroupList.put(contactToUserMap.get(contactRecord), new List<Id>{ groupID });
                                } 
                                }*/
                            }
                            
                            //Create fallout logs for Users that have No Group IDs
                            else{
                                if(addFalloutLogs.containsKey(contactRecord)){
                                    addFalloutLogs.get(contactRecord).add(channelProgram);    
                                }
                                else{
                                    addFalloutLogs.put(contactRecord,new List<id> {channelProgram});  
                                }
                            }
                            //system.debug('userToGroupList' + userToGroupList + 'toBeInsertedLogs' + toBeInsertedLogs);
                        }
                    }
                    
                    if(toBeAddedGM.size()>0){
                        List<id> insertedGMIds = new List<id>();
                        boolean successFlag = false;
                        Database.SaveResult[] saveList = Database.insert(toBeAddedGM,true);
                        system.debug('saveList' + saveList);
                        
                        for(Database.SaveResult sr : saveList) {
                            if(sr.isSuccess()){
                                successFlag= true;
                            }
                        }
                        if(successFlag){
                            loggingRecords(toBeInsertedLogs, 'Add', 'Completed');
                            
                            //ID jobID = System.enqueueJob(new Core_MDF_IPA_AccountUserMapping(userToGroupList));
                        }
                    }
                }
                
                system.debug('channelProgramToCPIdMap' + channelProgramToCPIdMap);
                system.debug('ccpEntitlementToCPMap' + ccpEntitlementToCPMap);
                
                //4. Removing user from Group
                if(entitlementRemoved !=null){
                    List<GroupMember> toBeDeleted = new List<GroupMember>();
                    Map<id,List<id>> userToGroupIdMap = new Map<id,List<id>>();
                    Map<id,List<id>> contactToGroupIdMap = new Map<id,List<id>>();
                    Map<string,id> userGroupIDToGMIDMap = new Map<String,Id>();
                    
                    for(id contactRecord: entitlementRemoved.keyset()){
                        
                        for(string entitlementRecord: entitlementRemoved.get(contactRecord)){
                            system.debug('entitlementRecord' + entitlementRecord);
                            system.debug('ccpEntitlementToCPMap.get(entitlementRecord.toUpperCase())' + ccpEntitlementToCPMap.get(entitlementRecord.toUpperCase()));
                            
                            string channelProgram = channelProgramToCPIdMap.get(ccpEntitlementToCPMap.get(entitlementRecord));
                            id groupID = accountChannelProgramToGroupIDMap.get(contactToAccountMap.get(contactRecord) + channelProgram.trim());
                            
                            system.debug('channelProgram + ' + channelProgram + 'groupID : ' +groupID ); 
                            
                            if(groupID!=null){
                                if(userToGroupIdMap.containsKey(contactToUserMap.get(contactRecord))){
                                    userToGroupIdMap.get(contactToUserMap.get(contactRecord)).add(groupID);
                                }
                                else{
                                    userToGroupIdMap.put(contactToUserMap.get(contactRecord), new List<id>{groupID});
                                }
                                
                                //For logging
                                if(contactToGroupIdMap.containsKey(contactRecord)){
                                    contactToGroupIdMap.get(contactRecord).add(groupID);
                                }
                                else{
                                    contactToGroupIdMap.put(contactRecord, new List<id>{groupID});
                                }
                            }
                            //Create fallout logs for Users that have No Group IDs
                            else{
                                if(removeFalloutLogs.containsKey(contactRecord)){
                                    removeFalloutLogs.get(contactRecord).add(channelProgram);
                                }
                                else{
                                    removeFalloutLogs.put(contactRecord, new List<id>{channelProgram});
                                }   
                            }
                        }
                    }
                    
                    system.debug('userToGroupIdMap  ' +userToGroupIdMap + '  removeFalloutLogs  ' + removeFalloutLogs);
                    
                    //5. Query GroupMember to get the record Ids
                    for(GroupMember gm: [select id,UserOrGroupId,GroupId from GroupMember where userorgroupid in :userToGroupIdMap.keyset()]){
                        string key = gm.UserOrGroupId;
                        key += gm.GroupId;
                        userGroupIDToGMIDMap.put(key, gm.id);
                    }
                    
                    system.debug('userGroupIDToGMIDMap' +userGroupIDToGMIDMap);
                    
                    //6. Identify the GroupMember records to be deleted
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
                    
                    system.debug('gmIdsToBeDeleted' + gmIdsToBeDeleted);
                    
                    //7. Delete the GroupMember records
                    if(gmIdsToBeDeleted.size()>0){
                        loggingRecords(contactToGroupIdMap, 'Remove', 'Completed');
                    }
                    
                    //8. Log the fallout records
                    if(addFalloutLogs.size()>0){
                        loggingRecords(addFalloutLogs, 'Add', 'Action Required'); 
                    }
                    if(removeFalloutLogs.size()>0){
                        loggingRecords(removeFalloutLogs, 'Remove', 'Action Required'); 
                    }
                    
                }
                
            }
            
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    public void finish(Database.BatchableContext bc) {
        system.debug('Finish method');
        if(gmIdsToBeDeleted.size()>0){
            Database.executeBatch(new Core_MDF_UserGroupMapping_Deletion(gmIdsToBeDeleted), 50);    
        }
        //Create usershare records for the users added to groups
        if(customSettingsMap.containsKey('callExtUsrSharingFrmUGMAutomation') && customSettingsMap.get('callExtUsrSharingFrmUGMAutomation').Core_Active__c && userOrGroupIdSet.size()>0){
        	Database.executeBatch(new Core_MDF_ExternalUserSharing(true,userOrGroupIdSet));
        }
        
        if(logObjectList.size()>0){
            Database.executeBatch(new Core_MDF_UGMLog(logObjectList), 250);
        }    
    }
    
    public static Map<id,id> getUserAndAccountForContact(set<id> contactList, boolean userDetails){
        
        Map<id,id> contactToUserMap = new Map<id,id>();
        Map<id,id> contactToAccountMap = new Map<id,id>();
        
        try{
            for(User u:[select id, AccountId,ContactId from user where IsActive = true and ContactId in: contactList]){
                contactToUserMap.put(u.ContactId, u.id);
                contactToAccountMap.put(u.ContactId,u.AccountId);
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}      
        
        if(userDetails){
            return contactToUserMap;
        }
        else{
            return contactToAccountMap;
        }
    }
    
    public static Map<string,id> getAccountGroupsFromPGM(List<id> accountIds){
        
        Map<string,id> accountChannelProgramToGroupIDMap = new Map<String,Id>();
        Map<id,List<id>> accountToWorksForMap = new Map<id,List<id>>();
        Set<id> multipleWorksFor = new Set<id>();
        string key;
        
        try{
            
            for(Core_MDF_Partner_Group_Mapping__c pgm : [select Core_MDF_Account__c,Core_MDF_Works_For__c,Core_MDF_Group_Id__c,Core_MDF_Channel_Program__c,Core_MDF_Type_of_Access__c 
                                                         from Core_MDF_Partner_Group_Mapping__c 
                                                         where Core_MDF_Account__c in : accountIds
                                                         and Core_MDF_Type_of_Access__c='External']){
                                                             
                                                             key =pgm.Core_MDF_Account__c;
                                                             key += pgm.Core_MDF_Channel_Program__c;
                                                             accountChannelProgramToGroupIDMap.put(key,pgm.Core_MDF_Group_Id__c);
                                                             
                                                             if(pgm.Core_MDF_Works_For__c != null){
                                                                 if(accountToWorksForMap.containskey(pgm.Core_MDF_Account__c)){
                                                                     List<id> worksFor = accountToWorksForMap.get(pgm.Core_MDF_Account__c);
                                                                     if(!worksFor.contains(pgm.Core_MDF_Works_For__c)){
                                                                         multipleWorksFor.add(pgm.Core_MDF_Account__c);
                                                                         accountToWorksForMap.get(pgm.Core_MDF_Account__c).add(pgm.Core_MDF_Works_For__c); 
                                                                     }
                                                                 }
                                                                 else{
                                                                     accountToWorksForMap.put(pgm.Core_MDF_Account__c, new List<id>{pgm.Core_MDF_Works_For__c});
                                                                 }  
                                                             }
                                                         }
            system.debug('accountChannelProgramToGroupIDMap' + accountChannelProgramToGroupIDMap);
            
            //Loop through the multipleWorksFor and remove the Account so that user does not get added to any group
            if(multipleWorksFor.size()>0){
                for(id worksFor : multipleWorksFor){
                    for(string accountChannelProgram : accountChannelProgramToGroupIDMap.keyset()){
                        string accountID = accountChannelProgram.left(18);
                        if(accountID == worksFor){
                            //Remove key
                            accountChannelProgramToGroupIDMap.remove(accountChannelProgram);
                            system.debug('Agency removed' + accountID);
                        }
                    }  
                }  
            }
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        
        return accountChannelProgramToGroupIDMap;
    }
    
    public void loggingRecords(Map<id,List<id>> contactToGroupMap, string action, string status){

        Map<id,id> contactToAccountMap = new Map<id,id>();
        Map<id,id> contactToUserMap = new Map<id,id>();
        Map<id,List<id>> accountToWorksForMap = new Map<id,List<id>>();
        Map<id,id> groupToChannelProgram = new Map<id,id>();
        List<id> multipleWorksFor = new List<id>();
        Map<id,id> groupToAccount = new Map<id,id>();
        
        try{
            
            for(User u : [select id, AccountId, contactId from user where isActive=true and contactId in: contactToGroupMap.keyset()]){
                contactToAccountMap.put(u.contactId,u.AccountId);
                contactToUserMap.put(u.contactId,u.id);
            }
            
            system.debug('contactToUserMap' + contactToUserMap);
            
            for(Core_MDF_Partner_Group_Mapping__c pgm : [select Core_MDF_Account__c,Core_MDF_Works_For__c,Core_MDF_Group_Id__c,Core_MDF_Channel_Program__c,Core_MDF_Type_of_Access__c 
                                                         from Core_MDF_Partner_Group_Mapping__c 
                                                         where Core_MDF_Type_of_Access__c='External']){
                                                             if(pgm.Core_MDF_Works_For__c != null){
                                                                 if(accountToWorksForMap.containsKey(pgm.Core_MDF_Account__c)){
                                                                     List<id> worksFor = accountToWorksForMap.get(pgm.Core_MDF_Account__c);
                                                                     if(!worksFor.contains(pgm.Core_MDF_Works_For__c)){
                                                                         accountToWorksForMap.get(pgm.Core_MDF_Account__c).add(pgm.Core_MDF_Works_For__c);
                                                                         multipleWorksFor.add(pgm.Core_MDF_Account__c);  
                                                                     }                                              
                                                                 }
                                                                 else{
                                                                     accountToWorksForMap.put(pgm.Core_MDF_Account__c,new list<id> {pgm.Core_MDF_Works_For__c});
                                                                 }
                                                             }
                                                             
                                                             groupToChannelProgram.put(pgm.Core_MDF_Group_Id__c,pgm.Core_MDF_Channel_Program__c);
                                                             groupToAccount.put(pgm.Core_MDF_Group_Id__c,pgm.Core_MDF_Account__c);
                                                         }
            
            system.debug('accountToWorksForMap' + accountToWorksForMap);
            
            for(id contactID: contactToGroupMap.keyset()){
                List<id> groupIdList = contactToGroupMap.get(contactID);
                for(id groupID : groupIdList){
                    Core_MDF_UserGroupMapping_Log__c logobject = new Core_MDF_UserGroupMapping_Log__c();
                    
                    logobject.Core_MDF_User_id__c= contactToUserMap.get(contactID);
                    logobject.Core_MDF_Group_id__c = String.valueOf(groupID).startsWith('00G') ? groupID: null;
                    logobject.Core_MDF_Contact_id__c = contactID;
                    logobject.Core_MDF_Account_id__c =contactToAccountMap.get(contactID);
                    if(accountToWorksForMap.containskey(contactToAccountMap.get(contactID)) && accountToWorksForMap.get(contactToAccountMap.get(contactID)).size() == 1){
                        logobject.Core_MDF_Works_For_Account_id__c = accountToWorksForMap.get(contactToAccountMap.get(contactID))[0];                            
                    }
                    logobject.Core_MDF_Channel_Program_id__c =String.valueOf(groupID).startsWith('00G')?groupToChannelProgram.get(groupID): groupID;  
                    logObject.Core_MDF_Processed_dtm__c = system.now();
                    logobject.Core_MDF_Action_nm__c = action;
                    logObject.Core_MDF_Status_nm__c= status;
                    if(multipleWorksFor.contains(contactToAccountMap.get(contactID))){
                        logobject.Core_MDF_Error_Message_txt__c = 'Multiple Works For';
                    }
                    else{
                        if(string.isEmpty(contactToUserMap.get(contactID))){
                            logobject.Core_MDF_Error_Message_txt__c = String.isEmpty(logobject.Core_MDF_Error_Message_txt__c) ? 'User is inactive' :logobject.Core_MDF_Error_Message_txt__c + '; User is inactive';
                        }
                        else if(!String.valueOf(groupID).startsWith('00G')){
                            logobject.Core_MDF_Error_Message_txt__c = String.isEmpty(logobject.Core_MDF_Error_Message_txt__c) ? 'PGM does not exist' : logobject.Core_MDF_Error_Message_txt__c + '; PGM does not exist' ;    
                        }  
                    }
                    system.debug('logobject' + logobject);
                    logObjectList.add(logobject);
                }    
            } 
            system.debug('logObjectList' + logObjectList);
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }   
}