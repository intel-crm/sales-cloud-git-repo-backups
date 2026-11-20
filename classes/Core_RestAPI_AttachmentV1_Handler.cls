/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_AttachmentV1_Handler
* Version     : 1.0 
* Created Date: 02 Dec 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hayata Takeshita         12/02/2018               Handler class  for uploading a single attachment
*****************************************************************************************************************************************/
public with sharing class Core_RestAPI_AttachmentV1_Handler{
    private DateTime entryTime = null;
    private String apiName; 
    
    private static final String CASE_CONDITION = ' WHERE ' + Core_RestAPI_Util.getConditionWithURIParam('CaseNumber', 3) +
                                                    ' AND Contact.AccountId = :idUserAccount AND Core_IPS_Customer_Visible__c = TRUE';
    private static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    
    private static final String GET_CASE_SOQL = ' SELECT Id, ContactId, Status, Core_Sub_Status__c, Contact.Account.Core_IPS_SFT_Partner_Path__c FROM case '+ CASE_CONDITION + ' LIMIT 1';
    private static final String GET_USER_ACCOUNT_SOQL = 'SELECT Contact.Account.Id FROM User WHERE Id = :idUser';
    private static final String GET_ATTACHMENT_SOQL = 'SELECT Name FROM Core_IPS_Case_Attachments__c WHERE Id = :idAttach';
    
    private static final String ATTACHMENT_VISIBILITY = 'Public to Customers';
    private static final String ATTACHMENT_TYPE = 'Attachment';
    private static final String ATTACHMENT_UPLOAD_STATUS = 'Complete';
    private static final String SFT_APP_NAME = Label.SFT_APP_NAME;
    private static final String SFT_DESTINATION_FILEPATH = Label.SFT_DESTINATION_FILEPATH;    
    
    private static final String ERROR_CODE_500 = '500';
    private static final String ERROR_CODE_503 = '503';
    private static final String SUCCESS_CODE_200 = '200';
    private static final String NO_DATA_FOUND_9001 = '9001';
    private static final String MALFORMED_INPUT_9011 = '9011';
    private static final String INVALID_INPUT = '9011';
    private static final String MAX_LENGTH_EXCEEDED_9025 = '9025';

    private static final Integer MAX_CASENUMBER_LENGTH = 8;
    private static final Integer MAX_FILENAME_LENGTH = 100;
    private static final Integer MAX_FILE_DESCRIPTION_LENGTH = 1200;
    private static final Integer MAX_FILE_GUID_LENGTH = 36;
    private String validationErrorCode = null;
    private String validationErrorMessage = null;

    List<CaseAttachmentWrapper> lAttachWrpr = new List<CaseAttachmentWrapper>();
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    Case objCase = null;
    private Core_RestAPI_AttachmentV1_Wrapper objAttachmentParams = null;
    
    //Default constructor
    public Core_RestAPI_AttachmentV1_Handler (DateTime currTime, String aPIname, Core_RestAPI_AttachmentV1_Wrapper requestParams) {
        this.entryTime = currTime;
        this.apiName = APIname;
        this.objAttachmentParams = requestParams;
        
    }
    
    //Create attachment for the given case number
    public Core_RestAPI_Response createAttachment(){
        
        
        try{
            //process all validations and skip processing the request if validations fails.
            boolean isRequestValid = doValidations();
            if(isRequestValid == false) {
                Core_RestAPI_Util.processException(null , validationErrorCode, response, apiName, entryTime, objAttachmentParams);
                response.errorContent.errorMessage += validationErrorMessage;
            } else {
                
                processRequest();
            }
        }catch(SFT_Internal_Exception e){
            response.successContent = null;
            Core_RestAPI_Util.processException(e, ERROR_CODE_503, response, apiName, entryTime, objAttachmentParams );
        }catch(Exception e){
            response.successContent = null;
            Core_RestAPI_Util.processException(e, ERROR_CODE_500, response, apiName, entryTime , objAttachmentParams );
        }finally{
            
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
            
        } 
        
        return response;
    }
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations() {
        
        Boolean isRequestValid = true;

        if(isValidFilename(objAttachmentParams.Filename) == false) {
            isRequestValid = false;
            validationErrorCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ': Filename was empty or exceeded the max length of ' + MAX_FILENAME_LENGTH;
        }

        if(isValidDescription(objAttachmentParams.FileDescription) == false) {
            isRequestValid = false;
            validationErrorCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ': Description was empty or exceeded the max length of ' + MAX_FILE_DESCRIPTION_LENGTH;
        }
        
        
        if(!CASE_NUMBER.isNumeric() ) {
            isRequestValid = false;
            validationErrorCode = MALFORMED_INPUT_9011;
            validationErrorMessage = ': Case Number Not Numeric';
        }

        if(CASE_NUMBER.length() > MAX_CASENUMBER_LENGTH ) {
            isRequestValid = false;
            validationErrorCode = MALFORMED_INPUT_9011;
            validationErrorMessage = ': Case Number Too Long';
        }
        
        Integer intValidCase = isValidCase();
        if(intValidCase <> 0) {
            isRequestValid = false;
            if(intValidCase == 1) {
                validationErrorCode = NO_DATA_FOUND_9001;
                validationErrorMessage = ' Case Number';
            } else if(intValidCase == 2) {
                validationErrorCode = INVALID_INPUT;
                validationErrorMessage = ': Case Is Closed Or On GEC Hold';
            }
        }
        
        //this relies on isValidCase() being executed first.
        if(objCase <> null && String.isEmpty(objCase.Contact.Account.Core_IPS_SFT_Partner_Path__c)) {
            isRequestValid = false;
            validationErrorCode = ERROR_CODE_503;
            validationErrorMessage = ': Missing SFT folder name on account.  Contact Intel.';
        }
        
        return isRequestValid;
    }
    
    //add attachment to case.
    public void processRequest(){
        
        List<Core_IPS_Case_Attachments__c> lAttach = new List<Core_IPS_Case_Attachments__c>();

        //isValidCase should already have been called during validations.  This is for safety.
        if(objCase == null) { isValidCase(); }
        
        //objCase will be not null if contact's account matches user's account.
        if(objCase != null) {
            
            Core_IPS_Case_Attachments__c oAttach = createAttachmentRecord(true);
            
            callSFTMoveFile(oAttach);        
            
            //create attachment record after response
            if(oAttach.Core_File_GUID__c != null) {
                oAttach.Core_File_URL__c = Label.Core_RestAPI_SFT_Download_URL;
                oAttach.Core_File_URL__c = String.format(oAttach.Core_File_URL__c = Label.Core_RestAPI_SFT_Download_URL,
                                                         new List<String>{EncodingUtil.urlEncode(oAttach.Core_File_Name__c,'UTF-8'),
                                                                       oAttach.Core_File_GUID__c,
                                                                       objCase.Id});

                
                insert oAttach;
                                
                Id idAttach = oAttach.Id;
                for(Core_IPS_Case_Attachments__c oAtt : Database.Query(GET_ATTACHMENT_SOQL)) {
                    CaseAttachmentWrapper oAttachWrpr = new CaseAttachmentWrapper();
                    oAttachWrpr.caseAttachmentID =oAtt.Name;
                    lAttachWrpr.add(oAttachWrpr);
                }
            }
        }

        response.successContent = lAttachWrpr;
        

        if(response.successContent != null && response.successContent.isEmpty()) {
            Core_RestAPI_Util.processException(null, ERROR_CODE_500, response, apiName, entryTime);
        }
        
        
    }
    
    @TestVisible private boolean callSFTMoveFile(Core_IPS_Case_Attachments__c oAttach) {
    
        
        boolean isSuccess = false;
        /*--START --US-US1018637-- 01-05-2021 -- Farooq -- change from old callout to APIGEE--*/
        String strSourceFilePath = objCase.Contact.Account.Core_IPS_SFT_Partner_Path__c; 
        String strSourceFileName = objAttachmentParams.filename;
        String strBody = '{' +
                            '"AppName": "' + SFT_APP_NAME + '",' +
                            '"SourceFilePath": "' + strSourceFilePath + '",' +
                            '"SourceFileName": "' + strSourceFileName + '",';
            
        if(oAttach.Core_File_GUID__c != null) {
            strBody = strBody + '"DestinationFileName": "' + oAttach.Core_File_GUID__c + '",';
        }
        
        strBody = strBody + '"DestinationFilePath": "' + SFT_DESTINATION_FILEPATH + '"}';
        
        
	String ips_Myintel_EndPoint = 'callout:Core_SFT_MoveFile_NamedCred'; //TWC745-6469-IPS Named Credentials chnage
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ips_Myintel_EndPoint);
            request.setMethod('POST');
            
            request.setHeader('Content-Type', 'application/json');
            request.setBody(strBody);
            HttpResponse response = http.send(request);
            String resBody = response.getBody();
            
            JSONParser parser = JSON.createParser(response.getBody());
            ResponseMoveFile oMoveFile = null;
            oMoveFile = (ResponseMoveFile)JSON.deserialize(resBody, ResponseMoveFile.class);
            
            if (response.getStatusCode() == 200) {  // successful
                if(String.isEmpty(oMoveFile.message) == true) {  //if Message has a value, there was an error.
                    isSuccess = true;
                    oAttach.Core_File_GUID__c = oMoveFile.destinationFileName;
                    
                    if(String.isEmpty(oMoveFile.fileSize) == false) {
                        oAttach.Core_File_Size__c = fileSizeToString(Long.valueOf(oMoveFile.fileSize));    
                    }
                } else { //there was an error
                    throw new SFT_Internal_Exception('SFT MoveFile returned: ' + oMoveFile.message + ' in Core_RestAPI_AttachmentV1_Handler.callSFTMoveFile');
                }
            } else { //http.send was not successful
                throw new SFT_Internal_Exception('SFT MoveFile returned with HTTP Status: ' + response.getStatusCode() +
                                                 'and Status: ' + response.getStatus() + ' in Core_RestAPI_AttachmentV1_Handler.callSFTMoveFile');
            }          
            
        
        //HttpResponse res = h.send(req);
        
        

        return isSuccess;
    }
    
    @TestVisible private Core_IPS_Case_Attachments__c createAttachmentRecord(boolean createFileGUID) {
    
        Core_IPS_Case_Attachments__c oAttach = new Core_IPS_Case_Attachments__c();
        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Case__c.isCreateable()) {// Fls Create fix - Gangadhar
        	oAttach.Core_Case__c = objCase.Id;
        }
        oAttach.Core_File_Name__c = objAttachmentParams.filename;
        oAttach.Core_File_Description__c = objAttachmentParams.fileDescription;
        oAttach.Core_Last_Status_Updated_At__c = System.now();

        oAttach.Core_Upload_Status__c = ATTACHMENT_UPLOAD_STATUS;
        oAttach.Core_FileUploadedBy__c = UserInfo.getUserId();
        oAttach.Core_Type__c = ATTACHMENT_TYPE;
        oAttach.Core_IPS_Attachment_Visibility__c = ATTACHMENT_VISIBILITY;

        if(createFileGUID == true) {
            oAttach.Core_File_GUID__c = (CASE_NUMBER + '-' + (DateTime.now()).getTime()  + '-' + oAttach.Core_File_Name__c.replaceAll(' ', '-')).left(MAX_FILE_GUID_LENGTH);
        }

        
        return oAttach;
    }

    @TestVisible private boolean isValidFilename(string strFilename) {
        boolean isValid = false;
        if(strFilename != null) {
            String strFilenameTrim = strFilename.trim();
            if(strFilenameTrim.length() <= MAX_FILENAME_LENGTH && strFilenameTrim.length() != 0) {
                isValid = true;
            }
        }
        return isValid;
    }
    
    @TestVisible private boolean isValidDescription(string strDescription) {
        boolean isValid = false;
        if(strDescription != null) {
            String strDescriptionTrim = strDescription.trim();
            if(strDescriptionTrim.length() <= MAX_FILE_DESCRIPTION_LENGTH && strDescriptionTrim.length() != 0) {
                isValid = true;
            }
        }
        return isValid;
    }
    
    //Checks if contact's account matches user's account.  Also, update static objCase 
    //static variable for later use.
    @TestVisible private Integer isValidCase() {
        Id idUserAccount = getAccountIdOfUser();
        Integer isValid = 0;
        Case objCaseFound = null;
        
        //GET_CASE_SOQL returns record if contact's account matches user's account

        for(Case cs : Database.Query(GET_CASE_SOQL))  //there should only be one case
        {
            objCaseFound = cs;

        }
        
        if(objCaseFound == null) {
            isValid = 1;  // Case not found
        } else {
            //check for GEC Hold or Closed
            if(!String.isEmpty(objCaseFound.Status) && objCaseFound.Status.equalsIgnoreCase('Closed')) {
                isValid = 2;
            }
            
            if(!String.isEmpty(objCaseFound.Core_Sub_Status__c) && objCaseFound.Core_Sub_Status__c.equalsIgnoreCase('GEC Hold')) {
                isValid = 2;
            }
        }
        
        if(isValid == 0) {
            objCase = objCaseFound;
        }

        return isValid;
    }
    
    @TestVisible private Id getAccountIdOfUser() {  //put validation in common class.
        //Get logged in user's account record Id
        Id idUser = UserInfo.getUserId();
        Id idUserAccount = null;
        //There will only be one record returned
        for(User u : Database.Query(GET_USER_ACCOUNT_SOQL)) {
            if(String.isEmpty(u.ContactId) == false) {
                idUserAccount = u.Contact.Account.Id;
            }
        }

        
        return idUserAccount;
    }

    @TestVisible private static String fileSizeToString(Long lValue) {
        /* string representation if a file's size, such as 2 KB, 4.1 MB, etc */
        if (lValue < 1024) {
            return string.valueOf(lValue) + ' Bytes';
        } else {
            if (lValue >= 1024 && lValue < (1024*1024)) {
                //KB
                Decimal kb = Decimal.valueOf(lValue);
                kb = kb.divide(1024,2);
                return string.valueOf(kb.setScale(2)) + ' KB';
            } else if (lValue >= (1024*1024) && lValue < (1024*1024*1024)) {
                //MB
                Decimal mb = Decimal.valueOf(lValue);
                mb = mb.divide((1024*1024),2);
                return string.valueOf(mb.setScale(2)) + ' MB';
            } else {
                //GB
                Decimal gb = Decimal.valueOf(lValue);
                gb = gb.divide((1024*1024*1024),2);
                
                return string.valueOf(gb.setScale(2)) + ' GB';
            }    
        }
    }
    
    //IMPORTANT : Wrapper class must implement the interface Core_RestAPI_SuccessContent
    //Retrieves single case with all details
    public class CaseAttachmentWrapper implements Core_RestAPI_SuccessContent{
        public String caseAttachmentID {get;set;}
    }
    
    public class responseMoveFile {
        public string Message{get;set;}
        public string AppName{get;set;}
        public string DestinationFileName{get;set;}
        public string FileSize{get;set;}
    }
    
    public class SFT_Internal_Exception extends Exception {}
}