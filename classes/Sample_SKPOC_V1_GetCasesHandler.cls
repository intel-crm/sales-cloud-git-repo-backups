public class Sample_SKPOC_V1_GetCasesHandler extends Sample_SKPOC_V1_Abstract{
    
    /*class SuccessResponse implements Core_RestApiResponse{
        List<Core_RestApiResponseRecords> cases = new List<CaseWrapper>();
    }
    
    private String sqol;
    public SKPOC_V1_RestAPI_GetCasesHandler(String sql, DateTime currTime){
        this.sqol = sql;
        this.entryTime = currTime;
        entryLog();
    }
    
    public Core_RestApiResponse getCases(){
        SuccessResponse finalResponse = new SuccessResponse();

         
        //Step1:
        Boolean isReqValid = validate();
        System.debug(' >>>>>  Validations  '+isReqValid);
        if(isReqValid == false){
            return errorResp;
        }
        
        //Step 2 = Query and populate the result 
        System.debug(' >>>>>  PROCESSING REST STARTED  ');
        try{
            for(Case caseRec: Database.query(sqol))
            {
                CaseWrapper cw = new CaseWrapper();
                cw.CaseNumber = caseRec.CaseNumber;
                cw.Status= caseRec.Status;
                cw.CaseURL = Label.Core_IPS_Portal_URL+caseRec.id;
                cw.LastModifiedDate = caseRec.LastModifiedDate;
                cw.Subject = caseRec.Subject;
                finalResponse.cases.add(cw);
            }
            System.debug(' Serialize type '+JSON.serialize(finalResponse.cases));
        }
        catch(Exception ex){
            system.debug('Exception Occured '+ ex);

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
    
    
    
    /*
    public override Map<String, String> getfieldMapping(){
        Map<String, String> m = new Map<String, String>();
        m.put('CaseNumber', 'CaseNumberCC');
        m.put('Subject', 'SubjectCC');
        m.put('id', 'idCC');
        return m;
    }
    
    public override String getQuery(){
        return 'SELECT ID, CaseNumber,Subject  FROM CASE LIMIT 1 ';
    }
    
    public override String getWrapperType(){
        return 'SKPOC_RestHandler.CaseWrapper';
    }
    
    public override Core_RestApiResponseRecords getWrapperInstance(){
        return new CaseWrapper();
    } */
    
    
    //IMPORTANT : Every bean class should implement Core_RestApiResponseRecords
    /*class CaseWrapper implements Core_RestApiResponseRecords{
        Public String CaseNumber{get;set;}
        Public String Status{get;set;}
        Public String Subject{get;set;}
        Public String CaseURL{get;set;}
        Public DateTime LastModifiedDate{get;set;}
    } */
}