global class Core_MDF_BatchAddRemoveUsersFromPGMGroup implements Database.batchable<SObject>, Database.stateful{
    
    public List<Core_MDF_UserGroupMapping_Log__c> toUpdate = new List<Core_MDF_UserGroupMapping_Log__c>();
    public String errorMsgDelete = 'Error: Group Member Removal from PGM Account Group \n\n';
    public String errorMsgInsert = 'Error: Group Member Insert to PGM Account Group \n\n';
    public Boolean isErrorOnDelete = false;
    public Boolean isErrorOnInsert = false;
    public Map<Id, Id> intAccToVCIdMap = new Map<Id, Id>();
    public List<Core_MDF_UserGroupMapping_Log__c> ugmLogs;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        try{
            List<String> actionList = new List<String>{'PGM User Addition', 'PGM User Removal', 'PNUM Addition'};
                query = 'SELECT Id, Core_MDF_Action_nm__c, Core_MDF_Status_nm__c, Core_MDF_Account_id__c, Core_MDF_Channel_Program_id__c, Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Group_id__c,Core_MDF_Virtual_Account_id__c FROM Core_MDF_UserGroupMapping_Log__c WHERE Core_MDF_Action_nm__c IN: actionList AND Core_MDF_Status_nm__c = \'In Progress\' ORDER BY Core_MDF_Account_id__r.Core_Unified_Global_Customer_BP_Id__c, Core_MDF_Account_id__c, Core_MDF_Channel_Program_id__c, Core_MDF_Group_id__c, Core_MDF_Action_nm__c desc';
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Core_MDF_UserGroupMapping_Log__c> recordList){
        try{
            ugmLogs = recordList;
            Map<Id,Set<Id>> groupIdToAccountIdsToRemoveUsersMap = new Map<Id,Set<Id>>();
            Map<Id,Id> accountIdToGroupIdToAddUsersMap = new Map<Id,Id>();
            Set<Id> accountIdRemoveUserSet = new Set<Id>();
            
            Map<Id, List<String>> activePgmAccountIdToPrgmsMap = new Map<Id,List<String>>();
            Map<Id, List<String>> inactivePgmAccountIdToPrgmsMap = new Map<Id,List<String>>();
            Set<String> prgmNameToFetchSet = new Set<String>();
            List<Core_MDF_UserGroupMapping_Log__c> userGroupMappingList = new List<Core_MDF_UserGroupMapping_Log__c>();
            Map<Id, Id> accountIdToGroupIdWithErrors = new Map<Id, Id>();
            for(Core_MDF_UserGroupMapping_Log__c record: recordList){
                if(record.Core_MDF_Action_nm__c == 'PGM User Removal'){
                    
                    if(groupIdToAccountIdsToRemoveUsersMap.containsKey(record.Core_MDF_Group_id__c)){
                        groupIdToAccountIdsToRemoveUsersMap.get(record.Core_MDF_Group_id__c).add(record.Core_MDF_Account_id__c);
                    }else{
                        groupIdToAccountIdsToRemoveUsersMap.put(record.Core_MDF_Group_id__c, new Set<Id>{record.Core_MDF_Account_id__c});
                    }
                    
                    accountIdRemoveUserSet.add(record.Core_MDF_Account_id__c);
                    
                    if(inactivePgmAccountIdToPrgmsMap.containsKey(record.Core_MDF_Account_id__c)){
                        inactivePgmAccountIdToPrgmsMap.get(record.Core_MDF_Account_id__c).add(record.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c);
                    }else{
                        inactivePgmAccountIdToPrgmsMap.put(record.Core_MDF_Account_id__c, new List<String>{record.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c});
                    }
                    
                }else if(record.Core_MDF_Action_nm__c == 'PGM User Addition'){
                    accountIdToGroupIdToAddUsersMap.put(record.Core_MDF_Account_id__c, record.Core_MDF_Group_id__c);
                    
                    if(activePgmAccountIdToPrgmsMap.containsKey(record.Core_MDF_Account_id__c)){
                        activePgmAccountIdToPrgmsMap.get(record.Core_MDF_Account_id__c).add(record.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c);
                    }else{
                        activePgmAccountIdToPrgmsMap.put(record.Core_MDF_Account_id__c, new List<String>{record.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c});
                    }
                    prgmNameToFetchSet.add(record.Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c);
                }else if(record.Core_MDF_Action_nm__c == 'PNUM Addition'){
                    intAccToVCIdMap.put(record.Core_MDF_Account_id__c,record.Core_MDF_Virtual_Account_id__c);
                }
            }
            
            if(groupIdToAccountIdsToRemoveUsersMap != null && !groupIdToAccountIdsToRemoveUsersMap.isEmpty()){
                
                //To get User details
                Map<Id,Id> userIdToAccountIdMap = new Map<Id,Id>();
                if(!accountIdRemoveUserSet.isEmpty()){
                    userIdToAccountIdMap = Core_MDF_PGM_ServiceHandler.getUserDetails(accountIdRemoveUserSet, inactivePgmAccountIdToPrgmsMap);
                }
                
                //Remove Users from Account based Group
                //accountIdToGroupIdWithErrors.putAll(removeUsersFromAccountGroup(userIdToAccountIdMap, groupIdToAccountIdsToRemoveUsersMap, errorMsgInsert, isErrorOnInsert));
                Core_MDF_DmlOperationDetails dmlDetailsOnDelete = removeUsersFromAccountGroup(userIdToAccountIdMap, groupIdToAccountIdsToRemoveUsersMap, errorMsgDelete, isErrorOnDelete);
                errorMsgDelete = dmlDetailsOnDelete.message;
                isErrorOnDelete = dmlDetailsOnDelete.isError;
                if(dmlDetailsOnDelete.accountIdToGroupId != null){
                    accountIdToGroupIdWithErrors.putAll(dmlDetailsOnDelete.accountIdToGroupId);
                }
                
            }
            
            if(accountIdToGroupIdToAddUsersMap != null && !accountIdToGroupIdToAddUsersMap.isEmpty()){
                //Add Users to Account based Group
                //accountIdToGroupIdWithErrors.putAll(addUsersToAccountGroup(accountIdToGroupIdToAddUsersMap, activePgmAccountIdToPrgmsMap, prgmNameToFetchSet));
                Core_MDF_DmlOperationDetails dmlDetailsOnInsert = addUsersToAccountGroup(accountIdToGroupIdToAddUsersMap, activePgmAccountIdToPrgmsMap, prgmNameToFetchSet, errorMsgInsert, isErrorOnInsert);
                errorMsgInsert = dmlDetailsOnInsert.message;
                isErrorOnInsert = dmlDetailsOnInsert.isError;
                if(dmlDetailsOnInsert.accountIdToGroupId != null){
                    accountIdToGroupIdWithErrors.putAll(dmlDetailsOnInsert.accountIdToGroupId);
                }
            }
            
            for(Core_MDF_UserGroupMapping_Log__c record : recordList){
                if((!accountIdToGroupIdWithErrors.containsKey(record.Core_MDF_Account_id__c)) || (accountIdToGroupIdWithErrors.containsKey(record.Core_MDF_Account_id__c) && record.Core_MDF_Group_id__c != accountIdToGroupIdWithErrors.get(record.Core_MDF_Account_id__c))){
                    toUpdate.add(new Core_MDF_UserGroupMapping_Log__c(Id = record.Id, Core_MDF_Status_nm__c = 'Completed', Core_MDF_Processed_dtm__c = System.now()));
                }
            }
            
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    global void finish(Database.BatchableContext BC){
        try{
            if(!toUpdate.isEmpty()){
                Database.SaveResult[] srList = Database.update(toUpdate, false);
            }
            
            if(isErrorOnDelete){
                Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorMsgDelete, 'GroupMember');
            }
            
            if(isErrorOnInsert){
                Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorMsgInsert, 'GroupMember');
            }
            if(!intAccToVCIdMap.isEmpty() && Core_MDF_Utility.byPassFeature('Core_MDF_PNUM_Addition')){
                ID jobID = System.enqueueJob(new Core_MDF_ProcessPNUMFromUGM(intAccToVCIdMap,ugmLogs));
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /*****************************************************************************************************                              
Method Name   :        removeUsersFromAccountGroup                                
@return       :        void                          
@parameters   :        Map<Id,Id>, Map<Id,Set<Id>>
Description   :        Used to remove users from Account Group
Added By      :        JB - Accenture - 02/24/2023
Modified By   :        Date:           Changes:                                 
JB - Accenture         02/24/2023      Used to remove users from Account Group
******************************************************************************************************/
    public static Core_MDF_DmlOperationDetails removeUsersFromAccountGroup(Map<Id,Id> userIdToAccountIdMap, Map<Id,Set<Id>> groupIdToAccountIdsToRemoveUsersMap, String errorMsg, Boolean isError){
        
        //Remove Users from IPA Account based Group
        Map<Id, Id> accountIdToGroupIdWithErrors = new Map<Id, Id>();
        Set<Id> groupMemberToDelete = new Set<Id>();
        Map<Id, GroupMember> groupmemberIdToGroupMemMap = new Map<Id, GroupMember>();
        Core_MDF_DmlOperationDetails dmlDetails = new Core_MDF_DmlOperationDetails();
        for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN: userIdToAccountIdMap.keySet() AND GroupId IN: groupIdToAccountIdsToRemoveUsersMap.keySet()]){
            if(userIdToAccountIdMap.containsKey(gm.UserOrGroupId) && String.isNotBlank(userIdToAccountIdMap.get(gm.UserOrGroupId)) && 
               groupIdToAccountIdsToRemoveUsersMap.containsKey(gm.GroupId) && groupIdToAccountIdsToRemoveUsersMap.get(gm.GroupId).contains(userIdToAccountIdMap.get(gm.UserOrGroupId))){
                   groupMemberToDelete.add(gm.Id);
                   groupmemberIdToGroupMemMap.put(gm.Id, gm);
               }
        }
        
        
        if(!groupMemberToDelete.isEmpty()){
            Database.DeleteResult[] drList = Database.delete(new  List<Id>(groupMemberToDelete), false);
            // Iterate through each returned result
            for(Database.DeleteResult dr : drList) {
                GroupMember gmWithError = groupmemberIdToGroupMemMap.get(dr.getId());
                if(!dr.isSuccess() && gmWithError != null && userIdToAccountIdMap.keySet().contains(gmWithError.UserOrGroupId)){
                    accountIdToGroupIdWithErrors.put(userIdToAccountIdMap.get(gmWithError.UserOrGroupId), gmWithError.GroupId);
                    isError = true;
                    errorMsg += '<b>Account Id:</b> ' + userIdToAccountIdMap.get(gmWithError.UserOrGroupId) + ' <b>Group Id:</b> ' + gmWithError.GroupId + ' <b>User Id:</b> ' + gmWithError.UserOrGroupId + ' <b>Error Details:</b> ' + dr.getErrors() + '\n';
                }
            }
        }
        dmlDetails.message = errorMsg;
        dmlDetails.isError = isError;
        dmlDetails.accountIdToGroupId = accountIdToGroupIdWithErrors;
        return dmlDetails;
    }
    
    /*****************************************************************************************************                              
Method Name   :        addUsersToAccountGroup                                
@return       :        void                          
@parameters   :        Map<Id,Id>
Description   :        Used to add users to Account Group
Added By      :        JB - Accenture - 02/24/2023
Modified By   :        Date:           Changes:                                 
JB - Accenture         02/24/2023      Used to add users to Account Group
******************************************************************************************************/
    public static Core_MDF_DmlOperationDetails addUsersToAccountGroup(Map<Id,Id> accountIdToGroupIdToAddUsersMap, Map<Id, List<String>> activePgmAccountIdToPrgmsMap, Set<String> prgmNames, String errorMsg, Boolean isError){
        
        Map<String, String> permissionSetToPrgmNameMapping = new Map<String, String>();
        Core_MDF_DmlOperationDetails dmlDetails = new Core_MDF_DmlOperationDetails();
        //String permissionSetToPrgmNameMapping = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Program_PermissionSetMapping');
        for(String  prgmAndPS: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Program_PermissionSetMapping').split(';')){
            List<String> prgmandPSList = prgmAndPS.split(':');
            if(String.isNotBlank(prgmAndPS) && prgmandPSList.size() == 2 && prgmNames.contains(prgmandPSList[0])){
                //permissionSetToPrgmNameMapping.put(prgmandPSList[1], prgmandPSList[0]);
                permissionSetToPrgmNameMapping.put(prgmandPSList[1].split(',')[0], prgmandPSList[0]);  //Roshan - added for PNUM inactivation defect fix TWC3117-13707
            }
        }
        
        //Add Users to Account based Group
        List<GroupMember> groupMemberToInsertList = new List<GroupMember>();
        Map<String, GroupMember> groupMemberToInsertMap = new Map<String, GroupMember>();
        Map<Id, Id> accountIdToGroupIdMap = new Map<Id, Id>();
        Map<Id, Id> userIdToAccountIdMap = new Map<Id, Id>();
        Map<Id, Id> accountIdToGroupIdWithErrors = new Map<Id, Id>();
        for(PermissionSetAssignment psa : [SELECT PermissionSetId, AssigneeId, Assignee.AccountId, PermissionSet.Name
                                           FROM PermissionSetAssignment
                                           WHERE PermissionSet.Name IN: permissionSetToPrgmNameMapping.keySet()
                                           AND Assignee.AccountId IN: accountIdToGroupIdToAddUsersMap.keySet()]){
                                               if(String.isNotBlank(psa.Assignee.AccountId) && accountIdToGroupIdToAddUsersMap.containsKey(psa.Assignee.AccountId) && String.isNotBlank(accountIdToGroupIdToAddUsersMap.get(psa.Assignee.AccountId)) &&
                                                  activePgmAccountIdToPrgmsMap.containsKey(psa.Assignee.AccountId) && activePgmAccountIdToPrgmsMap.get(psa.Assignee.AccountId).size() > 0 && permissionSetToPrgmNameMapping.containsKey(psa.PermissionSet.Name) &&
                                                  activePgmAccountIdToPrgmsMap.get(psa.Assignee.AccountId).contains(permissionSetToPrgmNameMapping.get(psa.PermissionSet.Name))){
                                                      
                                                      //groupMemberToInsertList.add(new GroupMember(GroupId = accountIdToGroupIdToAddUsersMap.get(psa.Assignee.AccountId), UserOrGroupId = psa.AssigneeId));
                                                      String key = ''+ accountIdToGroupIdToAddUsersMap.get(psa.Assignee.AccountId) + '_' + psa.AssigneeId;
                                                      groupMemberToInsertMap.put(key,new GroupMember(GroupId = accountIdToGroupIdToAddUsersMap.get(psa.Assignee.AccountId), UserOrGroupId = psa.AssigneeId));
                                                      accountIdToGroupIdMap.put(psa.Assignee.AccountId, accountIdToGroupIdToAddUsersMap.get(psa.Assignee.AccountId));
                                                      userIdToAccountIdMap.put(psa.AssigneeId, psa.Assignee.AccountId);
                                                  }
                                           }
        
        if(groupMemberToInsertMap != null && !groupMemberToInsertMap.isEmpty()){
            Database.SaveResult[] srList = Database.insert(groupMemberToInsertMap.values(), false);
            //To add error messages from Save Result
            for(Database.SaveResult sr : srList){
                if(!sr.isSuccess()){
                    isError = true;
                    errorMsg += '<b>Error Details:</b> ' + sr.getErrors() + '\n';
                }
            }
            
            errorMsg = isError ? errorMsg + '\n\n <b>Error Occured in the following Account(s) and Group(s):<b> \n' : errorMsg;
            
            //Add error details from prepared Map and also add to Error Map
            for(String key : groupMemberToInsertMap.keySet()){
                if(groupMemberToInsertMap.get(key).Id == null){
                    Id userId = Id.valueOf(key.substringAfter('_'));
                    accountIdToGroupIdWithErrors.put(userIdToAccountIdMap.get(userId), accountIdToGroupIdMap.get(userIdToAccountIdMap.get(userId)));
                    errorMsg = isError ? errorMsg + '<b>Account Id:</b> ' + userIdToAccountIdMap.get(userId) + ' <b>Group Id:</b> ' + accountIdToGroupIdMap.get(userIdToAccountIdMap.get(userId)) + ' <b>User Id:</b> ' + userId + '\n' : '';
                }
            }
        }
        
        dmlDetails.message = errorMsg;
        dmlDetails.isError = isError;
        dmlDetails.accountIdToGroupId = accountIdToGroupIdWithErrors;
        return dmlDetails;
    }        
}