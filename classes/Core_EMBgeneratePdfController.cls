public with sharing class Core_EMBgeneratePdfController{
    public Executive_Meeting_Brief__c meetingBrief { get; set; }

/* @AuraEnabled(cacheable=true)
  public static Executive_Meeting_Brief__c Core_EMBgeneratePdfController(Id recordId) {
        return [
             SELECT Account__c, Brief_Status__c, ConnectionReceivedId, ConnectionSentId, Core_Document_Link__c, Core_Executive_Meeting_Brief_Name__c, CreatedById, CreatedDate, CRM_Additional_Information__c, CRM_Additional_Legal_Guidance__c, CRM_Agenda_Topic__c, CRM_Agenda_Topic_backendField__c, CRM_Attendee_Bio_s__c, CRM_Background_Objective1__c, CRM_Country__c, CRM_Dress_Code__c, CRM_EMB_isOldOrNew__c, CRM_End_Time__c, CRM_EndTime_DetailField__c, CRM_Event_Engagement_Name__c, CRM_ExternalAttendees__c, CRM_ExternalAttendees_Ids__c, CRM_IntelAttendees__c, CRM_Intels_Meeting_Objectives__c, CRM_InternalAttendees_Ids__c, CRM_Investor_Scouting_Report__c, CRM_Location__City__s, CRM_Location__CountryCode__s, CRM_Location__GeocodeAccuracy__s, CRM_Location__Latitude__s, CRM_Location__Longitude__s, CRM_Location__PostalCode__s, CRM_Location__StateCode__s, CRM_Location__Street__s, CRM_Location_Maps__c, CRM_Meeting_Agenda_Items__c, CRM_Meeting_Owner_Contact__c, CRM_MeetingOwnerContact__c, CRM_Most_Critical_Messages_to_Get_Across__c, CRM_Other_Partys_Meeting_Objectives__c, CRM_PreparedBy__c, CRM_Presenters_Conversation_Lead__c, CRM_Presenters_Conversation_Lead_Id__c, CRM_PresentersConversationLeadNames__c, CRM_Proactive_Talking_Points__c, CRM_Reactive_Talking_Points__c, CRM_Reviewed_By_Names__c, CRM_ReviewedBy__c, CRM_Scheduled_End_Time__c, CRM_Scheduled_Start_Time__c, CRM_Start_Time__c, CRM_StartTime_DetailField__c, CRM_State__c, How_They_Buy_Sell__c, Id, Industry_Insights_Political_Climate__c, Is_New__c, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, OwnerId, Presenters_Conversation_Lead__c, Quip_Document_URL__c, RecordTypeId
               FROM Executive_Meeting_Brief__c 
            WHERE Id = :recordId
        ];
    }*/
    public Core_EMBgeneratePdfController() {
        String recordId = ApexPages.currentPage().getParameters().get('id');
        if (recordId != null) {
            meetingBrief = [
               SELECT Account__c, Brief_Status__c, ConnectionReceivedId, ConnectionSentId, Core_Document_Link__c, Core_Executive_Meeting_Brief_Name__c, CreatedById, CreatedDate, CRM_Additional_Information__c, CRM_Additional_Legal_Guidance__c, CRM_Agenda_Topic__c, CRM_Agenda_Topic_backendField__c, CRM_Attendee_Bio_s__c, CRM_Background_Objective1__c, CRM_Country__c, CRM_Dress_Code__c, CRM_EMB_isOldOrNew__c, CRM_End_Time__c, CRM_EndTime_DetailField__c, CRM_Event_Engagement_Name__c, CRM_ExternalAttendees__c, CRM_ExternalAttendees_Ids__c, CRM_IntelAttendees__c, CRM_Intels_Meeting_Objectives__c, CRM_InternalAttendees_Ids__c, CRM_Investor_Scouting_Report__c, CRM_Location__City__s, CRM_Location__CountryCode__s, CRM_Location__GeocodeAccuracy__s, CRM_Location__Latitude__s, CRM_Location__Longitude__s, CRM_Location__PostalCode__s, CRM_Location__StateCode__s, CRM_Location__Street__s, CRM_MeetingOwnerContact__c, CRM_Most_Critical_Messages_to_Get_Across__c, CRM_Other_Partys_Meeting_Objectives__c, CRM_ReviewedBy__c, CRM_Scheduled_End_Time__c, CRM_Scheduled_Start_Time__c, CRM_Start_Time__c, CRM_StartTime_DetailField__c, CRM_State__c, How_They_Buy_Sell__c, Id, Industry_Insights_Political_Climate__c, Is_New__c, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, OwnerId, Presenters_Conversation_Lead__c, Quip_Document_URL__c, RecordTypeId
               FROM Executive_Meeting_Brief__c 
                WHERE Id = :recordId
                LIMIT 1
            ];
        }
    }

}