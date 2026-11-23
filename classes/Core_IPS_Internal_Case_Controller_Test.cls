/***************************************************************************************************
Class Name:  Core_IPS_Internal_Case_Controller_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for Core_IPS_Internal_Case_Controller Apex Class.
When Agent Logs access Case, Agent is directed to Core_IPS_Internal_Case_Creation VF Page and Core_IPS_Internal_Case_Controller Class is invoked
Description:   This class contains unit test scenarios for Core_IPS_Internal_Case_Controller Apex Class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       02/02/2016                Created
* Amritesh                  01/19/2018                Modified
****************************************************************************************************/   
@isTest
public class Core_IPS_Internal_Case_Controller_Test {
    //Instance variables that are commonly used in multiple test methods
    static List<User> SysAdminUsr = new List<User> ();
    static List<User> ListOfInternalSfUsers = new List<User> ();
    static List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c> ();
    static List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseCat = new List<Core_IPS_Master_Issue_Category__c>();//Added By Manoj
    static List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseSubCat = new List<Core_IPS_Master_Issue_Category__c>();//Added By Manoj
    static list<Asset> ListOfAssets = new list<Asset> ();
    static List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = new List<Core_IPS_Supported_Product__c>();
    static Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
    static  Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
    static Core_IPS_Project__c projectcase=new Core_IPS_Project__c();
    static Case CaseRecord = new Case();
    static Case CaseRecordSA = new Case();
    static case caseRecordSA2 = new Case();//Ashutosh - US106566 
    static Case CaseRecord1 = new Case();
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
    * Amritesh                  01/19/2018                Modified
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
        ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
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
        CaseRecord1 = new Case ();//added by sugandha for PSA PSO
        CaseRecord.AccountId=ListOfAccounts.get(0).Id;
        CaseRecord1.AccountId=ListOfAccounts.get(0).Id;
        if(tid!=3){
            if(tid!=4) {
                CaseRecord.AssetId=ListOfAssets.get(0).Id;
                CaseRecord1.AssetId=ListOfAssets.get(0).Id;
            }
            CaseRecord.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
            CaseRecord1.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
        }
        CaseRecord.ContactId=ListOfContacts.get(0).id;  
        CaseRecord1.ContactId=ListOfContacts.get(0).id;        
        CaseRecord.Core_IPS_Product_Org1__c=ListOfSupportOrg.get(0).id;
        CaseRecord1.Core_IPS_Product_Org1__c=ListOfSupportOrg.get(0).id;
        CaseRecord.Core_Case_Issue_Category__c = caseCat.id;
        CaseRecord1.Core_Case_Issue_Category__c = caseCat.id;
        CaseRecord.Core_case_issue_sub_category__c = subCategory.id;
        CaseRecord1.Core_case_issue_sub_category__c = subCategory.id;
        CaseRecord.Core_Issue_Description__c = 'test';
        CaseRecord1.Core_Issue_Description__c = 'test';
        CaseRecord.Subject='TestSubject';
        CaseRecord1.Subject='TestSubject';
        CaseRecord.Core_CaseType__c='Issue';
        CaseRecord.Core_IPS_Issue_source__c='n/a';
        CaseRecord1.Core_CaseType__c='Issue';
        CaseRecord1.Core_IPS_Issue_source__c='n/a';
        CaseRecord.core_ips_project_case__c=projectcase.id;
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        CaseRecord.recordTypeId = RT.Id;
        CaseRecord1.recordTypeId = RT.Id;
        RecordType RT2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        CaseRecordSA = CaseRecord.clone(false,true);
        CaseRecordSA.RecordTypeId = RT2.Id;
        
        if(tid==1){
            CaseRecord.Core_Severity__c='Critical';
            CaseRecord1.Core_Severity__c='Critical';
        }
        if(tid!=1){
            insert CaseRecord;
            insert CaseRecordSA;
            insert CaseRecord1;
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
        List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(9);    
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            objQues.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).id;
        }
        lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[6].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[4].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[7].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[8].Core_IPS_Datatype__c = 'Multiselect Picklist';
        
        insert lstCoreQuestion;
        System.assert(lstCoreQuestion[0].Id != null, 'Record not created');
        
        lstCoreQuestion[4].Core_IPS_Parent_Question__c = lstCoreQuestion[2].Id;
        update lstCoreQuestion[4];
        
        List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Ans = new Map<Id,List<Core_IPS_Answer__c>>();
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            mapQuesId2Ans.put(objQues.Id,new List<Core_IPS_Answer__c>());
            for(Core_IPS_Answer__c objAns : TestUtilities.getCoreAnswers(2)) {
                objAns.Core_IPS_Question__c = objQues.Id;
                lstAnswer.add(objAns);
                mapQuesId2Ans.get(objQues.Id).add(objAns);
            }               
        }
               
        insert lstAnswer;
        System.assert(lstAnswer[0].Id != null, 'Record not created');
        
        mapQuesId2Ans.get(lstCoreQuestion[4].Id)[0].Core_IPS_Parent_Answer__c = mapQuesId2Ans.get(lstCoreQuestion[2].Id)[0].Id;
        mapQuesId2Ans.get(lstCoreQuestion[4].Id)[1].Core_IPS_Parent_Answer__c = mapQuesId2Ans.get(lstCoreQuestion[2].Id)[1].Id;
        lstAnswer = new List<Core_IPS_Answer__c>{mapQuesId2Ans.get(lstCoreQuestion[4].Id)[0], mapQuesId2Ans.get(lstCoreQuestion[4].Id)[1]};
        update lstAnswer;
            
        //Creating Environmental Details Operational
        List<Core_IPS_Assigned_Environment_Variables__c> EnvironmentalDetailsList = new List<Core_IPS_Assigned_Environment_Variables__c>();
        for(integer i=0;i<5;i++){
            Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails = TestUtilities.getEnvironmentalDetailsOperational();
            EnvironmentalDetails.Core_IPS_Question__c = lstCoreQuestion[i].id;
            EnvironmentalDetails.Core_Required__c=true;
            //Added by karthick - US113683
            if(i==3){
                EnvironmentalDetails.Core_Agent_Only__c = true;
            }
            EnvironmentalDetails.Core_supported_product__c = ListOfSupportedProduct[0].id;
            EnvironmentalDetailsList.add(EnvironmentalDetails);
        }
        
        for(integer i=5;i<9;i++){
            Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails = TestUtilities.getEnvironmentalDetailsOperational();
            EnvironmentalDetails.Core_IPS_Question__c = lstCoreQuestion[i].id;
            EnvironmentalDetails.Core_Required__c=false;
            //Added by karthick - US113683
            if(i==7){
                EnvironmentalDetails.Core_Agent_Only__c = true;
            }
            EnvironmentalDetails.Core_Product_Issue_Sub_Category__c = subCategory.id;
            EnvironmentalDetailsList.add(EnvironmentalDetails);
        }        
        insert EnvironmentalDetailsList;
        System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
        //added by amritesh US8534 - end
        
        List<Core_IPS_Error_Code__c> errorCodes= TestUtilities.getListOfIpsErrorCodes();
        insert errorCodes;
        System.assert(errorCodes[0].Id != null, 'Record not created');
    }
    
    static void insertCoreResponse(Id caseId) {
        List<Core_IPS_Response__c> lstResponse = new List<Core_IPS_Response__c>();
        for(Core_IPS_Question__c objQues : [SELECT Id,Core_IPS_Datatype__c,(SELECT Id, Core_IPS_Answer__c FROM Core_Answers__r LIMIT 1) FROM Core_IPS_Question__c]) {
            for(Core_IPS_Answer__c objAns : objQues.Core_Answers__r) {
                Core_IPS_Response__c objResponse = new Core_IPS_Response__c();
                objResponse.Core_IPS_Case__c = caseId;
                if(String.isNotBlank(objQues.Core_IPS_Datatype__c) && String.valueOf(objQues.Core_IPS_Datatype__c).contains('Picklist')){
                    objResponse.Core_IPS_Answer_Master__c = objAns.Id;
                }
                objResponse.Core_IPS_Question_Master__c = objQues.Id;
                objResponse.Core_IPS_Answer__c = objAns.Core_IPS_Answer__c;
                lstResponse.add(objResponse);
            }
        }
        insert lstResponse;
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
    * Syed Moosa Nazir TN       02/02/2016               Created
    * Amritesh                  01/19/2018               Modified
    ***************************************************************************************************/
    static testmethod void InsertCaseRecord(){
        getRecords(1);
        //CaseRecord = new Case(); Commented By Manoj
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');        
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        //system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        //system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        /*ApexPages.currentPage().getParameters().put('accountId', ListOfAccounts.get(0).Id);
        Core_IPS_Account__c projacc= new Core_IPS_Account__c();
        projacc.Core_Account__c = ListOfAccounts.get(0).Id;
        projacc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        insert projacc;
        System.debug('projacc-->'+projacc);*/
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
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
        //Added by karthick - US113683
        if(ipsInternalCaseController.envDetails[0] !=null && ipsInternalCaseController.envDetails[0].pplaceholder !=null )
            ipsInternalCaseController.envDetails[0].selectedValue = ipsInternalCaseController.envDetails[0].pplaceholder.get(1).getValue();
        ipsInternalCaseController.GECAnswer1='Yes';
        List<String> val= new List<String>();
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(0).getValue());
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(1).getValue());
        ipsInternalCaseController.envDetails[3].selectedMValue = val;
        ipsInternalCaseController.validateEnvironmentDetails();//Added By Manoj
        //ipsInternalCaseController.showGECFields = True;  //added by Abhishek
        //ipsInternalCaseController.GECAnswer2 ='Yes'; //added  by Abhishek
        //ipsInternalCaseController.GECAnswer1 ='Yes'; //added by Abhishek
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
        
        ipsInternalCaseController.selectedProductId = ListOfAssets.get(0).Id;
        ipsInternalCaseController.getEnvironmentOptions();
    }
    
    static testmethod void InsertCaseRecord_selfAssigned(){
        getRecords(1);
        //CaseRecord = new Case(); Commented By Manoj
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');        
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        //ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        //ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecordSA));
        ipsInternalCaseController.objectSelected = 'Product';
        ipsInternalCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsInternalCaseController.LookupChange();  
        ipsInternalCaseController.clearProject();
        ipsInternalCaseController.getCountriesOptions();
        ipsInternalCaseController.contactClear();
        ipsInternalCaseController.getEnvironmentOptions();
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.categorySelected = caseCat.id;
        ipsInternalCaseController.subCategorySelected = subCategory.Id;
        ipsInternalCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsInternalCaseController.envDetails+'----SubEnv Details---'+ipsInternalCaseController.subCatenvDetList);
        //Added by karthick - US113683
        if(ipsInternalCaseController.envDetails[0] !=null && ipsInternalCaseController.envDetails[0].pplaceholder !=null )
            ipsInternalCaseController.envDetails[0].selectedValue= ipsInternalCaseController.envDetails[0].pplaceholder.get(0).getValue();
        ipsInternalCaseController.GECAnswer1='Yes';
        List<String> val= new List<String>();
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(0).getValue());
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(1).getValue());
        ipsInternalCaseController.envDetails[3].selectedMValue = val;
        ipsInternalCaseController.validateEnvironmentDetails();
        ipsInternalCaseController.renderErrorFlag = True; 
        ipsInternalCaseController.saveCaseDetails();
        System.RunAs(ListOfInternalSfUsers.get(0)){
            ipsInternalCaseController.checkcloseCaseEditPermission();
        }
        ipsInternalCaseController.clearEnvDetails();
        ipsInternalCaseController.errormessage('I100');
        ipsInternalCaseController.rerenderGECFieldsToIntUsrsForMAGAcc();
        ipsInternalCaseController.resetProduct();
        ipsInternalCaseController.DisplayPriorityReason();
        ipsInternalCaseController.BindEvent();
        
    }
    
    /***************************************************************************************************
    Method Name:  EditCase
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
    *  Amritesh                 01/19/2018               Modified
    ****************************************************************************************************/
    static testmethod void EditCase(){
        getRecords(3);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
         
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
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
    
    static testmethod void EditCase2() {
        getRecords(3);
        System.RunAs(ListOfInternalSfUsers.get(0)){
            insertCoreResponse(CaseRecord.Id);
            // Setting the Visualforce Page
            PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
            Test.setCurrentPage(InternalCaseCreationPage);
            ApexPages.currentPage().getParameters().put('mode','edit');
            ApexPages.currentPage().getParameters().put('id', CaseRecord.Id);
            CaseRecord.AssetId = ListOfAssets.get(0).Id;
            CaseRecord.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).Id;
            update CaseRecord;
            Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));                        
            
            /*ipsInternalCaseController.projectList;
            ipsInternalCaseController.selectedProject;
            ipsInternalCaseController.supProduct;
            ipsInternalCaseController.displayForCust;*/
        } 
    }
    
    /***************************************************************************************************
    Method Name:  EditCase_SA
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 08 Feb 2016
    Description:  Creating Case Record by Clicking "NEW CASE" field in "Edit OBJECT" with Self Assigned 
    Input Parameter in URL : mode=edit, productId
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Ekbote           08/02/2016                 Created
    * Amritesh                  01/19/2018               Modified
    ****************************************************************************************************/
    static testmethod void EditCase_SA(){
        getRecords(4);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        //ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecordSA));
        ipsInternalCaseController.objectSelected = 'Contact';
        system.debug('envDetails - 1' + ipsInternalCaseController.envDetails);
            
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
    * Amritesh                  01/19/2018               Modified
    ***************************************************************************************************/
    static testmethod void testLookupChange(){
        getRecords(1);
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Product';
        system.debug('envDetails - ' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.LookupChange();
        ipsInternalCaseController.getEnvDetails();
        
    }
    
    
    static testmethod void cancelAction(){   
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getHeaders().put('referer','test');
        ApexPages.currentPage().getParameters().put('retURL','test');
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.PageInit();
        ipsInternalCaseController.CancelAction();
    }
    
    //modified by amritesh US8534
    static testmethod void validateEnvironmentDetails(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
            Test.startTest();
            // Setting the Visualforce Page
            PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
            Test.setCurrentPage(InternalCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
            ipsInternalCaseController.objectSelected ='Product';
            ipsInternalCaseController.cs = CaseRecord;
            ipsInternalCaseController.getEnvDetails();
            ipsInternalCaseController.envDetails[0].type='Multiselect Picklist';
            ipsInternalCaseController.envDetails[0].selectedMValue = null;
            ipsInternalCaseController.envDetails[0].required = true;
            ipsInternalCaseController.validateEnvironmentDetails();
            
            ipsInternalCaseController.envDetails[0].type='Picklist';
            ipsInternalCaseController.envDetails[0].selectedValue = '';
            ipsInternalCaseController.validateEnvironmentDetails();
            
            ipsInternalCaseController.envDetails[0].type='Text Area';
            ipsInternalCaseController.envDetails[0].tPlaceHolder = 'Test'.leftPad(5100,'g');
            ipsInternalCaseController.validateEnvironmentDetails();
            
            ipsInternalCaseController.envDetails[0].type='Text Area';
            ipsInternalCaseController.envDetails[0].tPlaceHolder = '';
            ipsInternalCaseController.validateEnvironmentDetails();
            
            ipsInternalCaseController.envDetails[0].type='Text';
            ipsInternalCaseController.envDetails[0].sPlaceHolder = 'Test'.leftPad(260,'g');
            ipsInternalCaseController.validateEnvironmentDetails();
            
            ipsInternalCaseController.envDetails[0].type='Text';
            ipsInternalCaseController.envDetails[0].sPlaceHolder = '';
            ipsInternalCaseController.validateEnvironmentDetails();
            
            Test.stopTest();
        }
    }
    
    //modified by amritesh US8534
    static testmethod void validateCaseRelatedInformation(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
            Test.startTest();
            // Setting the Visualforce Page
            PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
            Test.setCurrentPage(InternalCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            //ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
            ipsInternalCaseController.objectSelected ='Product';
            ipsInternalCaseController.cs = CaseRecord;
            List<SelectOption> lstOptions = new List<SelectOption>{ new SelectOption('1','1'), new SelectOption('2','2')};
                
            ipsInternalCaseController.categoryOptions = lstOptions;
            ipsInternalCaseController.subCategoryOptions = lstOptions;
            ipsInternalCaseController.categorySelected = '1';
            ipsInternalCaseController.subCategorySelected = '1';
            ipsInternalCaseController.cs.Subject = 'Test Subject';
            ipsInternalCaseController.cs.Core_Issue_Description__c = 'Test Description';
            ipsInternalCaseController.cs.Core_Severity__c  = 'Test Severity';
            ipsInternalCaseController.cs.Core_CaseType__c = 'Test Case Type';
            //Added by karthick - defect fix DE40206 - 20/06/2018
            ipsInternalCaseController.cs.Core_IPS_Issue_source__c = 'n/a';
                
            ipsInternalCaseController.platformOptions = lstOptions;
            ipsInternalCaseController.platformSelected = null;
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            //Added by karthick - defect fix DE40206 - 20/06/2018
            ipsInternalCaseController.cs.Core_IPS_Issue_source__c = '';
            ipsInternalCaseController.cs.Core_CaseType__c = 'Test Case Type';
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            ipsInternalCaseController.cs.Core_IPS_Issue_source__c = 'n/a';
            ipsInternalCaseController.cs.Core_CaseType__c = null;
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            ipsInternalCaseController.cs.Core_Severity__c  = null;
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            ipsInternalCaseController.cs.Core_Issue_Description__c = null;
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            ipsInternalCaseController.cs.Subject = null;
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            ipsInternalCaseController.subCategorySelected = '';
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            ipsInternalCaseController.categorySelected = '';
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            Test.stopTest();
        }
    }
    
    //modified by amritesh US8534
    static testmethod void validateInternalCase(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)) {
            Test.startTest();
            // Setting the Visualforce Page
            PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
            Test.setCurrentPage(InternalCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            //ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
            ipsInternalCaseController.objectSelected ='Product';
            ipsInternalCaseController.cs = CaseRecord;
            ipsInternalCaseController.selectedProductId = null;
            ipsInternalCaseController.selectedContactId = null;
            
            ipsInternalCaseController.DisplayPriorityReason = true;
            ipsInternalCaseController.cs.Core_Severity_Reason__c = '';
            ipsInternalCaseController.validateInternalCase();
            
            ipsInternalCaseController.selectedContactId = '';
            ipsInternalCaseController.validateInternalCase();
            
            ipsInternalCaseController.selectedProductId = '';
            ipsInternalCaseController.validateInternalCase();
            
            ipsInternalCaseController.caseTypeSelected = 'selfAssigned';            
            ipsInternalCaseController.DisplayPriorityReason = true;
            ipsInternalCaseController.cs.Core_Severity_Reason__c = '';
            ipsInternalCaseController.validateInternalCase();
            
            ipsInternalCaseController.selectedSAProductId = '';
            ipsInternalCaseController.validateInternalCase();
        }
    }
    
    //added by sugandha 
    static testmethod void validatePSAPSO(){
        getRecords(1);    
        Account AccountRec1 = TestUtilities.getAccount();
        System.RunAs(ListOfInternalSfUsers [0]){
            AccountRec1.Name = 'DellProducts2';
            AccountRec1.BillingCity = 'Mumbai';
            AccountRec1.BillingCountry = 'USA';
            AccountRec1.billingState = 'AK';
            AccountRec1.billingStreet = 'Bratislava 1';
            insert AccountRec1;
        }
        Contact contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = AccountRec1.id;
        contactRecord.Email = 'Test.con@gmail.com';
        System.RunAs(ListOfInternalSfUsers[0]){
        insert contactRecord;}
          
        System.RunAs(ListOfInternalSfUsers.get(0)) {
            
            Test.startTest();
            // Setting the Visualforce Page
            PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
            Test.setCurrentPage(InternalCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            //ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord1));
            ipsInternalCaseController.objectSelected ='Project';
            ipsInternalCaseController.cs = CaseRecord1; 
            ipsInternalCaseController.selectedPSOId = UserInfo.getUserId();
            ipsInternalCaseController.displayPSO = true;      
            ipsInternalCaseController.selectedContactId = contactRecord.Id;
            ipsInternalCaseController.selectedContact = contactRecord.Id;
            ipsInternalCaseController.projSelected =ListOfIpsProjects.get(0).Id;
            ipsInternalCaseController.DisplayPSAPSO();
            ipsInternalCaseController.LookupChange();
            ipsInternalCaseController.projSelected ='';
            ipsInternalCaseController.projSelected_Old=ListOfIpsProjects.get(0).Id;
            ipsInternalCaseController.LookupChange();
            ipsInternalCaseController.isResetProductRelInfo=true;
            ipsInternalCaseController.selectedSupProduct_Old=ListOfIpsProjects.get(0).Id;
            ipsInternalCaseController.LookupChange();
        }
    }
    static testmethod void validatePSAPSO1(){
        getRecords(1);    
        Account AccountRec1 = TestUtilities.getAccount();
        System.RunAs(ListOfInternalSfUsers [0]){
            AccountRec1.Name = 'DellProducts2';
            AccountRec1.BillingCity = 'Mumbai';
            AccountRec1.BillingCountry = 'USA';
            AccountRec1.billingState = 'AK';
            AccountRec1.billingStreet = 'Bratislava 1';
            insert AccountRec1;
        }
        Contact contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = AccountRec1.id;
        contactRecord.Email = 'Test.con@gmail.com';
        System.RunAs(ListOfInternalSfUsers[0]){
        insert contactRecord;}
            
        System.RunAs(ListOfInternalSfUsers.get(0)) {
            Test.startTest();
            // Setting the Visualforce Page
            PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
            Test.setCurrentPage(InternalCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
            //ipsInternalCaseController.objectSelected ='Product';
            ipsInternalCaseController.cs = CaseRecord;
            ipsInternalCaseController.displayPSO = true;
            ipsInternalCaseController.DisplayPSAPSO();
            //start
            Asset a = new Asset(Id=ListOfAssets.get(0).Id, Core_IPS_Project__c= ListOfIpsProjects.get(0).Id);
            update a;
            ipsInternalCaseController.selectedProductId = a.id;
            ipsInternalCaseController.PopulateAssetProj();
        }
    }
    /*Ashutosh - US106566*/
    static testMethod  void testProjectBasedNAC(){
        getRecords(1);
        
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');        
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecordSA));
       ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.selectedProductId = null;
        ipsInternalCaseController.selectedContactId = null;
        ipsInternalCaseController.selectedSAProductId = ListOfAssets.get(0).Id;
        ipsInternalCaseController.LookupChange(); 
        ipsInternalCaseController.getEnvDetails();
        
        ipsInternalCaseController.objectSelected = 'Product';
        ipsInternalCaseController.selectedSAProductId = ListOfSupportedProduct.get(0).Id;
        ipsInternalCaseController.LookupChange();  
        ipsInternalCaseController.clearProject();
        ipsInternalCaseController.getCountriesOptions();
        ipsInternalCaseController.contactClear();
        ipsInternalCaseController.getEnvironmentOptions();
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.categorySelected = caseCat.id;
        ipsInternalCaseController.subCategorySelected = subCategory.Id;
        ipsInternalCaseController.getEnvironmentDets();
        system.debug('envDetails - 4' + ipsInternalCaseController.envDetails+'----SubEnv Details---'+ipsInternalCaseController.subCatenvDetList);
        //Added by karthick - US113683
        if(ipsInternalCaseController.envDetails[0] !=null && ipsInternalCaseController.envDetails[0].pplaceholder !=null )
            ipsInternalCaseController.envDetails[0].selectedValue= ipsInternalCaseController.envDetails[0].pplaceholder.get(0).getValue();
        ipsInternalCaseController.GECAnswer1='Yes';
        List<String> val= new List<String>();
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(0).getValue());
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(1).getValue());
        ipsInternalCaseController.envDetails[3].selectedMValue = val;
        ipsInternalCaseController.validateEnvironmentDetails();
        ipsInternalCaseController.renderErrorFlag = True; 
        ipsInternalCaseController.saveCaseDetails();
        
    }
    
    static testmethod void CopyCase() {
        getRecords(3);
        System.RunAs(ListOfInternalSfUsers.get(0)){
            insertCoreResponse(CaseRecord.Id);
            // Setting the Visualforce Page
            PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
            Test.setCurrentPage(InternalCaseCreationPage);
            ApexPages.currentPage().getParameters().put('mode','copy');
            ApexPages.currentPage().getParameters().put('id', CaseRecord.Id);
            CaseRecord.AssetId = ListOfAssets.get(0).Id;
            CaseRecord.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).Id;
            Core_IPS_Case_Interested_Party__c ip=new Core_IPS_Case_Interested_Party__c();
            ip.User__c=ListOfInternalSfUsers.get(0).Id;
            ip.Active__c=true;
            ip.Type__c='Internal';
            ip.Case__c=CaseRecord.Id;
            insert ip;
            update CaseRecord;
            
            Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));                        
            //ipsInternalCaseController.showGECFields=true;
            /*Boolean val=ipsInternalCaseController.validateGecDetails();
            ipsInternalCaseController.copyInterestedParties();*/
            ipsInternalCaseController.copyInterestedParties();
            ipsInternalCaseController.saveCaseDetails();
            ipsInternalCaseController.cancelProductRelInfo();
        } 
    }
    
    /***************************************************************************************************
    Method Name: copyGEC_MAG_Case
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 08 Oct 2018
    Description:  Creating Case Record by Clicking "Copy" button
    Input Parameter in URL : mode=copy, productId and projectId, GEC details
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    *  Gourav                 10/08/2018                 Created
    ****************************************************************************************************/
    static testmethod void copyGEC_MAG_Case(){
        getRecords(3);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','copy');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
         
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Contact';
              system.debug('envDetails - ' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.showGECFields = True;
        ipsInternalCaseController.GECAnswer1 ='Yes';
        ipsInternalCaseController.GECAnswer2 ='Yes';
        ipsInternalCaseController.GECAnswer3 ='Argentina';
        ipsInternalCaseController.addGECRecords();
        ipsInternalCaseController.LookupChange(); 
        ipsInternalCaseController.getEnvDetails();
        ipsInternalCaseController.saveCaseDetails();
        } 
    }
    
    /***************************************************************************************************
    Method Name: copyNonGEC_MAG_Case
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 08 Oct 2018
    Description:  Creating Case Record by Clicking "Copy" button
    Input Parameter in URL : mode=copy, productId and projectId, GEC details
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    *  Gourav                 10/08/2018                 Created
    ****************************************************************************************************/
    static testmethod void copyNonGEC_MAG_Case(){
        getRecords(3);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','copy');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
         
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.objectSelected ='Contact';
              system.debug('envDetails - ' + ipsInternalCaseController.envDetails);
        ipsInternalCaseController.showGECFields = True;
        ipsInternalCaseController.GECAnswer1 ='No';
        ipsInternalCaseController.GECAnswer2 ='No';
        ipsInternalCaseController.GECAnswer3 ='Argentina';
        ipsInternalCaseController.addGECRecords();
        ipsInternalCaseController.LookupChange(); 
        ipsInternalCaseController.getEnvDetails();
        ipsInternalCaseController.saveCaseDetails();
        } 
    }

    //Added for NAC Project Removal;
    static testmethod void NACProjectTest(){
         getRecords(1);
     Product2 productRecord = new Product2();
            productRecord.Name = 'Haswell EP';
            productRecord.Core_Sales_Visible_Flag__c = false;
            productRecord.Core_IPS_Visible_Flag_External__c = true;
            productRecord.Core_IPS_Visible_Flag_Internal__c = 'Yes';
            productRecord.IsActive = true;
            productRecord.Core_Product_Org__c = 'IPS';
        insert productRecord; 
        
        Core_IPS_Product_Organization__c ProductOrganizationRec = new Core_IPS_Product_Organization__c();
            ProductOrganizationRec.Core_IPS_Support_Org_Name__c = 'TestName';
            ProductOrganizationRec.Core_Organization_Description__c = 'TestDescription';        
        insert ProductOrganizationRec;
       
         Core_IPS_Supported_Product__c spRec = new Core_IPS_Supported_Product__c();
            spRec.Core_Flag_Status__c = 'Par Hidden';
            spRec.Core_EOIS__c = false;
        spRec.Core_Product__c = productRecord.id;
        spRec.Core_Product_Organization__c = ProductOrganizationRec.Id;
        insert spRec;
       
        System.RunAs(ListOfInternalSfUsers.get(0)){
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        //ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        // instantiate the Controller - Core_IPS_Internal_Case_Controller Apex Class
        Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(CaseRecordSA));
        ipsInternalCaseController.objectSelected = 'Project';
         ipsInternalCaseController.selectedSAProductId = spRec.Id;
        ipsInternalCaseController.LookupChange(); 
        ipsInternalCaseController.getEnvDetails();
        ipsInternalCaseController.saveCaseDetails();
        } 
    }

    
    //end
    
    
  }