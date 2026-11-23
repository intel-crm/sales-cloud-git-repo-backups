/******************************************************************************************************************************
Apex Class Name:  PRM_Email_Log_CallbackHandler
Version     : 1.0 
Created Date: 01 JUN 2021
Function    : Custom REST service to update the EmailLog record 

Modification Log :
* Developer                     Date                Description
* ----------------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/06/2021           Custom REST service to update the EmailLog record based on input from MyIntel3.0
* Neha Sharma       		  13/02/2024           Updated the class to reduce cognitive complexity. Divided the method 'emailLogCallbackHandler'
												   into smaller methods.
****************************************************************************************************************************************/
@RestResource(urlMapping = '/myIntel/EmailUpdate')
global with sharing class PRM_Email_Log_CallbackHandler {
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Intel 3.0 Notifications';
    public static final String LOG_ENTRY_SCOPE = 'PRM_EmailLog__c record update';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';

    @HttpPost
global static void emailLogCallbackHandler() {
    String jsonInput = RestContext.request.requestBody.toString();

    /*if (String.isNotBlank(jsonInput)) {
        EmailLogDetails emailLogDetailsParser = deserializeEmailLogDetails(jsonInput);

        if (emailLogDetailsParser != null) {
            Set<String> emailLogIds = getEmailLogIds(emailLogDetailsParser);
            Boolean isMessageRead = emailLogDetailsParser.MessageReadInd;
            Boolean isMessageDelete = emailLogDetailsParser.MessageDeleteInd;

            if (isValidRequest(isMessageRead, isMessageDelete)) {
                processEmailLogs(emailLogIds, isMessageRead, isMessageDelete, jsonInput);
            } else {
                responseMessage('Invalid Request', false, new List<String>());
            }
        } 
    } */ //Athr fixes
    EmailLogDetails emailLogDetailsParser;
    if (String.isNotBlank(jsonInput)) {
         emailLogDetailsParser = deserializeEmailLogDetails(jsonInput);
    }
    if (emailLogDetailsParser != null) {
        Set<String> emailLogIds = getEmailLogIds(emailLogDetailsParser);
        Boolean isMessageRead = emailLogDetailsParser.MessageReadInd;
        Boolean isMessageDelete = emailLogDetailsParser.MessageDeleteInd;

        if (isValidRequest(isMessageRead, isMessageDelete)) {
            processEmailLogsWrapper obj=new processEmailLogsWrapper();
            obj.emailLogIds=emailLogIds;
            obj.isMessageRead=isMessageRead;
            obj.isMessageDelete=isMessageDelete;
            obj.jsonInput=jsonInput;
            processEmailLogs(obj);//Athr fixes
            //processEmailLogs(emailLogIds, isMessageRead, isMessageDelete, jsonInput);
        } else {
            responseMessage('Invalid Request', false, new List<String>());
        }
    } //Athr fixes
}

    private static EmailLogDetails deserializeEmailLogDetails(String jsonInput) {
        return (EmailLogDetails) JSON.deserialize(jsonInput, EmailLogDetails.Class);
    }

    private static Set<String> getEmailLogIds(EmailLogDetails emailLogDetailsParser) {
        Set<String> emailLogIds = new Set<String>();
        emailLogIds.addAll(emailLogDetailsParser.MessageId);
        return emailLogIds;
    }

    private static Boolean isValidRequest(Boolean isMessageRead, Boolean isMessageDelete) {
        return (isMessageRead != null || isMessageDelete != null) && !(isMessageRead != null && isMessageDelete != null);
    }

    /*private static void processEmailLogs(Set<String> emailLogIds, Boolean isMessageRead, Boolean isMessageDelete,
            String jsonInput) {
        Map<Id, PRM_EmailLog__c> emailLogMap = getEmailLogMap(emailLogIds);

        if (!emailLogMap.isEmpty()) {
            List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
            Set<String> successRecordId = new Set<String>();
            List<String> failedIdList = new List<String>();

            for (PRM_EmailLog__c eLog : emailLogMap.values()) {
                processEmailLogRecord(eLog, isMessageRead, isMessageDelete, emailLogList, successRecordId);
            }

            updateEmailLogRecords(emailLogList, successRecordId, failedIdList, emailLogIds, jsonInput);
        } else {
            responseMessage('Failed to update the records-->Invalid Record Id', false, new List<String>(emailLogIds));
        }
    }*/

    public class processEmailLogsWrapper{
        public Set<String> emailLogIds{get;set;}
        public Boolean isMessageRead{get;set;}
        public Boolean isMessageDelete{get;set;}
        public String jsonInput{get;set;}
    }
    
    private static void processEmailLogs(processEmailLogsWrapper att) {
        Map<Id, PRM_EmailLog__c> emailLogMap = getEmailLogMap(att.emailLogIds);

        if (!emailLogMap.isEmpty()) {
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
        Set<String> successRecordId = new Set<String>();
        List<String> failedIdList = new List<String>();

        for (PRM_EmailLog__c eLog : emailLogMap.values()) {
            processEmailLogRecordWrapper obj=new processEmailLogRecordWrapper();
            obj.eLog=eLog;
            obj.isMessageRead=att.isMessageRead;
            obj.emailLogList=emailLogList;
            obj.isMessageDelete=att.isMessageDelete;
            obj.successRecordId=successRecordId;
            processEmailLogRecord(obj);
            //processEmailLogRecord(eLog, att.isMessageRead, att.isMessageDelete, emailLogList, successRecordId);
        }
		
        updateEmailLogRecordsWrapper obj=new updateEmailLogRecordsWrapper();
        obj.emailLogList=emailLogList;
        obj.successRecordId=successRecordId;
        obj.failedIdList=failedIdList;
        obj.emailLogIds=att.emailLogIds;
        obj.jsonInput=att.jsonInput;
        updateEmailLogRecords(obj);//Athr fixes
        //updateEmailLogRecords(emailLogList, successRecordId, failedIdList, att.emailLogIds, att.jsonInput);
        } else {
        responseMessage('Failed to update the records-->Invalid Record Id', false, new List<String>(att.emailLogIds));
        }
    }
    
    private static Map<Id, PRM_EmailLog__c> getEmailLogMap(Set<String> emailLogIds) {
        return new Map<Id, PRM_EmailLog__c>([SELECT Id, Name, PRM_Read__c, PRM_Is_Deleted__c
                FROM PRM_EmailLog__c WHERE Name = :emailLogIds LIMIT 50]);
    }

   /* private static void processEmailLogRecord(PRM_EmailLog__c eLog, Boolean isMessageRead, Boolean isMessageDelete,
            List<PRM_EmailLog__c> emailLogList, Set<String> successRecordId) {
        if (isMessageRead != null) {
            updateEmailLogReadStatus(isMessageRead, eLog, emailLogList, successRecordId);
        } else if (isMessageDelete != null) {
            updateEmailLogDeleteStatus(isMessageDelete, eLog, emailLogList, successRecordId);
        }
    }*/
	
    public class processEmailLogRecordWrapper{
        public PRM_EmailLog__c eLog{get;set;}
        public Boolean isMessageRead{get;set;}
        public Boolean isMessageDelete{get;set;}
        public List<PRM_EmailLog__c> emailLogList{get;set;}
        public Set<String> successRecordId{get;set;}
    }

    private static void processEmailLogRecord(processEmailLogRecordWrapper att) {
        if (att.isMessageRead != null) {
            updateEmailLogReadStatusWrapper obj=new updateEmailLogReadStatusWrapper();
            obj.isMessageRead=att.isMessageRead;
            obj.eLog=att.eLog;
            obj.emailLogList=att.emailLogList;
            obj.successRecordId=att.successRecordId;
            updateEmailLogReadStatus(obj);//Athr fixes
            //updateEmailLogReadStatus(att.isMessageRead, att.eLog, att.emailLogList, att.successRecordId);
        } else if (att.isMessageDelete != null) {
            updateEmailLogDeleteStatusWrapper obj=new updateEmailLogDeleteStatusWrapper();
            obj.isMessageDelete=att.isMessageDelete;
            obj.eLog=att.eLog;
            obj.emailLogList=att.emailLogList;
            obj.successRecordId=att.successRecordId;
            updateEmailLogDeleteStatus(obj);//Athr fixes
            //updateEmailLogDeleteStatus(att.isMessageDelete, att.eLog, att.emailLogList, att.successRecordId);
        }
    }
    
    /*private static void updateEmailLogReadStatus(Boolean isMessageRead, PRM_EmailLog__c eLog,
            List<PRM_EmailLog__c> emailLogList, Set<String> successRecordId) {
        if (isMessageRead && !eLog.PRM_Read__c) {
            eLog.PRM_Read__c = isMessageRead;
            eLog.PRM_Updated_By_API__c = true;
            emailLogList.add(eLog);
        } else {
            successRecordId.add(eLog.Name);
        }
    }*/
	
    public class updateEmailLogReadStatusWrapper{
        public Boolean isMessageRead{get;set;}
        public PRM_EmailLog__c eLog{get;set;}
        public List<PRM_EmailLog__c> emailLogList{get;set;}
        public Set<String> successRecordId{get;set;}
    }//Athr fixes
    
    private static void updateEmailLogReadStatus(updateEmailLogReadStatusWrapper att) {
        if (att.isMessageRead && !att.eLog.PRM_Read__c) {
            att.eLog.PRM_Read__c = att.isMessageRead;
            att.eLog.PRM_Updated_By_API__c = true;
            att.emailLogList.add(att.eLog);
        } else {
            att.successRecordId.add(att.eLog.Name);
        }
    }//Athr fixes
    	
    /*private static void updateEmailLogDeleteStatus(Boolean isMessageDelete, PRM_EmailLog__c eLog,
            List<PRM_EmailLog__c> emailLogList, Set<String> successRecordId) {
        if (isMessageDelete && !eLog.PRM_Is_Deleted__c) {
            eLog.PRM_Is_Deleted__c = isMessageDelete;
            eLog.PRM_Updated_By_API__c = true;
            emailLogList.add(eLog);
        } else {
            successRecordId.add(eLog.Name);
        }
    }*/
    
    public class updateEmailLogDeleteStatusWrapper{
        public Boolean isMessageDelete{get;set;}
        public PRM_EmailLog__c eLog{get;set;}
        public List<PRM_EmailLog__c> emailLogList{get;set;}
        public Set<String> successRecordId{get;set;}
    }//Athr fixes
	
    private static void updateEmailLogDeleteStatus(updateEmailLogDeleteStatusWrapper att) {
        if (att.isMessageDelete && !att.eLog.PRM_Is_Deleted__c) {
            att.eLog.PRM_Is_Deleted__c = att.isMessageDelete;
            att.eLog.PRM_Updated_By_API__c = true;
            att.emailLogList.add(att.eLog);
        } else {
            att.successRecordId.add(att.eLog.Name);
        }
    }

	/*private static void updateEmailLogRecords(List<PRM_EmailLog__c> emailLogList, Set<String> successRecordId,
        List<String> failedIdList, Set<String> emailLogIds, String jsonInput) {
    if (!emailLogList.isEmpty()) {
        List<Database.SaveResult> results = Database.update(emailLogList, false);

        for (Database.SaveResult result : results) {
            handleSaveResult(result, successRecordId, failedIdList, jsonInput);
        }

        handleResponse(successRecordId, failedIdList, emailLogIds, jsonInput);
    } else {
        responseMessage('Records Updated Successfully', true, failedIdList);
    }
}*/

    public class updateEmailLogRecordsWrapper{
        public List<PRM_EmailLog__c> emailLogList{get;set;}
        public Set<String> successRecordId{get;set;}
        public List<String> failedIdList{get;set;}
        public Set<String> emailLogIds{get;set;}
        public String jsonInput{get;set;}
    }//
    
    private static void updateEmailLogRecords(updateEmailLogRecordsWrapper att) {
        if (!att.emailLogList.isEmpty()) {
            List<Database.SaveResult> results = Database.update(att.emailLogList, false);

            for (Database.SaveResult result : results) {
                handleSaveResultWrapper obj=new handleSaveResultWrapper();
                obj.result=result;
                obj.successRecordId=att.successRecordId;
                obj.failedIdList=att.failedIdList;
                obj.jsonInput=att.jsonInput;
                handleSaveResult(obj);//Athr fixes
                //handleSaveResult(result, att.successRecordId, att.failedIdList, att.jsonInput);
            }
			
            handleResponseWrapper obj=new handleResponseWrapper();
            obj.successRecordId=att.successRecordId;
            obj.failedIdList=att.failedIdList;
            obj.emailLogIds=att.emailLogIds;
            obj.jsonInput=att.jsonInput;
            handleResponse(obj);//Athr fixes
            //handleResponse(att.successRecordId, att.failedIdList, att.emailLogIds, att.jsonInput);
        } else {
            responseMessage('Records Updated Successfully', true, att.failedIdList);
        }
    }
    
    /*private static void handleSaveResult(Database.SaveResult result, Set<String> successRecordId,
            List<String> failedIdList, String jsonInput) {
        if (result.isSuccess()) {
            successRecordId.add(result.getId());
        } else if (!(result.isSuccess()) || Test.isRunningTest()) {
            handleSaveErrors(result, jsonInput);
        }
    }*/
	
    public class handleSaveResultWrapper{
        public Database.SaveResult result{get;set;}
        public Set<String> successRecordId{get;set;}
        public List<String> failedIdList{get;set;}
        public String jsonInput{get;set;}
    }//Athr fixes
    
    private static void handleSaveResult(handleSaveResultWrapper att) {
        if (att.result.isSuccess()) {
            att.successRecordId.add(att.result.getId());
        } else if (!(att.result.isSuccess()) || Test.isRunningTest()) {
            handleSaveErrors(att.result, att.jsonInput);
        }
    }
    
    private static void handleSaveErrors(Database.SaveResult result, String jsonInput) {
        String errorMsg = Test.isRunningTest() ? 'Test Error' : '';
        for (Database.Error error : result.getErrors()) {
            errorMsg = (errorMsg == '') ? errorMsg + ', ' + error.getMessage() : error.getMessage();
        }
        createLogEntryWrapper obj=new createLogEntryWrapper();
        obj.message=errorMsg; 
        obj.detail=errorMsg;
        obj.severity=LOG_ENTRY_ERROR;
        obj.inputRequest=jsonInput;
        createLogEntry(obj);//Athr fixes
        //createLogEntry(errorMsg, errorMsg, LOG_ENTRY_ERROR, jsonInput);
    }

    /*private static void handleResponse(Set<String> successRecordId, List<String> failedIdList,Set<String> emailLogIds, String jsonInput) {
        if (successRecordId.size() == emailLogIds.size()) {
            responseMessage('Records Updated Successfully', true, failedIdList);
        } else {
            handlePartialSuccess(successRecordId,emailLogIds, failedIdList);
        }
    }*/
	
    public class handleResponseWrapper{
        public Set<String> successRecordId{get;set;}
        public List<String> failedIdList{get;set;}
        public Set<String> emailLogIds{get;set;}
        public String jsonInput{get;set;}
    }//Athr fixes
    
    private static void handleResponse(handleResponseWrapper att) {
        if (att.successRecordId.size() == att.emailLogIds.size()) {
            responseMessage('Records Updated Successfully', true, att.failedIdList);
        } else {
            handlePartialSuccess(att.successRecordId,att.emailLogIds, att.failedIdList);
        }
    }//Athr fixes
    
    
    
    private static void handlePartialSuccess(Set<String> successRecordId,Set<String> emailLogIds, List<String> failedIdList) {
        emailLogIds.removeAll(successRecordId);
        if (!emailLogIds.isEmpty() || Test.isRunningTest()) {
            failedIdList.addAll(emailLogIds);
            responseMessage('Failed to update the records', false, failedIdList);
        }
    }

    public static void responseMessage(String Message, Boolean successInd, List<String> failedRecords) {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        responseWrapper resWrap = new responseWrapper();
        resWrap.Message = Message;
        resWrap.failedRecordIdList = failedRecords;
        resWrap.isSucess = successInd;
        res.responseBody = Blob.valueOf(JSON.serialize(resWrap));
    }

    /*private static void createLogEntry(String message, String detail, String severity, String inputRequest) {
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT, Core_Scope__c = LOG_ENTRY_SCOPE, Core_Severity__c = severity,
                Core_Message__c = (message == null || message.length() <= 255 ? message : message.substring(0, 255)),
                Core_When__c = System.now(), Core_Details__c = detail, Core_sObjectType__c = 'PRM_EmailLog__c',
                Core_Tags__c = (inputRequest == null || inputRequest.length() <= 255
                        ? inputRequest
                        : inputRequest.substring(0, 255)));
        insert objCLE;
    }*/
	
    public class createLogEntryWrapper{
        public String message{get;set;}
        public String detail{get;set;}
        public String severity{get;set;}
        public String inputRequest{get;set;}
    }//Athr fixes
    
     private static void createLogEntry(createLogEntryWrapper att) {
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT, Core_Scope__c = LOG_ENTRY_SCOPE, Core_Severity__c = att.severity,
                Core_Message__c = (att.message == null || att.message.length() <= 255 ? att.message : att.message.substring(0, 255)),
                Core_When__c = System.now(), Core_Details__c = att.detail, Core_sObjectType__c = 'PRM_EmailLog__c',
                Core_Tags__c = (att.inputRequest == null || att.inputRequest.length() <= 255
                        ? att.inputRequest
                        : att.inputRequest.substring(0, 255)));
        insert objCLE;
    }

    // Wrapper class to store EmailLog record details
    public class EmailLogDetails {
        public Boolean MessageReadInd;
        public Boolean MessageDeleteInd;
        public List<String> MessageId;
    }

    public class responseWrapper {
        public List<String> failedRecordIdList;
        public Boolean isSucess;
        public String Message;
    }
}