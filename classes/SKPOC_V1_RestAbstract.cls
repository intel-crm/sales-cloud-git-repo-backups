public abstract class SKPOC_V1_RestAbstract {
    
    public DateTime entryTime = null;
    RestRequest request = RestContext.request;
    public ErrorResponse errorResp{
        get{
            if(errorResp == null)
                errorResp = new ErrorResponse();
            return errorResp;
        }
        set;}
    
    
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
    
    
    public void setErrorMessage(String errCde, String errMsg){
        errorResp.error.put(errCde, errMsg);

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
        log.Core_Response__c = errCde+' '+errorResp;
        
        errorResp.error.put(errCde, 'Technical Error : '+errMsg+', Please contact administrator');
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

    public void logTransaction(){
        log.Core_Response_Return_Time__c = System.now();
        logAtFuture(System.JSON.serialize(log));
    }
    
    //Bulk test
    public List<Map<String, Object>> getRecords(){
        System.debug(' getRecords Invoked ');
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        Map<String, Object> record = null;
        for(sObject sobj : Database.query(getQuery())){
            record = new Map<String, Object>();
            Map<String, Object> mColVal  = sobj.getPopulatedFieldsAsMap();
            System.debug('\n\n  sobj '+sobj);
            System.debug('fieldValueMap '+mColVal);
            
            for(String key : getfieldMapping().keySet()){
                String custName = getfieldMapping().get(key);
                record.put(custName, mColVal.get(key)); 
                
                
            }
            
            records.add(mColVal);
            records.add(record);
        }
        
        
        return records;
    }
    
    @future 
    private static void logAtFuture(String json){
        System.debug(' \n LogTransaction \n Start Time '+json);
        Core_Log_Entry__c finalLog = (Core_Log_Entry__c)System.Json.deserialize(json, Core_Log_Entry__c.class);
        if(finalLog != null)
            insert finalLog;
    }
    
    public abstract Boolean additionalValidation();
    public abstract String getQuery();
    public abstract Map<String, String> getfieldMapping();
    public class ErrorResponse implements Core_RestApiResponse{
        Map<String, Object> error = new Map<String, Object>();

    }
}

/*
System.debug(key+' Instance of  DateTime? '+(mColVal.get(key) instanceof DateTime));
System.debug(key+' Instance of  Boolean ? '+(mColVal.get(key) instanceof Boolean));
System.debug(key+' Instance of  Date    ? '+(mColVal.get(key) instanceof Date));
System.debug(key+' Instance of  sObject ? '+(mColVal.get(key) instanceof sObject));
System.debug(key+' Instance of  ID      ? '+(mColVal.get(key) instanceof ID));
System.debug(key+' Instance of  Object  ? '+(mColVal.get(key) instanceof ID));
System.debug(key+' Instance of  String  ? '+(mColVal.get(key) instanceof String) +'\n');
*/