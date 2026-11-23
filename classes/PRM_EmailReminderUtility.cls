public class PRM_EmailReminderUtility {
    public static final String LOG_ENTRY_ORIGIN = 'Email Reminder Batch';
    public static final String LOG_ENTRY_PROJECT = 'IPA';
    public static final String LOG_ENTRY_SCOPE = 'Email Reminder Batch';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String PRM_PROCESSINBOUNDCLASS = 'PRM_EmailReminderBatch';
    private static final String PRIMARYCONTACT = 'Primary Contact';
    private static final String WORKSFOR = 'Works for';    
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO    = 'info';
    
    public static  Map<id,string> generateBulkEvToken(Map<id,PRM_EmailLog__c>  Maplist)
    {
        Map<id,string> EvMap = new Map<id,string>();
        
        if(!Maplist.IsEmpty()){
            for(PRM_EmailLog__c  Em :Maplist.values()){
                string evtoken  =   PRM_RetriggerEV_Token_API.reTriggerEV(Em.PRM_Contact__r.email);
                system.debug('The value of EVtoken is '+evtoken);
                EvMap.put(Em.PRM_Contact__c,evtoken);
            }
        }
        
        return    EvMap; 
    }
}