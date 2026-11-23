/****************************************************************************************************************************************************
* Class Name      : CRM_EMB_AI_Integration_Outbound
* Version               : 1.0
* Created Date          : 11-04-2025
* Modification Log      :
* Developer            Date             Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------
*                 11-04-2025       class for CDB Outbound Integartion for Executive Meeting Brief Agentic Brief Generation Process
******************************************************************************************************************************************************/
public class CRM_EMB_AI_Integration_Outbound {
    public static Integer LONG_TEXT_AREA_LIMIT = 32768;
    /*****************************************************************************************************************************************
    Method Name:        fetchExecutiveMeetingBriefDetails
    Description:        To Fetch Executive Meeting Brief, MeetingBrief Attendee and Document Details, then serialize it into a JSON string for Integration outbound.
    @Added By:          Sinduja - 11-04-2025
    Modified By:        Date:       Changes:
    ******************************************************************************************************************************************/
    @AuraEnabled
    public static void fetchExecutiveMeetingBriefDetails(List<Id> briefRecordIds)
    {
        try{
            List<Executive_Meeting_Brief__c> briefRecords = new List<Executive_Meeting_Brief__c>();
            List<CRM_Meeting_Brief_Attendee__c> attendees = new List<CRM_Meeting_Brief_Attendee__c>();
            Map<Id, List<CRM_Meeting_Brief_Attendee__c>> briefIdToAttendeesMap = new Map<Id, List<CRM_Meeting_Brief_Attendee__c>>();
            List<ContentDocumentLink> contentDocLinksList = new List<ContentDocumentLink>();
            Map<Id, List<String>> briefIdToContentVersionsMap = new Map<Id, List<String>>();
            Map<String,String> executiveBriefIdToJsonMap = new Map<String,String>();
            Map<String,Object> executiveBriefIdToAccPulseMap = new Map<String,Object>();
            if(briefRecordIds != null){
                briefRecords = [SELECT Id, Account__c,CRM_Intels_Meeting_Objectives__c, CRM_Other_Partys_Meeting_Objectives__c,CRM_Most_Critical_Messages_to_Get_Across__c,
                                Industry_Insights_Political_Climate__c, How_They_Buy_Sell__c,CRM_Investor_Scouting_Report__c, CRM_Additional_Legal_Guidance__c
                                FROM Executive_Meeting_Brief__c WHERE Id IN :briefRecordIds];
                
                
                contentDocLinksList = [SELECT Id,LinkedEntityId,ContentDocument.LatestPublishedVersionId,ContentDocument.LatestPublishedVersion.FileExtension,
                                       ContentDocument.Title from ContentDocumentLink WHERE LinkedEntityId IN:briefRecordIds];
                
                // Initialize map for all brief IDs
                for(Id briefId : briefRecordIds) {
                    briefIdToContentVersionsMap.put(briefId, new List<String>());
                }
                
                // Filter and group content versions by brief ID and allowed file formats
                Set<String> allowedFormats = new Set<String>{'txt','pdf','docx','msg','pptx'};
                    
                    for(ContentDocumentLink cdl : contentDocLinksList) {
                        String fileExtension = cdl.ContentDocument.LatestPublishedVersion.FileExtension;
                        String title = cdl.ContentDocument.Title;
                        if(fileExtension != null && allowedFormats.contains(fileExtension.toLowerCase()) && !title.startsWith('Briefing for')) {
                            if(!briefIdToContentVersionsMap.containsKey(cdl.LinkedEntityId)) {
                                briefIdToContentVersionsMap.put(cdl.LinkedEntityId, new List<String>{cdl.ContentDocument.LatestPublishedVersionId});
                            }
                            else{
                                briefIdToContentVersionsMap.get(cdl.LinkedEntityId).add(cdl.ContentDocument.LatestPublishedVersionId);
                            }
                        }
                    }
				
                //Account pulse callout
                executiveBriefIdToAccPulseMap= CRM_Account_Pulse_Integration.getAccountPulse(briefRecordIds);
            }
            // Creating mainWrapper for each brief
            for(Executive_Meeting_Brief__c briefRecord:briefRecords){
                // Build Claim wrapper
                ExecutiveMeetingBriefWrapper briefWrap = new ExecutiveMeetingBriefWrapper();
                briefWrap.executiveMeetingBriefId = briefRecord.Id;
                briefWrap.accountId = briefRecord.Account__c;
                briefWrap.intelMeetingObjectives = briefRecord.CRM_Intels_Meeting_Objectives__c;
                briefWrap.otherPartyMeetingObjectives = briefRecord.CRM_Other_Partys_Meeting_Objectives__c;
                briefWrap.mostCriticalMessage = briefRecord.CRM_Most_Critical_Messages_to_Get_Across__c;
                briefWrap.howTheyBuySell = briefRecord.How_They_Buy_Sell__c;
                briefWrap.investorScoutingReport = briefRecord.CRM_Investor_Scouting_Report__c;

                if(briefIdToContentVersionsMap.containsKey(briefRecord.Id)){
                    // Initialize the list if it's null
                    if(briefWrap.contentVersionDetails == null) {
                        briefWrap.contentVersionDetails = new List<ContentVersionDetailsWrapper>();
                    }
                    for(String cdId : briefIdToContentVersionsMap.get(briefRecord.Id)) {
                        ContentVersionDetailsWrapper cdWrapper = new ContentVersionDetailsWrapper();
                        cdWrapper.contentVersionId = cdId;
                        briefWrap.contentVersionDetails.add(cdWrapper);
                    }
                    
                }
                Object accPulseValue = executiveBriefIdToAccPulseMap.get(briefRecord.Id);
                if (accPulseValue != null) {
                    briefWrap.acc_pulse = accPulseValue;
                }
                
                // Add content version IDs for this brief
                String jsonPayload = JSON.serialize(briefWrap);
                executiveBriefIdToJsonMap.put(briefRecord.Id,jsonPayload);
            }
            if(!executiveBriefIdToJsonMap.isEmpty()){
                makeCDBCallout(executiveBriefIdToJsonMap);
            }
            deleteExistingRecords(briefRecordIds);
        }
        catch (Exception exp) {       
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = exp.getMessage(), Core_Origin__c='CRM_EMB_AI_Integration_Outbound.fetchExecutiveMeetingBriefDetails', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');          
            insert logEntry;
        }
    }
    
    /***********************************************************************************************************
Method Name:        makeCDBCallout
Description:        To call sendCDBPayload method with CDB Payload and handle retry logic.
@Added By:          Sinduja - 11-04-2025
Modified By:        Date:       Changes:
************************************************************************************************************/
    @Future(callout=true)
    public static void makeCDBCallout(Map<String, String> executiveBriefIdToJsonMap)
    {
        try {
            List<Core_CDB_Integration_Log__c> cdbLogList = new List<Core_CDB_Integration_Log__c>();
            List<Executive_Meeting_Brief__c> executiveMeetingBriefList = new List<Executive_Meeting_Brief__c>();
            
            // Process each payload
            for (String execBriefId : executiveBriefIdToJsonMap.keySet()) {
                
                String payload = executiveBriefIdToJsonMap.get(execBriefId);
                
                if (String.isBlank(payload)) {
                    continue;
                }
                // Send payload to CDB
                HttpResponse res = sendCDBPayload(payload);
                Boolean isSuccess = (res != null && (res.getStatus() == 'SUCCESS' || res.getStatus() == 'OK')) ? true : false;
                
                if(isSuccess){
                    Executive_Meeting_Brief__c executiveRec = new Executive_Meeting_Brief__c(Id=execBriefId);
                    executiveRec.CRM_Agentic_Drafting_Status__c = 'In Progress';
                    executiveMeetingBriefList.add(executiveRec);
                }
                
                // Create log record
                Core_CDB_Integration_Log__c logRec = new Core_CDB_Integration_Log__c();
                logRec.Core_Integration_Type__c = 'CDB Executive Meeting Brief Integration';
                logRec.Core_Record_Id__c = execBriefId;
                logRec.Core_Log_Status_Nm__c = isSuccess ? 'Successful' : 'Failed';
                logRec.Core_Status_Code__c = (res != null) ? String.valueOf(res.getStatusCode()) : '';
                logRec.Core_Status_Message__c = (res != null) ? res.getStatus() : '';
                logrec.Core_Integration_Direction_Nm__c ='Outbound';
                cdbLogList.add(logRec);
                
            }
            if(!executiveMeetingBriefList.isEmpty()){
                update executiveMeetingBriefList;
            }
            // Insert log records if we have any
            if (!cdbLogList.isEmpty()) {
                Database.UpsertResult[] upsertResultList = Database.upsert(cdbLogList,Core_CDB_Integration_Log__c.Core_Record_Id__c, false);
                // Process insert errors with consolidated logging
                Map<String, List<Database.Error>> executiveIdToUpsertErrorsMap = new Map<String, List<Database.Error>>();
                Map<String, String> executiveIdToBaseMessageMap = new Map<String, String>();
                for (Integer i = 0; i < upsertResultList.size(); i++) {
                    Database.UpsertResult upsertResult = upsertResultList[i];
                     if (!upsertResult.isSuccess()) {
                        String execIdForError = cdbLogList[i].Core_Record_Id__c;
                        List<Database.Error> erros = executiveIdToUpsertErrorsMap.containsKey(execIdForError) ? executiveIdToUpsertErrorsMap.get(execIdForError) : new List<Database.Error>();
                        erros.addAll(upsertResult.getErrors());
                        executiveIdToUpsertErrorsMap.put(execIdForError, erros);
                        executiveIdToBaseMessageMap.put(execIdForError, 'CDB Integration Log upsert failed for record: ' + execIdForError);
                    }
                }
                if (!executiveIdToUpsertErrorsMap.isEmpty()) {
                    collectAndLogDbErrors( executiveIdToUpsertErrorsMap, executiveIdToBaseMessageMap,'Core_CDB_Integration_Log__c');
                }
            }
          
        }
        catch (Exception exp) {
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = exp.getMessage(), Core_Origin__c='CRM_EMB_AI_Integration_Outbound.makeCDBCallout', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');          
            insert logEntry;
        }
    }
    
    
    /***********************************************************************************************************
    Method Name:        sendCDBPayload
    Description:        To send the payload to CDB system
    @Added By:          Sinduja - 06-11-2025
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    
    public static HttpResponse sendCDBPayload(String payload)
    {
        try{
            String execEndPoint = Core_CRM_Utility.getCRMLabel('CRM_EMB_AI_Endpoint');
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SalesCRM_Apigee'+execEndPoint);
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');
            req.setBody(payload);
            HttpResponse resp = new Http().send(req);
            return resp;
        }catch(Exception exp){
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = exp.getMessage(), Core_Origin__c='CRM_EMB_AI_Integration_Outbound.sendCDBPayload', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');          
            insert logEntry;
            return null;
        }
    }
    /***********************************************************************************************************
    Method Name:        collectAndLogDbErrors
    Description:       Method to log database errors from both Insert and Upert operations
    Added By:           Sinduja - 06-11-2025
    Modified By:        Date:       Changes:
    **********************************************************************************************************/
    
    public static void collectAndLogDbErrors(
        Map<String, List<Database.Error>> errorsByRecordKeyMap,
        Map<String, String> baseMessageByRecordKeyMap,
        String sObjectApiName
    ) {
        if (errorsByRecordKeyMap == null || errorsByRecordKeyMap.isEmpty()) {
            return;
        }
        List<Map<String, String>> coreLogMaps = new List<Map<String, String>>();
        for (String recordIdentifier : errorsByRecordKeyMap.keySet()) {
            List<Database.Error> errors = errorsByRecordKeyMap.get(recordIdentifier);
            if (errors == null || errors.isEmpty()) {
                continue;
            }
            List<String> errorMessages = new List<String>();
            for (Database.Error err : errors) {
                String errorMessage = String.valueOf(err.getStatusCode()) + ': ' +
                    String.valueOf(err.getFields()) + ': ' +
                    String.valueOf(err.getMessage());
                errorMessages.add(errorMessage);
            }
            if (errorMessages.isEmpty()) {
                continue;
            }
            List<String> errorMsgs = new List<String>{
                'Record ' + recordIdentifier + ' | ' + String.join(errorMessages, ' | ')
                    };
                        Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Origin__c', 'CRM_EMB_AI_Integration_Outbound');
            coreLogMap.put('Core_Severity__c', 'Low');
            coreLogMap.put('Core_sObjectType__c', sObjectApiName);
            coreLogMap.put('Core_Project__c', 'Sales CRM');
            coreLogMap.put('Core_Message__c', baseMessageByRecordKeyMap != null ? baseMessageByRecordKeyMap.get(recordIdentifier) : null);
            
            String serialized = JSON.serialize(errorMsgs);
            Integer strLength = serialized.length();
            String details = strLength < LONG_TEXT_AREA_LIMIT ? serialized : serialized.substring(0, LONG_TEXT_AREA_LIMIT);
            coreLogMap.put('Core_Details__c', details);
            coreLogMaps.add(coreLogMap);
        }
        if (!coreLogMaps.isEmpty()) {
            createLogEntries(coreLogMaps);
        }
    }
    
    /***********************************************************************************************************
    Method Name:        createLogEntries
    Description:       Method to create log entries
    Added By:           Sinduja - 06-11-2025
    Modified By:        Date:       Changes:
    **********************************************************************************************************/
    public static void createLogEntries(List<Map<String, String>> coreLogMaps){
        try {
            if (coreLogMaps == null || coreLogMaps.isEmpty()) {
                return;
            }
            List<Core_Log_Entry__c> logsToInsert = new List<Core_Log_Entry__c>();
            DateTime dtWhen = System.now();
            Map<String, Schema.SObjectField> logFields = Schema.SObjectType.Core_Log_Entry__c.fields.getMap();
            
            for (Map<String, String> coreLogMap : coreLogMaps) {
                if (coreLogMap == null || coreLogMap.isEmpty()) continue;
                Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
                for (String key : coreLogMap.keySet()) {
                    if (logFields.containsKey(key)) {
                        Schema.DescribeFieldResult field = logFields.get(key).getDescribe();
                        Integer length = field.getLength();
                        String value = String.valueOf(coreLogMap.get(key));
                        objCLE.put(key, value != null ? value.left(length) : null);
                    }
                }
                objCLE.put('Core_When__c', dtWhen);
                logsToInsert.add(objCLE);
            }
            if (!logsToInsert.isEmpty()) {
                Database.insert(logsToInsert, false);
            }
        } catch(Exception e) {
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = e.getMessage(), Core_Origin__c='CRM_EMB_AI_Integration_Outbound.createLogEntries', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');          
            insert logEntry;
        }
    }  
     /***********************************************************************************************************
    Method Name:        deleteExistingRecords
    Description:       Method to delete existing agenda and backgroundtalkingpoints
    Added By:           Sinduja - 13-11-2025
    Modified By:        Date:       Changes:
    **********************************************************************************************************/
    @Future
    public static void deleteExistingRecords(List<Id> briefIds) {
        try {
            
            List<CRM_Meeting_Brief_Agenda__c> briefAgendaList = new List<CRM_Meeting_Brief_Agenda__c>();
            List<CRM_MeetingBriefBackground_TalkingPoints__c> briefBgTalkingList = new List<CRM_MeetingBriefBackground_TalkingPoints__c>();
            
            briefAgendaList = [SELECT Id,CRM_Executive_Meeting_Brief__c,CRM_AI_Generated__c FROM CRM_Meeting_Brief_Agenda__c WHERE CRM_Executive_Meeting_Brief__c=:briefIds AND CRM_AI_Generated__c=TRUE];
               
            briefBgTalkingList = [SELECT Id,CRM_Executive_Meeting_Brief__c,CRM_AI_Generated__c FROM CRM_MeetingBriefBackground_TalkingPoints__c WHERE CRM_Executive_Meeting_Brief__c=:briefIds AND CRM_AI_Generated__c=TRUE];

            if(!briefAgendaList.isEmpty()){
                Database.DeleteResult[] agendaResults = Database.delete(briefAgendaList, false);
            }
            
            if(!briefBgTalkingList.isEmpty()){
                Database.DeleteResult[] bgResults = Database.delete(briefBgTalkingList, false);
            }
        } catch (Exception exp) {
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c(
                Core_Message__c = 'Error', 
                Core_Details__c = exp.getMessage(), 
                Core_Origin__c = 'CRM_EMB_AI_Integration_Outbound.deleteExistingRecords', 
                Core_Severity__c = 'Low', 
                Core_When__c = System.Now(), 
                Core_Project__c = 'Sales CRM'
            );          
            insert logEntry;
        }
    }
    /***********************************************************************************************************
    Method Name:        updateExecutiveBriefStatus
    Description:        Update Agentic Drafting Status to 'In Progress'
    @Added By:          Sinduja - 06-11-2025
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    @AuraEnabled
    public static void updateExecutiveBriefStatus(List<Id> briefIds) {
        List<Executive_Meeting_Brief__c> briefsToUpdate = new List<Executive_Meeting_Brief__c>();
    	
        for(Id briefId : briefIds) {
            if(briefId != null) {
                Executive_Meeting_Brief__c briefRec = new Executive_Meeting_Brief__c(Id = briefId);
                briefRec.CRM_Agentic_Drafting_Status__c = 'In Progress';
                briefsToUpdate.add(briefRec);
            }
        }
        
        if(!briefsToUpdate.isEmpty()) {
            Database.SaveResult[] saveResultList= Database.update(briefsToUpdate);
        }
            
      }
    //ContentVersion Wrapper
    public class ContentVersionDetailsWrapper{
        public String contentVersionId;
    }
    
    //Executive Meeting Brief Wrapper
    public class ExecutiveMeetingBriefWrapper
    {
        public String executiveMeetingBriefId;
        public Id accountId;
        public String intelMeetingObjectives;
        public String otherPartyMeetingObjectives;
        public String mostCriticalMessage;
        public String industryInsights;
        public String howTheyBuySell;
        public String investorScoutingReport;
        public List<ContentVersionDetailsWrapper> contentVersionDetails;
        public Object acc_pulse;
    }
}