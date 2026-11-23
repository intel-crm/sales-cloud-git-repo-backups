//TODO chnage all the method to private except createCase()
public class SKTemp_createcase {
    private static final String  REQ_FIELD_MISSING = 'Missing required field ';
    
    public String caseIPSRecTypeId = null;
    private Core_RestAPI_Case_CreateV1_Wrapper requestWrpr = null;
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    private String validationErrorMessage = null;
    private User runningUser = null;
    private Id catId = null;
    private Id subCatId = null;
    private Asset assetObj = null;
    private Core_IPS_Project__c ipsProj = null;
    
    public SKTemp_createcase(Core_RestAPI_Case_CreateV1_Wrapper argWrpr){
        this.caseIPSRecTypeId  = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType Where SobjectType = 'Case' AND DeveloperName ='IPS_Case_Create'].Id;
        this.runningUser = [Select ContactId, AccountId FROM User where Id =: UserInfo.getUserId()];
        this.requestWrpr = argWrpr;
    }
    
     //Create Case and return the caseNumber
    public Core_RestAPI_Response createCase(){
        //system.debug('inside createCase()');
        Savepoint sp = Database.setSavepoint();
        try{
            Boolean allCaseValidationsPassed = doAllCaseValidations();
            system.debug(' doAllCaseValidations passed ? >>> '+allCaseValidationsPassed);
            if(allCaseValidationsPassed == false){
                response.isSuccess = false;
                response.errorContent = new Core_RestAPI_ErrorContent();
                response.code = '500';
                response.errorContent.errorMessage = validationErrorMessage;
                return response;
            }
            // system.debug('allCaseValidationsPassed ==>> '+allCaseValidationsPassed );
            Case newCase = new Case();
            newCase.status = 'New';
            if(String.isNotBlank(requestWrpr.ipsProjectId)){
            	newCase.Core_IPS_Project_Case__c =  requestWrpr.ipsProjectId;    
            }
            newCase.assetId = requestWrpr.intelProductAssetId ;
            newCase.Subject = requestWrpr.subject ;
            newCase.Description = requestWrpr.caseDescription;
            newCase.Core_CaseType__c = requestWrpr.caseType;
            newCase.Core_Severity__c = requestWrpr.caseSeverity ;
            newCase.Core_Severity_Reason__c = requestWrpr.SeverityReason;
            newCase.Core_Customer_Reference_ID__c= requestWrpr.customerReferenceId ;
            newCase.Core_End_Customer__c = requestWrpr.endCustomer;
            newCase.RecordTypeId = caseIPSRecTypeId;
            newCase.ContactId = runningUser.ContactId;
            newCase.AccountId = runningUser.AccountId; 
            newCase.Core_IPS_Supported_Product__c = assetObj.core_supported_product__c;
            newCase.Origin ='Web';
            newCase.Core_IPS_Issue_source__c = 'API'; 
            newCase.Core_IPS_Customer_Visible__c = true;
            newCase.productId = assetObj.product2Id;
            
            
            //category and subcategory
            newCase.Core_Case_Issue_Category__c = this.catId;
            newCase.Core_Case_Issue_Sub_Category__c = this.subCatId;
            insert newCase;
            
            CaseWrapper cw = new CaseWrapper();
            cw.caseNumber = [SELECT Id, CaseNumber FROM Case where id =:newCase.Id].CaseNumber;
            List<CaseWrapper> cwl = new List<CaseWrapper>();
            cwl.add(cw);
            response.successContent = cwl;
            
            //Validate all the environment details
            Boolean allEnvDetailValidationsPassed = doAllEnvDetailValidations();
            if(allCaseValidationsPassed == false){
                response.isSuccess = false;
                response.errorContent = new Core_RestAPI_ErrorContent();
                response.code = '500';
                response.errorContent.errorMessage = validationErrorMessage;
                return response;
            }
            //TODO Nikhil : add code to insert the environment details
            ///Insert environment details
            // Environemnt variables insertintion case.Id, assetid, subcat.id, - Nikhil 
            //createEnvironmentDetails()
        }catch(Exception e){
            system.debug('inside catch '+e);
            Database.rollback(sp);
            //NOTE - Logging records should proceed
            //RollBACK to save point
            //TODO
            //Logging
            Core_RestAPI_Util.processException(e, '500', response, 'CreateCase', System.now());
            response.errorContent.errorMessage = response.errorContent.errorMessage +'  Message '+e.getMessage()+'  StackTrace '+e.getStackTraceString();
        }finally{
            Core_RestAPI_LoggingUtil.logTransaction(System.now(), response);
        }
        
        return response;
    }
    
    //Create Environment Details 
    public void createEnvironmentDetails(String caseId, Id assetid, Id subCatid ){
        //Read environment details from wrapperclass 
        
    }
    /******************************************************* Case field validatoins START ***************************************************/  
    public Boolean doAllCaseValidations(){
        //Validation create object accessibility
        Boolean isCreatable = Schema.sObjectType.Case.isCreateable();
        System.debug(' doAllCaseValidations started \n CreateAccess ? '+isCreatable);
        //Perform validations as per the following order
        //1. CRUD accessibility
        //2. Required field validations to see is all inputs exist which require for creating a case
        //3. sharing access - validate lookup fields are accessible
        //4. Validate input, eg. input is valid if it is pick list value
        //IMPORTANT NOTE - Do not change the order of the validations
        return ( isCreatable && validateCaseRequiredFields() && ( isProductIdValid() || isProjectIdValid() ) &&   validateCaseFieldValues() &&  validateCaseCategoryFields()  ) ;
    }
    
    //Validate the product is valid.
    public Boolean isProductIdValid(){
        Boolean productValid = false;
        for(Asset a : [Select Id, core_supported_product__c, core_supported_product__r.Name, product2Id FROM Asset WHERE Id =:requestWrpr.intelProductAssetId ]){
            assetObj = a;
            productValid = true;
            break;
        }
        validationErrorMessage = (assetObj == null) ? 'Product id '+requestWrpr.intelProductAssetId+' is invalid or not accessible' : '';
        System.debug(' isProductIdValid >>> '+productValid);
        return productValid;
    }
    
    //If project Id is Blank contact should be blank
    private Boolean isProjectIdValid(){
        Boolean projectValid = false;
        for(Core_IPS_Project__c ip : [Select Id FROM Core_IPS_Project__c WHERE Id =:requestWrpr.ipsProjectId ]){
            ipsProj = ip;
            projectValid = true;
            break;
        }
        validationErrorMessage = (ipsProj == null) ? 'Project id '+requestWrpr.ipsProjectId+' is invalid or not accessible' : '';
        System.debug(' isProjectIdValid >>> '+projectValid);
        return projectValid;
    }

    
    //Validate the input fields are allowed/valid for the SF fields
    public Boolean validateCaseFieldValues(){
        Boolean flag = true;
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
            validationErrorMessage = 'Invalid Case Type '; 
            flag = false;
        }else if(String.isNotBlank(requestWrpr.caseSeverity) && !picklistSeverity.contains(requestWrpr.caseSeverity)){
            validationErrorMessage = 'Invalid Case severity '; 
            flag = false;
        }
        
        System.debug(' validateCaseFieldValues >>> '+flag);
        return flag;
    }
    
    //Validate the required fields
    private Boolean validateCaseRequiredFields(){
        Boolean flag = true;
        if (String.isBlank(requestWrpr.subject) ){
            validationErrorMessage = REQ_FIELD_MISSING + 'Subject' ;  
            flag = false;
        }else if (String.isBlank(requestWrpr.caseDescription)) {
            validationErrorMessage = REQ_FIELD_MISSING +  'Case Description' ;  
            flag = false;
        }else if (String.isBlank(requestWrpr.caseType) ) {
            validationErrorMessage = REQ_FIELD_MISSING +  'Case Type' ;  
            flag = false;
        }else if(String.isBlank(requestWrpr.caseSeverity)) {
            validationErrorMessage = REQ_FIELD_MISSING + 'case severity ';  
            flag = false;
        }else if(String.isNotBlank(requestWrpr.caseSeverity) && 'Critical'.equalsIgnorecase(requestWrpr.caseSeverity) && String.isBlank(requestWrpr.SeverityReason)){
            validationErrorMessage = REQ_FIELD_MISSING + 'case severity reason ';  
            flag = false;
        }else if(String.isBlank(requestWrpr.ipsProjectId) && String.isBlank(requestWrpr.intelProductAssetId)){
            validationErrorMessage = 'Either ipsProjectId or intelProductAssetId required for creating the case.';  
            flag = false;
        }else if(String.isNotBlank(requestWrpr.ipsProjectId) && String.isNotBlank(requestWrpr.intelProductAssetId)){
            validationErrorMessage = 'Either ipsProjectId or intelProductAssetId required for creating the case but not both, please try removing one.';  
            flag = false;
        }
        System.debug(' validateCaseRequiredFields >>> '+flag);
        return flag;
    }
    
    //Validate both Case categories and sub categories
    public Boolean validateCaseCategoryFields(){
        //Boolean flag = true;  
        //Map holds the categories as Keys and all the sub categories as a set
        Boolean categoryValid = false;
        Boolean subCategoryValid = false;
        Boolean noCategories = true;
        
        //Query all the categories and sub categories for the product
        for(Core_IPS_Product_Issue_Category__c cat : [Select c.Name,  Core_Issue_Category_Name__r.Name,  
                                                      (Select Name, Core_Issue_Category_Name__c, Core_Issue_Sub_Category_Name__c, Core_Product_Issue_Category__c, 
                                                       Core_Supported_Product__c, Core_Type__c, Core_Issue_Sub_Category_Name__r.Name
                                                       From Product_Issue_Sub_Categories__r) 
                                                      From Core_IPS_Product_Issue_Category__c c 
                                                      WHERE Core_Supported_Product__r.Name =: assetObj.core_supported_product__r.Name  Limit 2000]) //AND Core_Issue_Category_Name__r.Name =:requestWrpr.caseCategory
        {
            noCategories = false;
            Set<String> sSubCat = new Set<String>();
            system.debug(' validateCaseCategoryFields case categories >>>> '+cat.Name + ' > '+cat.Core_Issue_Category_Name__r.Name);
            this.catId = cat.Id;
            categoryValid = true;
            for(Core_IPS_Product_Issue_Category__c subCat : cat.Product_Issue_Sub_Categories__r){
                system.debug(' validateCaseCategoryFields case sub categories >>>>>>>>>>>>>>>>>>>> '+cat.Name + ' > '+subCat.Core_Issue_Sub_Category_Name__r.Name);
                if(requestWrpr.caseSubCategory == subCat.Core_Issue_Sub_Category_Name__r.Name){
                    subCategoryValid = true;
                    this.subCatId = subCat.Id;
                    break;
                }
            }
        }
        
        if(categoryValid == false){
            validationErrorMessage = ' Invalid case category ';  
        }else if(subCategoryValid == false){
            validationErrorMessage = ' Invalid case sub category ';  
        }
        if(noCategories == true && (String.isNotBlank(requestWrpr.caseCategory) || String.isNotBlank(requestWrpr.caseSubCategory) ) )
           validationErrorMessage = 'product do not have any categories or subcategories.';  
           
        System.debug(' validateCaseCategoryFields  >>> categoryValid :'+categoryValid+' subCategoryValid:'+subCategoryValid+' noCategories > '+noCategories);
        return ( noCategories || (categoryValid && subCategoryValid ));
    }
    
    
 	/******************************************************* Case field validatoins End ***************************************************/  
	/******************************************************* Environment detail field validations START ***************************************************/    
    public Boolean doAllEnvDetailValidations(){
        //TODO Nikhil- note- separate all the validations to different methods 
        return (validateEnvDetailRequiredFields() && validateEnvDetailFieldValues());
    }
    
    
    public Boolean validateEnvDetailRequiredFields(){
        //TODO Nikhil
        return true;
    }
    public Boolean validateEnvDetailFieldValues(){
        //TODO Nikhil
        return true;
    }

    /******************************************************* Environment detail field validations END ***************************************************/    
    
    public class CaseWrapper implements Core_RestAPI_SuccessContent{
        public String caseNumber {get;set;}
    }
}