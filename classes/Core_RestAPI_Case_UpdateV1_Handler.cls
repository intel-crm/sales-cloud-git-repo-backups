/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_UpdateCasesHandler
* Version     : 1.0 
* Created Date: 3/6/2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         3/6/2018                RestAPI handler for validating the request and updating case
*****************************************************************************************************************************************/
public class Core_RestAPI_Case_UpdateV1_Handler {
    
    private final String  REQ_FIELD_MISSING_9002 = '9002';
    private final String  MAX_LENGTH_EXCEEDED_9025 = '9025';
    private final String  INVALID_INPUT = '9011';
    private final String  INVALID_INPUT_ANSWER = '9012';
    private final String  INACTIVE_PRODUCT = '9015';
    private final String  UN_AUTHORIZED= '9004';
    private final String INACTIVE_PROJECT ='9016';
    private final String DUPLICATE_INPUTS = '9017';
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
    private Case existingCaseObj = null;
    private DateTime entryTime = null;
    private String apiName = null;
    
    public static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    
    private List<Core_IPS_Assigned_Environment_Variables__c> lstOfEnvDetails  = null;
    
    //Map<Question, Object> for all the REQUIRED**** environment details questions for the PRODUCT And SUBCATEGORY
    Map<String, Core_IPS_Assigned_Environment_Variables__c> mEnvDetailsRequiredAll = new Map<String, Core_IPS_Assigned_Environment_Variables__c>();
    
    //Map<Question, Object> for all environment details questions for the PRODUCT And SUBCATEGORY
    Map<String, Core_IPS_Assigned_Environment_Variables__c> mEnvDetailsAll = new Map<String, Core_IPS_Assigned_Environment_Variables__c>();
    
    
    //Map<Question, Object> for all the environment details which are passed in api request
    Map<String, Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> mRequestQuestionEnvDetail = new Map<String, Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
    
    //Map<Question,Map<AnswerId,Answer>> for all Question's Answers and the map of AnswerId and Answers
    Map<String , map<String, Core_IPS_Answer__c>> mQuestionAnswerAll = new Map<String , map<String, Core_IPS_Answer__c>>();
    
    
    public Core_RestAPI_Case_UpdateV1_Handler(String apiname, DateTime entryTime, Core_RestAPI_Case_UpdateV1_Wrapper argWrpr){
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
            if(String.isNotBlank(requestWrpr.status)){
                
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
            system.debug('response.code==>> '+response.code);
            if(String.isBlank(response.code)){
                response.code = SUCCESS_CODE_201;
                CaseWrapper cw = new CaseWrapper();
                cw.message = existingCaseObj.CaseNumber +' updated successfully ';
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
        
        //category and subcategory
        existingCaseObj.Core_Case_Issue_Category__c = this.catId;
        existingCaseObj.Core_Case_Issue_Sub_Category__c = this.subCatId;
        
        update existingCaseObj;
        System.debug(' Updating the case record completed ');
    }
    
    /******************************************** Update EnvironmentDetails STARTS ****************************************************/
    
    //update Environment Details 
    public void updateEnvironmentDetails(){
        
        System.debug('updateEnvironmentDetails() started for envDetails from request'+requestWrpr.envDetails);
        List<Core_IPS_Response__c> envDetailsToUpdate = new List<Core_IPS_Response__c>();
        List<Core_IPS_Response__c> oldEnvDetailsToDelete = new List<Core_IPS_Response__c>();
        
        Set<String> addedQuestions = new Set<String>();
        if(requestWrpr.envDetails != null) {  
            for(Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper qa: mRequestQuestionEnvDetail.values()){
                for( Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ans : qa.answers){
                    if(String.isNotBlank(qa.envDetQuestionId)){
                        Core_IPS_Response__c detail = new Core_IPS_Response__c();
                        detail.Core_IPS_Case__c = existingCaseObj.id;
                        if(mEnvDetailsAll.containsKey(qa.envDetQuestionId)){
                            Core_IPS_Assigned_Environment_Variables__c objEnvVariables = mEnvDetailsAll.get(qa.envDetQuestionId);
                            detail.Core_IPS_Question_Master__c = objEnvVariables.Core_IPS_Question__r.id;
                        }
                        detail.Core_IPS_Answer__c = ans.answer;
                        if(mEnvDetailsAll.get(qa.envDetQuestionId).Core_IPS_Question__r.Core_IPS_Datatype__c == 'Picklist' || mEnvDetailsAll.get(qa.envDetQuestionId).Core_IPS_Question__r.Core_IPS_Datatype__c == 'Multiselect Picklist'){
                            
                            detail.Core_IPS_Answer_Master__c= mQuestionAnswerAll.get(qa.envDetQuestionId).get(ans.answerId).id;
                        }
                        envDetailsToUpdate.add(detail);
                        addedQuestions.add(qa.envDetQuestionId);
                    }
                }
            } 
        }
        //Add all other questions which were not being passed in request
        for(Core_IPS_Assigned_Environment_Variables__c suppProdEnv : mEnvDetailsAll.values()){
            if(suppProdEnv.Core_IPS_Question__r.name != null){
                if(!addedQuestions.contains(suppProdEnv.Core_IPS_Question__r.name)){
                    Core_IPS_Response__c detail = new Core_IPS_Response__c();
                    detail.Core_IPS_Case__c = existingCaseObj.id;
                    detail.Core_IPS_Question_Master__c = suppProdEnv.Core_IPS_Question__r.id;
                    detail.Core_IPS_Answer__c = '';
                    detail.Core_IPS_Answer_Master__c=null;
                    envDetailsToUpdate.add(detail);
                }
            }
        }
        System.debug('oldEnvDetailsToDelete===>> '+oldEnvDetailsToDelete );
        
        oldEnvDetailsToDelete =[SELECT Id FROM Core_IPS_Response__c WHERE Core_IPS_Case__c =:existingCaseObj.Id AND Core_IPS_Agent_Only__c = false];
        Core_IPS_AdminUtility.DeleteEnvDetails(oldEnvDetailsToDelete);
        Core_IPS_AdminUtility.insertEnvDetailsToCreate(envDetailsToUpdate);
    }
    
    /******************************************************* CLOSE CASE field validations START ***************************************************/  
    public Boolean doAllCloseCaseValidations(){
        System.debug('doAllCloseCaseValidations : Running validations for close case started ');
        Boolean requestValid = false;
        if(validateCaseNumber() == true ){
            if(!'Closed'.equalsIgnoreCase(requestWrpr.status)){
                requestValid = false;                
                validationCode = INVALID_INPUT;
                validationErrorMessage = ' status';   
            }else if('Closed'.equalsIgnoreCase(requestWrpr.status) && requestWrpr.subject == null && requestWrpr.caseDescription == null 
                     && requestWrpr.caseType == null && requestWrpr.caseSeverity == null && requestWrpr.severityReason == null
                     && requestWrpr.customerReferenceId == null && requestWrpr.endCustomer == null 
                     && requestWrpr.caseCategoryId == null && requestWrpr.subCategoryId == null && requestWrpr.envDetails == null)
            {
                requestValid = true;
            }else{
                requestValid = false;                
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
            }
        }
        
        Boolean result = ( validateCaseNumber() && isCaseCustomerVisible() && isCaseStatusValid()  && validateCaseRequiredFields()  && isProductOrProjectValid() &&  validateCaseInputs() && validateCaseCategoryFields()  ) ;
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
    
    
    
    //Validate the product is valid.
    @testVisible public Boolean isProductOrProjectValid(){
        System.debug(' isProductOrProjectValid started ');
        Boolean productValid = true;
        for( Asset a : [Select Id, core_supported_product__c, core_supported_product__r.Name, product2Id, Status, Core_IPS_Project__c, Core_IPS_Project__r.Name, 
                        Core_IPS_Project__r.Core_Status__c, core_supported_product__r.Core_EOIS__c 
                        FROM Asset WHERE Id =: existingCaseObj.assetId Limit 1])  
        {
            assetObj = a;
        }
        system.debug('assetObj ==>> '+assetObj);
        system.debug(' existingCaseObj. id ==>> '+ existingCaseObj.id);
        
        if(assetObj == null){
            System.debug('inside if assetObbj is null');
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' ';    
            productValid = false;
        }else if( assetObj.Status != 'Active')  {
            System.debug('inside else if assetObbj status is active');
            validationCode = INACTIVE_PRODUCT;
            validationErrorMessage = ' '+assetObj.Id;     
            productValid = false;
        }else if(assetObj.core_supported_product__r.Core_EOIS__c == true){
            System.debug('inside else if assetObbj core_supported_product__r.Core_EOIS__c is true');
            validationCode = INACTIVE_PRODUCT;
            validationErrorMessage = ' '+assetObj.Id;     
            productValid = false;
        }else if(String.isNotBlank(assetObj.Core_IPS_Project__c ) && assetObj.Core_IPS_Project__r.Core_Status__c  != 'Active'){
            System.debug('inside else if assetObj assetObj.Core_IPS_Project__c is not empty');
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
        for(Schema.PicklistEntry pl :  Case.Core_CaseType__c.getDescribe().getPicklistValues()){
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
            system.debug('requestWrpr.subject is blank ');
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' subject' ;  
            flag = false;
        }else if (String.isBlank(requestWrpr.caseDescription)) {
            system.debug('caseDescription is blank ');
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' caseDescription' ;  
            flag = false;
        }else if (String.isBlank(requestWrpr.caseType) ) {
            system.debug('caseType is blank ');
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' caseType' ;  
            flag = false;
        }else if(String.isBlank(requestWrpr.caseSeverity)) {
            system.debug('caseSeverity is blank ');
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
        Boolean noSubCategories = true;
        
        //Query all the categories and sub categories for the product
        System.debug('assetObj ===>> '+assetObj);
        for(Core_IPS_Product_Issue_Category__c cat : [Select Name,  Core_Issue_Category_Name__r.Name,  
                                                      (Select Name, Core_Issue_Category_Name__c, Core_Issue_Sub_Category_Name__c, Core_Product_Issue_Category__c, 
                                                       Core_Supported_Product__c, Core_Type__c, Core_Issue_Sub_Category_Name__r.Name
                                                       From Product_Issue_Sub_Categories__r WHERE Core_Status__c='Active') 
                                                      From Core_IPS_Product_Issue_Category__c c 
                                                      WHERE Core_Status__c='Active' AND Core_Supported_Product__c =: assetObj.core_supported_product__c Limit 2000]) //AND Name =: requestWrpr.caseCategoryId 
        {
            noCategories = false;
            System.debug(' validateCaseCategoryFields case categories >>>> '+cat.Name + ' > '+cat.Core_Issue_Category_Name__r.Name);
            System.debug('requestWrpr.caseCategoryId  ===>>> '+requestWrpr.caseCategoryId);
            if(requestWrpr.caseCategoryId == cat.Name){
                this.catId = cat.Id;
                categoryValid = true;
                for(Core_IPS_Product_Issue_Category__c subCat : cat.Product_Issue_Sub_Categories__r){
                noSubCategories = false;
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
            system.debug('inside if condition ');
            if(String.isNotBlank(requestWrpr.caseCategoryId) || String.isNotBlank(requestWrpr.subCategoryId)  ){
                validationCode = INVALID_INPUT;
                validationErrorMessage = ' caseCategoryId/subCategoryId '; 
                flag = false;
            }
        }else if(noCategories == false && String.isEmpty(requestWrpr.caseCategoryId)){
            system.debug('inside the empty cat ==>> ');
            flag = false;
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' caseCategoryId';  
        }else if(noCategories == false && categoryValid == false){
            system.debug('inside else condition categoryValid == false');
            flag = false;
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' caseCategoryId';  
        }else if(noSubCategories == true){
            if(String.isNotBlank(requestWrpr.subCategoryId)){
                validationCode = INVALID_INPUT;
                validationErrorMessage = ' caseCategoryId/subCategoryId '; 
                flag = false;
            }  
        }else if(noSubCategories == false && String.isEmpty(requestWrpr.subCategoryId)){
            system.debug('inside else condition requestWrpr.subCategoryId is empty ');
            flag = false;
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = ' subCategoryId';  
        }else if(noSubCategories == false && subCategoryValid == false){
            system.debug('inside else condition subCategoryValid == false');
            validationCode = INVALID_INPUT;
            flag = false;
            validationErrorMessage = ' subCategoryId'; 
        }
        
        System.debug(' validateCaseCategoryFields  >>> categoryValid :'+categoryValid+' subCategoryValid:'+subCategoryValid+' noCategories > '+noCategories +' Result :'+flag+' validationErrorMessage :'+validationErrorMessage);
        return flag;
    }
    
    
    /******************************************************* Case field validations End ***************************************************/  
    /******************************************************* Environment detail field validations START ***************************************************/    
    @testVisible 
    private Boolean doAllEnvDetailValidations(){
        
        system.debug('doAllEnvDetailValidations started ====<>>> '+assetObj.core_supported_product__c);
        Set<Id> questionId = new Set<Id>();
        lstOfEnvDetails  = [SELECT Name ,Core_IPS_Question__r.name,Core_IPS_Question__r.id,Core_IPS_Question__r.Core_IPS_Parent_Question__r.name,Core_IPS_Question__r.Core_IPS_Datatype__c,Core_IPS_Question__r.Core_IPS_Question__c,Core_Required__c
                            FROM Core_IPS_Assigned_Environment_Variables__c 
                            WHERE ( Core_Supported_Product__c =: assetObj.core_supported_product__c 
                            OR (Core_Product_Issue_Sub_Category__r.Name =: requestWrpr.subCategoryId AND Core_Product_Issue_Sub_Category__r.Name != null))
                            AND Core_Agent_Only__c = false AND Core_Status__c='Active'];
        System.debug('lstOfEnvDetails  -->'+lstOfEnvDetails  );
        
        for(Core_IPS_Assigned_Environment_Variables__c objId : lstOfEnvDetails){
            questionId.add(objId.Core_IPS_Question__c);
        }
        List<Core_IPS_Question__c > lstQuesAns= [SELECT Name,id,Core_IPS_Question__c,Core_IPS_Parent_Question__r.name ,Core_IPS_Datatype__c ,
                                                (select id ,name , Core_IPS_Answer__c , Core_IPS_Question__r.name from Core_Answers__r
                                                WHERE Core_IPS_Status__c = 'Active') 
                                                FROM Core_IPS_Question__c WHERE Id  IN: questionId  AND Core_IPS_Status__c='Active'];
        
        for(Core_IPS_Question__c quest: lstQuesAns){
            String ques = ( quest.Name != null ? quest.Name.trim(): '');
            Map<String, Core_IPS_Answer__c> ansIdDetails= new map<String, Core_IPS_Answer__c>();
            for(Core_IPS_Answer__c objans : quest.Core_Answers__r){
                ansIdDetails.put(objans.name ,objans);
            }
            mQuestionAnswerAll.put(ques,ansIdDetails);
            
        }
        //  code for check duplicate question 
        if(requestWrpr.EnvDetails != null && !requestWrpr.EnvDetails.isEmpty() ){
            for( Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper wrpr :  requestWrpr.EnvDetails){
                String ques = ( wrpr.envDetQuestionId!= null ? wrpr.envDetQuestionId.trim(): '');
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
        if(( lstOfEnvDetails  == null || ( lstOfEnvDetails  != null && lstOfEnvDetails .isEmpty() ) ) && !mRequestQuestionEnvDetail.isEmpty())
        {
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' envDetails ' ;
            return false;
        }
        
        if(lstOfEnvDetails  != null){
            for(Core_IPS_Assigned_Environment_Variables__c prodEnvDet : lstOfEnvDetails ){
                if(prodEnvDet.Core_Required__c == true && String.isNotBlank(prodEnvDet.Core_IPS_Question__r.Core_IPS_Question__c)){
                    mEnvDetailsRequiredAll.put(prodEnvDet.Core_IPS_Question__r.Name, prodEnvDet);
                }
                mEnvDetailsAll.put(prodEnvDet.Core_IPS_Question__r.Name, prodEnvDet);
            }
        }
        System.debug('mEnvDetailsRequiredAll ===>> '+mEnvDetailsRequiredAll);
        System.debug('mEnvDetailsAll      ===>> '+mEnvDetailsAll);
        System.debug('mRequestQuestionEnvDetail   ===>> '+mRequestQuestionEnvDetail);
        
        Boolean result =  validateEnvDetailRequiredFields() && validateEnvDetailMatch();
        System.debug('doAllEnvDetailValidations    result    ===>> '+result);
        
        return result;
    }
    // checking for required fields are given in request or not
    @testVisible private Boolean validateEnvDetailRequiredFields(){
        System.debug('validateEnvDetailRequiredFields started ');
        Boolean requestHasAllRequiredFields = true;
        
        //Product/Subcategory has envDetails as required fields and api request do not have evn details
        if(mEnvDetailsRequiredAll.size() > 0  && mRequestQuestionEnvDetail.size() == 0){
            System.debug('inside all blank list condition ');
            validationCode = REQ_FIELD_MISSING_9002; 
            validationErrorMessage = ' envDetails' ;
            return false;
        }
        
        //PRODUCT : Verify request has all the required environmental details passed
        for(Core_IPS_Assigned_Environment_Variables__c prodEnvDet : mEnvDetailsRequiredAll.values()){
            System.debug('mRequestQuestionEnvDetail  ===>> '+mRequestQuestionEnvDetail);
            System.debug('prodEnvDet.Core_IPS_Question__r.Core_IPS_Question__c  ===>> '+prodEnvDet.Core_IPS_Question__r.Core_IPS_Question__c);
            if(mRequestQuestionEnvDetail.get(prodEnvDet.Core_IPS_Question__r.Name) == null){
                validationCode = REQ_FIELD_MISSING_9002;
                validationErrorMessage = ' envDetails '+prodEnvDet.Core_IPS_Question__r.Name +' '+prodEnvDet.Core_IPS_Question__r.Core_IPS_Question__c ;
                return false;
                
            }
        }
        System.debug('requestHasAllRequiredFields ? ==>> '+requestHasAllRequiredFields );
        return requestHasAllRequiredFields;
    }
    
    // validation method to check user entered question is present in env details or not (checking required question and match it )
    @testVisible  private Boolean validateEnvDetailMatch(){
        
        Boolean envDetailMatch= true;
        Boolean isAnsValidate = true;
        for(Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper envdet : mRequestQuestionEnvDetail.values())
        {    
            boolean envDetailMatchTemp = false;
            System.debug('envdet.envDetQuestionId==>> '+envdet.envDetQuestionId);
            System.debug('mEnvDetailsAll.containsKey(envdet.envDetQuestionId) ====>> '+mEnvDetailsAll.containsKey(envdet.envDetQuestionId));
            System.debug('mEnvDetailsAll.containsKey(envdet.envDetQuestion) ====>> '+!mEnvDetailsAll.isEmpty());
            if(!mEnvDetailsAll.isEmpty()){
                
                if(mEnvDetailsAll.containsKey(envdet.envDetQuestionId) && (mEnvDetailsAll.get(envdet.envDetQuestionId).Core_IPS_Question__r.Core_IPS_Question__c == envdet.envDetQuestion) ){
                    
                    System.debug('inside question id and question is match ===>> ');
                    envDetailMatchTemp= true;
                    isAnsValidate = isAnsValidate && isAnsValidate(envdet, mEnvDetailsAll.get(envdet.envDetQuestionId), mQuestionAnswerAll.get(mEnvDetailsAll.get(envdet.envDetQuestionId).Core_IPS_Question__r.name));
                    
                }else{
                    envDetailMatchTemp=false;
                }
                
            }
            envDetailMatch = envDetailMatch && envDetailMatchTemp ;
            if(envDetailMatch == false){
                validationCode = INVALID_INPUT;  
                validationErrorMessage = '  envDetQuestion / envDetQuestionId '+envdet.envDetQuestion+' / '+envdet.envDetQuestionId; 
                break; 
            }
          }  
        
        System.debug(' envDetailMatch  result : '+envDetailMatch );
        System.debug(' isAnsValidate result : '+isAnsValidate );
        
        Boolean finalResult = (envDetailMatch && isAnsValidate ); //&& parentQuestionTemp );
        System.debug(' validateEnvDetailMatch result : '+finalResult);
        return finalResult;
    }    
    
    // Validate all Answers in the request.
    // checking validation for answer length , answer list size(answer is not more than one) and answer are valid or not
    @testVisible private Boolean isAnsValidate(Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper reqQuest , Core_IPS_Assigned_Environment_Variables__c envQuestDetail, map<String, Core_IPS_Answer__c> mEnvAns){
        System.debug(' isAnsValidate invoked to validate all answers  >> ');
        Boolean ansLstValidSize = true;
        Boolean ansValidation = true;
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstWrappAnswer = reqQuest.answers;
        system.debug('lstWrappAnswer  ==>> '+lstWrappAnswer );
        if(envQuestDetail.Core_IPS_Question__r.Core_IPS_Datatype__c == 'Text Area' ){
            
            // checking for answer is not more than one
            if(lstWrappAnswer.size() > 1){
                ansLstValidSize = false;
                validationCode = INVALID_INPUT_ANSWER ;
                validationErrorMessage = ' '+reqQuest.envDetQuestionId;
            }else{
                // checking for ans size is less than 5000
                for(Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                    system.debug('answerObj.answer ===>> '+answerObj.answer);
                    if(Core_RestAPI_Util.isMaxLengthExceeded(answerObj.answer, 5000) ){
                        ansValidation = false;
                        validationCode = MAX_LENGTH_EXCEEDED_9025;
                        validationErrorMessage = ' 5000 for Answer '+reqQuest.envDetQuestionId;
                    }
                }
            }
            
        }else If(envQuestDetail.Core_IPS_Question__r.Core_IPS_Datatype__c == 'Text'){
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
        }else If(envQuestDetail.Core_IPS_Question__r.Core_IPS_Datatype__c == 'Picklist'){
            
            system.debug('envQuestDetail.Core_IPS_Question__r.name ==>> '+envQuestDetail.Core_IPS_Question__r.name);   
            if(lstWrappAnswer.size() > 1){
                ansLstValidSize = false;
                validationCode = INVALID_INPUT_ANSWER ;
                validationErrorMessage = ' '+reqQuest.envDetQuestionId;
            }else{
                for(Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                    system.debug('inside new ans validation  ');
                    if(!((mEnvAns.containsKey(answerObj.answerId)) && (mEnvAns.get(answerObj.answerId).Core_IPS_Answer__c == answerObj.answer))){
                        ansValidation = false;
                        validationCode = INVALID_INPUT_ANSWER ;
                        validationErrorMessage = ' '+reqQuest.envDetQuestionId;
                    }
                }
            }
        }else if(envQuestDetail.Core_IPS_Question__r.Core_IPS_Datatype__c == 'Multiselect Picklist'){
            for(Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                system.debug('inside new ans validation  Multiselect Picklist');
                if(!((mEnvAns.containsKey(answerObj.answerId)) && (mEnvAns.get(answerObj.answerId).Core_IPS_Answer__c == answerObj.answer))){
                    ansValidation = false;
                    validationCode = INVALID_INPUT_ANSWER ;
                    validationErrorMessage = ' '+reqQuest.envDetQuestionId;
                }
            }
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