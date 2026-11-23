public with sharing class Core_IPS_RDC_Attachments_Handler{
    
    //private static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(4);
    private static final String REQ_FIELD_MISSING_9002 = '9002';
    private static final String UNAUTHORIZED_CASE_RECORDTYPE_9003 = '9003';
    private static final String MISMATCH_CASENUMBERS_9023 = '9023';
    private static final String MAX_LENGTH_EXCEEDED_9025 = '9025';
    private static final String ERROR_CODE_500 = '500';
    private static final String INVALID_INPUT = '9011';
    private static final String INVALID_CONTACT = '9014';
    private static final String INACTIVE_CONTACT = '9019';
    private static final String INVALID_PROFILE = '9013';
    private static final String INACTIVE_PROJECTMEMBER = '9018';
    private String validationErrorCode = null;
    private String validationErrorMessage = '';
    private User runningUser = null;
    private List<User> lstUser ;
    @testVisible private Case caseObj ;
    private User userObj = null;
    private DateTime entryTime = null;
    private String apiName = null;
    private String Contact_Id = null;
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    private Core_IPS_RDC_AttachmentsWrapper CaseAttWrapper = null;
    private String CaseAtt_URI='/IPS_RDC/v1.0/cases/attachments';
    private String INVALID_URI_404= '404';
    
    private static final String ATTACHMENT_VISIBILITY = 'Public to Customers';
    private static final String ATTACHMENT_TYPE = 'Attachment';
    private static final String ATTACHMENT_UPLOAD_STATUS = 'Complete';
    
    private static final Integer MAX_CASENUMBER_LENGTH = 8;
    private static final Integer MAX_FILENAME_LENGTH = 100;
    private static final Integer MAX_FILE_DESCRIPTION_LENGTH = 1200;
    private static final Integer MAX_FILE_GUID_LENGTH = 36;
    
    //Default Constructor
    public Core_IPS_RDC_Attachments_Handler(DateTime currTime, String APIname,Core_IPS_RDC_AttachmentsWrapper ccWrpr){
        
        System.debug('Inside Core_IPS_RDC_Attachments_Handler Constructor');
        this.runningUser = [Select ContactId, AccountId FROM User where Id =: UserInfo.getUserId()];
        this.entryTime = currTime;
        this.apiName = APIname;
        this.CaseAttWrapper = ccWrpr;
        
        if(ccWrpr.contactEmail == ''){
            this.Contact_Id = null;
        }
        if(ccWrpr.contactEmail!= null){
            this.Contact_Id= [select Id from Contact where Email =:ccWrpr.contactEmail].Id;
        }
        
        //System.debug(' Initialization completed CASE_NUMBER '+CASE_NUMBER);
        
    }
    
    //Method to create case attachment for particular case
    public Core_RestAPI_Response createCaseAttachments(){
        try{
            System.debug('Inside createCaseAttachments method');
            Boolean allAttachmentValidationsPassed= doAllCaseAttachmentValidation();
            System.debug('allAttachmentValidationsPassed==>> '+allAttachmentValidationsPassed);
            if(allAttachmentValidationsPassed == false){
                Core_RestAPI_Util.processException(null, validationErrorCode, response, apiName , entryTime,CaseAttWrapper );
                response.errorContent.errorMessage += validationErrorMessage;
            }else{
                insertCaseAttachment();
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Core_IPS_RDC_Attachments_Handler Exception : ' + Core_RestAPI_Util.getExceptionAsString(e));
            Core_RestAPI_Util.processException(e,ERROR_CODE_500, response, apiName, entryTime,CaseAttWrapper);
        }finally{ 
            System.debug('Core_IPS_RDC_Attachments_Handler Logging transaction and returning the response '+response);        
            if(String.isBlank(response.code))
                response.code = '201';
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }     
        
        return response;
    }
    public void insertCaseAttachment(){
        
        System.debug('Inside insertCaseAttachment method');
        System.debug('runningUser.AccountId ===>> '+runningUser.AccountId);
        system.debug('Contact_Id ====>> '+Contact_Id);
        
        List<Core_IPS_Case_Attachments__c> lstCaseAtt= new List<Core_IPS_Case_Attachments__c>();
        Core_IPS_Case_Attachments__c newAtt = new Core_IPS_Case_Attachments__c(); 
        System.debug('???????'+caseObj);
        case caseObj = [select CaseNumber,Id from case where CaseNumber =:CaseAttWrapper.CaseNumber];
        if(caseObj != null){
            system.debug('----+++++++' +caseObj);
            newAtt.Core_Case__c= caseObj.Id;
            newAtt.Core_File_Name__c = CaseAttWrapper.fileName;
            newAtt.Core_File_Description__c = caseAttWrapper.fileDescription;
            newAtt.Core_Last_Status_Updated_At__c = System.now();
            newAtt.Core_Upload_Status__c = ATTACHMENT_UPLOAD_STATUS;
            newAtt.Core_File_GUID__c = caseAttWrapper.fileGUID;
            if(newAtt.Core_File_GUID__c != null) {
                newAtt.Core_File_URL__c = Label.Core_RestAPI_SFT_Download_URL;
                newAtt.Core_File_URL__c = String.format(newAtt.Core_File_URL__c = Label.Core_RestAPI_SFT_Download_URL,
                                                        new List<String>{EncodingUtil.urlEncode(newAtt.Core_File_Name__c,'UTF-8'),
                                                            newAtt.Core_File_GUID__c,
                                                            caseObj.Id});  
                
            }
            
            if(String.isNotBlank(LABEL.Core_RestAPI_Attachment_Source)){
                newAtt.Core_IPS_Attachment_Source__c = LABEL.Core_RestAPI_Attachment_Source;
            } 
            
            if(Contact_Id != null){
                newAtt.Core_IPS_Uploaded_By_Email__c = userObj.Contact.Email; 
                newAtt.Core_IPS_Uploaded_By_FirstName__c = userObj.Contact.FirstName;
                newAtt.Core_IPS_Uploaded_By_Name__c = userObj.Contact.Name;
                newAtt.Core_FileUploadedBy__c = userObj.Id;
            }else{
                newAtt.Core_FileUploadedBy__c = UserInfo.getUserId();
            }
            
            
            if((Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS') != null) && (!String.isBlank(Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c))){
                newAtt.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            }
            
            lstCaseAtt.add(newAtt);
            upsert lstCaseAtt;
            
            system.debug('execution ++====>>  ');
            CaseAttWrapper  csAtt = new CaseAttWrapper ();
            csAtt.caseAttachmentNumber= [SELECT Id, Name FROM Core_IPS_Case_Attachments__c where id =:newAtt.Id].Name;
            List<CaseAttWrapper> lstCaseComm = new List<CaseAttWrapper >();
            lstCaseComm.add(csAtt);
            response.successContent = lstCaseComm;
        } 
        
    } 
    
    //Validate the Contact passed by the customer
    @testVisible
    private Boolean validateContact(){
        
        System.debug('Inside validating the contact record');
        Boolean isValidContact = true;
        if(Contact_Id != null){
            lstUser= [SELECT Id,Contact.Email,Contact.FirstName,Contact.Name,isActive,ContactId,Contact.Core_IPS_Active__c,AccountId,ProfileId FROM User WHERE ContactId =: Contact_Id  LIMIT 1];
            System.debug('lstUser'+lstUser);
            if(!lstUser.isEmpty()){
                userObj = lstUser[0];
            }
            // system.debug('userObj ===>>> '+userObj);
            system.debug('Contact_Id ===>>> '+Contact_Id);
            if((Core_RestAPI_Util.isValidContactId(Contact_Id,userObj,runningUser)) == true){
                isValidContact = false;
                validationErrorCode = INVALID_CONTACT;  
                validationErrorMessage = '';
            }
            else if(Core_RestAPI_Util.validIsActive(userObj) == true){
                isValidContact = false;
                validationErrorCode = INACTIVE_CONTACT; 
                validationErrorMessage = '';
            }
            else if(Core_RestAPI_Util.isValidProfile(userObj) == true){
                isValidContact = false;
                validationErrorCode = INVALID_PROFILE ; 
                validationErrorMessage = '';
            }
            else if(Core_RestAPI_Util.isvalidProjectMember(caseObj,Contact_Id) == true){
                isValidContact =false;
                validationErrorCode= INACTIVE_PROJECTMEMBER ;
                validationErrorMessage = '';
            }
            else if(Contact_Id != null && userObj.Id != null && Core_RestAPI_Util.validateContactCaseVisbility(caseObj,userObj) == true){
                isValidContact = false;
                validationErrorCode = INVALID_PROFILE ; 
                validationErrorMessage = '';
            }
            
        }   
        System.debug('validate Contact isValid :'+isValidContact);
        return isValidContact ;
        
        
    }
    
    
    //Validate whether URI is valid or not
    @testVisible
    private Boolean validateURI(){
        System.debug('Inside validateURI method');
        Boolean isURIValid = true;
        if(Core_RestAPI_Util.isRequestURIValid(CaseAtt_URI) == false){
            validationErrorCode = INVALID_URI_404;
            isURIValid = false;
        } 
        System.debug('validateURI isValid :'+isURIValid);
        return isURIValid ;
    }
    
    
    //Validate whether case number exists or not
    @testVisible
    private Boolean validateCaseNumber(){
        
        System.debug('Inside validateCaseNumber method');
        Boolean isValid = true;
        List<Case> caseList = [Select Id,Core_IPS_Customer_Visible__c,Core_IPS_Project_Case__c,Core_Sub_Status__c,Status,RecordType.Name FROM CASE Where CaseNumber =: CaseAttWrapper.CaseNumber Limit 1]; 
        System.debug('caseList -->'+caseList );
        if(!caseList.isEmpty()){
            caseObj = caseList[0];
        }
        if(caseObj == null){
            isValid = false;
            validationErrorCode = INVALID_INPUT;
            validationErrorMessage = ' Case Number';
        }
        
        System.debug('validateCaseNumber result'+isValid);
        return isValid;
        
    }
    @testVisible
    private boolean validateCaseVisibility(){
        Boolean isValid = true;
        if(caseObj.Core_IPS_Customer_Visible__c == false){
            isValid = false;
            validationErrorCode = INVALID_INPUT;
            validationErrorMessage = ',Invisible Case Number';
        }
        return isValid;
    }
    
    //Validate the required fields
    @testVisible 
    private Boolean validateAttachmentRequiredFields(){
        System.debug('Inside validateAttachmentRequiredFields method');
        Boolean flag = true;
        if (String.isBlank(CaseAttWrapper.fileName) ){
            validationErrorCode = REQ_FIELD_MISSING_9002 ;  
            validationErrorMessage = ' attachment file name';
            flag = false;
        }
        if (String.isBlank(CaseAttWrapper.contactEmail) ){
            validationErrorCode = REQ_FIELD_MISSING_9002 ;  
            validationErrorMessage = ' contactEmail';
            flag = false;
        }
        System.debug('validateAttachmentRequiredFields result'+flag);
        return flag;
    }
    
    //Validate casetype and caseStatus of Case 
    @testVisible 
    private Boolean validateCaseTypeStatus(){
        
        System.debug('Inside validateCaseTypeStatus method');
        Boolean flag = true;
        if((caseObj  != null) && (caseObj.RecordType.Name == 'IPS Closed Case' || caseObj.RecordType.Name == 'IPS GEC ReadOnly')){
            flag= false;
            validationErrorCode = UNAUTHORIZED_CASE_RECORDTYPE_9003 ;
            validationErrorMessage = ' ';   
        }
        System.debug('validateCaseTypeStatus result'+flag);
        return flag ;
    }
    
    //Validate the case number format
    @testVisible 
    private boolean validateNumbericCaseNumber(){
        
        System.debug('Inside validateNumbericCaseNumber method');
        Boolean isRequestValid = true;
        
        if((!CaseAttWrapper.CaseNumber.isNumeric() || CaseAttWrapper.CaseNumber.length() != 8 )){
            
            isRequestValid = false;
            validationErrorCode = INVALID_INPUT;
            validationErrorMessage = ' Case Number';
        }  
        System.debug('validateNumbericCaseNumber result'+isRequestValid);  
        return isRequestValid;
    }
    
    //Validate the length of file name and description fields on case attachment field 
    @testVisible 
    private boolean validateLengthCaseAttachment(){
        
        System.debug('Inside validateLengthCaseAttachment method');
        Boolean isValidLength = true;
        if (CaseAttWrapper.fileName != null && Core_RestAPI_Util.isMaxLengthExceeded(CaseAttWrapper.fileName, 255)){
            isValidLength= false;
            validationErrorCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ' 255';  
        }
        if (CaseAttWrapper.fileDescription != null && Core_RestAPI_Util.isMaxLengthExceeded(CaseAttWrapper.fileDescription, 1000)){
            isValidLength= false;
            validationErrorCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ' 1000';  
        }
        System.debug('validateLengthCaseAttachment result'+isValidLength); 
        return isValidLength ;
    }
    
    
    //All the validation of Case attachments
    @testVisible 
    private boolean doAllCaseAttachmentValidation(){
        
        System.debug('Inside doAllCaseAttachmentValidation method');
        Boolean isAllValid =  validateURI() && validateNumbericCaseNumber()  && validateAttachmentRequiredFields()  && validateLengthCaseAttachment() && validateCaseNumber() && validateCaseTypeStatus() && validateCaseVisibility() && validateContact();
        System.debug('doAllCaseAttachmentValidation result'+isAllValid); 
        return isAllValid ;
    }
    
    //Wrapper class for the success response
    public class CaseAttWrapper implements Core_RestAPI_SuccessContent{
       String caseAttachmentNumber{get;set;}
    }
}