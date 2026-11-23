public class PRM_AGSIdentityCreationHandler implements Queueable{
    
    List<PRM_Account_Contact_Relationship__c> ConACRs = new List<PRM_Account_Contact_Relationship__c>();
    
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_AGSIdentityCreationHandler';
    public static final String LOG_ENTRY_PROJECT  = 'Bulk Data Upload';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_AGSIdentityCreationHandler';
    public static final String LOG_ENTRY_SEVERITY = 'error';
    
    public PRM_AGSIdentityCreationHandler(List<PRM_Account_Contact_Relationship__c> ContactACRs ){
        ConACRs = ContactACRs;
    }
    
    public void execute(QueueableContext qc){
        try{
            PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger = true;
            PRM_AGS_IdentityCreation.SendEmailVerificationAndCreateIdentityInAGS(ConACRs);
        }
        catch(Exception e){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);
    }
}
}