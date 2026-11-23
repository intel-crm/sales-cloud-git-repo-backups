/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseV1_Handler 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/6/2017               Handler class for process request and reponse for the case API
*****************************************************************************************************************************************/
public with sharing class  Core_RestAPI_CaseV1_Handler {
    
   private String INVALID_QUERY_PRAMS_9010 = '9010';
    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_200 = '200';
    private DateTime entryTime = null;
    private String apiName; 

    private static final String ORDER_BY =' Order by CaseNumber DESC ';
    public Core_RestAPI_Response_withCount response = new Core_RestAPI_Response_withCount();
    List<String> columnNames = new List<String> ();
    @testVisible private Map<String, String> allowedRequestURIParams = new Map<String, String>();
    
    private static String  condition = '';  
    private static String addCondition= '';  
    private static String getCondition(){
        String queryParamValue = Core_RestAPI_Util.getRequestParam('v');
        if('mycases'.equalsIgnoreCase(queryParamValue))
            condition = ' AND Core_IPSPortal_Check__c = true ';
        return condition;
    }

    // Niyaz -- 12/06/2025 --- added as part of vulnerability fix, Removed the CreatedBy.Core_Login_Id__c from the below query (field is queried but never set in CaseWrapper, creating unnecessary PII risk)
    private static final String GET_CASES_SOQL =  ' SELECT id,CaseNumber, Status,Core_Sub_Status__c, Core_Severity__c, Core_IPS_Project_Case__r.Name, Core_IPS_Product__c, '+
        ' Subject, Contact.Name, Contact.Account.Name, CreatedDate,Core_Customer_Reference_ID__c, ClosedDate, LastModifiedDate, Core_Issue_Description__c,  '+
        ' Core_IPS_Project_Case__r.Core_IPS_Project_ID__c, Core_IPS_Product_name__c '+
        ' FROM case WHERE Core_IPS_Customer_Visible__c = true'+ getCondition() + ORDER_BY + 'LIMIT '+Label.Core_RestAPI_CasesV1_Records_Limit; 
    
    
    public Core_RestAPI_CaseV1_Handler(DateTime currTime, String APIname){
        System.debug('GET_CASES_SOQL --->'+GET_CASES_SOQL );
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
            response.successContent = null;
        }finally{
            System.debug('Core_RestAPI_CaseV1_Handler Logging transaction and returning the response '+response);
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200 ;
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
        System.debug('Core_RestAPI_CaseV1_Handler doValidations Existing : isRequestValid '+isRequestValid);
        return isRequestValid;
    }
    
    
    //Execute the SOQL and populate the result to wrapper list objects 
    public void processRequest(){
        System.debug('Core_RestAPI_CaseV1_Handler  processRequest ');
        response.successContent = new List<CaseWrapper>();
        for(Case c : Database.Query(GET_CASES_SOQL))
        {  
            CaseWrapper cw = new CaseWrapper();
            cw.caseNumber = c.CaseNumber;
            cw.status = c.Status;
            cw.subStatus = c.Core_Sub_Status__c;
            cw.severity = c.Core_Severity__c;
            cw.ipsProjectName = c.Core_IPS_Project_Case__r.Name;
            cw.intelProductName = c.Core_IPS_Product__c;
            cw.subject = c.Subject;
            cw.contactName = c.Contact.Name;
            cw.accountName = c.Contact.Account.Name;
            cw.dateTimeOpened = c.CreatedDate;
            cw.lastModifiedDateTime = c.LastModifiedDate;
            cw.dateTimeClosed = c.ClosedDate;
            cw.customerReferenceId= c.Core_Customer_Reference_ID__c;
            cw.caseLink=Label.Core_RestAPI_Attachment_Link+c.id;
            response.successContent.add(cw);
        }
            
       List<aggregateResult> newCasesCountList = new List<aggregateResult>();
       List<aggregateResult> openCaseCountList = new List<aggregateResult>();
       if(!String.isBlank(getCondition())){
           System.debug('Inside myCase');
           newCasesCountList = [SELECT count(id) TotalCount, status FROM case WHERE Core_IPSPortal_Check__c = true AND Status = 'New' group by status];
           openCaseCountList  = [SELECT count(id) TotalCount, status FROM case WHERE Core_IPSPortal_Check__c = true AND Status = 'Open' group by status];
       }else{
           System.debug('Inside List of Cases');
           /*START Niyaz -- 12/06/2025 --- added as part of vulnerability fix Core_IPS_Customer_Visible__c = true */
           newCasesCountList = [SELECT count(id) TotalCount, status FROM case WHERE Status = 'New' AND Core_IPS_Customer_Visible__c = true group by status ];  
           openCaseCountList  = [SELECT count(id) TotalCount, status FROM case WHERE Status = 'Open' AND Core_IPS_Customer_Visible__c = true group by status ];
           /*END Niyaz -- 12/06/2025 */
       }
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
        public String ipsProjectName {get;set;}
        public String intelProductName {get;set;}
        public String subject {get;set;}//Encrypted field
        public String contactName {get;set;}
        public String  accountName {get;set;}
        public String customerReferenceId {get;set;}
        public DateTime dateTimeOpened {get;set;}
        public DateTime lastModifiedDateTime {get;set;}
        public DateTime dateTimeClosed {get;set;}
        public String caseLink{get;set;}
    }
    
    //Adding additional fields to actual response
    public class Core_RestAPI_Response_withCount extends Core_RestAPI_Response{
        Integer openCases {get;set;}
        Integer newCases {get;set;}
    }
    
 
    
}

//INFO : https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm