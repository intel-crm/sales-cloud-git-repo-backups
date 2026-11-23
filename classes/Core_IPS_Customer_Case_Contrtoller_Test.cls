/***************************************************************************************************
Class Name:   Core_IPS_Customer_Case_Contrtoller_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for Core_IPS_Customer_Case_Controller  Apex Class.
When Agent Logs access Case, Agent is directed to Core_IPS_Customer_Case_Creation VF Page and Core_IPS_Customer_Case_Controller  Class is invoked
Description:   This class contains unit test scenarios for Core_IPS_Customer_Case_Controller  Apex Class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       02/02/2016                Created
****************************************************************************************************/   
@isTest
public class Core_IPS_Customer_Case_Contrtoller_Test{
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
    static case CaseRecord1;
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
        ListOfAssets.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).Id;
        ListOfAssets.get(0).product2Id = ListOfProducts.get(0).Id;
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
            ProdIssuCat.Core_Issue_Sub_Category_Name__c = ListOfCoreMasterIssueCategory_CaseSubCat.get(0).id; 
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
        Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
        insert cipspro;
        
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
        CaseRecord.Core_Partner_Supported_Account__c=AccountRec1.id;
        CaseRecord.Core_IPS_Product_name__c='Licensed Products';
        CaseRecord.core_ips_project_case__c=cipspro.id;
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
        ListOfenvVars[1].Core_Datatype__c= 'Text';
        ListOfenvVars[2].Core_Datatype__c= 'Text Area';
        ListOfenvVars[3].Core_Datatype__c= 'Multiselect Picklist';
        //Added By Manoj 
        ListOfenvVars[4].Core_Datatype__c= 'Picklist';
        ListOfenvVars[5].Core_Datatype__c= 'Text';
        ListOfenvVars[6].Core_Datatype__c= 'Text Area';
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
        
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
        //parQues.recordtypeid = edqRecordTypeId;
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).id;
        
        insert parQues1;        
        EnvironmentalDetailsList[0].Core_IPS_Question__c =parQues1.id;
        
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
   /* static testmethod void InsertCaseRecord(){
        //test.startTest();
        getRecords(1);
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        
        Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
        system.debug('edqRecordTypeId===='+edqRecordTypeId);
        
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(2);
        for(Core_IPS_Product_Issue_Category__c ProdIssuCat : ListOfCoreProdIssCategory_CaseCat){
            ProdIssuCat.Core_type__c = 'Case Category';
            ProdIssuCat.Core_Issue_Category_Name__c = ListOfCoreMasterIssueCategory_CaseCat.get(0).id;
            ProdIssuCat.Core_supported_product__c = ListOfSupportedProduct[0].id;
            ProdIssuCat.Core_Issue_Sub_Category_Name__c = ListOfCoreMasterIssueCategory_CaseSubCat.get(0).id; 
        }
        insert ListOfCoreProdIssCategory_CaseCat;
        
        Core_IPS_Product_Issue_Category__c  subCategory = new Core_IPS_Product_Issue_Category__c();
        subCategory.Core_Status__c = 'Active';
        subCategory.Core_Type__c = 'Case Subcategory';
        subCategory.Core_Product_Issue_Category__c = ListOfCoreProdIssCategory_CaseCat.get(0).id;
        insert subCategory;
        
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        //Modified By Manoj
        for(integer i=0;i<8;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = CIPO.Id;
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
        
        //Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        //Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        ApexPages.currentPage().getParameters().put('sbs','ccs');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        //instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.showGECFields = True;
        ipsCustomerCaseController.objectSelected ='Contact';
        system.debug(ipsCustomerCaseController.displayPlatform);
        system.debug(ipsCustomerCaseController.platformOptions);
        ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsCustomerCaseController.displayProductVariant();
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getCountries();
        ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController.selectedProduct = '';
        Pagereference Pg = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.selectedProject = null;//Added By Manoj
        Pagereference Pg1 = ipsCustomerCaseController.clearProduct();//Added By Manoj
        ipsCustomerCaseController.clearEnvDetails();
        
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
        Core_IPS_Question__c parQues = new Core_IPS_Question__c();       
        parQues.recordtypeid = edqRecordTypeId;
        parQues.Core_IPS_Question__c = 'Test Parent Question';
        parQues.Core_IPS_Datatype__c = 'Picklist';
        parQues.Core_IPS_Status__c = 'Active';
        parQues.Core_IPS_Product_Organization__c = Org.id;
        
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        
        Core_IPS_Question__c parQues2 = new Core_IPS_Question__c();
        parQues2.Core_IPS_Question__c = 'Test Parent Question';
        parQues2.Core_IPS_Datatype__c = 'Multiselect Picklist';
        parQues2.Core_IPS_Status__c = 'Active';
        parQues2.Core_IPS_Product_Organization__c = Org.id;
        
        Core_IPS_Question__c parQues3 = new Core_IPS_Question__c();
        parQues3.Core_IPS_Question__c = 'Test Parent Question';
        parQues3.Core_IPS_Datatype__c = 'Text Area';
        parQues3.Core_IPS_Status__c = 'Active';
        parQues3.Core_IPS_Product_Organization__c = Org.id;
        
        lstparQues.add(parQues);
        lstparQues.add(parQues1);
        lstparQues.add(parQues2);
        lstparQues.add(parQues3);
        insert lstparQues;
        
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<8;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Product_Organization__c = org.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues.id;
            childQuesList.add(childQuestion);
        }
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues.id;
        insert parentAns;
        
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        
        Case cs = new Case();
        cs.assetId=asset.id;
        cs.Core_IPS_Issue_source__c='Legacy PSG';
        insert cs;
        System.assertEquals('Legacy PSG', cs.Core_IPS_Issue_source__c);
        
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = parQues.Id;
        envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
        envResponse.Core_IPS_Case__c = cs.Id;
        lstEnvResponse.add(envResponse);
        insert lstEnvResponse;
        
        List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
        Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
        question.isVisible=false;
        question.type='Text';
        question.questionId=parQues.id;
        question.sPlaceHolder=null;
        question.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
        question1.type='Text Area';
        question1.questionId=parQues.id;
        question1.tPlaceHolder='';
        
        
        Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
        question2.type='Picklist';
        question2.questionId=parQues.id;
        question2.sPlaceHolder=null;
        
        Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
        question3.type='Multiselect Picklist';
        question3.questionId=parQues.id;
        question3.sPlaceHolder=null;
        question3.selectedMValue=new List<String>{parentAns.Id};
            
            Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
        question4.type='Text';
        question4.questionId=parQues.id;
        question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        question4.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
        question5.type='Text Area';
        question5.questionId=parQues.id;
        question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        lstquestion.add(question);
        lstquestion.add(question1);
        lstquestion.add(question2);
        lstquestion.add(question3);
        lstquestion.add(question4);
        lstquestion.add(question5);
        
        
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        EnvDetails.Core_IPS_Question__c =parQues.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        
        ipsCustomerCaseController.constructResponse(question);
        ipsCustomerCaseController.constructResponse(question1);
        ipsCustomerCaseController.constructResponse(question2);
        ipsCustomerCaseController.constructResponse(question3);
        ipsCustomerCaseController.constructResponse(question4);
        ipsCustomerCaseController.constructResponse(question5);
        test.startTest();
        ipsCustomerCaseController.setCurrentEnvironmentDetails(lstquestion,cs.id);
        ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
        ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        
    
        ipsCustomerCaseController.getEnvironmentOptions();
	    
        ipsCustomerCaseController.getEnvironmentDets();
	
        system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        system.debug(ipsCustomerCaseController.GECAnswer1);
        system.debug(ipsCustomerCaseController.GECAnswer2);
        //Added By Manoj
        ipsCustomerCaseController.envDetails=lstquestion;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        ipsCustomerCaseController.subCatenvDetList[0].type='Text';
        ipsCustomerCaseController.subCatenvDetList[0].sPlaceHolder='';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();
        //Added By Manoj
        ipsCustomerCaseController.subCatenvDetList[0].type='Text';
        ipsCustomerCaseController.subCatenvDetList[0].sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Text Area';
        ipsCustomerCaseController.subCatenvDetList[0].tPlaceHolder='';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Text Area';
        ipsCustomerCaseController.subCatenvDetList[0].tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Multiselect Picklist';
        ipsCustomerCaseController.subCatenvDetList[0].selectedMValue=null;
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        //Ended By Manoj
        ipsCustomerCaseController.validateEnvironmentDetails();
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        test.stopTest();
    }*/
    
   /* static testmethod void InsertCaseRecordNegative(){
        test.startTest();
        getRecords(1);
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        
        Case cs = new Case();
        cs.assetId=asset.id;
        insert cs;
        
        Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
        insert subCategory;
        
        
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        ApexPages.currentPage().getParameters().put('sbs','ccs');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.showGECFields = True;
        ipsCustomerCaseController.objectSelected ='Contact';
        ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        //EnvDetails.Core_IPS_Question__c =parQues1.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        System.assertEquals('Active', EnvDetails.Core_Status__c);
        
        ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
        ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentOptions();
        ipsCustomerCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        ipsCustomerCaseController.GECAnswer1='Yes'; 
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        //Added By Manoj
        ipsCustomerCaseController.saveCaseDetails();//Added By Manoj
        ipsCustomerCaseController.mode='sNew';
        ipsCustomerCaseController.showGECFields=false;
        ipsCustomerCaseController.subCatenvDetList= null;
        ipsCustomerCaseController.envDetails=null;
        ipsCustomerCaseController.saveCaseDetails();
        system.debug(ipsCustomerCaseController.GECAnswer1);
        system.debug(ipsCustomerCaseController.GECAnswer2);
        
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        test.stopTest();
    }*/
    
    static testmethod void InsertCaseRecordNegativeTest(){
        getRecords(1);
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        Account accountRecord1 = new Account(
            Name = 'Dell Products test',
            Core_Account_Type__c = 'Distributor',
            Core_Sales_Segment__c = 'Compute',
            Industry = 'Banking',
            BillingCity = 'Delhi',
            BillingCountry = 'USA',
            billingState = 'AK',
            billingStreet = 'Bratislava 1',
            Core_IPS_Active__c = true
        );
        insert accountRecord1;
        Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
        insert cipspro;
        
        core_ips_account__c projAccount= new core_ips_account__c();
        projAccount.Core_Account__c=accountRecord1.Id;
        projAccount.Core_IPS_Project__c=cipspro.Id;
        projAccount.Core_Members__c = 'All';
        projAccount.Core_Status__c = 'Active';
        insert projAccount;
        test.startTest();
        
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        ApexPages.currentPage().getParameters().put('sbs','ccs');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('accountId', projAccount.id);
        ApexPages.currentPage().getParameters().put('projectId', cipspro.Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.showGECFields = True;
        ipsCustomerCaseController.objectSelected ='Contact';
        ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getCountries();
        ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController.selectedProduct = '';
        Pagereference Pg = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.selectedProject = null;//Added By Manoj
        Pagereference Pg1 = ipsCustomerCaseController.clearProduct();//Added By Manoj
        ipsCustomerCaseController.clearEnvDetails();
        
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
        //parQues.recordtypeid = edqRecordTypeId;
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text Area';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        lstparQues.add(parQues1);
        insert lstparQues;
        
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<8;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            // childQuestion.recordTypeId = edqRecordTypeId;
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Product_Organization__c = org.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues1.id;
            childQuesList.add(childQuestion);
        }
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues1.id;
        insert parentAns;
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        System.assertEquals('intel@Products', asset.Name);
        
        Case cs = new Case();
        cs.assetId=asset.id;
        insert cs;
        
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = parQues1.Id;
        envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
        envResponse.Core_IPS_Case__c = cs.Id;
        //Core_IPS_Answer__c
        lstEnvResponse.add(envResponse);
        insert lstEnvResponse;
        
        List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
        Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
        question.isVisible=false;
        question.type='Text';
        question.questionId=parQues1.id;
        question.sPlaceHolder=null;
        question.required=true;
        question.selectedValue='test';
        
        Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
        question4.type='Text';
        question4.questionId=parQues1.id;
        question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        
        Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
        question1.type='Text Area';
        question1.questionId=parQues1.id;
        question1.tPlaceHolder='';
        question4.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
        question5.type='Text Area';
        question5.questionId=parQues1.id;
        question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        
        Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
        question2.type='Picklist';
        question2.questionId=parQues1.id;
        question2.sPlaceHolder=null;
        
        Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
        question3.type='Multiselect Picklist';
        question3.questionId=parQues1.id;
        question3.sPlaceHolder=null;
        
        lstquestion.add(question);
        lstquestion.add(question1);
        lstquestion.add(question2);
        lstquestion.add(question3);
        lstquestion.add(question4);
        lstquestion.add(question5);
        
        Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
        label1.name= 'Core_IPS_Datatype_TextArea';
        label1.value__c= 'Text Area';
        insert label1;
        
        Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
        insert subCategory;
        
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        EnvDetails.Core_IPS_Question__c =parQues1.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        
        
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        //Modified By Manoj
        for(integer i=0;i<8;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = CIPO.Id;
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
        
        ipsCustomerCaseController.constructResponse(question);
        ipsCustomerCaseController.constructResponse(question2);
        ipsCustomerCaseController.constructResponse(question5);
        ipsCustomerCaseController.constructResponse(question3);
        ipsCustomerCaseController.constructResponse(question1);
        ipsCustomerCaseController.constructResponse(question4);
        
        ipsCustomerCaseController.setCurrentEnvironmentDetails(lstquestion,cs.id);
        ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
        ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentOptions();
        ipsCustomerCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        ipsCustomerCaseController.GECAnswer1='Yes';
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        /********Added By Manoj*********/ 
        ipsCustomerCaseController.envDetails=lstquestion;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        ipsCustomerCaseController.subCatenvDetList[0].type='Text (255)';
        ipsCustomerCaseController.subCatenvDetList[0].sPlaceHolder='';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Text (255)';
        ipsCustomerCaseController.subCatenvDetList[0].sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Text Area (5000)';
        ipsCustomerCaseController.subCatenvDetList[0].tPlaceHolder='';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Text Area (5000)';
        ipsCustomerCaseController.subCatenvDetList[0].tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        
        ipsCustomerCaseController.subCatenvDetList[0].type='Multiselect Picklist';
        ipsCustomerCaseController.subCatenvDetList[0].selectedMValue=null;
        ipsCustomerCaseController.subCatenvDetList[0].required=true;
        
        /********Ended By Manoj*********/
        ipsCustomerCaseController.validateEnvironmentDetails();//Added By Manoj
        ipsCustomerCaseController.saveCaseDetails();//Added By Manoj
        system.debug(ipsCustomerCaseController.GECAnswer1);
        system.debug(ipsCustomerCaseController.GECAnswer2);
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        test.stopTest();
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
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert ListOfSupportOrg;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        insert ListOfProducts;
        System.assert(ListOfProducts[0].id != null,'Product2 Record not created');
        // Create Supported product Record
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        insert ListOfSupportedProduct;
        System.assert(ListOfSupportedProduct[0].id != null,'Supported product Record not created');
        
        Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
        cipspro.Core_Status__c='Draft';
        insert cipspro;
        cipspro.Core_Status__c='Inactive';
        update cipspro;
        
        Account testAccount = new Account();
        Contact testContact = new Contact();
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        User u = [select id from user where usertype='Standard' AND ISActive=true AND profileId=:prof.id AND  UserRole.Name != NULL limit 1 ];
        System.RunAs(u){
            testAccount.Name='testAccountSetup';
            testAccount.Core_Sales_Group__c='Global Accounts';
            testAccount.Core_Account_Type__c='Other';
            testAccount.Industry='Others';
            testAccount.BillingStreet='1234 testAccountSetup';
            testAccount.BillingCity='testCity1';
            testAccount.BillingState='OR';
            testAccount.BillingCountry='USA';
            testAccount.BillingPostalCode='12345';
            testAccount.Core_CNDA_Number__c = '126545';
            insert testAccount;
            
            testContact.FirstName='testFirstName123';
            testContact.LastName='testLastName';
            testContact.Email='test123456@testing.com.testsetup';
            testContact.Core_IPS_Intel_Support_Owner__c=u.id;
            testContact.AccountId=testAccount.id;
            testContact.Core_Personal_Email_Indicator__c = false;
            testContact.Core_Enterprise_Id__c='12345';
            testContact.Core_AGS_Integration_Status__c='Successful';
            testContact.Core_IPS_Active__c=true;
            insert testContact;            
        }
        Asset asset= new Asset();
        asset.Name='intel Products test';
        insert asset;    
        User u1 = [select id from user where usertype='Standard' AND ISActive=true AND UserRole.Name != NULL limit 1 ];
        String RT = [Select Id,Name From RecordType Where SobjectType = 'Case' and DeveloperName ='IPS_Case_Create'].Id;
        Case  cse = new Case ();
        cse.RecordTypeId=RT;
        cse.core_ips_project_case__c=cipspro.id;
        cse.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
        cse.status='closed';
        cse.accountid=testAccount.id;
        cse.contactid=testContact.id;
        cse.assetId=asset.id;
        cse.Core_IPS_Partner_Sup_Owner__c=u1.id;
        cse.Core_IPS_Issue_source__c='Legacy PSG';
        cse.Core_Severity__c='Critical';
        insert cse;
        
        Test.startTest();
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            /*String RT = [Select Id,Name From RecordType Where SobjectType = 'Case' and DeveloperName ='IPS_Case_Create'].Id;
Case  cse = new Case ();
cse.RecordTypeId=RT;
cse.core_ips_project_case__c=cipspro.id;
cse.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
cse.status='closed';
cse.accountid=testAccount.id;
cse.contactid=testContact.id;
cse.assetId=asset.id;
cse.Core_IPS_Partner_Sup_Owner__c=ListOfCustomerSfUsers.get(0).id;
cse.Core_IPS_Issue_source__c='Legacy PSG';
cse.Core_Severity__c='Critical';
insert cse;*/
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','edit');
            ApexPages.currentPage().getParameters().put('rType',RT);
            Case CaseRecord = Core_IPS_CaseUtility.getCase_DynamiCSOQL(cse.id,true);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Contact';
            system.debug('envDetails - ' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.GECAnswer2 ='Yes';
            ipsCustomerCaseController.GECAnswer3 ='Yes';
            ipsCustomerCaseController.GECAnswer1 ='Yes';
            ipsCustomerCaseController.LookupChange(); 
            ipsCustomerCaseController.getEnvDetails();
            ipsCustomerCaseController.saveCaseDetails();
            ipsCustomerCaseController.clearProject();
            ipsCustomerCaseController.selectedProject='NA';
            ipsCustomerCaseController.clearProject();                
        }
        Test.stopTest();        
    }
    
    static testmethod void InsertCaseRecord_editObjWithSAP(){
        getRecords(4);
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
        
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c(); 
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        lstparQues.add(parQues1);
        insert lstparQues;
        
        Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
        insert subCategory;
        
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        EnvDetails.Core_IPS_Question__c =parQues1.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        System.assertEquals('Active', EnvDetails.Core_Status__c);
        
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','edit');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Contact';
            system.debug('envDetails - 1' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.LookupChange();
            ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
            ipsCustomerCaseController.showProjListBasedOnSelectedProd();
            ipsCustomerCaseController.subCategorySelected_old = 'fggf';
            ipsCustomerCaseController.subCategorySelected = 'test';
            ipsCustomerCaseController.Mode = 'edit';
            //ipsCustomerCaseController.GECAnswer1='Yes';
            //ipsCustomerCaseController.validateGecDetails();
            ipsCustomerCaseController.isMindsFlag = true;
            ipsCustomerCaseController.getEnvDetails();
            ipsCustomerCaseController.showGECFields = true; 
            ipsCustomerCaseController.saveCaseDetails();
        } 
        
    }  
    static testmethod void InsertCaseRecordsWithoutAccount(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        CaseRecord.Core_Severity__c='Critical1';
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Product';
            ipsCustomerCaseController.cs = CaseRecord;
            ipsCustomerCaseController.LookupChange();  
            ipsCustomerCaseController.getEnvDetails();
            system.debug('CaseRecord -- ' + CaseRecord);
            system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.categorySelected=caseCat.id;
            ipsCustomerCaseController.subCategorySelected= subCategory.id;
            ipsCustomerCaseController.GECAnswer1='Yes';
            ipsCustomerCaseController.GECAnswer2='Yes';
            ipsCustomerCaseController.GECAnswer3='Yes';
            List<String> val= new List<String>();
            val.add('test');
            val.add('test2');
            ipsCustomerCaseController.showGECFields = true;
            ipsCustomerCaseController.cs = CaseRecord;
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c ='test';
            org.Core_Organization_Description__c ='test';
            insert org;
            System.assertEquals('test', org.Core_IPS_Support_Org_Name__c);
            Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            system.debug('edqRecordTypeId===='+edqRecordTypeId);
            //Parent Question Record
            Core_IPS_Question__c parQues = new Core_IPS_Question__c();       
            parQues.recordtypeid = edqRecordTypeId;
            parQues.Core_IPS_Question__c = 'Test Parent Question';
            parQues.Core_IPS_Datatype__c = 'Picklist';
            parQues.Core_IPS_Status__c = 'Active';
            parQues.Core_IPS_Product_Organization__c = Org.id;
            
            Core_IPS_Question__c childQues = new Core_IPS_Question__c();       
            childQues.recordtypeid = edqRecordTypeId;
            childQues.Core_IPS_Question__c = 'Test Child Question';
            childQues.Core_IPS_Datatype__c = 'Picklist';
            childQues.Core_IPS_Status__c = 'Active';
            childQues.Core_IPS_Product_Organization__c = Org.id;
            
            List<Core_IPS_EnvironmentDetailQuestion> lstchildquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
            Core_IPS_EnvironmentDetailQuestion childquestion = new Core_IPS_EnvironmentDetailQuestion();
            childquestion.isVisible=false;
            childquestion.type='Text';
            childquestion.questionId=childQues.id;
            childquestion.sPlaceHolder=null;
            childquestion.required=true;
            lstchildquestion.add(childquestion);
            
            List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
            Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
            question.isVisible=false;
            question.type='Text';
            question.questionId=parQues.id;
            question.sPlaceHolder=null;
            question.required=true;
            question.childQuestions=lstchildquestion;
            lstquestion.add(question);
            
            ipsCustomerCaseController.envDetails=lstquestion;
            ipsCustomerCaseController.saveCaseDetails();
            ipsCustomerCaseController.DisplayPriorityReason();
            ipsCustomerCaseController.selectedProject = null;
            ipsCustomerCaseController.showProjListBasedOnSelectedProd();
            ipsCustomerCaseController.productChanges();
            ipsCustomerCaseController.clearProject();
            ipsCustomerCaseController.getsubCategory_Options(caseCat.id);
        }
    }
    static testmethod void cancelAction(){   
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getHeaders().put('referer','test');
        ApexPages.currentPage().getParameters().put('retURL','test');
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.CancelAction();
        ipsCustomerCaseController.pageInit();
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ApexPages.currentPage().getHeaders().put('referer','ggid');
        ApexPages.currentPage().getParameters().put('retURL','test');
        PageReference pg = ipsCustomerCaseController1.CancelAction();
        system.assertEquals(true, pg.getRedirect());
        //ipsCustomerCaseController1.CancelAction();
    }
    static testmethod void validateCaseRelatedInformation1(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        CaseRecord.Core_Severity_Reason__c=null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            system.debug('CaseRecord -- ' + CaseRecord);
            system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.categorySelected='';
            ipsCustomerCaseController.DisplayPriorityReason=true;
            ipsCustomerCaseController.validateCaseRelatedInformation();
            ipsCustomerCaseController.subCategorySelected='';
            ipsCustomerCaseController.DisplayPriorityReason=true;
            ipsCustomerCaseController.validateCaseRelatedInformation();
            System.assertEquals('', ipsCustomerCaseController.subCategorySelected);
        }
    }
    static testmethod void validateCaseRelatedInformationSubCat(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        CaseRecord.Core_Severity_Reason__c=null;
        
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.subCategoryOptions=new List<SelectOption>{new SelectOption('', 'Select Category'),new SelectOption('', 'Select Category1')};
                ipsCustomerCaseController.subCategorySelected='';
            ipsCustomerCaseController.DisplayPriorityReason=true;
            ipsCustomerCaseController.validateCaseRelatedInformation();
            System.assertEquals('', ipsCustomerCaseController.subCategorySelected);
        }
    }
    static testmethod void validateCaseRelatedInformation2(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Product';
            ipsCustomerCaseController.cs = CaseRecord;
            system.debug('CaseRecord -- ' + CaseRecord);
            system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.categorySelected='sdas';
            ipsCustomerCaseController.subCategorySelected= '';
            ipsCustomerCaseController.validateCaseRelatedInformation();
            //code added as per US136245
            ipsCustomerCaseController.categoryOptions=new List<SelectOption>{new SelectOption('', 'Select Category'),new SelectOption('', 'Select Category1')};
                ipsCustomerCaseController.categorySelected=null;
            ipsCustomerCaseController.validateCaseRelatedInformation();
            
            ipsCustomerCaseController.subCategoryOptions=new List<SelectOption>{new SelectOption('', 'Select subCategory'),new SelectOption('', 'Select subCategory1')};
                ipsCustomerCaseController.subCategorySelected=null;
            ipsCustomerCaseController.validateCaseRelatedInformation();
            System.assertEquals(null, ipsCustomerCaseController.subCategorySelected);
        }
    }
    static testmethod void validateCaseRelatedInformation3(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        CaseRecord.Core_Severity__c='Critical';
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            CaseRecord.Subject = '';
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Product';
            ipsCustomerCaseController.cs = CaseRecord;
            system.debug('CaseRecord -- ' + CaseRecord);
            system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.categorySelected='sdas';
            ipsCustomerCaseController.subCategorySelected= 'sadasd';
            ipsCustomerCaseController.validateCaseRelatedInformation();
            ipsCustomerCaseController.DisplayPriorityReason();
            ipsCustomerCaseController.subCategorySelected= null;
            ipsCustomerCaseController.validateCaseRelatedInformation();
            //code added as per US136245
            ipsCustomerCaseController.categoryOptions=new List<SelectOption>{new SelectOption('', 'Select Category'),new SelectOption('', 'Select Category1')};
                ipsCustomerCaseController.categorySelected=null;
            ipsCustomerCaseController.validateCaseRelatedInformation();
            System.assertEquals('Product', ipsCustomerCaseController.objectSelected);
        }
    }
    static testmethod void validateCustomerCase4(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            CaseRecord.Subject = 'sd';
            CaseRecord.Core_Issue_Description__c = '';
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Product';
            ipsCustomerCaseController.cs = CaseRecord;
            system.debug('CaseRecord -- ' + CaseRecord);
            system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.categorySelected='sdas';
            ipsCustomerCaseController.subCategorySelected= 'sdsa';
            ipsCustomerCaseController.validateCaseRelatedInformation();
            System.assertEquals('sdsa', ipsCustomerCaseController.subCategorySelected); 
            //code added as per US136245
            CaseRecord.Subject = '';
            CaseRecord.Core_Severity__c='Low';
            CaseRecord.Core_CaseType__c='Test';
            ipsCustomerCaseController.validateCaseRelatedInformation();
        }
    }
    
    static testmethod void validateCustomerCaseSeverityReason(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            CaseRecord.Subject = 'sd';
            CaseRecord.Core_Severity_Reason__c='';
            System.assertEquals('sd', CaseRecord.Subject); 
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Product';
            ipsCustomerCaseController.cs = CaseRecord;
            system.debug('CaseRecord -- ' + CaseRecord);
            system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.categorySelected='sdas';
            ipsCustomerCaseController.subCategorySelected= 'sdsa';
            ipsCustomerCaseController.DisplayPriorityReason=true;
            ipsCustomerCaseController.validateCaseRelatedInformation();
        }
    }
    
    static testmethod void validateCaseRelatedInformation5(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            CaseRecord.Subject = 'sd';
            CaseRecord.Core_Issue_Description__c = 'dasd';
            CaseRecord.Core_Severity__c='';
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Product';
            ipsCustomerCaseController.cs = CaseRecord;
            system.debug('CaseRecord -- ' + CaseRecord);
            system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.categorySelected='sdas';
            ipsCustomerCaseController.subCategorySelected= 'sdsa';
            ipsCustomerCaseController.DisplayPriorityReason=true;
            ipsCustomerCaseController.validateCaseRelatedInformation();
            System.assertEquals('sdsa', ipsCustomerCaseController.subCategorySelected);
        }
    }
    static testmethod void validateCaseRelatedInformation6(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            CaseRecord.Subject = 'sd';
            CaseRecord.Core_Issue_Description__c = 'dasd';
            CaseRecord.Core_Severity__c='Medium';
            CaseRecord.Core_CaseType__c ='';
            CaseRecord.Core_Severity_Reason__c='';
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Product';
            ipsCustomerCaseController.cs = CaseRecord;
            system.debug('CaseRecord -- ' + CaseRecord);
            system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.categorySelected='sdas';
            ipsCustomerCaseController.subCategorySelected= 'sdsa';
            ipsCustomerCaseController.DisplayPriorityReason=true;
            ipsCustomerCaseController.validateCaseRelatedInformation();
            System.assertEquals('sdsa', ipsCustomerCaseController.subCategorySelected);
        }
    }
    /**static testmethod void addGECRecordsTest(){
getRecords(0);
CaseRecord.Core_IPS_Supported_Product__c= null;
System.RunAs(ListOfCustomerSfUsers.get(0)){
// Setting the Visualforce Page
PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
Test.setCurrentPage(CustomerCaseCreationPage);
// Assigning parameters in the URL
ApexPages.currentPage().getParameters().put('mode','asset');
ApexPages.currentPage().getParameters().put('sbs','ccs');
RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
ApexPages.currentPage().getParameters().put('rType',RT.Id);
ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
// instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
ipsCustomerCaseController.objectSelected ='Product';
ipsCustomerCaseController.cs = CaseRecord;
ipsCustomerCaseController.showGECFields = true;
ipsCustomerCaseController.GECAnswer1 = 'yes';
ipsCustomerCaseController.GECAnswer2 = 'yes';
//ipsCustomerCaseController.addGECRecords();
}
}**/
    
    static testmethod void productChangesTest(){
        getRecords(0);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('firstparameter',ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('secparameter', 'asdads');
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Product';
            System.assertEquals('Product', ipsCustomerCaseController.objectSelected);
            ipsCustomerCaseController.cs = CaseRecord;
            Apexpages.currentPage().getParameters().put('secparameter','  ');
            ipsCustomerCaseController.productChanges();
            ipsCustomerCaseController.Mode = 'edit';
            ipsCustomerCaseController.showGECFields = true;
            ipsCustomerCaseController.PageInit();
        }
    }
    
    static testMethod void validateCustomerCaseTest10(){
        getRecords(0);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('firstparameter',ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('secparameter', 'asdads');
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.projectList =  new List<SelectOption>(); 
            ipsCustomerCaseController.projectList.add(new SelectOption('ABC','ABC'));
            ipsCustomerCaseController.projectList.add(new SelectOption('ABC1','ABC1'));
            ipsCustomerCaseController.selectedProject ='NA';
            ipsCustomerCaseController.cs = CaseRecord;
            ipsCustomerCaseController.validateCustomerCase();
            ipsCustomerCaseController.Mode = 'edit';
            System.assertEquals('edit', ipsCustomerCaseController.Mode);
            ipsCustomerCaseController.isclosed = true;
            ipsCustomerCaseController.PageInit();
        }
    }
    
    static testMethod void validateCustomerCaseTest12(){
        getRecords(1);
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','new');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('firstparameter',ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('secparameter', 'asdads');
            //instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.AnswerOptions =  new List<SelectOption>(); 
            ipsCustomerCaseController.renderErrorFlag =true;
            ipsCustomerCaseController.selectedContactId = '>>>>>>>>>>>>>>>>>';
            ipsCustomerCaseController.displaySelfAssigned = true;
            ipsCustomerCaseController.hasProject = true;
            System.assertEquals(true, ipsCustomerCaseController.hasProject);
            ipsCustomerCaseController.cs = CaseRecord;
            ipsCustomerCaseController.BindEvent();        
        }
    }
    public static testmethod void MissingCodeChangesCoverageTest(){
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
        insert cipspro;
        System.assertNotEquals(null, cipspro);
        Case  cse = new Case ();
        cse.core_ips_project_case__c=cipspro.id;
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(cse));
        ipsCustomerCaseController.cs = cse;
        ipsCustomerCaseController.isAgent = false;
    }
    static testMethod void validateCustomerCaseTest13(){
        getRecords(0); 
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('firstparameter',ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('secparameter', 'asdads');
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.projectList =  new List<SelectOption>(); 
            ipsCustomerCaseController.projectList.add(new SelectOption('ABC','ABC'));
            ipsCustomerCaseController.projectList.add(new SelectOption('ABC1','ABC1'));
            ipsCustomerCaseController.selectedProject ='NA';
            ipsCustomerCaseController.selectedProductId ='123ae' ; 
            ipsCustomerCaseController.cs = CaseRecord;
            ipsCustomerCaseController.validateCustomerCase();
            System.assertEquals('123ae', ipsCustomerCaseController.selectedProductId );
            System.assertEquals('NA', ipsCustomerCaseController.selectedProject );
            //code added as per US136245
            ipsCustomerCaseController.selectedProject = null;
            ipsCustomerCaseController.selectedProductId = '';
            ipsCustomerCaseController.validateCustomerCase();
            
            
        }
    }
    //Added by Geetha as per User story US78568
    static testmethod void showPopupOnContactLink(){
        Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
        insert cipspro;
        System.assertNotEquals(null, cipspro);
        Case  cse = new Case ();
        cse.core_ips_project_case__c=cipspro.id;
        User u = [select id from user where usertype='Standard' AND ISActive=true AND UserRole.Name != NULL limit 1 ];
        System.RunAs(u){
            Account accountRecord = new Account(
                Name = 'Dell Products',
                Core_Account_Type__c = 'Distributor',
                Core_Sales_Segment__c = 'Compute',
                Industry = 'Banking',
                BillingCity = 'Delhi',
                BillingCountry = 'USA',
                billingState = 'AK',
                billingStreet = 'Bratislava 1',
                Core_IPS_Active__c = true
            );
            insert accountRecord;
            System.AssertEquals('Dell Products',accountRecord.Name);
            
            Contact contactRecord = new Contact(
                FirstName = 'Ding Dong', 
                Lastname = 'Dell',
                Email = 'Contact1Dell@gmail.com',
                Accountid = accountRecord.id,
                Core_IPS_Intel_Support_Owner__c=u.id,
                Core_IPS_Active__c = true
            );
            insert contactRecord;
            System.assertNotEquals(null, contactRecord);
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(cse));
            ipsCustomerCaseController.closePopup();
            ipsCustomerCaseController.showPopup();
            //Ended by Geetha as per User story US78568
        }
    }
    static testmethod void searchbeforesubmit(){
        Case cse = new case();
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
        System.RunAs(SysAdminUsr[0]){
            insert ListOfCustomerSfUsers;
        }
        List<Core_IPS_EV_Filters__c> lstEnv = new List<Core_IPS_EV_Filters__c>();
        Core_IPS_EV_Filters__c evntFields = new Core_IPS_EV_Filters__c(); 
        evntFields.Name='Test';
        lstEnv.add(evntFields);
        // Create Account Record
        List<Account> ListOfAccounts = new List<Account> ();
        Account AccountRec1 = TestUtilities.getAccount();
        AccountRec1.Core_IPS_Active__c = true;
        AccountRec1.ownerid = ListOfCustomerSfUsers.get(0).id;
        AccountRec1.Core_Military_Aerospace_and_Government__c = true;
        ListOfAccounts.add(AccountRec1);
        insert ListOfAccounts;
        System.assertEquals(true, AccountRec1.Core_IPS_Active__c);
        // Create Design Project Record
        ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        insert ListOfIpsProjects;
        // Create Support Org Record
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert ListOfSupportOrg;
        // Create Product2 Record
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        insert ListOfProducts;
        // Create Supported product Record
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        insert ListOfSupportedProduct;
        // Create Asset
        ListOfAssets = TestUtilities.getAssetList(1);
        ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfAssets.get(0).accountId = ListOfAccounts.get(0).Id;
        ListOfAssets.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).Id;
        ListOfAssets.get(0).product2Id = ListOfProducts.get(0).Id;
        ListOfAssets.get(0).core_supported_product__c = ListOfSupportedProduct[0].id;
        insert ListOfAssets;
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(cse));
        ApexPages.currentPage().getParameters().put('retURL','test');
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;
        ipsCustomerCaseController.selectedProjId = 'NA';
        ipsCustomerCaseController.NextCaseDetails();
        ipsCustomerCaseController.validateSearchRelatedInformation();
        Product2 pro=new Product2(name='test');
        insert pro;
        
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(cse));
        ipsCustomerCaseController1.selectedSAProduct=pro.id;
        ApexPages.currentPage().getParameters().put('retURL','test');
        ipsCustomerCaseController1.selectedProjId = 'NA';
        ipsCustomerCaseController1.NextCaseDetails();
        ipsCustomerCaseController1.CaseCreation();
        
        Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
        insert cipspro; 
        
        ipsCustomerCaseController1.subject = 'test';
        ipsCustomerCaseController1.selectedProjId = cipspro.id;
        ipsCustomerCaseController1.SearchBeforeSubmit();
        
        ipsCustomerCaseController1.subCategoryOptions=new List<SelectOption>{new SelectOption('', 'Select Category'),new SelectOption('', 'Select Category1')};
            ipsCustomerCaseController1.subCategorySelected = null;
        ipsCustomerCaseController1.validateCaseRelatedInformation();
        ipsCustomerCaseController1.SearchBeforeSubmit();
        
        ipsCustomerCaseController1.platformOptions=new List<SelectOption>{new SelectOption('', 'Select Category'),new SelectOption('', 'Select Category1')};
            ipsCustomerCaseController1.csid = 'test';
        ipsCustomerCaseController1.platformSelected = 'test'; 
        ipsCustomerCaseController1.SearchBeforeSubmit();
        System.AssertEquals('test',ipsCustomerCaseController1.csid);
        ipsCustomerCaseController1.validateCaseRelatedInformation();
        
        //new code
        ipsCustomerCaseController1.subject = 'test';
        ipsCustomerCaseController1.selectedProjId = cipspro.id;
        ipsCustomerCaseController1.subCategoryOptions=new List<SelectOption>{new SelectOption('', 'Select subCategory'),new SelectOption('', 'Select subCategory1')};
            ipsCustomerCaseController1.subCategorySelected = null;
        ipsCustomerCaseController1.SearchBeforeSubmit();
        ipsCustomerCaseController1.validateCaseRelatedInformation();
        ipsCustomerCaseController1.categoryOptions=new List<SelectOption>{new SelectOption('', 'Select Category'),new SelectOption('', 'Select Category1')};
            ipsCustomerCaseController1.categorySelected=null;
        ipsCustomerCaseController1.SearchBeforeSubmit();
        
        ipsCustomerCaseController1.categoryOptions=new List<SelectOption>{new SelectOption('', 'Select Category'),new SelectOption('', 'Select Category1')};
            ipsCustomerCaseController1.categorySelected=null;
        ipsCustomerCaseController1.SearchBeforeSubmit();
        
        ipsCustomerCaseController1.platformOptions=new List<SelectOption>{new SelectOption('', 'Select Platform'),new SelectOption('', 'Select Platform1')};
            ipsCustomerCaseController1.csid='cse.id';
        ipsCustomerCaseController1.platformSelected =null; 
        ipsCustomerCaseController1.validateCaseRelatedInformation();
    }
    static testmethod void InsertCaseRecord123(){
        getRecords(1);
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        apexpages.currentpage().getParameters().put('subject','test');
        apexpages.currentpage().getParameters().put('sbs','pss');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController2 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController2.showGECFields = True;
        ipsCustomerCaseController2.objectSelected ='Contact';
        system.debug(ipsCustomerCaseController2.displayPlatform);
        system.debug(ipsCustomerCaseController2.platformOptions);
        ipsCustomerCaseController2.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsCustomerCaseController2.LookupChange(); 
        ipsCustomerCaseController2.getCountries();
        ipsCustomerCaseController2.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController2.selectedProduct = '';
        Pagereference Pg = ipsCustomerCaseController2.clearProduct();
        ipsCustomerCaseController2.selectedProject = null;//Added By Manoj
        Pagereference Pg1 = ipsCustomerCaseController2.clearProduct();//Added By Manoj
        ipsCustomerCaseController2.clearEnvDetails();
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        
        Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
        system.debug('edqRecordTypeId===='+edqRecordTypeId);
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
        Core_IPS_Question__c parQues = new Core_IPS_Question__c();       
        parQues.recordtypeid = edqRecordTypeId;
        parQues.Core_IPS_Question__c = 'Test Parent Question';
        parQues.Core_IPS_Datatype__c = 'Picklist';
        parQues.Core_IPS_Status__c = 'Active';
        parQues.Core_IPS_Product_Organization__c = Org.id;
        
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();  
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        
        Core_IPS_Question__c parQues2 = new Core_IPS_Question__c();
        parQues2.Core_IPS_Question__c = 'Test Parent Question';
        parQues2.Core_IPS_Datatype__c = 'Multiselect Picklist';
        parQues2.Core_IPS_Status__c = 'Active';
        parQues2.Core_IPS_Product_Organization__c = Org.id;
        
        Core_IPS_Question__c parQues3 = new Core_IPS_Question__c(); 
        parQues3.Core_IPS_Question__c = 'Test Parent Question';
        parQues3.Core_IPS_Datatype__c = 'Text Area';
        parQues3.Core_IPS_Status__c = 'Active';
        parQues3.Core_IPS_Product_Organization__c = Org.id;
        
        lstparQues.add(parQues);
        lstparQues.add(parQues1);
        lstparQues.add(parQues2);
        lstparQues.add(parQues3);
        insert lstparQues;
        
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<8;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Product_Organization__c = org.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues.id;
            childQuesList.add(childQuestion);
        }
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues.id;
        insert parentAns;
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        
        Case cs = new Case();
        cs.assetId=asset.id;
        insert cs;
        
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = parQues.Id;
        envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
        envResponse.Core_IPS_Case__c = cs.Id;
        lstEnvResponse.add(envResponse);
        insert lstEnvResponse;
        
        
        List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
        Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
        question.isVisible=false;
        question.type='Text';
        question.questionId=parQues.id;
        question.sPlaceHolder=null;
        question.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
        question4.type='Text';
        question4.questionId=parQues.id;
        question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
        question1.type='Text Area';
        question1.questionId=parQues.id;
        question1.tPlaceHolder='';
        question4.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
        question5.type='Text Area';
        question5.questionId=parQues.id;
        question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
        question2.type='Picklist';
        question2.questionId=parQues.id;
        question2.sPlaceHolder=null;
        
        Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
        question3.type='Multiselect Picklist';
        question3.questionId=parQues.id;
        question3.sPlaceHolder=null;
        question3.selectedMValue=new List<String>{parentAns.Id};
            
            lstquestion.add(question);
        lstquestion.add(question1);
        lstquestion.add(question2);
        lstquestion.add(question3);
        lstquestion.add(question4);
        lstquestion.add(question5);
        
        Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
        label1.name= 'Core_IPS_Datatype_Text';
        label1.value__c= 'Text';
        insert label1;
        
        Core_IPS_Labels__c label2= new Core_IPS_Labels__c();
        label2.name= 'Core_IPS_Datatype_TextArea';
        label2.value__c= 'Text Area';
        insert label2;
        Core_IPS_Labels__c label3= new Core_IPS_Labels__c();
        label3.name= 'Core_IPS_Picklist';
        label3.value__c= 'Picklist';
        insert label3;
        Core_IPS_Labels__c label4= new Core_IPS_Labels__c();
        label4.name= 'Core_IPS_Multi_Select';
        label4.value__c= 'Multiselect Picklist';
        insert label4;
        
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(2);
        for(Core_IPS_Product_Issue_Category__c ProdIssuCat : ListOfCoreProdIssCategory_CaseCat){
            ProdIssuCat.Core_type__c = 'Case Category';
            ProdIssuCat.Core_Issue_Category_Name__c = ListOfCoreMasterIssueCategory_CaseCat.get(0).id;
            ProdIssuCat.Core_supported_product__c = ListOfSupportedProduct[0].id;
            ProdIssuCat.Core_Issue_Sub_Category_Name__c = ListOfCoreMasterIssueCategory_CaseSubCat.get(0).id; 
        }
        insert ListOfCoreProdIssCategory_CaseCat;
        
        Core_IPS_Product_Issue_Category__c  subCategory = new Core_IPS_Product_Issue_Category__c();
        subCategory.Core_Status__c = 'Active';
        subCategory.Core_Type__c = 'Case Subcategory';
        subCategory.Core_Product_Issue_Category__c = ListOfCoreProdIssCategory_CaseCat.get(0).id;
        insert subCategory;
        
        Core_IPS_Assigned_Environment_Variables__c filteredEnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        filteredEnvDetails.Core_IPS_Question__c =parQues.id;
        filteredEnvDetails.Core_Required__c=true;
        filteredEnvDetails.Core_Status__c = 'Active';
        filteredEnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert filteredEnvDetails;
        System.AssertEquals('Active',filteredEnvDetails.Core_Status__c);
        
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        //Modified By Manoj
        for(integer i=0;i<8;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = CIPO.Id;
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
        
        test.startTest();
        ipsCustomerCaseController2.constructResponse(question);
        ipsCustomerCaseController2.constructResponse(question2);
        ipsCustomerCaseController2.constructResponse(question5);
        ipsCustomerCaseController2.constructResponse(question3);
        question3.selectedMValue=new List<String>{''};
            ipsCustomerCaseController2.constructResponse(question3);
        ipsCustomerCaseController2.constructResponse(question1);
        ipsCustomerCaseController2.constructResponse(question4);
        
        ipsCustomerCaseController2.setCurrentEnvironmentDetails(lstquestion,cs.id);
        ipsCustomerCaseController2.cs = CaseRecord;//Added By Manoj
        
        ipsCustomerCaseController2.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController2.subCategorySelected = null;//Added By Manoj
        ipsCustomerCaseController2.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController2.subCategorySelected = subCategory.Id;//Added By Manoj
        
        ipsCustomerCaseController2.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController2.getEnvironmentOptions();
        ipsCustomerCaseController2.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsCustomerCaseController2.envDetails+'----SubEnv Details---'+ipsCustomerCaseController2.subCatenvDetList);
        system.debug(ipsCustomerCaseController2.GECAnswer1);
        system.debug(ipsCustomerCaseController2.GECAnswer2);
        /********Added By Manoj*********/ 
        ipsCustomerCaseController2.envDetails=lstquestion;
        /********Ended By Manoj*********/
        List<Core_IPS_Assigned_Environment_Variables__c> lstEDO = Core_IPS_Questions_Utility.getEnvDetailQuestions(ListOfSupportedProduct[0].Id, null, true);
        
        ipsCustomerCaseController2.validateFilteredEnvironmentDetails();//Added By Manoj
        List<SelectOption> LstSelectOption = ipsCustomerCaseController2.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController2.getEnvironmentDets();
        
        Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
        insert cipspro; 
        
        ipsCustomerCaseController2.subject = 'test';
        ipsCustomerCaseController2.selectedProject= cipspro.id;
        ipsCustomerCaseController2.SearchBeforeSubmit();
        test.stopTest();
    }
    static testmethod void InsertCaseRecordNegativemodesslc(){
        getRecords(1);
        List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
        ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts1;
        Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO1.Core_Organization_Description__c='This is from portal side';
        insert CIPO1;
        System.AssertEquals('Trident Solutions',CIPO1.Core_IPS_Support_Org_Name__c);
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
        ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
        ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource.name='Supported_Product';
        IssueSource.Core_IPS_Default_Data__c='product';
        IssueSource.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource1=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource1.name='Asset';
        IssueSource1.Core_IPS_Default_Data__c='product';
        IssueSource1.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource3=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource3.name='Case Description';
        IssueSource3.Core_IPS_Default_Data__c='product';
        IssueSource3.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource3;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource2=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource2.name='Project';
        IssueSource2.Core_IPS_Default_Data__c='product';
        IssueSource2.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource2;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource4=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource4.name='Case Type';
        IssueSource4.Core_IPS_Default_Data__c='product';
        IssueSource4.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource4;      
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource5=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource5.name='Issue Source';
        IssueSource5.Core_IPS_Default_Data__c='product';
        IssueSource5.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource5;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource7=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource7.name='Case Category';
        IssueSource7.Core_IPS_Default_Data__c='product';
        IssueSource7.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource7;       
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource6=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource6.name='Case Subcategory';
        IssueSource6.Core_IPS_Default_Data__c='product';
        IssueSource6.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource6;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource8=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource8.name='Case Subcategory Detail';
        IssueSource8.Core_IPS_Default_Data__c='product';
        IssueSource8.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource8;
        
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        
        Core_IPS_Labels__c label2= new Core_IPS_Labels__c();
        label2.name= 'Core_IPS_Datatype_Text';
        label2.value__c= 'Multiselect Picklist';
        insert label2;
        Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
        label1.name= 'Core_IPS_Datatype_Text';
        label1.value__c= 'Text';
        insert label1;
        
        test.startTest();
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','sslc');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.showGECFields = True;
        ipsCustomerCaseController.objectSelected ='Contact';
        ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getCountries();
        ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController.selectedProduct = '';
        ipsCustomerCaseController.clearAlldetails();
        Pagereference Pg = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.selectedProject = null;//Added By Manoj
        Pagereference Pg1 = ipsCustomerCaseController.clearProduct();//Added By Manoj
        ipsCustomerCaseController.clearEnvDetails();
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>();
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c(); 
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Picklist';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        lstparQues.add(parQues1);
        insert lstparQues;
        
        Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<8;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            childQuestion.recordTypeId = edqRecordTypeId;
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Product_Organization__c = org.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues1.id;
            childQuesList.add(childQuestion);
        }
        insert childQuesList;
        
        Core_IPS_Answer__c childAns =  new Core_IPS_Answer__c();
        childAns.Core_IPS_Answer__c = 'Test Answer';
        childAns.Core_IPS_Status__c = 'Active';
        childAns.Core_IPS_Question__c =childQuesList[0].Id;
        insert childAns;
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues1.id;
        insert parentAns;
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        
        Case cs = new Case();
        cs.assetId=asset.id;
        insert cs;
        
        //Ev filter
        List<Core_IPS_EV_Filters__c> lstEnv = new List<Core_IPS_EV_Filters__c>();
        Core_IPS_EV_Filters__c evntFields = new Core_IPS_EV_Filters__c(); 
        evntFields.Name='Test Parent Question';
        lstEnv.add(evntFields);
        Core_IPS_EV_Filters__c evntFields2 = new Core_IPS_EV_Filters__c(); 
        evntFields2.Name='Altera Software';
        lstEnv.add(evntFields2);
        insert lstEnv;
        
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = parQues1.Id;
        envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
        envResponse.Core_IPS_Case__c = cs.Id;
        //Core_IPS_Answer__c
        lstEnvResponse.add(envResponse);
        
        Core_IPS_Response__c envResponse1 = new Core_IPS_Response__c();
        envResponse1.Core_IPS_Question_Master__c = childQuesList[0].Id;
        envResponse1.Core_IPS_Answer_Master__c =childAns.Id;
        envResponse1.Core_IPS_Case__c = cs.Id;
        lstEnvResponse.add(envResponse1); 
        insert lstEnvResponse;
        
        List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
        Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
        question.isVisible=false;
        question.type='picklist';
        question.questionId=parQues1.id;
        question.sPlaceHolder=null;
        question.required=true;
        question.selectedValue=parentAns.id;
        
        Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
        question4.type='Multiselect Picklist';
        question4.questionId=parQues1.id;
        question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
        question1.type='Text Area';
        question1.questionId=parQues1.id;
        question1.tPlaceHolder='';
        question4.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
        question5.type='Text Area';
        question5.questionId=parQues1.id;
        question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
        question2.type='Picklist';
        question2.questionId=parQues1.id;
        question2.childQuestions=new List<Core_IPS_EnvironmentDetailQuestion>{question};
            question2.sPlaceHolder=null;
        
        Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
        question3.type='Multiselect Picklist';
        question3.questionId=parQues1.id;
        question3.sPlaceHolder=null;
        lstquestion.add(question);
        lstquestion.add(question1);
        lstquestion.add(question2);
        lstquestion.add(question3);
        lstquestion.add(question4);
        lstquestion.add(question5);
        ipsCustomerCaseController.filteredEnvDetails = lstquestion;
        ipsCustomerCaseController.validateFilteredEnvironmentDetails();
        
        Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
        insert subCategory;
        
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        EnvDetails.Core_IPS_Question__c =parQues1.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        
        
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        //Modified By Manoj
        for(integer i=0;i<8;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = CIPO.Id;
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
        
        ipsCustomerCaseController.constructResponse(question);
        ipsCustomerCaseController.constructResponse(question2);
        ipsCustomerCaseController.constructResponse(question5);
        ipsCustomerCaseController.constructResponse(question3);
        ipsCustomerCaseController.constructResponse(question1);
        ipsCustomerCaseController.constructResponse(question4);
        ipsCustomerCaseController.setCurrentEnvironmentDetails(lstquestion,cs.id);
        ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
        ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentOptions();
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        ipsCustomerCaseController.GECAnswer1='Yes';
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        /********Added By Manoj*********/ 
        ipsCustomerCaseController.envDetails=lstquestion;
        ipsCustomerCaseController.saveCaseDetails();//Added By Manoj
        system.debug(ipsCustomerCaseController.GECAnswer1);
        system.debug(ipsCustomerCaseController.GECAnswer2);
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        
        Core_IPS_Question__c parQues3 = new Core_IPS_Question__c();  
        parQues3.Core_IPS_Question__c = 'Test Parent Question';
        parQues3.Core_IPS_Datatype__c = 'Text Area';
        parQues3.Core_IPS_Status__c = 'Active';
        parQues3.Core_IPS_Product_Organization__c = Org.id;
        insert parQues3;
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns1 =  new Core_IPS_Answer__c();
        parentAns1.Core_IPS_Answer__c = 'Test Answer';
        parentAns1.Core_IPS_Status__c = 'Active';
        parentAns1.Core_IPS_Question__c = parQues3.id; 
        insert parentAns1;
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(cs)); 
        ipsCustomerCaseController1.cs=cs;
        ipsCustomerCaseController1.filteredEnvDetails = lstquestion; 
        ipsCustomerCaseController1.constructResponse(question);
        test.stopTest();
    }
    static testmethod void InsertCaseRecordNegativemodesslc1(){
        getRecords(1);
        List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
        ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts1;
        Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO1.Core_Organization_Description__c='This is from portal side';
        insert CIPO1;
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
        ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
        ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource.name='Supported_Product';
        IssueSource.Core_IPS_Default_Data__c='product';
        IssueSource.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource1=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource1.name='Asset';
        IssueSource1.Core_IPS_Default_Data__c='product';
        IssueSource1.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource3=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource3.name='Case Description';
        IssueSource3.Core_IPS_Default_Data__c='product';
        IssueSource3.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource3;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource2=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource2.name='Project';
        IssueSource2.Core_IPS_Default_Data__c='product';
        IssueSource2.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource2;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource4=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource4.name='Case Type';
        IssueSource4.Core_IPS_Default_Data__c='product';
        IssueSource4.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource4;      
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource5=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource5.name='Issue Source';
        IssueSource5.Core_IPS_Default_Data__c='product';
        IssueSource5.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource5;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource7=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource7.name='Case Category';
        IssueSource7.Core_IPS_Default_Data__c='product';
        IssueSource7.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource7;       
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource6=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource6.name='Case Subcategory';
        IssueSource6.Core_IPS_Default_Data__c='product';
        IssueSource6.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource6;
        Core_IPS_SSLCCase_DefaultData__c IssueSource8=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource8.name='Case Subcategory Detail';
        IssueSource8.Core_IPS_Default_Data__c='product';
        IssueSource8.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource8;
        test.startTest();
        
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','sslc');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.showGECFields = True;
        ipsCustomerCaseController.objectSelected ='Contact';
        
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        System.AssertEquals('Trident Solutions',CIPO.Core_IPS_Support_Org_Name__c);
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        
        
        ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getCountries();
        ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController.selectedProduct = '';
        Pagereference Pg = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.selectedProject = null;//Added By Manoj
        Pagereference Pg1 = ipsCustomerCaseController.clearProduct();//Added By Manoj
        ipsCustomerCaseController.clearEnvDetails();
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c(); 
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        lstparQues.add(parQues1);
        insert lstparQues;
        
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<8;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Product_Organization__c = org.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues1.id;
            childQuesList.add(childQuestion);
        }
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues1.id;
        insert parentAns;
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        
        Case cs = new Case();
        cs.assetId=asset.id;
        insert cs;
        
        
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = parQues1.Id;
        envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
        envResponse.Core_IPS_Case__c = cs.Id;
        lstEnvResponse.add(envResponse);
        insert lstEnvResponse;
        
        List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
        Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
        question.isVisible=false;
        question.type='Text';
        question.questionId=parQues1.id;
        question.sPlaceHolder=null;
        question.required=true;
        question.selectedValue='test';
        
        Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
        question4.type='Multiselect Picklist';
        question4.questionId=parQues1.id;
        question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        
        
        Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
        question1.type='Text Area';
        question1.questionId=parQues1.id;
        question1.tPlaceHolder='';
        question4.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
        question5.type='Text Area';
        question5.questionId=parQues1.id;
        question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
        question2.type='Picklist';
        question2.questionId=parQues1.id;
        question2.sPlaceHolder=null;
        
        Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
        question3.required=True;
        question3.type='Multiselect Picklist';
        question3.questionId=parQues1.id;
        question3.sPlaceHolder=null;
        
        
        lstquestion.add(question);
        lstquestion.add(question1);
        lstquestion.add(question2);
        lstquestion.add(question3);
        lstquestion.add(question4);
        lstquestion.add(question5);
        
        Core_IPS_Labels__c label2= new Core_IPS_Labels__c();
        label2.name= 'Core_IPS_Datatype_Text';
        label2.value__c= 'Multiselect Picklist';
        insert label2;
        
        ipsCustomerCaseController.filteredEnvDetails = lstquestion;
        ipsCustomerCaseController.validateFilteredEnvironmentDetails();
        
        Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
        insert subCategory;
        
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        EnvDetails.Core_IPS_Question__c =parQues1.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        //Modified By Manoj
        for(integer i=0;i<8;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = CIPO.Id;
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
        
        ipsCustomerCaseController.constructResponse(question);
        ipsCustomerCaseController.constructResponse(question2);
        ipsCustomerCaseController.constructResponse(question5);
        ipsCustomerCaseController.constructResponse(question3);
        ipsCustomerCaseController.constructResponse(question1);
        ipsCustomerCaseController.constructResponse(question4);
        
        ipsCustomerCaseController.setCurrentEnvironmentDetails(lstquestion,cs.id);
        ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
        ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentOptions();
        ipsCustomerCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        ipsCustomerCaseController.GECAnswer1='Yes'; 
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        /********Added By Manoj*********/ 
        ipsCustomerCaseController.envDetails=lstquestion;
        //ipsCustomerCaseController.saveCaseDetails();//Added By Manoj
        system.debug(ipsCustomerCaseController.GECAnswer1);
        system.debug(ipsCustomerCaseController.GECAnswer2);
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        
        Core_IPS_Question__c parQues3 = new Core_IPS_Question__c();
        parQues3.Core_IPS_Question__c = 'Test Parent Question';
        parQues3.Core_IPS_Datatype__c = 'Text Area';
        parQues3.Core_IPS_Status__c = 'Active';
        parQues3.Core_IPS_Product_Organization__c = Org.id;
        insert parQues3;
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns1 =  new Core_IPS_Answer__c();
        parentAns1.Core_IPS_Answer__c = 'Test Answer';
        parentAns1.Core_IPS_Status__c = 'Active';
        parentAns1.Core_IPS_Question__c = parQues3.id;
        insert parentAns1;
        
        Core_IPS_Response__c envResponse1 = new Core_IPS_Response__c();
        envResponse1.Core_IPS_Question_Master__c = parQues3.Id;
        envResponse1.Core_IPS_Answer_Master__c =parentAns1.Id;
        envResponse1.Core_IPS_Case__c = cs.Id;
        insert envResponse1;
        
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord)); 
        test.stopTest();
    }
    static testmethod void InsertCaseRecordNegativemodesslc2(){
        getRecords(1);
        List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
        ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts1;
        Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO1.Core_Organization_Description__c='This is from portal side';
        insert CIPO1;
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
        ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
        ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource.name='Supported_Product';
        IssueSource.Core_IPS_Default_Data__c='product';
        IssueSource.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource1=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource1.name='Asset';
        IssueSource1.Core_IPS_Default_Data__c='product';
        IssueSource1.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource3=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource3.name='Case Description';
        IssueSource3.Core_IPS_Default_Data__c='product';
        IssueSource3.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource3;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource2=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource2.name='Project';
        IssueSource2.Core_IPS_Default_Data__c='product';
        IssueSource2.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource2;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource4=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource4.name='Case Type';
        IssueSource4.Core_IPS_Default_Data__c='product';
        IssueSource4.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource4;      
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource5=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource5.name='Issue Source';
        IssueSource5.Core_IPS_Default_Data__c='product';
        IssueSource5.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource5;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource7=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource7.name='Case Category';
        IssueSource7.Core_IPS_Default_Data__c='product';
        IssueSource7.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource7;       
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource6=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource6.name='Case Subcategory';
        IssueSource6.Core_IPS_Default_Data__c='product';
        IssueSource6.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource6;
        Core_IPS_SSLCCase_DefaultData__c IssueSource8=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource8.name='Case Subcategory Detail';
        IssueSource8.Core_IPS_Default_Data__c='product';
        IssueSource8.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource8;
        test.startTest();
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','sslc');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.showGECFields = True;
        ipsCustomerCaseController.objectSelected ='Contact';
        
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        System.AssertEquals('Trident Solutions',CIPO.Core_IPS_Support_Org_Name__c);
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        
        
        ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getCountries();
        ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController.selectedProduct = '';
        Pagereference Pg = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.selectedProject = null;//Added By Manoj
        Pagereference Pg1 = ipsCustomerCaseController.clearProduct();//Added By Manoj
        ipsCustomerCaseController.clearEnvDetails();
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
        
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        lstparQues.add(parQues1);
        insert lstparQues;
        
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<8;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Product_Organization__c = org.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues1.id;
            childQuesList.add(childQuestion);
        }
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues1.id;
        insert parentAns;
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        
        Case cs = new Case();
        cs.assetId=asset.id;
        insert cs;
        
        
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = parQues1.Id;
        envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
        envResponse.Core_IPS_Case__c = cs.Id;
        //Core_IPS_Answer__c
        lstEnvResponse.add(envResponse);
        insert lstEnvResponse;
        
        List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
        Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
        question.isVisible=false;
        question.type='Text';
        question.questionId=parQues1.id;
        question.sPlaceHolder=null;
        question.required=true;
        question.selectedValue='test';
        
        Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
        question4.type='Multiselect Picklist';
        question4.questionId=parQues1.id;
        question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
        question1.type='Text Area';
        question1.questionId=parQues1.id;
        question1.tPlaceHolder='';
        question4.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
        question5.type='Text Area';
        question5.questionId=parQues1.id;
        question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
        question2.type='Picklist';
        question2.questionId=parQues1.id;
        question2.sPlaceHolder=null;
        
        Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
        question3.type='Multiselect Picklist';
        question3.questionId=parQues1.id;
        question3.sPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        lstquestion.add(question);
        lstquestion.add(question1);
        lstquestion.add(question2);
        lstquestion.add(question3);
        lstquestion.add(question4);
        lstquestion.add(question5);
        
        Core_IPS_Labels__c label2= new Core_IPS_Labels__c();
        label2.name= 'Core_IPS_Datatype_Text';
        label2.value__c= 'Multiselect Picklist';
        insert label2;
        
        ipsCustomerCaseController.filteredEnvDetails = lstquestion;
        ipsCustomerCaseController.validateFilteredEnvironmentDetails();
        
        Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
        insert subCategory;
        
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        EnvDetails.Core_IPS_Question__c =parQues1.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        //Modified By Manoj
        for(integer i=0;i<8;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = CIPO.Id;
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
        
        ipsCustomerCaseController.constructResponse(question);
        ipsCustomerCaseController.constructResponse(question2);
        ipsCustomerCaseController.constructResponse(question5);
        ipsCustomerCaseController.constructResponse(question3);
        ipsCustomerCaseController.constructResponse(question1);
        ipsCustomerCaseController.constructResponse(question4);
        ipsCustomerCaseController.setCurrentEnvironmentDetails(lstquestion,cs.id);
        ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
        ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentOptions();
        ipsCustomerCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        ipsCustomerCaseController.GECAnswer1='Yes'; 
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        /********Added By Manoj*********/ 
        ipsCustomerCaseController.envDetails=lstquestion;
        //ipsCustomerCaseController.saveCaseDetails();//Added By Manoj
        system.debug(ipsCustomerCaseController.GECAnswer1);
        system.debug(ipsCustomerCaseController.GECAnswer2);
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        Core_IPS_Question__c parQues3 = new Core_IPS_Question__c(); 
        parQues3.Core_IPS_Question__c = 'Test Parent Question';
        parQues3.Core_IPS_Datatype__c = 'Text Area';
        parQues3.Core_IPS_Status__c = 'Active';
        parQues3.Core_IPS_Product_Organization__c = Org.id;
        insert parQues3;
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns1 =  new Core_IPS_Answer__c();
        parentAns1.Core_IPS_Answer__c = 'Test Answer';
        parentAns1.Core_IPS_Status__c = 'Active';
        parentAns1.Core_IPS_Question__c = parQues3.id;
        insert parentAns1;
        
        Core_IPS_Response__c envResponse1 = new Core_IPS_Response__c();
        envResponse1.Core_IPS_Question_Master__c = parQues3.Id;
        envResponse1.Core_IPS_Answer_Master__c =parentAns1.Id;
        envResponse1.Core_IPS_Case__c = cs.Id;
        insert envResponse1;
        
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord)); 
        test.stopTest();
    }
    static testmethod void InsertCaseRecordNegativemodesslc3(){
        getRecords(1);
        List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
        ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts1;
        Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO1.Core_Organization_Description__c='This is from portal side';
        insert CIPO1;
        System.AssertEquals('Trident Solutions',CIPO1.Core_IPS_Support_Org_Name__c);
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
        ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
        ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource.name='Supported_Product';
        IssueSource.Core_IPS_Default_Data__c='product';
        IssueSource.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource1=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource1.name='Asset';
        IssueSource1.Core_IPS_Default_Data__c='product';
        IssueSource1.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource3=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource3.name='Case Description';
        IssueSource3.Core_IPS_Default_Data__c='product';
        IssueSource3.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource3;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource2=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource2.name='Project';
        IssueSource2.Core_IPS_Default_Data__c='product';
        IssueSource2.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource2;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource4=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource4.name='Case Type';
        IssueSource4.Core_IPS_Default_Data__c='product';
        IssueSource4.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource4;      
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource5=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource5.name='Issue Source';
        IssueSource5.Core_IPS_Default_Data__c='product';
        IssueSource5.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource5;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource7=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource7.name='Case Category';
        IssueSource7.Core_IPS_Default_Data__c='product';
        IssueSource7.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource7;       
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource6=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource6.name='Case Subcategory';
        IssueSource6.Core_IPS_Default_Data__c='product';
        IssueSource6.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource6;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource8=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource8.name='Case Subcategory Detail';
        IssueSource8.Core_IPS_Default_Data__c='product';
        IssueSource8.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource8;
        test.startTest();
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','sslc');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.showGECFields = True;
        ipsCustomerCaseController.objectSelected ='Contact';
        
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        
        ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getCountries();
        ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController.selectedProduct = '';
        Pagereference Pg = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.selectedProject = null;//Added By Manoj
        Pagereference Pg1 = ipsCustomerCaseController.clearProduct();//Added By Manoj
        ipsCustomerCaseController.clearEnvDetails();
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
        
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
        //parQues.recordtypeid = edqRecordTypeId;
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        lstparQues.add(parQues1);
        insert lstparQues;
        
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<8;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            // childQuestion.recordTypeId = edqRecordTypeId;
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Product_Organization__c = org.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues1.id;
            childQuesList.add(childQuestion);
        }
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues1.id;
        insert parentAns;
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        
        Case cs = new Case();
        cs.assetId=asset.id;
        insert cs;
        
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = parQues1.Id;
        envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
        envResponse.Core_IPS_Case__c = cs.Id;
        lstEnvResponse.add(envResponse);
        insert lstEnvResponse;
        
        
        List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
        Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
        question.isVisible=false;
        question.type='Text';
        question.questionId=parQues1.id;
        question.sPlaceHolder=null;
        question.required=true;
        question.selectedValue='test';
        
        Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
        question4.type='Multiselect Picklist';
        question4.questionId=parQues1.id;
        question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
        question1.type='Text Area';
        question1.questionId=parQues1.id;
        question1.tPlaceHolder='';
        question4.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
        question5.type='Text Area';
        question5.questionId=parQues1.id;
        question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
        question2.type='Picklist';
        question2.questionId=parQues1.id;
        question2.sPlaceHolder=null;
        
        Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
        question3.type='Multiselect Picklist';
        question3.questionId=parQues1.id;
        question3.tPlaceHolder=null;
        question3.required=true;
        
        lstquestion.add(question);
        lstquestion.add(question1);
        lstquestion.add(question2);
        lstquestion.add(question3);
        lstquestion.add(question4);
        lstquestion.add(question5);
        
        Core_IPS_Labels__c label2= new Core_IPS_Labels__c();
        label2.name= 'Core_IPS_Datatype_TextArea';
        label2.value__c= 'Multiselect Picklist';
        insert label2;
        
        ipsCustomerCaseController.filteredEnvDetails = lstquestion;
        ipsCustomerCaseController.validateFilteredEnvironmentDetails();
        
        Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
        insert subCategory;
        
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        EnvDetails.Core_IPS_Question__c =parQues1.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        //Modified By Manoj
        for(integer i=0;i<8;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = CIPO.Id;
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
        
        ipsCustomerCaseController.constructResponse(question);
        ipsCustomerCaseController.constructResponse(question2);
        ipsCustomerCaseController.constructResponse(question5);
        ipsCustomerCaseController.constructResponse(question3);
        ipsCustomerCaseController.constructResponse(question1);
        ipsCustomerCaseController.constructResponse(question4);
        
        ipsCustomerCaseController.setCurrentEnvironmentDetails(lstquestion,cs.id);
        ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
        ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentOptions();
        ipsCustomerCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        ipsCustomerCaseController.GECAnswer1='Yes';
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        /********Added By Manoj*********/ 
        ipsCustomerCaseController.envDetails=lstquestion;
        ipsCustomerCaseController.saveCaseDetails();//Added By Manoj
        system.debug(ipsCustomerCaseController.GECAnswer1);
        system.debug(ipsCustomerCaseController.GECAnswer2);
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        
        Core_IPS_Question__c parQues3 = new Core_IPS_Question__c(); 
        parQues3.Core_IPS_Question__c = 'Test Parent Question';
        parQues3.Core_IPS_Datatype__c = 'Text Area';
        parQues3.Core_IPS_Status__c = 'Active';
        parQues3.Core_IPS_Product_Organization__c = Org.id;
        insert parQues3;
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns1 =  new Core_IPS_Answer__c();
        parentAns1.Core_IPS_Answer__c = 'Test Answer';
        parentAns1.Core_IPS_Status__c = 'Active';
        parentAns1.Core_IPS_Question__c = parQues3.id;
        insert parentAns1;
        
        Core_IPS_Response__c envResponse1 = new Core_IPS_Response__c();
        envResponse1.Core_IPS_Question_Master__c = parQues3.Id;
        envResponse1.Core_IPS_Answer_Master__c =parentAns1.Id;
        envResponse1.Core_IPS_Case__c = cs.Id;
        insert envResponse1;
        
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord)); 
        test.stopTest();
    }
    static testmethod void InsertCaseRecordNegativemodesslc4(){
        getRecords(1);
        List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
        ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts1;
        Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO1.Core_Organization_Description__c='This is from portal side';
        insert CIPO1;
        System.AssertEquals('Trident Solutions',CIPO1.Core_IPS_Support_Org_Name__c);
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
        ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
        ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource.name='Supported_Product';
        IssueSource.Core_IPS_Default_Data__c='product';
        IssueSource.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource1=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource1.name='Asset';
        IssueSource1.Core_IPS_Default_Data__c='product';
        IssueSource1.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource3=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource3.name='Case Description';
        IssueSource3.Core_IPS_Default_Data__c='product';
        IssueSource3.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource3;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource2=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource2.name='Project';
        IssueSource2.Core_IPS_Default_Data__c='product';
        IssueSource2.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource2;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource4=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource4.name='Case Type';
        IssueSource4.Core_IPS_Default_Data__c='product';
        IssueSource4.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource4;      
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource5=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource5.name='Issue Source';
        IssueSource5.Core_IPS_Default_Data__c='product';
        IssueSource5.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource5;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource7=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource7.name='Case Category';
        IssueSource7.Core_IPS_Default_Data__c='product';
        IssueSource7.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource7;       
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource6=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource6.name='Case Subcategory';
        IssueSource6.Core_IPS_Default_Data__c='product';
        IssueSource6.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource6;
        Core_IPS_SSLCCase_DefaultData__c IssueSource8=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource8.name='Case Subcategory Detail';
        IssueSource8.Core_IPS_Default_Data__c='product';
        IssueSource8.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource8;
        test.startTest();
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','sslc');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.showGECFields = True;
        ipsCustomerCaseController.objectSelected ='Contact';
        
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        
        ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getCountries();
        ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController.selectedProduct = '';
        Pagereference Pg = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.selectedProject = null;//Added By Manoj
        Pagereference Pg1 = ipsCustomerCaseController.clearProduct();//Added By Manoj
        ipsCustomerCaseController.clearEnvDetails();
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
        
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c(); 
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        lstparQues.add(parQues1);
        insert lstparQues;
        
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<8;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Product_Organization__c = org.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues1.id;
            childQuesList.add(childQuestion);
        }
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues1.id;
        insert parentAns;
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        
        Case cs = new Case();
        cs.assetId=asset.id;
        insert cs;
        
        
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = parQues1.Id;
        envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
        envResponse.Core_IPS_Case__c = cs.Id;
        lstEnvResponse.add(envResponse);
        insert lstEnvResponse;
        
        List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
        Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
        question.isVisible=false;
        question.type='Text';
        question.questionId=parQues1.id;
        question.sPlaceHolder=null;
        question.required=true;
        question.selectedValue='test';
        
        Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
        question4.type='Multiselect Picklist';
        question4.questionId=parQues1.id;
        question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
        question1.type='Text Area';
        question1.questionId=parQues1.id;
        question1.tPlaceHolder='';
        question4.required=true;
        
        Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
        question5.type='Text Area';
        question5.questionId=parQues1.id;
        question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
        question2.type='Picklist';
        question2.questionId=parQues1.id;
        question2.sPlaceHolder=null;
        
        Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
        question3.type='Multiselect Picklist';
        question3.questionId=parQues1.id;
        question3.tPlaceHolder=null;
        question3.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        
        lstquestion.add(question);
        lstquestion.add(question1);
        lstquestion.add(question2);
        lstquestion.add(question3);
        lstquestion.add(question4);
        lstquestion.add(question5);
        
        Core_IPS_Labels__c label2= new Core_IPS_Labels__c();
        label2.name= 'Core_IPS_Datatype_TextArea';
        label2.value__c= 'Multiselect Picklist';
        insert label2;
        
        ipsCustomerCaseController.filteredEnvDetails = lstquestion;
        ipsCustomerCaseController.validateFilteredEnvironmentDetails();
        
        Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
        insert subCategory;
        
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        EnvDetails.Core_IPS_Question__c =parQues1.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        //Modified By Manoj
        for(integer i=0;i<8;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = CIPO.Id;
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
        
        ipsCustomerCaseController.constructResponse(question);
        ipsCustomerCaseController.constructResponse(question2);
        ipsCustomerCaseController.constructResponse(question5);
        ipsCustomerCaseController.constructResponse(question3);
        ipsCustomerCaseController.constructResponse(question1);
        ipsCustomerCaseController.constructResponse(question4);
        ipsCustomerCaseController.setCurrentEnvironmentDetails(lstquestion,cs.id);
        ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
        ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
        ipsCustomerCaseController.getEnvironmentOptions();
        ipsCustomerCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        ipsCustomerCaseController.GECAnswer1='Yes';
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        /********Added By Manoj*********/ 
        ipsCustomerCaseController.envDetails=lstquestion;
        ipsCustomerCaseController.saveCaseDetails();//Added By Manoj
        system.debug(ipsCustomerCaseController.GECAnswer1);
        system.debug(ipsCustomerCaseController.GECAnswer2);
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        
        Core_IPS_Question__c parQues3 = new Core_IPS_Question__c();       
        //parQues.recordtypeid = edqRecordTypeId;
        parQues3.Core_IPS_Question__c = 'Test Parent Question';
        parQues3.Core_IPS_Datatype__c = 'Text Area';
        parQues3.Core_IPS_Status__c = 'Active';
        parQues3.Core_IPS_Product_Organization__c = Org.id;
        
        insert parQues3;
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns1 =  new Core_IPS_Answer__c();
        parentAns1.Core_IPS_Answer__c = 'Test Answer';
        parentAns1.Core_IPS_Status__c = 'Active';
        parentAns1.Core_IPS_Question__c = parQues3.id; 
        insert parentAns1;
        
        Core_IPS_Response__c envResponse1 = new Core_IPS_Response__c();
        envResponse1.Core_IPS_Question_Master__c = parQues3.Id;
        envResponse1.Core_IPS_Answer_Master__c =parentAns1.Id;
        envResponse1.Core_IPS_Case__c = cs.Id;
        insert envResponse1;
        
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord)); 
        test.stopTest();
    }
    /*static testmethod void InsertCaseRecordNegativemodesslc5(){
        
        getRecords(1);
        Account testAccount = new Account();
        Contact testContact = new Contact();
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        User u = [select id from user where usertype='Standard' AND ISActive=true AND profileId=:prof.id AND UserRole.Name != NULL limit 1 ];
        System.RunAs(u){
            System.debug('user negative');
            testAccount.Name='testAccountSetup';
            testAccount.Core_Sales_Group__c='Global Accounts';
            testAccount.Core_Account_Type__c='Other';
            testAccount.Industry='Others';
            testAccount.BillingStreet='1234 testAccountSetup';
            testAccount.BillingCity='testCity1';
            testAccount.BillingState='OR';
            testAccount.BillingCountry='USA';
            testAccount.BillingPostalCode='12345';
            testAccount.Core_CNDA_Number__c = '126545';
            insert testAccount;
            System.debug('user testAccount');
            testContact.FirstName='testFirstName123';
            testContact.LastName='testLastName';
            testContact.Email='test123456@testing.com.testsetup';
            testContact.Core_IPS_Intel_Support_Owner__c=u.id;
            testContact.AccountId=testAccount.id;
            testContact.Core_Personal_Email_Indicator__c = false;
            testContact.Core_Enterprise_Id__c='12345';
            testContact.Core_AGS_Integration_Status__c='Successful';
            testContact.Core_IPS_Active__c=true;
            insert testContact; 
            System.debug('user testContact');
        }
        Product2 aproduct2 = new Product2();
        aproduct2.Name='4th Intel';
        insert aproduct2;
        system.debug('user aproduct2');
        Case cse = new Case ();
        cse.status='new';
        cse.Origin = 'Web';
        cse.accountid=testAccount.id;
        cse.contactid=testContact.id;
        cse.Core_IPS_Partner_Sup_Owner__c=ListOfCustomerSfUsers.get(0).id;
        insert cse;
        system.debug('user cse');
        System.RunAs(ListOfCustomerSfUsers.get(0)){            
            List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
            ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='5678';
            insert ListOfProducts1;
            system.debug('user ListOfProducts1');
            Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
            CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
            CIPO1.Core_Organization_Description__c='This is from portal side';
            insert CIPO1;
            system.debug('user CIPO1');
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
            ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
            ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =true;
            insert ListOfSupportedProduct1;
            system.debug('user ListOfSupportedProduct1');
            Core_IPS_SSLCCase_DefaultData__c IssueSource=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSource.name='Supported_Product';
            IssueSource.Core_IPS_Default_Data__c='product';
            IssueSource.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
            insert IssueSource;
            system.debug('user IssueSource');
            Core_IPS_SSLCCase_DefaultData__c IssueSource1=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSource1.name='Asset';
            IssueSource1.Core_IPS_Default_Data__c='product';
            IssueSource1.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
            insert IssueSource1;
            system.debug('user IssueSource1');
            Core_IPS_SSLCCase_DefaultData__c IssueSource3=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSource3.name='Case Description';
            IssueSource3.Core_IPS_Default_Data__c='product';
            IssueSource3.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
            insert IssueSource3;
            system.debug('user IssueSource3');
            Core_IPS_SSLCCase_DefaultData__c IssueSource2=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSource2.name='Project';
            IssueSource2.Core_IPS_Default_Data__c='product';
            IssueSource2.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
            insert IssueSource2;
            system.debug('user IssueSource2');
            Core_IPS_SSLCCase_DefaultData__c IssueSource4=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSource4.name='Case Type';
            IssueSource4.Core_IPS_Default_Data__c='product';
            IssueSource4.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
            insert IssueSource4;      
            
            Core_IPS_SSLCCase_DefaultData__c IssueSource5=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSource5.name='Issue Source';
            IssueSource5.Core_IPS_Default_Data__c='product';
            IssueSource5.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
            insert IssueSource5;
            
            Core_IPS_SSLCCase_DefaultData__c IssueSource7=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSource7.name='Case Category';
            IssueSource7.Core_IPS_Default_Data__c='product';
            IssueSource7.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
            insert IssueSource7;       
            
            Core_IPS_SSLCCase_DefaultData__c IssueSource6=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSource6.name='Case Subcategory';
            IssueSource6.Core_IPS_Default_Data__c='product';
            IssueSource6.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
            insert IssueSource6;
            Core_IPS_SSLCCase_DefaultData__c IssueSource8=new Core_IPS_SSLCCase_DefaultData__c();
            IssueSource8.name='Case Subcategory Detail';
            IssueSource8.Core_IPS_Default_Data__c='product';
            IssueSource8.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
            insert IssueSource8;
            Test.startTest();
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','sslc');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
            system.debug('ListOfAssets --' + ListOfAssets);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.showGECFields = True;
            ipsCustomerCaseController.objectSelected ='Contact';
            
            Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
            CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
            CIPO.Core_Organization_Description__c='This is from portal side';
            insert CIPO;
            System.AssertEquals('Trident Solutions',CIPO.Core_IPS_Support_Org_Name__c);
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
            insert ListOfProducts;
            //Test.starttest();
         
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
            ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
            ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
            insert ListOfSupportedProduct;
            ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
            ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
            ipsCustomerCaseController.LookupChange(); 
            ipsCustomerCaseController.getCountries();
            ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
            ipsCustomerCaseController.selectedProduct = '';
            Pagereference Pg = ipsCustomerCaseController.clearProduct();
            ipsCustomerCaseController.selectedProject = null;//Added By Manoj
            Pagereference Pg1 = ipsCustomerCaseController.clearProduct();//Added By Manoj
            ipsCustomerCaseController.clearEnvDetails();
            
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c ='test';
            org.Core_Organization_Description__c ='test';
            insert org;
            //Parent Question Record
            List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
            
            Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
            //parQues.recordtypeid = edqRecordTypeId;
            parQues1.Core_IPS_Question__c = 'Test Parent Question';
            parQues1.Core_IPS_Datatype__c = 'Text';
            parQues1.Core_IPS_Status__c = 'Active';
            parQues1.Core_IPS_Product_Organization__c = Org.id;
            lstparQues.add(parQues1);
            insert lstparQues;
            
            List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
            for(Integer i=0;i<8;i++){
                Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
                // childQuestion.recordTypeId = edqRecordTypeId;
                childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
                childQuestion.Core_IPS_Status__c = 'Active';
                childQuestion.Core_IPS_Datatype__c = 'Picklist';
                childQuestion.Core_IPS_Product_Organization__c = org.id;
                childQuestion.Core_IPS_Parent_Question__c = parQues1.id;
                childQuesList.add(childQuestion);
            }
            //Parnet Question- Answer Record       
            Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
            parentAns.Core_IPS_Answer__c = 'Test Answer';
            parentAns.Core_IPS_Status__c = 'Active';
            parentAns.Core_IPS_Question__c = parQues1.id;
            insert parentAns;
            Asset asset= new Asset();
            asset.Name='intel@Products';
            insert asset;
            List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
            Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
            envResponse.Core_IPS_Question_Master__c = parQues1.Id;
            envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
            envResponse.Core_IPS_Case__c = cse.Id;
            //Core_IPS_Answer__c
            lstEnvResponse.add(envResponse);
            insert lstEnvResponse;
            
            List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
            Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
            question.isVisible=false;
            question.type='Text';
            question.questionId=parQues1.id;
            question.sPlaceHolder=null;
            question.required=true;
            question.selectedValue='test';
            
            Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
            question1.isVisible=false;
            question1.type='Text';
            question1.questionId=parQues1.id;
            question1.sPlaceHolder=null;
            question1.required=true;
            question1.selectedValue='test';
            
            Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
            question4.type='Multiselect Picklist';
            question4.questionId=parQues1.id;
            question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
            
            
            
            Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
            //question5.isVisible=false;
            question5.type='Text Area';
            question5.questionId=parQues1.id;
            question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
            
            Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
            question2.type='Picklist';
            question2.questionId=parQues1.id;
            question2.sPlaceHolder=null;
            
            Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
            question3.type='Multiselect Picklist';
            question3.questionId=parQues1.id;
            question3.tPlaceHolder=null;
            question3.selectedValue = '[]';
            question3.required = true;
            
            Core_IPS_EnvironmentDetailQuestion question6 = new Core_IPS_EnvironmentDetailQuestion();
            question6.type='';
            question6.questionId=parQues1.id;
            question6.tPlaceHolder='';
            question6.required=true;
            
            lstquestion.add(question);
            lstquestion.add(question1);
            lstquestion.add(question2);
            lstquestion.add(question3);
            lstquestion.add(question4);
            lstquestion.add(question5);
            lstquestion.add(question6);
            
            Core_IPS_Labels__c label2= new Core_IPS_Labels__c();
            label2.name= 'Core_IPS_Picklist';
            label2.value__c= 'Multiselect Picklist';
            insert label2;
            
            ipsCustomerCaseController.filteredEnvDetails = lstquestion;
            ipsCustomerCaseController.validateFilteredEnvironmentDetails();
            Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
            insert subCategory;
            
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert ListOfSupportOrg;
            
            List<Product2> ListOfProducts3 = TestUtilities.getListOfProduct(1);
            insert ListOfProducts3;
            
            
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct3 = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct3.get(0).Core_Product__c = ListOfProducts3.get(0).id;
            ListOfSupportedProduct3.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            insert ListOfSupportedProduct3;
            
            Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
            EnvDetails.Core_IPS_Question__c =parQues1.id;
            EnvDetails.Core_Required__c=true;
            EnvDetails.Core_Status__c = 'Active';
            EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
            EnvDetails.Core_supported_product__c = ListOfSupportedProduct3[0].id;
            insert EnvDetails;
            
            List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
            //Modified By Manoj
            for(integer i=0;i<8;i++){
                Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
                envVar.Core_Product_Organization__c = CIPO.Id;
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
            
            ipsCustomerCaseController.constructResponse(question);
            ipsCustomerCaseController.constructResponse(question2);
            ipsCustomerCaseController.constructResponse(question5);
            ipsCustomerCaseController.constructResponse(question1);
            ipsCustomerCaseController.constructResponse(question4);
            ipsCustomerCaseController.setCurrentEnvironmentDetails(lstquestion,cse.id);
            String strjs = JSON.serialize(lstEnvResponse); 
            ipsCustomerCaseController.setSearchedEnvironmentDetails(lstquestion,strjs);
            ipsCustomerCaseController.cs = CaseRecord;//Added By Manoj
            ipsCustomerCaseController.categorySelected = caseCat.id;//Added By Manoj
            ipsCustomerCaseController.subCategorySelected = null;//Added By Manoj
            ipsCustomerCaseController.getEnvironmentDets();//Added By Manoj
            ipsCustomerCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
            ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;//Added By Manoj
            ipsCustomerCaseController.getEnvironmentOptions();
            ipsCustomerCaseController.getEnvironmentDets();
            system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
            ipsCustomerCaseController.GECAnswer1='Yes'; 
            ipsCustomerCaseController.showGECFields = true;
            ipsCustomerCaseController.GECAnswer1 = 'yes';
            ipsCustomerCaseController.GECAnswer2 = 'yes';
            ipsCustomerCaseController.envDetails=lstquestion;
            ipsCustomerCaseController.saveCaseDetails();//Added By Manoj
            system.debug(ipsCustomerCaseController.GECAnswer1);
            system.debug(ipsCustomerCaseController.GECAnswer2);
            List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
            ipsCustomerCaseController.getEnvironmentDets();
            
            Core_IPS_Question__c parQues3 = new Core_IPS_Question__c(); 
            parQues3.Core_IPS_Question__c = 'Test Parent Question';
            parQues3.Core_IPS_Datatype__c = 'Text Area';
            parQues3.Core_IPS_Status__c = 'Active';
            parQues3.Core_IPS_Product_Organization__c = Org.id;
            insert parQues3;
            
            //Parnet Question- Answer Record       
            Core_IPS_Answer__c parentAns1 =  new Core_IPS_Answer__c();
            parentAns1.Core_IPS_Answer__c = 'Test Answer';
            parentAns1.Core_IPS_Status__c = 'Active';
            parentAns1.Core_IPS_Question__c = parQues3.id;
            insert parentAns1;
            
            Core_IPS_Response__c envResponse1 = new Core_IPS_Response__c();
            envResponse1.Core_IPS_Question_Master__c = parQues3.Id;
            envResponse1.Core_IPS_Answer_Master__c =parentAns1.Id;
            envResponse1.Core_IPS_Case__c = cse.Id;
            insert envResponse1;
            
            //for mode=Snew
            Core_IPS_Deflected_Object__c dfltObj = new Core_IPS_Deflected_Object__c();
            dfltObj.Core_IPS_Status__c='Deflected';
            insert dfltObj;
            String PARTITION_NAME = system.label.Core_IPS_Platform_Cache_Name;
            Cache.Partition  partition = Cache.Session.getPartition(PARTITION_NAME);
            partition.put('caseJson'+dfltObj.id, JSON.serialize(CaseRecord),9000);
            partition.put('EnvResponse'+dfltObj.id, JSON.serialize(lstEnvResponse),9000);
            PageReference CustomerCaseCreationPage1 = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage1);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','sNew');
            ApexPages.currentPage().getParameters().put('sbs','ccs');
            RecordType RTT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RTT.Id);
            ApexPages.currentPage().getParameters().put('deflectedId',dfltObj.Id);
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord)); 
            ipsCustomerCaseController.filteredEnvDetails = lstquestion;
            Test.stopTest();
            try{
                //Test.startTest();
                ipsCustomerCaseController1.isagent=false;
                ipsCustomerCaseController1.isPartnerAgent=true;
                ipsCustomerCaseController1.getSnewModeRequiredData();
            }
            catch(Exception e){            
            }
            
        }
        
    }    */
    /*   static testmethod void InsertCaseRecordstwo(){
getRecords(1);
CaseRecord.Core_IPS_Supported_Product__c= null;
CaseRecord.Core_Severity__c='Critical1';
System.RunAs(ListOfCustomerSfUsers.get(0)){
// Setting the Visualforce Page
PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
Test.setCurrentPage(CustomerCaseCreationPage);
// Assigning parameters in the URL
ApexPages.currentPage().getParameters().put('mode','asset');
ApexPages.currentPage().getParameters().put('sbs','ccs');
RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
ApexPages.currentPage().getParameters().put('rType',RT.Id);
Account accountRecord1 = new Account(
Name = 'Dell Products test',
Core_Account_Type__c = 'Distributor',
Core_Sales_Segment__c = 'Compute',
Industry = 'Banking',
BillingCity = 'Delhi',
BillingCountry = 'USA',
billingState = 'AK',
billingStreet = 'Bratislava 1',
Core_IPS_Active__c = true
);
insert accountRecord1;
Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
insert cipspro;

core_ips_account__c projAccount= new core_ips_account__c();
projAccount.Core_Account__c=accountRecord1.Id;
projAccount.Core_IPS_Project__c=cipspro.Id;
projAccount.Core_Members__c = 'All';
projAccount.Core_Status__c = 'Active';
insert projAccount;

ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
ApexPages.currentPage().getParameters().put('accountId', projAccount.id);
ApexPages.currentPage().getParameters().put('projectId', cipspro.Id);
// instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
ipsCustomerCaseController.objectSelected ='Product';
ipsCustomerCaseController.cs = CaseRecord;
ipsCustomerCaseController.LookupChange();  
ipsCustomerCaseController.getEnvDetails();
system.debug('CaseRecord -- ' + CaseRecord);
system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails);
ipsCustomerCaseController.categorySelected=caseCat.id;
ipsCustomerCaseController.subCategorySelected= subCategory.id;
ipsCustomerCaseController.GECAnswer1='No';
ipsCustomerCaseController.GECAnswer2='No';
ipsCustomerCaseController.GECAnswer3='No';
List<String> val= new List<String>();
val.add('test');
val.add('test2');
ipsCustomerCaseController.showGECFields = true;
ipsCustomerCaseController.cs = CaseRecord;
Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
org.Core_IPS_Support_Org_Name__c ='test';
org.Core_Organization_Description__c ='test';
insert org;

Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
system.debug('edqRecordTypeId===='+edqRecordTypeId);
//Parent Question Record
Core_IPS_Question__c parQues = new Core_IPS_Question__c();       
parQues.recordtypeid = edqRecordTypeId;
parQues.Core_IPS_Question__c = 'Test Parent Question';
parQues.Core_IPS_Datatype__c = 'Picklist';
parQues.Core_IPS_Status__c = 'Active';
parQues.Core_IPS_Product_Organization__c = Org.id;

Core_IPS_Question__c childQues = new Core_IPS_Question__c();       
childQues.recordtypeid = edqRecordTypeId;
childQues.Core_IPS_Question__c = 'Test Child Question';
childQues.Core_IPS_Datatype__c = 'Picklist';
childQues.Core_IPS_Status__c = 'Active';
childQues.Core_IPS_Product_Organization__c = Org.id;

List<Core_IPS_EnvironmentDetailQuestion> lstchildquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
Core_IPS_EnvironmentDetailQuestion childquestion = new Core_IPS_EnvironmentDetailQuestion();
childquestion.isVisible=false;
childquestion.type='Text';
childquestion.questionId=childQues.id;
childquestion.sPlaceHolder=null;
childquestion.required=true;
lstchildquestion.add(childquestion);

List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
question.isVisible=false;
question.type='Text';
question.questionId=parQues.id;
question.sPlaceHolder=null;
question.required=true;
question.childQuestions=lstchildquestion;
lstquestion.add(question);
ipsCustomerCaseController.envDetails=lstquestion;
ipsCustomerCaseController.saveCaseDetails();
ipsCustomerCaseController.DisplayPriorityReason();
ipsCustomerCaseController.selectedProject = null;
ipsCustomerCaseController.showProjListBasedOnSelectedProd();
ipsCustomerCaseController.productChanges();
ipsCustomerCaseController.selectedProject=cipspro.Id;
ipsCustomerCaseController.clearProject();
ipsCustomerCaseController.getsubCategory_Options(caseCat.id);
}
}
*/
    static testmethod void testPortalUser(){
        
            test.startTest();
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' and name='Admin' Limit 1];
            Profile prof = [select id from profile where name = 'System Administrator' limit 1];
            User usr = [Select Id,UserRoleId from User where UserRoleId=:portalRole.Id AND profileId=:prof.id AND isactive=true limit 1];
            /*Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
insert cipspro;
UserRecordAccess userAccess=[SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:usr.id AND RecordId=:cipspro.id limit 1];*/
            system.runAs(usr){
                //Create account
                Account portalAccount1 = new Account(
                    Name = 'newAcc2',
                    BillingCity = 'folsom',
                    BillingCountry = 'USA',
                    BillingStreet = 'Creek Side Dr'    
                );
                Database.insert(portalAccount1);
                //Create contact
                Contact contact1 = new Contact(
                    AccountId = portalAccount1.id,
                    FirstName = 'portia',
                    LastName  = 'portalTestUser',
                    Email='babux5x5@intel.com'      
                );
                Database.insert(contact1);
                Profile p = [select id, name from Profile where name in ('IPS Agent-Partner') limit 1]; 
                //create user record
                User user1=new User(
                    username = 'newUser343434@yahoo.com',
                    ContactId = contact1.Id,   
                    profileId =p.id,   
                    email = 'ponneri2525@intel.com',
                    emailencodingkey = 'UTF-8',
                    localesidkey = 'en_US',
                    languagelocalekey = 'en_US',
                    timezonesidkey = 'America/Los_Angeles',
                    alias='nuser',
                    Firstname='BruceS',   
                    lastname='lastname2'
                );
                Database.insert(user1);
                system.runAs(user1){
                    // Setting the Visualforce Page
                    PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
                    Test.setCurrentPage(CustomerCaseCreationPage);
                    ApexPages.currentPage().getParameters().put('mode','edit');
                    Case CaseRecord =  TestUtilities.getCase(); 
                    CaseRecord.AccountId=portalAccount1.id;
                    CaseRecord.contactid=contact1.id;
                    insert CaseRecord;
                    System.assertNotEquals(null, CaseRecord);
                    ApexPages.currentPage().getParameters().put('id',CaseRecord.id);
                    Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));    
                }
            }
            test.stopTest();  
            
        
    }
    static testmethod void getAssetEnvwithsubcategoryTest(){
        test.startTest();
        Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
        label1.name= 'Core_IPS_Datatype_Text';
        label1.value__c= 'Text';
        insert label1;
        List<Core_IPS_EV_Filters__c> lstEnv = new List<Core_IPS_EV_Filters__c>();
        Core_IPS_EV_Filters__c evntFields = new Core_IPS_EV_Filters__c(); 
        evntFields.Name='Test';
        lstEnv.add(evntFields);
        Core_IPS_EV_Filters__c evntFields2 = new Core_IPS_EV_Filters__c(); 
        evntFields2.Name='Altera Software';
        lstEnv.add(evntFields2);
        insert lstEnv;
        //Support Org
        Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO1.Core_Organization_Description__c='This is from portal side';
        insert CIPO1;
        
        //Product2
        List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
        ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts1;
        
        // Supported Product        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
        ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
        ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct1;
        
        // Create Design Project Record
        ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        insert ListOfIpsProjects;
        System.assert(ListOfIpsProjects.get(0).Id != null, 'Design Project Record not created');
        // Create IPS Product Record
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        ListOfIpsProducts.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
        ListOfIpsProducts.get(0).Core_Supported_Product__c = ListOfSupportedProduct1.get(0).id;
        ListOfIpsProducts.get(0).Status__c = 'Submitted';
        insert ListOfIpsProducts;
        System.assert(ListOfIpsProducts.get(0).Id != null, 'IPS Product Record not created');
        
        // Create Asset
        ListOfAssets = TestUtilities.getAssetList(1);
        ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfAssets.get(0).Core_Product_Organization__c = CIPO1.Id;
        ListOfAssets.get(0).product2Id = ListOfProducts1.get(0).Id;
        ListOfAssets.get(0).Core_Supported_Product__c = ListOfSupportedProduct1.get(0).Id;
        insert ListOfAssets;
        
        //EDQ record type
        Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
        //Parent Question Record
        Core_IPS_Question__c parQues = new Core_IPS_Question__c();       
        parQues.recordTypeId = edqRecordTypeId;
        parQues.Core_IPS_Question__c = 'Test Parent Question';
        parQues.Core_IPS_Datatype__c = 'Text';
        parQues.Core_IPS_Status__c = 'Active';
        parQues.Core_IPS_Product_Organization__c = CIPO1.id; 
        insert parQues;
        
        //Creating Environmental Details Operational
        List<Core_IPS_Assigned_Environment_Variables__c> EnvironmentalDetailsList = new List<Core_IPS_Assigned_Environment_Variables__c>();
        Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails = new Core_IPS_Assigned_Environment_Variables__c ();
        EnvironmentalDetails.Core_Status__c = 'Active';
        EnvironmentalDetails.Core_IPS_Question__c = parQues.id;
        EnvironmentalDetails.Core_Required__c=true;
        EnvironmentalDetails.Core_supported_product__c = ListOfSupportedProduct1[0].id;
        EnvironmentalDetailsList.add(EnvironmentalDetails);
        
        Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails2 = new Core_IPS_Assigned_Environment_Variables__c ();
        EnvironmentalDetails2.Core_Status__c = 'Active';
        EnvironmentalDetails2.Core_IPS_Question__c = parQues.id;
        EnvironmentalDetails2.Core_Required__c=false;
        EnvironmentalDetails2.Core_Product_Issue_Sub_Category__c = subCategory.id;
        EnvironmentalDetailsList.add(EnvironmentalDetails2);
        insert EnvironmentalDetailsList;
        System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
        
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
        caseCat.Core_Supported_Product__c=ListOfSupportedProduct1.get(0).Id;
        insert caseCat; 
        System.assert(caseCat.Id != null, 'Record not created');
        
        subCategory = TestUtilities.getCaseCategories();
        subCategory.Core_Issue_Sub_Category_Name__c = MasterCategory.id;
        subCategory.Core_Type__c = 'Case Subcategory';
        subCategory.Core_Supported_Product__c=ListOfSupportedProduct1.get(0).Id;
        insert subCategory; 
        System.assert(subCategory.Id != null, 'Record not created');
        
        CaseRecord = new Case ();
        CaseRecord.AssetId=ListOfAssets.get(0).Id;
        CaseRecord.Core_IPS_Supported_Product__c=ListOfSupportedProduct1.get(0).id;
        CaseRecord.Core_IPS_Product_Org1__c=CIPO1.id;
        CaseRecord.Core_Case_Issue_Category__c = caseCat.id;
        CaseRecord.Core_case_issue_sub_category__c = subCategory.id;
        CaseRecord.Core_Issue_Description__c = 'test';
        CaseRecord.Subject='TestSubject';
        CaseRecord.Core_CaseType__c='Issue';
        insert CaseRecord;
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','new');
        ApexPages.currentPage().getParameters().put('sbs','scs');
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        PageReference CustomerCaseCreationPage1 = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage1);
        ApexPages.currentPage().getParameters().put('paramId',ListOfAssets.get(0).id);
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController1.selectedProject='NA';
        ipsCustomerCaseController1.showProjListBasedOnSelectedProd();
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController2 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController2.LookupChange();
        ipsCustomerCaseController2.SearchBeforeSubmit();
        Test.stopTest();
    }
   /* static testmethod void InsertCaseRecord_editObj2(){
        getRecords(3);
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert ListOfSupportOrg;
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        insert ListOfProducts;
        System.assert(ListOfProducts[0].id != null,'Product2 Record not created');
        // Create Supported product Record
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        insert ListOfSupportedProduct;
        System.assert(ListOfSupportedProduct[0].id != null,'Supported product Record not created');
        Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
        insert cipspro;
        
        System.RunAs(ListOfCustomerSfUsers.get(0)){
            // Setting the Visualforce Page
            PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
            Test.setCurrentPage(CustomerCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','iframe');
            String RT = [Select Id,Name From RecordType Where SobjectType = 'Case' and DeveloperName ='IPS_GEC_ReadOnly'].Id;
            ApexPages.currentPage().getParameters().put('rType',RT);
            User u = [select id from user where usertype='Standard' AND ISActive=true limit 1 ];
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545');
            insert testAccount;
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123456@testing.com.testsetup',Core_IPS_Intel_Support_Owner__c=u.id,
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Active__c=true);
            insert testContact;
            Asset asset= new Asset();
            asset.Name='intel Products test';
            insert asset;
            
            Case  cse = new Case ();
            cse.RecordTypeId=RT;
            cse.core_ips_project_case__c=cipspro.id;
            cse.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
            cse.status='closed';
            cse.accountid=testAccount.id;
            cse.contactid=testContact.id;
            cse.assetId=asset.id;
            insert cse;
            //Ev filter
            List<Core_IPS_EV_Filters__c> lstEnv = new List<Core_IPS_EV_Filters__c>();
            Core_IPS_EV_Filters__c evntFields = new Core_IPS_EV_Filters__c(); 
            evntFields.Name='Test Parent Question';
            evntFields.Core_IPS_Param_Name__c='question';
            lstEnv.add(evntFields);
            Core_IPS_EV_Filters__c evntFields2 = new Core_IPS_EV_Filters__c(); 
            evntFields2.Name='Altera Software';
            evntFields2.Core_IPS_Param_Name__c='question';
            lstEnv.add(evntFields2);
            insert lstEnv;
            
            Case CaseRecord = Core_IPS_CaseUtility.getCase_DynamiCSOQL(cse.id,true);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
            Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
            ipsCustomerCaseController.objectSelected ='Contact';
            system.debug('envDetails - ' + ipsCustomerCaseController.envDetails);
            ipsCustomerCaseController.GECAnswer2 ='Yes';
            ipsCustomerCaseController.GECAnswer3 ='Yes';
            ipsCustomerCaseController.GECAnswer1 ='Yes';
            ipsCustomerCaseController.LookupChange(); 
            ipsCustomerCaseController.getEnvDetails();
            ipsCustomerCaseController.saveCaseDetails();
        } 
    }*/
    
    
    //Test Method to create Deflected object JSON string.
    static testmethod void createJSONString(){
        getRecords(1);
        List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
        ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts1;
        Core_IPS_Product_Organization__c CIPO1 = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO1.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO1.Core_Organization_Description__c='This is from portal side';
        insert CIPO1;
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct1 = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct1.get(0).Core_Product__c = ListOfProducts1.get(0).id;
        ListOfSupportedProduct1.get(0).Core_Product_Organization__c=CIPO1.Id;
        ListOfSupportedProduct1.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource.name='Supported_Product';
        IssueSource.Core_IPS_Default_Data__c='product';
        IssueSource.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource1=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource1.name='Asset';
        IssueSource1.Core_IPS_Default_Data__c='product';
        IssueSource1.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource1;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource3=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource3.name='Case Description';
        IssueSource3.Core_IPS_Default_Data__c='product';
        IssueSource3.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource3;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource2=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource2.name='Project';
        IssueSource2.Core_IPS_Default_Data__c='product';
        IssueSource2.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource2;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource4=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource4.name='Case Type';
        IssueSource4.Core_IPS_Default_Data__c='product';
        IssueSource4.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource4;      
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource5=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource5.name='Issue Source';
        IssueSource5.Core_IPS_Default_Data__c='product';
        IssueSource5.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource5;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource7=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource7.name='Case Category';
        IssueSource7.Core_IPS_Default_Data__c='product';
        IssueSource7.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource7;       
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource6=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource6.name='Case Subcategory';
        IssueSource6.Core_IPS_Default_Data__c='product';
        IssueSource6.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource6;
        
        Core_IPS_SSLCCase_DefaultData__c IssueSource8=new Core_IPS_SSLCCase_DefaultData__c();
        IssueSource8.name='Case Subcategory Detail';
        IssueSource8.Core_IPS_Default_Data__c='product';
        IssueSource8.Core_IPS_Default_data_Id__c=ListOfSupportedProduct1[0].id;
        insert IssueSource8;
        test.startTest();
        // Setting the Visualforce Page
        PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
        Test.setCurrentPage(CustomerCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','sslc');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Customer_Case_Controller  Apex Class
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
        ipsCustomerCaseController.showGECFields = True;
        ipsCustomerCaseController.objectSelected ='Contact';
        
        Core_IPS_Product_Organization__c CIPO = new Core_IPS_Product_Organization__c(); //SupportOrg
        CIPO.Core_IPS_Support_Org_Name__c='Trident Solutions';
        CIPO.Core_Organization_Description__c='This is from portal side';
        insert CIPO;
        System.AssertEquals('Trident Solutions',CIPO.Core_IPS_Support_Org_Name__c);
        
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
        insert ListOfProducts;
        
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c=CIPO.Id;
        ListOfSupportedProduct.get(0).Core_IPS_Is_Show_Variant__c =true;
        insert ListOfSupportedProduct;
        
        ipsCustomerCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;
        ipsCustomerCaseController.LookupChange(); 
        ipsCustomerCaseController.getCountries();
        ipsCustomerCaseController.selectedProject = ListOfIpsProjects.get(0).Id;
        ipsCustomerCaseController.selectedProduct = '';
        Pagereference Pg = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.selectedProject = null;
        Pagereference Pg1 = ipsCustomerCaseController.clearProduct();
        ipsCustomerCaseController.clearEnvDetails();
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c ='test';
        org.Core_Organization_Description__c ='test';
        insert org;
        
        //Parent Question Record
        List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
        
        Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
        parQues1.Core_IPS_Question__c = 'Test Parent Question';
        parQues1.Core_IPS_Datatype__c = 'Text';
        parQues1.Core_IPS_Status__c = 'Active';
        parQues1.Core_IPS_Product_Organization__c = Org.id;
        insert parQues1;
        
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<8;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Product_Organization__c = org.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues1.id;
            childQuesList.add(childQuestion);
        }
        //Parent Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues1.id;
        insert parentAns;
        Asset asset= new Asset();
        asset.Name='intel@Products';
        insert asset;
        
        Case cs = new Case();
        cs.assetId=asset.id;
        cs.subject ='test';
        insert cs;
        
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = parQues1.Id;
        envResponse.Core_IPS_Answer_Master__c =parentAns.Id;
        envResponse.Core_IPS_Case__c = cs.Id;
        lstEnvResponse.add(envResponse);
        insert lstEnvResponse;
        
        Core_IPS_EV_Filters__c evntFields = new Core_IPS_EV_Filters__c(); 
        evntFields.Name='Q1';
        insert evntFields;
        
        List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
        Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
        question.isVisible=true;
        question.type='Multiselect Picklist';
        question.questionId=parQues1.id;
        question.sPlaceHolder=null;
        question.required=false;
        question.tPlaceHolder=null;
        question.label ='Q1';
        Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
        question4.type='Multiselect Picklist';
        question4.questionId=parQues1.id;
        question4.required=false;
        question4.isVisible=true;
        question4.tPlaceHolder=null;
        question4.sPlaceHolder=null;
        question.label ='Q1';
        Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
        question1.type='Multiselect Picklist';
        question1.questionId=parQues1.id;
        question1.tPlaceHolder=null;
        question1.required=false;
        question1.isVisible=true;
        question1.sPlaceHolder=null;
        question.label ='Q1';
        Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
        question5.type='Multiselect Picklist';
        question5.questionId=parQues1.id;
        question5.required=false;
        question5.isVisible=true;
        question5.tPlaceHolder=null;
        question5.sPlaceHolder=null;
        question.label ='Q1';
        Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
        question2.type='Picklist';
        question2.questionId=parQues1.id;
        question2.sPlaceHolder=null;
        question2.required=false;
        question2.isVisible=true;
        question2.tPlaceHolder=null;
        question.label ='Q1';
        Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
        question3.type='Multiselect Picklist';
        question3.questionId=parQues1.id;
        question3.tPlaceHolder=null;
        question3.required=false;
        question3.isVisible=true;
        question3.sPlaceHolder=null;
        question.label ='Q1';
        
        lstquestion.add(question);
        lstquestion.add(question1);
        lstquestion.add(question2);
        lstquestion.add(question3);
        lstquestion.add(question4);
        lstquestion.add(question5);
        
        Core_IPS_Labels__c label2= new Core_IPS_Labels__c();
        label2.name= 'Core_IPS_Datatype_TextArea';
        label2.value__c= 'Text Area';
        insert label2;
        System.AssertEquals('Trident Solutions',CIPO1.Core_IPS_Support_Org_Name__c);
        
        Core_IPS_Product_Issue_Category__c  subCategory = TestUtilities.getCaseCategories();
        insert subCategory;
        
        Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
        EnvDetails.Core_IPS_Question__c =parQues1.id;
        EnvDetails.Core_Required__c=true;
        EnvDetails.Core_Status__c = 'Active';
        EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
        insert EnvDetails;
        
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        for(integer i=0;i<8;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = CIPO.Id;
            ListOfenvVars.add(envVar);
        }
        
        ListOfenvVars[0].Core_Datatype__c= 'Picklist';
        ListOfenvVars[1].Core_Datatype__c= 'Text (255)';
        ListOfenvVars[2].Core_Datatype__c= 'Text Area (5000)';
        ListOfenvVars[3].Core_Datatype__c= 'Multiselect Picklist';
        
        ListOfenvVars[4].Core_Datatype__c= 'Picklist';
        ListOfenvVars[5].Core_Datatype__c= 'Text (255)';
        ListOfenvVars[6].Core_Datatype__c= 'Text Area (5000)';
        ListOfenvVars[7].Core_Datatype__c= 'Multiselect Picklist';
        insert ListOfenvVars;
        System.assertNotEquals(ListOfenvVars.size(),0); 
        
        ipsCustomerCaseController.constructResponse(question);
        ipsCustomerCaseController.constructResponse(question2);
        ipsCustomerCaseController.constructResponse(question5);
        ipsCustomerCaseController.constructResponse(question3);
        ipsCustomerCaseController.constructResponse(question1);
        ipsCustomerCaseController.constructResponse(question4);
        
        ipsCustomerCaseController.setCurrentEnvironmentDetails(lstquestion,cs.id);
        ipsCustomerCaseController.cs = CaseRecord;
        ipsCustomerCaseController.categorySelected = caseCat.id;
        ipsCustomerCaseController.subCategorySelected = null;
        ipsCustomerCaseController.getEnvironmentDets();
        ipsCustomerCaseController.subCategorySelected = subCategory.Id;
        
        ipsCustomerCaseController.selectedProductId = ListOfAssets.get(0).Id;
        ipsCustomerCaseController.getEnvironmentOptions();
        ipsCustomerCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsCustomerCaseController.envDetails+'----SubEnv Details---'+ipsCustomerCaseController.subCatenvDetList);
        ipsCustomerCaseController.GECAnswer1='Yes';
        ipsCustomerCaseController.showGECFields = true;
        ipsCustomerCaseController.GECAnswer1 = 'yes';
        ipsCustomerCaseController.GECAnswer2 = 'yes';
        ipsCustomerCaseController.envDetails=lstquestion;
        ipsCustomerCaseController.saveCaseDetails();
        system.debug(ipsCustomerCaseController.GECAnswer2);
        List<SelectOption> LstSelectOption = ipsCustomerCaseController.getsubCategory_Options(string.valueof(caseCat.id));
        ipsCustomerCaseController.getEnvironmentDets();
        
        Core_IPS_Question__c parQues3 = new Core_IPS_Question__c(); 
        parQues3.Core_IPS_Question__c = 'Test Parent Question';
        parQues3.Core_IPS_Datatype__c = 'Text Area';
        parQues3.Core_IPS_Status__c = 'Active';
        parQues3.Core_IPS_Product_Organization__c = Org.id;
        insert parQues3;
        Core_IPS_Answer__c parentAns1 =  new Core_IPS_Answer__c();
        parentAns1.Core_IPS_Answer__c = 'Test Answer';
        parentAns1.Core_IPS_Status__c = 'Active';
        parentAns1.Core_IPS_Question__c = parQues3.id;
        insert parentAns1;
        
        Core_IPS_Response__c envResponse1 = new Core_IPS_Response__c();
        envResponse1.Core_IPS_Question_Master__c = parQues3.Id;
        envResponse1.Core_IPS_Answer_Master__c =parentAns1.Id;
        envResponse1.Core_IPS_Case__c = cs.Id;
        insert envResponse1;
        
        Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord)); 
        ipsCustomerCaseController1.cs = cs;
        ipsCustomerCaseController1.filteredEnvDetails = lstquestion;
        
        ipsCustomerCaseController1.subject = 'test case';
        ipsCustomerCaseController1.categorySelected = caseCat.id;
        ipsCustomerCaseController1.subCategorySelected = subCategory.Id;
        ipsCustomerCaseController1.validateFilteredEnvironmentDetails();
        ipsCustomerCaseController1.SearchBeforeSubmit();
        test.stopTest();
    }
    
    static testmethod void testSnewwithoutpartion(){
        test.startTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' and name='Admin' Limit 1];
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        User usr = [Select Id,UserRoleId from User where UserRoleId=:portalRole.Id AND profileId=:prof.id AND isactive = true limit 1];
        /*Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
insert cipspro;
UserRecordAccess userAccess=[SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:usr.id AND RecordId=:cipspro.id limit 1];*/
        system.runAs(usr){
            //Create account
            Account portalAccount1 = new Account(
                Name = 'newAcc2',
                BillingCity = 'folsom',
                BillingCountry = 'USA',
                BillingStreet = 'Creek Side Dr'    
            );
            Database.insert(portalAccount1);
            //Create contact
            Contact contact1 = new Contact(
                AccountId = portalAccount1.id,
                FirstName = 'portia',
                LastName  = 'portalTestUser',
                Email='babux5x5@intel.com'      
            );
            Database.insert(contact1);
            Profile p = [select id, name from Profile where name in ('IPS Agent-Partner') limit 1]; 
            User user1=new User(
                username = 'newUser343434@yahoo.com',
                ContactId = contact1.Id,   
                profileId =p.id,   
                email = 'ponneri2525@intel.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                Firstname='BruceS',   
                lastname='lastname2'
            );
            Database.insert(user1);
            system.runAs(user1){
                // Setting the Visualforce Page
                PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
                Test.setCurrentPage(CustomerCaseCreationPage);
                ApexPages.currentPage().getParameters().put('mode','edit');
                Case CaseRecord =  TestUtilities.getCase(); 
                CaseRecord.AccountId=portalAccount1.id;
                CaseRecord.contactid=contact1.id;
                //insert CaseRecord;
                Core_IPS_Deflected_Object__c dfltObj = new Core_IPS_Deflected_Object__c();
                dfltObj.Core_IPS_Status__c='Deflected';
                insert dfltObj;
                System.assertNotEquals(null, dfltObj);
                List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
                String PARTITION_NAME = system.label.Core_IPS_Platform_Cache_Name;
                Cache.Partition  partition = Cache.Session.getPartition(PARTITION_NAME);
                partition.put('caseJson'+dfltObj.id, JSON.serialize(CaseRecord),9000);
                partition.put('EnvResponse'+dfltObj.id, JSON.serialize(lstEnvResponse),9000);
                
                ApexPages.currentPage().getParameters().put('mode','sNew');
                ApexPages.currentPage().getParameters().put('sbs','ccs');
                
                Core_IPS_Customer_Case_Controller  ipsCustomerCaseController1 = new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));  
                ApexPages.currentPage().getParameters().put('mode','iframe');
                ApexPages.currentPage().getParameters().put('sbs','ccs');
                ApexPages.currentPage().getParameters().put('deflectedId',dfltObj.Id);
                ipsCustomerCaseController1.saveCaseDetails();
                Core_IPS_Customer_Case_Controller  ipsCustomerCaseController2= new Core_IPS_Customer_Case_Controller (new ApexPages.StandardController(CaseRecord));
                ApexPages.currentPage().getParameters().put('deflectedId',dfltObj.Id);
            }
        }
        test.stopTest();  
    }
    
}