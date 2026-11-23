public abstract class Sample_SKPOC_V1_Abstract {
    
   /* public DateTime entryTime = null;
    RestRequest request = RestContext.request;
    public Core_Log_Entry__c log{
        get{
            if(log == null){
                log = new Core_Log_Entry__c();
                String reqParam = System.JSON.serialize(request);
                log.Core_Details__c = String.isNotBlank(reqParam) ? reqParam.Left(32760) : '';
                log.Core_Contact__c  = [Select ContactId FROM User where Id =:UserInfo.getUserId()].ContactId;
                log.Core_Severity__c = 'info';
                log.Core_Origin__c = 'B2B';
                log.Core_When__c = entryTime;
            }
                
        return log;
    }set;}
    
    public ErrorResponse errorResp{get;set;}
    public void setErrorMessage(String errCde, String errMsg){
        errorResp = new ErrorResponse();
        ErrorRecord temp = new ErrorRecord(errCde, errMsg);
        errorResp.error = temp;
    }
    public void setErrorMessage(String errCde, Exception ex){
        errorResp = new ErrorResponse();
        String errMsg = '';
        if( errMsg != null ) {
            errMsg += 'UserId:'+UserInfo.getUserId() +'Message: ' + ex.getMessage() + '\n';
            errMsg += 'Cause: ' + ex.getCause() + '\n';
            errMsg += 'Line Number: ' + ex.getLineNumber() + '\n';
            errMsg += 'Stack Trace: ' + ex.getStackTraceString() + '\n';
            errMsg += 'Type Name: ' + ex.getTypeName() + '\n';
        } 
        
        ErrorRecord temp = new ErrorRecord(errCde, 'Technical Error, Please contact administrator');
        errorResp.error = temp;
        
        log.Core_Response__c = errCde+' '+errorResp;
    }
    
        
    public boolean validate(){
        System.debug('\n  1. Common Validation ');
        Boolean isValid = true;
        //Step 1: Validate Uri
        //eg: no blank spaces between each slashes
        String[] uriParams = request.requestURI.split('/');
        System.debug(request.requestURI+'  uriParams '+uriParams);
        isValid = additionalValidation();
        return isValid;
    }
    
    
    public void exitLog(){
        System.debug(' Exit Log Invoked ');
    }
    
    public void entryLog(){
        System.debug(' \n Rest Service invoked  @ '+entryTime);
        RestRequest req = RestContext.request;
        System.debug(' Request URI '+req);
    }
    

    public void logTransaction(){
        log.Core_Response_Return_Time__c = System.now();
        logAtFuture(System.JSON.serializePretty(log));
    }
    
    
    @future 
    private static void logAtFuture(String json){
        System.debug(' \n LogTransaction \n Start Time '+json);
        Core_Log_Entry__c finalLog = (Core_Log_Entry__c)System.Json.deserialize(json, Core_Log_Entry__c.class);
        if(finalLog != null)
            insert finalLog;
    }
    
    public abstract Boolean additionalValidation();
    //public abstract String getQuery();
    //public abstract Map<String, String> getfieldMapping();
    //public abstract String getWrapperType();
    //public abstract Core_RestApiResponseRecords getWrapperInstance();

    
    public class ErrorResponse implements Core_RestApiResponse{
        public ErrorRecord error {get;set;}

    }
    
    public class ErrorRecord implements Core_RestApiResponseRecords{
        public String errorCode{get;set;}
        public String errorMessage{get;set;}
        public ErrorRecord(String arg1, String arg2){
           this.errorCode =  arg1;
           this.errorMessage = arg2;
        }
    }
*/
}