/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseDetailV1_Handler 
* Version     : 1.0 
* Created Date: 6 Nov 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         11/16/2017               Handler class for process request and response for the case API
*****************************************************************************************************************************************/
public with sharing class Core_RestAPI_CaseDetailV1_Handler {

    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_200 = '200';
    private String MALFORMED_INPUT_9011 = '9011';
    private DateTime entryTime = null;
    private String apiName; 
    
    private static final String CONDITION = ' Where ' +Core_RestAPI_Util.getConditionWithURIParam('CaseNumber', 3);
    private static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    private List<CaseDetailWrapper> lCaseWrpr = new List<CaseDetailWrapper>();
    
    private final String GET_CASE_DETAIL_SOQL = 'SELECT CaseNumber, Status,Core_Sub_Status__c, AssetId,Core_Severity__c, Core_Severity_Reason__c, Core_IPS_Project_Case__r.Name, Core_IPS_Product__c, '+
        ' Subject, Contact.Name, Contact.Account.Name, Description,CreatedDate, ClosedDate, LastModifiedDate, Core_Issue_Description__c, '+
        ' Core_IPS_Supported_Product__r.Name, Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, Core_Code_Name__c, '+
        ' Core_CaseType__c, Core_Customer_Reference_ID__c, Core_End_Customer__c,Core_External_Issue_Category__c, Core_External_Issue_Subcategory__c,'+
        ' ( SELECT Id, Name, Core_IPS_Case__c, Core_IPS_Answer__c, Core_IPS_Question__c, Core_IPS_Question_Master__r.Core_IPS_Datatype__c FROM Core_IPS_Responses__r ' +
        ' WHERE Core_IPS_Agent_Only__c = false AND Core_IPS_Survey_Type__c = null) FROM Case '+ CONDITION  + ' AND Core_IPS_Customer_Visible__c = true LIMIT 1';
    
    
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    
    //Default constructor
    public Core_RestAPI_CaseDetailV1_Handler (DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName = APIname;
        System.debug('Core_RestAPI_CaseDetailV1_Handler URI '+RestContext.request.requestURI  );
    }
    
    
    //Case Detail for the given case number
    @testVisible public  Core_RestAPI_Response getCaseDetail(){
        
        System.debug(' Core_RestAPI_Case_DetailV1_Handler getCaseDetail Entered  \n ');
        
        try{
            //process all validations and skip processing the request if validations fails.
            boolean isRequestValid = doValidations();
            if(isRequestValid == true)
                processRequest();
            
        }catch(Exception e){
            response.successContent = null;
            lCaseWrpr = null;
            Core_RestAPI_Util.processException(e, ERROR_CODE_500, response, apiName, entryTime);
        }finally{
            System.debug('Core_RestAPI_Case_Handler Logging transaction and returning the response '+response);
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
            
        } 
        System.debug(' Core_RestAPI_Case_DetailV1_Handler getCaseDetail Exiting ');
        return response;
    }
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        System.debug('Core_RestAPI_CaseV1_Handler doValidations Invoked ');
        Boolean isRequestValid = true;
        if(!CASE_NUMBER.isNumeric() || CASE_NUMBER.length() != 8){
            Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011, response, apiName, entryTime);   
            isRequestValid = false;
        }else if(Core_RestAPI_Util.isRequestURIValid('/v1.0/cases/*') == false){
            //TODO Move to constant after the code review
            Core_RestAPI_Util.processException(null ,'404', response, apiName, entryTime);   
            isRequestValid = false;
        }
        
        return isRequestValid;
        
    }
    
    //Retrive the case details for the given case number.
    public void processRequest(){
        System.debug(' Core_RestAPI_CaseDetailV1_Handler processRequest Entering SOQL  \n '+GET_CASE_DETAIL_SOQL);
        for(Case c : Database.Query(GET_CASE_DETAIL_SOQL))
        {  
            CaseDetailWrapper cw = new CaseDetailWrapper();
            cw.caseNumber = c.CaseNumber;
            cw.status = c.Status;
            cw.subStatus = c.Core_Sub_Status__c;
            cw.severity = c.Core_Severity__c;
            if (c.Core_Severity__c == 'Critical'){
            cw.severityReason = c.Core_Severity_Reason__c;}
            else {cw.severityReason = null;}
            cw.ipsProjectName = c.Core_IPS_Project_Case__r.Name;
            cw.ipsProjectId = c.Core_IPS_Project_Case__r.Id;
            cw.intelProductName = c.Core_IPS_Product__c;
            cw.subject = c.Subject;
            cw.contactName = c.Contact.Name;
            cw.accountName = c.Contact.Account.Name;
            cw.dateTimeOpened = c.CreatedDate;
            cw.lastModifiedDateTime = c.LastModifiedDate;
            cw.dateTimeClosed = c.ClosedDate;
            cw.caseDescription = c.Description;
            cw.intelProductId= c.AssetId;
            cw.codeName = c.Core_Code_Name__c;
            cw.caseType = c.Core_CaseType__c;
            cw.customerReferenceId = c.Core_Customer_Reference_ID__c;
            cw.endCustomer = c.Core_End_Customer__c;
            cw.caseCategory = c.Core_External_Issue_Category__c;
            cw.caseSubcategory = c.Core_External_Issue_Subcategory__c;
            
            System.debug('\n Core_RestAPI_CaseDetailV1_Handler Environmental Questions ' +c.Core_IPS_Responses__r);
            //Set environment details
            if(c.Core_IPS_Responses__r != null ){
                system.debug('c.Environments__r ==>> '+c.Core_IPS_Responses__r);
                cw.environmentalDetailQuestions = new List<EnvironmentDetail>();
                for(Core_IPS_Response__c  envDet : c.Core_IPS_Responses__r){
                    EnvironmentDetail env = new EnvironmentDetail();
                    env.question = envDet.Core_IPS_Question__c;
                    if('Multiselect Picklist'.equalsIgnoreCase(envDet.Core_IPS_Question_Master__r.Core_IPS_Datatype__c)){
                        //Check if already added to the list
                        //IF added append
                        //ELSE add new
                        boolean alreadyAdded = false;
                        for(EnvironmentDetail alreadyAddedListItem : cw.environmentalDetailQuestions){
                            if(alreadyAddedListItem.question == env.question){
                                alreadyAddedListItem.answer = alreadyAddedListItem.answer+';'+envDet.Core_IPS_Answer__c;
                                alreadyAdded = true;
                                break;
                            }
                        }
                        if(alreadyAdded == false){
                            env.answer = envDet.Core_IPS_Answer__c;    
                            cw.environmentalDetailQuestions.add(env);
                        }
                        
                    }else{
                        env.answer = envDet.Core_IPS_Answer__c;    
                        cw.environmentalDetailQuestions.add(env);
                    }
                    
                }
            }
            lCaseWrpr.add(cw);
        } 
        response.successContent = lCaseWrpr;
        if(response.successContent != null && response.successContent.isEmpty())
            Core_RestAPI_Util.processException(null,MALFORMED_INPUT_9011, response, apiName, entryTime); 
        
        System.debug(' >> processRequest response.successContent '+response.successContent);
    }
    
    //IMPORTANT : Wrapper class must implement the interface Core_RestAPI_SuccessContent
    //Retrieves single case with all details
    public class CaseDetailWrapper   implements Core_RestAPI_SuccessContent{
        public String caseNumber {get;set;}
        public String status {get;set;}
        public String subStatus {get;set;}
        public String severity {get;set;}
        public String severityReason {get;set;}
        public String ipsProjectName {get;set;}
        public String intelProductName {get;set;}
        public String subject {get;set;}
        public String contactName {get;set;}
        public String  accountName {get;set;}
        public DateTime dateTimeOpened {get;set;}
        public DateTime lastModifiedDateTime {get;set;}
        public DateTime dateTimeClosed {get;set;}
        public String caseDescription {get;set;}
        public String ipsProjectId {get;set;}
        public String intelProductId{get;set;}
        public String codeName {get;set;}
        public String caseType {get;set;}
        public String customerReferenceId {get;set;}
        public String endCustomer  {get;set;}
        public String caseCategory {get;set;}
        public String caseSubcategory {get;set;}
        List<EnvironmentDetail> environmentalDetailQuestions {get;set;}
    }
    
    //Environment Details
    public class EnvironmentDetail{
        String question {get;set;}
        String answer {get;set;}
    }
    
}