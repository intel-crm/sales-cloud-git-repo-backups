trigger Core_MDF_ErrorLogging on Core_MDF_Error_Logging__e (after insert) {
    for (Core_MDF_Error_Logging__e event : Trigger.New) {
        // Handle the event, for example, storing it in a custom error log object
        System.debug('Error Message: ' + event.Core_MDF_Apex_Class_Name_Txt__c);
        System.debug('Error Code: ' + event.Core_MDF_Exception_Message_Txt__c);
        System.debug('event'+event);
        // You can create a custom object to store the logs in a database
        //Core_MDF_CCP_UtilityClass.logErrorWithSeverity(event.Core_MDF_Exception_Message_Txt__c,event.Core_MDF_Apex_Class_Name_Txt__c,'Critical');
       //Core_MDF_CCP_UtilityClass.logErrorWithSeverityforMOU(event.Core_MDF_Exception_Message_Txt__c,event.Core_MDF_Apex_Class_Name_Txt__c,event.Core_MDF_Object_Name_txt__c,event.Core_MDF_Severity_txt__c,event.Core_MDF_Support_Email_txt__c,event.Core_MDF_Support_Email_txt__c,event.Core_MDF_Tag_txt__c,event.Core_MDF_Project_txt__c);
       Core_MDF_CCP_UtilityClass.logSeverityErrorWithPE(event);
    }

}