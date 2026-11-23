/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CRM_ExecutiveMeetingBriefController {
    @AuraEnabled
    public static Id saveMeetingBrief(Map<String, Object> meetingBriefData, Boolean editMode,Id recordId) {
        System.debug('Meeting Brief Data: ' + meetingBriefData);
		Executive_Meeting_Brief__c meetingBrief;
         system.debug('EDIT MODE'+editMode);
        system.debug('RECORDID'+recordId);
        
         if(!editMode){
             meetingBrief = new Executive_Meeting_Brief__c();
          }
        else{
         	meetingBrief = new Executive_Meeting_Brief__c(Id= recordId);    
        }
        meetingBrief.CRM_EMB_isOldOrNew__c = true;
        //EVENT Details
        meetingBrief.CRM_Event_Engagement_Name__c = (String) meetingBriefData.get('CRM_Event_Engagement_Name__c');
        meetingBrief.CRM_Scheduled_Start_Time__c = parseDate((String) meetingBriefData.get('CRM_Scheduled_Start_Time__c'));
        meetingBrief.CRM_Scheduled_End_Time__c = parseDate((String) meetingBriefData.get('CRM_Scheduled_End_Time__c'));


        // MEETING OBJECTIVES & KEY MESSAGES
        meetingBrief.CRM_Intels_Meeting_Objectives__c = (String) meetingBriefData.get('CRM_Intels_Meeting_Objectives__c');
        meetingBrief.CRM_Other_Partys_Meeting_Objectives__c = (String) meetingBriefData.get('CRM_Other_Partys_Meeting_Objectives__c');
        meetingBrief.CRM_Most_Critical_Messages_to_Get_Across__c = (String) meetingBriefData.get('CRM_Most_Critical_Messages_to_Get_Across__c');
        
        //meetingBrief.Account__c =''; //'0012D00000aYhYGQA0'
    
        // LOGISTICS, MEETING CONTACTS & SALESFORCE LINKS
        System.debug('CRM_PreparedBy__c: ' + (String) meetingBriefData.get('CRM_PreparedBy__c'));
        //System.debug('CRM_Reviewed_by__c: ' + (String) meetingBriefData.get('CRM_Reviewed_by__c'));
        System.debug('CRM_Reviewed_By_Names__c: ' + (String) meetingBriefData.get('CRM_Reviewed_By_Names__c'));
        System.debug('CRM_MeetingOwnerContact__c: ' + (String) meetingBriefData.get('CRM_MeetingOwnerContact__c'));

        
        meetingBrief.CRM_PreparedBy__c = (String) meetingBriefData.get('CRM_PreparedBy__c');
        //meetingBrief.CRM_Reviewed_by__c = (String) meetingBriefData.get('CRM_Reviewed_by__c');
        meetingBrief.CRM_Reviewed_By_Names__c = (String) meetingBriefData.get('CRM_Reviewed_By_Names__c');
		//meetingBrief.CRM_Dress_Code__c = (String) meetingBriefData.get('CRM_Dress_Code__c');
        meetingBrief.CRM_Location__Street__s = (String) meetingBriefData.get('CRM_Location__Street__s');
        meetingBrief.CRM_Location__City__s = (String) meetingBriefData.get('CRM_Location__City__s');
        meetingBrief.CRM_Location__PostalCode__s = (String) meetingBriefData.get('CRM_Location__PostalCode__s');
        //meetingBrief.CRM_Location__Latitude__s = (Double) meetingBriefData.get('CRM_Location__Latitude__s');
        //meetingBrief.CRM_Location__Longitude__s = (Double) meetingBriefData.get('CRM_Location__Longitude__s');
        meetingBrief.CRM_Location__CountryCode__s = (String) meetingBriefData.get('CRM_Location__CountryCode__s');
        meetingBrief.CRM_Location__StateCode__s = (String) meetingBriefData.get('CRM_Location__StateCode__s');
        //meetingBrief.CRM_Location__GeocodeAccuracy__s = (String) meetingBriefData.get('CRM_Location__GeocodeAccuracy__s');        
        if(meetingBriefData.get('CRM_MeetingOwnerContact__c') != null){
        meetingBrief.CRM_MeetingOwnerContact__c = (String) meetingBriefData.get('CRM_MeetingOwnerContact__c');
        }
        // ATTENDEES
        //meetingBrief.CRM_Intel_Attendees__c = (String) meetingBriefData.get('CRM_Intel_Attendees__c'); 
        //meetingBrief.CRM_External_Attendees__c = (String) meetingBriefData.get('CRM_External_Attendees__c');
        meetingBrief.CRM_IntelAttendees__c = (String) meetingBriefData.get('CRM_IntelAttendees__c'); 
        meetingBrief.CRM_ExternalAttendees__c = (String) meetingBriefData.get('CRM_ExternalAttendees__c'); 
        

        // AGENDA
        //meetingBrief.CRM_Start_Time__c = parseDate((String) meetingBriefData.get('CRM_Start_Time__c'));
        //meetingBrief.CRM_End_Time__c = parseDate((String) meetingBriefData.get('CRM_End_Time__c'));
        meetingBrief.CRM_StartTime_DetailField__c = (String) meetingBriefData.get('CRM_StartTime_DetailField__c');
        meetingBrief.CRM_EndTime_DetailField__c = (String) meetingBriefData.get('CRM_EndTime_DetailField__c');

        meetingBrief.CRM_Meeting_Agenda_Items__c = (String) meetingBriefData.get('CRM_Meeting_Agenda_Items__c');
        //meetingBrief.CRM_Presenters_Conversation_Lead__c = (String) meetingBriefData.get('CRM_Presenters_Conversation_Lead__c');
        meetingBrief.CRM_PresentersConversationLeadNames__c = (String) meetingBriefData.get('CRM_PresentersConversationLeadNames__c');
        meetingBrief.CRM_Presenters_Conversation_Lead_Id__c = (String) meetingBriefData.get('CRM_Presenters_Conversation_Lead_Id__c');
		system.debug('APEX START TIME:'+ meetingBrief.CRM_Start_Time__c);
      	system.debug('APEX end TIME:'+ meetingBrief.CRM_End_Time__c);

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
            return meetingBrief.Id;
        } catch (DmlException e) {
            throw new AuraHandledException('Error saving meeting brief: ' + e.getMessage());
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

    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [SELECT Id, Name FROM User limit 10]; //WHERE Email IN ('areefa.banu@intel.com', 'vani.sujana.tupili@intel.com', 'navneet.kaur@intel.com')
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

   /* @AuraEnabled(cacheable=true)
    public static List<User> searchIntelAttendees(String searchInternalUser) {
        String searchPattern = '%' + searchInternalUser + '%';
        return [SELECT Id, Name FROM User WHERE Core_User_Type__c = 'CRM_Intel_Attendees__c' AND Name LIKE :searchPattern];
    }

    @AuraEnabled(cacheable=true)
    public static List<User> searchExternalAttendees(String searchExternalUser) {
        String searchPattern = '%' + searchExternalUser + '%';
        return [SELECT Id, Name FROM User WHERE Core_User_Type__c = 'CRM_External_Attendees__c' AND Name LIKE :searchPattern];
    }*/
    @AuraEnabled(cacheable=true)
    public static List<User> searchAttendees(String userType, String searchTerm) { // searchAttendees
        system.debug('INSIDE searchAttendees userType:'+userType+ ' searchTerm:'+searchTerm);
        String searchPattern = '%' + searchTerm + '%';
        /*return [
            SELECT Id, Name 
            FROM User 
            WHERE Core_User_Type__c = :userType 
            AND Name LIKE :searchPattern // AND IsActive = true             
            LIMIT 10
        ];*/
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
        system.debug('Inside apex updateMeetingBriefData data:'+meetingBriefData);
        system.debug('Inside apex updateMeetingBriefData id:'+executiveMeetingId);
       system.debug('Inside apex updateMeetingBriefData data:'+fieldUpdated);

        
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
              system.debug('BG OBJECTIVE'+meetingBrief.CRM_Background_Objective1__c);
              system.debug('BG PROACTIVE'+meetingBrief.CRM_Proactive_Talking_Points__c);
              system.debug('BG REACTIVE'+meetingBrief.CRM_Reactive_Talking_Points__c);
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
              system.debug('APEX AGENDA STARTTIME'+meetingBrief.CRM_Start_Time__c);
              system.debug('APEX AGENDA ENDTIME'+meetingBrief.CRM_End_Time__c);
              system.debug('APEX AGENDA STARTDATEFIELD'+meetingBrief.CRM_StartTime_DetailField__c);
              system.debug('APEX AGENDA ENDATEFIELD'+meetingBrief.CRM_EndTime_DetailField__c);
         }
        if(fieldUpdated=='ReviewedBy'){
             meetingBrief.CRM_Reviewed_By_Names__c = (String) meetingBriefData.get('CRM_Reviewed_By_Names__c');
             meetingBrief.CRM_ReviewedBy__c = 	(String) meetingBriefData.get('CRM_ReviewedBy__c');
         }
        
        
        
        try{
            update meetingBrief;
        }
        catch(Exception e){
            //throw new AuraHandledException('Error saving meeting brief: ' + e.getMessage());
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

}