public class ATBLogLimits {
    
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ATBLogLimits';
    
    @InvocableMethod(label='Log Limits' description='Log Limits' category= 'New Registration')
    public static void LogLimits(List<id> reqId) {
        string params = 'RequestId - '+ reqId[0];
        ER_ErrorUtility.createLogEntry('SOQL query so far '+ Limits.getQueries(), null, LOG_ENTRY_INFO, LOG_ENTRY_SCOPE, params);
    }

}