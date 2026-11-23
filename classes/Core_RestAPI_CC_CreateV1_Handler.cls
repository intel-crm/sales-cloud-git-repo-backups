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
        
        System.debug('Inside Core_RestAPI_CC_CreateV1_Handler Constructor');
        this.entryTime = currTime;
        this.apiName = APIname;
        this.CaseCommentWrapper = ccWrpr;
        System.debug(' Initialization completed CASE_NUMBER '+CASE_NUMBER);
        System.debug('ccWrpr-->'+ccWrpr);
        
    }
    
    //Method to create case comment for particular case
    public Core_RestAPI_Response createCaseComments(){
        try{
            System.debug('Inside createCaseComments method');
            Boolean allCommentValidationsPassed= doAllCaseCommentValidation();
            System.debug('allCommentValidationsPassed==>> '+allCommentValidationsPassed);
            if(allCommentValidationsPassed == false){
                Core_RestAPI_Util.processException(null, validationErrorCode, response, apiName , entryTime,CaseCommentWrapper );
                response.errorContent.errorMessage += validationErrorMessage;
            }else{
                insertCaseComment();
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Core_RestAPI_CC_CreateV1_Handler Exception : ' + Core_RestAPI_Util.getExceptionAsString(e));
            Core_RestAPI_Util.processException(e,ERROR_CODE_500, response, apiName, entryTime,CaseCommentWrapper);
        }finally{ 
            System.debug('Core_RestAPI_CC_CreateV1_Handler Logging transaction and returning the response '+response);        
            if(String.isBlank(response.code))
                response.code = SUCCESS_CODE_200;
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }     
        
        return response;
    }
    public void insertCaseComment(){
    
        System.debug('Inside insertCaseComment method');
        List<Core_IPS_Case_Comments__c> lstCaseComments = new List<Core_IPS_Case_Comments__c>();
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        if(caseObj != null){
            if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case__c.isCreateable()) { //Fls create fix -Gangadhar
          newComment.Core_IPS_Case__c = caseObj.Id;
            }
            String escapeString = caseCommentWrapper.comment;
            newComment.Core_IPS_Case_Comment_Type__c = 'Public to Customers';
newComment.Core_IPS_Rich_Comment__c = escapeString.escapeHtml4().replace('\n', '<br/>');
            newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId());
            lstCaseComments.add(newComment);
            insert lstCaseComments;
            
            CaseCommentWrapper  csComment = new CaseCommentWrapper ();
            //FLS check added-Venugopal
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
            csComment.caseCommentId= [SELECT Id, Name FROM Core_IPS_Case_Comments__c where id =:newComment.Id].Name;
            }
            //FLS check added-Venugopal
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
            System.debug('query test=>'+[SELECT Id, Name,Core_IPS_Rich_Comment__c FROM Core_IPS_Case_Comments__c where id =:newComment.Id].Core_IPS_Rich_Comment__c);
            }
            List<CaseCommentWrapper > lstCaseComm = new List<CaseCommentWrapper >();
            lstCaseComm.add(csComment);
            response.successContent = lstCaseComm;
        } 
        
    }
   //Validate whether URI is valid or not
    @testVisible
    private Boolean validateURI(){
        System.debug('Inside validateURI method');
        Boolean isURIValid = true;
        if(Core_RestAPI_Util.isRequestURIValid(CaseCommentV1_URI) == false){
            validationErrorCode = INVALID_URI_404;
            isURIValid = false;
        } 
       System.debug('validateURI isValid :'+isURIValid);
       return isURIValid ;
    }
    
    
    //Validate whether case number exists or not
    @testVisible
    private Boolean validateCaseNumber(){
        List<Case> caseList = new List<Case>();
        System.debug('Inside validateCaseNumber method');
        Boolean isValid = true;
        //FLS check added-Venugopal
        if(Case.SObjectType.getDescribe().isAccessible()){
        caseList = [Select Id,Core_IPS_Customer_Visible__c,Core_IPS_Comment__c,Core_IPS_Project_Case__c,Core_Sub_Status__c,Status,RecordType.Name FROM CASE Where CaseNumber =: CASE_NUMBER Limit 1]; 
        }
        System.debug('caseList -->'+caseList );
        if(!caseList.isEmpty()){
            caseObj = caseList[0];
        }
         if(caseObj == null ){
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
    private Boolean validateCommentRequiredFields(){
        System.debug('Inside validateCommentRequiredFields method');
        Boolean flag = true;
        if (String.isBlank(caseCommentWrapper.comment) ){
            validationErrorCode = REQ_FIELD_MISSING_9002 ;  
            validationErrorMessage = ' Comment';
            flag = false;
        }
        System.debug('validateCommentRequiredFields result'+flag);
        return flag;
    }
    
    //Validate casetype and caseStatus of Case 
    @testVisible 
    private Boolean validateCaseTypeStatus(){
        
        System.debug('Inside validateCaseTypeStatus method');
        Boolean flag = true;
        if((caseObj  != null) && (caseObj.RecordType.Name == 'IPS Closed Case' || caseObj.RecordType.Name == 'IPS GEC ReadOnly')){
            flag= false;
            validationErrorCode = UNAUTHORIZED_CASE_RECORDTYPE_9004 ;
            validationErrorMessage = ' Create Comment for Closed and GEC Cases';
        }
        System.debug('validateCaseTypeStatus result'+flag);
        return flag ;
    }
    
    //Validate the case number format
    @testVisible 
    private boolean validateNumbericCaseNumber(){
    
        System.debug('Inside validateNumbericCaseNumber method');
        Boolean isRequestValid = true;
        
        if((!CASE_NUMBER.isNumeric() || CASE_NUMBER.length() != 8 )){
           
            isRequestValid = false;
            validationErrorCode = INVALID_INPUT;
            validationErrorMessage = ' Case Number';
        }  
        System.debug('validateNumbericCaseNumber result'+isRequestValid);  
        return isRequestValid;
    }
    
    //Validate the length of case comment field should not be more than 92768
    @testVisible 
    private boolean validateLengthCaseComment(){
    
        System.debug('Inside validateLengthCaseComment method');
        Boolean isValidLength = true;
        if (caseCommentWrapper.comment != null && Core_RestAPI_Util.isMaxLengthExceeded(caseCommentWrapper.comment, 92768)){
            isValidLength= false;
            validationErrorCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ' 92768';  
        }
        System.debug('validateLengthCaseComment result'+isValidLength); 
        return isValidLength ;
    }
    
    //All the validation of Case comment
    @testVisible 
    private boolean doAllCaseCommentValidation(){
           
        System.debug('Inside doAllCaseCommentValidation method');
        Boolean isAllValid =  validateURI() && validateNumbericCaseNumber()  && validateCommentRequiredFields() && validateLengthCaseComment() && validateCaseNumber() && validateCaseTypeStatus() && validateCaseVisibility();
        System.debug('doAllCaseCommentValidation result'+isAllValid); 
        return isAllValid ;
    }
    
    //Wrapper class for the success response
    public class CaseCommentWrapper implements Core_RestAPI_SuccessContent{
        String caseCommentId{get;set;}
    }
    
    //Identifies and Maps the logged in User with Author Type
    public static String getAuthr(String loggedUserId){
        
        System.debug('Inside getAuthr method');
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
        else if(Label.Core_IPS_Data_Migration_ProfileId.contains(loggedUserId.substring(0,15)) && (Core_IPS_Labels__c.getValues('Data Migration') != null) && (!String.isBlank(Core_IPS_Labels__c.getValues('Data Migration').value__c))){
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
        System.debug('getAuthr result'+authroTyp);
        return authroTyp; 
    }
}