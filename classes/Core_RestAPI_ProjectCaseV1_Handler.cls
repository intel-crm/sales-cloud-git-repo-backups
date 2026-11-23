/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_ProjectCaseV1_Handler
* Version     : 1.0  
* Created Date: 14 Dec 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         12/14/2017              Handler class to process request and response for the specific Project's Cases API
*****************************************************************************************************************************************/
public with sharing class  Core_RestAPI_ProjectCaseV1_Handler{
    
    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_200 = '200';
    private String MALFORMED_INPUT_9011 = '9011';
    private static final String ORDER_BY_LAST_MODF_DESC = ' Order by LastModifiedDate DESC ';
    private DateTime entryTime = null;
    private String apiName;
    private static final String PROJECT_ID =  Core_RestAPI_Util.getInputFromURIParam(3); 
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    private static final String filterCondition = Core_RestAPI_Util.getConditionWithURIParam('Core_IPS_Project_Case__r.Core_IPS_Project_ID__c', 3);
    private String ProjectCaseV1_URI ='/v1.0/projects/*/cases';
    private String INVALID_URI_404= '404';
    
    private static final String GET_PROJECT_CASES_SOQL = ' SELECT CaseNumber, Status,Core_Sub_Status__c, Core_Severity__c, Core_IPS_Project_Case__r.Core_IPS_Project_ID__c, Core_IPS_Product__c, '+
        ' Subject, Contact.Name, Contact.Account.Name, CreatedDate, ClosedDate, LastModifiedDate FROM case WHERE '
        +filterCondition + ' AND Core_IPS_Customer_Visible__c = true ' +ORDER_BY_LAST_MODF_DESC +' LIMIT '+Label.Core_RestAPI_CasesV1_Records_Limit;  
    
    //Default Constructor
    public Core_RestAPI_ProjectCaseV1_Handler(DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName= APIname;
        response.successContent = new List<ProjectCaseWrapper>();
        System.debug('Core_RestAPI_ProjectCaseV1_Handler  URI '+RestContext.request.requestURI  );
    }
    //Retrieve specific Project's Cases for the logged in User
    public Core_RestAPI_Response getProjectCases(){
        System.debug(' Core_RestAPI_ProjectCaseV1_Handler getProjectCases Entered  \n ');
        try{
            //Validations if need to be handled in util class      
            Boolean isRequestValid = doValidations();               
            //Process the api request
            if(isRequestValid == true)
            {
                processRequest();
            }                                
        }catch(Exception e){
            Core_RestAPI_Util.processException(e,ERROR_CODE_500,response,apiName,entryTime);
        }finally{        
            System.debug('Core_RestAPI_ProjectCaseV1_Handler Logging transaction and returning the response '+response);
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }        
        System.debug(' Core_RestAPI_ProjectCaseV1_Handler getProjectCases Exiting ');
        return response;
    } 
    // Validation if any for the API goes here
    @testVisible
    private Boolean doValidations(){
        
        System.debug('Core_RestAPI_ProjectCaseV1_Handler doValidations Invoked ');
        Boolean isRequestValid = true; 
        Pattern inputPattern = Pattern.compile('IPJ-[0-9]{6}');
        Matcher inputMatcher = inputPattern.matcher(PROJECT_ID);
        if(!inputMatcher.matches()){ 
            Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011 , response, apiName, entryTime);         
            isRequestValid = false;          
        }else if(Core_RestAPI_Util.isRequestURIValid(ProjectCaseV1_URI) == false){
            //TODO Move to constant after the code review
            system.debug('inside isRequestValid ==>> '+isRequestValid );
            Core_RestAPI_Util.processException(null , INVALID_URI_404, response, apiName, entryTime);   
            isRequestValid = false;
        }
        return isRequestValid;
        
    } 
    // Execute the SOQL and populate the result to wrapper list objects 
    public void processRequest(){
        
               
        System.debug(' Core_RestAPI_ProjectCaseV1_Handler processRequest Entering SOQL  \n '+GET_PROJECT_CASES_SOQL);
        // In this for loop retrieving fields of Case Standard Object
        List<Case> lstProjectCase = new List<Case>();
        lstProjectCase = DATABASE.Query(GET_PROJECT_CASES_SOQL );
        if(!lstProjectCase.isEmpty()){
            for(Case objCase: lstProjectCase)
            {    
                ProjectCaseWrapper objCaseWrapp = new ProjectCaseWrapper();
                objCaseWrapp.caseNumber =objCase.CaseNumber;
                objCaseWrapp.status =objCase.Status;
                objCaseWrapp.subStatus =objCase.Core_Sub_Status__c;
                objCaseWrapp.severity =objCase.Core_Severity__c;
                objCaseWrapp.ipsProjectId =objCase.Core_IPS_Project_Case__r.Core_IPS_Project_ID__c;
                objCaseWrapp.intelProductName =objCase.Core_IPS_Product__c;
                objCaseWrapp.subject =objCase.Subject;// Encrypted Field
                objCaseWrapp.contactName =objCase.Contact.Name;
                objCaseWrapp.accountName =objCase.Contact.Account.Name;
                objCaseWrapp.dateTimeOpened =objCase.CreatedDate;
                objCaseWrapp.lastModifiedDateTime =objCase.LastModifiedDate;
                objCaseWrapp.dateTimeClosed =objCase.ClosedDate;       
                response.successContent.add(objCaseWrapp);               
            }
        }
        System.debug('processRequest response.successContent '+response.successContent);
    }
    // Here below CaseWrapper Wrapper class must implements the interface Core_RestAPI_SuccessContent
    // Wrapper to build fields of case object
    public class ProjectCaseWrapper  implements Core_RestAPI_SuccessContent{
        
        public String caseNumber {get;set;}
        public String status {get;set;}
        public String subStatus {get;set;}
        public String severity {get;set;}
        public String ipsProjectId {get;set;}
        public String intelProductName {get;set;}
        public String subject {get;set;}//Encrypted field
        public String contactName {get;set;}
        public String  accountName {get;set;}
        public DateTime dateTimeOpened {get;set;}
        public DateTime lastModifiedDateTime {get;set;}
        public DateTime dateTimeClosed {get;set;}
        
    }
}