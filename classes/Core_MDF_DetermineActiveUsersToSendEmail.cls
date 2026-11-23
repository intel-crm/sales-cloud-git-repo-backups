/****************************************************************************************************************************************
* Class Name        : Core_MDF_DetermineActiveUsersToSendEmail
* Created Date      : 03/04/2025
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ayush                03/04/2025         Class to check if user is Active then send email through Core_MDF_GenericClassToSendMail class
*****************************************************************************************************************************************/
public without sharing class Core_MDF_DetermineActiveUsersToSendEmail {
    
    @InvocableMethod
    public static void sendEmailToActiveUsers(List<mailParams> paramsList){
        List<Core_MDF_GenericClassToSendMail.MailParams> settingMailParameters = new List<Core_MDF_GenericClassToSendMail.MailParams>();
        List<Id> userIdToNotifyList = new List<Id>();
    	List<Id> userIdParamsList = new List<Id>();
        Map<String,List<Id>> paramsToUserIdListMap = new Map<String,List<Id>>();
        Map<String,List<Id>> uniqueKeyToUserIdListMap = new Map<String,List<Id>>();
        system.debug('paramsList1'+paramsList);
        for(mailParams params : paramsList){
            userIdParamsList.addAll(params.userIdList);
            for(Id userId : params.userIdList){
                String key = '';
                key += params.recordId + params.templateName + params.sendDiff + params.userIdList;
                system.debug('@@key -> ' + key);
                if(!paramsToUserIdListMap.containsKey(key)){
                    paramsToUserIdListMap.put(key, new List<Id>());
                }
                paramsToUserIdListMap.get(key).add(userId);
                system.debug('@@paramsToUserIdListMapKey -> ' + paramsToUserIdListMap.keySet());
                system.debug('@@paramsToUserIdListMapValues -> ' + paramsToUserIdListMap.Values());
            }
        }
        
        if(!userIdParamsList.isEmpty()){
            for(User usrRecord : [SELECT Id, isActive, Partner_License_Reclaimed__c FROM User WHERE Id in: userIdParamsList AND (isActive = TRUE OR Partner_License_Reclaimed__c = TRUE)]){
                userIdToNotifyList.add(usrRecord.Id);
                
            }
        }
        
        for(String uniqueKey : paramsToUserIdListMap.keySet()){
            for(Id userId : paramsToUserIdListMap.get(uniqueKey)){
                if(userIdToNotifyList.contains(userId)){
                    uniqueKeyToUserIdListMap.put(uniqueKey, new list<Id> {userId});
                }
            }
        }
        system.debug('@@uniqueKeyToUserIdListMapValues -> ' + uniqueKeyToUserIdListMap.Values());
        
        if(!userIdToNotifyList.isEmpty()){
        	for(mailParams input : paramsList){
                String key = '';
                key += input.recordId + input.templateName + input.sendDiff + input.userIdList;

                Core_MDF_GenericClassToSendMail.MailParams params = new Core_MDF_GenericClassToSendMail.MailParams();
                params.userIdList = uniqueKeyToUserIdListMap.get(key);
                params.recordId = input.recordId;
                params.templateName = input.templateName;
                params.sendDiff = input.sendDiff;
                params.groupId = input.groupId;
                params.emailIds = input.emailIds;
                params.objectName = input.objectName;
                params.notificationName = input.notificationName;
                params.excludedUserIdList = input.excludedUserIdList;
                params.excludedUserEmailList = input.excludedUserEmailList;
                params.emailAttachment = input.emailAttachment;

                settingMailParameters.add(params);
            }
            system.debug('@@settingMailParameters -> ' + settingMailParameters);
            if(settingMailParameters != NULL && settingMailParameters.Size() > 0){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(settingMailParameters);
        	}
        }
    }
    
    /***************************************************************************************************** 
    Class Name    :        mailParams
    Description   :        contains all the invocable variables
    Added By      :        Ayush       03/04/2025
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public class MailParams{
        @InvocableVariable(label = 'GroupId')
        public String groupId;
        
        @InvocableVariable(label = 'UserIdList')
        public List<Id> userIdList = new List<Id>();
        
        @InvocableVariable(label = 'emailId')
        public String emailIds;
        
        @InvocableVariable(label = 'recordId')
        public Id recordId;
        
        @InvocableVariable(label = 'templateDeveloperName')
        public String templateName;
        
        @InvocableVariable(label = 'sendDiff')
        public Boolean sendDiff = TRUE;
        
        @InvocableVariable(label='emailAttachment')
        public Core_MDF_SendEmailAttachment[] emailAttachment;
    
        @InvocableVariable(label = 'objectName')
        public String objectName;
    
        @InvocableVariable(label = 'notificationName')
        public String notificationName;
    
        @InvocableVariable(label = 'excludedUserIdList')
        public List<Id> excludedUserIdList = new List<Id>();
    
        @InvocableVariable(label = 'excludedUserEmailList')
        public List<String> excludedUserEmailList = new List<String>();
        
    }
}