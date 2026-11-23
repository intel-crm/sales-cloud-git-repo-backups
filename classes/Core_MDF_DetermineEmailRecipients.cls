/****************************************************************************************************************************************
* Class Name        : Core_MDF_DetermineEmailRecipients
* Created Date      : 04/08/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       04/08/2020         Class to identify the email recipients 
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
        List<initialInputs> externalUserList = new List<initialInputs>();
        List<initialInputs> additionalUserList = new List<initialInputs>(); 
        
        try{
            for(initialInputs inputs : processInput){
                if(inputs.recipients == 'InternalUsers'){
                    internalUserList.add(inputs);
                }
                if(inputs.recipients == 'ExternalUsers'){
                    System.debug('inside first if');
                    externalUserList.add(inputs);
                }
                /*if(inputs.recipients == 'AdditionalUsers'){
                    additionalUserList.add(inputs);   
                }*/    
            }
            
            if(internalUserList != NULL && internalUserList.Size() > 0){
                toInternalUsers(internalUserList);
            }
            if(externalUserList != NULL && externalUserList.Size() > 0){
                toExternalUsers(externalUserList);
            }
            /*if(additionalUserList != NULL && additionalUserList.Size() > 0){
                toAdditionalUsers(additionalUserList);
            }*/
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    /***************************************************************************************************** 
    Method Name   :        toInternalUsers
    @return       :        void
    @parameters   :        List of initialInputs defined
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public static void toInternalUsers(List<initialInputs> internalUserList){
        
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
                        
                        if(recordIdGroupIdSetMap.containsKey(groupId)){
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
        
            if(groupIdSet != NULL){
                for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId 
                                      FROM GroupMember
                                      WHERE GroupId IN: groupIdSet]){
                    if(string.valueof(gm.UserOrGroupId).startsWith('005')){
                        for(Id recordId : recordIdGroupIdSetMap.keySet()){
                            if(recordIdGroupIdSetMap.get(recordId) != NULL && recordIdGroupIdSetMap.get(recordId).contains(gm.GroupId)){
                                userIdSet.add(gm.UserOrGroupId);
                                if(recordIdUserIdListMap.containsKey(recordId)){
                                    recordIdUserIdListMap.get(recordId).add(gm.UserOrGroupId);
                                }else{
                                    recordIdUserIdListMap.put(recordId,new List<Id>{gm.UserOrGroupId});
                                }
                            }
                        }
                    }
                }
            }
        
            if(permissionSetNameList != NULL && permissionSetNameList.Size() > 0){ 
                for(PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name,AssigneeId
                                                   FROM PermissionSetAssignment
                                                   WHERE AssigneeId IN: userIdSet AND
                                                    PermissionSet.Name IN: permissionSetNameList AND
                                                   Assignee.isActive = TRUE]){
                    userWithRequiredPermissionSet.add(psa.AssigneeId);              
                }
            }
        	
            List<Core_MDF_GenericClassToSendMail.MailParams> settingMailParameters = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            
            for(initialInputs input : internalUserList){
                Core_MDF_GenericClassToSendMail.MailParams params = new Core_MDF_GenericClassToSendMail.MailParams();
                
                if(recordIdUserIdListMap.containsKey(input.recordId) && recordIdUserIdListMap.get(input.recordId) != NULL){
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
                }
                
                if(params.userIdList != NULL && params.userIdList.Size() > 0){
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
    Method Name   :        toExternalUsers
    @return       :        void
    @parameters   :        List of initialInputs defined
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public static void toExternalUsers(List<initialInputs> externalUserList){
        
        Set<Id> accIdSet = new Set<Id>();
        List<String> permissionSetNameList = new List<String>();
        Map<Id,Set<Id>> accIdUserIdSetMap = new Map<Id,Set<Id>>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> userWithRequiredPermissionSet = new Set<Id>();
        
        try{
            for(initialInputs input : externalUserList){
                System.debug('input.accountId---' + input.accountId);
                if(input.accountId != NULL){
                    accIdSet.add(input.accountId);
                }
                
                if(input.permissionSetName != NULL){
                    permissionSetNameList.addAll(input.permissionSetName.split(';'));
                }
            }
        
            if(accIdSet != NULL && accIdSet.Size() > 0){
                for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c
                                                                  FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                  WHERE Core_MDF_Account__c IN: accIdSet AND
                                                                  Core_MDF_User__r.IsActive = TRUE]){
                    userIdSet.add(pnum.Core_MDF_User__c);
                    if(accIdUserIdSetMap.containsKey(pnum.Core_MDF_Account__c)){
                        accIdUserIdSetMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
                    }else{
                        accIdUserIdSetMap.put(pnum.Core_MDF_Account__c,new Set<Id>{pnum.Core_MDF_User__c});
                    }
                }
            }
                
            if(permissionSetNameList != NULL && permissionSetNameList.Size() > 0){
                for(PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name,AssigneeId
                                                   FROM PermissionSetAssignment
                                                   WHERE AssigneeId IN: userIdSet AND
                                                   PermissionSet.Name IN: permissionSetNameList]){
                    userWithRequiredPermissionSet.add(psa.AssigneeId);                                  
                }
            }
        
            List<Core_MDF_GenericClassToSendMail.MailParams> settingMailParameters = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            
            for(initialInputs input : externalUserList){
                Core_MDF_GenericClassToSendMail.MailParams params = new Core_MDF_GenericClassToSendMail.MailParams();
                
                if(accIdUserIdSetMap.containsKey(input.accountId) && accIdUserIdSetMap.get(input.accountId) != NULL){
                    if(input.permissionSetName != NULL){
                        for(Id userId : accIdUserIdSetMap.get(input.accountId)){
                            if(userWithRequiredPermissionSet.contains(userId)){
                                params.userIdList.add(userId);
                            }
                        }
                    }else{
                        params.userIdList.addAll(accIdUserIdSetMap.get(input.accountId));
                    }
                    
                    params.recordId = input.recordId;
                    params.sendDiff = input.sendDiff;
                    params.templateName = input.templateName;
                }
                    
                if(params.userIdList != NULL && params.userIdList.Size() > 0){
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
    Method Name   :        toAdditionalUsers
    @return       :        void
    @parameters   :        List of initialInputs defined
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/    
    /*public static void toAdditionalUsers(List<initialInputs> additionalUserList){
        
        Map<String, String> accNameEmailMap = new Map<String, String>();
        
        try{
            for(Core_MDF_Additional_Recipient__mdt mdt : [SELECT Id, Core_MDF_Account__c, Core_MDF_Email_Ids__c
                                                          FROM Core_MDF_Additional_Recipient__mdt]){
                accNameEmailMap.put(mdt.Core_MDF_Account__c,mdt.Core_MDF_Email_Ids__c);                                             
            }
            
            List<Core_MDF_GenericClassToSendMail.MailParams> settingMailParameters = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            
            for(initialInputs input : additionalUserList){
                Core_MDF_GenericClassToSendMail.MailParams params = new Core_MDF_GenericClassToSendMail.MailParams();
                
                if(input.accountName != NULL && accNameEmailMap.containsKey(input.accountName) && accNameEmailMap.get(input.accountName) != NULL){
                    params.emailIds = accNameEmailMap.get(input.accountName);
                }
                params.recordId = input.recordId;
                params.sendDiff = input.sendDiff;
                params.templateName = input.templateName;
                
                settingMailParameters.add(params);
            }
            
            if(settingMailParameters != NULL && settingMailParameters.Size() > 0){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(settingMailParameters);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }*/
    
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
    }
}