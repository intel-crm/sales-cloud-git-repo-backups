/******************************************************************************************************************************************
Class Name  		: CRM_ExecutiveMeetingBriefController
Version     		: 1.0 
Description       	: CRM_ExecutiveMeetingBriefController to create and update Executive Meeting Brief
Modification Log 	:
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Areefa		     04 /Feb /2025   	Original version
*****************************************************************************************************************************************/

public with sharing class CRM_ExecutiveMeetingBriefController {

    
   

    @AuraEnabled
    
    //Method used in : cRM_ExecutiveMeetingBriefForm
    public static Id saveMeetingBrief(Map<String, Object> meetingBriefData, Boolean editMode,Id recordId,List<Object> uploadedFiles) {      
		Executive_Meeting_Brief__c meetingBrief;       
        
         if(!editMode){
             meetingBrief = new Executive_Meeting_Brief__c();
          }
        else{
         	meetingBrief = new Executive_Meeting_Brief__c(Id= recordId);    
        }
        meetingBrief.CRM_EMB_isOldOrNew__c = true;
        //EVENT Details
        meetingBrief.CRM_Event_Engagement_Name__c = (String) meetingBriefData.get('CRM_Event_Engagement_Name__c');
        //meetingBrief.CRM_Scheduled_Start_Time__c = parseDate((String) meetingBriefData.get('CRM_Scheduled_Start_Time__c'));
        //meetingBrief.CRM_Scheduled_End_Time__c = parseDate((String) meetingBriefData.get('CRM_Scheduled_End_Time__c'));


        // MEETING OBJECTIVES & KEY MESSAGES
        meetingBrief.CRM_Intels_Meeting_Objectives__c = (String) meetingBriefData.get('CRM_Intels_Meeting_Objectives__c');
        meetingBrief.CRM_Other_Partys_Meeting_Objectives__c = (String) meetingBriefData.get('CRM_Other_Partys_Meeting_Objectives__c');
        meetingBrief.CRM_Most_Critical_Messages_to_Get_Across__c = (String) meetingBriefData.get('CRM_Most_Critical_Messages_to_Get_Across__c');        
    
        // LOGISTICS, MEETING CONTACTS & SALESFORCE LINKS
        meetingBrief.CRM_PreparedBy__c = (String) meetingBriefData.get('CRM_PreparedBy__c');        
        meetingBrief.CRM_Reviewed_By_Names__c = (String) meetingBriefData.get('CRM_Reviewed_By_Names__c');		
        meetingBrief.CRM_Location__Street__s = (String) meetingBriefData.get('CRM_Location__Street__s');
        meetingBrief.CRM_Location__City__s = (String) meetingBriefData.get('CRM_Location__City__s');
        meetingBrief.CRM_Location__PostalCode__s = (String) meetingBriefData.get('CRM_Location__PostalCode__s');        
        meetingBrief.CRM_Location__CountryCode__s = (String) meetingBriefData.get('CRM_Location__CountryCode__s');
        meetingBrief.CRM_Location__StateCode__s = (String) meetingBriefData.get('CRM_Location__StateCode__s');              
        if(meetingBriefData.get('CRM_MeetingOwnerContact__c') != null){
        meetingBrief.CRM_MeetingOwnerContact__c = (String) meetingBriefData.get('CRM_MeetingOwnerContact__c');
        }
        // ATTENDEES       
        meetingBrief.CRM_IntelAttendees__c = (String) meetingBriefData.get('CRM_IntelAttendees__c'); 
        meetingBrief.CRM_ExternalAttendees__c = (String) meetingBriefData.get('CRM_ExternalAttendees__c'); 
        

        // AGENDA        
        meetingBrief.CRM_StartTime_DetailField__c = (String) meetingBriefData.get('CRM_StartTime_DetailField__c');
        meetingBrief.CRM_EndTime_DetailField__c = (String) meetingBriefData.get('CRM_EndTime_DetailField__c');

        meetingBrief.CRM_Meeting_Agenda_Items__c = (String) meetingBriefData.get('CRM_Meeting_Agenda_Items__c');        
        meetingBrief.CRM_PresentersConversationLeadNames__c = (String) meetingBriefData.get('CRM_PresentersConversationLeadNames__c');
        meetingBrief.CRM_Presenters_Conversation_Lead_Id__c = (String) meetingBriefData.get('CRM_Presenters_Conversation_Lead_Id__c');
		

        // BACKGROUND & TALKING POINTS
        meetingBrief.CRM_Agenda_Topic_backendField__c =(String) meetingBriefData.get('CRM_Agenda_Topic_backendField__c');
        meetingBrief.CRM_Background_Objective1__c = (String) meetingBriefData.get('CRM_Background_Objective1__c');
        meetingBrief.CRM_Proactive_Talking_Points__c = (String) meetingBriefData.get('CRM_Proactive_Talking_Points__c');
        meetingBrief.CRM_Reactive_Talking_Points__c = (String) meetingBriefData.get('CRM_Reactive_Talking_Points__c');
        

        // ADDITIONAL INFORMATION
        meetingBrief.CRM_Additional_Information__c = (String) meetingBriefData.get('CRM_Additional_Information__c');
        meetingBrief.CRM_Additional_Legal_Guidance__c = (String) meetingBriefData.get('CRM_Additional_Legal_Guidance__c');
        meetingBrief.CRM_Attendee_Bio_s__c = (String) meetingBriefData.get('CRM_Attendee_Bio_s__c');
        
        meetingBrief.Account__c = (String) meetingBriefData.get('Account__c');
        system.debug('account ID '+meetingBrief.Account__c);

        try {
            upsert meetingBrief;
            system.debug('INSIDE APEX UPLOADFILES:'+uploadedFiles);
             if (uploadedFiles != null && !uploadedFiles.isEmpty()) {
                attachFilesToRecord(meetingBrief.Id, uploadedFiles);
            }
            return meetingBrief.Id;
        } catch (DmlException e) {
            throw new AuraHandledException('Error saving meeting brief: ' + e.getMessage());
        }
    }
    
   @AuraEnabled
   public static void attachFilesToRecord(Id recordId, List<Object> uploadedFiles) {
    try {
        if (uploadedFiles == null || uploadedFiles.isEmpty()) {
            system.debug('INSIDE UPLOADED FILES NULL');
            return;
        }
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        
        for (Object fileObj : uploadedFiles) {
            // Convert to JSON and back to get proper typing
            String jsonString = JSON.serialize(fileObj);
            Map<String, Object> fileMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            
            system.debug('FILE UPLOAD FILEMAP: ' + fileMap);
            String documentId = (String) fileMap.get('documentId');
            system.debug('FILE UPLOAD DOCUMENTID: ' + documentId);
            
            if (String.isNotBlank(documentId)) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = documentId;
                cdl.LinkedEntityId = recordId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                
                contentDocumentLinks.add(cdl);
            }
        }
        
        if (!contentDocumentLinks.isEmpty()) {
            insert contentDocumentLinks;
            System.debug('Successfully attached ' + contentDocumentLinks.size() + ' files to record: ' + recordId);
        }
        
        } catch (DmlException e) {
            System.debug('Error attaching files: ' + e.getMessage());
            throw new AuraHandledException('Error attaching files to record: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Unexpected error attaching files: ' + e.getMessage());
            throw new AuraHandledException('Unexpected error attaching files: ' + e.getMessage());
        }
}
    
    private static Date parseDate(String dateStr) {
        if (String.isNotBlank(dateStr)) {
            try {
                return Date.valueOf(dateStr);
            } catch (Exception e) {
                System.debug('Error parsing date: ' + e.getMessage());
            }
        }
        return null;
    }

    @AuraEnabled(cacheable=true)  // called in cRM_ExecutiveMeetingBriefForm.js [Do we need?]
    public static List<User> getUsers() {
        return [SELECT Id, Name FROM User limit 10]; 
        
    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchTerm) {
        system.debug('INSIDE searchContacts'+searchTerm);
        if (String.isBlank(searchTerm)) {
            return new List<Contact>();
        }        
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10];
        System.debug('Contacts Found: ' + contacts);
        return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String searchTerm) { //searchPreparedbyUsers
        if (String.isBlank(searchTerm)) {
            return new List<User>();
        }
    return [SELECT Id, Name,Core_WWID__c,Email,Phone  FROM User WHERE Name LIKE :('%' + searchTerm + '%') LIMIT 10];
    }

    @AuraEnabled(cacheable=true)
    public static List<User> searchAttendees(String userType, String searchTerm) { // searchAttendees
        system.debug('INSIDE searchAttendees userType:'+userType+ ' searchTerm:'+searchTerm);
        String searchPattern = '%' + searchTerm + '%';        
        if (String.isBlank(searchTerm)) {
            return new List<User>();
        }                
        List<User> users = [SELECT Id, Name,Core_WWID__c,Email,Phone FROM User WHERE Core_User_Type__c = :userType AND Name LIKE :searchPattern LIMIT 10];
        System.debug('users Found: ' + users);
        return users;
    }
    @AuraEnabled(cacheable=true)
    public static Executive_Meeting_Brief__c getExecutiveMeetingBriefData(Id executiveMeetingId){
    	Executive_Meeting_Brief__c executiveMeetingRec =[SELECT CRM_Event_Engagement_Name__c,CRM_Intels_Meeting_Objectives__c,CRM_Other_Partys_Meeting_Objectives__c,CRM_Most_Critical_Messages_to_Get_Across__c,CRM_PreparedBy__c,CRM_PreparedBy__r.Name,CRM_Reviewed_By_Names__c,Account__c,CRM_Location__c,//CRM_Dress_Code__c,CRM_Background_Objective1__c,CRM_Scheduled_Start_Time__c,CRM_Scheduled_End_Time__c
        CRM_MeetingOwnerContact__c,CRM_MeetingOwnerContact__r.Name,CRM_IntelAttendees__c,CRM_ExternalAttendees__c,CRM_Start_Time__c,CRM_End_Time__c,CRM_Meeting_Agenda_Items__c,CRM_Proactive_Talking_Points__c,CRM_Reactive_Talking_Points__c,CRM_Additional_Information__c,
          CRM_Additional_Legal_Guidance__c,CRM_Attendee_Bio_s__c,CRM_StartTime_DetailField__c,CRM_EndTime_DetailField__c,CRM_PresentersConversationLeadNames__c,CRM_Agenda_Topic__c,CRM_Agenda_Topic_backendField__c,CRM_Presenters_Conversation_Lead_Id__c,CRM_InternalAttendees_Ids__c,CRM_ExternalAttendees_Ids__c,CRM_ReviewedBy__c FROM Executive_Meeting_Brief__c WHERE Id=:executiveMeetingId];
        return executiveMeetingRec;
    }
    //added for checking rich text tag removal
    @AuraEnabled(cacheable=true)
    public static String getstripHtmlTags() { 
        String htmlString = '<p><span style="font-family: Cambria, serif; font-size: 12pt;">Understand SRF product advantage, ecosystem partner readiness and future Xeon roadmap </span><span style="font-family: Cambria, serif; font-size: 16px; color: rgb(68, 68, 68);">Understand SRF product advantage, ecosystem partner readiness and future Xeon roadmap U</span><strong style="font-family: Cambria, serif; font-size: 16px; color: rgb(68, 68, 68);">nderstand SRF product advantage, ecosystem partner readiness and future Xeon roadmap</strong></p><ul><li><span style="font-family: Cambria, serif; font-size: 16px;">﻿</span><span style="font-family: Cambria, serif; font-size: 16px; background-color: rgb(255, 255, 255);">test</span></li><li><span style="font-family: Cambria, serif; font-size: 16px; background-color: rgb(255, 255, 255);">Bullet </span></li><li><span style="font-family: Cambria, serif; font-size: 16px; background-color: rgb(255, 255, 255);">points</span><img src="https://intel--crmdevsls3.sandbox.file.force.com/servlet/rtaImage?eid=aCwDf00000003xk&amp;feoid=00NDf00000QMoy6&amp;refid=0EMDf0000002nZO" alt="rtaImage.jpg"></img></li></ul>';
        if (htmlString == null) {      
            return '';   
        }
        String plainText = htmlString.replaceAll('<[^>]+>', '');    
        return plainText;  
    } 
    @AuraEnabled(cacheable=true)
    public static String getBaseUrl(){
        String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm();
		return sfdcBaseURL;
    }
    @AuraEnabled
    public static void updateMeetingBriefData(Map<String, Object> meetingBriefData,Id executiveMeetingId,String fieldUpdated){ 
        Executive_Meeting_Brief__c meetingBrief = new Executive_Meeting_Brief__c(Id=executiveMeetingId);
        if(fieldUpdated=='Attendees'){
            meetingBrief.CRM_IntelAttendees__c = (String) meetingBriefData.get('CRM_IntelAttendees__c'); 
        	meetingBrief.CRM_ExternalAttendees__c = (String) meetingBriefData.get('CRM_ExternalAttendees__c'); 
            meetingBrief.CRM_InternalAttendees_Ids__c = (String) meetingBriefData.get('CRM_InternalAttendees_Ids__c'); 
            meetingBrief.CRM_ExternalAttendees_Ids__c = (String) meetingBriefData.get('CRM_ExternalAttendees_Ids__c'); 
            
        }
         if(fieldUpdated=='Background'){
             // BACKGROUND & TALKING POINTS
            meetingBrief.CRM_Agenda_Topic_backendField__c = (String) meetingBriefData.get('CRM_Agenda_Topic_backendField__c');
            meetingBrief.CRM_Background_Objective1__c = (String) meetingBriefData.get('CRM_Background_Objective1__c');
            meetingBrief.CRM_Proactive_Talking_Points__c = (String) meetingBriefData.get('CRM_Proactive_Talking_Points__c');
            meetingBrief.CRM_Reactive_Talking_Points__c = (String) meetingBriefData.get('CRM_Reactive_Talking_Points__c');
              
         }
		 if(fieldUpdated=='Agendas'){
             // BACKGROUND & TALKING POINTS
            //meetingBrief.CRM_Start_Time__c = parseDate((String) meetingBriefData.get('CRM_Start_Time__c'));
            //meetingBrief.CRM_End_Time__c = parseDate((String) meetingBriefData.get('CRM_End_Time__c'));
            meetingBrief.CRM_StartTime_DetailField__c = (String) meetingBriefData.get('CRM_StartTime_DetailField__c');
            meetingBrief.CRM_EndTime_DetailField__c = (String) meetingBriefData.get('CRM_EndTime_DetailField__c');
            meetingBrief.CRM_Meeting_Agenda_Items__c = (String) meetingBriefData.get('CRM_Meeting_Agenda_Items__c');
           	//meetingBrief.CRM_Presenters_Conversation_Lead__c = (String) meetingBriefData.get('CRM_Presenters_Conversation_Lead__c');
             meetingBrief.CRM_PresentersConversationLeadNames__c =  (String) meetingBriefData.get('CRM_PresentersConversationLeadNames__c');
             system.debug('LEADD IDS:'+meetingBriefData.get('CRM_Presenters_Conversation_Lead_Id__c'));
             meetingBrief.CRM_Presenters_Conversation_Lead_Id__c = (String) meetingBriefData.get('CRM_Presenters_Conversation_Lead_Id__c');
              
         }
        if(fieldUpdated=='ReviewedBy'){
             meetingBrief.CRM_Reviewed_By_Names__c = (String) meetingBriefData.get('CRM_Reviewed_By_Names__c');
             meetingBrief.CRM_ReviewedBy__c = 	(String) meetingBriefData.get('CRM_ReviewedBy__c');
         }
        
        try{
            update meetingBrief;
        }
        catch(Exception e){           
            String fullMessage = e.getMessage();
            String trimmedMessage = extractValidationMessage(fullMessage);
            throw new AuraHandledException(trimmedMessage);
        }
    }
    
    Private static String extractValidationMessage(String fullMessage) {
        // Define the keyword that indicates the start of the validation message
        String startKeyword = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, ';
        Integer startIndex = fullMessage.indexOf(startKeyword);
        
        // If the keyword is found, extract the message that follows it
        if (startIndex != -1) {
            // Extract the message starting after the keyword
            String validationMessage = fullMessage.substring(startIndex + startKeyword.length());
            
            // Find the end of the validation message, typically before any additional info
            Integer endIndex = validationMessage.indexOf(': [');
            if (endIndex != -1) {
                validationMessage = validationMessage.substring(0, endIndex);
            }
            
            return validationMessage.trim();
        }       
        
        return 'An unexpected error occurred.';
    }
    @AuraEnabled(cacheable=true)
    public static User getUserDetails(Id userId) {
        try {
            User userDetail = [SELECT Id, Name, Email, Phone FROM User WHERE Id = :userId LIMIT 1];
            return userDetail;
        } catch (QueryException e) {
            throw new AuraHandledException('Error fetching user details: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<CRM_Meeting_Brief_Agenda__c> getAgendaItems(Id executiveBriefId) {
        try {
           List<CRM_Meeting_Brief_Agenda__c> agendaList = [SELECT Id,CRM_Start_Time__c,CRM_End_Time__c,CRM_Presenters_Conversation_Lead__c,CRM_Executive_Meeting_Brief__c FROM CRM_Meeting_Brief_Agenda__c WHERE CRM_Presenters_Conversation_Lead__c=:executiveBriefId];
            return agendaList;
        }
       catch (QueryException e) {
            throw new AuraHandledException('Error fetching agenda details: ' + e.getMessage());
        }

   }
    /**
     * Saves (insert/update) agenda items
     * @param agendaItems - List of agenda items to save
     * @param meetingBriefId - The Id of the parent meeting brief
     * @return List of saved agenda items with Ids
     */
    @AuraEnabled
    public static List<CRM_Meeting_Brief_Agenda__c> saveAgendaItems(List<CRM_Meeting_Brief_Agenda__c> agendaItems, Id meetingBriefId) {
        try {
            system.debug('Inside saveAgendaItems:'+agendaItems+' Meeting Brief id:'+meetingBriefId);
            if (!Schema.sObjectType.CRM_Meeting_Brief_Agenda__c.isCreateable() || 
                !Schema.sObjectType.CRM_Meeting_Brief_Agenda__c.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to save agenda items');
            }
            if (agendaItems == null || agendaItems.isEmpty()) {
                throw new AuraHandledException('No agenda items to save');
            }
            
            if (meetingBriefId == null) {
                throw new AuraHandledException('Meeting Brief ID cannot be null');
            }
            
            // Validate that the meeting brief exists
            List<Executive_Meeting_Brief__c> meetingBriefs = [SELECT Id FROM Executive_Meeting_Brief__c WHERE Id = :meetingBriefId LIMIT 1];
            
            if (meetingBriefs.isEmpty()) {
                throw new AuraHandledException('Invalid Meeting Brief ID');
            }
            
            // Set the master-detail relationship for all records
            for (CRM_Meeting_Brief_Agenda__c item : agendaItems) {
                item.CRM_Executive_Meeting_Brief__c = meetingBriefId;
                
                // Validate required fields
                if (item.CRM_Start_Time__c == null) {
                    throw new AuraHandledException('Start Time is required for all agenda items');
                }
                
                if (item.CRM_End_Time__c == null) {
                    throw new AuraHandledException('End Time is required for all agenda items');
                }
                
                if (item.CRM_Start_Time__c >= item.CRM_End_Time__c) {
                    throw new AuraHandledException('End Time must be after Start Time');
                }
                
                if (String.isBlank(item.CRM_Presenters_Conversation_Lead__c)) {
                    throw new AuraHandledException('Presenter/Conversation Lead is required for all agenda items');
                }
            }
            
            // Check for overlapping time slots
            //validateTimeSlots(agendaItems);
            
            // Perform upsert operation
            upsert agendaItems;
            
            // Return the saved records with all fields populated
            Set<Id> savedIds = new Set<Id>();
            for (CRM_Meeting_Brief_Agenda__c item : agendaItems) {
                savedIds.add(item.Id);
            }
            
            return [
                SELECT Id,  CRM_Start_Time__c, CRM_End_Time__c, CRM_Presenters_Conversation_Lead__c, CRM_Meeting_Agenda_Items__c,CRM_Executive_Meeting_Brief__c,CreatedDate,LastModifiedDate
                FROM CRM_Meeting_Brief_Agenda__c  WHERE Id IN :savedIds ORDER BY CRM_Start_Time__c ASC];
            
        } catch (DmlException e) {
            System.debug('DML Error in saveAgendaItems: ' + e.getMessage());
            throw new AuraHandledException('Error saving agenda items: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            System.debug('Error in saveAgendaItems: ' + e.getMessage());
            throw new AuraHandledException('Error saving agenda items: ' + e.getMessage());
        }
    } 
   
    @AuraEnabled
    public static void deleteAgendaItem(Id agendaItemId) {
        try {
            if (agendaItemId == null) {
                throw new AuraHandledException('Agenda Item ID cannot be null');
            }
            
            List<CRM_Meeting_Brief_Agenda__c> itemsToDelete = [
                SELECT Id FROM CRM_Meeting_Brief_Agenda__c 
                WHERE Id = :agendaItemId LIMIT 1
            ];
            
            if (itemsToDelete.isEmpty()) {
                throw new AuraHandledException('Agenda item not found');
            }
            
            delete itemsToDelete;
            
        } catch (DmlException e) {
            System.debug('DML Error in deleteAgendaItem: ' + e.getMessage());
            throw new AuraHandledException('Error deleting agenda item: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            System.debug('Error in deleteAgendaItem: ' + e.getMessage());
            throw new AuraHandledException('Error deleting agenda item: ' + e.getMessage());
        }
    }
}