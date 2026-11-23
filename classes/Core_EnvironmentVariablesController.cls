public with sharing class Core_EnvironmentVariablesController{
    private id recordId;
    private string objectApi;
    private id currentLoggedInUser;
    private Core_IPS_Environment_Variables__c EnvVariableRecord; // used for Core_addEnvToProducts Visualforce Page
    private Core_IPS_Product_Issue_Category__c CaseCategoryRecord; // used for Core_addEnvironmentDetailsToIssueSubCat Visualforce Page
    private Core_IPS_Supported_product__c SupportedProductRecord; // used for Core_addEnvironmentDetailsToProduct Visualforce Page
    public String searchText{get;set;} // Search String. Provided by the End User in UI
    public string ErrorMessage {get;set;} // used to display Error Message in UI 
    public List<ProductsSel> supProductList{get;set;} // used in "Core_addEnvToProducts" VF page to display records.
    public List<EnvironmentVarSel> envDetails{get;set;} // used in "Core_addEnvironmentDetailsToProduct" and "Core_addEnvironmentDetailsToIssueSubCat" VF pages to display records.
    public Core_IPS_Assigned_Environment_Variables__c aev{get;set;}
    public Apexpages.standardController Controller; 
    
    /***************************************************************************************************
    Method Name:  Core_EnvironmentVariablesController
    Method Type: Constructor
    Version     : 1.0 
    Created Date: 28 Oct 2015
    Function / Description : Fetch the record id from the visualforce page using standard controller and based on the object, respective methods are called. 
    Input Parameters: None
    Output Parameters: None
    Used in   : Used in "Core_addEnvToProducts", "Core_addEnvironmentDetailsToProduct" and "Core_addEnvironmentDetailsToIssueSubCat" visualforce pages
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 3 from "getEnvironmentVariables_SupProd" Method, 3 from "getEnvironmentVariables_CaseCat" Method and 3 from "getSupportedProducts" Method . Only one method will get executed with maximum of 2 queries at a time .
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015                 Created
    ****************************************************************************************************/
    public Core_EnvironmentVariablesController(Apexpages.standardController controller){
        try{
            
            currentLoggedInUser = UserInfo.getUserId();
            recordId = controller.getId();
            objectApi = controller.getRecord().getSObjectType().getDescribe().getName();
            //this.Controller = controller;
            if(objectApi != null){
                if(objectApi == Core_IPS_Labels__c.getValues('SupportedProductObjectApi').value__c){
                    // Visualforce Page : Core_addEnvironmentDetailsToProduct
                    getEnvironmentVariables_SupProd();
                }
                else if(objectApi == Core_IPS_Labels__c.getValues('CaseCategoryObjectApi').value__c){
                    // Visualforce Page : Core_addEnvironmentDetailsToIssueSubCat
                    getEnvironmentVariables_CaseCat();
                }
                else if(objectApi == Core_IPS_Labels__c.getValues('EnvironmentalDetailMasterObjectApi').value__c){
                    // Visualforce Page : Core_addEnvToProducts
                    getSupportedProducts();
                    
                }   
                else if(objectApi == Core_IPS_Labels__c.getValues('Assigned_Environment_Variables').value__c){
                
                    aev = (Core_IPS_Assigned_Environment_Variables__c )controller.getRecord();
                    
                    
                 }  
            }
        }
        catch (Exception Ex){
        
            ErrorMessage = Core_IPS_Error_Code__c.getValues('G108').Core_Error_Message__c+' '+Ex;
        }
    }
    /***************************************************************************************************
    Method Name:  getEnvironmentVariables_CaseCat
    Method Type: Action Method and helper method
    Version     : 1.0 
    Created Date: 28 Oct 2015
    Function    : Fetch and Display the Env. Detail Master records which are available to add to the Case Category record
    Input Parameters: None
    Output Parameters: pagereference (null) .Reloads the Page.
    Description: Fetch and Display the Env. Detail Master records which are available to add to the Case Category record, Records which were already added are not displayed in the UI.
                    This method invokes "checkBusinessRules" method to validate the Business rules before displaying the records in UI.
                    This method is also called by "Search" Command button from Visualforce page.
                    Based on the User search input, records are fetched and displayed in the UI.
    Used in     : This method invoked by "Constructor" or "addEnvironmentVariables" method or by Visualforce Command button (Search functionality).
    Number of Queries Within this Method: 3. But maximum 2 queries executes at a time.
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015                 Created
    ****************************************************************************************************/
    public pagereference getEnvironmentVariables_CaseCat(){
        try{
            //FLS Check Added- Nishitha
            if(Core_IPS_Product_Issue_Category__c.SObjectType.getDescribe().isAccessible()){
                CaseCategoryRecord = [Select id,Name,Core_Issue_Sub_Category_Name__c,Core_Status__c,Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__c, Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__r.OwnerID, Core_Product_Issue_Category__c, ( select id, Core_Agent_Only__c,Core_Environment_Variable__c,Core_Required__c,Core_Supported_Product__c,Core_Type__c,Core_Status__c from Environment_Detail_Operationals__r where Core_Product_Issue_Sub_Category__c =: recordId) from Core_IPS_Product_Issue_Category__c where (id =: recordId)];
            }
            set<id> existingIds = new set<id>();
            if(CaseCategoryRecord.Core_Status__c == 'Active')
            {
                for(Core_IPS_Assigned_Environment_Variables__c env:CaseCategoryRecord.Environment_Detail_Operationals__r){
                    existingIds.add(env.Core_Environment_Variable__c);
                }
                List<Core_IPS_Environment_Variables__c> masterEnvList;
                if(searchText != null && searchText.trim() != ''){
                    String srchString = '%'+searchText+'%';
                    //FLS Check Added- Nishitha
                    if(Core_IPS_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){
                        masterEnvList= [select id,name from Core_IPS_Environment_Variables__c where (id not in :existingIds and Core_Product_Organization__c =: CaseCategoryRecord.Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__c and Core_Status__c !=: Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c and name like : srchString ) ORDER BY name];
                    }
                }
                else{
                    //FLS Check Added- Nishitha
                    if(Core_IPS_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){
                        masterEnvList= [select id,name from Core_IPS_Environment_Variables__c where (id not in :existingIds and Core_Product_Organization__c =: CaseCategoryRecord.Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__c and Core_Status__c !=: Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c) ORDER BY name];
                    }
                }
                envDetails = new List<EnvironmentVarSel>();
                for(Core_IPS_Environment_Variables__c env: masterEnvList){
                    EnvironmentVarSel envSel = new EnvironmentVarSel();
                    envSel.selected=false;
                    envSel.env= env;
                    envSel.required=false;
                    envSel.agentOnly=false;
                    envDetails.add(envSel);
                }   
                ErrorMessage = null;
                checkBusinessRules();
            }
            else
                ErrorMessage = Core_IPS_Error_Code__c.getValues('I113').Core_Error_Message__c;      
            return null;
        }
        catch (Exception Ex){
            ErrorMessage = Core_IPS_Error_Code__c.getValues('G108').Core_Error_Message__c+' '+Ex;
            return null;
        }
    }
    /***************************************************************************************************
    Method Name:  getEnvironmentVariables_SupProd
    Method Type: Action Method and helper method
    Version     : 1.0 
    Created Date: 28 Oct 2015
    Function    : Fetch and Display the Env. Detail Master records which are available to add to the Supported Product record
    Input Parameters: None
    Output Parameters: pagereference (null). Reloads the Page.
    Description: Fetch and Display the Env. Detail Master records which are available to add to the Supported Product record, Records which were already added are not displayed in the UI.
                    This method invokes "checkBusinessRules" method to validate the Business rules before displaying the records in UI.
                    This method is also called by "Search" Command button from Visualforce page.
                    Based on the User search input, records are fetched and displayed in the UI.
    Used in     : This method invoked by "Constructor" or "addEnvironmentVariables" method or by Visualforce Command button (Search functionality).
    Number of Queries Within this Method: 3. But maximum 2 queries executes at a time.
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015                 Created
    ****************************************************************************************************/
    public pagereference getEnvironmentVariables_SupProd(){
        try{
            //FLS Check Added- Nishitha
            if(Core_IPS_Supported_product__c.SObjectType.getDescribe().isAccessible()){
                SupportedProductRecord = [Select id,Core_Product_Organization__c, Core_Product_Organization__r.OwnerId, Core_EOIS__c, (select id, Core_Agent_Only__c,Core_Environment_Variable__c,Core_Required__c,Core_Supported_Product__c,Core_Type__c,Core_Status__c from Environment_Detail_Operationals__r where (Core_Status__c !=: Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c and Core_Supported_Product__c=: recordId)) from Core_IPS_Supported_product__c where id =: recordId];
            }
            set<id> existingIds = new set<id>();
            for(Core_IPS_Assigned_Environment_Variables__c env : SupportedProductRecord.Environment_Detail_Operationals__r){
               existingIds.add(env.Core_Environment_Variable__c);
            }
            List<Core_IPS_Environment_Variables__c> masterEnvList;
            if(searchText != null && searchText.trim() != ''){
                String srchString = '%'+searchText+'%';
                //FLS Check Added- Nishitha
                if(Core_IPS_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){
                    masterEnvList= [select id,name from Core_IPS_Environment_Variables__c where (id not in :existingIds and Core_Product_Organization__c =: SupportedProductRecord.Core_Product_Organization__c and Core_Status__c !=: Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c and name like : srchString ) ORDER BY name];
                }
            }
            else{
                //FLS Check Added- Nishitha
                if(Core_IPS_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){
                    masterEnvList= [select id,name from Core_IPS_Environment_Variables__c where (id not in :existingIds and Core_Product_Organization__c =: SupportedProductRecord.Core_Product_Organization__c and Core_Status__c !=: Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c) ORDER BY name];
                }
            }
            envDetails = new List<EnvironmentVarSel>();
            for(Core_IPS_Environment_Variables__c env: masterEnvList){
                EnvironmentVarSel envSel = new EnvironmentVarSel();
                envSel.selected=false;
                envSel.env= env;
                envSel.required=false;
                envSel.agentOnly=false;
                envDetails.add(envSel);
            }
            ErrorMessage = null;
            checkBusinessRules();
            return null;
        }
        catch (Exception Ex){
            ErrorMessage = Core_IPS_Error_Code__c.getValues('G108').Core_Error_Message__c+' '+Ex;
            return null;
        }
    }
    /***************************************************************************************************
    Method Name: addEnvironmentVariables
    Method Type: Action Method
    Version     : 1.0 
    Created Date: 28 Oct 2015
    Function    : This method creates the "Environmental Detail Master Detail" (child) records for either "Supported Products" or "Case Sub Category" (Parent) Records.
    Input Parameters: None
    Output Parameters: PageReference (null).
    Description: This method creates the "Environmental Detail Master Detail" (child) records for either "Supported Products" or "Case Sub Category" (Parent) Records. Upon record creation, page displays the remaining "Environmental Detail Master Detail" records (if available) to add to the Parent record.
    Used in     : This method invoked by "Add Environment Variables" command button from Visualforce page. This method is used as a Common method for two visaulforce pages. "Core_addEnvironmentDetailsToIssueSubCat" and "Core_addEnvironmentDetailsToProduct" VF pages.
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 3 queries from "getEnvironmentVariables_SupProd" method and 3 queries from "getEnvironmentVariables_CaseCat" method. But maximum 2 queries executes at a time.
    Number of DML Statements : 1
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015                 Created
    ****************************************************************************************************/
    public pagereference addEnvironmentVariables(){
        List<Core_IPS_Assigned_Environment_Variables__c> envTempList = new List<Core_IPS_Assigned_Environment_Variables__c>();
        for(EnvironmentVarSel env:envDetails){
            if(env.selected){
                Core_IPS_Assigned_Environment_Variables__c aEnv = new Core_IPS_Assigned_Environment_Variables__c();
                aEnv.Core_Required__c= env.required;
                aEnv.Core_Agent_Only__c= env.agentOnly;
                aEnv.Core_Status__c = Core_IPS_Labels__c.getValues('CoreStatus_Active').value__c;
                if(objectApi == Core_IPS_Labels__c.getValues('SupportedProductObjectApi').value__c){
                    aEnv.Core_Supported_Product__c= SupportedProductRecord.id;
                    aEnv.Core_Type__c= Core_IPS_Labels__c.getValues('CoreType_Product').value__c;
                }else if(objectApi == Core_IPS_Labels__c.getValues('CaseCategoryObjectApi').value__c){
                    aEnv.Core_Product_Issue_Sub_Category__c= CaseCategoryRecord.id;
                    aEnv.Core_Type__c = Core_IPS_Labels__c.getValues('CoreType_Issue_Sub_Category').value__c;
                }
                aEnv.Core_Environment_Variable__c= env.env.id;
                //aEnv.name = env.env.name;
                envTempList.add(aEnv);
            }
        }
        insert envTempList;
        searchText = '';
        ErrorMessage = null;
        if(objectApi == Core_IPS_Labels__c.getValues('SupportedProductObjectApi').value__c){
            getEnvironmentVariables_SupProd();
        }
        else if(objectApi == Core_IPS_Labels__c.getValues('CaseCategoryObjectApi').value__c){
            getEnvironmentVariables_CaseCat();
        }
        if(envDetails.size()>0)            
            return null;
        else
        {
            PageReference pr = new PageReference('/' + recordId);    
            pr.setRedirect(true);
            return pr;
        } 
    }
      /***************************************************************************************************
    Method Name:  getAssignedEnvironmentVariables
    Method Type: helper method
    Version     : 1.0 
    Created Date: 8 Dec 2015
    Function    : Fetch and Display the "Supported Product" records which are available to add to the Env. Detail Master record.
    Input Parameters: None
    Output Parameters: None
    Description: Fetch and Display the "Supported Product" records which are available to add to the Env. Detail Master record.
    Used in     : This method invoked by "Constructor".
    Number of Queries Within this Method: 2 queries.
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015                 Created
    ****************************************************************************************************/
    public PageReference getAssignedEnvironmentVariables(){
       
        PageReference  Pg ;    
        checkBusinessRules();
        
         return null;
        
    }
    public PageReference saveEvn() {
        
        string retUrl = ApexPages.currentPage().getParameters().get('retURL');
        PageReference  Pg =null ;  
        try
        {
          update aev;
        if(retUrl==null || retUrl=='')
        {
           retUrl = '/' + aev.id ;
        }
        
         Pg =  new PageReference(retUrl);
         Pg.setredirect(true);
         return Pg;
        }
        catch(exception ex)
        {
          return pg;
        }
         
       
        
    }
    /***************************************************************************************************
    Method Name:  getSupportedProducts
    Method Type: helper method
    Version     : 1.0 
    Created Date: 28 Oct 2015
    Function    : Fetch and Display the "Supported Product" records which are available to add to the Env. Detail Master record.
    Input Parameters: None
    Output Parameters: None
    Description: Fetch and Display the "Supported Product" records which are available to add to the Env. Detail Master record.
    Used in     : This method invoked by "Constructor".
    Number of Queries Within this Method: 2 queries.
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015                 Created
    ****************************************************************************************************/
    public void getSupportedProducts(){
        //FLS Check Added- Nishitha
        if(Core_IPS_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){
            EnvVariableRecord = [select id, name, Core_Status__c, Core_Product_Organization__c, Core_Product_Organization__r.ownerId, (select id,Core_Supported_Product__c, Core_supported_product__r.name, Core_Required__c, Core_Agent_Only__c, Core_Status__c from Environment_Detail_Operationals__r where Core_Environment_Variable__c =: recordId AND Core_Supported_Product__c != null) from Core_IPS_Environment_Variables__c where id =: recordId];
        }
        set<id> existingIds = new set<id>();
        for(Core_IPS_Assigned_Environment_Variables__c envT: EnvVariableRecord.Environment_Detail_Operationals__r){
            existingIds.add(envT.Core_Supported_Product__c);
        }
        supProductList = new List<ProductsSel>();
        //FLS Check Added- Nishitha
        if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){
            for(Core_IPS_Supported_Product__c sp: [select id,name,Core_Supported_Product_Name__c from Core_IPS_Supported_Product__c where Core_Product_Organization__c =: EnvVariableRecord.Core_Product_Organization__c and id not in: existingIds and Core_EOIS__c = false ORDER BY Core_Supported_Product_Name__c]){
                ProductsSel prodSel = new ProductsSel();
                prodSel.selected=false;
                prodSel.prod= sp;
                prodSel.required=false;
                prodSel.agentOnly=false;
                prodSel.existingref=false;
                supProductList.add(prodSel);
            }
        }
        ErrorMessage = null;
        checkBusinessRules();
    }
    /***************************************************************************************************
    Method Name: addToProducts
    Method Type: Action Method
    Version     : 1.0 
    Created Date: 28 Oct 2015
    Function    : This method creates the "Environmental Detail Operational" (child) records for "Environmental Detail Master Detail" (Parent) Records.
    Input Parameters: None
    Output Parameters: PageReference (null). Page redirects to the Parent record.
    Description: This method creates the "Environmental Detail Operational" (child) records for "Environmental Detail Master Detail" (Parent) Record. Upon record creation, redirects to the "Environmental Detail Master Detail" record.
    Used in     : This method invoked by "Add to Products" command button from Visualforce page.
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 1 upsert statement
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015                 Created
    ****************************************************************************************************/
    public PageReference addToProducts(){
        try{
            List<Core_IPS_Assigned_Environment_Variables__c> envTempList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            for(ProductsSel prodSel : supProductList){
                if(prodSel.selected){
                    Core_IPS_Assigned_Environment_Variables__c aEnv = new Core_IPS_Assigned_Environment_Variables__c();
                    
                    aEnv.Core_Required__c= prodSel.required;
                    aEnv.Core_Agent_Only__c= prodSel.agentOnly;
                    aEnv.Core_Status__c = Core_IPS_Labels__c.getValues('CoreStatus_Active').value__c;
                    if(!prodSel.existingref)
                    aEnv.Core_Supported_Product__c= prodSel.prod.id;
                    aEnv.Core_Type__c= Core_IPS_Labels__c.getValues('CoreType_Product').value__c; // Important Note : Picklist values are not available in the Field. Need to discuss with JP. By Syed
                    aEnv.Core_Environment_Variable__c= EnvVariableRecord.id;
                    //aEnv.name = EnvVariableRecord.name;
                    envTempList.add(aEnv);
                }
            }
            upsert envTempList;
            return new PageReference('/'+EnvVariableRecord.id);
        }
        catch (Exception Ex){
            ErrorMessage = Core_IPS_Error_Code__c.getValues('G108').Core_Error_Message__c+' '+Ex;
            return null;
        }
    }
    /***************************************************************************************************
    Version     : 1.1
    Created Date: 09 Oct 2015
    Function    : Custom validation rules based on logged in users
    Input Parameters: None
    Output Parameters: Reloads page with Error message.
    Description: This method validates the below scenarios for Supported Product:
                     Current Logged In user is not authorized to add the issue categories or not. Check is based on Organization ownership.
                     If the supported product is EOIS, issue categories cannot be added.
                     If envDetails list is empty
                 This method validates the below scenarios for Issue sub Category:
                     Current Logged In user is not authorized to add Env. Variables or not. Check is based on Organization ownership.
                     If envDetails List is empty
                     If Case Category Record not associated with Supported Product
                     If Case Sub Category Record not associated with Case Category Record 
                 This method validates the below scenarios for Environmental Detail Master Record:  
                    Current Logged In user not authorized to access the page (Add to Product)
                    If Env. Detail Master record status if Inactive. Error displayed.
                    if (Supported Product) records to display in the UI is empty
    Used in     : Invoked by "getSupportedProducts",  "getEnvironmentVariables_SupProd" and "getEnvironmentVariables_CaseCat" methods
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods: 2 queries (if Prod Org is owned by Queue And Queue holds only one public group and public group have list of users.)
    Modification Log :
    Version 1.1 : Moved the common code logic to Core_IPS_Helper_Utility class (method name : GetSetOfUsersbyQueueID). Handling the Exceptions using try catch.
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015              Created
    ****************************************************************************************************/
    public PageReference checkBusinessRules(){
        try{
            if(EnvVariableRecord != null){
                Set<id> SetOfUserId = new Set<id> ();
                SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(EnvVariableRecord.Core_Product_Organization__r.OwnerId);
                List<User> lstUser = [select profile.name from User where id=:UserInfo.getUserid()];
                if((System.Label.Core_IPS_Button_Override_ITAdmins).contains(lstUser[0].profile.name) == False)
                {
                    if(!SetOfUserId.contains(currentLoggedInUser)){
                        // Current Logged In user not authorized to access the page.
                        ErrorMessage = Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c;
                        return null;
                    }    
                }
                if(EnvVariableRecord.Core_Status__c == Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c){
                    ErrorMessage = Core_IPS_Error_Code__c.getValues('I108').Core_Error_Message__c;
                    return null;
                }
                if(supProductList.isEmpty()){
                    ErrorMessage = Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                    return null;
                }
            } 
            else if(SupportedProductRecord != null){
                Set<id> SetOfUserId = new Set<id> ();
                SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(SupportedProductRecord.Core_Product_Organization__r.OwnerId);
                List<User> lstUser = [select profile.name from User where id=:UserInfo.getUserid()];
                if((System.Label.Core_IPS_Button_Override_ITAdmins).contains(lstUser[0].profile.name) == False)
                {
                    if(!SetOfUserId.contains(currentLoggedInUser)){
                        // Current Logged In user not authorized to access the page.
                        ErrorMessage = Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c;
                        return null;
                    }    
                }
                if(SupportedProductRecord.Core_EOIS__c == true){
                    // Core_EOIS__c Error Message from Custom Setting. Cannot add as the Supported Product is EOL'ed
                    ErrorMessage = Core_IPS_Error_Code__c.getValues('I107').Core_Error_Message__c;
                    return null;
                }
                if(envDetails.isEmpty()){
                    ErrorMessage = Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                    return null;
                }
            }
            else if(CaseCategoryRecord != null){
                if(CaseCategoryRecord.Core_Product_Issue_Category__c != null){
                    if(CaseCategoryRecord.Core_Product_Issue_Category__r.Core_Supported_Product__c  != null){
                        Set<id> SetOfUserId = new Set<id> ();
                        SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(CaseCategoryRecord.Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__r.OwnerID);
                        List<User> lstUser = [select profile.name from User where id=:UserInfo.getUserid()];
                        if((System.Label.Core_IPS_Button_Override_ITAdmins).contains(lstUser[0].profile.name) == False)
                        {
                            if(!SetOfUserId.contains(currentLoggedInUser)){
                                // Current Logged In user not authorized to access the page.
                                ErrorMessage = Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c;
                                return null;
                            }   
                        }
                        if(envDetails.isEmpty()){
                            ErrorMessage = Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                            return null;
                        }
                    }
                    else{ 
                        // Case Category Record not associated with Supported Product           
                        ErrorMessage = Core_IPS_Error_Code__c.getValues('I109').Core_Error_Message__c;
                        return null;
                    }
                }
                else{
                    // Case Sub Category Record not associated with Case Category Record    
                    ErrorMessage = Core_IPS_Error_Code__c.getValues('I110').Core_Error_Message__c;
                    return null;
                }
            }
            return null;
        }
        catch (Exception Ex){
        
            ErrorMessage = Core_IPS_Error_Code__c.getValues('G108').Core_Error_Message__c+' '+Ex;
            return null;    
        }
        //return null;
    }
    /***************************************************************************************************
    Wrapper Class Name: EnvironmentVarSel
    Version     : 1.0 
    Created Date: 28 Oct 2015
    Function / Description    : This wrapper class is used for constructing components for "Core_addEnvironmentDetailsToProduct" and "Core_addEnvironmentDetailsToIssueSubCat" VF pages
    Used in     : "Core_addEnvironmentDetailsToProduct" and "Core_addEnvironmentDetailsToIssueSubCat" VF pages
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015                 Created
    ****************************************************************************************************/
    public class EnvironmentVarSel{
        public boolean selected{get;set;}
        public Core_IPS_Environment_Variables__c env{get;set;}
        public boolean agentOnly{get;set;}
        public boolean required{get;set;}
    }
    
    /***************************************************************************************************
    Wrapper Class Name: ProductsSel
    Version     : 1.0 
    Created Date: 28 Oct 2015
    Function / Description    : This wrapper class is used for constructing components for "Core_addEnvToProducts" VF pages
    Used in     : "Core_addEnvToProducts" VF pages
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/28/2015                 Created
    ****************************************************************************************************/
    public class ProductsSel{
        public boolean selected{get;set;}
        public Core_IPS_Supported_Product__c prod{get;set;}
        public Id prodId{get;set;}
        public boolean agentOnly{get;set;}
        public boolean required{get;set;}
        public boolean existingref{get;set;}
        public String prodName{get;set;}
    }
}