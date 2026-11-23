/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Case_CreateV1_Handler 
* Version     : 1.0 
* Created Date: 18 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/20/2018                RestAPI handler for validating the request and creating case
*****************************************************************************************************************************************/
public class Core_RestAPI_Case_CreateV1_Handler{
    
    private final String  REQ_FIELD_MISSING_9002 = '9002';
    private final String  MAX_LENGTH_EXCEEDED_9025 = '9025';
    private final String  INVALID_INPUT = '9011';
    private final String  INVALID_INPUT_ANSWER = '9012';
    private final String  INACTIVE_PRODUCT = '9015';
    private final String INACTIVE_PROJECT ='9016';
    private final String DUPLICATE_INPUTS = '9017';
    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_201 = '201';
    
    @testVisible private Core_RestAPI_Case_CreateV1_Wrapper requestWrpr = null;
    private Core_RestAPI_Response response = new Core_RestAPI_Response();
    private String validationErrorMessage = null;
    private String validationCode = null;
    private User runningUser = null;
    private Id catId = null;
    private Id subCatId = null;
    @testVisible private Asset assetObj = null;
    private Case newCaseObj = null;
    private DateTime entryTime = null;
    private String apiName = null;
    
    // List to get the list of all environment details
    private List<Core_IPS_Assigned_Environment_Variables__c> lstEnvDetails = null;
    
    // List to get all environment question and answers
    private List<Core_IPS_Question__c > lstAnswer = null;
    
    //Map<Question, Object> for all the REQUIRED environment details questions for the PRODUCT
    Map<String, Core_IPS_Assigned_Environment_Variables__c> mEnvDetailsRequired = new Map<String, Core_IPS_Assigned_Environment_Variables__c>();
    
    //Map<Question, Object> for all environment details questions for the PRODUCT
    Map<String, Core_IPS_Assigned_Environment_Variables__c> mEnvDetailsAll = new Map<String, Core_IPS_Assigned_Environment_Variables__c>();
    
    //Map<Question, Object> for all the environment details which are passed in api request
    Map<String, Core_RestAPI_Case_CreateV1_Wrapper.EnvQuestionWrapper> mRequestQuestionEnvDetail = new Map<String, Core_RestAPI_Case_CreateV1_Wrapper.EnvQuestionWrapper>();
    
    // map for all the question with map of answerId ans answer 
    Map<String , map<String, Core_IPS_Answer__c >> mQuestionAnswer = new Map<String , map<String, Core_IPS_Answer__c >>();
    
    public Core_RestAPI_Case_CreateV1_Handler(String apiname, DateTime entryTime, Core_RestAPI_Case_CreateV1_Wrapper argWrpr){
        this.runningUser = [Select ContactId, AccountId FROM User where Id =: UserInfo.getUserId()];
        this.requestWrpr = argWrpr;
        this.apiName = apiname;
        this.entryTime = entryTime;
    }
    
    //Create Case and return the caseNumber
    public Core_RestAPI_Response createCase(){
        System.debug('Core_RestAPI_Case_CreateV1_Handler createCase started processing request ');
        system.debug('requestWrpr ====== >>> '+requestWrpr);
        Savepoint sp = Database.setSavepoint();
        try{
            Boolean allValidationsPassed = ( doAllCaseValidations() && doAllEnvDetailValidations() );
            System.debug(' doAllCaseValidations passed ? >>> '+allValidationsPassed+' Validation code : '+validationCode + ' validationErrorMessage :'+validationErrorMessage);
            
            if(allValidationsPassed == false ){
                Core_RestAPI_Util.processException(null , validationCode, response, apiName, entryTime, requestWrpr);
                response.errorContent.errorMessage += validationErrorMessage;
            }else{    
                insertCase();
                insertEnvironmentDetails();   
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Core_RestAPI_Case_CreateV1_Handler Exception : ' + Core_RestAPI_Util.getExceptionAsString(e));
            Database.rollback(sp);        
            response.successContent = null;
            Core_RestAPI_Util.processException(e, ERROR_CODE_500, response, apiName, entryTime, requestWrpr);
        }finally{        
            if(String.isBlank(response.code)){
                response.code = SUCCESS_CODE_201;
            }
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        } 
        System.debug('Core_RestAPI_Case_CreateV1_Handler createCase processing request completed - final response :'+response);
        return response;
    }
    
    
    /******************************************** insert  Cases*****************************************************/
    //Insert the case, this will be called only if all validations passes
    public void insertCase(){
        System.debug('Create case started for the asset '+assetObj);
        
        Case newCase = new Case();
        newCase.status = 'New';
        newCase.assetId = requestWrpr.intelProductId ;
        newCase.Core_IPS_Project_Case__c  = (assetObj.Core_IPS_Project__c != null ? assetObj.Core_IPS_Project__c : null);
        newCase.Subject = requestWrpr.subject ;
        newCase.Core_Issue_Description__c = requestWrpr.caseDescription;
        newCase.Description = requestWrpr.caseDescription;
        newCase.Core_CaseType__c = requestWrpr.caseType;
        newCase.Core_Severity__c = requestWrpr.caseSeverity ;
        newCase.Core_Severity_Reason__c = requestWrpr.SeverityReason;
        newCase.Core_Customer_Reference_ID__c= requestWrpr.customerReferenceId ;
        newCase.Core_End_Customer__c = requestWrpr.endCustomer;
        newCase.RecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType Where SobjectType = 'Case' AND DeveloperName ='IPS_Case_Create'].Id;
        newCase.ContactId = runningUser.ContactId;
        newCase.AccountId = runningUser.AccountId; 
        newCase.Core_IPS_Supported_Product__c = assetObj.core_supported_product__c;        
        newCase.Origin = 'Web';
        newCase.Core_IPS_Issue_source__c = 'API'; 
        newCase.Core_IPS_Customer_Visible__c = true;
        newCase.productId = assetObj.product2Id;
        
        //category and subcategory
        newCase.Core_Case_Issue_Category__c = this.catId;
        newCase.Core_Case_Issue_Sub_Category__c = this.subCatId;
        
        insert newCase;
        newCaseObj = [SELECT Id, CaseNumber FROM Case where id =:newCase.Id];
        
        //Set the created cases 
        CaseWrapper cw = new CaseWrapper();
        cw.caseNumber = newCaseObj.CaseNumber;
        List<CaseWrapper> cwl = new List<CaseWrapper>();
        cwl.add(cw);
        response.successContent = cwl;
    }
    
    
    /******************************************** insert EnvironmentDetails STARTS*****************************************************/
    
    //Create Environment Details 
    public void insertEnvironmentDetails(){
        System.debug('insertEnvironmentDetails() started for envDetails from request'+requestWrpr.envDetails);
        List<Core_IPS_Response__c> envDetailsToCreate = new List<Core_IPS_Response__c>();
        Set<String> addedQuestions = new Set<String>();
        
        system.debug('mRequestQuestionEnvDetail.values() ==+>> '+mRequestQuestionEnvDetail.values());
        system.debug('request map size ==>> '+mRequestQuestionEnvDetail.size());
        if(requestWrpr.envDetails != null) {  
            for(Core_RestAPI_Case_CreateV1_Wrapper.EnvQuestionWrapper qa: mRequestQuestionEnvDetail.values()){
                system.debug('qa ==>> '+qa);
                System.debug('qa.envDetQuestion ===>> '+qa.envDetQuestion);
                for( Core_RestAPI_Case_CreateV1_Wrapper.AnsWrapper ans : qa.answers){
                    if(String.isNotBlank(qa.envDetQuestionId)){
                        System.debug('insertEnvironmentDetails()  if ==>>');
                        Core_IPS_Response__c detail = new Core_IPS_Response__c();
                        detail.Core_IPS_Case__c = newCaseObj.id;
                        
                        if(mEnvDetailsAll.containsKey(qa.envDetQuestionId)){
                            Core_IPS_Assigned_Environment_Variables__c tempQuest = mEnvDetailsAll.get(qa.envDetQuestionId);
                            system.debug('tempQuest.Core_IPS_Question__r.id ==>>> '+tempQuest.Core_IPS_Question__r.id);
                            detail.Core_IPS_Question_Master__c = tempQuest.Core_IPS_Question__r.id;
                        }
                        detail.Core_IPS_Answer__c = ans.answer;
                        
                        system.debug('123 mEnvDetailsAll ===>> '+mEnvDetailsAll);
                        system.debug('123 qa.envDetQuestionId===>> '+qa.envDetQuestionId);
                        
                        system.debug('mEnvDetailsAll.get(qa.envDetQuestionId).Core_IPS_Question__r.Core_IPS_Datatype__c ====>> '+mEnvDetailsAll.get(qa.envDetQuestionId).Core_IPS_Question__r.Core_IPS_Datatype__c);
                        if(mEnvDetailsAll.get(qa.envDetQuestionId).Core_IPS_Question__r.Core_IPS_Datatype__c == 'Picklist' || mEnvDetailsAll.get(qa.envDetQuestionId).Core_IPS_Question__r.Core_IPS_Datatype__c == 'Multiselect Picklist'){
                            system.debug('answer id ===>> '+ mQuestionAnswer.get(qa.envDetQuestionId).get(ans.answerId).id);
                            detail.Core_IPS_Answer_Master__c= mQuestionAnswer.get(qa.envDetQuestionId).get(ans.answerId).id;
                        }
                        
                        envDetailsToCreate.add(detail);
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
                    detail.Core_IPS_Case__c = newCaseObj.id;
                    detail.Core_IPS_Question_Master__c = suppProdEnv.Core_IPS_Question__r.id;
                    detail.Core_IPS_Answer__c = '';
                    detail.Core_IPS_Answer_Master__c=null;
                    envDetailsToCreate.add(detail);
                }
            }
        }
        insert envDetailsToCreate;
    }
    /*********************************************************Create Environment Details ENDS**************************************************/
    
    /******************************************************* Case field validations START ***************************************************/  
    public Boolean doAllCaseValidations(){
        //Validation create object accessibility
        Boolean isCreatable = Schema.sObjectType.Case.isCreateable();
        System.debug(' doAllCaseValidations started \n CreateAccess ? '+isCreatable);
        //Perform validations as per the following order
        //1. CRUD validations
        //2. Required field validations to see is all inputs exist which require for creating a case
        //3. sharing access - validate lookup fields are accessible
        //4. Validate input, eg. input is valid if it is pick list value
        //IMPORTANT NOTE - Do not change the order of the validations
        //return ( isCreatable && validateCaseRequiredFields() && (isProductIdValid() || isProjectIdValid() ) && validateCaseFieldValues() && validateCaseCategoryFields()  ) ;
        Boolean result = ( isCreatable && validateCaseRequiredFields() && isProductOrProjectValid() && validateCaseInputs() && validateCaseCategoryFields()  ) ;
        System.debug(' doAllCaseValidations result : '+result);
        return result;
    }
    
    //Validate the product is valid.
    public Boolean isProductOrProjectValid(){
        Boolean productValid = true;
        List<Asset> allAssets  = [Select Id, core_supported_product__c, core_supported_product__r.Name, product2Id, Status, Core_IPS_Project__c, Core_IPS_Project__r.Name, Core_IPS_Project__r.Core_Status__c, core_supported_product__r.Core_EOIS__c 
                                  FROM Asset WHERE Id =:requestWrpr.intelProductId];
        if(allAssets.size() > 0){
            assetObj = allAssets.get(0);
        }
        
        if(assetObj == null) {
            validationCode = INVALID_INPUT;
            validationErrorMessage = ', intelProductId '+requestWrpr.intelProductId;    
            productValid = false;
        }else if( assetObj.Status != 'Active')  {
            validationCode = INACTIVE_PRODUCT;
            validationErrorMessage = ' '+requestWrpr.intelProductId;     
            productValid = false;
        }else if(assetObj.core_supported_product__r.Core_EOIS__c == true){
            validationCode = INACTIVE_PRODUCT;
            validationErrorMessage = ' '+requestWrpr.intelProductId;     
            productValid = false;
            
        }else if(String.isNotBlank(assetObj.Core_IPS_Project__c ) && assetObj.Core_IPS_Project__r.Core_Status__c  != 'Active'){
            validationCode = INACTIVE_PROJECT;
            validationErrorMessage = ' '+requestWrpr.intelProductId;     
            productValid = false;
        }
        System.debug(' isProductIdValid >>> '+productValid+' validationErrorMessage :'+validationErrorMessage);
        return productValid;
    }
    
    //Validate the input fields are allowed/valid for the SF fields
    public Boolean validateCaseInputs(){
        Boolean flag = true;
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
        }else if(String.isBlank(requestWrpr.intelProductId)){
            validationCode = REQ_FIELD_MISSING_9002;
            validationErrorMessage = 'intelProductId';  
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
        System.debug('assetObj 1234 ===>> '+assetObj);
        System.debug('assetObj.core_supported_product__c ===>> '+assetObj.core_supported_product__c);
        for(Core_IPS_Product_Issue_Category__c cat : [Select Name,  Core_Issue_Category_Name__r.Name,  
                                                      (Select Name, Core_Issue_Category_Name__c, Core_Issue_Sub_Category_Name__c, Core_Product_Issue_Category__c, 
                                                       Core_Supported_Product__c, Core_Type__c, Core_Issue_Sub_Category_Name__r.Name
                                                       From Product_Issue_Sub_Categories__r where Core_Status__c='Active') 
                                                      From Core_IPS_Product_Issue_Category__c c 
                                                      WHERE Core_Status__c ='Active' AND Core_Supported_Product__c =: assetObj.core_supported_product__c Limit 2000]) //AND Name =: requestWrpr.caseCategoryId 
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
        system.debug('inside else condition no sub cat id  ');
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
        lstEnvDetails = [SELECT Core_IPS_Question__r.name, Core_IPS_Question__r.id, Core_IPS_Question__r.Core_IPS_Parent_Question__r.name,Core_IPS_Question__r.Core_IPS_Datatype__c, Core_IPS_Question__r.Core_IPS_Question__c,  Core_Required__c
                         FROM Core_IPS_Assigned_Environment_Variables__c 
                         WHERE (Core_Supported_Product__c  =: assetObj.core_supported_product__c OR (Core_Product_Issue_Sub_Category__r.Name=: requestWrpr.subCategoryId AND Core_Product_Issue_Sub_Category__r.Name != null)) AND Core_Agent_Only__c = false AND Core_Status__c='Active' ];
        System.debug('lstEnvDetails -->'+lstEnvDetails );
        
        //  code for check duplicate question 
        system.debug('requestWrpr.EnvDetails ===> '+requestWrpr.EnvDetails);
        if(requestWrpr.EnvDetails != null && !requestWrpr.EnvDetails.isEmpty() ){
            for( Core_RestAPI_Case_CreateV1_Wrapper.EnvQuestionWrapper wrpr :  requestWrpr.EnvDetails)        {
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
            System.debug('mRequestQuestionEnvDetail size ===>>> '+mRequestQuestionEnvDetail.size());
            System.debug('mRequestQuestionEnvDetail===>>> '+mRequestQuestionEnvDetail);
        }
        
        //Product & SubCategory does not have any environment details defined but request has, throw the validation message
        if(( lstEnvDetails == null || ( lstEnvDetails != null && lstEnvDetails .isEmpty() ) )  
           && !mRequestQuestionEnvDetail.isEmpty())
        {
            validationCode = INVALID_INPUT;
            validationErrorMessage = ' envDetails ' ;
            return false;
        }
        
        if(lstEnvDetails != null){
            for(Core_IPS_Assigned_Environment_Variables__c prodEnvDet : lstEnvDetails ){
                if(prodEnvDet.Core_Required__c == true && String.isNotBlank(prodEnvDet.Core_IPS_Question__r.Core_IPS_Question__c)){
                    mEnvDetailsRequired.put(prodEnvDet.Core_IPS_Question__r.Name, prodEnvDet);
                }
                mEnvDetailsAll.put(prodEnvDet.Core_IPS_Question__r.Name, prodEnvDet);
            }
        }
        
        for(Core_IPS_Assigned_Environment_Variables__c  objEnv :lstEnvDetails ){
            questionId.add(objEnv.Core_IPS_Question__c);
        }
        lstAnswer = [SELECT Name , Core_IPS_Question__c ,Core_IPS_Parent_Question__r.name , Core_IPS_Datatype__c ,
                     (select id ,name , Core_IPS_Answer__c , Core_IPS_Question__r.name from Core_Answers__r WHERE Core_IPS_Status__c = 'Active') 
                     FROM Core_IPS_Question__c where id  IN : questionId AND Core_IPS_Status__c = 'Active'];
        
        System.debug('lstAnswer -->'+lstAnswer );
        
        for(Core_IPS_Question__c quest: lstAnswer ){
            String ques = ( quest.Name != null ? quest.Name.trim(): '');
            map<String, Core_IPS_Answer__c > ansIdDetails= new map<String, Core_IPS_Answer__c >();
            for(Core_IPS_Answer__c ans1 : quest.Core_Answers__r){
                system.debug('ans1  ==>> '+ans1 );
                
                ansIdDetails.put(ans1.name ,ans1 );
            }
            mQuestionAnswer.put(ques ,ansIdDetails);
        }
        
        System.debug('mEnvDetailsRequired ===>> '+mEnvDetailsRequired );
        System.debug('mEnvDetailsAll  ===>> '+mEnvDetailsAll );
        System.debug('mQuestionAnswer ===>> '+mQuestionAnswer);
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
        if(mEnvDetailsRequired.size() > 0  && mRequestQuestionEnvDetail.size() == 0){
            System.debug('inside all blank list condition ');
            validationCode = REQ_FIELD_MISSING_9002; 
            validationErrorMessage = ' envDetails' ;
            return false;
        }
        
        //PRODUCT : Verify request has all the required environmental details passed
        for(Core_IPS_Assigned_Environment_Variables__c prodEnvDet : mEnvDetailsRequired.values()){
            System.debug('mRequestQuestionEnvDetail  ===>> '+mRequestQuestionEnvDetail);
            System.debug('prodEnvDet.Core_IPS_Question__r.Core_IPS_Question__c  ===>> '+prodEnvDet.Core_IPS_Question__r.Core_IPS_Question__c);
            if(mRequestQuestionEnvDetail.get(prodEnvDet.Core_IPS_Question__r.name) == null){
                validationCode = REQ_FIELD_MISSING_9002;
                validationErrorMessage = ' envDetails '+prodEnvDet.Core_IPS_Question__r.name +' '+prodEnvDet.Core_IPS_Question__r.Core_IPS_Question__c ;
                return false;
            }
        }
        System.debug('requestHasAllRequiredFields ? ==>> '+requestHasAllRequiredFields );
        return requestHasAllRequiredFields;
    }
    
    // validation method to check user entered question is present in subCat env details/product or not (checking required question and match it )
    @testVisible  private Boolean validateEnvDetailMatch(){
        Boolean envDetailMatch= true;
        Boolean isAnsValidate = true;
        
        for(Core_RestAPI_Case_CreateV1_Wrapper.EnvQuestionWrapper envdet : mRequestQuestionEnvDetail.values())
        {    
            boolean envDetailMatchTemp = false;
            System.debug('envdet.envDetQuestionId==>> '+envdet.envDetQuestionId);
            
            system.debug('mEnvDetailsAll.containsKey(envdet.envDetQuestionId) ====>> '+mEnvDetailsAll.containsKey(envdet.envDetQuestionId));
            system.debug('mEnvDetailsAll.containsKey(envdet.envDetQuestion) ====>> '+!mEnvDetailsAll.isEmpty());
            if(!mEnvDetailsAll.isEmpty()){
                
                if(mEnvDetailsAll.containsKey(envdet.envDetQuestionId) && (mEnvDetailsAll.get(envdet.envDetQuestionId).Core_IPS_Question__r.Core_IPS_Question__c == envdet.envDetQuestion) ){
                    
                    system.debug('inside question id and question is match ===>> ');
                    envDetailMatchTemp= true;
                    isAnsValidate = isAnsValidate && isAnsValidate(envdet, mEnvDetailsAll.get(envdet.envDetQuestionId), mQuestionAnswer.get(mEnvDetailsAll.get(envdet.envDetQuestionId).Core_IPS_Question__r.name));
                    
                }else{
                    envDetailMatchTemp=false;
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
           }   
        Boolean finalResult = (envDetailMatch && isAnsValidate );  //&& parentQuestionTemp );
        System.debug(' validateEnvDetailMatch result : '+finalResult);
        return finalResult;
        
    }
    // Validate all Answers in the request.
    // checking validation for answer length , answer list size(answer is not more than one) and answer are valid or not
    @testVisible private Boolean isAnsValidate(Core_RestAPI_Case_CreateV1_Wrapper.EnvQuestionWrapper reqQuest , Core_IPS_Assigned_Environment_Variables__c envQuestDetail, map<String, Core_IPS_Answer__c > mEnvAns){
        System.debug(' isAnsValidate invoked to validate all answers  >> ');
        Boolean ansLstValidSize = true;
        Boolean ansValidation = true;
        
        system.debug('mEnvAns ==>> '+mEnvAns );
        system.debug('envQuestDetail.Core_IPS_Question__r.Core_IPS_Datatype__c ==>> '+envQuestDetail.Core_IPS_Question__r.Core_IPS_Datatype__c);
        
        List<Core_RestAPI_Case_CreateV1_Wrapper.AnsWrapper> lstWrappAnswer = reqQuest.answers;
        system.debug('lstWrappAnswer  ==>> '+lstWrappAnswer );
        if(envQuestDetail.Core_IPS_Question__r.Core_IPS_Datatype__c == 'Text Area' ){
            
            // checking for answer is not more than one
            if(lstWrappAnswer.size() > 1){
                system.debug('inside text area ans  size > 1');
                ansLstValidSize = false;
                validationCode = INVALID_INPUT_ANSWER ;
                validationErrorMessage = ' '+reqQuest.envDetQuestionId;
            }else{
                // checking for ans size is less than 5000
                for(Core_RestAPI_Case_CreateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
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
                system.debug('inside text ans  size > 1');
                ansLstValidSize = false;
                validationCode = INVALID_INPUT_ANSWER ;
                validationErrorMessage = ' '+reqQuest.envDetQuestionId;
            }else{
                for(Core_RestAPI_Case_CreateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                    system.debug('answerObj.answer ===>> '+answerObj.answer);
                    if(Core_RestAPI_Util.isMaxLengthExceeded(answerObj.answer, 255)){
                        ansValidation = false;
                        validationCode = MAX_LENGTH_EXCEEDED_9025;
                        validationErrorMessage = ' 255 for Answer '+reqQuest.envDetQuestionId;
                    }
                }
            }
        }else If(envQuestDetail.Core_IPS_Question__r.Core_IPS_Datatype__c == 'Picklist'){
            
            if(lstWrappAnswer.size() > 1){
                ansLstValidSize = false;
                validationCode = INVALID_INPUT_ANSWER ;
                validationErrorMessage = ' '+reqQuest.envDetQuestionId;
            }else{
                for(Core_RestAPI_Case_CreateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                    system.debug('inside new ans validation  ');
                    if(!((mEnvAns.containsKey(answerObj.answerId)) && (mEnvAns.get(answerObj.answerId).Core_IPS_Answer__c == answerObj.answer))){
                        ansValidation = false;
                        validationCode = INVALID_INPUT_ANSWER ;
                        validationErrorMessage = ' '+reqQuest.envDetQuestionId;
                    }
                }
            }
        }else if(envQuestDetail.Core_IPS_Question__r.Core_IPS_Datatype__c == 'Multiselect Picklist'){
            for(Core_RestAPI_Case_CreateV1_Wrapper.AnsWrapper answerObj: lstWrappAnswer){
                system.debug('inside new ans validation  Multiselect Picklist');
                if(!((mEnvAns.containsKey(answerObj.answerId)) && ((mEnvAns.get(answerObj.answerId).Core_IPS_Answer__c) == answerObj.answer))){
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
        public String caseNumber {get;set;}
    }
    
}