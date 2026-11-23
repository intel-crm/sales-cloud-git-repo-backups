public class Core_IssueCategoryController{
    private id recordId;
    private id currentLoggedInUser;
    private Core_IPS_Product_Issue_Category__c CaseCategoryRecord;
    private Core_IPS_Supported_product__c SupportedProductRecord;
    public string ErrorMessage {get;set;} // used to display custom/business validations
    public list<masterIssueCatSel> issueCategoryList{get;set;} // used in "Core_addIssueCategories"  VF page to display records.
    public list<masterIssueCatSel> issueSubCategoryList{get;set;} // used in "Core_addSubCategories" VF Page to display records.
    
    public Core_IPS_Product_Issue_Category__c caseCategory{get;set;}
    
    /***************************************************************************************************
    Method Name:  Core_IssueCategoryController
    Method Type: Constructor
    Version     : 1.0 
    Created Date: 26 Oct 2015
    Function / Description : Fetch the record id from the visualforce page using standard controller and based on the object, respective methods are called. 
    Input Parameters: None
    Output Parameters: None
    Used in   : Used in "Add Issue Categories" button on Supported Product record, "Add Issue Sub Categories" button on Issue category detail record.
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 2 from getCategories Method and 2 from getSubCategories method.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/26/2015                 Created
    ****************************************************************************************************/
    public Core_IssueCategoryController(ApexPages.standardcontroller controller){
        try{
            currentLoggedInUser = UserInfo.getUserId();
            recordId = controller.getId();
            string objectApi = controller.getRecord().getSObjectType().getDescribe().getName();
            if(objectApi != null){
                
                if(objectApi == Core_IPS_Labels__c.getValues('SupportedProductObjectApi').value__c){
                    getCategories();
                }
                else if(objectApi == Core_IPS_Labels__c.getValues('CaseCategoryObjectApi').value__c){
                    
                    caseCategory = (Core_IPS_Product_Issue_Category__c)controller.getRecord();
                       
                    if(getVFPageName().equalsIgnoreCase('Core_addIssueCategories') || getVFPageName().equalsIgnoreCase('Core_addSubCategories'))
                    {
                     system.debug(getVFPageName());                     
                     getSubCategories();
                    }
                    else
                    {
                         caseCategory = CaseCategoryForEdit(string.valueOf(controller.getId()));
                    }
                }
            }
        }
        catch (Exception Ex){
            ErrorMessage = Core_IPS_Error_Code__c.getValues('G108').Core_Error_Message__c+' '+Ex;
        }
    }
   /***************************************************************************************************
    Method Name:  CaseCategoryForEdit
    Method Type: helper method
    Version     : 1.0 
    Created Date: 11 jan 2016
    Function    : Fetch and Display the Core_IPS_Product_Issue_Category__c  record  for edit
    Input Parameters: None
    Output Parameters: None
    Description: Fetch and Display the Core_IPS_Product_Issue_Category__c  record  for edit
    Used in     : This method invoked by "Constructor".
    Number of Queries Within this Method: 1 queries.
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sunil Chandani          11 jan 2016                Created
    ****************************************************************************************************/
    public Core_IPS_Product_Issue_Category__c CaseCategoryForEdit(string CaseCategoryID)
    {
        string CaseCategorySoql  =  'Select ' ;
        


        for(Schema.FieldSetMember f : Core_Utility.readFieldSet('Case_Category_Edit_Fields','Core_IPS_Product_Issue_Category__c')) {
            
              CaseCategorySoql += f.getFieldPath() + ',';
              
        }
        
        
        CaseCategorySoql += 'id';
        CaseCategorySoql += ' from Core_IPS_Product_Issue_Category__c where id =:CaseCategoryID';
        system.debug(CaseCategorySoql );
        sObject s = Database.query(CaseCategorySoql);
        Core_IPS_Product_Issue_Category__c casecategory = (Core_IPS_Product_Issue_Category__c)s;
        return casecategory;
        

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
    public PageReference getAssignedSubCategory(){
       
        
        checkBusinessRules();
        
         return null;
        
    }
    
    public PageReference SaveCategory(){
       
  
        
        string retUrl = ApexPages.currentPage().getParameters().get('retURL');
        PageReference  Pg =null ;  
        try
        {
          update caseCategory;
        if(retUrl==null || retUrl=='')
        {
           retUrl = '/' + caseCategory.id ;
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
    Method Name:  getSubCategories
    Method Type: helper method
    Version     : 1.0 
    Created Date: 26 Oct 2015
    Function    : Fetch and Display the Master Issue Subcategory records which are available to add to the Case Category record
    Input Parameters: None
    Output Parameters: None
    Description: Fetch and Display the Master Issue Subcategory records which are available to add to the Case Category record, Records which were already added are not displayed in the UI. This method invokes "checkBusinessRules" method to validate the Business rules before displaying the records in UI.
    Used in     : This method invoked by "Constructor" or "addSubCategories" method.
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/26/2015                 Created
    ****************************************************************************************************/
    public void getSubCategories(){
        set<id> existingIds = new set<id>();
        CaseCategoryRecord = [select id,name,Core_Issue_Category_Name__r.Name,Core_Status__c,Core_Supported_Product__c, Core_Supported_Product__r.Core_Product_Organization__r.OwnerId, Core_Supported_Product__r.Core_EOIS__c, (select id, Core_Issue_Sub_Category_Name__c from Product_Issue_Sub_Categories__r where Core_Product_Issue_Category__c =: recordId) from Core_IPS_Product_Issue_Category__c where id =: recordId];
        if(CaseCategoryRecord.Core_Status__c == 'Active')
        {
            for(Core_IPS_Product_Issue_Category__c icRec : CaseCategoryRecord.Product_Issue_Sub_Categories__r){
                existingIds.add(icRec.Core_Issue_Sub_Category_Name__c);
            }
            issueSubCategoryList = new List<masterIssueCatSel>();
            for(Core_IPS_Master_Issue_Category__c mic: [select id,name from Core_IPS_Master_Issue_Category__c where id not in :existingIds and Core_type__c=:Core_IPS_Labels__c.getValues('CaseSubCategory').value__c and Core_Master_Issue_Category__r.Name=:CaseCategoryRecord.Core_Issue_Category_Name__r.Name ORDER BY name]){
                masterIssueCatSel iscSel = new masterIssueCatSel();
                iscSel.selected=false;
                iscSel.masterIssueCat = mic;
                issueSubCategoryList.add(iscSel);                    
            }  
            ErrorMessage = null;
            checkBusinessRules();
        }
        else
            ErrorMessage = Core_IPS_Error_Code__c.getValues('I112').Core_Error_Message__c;            
    }
    /***************************************************************************************************
    Method Name: addSubCategories
    Method Type: Action Method
    Version     : 1.0 
    Created Date: 26 Oct 2015
    Function    : This method creates the Case Subcategory (Child) records for the Case Category (Parent) Record based on the selection of Master Issue Subcategory records.
    Input Parameters: None
    Output Parameters: PageReference (null)
    Description: This method creates the  Case Subcategory (Child) records for the Case Category (Parent) Record. Once the records are created, this method invokes the "getSubCategories" method and loads the page again to display the new available records
    Used in     : This method invoked by "Add Subcategories" command button from Visualforce page.
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 2 from getSubCategories method
    Number of DML Statements : 1
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/26/2015                 Created
    ****************************************************************************************************/
    public PageReference addSubCategories(){
        try{
            List<Core_IPS_Product_Issue_Category__c> isSubCatList = new List<Core_IPS_Product_Issue_Category__c>();
            id CaseCatObjRecordTypeId = schema.sobjecttype.Core_IPS_Product_Issue_Category__c.getrecordtypeinfosbyname().get(Core_IPS_Labels__c.getValues('CaseSubCategory').value__c).getRecordTypeId();
            if(CaseCatObjRecordTypeId != null){
                for(masterIssueCatSel isc:issueSubCategoryList){
                    if(isc.selected){
                        Core_IPS_Product_Issue_Category__c pic = new Core_IPS_Product_Issue_Category__c();
                        pic.Core_Issue_Sub_Category_Name__c= isc.masterIssueCat.id;
                        pic.Core_Product_Issue_Category__c= recordId;
                        pic.recordTypeId=CaseCatObjRecordTypeId; 
                        pic.Core_Status__c = Core_IPS_Labels__c.getValues('CoreStatus_Active').value__c;
                        //pic.Name = isc.masterIssueCat.Name;
                        isSubCatList.add(pic);
                    }
                }
                insert isSubCatList;               
                getSubCategories();
            }
            if(issueSubCategoryList.size()>0)            
                return null;
            else
            {
                PageReference pr = new PageReference('/' + recordId);    
                pr.setRedirect(true);
                return pr;
            }   
        }
        catch (Exception Ex){
            ErrorMessage = Core_IPS_Error_Code__c.getValues('G108').Core_Error_Message__c+' '+Ex;
            return null;
        }
    }
    /***************************************************************************************************
    Method Name:  getCategories
    Method Type: helper method
    Version     : 1.0 
    Created Date: 26 Oct 2015
    Function    : Fetch and Display the Master Issue category records which are available to add to the "Supported Product" record
    Input Parameters: None
    Output Parameters: None
    Description: Fetch and Display the Master Issue category records which are available to add to the "Supported Product" record, Records which were already added are not displayed in the UI. This method invokes "checkBusinessRules" method to validate the Business rules before displaying the records in UI.
    Used in     : This method invoked by "Constructor" or "addIssueCategories" method.
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/26/2015                 Created
    ****************************************************************************************************/
    public void getCategories(){
        set<id> existingIds = new set<id>();
        SupportedProductRecord = [Select id,Core_Product_Organization__c, Core_Product_Organization__r.OwnerId, Core_EOIS__c, (select id, Core_Issue_Category_Name__c from Product_Issue_Categories__r where Core_Supported_Product__c =: recordId) from Core_IPS_Supported_product__c where id =: recordId ];
        for(Core_IPS_Product_Issue_Category__c icRec:SupportedProductRecord.Product_Issue_Categories__r){
           existingIds.add(icRec.Core_Issue_Category_Name__c);
        }
        issueCategoryList = new List<masterIssueCatSel>();
        for(Core_IPS_Master_Issue_Category__c mic: [select id,name from Core_IPS_Master_Issue_Category__c where id not in: existingIds and Core_type__c =:  Core_IPS_Labels__c.getValues('CaseCategory').value__c ORDER BY name]){
            masterIssueCatSel icSel = new masterIssueCatSel();
            icSel.selected=false;
            icSel.masterIssueCat = mic;
            issueCategoryList.add(icSel);
        }
        ErrorMessage = null;
        checkBusinessRules();           
    }   
    /***************************************************************************************************
    Method Name: addIssueCategories
    Method Type: Action Method
    Version     : 1.0 
    Created Date: 26 Oct 2015
    Function    : This method creates the Case category (Child) records for the "Supported Product" (Parent) Record based on the selection of Master Issue category records.
    Input Parameters: None
    Output Parameters: PageReference (null)
    Description: This method creates the  Case category (Child) records for the "Supported Product" (Parent) Record. Once the records are created, this method invokes the "getCategories" method and loads the page again to display the new available records
    Used in     : This method invoked by "Add Categories" command button from Visualforce page.
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 2 from getCategories method
    Number of DML Statements : 1
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/26/2015                 Created
    ****************************************************************************************************/
    public PageReference addIssueCategories(){
        try{
            List<Core_IPS_Product_Issue_Category__c> isCatList = new List<Core_IPS_Product_Issue_Category__c>();
            id CaseCatObjRecordTypeId = schema.sobjecttype.Core_IPS_Product_Issue_Category__c.getrecordtypeinfosbyname().get(Core_IPS_Labels__c.getValues('CaseCategory').value__c).getRecordTypeId();
            if(CaseCatObjRecordTypeId != null){
                for(masterIssueCatSel ic:issueCategoryList){
                    if(ic.selected){
                        Core_IPS_Product_Issue_Category__c pic = new Core_IPS_Product_Issue_Category__c();
                        pic.Core_Issue_Category_Name__c = ic.masterIssueCat.id;
                        pic.Core_Supported_Product__c = recordId;
                        pic.Core_Status__c = Core_IPS_Labels__c.getValues('CoreStatus_Active').value__c;
                        pic.recordTypeId=CaseCatObjRecordTypeId;
                        //pic.Name = ic.masterIssueCat.Name;
                        isCatList.add(pic);
                    }
                }
                insert isCatList;              
                getCategories();
            }
            if(issueCategoryList.size()>0)            
                return null;
            else
            {
                PageReference pr = new PageReference('/' + recordId);    
                pr.setRedirect(true);
                return pr;
            }    
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
                     If issue category List is empty
                 This method validates the below scenarios for issue Category:
                     Current Logged In user is not authorized to add the issue categories or not. Check is based on Organization ownership.
                     If the supported product is EOIS, issue Sub categories cannot be added.
                     If issue Sub category List is empty
    Used in     : Add Issue Categories button on Supported Product, Add Issue Sub Categories button on Issue category detail record.
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods: 2 (if Prod Org is owned by Queue And Queue holds only one public group and public group have list of users.)
    Modification Log :
    Version 1.1 : Moved the common code logic to Core_IPS_Helper_Utility class (method name : GetSetOfUsersbyQueueID). Handling the Exceptions using try catch.
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    * Syed Moosa Nazir TN        10/28/2015              Modified
    ****************************************************************************************************/      
public PageReference checkBusinessRules(){
        try{
            if(SupportedProductRecord != null){
                Set<id> SetOfUserId = new Set<id> ();
                SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(SupportedProductRecord.Core_Product_Organization__r.OwnerId);
                if(!SetOfUserId.contains(currentLoggedInUser)){
                    // Current Logged In user not authorized to access the page.
                    ErrorMessage = Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c;
                    return null;
                }
                if(SupportedProductRecord.Core_EOIS__c == true){
                    // Core_EOIS__c Error Message from Custom Setting. Cannot add as the Supported Product is EOL'ed
                    ErrorMessage = Core_IPS_Error_Code__c.getValues('I107').Core_Error_Message__c;
                    return null;
                }
                if(issueCategoryList.isEmpty()){
                    ErrorMessage = Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                    return null;
                }
            }
            else if(CaseCategoryRecord != null){
                if(CaseCategoryRecord.Core_Supported_Product__c != null){
                    Set<id> SetOfUserId = new Set<id> ();
                    SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(CaseCategoryRecord.Core_Supported_Product__r.Core_Product_Organization__r.OwnerId);
                    if(!SetOfUserId.contains(currentLoggedInUser)){
                        // Current Logged In user not authorized to access the page.
                        ErrorMessage = Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c;
                        return null;
                    }
                    if(CaseCategoryRecord.Core_Supported_Product__r.Core_EOIS__c == true){
                        // Core_EOIS__c Error Message from Custom Setting. Cannot add as the Supported Product is EOL'ed
                        ErrorMessage = Core_IPS_Error_Code__c.getValues('I107').Core_Error_Message__c;
                        return null;
                    }
                    if(issueSubCategoryList.isEmpty()){
                        ErrorMessage = Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                        return null;
                    }
                }
                else{   
                    ErrorMessage = Core_IPS_Error_Code__c.getValues('I109').Core_Error_Message__c;
                    return null;
                }
            }
            return null;
        }
        catch (Exception Ex){
            ErrorMessage = Core_IPS_Error_Code__c.getValues('G108').Core_Error_Message__c+' '+Ex;
            return null;    
        }
        return null;
    }
   
    public string getVFPageName()  
    {
    // THIS IS THE CLOSEST YOU CAN GET SO FAR
    string pageName = ApexPages.CurrentPage().getUrl();  
    // IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
    pageName = pageName.replaceFirst('/apex/','');         
    pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');  
    // %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8 
    string[] pageNameExtra = pageName.split('%3F',0);   
    // SO YOU MAY SPLIT THE STRING AT THAT POINT
      // FOR THIS PURPOSE YOU ONLY NEED THE FIRST
    // IN THE RESULTING ARRAY
    pageName = pageNameExtra[0]; 
    // HERE IS YOUR PRODUCT  
    system.debug('pageName-->'+pageName);                       
    return pageName;                                        
   }
    /***************************************************************************************************
    Wrapper Class Name: masterIssueCatSel
    Version     : 1.0 
    Created Date: 26 Oct 2015
    Function / Description    : This wrapper class is used for constructing components for Core_addIssueCategories and Core_addSubCategories Visualforce pages.
    Used in     : Core_addIssueCategories and Core_addSubCategories Visualforce pages.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       10/26/2015                 Created
    ****************************************************************************************************/
    @TestVisible private class masterIssueCatSel{
        public boolean selected{get;set;}
        public Core_IPS_Master_Issue_Category__c masterIssueCat{get;set;}
    }
}