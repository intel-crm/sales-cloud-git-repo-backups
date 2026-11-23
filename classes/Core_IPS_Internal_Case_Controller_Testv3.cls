/***************************************************************************************************
Class Name:  Core_IPS_Internal_Case_Controller_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for Core_IPS_Internal_Case_Controllerv2 Apex Class.
When Agent Logs access Case, Agent is directed to Core_IPS_Internal_Case_Creation VF Page and Core_IPS_Internal_Case_Controllerv2 Class is invoked
Description:   This class contains unit test scenarios for Core_IPS_Internal_Case_Controllerv2 Apex Class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       02/02/2016                Created
* Amritesh                  01/19/2018                Modified
****************************************************************************************************/   
@isTest
public class Core_IPS_Internal_Case_Controller_Testv3 {
    //Instance variables that are commonly used in multiple test methods
    static List<User> SysAdminUsr = new List<User> ();
    static List<User> ListOfInternalSfUsers = new List<User> ();
    static List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c> ();
    static List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseCat = new List<Core_IPS_Master_Issue_Category__c>();//Added By Manoj
    static List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseSubCat = new List<Core_IPS_Master_Issue_Category__c>();//Added By Manoj
    static list<Asset> ListOfAssets = new list<Asset> ();
    static Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
    static  Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
    static Core_IPS_Project__c projectcase=new Core_IPS_Project__c();
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
        ListOfInternalSfUsers = TestUtilities.getListOfUser(1);
        ListOfInternalSfUsers.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        ListOfInternalSfUsers.get(0).userroleid = role.id;
        // Creating SETUP OBJECT (USER) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert ListOfInternalSfUsers;
        }
        System.assertEquals(ListOfInternalSfUsers.get(0).profileid, MapOfProfiles.get('System Administrator'));
        
        //Added By Manoj
        Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c(Name='CloseCaseEditPermission',Value__c='System Administrator');
        insert ipsLabel;
        
        // Create Account Record
        List<Account> ListOfAccounts = new List<Account> ();
        Account AccountRec1 = TestUtilities.getAccount();
        AccountRec1.Core_IPS_Active__c = true;
        AccountRec1.ownerid = ListOfInternalSfUsers.get(0).id;
        AccountRec1.Core_Military_Aerospace_and_Government__c = true;
        ListOfAccounts.add(AccountRec1);
        insert ListOfAccounts;
        List<Core_IPS_Labels__c>  LstLabels = TestUtilities.getIPSLabel();
                insert LstLabels;
        System.assert(ListOfAccounts[0].Id != null, 'Account Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        ListOfContacts.get(0).Accountid = ListOfAccounts.get(0).Id;
        ListOfContacts.get(0).Core_IPS_Intel_Support_Owner__c = ListOfInternalSfUsers.get(0).id;
        ListOfContacts.get(0).ownerid = ListOfInternalSfUsers.get(0).id;
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
        ListOfCoreMasterIssueCategory_CaseCat = TestUtilities.getListOfCoreMastIssCategory(1);
        ListOfCoreMasterIssueCategory_CaseCat.get(0).Core_type__c = 'Case Category';
        insert ListOfCoreMasterIssueCategory_CaseCat;
        System.assert(ListOfCoreMasterIssueCategory_CaseCat[0].Id != null, 'Record not Created');
        // Create Core Master Issue Category - Case Sub Category
        ListOfCoreMasterIssueCategory_CaseSubCat = TestUtilities.getListOfCoreMastIssCategory(1);//Changed by Manoj
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
        //added by naresh related to the Test Coverage Story US41854 on 6/10/16
       // projectcase = TestUtilities.getIpsProjectRecord();
       List<Core_IPS_Project__c> projList=new List<Core_IPS_Project__c>();
       //projList= TestUtilities.getListOfIpsProjects(1);
       // insert projList;
        projectcase=ListOfIpsProjects[0];
       // insert projectcase;
                  System.assert(projectcase.Id != null, 'Record not created');
         //end
        
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
        CaseRecord.core_ips_project_case__c=projectcase.id;
                  
        if(tid==1){
            CaseRecord.Core_Severity__c='Critical';
        }
        if(tid!=1){
            insert CaseRecord;
        }
        
		/********commented by amritesh - US8534 *********
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
            
            Core_IPS_Assigned_Environment_Variables__c EnvDetails = TestUtilities.getEnvironmentalDetailsOperational();
            EnvDetails.Core_Environment_Variable__c = ListOfenvVars[4].id;
            EnvDetails.Core_Required__c=true;
            EnvDetails.Core_Status__c = 'Active';
            EnvDetails.Core_Product_Issue_Sub_Category__c = subCategory.Id;
            
            Core _IPS_Assigned_Environment_Variables__c EnvDetails1 = TestUtilities.getEnvironmentalDetailsOperational();
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
        envDetal.Core_Question__c='intel';
        envDetal.Core_Answer__c='TestAnswer1;TestAns2;Testans3';
        envDetal.Core_Case__c = CaseRecord.id;
        
        if(tid!=1){   
            insert envDetal;                
            System.assert(envDetal.Id != null, 'Record not created');}
		*/
        
        //added by amritesh US8534 - start
        List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(8);        
        lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
        insert lstCoreQuestion;
        System.assert(lstCoreQuestion[0].Id != null, 'Record not created');
        
        List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            for(Core_IPS_Answer__c objAns : TestUtilities.getCoreAnswers(2)) {
                objAns.Core_IPS_Question__c = objQues.Id;
                lstAnswer.add(objAns);
            }				
        }
        insert lstAnswer;
        System.assert(lstAnswer[0].Id != null, 'Record not created');
        
        //Creating Environmental Details Operational
        List<Core_IPS_Assigned_Environment_Variables__c> EnvironmentalDetailsList = new List<Core_IPS_Assigned_Environment_Variables__c>();
        for(integer i=0;i<4;i++){
            Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails = TestUtilities.getEnvironmentalDetailsOperational();
            EnvironmentalDetails.Core_IPS_Question__c = lstCoreQuestion[i].id;
            EnvironmentalDetails.Core_Required__c=true;
            EnvironmentalDetails.Core_supported_product__c = ListOfSupportedProduct[0].id;
            EnvironmentalDetailsList.add(EnvironmentalDetails);
        }
        
        for(integer i=4;i<8;i++){
            Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails = TestUtilities.getEnvironmentalDetailsOperational();
            EnvironmentalDetails.Core_IPS_Question__c = lstCoreQuestion[i].id;
            EnvironmentalDetails.Core_Required__c=true;
            EnvironmentalDetails.Core_Product_Issue_Sub_Category__c = subCategory.id;
            EnvironmentalDetailsList.add(EnvironmentalDetails);
        }        
        insert EnvironmentalDetailsList;
        System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
        
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
    static testmethod void InsertCaseRecord(){
        getRecords(1);
        //CaseRecord = new Case(); Commented By Manoj
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
         system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Contact';
        ipsInternalCaseController.LookupChange();  
        ipsInternalCaseController.clearProject();
        ipsInternalCaseController.getCountriesOptions();
        ipsInternalCaseController.contactClear();
        ipsInternalCaseController.getEnvironmentOptions();
        ipsInternalCaseController.cs = CaseRecord;//Added By Manoj
        ipsInternalCaseController.categorySelected = caseCat.id;//Added By Manoj
        ipsInternalCaseController.subCategorySelected = subCategory.Id;//Added By Manoj
        ipsInternalCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsInternalCaseController.envDetails+'----SubEnv Details---'+ipsInternalCaseController.subCatenvDetList);
        List<SelectOption> options = new List<SelectOption>();
        
        List<Core_IPS_EnvironmentDetailQuestion> eq = new List<Core_IPS_EnvironmentDetailQuestion>();
        //System.assertEquals(ipsInternalCaseController.envDetails, eq);
        ipsInternalCaseController.envDetails[0].selectedValue= ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue();
        ipsInternalCaseController.GECAnswer1='Yes';
        List<String> val= new List<String>();
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(0).getValue());
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(1).getValue());
        ipsInternalCaseController.envDetails[3].selectedMValue = val;
        ipsInternalCaseController.validateEnvironmentDetails();//Added By Manoj
        /*ipsInternalCaseController.showGECFields = True;  //added by Abhishek
    	ipsInternalCaseController.GECAnswer2 ='Yes'; //added  by Abhishek
        ipsInternalCaseController.GECAnswer1 ='Yes';*/ //added by Abhishek
        ipsInternalCaseController.renderErrorFlag = True; 
        ipsInternalCaseController.saveCaseDetails(); //Added By Manoj
        System.RunAs(ListOfInternalSfUsers.get(0)){
            ipsInternalCaseController.checkcloseCaseEditPermission(); //Added By Manoj
        }
        ipsInternalCaseController.clearEnvDetails();
        ipsInternalCaseController.errormessage('I100');
        ipsInternalCaseController.rerenderGECFieldsToIntUsrsForMAGAcc();
        ipsInternalCaseController.resetProduct();
        ipsInternalCaseController.DisplayPriorityReason();
        ipsInternalCaseController.BindEvent();
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
        System.RunAs(ListOfInternalSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Contact';
              system.debug('envDetails - ' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.GECAnswer2 ='Yes';
        ipsInternalCaseController.GECAnswer3 ='Yes';
        ipsInternalCaseController.GECAnswer1 ='Yes';
            ipsInternalCaseController.showGECFields = True; //added by ABhishek
        ipsInternalCaseController.addGECRecords();
        ipsInternalCaseController.LookupChange(); 
        ipsInternalCaseController.getEnvDetails();
        ipsInternalCaseController.saveCaseDetails();
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
    ***************************************************************************************************/
    static testmethod void testLookupChange(){
        getRecords(1);
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        system.debug('envDetails - ' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.LookupChange(); 
        ipsInternalCaseController.getEnvDetails();
    }
    
    static testmethod void InsertCaseRecord_editObjWithSAP(){
        getRecords(4);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Contact';
        system.debug('envDetails - 1' + ipsInternalCaseController.envDetails);
            
        ipsInternalCaseController.LookupChange();
        ipsInternalCaseController.getEnvDetails();
        ipsInternalCaseController.showGECFields = true; 
        ipsInternalCaseController.saveCaseDetails();
        } 
    }
    
    static testmethod void InsertCaseRecords(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfInternalSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        
        ipsInternalCaseController.LookupChange();  
        ipsInternalCaseController.getEnvDetails();
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.categorySelected=caseCat.id;
        ipsInternalCaseController.subCategorySelected= subCategory.id;
        ipsInternalCaseController.envDetails[0].selectedValue = ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue();
        ipsInternalCaseController.GECAnswer1='Yes';
        List<String> val= new List<String>();
        //val.add(ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue());
        //ipsInternalCaseController.envDetails[2].selectedMValue=val;
        ipsInternalCaseController.saveCaseDetails();
       }
    }
    static testmethod void InsertCaseRecords1(){
        getRecords(1);
        //CaseRecord.Core_Case_Issue_Category__c = null;
        CaseRecord.Core_IPS_Supported_Product__c= null;
        System.RunAs(ListOfInternalSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',string.valueOF(RT.Id).substring(0,15));
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        
        ipsInternalCaseController.LookupChange();  
        ipsInternalCaseController.getEnvDetails();
             system.debug('CaseRecord -- ' + CaseRecord);
         system.debug('envDetails - 4' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.categorySelected=caseCat.id;
        ipsInternalCaseController.subCategorySelected= subCategory.id;
        ipsInternalCaseController.envDetails[0].selectedValue = ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue();
            ipsInternalCaseController.GECAnswer1='Yes';
            List<String> val= new List<String>();
            //val.add('test');
            //val.add('test1');
			val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(0).getValue());
			val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(1).getValue());
        ipsInternalCaseController.envDetails[3].selectedMValue=val;
        ipsInternalCaseController.saveCaseDetails();
        ipsInternalCaseController.pageInit();
       }
    }
       
    
    static testmethod void cancelAction(){   
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getHeaders().put('referer','test');
        ApexPages.currentPage().getParameters().put('retURL','test');
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.CancelAction();
    }
    static testmethod void validateEnvironmentDetails1(){       
         getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
         Test.startTest();
        // // Setting the Visualforce Page
         PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
         Test.setCurrentPage(InternalCaseCreationPage);
        // // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        // //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
         RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
         ApexPages.currentPage().getParameters().put('rType',RT.Id);
         ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
         ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.getEnvDetails();
        system.debug('envDetails - 4' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.envDetails[0].type='Text';
        ipsInternalCaseController.envDetails[0].sPlaceHolder='';
        ipsInternalCaseController.envDetails[0].required=true;
        ipsInternalCaseController.validateEnvironmentDetails();
        Test.stopTest();
       }
    }
    static testmethod void validateEnvironmentDetails2(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.getEnvDetails();
        system.debug('envDetails - 4' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.envDetails[0].selectedValue = ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue();
        ipsInternalCaseController.envDetails[1].type='Text';
        ipsInternalCaseController.envDetails[1].sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        ipsInternalCaseController.envDetails[1].required=true;
        ipsInternalCaseController.validateEnvironmentDetails();
        Test.stopTest();
       }
    }
    static testmethod void validateEnvironmentDetails3(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.getEnvDetails();
        system.debug('envDetails - 4' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.envDetails[0].selectedValue = ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue();
        ipsInternalCaseController.envDetails[2].type='Text Area';
        ipsInternalCaseController.envDetails[2].tPlaceHolder='';
        ipsInternalCaseController.envDetails[2].required=true;
        ipsInternalCaseController.validateEnvironmentDetails();
        Test.stopTest();
       }
    }
    static testmethod void validateEnvironmentDetails4(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.getEnvDetails();
        ipsInternalCaseController.envDetails[0].type = 'Picklist';
        ipsInternalCaseController.envDetails[0].selectedValue = '';
        ipsInternalCaseController.envDetails[0].required = true;
        ipsInternalCaseController.validateEnvironmentDetails();
        Test.stopTest();
       }
    }
    static testmethod void validateEnvironmentDetails5(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.getEnvDetails();
        ipsInternalCaseController.envDetails[0].selectedValue = ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue();
        ipsInternalCaseController.envDetails[3].type='Multiselect Picklist';
        ipsInternalCaseController.envDetails[3].selectedMValue = null;
        ipsInternalCaseController.envDetails[3].required=true;
        ipsInternalCaseController.validateEnvironmentDetails();
        Test.stopTest();
       }
    }
    static testmethod void validateCaseRelatedInformation1(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.categorySelected = '';
        ipsInternalCaseController.validateCaseRelatedInformation();
        Test.stopTest();
       }
    }
    static testmethod void validateCaseRelatedInformation2(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.categorySelected = 'sadsd';
        ipsInternalCaseController.subCategorySelected = '';
        ipsInternalCaseController.validateCaseRelatedInformation();
        Test.stopTest();
       }
    }
    static testmethod void validateCaseRelatedInformation3(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        CaseRecord.Subject = '';
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.categorySelected = 'sadsd';
        ipsInternalCaseController.subCategorySelected = 'sdsa';
        //ipsInternalCaseControllercs.cs.Subject = '';
        ipsInternalCaseController.validateCaseRelatedInformation();
        Test.stopTest();
       }
    }
    static testmethod void validateCaseRelatedInformation4(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        
        CaseRecord.Subject = 'sdsad';
        CaseRecord.Core_Issue_Description__c = '';
        
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.categorySelected = 'sadsd';
        ipsInternalCaseController.subCategorySelected = 'sdsa';
        
        ipsInternalCaseController.validateCaseRelatedInformation();
        Test.stopTest();
       }
    }
    static testmethod void validateCaseRelatedInformation5(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        CaseRecord.Subject = 'sdsad';
        CaseRecord.Core_Issue_Description__c = 'dasadsa';
        CaseRecord.Core_Severity__c='';
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.categorySelected = 'sadsd';
        ipsInternalCaseController.subCategorySelected = 'sdsa';
        
        ipsInternalCaseController.validateCaseRelatedInformation();
        Test.stopTest();
       }
    }
    static testmethod void validateCaseRelatedInformation6(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        CaseRecord.Subject = 'sdsad';
        CaseRecord.Core_Issue_Description__c = 'dasadsa';
        CaseRecord.Core_Severity__c='Medium';
        CaseRecord.Core_CaseType__c ='';
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.categorySelected = 'sadsd';
        ipsInternalCaseController.subCategorySelected = 'sdsa';
        
        
        ipsInternalCaseController.validateCaseRelatedInformation();
            
        Test.stopTest();
       }
    }
  //added by naresh related to the Test Coverage Story US41854 on 6/6/16
     static testmethod void validateEnvironmentDetails7(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.getEnvDetails();
        ipsInternalCaseController.envDetails[0].selectedValue = ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue();
        ipsInternalCaseController.envDetails[3].type='Multiselect Picklist';
        ipsInternalCaseController.envDetails[3].selectedMValue = null;
        ipsInternalCaseController.envDetails[3].required=true;
        ipsInternalCaseController.getEnvironmentOptions();
        Test.stopTest();
       }
    }
    static testmethod void validateEnvironmentDetails8(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creationv2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controllerv2 Apex Class
        Core_IPS_Internal_Case_Controllerv2 ipsInternalCaseController = new Core_IPS_Internal_Case_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.getEnvDetails();
        system.debug('envDetails - 4' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.envDetails[0].selectedValue = ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue();
        ipsInternalCaseController.envDetails[2].type='Text Area';
        ipsInternalCaseController.envDetails[2].tPlaceHolder='';
        ipsInternalCaseController.envDetails[2].tPlaceHolder='Testing'.leftPad(5100,'g');
        ipsInternalCaseController.envDetails[2].required=true;
        ipsInternalCaseController.envDetails[2].cplaceholder=true;    
        ipsInternalCaseController.validateEnvironmentDetails();
        Test.stopTest();
       }
    }
  }