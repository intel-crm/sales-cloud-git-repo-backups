/********************************************************************************************************************************************************************
Apex Class Name: CRM_Alertwatch 
Version: 1.0
Created Date: 11/11/2024
Function: Alert Watch is used to send emails based on Audit Trail data
Modification Log :
* Developer                 Date                Description
* ----------------------------------------------------------------------------
* Shijas KM/Areefa          11/11/2024          Original Version developed
******************************************************************************************************************************/

global without sharing class CRM_Alertwatch {
    
     public static List<SetupAuditTrail> getAuditTrailReminderData() {
          List<SetupAuditTrail> lst_aw_response =new  List<SetupAuditTrail>();
        try {
            // Retrieve custom metadata records
            Map<String, String> metadataValues = retrieveMetadataValues();
            
            // Extract values from metadata
            List<String> sections = metadataValues.containsKey('AuditTrailSections') ? metadataValues.get('AuditTrailSections').split(',') : new List<String>();
			List<String> actions = metadataValues.containsKey('AuditTrailActions') ? metadataValues.get('AuditTrailActions').split(',') : new List<String>();
            List<String> sectionsList = new List<String>();
            for (String section : sections) {
                sectionsList.add(section.trim());
            }
			List<String> actionsList = new List<String>();
            for (String action : actions) {
                actionsList.add(action.trim());
            }
            List<String> excludedUsersList = metadataValues.containsKey('AuditTrailExcludedUserNames') ? metadataValues.get('AuditTrailExcludedUserNames').split(';') : new List<String>();
           
            String whereCondition = metadataValues.get('AuditTrailWhereCondition');
            String selectFields = metadataValues.get('AuditTrailSelectFields');           
            
            // Get audit trail data
            lst_aw_response = getAuditTrailData(selectFields, whereCondition, excludedUsersList, sectionsList, actionsList);
        }  catch (Exception e) {PMP_Utility.logError(e, 'CRM Alert Watch');         
        }
         return lst_aw_response;
    }
    
    @TestVisible
     public static void sendAuditTrailMail(List<SetupAuditTrail> lstAuditTrail) {
          
        try {
            Map<String, String> metadataValues = retrieveMetadataValues();
            String mailSubject = metadataValues.get('EmailSubject');
            String strReplyTo = metadataValues.get('AuditTrailsetReplyTo');
            String auditTrailCSVHeader = metadataValues.get('AuditTrailCSVHeader');
            String auditTrailCSVFileName = metadataValues.get('AuditTrailCSVFileName');
            String auditTrailNoChanges = metadataValues.get('AuditTrail_NoChanges');
            // Send email with audit trail data
            sendEmail(lstAuditTrail, mailSubject, strReplyTo, auditTrailCSVHeader, auditTrailCSVFileName, auditTrailNoChanges);
        }  catch (Exception e) {PMP_Utility.logError(e, 'CRM Alert Watch');         
        }
        
    }
    
    @TestVisible
    private static Map<String, String> retrieveMetadataValues() {
        Map<String, String> metadataValues = new Map<String, String>();
        
        if (Schema.sObjectType.Core_MDF_CCP_Custom_Metadata_Utility__c.fields.Name.isAccessible() &&
            Schema.sObjectType.Core_MDF_CCP_Custom_Metadata_Utility__c.fields.Core_MDF_Value__c.isAccessible()) {
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> metadataRecords = [SELECT Name, Core_MDF_Value__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Program__c = 'Alert_Watch' limit 50];
            for (Core_MDF_CCP_Custom_Metadata_Utility__c rec : metadataRecords) {
                metadataValues.put(rec.Name, rec.Core_MDF_Value__c);
            }
        }
        
        return metadataValues;
    }
    
    private static List<SetupAuditTrail> getAuditTrailData(String selectFields, String whereCondition, List<String> excludedUsersList, List<String> sectionsList, List<String> actionsList ) {
        List<SetupAuditTrail> lst_aw_response = new List<SetupAuditTrail>();
        String query = constructQuery(selectFields, whereCondition, excludedUsersList);
        
        // Execute the query using bind variables
        List<SetupAuditTrail> lstAuditTrail = Database.query(String.escapeSingleQuotes(query));
        for (SetupAuditTrail rec : lstAuditTrail) {
            if ((sectionsList.contains(rec.Section)) && (!actionsList.contains(rec.Action))) {
			
                lst_aw_response.add(rec);                    
            }
        }
        
        return lst_aw_response;
    }
    
    private static String constructQuery(String selectFields, String whereCondition, List<String> excludedUsersList) {
        String query = 'SELECT ';
        
        // Construct the dynamic query
        if (String.isNotBlank(selectFields)) {
            query += selectFields;
        }
        if (String.isNotBlank(whereCondition)) {
            query += ' FROM SetupAuditTrail WHERE ' + whereCondition;
        }
        if (!excludedUsersList.isEmpty()) {
            query += ' AND CreatedBy.username NOT IN :excludedUsersList';
        }
        
        query += ' ORDER BY CreatedDate DESC ';
        system.debug(query);
        return query;
    }
    
    // Email Attachment CSV file creation
    @TestVisible
    private static Messaging.EmailFileAttachment generateCSVFile(List<SetupAuditTrail> lst_aw_response, String auditTrailCSVHeader, String auditTrailCSVFileName, String auditTrailNoChanges) {
        String csvContent = auditTrailCSVHeader + '\n';
        if (!lst_aw_response.isEmpty()) {
            for (SetupAuditTrail awData : lst_aw_response) {
                if (!String.isBlank(awData.Id) && !String.isEmpty(awData.Id)) {
                    String strModifiedDetails = String.escapeSingleQuotes(awData.Display).replace(',', ' ').replace('"', ' ').replace('\n', ' ').replace('\r', ' ');
                    csvContent += awData.Id + ',' + awData.Section + ',' + awData.CreatedBy.Name + ',' + awData.CreatedDate + ',' + strModifiedDetails + ',' + awData.Action + '\n';
                }
            }
        } else {
            csvContent += auditTrailNoChanges;
        }
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('text/csv');
        attachment.setFilename(auditTrailCSVFileName + '.csv');
        attachment.setInline(true);
        attachment.setBody(Blob.valueOf(csvContent));
        return attachment;
    }
    
    // Audit Trail email send with CSV as attachment
    @TestVisible
    private static void sendEmail(List<SetupAuditTrail> lst_aw_response, String emailSubject, String replyTo, String auditTrailCSVHeader, String auditTrailCSVFileName, String auditTrailNoChanges) {
        if (hasOrgWideEmailAddressAccess()) {
            List<OrgWideEmailAddress> orgWideEmailList = getOrgWideEmailAddresses();
            String orgWideEmailId = (orgWideEmailList != null && !orgWideEmailList.isEmpty()) ? orgWideEmailList[0].Id : '';
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            if (hasGroupMemberAndUserAccess()) {
                List<User> lstUser = getAlertWatchMembers();
                for (User mailuser : lstUser) {
                    Messaging.SingleEmailMessage mail = createEmailMessage(mailuser, orgWideEmailId, replyTo, emailSubject, lst_aw_response, auditTrailCSVHeader, auditTrailCSVFileName, auditTrailNoChanges);
                    emails.add(mail);
                }
                Messaging.sendEmail(emails);
            }
        } 
    }
    
    private static Boolean hasOrgWideEmailAddressAccess() {
        return Schema.sObjectType.OrgWideEmailAddress.isAccessible() &&
               Schema.sObjectType.OrgWideEmailAddress.fields.Id.isAccessible() &&
               Schema.sObjectType.OrgWideEmailAddress.fields.Address.isAccessible();
    }
    
    private static List<OrgWideEmailAddress> getOrgWideEmailAddresses() {
        return [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Intel Corporation-NoReply' LIMIT 1];
    }
    
    private static Boolean hasGroupMemberAndUserAccess() {
        return Schema.sObjectType.GroupMember.isAccessible() &&
               Schema.sObjectType.GroupMember.fields.GroupId.isAccessible() &&
               Schema.sObjectType.GroupMember.fields.UserOrGroupId.isAccessible() &&
               Schema.sObjectType.User.isAccessible() &&
               Schema.sObjectType.User.fields.Id.isAccessible() &&
               Schema.sObjectType.User.fields.Name.isAccessible();
    }
    
    private static List<User> getAlertWatchMembers() {
        return [SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'Core_AlertWatchMembers') limit 50];
    }
    
    private static Messaging.SingleEmailMessage createEmailMessage(User mailuser, String orgWideEmailId, String replyTo, String emailSubject, List<SetupAuditTrail> lst_aw_response, String auditTrailCSVHeader, String auditTrailCSVFileName, String auditTrailNoChanges) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(mailuser.Id);
        mail.setSaveAsActivity(false);
        mail.setOrgWideEmailAddressId(orgWideEmailId);
        mail.setReplyTo(replyTo);
        mail.setSubject(emailSubject);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { generateCSVFile(lst_aw_response, auditTrailCSVHeader, auditTrailCSVFileName, auditTrailNoChanges) });
        mail.setHtmlBody('Hi ' + mailuser.Name + '<BR><BR>' + 'Please find the attached ' + '<B>' + 'Audit Trail Details.' + '</B><BR><BR>' + 'Thanks' + '<BR>' + 'SF Team');
        return mail;
    }
}