public with sharing class Core_IPS_CaseUtility {
    Public Static Map<Id,Core_IPS_Supported_Product__c> GlobalProductRecords = new Map<Id,Core_IPS_Supported_Product__c>();// code Refactor 
    
     public static String mode=null;
    /* 
    *    Utility class to pull supported products
    */
    
    public static List<Supported_product> getSupportedProduct(String assetId, String productOrganizationId){
        List<Supported_product> ab = new List<Supported_product>();
        //FLS Check Added - Yasasvi
        if(Core_IPS_supported_product__c.SObjectType.getDescribe().isAccessible()){
            for(Core_IPS_supported_product__c a:[SELECT id, name FROM Core_IPS_supported_product__c where
                                                 Core_Product_Organization__r.name=: productOrganizationId and Core_Product__c =: assetId  ]){
                                                     ab.add(new supported_product (a.id, a.name));        
                                                 }
        }
        return ab;
        
        //   return [select Core_supported_product__c, supported_product__r.Product__r.name  FROM IPS_Product__c where IPS_Project__c =: projectSelected ];
    }
    
   /***************************************************************************************************
    Apex Method Name: getSubCategories 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This method returns SubCategories associated to a category
    Input Parameters: categoryid
    Output Parameters: List of issue sub categories
    Description: Returns sub categories associatd to a category
    Used in     : 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/     
    public static List<Core_IPS_Product_Issue_Category__c> getSubCategories(String issueCategoryId){
        List<Core_IPS_Product_Issue_Category__c> coreIPSProductIssueCategoryInfo=new List<Core_IPS_Product_Issue_Category__c>();
        if(issueCategoryId!=null && issueCategoryid!=''){
            //FLS Check Added - Yasasvi
            if(Core_IPS_Product_Issue_Category__c.SObjectType.getDescribe().isAccessible()){
                coreIPSProductIssueCategoryInfo = (List<Core_IPS_Product_Issue_Category__c>) Core_IPS_QueryService.queryRecords(
                    'SELECT id,name,core_issue_category_Name__c,Core_Issue_Sub_Category_Name__r.Name,Core_Issue_Category_Name__r.Name FROM Core_IPS_Product_Issue_Category__c WHERE Core_Product_Issue_Category__c = :issueCategoryId and core_status__c != \'Inactive\'',
                    new Map<String, Object>{'issueCategoryId' => issueCategoryId});
                    //coreIPSProductIssueCategoryInfo = [SELECT id,name,core_issue_category_Name__c,Core_Issue_Sub_Category_Name__r.Name,Core_Issue_Category_Name__r.Name FROM Core_IPS_Product_Issue_Category__c WHERE Core_Product_Issue_Category__c =:issuecategoryId and core_status__c!='Inactive' ];
            }
            return coreIPSProductIssueCategoryInfo;
        }
        return null;
    }
    
   /***************************************************************************************************
    Apex Method Name: getCategories 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This method returns SubCategories associated to a category
    Input Parameters: supported product id
    Output Parameters: List of issue categories
    Description: Returns list of categories associatd to a supported product
    Used in     : 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/    
    public static List<Core_IPS_Product_Issue_Category__c> getCategories(String productId){
        system.debug('productId'+productId);
        List<Core_IPS_Product_Issue_Category__c> coreIPSProductIssueCategory=new List<Core_IPS_Product_Issue_Category__c>();
        if(productId!=null && productId!=''){
            //FLS Check Added - Yasasvi
            if(Core_IPS_Product_Issue_Category__c.SObjectType.getDescribe().isAccessible()){
                coreIPSProductIssueCategory = (List<Core_IPS_Product_Issue_Category__c>) Core_IPS_QueryService.queryRecords('SELECT id, Name,Core_Issue_Category_Name__c, Core_Issue_Category_Name__r.name FROM Core_IPS_Product_Issue_Category__c where Core_supported_product__c = :productId and core_status__c != \'Inactive\'', new Map<String, Object>{'productId' => productId});
                //coreIPSProductIssueCategory = [SELECT id, Name,Core_Issue_Category_Name__c, Core_Issue_Category_Name__r.name FROM Core_IPS_Product_Issue_Category__c where Core_supported_product__c =: productId and core_status__c!='Inactive'];
            system.debug('coreIPSProductIssueCategory'+coreIPSProductIssueCategory);
            }
            return coreIPSProductIssueCategory;
        } 
        return null;
    }

   /***************************************************************************************************
    Apex Method Name: getSubCategories 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This method returns SubCategories associated to a category
    Input Parameters: categoryid, supported product id
    Output Parameters: List of issue sub categories
    Description: Returns sub categories associatd to a category
    Used in     : 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/       
    public static List<IssueSubCategories> getSubCategories(String issuecategoryId, String supportedProductId){
        List<IssueSubCategories> ab = new List<IssueSubCategories>();
        //FLS Check Added - Yasasvi
        if(Core_IPS_Product_Issue_Category__c.SObjectType.getDescribe().isAccessible()){
            List<Core_IPS_Product_Issue_Category__c> issueSubCategoryRecords = (List<Core_IPS_Product_Issue_Category__c>) Core_IPS_QueryService.queryRecords('SELECT id,name,Core_Issue_Category_Name__r.Name,Core_Issue_Sub_Category_Name__r.Name FROM Core_IPS_Product_Issue_Category__c where Core_Product_Issue_Category__c = :issuecategoryId and Core_Supported_Product__c = :SupportedProductId and core_status__c != \'Inactive\'', new Map<String, Object>{'issuecategoryId' => issuecategoryId, 'SupportedProductId' => supportedProductId});
            for(Core_IPS_Product_Issue_Category__c a : issueSubCategoryRecords){
                                                           ab.add(new IssueSubCategories(a.id, a.name));        
                                                       }
            /*for(Core_IPS_Product_Issue_Category__c a: [SELECT id,name,Core_Issue_Category_Name__r.Name,Core_Issue_Sub_Category_Name__r.Name FROM Core_IPS_Product_Issue_Category__c where 
                                                       Core_Product_Issue_Category__c=: issuecategoryId and Core_Supported_Product__c=:SupportedProductId and core_status__c!='Inactive']){
                                                           ab.add(new IssueSubCategories(a.id, a.name));         
                                                       }*/
        }
        return ab;
    }
   
    
   /***************************************************************************************************
    Apex Method Name: getEnvVariables 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This method returns EnvironmentDetails
    Input Parameters: Supported Product Id, Sub Category Id, usertype
    Output Parameters: List of Environment Variables
    Description: If sub category contains environment variables they are returned, 
                 else product based environment variables are returned
    Used in     : 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    * Amritesh                   12/18/2017              Modified - added null check for Core_Environment_Variable__c
    ****************************************************************************************************/    
    public static List<Core_IPS_Assigned_Environment_Variables__c> getEnvVariables(String productId, String subCatId,boolean isAgent){
        if(SubCatId!=null){
            if(isAgent!=null && isAgent){
                return [select id, name, Core_Environment_Variable__c,Core_Environment_Variable__r.Name,Core_Environment_Variable__r.Core_Answers__c, 
                 Core_Environment_Variable__r.Core_Datatype__c, Core_Product_Issue_Sub_Category__c,Core_Required__c,Core_Agent_Only__c 
                 from Core_IPS_Assigned_Environment_Variables__c where Core_Product_Issue_Sub_Category__c=:SubCatId and Core_Product_Issue_Sub_Category__c!='' and 
                        Core_Status__c=:'Active' AND Core_Environment_Variable__c!=null order by Core_Environment_Variable__r.Core_Datatype__c asc]; //added null check for Core_Environment_Variable__c by amritesh 12/18/2017 - US8534
             }else{
                 return [select id, name, Core_Environment_Variable__c,Core_Environment_Variable__r.Name,Core_Environment_Variable__r.Core_Answers__c, 
                 Core_Environment_Variable__r.Core_Datatype__c, Core_Product_Issue_Sub_Category__c,Core_Required__c,Core_Agent_Only__c 
                 from Core_IPS_Assigned_Environment_Variables__c where Core_Product_Issue_Sub_Category__c=:SubCatId and Core_Product_Issue_Sub_Category__c!='' and 
                         Core_Status__c=:'Active' and Core_Agent_Only__c!=true AND Core_Environment_Variable__c!=null order by Core_Environment_Variable__r.Core_Datatype__c asc]; //added null check for Core_Environment_Variable__c by amritesh 12/18/2017 - US8534
             }
        }else{
            if(isAgent!=null && isAgent){
                return [select id, name, Core_Environment_Variable__c,Core_Environment_Variable__r.Name,Core_Environment_Variable__r.Core_Answers__c, 
                 Core_Environment_Variable__r.Core_Datatype__c, Core_Product_Issue_Sub_Category__c,Core_Required__c,Core_Agent_Only__c 
                 from Core_IPS_Assigned_Environment_Variables__c where Core_supported_product__c =:productId and Core_supported_product__c!='' and 
                        Core_Status__c=:'Active' AND Core_Environment_Variable__c!=null order by Core_Environment_Variable__r.Core_Datatype__c asc]; //added null check for Core_Environment_Variable__c by amritesh 12/18/2017 - US8534
            }else{
                return [select id, name, Core_Environment_Variable__c,Core_Environment_Variable__r.Name,Core_Environment_Variable__r.Core_Answers__c, 
                 Core_Environment_Variable__r.Core_Datatype__c,Core_Product_Issue_Sub_Category__c ,Core_Required__c,Core_Agent_Only__c 
                 from Core_IPS_Assigned_Environment_Variables__c where Core_supported_product__c =:productId and Core_supported_product__c!='' and 
                        Core_Status__c=:'Active' and Core_Agent_Only__c!=true AND Core_Environment_Variable__c!=null order by Core_Environment_Variable__r.Core_Datatype__c asc]; //added null check for Core_Environment_Variable__c by amritesh 12/18/2017 - US8534
            }
        }
    }

    /***************************************************************************************************
    Apex Method Name: getEnvironmentVariables 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This method returns EnvironmentDetails
    Input Parameters: Supported Product Id, Sub Category Id 
    Output Parameters: List of Environment Variables
    Description: If sub category contains environment variables they are returned, 
                 else product based environment variables are returned
    Used in     : 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/ 
    public static List<EnvironmentTemplates> getEnvironmentVariables(String supportedProductId, String subCategoryID){
        List <Core_IPS_Assigned_Environment_Variables__c > envVariablesList=new List <Core_IPS_Assigned_Environment_Variables__c >(); 
        List<EnvironmentTemplates> ab = new List<EnvironmentTemplates>();
         if(SupportedProductId == 'null' && subCategoryID == 'null' && SupportedProductId  == ' '){
             return ab;
         } 
        //FLS Check Added - Yasasvi
        if(Core_IPS_Assigned_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){
        	envVariablesList = [select id, name, Core_Environment_Variable__c,Core_Environment_Variable__r.Name,Core_Environment_Variable__r.Core_Answers__c, 
                                                                               Core_Environment_Variable__r.Core_Datatype__c, Core_Product_Issue_Sub_Category__c,Core_Required__c,Core_Agent_Only__c 
                                                                               from Core_IPS_Assigned_Environment_Variables__c where Core_Product_Issue_Sub_Category__c=:SupportedProductId];
        }
        if( envVariablesList.size() > 0){   
            //FLS Check Added - Yasasvi
            if(Core_IPS_Assigned_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){             
                for (Core_IPS_Assigned_Environment_Variables__c  a:envVariablesList ){
                    ab.add(new EnvironmentTemplates(a.Core_Environment_Variable__c, a.Core_Environment_Variable__r.name, a.Core_Agent_Only__c, a.Core_Required__c));
                }
            }
         }else{
             //FLS Check Added - Yasasvi
             if(Core_IPS_Assigned_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){
                 for(Core_IPS_Assigned_Environment_Variables__c  a:[SELECT id, name, Core_Required__c, Core_Agent_Only__c, Core_Environment_Variable__c, Core_Environment_Variable__r.name FROM Core_IPS_Assigned_Environment_Variables__c where Core_supported_product__c  =: SupportedProductId]){
                     ab.add(new EnvironmentTemplates(a.Core_Environment_Variable__c, a.Core_Environment_Variable__r.name, a.Core_Agent_Only__c, a.Core_Required__c));
                 }
             }

          }
          
          return ab;
     }
     
   /***************************************************************************************************
    Apex Wrapper Class Name: EnvironmentTemplates 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This Wrapper class is used for collecting EnvironmentDetails information 
    Used in     :
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/    
    public class EnvironmentTemplates {
        public string envId{get;set;}
        public string envName{get;set;}
        public boolean selected{get;set;}
//        public Environment_Variables__c env{get;set;}
        public boolean agentOnly{get;set;}
        public boolean required{get;set;}
        public EnvironmentTemplates (string id, string name, boolean ag, boolean req){
            envId = id;
            envName = name;
            selected = false;
            agentOnly = ag;
            required = req;
            
        }
    }
    
   /***************************************************************************************************
    Apex Wrapper Class Name: AssetList 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This Wrapper class is used for collecting Asset information details
    Used in     :
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/
    public class AssetList {
        public string assetName;
        public string assetid;
        public string prodorgId;
        
        public AssetList(string a, string b, string c){
            AssetName = a;
            assetid = b;
            prodorgId = c;
            
        }
    
    }
   
   
    /***************************************************************************************************
    Apex Wrapper Class Name: Supported_Product 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This Wrapper class is used for collecting Supported product information details
    Used in     :
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/
    public class Supported_product {
        public string productName;
        public string productId;
        
        public Supported_product (String id, String name){
            productName = name;
            productId = id;        
        }
    
    }
    
    /***************************************************************************************************
    Apex Wrapper Class Name: IssueCategories 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This Wrapper class is used for collecting issue categories details
    Used In     :
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/
    public class IssueCategories{
        public string issueCatId;
        public string issueCatName;
        public IssueCategories(String id, string name){
            issueCatId = id;
            issueCatName = name;
        }
    
    }
    
    /***************************************************************************************************
    Apex Wrapper Class Name: IssueSubCategories 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : This Wrapper class is used for collecting issue sub categories details
    Used In     :
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/
    public class IssueSubCategories{
        public string issueSubCatId;
        public string issueSubCatName;
        public IssueSubCategories(String id, string name){
            issueSubCatId = id;
            issueSubCatName = name;
        }
    }
    



   /***************************************************************************************************
    Apex Method Name: getIPSProjectList 
    Parameters : None
    Return Type: Returns List of selectOptions with assigned projects for the logged in user. 
    Version     : 1.0 
    Created Date: 10 Oct 2015
    Function    : This function is used get the projects assigned to logged in user
    Used In     : Customer case creation page
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/10/2015              Created
    ****************************************************************************************************/       
    public static List<SelectOption> getIPSProjectList(){
        List<Core_IPS_Project__c> assignedProjectList = new List<Core_IPS_Project__c>();
        //FLS Check Added - Yasasvi
        if(core_ips_project__c.SObjectType.getDescribe().isAccessible()){
            assignedProjectList = [select id, name,Core_IPS_Project_ID__c from core_ips_project__c where core_status__c='Active' ORDER BY Core_IPS_Project_ID__c  DESC ];
        }
        List<SelectOption> projectList = new List<SelectOption>(); 
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            mode='edit';
        }    
        if(AssignedProjectList <> null && AssignedProjectList.size()>0){
            
            if(mode !='edit'){
                projectList.add(new SelectOption('NA','--Select--'));//Geetha
            }
            projectList.add(new SelectOption('NoProj','Not Applicable'));
            for(Core_IPS_Project__c proj:assignedProjectList){
                projectList.add(new SelectOption(proj.Id,proj.Core_IPS_Project_ID__c+': '+proj.Name));
            }
            //displayCustProj=true;
        }
        //displayCustProj=false;
        return projectList;
    }
    
    public static List<SelectOption> getGECAnswerOptions(){
        List<SelectOption> answerOptions = new list<SelectOption>();
        AnswerOptions.add(new SelectOption('', '--Select--'));//already changed
        AnswerOptions.add(new SelectOption('Yes', 'Yes'));
        AnswerOptions.add(new SelectOption('No', 'No'));
        return answerOptions;
    }    

   
    /***************************************************************************************************
    Method Name:  getCase_DynamiCSOQL 
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : Returns the current case information.
    Input Parameters: caseId, isAgent
    Output Parameters: Returns the case information from current case
    Description:   Returns the current case information.
    Used in     : Case edit
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    * EswaraRao U                22/12/2017              Appended 'Core_IPS_Customer_Visible__c' US72553 Iteration 2
    * Gourav Anand               10/06/2018              Added Account.Core_Military_Aerospace_and_Government__c in dynamic SOQL to check MAG cases
    ****************************************************************************************************/   
    public static Case getCase_DynamiCSOQL(String csId, boolean isAgent) {
        // SOQL Injection Start - START -  Shipra
        Map<String, Object> bindMap = new Map<String, Object>{ 'caseID' =>csId.escapeHtml4()  };
        try
        {
            String query = 'SELECT ';
            csId = csId.escapeHtml4();
            for(Schema.FieldSetMember f : getFields(isAgent)) { 
                String fieldname = f.getFieldPath();
                if(string.isNotBlank(fieldname)){
                    query += fieldname + ', ';
                }    
            }
            if(isAgent){
            // Appened 'Core_IPS_Customer_Visible__c' by Eswar US72553 Iteration-2 Dt:22-12-2017
            //Added Core_Partner_Supported_Account__c by Geetha as per user story US90061 
            //added AccountId,Core_IPS_Partner_Sup_Owner__c by Sugandha for US84997 I8
            //Added Core_IPS_Partner_Sup_Owner__r.isActive by Geetha as per user story US90061
            // Added fields for US127333
            //US185241 Gourav -Added Account.Core_Military_Aerospace_and_Government__c for MAG Account case check
           
             

            query += 'Id,Core_IPS_Country_Region__c,Core_IPS_Minds__c,Account.Core_Military_Aerospace_and_Government__c,Core_Product_Variant__c, Core_IPS_Partner_Sup_Owner__r.FirstName, Core_IPS_Partner_Sup_Owner__r.LastName, Core_IPS_Partner_Sup_Owner__r.isActive,Core_Partner_Supported_Account__r.Name, contact.Account.OwnerId , Core_Sub_Status__c,Contact.Name,Core_IPS_Issue_source__c, Core_IPS_Customer_Visible__c,Contact.FirstName,Contact.LastName, AssetId,status,Core_Customer_Reference_ID__c,Core_Platform_Name__c,asset.name,productId,product.name,Core_Case_issue_category__c,Core_IPS_Supported_Product__c,Core_IPS_Supported_Product__r.name, Core_IPS_Supported_Product__r.core_Product_Application__c, Core_case_issue_sub_category__c,Core_IPS_Product_Org1__c,ContactId,core_ips_project_case__c, core_ips_project_case__r.name,recordtypeId,recordtype.DeveloperName,Core_Partner_Supported_Account__c,AccountId,Core_IPS_Partner_Sup_Owner__c,Core_IPS_Partner_Sup_Owner__r.Name,Core_IPS_Product__c,Core_IPS_Self_Assigned__c,CaseNumber,Core_IPS_Classification__c,Core_IPS_GEC_Status__c,Core_IPS_Restricted_Secret_Content__c,origin,Core_IPS_Project_Case__r.Core_IPS_Private__c,Core_IPS_Supported_Contact__c,Core_IPS_Supported_Contact__r.Name ,Core_IPS_Supported_Contact__r.FirstName, Core_IPS_Supported_Contact__r.LastName , Core_IPS_Supported_Contact__r.AccountId, Core_IPS_Supported_Contact__r.Account.OwnerId, Core_IPS_Private_Project__c ,Core_IPS_Supported_Account__c ,Core_IPS_Supported_Contact__r.Account.Core_Military_Aerospace_and_Government__c, Core_IPS_Supported_Product__r.Core_EOIS__c, Asset.status, Core_IPS_Priority_Reason__c, Priority,Asset.Core_Supported_Product__c FROM case WHERE Id = :caseID   limit 1';
            } else {
                // Commented as Core_IPS_Supported_Product__r.Core_IPS_Project_Name__c is not existing in org
                //query += 'Id,Core_IPS_Country_Region__c,Core_IPS_Minds__c, Account.Core_Military_Aerospace_and_Government__c, contact.Account.OwnerId , Core_Product_Variant__c, Core_IPS_Partner_Sup_Owner__r.FirstName, Core_IPS_Partner_Sup_Owner__r.LastName, Core_IPS_Partner_Sup_Owner__r.isActive,Core_Partner_Supported_Account__r.Name,Core_Sub_Status__c,Core_IPS_Issue_source__c,Core_IPS_Customer_Visible__c,Core_End_Customer__c, Contact.FirstName,Contact.LastName, status,Core_Customer_Reference_ID__c,Core_Platform_Name__c,Contact.Name,AssetId,asset.name,productId,product.name,Core_Case_issue_category__c, Core_IPS_Supported_Product__c,Core_IPS_Supported_Product__r.name, Core_IPS_Supported_Product__r.core_Product_Application__c, Core_IPS_Supported_Product__r.Core_IPS_Project_Name__c, Core_case_issue_sub_category__c,Core_IPS_Product_Org1__c,ContactId,core_ips_project_case__c, core_ips_project_case__r.name,Core_IPS_Project_Case__r.Core_Status__c,recordtypeId,recordtype.DeveloperName,Core_Partner_Supported_Account__c,AccountId,Core_IPS_Partner_Sup_Owner__c,Core_IPS_Partner_Sup_Owner__r.Name,Core_IPS_Product__c,Core_IPS_Private_Project__c ,Core_IPS_Supported_Contact__c,Core_IPS_Supported_Contact__r.Name ,Core_IPS_Supported_Contact__r.FirstName, Core_IPS_Supported_Contact__r.LastName   ,Core_IPS_Supported_Contact__r.AccountId ,Core_IPS_Supported_Account__c ,Core_IPS_Supported_Contact__r.Account.Core_Military_Aerospace_and_Government__c FROM case WHERE Id = \'' + csId.escapeHtml4() + '\' limit 1';
                query += 'Id,Core_IPS_Country_Region__c,Core_IPS_Minds__c, Account.Core_Military_Aerospace_and_Government__c, contact.Account.OwnerId , Core_Product_Variant__c, Core_IPS_Partner_Sup_Owner__r.FirstName, Core_IPS_Partner_Sup_Owner__r.LastName, Core_IPS_Partner_Sup_Owner__r.isActive,Core_Partner_Supported_Account__r.Name,Core_Sub_Status__c,Core_IPS_Issue_source__c,Core_IPS_Customer_Visible__c,Core_End_Customer__c, Contact.FirstName,Contact.LastName, status,Core_Customer_Reference_ID__c,Core_Platform_Name__c,Contact.Name,AssetId,asset.name,productId,product.name,Core_Case_issue_category__c, Core_IPS_Supported_Product__c,Core_IPS_Supported_Product__r.name, Core_IPS_Supported_Product__r.core_Product_Application__c, Core_case_issue_sub_category__c,Core_IPS_Product_Org1__c,ContactId,core_ips_project_case__c, core_ips_project_case__r.name,Core_IPS_Project_Case__r.Core_Status__c,recordtypeId,recordtype.DeveloperName,Core_Partner_Supported_Account__c,AccountId,Core_IPS_Partner_Sup_Owner__c,Core_IPS_Partner_Sup_Owner__r.Name,Core_IPS_Product__c,Core_IPS_Private_Project__c ,Core_IPS_Supported_Contact__c,Core_IPS_Supported_Contact__r.Name ,Core_IPS_Supported_Contact__r.FirstName, Core_IPS_Supported_Contact__r.LastName   ,Core_IPS_Supported_Contact__r.AccountId ,Core_IPS_Supported_Account__c ,Core_IPS_Supported_Contact__r.Account.Core_Military_Aerospace_and_Government__c FROM case WHERE Id = :caseID limit 1';
            }
            return Database.queryWithBinds(query,bindMap,AccessLevel.USER_MODE);
            // SOQL Injection Start - START -  Shipra
        }
        catch(Exception e)
        {
        }
        return null;
    }
    
    /***************************************************************************************************
    Method Name:  getFields
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : Returns field set values based on user type
    Input Parameters: None
    Output Parameters: Returns the fields list based on user type from the fieldsets configured
    Description:   Returns field set values based on user type
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/      
    //Name needs to be changed by JP
    public static List<Schema.FieldSetMember> getFields(boolean isAgent){
        if(!isAgent){
            return SObjectType.Case.FieldSets.Core_Customer_Case_Fields.getFields();
        }else{ 
            return SObjectType.Case.FieldSets.Core_Internal_Case_Fields.getFields();
        }    
    }
    
    
    public static List<Core_IPS_Assigned_Environment_Variables__c> getEnvironmentDetailsOperationalRecords(String prod){
        return null;
    }
    
    /***************************************************************************************************
    Method Name:  getPlatform
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Oct 2015
    Function    : Returns Map of Supp Prod Id and related Platform Names.
    Input Parameters: List of SupportedProduct Id.
    Output Parameters: Returns Map of Supp Prod Id and related Platform Names based on SupportedProduct passed.
    Description:   This method will return Map of Supp Prod Id and related Platform Names based on Supported Product passed inside.
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              10/17/2015              Created
    ****************************************************************************************************/      
    public static Map<String,Set<String>> getPlatform(List<Id> suppProductIdList){
        String platformNames = '';                                
        List<String> epmIdList;
        Set<String> platfomSet;
        List<Core_IPS_Supported_Product__c> suppPrdList=new List<Core_IPS_Supported_Product__c>();
        List<Core_Flat_Product_Hierarchy__c> fphList = new List<Core_Flat_Product_Hierarchy__c>();
        If(suppProductIdList <> null && suppProductIdList.size() > 0){
            suppPrdList = new List<Core_IPS_Supported_Product__c>();
            //Avoid Deeply Nested IF Statements Kamala
            //FLS Check Added - Yasasvi
            if((Test.isRunningTest())&&(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible())){
                    suppPrdList = [select Id,Core_Flag_Status__c,Core_Code_Name__c,Core_EOIS__c,Core_Prod_EPM_Id__c,Core_Product__r.Core_Sales_Visible_Flag__c,Core_Product__r.Core_Hierarchy_ID__c from Core_IPS_Supported_Product__c where Id in:suppProductIdList AND Core_Product__r.Core_Sales_Visible_Flag__c =:FALSE AND Core_Product__r.Core_Hierarchy_ID__c=:'59'];
            }
        }   
        
        If(suppPrdList <> null && suppPrdList.size() > 0){
            epmIdList = new List<String>();
            for(Core_IPS_Supported_Product__c suppProdObj:suppPrdList){
                if(suppProdObj <> null && suppProdObj.Core_Prod_EPM_Id__c <> null && suppProdObj.Core_Prod_EPM_Id__c <> ''){
                    epmIdList.add(suppProdObj.Core_Prod_EPM_Id__c);
                }
            }
        }                                      
        if(epmIdList <> null && epmIdList.size() > 0){
            //FLS Check Added - Yasasvi
            if(Core_Flat_Product_Hierarchy__c.SObjectType.getDescribe().isAccessible()){
                fphList = [select Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_L3_EPM_ID__c,Core_L3_EPM_Name__c,Core_L4_EPM_ID__c,Core_L4_EPM_Name__c,Core_L5_EPM_ID__c,Core_L5_EPM_Name__c from Core_Flat_Product_Hierarchy__c where Core_L5_EPM_ID__c in:epmIdList OR Core_L4_EPM_ID__c in:epmIdList OR Core_L2_EPM_ID__c in:epmIdList];        
            }
        }
        Map<String, Set<String>> prodHierarchyBySupProd;
        Set<String> platformNameList;
        If(suppPrdList <> null && suppPrdList.size() > 0 && fphList <> null && fphList.size() > 0){
            prodHierarchyBySupProd = new Map<String, Set<String>>();
            for(Core_IPS_Supported_Product__c sp:suppPrdList){
                platformNameList = new Set<String>();
                for(Core_Flat_Product_Hierarchy__c fphObj:fphList){
                    if(sp.Core_Prod_EPM_Id__c <> null && sp.Core_Prod_EPM_Id__c <> '' && fphObj.Core_L5_EPM_ID__c <> null && fphObj.Core_L5_EPM_ID__c <> '' && sp.Core_Prod_EPM_Id__c==fphObj.Core_L5_EPM_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                        platformNameList.add(fphObj.Core_L1_EPM_Name__c);
                    }else if(sp.Core_Prod_EPM_Id__c <> null && sp.Core_Prod_EPM_Id__c <> '' && fphObj.Core_L4_EPM_ID__c <> null && fphObj.Core_L4_EPM_ID__c <> '' && sp.Core_Prod_EPM_Id__c==fphObj.Core_L4_EPM_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                        platformNameList.add(fphObj.Core_L1_EPM_Name__c);
                    }else if(sp.Core_Prod_EPM_Id__c <> null && sp.Core_Prod_EPM_Id__c <> '' && fphObj.Core_L2_EPM_ID__c <> null && fphObj.Core_L2_EPM_ID__c <> '' && sp.Core_Prod_EPM_Id__c==fphObj.Core_L2_EPM_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                        platformNameList.add(fphObj.Core_L1_EPM_Name__c);
                    }               
                }                
                prodHierarchyBySupProd.put(sp.id,platformNameList);
            }
        }        
        /*If(fphList <> null && fphList.size() > 0){
            platfomSet = new Set<String>();
            for(Flat_Product_Hierarchy__c fphObj:fphList){
                if(fphObj.Core_L5_EPM_ID__c <> null && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                    platfomSet.add(fphObj.Core_L1_EPM_Name__c);
                }else if(fphObj.Core_L5_EPM_ID__c == null && fphObj.Core_L4_EPM_ID__c <> null && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                    platfomSet.add(fphObj.Core_L1_EPM_Name__c);
                }else if(fphObj.Core_L5_EPM_ID__c == null && fphObj.Core_L4_EPM_ID__c == null && fphObj.Core_L2_EPM_ID__c <> null && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                    platfomSet.add(fphObj.Core_L1_EPM_Name__c);
                }
            }
        }        
        for(String platformString : platfomSet){
            if(platformNames == '')
            platformNames = platformString;           
            else
            platformNames = platformNames + ',' + platformString;    
        }
        return platformNames;        
        */
        return prodHierarchyBySupProd;
    }
    
    /***************************************************************************************************
    Method Name: getCodeName
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Oct 2015
    Function    : Returns Map of Supported Product Id and related Code Name.
    Input Parameters: List of SupportedProductIds.
    Output Parameters: Returns Map of Supported Product Id and related Code Name based on Supp Prod Id passed.
    Description:   This method will return Map of Supported Product Id and related Code Name based on Supported Product passed inside.
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              10/17/2015              Created
    ****************************************************************************************************/      
    public static Map<String,String> getCodeName(List<Id> suppProductIdList){
        String codeNames = '';
        //Set<String> codeSet;
        Map<String,String> suppProdIdCodeNameMap;
        List<Core_IPS_Supported_Product__c> suppPrdList;
        If(suppProductIdList <> null && suppProductIdList.size() > 0){
            suppPrdList = new List<Core_IPS_Supported_Product__c>();
            //FLS Check Added - Yasasvi
            //if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){
			//suppPrdList = [select Id,Core_Flag_Status__c,Core_Code_Name__c,Core_EOIS__c,Core_Prod_EPM_Id__c,Core_Product__r.Core_Sales_Visible_Flag__c,Core_Product__r.Core_Hierarchy_ID__c,Core_Product__r.Core_Code_Name__c from Core_IPS_Supported_Product__c where Id in:suppProductIdList AND Core_Product__r.Core_Sales_Visible_Flag__c =:FALSE];
            //}
            //Added logic as part of Code Refactor TWC745-6459
            if(globalProductRecords != null && globalProductRecords.Size()>0 && !Core_IPS_CaseTriggerHandler.isQueryRequired(suppProductIdList,globalProductRecords,null)){
                system.debug('CODE REFCATOR getCodeName - Global Data');
                for(Core_IPS_Supported_Product__c record : globalProductRecords.Values()){
                    if(record.Core_Product__r.Core_Sales_Visible_Flag__c = false) {
                        suppPrdList.add(record);
                    }
                } 
                //FLS Added as Part of code refactor
            } else if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){
                system.debug('CODE REFCATOR getCodeName - QUERY EXECUTION');
                suppPrdList = [select Id,Core_Flag_Status__c,Core_Code_Name__c,Core_EOIS__c,Core_Prod_EPM_Id__c,Core_Product__r.Core_Sales_Visible_Flag__c,Core_Product__r.Core_Hierarchy_ID__c,Core_Product__r.Core_Code_Name__c from Core_IPS_Supported_Product__c where Id in:suppProductIdList AND Core_Product__r.Core_Sales_Visible_Flag__c =:FALSE];
            }
              //END
        }        
        If(suppPrdList <> null && suppPrdList.size() > 0){
            //codeSet = new Set<String>();
            suppProdIdCodeNameMap = new Map<String,String>();
            for(Core_IPS_Supported_Product__c suppProdObj:suppPrdList){
                //if(suppProdObj <> null && suppProdObj.Core_Product__r <> null && suppProdObj.Core_Product__r.Core_Code_Name__c <> null && suppProdObj.Core_Product__r.Core_Code_Name__c <> '')
                //codeSet.add(suppProdObj.Core_Product__r.Core_Code_Name__c);
                //suppProdIdCodeNameMap.put(suppProdObj.Id,suppProdObj.Core_Product__r.Core_Code_Name__c);
                if(suppProdObj <> null && suppProdObj.Core_Code_Name__c <> null && suppProdObj.Core_Code_Name__c <> ''){
                    suppProdIdCodeNameMap.put(suppProdObj.Id,suppProdObj.Core_Code_Name__c);
                }    
            }
        }                                                      
        If(suppProdIdCodeNameMap <> null && suppProdIdCodeNameMap.size() > 0){
            return suppProdIdCodeNameMap;
        }
        return null;
        /*for(String codeString : codeSet){
            if(codeNames == '')
            codeNames = codeString;           
            else
            codeNames = codeNames+','+codeString;    
        }
        return codeNames;*/        
    }
    
    /***************************************************************************************************
    Method Name: getVPHProductType
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Oct 2015
    Function    : Returns comma separated Product Types.
    Input Parameters: List of SupportedProduct.
    Output Parameters: Returns Map of Supported Product Id v/s set of VPH Product Type based on SupportedProduct passed.
    Description:   This method will Returns Map of Supported Product Id v/s set of VPH Product Type based on Supported Product passed inside.
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              10/17/2015              Created
    ****************************************************************************************************/      
    public static Map<String,Set<String>> getVPHProductType(List<Id> suppProductIdList){
        String prodTypes = '';
        List<String> epmIdList;
        Set<String> prodSet;
        List<Core_IPS_Supported_Product__c> suppPrdList;
        List<Product2> prodList;
        List<String> hierarchyIdList;
        List<String> hierarchyNameList;
        List<Core_Flat_Product_Hierarchy__c> fphList = new List<Core_Flat_Product_Hierarchy__c>(); 
        Map<String,Set<String>> suppProdIdProdTypeMap;
        If(suppProductIdList <> null && suppProductIdList.size() > 0){
            suppPrdList = new List<Core_IPS_Supported_Product__c>();
            //FLS Check Added - Yasasvi
           // if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){
		// suppPrdList = [select Id,Core_Flag_Status__c,Core_Code_Name__c,Core_EOIS__c,Core_Prod_EPM_Id__c,Core_Product__r.Core_Unique_ID__c,Core_Product__r.Core_Sales_Visible_Flag__c,Core_Product__r.Core_Hierarchy_ID__c from Core_IPS_Supported_Product__c where Id in:suppProductIdList AND Core_Product__r.Core_Sales_Visible_Flag__c =:FALSE AND Core_Product__r.Core_Hierarchy_ID__c=:'43'];
               //Added logic as part of Code Refactor TWC745-6459
                if(globalProductRecords != null && globalProductRecords.Size()>0 && !Core_IPS_CaseTriggerHandler.isQueryRequired(suppProductIdList,globalProductRecords,null)){
                    system.debug('CODE REFCATOR getVPHProductType - Global Data');
                    for(Core_IPS_Supported_Product__c record : globalProductRecords.Values()){
                        if(record.Core_Product__r.Core_Sales_Visible_Flag__c == false && record.Core_Product__r.Core_Hierarchy_ID__c == '43'){
                           suppPrdList.add(record); 
            }
                    }
                    //FLS Added as Part of code refactor
                } else if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isQueryable()){
                    system.debug('CODE REFCATOR getVPHProductType - QUERY EXECUTION');
                    suppPrdList = [select Id,Core_Flag_Status__c,Core_Code_Name__c,Core_EOIS__c,Core_Prod_EPM_Id__c,Core_Product__r.Core_Unique_ID__c,Core_Product__r.Core_Sales_Visible_Flag__c,Core_Product__r.Core_Hierarchy_ID__c from Core_IPS_Supported_Product__c where Id in:suppProductIdList AND Core_Product__r.Core_Sales_Visible_Flag__c =:FALSE AND Core_Product__r.Core_Hierarchy_ID__c=:'43'];  
                }
               //End
           // }
        }        
        If(suppPrdList <> null && suppPrdList.size() > 0){
            epmIdList = new List<String>();
            for(Core_IPS_Supported_Product__c suppProdObj:suppPrdList){
                if(suppProdObj <> null && suppProdObj.Core_Product__r <> null && suppProdObj.Core_Product__r.Core_Unique_ID__c <> null && suppProdObj.Core_Product__r.Core_Unique_ID__c <> ''){
                    epmIdList.add(suppProdObj.Core_Prod_EPM_Id__c);
                }
            }
        }                                              
        if(epmIdList <> null && epmIdList.size() > 0){
            prodList = new List<Product2>();
            //FLS Check Added - Yasasvi
            if(Product2.SObjectType.getDescribe().isAccessible()){
                prodList = [select Id,Core_Unique_ID__c,Core_Hierarchy_ID__c,Core_Hierarchy_Name__c from Product2 where Core_Unique_ID__c in:epmIdList];
            }
        }
        If(prodList <> null && prodList.size() > 0){
            hierarchyIdList = new List<String>();
            hierarchyNameList = new List<String>();
            for(Product2 prodObj:prodList){
                if(prodObj <> null && prodObj.Core_Hierarchy_ID__c <> null && prodObj.Core_Hierarchy_ID__c <> ''){
                    hierarchyIdList.add(prodObj.Core_Hierarchy_ID__c);
                }    
                if(prodObj <> null && prodObj.Core_Hierarchy_Name__c <> null && prodObj.Core_Hierarchy_Name__c <> ''){
                    hierarchyNameList.add(prodObj.Core_Hierarchy_Name__c);
                }    
            }
        }                
        if(((hierarchyIdList <> null && hierarchyIdList.size() > 0) || (hierarchyNameList <> null && hierarchyNameList.size() > 0)) && (epmIdList <> null && epmIdList.size() > 0)){
            //FLS Check Added - Yasasvi
            if(Core_Flat_Product_Hierarchy__c.SObjectType.getDescribe().isAccessible()){
                fphList = [select Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_L3_EPM_ID__c,Core_L3_EPM_Name__c,Core_L4_EPM_ID__c,Core_L4_EPM_Name__c,Core_L5_EPM_ID__c,Core_L5_EPM_Name__c,Core_EPM_Hierarchy_Name__c from Core_Flat_Product_Hierarchy__c where ((Core_EPM_Hierarchy_Name__c IN:hierarchyNameList OR Core_EPM_Hierarchy_ID__c IN:hierarchyIdList) AND (Core_L5_EPM_ID__c in:epmIdList OR Core_L4_EPM_ID__c in:epmIdList OR Core_L3_EPM_ID__c in:epmIdList OR Core_L2_EPM_ID__c in:epmIdList))];        
            }
        }
        
        If(suppPrdList <> null && suppPrdList.size() > 0 && prodList <> null && prodList.size() > 0 && fphList <> null && fphList.size() > 0){
            suppProdIdProdTypeMap = new Map<String,Set<String>> ();
            for(Core_IPS_Supported_Product__c suppProdObj:suppPrdList){
                prodSet = new Set<string> ();
                for(Product2 prodObj:prodList){
                    for(Core_Flat_Product_Hierarchy__c fphObj:fphList){
                        If(suppProdObj.Core_Prod_EPM_Id__c <> null && suppProdObj.Core_Prod_EPM_Id__c <> '' && prodObj.Core_Unique_ID__c <> null && prodObj.Core_Unique_ID__c <> '' && suppProdObj.Core_Prod_EPM_Id__c == prodObj.Core_Unique_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> '' && (fphObj.Core_L5_EPM_ID__c == suppProdObj.Core_Prod_EPM_Id__c && (prodObj.Core_Hierarchy_Name__c == fphObj.Core_EPM_Hierarchy_Name__c || prodObj.Core_Hierarchy_ID__c == fphObj.Core_EPM_Hierarchy_ID__c))){
                            prodSet.add(fphObj.Core_L1_EPM_Name__c);
                        }else If(suppProdObj.Core_Prod_EPM_Id__c <> null && suppProdObj.Core_Prod_EPM_Id__c <> '' && prodObj.Core_Unique_ID__c <> null && prodObj.Core_Unique_ID__c <> '' && suppProdObj.Core_Prod_EPM_Id__c == prodObj.Core_Unique_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> '' && (fphObj.Core_L4_EPM_ID__c == suppProdObj.Core_Prod_EPM_Id__c && (prodObj.Core_Hierarchy_Name__c == fphObj.Core_EPM_Hierarchy_Name__c || prodObj.Core_Hierarchy_ID__c == fphObj.Core_EPM_Hierarchy_ID__c))){
                            prodSet.add(fphObj.Core_L1_EPM_Name__c);
                        }else If(suppProdObj.Core_Prod_EPM_Id__c <> null && suppProdObj.Core_Prod_EPM_Id__c <> '' && prodObj.Core_Unique_ID__c <> null && prodObj.Core_Unique_ID__c <> '' && suppProdObj.Core_Prod_EPM_Id__c == prodObj.Core_Unique_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> '' && (fphObj.Core_L3_EPM_ID__c == suppProdObj.Core_Prod_EPM_Id__c && (prodObj.Core_Hierarchy_Name__c == fphObj.Core_EPM_Hierarchy_Name__c || prodObj.Core_Hierarchy_ID__c == fphObj.Core_EPM_Hierarchy_ID__c))){
                            prodSet.add(fphObj.Core_L1_EPM_Name__c);
                        }else If(suppProdObj.Core_Prod_EPM_Id__c <> null && suppProdObj.Core_Prod_EPM_Id__c <> '' && prodObj.Core_Unique_ID__c <> null && prodObj.Core_Unique_ID__c <> '' && suppProdObj.Core_Prod_EPM_Id__c == prodObj.Core_Unique_ID__c && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> '' && (fphObj.Core_L2_EPM_ID__c == suppProdObj.Core_Prod_EPM_Id__c && (prodObj.Core_Hierarchy_Name__c == fphObj.Core_EPM_Hierarchy_Name__c || prodObj.Core_Hierarchy_ID__c == fphObj.Core_EPM_Hierarchy_ID__c))){
                            prodSet.add(fphObj.Core_L1_EPM_Name__c);
                        }
                    }
                }
                suppProdIdProdTypeMap.put(suppProdObj.Id,prodSet);
            }
        }
        return suppProdIdProdTypeMap;
                        
        /*If(fphList <> null && fphList.size() > 0){
            prodSet = new Set<String>();
            for(Flat_Product_Hierarchy__c fphObj:fphList){
                if(fphObj.Core_L5_EPM_ID__c <> null && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                    prodSet.add(fphObj.Core_L1_EPM_Name__c);
                }else if(fphObj.Core_L5_EPM_ID__c == null && fphObj.Core_L4_EPM_ID__c <> null && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                    prodSet.add(fphObj.Core_L1_EPM_Name__c);
                }else if(fphObj.Core_L5_EPM_ID__c == null && fphObj.Core_L4_EPM_ID__c == null && fphObj.Core_L3_EPM_ID__c <> null && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                    prodSet.add(fphObj.Core_L1_EPM_Name__c);
                }else if(fphObj.Core_L5_EPM_ID__c == null && fphObj.Core_L4_EPM_ID__c == null && fphObj.Core_L3_EPM_ID__c == null && fphObj.Core_L2_EPM_ID__c <> null && fphObj.Core_L1_EPM_Name__c <> null && fphObj.Core_L1_EPM_Name__c <> ''){
                    prodSet.add(fphObj.Core_L1_EPM_Name__c);
                }                
            }
        }        
        for(String prodString : prodSet){
            if(prodTypes == '')
            prodTypes = prodString;           
            else
            prodTypes = prodTypes + ',' + prodString;    
        }                        
        return prodTypes;*/
    }
    
    /***************************************************************************************************
    Method Name: getVPLHProductType
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Oct 2015
    Function    : Returns comma separated Product Types.
    Input Parameters: List of SupportedProduct.
    Output Parameters: Returns Map of Supported Product Id v/s set of VPLH Product Type based on SupportedProduct passed.
    Description:   This method will Returns Map of Supported Product Id v/s set of VPLH Product Type based on Supported Product passed inside.
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              10/17/2015              Created
    ****************************************************************************************************/      
    public static Map<String,Set<String>> getVPLHProductType(List<Id> suppProductIdList){
        String prodTypes = '';
        List<String> epmIdList;
        Set<String> prodSet;
        List<Core_IPS_Supported_Product__c> suppPrdList;
        List<Core_Flat_Product_Hierarchy__c> fphList = new List<Core_Flat_Product_Hierarchy__c>(); 
        Map<String,Set<String>> suppProdIdProdTypeMap;
        If(suppProductIdList <> null && suppProductIdList.size() > 0){
            suppPrdList = new List<Core_IPS_Supported_Product__c>();
            //FLS Check Added - Yasasvi
           // if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){
               // suppPrdList = [select Id,Core_Flag_Status__c,Core_Code_Name__c,Core_EOIS__c,Core_Prod_EPM_Id__c,Core_Product__r.Core_Unique_ID__c,Core_Product__r.Core_Sales_Visible_Flag__c,Core_Product__r.Core_Hierarchy_ID__c from Core_IPS_Supported_Product__c where Id in:suppProductIdList AND Core_Product__r.Core_Sales_Visible_Flag__c =:FALSE AND Core_Product__r.Core_Hierarchy_ID__c=:'59'];
           
                //Added logic as part of Code Refactor TWC745-6459
                if(GlobalProductRecords != null && GlobalProductRecords.Size()>0 && !Core_IPS_CaseTriggerHandler.isQueryRequired(suppProductIdList,GlobalProductRecords,null)){
                    system.debug('CODE REFCATOR getVPLHProductType - Global Data');
                    for(Core_IPS_Supported_Product__c record : GlobalProductRecords.Values()){
                        if(record.Core_Product__r.Core_Sales_Visible_Flag__c == False && record.Core_Product__r.Core_Hierarchy_ID__c == '59'){
                           suppPrdList.add(record); 
                        }
                    }
                    //FLS Added as Part of code refactor
                } else if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isQueryable()){
                        system.debug('CODE REFCATOR getVPLHProductType - QUERY EXECUTION');
                        suppPrdList = [select Id,Core_Flag_Status__c,Core_Code_Name__c,Core_EOIS__c,Core_Prod_EPM_Id__c,Core_Product__r.Core_Unique_ID__c,Core_Product__r.Core_Sales_Visible_Flag__c,Core_Product__r.Core_Hierarchy_ID__c from Core_IPS_Supported_Product__c where Id in:suppProductIdList AND Core_Product__r.Core_Sales_Visible_Flag__c =:FALSE AND Core_Product__r.Core_Hierarchy_ID__c=:'59'];
                }
                //END
            }
        //}        
        If(suppPrdList <> null && suppPrdList.size() > 0){
            epmIdList = new List<String>();
            for(Core_IPS_Supported_Product__c suppProdObj:suppPrdList){
                if(suppProdObj <> null && suppProdObj.Core_Prod_EPM_Id__c <> null && suppProdObj.Core_Prod_EPM_Id__c <> ''){
                    epmIdList.add(suppProdObj.Core_Prod_EPM_Id__c);
                }
            }
        }                                      
        if(epmIdList <> null && epmIdList.size() > 0){
            //FLS Check Added - Yasasvi
            if(Core_Flat_Product_Hierarchy__c.SObjectType.getDescribe().isAccessible()){
                fphList = [select Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_L3_EPM_ID__c,Core_L3_EPM_Name__c,Core_L4_EPM_ID__c,Core_L4_EPM_Name__c,Core_L5_EPM_ID__c,Core_L5_EPM_Name__c from Core_Flat_Product_Hierarchy__c where Core_L5_EPM_ID__c in:epmIdList OR Core_L4_EPM_ID__c in:epmIdList];        
            }
        }
        
        If(suppPrdList <> null && suppPrdList.size() > 0 && fphList <> null && fphList.size() > 0){
            suppProdIdProdTypeMap = new Map<String,Set<String>>();
            for(Core_IPS_Supported_Product__c suppProdObj:suppPrdList){
                prodSet = new Set<String>();
                for(Core_Flat_Product_Hierarchy__c fphObj: fphList){
                    if(fphObj.Core_L5_EPM_ID__c <> null && fphObj.Core_L5_EPM_ID__c <> '' && fphObj.Core_L3_EPM_Name__c <> null && fphObj.Core_L3_EPM_Name__c <> '' && suppProdObj.Core_Prod_EPM_Id__c <> null && suppProdObj.Core_Prod_EPM_Id__c <> '' && fphObj.Core_L5_EPM_ID__c == suppProdObj.Core_Prod_EPM_Id__c){
                        prodSet.add(fphObj.Core_L3_EPM_Name__c);
                    }else if(fphObj.Core_L4_EPM_ID__c <> null && fphObj.Core_L4_EPM_ID__c <> '' && fphObj.Core_L3_EPM_Name__c <> null && fphObj.Core_L3_EPM_Name__c <> '' && suppProdObj.Core_Prod_EPM_Id__c <> null && suppProdObj.Core_Prod_EPM_Id__c <> '' && fphObj.Core_L4_EPM_ID__c == suppProdObj.Core_Prod_EPM_Id__c){
                        prodSet.add(fphObj.Core_L3_EPM_Name__c);
                    }
                }
                suppProdIdProdTypeMap.put(suppProdObj.Id,prodSet);
            }                
        }
        return suppProdIdProdTypeMap;        
        
        /*If(fphList <> null && fphList.size() > 0){
            prodSet = new Set<String>();
            for(Flat_Product_Hierarchy__c fphObj:fphList){
                if(fphObj.Core_L5_EPM_ID__c <> null && fphObj.Core_L3_EPM_Name__c <> null && fphObj.Core_L3_EPM_Name__c <> ''){
                    prodSet.add(fphObj.Core_L3_EPM_Name__c);
                }else if(fphObj.Core_L5_EPM_ID__c == null && fphObj.Core_L4_EPM_ID__c <> null && fphObj.Core_L3_EPM_Name__c <> null && fphObj.Core_L3_EPM_Name__c <> ''){
                    prodSet.add(fphObj.Core_L3_EPM_Name__c);
                }                
            }
        }        
        for(String prodString : prodSet){
            if(prodTypes == '')
            prodTypes = prodString;           
            else
            prodTypes = prodTypes + ',' + prodString;    
        }
        return prodTypes;*/ 
    }
    
    
    /***************************************************************************************************
    Method Name:  getplatform_Options
    Method Type: Action Helper Method  
    Version     : 1.0 
    Created Date: 27 Oct 2015
    Function    : Constructs the Platform options based on supported Product selected
    Input Parameters: List of Supported Product/Asset Ids 
    Output Parameters: List of select options
    Description:   Constructs the Platform options based on supp prod/Asset
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              10/27/2015              Created
    ****************************************************************************************************/     
    public static List<SelectOption> getplatform_Options(List<Id> idList){ 
      List<SelectOption> platformOptions = new List<SelectOption>();  
      platformOptions.add(new SelectOption('', '--Select--'));//Geetha
      List<Asset> astList = new List<Asset>();
      List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
        //FLS Check Added - Yasasvi
        if(Asset.SObjectType.getDescribe().isAccessible()){
            astList = [select Id,core_supported_product__c from Asset where Id in:idList];  
        }
        //FLS Check Added - Yasasvi
        if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){
            suppProdList = [select Id from Core_IPS_Supported_Product__c where Id in:idList];  
        }
        List<Id> supportedProductIdList = new List<Id>();
        if(astList <> null && astList.size() > 0){
            for(Asset asset:astList){
                supportedProductIdList.add(asset.core_supported_product__c);
            }
        }    
      if(suppProdList <> null && suppProdList.size() > 0){
          for(Core_IPS_Supported_Product__c suppProdObj:suppProdList){
            supportedProductIdList.add(suppProdObj.Id);
          }
      }      
      if(supportedProductIdList <> null && supportedProductIdList.size()>0){
            Map<String,Set<String>> platformByProduct=Core_IPS_Caseutility.getPlatform(supportedProductIdList);
            if(platformByProduct!=null && platformByProduct.size()>0){
                  if(astList <> null && astList.size() > 0){
                      for(Asset asset:astList){
                          if(asset <> null && asset.core_supported_product__c <> null && platformByProduct.get(asset.core_supported_product__c) <> null){
                              for(String pltfrmString:platformByProduct.get(asset.core_supported_product__c)){
                                  if(pltfrmString != null && pltfrmString != ''){
                                      platformOptions.add(new SelectOption(pltfrmString, pltfrmString));
                                  }
                               }
                            }
                        }        
                   }
                   if(suppProdList <> null && suppProdList.size() > 0){
                      for(Core_IPS_Supported_Product__c suppProdObj:suppProdList){
                          if(platformByProduct.get(suppProdObj.Id) <> null){
                              for(String pltfrmString:platformByProduct.get(suppProdObj.Id)){
                                  if(pltfrmString != null && pltfrmString != ''){
                                      platformOptions.add(new SelectOption(pltfrmString, pltfrmString));
                                  }
                               }
                            }
                      }        
                   }
                   if(platformOptions <> null && platformOptions.size() > 0){
                       platformOptions.sort();
                   }
            }          
        }    
        return platformOptions;
    }  
    
    /***************************************************************************************************
    Apex Method Name: getIPSProjListBasedOnSelectedProd
    Parameters : None
    Return Type: Returns List of selectOptions with assigned projects based on Selected Product. 
    Version     : 1.0 
    Created Date: 10 Nov 2015
    Function    : This function is used get the projects based on Selected Product
    Used In     : Customer case creation page
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              Nov/10/2015              Created
    ****************************************************************************************************/       
    public static List<SelectOption> getIPSProjListBasedOnSelectedProd(String selectedProductId){
        List<Asset> objAssetSupported=new List<Asset>();
       List<Asset> assignedProjectList = new List<Asset>();
        //FLS already added-Aditya
        if(Asset.SObjectType.getDescribe().isAccessible()){
            objAssetSupported = [SELECT Id,Core_Supported_Product__c,Core_IPS_Project__c  FROM Asset where Id=:selectedProductId ];//Added by Mahendra per US79769 start
        }
        if(objAssetSupported.size()>0){
        // Start - DE55816 - Modified where condition 
            //FLS Check Added - Yasasvi
            if(Asset.SObjectType.getDescribe().isAccessible()){
                assignedProjectList = [select id, name,Core_IPS_Project__c,Core_IPS_Project__r.Name,Core_IPS_Project__r.Core_IPS_Project_ID__c from Asset where Core_IPS_Project__r.core_status__c !='Inactive' and Status !='Inactive' and Core_Supported_Product__c =:objAssetSupported[0].Core_Supported_Product__c ORDER BY Core_IPS_Project__r.Core_IPS_Project_ID__c  DESC ];
            }
        // End - DE55816 - Modified where condition 
       }       
       List<SelectOption> projectList = new List<SelectOption>();
       if(ApexPages.currentPage().getParameters().get('id')!=null){
            mode='edit';
       }     
       if(AssignedProjectList <> null && AssignedProjectList.size() > 0){
           if(mode!='edit'){
           projectList.add(new SelectOption('NA','--Select--'));//Geetha
           }
           projectList.add(new SelectOption('NoProj','Not Applicable'));
           for(Asset astObj:assignedProjectList){
               if(astObj.Core_IPS_Project__c <> null && astObj.Core_IPS_Project__r <> null && astObj.Core_IPS_Project__r.Name <> null) {
                    projectList.add(new SelectOption(astObj.Core_IPS_Project__c,astObj.Core_IPS_Project__r.Core_IPS_Project_ID__c+': '+astObj.Core_IPS_Project__r.Name));
               }
            }
           /*if(projectList.size() == 0){
               projectList.add(new SelectOption('','Select One'));
           }*/       
       }
       //displayCustProj=false;
       return projectList;
    }
    
    /***************************************************************************************************
    Apex Method Name: isSelectedProdRelatedToProject
    Parameters : None
    Return Type: Returns List of selectOptions with assigned projects based on Selected Product. 
    Version     : 1.0 
    Created Date: 10 Nov 2015
    Function    : This function is used get the projects based on Selected Product
    Used In     : Customer case creation page
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya              Nov/10/2015              Created
    ****************************************************************************************************/       
    public static Boolean isSelectedProdRelatedToProject(String selectedProjectId,String selectedProductId){
       if(selectedProjectId=='NoProj'){
           selectedProjectId=null;
       }
       //Core_IPS_Customer_Case_Controller.AssetIdModified=null;
       List<Asset> assignedProjectList = new List<Asset>();
       List<Asset> objAssetSupported=new List<Asset>();
        //FLS Check Added - Yasasvi
        if(Asset.SObjectType.getDescribe().isAccessible()){
            objAssetSupported = [SELECT Id,Core_Supported_Product__c,Core_IPS_Project__c  FROM Asset where Id=:selectedProductId ];//Added by Mahendra per US79769 start
        }
        if(objAssetSupported.size()>0 && selectedProjectId !='NA'){
            //FLS Check Added - Yasasvi
            if(Asset.SObjectType.getDescribe().isAccessible()){
                assignedProjectList = [select id, name,Core_IPS_Project__c,Core_Supported_Product__c,Core_IPS_Project__r.Name from Asset where Status !='Inactive' and Core_Supported_Product__c =:objAssetSupported[0].Core_Supported_Product__c and Core_IPS_Project__c =:selectedProjectId];
            }
        }
        if(objAssetSupported.size()>0 && selectedProjectId=='NA' ){
            //FLS Check Added - Yasasvi
            if(Asset.SObjectType.getDescribe().isAccessible()){
                assignedProjectList = [select id, name,Core_IPS_Project__c,Core_IPS_Project__r.Name from Asset where Status !='Inactive'  and Core_Supported_Product__c =:objAssetSupported[0].Core_Supported_Product__c];
            }
        }
       if(assignedProjectList <> null && assignedProjectList.size() > 0){
          //  Core_IPS_Customer_Case_Controller.AssetIdModified=assignedProjectList[0].id;
            return true;
       }
       return false;
    }
    public class CaseInformationByAsset{
        
    }
   /***************************************************************************************************
    Apex Method Name: ConvertJsonToString
    Parameters : None
    Return Type: return  String  after deserialize the Json 
    Version     : 1.0 
    Created Date: Jan-4-2016 
    Function    : Convert String  after deserialize the Json
    Used In     : custom Search
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sunil Chandani             Jan-4-2016              Created
    ****************************************************************************************************/    
   /*  public static string convertJsonToString(String json){
         return (string) System.JSON.deserialize(json, string.class);
     }*/
     
     //Added for getting list of Project Account
     public static List<SelectOption> getIPSParentAccountList(String selectedProject,String psoUserId){ 
         if(selectedProject=='NoProj'){
             selectedProject=null;
         }
         List<Core_IPS_Project_Member__c> projMembersList = new List<Core_IPS_Project_Member__c>();
         Set<Id> projIds=new Set<Id>();
        if(!String.isBlank(PSOUserId)){
            List<User> contIdValLst = [select id,ContactId from user where id=:PSOUserId limit 1];
            if(contIdValLst.size()>0){
                String contId =contIdValLst[0].ContactId;
                //FLS Check Added - Aditya
                if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
                projMembersList=[select id,name,Core_IPS_Project__c,Core_IPS_Contact_Account__c from Core_IPS_Project_Member__c where Core_IPS_Contact__c=:contId and Core_Status__c='Active'];
                }
            }
        }
         //prepare set for Core_IPS_Project__c
            
            for(integer i=0;i<projMembersList.size();i++){
                projIds.add(projMembersList[i].Core_IPS_Project__c);
            }
            if(!String.isBlank(selectedProject) && selectedProject!='NA'){
                
                projIds.clear();
                projIds.add(Id.valueOf(selectedProject));
            }
         	//FLS Read fix applied - Gangadhar 19/10/2022
            List<Core_IPS_Account__c> projMemAccounts = new List<Core_IPS_Account__c>();
         	if (Schema.sObjectType.Core_IPS_Account__c.isAccessible()){
            	 projMemAccounts=[select id,name, Core_Account__r.id,Core_Account__c,Core_IPS_Account_Name__c,Core_IPS_Project__r.Name,Core_IPS_Project__c from Core_IPS_Account__c where Core_IPS_Project__c  IN :projIds AND Core_Account__c!=null AND Core_IPS_Account_Name__c!=null AND Core_Status__c='Active'];
             }
            List<SelectOption> accountList = new List<SelectOption>();
            accountList.add(new SelectOption('NA','--Select--'));//Geetha
        
            if(projMemAccounts <> null && projMemAccounts.size()>0) {
                for(Core_IPS_Account__c ipsacc:projMemAccounts){
                    accountList.add(new SelectOption(ipsacc.Core_Account__c,ipsacc.Core_IPS_Account_Name__c));
                }
             }
            Set<SelectOption> accountoptSet = new Set<SelectOption>(accountList);
            accountList =new List<SelectOption>(accountoptSet );
            return accountList;
    }

}