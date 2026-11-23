//TODO FUTURE METHOD limits
// 
public class Sample_SKPOC_V1_GetRequestHandler extends Sample_SKPOC_V1_Abstract{
   
   /* private Map<String, String> fieldMapping = null;
    class SuccessResponse implements Core_RestApiResponse{
        List<Map<String, Object>> cases = new List<Map<String, Object>>();
    }
    
    private String soql;
    public SKPOC_V1_RestApiGetRequestHandler(String sql, DateTime currTime, Map<String, String> fieldMapping){
        this.soql = sql;
        this.entryTime = currTime;
        this.fieldMapping = fieldMapping;
    }
    
    public Core_RestApiResponse getCases(){
        SuccessResponse finalResponse = new SuccessResponse();
         
        //Step1:
        Boolean isReqValid = validate();
        System.debug(' >>>>>  Validations  '+isReqValid);
        if(isReqValid == false){
            setErrorMessage('Failed','Validation Failed');
        }
        
        //Step 2 = Query and populate the result 
        System.debug(' >>>>>  PROCESSING REST STARTED  ');
        try{
           finalResponse.cases = getRecords(); 
        }
        catch(Exception ex){
            system.debug('Exception Occured '+ ex);
            setErrorMessage('ExceptionOccured',ex);
        }
        System.debug(' >>>>>  PROCESSING REST ENDE   ');
        return finalResponse;
    }
    
    public override Boolean additionalValidation(){
        System.debug(' \n 2.  Additional Validation ');
        //Additional validations
        setErrorMessage('Failed','Validation Failed');
        return true;
    }
    
    
    public override Map<String, String> getfieldMapping(){
        return fieldMapping;
    }
    
    public override String getQuery(){
        return soql;
    }*/
    
}
/*
 * 
 * Standard date field Does not converts , eg, Created Date
 * 
 */