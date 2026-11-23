/******************************************************************************************************************************************
Class Name  : Core_Log_Entry
Version     : 1.0 (copied from Service Cloud)
Created Date: 10 JAN 2017
Function    : Application error and information logging.

Parameters:
strOrigin: Origin of the log entry - "ipaas" or "SFDC".
strProject: Project generating the log entry - "Entitlement", "Sales", "IPS"
strScope: Identifies high level feature.  Values that match ICS App Logging Tracked Scopes custom label will be logged.
If null is passed, this parameter is ignored and a log record will be created.
strSeverity: Values are info, warn, error, baddata, processed.
strMessage: Short message
strDetails: Detailed information to be logged.
strObjectId: SFDC ID of the record that generated the log entry
strObjectType: sObject type that generated the log entry
ex: Exception object.  The debug info will be stored in Details.

* An exception anywhere in the execution thread could rollback
the insert into the Log Entry entry.
* This may interfere with Web Callouts.
See https://help.salesforce.com/apex/HTViewSolution?id=000003701

Modification Log :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Dave Hood                 01/10/2017              Original version, copied & tweaked from Service Cloud version
*****************************************************************************************************************************************/
public class Core_Log_Entry {
    public List<string> emailsList = new List<String>();
    
    /* strInvocationID ties together multiple calls from the same trigger or controller invocation */
    
    // DH NOTE: I am leaving in the Invocation ID code, from Service Cloud, but not actually storing it since
    // we don't have that field. Need to discuss whether or not we want multiple entries per invocation or not
    // before we implement that.
    static String strInvocationID = UserInfo.getUserId() + '_' + system.now().formatGmt('yyyyMMddkkmmssSS')
        + '_' + String.valueOf((Math.random() * 10).round()).leftpad(3,'0');
    static boolean blStopLogging = false;
    
    // DH NOTE: originally all of these methods had strLogEntryName, but in Sales Cloud, Name is an autonumber field,
    // and can't be written to. So removed it from everything for now. Also added sObjectID and sObjectType, so they
    // can be stored along with the other data.
    
    //Use this method to log Exceptions.  The function will stringify the Exception object and add to Details.
    public static String logEntryWithException(String strOrigin, String strProject, String strScope, String strSeverity, String strMessage,
                                               String strDetails, String strObjectID, String strObjectType, String strTags, Exception ex) {
                                                   return core_Log_Entry(strOrigin, strProject, strScope, strSeverity, strMessage, strDetails, strObjectID, strObjectType, strTags, ex);
                                               }
    
    //Use this method to log informational messages.
    public static String logEntryWithDetails(String strOrigin, String strProject, String strScope, String strSeverity, String strMessage,
                                             String strDetails, String strObjectID, String strObjectType, String strTags) {
                                                 return core_Log_Entry(strOrigin, strProject, strScope, strSeverity, strMessage, strDetails, strObjectID, strObjectType, strTags, null);   
                                             }
    
    /* This function provides common processing for the other methods.
* It's not intended to be called directly
*/
    public static String core_Log_Entry(String strOrigin, String strProject, String strScope, String strSeverity, String strMessage,
                                        String strDetails, String strObjectID, String strObjectType, String strTags, Exception ex) {
                                            try {
                                                /* Custom label to enable/disable tracking of specific Severities. */
                                                String strSeverityTracked = Label.Core_App_Logging_Tracked_Severities;
                                                strSeverity = !String.IsBlank(strSeverity) ? strSeverity : '';
                                                
                                                String strScopeTracked = Label.Core_App_Logging_Tracked_Scopes;
                                                strScope = !String.IsBlank(strScope) ? strScope : '';
                                                
                                                if(strScopeTracked == '0') return '';
                                                
                                                /* Check if tracking is turned on for scope and severity */
                                                boolean blInsert = false;
                                                if(strSeverityTracked.containsIgnoreCase(strSeverity) && (strScopeTracked.containsIgnoreCase(strScope))) {
                                                    blInsert = true;
                                                }
                                                
                                                /* Before inserting log entry, check governor limits */
                                                boolean blGovernorLimitHit = false;
                                                
                                                if(blInsert == true) {
                                                    integer intDMLStmtBuffer = Label.Core_App_Logging_DML_Statements_Buffer.isNumeric() ?
                                                        Integer.valueOf(Label.Core_App_Logging_DML_Statements_Buffer) : 5;
                                                    integer intDMLRowsBuffer = Label.Core_App_Logging_DML_Rows_Buffer.isNumeric() ?
                                                        Integer.valueOf(Label.Core_App_Logging_DML_Rows_Buffer) : 5;
                                                    
                                                    integer intDMLStmtsRemaining = Limits.getLimitDMLStatements() - Limits.getDMLStatements();
                                                    integer intDMLRowsRemaining = Limits.getLimitDMLRows() - Limits.getDMLRows();
                                                    String strDMLStats = 'DML Stmt Buffer: ' + intDMLStmtBuffer + ', ' +
                                                        'DML Stmts Remaining: ' + intDMLStmtsRemaining + ', ' +
                                                        'DML Rows Buffer: ' + intDMLRowsBuffer + ', ' +
                                                        'DML Rows Remaining: ' + intDMLRowsRemaining;
                                                    
                                                    //Check the limits.  Subtracting 2 because the buffer amount is what should be left behind and allow
                                                    //for the limits error record.
                                                    if(((intDMLStmtsRemaining - 2)< intDMLStmtBuffer) || ((intDMLRowsRemaining - 2) < intDMLRowsBuffer)) {
                                                        blGovernorLimitHit = true;
                                                        
                                                        // Replace log entry values with limits error
                                                        //strLogEntryName = 'App Logging Hit Limits';
                                                        strSeverity = Label.Core_App_Logging_Critical_Severity;
                                                        strMessage = '';
                                                        strDetails = strDMLStats;
                                                        ex = null;
                                                    }
                                                }
                                                
                                                /* Create log entry record */
                                                if(blInsert && !blStopLogging) {
                                                    DateTime dtWhen = system.now();
                                                    
                                                    /*if(String.IsBlank(strLogEntryName) == TRUE) {
strLogEntryName = strInvocationID;
}*/
                                                    
                                                    String strDetailsAndEx = '';
                                                    if(String.isBlank(strDetails) == FALSE) {
                                                        strDetailsAndEx = strDetails + '\n';
                                                    }
                                                    
                                                    if( ex != null ) {
                                                        strDetailsAndEx += 'Message: ' + ex.getMessage() + '\n';
                                                        strDetailsAndEx += 'Cause: ' + ex.getCause() + '\n';
                                                        strDetailsAndEx += 'Line Number: ' + ex.getLineNumber() + '\n';
                                                        strDetailsAndEx += 'Stack Trace: ' + ex.getStackTraceString() + '\n';
                                                        strDetailsAndEx += 'Type Name: ' + ex.getTypeName() + '\n';
                                                    }
                                                    
                                                    //Trim all fields to fit
                                                    //strLogEntryName = String.isNotBlank(strLogEntryName) ? strLogEntryName.Left(80) : '';
                                                    strScope = String.isNotBlank(strScope) ? strScope.Left(255) : '';
                                                    strOrigin = String.isNotBlank(strOrigin) ? strOrigin.Left(255) : '';
                                                    strSeverity = String.isNotBlank(strSeverity) ? strSeverity.Left(20) : '';
                                                    strMessage = String.isNotBlank(strMessage) ? strMessage.Left(255) : '';
                                                    strInvocationID = String.isNotBlank(strInvocationID) ? strInvocationID.Left(255) : '';
                                                    strDetailsAndEx = String.isNotBlank(strDetailsAndEx) ? strDetailsAndEx.Left(131072) : '';
                                                    strObjectId = String.isNotBlank(strObjectId) ? strObjectId.Left(36) : '';
                                                    strObjectType = String.isNotBlank(strObjectType) ? strObjectType.Left(255) : '';
                                                    strTags = String.isNotBlank(strTags) ? strTags.Left(255) : '';
                                                    
                                                    Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                                                        //Name = strLogEntryName, // From Service Cloud
                                                        Core_Origin__c = strOrigin,
                                                        Core_Project__c = strProject,
                                                        Core_Scope__c = strScope,
                                                        Core_Severity__c = strSeverity,
                                                        Core_Message__c = strMessage,
                                                        Core_When__c = dtWhen,
                                                        //Core_Status__c = Label.ICS_App_Logging_Default_Status, // From Service Cloud
                                                        //Core_Invocation_ID__c = strInvocationID, // From Service Cloud
                                                        Core_Details__c = strDetailsAndEx,
                                                        Core_sObjectId__c = strObjectID,
                                                        Core_sObjectType__c = strObjectType,
                                                        Core_Tags__c = strTags
                                                    );
                                                    
                                                    if(Core_Log_Entry__c.sObjectType.getDescribe().isCreateable()){ //TWC729-5289 medium severity - Shraddha
                                                        insert objCLE;
                                                    }
                                                    
                                                    if(blGovernorLimitHit) {
                                                        blStopLogging = true;
                                                    }
                                                    
                                                    //return objCLE.Id;
                                                    
                                                    Id objCLEId; //TWC729-5289 medium severity - Shraddha
                                                    if(objCLE != null){
                                                        objCLEId = objCLE.Id;
                                                    }
                                                    return objCLEId;
                                                }            
                                            } catch(Exception e) {
                                                //Do not rethrow and cause error to propagate.
                                            }
                                            return null;
                                        }        
    
    /* Creates log entry with Limits info */
    /*    public static String logEntryWithLimits(String strOrigin, String strProject, String strScope, String strDetails) {
try {
String strMessage = '';
if(Trigger.isExecuting == true) {
if(Trigger.isAfter) {
strMessage += 'Trigger: isAfter ';
} else if(Trigger.isBefore) {
strMessage += 'Trigger: isBefore ';
}
if(Trigger.isInsert) {
strMessage += 'isInsert';
} else if(Trigger.isUpdate) {
strMessage += 'isUpdate';
} else if(Trigger.isDelete) {
strMessage += 'isDelete';
}
}

if(String.isBlank(strDetails)) {
strDetails = '';
}
strDetails += '\n\n';

//            strDetails = strDetails + 'Async Calls: ' + Limits.getAsyncCalls() + '/' + Limits.getLimitAsyncCalls() + '\n';
strDetails = strDetails + 'Callouts: ' + Limits.getCallouts() + '/' + Limits.getLimitCallouts() + '\n';
strDetails = strDetails + 'CPU Time: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime() + '\n';
strDetails = strDetails + 'DML Rows: ' + Limits.getDMLRows() + '/' + Limits.getLimitDMLRows() + '\n';
strDetails = strDetails + 'DML Statements: ' + Limits.getDMLStatements() + '/' + Limits.getLimitDMLStatements() + '\n';
strDetails = strDetails + 'Email Invocations: ' + Limits.getEmailInvocations() + '/' + Limits.getLimitEmailInvocations() + '\n';
strDetails = strDetails + 'Future Calls: ' + Limits.getFutureCalls() + '/' + Limits.getLimitFutureCalls() + '\n';
strDetails = strDetails + 'Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries() + '\n';
strDetails = strDetails + 'Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows();

//return core_Log_Entry('Log Limits', strScope, strOrigin, 'Info',  strMessage, strDetails, null);
return core_Log_Entry(strOrigin, strProject, strScope, 'Info',  strMessage, strDetails, null, null, null);
} catch (Exception e) {
//Do not rethrow and cause error to propagate.           
}
return null;
}*/
    
    
    /****************************************************************************************
*  Discription: Creates log entry for failed records
* Parameter: List of log entry records
*******************************************************************************************/
    
    Public static void createLogEntries(List<Core_Log_Entry__c> listOfLogEntries){
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        
        // insert a log entry
        if(!listOfLogEntries.isEmpty() && !logSwitch.isEmpty()){
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c){
                insert listOfLogEntries;
            }
        }
        
    }
}