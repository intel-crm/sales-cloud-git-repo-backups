public with sharing class PRM_DMLUtility {    
    public static List<Database.saveResult> doinsert(List<SObject> SObjList,String SObj,String Source){
        String LOG_ENTRY_ORIGIN   = Source;
        String LOG_ENTRY_PROJECT  = 'IPA Registrations';
        String LOG_ENTRY_SCOPE    = Source.substringBefore('.');//SObj
        String LOG_ENTRY_SEVERITY = 'Medium';
        List<Database.saveResult> saveResLst =  Database.insert(SObjList,false); 
        for (Database.SaveResult sr : saveResLst) {
            if (sr.isSuccess()) {
                System.debug('Insert Successful with ID -->'+sr.getId());                    
            }
            else if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors())
                {
	                //System.debug('Insert failed on object '+Sobj+' from '+Source+' on id '+sr.getId()+' with error '+err.getmessage());
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
            if (sr.isSuccess()) {
                System.debug('Update Successful with ID -->'+sr.getId());                    
            }
            else if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors())
                {
                	//System.debug('Update failed on object '+Sobj+' from '+Source+' with id '+sr.getId());
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
            if (sr.isSuccess()) {
                System.debug('Upsert Successful with ID -->'+sr.getId());                    
            }
            else if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors())
                {
                	//System.debug('Upsert failed on object '+Sobj+' from '+Source+' with id '+sr.getId());
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
            if (sr.isSuccess()) {
                System.debug('Delete Successful with ID -->'+sr.getId());                    
            }
            else if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors())
                {
                System.debug('Delete failed on object '+Sobj+' from '+Source+' with id '+sr.getId());
                String logEntry=Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '');
                } 
            }                  
        }
        return 	saveResLst;
    }	*/
}