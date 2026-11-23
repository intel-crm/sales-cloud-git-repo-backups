@SuppressWarnings('PMD')
@RestResource(urlMapping='/RegistrationValidations/*')
global class ER_WhiteListBlackList {
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'RegistrationValidations API';
    public static final String LOG_ENTRY_SCOPE    = 'ER_WhiteListBlackList class';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    
    @HttpPost
    global static ER_WhiteListBlackList_Model.WhitelistBlackListResult GetWhitelistBlacklistDomains(){
        try{     
            ER_WhiteListBlackList_Utility.startTime = system.now().getTime();
            ER_WhitelistBlackList_Input input = ER_WhitelistBlackList_Input.parse(RestContext.request.requestBody.toString());
            System.debug(RestContext.request.requestBody.toString());
            if(String.isBlank(input.ProgramCode) && String.isBlank(input.EntitlementName)) {
                return ER_WhiteListBlackList_Utility.generateError('Program Code is mandatory');
            }
            return ER_WhiteListBlackList_Utility.getWhiteListBlackListDomains(input.ProgramCode,input.EntitlementName);
        }
        catch(Exception ex)
        {           
            CustomException custEx = new CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();
            System.debug('Error : '+custEx.Message);
            createLogEntry('Error in RegistrationValidations API', custEx, LOG_ENTRY_ERROR, RestContext.request.requestBody.toString());  
            return ER_WhiteListBlackList_Utility.generateException(ex);
        }
    }
    
    public static void createLogEntry(String Msg, CustomException ex, String Severity, String params){
        try{         
            
            String strDetailsAndEx = '';
            Id recordId = null;
            
            if( ex != null ) {
                strDetailsAndEx += 'Message: ' + ex.Message + '\n';
                strDetailsAndEx += 'Cause: ' + ex.Cause + '\n';
                strDetailsAndEx += 'Line Number: ' + ex.LineNumber + '\n';
                strDetailsAndEx += 'Stack Trace: ' + ex.StackTraceString + '\n';
                strDetailsAndEx += 'Type Name: ' + ex.TypeName + '\n';
            }
            Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                //Name = strLogEntryName, // From Service Cloud
                Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT,
                Core_Scope__c = LOG_ENTRY_SCOPE,
                Core_Severity__c = Severity,
                Core_Message__c = Msg,
                Core_When__c = system.now(),
                Core_Details__c = strDetailsAndEx,
                Core_sObjectId__c = null,
                Core_sObjectType__c = null,
                Core_Tags__c = params
            );
            insert objCLE;
        }
        catch(Exception e)
        {
            system.debug('Error Cause ==>Log Entry -->'+ e.getCause());
            system.debug('Error Message==>Log Entry -->'+ e.getMessage());
        }
    }
    
    public class CustomException extends Exception {
        public String message {set;get;}
        public Exception cause {set;get;}
        public Integer lineNumber {set;get;}
        public String stackTraceString {set;get;}
        public String typeName {set;get;}
    }
}