/* @File Name : CRM_GenerateWord_EMBController.cls
* @Description :This controller is used to generate pdf for executive meeting brief
* @Last Modified By :Swati Paraste
* @Last Modified On : April 29, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 29, 2025 |Swati Paraste   | Initial Version
**/

public class CRM_GenerateWord_EMBController {
    
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
    
    public CRM_GenerateWord_EMBController() {
        
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        record = [
            
            SELECT Id, Name,CRM_Start_Date__c,CRM_Start_Time__c,CRM_Agentic_Attendee_Bio__c,CRM_Scheduled_End_Date__c,CRM_Scheduled_End_Time_Only__c, Core_Executive_Meeting_Brief_Name__c,CRM_Intels_Meeting_Objectives__c,CRM_Most_Critical_Messages_to_Get_Across__c,CRM_Other_Partys_Meeting_Objectives__c,Account__c,CRM_PreparedBy__r.Name,CRM_Location__c,CRM_Location__Street__s,CRM_Location__City__s,CRM_Location__PostalCode__s,CRM_Location__StateCode__s,CRM_Location__CountryCode__s,CRM_Dress_Code__c,CRM_Scheduled_End_Time_txt__c,CRM_Scheduled_Start_Time_txt__c,
            
            Industry_Insights_Political_Climate__c,How_They_Buy_Sell__c,CRM_Investor_Scouting_Report__c,CRM_Additional_Legal_Guidance__c,CRM_Attendee_Bio_s__c,CRM_Brief_Reviewer__r.Name
            
            FROM Executive_Meeting_Brief__c
            
            WHERE Id = :recordId
            
            LIMIT 1
            
        ];
        String baseUrl = ApexPages.currentPage().getHeaders().get('Host');

        relatedAccount = [SELECT Id, Name FROM Account WHERE Id = :record.Account__c LIMIT 1];
        accountUrl = 'https://' + baseUrl + '/' + relatedAccount.Id;    
        if (!String.isBlank(record.CRM_Intels_Meeting_Objectives__c) || !String.isBlank(record.CRM_Most_Critical_Messages_to_Get_Across__c) || !String.isBlank(record.CRM_Other_Partys_Meeting_Objectives__c)  ){
            formatted_CRM_Intels_Meeting_Objectives = reduceSizeForWord(convertImageToDataURI(record.CRM_Intels_Meeting_Objectives__c,'CRM_Intels_Meeting_Objectives__c','Executive_Meeting_Brief__c'));
            formatted_CRM_Most_Critical_Messages_to_Get_Across = reduceSizeForWord(convertImageToDataURI(record.CRM_Most_Critical_Messages_to_Get_Across__c,'CRM_Most_Critical_Messages_to_Get_Across__c','Executive_Meeting_Brief__c'));
            formatted_CRM_Other_Partys_Meeting_Objectives = reduceSizeForWord(convertImageToDataURI(record.CRM_Other_Partys_Meeting_Objectives__c,'CRM_Other_Partys_Meeting_Objectives__c','Executive_Meeting_Brief__c'));      
        }
        if(!String.isBlank(record.Industry_Insights_Political_Climate__c)||!String.isBlank(record.How_They_Buy_Sell__c)|| !String.isBlank(record.CRM_Investor_Scouting_Report__c)|| !String.isBlank(record.CRM_Additional_Legal_Guidance__c)||!String.isBlank(record.CRM_Attendee_Bio_s__c)){
            formatted_Industry_Insights_Political_Climate = reduceSizeForWord(convertImageToDataURI(record.Industry_Insights_Political_Climate__c,'Industry_Insights_Political_Climate__c','Executive_Meeting_Brief__c'));
            formatted_How_They_Buy_Sell = reduceSizeForWord(convertImageToDataURI(record.How_They_Buy_Sell__c,'How_They_Buy_Sell__c','Executive_Meeting_Brief__c'));
            formatted_CRM_Investor_Scouting_Report = reduceSizeForWord(convertImageToDataURI(record.CRM_Investor_Scouting_Report__c,'CRM_Investor_Scouting_Report__c','Executive_Meeting_Brief__c'));
            formatted_CRM_Additional_Legal_Guidance = reduceSizeForWord(convertImageToDataURI(record.CRM_Additional_Legal_Guidance__c,'CRM_Additional_Legal_Guidance__c','Executive_Meeting_Brief__c'));
            formatted_CRM_Attendee_Bio = reduceSizeForWord(convertImageToDataURI(record.CRM_Attendee_Bio_s__c,'CRM_Attendee_Bio_s__c','Executive_Meeting_Brief__c'));
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
        
        List<CRM_Meeting_Brief_Agenda__c> agendaList = [SELECT Id,CRM_Start_Date__c,CRM_Start_Time_Only__c,CRM_End_Date__c,CRM_End_Time_Only__c,CRM_Start_Time_txt__c,CRM_End_Time_txt__c,CRM_Presenters_Conversation_Lead__r.Name,CRM_Meeting_Agenda_Items__c FROM CRM_Meeting_Brief_Agenda__c WHERE CRM_Executive_Meeting_Brief__c=:recordId];
        if(agendaList.size()>0){
            for(CRM_Meeting_Brief_Agenda__c agendaRec:agendaList){
                //StartTime_DetailFieldList.add(String.valueOf(agendaRec.CRM_Start_Time_txt__c));
                //EndTime_DetailFieldList.add(String.valueOf(agendaRec.CRM_End_Time_txt__c));

                String formattedDate = agendaRec.CRM_Start_Date__c != null ? agendaRec.CRM_Start_Date__c.format() : '';

                // Get the formatted time (e.g., 1:30:00 AM)
                // Note: Time fields don't have a direct .format(), so we use a dummy DateTime
                String formattedTime = '';
                if (agendaRec.CRM_Start_Time_Only__c != null) {
                    Time t = agendaRec.CRM_Start_Time_Only__c;
                    // Create a dummy DateTime to use the format method for AM/PM
                    formattedTime = DateTime.newInstance(Date.today(), t).format('h:mm:ss a');
                }

                // Add to your list
                StartTime_DetailFieldList.add(formattedDate + ' ' + formattedTime);

                //StartTime_DetailFieldList.add(String.valueOf(agendaRec.CRM_Start_Date__c)+ ' ' +String.valueOf(agendaRec.CRM_Start_Time_Only__c));

                String formattedEndDate = agendaRec.CRM_End_Date__c != null ? agendaRec.CRM_End_Date__c.format() : '';

                // Get the formatted time (e.g., 1:30:00 AM)
                // Note: Time fields don't have a direct .format(), so we use a dummy DateTime
                String formattedEndTime = '';
                if (agendaRec.CRM_End_Time_Only__c != null) {
                    Time t = agendaRec.CRM_End_Time_Only__c;
                    // Create a dummy DateTime to use the format method for AM/PM
                    formattedEndTime = DateTime.newInstance(Date.today(), t).format('h:mm:ss a');
                }

                // Add to your list
                EndTime_DetailFieldList.add(formattedEndDate + ' ' + formattedEndTime);

                //EndTime_DetailFieldList.add(String.valueOf(agendaRec.CRM_End_Date__c)+ ' ' +String.valueOf(agendaRec.CRM_End_Time_Only__c));
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

            formatted_Background_Objective = reduceSizeForWord(convertImageToDataURI(Background_Objective,'CRM_Background__c','CRM_MeetingBriefBackground_TalkingPoints__c'));
            formatted_Reactive_Talking_Points = reduceSizeForWord(convertImageToDataURI(Reactive_Talking_Points,'CRM_Reactive_Talking_Points__c','CRM_MeetingBriefBackground_TalkingPoints__c'));
            formatted_Proactive_Talking_Points = reduceSizeForWord(convertImageToDataURI(Proactive_Talking_Points,'CRM_Proactive_Talking_Points__c','CRM_MeetingBriefBackground_TalkingPoints__c'));
           
            if (!String.isBlank(Agenda_Topic) || !String.isBlank(formatted_Background_Objective) || !String.isBlank(formatted_Proactive_Talking_Points) || !String.isBlank(formatted_Reactive_Talking_Points)) {
                background_talking_point.add(new List<String>{ Agenda_Topic,formatted_Background_Objective,formatted_Proactive_Talking_Points,formatted_Reactive_Talking_Points  });
            }
        }
    }   

    /*public static string reduceSizeForWord(String html){
         String reduceSIze= html;
                reduceSIze = reduceSIze.replaceAll(
                    '<img',
                    '<img width="250"'
                );
        return reduceSIze;

    }*/
    /*****************************************
    Method name:- reduceSizeForWord
    Added by & Date:- Aswin Selvaraj & 07-May-2026
    Release:- WW22'2026'
    Description:- Method to reduce the size of the image in the rich text area field to render in the generated word document (added this method explicitly
                  for word document generation). Not applicable for pdf generation
    ******************************************/
   public static String reduceSizeForWordForWord(String reduceSize) {
        
        String html = reduceSize;
        if (String.isBlank(reduceSize)) {return '';
        }

        reduceSize = reduceSize.replaceAll('<img', '<img style="width:80%;max-width:300px;height:auto"');
        
        // Handle tables - only fix width/cropping issues, preserve all other styling
        if (html.contains('<table')) {
            // Simple approach: Remove width attributes and add fixed width
            html = html.replaceAll('width="[^"]*"', '');
            html = html.replaceAll('width:\\s*[^;]*;?', '');
            
            // Add table-layout fixed to all tables
            html = html.replaceAll('<table', '<table style="width:100%;table-layout:fixed;"');
            
            // Remove colgroup and col elements
            html = html.replaceAll('<colgroup>.*?</colgroup>', '');
            html = html.replaceAll('<col[^>]*/?>', '');
            
            // Add word-wrap to all td elements
            html = html.replaceAll('<td', '<td style="word-wrap:break-word;"');
        }
        // Normalize line breaks
        html = html.replace('<p>', '');
        html = html.replace('</p>', '<br/><br/>'); 
        html = html.replace('<div>', '');
        html = html.replace('</div>', '');

        // Remove Word-only tags safely (no regex)
        while (html.contains('<o:p>')) {
            Integer start = html.indexOf('<o:p>');Integer endOf = html.indexOf('</o:p>', start);
            if (endOf > start) {html = html.substring(0, start) + html.substring(endOf + 6);
            } else break;
        }

        // Force image width (Word-friendly)
        html = html.replace(' width="', ' data-old-width="');
        html = html.replace('<img', '<img width="400"');
        return html;
    }
    public static String reduceSizeForWord(String reduceSize) {

        if (String.isBlank(reduceSize)) {return '';
        }

        String html = reduceSize;

        // Images
        html = html.replace('&lt;img', '&lt;img style="width:80%;max-width:300px;height:auto"');

        if (html.contains('&lt;table')) {

            // Remove width attributes safely
            html = html.replace(' width="', ' data-old-width="');

            // Add fixed width to tables
            html = html.replace('&lt;table', '&lt;table style="width:100%;table-layout:fixed;"');

            // Remove colgroup (safe loop)
            while (html.contains('&lt;colgroup&gt;')) {
                Integer start = html.indexOf('&lt;colgroup&gt;');
                Integer endPos = html.indexOf('&lt;/colgroup&gt;', start);
                if (endPos > start) {
                    html = html.substring(0, start) + html.substring(endPos + 13);
                } else break;
            }

            // Remove col tags
            while (html.contains('&lt;col')) {
                Integer start = html.indexOf('&lt;col');
                Integer endPos = html.indexOf('&gt;', start);
                if (endPos > start) {
                    html = html.substring(0, start) + html.substring(endPos + 4);
                } else break;
            }

            // Add wrap to td
            html = html.replace('&lt;td', '&lt;td style="word-wrap:break-word;"');
        }

        // Normalize line breaks
        html = html.replace('&lt;p&gt;', '');
        html = html.replace('&lt;/p&gt;', '&lt;br/&gt;&lt;br/&gt;');
        html = html.replace('&lt;div&gt;', '');
        html = html.replace('&lt;/div&gt;', '');

        // Remove Word-only tags
        while (html.contains('&lt;o:p&gt;')) {
            Integer start = html.indexOf('&lt;o:p&gt;');
            Integer endPos = html.indexOf('&lt;/o:p&gt;', start);
            if (endPos > start) {
                html = html.substring(0, start) + html.substring(endPos + 6);
            } else break;
        }

        // Force image width
        html = html.replace('&lt;img', '&lt;img width="400"');

        return html;
    }
    /*****************************************
    Method name:- convertImageToDataURI
    Added by & Date:- Aswin Selvaraj & 07-May-2026
    Release:- WW22'2026'
    Description:- Method to replace the content from rich text area field, extract the url (domain url & other ids)(added this method explicitly
                  for word document generation). Not applicable for pdf generation
    ******************************************/
    public static String convertImageToDataURI(String html,String FIELD_API, String OBJECT_API) {
        if (String.isBlank(html)) return html;
        Map<String, String> params = new Map<String, String>();
        system.debug('html-->'+html);
          Map<String, String> replacements = new Map<String, String>();
        // Pattern to find the refid (0EM...)
        Pattern p = Pattern.compile('<img[^>]+src="([^"]+)"[^>]*>');
        Matcher m = p.matcher(html);
        
        while (m.find()) {
            
            String originalUrl = m.group(1);
               
                // Only process relative Salesforce URLs
                if (originalUrl.contains('rtaImage') || originalUrl.contains('servlet')) {
                    // Fetch the image as a blob

                    if (!replacements.containsKey(originalUrl)) {
                        
                        String dataUri = fetchImageAsBase64(originalUrl,FIELD_API,OBJECT_API);
                        if (dataUri != null) {replacements.put(originalUrl, dataUri);
                        }
                    }
                    
                }
    
        }

        for (String originalUrl : replacements.keySet()) {
        html = html.replace(originalUrl, replacements.get(originalUrl));
        }
        return html;
    } //Aswin

    /*****************************************
    Method name:- fetchImageAsBase64
    Added by & Date:- Aswin Selvaraj & 07-May-2026
    Release:- WW22'2026'
    Description:- Http method to convert the rich text area image into base64 format (added this method explicitly
                  for word document generation). Not applicable for pdf generation
    ******************************************/
    public static String fetchImageAsBase64(String originalUrl, String FIELD_API, String OBJECT_API) {
        Map<String, String> params = new Map<String, String>();
        originalUrl = originalUrl.replace('&amp;', '&');

        String queryString = originalUrl.substringAfter('?');

        for (String pair : queryString.split('&')) {
            List<String> keyValue = pair.split('=');
            if (keyValue.size() == 2) {
                params.put(keyValue[0], keyValue[1]);
            }
        }
        String RECORD_ID   = params.get('eid');
        String IMAGE_ID = params.get('refid');
        
        // Build absolute URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
		String lightningUrl = baseUrl.replace('.my.salesforce.com', '.lightning.force.com');
        System.debug('baseUrl-->'+lightningUrl);
        
        String absoluteUrl;

        if(OBJECT_API=='Executive_Meeting_Brief__c'){
            absoluteUrl =
                lightningUrl +
                '/services/data/v66.0/sobjects/Executive_Meeting_Brief__c/' +
                RECORD_ID +
                '/richTextImageFields/' +
                FIELD_API +
                '/' +
                IMAGE_ID;
        }else if(OBJECT_API=='CRM_MeetingBriefBackground_TalkingPoints__c'){
            absoluteUrl =lightningUrl +'/services/data/v66.0/sobjects/CRM_MeetingBriefBackground_TalkingPoints__c/' +RECORD_ID +'/richTextImageFields/' +FIELD_API +'/' +IMAGE_ID;
        }
		
        if (Test.isRunningTest()) {
            return 'data:image/png;base64,' +
                   EncodingUtil.base64Encode(Blob.valueOf('TEST'));
        }else{

        //String absoluteUrl='https://intel--crmdevsls3.sandbox.lightning.force.com/services/data/v66.0/sobjects/Executive_Meeting_Brief__c/aCwWA000000E1130AC/richTextImageFields/CRM_Attendee_Bio_s__c/0EMWA000000wNM1';
    	system.debug('absoluteUrl-->'+absoluteUrl);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(absoluteUrl);
        req.setMethod('GET');
        // Pass the current session for authentication
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Accept', '*/*');
        Http http = new Http();
        HttpResponse res = http.send(req);
        // Follow redirect manually if needed
        if (res.getStatusCode() == 301 || res.getStatusCode() == 302) {
            String redirectUrl = res.getHeader('Location');
            system.debug('redirectUrl-->'+redirectUrl);
            req.setEndpoint(redirectUrl);
            res = http.send(req);
        }
        if (res.getStatusCode() == 200) {
            Blob imgBlob = res.getBodyAsBlob();
            // Detect content type from response header
            String contentType = res.getHeader('Content-Type');
            if (String.isBlank(contentType)) contentType = 'image/png';
            // Strip params like "image/png; charset=utf-8"
            contentType = contentType.split(';')[0].trim();
            return 'data:' + contentType + ';base64,' + EncodingUtil.base64Encode(imgBlob);
        }
    	}
        return null; // Return null if image can't be fetched
       
    }
   
    public String getFormattedSchedule() {

        // Combine into a DateTime to use the .format() method
        DateTime dt = DateTime.newInstance(record.CRM_Start_Date__c, record.CRM_Start_Time__c);
        String start = dt.format('M/d/yyyy h:mm a');

        // Combine into a DateTime to use the .format() method
        DateTime dtEnd = DateTime.newInstance(record.CRM_Scheduled_End_Date__c, record.CRM_Scheduled_End_Time_Only__c);
        String endDt = dtEnd.format('M/d/yyyy h:mm a');
        return start + ' - ' + endDt;
    }
    /*****************************************
    Method name:- generateWordAndCreateFile
    Added by & Date:- Aswin Selvaraj & 07-May-2026
    Release:- WW22'2026'
    Description:- Method to generate the word document (added this method explicitly
                  for word document generation). Not applicable for pdf generation
    ******************************************/
     @AuraEnabled
    public static Id generateWordAndCreateFile(Id recordId) {
        try {
            Blob wordBlob;

            if (Test.isRunningTest()) {
                wordBlob = Blob.valueOf('Test Word Content');
            } else {
                PageReference wordPage = Page.CRM_GenerateWord_EMB;
                wordPage.getParameters().put('id', recordId);
                wordBlob = wordPage.getContent();
            }

            List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId=:recordId AND ContentDocument.Title LIKE 'Briefing for%'];
        
            if(!cdlList.isEmpty()){
                delete cdlList;
            }

             Executive_Meeting_Brief__c embRecord = [SELECT Id,Name,Core_Executive_Meeting_Brief_Name__c,CRM_PDF_URL__c FROM Executive_Meeting_Brief__c WHERE Id=:recordId];
            // ✅ Create Word File
            ContentVersion cv = new ContentVersion();
           cv.Title= 'Briefing for ' +embRecord.Core_Executive_Meeting_Brief_Name__c;
            cv.PathOnClient = 'Briefing for ' +embRecord.Core_Executive_Meeting_Brief_Name__c +'.doc';
            cv.VersionData = wordBlob;
            insert cv;

            String contentVersionId = cv.Id;
      
            Id cdId = [SELECT ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

            // ✅ Link to record (Work Document)
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cdId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;

            String latestPublishedVersionId = cdl.ContentDocument.LatestPublishedVersionId;
        
         // Update the Executive_Meeting_Brief__c record with the attachment link
         String attachmentUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + cdId;        
        
        
        if(attachmentUrl!=null){
            embRecord.CRM_PDF_URL__c = attachmentUrl; 
        }
        else{embRecord.CRM_PDF_URL__c ='';
        }
        
       
            update embRecord;
            return cdl.ContentDocumentId;

        } catch (Exception e) {Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = e.getMessage(), Core_Origin__c='CRM_GeneratePDF_EMBController.generateWordAndCreateFile', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');throw new AuraHandledException('Failed to generate word: ' + e.getMessage());
        }
    }    
}