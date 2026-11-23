/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_UpdateCasesHandler
* Version     : 1.0 
* Created Date: 3/6/2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         3/6/2018                RestAPI handler for validating the request and updating case
*****************************************************************************************************************************************/
public class Core_RestAPI_Case_UpdateV1_Handler_BAKUP {
    private final String REQ_FIELD_MISSING_9002 = '9002';
    private final String MAX_LENGTH_EXCEEDED_9025 = '9025';
    private final String INVALID_INPUT = '9011';
    private final String INVALID_INPUT_ANSWER = '9012';
    private final String INACTIVE_PRODUCT = '9015';
    private final String UN_AUTHORIZED = '9004';
    private final String INACTIVE_PROJECT ='9016';
    private final String DUPLICATE_INPUTS = '9017';
    private final String ERR_CODE_9020 = '9020';
    private final String ERROR_CODE_500 = '500';
    private final String SUCCESS_CODE_201 = '201';
    private final String BAD_REQUEST_400 = '400';
    
    
    @testVisible private Core_RestAPI_Case_UpdateV1_Wrapper requestWrpr = null;
    private Core_RestAPI_Response response = new Core_RestAPI_Response();
    private String validationErrorMessage = null;
    private String validationCode = null;
    private User runningUser = null;
    private Id catId = null;
    private Id subCatId = null;
    @testVisible private Asset assetObj = null;
    @testVisible private Case existingCaseObj = null;
    private DateTime entryTime = null;
    private String apiName = null;
    
    public static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    public static String CONTACT_ID = null;

    private List<Core_IPS_Assigned_Environment_Variables__c> lstSuppProdEnvDetails = null;
    private List<Core_IPS_Assigned_Environment_Variables__c> lstSubCatEnvDetails = null;
    
    
    //Map<Question, Object> for all the REQUIRED**** environment details questions for the PRODUCT
    Map<String, Core_IPS_Assigned_Environment_Variables__c> mSuppProdEnvDetailsRequired = new Map<String, Core_IPS_Assigned_Environment_Variables__c>();
    //Map<Question, Object> for all the REQUIRED**** environment details questions for the SUB-CATEGORY
    Map<String, Core_IPS_Assigned_Environment_Variables__c> mSubCatEnvDetailsRequired = new Map<String, Core_IPS_Assigned_Environment_Variables__c>();
    
    //Map<Question, Object> for all environment details questions for the PRODUCT
    Map<String, Core_IPS_Assigned_Environment_Variables__c> mSuppProdEnvDetailsAll = new Map<String, Core_IPS_Assigned_Environment_Variables__c>();
    
    //Map<Question, Object> for all the environment details questions for the SUB-CATEGORY
    Map<String, Core_IPS_Assigned_Environment_Variables__c> mSubCatEnvDetailsAll = new Map<String, Core_IPS_Assigned_Environment_Variables__c>();
    
    //Map<Question, Object> for all the environment details which are passed in api request
    Map<String, Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> mRequestQuestionEnvDetail = new Map<String, Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
    
    public Core_RestAPI_Case_UpdateV1_Handler_BAKUP(String apiname, DateTime entryTime, Core_RestAPI_Case_UpdateV1_Wrapper argWrpr){
        this.runningUser = [Select ContactId, AccountId FROM User where Id =: UserInfo.getUserId()];
        this.requestWrpr = argWrpr;
        this.apiName = apiname;
        this.entryTime = entryTime;        
    }
    
    
    //UPDATE OR CLOSE case based on the request json
    public Core_RestAPI_Response updateCase(){
        System.debug('Core_RestAPI_Case_UpdateV1_Handler  started processing request for Update/Close Case  ');
        Savepoint sp = Database.setSavepoint();
        try{
            
            //IF CONDITION runs for CLOSE case 
            if(String.isNotBlank(requestWrpr.status) && 'Closed'.equalsIgnoreCase(requestWrpr.status)){
                Boolean allCloseCaseValidationsPassed = doAllCloseCaseValidations();
                System.debug('CLOSE CASE: allCloseCaseValidationsPassed  ? >>> '+allCloseCaseValidationsPassed+' Validation code : '+validationCode + ' validationErrorMessage :'+validationErrorMessage);
                if(allCloseCaseValidationsPassed  == true){
                    closeCase();    
                }else{
                    Core_RestAPI_Util.processException(null , validationCode, response, apiName, entryTime, requestWrpr);
                    response.errorContent.errorMessage += validationErrorMessage;
                }
            }// ELSE CONDITION for update case
            else {
                Boolean allUpdateCaseValidationsPassed = (  doAllUpdateCaseValidations() && doAllEnvDetailValidations() );
                System.debug('UPDATE CASE : allUpdateCaseValidationsPassed passed ? >>> '+allUpdateCaseValidationsPassed+' Validation code : '+validationCode + ' validationErrorMessage :'+validationErrorMessage);
                if(allUpdateCaseValidationsPassed == false ){
                    Core_RestAPI_Util.processException(null , validationCode, response, apiName, entryTime, requestWrpr);
                    response.errorContent.errorMessage += validationErrorMessage;
                }else{    
                    updateCaseDetails();
                    updateEnvironmentDetails();   
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Core_RestAPI_Case_UpdateV1_Handler Exception : ' + Core_RestAPI_Util.getExceptionAsString(e));
            Database.rollback(sp);        
            response.successContent = null;
            Core_RestAPI_Util.processException(e, ERROR_CODE_500, response, apiName, entryTime, requestWrpr);
        }finally{        
            if(String.isBlank(response.code)){
                response.code = SUCCESS_CODE_201;
                CaseWrapper cw = new CaseWrapper();
                cw.message = existingCaseObj.CaseNumber +' udpated successfully ';
                List<CaseWrapper> cwl = new List<CaseWrapper>();
                cwl.add(cw);
                response.successContent = cwl;
            }
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        } 
        System.debug('Core_RestAPI_Case_UpdateV1_Handler updateCase processing request completed - final response :'+response);
        return response;
    }
    
    /******************************************** Close case *****************************************************/
    public void closeCase(){
        existingCaseObj.Status = 'Closed';
        existingCaseObj.Core_Sub_Status__c = 'Closed';
        existingCaseObj.Core_IPS_Partner_status_ReadOnly__c = true;
        existingCaseObj.RecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType  ='Case' AND DeveloperName = 'IPS_Closed_Case'].Id;
        update existingCaseObj;
    }
    
    /******************************************** Update Cases*****************************************************/
    public void updateCaseDetails(){
        System.debug(' Updating the case record started ');
        existingCaseObj.Subject = requestWrpr.subject ;
        existingCaseObj.Core_Issue_Description__c = requestWrpr.caseDescription;
        existingCaseObj.Description = requestWrpr.caseDescription;
        existingCaseObj.Core_CaseType__c = requestWrpr.caseType;
        existingCaseObj.Core_Severity__c = requestWrpr.caseSeverity ;
        existingCaseObj.Core_Severity_Reason__c = requestWrpr.SeverityReason;
        existingCaseObj.Core_Customer_Reference_ID__c= requestWrpr.customerReferenceId ;
        existingCaseObj.Core_End_Customer__c = requestWrpr.endCustomer;
        existingCaseObj.ContactId = CONTACT_ID;
        
        //category and subcategory
        existingCaseObj.Core_Case_Issue_Category__c = this.catId;
        existingCaseObj.Core_Case_Issue_Sub_Category__c = this.subCatId;
        
        update existingCaseObj;
        System.debug(' Updating the case record completed ');
    }
    
    /******************************************** Update EnvironmentDetails STARTS ****************************************************/
    
    //update Environment Details 
    public void updateEnvironmentDetails(){
        System.debug('insertEnvironmentDetails() started for envDetails from request'+requestWrpr.envDetails);
        List<Core_IPS_Environment_Details__c> envDetailsToUpdate = new List<Core_IPS_Environment_Details__c>();
        List<Core_IPS_Environment_Details__c> oldEnvDetailsToDelete = new List<Core_IPS_Environment_Details__c>();
        
        Set<String> addedQuestions = new Set<String>();
        if(requestWrpr.envDetails != null) {  
            for(Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper qa: mRequestQuestionEnvDetail.values()){
                System.debug('qa.envDetQuestion ===>> '+qa.envDetQuestion);
                if(String.isNotBlank(qa.envDetQuestion)){
                    Core_IPS_Environment_Details__c detail = new Core_IPS_Environment_Details__c();
                    detail.Core_case__c = existingCaseObj.id;
                    detail.Core_Question__c ='';
                    detail.Core_Answer__c ='';
                    detail.Core_Question__c += qa.envDetQuestion;
                    for(Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper a : qa.answers){
                        detail.Core_Answer__c += a.answer+'\r\n';
                    }
                    envDetailsToUpdate.add(detail);
                    addedQuestions.add(qa.envDetQuestionId);
                }
            } 
        }
        
        //Add all other questions which were not being passed in request
        for(Core_IPS_Assigned_Environment_Variables__c suppProdEnv : mSuppProdEnvDetailsAll.values()){
            if(!addedQuestions.contains(suppProdEnv.Name)){
                Core_IPS_Environment_Details__c detail = new Core_IPS_Environment_Details__c();
                detail.Core_case__c= existingCaseObj.id;
                detail.Core_Question__c = '';
                detail.Core_Answer__c = '';
                detail.Core_Question__c = suppProdEnv.Core_Environment_Variable__r.Name;
                envDetailsToUpdate.add(detail);
            }
        }
        
        //Add all other questions which were not being passed in request
        for(Core_IPS_Assigned_Environment_Variables__c suppProdEnv : mSubCatEnvDetailsAll.values()){
            if(!addedQuestions.contains(suppProdEnv.Name)){
                Core_IPS_Environment_Details__c detail = new Core_IPS_Environment_Details__c();
                detail.Core_case__c= existingCaseObj.id;
                detail.Core_Question__c = '';
                detail.Core_Answer__c = '';
                detail.Core_Question__c = suppProdEnv.Core_Environment_Variable__r.Name;
                envDetailsToUpdate.add(detail);
            }
        }
        
        oldEnvDetailsToDelete =[select id , Core_Case__r.CaseNumber,Core_Question__c,Core_Answer__c from Core_IPS_Environment_Details__c where Core_Case__r.CaseNumber=:CASE_NUMBER];
        
        delete oldEnvDetailsToDelete;
        insert envDetailsToUpdate;
        
    }
    
    
    /******************************************************* CLOSE CASE field validations START ***************************************************/  
    public Boolean doAllCloseCaseValidations(){
        System.debug('doAllCloseCaseValidations : Running validations for close case started ');
        Boolean requestValid = false;
        if(validateCaseNumber() == true ){
            if(requestWrpr.subject == null && requestWrpr.caseDescription == null 
               && requestWrpr.caseType == null && requestWrpr.caseSeverity == null && requestWrpr.severityReason == null
               && requestWrpr.customerReferenceId == null && requestWrpr.endCustomer == null && requestWrpr.contactId == null
               && requestWrpr.caseCategoryId == null && requestWrpr.subCategoryId == null && requestWrpr.envDetails == null)
            {
                requestValid = true;
            }else{
                validationCode = BAD_REQUEST_400;
                validationErrorMessage = '';
                
            }
        }
        Boolean result = (requestValid  && isCaseCustomerVisible() && isCaseStatusValid() );
        System.debug('doAllCloseCaseValidations : Running validations for close case completed result : '+result);
        return result;
    }
    
    /******************************************************* UPDATE CASE field validations START ***************************************************/  
    public Boolean doAllUpdateCaseValidations(){
        System.debug(' doAllUpdateCaseValidations started ');
        
        Boolean isUpdatable = Schema.sObjectType.Case.isUpdateable();
        Boolean isCasenumberValid =  (CASE_NUMBER.isNumeric() && CASE_NUMBER.length() == 8 );
        if(requestWrpr.status != null){
            validationCode = BAD_REQUEST_400;
            validationErrorMessage = '';
        }else if(isCasenumberValid == false){
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' Case Number';
        }else{
            List<Case> caseList =  [select CaseNumber,Core_IPS_Customer_Visible__c ,ContactId, status  ,AccountId, Subject ,Core_Issue_Description__c,Description ,Core_CaseType__c ,
                                    Core_Severity__c ,Core_Severity_Reason__c ,AssetId,   Core_Customer_Reference_ID__c, Core_End_Customer__c, Core_Case_Issue_Category__c , 
                                    Core_Case_Issue_Sub_Category__c ,Core_IPS_Supported_Product__r.name, Core_Sub_Status__c, Core_IPS_Partner_status_ReadOnly__c  
                                    from case where CaseNumber =: CASE_NUMBER];
            if(caseList.size() == 0){
                validationCode = INVALID_INPUT;
                validationErrorMessage = ' Case Number';
                isCasenumberValid = false;
            }else{
                existingCaseObj = caseList.get(0);
                System.debug('existingCaseObj  ==>> '+existingCaseObj );
                //System.debug('existingCaseObj.AssetId  ==>> '+existingCaseObj.AssetId );
                //System.debug('existingCaseObj.ContactId  ==>> '+existingCaseObj.ContactId );
            }
        }
        
        Boolean result = ( validateCaseNumber() && isCaseCustomerVisible() && isCaseStatusValid() && validateContactId() && validateCaseRequiredFields()  && isProductOrProjectValid() &&  validateCaseInputs() && validateCaseCategoryFields()  ) ;
        System.debug(' doAllUpdateCaseValidations result : '+result);
        return result;
    }
    
    //Validate the case number
    private Boolean validateCaseNumber(){
        System.debug(' validateCaseNumber result started ');
        Boolean isUpdatable = Schema.sObjectType.Case.isUpdateable();
        Boolean isCasenumberValid =  (CASE_NUMBER.isNumeric() && CASE_NUMBER.length() == 8 );

        if(isCasenumberValid == false){
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' Case Number';
            
        }else{
            List<Case> caseList =  [select CaseNumber,Core_IPS_Customer_Visible__c ,ContactId, status  ,AccountId, Subject ,Core_Issue_Description__c,Description ,Core_CaseType__c ,
                                    Core_Severity__c ,Core_Severity_Reason__c ,AssetId,   Core_Customer_Reference_ID__c, Core_End_Customer__c, Core_Case_Issue_Category__c , 
                                    Core_Case_Issue_Sub_Category__c ,Core_IPS_Supported_Product__r.name
                                    from case where CaseNumber =: CASE_NUMBER];
            if(caseList.size() == 0){
                validationCode = INVALID_INPUT;
                validationErrorMessage = ' Case Number';
                isCasenumberValid = false;
            }else{
                existingCaseObj = caseList.get(0);
                System.debug('existingCaseObj  ==>> '+existingCaseObj );
                System.debug('existingCaseObj.AssetId  ==>> '+existingCaseObj.AssetId );
                System.debug('existingCaseObj.ContactId  ==>> '+existingCaseObj.ContactId );
                
            }
        }
        Boolean result = ( isUpdatable && isCasenumberValid );
        System.debug(' validateCaseNumber result : '+result);
        return result;
    }
    
    
    public Boolean isCaseCustomerVisible(){
        System.debug(' isCaseCustomerVisible result started ');
        Boolean isCaseCustomerVisible= true; 
        if((existingCaseObj == null ) || (existingCaseObj != null && existingCaseObj.Core_IPS_Customer_Visible__c == false)){
            isCaseCustomerVisible = false;
            validationCode = INVALID_INPUT ;
            validationErrorMessage = ' ';   
        }
        System.debug(' isCaseCustomerVisible result completed result: '+isCaseCustomerVisible);
        return isCaseCustomerVisible;
    }
    
    public Boolean isCaseStatusValid(){
        System.debug(' isCaseStatusValid Validating the case status started ');
        Boolean isStatusValid = true; 
        if(existingCaseObj.status == 'Closed' || existingCaseObj.status == 'On Hold'){
            isStatusValid  = false;
            validationCode = UN_AUTHORIZED;
            validationErrorMessage = ' update the closed case or GEC case';   
        }
        System.debug(' isCaseStatusValid Validating the case status started completed result :'+isStatusValid);
        return isStatusValid ;
    }
    
    public Boolean validateContactId(){
        Boolean isContactIdValid = false;
        System.debug(' validateContactId Started existingCaseObj  contact Id '+existingCaseObj.ContactId +',  Request  contact Id '+requestWrpr.contactId);
        
        List<contact> con = [select Account.id  from contact where id = :requestWrpr.contactId ];
        if(con.Size() == 0){
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' Contact Id';
            isContactIdValid = false;
        }else if((existingCaseObj.ContactId).equals(requestWrpr.contactId)){
            System.debug('inside if condition contact ');
            CONTACT_ID = existingCaseObj.ContactId;
            isContactIdValid = true;
        }else if((existingCaseObj.AccountId).equals(con[0].Account.id)){
            System.debug('inside else if condition contact ');
            CONTACT_ID = requestWrpr.contactId;
            isContactIdValid = true;
        }else{
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' Contact Id';
            isContactIdValid = false;
        }
        System.debug(' validateContactId RESULT :'+isContactIdValid);
        return isContactIdValid;
    }
    
    //Validate the product is valid.
    @testVisible public Boolean isProductOrProjectValid(){
        Boolean productValid = true;
        for( Asset a : [Select Id, core_supported_product__c, core_supported_product__r.Name, product2Id, Status, Core_IPS_Project__c, Core_IPS_Project__r.Name, 
                        Core_IPS_Project__r.Core_Status__c, core_supported_product__r.Core_EOIS__c 
                        FROM Asset WHERE Id =: existingCaseObj.assetId Limit 1])  
        {
            assetObj = a;
        }
        if(assetObj == null){
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' ';    
            productValid = false;
        }else if( assetObj.Status != 'Active')  {
            validationCode = INACTIVE_PRODUCT;
            validationErrorMessage = ' '+assetObj.Id;     
            productValid = false;
        }else if(assetObj.core_supported_product__r.Core_EOIS__c == true){
            validationCode = INACTIVE_PRODUCT;
            validationErrorMessage = ' '+assetObj.Id;     
            productValid = false;
        }else if(String.isNotBlank(assetObj.Core_IPS_Project__c ) && assetObj.Core_IPS_Project__r.Core_Status__c  != 'Active'){
            validationCode = INACTIVE_PROJECT;
            validationErrorMessage = ' '+assetObj.Id;     
            productValid = false;
        }
        System.debug(' isProductIdValid >>> '+productValid+' validationErrorMessage :'+validationErrorMessage);
        return productValid;
    }
    
    
    
    //Validate the input fields are allowed/valid for the SF fields
    public Boolean validateCaseInputs(){
        Boolean flag = true;
        
        System.debug('ExistingCase  ====>>> '+existingCaseObj );
        
        Set<String> picklistCaseType = new Set<String>();
        Set<String> picklistSeverity = new Set<String>();
        //Retrieve all the Case.Type picklist values
        for(Schema.PicklistEntry pl :  Case.Type.getDescribe().getPicklistValues()){
            if(pl.isActive() == true)
                picklistCaseType.add(pl.getValue());
        }
        //Retrieve all the Case.Core_Severity__c picklist values
        for(Schema.PicklistEntry pl :  Case.Core_Severity__c.getDescribe().getPicklistValues()){
            if(pl.isActive() == true)
                picklistSeverity.add(pl.getValue());
        }
        System.debug(' >> Type valid Pick List values '+picklistCaseType+' \n >> severityValidPl valid pick List values '+picklistSeverity);
        
        //Validate the inputs are valid picklist values
        if(String.isNotBlank(requestWrpr.caseType) && !picklistCaseType.contains(requestWrpr.caseType)){
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' caseType '; 
            flag = false;
        }else if(String.isNotBlank(requestWrpr.caseSeverity) && !picklistSeverity.contains(requestWrpr.caseSeverity)){
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' caseSeverity '; 
            flag = false;
        }else if (Core_RestAPI_Util.isMaxLengthExceeded(requestWrpr.subject, 255)){
            validationCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ' 255 for subject';  
            flag = false;
        }else if (Core_RestAPI_Util.isMaxLengthExceeded(requestWrpr.caseDescription, 32000)){
            validationCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ' 32000 for caseDescription';  
            flag = false;
        }else if (String.isNotBlank(requestWrpr.severityReason)  && Core_RestAPI_Util.isMaxLengthExceeded(requestWrpr.severityReason, 255)){
            validationCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ' 255 for severityReason';  
            flag = false;
        }else if (Core_RestAPI_Util.isMaxLengthExceeded(requestWrpr.endCustomer, 120)){
            validationCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ' 120 for endCustomer';  
            flag = false;
        }else if(Core_RestAPI_Util.isMaxLengthExceeded(requestWrpr.customerReferenceId, 40)){
            validationCode = MAX_LENGTH_EXCEEDED_9025;
            validationErrorMessage = ' 40 for customerReferenceId';  
            flag = false;
        }
        
        System.debug(' validateCaseFieldValues >>> '+flag+' validationErrorMessage :'+validationErrorMessage);
        return flag;
    }
    
    //Validate the required fields 
    @testVisible
    private Boolean validateCaseRequiredFields(){
        Boolean flag = true;
        System.debug('requestWrpr  ==> '+requestWrpr);
        if (String.isBlank(requestWrpr.subject) ){
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' subject' ;  
            flag = false;
        }else if (String.isBlank(requestWrpr.caseDescription)) {
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' caseDescription' ;  
            flag = false;
        }else if (String.isBlank(requestWrpr.caseType) ) {
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' caseType' ;  
            flag = false;
        }else if(String.isBlank(requestWrpr.caseSeverity)) {
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' caseSeverity';  
            flag = false;
        }else if(String.isNotBlank(requestWrpr.caseSeverity) && 'Critical'.equalsIgnorecase(requestWrpr.caseSeverity) && String.isBlank(requestWrpr.severityReason)){
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' severityReason ';  
            flag = false;
        }
        
        System.debug(' validateCaseRequiredFields >>> '+flag+' validationErrorMessage :'+validationErrorMessage);
        return flag;
    }
    
    //Validate both Case categories and sub categories
    public Boolean validateCaseCategoryFields(){
        Boolean flag = true;  
        //Map holds the categories as Keys and all the sub categories as a set
        System.debug('  validateCaseCategoryFields started ');
        Boolean categoryValid = false;
        Boolean subCategoryValid = false;
        Boolean noCategories = true;
        
        //Query all the categories and sub categories for the product
        System.debug('assetObj 1234 ===>> '+assetObj);
        System.debug('assetObj.core_supported_product__c ===>> '+assetObj.core_supported_product__c);
        for(Core_IPS_Product_Issue_Category__c cat : [Select Name,  Core_Issue_Category_Name__r.Name,  
                                                      (Select Name, Core_Issue_Category_Name__c, Core_Issue_Sub_Category_Name__c, Core_Product_Issue_Category__c, 
                                                       Core_Supported_Product__c, Core_Type__c, Core_Issue_Sub_Category_Name__r.Name
                                                       From Product_Issue_Sub_Categories__r) 
                                                      From Core_IPS_Product_Issue_Category__c c 
                                                      WHERE Core_Supported_Product__c =: assetObj.core_supported_product__c Limit 2000]) //AND Name =: requestWrpr.caseCategoryId 
        {
            noCategories = false;
            System.debug(' validateCaseCategoryFields case categories >>>> '+cat.Name + ' > '+cat.Core_Issue_Category_Name__r.Name);
            System.debug('requestWrpr.caseCategoryId  ===>>> '+requestWrpr.caseCategoryId);
            if(requestWrpr.caseCategoryId == cat.Name){
                this.catId = cat.Id;
                categoryValid = true;
                for(Core_IPS_Product_Issue_Category__c subCat : cat.Product_Issue_Sub_Categories__r){
                    System.debug(' validateCaseCategoryFields and sub categories >>> '+cat.Name + ' > '+subCat.Name+'  requestWrpr.subCategoryId ==>'+requestWrpr.subCategoryId);
                    if(requestWrpr.subCategoryId == subCat.Name){
                        subCategoryValid = true;
                        this.subCatId = subCat.Id;
                        break;
                    }
                }
                break;
            }
        }
        
        //Product does not have any categories defined but the user sent the values in the request body
        if(noCategories == true){
            if(String.isNotBlank(requestWrpr.caseCategoryId) || String.isNotBlank(requestWrpr.subCategoryId)  ){
                validationCode = INVALID_INPUT;
                validationErrorMessage = ' caseCategoryId/subCategoryId '; 
                flag = false;
            }  
        }else{
            if(String.isEmpty(requestWrpr.caseCategoryId)){
                flag = false;
                validationCode = REQ_FIELD_MISSING_9002;
                validationErrorMessage = ' caseCategoryId';  
                
            }else if(String.isEmpty(requestWrpr.subCategoryId)){
                flag = false;
                validationCode = REQ_FIELD_MISSING_9002;
                validationErrorMessage = ' subCategoryId';  
                
            }else if(categoryValid == false){
                flag = false;
                validationCode = INVALID_INPUT;
                validationErrorMessage = ' caseCategoryId';  
                
            }else if(subCategoryValid == false){
                validationCode = INVALID_INPUT;
                flag = false;
                validationErrorMessage = ' subCategoryId';  
            }            
        }
        System.debug(' validateCaseCategoryFields  >>> categoryValid :'+categoryValid+' subCategoryValid:'+subCategoryValid+' noCategories > '+noCategories +' Result :'+flag+' validationErrorMessage :'+validationErrorMessage);
        return flag;
    }
    
    
    /******************************************************* Case field validations End ***************************************************/  
    /******************************************************* Environment detail field validations START ***************************************************/    
    @testVisible 
    private Boolean doAllEnvDetailValidations(){
        System.debug('Started validating environment details  Inputs \n assetObj.core_supported_product__c  '+assetObj.core_supported_product__c+ ' \n requestWrpr.subCategoryId  '+requestWrpr.subCategoryId);
        lstSuppProdEnvDetails = [SELECT  Name, Core_Environment_Variable__r.Name, Core_Environment_Variable__r.Core_Answers__c, Core_Environment_Variable__r.Core_Datatype__c, Core_Required__c 
                                 FROM Core_IPS_Assigned_Environment_Variables__c 
                                 WHERE Core_Supported_Product__c =: assetObj.core_supported_product__c];
        System.debug('lstSuppProdEnvDetails -->'+lstSuppProdEnvDetails );
        if(String.isNotBlank(requestWrpr.subCategoryId)){
            lstSubCatEnvDetails =[SELECT Name, Core_Environment_Variable__r.Name, Core_Environment_Variable__r.Core_Datatype__c, Core_Required__c, Core_Environment_Variable__r.Core_Answers__c
                                  FROM Core_IPS_Assigned_Environment_Variables__c 
                                  WHERE Core_Product_Issue_Sub_Category__r.Name =: requestWrpr.subCategoryId];
            System.debug('lstSubCatEnvDetails -->'+lstSubCatEnvDetails );
        }      
        //  code for check duplicate question 
        if(requestWrpr.EnvDetails != null && !requestWrpr.EnvDetails.isEmpty() ){
            for( Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper wrpr :  requestWrpr.EnvDetails)        {
                String ques = ( wrpr.envDetQuestion != null ? wrpr.envDetQuestion.trim(): '');
                if(mRequestQuestionEnvDetail.containsKey(ques)){
                    System.debug('inside duplicate question '+ques);
                    validationCode = DUPLICATE_INPUTS ;
                    validationErrorMessage = ' '+ques;
                    return false;
                }else{
                    mRequestQuestionEnvDetail.put(ques, wrpr);
                }
            }
            System.debug('mRequestQuestionEnvDetail===>>> '+mRequestQuestionEnvDetail.size());
        }
        
        //Product & SubCategory does not have any environment details defined but request has, throw the validation message
        if(( lstSuppProdEnvDetails == null || ( lstSuppProdEnvDetails != null && lstSuppProdEnvDetails.isEmpty() ) )  
           && ( lstSubCatEnvDetails == null || ( lstSubCatEnvDetails != null && lstSubCatEnvDetails.isEmpty() ) ) 
           && lstSubCatEnvDetails == null && !mRequestQuestionEnvDetail.isEmpty())
        {
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' envDetails ' ;
            return false;
        }
        
        if(lstSuppProdEnvDetails != null){
            for(Core_IPS_Assigned_Environment_Variables__c prodEnvDet : lstSuppProdEnvDetails){
                if(prodEnvDet.Core_Required__c == true && String.isNotBlank(prodEnvDet.Core_Environment_Variable__r.Name)){
                    mSuppProdEnvDetailsRequired.put(prodEnvDet.Core_Environment_Variable__r.Name, prodEnvDet);
                }
                mSuppProdEnvDetailsAll.put(prodEnvDet.Core_Environment_Variable__r.Name, prodEnvDet);
            }
        }
        if(lstSubCatEnvDetails != null){
            for(Core_IPS_Assigned_Environment_Variables__c prodEnvDet : lstSubCatEnvDetails){
                if(prodEnvDet.Core_Required__c == true && String.isNotBlank(prodEnvDet.Core_Environment_Variable__r.Name)){
                    mSubCatEnvDetailsRequired.put(prodEnvDet.Core_Environment_Variable__r.Name, prodEnvDet);
                }
                mSubCatEnvDetailsAll.put(prodEnvDet.Core_Environment_Variable__r.Name, prodEnvDet);
            }
        }
        System.debug('mSuppProdEnvDetailsRequired ===>> '+mSuppProdEnvDetailsRequired);
        System.debug('mSuppProdEnvDetailsAll      ===>> '+mSuppProdEnvDetailsAll);
        System.debug('mSubCatEnvDetailsRequired   ===>> '+mSubCatEnvDetailsRequired);
        System.debug('mSubCatEnvDetailsAll        ===>> '+mSubCatEnvDetailsAll);
        System.debug('mRequestQuestionEnvDetail   ===>> '+mRequestQuestionEnvDetail);
        
        boolean result =  validateEnvDetailRequiredFields() && validateEnvDetailMatch();
        System.debug('doAllEnvDetailValidations    result    ===>> '+result);
        
        return result;
        
    }
    // checking for required fields are given in request or not
    @testVisible private Boolean validateEnvDetailRequiredFields(){
        System.debug('validateEnvDetailRequiredFields started ');
        Boolean requestHasAllRequiredFields = true;
        
        //Product/Subcategory has envDetails as required fields and api request do not have evn details
        if((mSuppProdEnvDetailsRequired.size() > 0 || mSubCatEnvDetailsRequired.size() > 0) && mRequestQuestionEnvDetail.size() == 0){
            System.debug('inside all blank list condition ');
            validationCode = REQ_FIELD_MISSING_9002; 
            validationErrorMessage = ' envDetails' ;
            return false;
        }
        
        //PRODUCT : Verify request has all the required environmental details passed
        for(Core_IPS_Assigned_Environment_Variables__c prodEnvDet : mSuppProdEnvDetailsRequired.values()){
            System.debug('mRequestQuestionEnvDetail  ===>> '+mRequestQuestionEnvDetail);
            System.debug('prodEnvDet.Core_Environment_Variable__r.Name  ===>> '+prodEnvDet.Core_Environment_Variable__r.Name);
            if(mRequestQuestionEnvDetail.get(prodEnvDet.Core_Environment_Variable__r.Name) == null){
                validationCode = REQ_FIELD_MISSING_9002;
                validationErrorMessage = ' envDetails '+prodEnvDet.Name +' '+prodEnvDet.Core_Environment_Variable__r.Name ;
                return false;
                
            }
        }
        System.debug('mSubCatEnvDetailsRequired  ===>> '+mSubCatEnvDetailsRequired);
        //SUB-CATEGORY : Verify request has all the required environmental details passed
        for(Core_IPS_Assigned_Environment_Variables__c subCatEnvDet : mSubCatEnvDetailsRequired.values()){
            System.debug('mRequestQuestionEnvDetail  ===>> '+mRequestQuestionEnvDetail);
            System.debug('subCatEnvDet.Core_Environment_Variable__r.Name  ===>> '+subCatEnvDet.Core_Environment_Variable__r.Name); 
            if(mRequestQuestionEnvDetail.get(subCatEnvDet.Core_Environment_Variable__r.Name) == null){
                System.debug('inside subcat required  condition '+subCatEnvDet.Core_Environment_Variable__r.Name);
                validationCode = REQ_FIELD_MISSING_9002;
                validationErrorMessage = ' envDetails ' +subCatEnvDet.Name +' '+subCatEnvDet.Core_Environment_Variable__r.Name; 
                return false;
            }
        }
        
        System.debug('requestHasAllRequiredFields ? ==>> '+requestHasAllRequiredFields );
        return requestHasAllRequiredFields;
    }
    
    // validation method to check user entered question is present in subCat env details or not (checking required question and match it )
    @testVisible  private Boolean validateEnvDetailMatch(){
        Boolean envDetailMatch= true;
        Boolean isAnsValidate = true;
        
        for(Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper envdet : mRequestQuestionEnvDetail.values())
        {    
            
            boolean envDetailMatchTemp = false;
            System.debug('envdet.envDetQuestion ==>> '+envdet.envDetQuestion);
            System.debug('lstSubCatEnvDetails   ==>> '+lstSubCatEnvDetails );    
            if(lstSubCatEnvDetails != null){
                for(Core_IPS_Assigned_Environment_Variables__c assEnvDet : lstSubCatEnvDetails)
                {
                    System.debug(' assEnvDet ===>> '+assEnvDet.Name +'  envdet.envDetQuestionId===>>> '+envdet.envDetQuestionId);
                    // compairing question and questionId 
                    if(envdet.envDetQuestion == assEnvDet.Core_Environment_Variable__r.Name && envdet.envDetQuestionId == assEnvDet.Name){
                        envDetailMatchTemp= true;
                        // If question matches check for valid ans by  isAnsValidate(envdet, assEnvDet)
                        isAnsValidate = isAnsValidate && isAnsValidate(envdet, assEnvDet);
                        break;
                    }
                }
            }
            // If question not found in sub cat env details find it in supported prod env details
            if(envDetailMatchTemp == false && lstSuppProdEnvDetails != null){ 
                for(Core_IPS_Assigned_Environment_Variables__c assEnvDet1 : lstSuppProdEnvDetails)
                {
                    System.debug('  envdet.envDetQuestionId===>>> '+envdet.envDetQuestionId+'   assEnvDet1.Name===>> '+assEnvDet1.Name);
                    if( envdet.envDetQuestion == assEnvDet1.Core_Environment_Variable__r.Name && envdet.envDetQuestionId == assEnvDet1.Name) {
                        envDetailMatchTemp= true; 
                        isAnsValidate = isAnsValidate && isAnsValidate(envdet, assEnvDet1);
                        break;
                    }else{
                        envDetailMatchTemp=false;
                    }   
                }
            }
            envDetailMatch = envDetailMatch && envDetailMatchTemp ;
            if(envDetailMatch == false){
                validationCode = INVALID_INPUT;  
                validationErrorMessage = '  envDetQuestion / envDetQuestionId '+envdet.envDetQuestion+' / '+envdet.envDetQuestionId; 
                break; 
            }
        }
        Boolean finalResult = (envDetailMatch && isAnsValidate);
        System.debug(' validateEnvDetailMatch result : '+finalResult);
        return finalResult;
    }    
    
    // Validate all Answers in the request.
    // checking validation for answer length , answer list size(answer is not more than one) and answer are valid or not
    @testVisible private Boolean isAnsValidate(Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper reqQuest , Core_IPS_Assigned_Environment_Variables__c envQuestDetail){
        System.debug(' isAnsValidate invoked to validate all answers  >> ');
        Boolean ansLstValidSize = true;
        Boolean ansValidation = true;
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstWrappAnswer = reqQuest.answers;
        if(envQuestDetail.Core_Environment_Variable__r.Core_Datatype__c == 'Text Area (5000)' ){
            
            // checking for answer is not more than one
            if(lstWrappAnswer.size() > 1){
                ansLstValidSize = false;
                validationCode = INVALID_INPUT_ANSWER ;
                validationErrorMessage = ' '+reqQuest.envDetQuestionId;
            }else{
                // checking for ans size is less than 5000
                for(Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                    if(Core_RestAPI_Util.isMaxLengthExceeded(answerObj.answer, 5000) ){
                        ansValidation = false;
                        validationCode = MAX_LENGTH_EXCEEDED_9025;
                        validationErrorMessage = ' 5000 for Answer '+reqQuest.envDetQuestionId;
                    }
                }
            }
            
        }else If(envQuestDetail.Core_Environment_Variable__r.Core_Datatype__c == 'Text (255)'){
            if(lstWrappAnswer.size() > 1){
                ansLstValidSize = false;
                validationCode = INVALID_INPUT_ANSWER ;
                validationErrorMessage = ' '+reqQuest.envDetQuestionId;
            }else{
                for(Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                    if(Core_RestAPI_Util.isMaxLengthExceeded(answerObj.answer, 255)){
                        ansValidation = false;
                        validationCode = MAX_LENGTH_EXCEEDED_9025;
                        validationErrorMessage = ' 255 for Answer '+reqQuest.envDetQuestionId;
                    }
                }
            }
        }else If(envQuestDetail.Core_Environment_Variable__r.Core_Datatype__c == 'Picklist'){
            if(lstWrappAnswer.size() > 1){
                ansLstValidSize = false;
                validationCode = INVALID_INPUT_ANSWER ;
                validationErrorMessage = ' '+reqQuest.envDetQuestionId;
            }else{
                List<String> lstEnvAnswers = envQuestDetail.Core_Environment_Variable__r.Core_Answers__c.split('\r\n');
                for(Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                    if(!(lstEnvAnswers.Contains(answerObj.answer))){
                        ansValidation = false;
                        validationCode = INVALID_INPUT_ANSWER ;
                        validationErrorMessage = ' '+reqQuest.envDetQuestionId;
                    }
                }
            }
        }else if(envQuestDetail.Core_Environment_Variable__r.Core_Datatype__c == 'Multiselect Picklist'){
            List<String> lstEnvAnswers = envQuestDetail.Core_Environment_Variable__r.Core_Answers__c.split('\r\n');
            for(Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                if(!(lstEnvAnswers.Contains(answerObj.answer))){
                    ansValidation = false;
                    validationCode = INVALID_INPUT_ANSWER ;
                    validationErrorMessage = ' '+reqQuest.envDetQuestionId;
                }
            }
        }
        else{
            ansLstValidSize = false;
            ansValidation   = false;
            validationCode = INVALID_INPUT_ANSWER ;
            validationErrorMessage = ' '+reqQuest.envDetQuestionId;
        }
        
        Boolean finalResult =  (ansLstValidSize  && ansValidation );
        System.debug(' isAnsValidate result >> '+finalResult);
        return finalResult;
    }
    
    /******************************************************* Environment detail field validations END ***************************************************/    
    public class CaseWrapper implements Core_RestAPI_SuccessContent{
        public String message {get;set;}
    }  
}