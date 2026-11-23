/******************************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_UtilityClass 
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
* Intel - Narayani Perachi		12/26/2018                   Added Environment Label to the Mail subject to make it more readable
* Intel - NP(11630236)          10/23/2019                   Edited the Subject of the logging record
*******************************************************************************************************************************************************/
public without sharing class Core_MDF_CCP_UtilityClass{
    
    //Method to perform Update action to DB and to Log errors
    public static Map<String, Object> updateListAndLogErrors(List<SObject> tobeupdated, String logEntryMsg)
    {
        
        // Database method to update the records in List
        system.debug('Update method' + tobeupdated);
        Map<string, Object> resultMap = new Map<String,Object>();
        Map<id,string> idAndUpdateStatus = new Map<id,string>();
        Try{
        Database.SaveResult[] toBeUpdatedList = Database.update(tobeupdated, false);
        system.debug('toBeUpdatedList' + toBeUpdatedList);
        
                // Iterate through each returned result by the method
                for (Database.SaveResult sr : toBeUpdatedList) 
                {
                   if (sr.isSuccess()) 
                       {
                          // This condition will be executed for successful records and will fetch the ids of successful records
                          System.debug('Successfully updated for id: ' + sr.getId());  
                           idAndUpdateStatus.put(sr.getId(),'Success'); 
                       } 
                    else 
                        {
                            idAndUpdateStatus.put(sr.getId(),'Failed');
                          // This condition will be executed for failed records
                              for(Database.Error objErr : sr.getErrors()) 
                                  {
                                     System.debug('The following error has occurred.');                           
                                     // Printing error message in Debug log
                                     System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                                     logEntryMsg += '\nFailed to Update:' + sr.getId() + '\t' + objErr.getMessage() + '\t' + objErr.getFields();
                                  }
                       }
                }
        resultMap.put('DatabaseResult', idAndUpdateStatus);
        resultMap.put('errorMessage', logEntryMsg);
        } catch(Exception e){
            system.debug(e.getMessage());
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
            String errorText = createLogEntry(coreLogMap);
    }
  
// Create Log Object by passing the logobject field names and values in the Map    
    public static String createLogEntry(Map<String, String> coreLogMap){
        
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        try {
            
            DateTime dtWhen = system.now();
            Map<String, Schema.SObjectField> logFields = Schema.SObjectType.Core_Log_Entry__c.fields.getMap();
            if(coreLogMap != null && coreLogMap.size() > 0){    
                for(String key:coreLogMap.keySet()){        
                    if(logFields.containsKey(key)){
                        Schema.DescribeFieldResult field= logFields.get(key).getDescribe();    
                        Integer length = field.getLength();
                        String value = String.valueOf(coreLogMap.get(key));                        
                        objCLE.put(key, value.left(length));                        
                    }
                }
                System.debug('******* CoreLog Map to be Inserted:'+objCLE);
                
                if(objCLE != null){
                    objCLE.put('Core_When__c',dtWhen);
                    Database.insert(objCLE);
                    System.debug('******* Inserted Object:'+ objCLE.id);
                    return objCLE.id;
                }
            }                      
        } catch(Exception e) {
            System.debug('*** App Logging Failed ' + e.getMessage());
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
        return 'Class & Method Name = ' + e.getStackTraceString().substringBefore(':') + ';\n' +
               'Exception Message = ' + e.getMessage() + ';\n' +
               'LineNumber = ' + String.valueOf(e.getLineNumber()) + ';\n' +
               'StackTrace = ' + e.getStackTraceString() + ';\n' +
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
        logErrorinLogObject(getErrorDetails(e), e.getStackTraceString().substringBefore(':'));
    }
}