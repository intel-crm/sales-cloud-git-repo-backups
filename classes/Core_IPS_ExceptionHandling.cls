/*
    Author: HCL
    Created Date: 18/05/2017
    Creatd by: Venki
    Description: created to hold all the exception handlign method in one place to increase the code re-usability
    
*/
Public Class Core_IPS_ExceptionHandling{

    /*****************************************************************************************************
     @ Description: Inserting DML error logs into LogEntry object
     @ par: Map, string, string
     @ Returns void
     created by :venki 18/05/2017
  ***********************************************************************************************************/
    
  Public static void dmlExceptionHandlingLogs(Map<string,Database.Error[]> errorRecords,String object_Name, string componentName){
      try{ 
        List<Core_Log_Entry__C>objCLEList= new List<Core_Log_Entry__c>();
        
        for(string  k : errorRecords.keyset()){ 
        
            for(Database.Error e: errorRecords.get(k)){

                string errorDetails = 'Message: ' + e.getMessage() + '\n';
                    errorDetails+= 'The following error has occurred' + e.getStatusCode() +'\n';
                    errorDetails+= Object_name+' Fieldsthat affected this error: ' + e.getFields() + '\n';
                    errorDetails+=  'Record:'+k;  
                    string strMessage=e.getmessage();
                Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                    
                    Core_Origin__c ='SFDC',
                    Core_Project__c = 'IPS Pre sales cloud',
                    Core_Scope__c = componentName,
                    Core_Severity__c = 'DML error',
                    Core_Message__c = String.isNotBlank(strMessage) ? strMessage.Left(255) : '',
                    Core_When__c =system.today() ,
                    //Core_Status__c = Label.ICS_App_Logging_Default_Status, // From Service Cloud
                    //Core_Invocation_ID__c = strInvocationID, // From Service Cloud
                    Core_Details__c = String.isNotBlank(errorDetails) ? errorDetails.Left(32760) : '',// trim to fit field,
                    //Core_sObjectId__c = ,
                    Core_sObjectType__c =object_Name 
                    //Core_Tags__c = 
                );
                
                objCLEList.add(objCLE );
              }
           } 
           
           insert objCLEList; 
          }catch(Exception e) {System.debug('*** Log Entry ' + e.getMessage());   }            
                    
           
     } 
          
  /******************************************************************
    @Description    : Application error and information logging.
                     An exception anywhere in the execution thread could rollback
                     the insert into the Log Entry entry.
    @Parameters      :exception
                    Componentname: class Name 
                    ObjectName: sobject
    
    
    @created by: Venki
    @Creted dated: 18/05/2017
    ************************************************************************/ 
    
    public static void logEntryWithException(exception ex, string ComponentName, string objectName){
        try{
            List<Core_Log_Entry__C>objCLEList= new List<Core_Log_Entry__c>();
            string strDetailsAndEx;
           if( ex != null ) {
                    strDetailsAndEx += 'UserId:'+UserInfo.getUserId() +'Message: ' + ex.getMessage() + '\n';
                    strDetailsAndEx += 'Cause: ' + ex.getCause() + '\n';
                    strDetailsAndEx += 'Line Number: ' + ex.getLineNumber() + '\n';
                    strDetailsAndEx += 'Stack Trace: ' + ex.getStackTraceString() + '\n';
                    strDetailsAndEx += 'Type Name: ' + ex.getTypeName() + '\n';
            } 
                    string strMessage=ex.getmessage();
                Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                    
                    Core_Origin__c ='SFDC',
                    Core_Project__c = 'IPS Pre sales cloud',
                    Core_Scope__c = componentName,
                    Core_Severity__c = 'DML error',
                    Core_Message__c = String.isNotBlank(strMessage) ? strMessage.Left(255) : '',
                    Core_When__c =system.today() ,
                    //Core_Status__c = Label.ICS_App_Logging_Default_Status, // From Service Cloud
                    //Core_Invocation_ID__c = strInvocationID, // From Service Cloud
                    Core_Details__c = String.isNotBlank(strDetailsAndEx) ? strDetailsAndEx.Left(32760) : '',// trim to fit field,
                    //Core_sObjectId__c = ,
                    Core_sObjectType__c =objectName
                    //Core_Tags__c = 
                );
                
                insert objCLE;
            }catch(Exception e) { System.debug('*** Log Entry ' + e.getMessage());}
                   
                    
            
           
    } 
    
     
}