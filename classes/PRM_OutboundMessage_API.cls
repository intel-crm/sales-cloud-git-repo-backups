public class PRM_OutboundMessage_API {
	public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'POST Outbound Messages To External System';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_OutboundMessage_API';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    
   // string payload=PRM_IntegrationOutboundMessageUtility.createPayload()
    public static String outboundMessage(String payload){
        String evToken;
        try {                             
            HttpRequest httpReq = new  HttpRequest(); 
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setEndpoint('callout:endpointurl');
            httpReq.setBody(constructoutputJSON(payload));
            httpReq.setMethod('POST');
            HttpResponse response = new Http().send(httpReq);
            system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
            String responseJsonString =EncodingUtil.urlDecode(response.getBody(), 'UTF-8');
            InputJsonResponseWrapper JsonRes =(InputJsonResponseWrapper) JSON.deserialize(responseJsonString, InputJsonResponseWrapper.Class);
            if(response.getStatusCode() != 201){
                CustomException ex = new CustomException();                    
                ex.Message = response.getBody();                          
                ex.StackTraceString = System.Label.PRM_Mulesoft_Api_Error;                              
                System.debug('Exception In Retrigger Call'+ex.Message);   
                System.debug('Exception Trace'+ex.StackTraceString); 
                createLogEntry('Failed To Retrieved EV Token', LOG_ENTRY_INFO,ex,EncodingUtil.urlDecode(response.getBody(), 'UTF-8')); 
            }else{
                //Pick and Store the EV Token from Response
                evToken =JsonRes.passwordResetToken;
            }                       
        }catch(Exception ex){  
            system.debug('Error Cause ==>Log Entry -->'+ ex.getCause());
            system.debug('Error Message==>Log Entry -->'+ ex.getMessage());               
            createLogEntry(ex.getMessage(), LOG_ENTRY_INFO,null, ex.getStackTraceString()); 
        }
        return evToken;
    }
    
    public static String constructoutputJSON(String payload) {
        outputJsonWrapper jsonoutputMsg =new outputJsonWrapper();
        jsonoutputMsg.payload = payload;
        String finalJsonString = JSON.serialize(jsonoutputMsg); 
        return finalJsonString;
    }
    
    private static void createLogEntry(String message, String severity,CustomException ex ,String inputRequest){      
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
        insert objCLE;
        system.debug('Log Entry Id ==>'+objCLE.Id);
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
        public string payload;
    }    
    //Wrapper Class for Input JSON Response    
    public class InputJsonResponseWrapper{
        public string passwordResetToken;
    }     
}