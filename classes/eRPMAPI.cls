public class eRPMAPI {
    
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'CIDAAS_ERPM_Callout'; 
    
	public static void ExecuteERPMAPI(string json, Id requestId) {
        system.debug('execute api methods');
        ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
        string params = requestId;
        try {
            HttpRequest httpReq = new HttpRequest();
			HttpResponse response = new HttpResponse();
            httpReq.setEndpoint('callout:eRPM_Apigee/m2r/erpm/v1/profiles/set-profiles');
            httpReq.setMethod('POST');
            httpReq.setBody(json);
            response = new Http().send(httpReq);           
            custEx.Message = response.getBody();
            system.debug('response- '+response.getBody());
            ER_ErrorUtility.createLogEntry('ExecuteAPI', custEx, LOG_ENTRY_INFO, LOG_ENTRY_SCOPE, params);                    
        }
        catch(Exception ex){
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();
			system.debug('error- '+custEx);            
            ER_ErrorUtility.createLogEntry('Error in ExecuteAPI- APIGEE', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
		
    }
}