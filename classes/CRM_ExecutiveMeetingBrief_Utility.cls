public class CRM_ExecutiveMeetingBrief_Utility {
     public static String fromEmailAddress = System.Label.Core_SetFromEmailAddress;//Organization-Wide Email Address
@AuraEnabled
public static String checkMandatoryFields(Id recordId){
    try {
        CRM_EMB_Required_Fields__mdt metadata = [SELECT Required_Fields__c FROM CRM_EMB_Required_Fields__mdt WHERE DeveloperName = 'CRM_EMB_Mandatory_Fields' LIMIT 1];
        
        // Split the required fields
        List<String> requiredFields = metadata.Required_Fields__c.split(',');
        
        // Get field describe information for labels
        Schema.SObjectType objType = Executive_Meeting_Brief__c.SObjectType;
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        // Build dynamic query
        String query = 'SELECT Id';
        for (String field : requiredFields) {
            query += ', ' + field.trim();
        }
        query += ' FROM Executive_Meeting_Brief__c WHERE Id = :recordId LIMIT 1';
        
        // Execute query
        List<Executive_Meeting_Brief__c> records = Database.query(query);
        
        Executive_Meeting_Brief__c record = records[0];
        List<String> missingFields = new List<String>();
        
        for (String fieldName : requiredFields) {
            String field = fieldName.trim();
            Object fieldValue = record.get(field);
            if (fieldValue == null || String.isBlank(String.valueOf(fieldValue))) {
                // Get field label
                Schema.SObjectField fieldToken = fieldMap.get(field);
                Schema.DescribeFieldResult fieldDescribe = fieldToken.getDescribe();
                missingFields.add(fieldDescribe.getLabel());
            }
        } 
        
        // Return result
        if (missingFields.isEmpty()) {
            return 'SUCCESS';
        } else {
            return 'Missing required fields: ' + String.join(missingFields, ', ');
        }
    }
    catch (Exception e) {
        return 'ERROR: ' + e.getMessage();
    }
}
    public static void createSharingRecords(List<Executive_Meeting_Brief__c> newRecords, Map<Id, Executive_Meeting_Brief__c> oldMap) {
        List<Executive_Meeting_Brief__Share> sharesToInsert = new List<Executive_Meeting_Brief__Share>();
        List<Executive_Meeting_Brief__Share> sharesToDelete = new List<Executive_Meeting_Brief__Share>();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> usersToRemove = new Set<Id>();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        
        // Collect record IDs and users to remove sharing for
        for(Executive_Meeting_Brief__c newRecord : newRecords) {
            Executive_Meeting_Brief__c oldRecord = oldMap.get(newRecord.Id);
            recordIds.add(newRecord.Id);
            
            // Check if CRM_TA__c changed
            if(newRecord.CRM_Technical_Assistant__c != oldRecord.CRM_Technical_Assistant__c) {
                if(oldRecord.CRM_Technical_Assistant__c != null && oldRecord.CRM_Technical_Assistant__c!=newRecord.CRM_Brief_Reviewer__c) {
                    usersToRemove.add(oldRecord.CRM_Technical_Assistant__c);
                }
            }
            
            // Check if CRM_Brief_Reviewer__c changed
            if(newRecord.CRM_Brief_Reviewer__c != oldRecord.CRM_Brief_Reviewer__c && oldRecord.CRM_Brief_Reviewer__c!=newRecord.CRM_Technical_Assistant__c) {
                if(oldRecord.CRM_Brief_Reviewer__c != null) {
                    usersToRemove.add(oldRecord.CRM_Brief_Reviewer__c);
                }
            }
        }
        
        // Query existing sharing records to delete
        if(!usersToRemove.isEmpty() && !recordIds.isEmpty()) {
            List<Executive_Meeting_Brief__Share> existingShares = [SELECT Id, ParentId, UserOrGroupId FROM Executive_Meeting_Brief__Share WHERE ParentId IN :recordIds 
                AND UserOrGroupId IN :usersToRemove AND RowCause = 'Manual'];
            sharesToDelete.addAll(existingShares);
        }
        
        // Create new sharing records
        for(Executive_Meeting_Brief__c newRecord : newRecords) {
            Executive_Meeting_Brief__c oldRecord = oldMap.get(newRecord.Id);
            
            // Create sharing for new CRM_TA__c
            if(newRecord.CRM_Technical_Assistant__c != oldRecord.CRM_Technical_Assistant__c && newRecord.CRM_Technical_Assistant__c != null) {
                Executive_Meeting_Brief__Share newShare = new Executive_Meeting_Brief__Share();
                newShare.ParentId = newRecord.Id;
                newShare.UserOrGroupId = newRecord.CRM_Technical_Assistant__c;
                newShare.AccessLevel = 'Edit'; 
                newShare.RowCause = 'Manual';
                sharesToInsert.add(newShare);
            }
            
            // Create sharing for new CRM_Brief_Reviewer__c
            if(newRecord.CRM_Brief_Reviewer__c != oldRecord.CRM_Brief_Reviewer__c && newRecord.CRM_Brief_Reviewer__c != null) {
                Executive_Meeting_Brief__Share newShare = new Executive_Meeting_Brief__Share();
                newShare.ParentId = newRecord.Id;
                newShare.UserOrGroupId = newRecord.CRM_Brief_Reviewer__c;
                newShare.AccessLevel = 'Edit'; 
                newShare.RowCause = 'Manual';
                sharesToInsert.add(newShare);
            }
        }
        
        // Perform DML operations
        try {
            if(!sharesToDelete.isEmpty()) {
                delete sharesToDelete;
            }
            
            if(!sharesToInsert.isEmpty()) {
                insert sharesToInsert;
            }
        } catch(Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = e.getMessage(), Core_Origin__c='CRM_ExecutiveMeetingBrief_Utility.createSharingRecords', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));          
    		insert logEntries;
        }
    }
    @InvocableMethod(label='Send Email to Brief Requestor' description='Send Email to Brief Requestor in EMB Flow')
    public static List<EmailResult> sendEmailFromTemplate(List<EmailRequest> requests) {  
        List<EmailResult> results = new List<EmailResult>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        try {
        // Get ContentDocumentLink - fixed the isEmpty() check
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocument.Title,ContentDocument.LatestPublishedVersion.FileExtension, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :requests[0].whatId AND ContentDocument.Title LIKE '%Briefing for%' AND ContentDocument.LatestPublishedVersion.FileExtension='pdf' limit 1];
        
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<Id> attachmentIds = new List<Id>();
        
        if (!cdlList.isEmpty()) {
            contentVersions = [SELECT Id, Title, VersionData, FileType, ContentDocumentId, VersionNumber FROM ContentVersion WHERE ContentDocumentId = :cdlList[0].ContentDocumentId AND IsLatest = true ];
            
            // Extract ContentVersion IDs for attachments
         	for (ContentVersion cv : contentVersions) {
                attachmentIds.add(cv.Id);
            }
        }
            for (EmailRequest request : requests) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String> {request.emailAddress});
                mail.setTemplateId(request.emailTemplateId);
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setWhatId(request.whatId);
                mail.setSaveAsActivity(false);
                mail.setOrgWideEmailAddressId(fromEmailAddress);
                // Directly set attachment ID
                if (attachmentIds != null && !attachmentIds.isEmpty()) {
                    mail.setEntityAttachments(attachmentIds);
                }
                mails.add(mail);
            }
            system.debug('MAILS:'+mails);
            // Send emails
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(mails);
            
            // Process results
            for (Integer i = 0; i < sendResults.size(); i++) {
                EmailResult result = new EmailResult();
                result.success = sendResults[i].isSuccess();
                if (!result.success) {
                    List<String> errorMessages = new List<String>();
                    for (Messaging.SendEmailError error : sendResults[i].getErrors()) {
                        errorMessages.add(error.getMessage());
                    }
                    result.errorMessage = String.join(errorMessages, '; ');
                }
                results.add(result);
            }
        }
            
       catch (Exception exp) {
            // Return error result for exception
            EmailResult errorResult = new EmailResult();
            errorResult.success = false;
            errorResult.errorMessage = exp.getMessage();
            results.add(errorResult);
        }
        
        return results;
    }

    /*****************************************
    Method name:- getExecutiveMeetingBriefData
    Added by & Date:- Aswin Selvaraj & 07-May-2026
    Release:- WW22'2026'
    Description:- Method to fetch the backend timezone field value to show it on the UI
    ******************************************/
     @AuraEnabled(cacheable=true)
    public static Executive_Meeting_Brief__c getExecutiveMeetingBriefData(Id executiveMeetingId){
    	Executive_Meeting_Brief__c executiveMeetingRec =[SELECT Id,CRM_Time_Zone__c FROM Executive_Meeting_Brief__c WHERE Id=:executiveMeetingId];
        return executiveMeetingRec;
    }
    
     public class TimezoneOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public TimezoneOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /*****************************************
    Method name:- getAllTimezones
    Added by & Date:- Aswin Selvaraj & 07-May-2026
    Release:- WW22'2026'
    Description:- Method to fetch all the timezones from user object
    ******************************************/
    @AuraEnabled(cacheable=true)
    public static List<TimezoneOption> getAllTimezones() {
        List<TimezoneOption> options = new List<TimezoneOption>();

        Schema.DescribeFieldResult fld =
            User.TimeZoneSidKey.getDescribe();

        for (Schema.PicklistEntry ple : fld.getPicklistValues()) {
            options.add(new TimezoneOption(
                ple.getLabel(), // Friendly label (GMT info)
                ple.getValue()  // Stored value (e.g. America/Los_Angeles)
            ));
        }
        return options;
    }
    /*****************************************
    Method name:- saveTimezone
    Added by & Date:- Aswin Selvaraj & 07-May-2026
    Release:- WW22'2026'
    Description:- Method to update the EMB with the selected timezone during onchange
    ******************************************/
    @AuraEnabled
    public static void saveTimezone(Id recordId, String timezone) {
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        try{
            update new Executive_Meeting_Brief__c(
                Id = recordId,
                CRM_Time_Zone__c = timezone
            );
        } catch(Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = e.getMessage(), Core_Origin__c='CRM_ExecutiveMeetingBrief_Utility.saveTimezone', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));          
    		insert logEntries;
        }
    }
    // Input wrapper class
    public class EmailRequest {
        @InvocableVariable(label='Email Address' description='Email address to send email to' required=true)
    	public String emailAddress;
        
        @InvocableVariable(label='Email Template Id' description='Id of the email template' required=true)
        public Id emailTemplateId;
        
        @InvocableVariable(label='What Id' description='Record Id to merge with template' required=true)
        public Id whatId;
        
    }
    
    // Output wrapper class
    public class EmailResult {
        @InvocableVariable(label='Success' description='Whether the email was sent successfully')
        public Boolean success;
        
        @InvocableVariable(label='Error Message' description='Error message if email failed')
        public String errorMessage;
    }

}