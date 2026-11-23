/****************************************************************************************************************************************
* Class Name        : Core_MDF_GenericClassToSendMail
* Created Date      : 04/08/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       04/08/2020         Class to send email based on inputs
*****************************************************************************************************************************************/
public class Core_MDF_GenericClassToSendMail {
    
    /***************************************************************************************************** 
    Method Name   :        sendEmailMethod
    @return       :        void
    @parameters   :        List of email parameters defined
    Description   :        Analyse the input parameters and send email
    Added By      :        Accenture - VD - 04/08/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/  	
    @InvocableMethod
    public static void sendEmailMethod(List<mailParams> paramsList){
        
        
        Set<String> templateNameSet = new Set<String>();
        Set<Id> groupIdSet = new Set<Id>();
        
        //Key:Template Name, Value:Template Id
        Map<String,Id> templateNameAndIdMap = new Map<String,Id>();  
        
        //Key:RecordId, Value:GroupId Set
        Map<Id,Set<Id>> recordIdGroupIdSetMap = new Map<Id,Set<Id>>();
        
        //Key:RecordId, Value:UserId List
        Map<Id,List<String>> recordIdUserIdListMap = new Map<Id,List<String>>();        
        
        try{
            for(mailParams params : paramsList){
                //Check if the input is groupId
                if(params.GroupId != NULL){
                    for(Id groupId : params.GroupId.Split(';')){
                        //Prepare set to query on groupMember
                        groupIdSet.add(groupId);
                        
                        if(recordIdGroupIdSetMap.containsKey(params.recordId)){
                            recordIdGroupIdSetMap.get(params.recordId).add(groupId);
                        }else{
                            recordIdGroupIdSetMap.put(params.recordId,new Set<Id>{groupId});
                        }
                    }
                }

                templateNameSet.add(params.templateName);
            }
            
            //Query on groupMembers
            //Tag the users to the record for which they would receive mail
            if(groupIdSet != NULL){
                for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId 
                                      FROM GroupMember
                                      WHERE GroupId IN: groupIdSet]){
                    if(string.valueof(gm.UserOrGroupId).startsWith('005')){
                        for(Id recordId : recordIdGroupIdSetMap.keySet()){
                            if(recordIdGroupIdSetMap.get(recordId) != NULL && recordIdGroupIdSetMap.get(recordId).contains(gm.GroupId)){
                                if(recordIdUserIdListMap.containsKey(recordId)){
                                    recordIdUserIdListMap.get(recordId).add(gm.UserOrGroupId);
                                }else{
                                    recordIdUserIdListMap.put(recordId,new List<String>{gm.UserOrGroupId});
                                }
                            }
                        }
                    }
                }
            }                      
            
            if(templateNameSet != NULL){
                for(EmailTemplate template : [SELECT Id, Name, DeveloperName 
                                              FROM EmailTemplate 
                                              WHERE DeveloperName IN: templateNameSet]){
                    templateNameAndIdMap.put(template.Name, template.Id);
                }
            }
            
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();   
            
            for(mailParams params : paramsList){
                Id templateId = templateNameAndIdMap.get(params.templateName);
                if(params.sendDiff){
                    if(recordIdUserIdListMap != NULL && recordIdUserIdListMap.Size() > 0 && 
                       recordIdUserIdListMap.containsKey(params.recordId) && recordIdUserIdListMap.get(params.recordId) != NULL){
                        for(String userId : recordIdUserIdListMap.get(params.recordId)){                            
                            emailsToSend.add(createEmailInstance(params.recordId, templateId, NULL, userId));
                        }
                    }
                    
                    if(params.userIdList != NULL){
                        for(Id userId : params.userIdList){
                            emailsToSend.add(createEmailInstance(params.recordId, templateId, NULL, userId));
                        }
                    }
                    
                    if(params.emailIds != NULL){
                        for(String emailId : params.emailIds.split(';')){
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                            String[] toAddresses = new String[] {emailId};
                            email.setToAddresses (toAddresses);
                            Id userId = UserInfo.getUserId();
                            email.targetObjectId = userId;
                            email.setTreatTargetObjectAsRecipient(false);
                            email.setWhatId(params.recordId);
                            email.setTemplateId(templateId);
                            email.setSaveAsActivity(false);
                            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                            emailsToSend.add(email);
                        }
                    }
                }else {
                    if(recordIdUserIdListMap != NULL && recordIdUserIdListMap.Size() > 0 &&
                       recordIdUserIdListMap.containsKey(params.recordId) && recordIdUserIdListMap.get(params.recordId) != NULL){
                        emailsToSend.add(createEmailInstance(params.recordId, templateId, 
                                                             recordIdUserIdListMap.get(params.recordId), 
                                                             recordIdUserIdListMap.get(params.recordId)[0]));
                    }
                    
                    if(params.userIdList != NULL && params.userIdList.Size() > 0){   
                        emailsToSend.add(createEmailInstance(params.recordId, templateId, 
                                                             params.userIdList, 
                                                             params.userIdList[0]));
                    }
                    
                    if(params.emailIds != NULL){ 
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                         
                        email.setToAddresses(params.emailIds.split(';'));
                        Id userId = UserInfo.getUserId();
                        email.targetObjectId = userId;
                        email.setTreatTargetObjectAsRecipient(false);
                        email.setWhatId(params.recordId);
                        email.setTemplateId(templateId);
                        email.setSaveAsActivity(false);
                        email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                        emailsToSend.add(email);
                    }
                }   
            }
            
            if(emailsToSend != NULL && emailsToSend.Size() > 0){
                Messaging.sendEmail(emailsToSend);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    /***************************************************************************************************** 
    Method Name   :        createEmailInstance
    @return       :        Messaging.SingleEmailMessage
    @parameters   :        Record Id, Template Id, List of UserId 
    Description   :        Creates and returns the Messaging.SingleEmailMessage instance based on input parameters
    Added By      :        Accenture - VD - 04/27/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public static Messaging.SingleEmailMessage createEmailInstance(Id recordId, Id templateId, List<String> userIdList, String setTargetObjectId){
        
        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            if(userIdList != NULL){
                email.setToAddresses(userIdList);
            }
            if(setTargetObjectId != NULL){
            	email.setTargetObjectId(setTargetObjectId);
            }
            email.setWhatId(recordId);
            email.setTemplateId(templateId);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
            return email;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);return NULL;} 
    }
    
    /***************************************************************************************************** 
    Class Name    :        mailParams
    Description   :        contains all the invocable variables
    Added By      :        Accenture - VD - 04/08/2020
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
    }
}