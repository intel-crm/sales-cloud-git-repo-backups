/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseAttachmentV1_Handler 
* Version     : 1.0 
* Created Date: 3 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/3/2018              Handler class for process request and reponse for the case attachment API
*****************************************************************************************************************************************/
public with sharing class Core_RestAPI_CaseAttachmentV1_Handler{
    
    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_200 = '200';
    private String MALFORMED_INPUT_9011 = '9011';
    private DateTime entryTime = null;
    private String apiName = null;
    private static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    private static final String filterCondition = ' WHERE '+Core_RestAPI_Util.getConditionWithURIParam('Core_Case__r.CaseNumber', 3);
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    private String CaseAttachmentV1_URI ='/v1.0/cases/*/attachments';
    private String INVALID_URI_404= '404';
    
    private static final String GET_CASE_ATTACH_SOQL = 'SELECT Id,Core_File_Hyperlink__c,Core_Case__r.CaseNumber,'+
        'Name,Core_File_Name__c,Core_File_Description__c,Core_File_Size__c,CreatedDate,Core_Upload_Status__c,'+
        'Core_FileUploadedBy__r.Name FROM Core_IPS_Case_Attachments__c'+ filterCondition+' AND '+
        'Core_IPS_Attachment_Visibility__c = \'Public to Customers\' AND Core_Case__r.Core_IPS_Customer_Visible__c = true LIMIT ' + 
        LABEL.Core_RestAPI_CaseAttachmentV1_Record_Limits;
    
    //Default constructor
    public Core_RestAPI_CaseAttachmentV1_Handler(DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName = APIname;
    }  
    
    //Case Attachments for given case Number
    public Core_RestAPI_Response getCaseAttachments(){
        try{
            //process all validations and skip processing the request if validations fails.
            boolean isRequestValid = doValidations();
            if(isRequestValid == true)
                //Process the api request
                processRequest();
        }catch(Exception e){
            Core_RestAPI_Util.processException(e,ERROR_CODE_500, response, apiName, entryTime);
        }finally{ 
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }        
        return response;
    } 
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        Boolean isRequestValid = true;
        //List<Case> caseList = [Select Id FROM CASE Where CaseNumber =: CASE_NUMBER Limit 1];
        if(!CASE_NUMBER.isNumeric() || ( CASE_NUMBER != null && CASE_NUMBER.length() != 8 )){
            isRequestValid = false;
            Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011, response, apiName, entryTime);   
        } else if(Core_RestAPI_Util.isRequestURIValid(CaseAttachmentV1_URI ) == false){
            Core_RestAPI_Util.processException(null , INVALID_URI_404, response, apiName, entryTime);   
            isRequestValid = false;
        } 
        return isRequestValid;
    }
    
    //Execute the SOQL and populate the result to wrapper list objects
    //Retrieves all the attachments which are only 'Public to Customers' of case
    public void processRequest(){
        
        response.successContent = new List<CaseAttachmentWrapper>();
        CaseAttachmentWrapper csAttachWrpr = null;
        List<Core_IPS_Case_Attachments__c>lstCaseAttach = DATABASE.query(GET_CASE_ATTACH_SOQL);
        if(!lstCaseAttach.isEmpty()){
            for(Core_IPS_Case_Attachments__c objCaseAttach : lstCaseAttach ){
                csAttachWrpr = new CaseAttachmentWrapper();
                csAttachWrpr.ipsCaseAttachmentNumber = objCaseAttach.Name;
                csAttachWrpr.fileName = objCaseAttach.Core_File_Name__c;
                csAttachWrpr.fileDescription = objCaseAttach.Core_File_Description__c;
                csAttachWrpr.fileSize = objCaseAttach.Core_File_Size__c;
                csAttachWrpr.createdDate= objCaseAttach.CreatedDate;
                csAttachWrpr.uploadStatus = objCaseAttach.Core_Upload_Status__c;
                csAttachWrpr.fileDownloadLink = LABEL.Core_RestAPI_Attachment_Link+objCaseAttach.Id;
                response.successContent.add(csAttachWrpr);
                
            }
        }
    }
    //wrapper class for the response fields    
    public class CaseAttachmentWrapper  implements Core_RestAPI_SuccessContent{
        
        public String ipsCaseAttachmentNumber {get;set;}
        public String fileName {get;set;}
        public String fileDescription {get;set;}
        public String fileSize {get;set;}
        public DateTime createdDate{get;set;}
        public String uploadStatus{get;set;}
        public String fileDownloadLink{get;set;}
    }
}