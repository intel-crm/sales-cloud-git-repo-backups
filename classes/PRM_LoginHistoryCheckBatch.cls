public class PRM_LoginHistoryCheckBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    //IPA2.0 - TWC727-2862 - Start
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_LoginHistoryCheckBatch';
    public static final String LOG_ENTRY_PROJECT  = 'IPA';
    public static final String LOG_ENTRY_SCOPE    = 'Batch class failures - IPA';
    public static final String LOG_ENTRY_SEVERITY = 'Exception';
    public String strTags;
    String logEntryMsgString='';
    //IPA2.0 - TWC727-2862 - End
    
    public static IPA_Batch_Configurations__mdt mdt=IPA_Batch_Configurations__mdt.getInstance('PRM_LoginHistoryCheckBatch');
    public static integer recordlimit=(mdt!=null && mdt.Record_Limit__c!=null)?integer.valueof(mdt.Record_Limit__c):10000;
    public static string stage=(mdt!=null && mdt.Stage__c!=null)?mdt.Stage__c:'23';
    public static string status='Approved';
    public static string program='Intel Partner Alliance';
    public static Database.QueryLocator start(Database.BatchableContext batchContext){  //Returns all VxStage reocrds where Changed Date > Processed Date 
        String query ='select id,PRM_User_Login_History__c,(select id,PRM_User_Loggedin_Time__c,Stage__c ,PRM_Step_Number__c,PRM_Registration__c,PRM_Log_Entries__c,PRM_Email__c from Registration_Trackers__r where IsActive__c = true and Stage__c=:stage limit 1  ),PRM_Status__c,PRM_Email_ID__c,createddate from PRM_Registration_Request__c  where PRM_User_Login_History__c =true and PRM_Status__c=:status  and PRM_Channel_Program__r.Name=:program order by createddate desc limit '+recordlimit;
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext batchContext, List<PRM_Registration_Request__c > scope){ 
        //IPA2.0 - TWC727-2862 - Added try catch block for creating log entry in case of failures
        try{
            PRM_RegistrationTrackerUtility.CheckUserLoginHistory(scope);
        }
        catch(Exception ex){
            logEntryMsgString+='\n\nException occurred:'+ex.getMessage() + '-' + ex.getStackTraceString();
            PRM_IPA_Utility.createLogEntry(logEntryMsgString, LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT ,LOG_ENTRY_SCOPE , LOG_ENTRY_SEVERITY , strTags); 
        }
        //IPA2.0 - TWC727-2862 - End
    }
    
    public void finish(Database.BatchableContext batchContext){
    }    
}