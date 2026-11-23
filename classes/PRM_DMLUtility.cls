public with sharing class PRM_DMLUtility {    
    public static List<Database.saveResult> doinsert(List<SObject> SObjList,String SObj,String Source){
        String LOG_ENTRY_ORIGIN   = Source;
        String LOG_ENTRY_PROJECT  = 'IPA Registrations';
        String LOG_ENTRY_SCOPE    = Source.substringBefore('.');//SObj
        String LOG_ENTRY_SEVERITY = 'Medium';
        List<Database.saveResult> saveResLst =  Database.insert(SObjList,false); 
        for (Database.SaveResult sr : saveResLst) {
            if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors())
                {
                	Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,+err.getmessage(), '', '', '');
                }
            }                   
        }
        return 	saveResLst;	          
    }
    public static List<Database.saveResult> doupdate(List<SObject> SObjList,String SObj,String Source){
        String LOG_ENTRY_ORIGIN   = Source;
        String LOG_ENTRY_PROJECT  = 'IPA Registrations';
        String LOG_ENTRY_SCOPE    = Source.substringBefore('.');
        String LOG_ENTRY_SEVERITY = 'Medium';
        List<Database.saveResult> saveResLst =  Database.update(SObjList,false); 
        for (Database.SaveResult sr : saveResLst) {
           if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors())
                {
                	Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '');
                } 
            }                  
        }
        return 	saveResLst;	
    }
    public static Database.UpsertResult[] doupsert(List<SObject> SObjList,String SObj,String Source){
        String LOG_ENTRY_ORIGIN   = Source;
        String LOG_ENTRY_PROJECT  = 'IPA Registrations';
        String LOG_ENTRY_SCOPE    = Source.substringBefore('.');
        String LOG_ENTRY_SEVERITY = 'Medium';
        Database.UpsertResult[] saveResLst =  Database.upsert(SObjList,false); 
        for (Database.UpsertResult sr : saveResLst) {
            if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors())
                {
                	Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '');
                } 
            }                  
        }
        return 	saveResLst;	
    }
    /*
    public static Database.DeleteResult[] dodelete(List<SObject> SObjList,String SObj,String Source){
        String LOG_ENTRY_ORIGIN   = Source;
        String LOG_ENTRY_PROJECT  = 'IPA Registrations';
        String LOG_ENTRY_SCOPE    = Source.substringBefore('.');
        String LOG_ENTRY_SEVERITY = 'Medium';
        Database.DeleteResult[] saveResLst =  Database.delete(SObjList,false); 
        for (Database.DeleteResult sr : saveResLst) {
           if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors())	
                {
                String logEntry=Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '');
                } 
            }                  
        }
        return 	saveResLst;
    }	*/
}