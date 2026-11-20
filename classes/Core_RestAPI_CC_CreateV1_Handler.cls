/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CC_CreateV1_Handler
* Version     : 1.0 
* Created Date: 19 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/19/2018              Creates Case Comments
*****************************************************************************************************************************************/
public class Core_RestAPI_CC_CreateV1_Handler{
    
    private static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    private static final String  REQ_FIELD_MISSING_9002 = '9002';
    private static final String UNAUTHORIZED_CASE_RECORDTYPE_9004 = '9004';
    private static final String MISMATCH_CASENUMBERS_9023 = '9023';
    private static final String MAX_LENGTH_EXCEEDED_9025 = '9025';
    private static final String ERROR_CODE_500 = '500';
    private static final String SUCCESS_CODE_200 = '200';
    private static final String  INVALID_INPUT = '9011';
    private String validationErrorCode = null;
    private String validationErrorMessage = '';
    @testVisible private Case caseObj =  null;
    private DateTime entryTime = null;
    private String apiName = null;
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    private Core_RestAPI_CC_CreateV1_Wrapper CaseCommentWrapper = null;
    private String CaseCommentV1_URI ='/v1.0/cases/*/comments';
    private String INVALID_URI_404= '404';
    
    
    //Default Constructor
    public Core_RestAPI_CC_CreateV1_Handler(DateTime currTime, String APIname,Core_RestAPI_CC_CreateV1_Wrapper ccWrpr){
        
        this.entryTime = currTime;
        this.apiName = APIname;
        this.CaseCommentWrapper = ccWrpr;
        
    }
    
    //Method to create case comment for particular case
    public Core_RestAPI_Response createCaseComments(){
        try{
            Boolean allCommentValidationsPassed= doAllCaseCommentValidation();
            if(allCommentValidationsPassed == false){
                Core_RestAPI_Util.processException(null, validationErrorCode, response, apiName , entryTime,CaseCommentWrapper );
                response.errorContent.errorMessage += validationErrorMessage;
            }else{
                insertCaseComment();
            }
        }catch(Exception e){
            Core_RestAPI_Util.processException(e,ERROR_CODE_500, response, apiName, entryTime,CaseCommentWrapper);
        }finally{ 
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }     
        
        return response;
    }
    public void insertCaseComment(){
    
        List<Core_IPS_Case_Comments__c> lstCaseComments = new List<Core_IPS_Case_Comments__c>();
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        if(caseObj != null){
            if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case__c.isCreateable()) { //Fls create fix -Gangadhar
            newComment.Core_IPS_Case__c = caseObj.Id;
            }
            newComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
            if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Rich_Comment__c.isCreateable()) { //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
            newComment.Core_IPS_Rich_Comment__c = caseCommentWrapper.comment;
            }
            newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId());
            lstCaseComments.add(newComment);
            insert lstCaseComments;
            
            CaseCommentWrapper  csComment = new CaseCommentWrapper ();
            //FLS check added-Venugopal
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
            csComment.caseCommentId= [SELECT Id, Name FROM Core_IPS_Case_Comments__c where id =:newComment.Id].Name;
            }
            List<CaseCommentWrapper > lstCaseComm = new List<CaseCommentWrapper >();
            lstCaseComm.add(csComment);
            response.successContent = lstCaseComm;
        } 
        
    }
   //Validate whether URI is valid or not
    @testVisible
    private Boolean validateURI(){
        Boolean isURIValid = true;
        if(Core_RestAPI_Util.isRequestURIValid(CaseCommentV1_URI) == false){
            validationErrorCode = INVALID_URI_404;
            isURIValid = false;
        } 
       return isURIValid ;
    }
    
    
    //Validate whether case number exists or not
    @testVisible
    private Boolean validateCaseNumber(){
        List<Case> caseList = new List<Case>();
        Boolean isValid = true;
        //FLS check added-Venugopal
        if(Case.SObjectType.getDescribe().isAccessible()){
        caseList = [Select Id,Core_IPS_Customer_Visible__c,Core_IPS_Comment__c,Core_IPS_Project_Case__c,Core_Sub_Status__c,Status,RecordType.Name FROM CASE Where CaseNumber =: CASE_NUMBER Limit 1]; 
        }
        if(!caseList.isEmpty()){
            caseObj = caseList[0];
        }
         if(caseObj == null ){
            isValid = false;
            validationErrorCode = INVALID_INPUT;
            validationErrorMessage = ' Case Number';
         }
         
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
    private Boolean validateCommentRequiredFields(){
        Boolean flag = true;
        if (String.isBlank(caseCommentWrapper.comment) ){
            validationErrorCode = REQ_FIELD_MISSING_9002 ;  
            validationErrorMessage = ' Comment';
            flag = false;
        }
        return flag;
    }
    
    //Validate casetype and caseStatus of Case 
    @testVisible 
    private Boolean validateCaseTypeStatus(){
        
        Boolean flag = true;
        if((caseObj  != null) && (caseObj.RecordType.Name == 'IPS Closed Case' || caseObj.RecordType.Name == 'IPS GEC ReadOnly')){
            flag= false;
            validationErrorCode = UNAUTHORIZED_CASE_RECORDTYPE_9004 ;
            validationErrorMessage = ' Create Comment for Closed and GEC Cases';
        }
        return flag ;
    }
    
    //Validate the case number format
    @testVisible 
    private boolean validateNumbericCaseNumber(){
    
        Boolean isRequestValid = true;
        
        if((!CASE_NUMBER.isNumeric() || CASE_NUMBER.length() != 8 )){
           
            isRequestValid = false;
            validationErrorCode = INVALID_INPUT;
            validationErrorMessage = ' Case Number';
        }  
        return isRequestValid;
    }
    
    //Validate the length of case comment field should not be more than 92768
    @testVisible 
    private boolean validateLengthCaseComment(){
    
        Boolean isValidLength = true;
        if (caseCommentWrapper.comment != null && Core_RestAPI_Util.isMaxLengthExceeded(caseCommentWrapper.comment, 92768)){
            isValidLength= false;
            validationErrorCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ' 92768';  
        }
        return isValidLength ;
    }
    
    //All the validation of Case comment
    @testVisible 
    private boolean doAllCaseCommentValidation(){
           
        Boolean isAllValid =  validateURI() && validateNumbericCaseNumber()  && validateCommentRequiredFields() && validateLengthCaseComment() && validateCaseNumber() && validateCaseTypeStatus() && validateCaseVisibility();
        return isAllValid ;
    }
    
    //Wrapper class for the success response
    public class CaseCommentWrapper implements Core_RestAPI_SuccessContent{
        String caseCommentId{get;set;}
    }
    
    //Identifies and Maps the logged in User with Author Type
    public static String getAuthr(String loggedUserId){
        
        String authroTyp = null;
        
        if(Label.Core_IPS_External_Customer_Profile_Ids.contains(loggedUserId.substring(0,15)) && (Core_IPS_Labels__c.getValues('Customer') != null)&& (!String.isBlank(Core_IPS_Labels__c.getValues('Customer').value__c))){
            authroTyp=Core_IPS_Labels__c.getValues('Customer').value__c; 
        }
        else if(Label.Core_IPS_SalesRep_ProfileIds.contains(loggedUserId.substring(0,15)) && (Core_IPS_Labels__c.getValues('FAE') != null) && (!String.isBlank(Core_IPS_Labels__c.getValues('FAE').value__c))){
            authroTyp=Core_IPS_Labels__c.getValues('FAE').value__c; 
        }
        else if(Label.Core_IPS_Agent_Profiles.contains(loggedUserId.substring(0,15)) && (Core_IPS_Labels__c.getValues('Agent') != null) && (!String.isBlank(Core_IPS_Labels__c.getValues('Agent').value__c))){
            authroTyp=Core_IPS_Labels__c.getValues('Agent').value__c;
        }
        
        else if((Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(userInfo.getUserId()) == true) && (Core_IPS_Labels__c.getValues('Data Migration') != null) && (!String.isBlank(Core_IPS_Labels__c.getValues('Data Migration').value__c))){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
            authroTyp=Core_IPS_Labels__c.getValues('Data Migration').value__c;
        }
        else if(Label.Core_Integration_Profile_Id.contains(loggedUserId.substring(0,15))&& (Core_IPS_Labels__c.getValues('Backend Integration') != null) && (!String.isBlank(Core_IPS_Labels__c.getValues('Backend Integration').value__c))){
            authroTyp=Core_IPS_Labels__c.getValues('Backend Integration').value__c;
        }
         else if(Label.Core_IPS_Agent_Partner_Profile_id.contains(loggedUserId.substring(0,15))&& (Core_IPS_Labels__c.getValues('Partner - Agent') != null)&& (!String.isBlank(Core_IPS_Labels__c.getValues('Partner - Agent').value__c))){
            authroTyp=Core_IPS_Labels__c.getValues('Partner - Agent').value__c;
        }
         else if(Label.Core_Partner_Profile_Id.contains(loggedUserId.substring(0,15))&& (Core_IPS_Labels__c.getValues('Partner') != null)&& (!String.isBlank(Core_IPS_Labels__c.getValues('Partner').value__c))){
            authroTyp=Core_IPS_Labels__c.getValues('Partner').value__c;
        }     
        return authroTyp; 
    }
}