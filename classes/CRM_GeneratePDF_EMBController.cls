/**
* @File Name : CRM_GeneratePDF_EMBController.cls
* @Description :This controller is used to generate pdf for executive meeting brief
* @Last Modified By :Swati Paraste
* @Last Modified On : April 29, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 29, 2025 |Swati Paraste   | Initial Version
**/

public class CRM_GeneratePDF_EMBController {
    
    public Executive_Meeting_Brief__c record { get; set; }
    public Account relatedAccount { get; set; }
    public String accountUrl { get; set; }
    public String formatted_CRM_Intels_Meeting_Objectives { get; set; }
    public String formatted_CRM_Most_Critical_Messages_to_Get_Across { get; set; }
    public String formatted_CRM_Other_Partys_Meeting_Objectives { get; set; } 
    
    public String formatted_Reactive_Talking_Points { get; set; } 
    public String formatted_Background_Objective { get; set; } 
    public String formatted_Proactive_Talking_Points { get; set; } 
    public String mergedFormattedTime { get; set; }
    
    
    public List<String> CRM_Reactive_TalkingPoints { get; set; } 
    public List<String> CRM_Reactive_TalkingPointsList { get; set; } 
    public List<String> CRM_Proactive_TalkingPoints { get; set; } 
    public List<String> CRM_BackgroundObjective1 { get; set; } 
    public List<String> CRM_Agenda_TopicbackendField { get; set; }
    public Integer rowCount { get; set; }
    
    public String formatted_Industry_Insights_Political_Climate { get; set; } 
    public String formatted_How_They_Buy_Sell { get; set; } 
    public String formatted_CRM_Investor_Scouting_Report { get; set; }
    
    public String formatted_CRM_Additional_Legal_Guidance { get; set; } 
    public String formatted_CRM_Attendee_Bio { get; set; }
    
    public List<List<String>> internalExternalAttendes { get; set; }
    public List<List<String>> agenda { get; set; }
    public List<List<String>> background_talking_point { get; set; }
    
    public String formattedLocation {get; set; }
    
    public CRM_GeneratePDF_EMBController() {
        
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        record = [
            
            SELECT Id, Name, Core_Executive_Meeting_Brief_Name__c,CRM_Intels_Meeting_Objectives__c,CRM_Most_Critical_Messages_to_Get_Across__c,CRM_Other_Partys_Meeting_Objectives__c,Account__c,CRM_PreparedBy__r.Name,CRM_Location__c,CRM_Location__Street__s,CRM_Location__City__s,CRM_Location__PostalCode__s,CRM_Location__StateCode__s,CRM_Location__CountryCode__s,CRM_Dress_Code__c,CRM_Scheduled_End_Time_txt__c,CRM_Scheduled_Start_Time_txt__c,
            
            Industry_Insights_Political_Climate__c,How_They_Buy_Sell__c,CRM_Investor_Scouting_Report__c,CRM_Additional_Legal_Guidance__c,CRM_Attendee_Bio_s__c,CRM_Brief_Reviewer__r.Name
            
            FROM Executive_Meeting_Brief__c
            
            WHERE Id = :recordId
            
            LIMIT 1
            
        ];
        String baseUrl = ApexPages.currentPage().getHeaders().get('Host');

        relatedAccount = [SELECT Id, Name FROM Account WHERE Id = :record.Account__c LIMIT 1];
        accountUrl = 'https://' + baseUrl + '/' + relatedAccount.Id;    
        if (!String.isBlank(record.CRM_Intels_Meeting_Objectives__c) || !String.isBlank(record.CRM_Most_Critical_Messages_to_Get_Across__c) || !String.isBlank(record.CRM_Other_Partys_Meeting_Objectives__c)  ){
            formatted_CRM_Intels_Meeting_Objectives = adjustImageSize(record.CRM_Intels_Meeting_Objectives__c);
            formatted_CRM_Most_Critical_Messages_to_Get_Across = adjustImageSize(record.CRM_Most_Critical_Messages_to_Get_Across__c);
            formatted_CRM_Other_Partys_Meeting_Objectives = adjustImageSize(record.CRM_Other_Partys_Meeting_Objectives__c);      
        }
        
        if(!String.isBlank(record.Industry_Insights_Political_Climate__c)||!String.isBlank(record.How_They_Buy_Sell__c)|| !String.isBlank(record.CRM_Investor_Scouting_Report__c)|| !String.isBlank(record.CRM_Additional_Legal_Guidance__c)||!String.isBlank(record.CRM_Attendee_Bio_s__c)){
            formatted_Industry_Insights_Political_Climate = adjustImageSize(record.Industry_Insights_Political_Climate__c);
            formatted_How_They_Buy_Sell = adjustImageSize(record.How_They_Buy_Sell__c);
            formatted_CRM_Investor_Scouting_Report = adjustImageSize(record.CRM_Investor_Scouting_Report__c);
            formatted_CRM_Additional_Legal_Guidance = adjustImageSize(record.CRM_Additional_Legal_Guidance__c);
            formatted_CRM_Attendee_Bio = adjustImageSize(record.CRM_Attendee_Bio_s__c);
        }
        List<CRM_Meeting_Brief_Attendee__c> attendeeList = [SELECT Id,CRM_Intel_Attendee__r.Name,CRM_External_Attendee__r.Name FROM CRM_Meeting_Brief_Attendee__c WHERE CRM_Executive_Meeting_Brief__c=:recordId];
        List<String> ExternalAttendeesList = new List <String>();
        List<String> IntelAttendeesList = new List<String>();
        if(attendeeList.size()>0){
            for(CRM_Meeting_Brief_Attendee__c attendeeRec:attendeeList){
                    ExternalAttendeesList.add(attendeeRec.CRM_Intel_Attendee__r.Name);
                    IntelAttendeesList.add(attendeeRec.CRM_External_Attendee__r.Name);
            }
            
        }
        List<String> StartTime_DetailFieldList = new List<String>();
        List<String> EndTime_DetailFieldList = new List<String>();
        List<String> PresentersConversationLeadNamesList = new List<String>();
        List<String> Meeting_Agenda_ItemsList = new List<String>();
        
        List<CRM_Meeting_Brief_Agenda__c> agendaList = [SELECT Id,CRM_Start_Time_txt__c,CRM_End_Time_txt__c,CRM_Presenters_Conversation_Lead__r.Name,CRM_Meeting_Agenda_Items__c FROM CRM_Meeting_Brief_Agenda__c WHERE CRM_Executive_Meeting_Brief__c=:recordId];
        if(agendaList.size()>0){
            for(CRM_Meeting_Brief_Agenda__c agendaRec:agendaList){
                StartTime_DetailFieldList.add(String.valueOf(agendaRec.CRM_Start_Time_txt__c));
                EndTime_DetailFieldList.add(String.valueOf(agendaRec.CRM_End_Time_txt__c));
                PresentersConversationLeadNamesList.add(agendaRec.CRM_Presenters_Conversation_Lead__r.Name);
                Meeting_Agenda_ItemsList.add(agendaRec.CRM_Meeting_Agenda_Items__c);
            }
        }
        
        internalExternalAttendes = new List<List<String>>();
        agenda = new List<List<String>>();
        //formattedlocation
        List<String> location = new List<String>();
        if (!String.isBlank(record.CRM_Location__Street__s)) location.add(record.CRM_Location__Street__s);
        if (!String.isBlank(record.CRM_Location__City__s)) location.add(record.CRM_Location__City__s);
        if (!String.isBlank(record.CRM_Location__PostalCode__s)) location.add(record.CRM_Location__PostalCode__s);
        if (!String.isBlank(record.CRM_Location__StateCode__s)) location.add(record.CRM_Location__StateCode__s);
        if (!String.isBlank(record.CRM_Location__CountryCode__s)) location.add(record.CRM_Location__CountryCode__s);

        formattedLocation = String.join(location, ', ');
        
        Integer maxLength = Math.max(ExternalAttendeesList.size(), IntelAttendeesList.size());
        Integer maxLength2 = Math.max(Math.max(StartTime_DetailFieldList.size(),EndTime_DetailFieldList.size()),Math.max(PresentersConversationLeadNamesList.size(),Meeting_Agenda_ItemsList.size()));
        for (Integer i = 0; i < maxLength; i++) {
            //attendes fields
            String ExternalAttendees = (i < ExternalAttendeesList.size() && ExternalAttendeesList[i] != null) ? ExternalAttendeesList[i].trim() : '';
            String IntelAttendees = (i < IntelAttendeesList.size() && IntelAttendeesList[i] != null) ? IntelAttendeesList[i].trim() : '';
            
            if (!String.isBlank(ExternalAttendees) || !String.isBlank(IntelAttendees)) {
                internalExternalAttendes.add(new List<String>{ IntelAttendees,ExternalAttendees  });
            }
            
        }
        for (Integer i = 0; i < maxLength2; i++) {
         
            //agenda fields
            String StartTime_DetailField = (i < StartTime_DetailFieldList.size() && StartTime_DetailFieldList[i] != null) ? StartTime_DetailFieldList[i].trim() : '';

            String EndTime_DetailField = (i < EndTime_DetailFieldList.size() && EndTime_DetailFieldList[i] != null) ? EndTime_DetailFieldList[i].trim() : '';

            String PresentersConversationLeadNames = (i < PresentersConversationLeadNamesList.size() && PresentersConversationLeadNamesList[i] != null) ? PresentersConversationLeadNamesList[i].trim() : '';

            String Meeting_Agenda_Items = (i < Meeting_Agenda_ItemsList.size() && Meeting_Agenda_ItemsList[i] != null)  ? Meeting_Agenda_ItemsList[i].trim() : '';
            
            mergedFormattedTime = '';
            
             
            // Format Start Time (12-hour format)
            //String formattedStart = formatTime(StartTime_DetailField);
            
            // Format End Time (12-hour format)
            //String formattedEnd = formatTime(EndTime_DetailField);

            // Combine formatted Start and End time
            if(!String.isBlank(StartTime_DetailField) || !String.isBlank(EndTime_DetailField)){
            mergedFormattedTime = StartTime_DetailField + ' - ' + EndTime_DetailField;
            }
            if (!String.isBlank(mergedFormattedTime) || !String.isBlank(PresentersConversationLeadNames) || !String.isBlank(Meeting_Agenda_Items)) {
                agenda.add(new List<String>{ mergedFormattedTime,PresentersConversationLeadNames,Meeting_Agenda_Items  });
            }
        }
        List<CRM_MeetingBriefBackground_TalkingPoints__c> bgTalkingPointsList = [SELECT Id,CRM_Agenda_Topic__c,CRM_Background__c,CRM_Proactive_Talking_Points__c,CRM_Reactive_Talking_Points__c FROM CRM_MeetingBriefBackground_TalkingPoints__c WHERE CRM_Executive_Meeting_Brief__c=:recordId];
        
        CRM_Agenda_TopicbackendField = new List<String>();
        CRM_BackgroundObjective1 = new List<String>();
        CRM_Proactive_TalkingPoints = new List<String>();
        CRM_Reactive_TalkingPoints = new List<String>();
        
        if(bgTalkingPointsList.size() > 0){
            for(CRM_MeetingBriefBackground_TalkingPoints__c bgRec : bgTalkingPointsList){
                CRM_Agenda_TopicbackendField.add(bgRec.CRM_Agenda_Topic__c != null ? bgRec.CRM_Agenda_Topic__c : '');
                CRM_BackgroundObjective1.add(bgRec.CRM_Background__c != null ? bgRec.CRM_Background__c : '');
                CRM_Proactive_TalkingPoints.add(bgRec.CRM_Proactive_Talking_Points__c != null ? bgRec.CRM_Proactive_Talking_Points__c : '');
                CRM_Reactive_TalkingPoints.add(bgRec.CRM_Reactive_Talking_Points__c != null ? bgRec.CRM_Reactive_Talking_Points__c : '');
            }
        }
        Integer maxSize = Math.max(
            Math.max(CRM_Agenda_TopicbackendField.size(), CRM_BackgroundObjective1.size()),
            Math.max(CRM_Proactive_TalkingPoints.size(), CRM_Reactive_TalkingPoints.size())
        );
        background_talking_point = new List<List<String>>();
        for (Integer i = 0; i < maxSize; i++) {
            //background fields
            String  Agenda_Topic = (i < CRM_Agenda_TopicbackendField.size()) ? CRM_Agenda_TopicbackendField[i] : '';
            String Background_Objective = (i < CRM_BackgroundObjective1.size()) ? CRM_BackgroundObjective1[i] : '';
            String Proactive_Talking_Points = (i < CRM_Proactive_TalkingPoints.size()) ? CRM_Proactive_TalkingPoints[i]:'';
            String Reactive_Talking_Points = (i < CRM_Reactive_TalkingPoints.size()) ? CRM_Reactive_TalkingPoints[i] : '';
            formatted_Background_Objective = adjustImageSize(Background_Objective);
            formatted_Reactive_Talking_Points = adjustImageSize(Reactive_Talking_Points);
            formatted_Proactive_Talking_Points = adjustImageSize(Proactive_Talking_Points);
           
            if (!String.isBlank(Agenda_Topic) || !String.isBlank(formatted_Background_Objective) || !String.isBlank(formatted_Proactive_Talking_Points) || !String.isBlank(formatted_Reactive_Talking_Points)) {
                background_talking_point.add(new List<String>{ Agenda_Topic,formatted_Background_Objective,formatted_Proactive_Talking_Points,formatted_Reactive_Talking_Points  });
            }
        }
    }   
    private String adjustImageSize(String content) {
    if (String.isNotBlank(content)) {
        // Handle images
        content = content.replaceAll('<img', '<img style="width:80%;max-width:300px;height:auto"');
        
        // Handle tables - only fix width/cropping issues, preserve all other styling
        if (content.contains('<table')) {
            // Simple approach: Remove width attributes and add fixed width
            content = content.replaceAll('width="[^"]*"', '');
            content = content.replaceAll('width:\\s*[^;]*;?', '');
            
            // Add table-layout fixed to all tables
            content = content.replaceAll('<table', '<table style="width:100%;table-layout:fixed;"');
            
            // Remove colgroup and col elements
            content = content.replaceAll('<colgroup>.*?</colgroup>', '');
            content = content.replaceAll('<col[^>]*/?>', '');
            
            // Add word-wrap to all td elements
            content = content.replaceAll('<td', '<td style="word-wrap:break-word;"');
        }
    }
    return content;
}
    private String formatTime(String timeString) {
    try {
        String dateString = '';
        if (String.isBlank(timeString)) {
            return ' ';
        }
        
        // Check if it's a datetime format (contains date)
        if (timeString.contains(' ')) {
            // Split by space to get date and time parts
            List<String> dateTimeParts = timeString.split(' ');
            if (dateTimeParts.size() >= 2) {
                // Get the time part (second element)
                timeString = dateTimeParts[1];
                dateString = dateTimeParts[0];
            }
        }
        
        // Now split by colon to get hour and minute
        List<String> timeParts = timeString.split(':');
        
        // Ensure the time format is correct
        if (timeParts.size() < 2) {
            return ' ';
        }

        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);

        // Convert to 12-hour format manually
        String ampm = (hour >= 12) ? 'PM' : 'AM';
        Integer hour12 = hour;

        if (hour12 > 12) {
            hour12 = hour - 12;
        }
        if (hour12 == 0) hour12 = 12;  // Handle midnight

        // Format the time in "hh:mm AM/PM" format
        String formattedTime = (hour12 < 10 ? '0' + hour12 : String.valueOf(hour12)) 
             + ':' + (minute < 10 ? '0' + minute : String.valueOf(minute)) 
             + ' ' + ampm;
        
        // Return date and time together if date exists
        if (String.isNotBlank(dateString)) {
            return dateString + ' ' + formattedTime;
        } else {
            return formattedTime;
        }
        
    } catch (Exception e) {
        return ' ';
    }
}

    @AuraEnabled
    public static String getPdfBase64(Id recordId) {
        try{
            Blob pdfContent;
                
            if (Test.isRunningTest()) {
                // Return mock blob for testing
                pdfContent=Blob.valueOf('Test PDF Content');
            } else{
                 PageReference pdfPage = Page.CRM_GeneratePDF_EMB;
            
                  pdfPage.getParameters().put('id', recordId);
                    
                 pdfContent = pdfPage.getContentAsPDF();
            }
             return EncodingUtil.base64Encode(pdfContent);
            
        }
        catch(Exception e){
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = e.getMessage(), Core_Origin__c='CRM_GeneratePDF_EMBController.getPdfBase64', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');          
            throw new AuraHandledException('Failed to generate PDF: ' + e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static void attachFiletoExecutiveMeetingBrief(Id recordId, String base64){
     try{
      List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId=:recordId AND ContentDocument.Title LIKE 'Briefing for%'];
        
      if(!cdlList.isEmpty()){
        delete cdlList;
       }
            
        Executive_Meeting_Brief__c embRecord = [SELECT Id,Name,Core_Executive_Meeting_Brief_Name__c,CRM_PDF_URL__c FROM Executive_Meeting_Brief__c WHERE Id=:recordId];
        ContentVersion cv = new ContentVersion();
        cv.Title= 'Briefing for ' +embRecord.Core_Executive_Meeting_Brief_Name__c;
        cv.PathOnClient = 'Briefing for ' +embRecord.Core_Executive_Meeting_Brief_Name__c +'.pdf';
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.ContentLocation = 'S';
        insert cv;
        
        String contentVersionId = cv.Id;
      
        Id cdId = [SELECT ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocumentLink cdlRec = new ContentDocumentLink();
        cdlRec.ContentDocumentId = cdId;
        cdlRec.LinkedEntityId = recordId;
        cdlRec.ShareType = 'V';
        insert cdlRec;
        String latestPublishedVersionId = cdlRec.ContentDocument.LatestPublishedVersionId;
        
         // Update the Executive_Meeting_Brief__c record with the attachment link
         String attachmentUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + cdId;        
        
        
        if(attachmentUrl!=null){
            embRecord.CRM_PDF_URL__c = attachmentUrl; 
        }
        else{
            embRecord.CRM_PDF_URL__c ='';
        }
        
       
            update embRecord;
     }
     catch(Exception e){
         Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = e.getMessage(), Core_Origin__c='CRM_GeneratePDF_EMBController.attachFiletoExecutiveMeetingBrief', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');          
         insert logEntry;
       }
  }
       
    
}