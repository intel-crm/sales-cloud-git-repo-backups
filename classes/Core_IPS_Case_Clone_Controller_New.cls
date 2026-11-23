public with sharing class Core_IPS_Case_Clone_Controller_New {
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
    
    //Added By Yogesh Sharma
    public List<Core_IPS_Response__c> showenvDetials = new List<Core_IPS_Response__c>();
    //public List<Core_IPS_Environment_Details__c> showenvDetials = new List<Core_IPS_Environment_Details__c>();
    
    //Added By Yogesh Sharma
    public List<Core_IPS_Response__c> getshowenvDetials()
    {
        return showenvDetials;
    }
    
    /*public List<Core_IPS_Environment_Details__c> getshowenvDetials()
    {
        return showenvDetials;
    }*/
    
    public Case cs{get;set;}
    public Case cloneCase{get;set;}
    public boolean isAgent{get;set;}
    public boolean displayEnvDetails{get;set;}
    public String categorySelected{get; set;}
    public String categorySelectedname{get;set;}
    public string ProjectName{get;set;}
    public String subcategorySelectedname{get;set;}
    public List<SelectOption> categoryOptions{get;set;} 
    public List<SelectOption> subCategoryOptions{set;get;}
    public boolean displayCategories{get;set;}
    public boolean displaySubCategories{get;set;}
    public boolean renderErrorFlag{get;set;}   
    public boolean rerenderFlag{get;set;}
    public boolean eoisFlag{get;set;}
    public integer intSubCategorySize = 0;
    public List<EnvironmentDetail> envDetails{set;get;}
    public List<EnvironmentDetail> envDetList{get;set;}
    public boolean isMAG{get;set;}
    public boolean isGec{get;set;}
    public Core_IPS_Case_Clone_Controller_New(ApexPages.standardController controller){
       displayEnvDetails = false;
       eoisFlag =false;
       isGEC = false;
        User u = [select Id, username,userType,ContactId,AccountId from User where Id = :UserInfo.getUserId()];
        eoisFlag =false;
        if(u != null)
        {
        if(u.userType== Label.Core_IPS_CustCommPlus_UserType ){
            isAgent=false;
        }else{
            isAgent=true;
        }
        }
        String csId = controller.getId(); 
        csId = ApexPages.currentPage().getParameters().get('id');
        if(csId==null){
            cs = new Case();
        }else{        
           
            cs= getCase_DynamiCSOQL(csId);   
                    
            if(cs !=null)
            {            
            cloneCase = cs.clone(false, true, false, false);
            isMAG = cs.Account.Core_Military_Aerospace_and_Government__c;
            cloneCase.Subject=null;
            cloneCase.Core_CaseType__c = cs.Core_CaseType__c;
            cloneCase.Core_IPS_GEC_Flag__c = cs.Core_IPS_GEC_Flag__c;
            cloneCase.Core_IPS_GEC_Status__c = cs.Core_IPS_GEC_Status__c;
            cloneCase.Core_Issue_Description__c = null;
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
            ProjectName = cloneCase.Core_IPS_Project_Case__r.Name;
            categorySelectedname = cloneCase.Core_Case_Issue_Category__r.Core_Issue_Category_Name__r.Name;
            subcategorySelectedname = cloneCase.Core_Case_Issue_Sub_Category__r.Core_Issue_Sub_Category_Name__r.Name;
            categorySelected=cloneCase.Core_Case_Issue_Category__c;
            
            subCategorySelected=cloneCase.Core_case_issue_sub_category__c;    
            subCategoryOptions=getsubCategory_Options(categorySelected);            
            cloneCase.AssetId = Cs.AssetId;
            cloneCase.Core_IPS_Supported_Product__c = Cs.Core_IPS_Supported_Product__c;
            if(Cs.Core_IPS_Supported_Product__r.Core_EOIS__c ==true)
            {
               eoisFlag =true;
            }
            cloneCase.recordTypeId = Cs.recordTypeId;
            cloneCase.Core_Severity__c = Cs.Core_Severity__c;
            }           
        }
        
       // String assetId = ApexPages.currentPage().getParameters().get('assetid');
        if(csId != null)
        {
        	//Added By Yogesh Sharma
        	showenvDetials = [select id,Name,Core_IPS_Case__c,Core_IPS_Question__c,Core_IPS_Answer__c from Core_IPS_Response__c where Core_IPS_Case__c =: csId];
            //showenvDetials = [select id,Name,Core_Case__c,Core_Question__c,Core_Answer__c from Core_IPS_Environment_Details__c where Core_Case__c =: csId];
        }
        if(cs <> null && cs.Core_Severity__c== 'Critical')
        {
            DisplayPriorityReason = true;
        }
        if(showenvDetials.size()>0)
        {
            displayEnvDetails = true; 
        }
        
        
        if(cs != null && (cloneCase.AssetId != null || cloneCase.AssetId != ''))
        
        ast = [select id, name,Core_IPS_Supported_Product_EOIS__c,Core_IPS_Project__c,Core_Supported_Product__r.Core_EOIS__c, Core_Product_Organization__c,product2Id from Asset where id =: Cs.AssetId limit 1];
        system.debug('#######'+ast+cloneCase.AssetId);
        if(ast.size()>0)
        {
        List<Core_IPS_Supported_product__c> sProd = [select id from Core_IPS_Supported_product__c where Core_product__c=:ast[0].product2Id and Core_product_organization__c=:ast[0].Core_product_organization__c limit 1];
        system.debug('#######'+sProd);
        if(sProd.size() > 0)  
        {
           system.debug('Product *******Size' + sProd.size() + 'Prod Id' + sProd[0].id);
        
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
        if(null != productId ||  cloneCase.Core_IPS_Supported_Product__c!=null){    
           if(productId == null)
           {
            productId = cloneCase.Core_IPS_Supported_Product__c;
           }
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getCategories(productId) ){
                categoryOptions.add(new SelectOption(a.id, a.Core_Issue_Category_Name__r.Name));
            }      
        }
        system.debug('#####'+productId+'#####'+categoryOptions);
        if(categoryOptions.size()>0){
        
        Core_Utility.doSort(categoryOptions,Core_Utility.FieldToSort.Label,'Select Category'); 
            displayCategories=true;
            displaySubCategories=true;
        }else{
            displayCategories=false;
            displaySubCategories=false;
        }
        system.debug(cs.Core_IPS_Supported_Product__c);
        system.debug(subCategorySelected);
       envDetails = getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,subCategorySelected,isAgent);  
       setCurrentEnvironmentDetails(envDetails,cs.id);
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
    ****************************************************************************************************/   
    public void setCurrentEnvironmentDetails(List<EnvironmentDetail> envDetails, String caseId){
        //Added By Yogesh Sharma
        List<Core_IPS_Response__c> caseEnvDetails = [select id,name,Core_IPS_Question_Master__c,Core_IPS_Answer_Master__c,Core_IPS_Answer__c,Core_IPS_Question__c from Core_IPS_Response__c where Core_IPS_Case__c =: caseId];
        //List<Core_IPS_Environment_Details__c> caseEnvDetails = [select id,name,Core_Question__c,Core_Answer__c from Core_IPS_Environment_Details__c where Core_Case__c=:caseId];
        
        if(envDetails!=null){
            for(EnvironmentDetail ed: envDetails){
                //Added By Yogesh Sharma
                for(Core_IPS_Response__c ced:caseEnvDetails){
                //for(Core_IPS_Environment_Details__c ced:caseEnvDetails){	
                    System.debug('CED Name:'+ced.name+'ED Label:'+ed.label);
                    if(ced.name==ed.label){
                        
                        if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c || ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').Value__c)
                        {
                          //Added By Yogesh Sharma
                          if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c && ced.Core_IPS_Answer__c!=null)	
                          
                          //if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c && ced.Core_Answer__c!=null)
                          {
                            //Added By Yogesh Sharma
                            List<string> LstSelectOptions = ced.Core_IPS_Answer__c.split(';');
                            //List<string> LstSelectOptions = ced.Core_Answer__c.split(';');
                            
                           // LstSelectOptions.remove(LstSelectOptions.size()-1);
                            ed.selectedMValue=LstSelectOptions;
                          }
                          else
                          {
                          	//Added By Yogesh Sharma
                          	ed.selectedValue=ced.Core_IPS_Answer__c;
                            //ed.selectedValue=ced.Core_Answer__c;
                          }
                        }
                        else if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c)
                            
                            //Added By Yogesh Sharma
                            ed.sPlaceholder=ced.Core_IPS_Answer__c;
                            //ed.sPlaceholder=ced.Core_Answer__c;
                            
                        else if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c)
                            //Added By Yogesh Sharma
                            ed.tPlaceholder=ced.Core_IPS_Answer__c;
                            //ed.tPlaceholder=ced.Core_Answer__c;
                            
                        /*else if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_check').value__c){
                            if(ced.core_answer__c=='True')
                            ed.cPlaceholder= true;
                            else
                            ed.cPlaceholder = false;
                        }*/
                    }
                }
            }
        }
    }
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
    ****************************************************************************************************/    
    public  void  UpdateEnvDetails(){
    
     envDetails = getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,subCategorySelected,isAgent);  
    }
     private List<EnvironmentDetail> getEnvironmentDetailsOperationList(String productId, String subCategoryId, boolean isAgent){
        
        List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
        if(subCategoryId!=null && subCategoryId!=''){
            envVars=Core_IPS_CaseUtility.getEnvVariables(null,subCategoryId,isAgent);
            List<Core_IPS_Assigned_Environment_Variables__c> LstAssignedEnv = new List<Core_IPS_Assigned_Environment_Variables__c>();
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
            
        }
        else
        {
            envVars=Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent);
        }
        if(envVars.size()>0){
       
            displayEnvDetails=true;
            return constructWrapper(envVars);
        }else{
            displayEnvDetails=true;
        }   
        return null;
    }
    
    
     /***************************************************************************************************
    Method Name:  getEnvDetails
    Method Type: Action Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : Gets the environment Details When Supported product is changed on Case create page.
    Input Parameters: None 
    Output Parameters: reload page partly when Supported product is changed
    Description:   Gets the environment Details When Supported product is changed on Case create page.
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/    
   public Pagereference getEnvDetails(){
       if(subcategorySelected!=null && subcategorySelected!=''){
            subcategorySelected='';
       }  
       system.debug('####@@####'+categorySelected);  
       subCategoryOptions=getsubCategory_Options(categorySelected); 
       system.debug('####@@####'+subCategoryOptions);
       envDetails =  getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,null,isAgent);
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
        List<SelectOption> subCategoryOptions = new List<SelectOption>();
        System.debug('Category Selected:'+categorySelected);
        if(categorySelected!=null && categorySelected!=''){
            //subCategoryOptions.add(new SelectOption('', 'Select SubCategory'));
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getSubCategories(categorySelected)){
              system.debug('inside for '+a.Core_Issue_Sub_Category_Name__r.Name+' '+Core_IPS_CaseUtility.getSubCategories(categorySelected));
                if(a.Core_Issue_Sub_Category_Name__c!=null){
                subCategoryOptions.add(new SelectOption(a.id, a.Core_Issue_Sub_Category_Name__r.Name));
                system.debug('inside for and if'+subCategoryOptions);
                }
            }
            if(subCategoryOptions.size()>0){Core_Utility.doSort(subCategoryOptions, Core_Utility.FieldToSort.Label,'Select SubCategory');displaySubCategories=true;}
            else displaySubCategories=false;
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
    ****************************************************************************************************/    
   public List<EnvironmentDetail> constructWrapper(List<Core_IPS_Assigned_Environment_Variables__c> envVars){
   
   Map<string,Core_IPS_Assigned_Environment_Variables__c> MapAssigned_EnvironmentVariables = new Map<string,Core_IPS_Assigned_Environment_Variables__c>();
   boolean IsOptionsChanges =  false;
   for(Core_IPS_Assigned_Environment_Variables__c Ev:envVars)
   {
    if(Ev.Core_Environment_Variable__c !=null && Ev.Core_Environment_Variable__r.Name !=null && Ev.Core_Environment_Variable__r.Name !='')
    {
     MapAssigned_EnvironmentVariables.Put(Ev.Core_Environment_Variable__r.Name,ev);
     }
   }
    if(envDetails !=null && envVars !=null && envDetails.size() == envVars.size())
    {
     for(EnvironmentDetail En :envDetails)
     {
       system.debug(en.Label);
       system.debug(en.type);
       //system.debug(en.splaceholder);
       system.debug(en.selectedValue);
       if(MapAssigned_EnvironmentVariables.containsKey(en.Label)==false)
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
   system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + IsOptionsChanges);
   if(IsOptionsChanges==false)
   {
     return envDetails;
   }
   
       envDetList = new List<EnvironmentDetail>();
        for(Core_IPS_Assigned_Environment_Variables__c en:envVars){
            EnvironmentDetail det = new EnvironmentDetail();
            
            det.label = en.Core_Environment_Variable__r.name;
            det.required = en.Core_required__c;
            det.IsAgentOnly = en.Core_Agent_Only__c;
            if(en.Core_Environment_Variable__r.Core_Datatype__c== Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c){
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c;
                if(en.Core_Environment_Variable__r.Core_Answers__C!=null)
                    det.splaceHolder=en.Core_Environment_Variable__r.Core_Answers__C;
                else
                    det.splaceHolder = '';
                
            }else if(en.Core_Environment_Variable__r.Core_Datatype__c== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c || en.Core_Environment_Variable__r.Core_Datatype__c== Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c){
                List<String> answersList = en.Core_Environment_Variable__r.Core_Answers__C.split('\n');
                List<SelectOption> selectOptionsList = new List<SelectOption>();
                SelectOptionsList.add(new SelectOption('','Select Option'));
                for(String ans:answersList){
                    ans=ans.trim();
                    selectOptionsList.add(new SelectOption(ans,ans));
                }
                if(en.Core_Environment_Variable__r.Core_Datatype__c== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c)
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c;
                else{
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c;
                }
                det.pplaceholder=selectOptionsList;
                det.selectedValue=selectOptionsList.get(0).getValue();
            }else if(en.Core_Environment_Variable__r.Core_Datatype__c == Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c){
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c;
                if(en.Core_Environment_Variable__r.Core_Answers__c!=null)
                    det.tplaceHolder=en.Core_Environment_Variable__r.Core_Answers__C;
                else
                    det.tplaceHolder= '';
            }/*else if(en.Core_Environment_Variable__r.Core_Datatype__c == 'boolean'){
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_check').value__c;
                det.cplaceholder=false;
            }*/
                        envDetList.add(det);
        }
        return envDetList;
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
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : this.getFields1()) {
                query += f.getFieldPath() + ', ';
            }
            /*for(Schema.FieldSetMember f : this.getFields2()) {
                query += f.getFieldPath() + ', ';
            }*/
            
            query += 'RecordTypeId,RecordType.DeveloperName,Id,Core_CaseType__c ,Core_Customer_Reference_ID__c ,Core_End_Customer__c , Core_IPS_GEC_Flag__c,Priority, Core_IPS_GEC_Status__c,  AccountId, Account.Core_Military_Aerospace_and_Government__c, ContactId,Core_Case_issue_category__c,Core_case_issue_sub_category__c,Core_IPS_Project_Case__r.Name, Core_Case_issue_category__r.name,Core_case_issue_sub_category__r.name,AssetId,Core_IPS_Supported_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c,Core_IPS_Supported_Product__r.Core_EOIS__c ,Core_Case_Issue_Category__r.Core_Issue_Category_Name__r.Name,Core_Case_Issue_Sub_Category__r.Core_Issue_Sub_Category_Name__r.Name, (select Name, Core_Question__c, Core_Answer__c, Core_Case__c from Environments__r)  FROM case WHERE Id = \'' + csId+ '\'';
            System.debug('Query:'+query);
            return Database.query(query);
        }
        catch(Exception e)
        {
            //Utility.addError('There is error while Fetching existing Question using Dynamic SOQL in Field Set. Error Detail - '+e.getMessage()); //This is Utility Method to display error message on VF Page
            system.debug(e);
            return null;
        }
        return null;
    }
    
    
    public String subCategorySelected{get; set;}
   
    
 
   
        public PageReference cancelCaseDetails(){
          PageReference Pg ; 
          if(ApexPages.currentPage().getParameters().get('retURL') !=null)
          {
                    Pg =  new pageReference(ApexPages.currentPage().getParameters().get('retURL'));   
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
    ****************************************************************************************************/
    public boolean validateEnvironmentDetails(){
        if(envDetails!=null && envDetails.size()>0){
            for(EnvironmentDetail det : envDetails){
                system.debug('Deta ==============' +det);
                
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c &&(det.sPlaceHolder==null || det.sPlaceHolder=='') &&det.required){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                ApexPages.addMessage(myMsg);
                return true;    
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c&&(det.sPlaceHolder !=null || det.sPlaceHolder !='') && det.sPlaceHolder.length()>255){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G111')+':'+det.label);
                ApexPages.addMessage(myMsg);
                return true;    
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c &&(det.tPlaceHolder==null ||det.tPlaceHolder=='')&&det.required){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                ApexPages.addMessage(myMsg);
                return true;
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c && (det.tPlaceHolder != null ||det.tPlaceHolder!='') && det.tPlaceHolder.length()>5000){
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
            return false;
        }
        return false;
    }
        public PageReference saveCaseDetails(){
        //cs = new Case();
        System.debug('Inside Case Save method:'+categorySelected+subCategorySelected);
        if(validateEnvironmentDetails()) return null;
        if(validateCaseRelatedInformation()) return null;
        try{
        Core_IPS_Product_Issue_Category__c ic;
        Core_IPS_Product_Issue_Category__c isc;
        if(categorySelected !=null && categorySelected !=''){
        ic = [select id, name from Core_IPS_Product_Issue_Category__c where id=:categorySelected limit 1];
            cloneCase.Core_External_Issue_Category__c=ic.Name;    
            cloneCase.Core_Case_Issue_Category__c=categorySelected;
        }
        if(subCategorySelected !=null && subCategorySelected !=''){
            isc = [select id, name from Core_IPS_Product_Issue_Category__c where id=:subCategorySelected limit 1];
            cloneCase.Core_External_Issue_Subcategory__c=isc.Name;
            cloneCase.Core_Case_Issue_Sub_Category__c=subCategorySelected;
        }
        //RecordType rt = [select id from RecordType where name = 'IPS Case Create'];
       // cloneCase.RecordTypeId = rt.id;
        
         if(cloneCase.Subject == null || cloneCase.Subject == '' || cloneCase.Core_Severity__c == null || cloneCase.Core_Severity__c == '' || cloneCase.Core_Issue_Description__c == null || cloneCase.Core_Issue_Description__c == '')
         {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please Enter the required Values'));
              return null;
         
         }
         if(DisplayPriorityReason == true && (cloneCase.Core_Severity_Reason__c==null || cloneCase.Core_Severity_Reason__c=='')){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('I111'));
             ApexPages.addMessage(myMsg);
             return null;
         }
          if(cloneCase.Core_Issue_Description__c != null)
                {
                   string  strDescValue =  Core_Utility.replaceSpecialChar(cloneCase.Core_Issue_Description__c);
                          
                   cloneCase.Description = Core_Utility.replaceHtmlTags(strDescValue);
                }  
    if( cloneCase.recordTypeID == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId())
                    {
                        cs.Core_IPS_Self_Assigned__c = true;
                    }
                    else
                    {
                      cs.Core_IPS_Self_Assigned__c = false;
                    }
                    
        if(UserInfo.getUserType() == 'PowerCustomerSuccess')
        {
        cs.Origin = 'Web';
    

        }
                
        upsert cloneCase;
        
            addEnvDetails();
        }catch(DMLException e){
           renderErrorFlag=true;
           ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.Warning, 'Please enter value' + e);
            ApexPages.addMessage(msg);
            System.debug('Error:In Catch' + e);
            //return new PageReference('/apex/Core_IPS_CreateCase?assetId='+ast[0].id);
            return null;
         }    
         //renderErrorFlag=false; 
         System.debug('Error:');
         if(!isAgent){
            return new pageReference('/'+cloneCase.id);
        }else{
            return new pageReference('/'+cloneCase.id);
        }
        //System.debug
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
    ****************************************************************************************************/     
    public void addEnvDetails(){
    // List<Core_IPS_Environment_Details__c> existingDetails = new List<Core_IPS_Environment_Details__c>();
        // existingDetails = [select id from Core_IPS_Environment_Details__c where Core_case__c=:cs.id];
        // system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + existingDetails);
        // if(existingDetails <> null && existingDetails.size()>0){
            // delete ExistingDetails;
        // }
        
        //Added By Yogesh Sharma
        List<Core_IPS_Response__c> envDetailsToCreate = new List<Core_IPS_Response__c>();
        //List<Core_IPS_Environment_Details__c> envDetailsToCreate = new List<Core_IPS_Environment_Details__c>();
        
        if(envDetails!=null && envDetails.size()>0){
            for(EnvironmentDetail det:envDetails){
            	
            	//Added By Yogesh Sharma
                Core_IPS_Response__c detail = new Core_IPS_Response__c();
                //Core_IPS_Environment_Details__c detail = new Core_IPS_Environment_Details__c();
                
                //Added By Yogesh Sharma - Field Not Writable
                //detail.Core_IPS_Question__c= det.label;
                
                //detail.Core_Question__c= det.label;
                 
                //Added By Yogesh Sharma
                detail.Core_IPS_Case__c= cloneCase.id;
                //detail.Core_case__c= cloneCase.id;
                
                //Added By Yogesh Sharma - Field Not Writable  
                //detail.Name = det.label;
                
                //Added By Yogesh Sharma
                detail.Core_IPS_Agent_Only__c = det.IsAgentOnly;
                //detail.Core_Agent_Only__c = det.IsAgentOnly;
                
                system.debug('>>>>>>>>>>>>>' + det.type);
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c){
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c = det.sPlaceHolder;
                    //detail.Core_Answer__c = det.sPlaceHolder;
                    
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c){
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c= det.tPlaceHolder;
                    //detail.Core_Answer__c= det.tPlaceHolder;
                
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ){
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c= det.selectedValue;
                    //detail.Core_Answer__c= det.selectedValue;
                    
                }else if(det.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c){
                    string  strSelectedValue  = '';
                    for(string  str  : det.selectedMValue)
                        { 
                         if(str!='')
                          strSelectedValue = strSelectedValue + str + ';' ;
                        }
                    
                    //Added By Yogesh Sharma    
                    detail.Core_IPS_Answer__c = strSelectedValue;//det.selectedValue;
                    //detail.Core_Answer__c = strSelectedValue;//det.selectedValue;
                    
                }/*else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_check').value__c){
                    if( det.cPlaceHolder)
                        detail.Core_Answer__c= 'True';
                    else
                        detail.Core_Answer__c= 'False'; 
                }*/
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + detail);
                envDetailsToCreate.add(detail);
            }
            if(envDetailsToCreate.size()>0){
                 //insert envDetailsToCreate;
                Core_IPS_AdminUtility.insertEnvDetailsToCreate(envDetailsToCreate);
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
        system.debug('method invoked. DisplayPriorityReason=    '+DisplayPriorityReason);
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
    /*
    
    
    */
    public boolean validateCaseRelatedInformation()
    {
       
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
        if(cloneCase.Core_CaseType__c==null || cloneCase.Core_CaseType__c==''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G109'));
                ApexPages.addMessage(myMsg);
                return true;
        }        
        return false;
    }   
    public Pagereference  PageInit()
    {
      Pagereference Pg =  null;
     if(eoisFlag) 
     {
       pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G113&retURL='+cs.Id);
      
     }else if(isMAG){
         pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G112&retURL='+cs.Id);
         
     }
     else if(isGEC){
       pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G114&retURL='+cs.Id);
     }
     return Pg;
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
    }
    
}