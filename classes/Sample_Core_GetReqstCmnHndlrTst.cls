public class Sample_Core_GetReqstCmnHndlrTst  extends Sample_Core_Abstract{
    
    private Map<String, String> fieldMapping = null;
    private String soql;
    public List<Map<String, Object>> records = new List<Map<String, Object>>();
    
    
    public Sample_Core_GetReqstCmnHndlrTst  (String sql, DateTime currTime, Map<String, String> fieldMapping){
        this.soql = sql;
        this.entryTime = currTime;
        this.fieldMapping = fieldMapping;
    }
    
    //INFO: NO Exception handling needed.
    public List<Map<String, Object>> queryRecords(){
        
        //Step1:
        validate();
        
        //Step 2 = Query and populate the result 
        records = getSObjectRecords(); 
        return records;
    }
    
    
    //Do Additional Validation if needed by overriding else return true.
    public override Boolean additionalValidation(){
        System.debug(' \n 2.  Additional Validation ');
        //Additional validations LOGIC
        
        //setErrorMessage('Failed','Validation Failed');
        return true;
    }
    
    
    public override Map<String, String> getfieldMapping(){
        //Query from Custom Setting based on service name
        return fieldMapping;
    }
    
    public override String getQuery(){
        return soql;
    }
}