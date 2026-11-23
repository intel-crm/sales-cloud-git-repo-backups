/****************************************************************************************************************************************
* Class Name        : Core_MDF_DetermineEmailRecipients
* Created Date      : 04/08/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       04/08/2020         Class to identify the email recipients 
* Ayush                12/18/2024         Added changes for "Reclaiming SF Partner License"
*****************************************************************************************************************************************/
public without sharing class Core_MDF_DetermineEmailRecipients {
    
    /***************************************************************************************************** 
    Method Name   :        determineRecipients
    @return       :        void
    @parameters   :        List of initialInputs defined
    Description   :        Analyse the input parameters and call respective methods
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    @InvocableMethod
    public static void determineRecipients(List<initialInputs> processInput){
        
        List<initialInputs> internalUserList = new List<initialInputs>();
        List<initialInputs> internalIUPGMUserList = new List<initialInputs>();
        List<initialInputs> externalUserList = new List<initialInputs>();
        List<initialInputs> additionalUserList = new List<initialInputs>(); 
        List<initialInputs> externalUserwithGroupIdList = new List<initialInputs>();

        Map<String, List<initialInputs>> categoryToInputs = new Map<String, List<initialInputs>>();

        system.debug('processinput@@@' + processInput);

        try{
            for(initialInputs inputs : processInput){
                if(inputs.recipients == 'InternalUsers'){
                    system.debug('insideInternalUsers@@@@');
                    if(inputs.groupId != NULL && inputs.groupId != ''){
                        internalUserList.add(inputs);
                    } else {
                        //internalIUPGMUserList.add(inputs);

                        String category = String.isBlank(inputs.category) ? null : inputs.category;
                        if (!categoryToInputs.containsKey(category)) {
                            categoryToInputs.put(category, new List<initialInputs>());
                        }
                        categoryToInputs.get(category).add(inputs);
                    }
                }
                system.debug('@@internalUserList@@@@'+internalUserList);
                if(inputs.recipients == 'ExternalUsers'){
                    if(inputs.groupId != NULL && inputs.groupId != ''){
                        externalUserwithGroupIdList.add(inputs);
                    }else{
                        externalUserList.add(inputs);
                    }
                }
            }
            
            if (!categoryToInputs.isEmpty()) {
                internalIUPGMUserList.addAll(categoryToInputs.values()[0]);
            }
            system.debug('internalIUPGMUserList@@@' + internalIUPGMUserList);

            if(internalUserList != NULL && internalUserList.Size() > 0){
                toGroupIdUsers(internalUserList);
            }
            if(!internalIUPGMUserList.isEmpty()){
                toInternalIUPGMUsers(internalIUPGMUserList);
            }
            if(externalUserList != NULL && externalUserList.Size() > 0){
                toExternalUsers(externalUserList);
            }
            if(externalUserwithGroupIdList!=null && externalUserwithGroupIdList.size()>0){
                toGroupIdUsers(externalUserwithGroupIdList);
            }
           
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    /***************************************************************************************************** 
    Method Name   :        toInternalIUPGMUsers
    @return       :        void
    @parameters   :        List of initialInputs defined
    Added By      :        Saikat - 27/07/2022
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    
    public static void toInternalIUPGMUsers(List<initialInputs> internalUserList){
        
        List<Core_MDF_GenericClassToSendMail.MailParams> settingMailParameters = new List<Core_MDF_GenericClassToSendMail.MailParams>();
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        List<String> permissionSetNameList = new List<String>();
        Set<Id> userIdSet = new Set<Id>();
        List<String> geoList = new List<String>();
        List<String> accntList = new List<String>();
        List<String> programList = new List<String>();
        List<String> approvalStageList = new List<String>();

        system.debug('internalUserList@@@' + internalUserList);
        String category = '';
        
        try{
            for(initialInputs inputs : internalUserList){
                if(inputs.permissionSetName != NULL){
                    permissionSetNameList.addAll(inputs.permissionSetName.Split(';'));
                }
                if(String.isNotEmpty(inputs.recordId)){
                    accntList.add(inputs.ultimateAccountId);
                    programList.add(inputs.programName);
                    geoList.add(inputs.region);
                }
                if(inputs.category != NULL){
                    category = inputs.category;
                }
            }

            resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsForApprovers(accntList, programList, geoList, permissionSetNameList, category);
            //resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsForApprovers(accntList, programList, geoList, permissionSetNameList);

            system.debug('resultMap@@@' + resultMap);  //Intel Partner AllianceASMOCore_MDF_CCP_Internal_IPA_Acct_Mgr001g000002gkDgAAAU = 005g0000007uPAiAAM


            // Core_MDF_CCP_Internal_Co_GTM_Business_Approver={
            //     CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001Dz00002jGn0PIAS=(005Dz000009dKDbIAM), 
            //     CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001Dz00002jGnooIAC=(005Dz000009dKDbIAM), 
            //     CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001g000002CANf4AAH=(005Dz000009dKDbIAM), 
            //     CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001g000002gkDgAAAU=(005Dz000009eZIUIA2, 005Dz000009dKDbIAM)
            // }
            
            for(initialInputs input : internalUserList){

                String role = System.Label.Core_MDF_CCP_Internal_IPA_Acct_Mgr_PS;
                if (input.programName == 'CoGTM') {
                    role = input.permissionSetName;
                }

                Map<string, List<Id>> resultsubMap;
                List<Id> userIds;
                //ATHR - Deeply Nested if 16209
                if(resultMap == null) {
                    continue;
                }
                //if(resultMap != null){

                    String allAccountNOKey = input.programName + input.region + role + input.ultimateAccountId;
                    String allAccountNOKeyWW = input.programName + 'WW' + role + input.ultimateAccountId;
                    String allAccountYesKey = input.programName + input.region + role + 'null';
                    String allAccountYesKeyWW = input.programName + 'WW' + role + 'null';

                    system.debug('allAccountNOKey@@@' + allAccountNOKey);  // CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001g000002gkDgAAAU
                    system.debug('allAccountNOKeyWW@@@' + allAccountNOKeyWW);  // CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001g000002gkDgAAAU
                    system.debug('allAccountYesKey@@@' + allAccountYesKey);  // CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approvernull
                    system.debug('allAccountYesKeyWW@@@' + allAccountYesKeyWW);  // CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approvernull
                    
                    userIds = new List<Id>();
                    if(resultMap.containsKey(role)){
                        resultsubMap = resultMap.get(role);  
                        system.debug('resultsubMap@@@' + resultsubMap);

                    // CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001Dz00002jGn0PIAS=(005Dz000009dKDbIAM)
                    // CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001Dz00002jGnooIAC=(005Dz000009dKDbIAM)
                    // CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001g000002CANf4AAH=(005Dz000009dKDbIAM)
                    // CoGTMWWCore_MDF_CCP_Internal_Co_GTM_Business_Approver001g000002gkDgAAAU=(005Dz000009eZIUIA2, 005Dz000009dKDbIAM)

                        for(String key :resultsubMap.keySet()){
                            if(key == allAccountNOKey || key == allAccountNOKeyWW ||
                               key == allAccountYesKey || key == allAccountYesKeyWW){
                                   userIds.addAll(resultsubMap.get(key));
                               }
                        }

                        system.debug('userIds@@@' + userIds);  //(005Dz000009eZIUIA2, 005Dz000009dKDbIAM)
                    } 
                //}

                if(userIds != NULL && !userIds.isEmpty()){

                    if (input.programName == 'CoGTM' && input.userIdList != null && !input.userIdList.isEmpty()) {
                    List<Id> finalRecipient = new List<Id>();
                        for (Id uid : userIds) {
                            if (input.userIdList.contains(uid)) {
                                finalRecipient.add(uid);
                            }
                        }
                        userIds = finalRecipient;
                    }

                    system.debug('userIds@@@' + userIds);  //(005Dz000009eZIUIA2, 005Dz000009dKDbIAM)
                    Core_MDF_GenericClassToSendMail.MailParams params = new Core_MDF_GenericClassToSendMail.MailParams();
                    params.recordId = input.recordId;
                    params.templateName = input.templateName;
                    params.userIdList = userIds;
                    params.sendDiff = input.sendDiff;

                    //Roshan - Notfiy CoGTM Business Approvers
                    params.objectName = input.objectName;
                    params.notificationName = input.notificationName;

                    settingMailParameters.add(params);
                }
            }
           
            if(settingMailParameters != NULL && settingMailParameters.Size() > 0){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(settingMailParameters);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
        
    /***************************************************************************************************** 
    Method Name   :        toGroupIdUsers
    @return       :        void
    @parameters   :        List of initialInputs defined
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public static void toGroupIdUsers(List<initialInputs> internalUserList){
        Set<Id> groupIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        List<String> permissionSetNameList = new List<String>();
        Map<Id,Set<Id>> recordIdGroupIdSetMap = new Map<Id,Set<Id>>();
        Map<Id,List<Id>> recordIdUserIdListMap = new Map<Id,List<Id>>();
        Set<Id> userWithRequiredPermissionSet = new Set<Id>();
        
        try{
            for(initialInputs inputs : internalUserList){
                if(String.isNotEmpty(inputs.GroupId)){
                    for(Id groupId : inputs.GroupId.Split(';')){
                        groupIdSet.add(groupId);
                        
                        if(recordIdGroupIdSetMap.containsKey(inputs.recordId)){
                            recordIdGroupIdSetMap.get(inputs.recordId).add(groupId);
                        }else{
                            recordIdGroupIdSetMap.put(inputs.recordId,new Set<Id>{groupId});
                        }
                    }
                }
                if(inputs.permissionSetName != NULL){
                    permissionSetNameList.addAll(inputs.permissionSetName.Split(';'));
                }
            }
            
            system.debug('groupIdSet@@@' + groupIdSet);
            //Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
            if(groupIdSet != NULL){
                for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId 
                                      FROM GroupMember
                                      WHERE GroupId IN: groupIdSet AND (UserOrGroup.isActive = true OR UserOrGroup.Partner_License_Reclaimed__c = true)]){
                    //ATHR - Deeply Nested if 16209
                    if (!String.valueOf(gm.UserOrGroupId).startsWith('005')) continue;
                    //if(string.valueof(gm.UserOrGroupId).startsWith('005')){
                        for(Id recordId : recordIdGroupIdSetMap.keySet()){
                            //ATHR - Deeply Nested if 16209
                            if(recordIdGroupIdSetMap.get(recordId) == null || !recordIdGroupIdSetMap.get(recordId).contains(gm.GroupId)){
                                continue;
                            }
                            //if(recordIdGroupIdSetMap.get(recordId) != NULL && recordIdGroupIdSetMap.get(recordId).contains(gm.GroupId)){
                                userIdSet.add(gm.UserOrGroupId);
                                if(recordIdUserIdListMap.containsKey(recordId)){
                                    recordIdUserIdListMap.get(recordId).add(gm.UserOrGroupId);
                                }else{
                                    recordIdUserIdListMap.put(recordId,new List<Id>{gm.UserOrGroupId});
                                }
                            //}
                        }
                    //}
                }
            }
            system.debug('userIdSet@@@' + userIdSet);
            system.debug('recordIdUserIdListMap@@@' + recordIdUserIdListMap);
            system.debug('permissionSetNameList@@@' + permissionSetNameList);
        
            //Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
            if(permissionSetNameList != NULL && permissionSetNameList.Size() > 0){ 
                for(PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name,AssigneeId
                                                   FROM PermissionSetAssignment
                                                   WHERE AssigneeId IN: userIdSet AND
                                                   PermissionSet.Name IN: permissionSetNameList AND
                                                   (Assignee.isActive = TRUE OR Assignee.Partner_License_Reclaimed__c = TRUE)]){
                    userWithRequiredPermissionSet.add(psa.AssigneeId);              
                }
            }
            system.debug('userWithRequiredPermissionSet@@@' + userWithRequiredPermissionSet);

            List<Core_MDF_GenericClassToSendMail.MailParams> settingMailParameters = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            
            for(initialInputs input : internalUserList){
                Core_MDF_GenericClassToSendMail.MailParams params = new Core_MDF_GenericClassToSendMail.MailParams();
                //ATHR - Deeply Nested if 16209
                if(!recordIdUserIdListMap.containsKey(input.recordId) || recordIdUserIdListMap.get(input.recordId) == NULL){
                    continue;
                }
                //if(recordIdUserIdListMap.containsKey(input.recordId) && recordIdUserIdListMap.get(input.recordId) != NULL){
                    if(input.permissionSetName != NULL){
                        for(Id userId : recordIdUserIdListMap.get(input.recordId)){
                            if(userWithRequiredPermissionSet.contains(userId)){
                                params.userIdList.add(userId);
                            }
                        }
                    }else {
                        params.userIdList.addAll(recordIdUserIdListMap.get(input.recordId));
                    }
                    params.recordId = input.recordId;
                    params.sendDiff = input.sendDiff;
                    params.templateName = input.templateName;
                //}                
                if(params.userIdList != NULL && params.userIdList.Size() > 0){
                    settingMailParameters.add(params);
                }
            }

            system.debug('settingMailParameters@@@' + settingMailParameters);
           
            if(settingMailParameters != NULL && settingMailParameters.Size() > 0){
                
                Core_MDF_GenericClassToSendMail.sendEmailMethod(settingMailParameters);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    /***************************************************************************************************** 
    Method Name   :        toExternalUsers
    @return       :        void
    @parameters   :        List of initialInputs defined
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:           Changes: 
    Ayush                  12/18/2024      Added changes for "Reclaiming SF Partner License"
    ******************************************************************************************************/
    public static void toExternalUsers(List<initialInputs> externalUserList){
        
        Set<Id> accIdSet = new Set<Id>();
        List<String> permissionSetNameList = new List<String>();
        Map<Id,Set<Id>> accIdUserIdSetMap = new Map<Id,Set<Id>>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> userWithRequiredPermissionSet = new Set<Id>();
        
        try{
            system.debug('externalUserList@@@' + externalUserList);
            for(initialInputs input : externalUserList){
                if(input.accountId != NULL){
                    accIdSet.add(input.accountId);
                }
                
                if(input.permissionSetName != NULL){
                    permissionSetNameList.addAll(input.permissionSetName.split(';'));
                }
            }
        
            if(accIdSet != NULL && accIdSet.Size() > 0){
                //Ayush - Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
                for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c
                                                                  FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                  WHERE Core_MDF_Account__c IN: accIdSet AND
                                                                  (Core_MDF_User__r.IsActive = TRUE  OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE) AND
                                                                  Core_MDF_Active_Ind__c = TRUE]){
                                                                    system.debug('pnum@@@' + pnum);
                    userIdSet.add(pnum.Core_MDF_User__c);
                    if(accIdUserIdSetMap.containsKey(pnum.Core_MDF_Account__c)){
                        accIdUserIdSetMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
                    }else{
                        accIdUserIdSetMap.put(pnum.Core_MDF_Account__c,new Set<Id>{pnum.Core_MDF_User__c});
                    }
                }
            }
            system.debug('accIdUserIdSetMap@@@' + accIdUserIdSetMap);
                
            if(permissionSetNameList != NULL && permissionSetNameList.Size() > 0){
                for(PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name,AssigneeId
                                                   FROM PermissionSetAssignment
                                                   WHERE AssigneeId IN: userIdSet AND
                                                   PermissionSet.Name IN: permissionSetNameList]){
                    userWithRequiredPermissionSet.add(psa.AssigneeId);                                  
                }
            }
            system.debug('userWithRequiredPermissionSet@@@' + userWithRequiredPermissionSet);
        
            List<Core_MDF_GenericClassToSendMail.MailParams> settingMailParameters = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            
            for(initialInputs input : externalUserList){
                Core_MDF_GenericClassToSendMail.MailParams params = new Core_MDF_GenericClassToSendMail.MailParams();
                //ATHR - Deeply Nested if 16209
                if(!accIdUserIdSetMap.containsKey(input.accountId) || accIdUserIdSetMap.get(input.accountId) == NULL){
                    continue;
                }
                //if(accIdUserIdSetMap.containsKey(input.accountId) && accIdUserIdSetMap.get(input.accountId) != NULL){
                    if(input.permissionSetName != NULL){
                        for(Id userId : accIdUserIdSetMap.get(input.accountId)){
                            if(userWithRequiredPermissionSet.contains(userId)){
                                params.userIdList.add(userId);
                                system.debug('paramsUserIdList@@@' + params.userIdList);
                            }
                        }
                    }else{
                        params.userIdList.addAll(accIdUserIdSetMap.get(input.accountId));
                        system.debug('paramsUserIdList2@@@' + params.userIdList);
                    }
                    
                    params.recordId = input.recordId;
                    params.sendDiff = input.sendDiff;
                    params.templateName = input.templateName;
                //}
                   
                if(params.userIdList != NULL && params.userIdList.Size() > 0){
                    settingMailParameters.add(params);
                }
                system.debug('settingMailParameters1@@@' + settingMailParameters);
            }   
            system.debug('settingMailParameters2@@@' + settingMailParameters);        
            if(settingMailParameters != NULL && settingMailParameters.Size() > 0){
               
                Core_MDF_GenericClassToSendMail.sendEmailMethod(settingMailParameters);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
        
    
    
    /***************************************************************************************************** 
    Class Name    :        initialInputs
    Description   :        contains all the invocable variables
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public class InitialInputs{
        @InvocableVariable(label = 'GroupId')
        public String groupId;
        
        @InvocableVariable(label = 'UserIdList')
        public List<Id> userIdList;
        
        @InvocableVariable(label = 'recordId' required = true)
        public Id recordId;
        
        @InvocableVariable(label = 'PermissionSet')
        public String permissionSetName;
        
        @InvocableVariable(label = 'templateDeveloperName' required = true)
        public String templateName;
        
        @InvocableVariable(label = 'sendDiff')
        public Boolean sendDiff = TRUE;
        
        @InvocableVariable(label = 'accountId')
        public Id accountId;
        
        @InvocableVariable(label = 'accountName')
        public String accountName;
        
        @InvocableVariable(label = 'Recipients')
        public string recipients;   
        
        @InvocableVariable(label = 'UltimateAccountId')
        public string ultimateAccountId;
        
        @InvocableVariable(label = 'ProgramName')
        public string programName;
        
        @InvocableVariable(label = 'Region')
        public string region;

        @InvocableVariable(label = 'Category')
        public String category;

        //Roshan - Notfiy CoGTM Business Approvers
        @InvocableVariable(label = 'objectName')
        public String objectName;

        @InvocableVariable(label = 'notificationName')
        public String notificationName;
    }
}