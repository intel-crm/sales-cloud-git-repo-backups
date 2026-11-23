public class PRM_LinkEmailLogtoContact implements Queueable {
    private set<string> EmailIds;
    public static final String LOG_ENTRY_ORIGIN   = 'CreateAccountAndRelatedRecords';
    public static final String LOG_ENTRY_PROJECT  = 'IPA Registrations';
    public static final String LOG_ENTRY_SCOPE    = 'CreateAccountAndRelatedRecords';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public PRM_LinkEmailLogtoContact(set<string> EmailSet){
        this.EmailIds = EmailSet;
    }
    public void execute(QueueableContext context) {
        map<string,id> emailcontactMap=new map<string,id>();string emailds;
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>(); 

        try
        {
            //get the Contacts matched by Email
            for(Contact con:[Select id,Email from contact where email in: EmailIds]){
                emailcontactMap.put(con.Email,con.Id);
            }
            //get PRM_EmailLog__c  matched by Email
            for (PRM_EmailLog__c EL : [select Id,PRM_ToEmailID__c,PRM_User__c,PRM_Contact__c from PRM_EmailLog__c where PRM_ToEmailID__c in: emailcontactMap.keyset()]) {
                emailds+=EL.PRM_ToEmailID__c+';';
                if(emailcontactMap.containskey(EL.PRM_ToEmailID__c))
                {
                EL.PRM_Contact__c = emailcontactMap.get(EL.PRM_ToEmailID__c);
                emailLogList.add(EL);
                }
            }
            
            if(emailLogList.size()>0)
            update emailLogList;
        }
        catch (Exception e){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', emailds,e);                                  
        
        }
    }
}