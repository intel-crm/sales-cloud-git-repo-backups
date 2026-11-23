/***************************************************************************************************
Class Name:  Core_IPS_Customer_Case_Controller_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for Core_IPS_Customer_Case_Controller Apex Class.
When Agent Logs access Case, Agent is directed to Core_IPS_Customer_Case_Creation VF Page and Core_IPS_Customer_Case_Controller Class is invoked
Description:   This class contains unit test scenarios for Core_IPS_Customer_Case_Controller Apex Class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       02/02/2016                Created
****************************************************************************************************/   
@isTest
public class Core_IPS_Customer_Case_Controller_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> SysAdminUsr = new List<User> ();
    static List<User> ListOfCustomerSfUsers = new List<User> ();
    static List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c> ();
    static List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseCat = new List<Core_IPS_Master_Issue_Category__c>();//Added By Manoj
    static List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseSubCat = new List<Core_IPS_Master_Issue_Category__c>();//Added By Manoj
    static list<Asset> ListOfAssets = new list<Asset> ();
    static Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
    static  Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
    static Case CaseRecord = new Case();
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       02/02/2016                Created
    ****************************************************************************************************/
    static void getRecords(integer tid){
        // Query Profiles
        List<string> ListOfProfileNames = new List<string> {'System Administrator'};
        Map<String,ID> MapOfProfiles = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: ListOfProfileNames]){
            MapOfProfiles.put(prof.name, prof.id);
        }
        SysAdminUsr = TestUtilities.getListOfUser(1);
        SysAdminUsr.get(0).UserName = 'SysAdminUsr'+SysAdminUsr.get(0).UserName;
        SysAdminUsr.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        // Create UserRole Record
        UserRole role = new UserRole();
        role.name='CEO';
        // Creating SETUP OBJECT (USERROLE) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert role;
        }
        // Create Users
        ListOfCustomerSfUsers = TestUtilities.getListOfUser(1);
        ListOfCustomerSfUsers.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        ListOfCustomerSfUsers.get(0).userroleid = role.id;
        // Creating SETUP OBJECT (USER) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert ListOfCustomerSfUsers;
        }
        System.assertEquals(ListOfCustomerSfUsers.get(0).profileid, MapOfProfiles.get('System Administrator'));
        
         //Added By Manoj
        Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c(Name='CloseCaseEditPermission',Value__c='System Administrator');
        insert ipsLabel;
        
        // Create Account Record
        List<Account> ListOfAccounts = new List<Account> ();
        Account AccountRec1 = TestUtilities.getAccount();
        AccountRec1.Core_IPS_Active__c = true;
        AccountRec1.ownerid = ListOfCustomerSfUsers.get(0).id;
        AccountRec1.Core_Military_Aerospace_and_Government__c = true;
        ListOfAccounts.add(AccountRec1);
        insert ListOfAccounts;
        System.assert(ListOfAccounts[0].Id != null, 'Account Record not created');
                List<Core_IPS_Labels__c>  LstLabels = TestUtilities.getIPSLabel();
                insert LstLabels;
        
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        ListOfContacts.get(0).Accountid = ListOfAccounts.get(0).Id;
        ListOfContacts.get(0).Core_IPS_Intel_Support_Owner__c = ListOfCustomerSfUsers.get(0).id;
        ListOfContacts.get(0).ownerid = ListOfCustomerSfUsers.get(0).id;
        insert ListOfContacts;
        System.assert(ListOfContacts[0].Id != null, 'Contact Record not created');
        // Create Support Org Record
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert ListOfSupportOrg;
        System.assert(ListOfSupportOrg != null, 'Support Org Record not created');
        // Create Product2 Record
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        insert ListOfProducts;
        System.assert(ListOfProducts[0].id != null,'Product2 Record not created');
        // Create Supported product Record
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        insert ListOfSupportedProduct;
        System.assert(ListOfSupportedProduct[0].id != null,'Supported product Record not created');
        // Create Design Project Record
        ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        insert ListOfIpsProjects;
        System.assert(ListOfIpsProjects.get(0).Id != null, 'Design Project Record not created');
        // Create IPS Product Record
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        ListOfIpsProducts.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
        ListOfIpsProducts.get(0).Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
        ListOfIpsProducts.get(0).Status__c = 'Submitted';
        insert ListOfIpsProducts;
        System.assert(ListOfIpsProducts.get(0).Id != null, 'IPS Product Record not created');
        // Create Asset
        ListOfAssets = TestUtilities.getAssetList(1);
        ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfAssets.get(0).accountId = ListOfAccounts.get(0).Id;
       // if(tid!=1){
            ListOfAssets.get(0).core_supported_product__c = ListOfSupportedProduct[0].id;
        //}
        insert ListOfAssets;
        System.assert(ListOfAssets.get(0).Id != null, 'Asset Record not created');
        // Create Core Master Issue Category - Case Category
        ListOfCoreMasterIssueCategory_CaseCat = TestUtilities.getListOfCoreMastIssCategory(1);//Changed By Manoj
        ListOfCoreMasterIssueCategory_CaseCat.get(0).Core_type__c = 'Case Category';
        insert ListOfCoreMasterIssueCategory_CaseCat;
        System.assert(ListOfCoreMasterIssueCategory_CaseCat[0].Id != null, 'Record not Created');
        // Create Core Master Issue Category - Case Sub Category
        ListOfCoreMasterIssueCategory_CaseSubCat = TestUtilities.getListOfCoreMastIssCategory(1);//Changed By Manoj
        ListOfCoreMasterIssueCategory_CaseSubCat.get(0).Core_Master_Issue_Category__c = ListOfCoreMasterIssueCategory_CaseCat.get(0).id;
        insert ListOfCoreMasterIssueCategory_CaseSubCat;
        System.assert(ListOfCoreMasterIssueCategory_CaseSubCat[0].Id != null, 'Record not Created');
        // Create Core Product Issue Category - Case Category
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(2);
        for(Core_IPS_Product_Issue_Category__c ProdIssuCat : ListOfCoreProdIssCategory_CaseCat){
            ProdIssuCat.Core_type__c = 'Case Category';
            ProdIssuCat.Core_Issue_Category_Name__c = ListOfCoreMasterIssueCategory_CaseCat.get(0).id;
            ProdIssuCat.Core_supported_product__c = ListOfSupportedProduct[0].id;
        }
        insert ListOfCoreProdIssCategory_CaseCat;
        System.assert(ListOfCoreProdIssCategory_CaseCat[0].Id != null, 'Record not Created');
        //Creating MasterCaseCategory
        Core_IPS_Master_Issue_Category__c MasterCaseCategory = TestUtilities.getMasterCaseCategories();
        MasterCaseCategory.Core_type__c = 'Case Category';
        insert MasterCaseCategory;
        System.assert(MasterCaseCategory.Id != null, 'Record not created'); 
         //Creating MasterCategory
        Core_IPS_Master_Issue_Category__c MasterCategory = TestUtilities.getMasterCaseCategories();
        MasterCategory.Core_Master_Issue_Category__c = MasterCaseCategory.id;            
        insert MasterCategory;
        System.assert(MasterCategory.Id != null, 'Record not created');
        caseCat = TestUtilities.getCaseCategories();
        caseCat.Core_Issue_Category_Name__c = MasterCategory.id;
        caseCat.Core_Type__c = 'Case Category';
        insert caseCat; 
        System.assert(caseCat.Id != null, 'Record not created');
        
        subCategory = TestUtilities.getCaseCategories();
        subCategory.Core_Issue_Sub_Category_Name__c = MasterCategory.id;
        subCategory.Core_Type__c = 'Case Subcategory';
        insert subCategory; 
                System.assert(subCategory.Id != null, 'Record not created');
        CaseRecord = new Case ();
        CaseRecord.AccountId=ListOfAccounts.get(0).Id;
        if(tid!=3){
            if(tid!=4){
          CaseRecord.AssetId=ListOfAssets.get(0).Id;
            }
            CaseRecord.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
        }
        CaseRecord.ContactId=ListOfContacts.get(0).id;        
        CaseRecord.Core_IPS_Product_Org1__c=ListOfSupportOrg.get(0).id;
        CaseRecord.Core_Case_Issue_Category__c = caseCat.id;
        CaseRecord.Core_case_issue_sub_category__c = subCategory.id;
        CaseRecord.Core_Issue_Description__c = 'test';
        CaseRecord.Subject='TestSubject';
        CaseRecord.Core_CaseType__c='Issue';
        if(tid==1){
          CaseRecord.Core_Severity__c='Critical';
        }
        if(tid!=1){
            insert CaseRecord;
            }
        
        //create env Var
            List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
            //Modified By Manoj
            for(integer i=0;i<8;i++){
                Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
                envVar.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                ListOfenvVars.add(envVar);
            }
            
            ListOfenvVars[0].Core_Datatype__c= 'Picklist';
            ListOfenvVars[1].Core_Datatype__c= 'Text (255)';
            ListOfenvVars[2].Core_Datatype__c= 'Text Area (5000)';
            ListOfenvVars[3].Core_Datatype__c= 'Multiselect Picklist';

            //Added By Manoj 
            ListOfenvVars[4].Core_Datatype__c= 'Picklist';
            ListOfenvVars[5].Core_Datatype__c= 'Text (255)';
            ListOfenvVars[6].Core_Datatype__c= 'Text Area (5000)';
            ListOfenvVars[7].Core_Datatype__c= 'Multiselect Picklist';
            
            
            insert ListOfenvVars;
            System.assert(ListOfenvVars[0].Id != null, 'Record not created');
            //Creating EnvironmentalDetails
            List<Core_IPS_Assigned_Environment_Variables__c> EnvironmentalDetailsList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            for(integer i=0;i<4;i++){
            Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails = TestUtilities.getEnvironmentalDetailsOperational();
            EnvironmentalDetails.Core_Environment_Variable__c = ListOfenvVars[i].id;
                EnvironmentalDetails.Core_Required__c=true;
            EnvironmentalDetails.Core_supported_product__c = ListOfSupportedProduct[0].id;
            EnvironmentalDetailsList.add(EnvironmentalDetails);
            }
            
            Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
            EnvDetails.Core_Environment_Variable__c = ListOfenvVars[4].id;
            EnvDetails.Core_Required__c=true;
            EnvDetails.Core_Status__c = 'Active';
            EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
       
            Core_IPS_Assigned_Environment_Variables__c EnvDetails1 = TestUtilities.getEnvironmentalDetailsOperational();
            EnvDetails1.Core_Environment_Variable__c = ListOfenvVars[5].id;
            EnvDetails1.Core_Required__c=true;
            EnvDetails1.Core_Status__c = 'Active';
            EnvDetails1.Core_Product_Issue_Sub_Category__c = subCategory.Id;
            
            Core_IPS_Assigned_Environment_Variables__c EnvDetails2 = TestUtilities.getEnvironmentalDetailsOperational();
            EnvDetails2.Core_Environment_Variable__c = ListOfenvVars[6].id;
            EnvDetails2.Core_Required__c=true;
            EnvDetails2.Core_Status__c = 'Active';
            EnvDetails2.Core_Product_Issue_Sub_Category__c = subCategory.Id;
            
            Core_IPS_Assigned_Environment_Variables__c EnvDetails3 = TestUtilities.getEnvironmentalDetailsOperational();
            EnvDetails3.Core_Environment_Variable__c = ListOfenvVars[7].id;
            EnvDetails3.Core_Required__c=true;
            EnvDetails3.Core_Status__c = 'Active';
            EnvDetails3.Core_Product_Issue_Sub_Category__c = subCategory.Id;
            
            EnvironmentalDetailsList.add(EnvDetails);
            EnvironmentalDetailsList.add(EnvDetails1);
            EnvironmentalDetailsList.add(EnvDetails2);
            EnvironmentalDetailsList.add(EnvDetails3);          
            //Ended By Manoj
            
            insert EnvironmentalDetailsList;
            System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
            Core_IPS_Environment_Details__c envDetal = new Core_IPS_Environment_Details__c();
            envDetal.Name = 'Issue Resolution List';
            envDetal.Core_Question__c='intel';
            envDetal.Core_Answer__c='TestAnswer1;TestAns2;Testans3';
            envDetal.Core_Case__c = CaseRecord.id;
        if(tid!=1){
            insert envDetal;                
            System.assert(envDetal.Id != null, 'Record not created');}
           List<Core_IPS_Error_Code__c> errorCodes= TestUtilities.getListOfIpsErrorCodes();
            insert errorCodes;
            System.assert(errorCodes[0].Id != null, 'Record not created');
        /*
        // Create Core Product Issue Category - Case Sub Category
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseSubCat = TestUtilities.getListOfCoreProdIssCategory(1);
        ListOfCoreProdIssCategory_CaseSubCat.get(0).Core_Product_Issue_Category__c = ListOfCoreProdIssCategory_CaseCat.get(0).id;
        ListOfCoreProdIssCategory_CaseSubCat.get(0).Core_Issue_Sub_Category_Name__c = ListOfCoreMasterIssueCategory_CaseSubCat.get(0).id;
        ListOfCoreProdIssCategory_CaseSubCat.get(0).Core_supported_product__c = ListOfSupportedProduct[0].id;
        insert ListOfCoreProdIssCategory_CaseSubCat;
        System.assert(ListOfCoreProdIssCategory_CaseSubCat[0].Id != null, 'Record not Created');
        */
    }
    /***************************************************************************************************
    Method Name:  InsertCaseRecord
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Creating Case Record by Clicking "NEW CASE" field in "ASSET OBJECT"
    Input Parameter in URL : mode=asset, productId and projectId
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       02/02/2016                 Created
    ***************************************************************************************************/
    static testmethod void InsertCaseRecord(){
        getRecords(1);
        //CaseRecord = new Case(); COmmented By Manoj
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
         system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Contact';
        ipsCustomerCaseController.LookupChange();  
        //ipsCustomerCaseController.getCountriesOptions();
        ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController.selectedProduct = '';
        Pagereference Pg = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.selectedProject = null;//Added By Manoj
        Pagereference Pg1 = ipsCustomerCaseController.clearProduct();//Added By Manoj
        //ipsCustomerCaseController.contactClear();
        ipsCustomerCaseController.clearEnvDetails();
        
         ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
        ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
        
        ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentDets();
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        
        /*ipsCustomerCaseController.envDetails[0].selectedValue='test';
            ipsCustomerCaseController.GECAnswer1='Yes';
            List<String> val= new List<String>();
            val.add('test');
            val.add('test1');
        ipsCustomerCaseController.envDetails[3].selectedMValue=val; */
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        //ipsCustomerCaseController.addGECRecords();
        /********Added By Manoj*********/
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        ipsCustomerCaseController.subCatenvDetList[0].type='Text (255)';
        ipsCustomerCaseController.subCatenvDetList[0].sPlaceHolder='';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Text (255)';
        ipsCustomerCaseController.subCatenvDetList[0].sPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
                
        ipsCustomerCaseController.subCatenvDetList[0].type='Text Area (5000)';
        ipsCustomerCaseController.subCatenvDetList[0].tPlaceHolder='';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Text Area (5000)';
        ipsCustomerCaseController.subCatenvDetList[0].tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Multiselect Picklist';
        ipsCustomerCaseController.subCatenvDetList[0].selectedMValue=null;
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        
        /********Ended By Manoj*********/
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        ipsCustomerCaseController.saveCaseDetails();//Added By Manoj
        
        //Ended By Manoj
        //ipsCustomerCaseController.categorySelected = caseCat.id;
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        ipsCustomerCaseController.showGECFields = true;
        
        

    }
    /***************************************************************************************************
    Method Name:  InsertCaseRecord
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 08 Feb 2016
    Description:  Creating Case Record by Clicking "NEW CASE" field in "Edit OBJECT"
    Input Parameter in URL : mode=edit, productId and projectId
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Ekbote      08/02/2016                 Created
    ****************************************************************************************************/
    static testmethod void InsertCaseRecord_editObj(){
        getRecords(3);
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Contact';
              system.debug('envDetails - ' + ipsCustomerCaseController.envDetails);
        ipsCustomerCaseController.GECAnswer2 ='Yes';
        ipsCustomerCaseController.GECAnswer3 ='Yes';
        ipsCustomerCaseController.GECAnswer1 ='Yes';
          //  ipsCustomerCaseController.showGECFields = true;  //added by abhishek
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getEnvDetails();
        ipsCustomerCaseController.saveCaseDetails();
        } 
    }
    /***************************************************************************************************
    Method Name:  testLookupChange
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 08 Feb 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Ekbote      09/02/2016                 Created
    *************************************************************************************************** */
    static testmethod void testLookupChange(){
        getRecords(1);
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        system.debug('envDetails - ' + ipsCustomerCaseController.envDetails);
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getEnvDetails();
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;
        ipsCustomerCaseController.getEnvDetails();
    }
    
    static testmethod void InsertCaseRecord_editObjWithSAP(){
        getRecords(4);
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Contact';
        system.debug('envDetails - 1' + ipsCustomerCaseController.envDetails);
            
        ipsCustomerCaseController.LookupChange();
    ipsCustomerCaseController.getEnvDetails();
        ipsCustomerCaseController.showGECFields = true; 
        ipsCustomerCaseController.saveCaseDetails();
        } 
    }
   
    static testmethod void InsertCaseRecords(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        
        ipsCustomerCaseController.LookupChange();  
        ipsCustomerCaseController.getEnvDetails();
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
    ipsCustomerCaseController.categorySelected=caseCat.id;
        ipsCustomerCaseController.subCategorySelected= subCategory.id;
        ipsCustomerCaseController.envDetails[0].selectedValue='test';
            ipsCustomerCaseController.GECAnswer1='Yes';
            List<String> val= new List<String>();
            val.add('test');
            val.add('test2');
         ipsCustomerCaseController.envDetails[3].selectedMValue=val;
        ipsCustomerCaseController.saveCaseDetails();
        ipsCustomerCaseController.GECAnswer1 = 'Yes';
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.showGECFields = true;
        //ipsCustomerCaseController.addGECRecords();
        ipsCustomerCaseController.DisplayPriorityReason();
        ipsCustomerCaseController.showProjListBasedOnSelectedProd();
        ipsCustomerCaseController.productChanges();
        ipsCustomerCaseController.clearProject();
       }
    }
    static testmethod void cancelAction(){   
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getHeaders().put('referer','test');
        ApexPages.currentPage().getParameters().put('retURL','test');
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.CancelAction();
        ipsCustomerCaseController.pageInit();
    }
     static testmethod void validateCaseRelatedInformation1(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
       
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        ipsCustomerCaseController.categorySelected='';
        //ipsCustomerCaseController.subCategorySelected= subCategory.id;
        ipsCustomerCaseController.validateCaseRelatedInformation();
       }
    }
    static testmethod void validateCaseRelatedInformation2(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        ipsCustomerCaseController.categorySelected='sdas';
        ipsCustomerCaseController.subCategorySelected= '';
        ipsCustomerCaseController.validateCaseRelatedInformation();
       }
    }
    static testmethod void validateCaseRelatedInformation3(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        CaseRecord.Subject = '';
        //CaseRecord.Core_Issue_Description__c = 'dasadsa';
        //CaseRecord.Core_Severity__c='Medium';
        //CaseRecord.Core_CaseType__c ='';
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        ipsCustomerCaseController.categorySelected='sdas';
        ipsCustomerCaseController.subCategorySelected= 'sadasd';
        ipsCustomerCaseController.validateCaseRelatedInformation();
       }
    }
    static testmethod void validateCustomerCase4(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        CaseRecord.Subject = 'sd';
        CaseRecord.Core_Issue_Description__c = '';
        //CaseRecord.Core_Severity__c='Medium';
        //CaseRecord.Core_CaseType__c ='';
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        ipsCustomerCaseController.categorySelected='sdas';
        ipsCustomerCaseController.subCategorySelected= 'sdsa';
        ipsCustomerCaseController.validateCaseRelatedInformation();
       }
    }
    static testmethod void validateCaseRelatedInformation5(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        CaseRecord.Subject = 'sd';
        CaseRecord.Core_Issue_Description__c = 'dasd';
        CaseRecord.Core_Severity__c='';
        //CaseRecord.Core_CaseType__c ='';
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        ipsCustomerCaseController.categorySelected='sdas';
        ipsCustomerCaseController.subCategorySelected= 'sdsa';
        ipsCustomerCaseController.validateCaseRelatedInformation();
       }
    }
    static testmethod void validateCaseRelatedInformation6(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        CaseRecord.Subject = 'sd';
        CaseRecord.Core_Issue_Description__c = 'dasd';
        CaseRecord.Core_Severity__c='Medium';
        CaseRecord.Core_CaseType__c ='';
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        ipsCustomerCaseController.categorySelected='sdas';
        ipsCustomerCaseController.subCategorySelected= 'sdsa';
        ipsCustomerCaseController.validateCaseRelatedInformation();
       }
    }
    static testmethod void validateEnvironmentDetails1(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        
        ipsCustomerCaseController.getEnvDetails();         
         system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
         
        ipsCustomerCaseController.envDetails[0].type='Text (255)';
        ipsCustomerCaseController.envDetails[0].sPlaceHolder='';
        ipsCustomerCaseController.envDetails[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();
       }
    }
    static testmethod void validateEnvironmentDetails2(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.getEnvDetails();         
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        ipsCustomerCaseController.envDetails[0].type='Text (255)';
        ipsCustomerCaseController.envDetails[0].sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        ipsCustomerCaseController.envDetails[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();
       }
       
    }
    static testmethod void validateEnvironmentDetails21(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.getEnvDetails();         
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        
        
        ipsCustomerCaseController.envDetails[0].selectedValue='dsadas';
        ipsCustomerCaseController.envDetails[2].type='Text Area (5000)';
        ipsCustomerCaseController.envDetails[2].tPlaceHolder='';
        ipsCustomerCaseController.envDetails[2].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();
        
        /**********Added By Manoj**********/
        ipsCustomerCaseController.envDetails[0].type='Text Area (5000)';
        ipsCustomerCaseController.envDetails[0].tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        ipsCustomerCaseController.envDetails[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();
        /*********Ended By Manoj***********/
       }
       
    }
    static testmethod void validateEnvironmentDetails4(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.getEnvDetails();         
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        
        
                
        ipsCustomerCaseController.envDetails[0].type='Picklist';
        ipsCustomerCaseController.envDetails[0].selectedValue='';
        ipsCustomerCaseController.envDetails[0].required=true;
        
        ipsCustomerCaseController.validateEnvironmentDetails();
       }
       
    }
    static testmethod void validateEnvironmentDetails5(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.getEnvDetails();         
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
        
        
                
        ipsCustomerCaseController.envDetails[0].selectedValue='dsadas';
        ipsCustomerCaseController.envDetails[3].type='Multiselect Picklist';
        ipsCustomerCaseController.envDetails[3].selectedMValue=null;
        ipsCustomerCaseController.envDetails[3].required=true;
        
        ipsCustomerCaseController.validateEnvironmentDetails();
       }
       
    }
    static testmethod void addGECRecordsTest(){
        getRecords(0);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        //ipsCustomerCaseController.addGECRecords();
       }
       
    }
    
    static testmethod void productChangesTest(){
        getRecords(0);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('firstparameter',ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('secparameter', 'asdads');
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.objectSelected ='Product';
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.productChanges();
       }
       
    }
    
    static testMethod void validateCustomerCaseTest10()
    {
       getRecords(0);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('firstparameter',ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('secparameter', 'asdads');
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.projectList =  new List<SelectOption>(); 
        ipsCustomerCaseController.projectList.add(new SelectOption('ABC','ABC'));
        ipsCustomerCaseController.projectList.add(new SelectOption('ABC1','ABC1'));
        ipsCustomerCaseController.selectedProject ='NA';
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.validateCustomerCase();
       }
    }
    
    static testMethod void validateCustomerCaseTest11()
    {
       getRecords(0);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('firstparameter',ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('secparameter', 'asdads');
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.projectList =  new List<SelectOption>(); 
        ipsCustomerCaseController.projectList.add(new SelectOption('ABC','ABC'));
        ipsCustomerCaseController.projectList.add(new SelectOption('ABC1','ABC1'));
        ipsCustomerCaseController.selectedProject ='sdasdsa';
        ipsCustomerCaseController.selectedProductId = null ; 
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.validateCustomerCase();
       }
    }
    static testMethod void validateCustomerCaseTest12()
    {
       getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','new');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('firstparameter',ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('secparameter', 'asdads');
        
        // instantiate the Controller - Core_IPS_Customer_Case_Controller Apex Class
        Core_IPS_Customer_Case_Controller ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.AnswerOptions =  new List<SelectOption>(); 
        ipsCustomerCaseController.renderErrorFlag =true;
        ipsCustomerCaseController.selectedContactId = '>>>>>>>>>>>>>>>>>';
        ipsCustomerCaseController.displaySelfAssigned = true;
       // ipsCustomerCaseController.supProduct = new core_IPS_supported_product__c();
        //ipsCustomerCaseController.displayForCust = true;
        ipsCustomerCaseController.hasProject = true;       
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.BindEvent();        
       }
    }
    
}