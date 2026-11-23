/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CC_CreateV2_Handler
* Version     : 1.0 
* Created Date: 19 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/19/2018              Creates Case Comments
*****************************************************************************************************************************************/
public class Core_RestAPI_CC_CreateV2_Handler{
    
    private static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    private static final String  REQ_FIELD_MISSING_9002 = '9002';
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
    @testVisible private Case caseObj =  null;
    private User userObj = null;
    private DateTime entryTime = null;
    private String apiName = null;
    private String Contact_Id = null;
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    private Core_RestAPI_CC_CreateV1_Wrapper CaseCommentWrapper = null;
    private String CaseCommentV1_URI ='/v1.0/cases/*/comments';
    private String INVALID_URI_404= '404';
    
    
    //Default Constructor
    public Core_RestAPI_CC_CreateV2_Handler(DateTime currTime, String APIname,Core_RestAPI_CC_CreateV1_Wrapper ccWrpr){
        
        System.debug('Inside Core_RestAPI_CC_CreateV1_Handler Constructor');
        this.runningUser = [Select ContactId, AccountId FROM User where Id =: UserInfo.getUserId()];
        this.entryTime = currTime;
        this.apiName = APIname;
        this.CaseCommentWrapper = ccWrpr;
        if(ccWrpr.contactId == ''){
            this.Contact_Id = null;
        }else{
            this.Contact_Id = ccWrpr.contactId;
        }    
        System.debug(' Initialization completed CASE_NUMBER '+CASE_NUMBER);
        
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
                response.code = '201';
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }     
        
        return response;
    }
    public void insertCaseComment(){
        
        System.debug('Inside insertCaseComment method');
        System.debug('runningUser.AccountId ===>> '+runningUser.AccountId);
        List<Core_IPS_Case_Comments__c> lstCaseComments = new List<Core_IPS_Case_Comments__c>();
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();  
        if(caseObj != null){
            newComment.Core_IPS_Case__c = caseObj.Id;
            newComment.Core_IPS_Rich_Comment__c = caseCommentWrapper.comment;
            if(Contact_Id != null && userObj.Id != null){
                newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userObj.ProfileId);
            }else {
                newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId());
            }
            if((Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS') != null) && (!String.isBlank(Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c))){
                newComment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            }
            if((Core_IPS_Labels__c.getValues('Comment Source - B2B API') != null) && (!String.isBlank(Core_IPS_Labels__c.getValues('Comment Source - B2B API').value__c))){
                newComment.Core_IPS_Case_Comment_Source__c = Core_IPS_Labels__c.getValues('Comment Source - B2B API').value__c;
            }
            if(userObj != null){
                newComment.Core_IPS_Comment_Authored_By__c= userObj.Id;
            }
            lstCaseComments.add(newComment);
            insert lstCaseComments;
            system.debug('execution for CaseCommentWrapper++====>>  ');
            CaseCommentWrapper  csComment = new CaseCommentWrapper ();
            csComment.caseCommentId= [SELECT Id, Name FROM Core_IPS_Case_Comments__c where id =:newComment.Id].Name;
            List<CaseCommentWrapper > lstCaseComm = new List<CaseCommentWrapper >();
            lstCaseComm.add(csComment);
            response.successContent = lstCaseComm;
        } 
        
    }
    
    //Validate the Contact passed by the customer
    @testVisible
    private Boolean validateContact(){
        
        System.debug('Inside validating the contact record');
        Boolean isValidContact = true;
        Set<String> profileIds;
        if(Contact_Id != null){
            if(String.isNotBlank(LABEL.Core_RestAPI_CC_ProfileIds)){
                profileIds= new Set<String>((LABEL.Core_RestAPI_CC_ProfileIds).split(','));
            }  
            lstUser= [SELECT Id,isActive,ContactId,Contact.Core_IPS_Active__c,AccountId,ProfileId FROM User WHERE ContactId =: Contact_Id  LIMIT 1];
            if(!lstUser.isEmpty()){
                userObj = lstUser[0];
            }
            system.debug('Contact_Id.length() ====>> '+Contact_Id.length());
            if((userObj == null) || Contact_Id.length() != 18 || userObj.AccountId != runningUser.AccountId){
                isValidContact = false;
                validationErrorCode = INVALID_CONTACT;  
            }
            else if(userObj.isActive == false || userObj.Contact.Core_IPS_Active__c == false){
                isValidContact = false;
                validationErrorCode = INACTIVE_CONTACT; 
            }else if((profileIds.contains(String.valueOf(userObj.ProfileId).left(15))) == false){
                isValidContact = false;
                validationErrorCode = INVALID_PROFILE ; 
            }
        }   
        System.debug('validate Contact isValid :'+isValidContact);
        return isValidContact ;
        
    }
    
    //Validate Contact/User should be active member of the project.
    @testVisible
    private Boolean validateProjectMember(){
        
        Boolean  isValidProjectMember = true;
        if(Contact_Id != null){
            if(caseObj.Core_IPS_Project_Case__c != null){
                List<Core_IPS_Project_Member__c> objProjMem = [SELECT Id, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__c =: caseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' AND Core_IPS_Contact__c =: Contact_Id ];
                System.debug('objProjMem -->'+objProjMem);
                if(objProjMem == null || objProjMem.isEmpty()){
                    isValidProjectMember = false;
                    validationErrorCode = INACTIVE_PROJECTMEMBER ; 
                }
            } 
        }   
        System.debug('validate User Project Member :'+isValidProjectMember);
        return isValidProjectMember;
    }
    
    //Validate Case Visibility over the Contact user
    @testVisible
    private boolean validateContactCaseVisbility(){
        Boolean isVisbileContactCase = true;
        if(Contact_Id != null && userObj.Id != null ){
            UserRecordAccess objRecordAccess = [SELECT RecordId, HasReadAccess,HasEditAccess FROM UserRecordAccess WHERE UserId =:userObj.Id AND RecordId =: caseObj.Id];
            System.debug('objRecordAccess----->'+objRecordAccess);
            if(objRecordAccess.HasReadAccess == false || objRecordAccess.HasEditAccess == false){
                isVisbileContactCase = false;
                validationErrorCode = INVALID_PROFILE ; 
            }
            System.debug('validate User Visbility over Case :'+ isVisbileContactCase);
        }    
        return isVisbileContactCase;
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
        
        System.debug('Inside validateCaseNumber method');
        Boolean isValid = true;
        List<Case> caseList = [Select Id,Core_IPS_Customer_Visible__c,Core_IPS_Comment__c,Core_IPS_Project_Case__c,Core_Sub_Status__c,Status,RecordType.Name FROM CASE Where CaseNumber =: CASE_NUMBER Limit 1]; 
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
        Boolean isAllValid =  validateURI() && validateNumbericCaseNumber()  && validateCommentRequiredFields()  && validateLengthCaseComment() && validateCaseNumber() && validateCaseTypeStatus() && validateCaseVisibility() && validateContact() && validateProjectMember() && validateContactCaseVisbility();
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