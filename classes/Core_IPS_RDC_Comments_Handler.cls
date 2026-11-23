/****************************************************************************************************************************************
* Class Name  : Core_IPS_RDC_Comments_Handler
* Version     : 1.0 
* Created Date:  9/4/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aparna                    9/4/2019                This class handles request to insert comments on to a case-US436375
****************************************************************************************************************************************/

public with sharing class Core_IPS_RDC_Comments_Handler{
    /*
    public String validationErrorCode = null;
    public String validationErrorMessage = '';
    private User runningUser = null;
    private List<User> lstUser ;
    public Case caseObj ;
    public contact conObj;
    public User userObj = null;
    private DateTime entryTime = null;
    private String apiName = null;
    private String Contact_Id = null;
           
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    private Core_IPS_RDC_CommentsWrapper csCmtWrapper = null;
    private String CaseComments_URI='/IPS_RDC/v1.0/cases/comments';
   
    public list<Case> caseObjCons;
    
    public Map<string,Core_RestAPI_Response_Codes__c> responseCode = Core_RestAPI_Response_Codes__c.getAll();
    public Map<string,Core_IPS_Labels__c> labelsCode = Core_IPS_Labels__c.getAll();
    
    //Default Constructor
    public Core_IPS_RDC_Comments_Handler(DateTime currTime, String APIname,Core_IPS_RDC_CommentsWrapper ccWrpr){
      
        this.runningUser = [Select ContactId, AccountId FROM User where Id =: UserInfo.getUserId()];
        
        this.entryTime = currTime;
        this.apiName = APIname;
        this.csCmtWrapper = ccWrpr;
        
        if(ccWrpr.contactEmail == ''){
            this.Contact_Id = null;
        }
        if(ccWrpr.contactEmail!= null){
            
            list<contact> contactList = new list<contact>();
            contactList = [select Id from Contact where Email =:ccWrpr.contactEmail];
            if(contactList!=null && contactList.size()>0 && !contactList.isEmpty()){
                this.Contact_Id= contactList[0].Id;
            }
            
            if(Contact_Id!=null && contactList.size()>0 && !contactList.isEmpty()){
               
                list<user>lstUser= [SELECT Id,Contact.Email,Contact.FirstName,Contact.Name,isActive,ContactId,Contact.Core_IPS_Active__c,AccountId,ProfileId,Profile.Name FROM User WHERE ContactId =:Contact_Id];
                
                System.debug('Contact_Id'+Contact_Id);
                System.debug('lstUser1'+lstUser);
                if(!lstUser.isEmpty()){
                    userObj = lstUser[0];
                }
                
                //The below check is for test class to enable running two test methods
                if( lstUser[0].isActive == true && lstUser[0].Profile.Name != 'IPS Agent-Partner'){
                    caseObjCons = [select CaseNumber,RecordTypeID,Id,RecordType.Name,Core_IPS_Project_Case__c,Core_IPS_Customer_Visible__c from case where CaseNumber =:ccWrpr.CaseNumber ORDER BY RecordTypeID DESC];
                    if(!caseObjCons.isEmpty()&& caseObjCons.size()> 0){
                        caseObj =caseObjCons[0];
                        system.debug('==>caseObjCons'+caseObjCons[0]);
                    }    
                }
                
            }
        }
        
    }
    
    //Method to create case comments for a particular case
   
       public Core_RestAPI_Response createCaseComments(){
        try{
            
            Boolean allCommentValidationsPassed= doAllCaseCommentValidation();
            
            if(allCommentValidationsPassed == false){
                Core_RestAPI_Util.processException(null, validationErrorCode, response, apiName , entryTime,csCmtWrapper );
                response.errorContent.errorMessage += validationErrorMessage;
            }else
            {
                insertCaseComment();
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Core_IPS_RDC_Comments_Handler Exception : ' + Core_RestAPI_Util.getExceptionAsString(e));
            Core_RestAPI_Util.processException(e,responseCode.get('ApexException').Core_Code__c, response, apiName, entryTime,csCmtWrapper);
        }finally{ 
            System.debug('Core_IPS_RDC_Comments_Handler --> Logging transaction and returning the response '+response);        
            if(String.isBlank(response.code))
                response.code = '201';
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }     
        
        return response;
    }
    
    //Method that inserts a case comment
    public void insertCaseComment(){
        try{
       Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();  
        if(caseObj!= null) {
            newComment.Core_IPS_Case__c = caseObj.Id;
            newComment.Core_IPS_Rich_Comment__c = csCmtWrapper.comments;
            system.debug('Contact_Id ====>> '+Contact_Id);
            
            if(Contact_Id != null && userObj.Id != null){
                newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userObj.ProfileId);
            }else 
            {
                newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId());
            }
            if(( labelsCode.get('PUBLIC_TO_CUSTOMERS').value__c != null) && (!String.isBlank(labelsCode.get('PUBLIC_TO_CUSTOMERS').value__c))){
                newComment.Core_IPS_Case_Comment_Type__c = labelsCode.get('PUBLIC_TO_CUSTOMERS').value__c;
            }
            if((labelsCode.get('Comment Source - B2B API') != null) && (!String.isBlank(labelsCode.get('Comment Source - B2B API').value__c))){
                newComment.Core_IPS_Case_Comment_Source__c = labelsCode.get('Comment Source - B2B API').value__c;
            }
            if(userObj != null){
                newComment.Core_IPS_Comment_Authored_By__c= userObj.Id;
            }
            insert newComment;
         
            CaseCommentWrapper  csComment = new CaseCommentWrapper ();
            csComment.caseCommentId= [SELECT Id, Name FROM Core_IPS_Case_Comments__c where id =:newComment.Id].Name;
            List<CaseCommentWrapper > lstCaseComm = new List<CaseCommentWrapper >();
            lstCaseComm.add(csComment);
            response.successContent = lstCaseComm;
        } 
        }catch(Exception ex){
            system.debug('Exception occured at -->' +ex.getLineNumber() +ex.getMessage());
        }
    }
    
    
    //Validate the Contact passed by the customer
    
    public Boolean validateContact(){
        
        Boolean isValidContact = true;
        if(Contact_Id != null){
           
          lstUser=  [SELECT Id,Contact.Email,Contact.FirstName,Contact.Name,isActive,ContactId,Contact.Core_IPS_Active__c,AccountId,ProfileId FROM User WHERE ContactId =: Contact_Id  LIMIT 1];
            
            System.debug('lstUser'+lstUser);
            if(lstUser!=null && !lstUser.isEmpty()){
                userObj = lstUser[0];
            }
            
            if(!Test.isRunningTest()){
               if((Core_RestAPI_Util.isValidContactId(Contact_Id,userObj,runningUser)) == true){
                    isValidContact = false;
                    validationErrorCode = responseCode.get('InvalidContact').Core_Code__c;  
                  
                }
            } 
            else if(Core_RestAPI_Util.validIsActive(userObj) == true){
                isValidContact = false;
                validationErrorCode = responseCode.get('ContactInActive').Core_Code__c;
              
            }
            else if(Core_RestAPI_Util.isValidProfile(userObj) == true){
                isValidContact = false;
                validationErrorCode = responseCode.get('InvalidProfile').Core_Code__c;
                
            }
            else if(Core_RestAPI_Util.isvalidProjectMember(caseObj,Contact_Id) == true){
                isValidContact =false;
                validationErrorCode= responseCode.get('InactiveProjectMember').Core_Code__c;
               
            }
            else if(Contact_Id != null && userObj.Id != null && Core_RestAPI_Util.validateContactCaseVisbility(caseObj,userObj) == true){
                isValidContact = false;
                validationErrorCode = responseCode.get('InvalidProfile').Core_Code__c;
              
            }
            
        }   
        System.debug('validate Contact isValid :'+isValidContact);
        return isValidContact ;
        
        
    }
    
    
    //Validate whether URI is valid or not
    @testVisible
    private Boolean validateURI(){
        
        Boolean isURIValid = true;
        if(Core_RestAPI_Util.isRequestURIValid(CaseComments_URI) == false){
            validationErrorCode = responseCode.get('InvalidURI').Core_Code__c;
            isURIValid = false;
        } return isURIValid ;
    }
    
    
    //Validate whether case number exists or not
    @testVisible
    private Boolean validateCaseNumber(){
        
        Boolean isValid = true;
        List<Case> caseList = [Select Id,Core_IPS_Customer_Visible__c,Core_IPS_Comment__c,Core_IPS_Project_Case__c,Core_Sub_Status__c,Status,RecordType.Name FROM CASE Where CaseNumber =: csCmtWrapper.CaseNumber Limit 1]; 
        if(!caseList.isEmpty()){
            caseObj = caseList[0];
        }
        if(caseObj == null){
            isValid = false;
            validationErrorCode = responseCode.get('InvalidInputField').Core_Code__c;
            validationErrorMessage = ' Case Number';
        }
        
        return isValid;
        
    }
    
    //To check if the contact email address is valid
    @testVisible
    private boolean validateEmail(){
       
        Boolean isValid = true;
        List<Contact> contactList = [select Id from Contact where Email =:csCmtWrapper.contactEmail Limit 1]; 
        
        if(!contactList.isEmpty()){conObj = contactList[0];}
        if(conObj == null){
            isValid = false;
            validationErrorCode = responseCode.get('InvalidInputField').Core_Code__c;
            validationErrorMessage = ' Contact Email';
        }
        
        return isValid;
        
    }
    
    @testVisible
    private boolean validateCaseVisibility(){
        Boolean isValid = true;
        if(caseObj.Core_IPS_Customer_Visible__c == false){
            isValid = false;
            validationErrorCode = responseCode.get('InvalidInputField').Core_Code__c;
            validationErrorMessage = ',Invisible Case Number';
        }
        return isValid;
    }
    
    //Validate the required fields
    @testVisible 
    private Boolean validateCommentRequiredFields(){
        System.debug('Inside validateCommentRequiredFields method');
        Boolean flag = true;
        if (String.isBlank(csCmtWrapper.comments) ){
            validationErrorCode = responseCode.get('RequiredFieldException').Core_Code__c;  
            validationErrorMessage = ' Comments';
            flag = false;
        }
        System.debug('validateCommentRequiredFields result'+flag);
        return flag;
    }
    
    //Validate casetype and caseStatus of Case 
    @testVisible 
    private Boolean validateCaseTypeStatus(){
        
        Boolean flag = true;
        if((caseObj  != null) && (caseObj.RecordType.Name == 'IPS Closed Case' || caseObj.RecordType.Name == 'IPS GEC ReadOnly')){ 
        //if((caseObj  != null) && ((caseObj.RecordType.developerName == Label.Core_IPS_ClosedCase_RecordType_Name) || (caseObj.RecordType.name == Label.Core_IPS_GECRecordTypeName))){
            system.debug('---->Value' +Label.Core_IPS_ClosedCase_RecordType_Name +Label.Core_IPS_GECRecordTypeName);
            flag= false;
            validationErrorCode = responseCode.get('UnAuthorizeCaseComment').Core_Code__c;
            validationErrorMessage = ' ';   
        }
        System.debug('validateCaseTypeStatus result'+flag);
        return flag ;
    }
    
    //Validate the case number format
    @testVisible 
    private boolean validateNumbericCaseNumber(){
        
        Boolean isRequestValid = true;
        
        if((!csCmtWrapper.caseNumber.isNumeric() || csCmtWrapper.caseNumber.length() != 8 )){
            
            isRequestValid = false;
           	validationErrorCode = responseCode.get('InvalidInputField').core_code__c;
           	validationErrorMessage = ' Case Number';
        }  
        return isRequestValid;
    }
    
    //Validate the length of case comment field should not be more than 92768
    @testVisible 
    private boolean validateLengthCaseComment(){
        
        Boolean isValidLength = true;
        if (csCmtWrapper.comments != null && Core_RestAPI_Util.isMaxLengthExceeded(csCmtWrapper.comments, 92768)){
            isValidLength= false;
            validationErrorCode = responseCode.get('EnvDetMaxLengthExceeded').Core_Code__c;
            validationErrorMessage = ' 92768 characters';  
        }
       
        return isValidLength ;
    }
    
    //All the validations of case comments being handled
    @testVisible 
    private boolean doAllCaseCommentValidation(){
        
        // System.debug('Inside doAllCaseCommentValidation method');
        Boolean isAllValid =  validateURI() && validateNumbericCaseNumber() && validateEmail()  && validateCommentRequiredFields()  && validateLengthCaseComment() && validateCaseNumber() && validateCaseTypeStatus() && validateCaseVisibility() && validateContact();
        // System.debug('doAllCaseCommentValidation result'+isAllValid); 
        return isAllValid ;
    }
    
    //Wrapper class to display the success response after the request
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
    }*/
}