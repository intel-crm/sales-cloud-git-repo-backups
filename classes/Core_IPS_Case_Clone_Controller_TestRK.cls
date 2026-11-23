/***************************************************************************************************
Class Name:  Core_IPS_Case_Clone_Controller_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 28 Jan 2016
Function    : This class contains test coverage for Core_IPS_Case_Clone_Controller_Test class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Case_Clone_Controller_Test class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Ekbote       28/01/2016                 Created
****************************************************************************************************/ 
@isTest
public class  Core_IPS_Case_Clone_Controller_TestRK{
    private static User SystUserRunAs; 
    
    static Core_IPS_Case_Clone_Controller caseClone ;
    Static Case testCaseObj;
    static List<Case> ListOfCases = new List<Case>();
    static List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = new List<Core_IPS_Supported_Product__c>();
    static List<Core_IPS_Product_Organization__c> ListOfSupportOrg = new List<Core_IPS_Product_Organization__c>();
    static Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
    private static void Core_IPS_Case_Clone_Controller_Test(){
        Profile ps = [select id, name from Profile where  name = 'System Administrator' limit 1];        
        User sysAdimUser = TestUtilities.getUser();
        sysAdimUser.ProfileId = ps.id;
        insert sysAdimUser;
        System.runAs(sysAdimUser){                
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts; 
            System.assert(ListOfContacts[0].id != null,'Record not created');
            // Create Product
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            for(Product2 Product : ListOfProducts){
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
                
            }
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null,'Record not created');
            List<Core_IPS_Labels__c>  LstLabels = TestUtilities.getIPSLabel();
            insert LstLabels;
            // Create Support Org
            ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Record not created');
            // Create Supported product
            ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                
            }
            insert ListOfSupportedProduct;                
            System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
            
            //Added by Sunil 
            //Product2 prod =  TestUtilities.getProduct();
            //insert Prod;
            
            Asset asst = TestUtilities.getAsset();                
            asst.Core_Supported_Product__c = ListOfSupportedProduct[0].Id;
            Asst.product2Id = ListOfProducts.get(0).id;
            Asst.Core_product_organization__c = ListOfSupportOrg.get(0).id;
            insert Asst;
            System.assert(Asst.Id != null, 'Record not created'); 
            //End By sunil                
            // Create Case
            ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.AssetId = Asst.id;
                CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
            }                
            Core_IPS_Master_Issue_Category__c MasterCaseCategory = TestUtilities.getMasterCaseCategories();
            MasterCaseCategory.Core_type__c = 'Case Category';
            insert MasterCaseCategory;
            System.assert(MasterCaseCategory.Id != null, 'Record not created'); 
            
            Core_IPS_Master_Issue_Category__c MasterCategory = TestUtilities.getMasterCaseCategories();
            MasterCategory.Core_Master_Issue_Category__c = MasterCaseCategory.id;            
            insert MasterCategory;
            System.assert(MasterCategory.Id != null, 'Record not created');    
            caseCat = TestUtilities.getCaseCategories();
            caseCat.Core_Issue_Category_Name__c = MasterCategory.id;
            caseCat.Core_Type__c = 'Case Category';
            insert caseCat; 
            System.assert(caseCat.Id != null, 'Record not created');
            
            Core_IPS_Product_Issue_Category__c subCategory = TestUtilities.getCaseCategories();
            subCategory.Core_Issue_Sub_Category_Name__c = MasterCategory.id;
            subCategory.Core_Type__c = 'Case Subcategory';
            insert subCategory;
            
            System.assert(subCategory.Id != null, 'Record not created');
            ListOfCases.get(0).Core_Case_Issue_Category__c =  caseCat.id;
            ListOfCases.get(0).Core_case_issue_sub_category__c =  subCategory.id;
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            List<Core_IPS_Error_Code__c> errorCodes= TestUtilities.getListOfIpsErrorCodes();
            insert errorCodes;
            System.assert(errorCodes[0].Id != null, 'Record not created');
        } 
    }
    private static void createData(){
        TestUtilities.getCustomerUsersWithAccountsAndContacts('TestAcct',1, 5, 5, 5,  'IPS External Customer', 4);
        
        //create env Var
        List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
        for(integer i=0;i<4;i++){
            Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
            envVar.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            ListOfenvVars.add(envVar);
        }
        ListOfenvVars[0].Core_Datatype__c= 'Picklist';
        ListOfenvVars[1].Core_Datatype__c= 'Text (255)';
        ListOfenvVars[2].Core_Datatype__c= 'Text Area (5000)';
        ListOfenvVars[3].Core_Datatype__c= 'Multiselect Picklist';
        
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
        
        insert EnvironmentalDetailsList;
        System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
        testCaseObj = ListOfCases[0];
        Core_IPS_Environment_Details__c envDetal = new Core_IPS_Environment_Details__c();
        envDetal.Name = 'Issue Resolution List';
        envDetal.Core_Question__c='intel';
        envDetal.Core_Answer__c='TestAnswer1;TestAns2;Testans3';
        envDetal.Core_Case__c = testCaseObj.id;
        insert envDetal;                
        System.assert(envDetal.Id != null, 'Record not created');
        
        PageReference pageRef = Page.Core_IPS_CaseClone;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id',testCaseObj.Id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(testCaseObj);
        caseClone = new Core_IPS_Case_Clone_Controller(StndContr);
    }
    
    static testmethod void testPageinit(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.eoisFlag =true;
        caseClone.isMAG=false;
        caseClone.isGEC=false;
        PageReference pageRef = caseClone.PageInit();
        //System.assertEquals(null,pageRef);
        Test.stopTest();
    }
    //Added by Geetha 
    static testmethod void testPageinit1(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.isMAG=true;
        PageReference pageRef = caseClone.PageInit();
        Test.stopTest();
    }
    static testmethod void testPageinit2(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.isGEC=true;
        PageReference pageRef = caseClone.PageInit();
        Test.stopTest();
    }
    
    static testmethod void testPageinit3(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.eoisFlag =false;
        PageReference pageRef = caseClone.PageInit();
        Test.stopTest();
    }
    
    static testmethod void testPageinit4(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.categoryOptions = new List<SelectOption>();
        caseClone.categoryOptions.add(new SelectOption('dfcgjf', 'haskfhkadhf'));
        caseClone.categoryOptions.add(new SelectOption('dfgcccjf', 'haskfhkadhf'));
        caseClone.subCategoryOptions= new List<SelectOption>();
        caseClone.subCategoryOptions.add(new SelectOption('dccfgjf', 'haskfhkadhf'));
        caseClone.subCategoryOptions.add(new SelectOption('dfccccccccccgjf', 'haskfhkadhf'));
        caseClone.validateCaseRelatedInformation();
        
        Test.stopTest();
    }
    
    static testmethod void testPageinit4RK(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        Test.stopTest();
    }
    
    //Ended by Geetha 
    static testmethod void testPageInitWitheotrue(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        PageReference pageRef = caseClone.PageInit();
        //System.assertEquals('/apex/Core_IPS_EoisError',pageRef.getUrl());
        caseClone.getast();
        caseClone.getshowenvDetials();
        
        Test.stopTest();
    }
    static testmethod void testCancelCaseDetails(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        PageReference pageRef = caseClone.cancelCaseDetails();
        System.assertEquals('/500/o',pageRef.getUrl());
        Test.stopTest();
    }
    
    static testmethod void testsaveCaseDetailsWithDetails(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.cloneCase.Subject ='TestSubject';
        caseClone.cloneCase.Core_Severity__c='Critical';
        caseClone.cloneCase.Core_Issue_Description__c  = 'Test';
        testCaseObj.Core_IPS_GEC_Flag__c =true;
        PageReference pageRef = caseClone.saveCaseDetails();
        //System.assertEquals('/'+caseClone.cloneCase.Id,pageRef.getUrl());
        Test.stopTest();
    } 
    static testmethod void testsaveCaseDetailsWithOutDetails(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        PageReference pageRef = caseClone.saveCaseDetails();
        System.assertEquals(null,pageRef);
        Test.stopTest();
    }      
    static testmethod void testUpdateEnvDetails(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        CaseClone.isAgent = false;
        CaseClone.UpdateEnvDetails();
        Test.stopTest();
    }
    static testmethod void testDisplayPriorityReason(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        CaseClone.DisplayPriorityReason();
        Test.stopTest();
    } 
    
    static testmethod void testgetsubCategoryOptions(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.categorySelected = caseCat.Id;
        caseClone.getsubCategory_Options(caseCat.Id);
        Test.stopTest();
    } 
    static testmethod void testValidateEnvDetails1(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        //validation 1
        caseClone.envDetails[0].type='Text (255)';
        caseClone.envDetails[0].sPlaceHolder='';
        caseClone.envDetails[0].required=true;
        PageReference pageRef = caseClone.saveCaseDetails();
        System.assertEquals(null,pageRef);
        Test.stopTest();
    }
    static testmethod void testValidateEnvDetails2(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        //validation 2
        caseClone.envDetails[1].type='Text (255)';
        caseClone.envDetails[1].sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        caseClone.envDetails[1].required=true;
        PageReference pageRef = caseClone.saveCaseDetails();
        System.assertEquals(null,pageRef);
        Test.stopTest();
    }
    static testmethod void testValidateEnvDetails3(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        //Core_IPS_Supported_Product__c pdt = new Core_IPS_Supported_Product__c();
        //pdt.Core_EOIS__c=true;
        //insert pdt;
        //validation 3
        caseClone.envDetails[2].type='Text Area (5000)';
        caseClone.envDetails[2].tPlaceHolder='';
        caseClone.envDetails[2].required=true;
        PageReference pageRef = caseClone.saveCaseDetails();
        System.assertEquals(null,pageRef);
        Test.stopTest();
    }
    static testmethod void testValidateEnvDetails4(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        //validation 4
        caseClone.envDetails[3].type='Picklist';
        caseClone.envDetails[3].selectedValue='';
        caseClone.envDetails[3].required=true;
        PageReference pageRef = caseClone.saveCaseDetails();
        System.assertEquals(null,pageRef);
        Test.stopTest();
    }
    static testmethod void testValidateEnvDetails5(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        //validation 5
        caseClone.envDetails[3].type='Multiselect Picklist';
        caseClone.envDetails[3].selectedValue='';
        caseClone.envDetails[3].required=true;
        PageReference pageRef = caseClone.saveCaseDetails();
        System.assertEquals(null,pageRef);
        Test.stopTest();
    }
    static testmethod void testValidateEnvDetails7(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        //validation 5
        caseClone.envDetails[3].type='Multiselect Picklist';
        caseClone.envDetails[3].selectedValue='a;b;c;';
        caseClone.envDetails[3].required=true;
        PageReference pageRef = caseClone.saveCaseDetails();
        System.assertEquals(null,pageRef);
        Test.stopTest();
    }
    static testmethod void testsaveCaseDetailsWithOutDetails2(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.categorySelected = caseCat.Id;
        caseClone.envDetails[3].type='Picklist';
        caseClone.envDetails[3].selectedValue='dfsdf';
        caseClone.envDetails[3].required=true;
        caseClone.cloneCase.Core_CaseType__c = 'Question';
        caseClone.cloneCase.Subject = 'Question';
        caseClone.cloneCase.Core_Severity__c = 'Medium';
        caseClone.cloneCase.Core_Issue_Description__c = 'Question';
        PageReference pageRef = caseClone.saveCaseDetails();
        caseClone.subCategorySelected = 'sdasdsa';
        pageRef = caseClone.getEnvDetails();
        
        Test.stopTest();
    }    
    static testmethod void testsaveCaseDetails4(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.categorySelected = caseCat.Id;
        caseClone.envDetails[3].type='Picklist';
        caseClone.envDetails[3].selectedValue='dfsdf';
        caseClone.envDetails[3].required=true;
        caseClone.cloneCase.Core_CaseType__c = 'Question';
        caseClone.cloneCase.Subject = 'Question';
        caseClone.cloneCase.Core_Severity__c = 'Medium';
        caseClone.cloneCase.Core_Issue_Description__c = 'Question';
        caseClone.DisplayPriorityReason();
        
        Test.stopTest();
    }    
    static testmethod void testsaveCaseDetails3(){
        
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.categorySelected = caseCat.Id;
        caseClone.envDetails[3].type='Picklist';
        caseClone.envDetails[3].selectedValue='dfsdf';
        caseClone.envDetails[3].required=true;
        caseClone.cloneCase.Core_CaseType__c = 'Question';
        caseClone.cloneCase.Subject = 'Question';
        caseClone.cloneCase.Core_Severity__c = 'Critical';
        caseClone.cloneCase.Core_Issue_Description__c = 'Question';
        caseClone.DisplayPriorityReason();
        
        Test.stopTest();
    }
    //Added by Geetha
    static testmethod void testsaveCaseDetailsOne(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.categorySelected = caseCat.Id;
        caseClone.envDetails[3].type='Picklist';
        caseClone.envDetails[3].selectedValue='dfsdf';
        caseClone.envDetails[3].required=true;
        caseClone.cloneCase.Core_CaseType__c = 'Question';
        caseClone.cloneCase.Subject = '';
        caseClone.cloneCase.Core_Severity__c = 'Medium';
        caseClone.cloneCase.Core_Issue_Description__c = 'Question';
        PageReference pageRef = caseClone.saveCaseDetails();
        caseClone.subCategorySelected = 'sdasdsa';
        pageRef = caseClone.getEnvDetails();
        Test.stopTest();
    }
    static testmethod void testsaveCaseDetailsTwo(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        CaseClone.DisplayPriorityReason=true;
        //Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
        //system.debug(Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId());
        
        caseClone.categorySelected = caseCat.Id;
        caseClone.envDetails[3].type='Multiselect Picklist';
        caseClone.envDetails[3].selectedValue='dfsdf';
        caseClone.envDetails[3].required=true;
        caseclone.envDetails[3].cplaceholder=true; 
        caseClone.cloneCase.Core_CaseType__c = 'Question';
        caseClone.cloneCase.Subject = 'Question';
        caseClone.cloneCase.Core_Severity__c = 'Critical';
        caseClone.cloneCase.Core_Severity_Reason__c='';
        caseClone.cloneCase.Core_Issue_Description__c = 'Question';
        PageReference pageRef = caseClone.saveCaseDetails();
        caseClone.subCategorySelected = 'sdasdsa';
        pageRef = caseClone.getEnvDetails();
        Test.stopTest();
    }
    //Ended by Geetha
    
    //added by naresh related to the Test Coverage Story US41854 on 6/6/16
    static testmethod void testValidateEnvDetails10(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        //validation 3
        caseClone.envDetails[2].type='Text Area (5000)';
        caseClone.envDetails[2].tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
        caseClone.envDetails[2].required=true;
        PageReference pageRef = caseClone.saveCaseDetails();
        System.assertEquals(null,pageRef);
        Test.stopTest();
    }
    static testmethod void testsaveCaseDetailsWithOutDetails4(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.categorySelected = caseCat.Id;
        caseClone.envDetails[3].type='Multiselect Picklist';
        caseClone.envDetails[3].selectedValue='dfsdf';
        caseClone.envDetails[3].required=true;
        caseclone.envDetails[3].cplaceholder=true; 
        caseClone.cloneCase.Core_CaseType__c = 'Question';
        caseClone.cloneCase.Subject = 'Question';
        caseClone.cloneCase.Core_Severity__c = 'Medium';
        caseClone.cloneCase.Core_Issue_Description__c = 'Question';
        PageReference pageRef = caseClone.saveCaseDetails();
        caseClone.subCategorySelected = 'sdasdsa';
        pageRef = caseClone.getEnvDetails(); 
        caseClone.BindEvent(); 
        Test.stopTest();
    }
    
    static testmethod void testValidateEnvDetails11(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.envDetails[3].type='Multiselect Picklist';
        caseClone.envDetails[3].selectedMValue=null;
        caseClone.envDetails[3].required=true;
        caseClone.cloneCase.Core_CaseType__c = 'Question';
        caseClone.cloneCase.Subject = 'Question';
        caseClone.cloneCase.Core_Severity__c = 'Medium';
        caseClone.cloneCase.Core_Issue_Description__c = 'Question';
        PageReference pageRef = caseClone.saveCaseDetails();
        System.assertEquals(null,pageRef);
        caseClone.validateEnvironmentDetails();
        Test.stopTest();
    }
    //end 
    
    //Added by Geetha as per User story US78568
    static testmethod void showPopupOnContactLink(){
        Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
        insert cipspro;
        System.assertNotEquals(null, cipspro);
        Case  cse = new Case ();
        cse.core_ips_project_case__c=cipspro.id;
        insert cse;
        Account accountRecord = new Account();
        
        User u = [select id,userType,UserRole.Name  from user where usertype='PowerCustomerSuccess' AND ISActive=true AND UserRole.Name!='' limit 1 ];
        //system.runAs(u){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' and name='Admin' Limit 1];
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        User usr = [Select Id,UserRoleId from User where UserRoleId=:portalRole.Id AND profileId=:prof.id limit 1];
        system.runAs(usr){
            
            accountRecord = new Account(
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
        }
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
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_CaseClone;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id',cse.Id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(cse);
        caseClone = new Core_IPS_Case_Clone_Controller(StndContr);
        CaseClone.closePopup();
        CaseClone.showPopup();
        CaseClone.BindEvent();
        CaseClone.renderErrorFlag =true;
        CaseClone.rerenderFlag=true;
        Test.stopTest(); 
        
        //Ended by Geetha as per User story US78568
    } 
    
    static testmethod void testsaveCaseDetailsWithOutDetails24(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.categorySelected = null;
        caseClone.subCategorySelected= null;
        caseClone.envDetails[3].type='Picklist';
        caseClone.envDetails[3].selectedValue='dfsdf';
        caseClone.envDetails[3].required=true;
        caseClone.cloneCase.Core_CaseType__c = 'Question';
        caseClone.cloneCase.Subject = 'Question';
        caseClone.cloneCase.Core_Severity__c = 'Medium';
        caseClone.cloneCase.Core_Issue_Description__c = 'Question';
        caseClone.categoryOptions.add(new SelectOption('dfcgjf', 'haskfhkadhf'));
        caseClone.categoryOptions.add(new SelectOption('dfgcccjf', 'haskfhkadhf'));
        caseClone.subCategoryOptions.add(new SelectOption('dccfgjf', 'haskfhkadhf'));
        caseClone.subCategoryOptions.add(new SelectOption('dfccccccccccgjf', 'haskfhkadhf'));
        PageReference pageRef = caseClone.saveCaseDetails();
        caseClone.subCategorySelected = 'sdasdsa';
        pageRef = caseClone.getEnvDetails();
        
        Test.stopTest();
    }    
    
    static testmethod void testsaveCaseDetailsWithOutDetails25(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        caseClone.categorySelected = caseCat.Id;
        caseClone.subCategorySelected= null;
        caseClone.envDetails[3].type='Picklist';
        caseClone.envDetails[3].selectedValue='dfsdf';
        caseClone.envDetails[3].required=true;
        caseClone.cloneCase.Core_CaseType__c = 'Question';
        caseClone.cloneCase.Subject = 'Question';
        caseClone.cloneCase.Core_Severity__c = 'Medium';
        caseClone.cloneCase.Core_Issue_Description__c = 'Question';
        caseClone.categoryOptions.add(new SelectOption('dfcgjf', 'haskfhkadhf'));
        caseClone.categoryOptions.add(new SelectOption('dfgcccjf', 'haskfhkadhf'));
        caseClone.subCategoryOptions.add(new SelectOption('dccfgjf', 'haskfhkadhf'));
        caseClone.subCategoryOptions.add(new SelectOption('dfccccccccccgjf', 'haskfhkadhf'));
        PageReference pageRef = caseClone.saveCaseDetails();
        caseClone.subCategorySelected = 'sdasdsa';
        pageRef = caseClone.getEnvDetails();
        
        Test.stopTest();
    } 
    
    static testmethod void closeCaseRecordType(){
        Core_IPS_Case_Clone_Controller_Test();
        ListOfCases = TestUtilities.getListOfCases(10);
        ListOfCases[0].status = 'Closed';
        insert ListOfCases;
        Test.startTest();
        createData();
        PageReference pageRef = Page.Core_IPS_CaseClone;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id',ListOfCases[0].Id);
        ApexPages.CurrentPage().getparameters().put('retURL','500/o');
        ApexPages.StandardController StndContr = new ApexPages.standardController(ListOfCases[0]);
        caseClone = new Core_IPS_Case_Clone_Controller(StndContr);
        caseclone.cancelCaseDetails();
        test.stopTest();
    }   
    
    static testmethod void getGECCase(){
        Core_IPS_Case_Clone_Controller_Test();
        ListOfCases = TestUtilities.getListOfCases(10);
        ListOfCases[0].RecordtypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId(); 
        insert ListOfCases;
        Test.startTest();
        createData();
        PageReference pageRef = Page.Core_IPS_CaseClone;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id',ListOfCases[0].Id);
        ApexPages.CurrentPage().getparameters().put('retURL','500/o');
        ApexPages.StandardController StndContr = new ApexPages.standardController(ListOfCases[0]);
        caseClone = new Core_IPS_Case_Clone_Controller(StndContr);
        caseclone.cancelCaseDetails();
        test.stopTest();
    }  
    
    static testmethod void cancelRedirect(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        PageReference pageRef = Page.Core_IPS_CaseClone;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id',testCaseObj.Id);
        ApexPages.CurrentPage().getparameters().put('retURL','500/o');
        ApexPages.StandardController StndContr = new ApexPages.standardController(testCaseObj);
        caseClone = new Core_IPS_Case_Clone_Controller(StndContr);
        caseclone.cancelCaseDetails();
        test.stopTest();
    }
    
    static testmethod void severityTest(){
        Core_IPS_Case_Clone_Controller_Test();
        ListOfCases = TestUtilities.getListOfCases(10);
        ListOfCases[0].Core_Severity__c= 'Critical';
        insert ListOfCases;
        Test.startTest();
        createData();
        PageReference pageRef = Page.Core_IPS_CaseClone;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id',ListOfCases[0].Id);
        ApexPages.CurrentPage().getparameters().put('retURL','500/o');
        ApexPages.StandardController StndContr = new ApexPages.standardController(ListOfCases[0]);
        caseClone = new Core_IPS_Case_Clone_Controller(StndContr);
        caseclone.cancelCaseDetails();
        test.stopTest();
    } 
    
    static testmethod void cancelRedirectNegative(){
        Core_IPS_Case_Clone_Controller_Test();
        Test.startTest();
        createData();
        PageReference pageRef = Page.Core_IPS_CaseClone;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id',testCaseObj.Id);
        ApexPages.StandardController StndContr = new ApexPages.standardController(testCaseObj);
        caseClone = new Core_IPS_Case_Clone_Controller(StndContr);
        caseclone.cancelCaseDetails();
        test.stopTest();
    }
}