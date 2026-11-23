/***************************************************************************************************
Class Name:  Core_IPS_Case_Clone_Controllerv2_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for Core_IPS_Case_Clone_Controllerv2 Apex Class.
When Agent Logs access Case, Agent is directed to Core_IPS_Internal_Case_Creation VF Page and Core_IPS_Case_Clone_Controllerv2 Class is invoked
Description:   This class contains unit test scenarios for Core_IPS_Case_Clone_Controllerv2 Apex Class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       02/02/2016                Created
* Amritesh                  01/19/2018                Modified
* Karthick                  02/28/2018                Modified
****************************************************************************************************/   
@isTest
public class Core_IPS_Case_Clone_Controllerv2_Test {
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
    static List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = new List<Core_IPS_Supported_Product__c>();
    static Case CaseRecordSA = new Case();
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
        
        System.RunAs(ListOfInternalSfUsers.get(0)){
            
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
            CaseRecord.AccountId=ListOfAccounts.get(0).Id;
            CaseRecord.AssetId=ListOfAssets.get(0).Id;
            CaseRecord.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
            CaseRecord.ContactId=ListOfContacts.get(0).id;        
            CaseRecord.Core_IPS_Product_Org1__c=ListOfSupportOrg.get(0).id;
            CaseRecord.Core_Case_Issue_Category__c = caseCat.id;
            CaseRecord.Core_case_issue_sub_category__c = subCategory.id;
            CaseRecord.Core_Issue_Description__c = 'test';
            CaseRecord.Subject='TestSubject';
            CaseRecord.Core_CaseType__c='Issue';
            CaseRecord.core_ips_project_case__c=projectcase.id;
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            CaseRecord.recordTypeId = RT.Id;
            
        
            
            RecordType RT2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
            CaseRecordSA = CaseRecord.clone(false,true);
            CaseRecordSA.RecordTypeId = RT2.Id;
            
            if(tid==1){
                CaseRecord.Core_Severity__c='Critical';
            }
            if(tid!=1){
                insert CaseRecord;
                insert CaseRecordSA;
            }
            
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
                EnvironmentalDetails.Core_supported_product__c = ListOfSupportedProduct[0].id;
                EnvironmentalDetailsList.add(EnvironmentalDetails);
            }
            
            for(integer i=5;i<9;i++){
                Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails = TestUtilities.getEnvironmentalDetailsOperational();
                EnvironmentalDetails.Core_IPS_Question__c = lstCoreQuestion[i].id;
                EnvironmentalDetails.Core_Required__c=false;
                EnvironmentalDetails.Core_Product_Issue_Sub_Category__c = subCategory.id;
                EnvironmentalDetailsList.add(EnvironmentalDetails);
            }        
            insert EnvironmentalDetailsList;
            system.debug('EnvironmentalDetailsList'+EnvironmentalDetailsList);
            System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
            //added by amritesh US8534 - end
            
            List<Core_IPS_Error_Code__c> errorCodes= TestUtilities.getListOfIpsErrorCodes();
            insert errorCodes;
            System.assert(errorCodes[0].Id != null, 'Record not created');
        }
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
            PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClonev2;
            Test.setCurrentPage(InternalCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','edit');
            //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
            ApexPages.currentPage().getParameters().put('id', CaseRecord.Id);
            
            System.debug('---CaseRecord :::'+CaseRecord);
            // instantiate the Controller - Core_IPS_Case_Clone_Controllerv2 Apex Class
            Core_IPS_Case_Clone_Controllerv2 ipsInternalCaseController = new Core_IPS_Case_Clone_Controllerv2(new ApexPages.StandardController(CaseRecord));
            //ipsInternalCaseController.objectSelected ='Contact';
            system.debug('envDetails - ' + ipsInternalCaseController.envDetails);
            
            ipsInternalCaseController.cloneCase.Subject='Test subject';
            ipsInternalCaseController.cloneCase.Core_Severity__c='Critical';
            ipsInternalCaseController.cloneCase.Core_Issue_Description__c ='test description <div> test1</div><br/>thanks';
            
            ipsInternalCaseController.getEnvDetails();
            ipsInternalCaseController.saveCaseDetails();
            
            //ipsInternalCaseController.pageInit();
            
            ipsInternalCaseController.DisplayPriorityReason = false;
            ipsInternalCaseController.getast();
            ipsInternalCaseController.getshowenvDetials();
            ipsInternalCaseController.rerenderFlag = true;
            ipsInternalCaseController.cancelCaseDetails();
            
            ApexPages.currentPage().getParameters().put('retURL', '/'+CaseRecord.Id);
            ipsInternalCaseController.cancelCaseDetails();
            
            ipsInternalCaseController.DisplayPriorityReason();
            ipsInternalCaseController.closePopup();
            ipsInternalCaseController.showPopup();
            
            //ipsInternalCaseController.addEnvDetails();
            ipsInternalCaseController.captureEnvDetails();
            ipsInternalCaseController.captureEnvDetails();
            
            ipsInternalCaseController.cloneCase.Core_Severity__c='Normal';
            ipsInternalCaseController.DisplayPriorityReason();
            //PriorityCheck
            ipsInternalCaseController.DisplayPriorityReason = true;
            ipsInternalCaseController.cloneCase.Subject ='';            
            ipsInternalCaseController.saveCaseDetails();
            
            ipsInternalCaseController.cloneCase=caseRecord;     
            ipsInternalCaseController.cloneCase.Core_Severity_Reason__c='';         
            ipsInternalCaseController.saveCaseDetails();
            
        } 
    }
    static testmethod void pageInitTest(){
        
        getRecords(2);
            System.RunAs(ListOfInternalSfUsers.get(0)){
            CaseRecord =  new case();
            PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClonev2;
            Test.setCurrentPage(InternalCaseCreationPage);
            System.debug('---CaseRecord :::'+CaseRecord);
            // instantiate the Controller - Core_IPS_Case_Clone_Controllerv2 Apex Class
            Core_IPS_Case_Clone_Controllerv2 ipsInternalCaseController = new Core_IPS_Case_Clone_Controllerv2(new ApexPages.StandardController(CaseRecord));
            ipsInternalCaseController.eoisFlag= true;
            ipsInternalCaseController.pageInit();
            
            ipsInternalCaseController.eoisFlag= false;
            ipsInternalCaseController.isMAG= true;
            ipsInternalCaseController.pageInit();
            
            ipsInternalCaseController.eoisFlag= false;
            ipsInternalCaseController.isMAG= false;
            ipsInternalCaseController.isGEC= true;
            ipsInternalCaseController.pageInit();
        }
    }
    static testmethod void InsertCaseRecord(){
        getRecords(2);
        System.RunAs(ListOfInternalSfUsers.get(0)){
            
            CaseRecord.AssetId=ListOfAssets.get(0).Id;
            CaseRecord.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).Id;
            CaseRecord.Core_Severity__c='Critical';
            
            update CaseRecord;
            
            // Setting the Visualforce Page
            PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClonev2;
            Test.setCurrentPage(InternalCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','edit');
            //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
            ApexPages.currentPage().getParameters().put('id', CaseRecord.Id);
            
            System.debug('---CaseRecord :::'+CaseRecord);
            // instantiate the Controller - Core_IPS_Case_Clone_Controllerv2 Apex Class
            Core_IPS_Case_Clone_Controllerv2 ipsInternalCaseController = new Core_IPS_Case_Clone_Controllerv2(new ApexPages.StandardController(CaseRecord));
            //ipsInternalCaseController.objectSelected ='Contact';
            system.debug('envDetails - ' + ipsInternalCaseController.envDetails);
            
            ipsInternalCaseController.cloneCase.Subject='Test subject';
            ipsInternalCaseController.cloneCase.Core_Severity__c='Critical';
            ipsInternalCaseController.cloneCase.Core_Issue_Description__c ='test description <div> test1</div><br/>thanks';
            
            ipsInternalCaseController.getEnvDetails();
            ipsInternalCaseController.saveCaseDetails();
            
            UserRecordAccess assetAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: caseRecord.AssetId Limit 1];
            System.debug('-----Record Access Page Init ::'+assetAccess);
            ipsInternalCaseController.pageInit();
            //ipsInternalCaseController.cs.Core_IPS_Copy_Flag__c = true;
            
            
            ipsInternalCaseController.cs = CaseRecord;
            ipsInternalCaseController.categorySelected = '';
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            ipsInternalCaseController.categorySelected = 'sadsd';
            ipsInternalCaseController.subCategorySelected = '';
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            ipsInternalCaseController.categorySelected = 'sadsd';
            ipsInternalCaseController.subCategorySelected = 'sdsa';
            ipsInternalCaseController.validateCaseRelatedInformation();
        } 
    }
    
    static testmethod void validateEnvironmentDetails1(){       
        getRecords(7);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
         
        CaseRecord.AssetId=ListOfAssets.get(0).Id;
        CaseRecord.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).Id;
        CaseRecord.Core_Severity__c='Critical';
        
        update CaseRecord;
            
     
        // // Setting the Visualforce Page
         PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClonev2;
         Test.setCurrentPage(InternalCaseCreationPage);
        // // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        // //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
         RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
         ApexPages.currentPage().getParameters().put('rType',RT.Id);
         ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('id', CaseRecord.Id);
        // // instantiate the Controller - Core_IPS_Case_Clone_Controllerv2 Apex Class
        Core_IPS_Case_Clone_Controllerv2 ipsInternalCaseController = new Core_IPS_Case_Clone_Controllerv2(new ApexPages.StandardController(CaseRecord));
        ipsInternalCaseController.cloneCase=caseRecord;
        //ipsInternalCaseController.objectSelected ='Product';
        ipsInternalCaseController.cs = CaseRecord;
        ipsInternalCaseController.getEnvDetails();
        system.debug('validateEnvironmentDetails1 ----envDetails - 4' + ipsInternalCaseController.envDetails);
        system.debug('validateEnvironmentDetails1 -case record::' + caseRecord);
        //ipsInternalCaseController.addEnvDetails();
        
        
        
        ipsInternalCaseController.pageInit();
        
       // ipsInternalCaseController.envDetails[0].selectedValue= ipsInternalCaseController.envDetails[0].pplaceholder.get(0).getValue();
        List<String> val= new List<String>();
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(0).getValue());
        val.add(ipsInternalCaseController.envDetails[3].pplaceholder.get(1).getValue());
        ipsInternalCaseController.envDetails[3].selectedMValue = val;
        ipsInternalCaseController.validateEnvironmentDetails();
        
        ipsInternalCaseController.captureEnvDetails(); //- will add it after getting clarification
        ipsInternalCaseController.renderErrorFlag = false;
        ipsInternalCaseController.bindEvent();
        
        
        ipsInternalCaseController.envDetails[0].type='Text';
        ipsInternalCaseController.envDetails[0].sPlaceHolder='';
        ipsInternalCaseController.envDetails[0].required=true;
        ipsInternalCaseController.validateEnvironmentDetails();
        
        ipsInternalCaseController.envDetails[0].type='Text';
        ipsInternalCaseController.envDetails[0].sPlaceHolder='Testing'.leftPad(300,'g');
        ipsInternalCaseController.envDetails[0].required=true;
        ipsInternalCaseController.validateEnvironmentDetails();
        
        ipsInternalCaseController.envDetails[0].type='Text Area';
        ipsInternalCaseController.envDetails[0].tPlaceHolder='';
        ipsInternalCaseController.envDetails[0].required=true;
        ipsInternalCaseController.validateEnvironmentDetails();
        
        ipsInternalCaseController.envDetails[0].type = 'Picklist';
        ipsInternalCaseController.envDetails[0].selectedValue = '';
        ipsInternalCaseController.envDetails[0].required = true;
        ipsInternalCaseController.validateEnvironmentDetails();
        
        ipsInternalCaseController.envDetails[0].type='Multiselect Picklist';
        ipsInternalCaseController.envDetails[0].selectedMValue = null;
        ipsInternalCaseController.envDetails[0].required=true;
        ipsInternalCaseController.validateEnvironmentDetails();
        
        ipsInternalCaseController.envDetails[0].type='Text Area';
        ipsInternalCaseController.envDetails[0].tPlaceHolder='';
        ipsInternalCaseController.envDetails[0].tPlaceHolder='Testing'.leftPad(5100,'g');
        ipsInternalCaseController.envDetails[0].required=true;
        ipsInternalCaseController.envDetails[0].cplaceholder=true;    
        ipsInternalCaseController.validateEnvironmentDetails();
        
        
        System.debug('-------------Clone Case Record :::'+ipsInternalCaseController.cloneCase);
        //Exception part
        ipsInternalCaseController.getEnvDetails();
        
        try{
            delete caseRecord;
            ipsInternalCaseController.saveCaseDetails();
            
        }catch(Exception e){
            system.debug('---Exception Caught ::'+e.getMessage());
        }
        
        
        Test.stopTest();
       }
    }
    
    
    static testmethod void validateCaseRelatedInformation(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
        Test.startTest();
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClonev2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','asset');
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        ApexPages.currentPage().getParameters().put('rType',RT.Id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        ApexPages.currentPage().getParameters().put('id', CaseRecord.Id);
        CaseRecord.Subject = 'sdsad';
        CaseRecord.Core_Issue_Description__c = 'dasadsa';
        CaseRecord.Core_Severity__c='';
        // instantiate the Controller - Core_IPS_Case_Clone_Controllerv2 Apex Class
        Core_IPS_Case_Clone_Controllerv2 ipsInternalCaseController = new Core_IPS_Case_Clone_Controllerv2(new ApexPages.StandardController(CaseRecord));
        //ipsInternalCaseController.objectSelected ='Product';
        
        
        ipsInternalCaseController.cs = CaseRecord;
        
        ipsInternalCaseController.cloneCase = CaseRecord;
        
        ipsInternalCaseController.categorySelected = '';
        ipsInternalCaseController.validateCaseRelatedInformation();
        
        
        ipsInternalCaseController.categorySelected = 'sadsd';
        ipsInternalCaseController.subCategorySelected = '';
        ipsInternalCaseController.validateCaseRelatedInformation();
        
        ipsInternalCaseController.categorySelected = 'sadsd';
        ipsInternalCaseController.subCategorySelected = 'sdsa';
        ipsInternalCaseController.cloneCase.Core_CaseType__c='';
        
        ipsInternalCaseController.validateCaseRelatedInformation();
        Test.stopTest();
       }
    }
    
    static testmethod void InsertCaseRecord_selfAssigned(){
        getRecords(1);
        //CaseRecord = new Case(); Commented By Manoj
        // Setting the Visualforce Page
        PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClonev2;
        Test.setCurrentPage(InternalCaseCreationPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');        
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        system.debug('ListOfIpsProjects --' + ListOfIpsProjects);
        system.debug('ListOfAssets --' + ListOfAssets);
        //ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        //ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
        
        Core_IPS_Case_Clone_Controllerv2 ipsInternalCaseController = new Core_IPS_Case_Clone_Controllerv2(new ApexPages.StandardController(CaseRecordSA));
                
        ipsInternalCaseController.cs = CaseRecordSA;
        ipsInternalCaseController.cloneCase = CaseRecordSA;
        ipsInternalCaseController.categorySelected = caseCat.id;
        ipsInternalCaseController.subCategorySelected = subCategory.Id;
        
        system.debug('InsertCaseRecord_selfAssigned envDetails - 4' + ipsInternalCaseController.envDetails);
        
        //PriorityCheck      
        ipsInternalCaseController.cloneCase.Subject = 'clone case subject';
        ipsInternalCaseController.cloneCase.Core_Issue_Description__c = 'clone case description';
        ipsInternalCaseController.cloneCase.Core_Severity__c = 'Normal';            
        ipsInternalCaseController.DisplayPriorityReason = true;
        ipsInternalCaseController.cloneCase.Core_Severity_Reason__c='';     
        ipsInternalCaseController.saveCaseDetails();
        
        ipsInternalCaseController.cloneCase.Core_Severity_Reason__c='Test reason';      
        ipsInternalCaseController.cloneCase.Core_Issue_Description__c='Test description';
        ipsInternalCaseController.saveCaseDetails();
        
        ipsInternalCaseController.renderErrorFlag = True; 
        ipsInternalCaseController.saveCaseDetails();
        
        
        ipsInternalCaseController.errormessage('I100');
        
        ipsInternalCaseController.DisplayPriorityReason();
        ipsInternalCaseController.BindEvent();
        
    }
    
  }