/******************************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_UtilityClass
* Test Class  : Core_MDF_CCP_UtilityClass_Test
* Version     : 1.0 
* Created Date: 9-7-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel – Narayani Perachi      9/7/2018                     updateListAndLogErrors() - Perform Database update and Log the errors
*
* Intel – Narayani Perachi      9/7/2018                     logErrorinLogObject() - Create a instance in Log entry object to capture only failures
* Intel - Narayani Perachi      9/24/2018                    Changed method name from core_Log_Entry to createLogEntry as per Code Scan suggestions
* Intel - Narayani Perachi      9/24/2018                    Changed variable name from log_fields to logFields as per Code Scan suggestions
* Intel - Narayani Perachi      9/24/2018                    Added without sharing to class Core_MDF_CCP_UtilityClass
* Intel - Narayani Perachi      12/26/2018                   Added Environment Label to the Mail subject to make it more readable
* Intel - NP(11630236)          10/23/2019                   Edited the Subject of the logging record
*******************************************************************************************************************************************************/
public without sharing class Core_MDF_CCP_UtilityClass{
    
    //Method to perform Update action to DB and to Log errors
    public static Map<String, Object> updateListAndLogErrors(List<SObject> tobeupdated, String logEntryMsg)
    {
        
        // Database method to update the records in List
       
        Map<string, Object> resultMap = new Map<String,Object>();
        Map<id,string> idAndUpdateStatus = new Map<id,string>();
        Try{
        Database.SaveResult[] toBeUpdatedList = Database.update(tobeupdated, false);
       
        
                // Iterate through each returned result by the method
                for (Database.SaveResult sr : toBeUpdatedList) 
                {
                   if (sr.isSuccess()) 
                       {
                          // This condition will be executed for successful records and will fetch the ids of successful records
                           
                           idAndUpdateStatus.put(sr.getId(),'Success'); 
                       } 
                    else 
                        {
                            idAndUpdateStatus.put(sr.getId(),'Failed');
                          // This condition will be executed for failed records
                              for(Database.Error objErr : sr.getErrors()) 
                                  {
                                                               
                                     // Printing error message in Debug log
                                     
                                     logEntryMsg += '\nFailed to Update:' + sr.getId() + '\t' + objErr.getMessage() + '\t' + objErr.getFields();
                                  }
                       }
                }
        resultMap.put('DatabaseResult', idAndUpdateStatus);
        resultMap.put('errorMessage', logEntryMsg);
        } catch(Exception e){
            //system.debug(e.getMessage());
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return resultMap;
        
    }
    
    //Call Log object to log errors
    public static void logErrorinLogObject(string errorMessage,string objectName)
    {
            String subject = Label.Core_MDF_CCP_Support_Email_Subject + ' ' +  objectName;
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Details__c', errorMessage);
            coreLogMap.put('Core_Message__c', Label.Core_MDF_SFDC_Environment + ': ' + subject);
            coreLogMap.put('Core_Origin__c', objectName);
            coreLogMap.put('Core_Project__c',Label.Core_MDF_Program_Name);
            coreLogMap.put('Core_Scope__c',objectName);
            coreLogMap.put('Core_Severity__c', 'Critical');
            coreLogMap.put('Core_Support_Email__c', Label.Core_MDF_CCP_Support_Email);
            coreLogMap.put('Core_Support_Link__c', Label.Core_MDF_CCP_Support_Link);
            coreLogMap.put('Core_Tags__c', objectName + '\t' + 'Co-Marketing') ;
        
            // Highlight: Unused Local Variable - 14285 
            // String errorText = createLogEntry(coreLogMap);
            createLogEntry(coreLogMap);
    }
    
    /***************************************************************************************************** 
    Method Name:        logErrorAsNormal
    @return  :          void
    @parameters:        Error Message details and Object Name
    Description:        Exception which are generated due Custom Validation are capture in normal Severity in Log Entry.
    Added By:           Accenture - Sandesh H - 05/09/2023
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void logErrorAsNormal(string errorMessage,string objectName)
    {
            String subject = Label.Core_MDF_CCP_Support_Email_Subject + ' ' +  objectName;
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Details__c', errorMessage);
            coreLogMap.put('Core_Message__c', Label.Core_MDF_SFDC_Environment + ': ' + subject);
            coreLogMap.put('Core_Origin__c', objectName);
            coreLogMap.put('Core_Project__c',Label.Core_MDF_Program_Name);
            coreLogMap.put('Core_Scope__c',objectName);
            coreLogMap.put('Core_Severity__c', 'Normal');
            coreLogMap.put('Core_Support_Email__c', Label.Core_MDF_CCP_Support_Email);
            coreLogMap.put('Core_Support_Link__c', Label.Core_MDF_CCP_Support_Link);
            coreLogMap.put('Core_Tags__c', objectName + '\t' + 'Co-Marketing') ;
        
            // Highlight: Unused Local Variable - 14285
            // String errorText = createLogEntry(coreLogMap);
            createLogEntry(coreLogMap);
    }

// Create Log Object by passing the logobject field names and values in the Map    
    public static String createLogEntry(Map<String, String> coreLogMap){
        
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        try {
            
            DateTime dtWhen = system.now();
            Map<String, Schema.SObjectField> logFields = Schema.SObjectType.Core_Log_Entry__c.fields.getMap();
            if(coreLogMap != null && coreLogMap.size() > 0){    
                for(String key:coreLogMap.keySet()){
                    System.debug('Key'+key);
                    System.debug('val'+coreLogMap.get(key));      
                    if(logFields.containsKey(key)){
                        Schema.DescribeFieldResult field= logFields.get(key).getDescribe();    
                        Integer length = field.getLength();
                        String value = String.valueOf(coreLogMap.get(key));                        
                        objCLE.put(key, value.left(length));                        
                    }
                }
                
                
                if(objCLE != null){
                    objCLE.put('Core_When__c',dtWhen);
                    Database.insert(objCLE);
                    
                    return objCLE.id;
                }
            }                      
        } catch(Exception e) {
            System.debug('@@@ *** App Logging Failed ' + e.getMessage());
            System.debug('@@@ *** Limits.getDmlStatements() ' + Limits.getDmlStatements());
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return null;    
    }   
    /***************************************************************************************************** 
    Method Name:        getErrorDetails
    @return  :          String
    @parameters:        Exception - This will contain the Exception that is caught in various other classes. This 
                        will be called from the logError method.
    Description:        Whenever an exception is passed as an argument, it will fetch all the details from the 
                        Exception and return the formed String.
    Added By:           Accenture - SB - 09/14/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static String getErrorDetails(Exception e){
        return 'Class & Method Name = ' + e.getStackTraceString()?.substringBefore(':') + ';\n' +
               'Exception Message = ' + e.getMessage() + ';\n' +
               'LineNumber = ' + String.valueOf(e.getLineNumber()) + ';\n' +
               'StackTrace = ' + e.getStackTraceString() + ';\n' +
               'Cause =' + e.getCause() + ';\n' +
               'Exception Type =' + e.getTypeName() + ';\n' +
               'Logged in user = ' + UserInfo.getName();
    }

    /***************************************************************************************************** 
    Method Name:        getErrorDetailsWithCustomMessage
    @return  :          String
    @parameters:        Exception - This will contain the Exception that is caught in various other classes. This 
                        will be called from the logError method.
    Description:        Whenever an exception is passed as an argument, it will fetch all the details from the 
                        Exception and return the formed String including additional message passed
    Added By:           Accenture - Vikas Soni 22/05/2026
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static String getErrorDetailsWithAdditionalMessage(Exception e, String additionalMessage){
        return 'Class & Method Name = ' + e.getStackTraceString()?.substringBefore(':') + ';\n' +
               'Exception Message = ' + e.getMessage() + ';\n' +
               'Additional Exception Message = ' + additionalMessage + ';\n' +
               'LineNumber = ' + String.valueOf(e.getLineNumber()) + ';\n' +
               'StackTrace = ' + e.getStackTraceString() + ';\n' +
               'Cause =' + e.getCause() + ';\n' +
               'Exception Type =' + e.getTypeName() + ';\n' +
               'Logged in user = ' + UserInfo.getName();
    }
    
    /***************************************************************************************************** 
    Method Name:        logError
    @return  :          void
    @parameters:        Exception - This will contain the Exception that is caught in various other classes.
    Description:        Whenever an exception is passed as an argument, it will call the getErrorDetails method and
                        pass the string returned to create the Log Entry record through the logErrorinLogObject method.
    Added By:           Accenture - SB - 09/14/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void logError(Exception e){
    String message = e.getMessage();
        
        if(message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            
            logErrorAsNormal(getErrorDetails(e), e.getStackTraceString().substringBefore(':'));
        }
        else{
           
            logErrorinLogObject(getErrorDetails(e), e.getStackTraceString().substringBefore(':'));
        }
    }
    /***************************************************************************************************** 
    Method Name:        logError
    @return  :          void
    @parameters:        Exception - This will contain the Exception that is caught in various other classes.
    Description:        Whenever an exception is passed as an argument along with additional message, it will call the getErrorDetails method and
                        pass the string returned to create the Log Entry record through the logErrorinLogObject method.
    Added By:           Accenture - Vikas Soni - 22/05/2026
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void logErrorWithAdditionalMessage(Exception e, String additionalMessage){
    String message = e.getMessage();
        
        if(message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            logErrorAsNormal(getErrorDetails(e), e.getStackTraceString().substringBefore(':'));
        }
        else{
            logErrorinLogObject(getErrorDetailsWithAdditionalMessage(e, additionalMessage), e.getStackTraceString().substringBefore(':'));
        }
    }
     /***************************************************************************************************** 
    Method Name:        getErrorDetails
    @return  :          String
    @parameters:        Exception - This will contain the Exception that is caught in various other classes. This 
                        will be called from the logError method.
    Description:        Whenever an exception is passed as an argument, it will fetch all the details from the 
                        Exception and return the formed String.
    Added By:           Accenture - AN - 02/02/2025
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void logErrorWithSeverity(string errorMessage,string objectName,String severity)
    {
            String subject = Label.Core_MDF_CCP_Support_Email_Subject + ' ' +  objectName;
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Details__c', errorMessage);
            coreLogMap.put('Core_Message__c', Label.Core_MDF_SFDC_Environment + ': ' + subject);
            coreLogMap.put('Core_Origin__c', objectName);
            coreLogMap.put('Core_Project__c',Label.Core_MDF_Program_Name);
            coreLogMap.put('Core_Scope__c',objectName);
            coreLogMap.put('Core_Severity__c', severity);
            coreLogMap.put('Core_Support_Email__c', Label.Core_MDF_CCP_Support_Email);
            coreLogMap.put('Core_Support_Link__c', Label.Core_MDF_CCP_Support_Link);
            coreLogMap.put('Core_Tags__c', objectName + '\t' + 'Co-Marketing') ;
            String errorText = createLogEntry(coreLogMap);
    }


    /***************************************************************************************************** 
    Method Name:        logErrorWithPE
    @return  :          void
    @parameters:        Exception - This will contain the Exception that is caught in various other classes. 
                        This will be called from multiple locations to log errors in the event bus.
    Description:        Whenever an exception is passed as an argument, this method will fetch all the details 
                        from the Exception and log them in the Core_MDF_Error_Logging__e event for tracking.
    Added By:           Accenture - Roshan - 10/03/2025
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    public static void logErrorWithPE(Exception ex) {
        Core_MDF_Error_Logging__e el = new Core_MDF_Error_Logging__e();
        el.Core_MDF_Stack_Trace_Txt__c = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
        el.Core_MDF_Apex_Class_Name_Txt__c = ex.getStackTraceString().substringBefore(':') +';\n'+ 'LineNumber = ' + String.valueOf(ex.getLineNumber());
        el.Core_MDF_Exception_Message_Txt__c = ex.getMessage();
        EventBus.publish(el);
    }

    /***************************************************************************************************** 
    Method Name:        isWarningVisible
    @return  :          Boolean
    @parameters:        
    Description:        Show the Warning contents based on custom setting flag
    Added By:           Accenture - JB - 03/12/2025
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static Boolean isWarningVisible() {
        List<Core_Trigger_Executions__c> result = [SELECT id, Core_Active__c, Name FROM Core_Trigger_Executions__c WHERE Name = 'EnableWarningMsgCommunity' LIMIT 1];
        if(!result.isEmpty() ){
            return result[0].Core_Active__c;
        }
        return false;
    }
     /***************************************************************************************************** 
    Method Name:        logErrorWithSeverityforMOU
    @return  :          String
    @parameters:        Exception - This will contain the Exception that is caught in various other classes. This 
                        will be called from the logError method.
    Description:        Whenever an exception is passed as an argument, it will fetch all the details from the 
                        Exception and return the formed String.
    Added By:           Accenture - AN - 02/02/2025
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    //public static void logErrorWithSeverityforMOU(string errorMessage,string apexClass, string objectName,String severity,String supportEmail, String supportLink, string tag,String project)
    public static void logSeverityErrorWithPE(Core_MDF_Error_Logging__e el)
    {
           system.debug('el'+el);
            String subject = Label.Core_MDF_CCP_Support_Email_Subject + ' ' +  el.Core_MDF_Object_Name_Nm__c;
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Details__c', el.Core_MDF_Details_txt__c);
            if(el.Core_MDF_Exception_Message_Txt__c!=null){
                coreLogMap.put('Core_Message__c', el.Core_MDF_Exception_Message_Txt__c);
            }
            else{
                coreLogMap.put('Core_Message__c', Label.Core_MDF_SFDC_Environment + ': ' + subject);
            }
            coreLogMap.put('Core_Origin__c', el.Core_MDF_Apex_Class_Name_Txt__c);
            coreLogMap.put('Core_Project__c',el.Core_MDF_Project_nm__c);
            coreLogMap.put('Core_sObjectType__c',el.Core_MDF_Object_Name_Nm__c);
            coreLogMap.put('Core_Scope__c',el.Core_MDF_Object_Name_Nm__c);
            coreLogMap.put('Core_Severity__c',  el.Core_MDF_Severity_txt__c);
            if(el.Core_MDF_Support_Email_txt__c!=null){
            coreLogMap.put('Core_Support_Email__c', el.Core_MDF_Support_Email_txt__c);
            }
            if(el.Core_MDF_Support_Link_txt__c!=null){
                coreLogMap.put('Core_Support_Link__c', el.Core_MDF_Support_Link_txt__c);

            }
            if(el.Core_MDF_Tag_txt__c!=null){
            coreLogMap.put('Core_Tags__c',  el.Core_MDF_Tag_txt__c) ;
            }
            System.debug('coreLogMap'+coreLogMap);
        
            // Highlight: Unused Local Variable - 14285
            // String errorText = createLogEntry(coreLogMap);
            createLogEntry(coreLogMap);
    }
    
    /***************************************************************************************************** 
    Method Name:        triggerErrLoggingPE
    @return  :          void
    @parameters:        Exception - This will contain the Exception that is caught in various other classes. 
                        This will be called from multiple locations to log errors in the event bus.
    Description:        Whenever an exception is passed as an argument, this method will fetch all the details 
                        from the Exception and log them in the Core_MDF_Error_Logging__e event for tracking.
    Added By:           Accenture - AN - 10/03/2025
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    //public static void triggerErrLoggingPE(Exception ex,String severity,String projectName,String objectNm, String tag,String message) {
     public static void triggerErrLoggingPE(Map<String, Object> parameterMap) {
        Exception ex = parameterMap.containsKey('exception') ? (Exception) parameterMap.get('exception') : null;
        String severity = parameterMap.containsKey('severity') ? (String) parameterMap.get('severity') : '';
        String projectName = parameterMap.containsKey('projectName') ? (String) parameterMap.get('projectName') : '';
        String objectNm = parameterMap.containsKey('objectName') ? (String) parameterMap.get('objectName') : '';
        String tag = parameterMap.containsKey('operation') ? (String) parameterMap.get('operation') : '';
        String message = parameterMap.containsKey('additionalInfo') ? (String) parameterMap.get('additionalInfo') : null;
        Core_MDF_Error_Logging__e el = new Core_MDF_Error_Logging__e();
        el.Core_MDF_Stack_Trace_Txt__c = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
        el.Core_MDF_Apex_Class_Name_Txt__c = ex.getStackTraceString().substringBefore(':') +';\n'+ 'LineNumber = ' + String.valueOf(ex.getLineNumber());
        el.Core_MDF_Details_txt__c = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
        el.Core_MDF_Exception_Message_Txt__c = message;//ex.getMessage();
        el.Core_MDF_Severity_txt__c = severity!=null?severity:'Normal';
        el.Core_MDF_Project_nm__c = projectName;
        el.Core_MDF_Tag_txt__c = tag;
        el.Core_MDF_Object_Name_Nm__c = objectNm;
        el.Core_MDF_Support_Email_txt__c = projectName=='CCP'?Label.Core_MDF_CCP_Support_Email:null;
        el.Core_MDF_Support_Link_txt__c = projectName == 'CCP'?Label.Core_MDF_CCP_Support_Link:null;
        EventBus.publish(el);
    }

/***********************************************************************************************************
Method Name:        createLogEntries
Description:        Method to create log entries (Bulkified version of createLogEntry)
Added By:           Sham - 10-27-2025
Modified By:        Date:       Changes:
**********************************************************************************************************/
    public static void createLogEntries(List<Map<String, String>> coreLogMaps){
       // List<Id> createdIds = new List<Id>();
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
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }  



    /***************************************************************************************************** 
    Method Name:        logErrors
    @return  :          void
    @parameters:        List<Exception> - Bulk list of exceptions to be logged
    Description:        Bulkified logging that retains logic of logError, logErrorinLogObject, and logErrorAsNormal.
                        Builds Core Log Maps for each exception and inserts all logs in one DML via createLogEntries.
    Added By:           Sham - 11/18/2025
    ******************************************************************************************************/
    public static void logErrors(List<Exception> exceptions){
        if(exceptions == null || exceptions.isEmpty()){
            return;
        }
        List<Map<String, String>> coreLogMaps = new List<Map<String, String>>();
        for(Exception e : exceptions){
            if(e == null) continue;
            String objectName = e.getStackTraceString().substringBefore(':');
            String subject = Label.Core_MDF_CCP_Support_Email_Subject + ' ' +  objectName;

            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Details__c', getErrorDetails(e));
            coreLogMap.put('Core_Message__c', Label.Core_MDF_SFDC_Environment + ': ' + subject);
            coreLogMap.put('Core_Origin__c', objectName);
            coreLogMap.put('Core_Project__c', Label.Core_MDF_Program_Name);
            coreLogMap.put('Core_Scope__c', objectName);
            // Severity: Normal for validation, Critical otherwise
            Boolean isValidation = (e.getMessage() != null && e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            coreLogMap.put('Core_Severity__c', isValidation ? 'Normal' : 'Critical');
            coreLogMap.put('Core_Support_Email__c', Label.Core_MDF_CCP_Support_Email);
            coreLogMap.put('Core_Support_Link__c', Label.Core_MDF_CCP_Support_Link);
            coreLogMap.put('Core_Tags__c', objectName + '\t' + 'Co-Marketing');

            coreLogMaps.add(coreLogMap);
        }
        createLogEntries(coreLogMaps);
    }
     public class PicklistDetails {
        public string active { get; set; }
        public string defaultValue { get; set; }
        public string label { get; set; }
        public string value { get; set; }
        public string validFor { get; set; }
        public PicklistDetails() { }
    }
     public static Map<Object, List<Map<String,String>>> getFieldDependenciesMaps(String objectName, String controllingField, String dependentField) {

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType == null) {
            return new Map<Object, List<Map<String,String>>>();
        }
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();

        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return new Map<Object, List<Map<String,String>>>();
        }
        List<Schema.PicklistEntry> controllingValues = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        return getFieldDependenciesMaps(dependentValues, controllingValues);
    }

    private static Map<Object, List<Map<String,String>>> getFieldDependenciesMaps(List<Schema.PicklistEntry> dependentValues, List<Schema.PicklistEntry> controllingValues) {
        Map<Object, List<Map<String,String>>> controllingInfo = new Map<Object, List<Map<String,String>>>();

        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getValue(), new List<Map<String,String>>());
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {

            String jsonString = JSON.serialize(currDependentValue);
            PicklistDetails info = (PicklistDetails) JSON.deserialize(jsonString, PicklistDetails.class);
            if(info.validFor == null) {
                continue;
            }
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;
            for (Integer curr : hexString.getChars()) {
                Integer val = 0;
                if (curr >= 65) {
                    val = curr - 65 + 10;
                }
                else {
                    val = curr - 48;
                }
                if ((val & 8) == 8) {
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(new Map<String, String>{'value' => currDependentValue.getValue(), 'label' => currDependentValue.getLabel()});
                }
                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(new Map<String, String>{'value' => currDependentValue.getValue(), 'label' => currDependentValue.getLabel()});
                }
                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(new Map<String, String>{'value' => currDependentValue.getValue(), 'label' => currDependentValue.getLabel()});
                }
                if ((val & 1) == 1) {
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(new Map<String, String>{'value' => currDependentValue.getValue(), 'label' => currDependentValue.getLabel()});
                }
                baseCount += 4;
            }
        }
        return controllingInfo;
    }

	public static List<String> collectDmlFailureDetails(List<Id> recordIds, Database.SaveResult[] dmlResults){
        List<String> failedRecordDetails = new List<String>();
        Integer sizeToProcess = Math.min(recordIds.size(), dmlResults.size());
        for(Integer i = 0; i < sizeToProcess; i++){
            if(!dmlResults[i].isSuccess()){
                Id recordId = recordIds[i];                
                for(Database.Error err : dmlResults[i].getErrors()){
                    failedRecordDetails.add(String.valueOf(recordId) + ' - ' + String.valueOf(err.getStatusCode()) + ': ' + err.getMessage());
                }
            }
        }
        return failedRecordDetails;
    }
}