public class Sample_SKPOC_V2_GetRequestHandler{/* extends SKPOC_V2_RestAbstract{
    
    private Map<String, String> fieldMapping = null;
    private String soql;
    public List<Map<String, Object>> records = new List<Map<String, Object>>();
    
    
    public SKPOC_V2_RestApiGetRequestHandler(String sql, DateTime currTime, Map<String, String> fieldMapping){
        this.soql = sql;
        this.entryTime = currTime;
        this.fieldMapping = fieldMapping;
    }
    
    //INFO: NO Exception handling needed.
    public List<Map<String, Object>> queryRecords(){
        
        
        //Step 2 = Query and populate the result 
        records = getSObjectRecords(); 
        return records;
    }
    
    
    //Do Additional Validation if needed by overriding else return true.
    public override Boolean additionalValidation(){
        System.debug(' \n 2.  Additional Validation ');
        //Additional validations LOGIC
        
        setErrorMessage('Failed','Validation Failed');
        return true;
    }
    
    //Returns the field mapping
    public override Map<String, String> getfieldMapping(){
        return fieldMapping;
    }
    
    //returns the Query
    public override String getQuery(){
        return soql;
    }
    */
}
/*
* 
* Standard date field Does not converts , eg, Created Date
* 
*/