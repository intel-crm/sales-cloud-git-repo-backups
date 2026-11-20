/****************************************************************************************************
*Class Name:  Core_IPS_Case_Clone_Controller
*Description:  Controller Core_IPS_CaseClone VF
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------                 
* Amritesh                    12/18/2017                  Modified US85344,US101112 I7
****************************************************************************************************/
public with sharing class Core_IPS_Case_Clone_Controller{
    public Id productId{get;set;}
    public boolean DisplayPriorityReason {get;set;}
    public list<Asset> ast = new list<Asset>();
    public Asset getast()
    {
        Asset assetRec = new Asset();
        If(!ast.isEmpty())
            assetRec = ast[0];   
        
        return assetRec;
    }
    public List<Core_IPS_Environment_Details__c> showenvDetials = new List<Core_IPS_Environment_Details__c>();
    public List<Core_IPS_Environment_Details__c> getshowenvDetials()
    {
        return showenvDetials;
    }
    public Case cs{get;set;}
    public Case cloneCase{get;set;}
    public boolean isAgent{get;set;}
    public boolean displayEnvDetails{get;set;}
    public String categorySelected{get; set;}
    public String categorySelectedname{get;set;}
    public string ProjectName{get;set;}
    public String subcategorySelectedname{get;set;}
    public String subCategorySelected{get; set;} 
    public List<SelectOption> categoryOptions{get;set;} 
    public List<SelectOption> subCategoryOptions{set;get;}
    public boolean displayCategories{get;set;}
    public boolean displaySubCategories{get;set;}
    public boolean renderErrorFlag{get;set;}   
    public boolean rerenderFlag{get;set;}
    public boolean eoisFlag{get;set;}
    public integer intSubCategorySize = 0;
    public List<Core_IPS_EnvironmentDetailQuestion> envDetails{set;get;} //modified by amritesh 12/18/2017 - US85344,US101112 
    public List<Core_IPS_EnvironmentDetailQuestion> subCatEnvDetails{set;get;} //added by amritesh 12/18/2017 - US85344,US101112 
    //public List<EnvironmentDetail> envDetList{get;set;} //commented by amritesh 12/18/2017 - US85344,US101112 
    //Start--15/07/2019--Aniket--Removed unused variables
    //public boolean isMAG{get;set;}
    //End--15/07/2019--Aniket--Removed unused variables
    public boolean isGec{get;set;}
    public boolean externalUser{get;set;}{externalUser=Network.getNetWorkid()!= null? True:false;} // <!--Added by Geetha as per user story US92077-->
    //US108800 :Add Product Variant to Copy Case
    public List<List<SelectOption>> variantsList{get;set;}
    public String selectedProductId{get;set;}
    public Boolean blnShowVariant{get;set;}
    public String selectedVariant{get;set;} 
    //US108800
    public Boolean isPartnerFAE{get;set;}//US108521 Add PSO/PSA to Case when copying a case
    public Boolean isAgentPartner{get;set;}//US108521 Add PSO/PSA to Case when copying a case
    public String selectedAccountId{get;set;}//US108521 Add PSO/PSA to Case when copying a case
    public List<SelectOption> IPSParentAccountList{get;set;}//US108521 Add PSO/PSA to Case when copying a case
    public Boolean isNACCase{get;set;}                              //added by Aayushi US126300
    public Boolean custVisible{get;set;}                            //added by Aayushi US126300
    
    //Start--US343456--Aniket--MINDS Case Creation
    public Boolean isMindsFlag{get;set;}
    public String selectedCountry{get;set;}
    public List<SelectOption> countryOptions {get; set;}
    List<Contact> contactInContext = new List<Contact>();
    
    //End--US343456--Aniket--MINDS Case Creation
    
    public Core_IPS_Case_Clone_Controller(ApexPages.standardController controller){
        List<Core_IPS_Supported_product__c> sProd;
        displayEnvDetails = false;
        eoisFlag =false;
        isGEC = false;
        //Start--15/07/2019--Aniket--Removed unused variables
        //isMag = false;
        //End--15/07/2019--Aniket--Removed unused variables
        User u = [select Id, username,userType,ContactId,AccountId,profileid from User where Id = :UserInfo.getUserId()];
        //Start--US343456--Aniket--MINDS Case Creation
        isMindsFlag = false;
        contactInContext = [Select id, Name,Core_MINDS__c,Core_Country_Region__c  from Contact where id=: u.Contactid limit 1];
        if(contactInContext!=null && !contactInContext.isEmpty()) {
            if(isMindsFlag!=NULL){
                isMindsFlag = contactInContext[0].Core_MINDS__c;
            }            
            if(contactInContext[0].Core_Country_Region__c!=NULL || contactInContext[0].Core_Country_Region__c!=''){
                selectedCountry = contactInContext[0].Core_Country_Region__c ;
            }
        }
        //End--US343456--Aniket--MINDS Case Creation
        //US108521 Add PSO/PSA to Case when copying a case
        isPartnerFAE = (Core_Utility.getPartnerUserType(userinfo.getuserId())).contains('Partner - DFAE');
        //Commented because,deleting the Core_IPS_Customer_Case_Controller.US:TWC745-5417
       // isAgentPartner = Core_IPS_Customer_Case_Controller.isPartnerAgentUser();//Change it to agent partner check 
            isAgentPartner =false;
        eoisFlag =false;
        if(u != null)
        {
            
            if(u.userType== Label.Core_IPS_CustCommPlus_UserType || (Label.Core_Partner_Profile_Id).contains((u.profileId+'').substring(0,15))){
                isAgent=false;
            }else{
                isAgent=true;
            }
        }
        String csId = controller.getId(); 
            // Unencoded Formulas in Script Tags XSS Fix - TWC745-7251
        csId = ApexPages.currentPage().getParameters().get('id')?.escapeHtml4();
        if(csId==null){
            
            cs = new Case();
        }else{        
                        
            cs= getCase_DynamiCSOQL(csId);
             
            if(cs !=null)
            {            
                cloneCase = cs.clone(false, true, false, false);
                //Start--15/07/2019--Aniket--Removed unused variables
                //isMAG = cs.Account.Core_Military_Aerospace_and_Government__c;
                //End--15/07/2019--Aniket--Removed unused variables
                //cloneCase.Subject=null; Ashutosh - US103890 - Adding prefix in subject
                String prefixString = '(Copy Of '+cs.CaseNumber+') ';
                cloneCase.Subject = prefixString + cloneCase.Subject;
                cloneCase.Core_IPS_Customer_Visible__c=cs.Core_IPS_Customer_Visible__c;
                cloneCase.Core_CaseType__c = cs.Core_CaseType__c;
                selectedVariant = cloneCase.Core_Product_Variant__c;//CODE US108800
                selectedProductId = cloneCase.assetId;// US108800
                custVisible=cs.Core_IPS_Customer_Visible__c;            //added by Aayushi US126300
                //PSA Field US108521
                if(isPartnerFAE|| isAgentPartner){
                    IPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(cs.Core_IPS_Project_Case__c,userinfo.getUserId()); //retrieve the PSA 's
                }
                
                //start added by Aayushi US126300
                if(cs.Core_IPS_Issue_source__c==Label.Core_IPS_Legacy_PSG){
                 cloneCase.Core_IPS_Issue_source__c=Label.Core_IPS_CaseSource_Val_for_Legacy_PSG;  
                }//end
                //cloneCase.Core_IPS_GEC_Flag__c = cs.Core_IPS_GEC_Flag__c;Ashutosh - US 103890 - not copy GEC flag
                /**DE47491 --- Commented out GEC Status and setting it as Blank --- to fix incorrect Queue routing issue--post submit logic will be taken care in trigger**/
                //cloneCase.Core_IPS_GEC_Status__c = cs.Core_IPS_GEC_Status__c;
                cloneCase.Core_IPS_GEC_Status__c = '';
                /**DE47491 ---**/ 
                //cloneCase.Core_Issue_Description__c = null; Ashutosh - US 103890 - Adding prefix in description
                String prefixDesc = '**Copied From Case '+cs.CaseNumber+'<br>';
                cloneCase.Core_Issue_Description__c = prefixDesc+cloneCase.Core_Issue_Description__c;
                if(cs.Recordtype.DeveloperName == 'IPS_GEC_ReadOnly')
                { 
                    isGEC = true;
                }
                if(u.userType==Label.Core_IPS_CustCommPlus_UserType)
                {
                    cloneCase.ContactId = u.ContactId;
                    cloneCase.AccountId = u.AccountId;
                }
                else
                {
                    cloneCase.ContactId = cs.ContactId;
                    cloneCase.AccountId = cs.AccountId;
                }
                cloneCase.Core_Severity__c= null;
                cloneCase.Status = null; 
                cloneCase.ParentId = cs.Id;
                ProjectName = cloneCase.Core_IPS_Project_Case__r.Name;
                categorySelectedname = cloneCase.Core_Case_Issue_Category__r.Core_Issue_Category_Name__r.Name;
                subcategorySelectedname = cloneCase.Core_Case_Issue_Sub_Category__r.Core_Issue_Sub_Category_Name__r.Name;
                categorySelected=cloneCase.Core_Case_Issue_Category__c;
                
                subCategorySelected=cloneCase.Core_case_issue_sub_category__c;    
                subCategoryOptions=getsubCategory_Options(categorySelected); 
                cloneCase.AssetId = Cs.AssetId;
                
                //Opportunity [] myList = [SELECT ExpectedRevenue FROM Opportunity LIMIT 1000]; //commented by amritesh 12/18/2017 - US85344,US101112 
                
                cloneCase.Core_IPS_Supported_Product__c = Cs.Core_IPS_Supported_Product__c;
                if(Cs.Core_IPS_Supported_Product__r.Core_EOIS__c ==true)
                {
                    eoisFlag =true;
                }
                //Ashutosh - US103890 - getting recordType
                
                Schema.DescribeSObjectResult caseObjectDetail = Schema.SObjectType.Case;
                Map<String,Schema.RecordTypeInfo> rtMapByName = caseObjectDetail.getRecordTypeInfosByName();
                Schema.RecordTypeInfo rtNoAssignedContact =  rtMapByName.get('IPS No Assigned Contact Case');
                Schema.RecordTypeInfo rtCaseCreate =  rtMapByName.get('IPS Case Create');
                
                /*This code was added by CX Team as a part of US77435*/                     
                if(cs.Status == 'Closed'){
                    List<RecordType> createCase = [Select id,Name from RecordType where Name='IPS Case Create' Limit 1];
                    //Ashutosh -US103890 
                    if(cloneCase.contactId != null){
                        cloneCase.recordTypeId = rtCaseCreate.getRecordTypeId();
                    }
                    else{
                        //isNACCase is true added by Aayushi US126300
                        cloneCase.recordTypeId = rtNoAssignedContact.getRecordTypeId(); isNACCase=true;      
                    }
                    //cloneCase.recordTypeId = createCase[0].id; commented by ashutosh -US103890
                }else{
                    //cloneCase.recordTypeId= cs.recordTypeId; commented by ashutosh -US103890
                    if(cloneCase.contactId != null){
                        cloneCase.recordTypeId = rtCaseCreate.getRecordTypeId(); 
                    }
                    else{
                        //isNACCase is true added by Aayushi US126300 
                        cloneCase.recordTypeId = rtNoAssignedContact.getRecordTypeId(); isNACCase=true;         
                    }
                }
                cloneCase.Core_Severity__c = Cs.Core_Severity__c;
            }           
        }
        
        // String assetId = ApexPages.currentPage().getParameters().get('assetid');
        if(csId != null)
        {
            showenvDetials = [select id,Name,Core_Case__c,Core_Question__c,Core_Answer__c from Core_IPS_Environment_Details__c where Core_Case__c =: csId];
        }
        if(cs <> null && cs.Core_Severity__c== 'Critical')
        {
            DisplayPriorityReason = true;
        }
        if(showenvDetials.size()>0)
        {
            displayEnvDetails = true;
        }
        

        if(cs != null && cloneCase!=null && (cloneCase.AssetId != null || cloneCase.AssetId != '') && Asset.SObjectType.getDescribe().isAccessible() ){
                ast = [select id, name,Core_IPS_Supported_Product_EOIS__c,Core_IPS_Project__c,Core_Supported_Product__r.Core_EOIS__c, Core_Product_Organization__c,product2Id from Asset where id =: Cs.AssetId limit 1];
            }
        if(ast.size()>0)
        {
            //FLS Check Added - Nishitha
            if(Core_IPS_Supported_product__c.SObjectType.getDescribe().isAccessible()){
                sProd = [select id from Core_IPS_Supported_product__c where Core_product__c=:ast[0].product2Id and Core_product_organization__c=:ast[0].Core_product_organization__c limit 1];
            }
            if(sProd.size() > 0)  
            {
                productId = sProd[0].id;
            }
            if(ast[0].Core_Supported_Product__r.Core_EOIS__c == true)
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You cannot create a new case for an inactive Intel Product.'));
                eoisFlag = true;
            }
        }
        
        categoryOptions = new List<SelectOption>();
        //categoryOptions.add(new SelectOption('', 'Select Category'));
        if(null != productId ||  (cloneCase!=null && cloneCase.Core_IPS_Supported_Product__c!=null)){    
            if(productId == null)
            {
                productId = cloneCase.Core_IPS_Supported_Product__c;
            }
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getCategories(productId) ){
                categoryOptions.add(new SelectOption(a.id, a.Core_Issue_Category_Name__r.Name));
            }      
        }
        
        if(categoryOptions.size()>0){
            
            Core_Utility.doSort(categoryOptions,Core_Utility.FieldToSort.Label,'Select Category'); 
            displayCategories=true;
            displaySubCategories=true;
        }else{
            displayCategories=false;
            displaySubCategories=false;
        }
        envDetails = getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,null,isAgent);  //modified  by amritesh 12/18/2017 - US85344,US101112 
        subCatEnvDetails = getEnvironmentDetailsOperationList(null,subCategorySelected,isAgent);  //modified  by amritesh 12/18/2017 - US85344,US101112 
        //setCurrentEnvironmentDetails(envDetails,cs.id);
        //UpdateEnvDetails(); 
        Core_IPS_Internal_Case_Controller.setCurrentEnvironmentDetails(envDetails,cs.id); //modified  by amritesh 12/18/2017 - US85344,US101112    
        Core_IPS_Internal_Case_Controller.setCurrentEnvironmentDetails(subCatEnvDetails,cs.id); //modified  by amritesh 12/18/2017 - US85344,US101112
        displayProductVariant();
    }
    /***************************************************************************************************
Method Name:  setCurrentEnvironmentDetails
Method Type: Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : Used in case edit page to get the current environment variable values and default them.
Input Parameters: Product or subcategory based environment variables and case Id 
Output Parameters: None
Description:   Used in case edit page to get the case information
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
* Amritesh                   12/18/2017              Modified US85344,US101112
****************************************************************************************************/   
    /******* commented  by amritesh 12/18/2017 - US85344,US101112 
public void setCurrentEnvironmentDetails(List<EnvironmentDetail> envDetails, String caseId){
List<Core_IPS_Environment_Details__c> caseEnvDetails = [select id,name,Core_Question__c,Core_Answer__c from Core_IPS_Environment_Details__c where Core_Case__c=:caseId];
if(envDetails!=null){
for(EnvironmentDetail ed: envDetails){
for(Core_IPS_Environment_Details__c ced:caseEnvDetails){
if(ced.name==ed.label){
if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c || ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').Value__c)
{
if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c && ced.Core_Answer__c!=null)
{
List<string> LstSelectOptions = ced.Core_Answer__c.split(';');
// LstSelectOptions.remove(LstSelectOptions.size()-1);
ed.selectedMValue=LstSelectOptions;
}
else
{
ed.selectedValue=ced.Core_Answer__c;
}
}
else if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c)
ed.sPlaceholder=ced.Core_Answer__c;
else if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c)
ed.tPlaceholder=ced.Core_Answer__c;
//else if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_check').value__c){
//if(ced.core_answer__c=='True')
//ed.cPlaceholder= true;
//else
//ed.cPlaceholder = false;
//}
}
}
}
}
}**********/
    /***************************************************************************************************
Method Name:  UpdateEnvDetails
Method Type: Action Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : The method is called when the subcategory is change .It will update the EnvDetails.    
Input Parameters: None 
Output Parameters: None
Description: The method is called when the subcategory is change .It will update the EnvDetails.
Used in     : Case cloning
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sunil Chandani              11/24/2015              Created
* Amritesh                   12/18/2017              Modified US85344,US101112
****************************************************************************************************/    
    public  void  UpdateEnvDetails(){
        //modified  by amritesh 12/18/2017 - US85344,US101112 
        //envDetails = getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,subCategorySelected,isAgent);  
        subCatEnvDetails = getEnvironmentDetailsOperationList(null,subCategorySelected,isAgent);  
    }
    private List<Core_IPS_EnvironmentDetailQuestion> getEnvironmentDetailsOperationList(String productId, String subCategoryId, boolean isAgent){
        
        List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
        if(subCategoryId!=null && subCategoryId!='') {
            //envVars=Core_IPS_CaseUtility.getEnvVariables(null,subCategoryId,isAgent);
            //envVars.addAll(Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategoryId,isAgent)); // added by amritesh 12/18/2017 - US85344,US101112
            //Stabalization Fix
            Set<Id> setQuestionIds = new Set<Id>(); //store question ids from Supported Product environment details question list
            if(envDetails!=null && envDetails.size()>0) {
                for(Core_IPS_EnvironmentDetailQuestion objWEDQ : envDetails) {
                    setQuestionIds.add(objWEDQ.QuestionId);
                }
            }
            for(Core_IPS_Assigned_Environment_Variables__c objAEV : Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategoryId,isAgent)) {
                if(!setQuestionIds.contains(objAEV.Core_IPS_Question__c)) {
                    envVars.add(objAEV);
                }
            }
            
            /*List<Core_IPS_Assigned_Environment_Variables__c> LstAssignedEnv = new List<Core_IPS_Assigned_Environment_Variables__c>();
            if(isAgent==false && envVars.size() == 0)
            {
            LstAssignedEnv = [select id, name, Core_Environment_Variable__c,Core_Environment_Variable__r.Name,Core_Environment_Variable__r.Core_Answers__c,Core_Environment_Variable__r.Core_Datatype__c, Core_Product_Issue_Sub_Category__c,Core_Required__c,Core_Agent_Only__c from Core_IPS_Assigned_Environment_Variables__c where Core_Product_Issue_Sub_Category__c=:subCategoryId and Core_Product_Issue_Sub_Category__c!='' and Core_Status__c=:'Active' ];
            
            if(LstAssignedEnv.size() == 0 && envVars.size() == 0 && productId!=null)
            {
            envVars=Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent);
            }
            }
            else if(envVars.size() == 0 && productId!=null)
            {
            envVars=Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent);
            }
            */
        }
        //else
        if(productId!=null && productId!='') // added by amritesh 12/18/2017
        {
            //envVars=Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent);
            envVars.addAll(Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isAgent)); // added by amritesh 12/18/2017
        }
        if(envVars.size()>0) {            
            displayEnvDetails=true;
            return constructWrapper(envVars);
        } else {
            displayEnvDetails=true;
        }   
        return null;
    }
    
    
    /***************************************************************************************************
Method Name:  getEnvDetails
Method Type: Action Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : Gets the environment Details When Case Category is changed on Case create page.
Input Parameters: None 
Output Parameters: reload page partly when Supported product is changed
Description:   Gets the environment Details When Supported product is changed on Case create page.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/    
    public Pagereference getEnvDetails() {
        displaySubCategories=false;
        if(subcategorySelected!=null && subcategorySelected!=''){
            subcategorySelected='';
            //Added by karthick 25/06/2018 - defect fix -DE40246
            cloneCase.Core_case_issue_sub_category__c = null;
            subCategoryOptions =null;
            displaySubCategories=false;
            
        }  
          
        
        subCategoryOptions = getsubCategory_Options(categorySelected); 
        
        subCatEnvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        
        
        //envDetails =  getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,null,isAgent); // commented by amritesh 12/18/2017 - US101112
        return null;
    }
    
    
    /***************************************************************************************************
Method Name:  getsubCategory_Options
Method Type: Action Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : Constructs the Sub Category options based on category selected
Input Parameters: None 
Output Parameters: None
Description:   Constructs the Sub Category options based on category selected
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/     
    public List<SelectOption> getsubCategory_Options(String categorySelected){ 
        //List<SelectOption> subCategoryOptions = new List<SelectOption>();
        //Modified by karthick 25/06/2018 - defect fix -DE40246
        subCategoryOptions = new List<SelectOption>();
        
        if(categorySelected!=null && categorySelected!=''){
            //subCategoryOptions.add(new SelectOption('', 'Select SubCategory'));
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getSubCategories(categorySelected)){
                if(a.Core_Issue_Sub_Category_Name__c!=null){
                    subCategoryOptions.add(new SelectOption(a.id, a.Core_Issue_Sub_Category_Name__r.Name));
                }
            }
            //Modified by karthick 25/06/2018 - defect fix- DE40246     
            Core_Utility.doSort(subCategoryOptions,Core_Utility.FieldToSort.Label,'Select SubCategory');
            if(subCategoryOptions.size()>0){
                /*Core_Utility.doSort(subCategoryOptions, Core_Utility.FieldToSort.Value,'Select SubCategory');*/displaySubCategories=true;}
            else {
                displaySubCategories=false;
            }    
        }
        return subCategoryOptions;
    }
    /***************************************************************************************************
Method Name:  constructWrapper
Method Type: Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : This method helps in constructing a wrapper for Environment Details that is used for displaying components based on ENV Details Data type.
Input Parameters: Core_IPS_Assigned_Environment_Variables__c based on selected Subcategory or selected Supported product 
Output Parameters: None
Description: This method helps in constructing a wrapper for Environment Details that is used for displaying components based on ENV Details Data type.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
* Amritesh                   12/18/2017              Modified US85344,US101112
****************************************************************************************************/    
    public List<Core_IPS_EnvironmentDetailQuestion> constructWrapper(List<Core_IPS_Assigned_Environment_Variables__c> envVars) {
        
        Map<Id,Core_IPS_Assigned_Environment_Variables__c> MapAssigned_EnvironmentVariables = new Map<Id,Core_IPS_Assigned_Environment_Variables__c>();
        Map<Id,Set<Id>> mapQuesParentId2DependentId = new Map<Id,Set<Id>>(); // added by amritesh 12/18/2017 - US85344,US101112 
        boolean IsOptionsChanges =  false;
        for(Core_IPS_Assigned_Environment_Variables__c Ev:envVars)
        {
            /****** added by amritesh 12/18/2017 - US85344,US101112 - start *******/
            //if(Ev.Core_Environment_Variable__c !=null && Ev.Core_Environment_Variable__r.Name !=null && Ev.Core_Environment_Variable__r.Name !='')
            if(Ev.Core_IPS_Question__c!=null && String.isNotBlank(Ev.Core_IPS_Question__r.Core_IPS_Question__c)) 
            {
                //MapAssigned_EnvironmentVariables.Put(Ev.Core_Environment_Variable__r.Name,ev);
                // added by amritesh 12/18/2017 - US85344,US101112 - start
                MapAssigned_EnvironmentVariables.put(Ev.Core_IPS_Question__c, ev); 
                // define the questions dependency
                if(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c!=null) {
                    if(!mapQuesParentId2DependentId.containsKey(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c)) {
                        mapQuesParentId2DependentId.put(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c, new Set<Id>());
                        
                    }                    
                    mapQuesParentId2DependentId.get(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c).add(Ev.Core_IPS_Question__c);
                }
                // added by amritesh 12/18/2017 - US85344,US101112 - end
            }  
        }
        if(envDetails !=null && envVars !=null && envDetails.size() == envVars.size())
        {
            //for(Core_IPS_EnvironmentDetailQuestion En :envDetails)
            for(Core_IPS_EnvironmentDetailQuestion En : Core_IPS_Questions_Utility.getAllWithChildEnvDetails(envDetails)) //added by amritesh 12/18/2017 - US85344,US101112
            {
                if(MapAssigned_EnvironmentVariables.containsKey(en.questionId)==false)
                {         
                    IsOptionsChanges = true;
                    break;
                }
                
            }
        }
        else
        {
            IsOptionsChanges =  true;
        }
        
        if(IsOptionsChanges==false)
        {
            return envDetails;
        }
        
        // added  by amritesh 12/18/2017 - US85344,US101112 -start
        Map<Id,Map<Id,String>> mapQues2AnswerMap = new Map<Id,Map<Id,String>>();
        mapQues2AnswerMap = Core_IPS_Questions_Utility.getQues2AnswerMapId(new List<Id>(MapAssigned_EnvironmentVariables.keySet()));
        // added  by amritesh 12/18/2017 - US85344,US101112 - end
        
        //List<Core_IPS_EnvironmentDetailQuestion> envDetList = new List<Core_IPS_EnvironmentDetailQuestion>(); // commented by amritesh 12/18/2017 - US85344,US101112 
        Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail = new Map<Id,Core_IPS_EnvironmentDetailQuestion>(); // added by amritesh 12/18/2017 - US85344,US101112 
        for(Core_IPS_Assigned_Environment_Variables__c en : envVars){
            Core_IPS_EnvironmentDetailQuestion det = new Core_IPS_EnvironmentDetailQuestion();
            //det.label=en.Core_Environment_Variable__r.name;            
            det.label = en.Core_IPS_Question__r.Core_IPS_Question__c; // added by amritesh 12/18/2017 - US85344,US101112 
            det.questionId = en.Core_IPS_Question__c; // added by amritesh 12/18/2017 - US85344,US101112 
            det.required = en.Core_required__c;
            det.IsAgentOnly = en.Core_Agent_Only__c;
            
            
            //if(en.Core_Environment_Variable__r.Core_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c.trim()){
            if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()) { //added by amritesh 12/18/2017 - US85344,US101112
                
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c;
                det.splaceHolder = '';
                /*if(en.Core_Environment_Variable__r.Core_Answers__C!=null)
det.splaceHolder=en.Core_Environment_Variable__r.Core_Answers__C;
else
det.splaceHolder = '';
*/  // commented by amritesh 12/18/2017 - US85344,US101112 
                // added by amritesh 12/18/2017 - US85344,US101112 
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    if(mapAns.values().size()>0) {
                        det.splaceHolder = mapAns.values().get(0);
                    }
                } 
                
            }else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim() || en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim()){
                //List<String> answersList = en.Core_Environment_Variable__r.Core_Answers__C.split('\n');
                //added  by amritesh 12/18/2017 - US85344,US101112 - start
                List<SelectOption> selectOptionsList = new List<SelectOption>();
                SelectOptionsList.add(new SelectOption('','Select Option'));
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    for(Id ansId : mapAns.keySet()) {
                        selectOptionsList.add(new SelectOption(ansId, mapAns.get(ansId)));
                    }
                } 
                //if(en.Core_Environment_Variable__r.Core_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim())
                if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim()){ // added  by amritesh 12/18/2017 - US85344,US101112
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim();
                } else{
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim();
                }
                det.pplaceholder=selectOptionsList;
                det.selectedValue=selectOptionsList.get(0).getValue();
                //}else if(en.Core_Environment_Variable__r.Core_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c.trim()){
            } else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim()){   // added  by amritesh 12/18/2017 - US85344,US101112          
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim();
                det.tplaceHolder= '';
                /*if(en.Core_Environment_Variable__r.Core_Answers__c!=null)
det.tplaceHolder=en.Core_Environment_Variable__r.Core_Answers__C.trim();
else
det.tplaceHolder= '';
*/ // commented by amritesh 12/18/2017 - US85344,US101112 
                // added by amritesh 12/18/2017 - US85344,US101112 
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    det.tplaceHolder = String.join(mapAns.values(), '\r\n');
                } 
            }
            /*else if(en.Core_Environment_Variable__r.Core_Datatype__c == 'boolean'){
det.type=Core_IPS_Labels__c.getValues('Core_IPS_check').value__c;
det.cplaceholder=false;
}*/
            //envDetList.add(det);
            //added  by amritesh 12/18/2017 - US85344,US101112
            if(mapQuesParentId2DependentId.containsKey(en.Core_IPS_Question__c)) {
                det.hasChildQuestions = true;
            }
            if(en.Core_IPS_Question__r.Core_IPS_Parent_Question__c!=null) {
                det.hasParentQuestion = true;
                det.isVisible = false;
            }
            mapEnvDetail.put(en.Core_IPS_Question__c, det);            
        }
        
        List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetail = new List<Core_IPS_EnvironmentDetailQuestion>();
        for(Id quesId : mapEnvDetail.keySet()) { 
            if(!mapEnvDetail.get(quesId).hasParentQuestion) {
                createQuestionHierachy(quesId, mapEnvDetail, mapQuesParentId2DependentId);
            }
        }
        for(Id quesId : mapEnvDetail.keySet()) {
            if(!mapEnvDetail.get(quesId).hasParentQuestion) {
                lstEnvDetail.add(mapEnvDetail.get(quesId));
            }
        }
        return lstEnvDetail;
    }
    
    private static void createQuestionHierachy(Id quesId, Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail, Map<Id,Set<Id>> mapQuesParentId2DependentId) {
        //for(Id quesId : mapEnvDetail.keySet()) { 
        if(mapQuesParentId2DependentId.containsKey(quesId)) {
            for(Id childQuesId : mapQuesParentId2DependentId.get(quesId)) {
                if(mapEnvDetail.containsKey(childQuesId)) {
                    createQuestionHierachy(childQuesId, mapEnvDetail, mapQuesParentId2DependentId);                       
                    mapEnvDetail.get(quesId).childQuestions.add(mapEnvDetail.get(childQuesId));
                }
            }
        }
        //return lstEnvDetail;
    }
    public List<Schema.FieldSetMember> getFields1() {
        return SObjectType.Case.FieldSets.Core_IPS_Clone_Case_Field_Set.getFields();
    }
    /*public List<Schema.FieldSetMember> getFields2(){
return SObjectType.Case.FieldSets.Issue_Description_Fields.getFields();
}*/
    
    /**
* On basis of field set, Create Dynamic SOQL
*/
    private Case getCase_DynamiCSOQL(String csId) {
        try
        {
             // SOQL Injection Fix - Start -  Shipra
            Map<String, Object> bindMap = new Map<String, Object>{'cseId' => csId  };
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : this.getFields1()) {
                query += f.getFieldPath() + ', ';
            }
            /*for(Schema.FieldSetMember f : this.getFields2()) {
query += f.getFieldPath() + ', ';
}*/
            /*Ashutosh - US103890 - Added some field in query*/
            
            query += 'CaseNumber,Core_IPS_Customer_Visible__c,Core_IPS_Issue_source__c,Core_IPS_Classification__c,RecordTypeId,RecordType.DeveloperName,Id,status,Core_CaseType__c,Core_Customer_Reference_ID__c,Core_IPS_Product_name__c,Core_IPS_Copy_Flag__c,Core_End_Customer__c ,Asset.Core_IPS_Case__c, Priority, Core_IPS_GEC_Status__c,  AccountId, Account.Core_Military_Aerospace_and_Government__c, ContactId,Core_Case_issue_category__c,Core_case_issue_sub_category__c,Core_IPS_Project_Case__r.Name, Core_Case_issue_category__r.name,Core_case_issue_sub_category__r.name,AssetId,Asset.status,Core_IPS_Supported_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c,Core_IPS_Supported_Product__r.Core_EOIS__c ,Core_Case_Issue_Category__r.Core_Issue_Category_Name__r.Name,Core_Case_Issue_Sub_Category__r.Core_Issue_Sub_Category_Name__r.Name, Core_Product_Variant__c,Core_IPS_Restricted_Secret_Content__c,Core_Severity_Reason__c,Core_IPS_Partner_Sup_Owner__c,Core_Partner_Supported_Account__c,Core_IPS_Priority_Reason__c,ParentId,origin,(select Name, Core_Question__c, Core_Answer__c, Core_Case__c from Environments__r) ,(Select Id,Type__c,User__c,Contact__c,Active__c ,case__c From  Interested_Parties__r) FROM case WHERE Id = :cseId';
            
            return Database.queryWithBinds(query,bindMap,AccessLevel.USER_MODE);
             // SOQL Injection Fix - End -  Shipra
        }
        catch(Exception e){
            //Utility.addError('There is error while Fetching existing Question using Dynamic SOQL in Field Set. Error Detail - '+e.getMessage()); //This is Utility Method to display error message on VF Page
            //return null;
            throw new AuraHandledException(e.getMessage());// ATHR fix Gangadhar
        }
        //return null;
    }
    
    public PageReference cancelCaseDetails(){
        PageReference Pg ; 
        if(ApexPages.currentPage().getParameters().get('retURL') !=null)
        {
            /*TWC745-112 - 11/08/2021 - Vishal - IPS Security Vulnerability --*/
            Pg =  new pageReference(ApexPages.currentPage().getParameters().get('retURL').escapeHtml4());   
        }
        else
        {
            Pg = new pageReference('/500/o');
        }
        return  Pg;//pageReference('/500/o');
    }
    
    /***************************************************************************************************
Method Name:  validateEnvironmentDetails
Method Type: Helper Method 
Version     : 1.0 
Created Date: 15 Jul 2015
Function    : This Method validates Environment Detail Responses provided by customer.
Input Parameters: None
Output Parameters: Returns true if user does not fill the mandatory Environment details and false otherwise.
Description: This Method validates Environment Detail Responses provided by customer.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/15/2015              Created
* Amritesh                   12/18/2017              Modified US85344,US101112
****************************************************************************************************/
    public boolean validateEnvironmentDetails(){
        
        // added by amritesh 12/18/2017 - US85344,US101112 - start
        List<Core_IPS_EnvironmentDetailQuestion> lstAllenvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        if(subCatEnvDetails!=null && subCatEnvDetails.size()>0){
            lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(subCatEnvDetails));
        }
        if(envDetails!=null && envDetails.size()>0){
            lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(envDetails));
        }
        
        // added by amritesh 12/18/2017 - US85344,US101112
        if(lstAllenvDetails!=null && lstAllenvDetails.size()>0){
            for(Core_IPS_EnvironmentDetailQuestion det : lstAllenvDetails){     
                if(!det.isVisible) {
                    continue; // added by amritesh 12/18/2017 - US85344,US101112
                }    
                //if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c &&(det.sPlaceHolder==null || det.sPlaceHolder=='') &&det.required){
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c &&(det.sPlaceHolder==null || det.sPlaceHolder=='') &&det.required){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;    
                    //}else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c&&(det.sPlaceHolder !=null || det.sPlaceHolder !='') && det.sPlaceHolder.length()>255){
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c&&(det.sPlaceHolder !=null || det.sPlaceHolder !='') && det.sPlaceHolder.length()>255){ // added  by amritesh 12/18/2017 - US85344,US101112
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G111')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;    
                    //}else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c &&(det.tPlaceHolder==null ||det.tPlaceHolder=='')&&det.required){
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c &&(det.tPlaceHolder==null ||det.tPlaceHolder=='')&&det.required){ // added  by amritesh 12/18/2017 - US85344,US101112
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                    //}else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c && (det.tPlaceHolder != null ||det.tPlaceHolder!='') && det.tPlaceHolder.length()>5000){
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c && (det.tPlaceHolder != null ||det.tPlaceHolder!='') && det.tPlaceHolder.length()>5000){ // added  by amritesh 12/18/2017 - US85344,US101112
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G110')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }else if((det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c) &&(det.selectedValue==null || det.selectedValue=='' || det.selectedValue=='[]') && det.required){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G106')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }
                else if((det.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) &&(det.selectedMValue==null || det.selectedMValue.size() == 0 ||(det.selectedMValue.size()==1 && det.selectedMValue[0]=='')) && det.required){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G106')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }
            }
        }
        
        
        return false;    
    }
    /***************************************************************************************************
Method Name:  saveCaseDetails
Method Type: Save Method 
Version     : 1.0 
Created Date: 15 Jul 2015
Function    : This Method save the Case.
Input Parameters: None
Output Parameters: PageReference - Redirect to Case Details Page
Description: This Method save the Case.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/15/2015              Created
* Amritesh                   12/18/2017              Modified US85344,US101112
****************************************************************************************************/
    public PageReference saveCaseDetails(){
        //cs = new Case();        
        
        if(validateCaseRelatedInformation()) { 
            return null; 
        }
        if(validateEnvironmentDetails()){ 
            return null; 
        }
        
        try{
            Core_IPS_Product_Issue_Category__c ic = new Core_IPS_Product_Issue_Category__c();
            Core_IPS_Product_Issue_Category__c isc = new Core_IPS_Product_Issue_Category__c();
            if(categorySelected !=null && categorySelected !=''){
                ic = [select id, name from Core_IPS_Product_Issue_Category__c where id=:categorySelected limit 1];
                /*Ashutosh - US103890 - added check condition for ic*/
                if(ic != null && !String.isBlank(ic.Name) ){
                    /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
                   // if (Schema.sObjectType.Case.fields.Core_External_Issue_Category__c.isUpdateable()) {
                          cloneCase.Core_External_Issue_Category__c=ic.Name;     
                    //}
                }
                //cloneCase.Core_External_Issue_Category__c=ic.Name;   
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Case.fields.Core_Case_Issue_Category__c.isUpdateable()) {
                    cloneCase.Core_Case_Issue_Category__c=categorySelected;
                //}
            }
            if(subCategorySelected !=null && subCategorySelected !=''){
                isc = [select id, name from Core_IPS_Product_Issue_Category__c where id=:subCategorySelected limit 1];
                /*Ashutosh - US103890 - added check condition for ic*/
                if(isc != null && !String.isBlank(ic.Name)){
                    /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
                   // if (Schema.sObjectType.Case.fields.Core_External_Issue_Subcategory__c.isCreateable() || Schema.sObjectType.Case.fields.Core_External_Issue_Subcategory__c.isUpdateable()) {
                        cloneCase.Core_External_Issue_Subcategory__c=isc.Name;            
                    //}
                }
                //cloneCase.Core_External_Issue_Subcategory__c=isc.Name;
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Case.fields.Core_Case_Issue_Sub_Category__c.isUpdateable()) {
                    cloneCase.Core_Case_Issue_Sub_Category__c=subCategorySelected;
               // }
            }
            /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
            //if (Schema.sObjectType.Case.fields.Core_IPS_Customer_Visible__c.isUpdateable()) {
                 cloneCase.Core_IPS_Customer_Visible__c =custVisible;        //added by Aayushi US126300
            //}
            
            if(DisplayPriorityReason == true && (cloneCase.Core_Severity_Reason__c==null || cloneCase.Core_Severity_Reason__c=='')){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('I111'));
                ApexPages.addMessage(myMsg);
                return null;
            }
            if(cloneCase.Core_Issue_Description__c != null)
            {
                string  strDescValue =  Core_Utility.replaceSpecialChar(cloneCase.Core_Issue_Description__c);
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Case.fields.Description.isUpdateable()) {
                    cloneCase.Description = Core_Utility.replaceHtmlTags(strDescValue);
                //}
            }  
            if( cloneCase.recordTypeID == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId())
            {
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Case.fields.Core_IPS_Self_Assigned__c.isUpdateable()) {
                    cloneCase.Core_IPS_Self_Assigned__c = true;
                //}
                
            }
            else
            {
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
              //  if (Schema.sObjectType.Case.fields.Core_IPS_Self_Assigned__c.isUpdateable()) {
                    cloneCase.Core_IPS_Self_Assigned__c = false;
               // }

            }
            
            if(UserInfo.getUserType() == 'PowerCustomerSuccess')
            {
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
              //  if (Schema.sObjectType.Case.fields.Origin.isUpdateable()) {
                    cloneCase.Origin = 'Web';
               // }                               
            }
            /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
           // if (Schema.sObjectType.Case.fields.Core_IPS_Classification__c.isUpdateable()) {
                cloneCase.Core_IPS_Classification__c = cs.Core_IPS_Classification__c;    
            //}
            //if (Schema.sObjectType.Case.fields.Core_Partner_Supported_Account__c.isUpdateable()) {
                cloneCase.Core_Partner_Supported_Account__c =null;
            //}
            //if (Schema.sObjectType.Case.fields.Core_IPS_Partner_Sup_Owner__c.isUpdateable()) {
                cloneCase.Core_IPS_Partner_Sup_Owner__c = null;
            //} 
            //if (Schema.sObjectType.Case.fields.Core_Product_Variant__c.isUpdateable()) {
                cloneCase.Core_Product_Variant__c = selectedVariant;
            //}
            
            //Start--US343456--14th June 2019--Aniket--MINDS Case Creation
            if(isMindsFlag!=NULL){
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Case.fields.Core_IPS_Minds__c.isUpdateable()) {
                    cloneCase.Core_IPS_Minds__c= isMindsFlag;
                //}
            }else{
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Case.fields.Core_IPS_Minds__c.isUpdateable()) {
                cloneCase.Core_IPS_Minds__c=false;
                //}
            }
            
            if(selectedCountry!=null){
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
              //  if (Schema.sObjectType.Case.fields.Core_IPS_Country_Region__c.isUpdateable()) {
                    cloneCase.Core_IPS_Country_Region__c = selectedCountry;
                //}
            }
            //End--US343456--14th June 2019--Aniket--MINDS Case Creation
            
            //Insert PSO/PSA Field if user is FAE Partner or Agent PArtner / US108521 Add PSO/PSA to Case when copying a case
            if(isPartnerFAE|| isAgentPartner){
                cloneCase.Core_IPS_Partner_Sup_Owner__c = userinfo.getUserId();
                //Checking if the selectedAccountId String is empty since it's an ID Variable
                if(selectedAccountId!= 'NA'){
                    
                    cloneCase.Core_Partner_Supported_Account__c = selectedAccountId;  
                }
                
                //Checking if Case has Project and PSA is not Selected
                if((cs.Core_IPS_Project_Case__c!= null) && (String.isBlank(selectedAccountId)|| selectedAccountId == 'NA') ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select Partner Supported Account'));
                    return null;
                }                
                //Using this without sharing method to insert PSA
                CaseRecordSave caseRecSave=new CaseRecordSave();
                caseRecSave.saveCase(cloneCase); 
            }
            else{                
                            
                upsert cloneCase;
            }
            
            //addEnvDetails();
            captureEnvDetails(); // added  by amritesh 12/18/2017 - US85344,US101112
            if(cs.Interested_Parties__r != null && !(cs.Interested_Parties__r).isEmpty()){
                copyInterestedParties(cs.Interested_Parties__r);//added by ashutosh US103890,11/05/2018 - copying all interested parties on new case 
            }
            
            
        }catch(DMLException e){
            renderErrorFlag=true;
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.Warning, 'Please enter value' + e);
            ApexPages.addMessage(msg);
            
            //return new PageReference('/apex/Core_IPS_CreateCase?assetId='+ast[0].id);
            return null;
        }    
        //renderErrorFlag=false; 
        
        if(!isAgent){
            return new pageReference('/'+cloneCase.id);
        }else{
            return new pageReference('/'+cloneCase.id);
        }
        
    }
    /***************************************************************************************************
Method Name:  addEnvDetails
Method Type: Action method 
Version     : 1.0 
Created Date: 01 Jul 2015
Function    : This method saves environment details as related list to case.
Input Parameters: None
Output Parameters: None
Description:This method is used to save environment details under case as related list. Each question and answer is saved as a record under case
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/01/2015              Created
* Amritesh                   12/18/2017              Modified US85344,US101112
****************************************************************************************************/     
    /****** commented  by amritesh 12/18/2017 - US85344,US101112
public void addEnvDetails(){
// List<Core_IPS_Environment_Details__c> existingDetails = new List<Core_IPS_Environment_Details__c>();
// existingDetails = [select id from Core_IPS_Environment_Details__c where Core_case__c=:cs.id];
// if(existingDetails <> null && existingDetails.size()>0){
// delete ExistingDetails;
// }
List<Core_IPS_Environment_Details__c> envDetailsToCreate = new List<Core_IPS_Environment_Details__c>();
if(envDetails!=null && envDetails.size()>0){
for(Core_IPS_EnvironmentDetailQuestion det:envDetails){
Core_IPS_Environment_Details__c detail = new Core_IPS_Environment_Details__c();
detail.Core_Question__c= det.label;
detail.Core_case__c= cloneCase.id;
detail.Name = det.label;
detail.Core_Agent_Only__c = det.IsAgentOnly;
if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c){
detail.Core_Answer__c = det.sPlaceHolder;
}else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c){
detail.Core_Answer__c= det.tPlaceHolder;
}else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ){
detail.Core_Answer__c= det.selectedValue;
}else if(det.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c){
string  strSelectedValue  = '';
for(string  str  : det.selectedMValue)
{ 
if(str!='')
strSelectedValue = strSelectedValue + str + ';' ;
}
detail.Core_Answer__c = strSelectedValue;//det.selectedValue;
}
//else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_check').value__c){
//if( det.cPlaceHolder)
//detail.Core_Answer__c= 'True';
//else
//detail.Core_Answer__c= 'False'; 
//}
envDetailsToCreate.add(detail);
}
if(envDetailsToCreate.size()>0){
//insert envDetailsToCreate;
Core_IPS_AdminUtility.insertEnvDetailsToCreate(envDetailsToCreate);
}
}
}
*/
    
    // added  by amritesh 12/18/2017 - US85344,US101112
    public void captureEnvDetails() {   
        /*if(cs.Id!=null) {
List<Core_IPS_Response__c> lstExistingCoreResponse = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(cs.Id);
if(lstExistingCoreResponse!=null && lstExistingCoreResponse.size()>0) {
Core_IPS_AdminUtility.DeleteEnvDetails(lstExistingCoreResponse);
}
}*/
        List<Core_IPS_Response__c> lstEnvDetailsResponse = new List<Core_IPS_Response__c>();
        List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        if(envDetails!=null) { 
            lstEnvDetails.addAll(envDetails);
        }    
        if(subCatEnvDetails!=null) {
         lstEnvDetails.addAll(subCatEnvDetails);
        } 
        
        if(lstEnvDetails!=null && lstEnvDetails.size()>0) {
            for(Core_IPS_EnvironmentDetailQuestion envdet : lstEnvDetails) {
                lstEnvDetailsResponse.addAll(Core_IPS_Questions_Utility.constructResponse(envdet, cloneCase));
                if(envdet.childQuestions.size()>0) {
                    for(Core_IPS_EnvironmentDetailQuestion childEnvDetail : envdet.childQuestions) {
                        if(childEnvDetail.isVisible){
                            lstEnvDetailsResponse.addAll(Core_IPS_Questions_Utility.constructResponse(childEnvDetail, cloneCase));
                        }    
                    }
                }
            }
            if(lstEnvDetailsResponse.size()>0){
                Core_IPS_AdminUtility.insertEnvDetailsToCreate(lstEnvDetailsResponse);
            }
        }
    }
    
    /***************************************************************************************************
Method Name:  DisplayPriorityReason
Method Type: Action Method 
Version     : 1.0 
Created Date: 11-03-2015
Function    : This method set the "DisplayPriorityReason" boolean variable set to True if User selects "Core_Severity__c" as 'Critical'. If boolean variable is True then, "Severity Reason" picklist is displayed in the UI.
Input Parameters: None
Output Parameters: None
Description: This method is called when user changes the Core_Severity__c Picklist in the UI. If Core_Severity__c Picklist is Critical, Severity Reason picklist is displayed in the UI 
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya       11/03/2015                 Created
****************************************************************************************************/    
    public void DisplayPriorityReason(){
        if(cloneCase.Core_Severity__c == 'Critical'){
            DisplayPriorityReason = true;
        }
        else {
            DisplayPriorityReason = false;
            cloneCase.Core_Severity_Reason__c='';
        }
        
    }
    
    
    
    /***************************************************************************************************
Method Name:  copyInterestedParties
Method Type: Action Method 
Version     : 1.0 
Created Date: 11-05-2018
Function    : This method groups all the interested party from parent case and copy them on new copied case
Input Parameters: List of interested parties
Output Parameters: None
Description: This is called when we starts cloning all the details from parent case
Used in     : Case copy
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashutosh Bhardwaj           11/05/2018               Created
****************************************************************************************************/    
    public void copyInterestedParties(List<Core_IPS_Case_Interested_Party__c> interestedParties){
        List<Core_IPS_Case_Interested_Party__c> newPartyList = new List<Core_IPS_Case_Interested_Party__c>();
        for(Core_IPS_Case_Interested_Party__c party : interestedParties){
            Core_IPS_Case_Interested_Party__c newParty =  new Core_IPS_Case_Interested_Party__c();
            /* Start ---US1038641 06/24/2021 - Sai Krishna - FLS Check for security vulnerability--*/
            //if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Case__c.isCreateable()){
               newParty.Case__c = cloneCase.Id;    
            //}
          //  if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.User__c.isCreateable()){
               newParty.User__c = party.User__c;
           // }
          //  if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Active__c.isCreateable()){
               newParty.Active__c = party.Active__c;
            //}
           // if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Contact__c.isCreateable()){
               newParty.Contact__c = party.Contact__c;
            //}
            //if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Type__c.isCreateable()){
               newParty.Type__c = party.Type__c;
            //}    
           /*End ---US1038641 06/24/2021 - Sai Krishna - FLS Check for security vulnerability--*/ 
            newPartyList.add(newParty);
        }
        Core_IPS_AdminUtility.insertInterestedParties(newPartyList);//This method insert the parties now
    }    
    /***************************************************************************************************
Method Name:  errormessage
Method Type: Helper Method 
Version     : 1.0 
Created Date: 01 Jul 2015
Function    : This method Gets the error message from Core_IPS_Error_Code custom setting.
Input Parameters: Error code
Output Parameters: Returns error message
Description: All the error messages are added in Custom setting and this method gets the error message from error code.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/01/2015              Created
****************************************************************************************************/    
    public string errormessage(string errorCode){
        string defaultmessage ='please fill the Mandatory fields';
        if(Core_IPS_Error_Code__c.getinstance(errorCode)!=null){
            if(Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c!=null){
                defaultmessage =Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c; 
            }
        }
        return defaultmessage;
    }
    
    public boolean validateCaseRelatedInformation()
    {
        
        if(cloneCase.Subject==null || cloneCase.Subject==''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G102'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        if(String.isBlank(cloneCase.Core_Issue_Description__c) || (!String.isBlank(cloneCase.Core_Issue_Description__c)&& cloneCase.Core_Issue_Description__c.stripHtmlTags().replaceAll('\u00A0','').trim()=='') ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G103'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        if(cloneCase.Core_Severity__c==null || cloneCase.Core_Severity__c==''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G104'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        if(cloneCase!= null && (cloneCase.Core_CaseType__c==null || cloneCase.Core_CaseType__c=='')) {
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G109'));
            ApexPages.addMessage(myMsg);
            return true;
        } 
        if((categoryOptions!=null && categoryOptions.size()>1) && (categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0)))
        {
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G100'));//G100
            ApexPages.addMessage(myMsg);               
            return true ;  
        }
        
        if((subCategoryOptions !=null && subCategoryOptions.size()>1) && (subCategorySelected==null || (subCategorySelected!=null && subCategorySelected.trim().length()==0))){
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G101'));
            ApexPages.addMessage(myMsg);
            return true;
        }       
        return false;
    }   
    
    //Method called when page is launched
    public Pagereference  PageInit()
    {
        
        Pagereference Pg =  null;
        
        
        
        //US185241 Gourav -- Commented MAG check To allow MAG Account cases to be cloned
        /* if(isMAG){//Checks id Account is MAG
            pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G112&retURL='+cs.Id);
            
        }else */
        if(eoisFlag || (cs.Assetid != null && cs.Asset.status == 'Inactive')){//Checks if EOIS in Supported Product is checked or asset is inactive
            //pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G113&retURL='+cs.Id); ----Ashutosh - DE39882 - change to single messgae
            pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G119&retURL='+cs.Id); //----Ashutosh - DE39882 - change to single messgae FOR EOIS OR ASSET IS INACTIVE
        }
        else if(isGEC){   //checks for GECRead_Only Record type 
            pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G114&retURL='+cs.Id);
        }
        else{/* As part of the US77435 Raj Kommera added the following Condition */
            If(cs.AssetId!= null){
                UserRecordAccess assetAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: cs.AssetID Limit 1];
                if(!assetAccess.HasReadAccess){//This block when copying cases: Validate if user has Asset read access or not 
                    pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G117&retURL='+cs.Id);
                }
                
                else if(cs.Core_IPS_Copy_Flag__c){//This block to check if Project/Product is Active or not .
                    pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G116&retURL='+cs.Id);    
                }
            }
        }        
        displayProductVariant();
        if(pg==null && externalUser==false) { //US127333
            pg = new Pagereference('/apex/Core_IPS_Internal_Case_Creation?id=' + cs.Id + '&mode=copy&retURL=%2F' + cs.Id);
        }
        return pg;
    }
    
    
    public void BindEvent(){}
    /***************************************************************************************************
Wrapper Class Name: EnvironmentDetail 
Version     : 1.0 
Created Date: 01 Jul 2015
Function    : This wrapper class is used for constructing components for environment details in Case Creation visualforce page.
Input Parameters: None
Output Parameters: None
Description: Constructs wrapper that is used in case creation visualforce page for displaying specific components.
Used in     : Case create visualforce pages
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/01/2015              Created
****************************************************************************************************/   
    /*****  commented by amritesh 12/18/2017 - US85344,US101112 
private class EnvironmentDetail{
public String type{get;set;}
public String label{get;set;}
public String splaceholder{get;set;}
public List<SelectOption> pplaceholder{get;set;}
public String selectedValue{get;set;}
public boolean cplaceholder{get;set;}
public String tplaceholder{get;set;}
public boolean required{get;set;}
public boolean IsAgentOnly{get;set;}
public List<string> selectedMValue{get;set;}
}*/
    
    //Added by Geetha as per user story US92077
    
    public boolean displayPopup {get; set;}    
    public static list<Contact> con{set;get;}
    public void closePopup()
    {       
        displayPopup = false;   
        
    }    
    public void showPopup()
    {       
        displayPopup = true; 
        con=[SELECT Id,FirstName,LastName,Email FROM Contact WHERE ( AccountID In (SELECT AccountID FROM User WHERE id=:userinfo.getuserid()) and (Core_IPS_Active__c=true)) ];
    }   
    //Ended by geetha as per user story US92077
    
    
    /***************************************************************************************************
Method Name:  displayProductVariant
Method Type:  Helper Method 
Version     : 1.0 
Created Date: 09 July 2018
Function    : US108800 :Add Product Variant to Copy Case
Input Parameters: None
Output Parameters: None
Description:   To get values of product variant 
Used in     : Copy Case
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps               07/09/2018              Created
****************************************************************************************************/  
    Public void displayProductVariant(){
        List<SelectOption> variants = Product_Variant_Utility.displayProductVariant(selectedProductId); 
        List<SelectOption> so = null;
        variantsList=new List<list<SelectOption>>();
        for(Integer i=0;variants!=null && i<(variants.size()/999)+1;i++){
            so=new List<SelectOption>();
            for(Integer j=(i*999);(j<(i*999)+999) && j<variants.size() ;j++){
                so.add(variants.get(j));
            }
            variantsList.add(so);
        }
        blnShowVariant = Product_Variant_Utility.blnShowVariant;
        
    }
    
    /***************************************************************************************************
Inner Class Name:  CaseRecordSave
Class Type: without sharing
Version     : 1.0 
Function    : This Inner Class bypass The case creation sharing issue for US108521 
Method      :saveCase Get case Object 
Used in     : Case Create/Edit
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Raj Kommera                7/18/2018                 Created
****************************************************************************************************/ 
    public without sharing class CaseRecordSave{
        public void saveCase(Case cloneCase){            
            upsert cloneCase;
        }
    } 
    
    /***************************************************************************************************
    Method Name :  getCountries
    Function    : This method will return you countries
    Used in     : Case clone
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aniket Kakade            14/06/2019            Created to get countries
    ****************************************************************************************************/ 
    public List<SelectOption> getCountries() {
        countryOptions = new List<SelectOption>();
        Schema.Describefieldresult result = Schema.sObjectType.Contact.fields.Core_Country_Region__c;
        Schema.DescribeFieldResult fieldResult = result.getSObjectField().getDescribe();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //countryOptions.add(new SelectOption('-None-', '-None-'));
        for( Schema.PicklistEntry entry : ple) {
            countryOptions.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        Core_Utility.doSort(countryOptions, Core_Utility.FieldToSort.Label,'-None-');
        return countryOptions;
    }
}