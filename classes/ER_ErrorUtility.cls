public with Sharing class ER_ErrorUtility {


    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'Registration';
    
    public static void createLogEntry(String Msg, CustomException ex, String Severity, String scope, String params){
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
                Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT,
                Core_Scope__c = scope,
                Core_Severity__c = Severity,
                Core_Message__c = Msg,
                Core_When__c = system.now(),
                Core_Details__c = strDetailsAndEx,
                Core_sObjectId__c = null,
                Core_sObjectType__c = null,
                Core_Tags__c = params
            );
            if(Schema.sObjectType.Core_Log_Entry__c.isCreateable())
            {insert objCLE;}
            
        }catch(Exception e){
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