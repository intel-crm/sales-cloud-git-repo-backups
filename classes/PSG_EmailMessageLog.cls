/****************************************************************************************************
Apex Class Name : PSG_EmailMessageLog
Version         : 1.0 
Created Date    : 8/18/2023
Function        : This class is used for storing all the Emails that are triggering from Apex
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               8/18/2023                Created
*****************************************************************************************************/
public without sharing class PSG_EmailMessageLog {
    /************************************************************************************************************
    *Method Name : createEmailMessageRecord
    *Created Date: 08/18/2023
    *Author: Bishal Singh
    *Description : Performs Insertion operation on Email Message Object
    ************************************************************************************************************/
    public static void createEmailMessageRecord(Map<String, List<String>> relatedValues, String fromAddress, String fromName, List<String> toIds, List<String> toAddressList, List<String> ccAddressList, List<String> bccAddressList) {
        try{
            if (relatedValues.isEmpty()) {
                return;
            }
            List<EmailMessage> emailMessages = new List<EmailMessage>();
            for (Integer i = 0; i < relatedValues.get('relatedToId').size(); i++) {
                EmailMessage emailMessage = new EmailMessage();
                emailMessage.status = '3'; // email was sent
                emailMessage.relatedToId = relatedValues.get('relatedToId')[i];
                emailMessage.fromAddress = fromAddress;
                emailMessage.fromName = fromName;
                emailMessage.subject = relatedValues.get('subject')[i];
                emailMessage.htmlBody = relatedValues.get('htmlBody')[i];
                if (!toIds.isEmpty() && toIds != null) {
                    emailMessage.toIds = toIds;
                }
                emailMessage.toAddress = getEmailListFromList(toAddressList);
                emailMessage.CcAddress = getEmailListFromList(ccAddressList);
                emailMessage.BccAddress = getEmailListFromList(bccAddressList);
                emailMessages.add(emailMessage);
            }
            
            insert emailMessages;
            
        }catch(Exception e){
            PSG_Utility.createCoreLogEntry('PSG_EmailMessageLog','createEmailMessageRecord',e.getMessage(),'','EmailMessage','Low',relatedValues.get('relatedToId')[0]);
        }
    }
    
    private static String getEmailListFromList(List<String> addressList) {
        if (addressList == null || addressList.isEmpty()) {
            return '';
        }
        return String.join(addressList, ',');
    }
    
    
    
    /*
    @InvocableMethod(label ='createEmailMessageRecordForFlow')
    public static void callEmailMessageFromFlow(List<List<String>> record){
        createEmailMessageRecordForFlow(record[0]);
    }

    /************************************************************************************************************
    *Method Name : createEmailMessageRecordForFlow
    *Created Date: 08/18/2023
    *Author: Bishal Singh
    *Description : Performs Insertion operation on Email Message Object from Email Alerts
    ************************************************************************************************************/
    /*
    @Future(callout=true)
    public static void createEmailMessageRecordForFlow(List<String> recordDetails) {
        try{
            if (recordDetails.size() < 2 || String.isBlank(recordDetails[0])) {
                return;
            }
            String developerName = recordDetails[1];
            String recordId = recordDetails[0];
            String objectName = '';
            if(recordDetails.size()==3){
                objectName = recordDetails[2];
            }
            
            String endPoint = '/services/data/v47.0/tooling/query/?q=select+id,SenderType,templateId+from+WorkflowAlert+where+DeveloperName=\''+developerName+'\'';        
            //String endPoint = '/services/data/v47.0/tooling/query/?q=select+id,SenderType,templateId+from+WorkflowAlert+where+DeveloperName=\'PSG_Notify_Disty_on_Request_of_a_DPA\'';        
            
            List<String> workflowEmailAlertIds= new List<String>();
            String response= performToolingRequest(endPoint);
            System.debug('response:: ' + response);
            System.JSONParser parser = JSON.createParser(response);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'Id') {
                        workflowEmailAlertIds.add(parser.getText());
                    }
                }
            }
            
            if(workflowEmailAlertIds.size() == 1){
                for(String str:workflowEmailAlertIds){
                    endPoint = '/services/data/v41.0/tooling/sobjects/WorkflowAlert/'+str;
                    response = performToolingRequest(endPoint);
                    System.debug('response:: ' + response);
                    response = response.replace('type', 'type_z');
                    response = response.replace('protected','protected_z');
                    response = response.replaceAll(',\r\n','\r\n');
                }
                System.debug('response:: ' + response);
                
                PSG_EmailMessageLogWrapper wrapper = PSG_EmailMessageLogWrapper.parse(response);
                
                List<String> toUserRecipient = getRecipientList(wrapper.Metadata,objectName,recordId);
                
                EmailTemplate template = [SELECT Id, Subject, HtmlValue, Markup, DeveloperName, Body FROM EmailTemplate WHERE Id = :wrapper.TemplateId];
                Messaging.SingleEmailMessage getEmail = Messaging.renderStoredEmailTemplate(template.Id, null, recordId);
                Map<String, List<String>> relatedValues = new Map<String, List<String>>();
                relatedValues.put('relatedToId', new List<String>{recordId});
                relatedValues.put('subject', new List<String>{getEmail.getSubject()});
                relatedValues.put('htmlBody', new List<String>{getEmail.getHtmlBody()});
                
                List<String> ccEmails = wrapper.Metadata.ccEmails;
                    PSG_EmailMessageLog.createEmailMessageRecord(
                        relatedValues,
                        wrapper.Metadata.senderAddress,
                        'Intel Corporation-NoReply',
                        new String[]{},
                        toUserRecipient,
                        ccEmails,
                        null
                    );
            }
        }catch(Exception e){
            //PSG_Utility.createCoreLogEntry('PSG_EmailMessageLog','callEmailMessageFromFlow',e.getMessage(),'','EmailMessage','Low',recordDetails[0]);
        }
    }
    
    private static String performToolingRequest(String endPoint){
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        request.setHeader('Content-Type', 'application/XML');
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + endPoint);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);        
        return response.getBody();
    }
    
    private static List<String> getRecipientList(PSG_EmailMessageLogWrapper.Metadata metadata, String objectName , String recordId){
        Set<String> recipientUsernames = new Set<String>();
        Set<String> fieldsToQuery = new Set<String>();
        Boolean queryOwner = false;
        
        for (PSG_EmailMessageLogWrapper.Recipients recipient : metadata.recipients) {
            recipientUsernames.add(recipient.recipient + '%');
            if (recipient.field != null) {
                fieldsToQuery.add(recipient.field.replace('__c', '__r') + '.Email');
            }
            if(recipient.type_z != null && recipient.type_z == 'Owner') {
                queryOwner = true;
                fieldsToQuery.add('OwnerId');
                fieldsToQuery.add('Owner.Type');
                fieldsToQuery.add('Owner.Email');
            }
        }
        
        Set<String> toUserRecipient = new Set<String>();
        if(!Test.isRunningTest()){
            List<User> users = [SELECT Email FROM User WHERE Username LIKE :recipientUsernames];
            for (User user : users) {
                toUserRecipient.add(user.Email);
            }
        }
        
        
        if ((!fieldsToQuery.isEmpty() || queryOwner) && (objectName !='' || objectName != null)) {
            String fields = String.join(new List<String>(fieldsToQuery), ',');
            String query = 'SELECT ' + fields + ' FROM ' + objectName + ' WHERE Id = \'' + recordId + '\' LIMIT 1';            
            sObject sobj = Database.query(query);
            for (String field : fieldsToQuery) {
                field = field.replace('.Email', '');
                if(field == 'Owner.Type' || field == 'Owner.Email' || field == 'OwnerId'){
                    fieldsToQuery.remove(field);
                }else{
                    SObject relatedObj = sobj.getSObject(field);
                    if (relatedObj != null) {
                        toUserRecipient.add((String)relatedObj.get('Email'));
                    }
                }
            }
            
            if (queryOwner) {
                SObject owner = sobj.getSObject('Owner');
                if (owner != null && owner.get('Type') != 'Group' && owner.get('Type') != 'Queue') {
                    toUserRecipient.add((String)owner.get('Email'));
                }else if(owner != null && (owner.get('Type') == 'Group' || owner.get('Type') == 'Queue')){
                    Set<String> groupId = new Set<String>();
                    groupId.add((String)sobj.get('OwnerId'));
                    Set<String> getGroupMembers = new Set<String>();
                    getGroupMembers = (getGroupMember(groupId));
                    List<User> groupUsers = [SELECT Email FROM User WHERE Id =:getGroupMembers];
                    for (User user : groupUsers) {
                        toUserRecipient.add(user.Email);
                    }
                }else if(Test.isRunningTest()){
                    Set<String> groupId = new Set<String>();
                    groupId.add((String)sobj.get('OwnerId'));
                    Set<String> getGroupMembers = new Set<String>();
                    getGroupMembers = (getGroupMember(groupId));
                    List<User> groupUsers = [SELECT Email FROM User WHERE Id =:getGroupMembers];
                    for (User user : groupUsers) {
                        toUserRecipient.add(user.Email);
                    }   
                }
            }
        }
        
        return (new List<String>(toUserRecipient));
    }
    
    private static Set<String> getGroupMember(Set<String> groupIdSet) {
        Set<String> userIdSet = new Set<String>();
        Set<String> innerGroupIdSet = new Set<String>();
        
        List<GroupMember> groupMembers = [
            SELECT Id, UserOrGroupId
            FROM GroupMember
            WHERE UserOrGroupId IN :groupIdSet
            OR GroupId IN :groupIdSet
        ];
        
        for (GroupMember member : groupMembers) {
            String userOrGroupId = member.UserOrGroupId;
            if (userOrGroupId.startsWith('005')) {
                userIdSet.add(userOrGroupId);
            } else if (!groupIdSet.contains(userOrGroupId)) {
                innerGroupIdSet.add(userOrGroupId);
            }
        }
        
        if (!innerGroupIdSet.isEmpty()) {
            userIdSet.addAll(getGroupMember(innerGroupIdSet));
        }
        
        return userIdSet;
    }
	*/
}