/************************************************************************************************************************
Apex Class Name  :  PRM_RetriggerEV_Token_API
Version          : 1.0 
Created Date     : 10 June 2021
Function         : API Callout class to get New EV Token
Modification Log :
* Developer                        Date              Description
* ------------------------------------------------------------------------------------------------------------------------              
* GopiKrishna Vankadari         10/06/2021          Initial version
*************************************************************************************************************************/
Public class PRM_RetriggerEV_Token_API {  
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'Retrigger EV -API to Fetch new EV Token';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_RetriggerEV_Token_API';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    
    public static String reTriggerEV(String loginId){
        String evToken;
        HttpRequest httpReq = new  HttpRequest();
        HttpResponse response = new HttpResponse();
        String requestBody;
        try {                             
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setEndpoint('callout:PRM_EV_Retrigger_Credentials');
            requestBody = constructoutputJSON(loginId);
            httpReq.setBody(requestBody);
            httpReq.setMethod('POST');
            response = new Http().send(httpReq);
            String responseJsonString =EncodingUtil.urlDecode(response.getBody(), 'UTF-8');
            InputJsonResponseWrapper JsonRes =(InputJsonResponseWrapper) JSON.deserialize(responseJsonString, InputJsonResponseWrapper.Class);
            if(response.getStatusCode() != 201){
                CustomException ex = new CustomException();                    
                ex.Message = response.getBody();                          
                ex.StackTraceString = System.Label.PRM_Mulesoft_Api_Error;  
				createLogEntryAPIWrapper obj2=new createLogEntryAPIWrapper();
				obj2.message=ex.getMessage();
				obj2.severity=LOG_ENTRY_INFO;
				obj2.ex=null;
				obj2.inputRequest=ex.getStackTraceString();
				createLogEntry(obj2);//Athr fixes
                //createLogEntry('Failed To Retrieved EV Token', LOG_ENTRY_INFO,ex,EncodingUtil.urlDecode(response.getBody(), 'UTF-8')); 
            }else{
                //Pick and Store the EV Token from Response
                evToken =JsonRes.passwordResetToken;
            }                       
        }catch(Exception ex){  
            createLogEntryAPIWrapper obj2=new createLogEntryAPIWrapper();
            obj2.message=ex.getMessage();
            obj2.severity=LOG_ENTRY_INFO;
            obj2.ex=null;
            obj2.inputRequest=ex.getStackTraceString();
            createLogEntry(obj2);//Athr fixes
            //createLogEntry(ex.getMessage(), LOG_ENTRY_INFO,null, ex.getStackTraceString()); 
        }
        finally {
            // Integration log record creation for EV retrigger request
            if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
                //PRM_IPA_Utility.createIntegrationLog(loginId ,PRM_IPA_Constants.CALLOUT_TYPE_OUTBOUND ,PRM_IPA_Constants.MODULE_SELF_REGISTRATION ,requestBody ,response.getBody() ,response.getStatusCode() ,PRM_IPA_Constants.SYSTEM_NAME_AGS ,'PRM_RetriggerEV_Token_API');
            }
            else{
                //PRM_BulkDataUpload_Batch.listIntegrationLogs.add(PRM_IPA_Utility.createIntegrationLog(loginId ,PRM_IPA_Constants.CALLOUT_TYPE_OUTBOUND ,PRM_IPA_Constants.MODULE_SELF_REGISTRATION ,requestBody ,response.getBody() ,response.getStatusCode() ,PRM_IPA_Constants.SYSTEM_NAME_AGS ,'PRM_RetriggerEV_Token_API'));
            }
        }
        return evToken;
    }
    
    public static String constructoutputJSON(String contactLoginId) {
        outputJsonWrapper jsonoutputMsg =new outputJsonWrapper();
        jsonoutputMsg.loginId = contactLoginId;
        String finalJsonString = JSON.serialize(jsonoutputMsg); 
        return finalJsonString;
    }
    
    /*private static void createLogEntry(String message, String severity,CustomException ex ,String inputRequest){      
        String strDetailsAndEx ='';
        if( ex != null ) {
            strDetailsAndEx += 'Message: ' + ex.Message + '\n';
            strDetailsAndEx += 'Cause: ' + ex.Cause + '\n';
            strDetailsAndEx += 'Line Number: ' + ex.LineNumber + '\n';
            strDetailsAndEx += 'Stack Trace: ' + ex.StackTraceString + '\n';
            strDetailsAndEx += 'Type Name: ' + ex.TypeName + '\n';
        }
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
            Core_Origin__c = LOG_ENTRY_ORIGIN,
            Core_Project__c = LOG_ENTRY_PROJECT,
            Core_Scope__c = LOG_ENTRY_SCOPE,
            Core_Severity__c = severity,
            Core_Message__c =  (message == null || message.length() <= 255 ? message : message.substring(0, 255)),
            Core_When__c = system.now(),
            Core_Details__c = strDetailsAndEx,
            Core_sObjectType__c = 'PRM_EmailLog__c',
            Core_Tags__c = (inputRequest == null || inputRequest.length() <= 255 ? inputRequest : inputRequest.substring(0, 255))
        );
        if(!(System.isBatch() && PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad==true)){
            insert objCLE;
        }
        else{
            PRM_BulkDataUpload_Batch.listCoreLogEntry.add(objCLE);
        }
        
    }*/
    
    public class createLogEntryAPIWrapper{
        public String message{get;set;}
        public String severity{get;set;}
        public CustomException ex {get;set;}
        public String inputRequest{get;set;}
    }//JB

    private static void createLogEntry(createLogEntryAPIWrapper att){      
        String strDetailsAndEx ='';
        if( att.ex != null ) {
            strDetailsAndEx += 'Message: ' + att.ex.Message + '\n';
            strDetailsAndEx += 'Cause: ' + att.ex.Cause + '\n';
            strDetailsAndEx += 'Line Number: ' + att.ex.LineNumber + '\n';
            strDetailsAndEx += 'Stack Trace: ' + att.ex.StackTraceString + '\n';
            strDetailsAndEx += 'Type Name: ' + att.ex.TypeName + '\n';
        }
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
            Core_Origin__c = LOG_ENTRY_ORIGIN,
            Core_Project__c = LOG_ENTRY_PROJECT,
            Core_Scope__c = LOG_ENTRY_SCOPE,
            Core_Severity__c = att.severity,
            Core_Message__c =  (att.message == null || att.message.length() <= 255 ? att.message : att.message.substring(0, 255)),
            Core_When__c = system.now(),
            Core_Details__c = strDetailsAndEx,
            Core_sObjectType__c = 'PRM_EmailLog__c',
            Core_Tags__c = (att.inputRequest == null || att.inputRequest.length() <= 255 ? att.inputRequest : att.inputRequest.substring(0, 255))
        );
        if(!(System.isBatch() && PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad==true)){
            insert objCLE;
        }
        else{
            PRM_BulkDataUpload_Batch.listCoreLogEntry.add(objCLE);
        }
    }
    
    public class CustomException extends Exception {
        public String message {set;get;}
        public Exception cause {set;get;}
        public Integer lineNumber {set;get;}
        public String stackTraceString {set;get;}
        public String typeName {set;get;}
    }
    
    //Wrapper Class for Output JSON Request    
    public class outputJsonWrapper{
        public string loginId;
    }    
    //Wrapper Class for Input JSON Response    
    public class InputJsonResponseWrapper{
        public string passwordResetToken;
    }     
}