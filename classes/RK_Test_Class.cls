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
public class RK_Test_Class{
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
    static testmethod void InsertCaseRecordNegativemodesslcRK(){
        test.startTest();
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
        ipsCustomerCaseController.getCountriesOptions();
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
        // lstparQues.add(parQues1);
        insert parQues1;
        
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
        // question.selectedValue='test';
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
        ipsCustomerCaseController1.cs = cs;
        ipsCustomerCaseController1.filteredEnvDetails = lstquestion;
        
        ipsCustomerCaseController1.subject = 'test case';
        ipsCustomerCaseController1.categorySelected = caseCat.id;
        ipsCustomerCaseController1.subCategorySelected = subCategory.Id;
        ipsCustomerCaseController1.validateFilteredEnvironmentDetails();
        ipsCustomerCaseController1.SearchBeforeSubmit();
        test.stopTest();
    }
   
}