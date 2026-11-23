/*
    * description : To Create Success,Waring and Error Logs in Log Entry Custom Object
    * author and date : Harshal Gosavi, 22nd August 2021
*/
public without sharing class UCD_ACM_Logger {
    // Define a list for Log Entry Records
	private static List<Core_Log_Entry__c> logs = new List<Core_Log_Entry__c>();
    private static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();

    
    // Define Constructor
    public UCD_ACM_Logger(){
        logs = new List<Core_Log_Entry__c>();
    }
    
    // Create a log for success
    public static void information(string className,string methodName,string message,string tags){
        Organization orgInFo = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_EnableInfoLog') && 
           mapFunctionalityNameTriggerExecution.get('UCD_ACM_EnableInfoLog').Core_Active__c){    
            Core_Log_Entry__c log = mapLogObject(className,methodName,message,'Information',tags);
            logs.add(log);
        }
    }

    // Create a log for success
    public static void setInfoLog(string className,string methodName,string message,string tags, Long startTime, Long endTime){
        Long milliseconds = endTime - startTime;
        Long seconds = milliseconds/1000;
        String sMinutes = String.valueOf(seconds/60);
        String sSeconds = (seconds > 0) ? String.valueOf(math.mod(seconds, 60)):'0';
        //Long hours = minutes / 60;
        //Long days = hours / 24;
        //message+=' Time : '+sMinutes+':'+sSeconds +' (Min:Sec)';
        message+=' Time : '+(sMinutes.equals('0') ? (sSeconds+'s') : (sMinutes+'m '+sSeconds +'s'));
        Organization orgInFo = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_EnableInfoLog') && 
           mapFunctionalityNameTriggerExecution.get('UCD_ACM_EnableInfoLog').Core_Active__c){    
            Core_Log_Entry__c log = mapLogObject(className,methodName,message,'Information',tags);
            logs.add(log);
        }
    }
    
    // Create a log for warinings
     public static void warning(string className,string methodName,string message,string tags){
        Core_Log_Entry__c log = mapLogObject(className,methodName,message,'Warning',tags);
         logs.add(log);
     }
    
    // Create a log for errors
    public static void error(string className,string methodName,string message,string tags){
        Core_Log_Entry__c log = mapLogObject(className,methodName,message,'Error',tags);
        logs.add(log);
    }
    
    private static Core_Log_Entry__c mapLogObject(string classname,string methodname,string message,string severity,string tags){
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        log.Core_Origin__c = classname;
        log.Core_Project__c = 'ACM';
        log.Core_Scope__c = methodname;
        log.Core_Severity__c = severity;
        log.Core_Message__c = methodname;
        log.Core_Details__c = message;
        log.Core_Tags__c = tags;
        log.Core_When__c = System.today();
        return log;
    } 
    
    public static void setLogDetails(){
        try{
            Database.SaveResult[] logsResult = Database.insert(logs);
            logs.clear();
        }catch(Exception ex){
            
        }
    }

}