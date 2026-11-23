/******************************************************************************************************************************************************
* Class Name  : PRM_ErrorUtilityClass 
* Version     : 1.0 
* Created Date: 10-29-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Kushal Soni                   10/29/2018                    It logs all the exceptions in the 'Log Entry' custom object

*******************************************************************************************************************************************************/
public without sharing class PRM_ErrorUtilityClass{
    
    /**
    *  @description      : Call Log object to log errors
    *  @name             : logErrorInLogObject
    *  @param            : String, String
    *  @throws exception : NONE
    **/
    public static string logErrorInLogObject(string errorMessage,string objectName)
    {       string intLog;
            String subject = Label.PRM_Error_Subject+ ':' + objectName;
            Map<String, String> coreLogMap = new Map<String, String>();
            coreLogMap.put('Core_Details__c', errorMessage);
            coreLogMap.put('Core_Message__c', subject);
            coreLogMap.put('Core_Origin__c', objectName);
            coreLogMap.put('Core_Project__c',Label.PRM_Project_Name );
            coreLogMap.put('Core_Scope__c',objectName);
            coreLogMap.put('Core_Severity__c', 'Critical');
            //coreLogMap.put('Core_Support_Email__c', Label.PRM_Error_Subject);
            //coreLogMap.put('Core_Support_Link__c', Label.PRM_Error_Subject);
            coreLogMap.put('Core_Tags__c', objectName + '\t' + 'PRM') ;
            String errorText = createLogEntry(coreLogMap);
            intLog=errorText;
            return intLog;
    }
    
    /**
    *  @description      : Create Log Object by passing the logObject field names and values in the Map
    *  @name             : createLogEntry
    *  @param            : String, Map
    *  @throws exception : NONE
    **/
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
                    return objCLE.id;
                }
            }                      
        } catch(Exception e) {
            System.debug('*** App Logging Failed ' + e.getMessage());
        }
        return null;    
    }

    /**
    *  @description      : Whenever an exception is passed as an argument, it will fetch all the details from the 
    *                      Exception and return the formed String.
    *  @name             : getErrorDetails
    *  @param            : Exception
    *  @throws exception : NONE
    **/ 
    public static String getErrorDetails(Exception e){
        return 'Class & Method Name = ' + e.getStackTraceString().substringBefore(':') + ';\n' +
               'Exception Message = ' + e.getMessage() + ';\n' +
               'LineNumber = ' + String.valueOf(e.getLineNumber()) + ';\n' +
               'StackTrace = ' + e.getStackTraceString() + ';\n' +
               'Logged in user = ' + UserInfo.getName();
    }
    
    
    /**
    *  @description      : Whenever an exception is passed as an argument, it will call the getErrorDetails method and
    *                      pass the string returned to create the Log Entry record through the logErrorInLogObject method.
    *  @name             : logError
    *  @param            : Exception
    *  @throws exception : NONE
    **/
    public static string logError(Exception e){
    string intLogs;
        intLogs=logErrorinLogObject(getErrorDetails(e), e.getStackTraceString().substringBefore(':') + ' --> ' + e.getLineNumber());
        return intLogs;
    }

}