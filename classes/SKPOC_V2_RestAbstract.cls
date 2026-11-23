//@author - Sudhir Kathula
//TODO enhance exception handling
//Comments Core_RestAPI_Abstract
public abstract class SKPOC_V2_RestAbstract {
    
    public DateTime entryTime = null;
    private RestRequest request = RestContext.request;
    public Map<String, Object> apiError = new Map<String, Object>();
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
        apiError.put(errCde, errMsg);
    }
    
    public void setErrorMessage(String errCde, Exception ex){
        String errMsg = '';
        if( ex != null ) {
            errMsg += 'UserId:'+UserInfo.getUserId() +'Message: ' + ex.getMessage() + '\n';
            errMsg += 'Cause: ' + ex.getCause() + '\n';
            errMsg += 'Line Number: ' + ex.getLineNumber() + '\n';
            errMsg += 'Stack Trace: ' + ex.getStackTraceString() + '\n';
            errMsg += 'Type Name: ' + ex.getTypeName() + '\n';
        } 
        log.Core_Response__c = errCde+' '+errMsg;
        apiError.put(errCde, 'Technical Error : '+errMsg+', Please contact administrator');
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
    List<Map<String, Object>> records = null;
    //Bulk test
    public List<Map<String, Object>> getSObjectRecords(){
        
        Map<String, Object> record = null;
        
        if(apiError != null && apiError.size() == 0)
            return null;
        try{
            System.debug(' getRecords Invoked ');
            records = new List<Map<String, Object>>();
            for(sObject sobj : Database.query(getQuery())){
                record = new Map<String, Object>();
                
                System.debug('\n\n  sobj '+sobj);
                for(String key : getfieldMapping().keySet()){
                    String custName = getfieldMapping().get(key);
                    System.debug(' ++++ KEY '+key+' ++++ custName '+custName);
                    record.put(custName, getFieldValue(sobj, key)); 
                }
                records.add(record);
            }
        }
        catch(Exception ex){
            system.debug('Exception Occured '+ ex);
            setErrorMessage('ExceptionOccured',ex);
            records = new List<Map<String, Object>>();
            records.add(apiError);
        }
        return records;
    }
    
    //Retreive the value from object or from the nested object
    //1. 'CaseNumber:123123' - gives you case number
    //2. 'Case.Contact.Account.Name:John' - returns john
    private Object getFieldValue(sObject sobj, String key){
        Map<String, Object> populatedFieldsAsMap  = sobj.getPopulatedFieldsAsMap();
        System.debug(key+'\n ++++++++++++ populatedFieldsAsMap +++++++++  '+populatedFieldsAsMap);
        Object objVal = null;
        if(key != null && key.contains('.')){
            List<String> objRelationArray = key.split('\\.');
            //System.debug('  getFieldValue  ++++++++++ '+objRelationArray);
            for(Integer i=0; i<objRelationArray.size() ; i++){
                if(i+1 == objRelationArray.size() && sobj != null){
                    objVal = (Object)sobj.get(objRelationArray[i]);
                    break;
                }else{
                    sobj = sobj.getSobject(objRelationArray[i]); 
                    if(sobj == null)
                        break;
                }
            }
        }else{
            objVal = populatedFieldsAsMap.get(key);
        }
        return objVal;
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
    
}