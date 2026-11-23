/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseV2_Handler 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/6/2017               Handler class for process request and reponse for the case API
*****************************************************************************************************************************************/

//TODO COde clean up needed
public with sharing class  Core_RestAPI_CaseV2_Handler {

    private String INVALID_QUERY_PRAMS_9010 = '9010';
    private String ERROR_CODE_500 = '500';
    private String NO_DATA_FOUND_9013 = '9013';
    private DateTime entryTime = null;
    private String apiName; 

    private static final String ORDER_BY =' Order by CaseNumber DESC ';
    public Core_RestAPI_Response_withCount response = new Core_RestAPI_Response_withCount();//TODO Class Naming convention
    List<String> columnNames = new List<String> ();
    @testVisible private Map<String, String> allowedRequestURIParams = new Map<String, String>();
    
    private static String  condition = '';    
    private static String getCondition(){
        String queryParamValue = Core_RestAPI_Util.getRequestParam('v');
        if('mycases'.equalsIgnoreCase(queryParamValue))
            condition = ' WHERE Core_IPSPortal_Check__c = true';
        return condition;
    }

    
    private static final String GET_CASES_SOQL =  ' SELECT CaseNumber, Status,Core_Sub_Status__c, Core_Severity__c, Core_IPS_Project_Case__r.Name, Core_IPS_Product__c, '+
        ' Subject, Contact.Name, Contact.Account.Name, CreatedDate,Core_Customer_Reference_ID__c, ClosedDate, LastModifiedDate, Core_Issue_Description__c,CreatedBy.Core_Login_Id__c,  '+
        ' Core_IPS_Project_Case__r.Core_IPS_Project_ID__c, Core_IPS_Product_name__c '+
        ' FROM case '+ getCondition() + ORDER_BY + 'LIMIT '+Label.Core_RestAPI_CasesV2_Records_Limit; 
    
    public Core_RestAPI_CaseV2_Handler (DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName = APIname;
        //Initialize and add all valid allowed query string parameters
        allowedRequestURIParams.put('v','mycases');
        System.debug('Core_RestAPI_CaseV1_Handler  URI '+RestContext.request.requestURI +' \n SOQL '+GET_CASES_SOQL  );
    }
    
    //Retrieve cases for the logged in User
    public Core_RestAPI_Response getCases(){
        
        try{
            //Validations if need to be handled in util class      
            boolean isRequestValid = doValidations();
            
            //Process the api request
            if(isRequestValid == true)
                processRequest();
            
        }catch(Exception e){
            Core_RestAPI_Util.processException( e, ERROR_CODE_500, response, apiName, entryTime);
        }finally{
            System.debug('Core_RestAPI_CaseV2_Handler Logging transaction and returning the response '+response);
            if(String.isBlank(response.code))
                response.code = '200';
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
            
        }        
        return response;
    } 
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        System.debug('Core_RestAPI_CaseV1_Handler doValidations Invoked ');
        Boolean isRequestValid = true;
        if(Core_RestAPI_Util.isRequestParamValid(allowedRequestURIParams) == false){
            isRequestValid = false;
            Core_RestAPI_Util.processException( null, INVALID_QUERY_PRAMS_9010, response, apiName, entryTime);
        }
        System.debug('Core_RestAPI_Case_Handler doValidations Existing : isRequestValid '+isRequestValid);
        return isRequestValid;
    }
    
    
    //Execute the SOQL and populate the result to wrapper list objects 
    public void processRequest(){
        System.debug('Core_RestAPI_CaseV2_Handler processRequest ');
        
        response.successContent = new List<CaseWrapper>();
        for(Case c : Database.Query(GET_CASES_SOQL))
        {  
            CaseWrapper cw = new CaseWrapper();
            cw.caseNumber = c.CaseNumber;
            cw.status = c.Status;
            cw.subStatus = c.Core_Sub_Status__c;
            cw.severity = c.Core_Severity__c;
            cw.project = c.Core_IPS_Project_Case__c;
            cw.intelProductName = c.Core_IPS_Product__c;
            cw.subject = c.Subject;
            cw.contactName = c.Contact.Name;
            cw.accountName = c.Contact.Account.Name;
            cw.dateTimeOpened = c.CreatedDate;
            cw.lastModifiedDateTime = c.LastModifiedDate;
            cw.dateTimeClosed = c.ClosedDate;
            cw.product=c.Core_IPS_Product_name__c;
            cw.requestNumber=c.casenumber;
            cw.customerReferenceId= c.Core_Customer_Reference_ID__c;
            cw.dateCreated=c.CreatedDate;
            cw.lastUpdated=c.LastModifiedDate;
            cw.LoginId=c.CreatedBy.Core_Login_Id__c;
            response.successContent.add(cw);
        }
         if(response.successContent != null && response.successContent.isEmpty())
            Core_RestAPI_Util.processException(null, NO_DATA_FOUND_9013, response, apiName, entryTime); 
        
        List<aggregateResult> newCasesCountList = [select  count(id) TotalCount, status from case where status='New' group by status];
        List<aggregateResult> openCaseCountList = [select  count(id) TotalCount, status from case where status='Open' group by status];
        if(newCasesCountList != null && !newCasesCountList.isEmpty())
            response.newCases = Integer.valueOf(newCasesCountList[0].get('TotalCount'));
        if(openCaseCountList != null && !openCaseCountList.isEmpty())
             response.openCases = Integer.valueOf(openCaseCountList[0].get('TotalCount'));
        
    }
    
    //IMPORTANT : Wrapper class must implement the interface Core_RestAPI_SuccessContent
    public class CaseWrapper implements Core_RestAPI_SuccessContent{
        public String caseNumber {get;set;}
        public String status {get;set;}
        public String subStatus {get;set;}
        public String severity {get;set;}
        public String project {get;set;}
        public String intelProductName {get;set;}
        public String subject {get;set;}//Encrypted field
        public String contactName {get;set;}
        public String  accountName {get;set;}
        public String customerReferenceId {get;set;}
        public DateTime dateTimeOpened {get;set;}
        public DateTime lastModifiedDateTime {get;set;}
        public DateTime dateTimeClosed {get;set;}
        public String product  {get;set;}
        public String requestNumber {get;set;}
        public DateTime dateCreated {get;set;}
        public DateTime lastUpdated {get;set;}
        public String loginId {get;set;}
    }
    
    //Adding additional fields to actual response
    public class Core_RestAPI_Response_withCount extends Core_RestAPI_Response{
        Integer openCases {get;set;}
        Integer newCases {get;set;}
    }
}

//INFO : https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
//
//
//