/************************************************************************************************************************
Apex Class Name  : PRM_EmailReminderUtilityEV_Test
Version          : 1.0 
Created Date     : 28 Feb 2022
Function         : Test Class for PRM_RetriggerEV_Token_API
Modification Log :
* Developer                        Date              Description
* ------------------------------------------------------------------------------------------------------------------------              
* Sayeed Javid          02/28/2022          Initial version 
*************************************************************************************************************************/
Public class PRM_EmailReminderUtilityEV {  
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'Retrigger EV -API to Fetch new EV Token';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_RetriggerEV_Token_API';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    
    public static String reTriggerEVAcr(String loginId){
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
            system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
            String responseJsonString =EncodingUtil.urlDecode(response.getBody(), 'UTF-8');
            InputJsonResponseWrapper JsonRes =(InputJsonResponseWrapper) JSON.deserialize(responseJsonString, InputJsonResponseWrapper.Class);
            if(response.getStatusCode() != 201){
                CustomException ex = new CustomException();                    
                ex.Message = response.getBody();                          
                ex.StackTraceString = System.Label.PRM_Mulesoft_Api_Error;                              
                System.debug('Exception In Retrigger Call'+ex.Message);   
                System.debug('Exception Trace'+ex.StackTraceString); 
                //  createLogEntry('Failed To Retrieved EV Token', LOG_ENTRY_INFO,ex,EncodingUtil.urlDecode(response.getBody(), 'UTF-8')); 
            }else{
                //Pick and Store the EV Token from Response
                evToken =JsonRes.passwordResetToken;
            }                       
        }catch(Exception ex){  
            system.debug('Error Cause ==>Log Entry -->'+ ex.getCause());
            system.debug('Error Message==>Log Entry -->'+ ex.getMessage());               
            //   createLogEntry(ex.getMessage(), LOG_ENTRY_INFO,null, ex.getStackTraceString()); 
        }
        finally {
            // Integration log record creation for EV retrigger request
            //   PRM_IPA_Utility.createIntegrationLog(loginId ,PRM_IPA_Constants.CALLOUT_TYPE_OUTBOUND ,PRM_IPA_Constants.MODULE_SELF_REGISTRATION ,requestBody ,response.getBody() ,response.getStatusCode() ,PRM_IPA_Constants.SYSTEM_NAME_AGS ,'PRM_RetriggerEV_Token_API');
        }
        return evToken;
    }
    
    public static String constructoutputJSON(String contactLoginId) {
        outputJsonWrapper jsonoutputMsg =new outputJsonWrapper();
        jsonoutputMsg.loginId = contactLoginId;
        String finalJsonString = JSON.serialize(jsonoutputMsg); 
        return finalJsonString;
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