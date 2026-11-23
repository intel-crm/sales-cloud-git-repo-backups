/***************************************************************************************************
Class Name:  Core_IPS_Case_Clone_Controller_Test   
Class Type: Test Class 
Version     : 1.0 
Created Date: 03 Nov 2015
Function    : This class contains test coverage for Core_IPS_Case_Clone_Controller Apex Class.
When Agent Logs access Case, Agent is directed to Core_IPS_Internal_Case_Creation VF Page and Core_IPS_Case_Clone_Controller Class is invoked
Description:   This class contains unit test scenarios for Core_IPS_Case_Clone_Controller Apex Class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       02/02/2016                Created
* Amritesh                  01/19/2018                Modified
* Karthick                  02/28/2018                Modified
* Ganapati                  07/08/2019                Modified
****************************************************************************************************/   
@isTest
public class Core_IPS_Case_Clone_Controller_Test {
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
            if(tid!=3){
                if(tid!=4) {
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
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            CaseRecord.recordTypeId = RT.Id;
            CaseRecord.Core_IPS_Issue_source__c=Label.Core_IPS_Legacy_PSG; //Modified by Ganapati - referred label instead of hardcoded value - 'Legacy PSG'
            CaseRecord.Core_IPS_Customer_Visible__c=true;
            
            
            RecordType RT2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
            CaseRecordSA = CaseRecord.clone(false,true);
            CaseRecordSA.RecordTypeId = RT2.Id;
            CaseRecordSA.Core_IPS_Customer_Visible__c=false;
            CaseRecordSA.Core_IPS_Issue_source__c = Label.Core_IPS_CaseSource_Val_for_Legacy_PSG;   //Modified by Ganapati for US267989 - prev val - 'NA'
            CaseRecordSA.ContactId=null;
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
            System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
            //added by amritesh US8534 - end
            
            List<Core_IPS_Error_Code__c> errorCodes= TestUtilities.getListOfIpsErrorCodes();
            insert errorCodes;
            System.assert(errorCodes[0].Id != null, 'Record not created');
            
            
            
            
        }
    }
    
    static void insertCoreResponse(Id caseId) {
        List<Core_IPS_Response__c> lstResponse = new List<Core_IPS_Response__c>();
        for(Core_IPS_Question__c objQues : [SELECT Id,Core_IPS_Datatype__c,(SELECT Id, Core_IPS_Answer__c FROM Core_Answers__r LIMIT 1) FROM Core_IPS_Question__c LIMIT 999]) {//ATHR Query limit fix
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
            // commenting for Classic EOL - Tejaswini
          /*  PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClone;
            Test.setCurrentPage(InternalCaseCreationPage); */
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','edit');
            //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
            ApexPages.currentPage().getParameters().put('id', CaseRecord.Id);
            
            // instantiate the Controller - Core_IPS_Case_Clone_Controller Apex Class
            Core_IPS_Case_Clone_Controller ipsInternalCaseController = new Core_IPS_Case_Clone_Controller(new ApexPages.StandardController(CaseRecord));
            //ipsInternalCaseController.objectSelected ='Contact';
            
            ipsInternalCaseController.cloneCase.Subject='Test subject';
            ipsInternalCaseController.cloneCase.Core_Severity__c='Critical';
            ipsInternalCaseController.cloneCase.Core_Issue_Description__c ='test description <div> test1</div><br/>thanks';
            
             //code added by S. Vishal
            ipsInternalCaseController.cloneCase=caseRecord;     
            ipsInternalCaseController.isAgentPartner = true;
            
            ipsInternalCaseController.saveCaseDetails();
            
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
            system.assertEquals(ipsInternalCaseController.cloneCase.Core_Severity__c,'Normal');
            ipsInternalCaseController.DisplayPriorityReason();
            //PriorityCheck
            ipsInternalCaseController.DisplayPriorityReason = true;
            ipsInternalCaseController.cloneCase.Subject ='';            
            ipsInternalCaseController.saveCaseDetails();
            
            ipsInternalCaseController.cloneCase=caseRecord;     
            ipsInternalCaseController.cloneCase.Core_Severity_Reason__c='';         
            ipsInternalCaseController.saveCaseDetails();
            List<Core_IPS_Case_Interested_Party__c> ListOfIP = TestUtilities.getInternalInterestedParties(3);
            ipsInternalCaseController.copyInterestedParties(ListOfIP);
            List<SelectOption> lstCountries = ipsInternalCaseController.getCountries();
            
        } 
    }
    static testmethod void pageInitTest(){
        
        getRecords(2);
        System.RunAs(ListOfInternalSfUsers.get(0)){
            CaseRecord =  new case();
            //commenting for Classic EOL - Tejaswini
      /*      PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClone;
            Test.setCurrentPage(InternalCaseCreationPage); */
            // instantiate the Controller - Core_IPS_Case_Clone_Controller Apex Class
            Core_IPS_Case_Clone_Controller ipsInternalCaseController = new Core_IPS_Case_Clone_Controller(new ApexPages.StandardController(CaseRecord));
            ipsInternalCaseController.eoisFlag= true;
             system.assertEquals( ipsInternalCaseController.eoisFlag,true);
            ipsInternalCaseController.pageInit();
            
            ipsInternalCaseController.eoisFlag= false;
            //ipsInternalCaseController.isMAG= true;
            ipsInternalCaseController.pageInit();
            
            ipsInternalCaseController.eoisFlag= false;
            //ipsInternalCaseController.isMAG= false;
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
            //Commented becaues it is getting error need to take a US to solve it . US:TWC745-5417 
            //CaseRecord.Status='Closed';
            system.assertEquals(CaseRecord.AssetId,ListOfAssets.get(0).Id);
         
            update CaseRecord;
            
            // Setting the Visualforce Page
            // commenting for Classic EOL - Tejaswini
        /*    PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClone;
            Test.setCurrentPage(InternalCaseCreationPage); */
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','edit');
            //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('paramId', CaseRecord.ContactId);
            ApexPages.currentPage().getParameters().put('id', CaseRecord.Id);
            
            // instantiate the Controller - Core_IPS_Case_Clone_Controller Apex Class
            Core_IPS_Case_Clone_Controller ipsInternalCaseController = new Core_IPS_Case_Clone_Controller(new ApexPages.StandardController(CaseRecord));
            //ipsInternalCaseController.objectSelected ='Contact';
            
            
            
            ipsInternalCaseController.cloneCase.Subject='Test subject';
            ipsInternalCaseController.cloneCase.Core_Severity__c='Critical';
            ipsInternalCaseController.cloneCase.Core_Issue_Description__c ='test description <div> test1</div><br/>thanks';
            
            ipsInternalCaseController.getEnvDetails();
            ipsInternalCaseController.saveCaseDetails();
            
            UserRecordAccess assetAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: caseRecord.AssetId Limit 1];
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
            
            //code added as per US136245
           
            ipsInternalCaseController.cloneCase = CaseRecord;
            CaseRecord.Subject='Test';
            CaseRecord.Core_Issue_Description__c='Test';
            CaseRecord.Core_Severity__c='Low';
          
            ipsInternalCaseController.cloneCase.Core_Issue_Description__c='';
            ipsInternalCaseController.cloneCase.Core_CaseType__c='';
            
            ipsInternalCaseController.subCategorySelected = null;
            ipsInternalCaseController.subCategoryOptions.add(new SelectOption('', 'Select SubCategory'));   
            ipsInternalCaseController.cloneCase.subject = ''; 
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
             system.assertEquals(CaseRecord.Core_Severity__c,'Critical');
            update CaseRecord;
            
            // // Setting the Visualforce Page
            // commenting for Classic EOL - Tejaswini
        /*    PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClone;
            Test.setCurrentPage(InternalCaseCreationPage); */
            // // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            // //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
            ApexPages.currentPage().getParameters().put('id', CaseRecord.Id);
            // // instantiate the Controller - Core_IPS_Case_Clone_Controller Apex Class
            Core_IPS_Case_Clone_Controller ipsInternalCaseController = new Core_IPS_Case_Clone_Controller(new ApexPages.StandardController(CaseRecord));
            ipsInternalCaseController.cloneCase=caseRecord;
            //ipsInternalCaseController.objectSelected ='Product';
            ipsInternalCaseController.cs = CaseRecord;
            ipsInternalCaseController.getEnvDetails();
            //ipsInternalCaseController.addEnvDetails();
            
            
            
            ipsInternalCaseController.pageInit();
            ipsInternalCaseController.envDetails[0].selectedValue= ipsInternalCaseController.envDetails[2].pplaceholder.get(0).getValue();
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
            
            //Exception part
            ipsInternalCaseController.getEnvDetails();
            
            try{
                delete caseRecord;
                ipsInternalCaseController.saveCaseDetails();
                
            }catch(Exception e){
            }
            
            
            Test.stopTest();
        }
    }
    
    
    static testmethod void validateCaseRelatedInformation(){       
        getRecords(1);
        System.RunAs(ListOfInternalSfUsers.get(0)){
            Test.startTest();
            // Setting the Visualforce Page
            // commenting for Classic EOL - Tejaswini
        /*    PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClone;
            Test.setCurrentPage(InternalCaseCreationPage); */
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
             system.assertEquals(CaseRecord.Subject,'sdsad');
            // instantiate the Controller - Core_IPS_Case_Clone_Controller Apex Class
            Core_IPS_Case_Clone_Controller ipsInternalCaseController = new Core_IPS_Case_Clone_Controller(new ApexPages.StandardController(CaseRecord));
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
            
            //code added as per US136245
            ipsInternalCaseController.cloneCase = CaseRecord;
               
            ipsInternalCaseController.cloneCase.subject = 'test';
            ipsInternalCaseController.cloneCase.Core_Issue_Description__c = 'Test';
            ipsInternalCaseController.cloneCase.Core_Severity__c='Low';
           
            ipsInternalCaseController.validateCaseRelatedInformation();
            
            Test.stopTest();
        }
    }
    
    static testmethod void InsertCaseRecord_selfAssigned(){
        getRecords(1);
        //CaseRecord = new Case(); Commented By Manoj
        // Setting the Visualforce Page
        // commenting for Classic EOL - Tejaswini
    /*    PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClone;
        Test.setCurrentPage(InternalCaseCreationPage); */
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('mode','edit');        
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        ApexPages.currentPage().getParameters().put('rType', String.valueOf(RT.Id).left(15));
        //ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects.get(0).Id);
        //ApexPages.currentPage().getParameters().put('productId', ListOfAssets.get(0).Id);
     	ApexPages.currentPage().getParameters().put('id',CaseRecordSA.id);
        Core_IPS_Case_Clone_Controller ipsInternalCaseController = new Core_IPS_Case_Clone_Controller(new ApexPages.StandardController(CaseRecordSA));

        ipsInternalCaseController.cs = CaseRecordSA;
        ipsInternalCaseController.cloneCase = CaseRecordSA;
        ipsInternalCaseController.categorySelected = caseCat.id;
        ipsInternalCaseController.subCategorySelected = subCategory.Id;
        
        //PriorityCheck      
        ipsInternalCaseController.cloneCase.Subject = 'clone case subject';
        ipsInternalCaseController.cloneCase.Core_Issue_Description__c = 'clone case description';
        ipsInternalCaseController.cloneCase.Core_Severity__c = 'Normal';            
        ipsInternalCaseController.DisplayPriorityReason = true;
        ipsInternalCaseController.cloneCase.Core_Severity_Reason__c='';     
        ipsInternalCaseController.saveCaseDetails();
        ipsInternalCaseController.custVisible=false;
        ipsInternalCaseController.isNACCase=true;
        
         system.assertEquals(ipsInternalCaseController.cloneCase.Core_Severity__c,'Normal');
        
        ipsInternalCaseController.cloneCase.Core_Severity_Reason__c='Test reason';      
        ipsInternalCaseController.cloneCase.Core_Issue_Description__c='Test description';
        ipsInternalCaseController.saveCaseDetails();
        
        ipsInternalCaseController.renderErrorFlag = True; 
        ipsInternalCaseController.saveCaseDetails();
        
        
        ipsInternalCaseController.errormessage('I100');
        
        ipsInternalCaseController.DisplayPriorityReason();
        ipsInternalCaseController.BindEvent();
        
    }
    //Ashutosh - US103890
    static testmethod void testCopyInterestedParties(){
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> SalesRepProfIds = new List<String>();
        List<String> IPAgentProfileIds = new List<String>();
        
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        List<Contact>ListOfContacts = TestUtilities.getListOfContact(4);
        IPAgentProfileIds.addall(Label.Interested_Parties_Internal_Agent_ProfileIds.split(','));
        SalesRepProfIds.addall(label.Core_IPS_Sales_Rep_ProfileIds.split(','));
        
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator' limit 1];
        
        //Creating Custom Settings for search criteria of Accountteammembers
        List<Core_IPS_Labels__c> IpsLabels = new List<Core_IPS_Labels__c>();
        
        Core_IPS_Labels__c ipsLabelTeam = new Core_IPS_Labels__c(Name='RowCause_Team',Value__c='Team');
        Core_IPS_Labels__c ipsLabelOwner = new Core_IPS_Labels__c(Name='Rowcause_Owner',Value__c='Owner');
        Core_IPS_Labels__c ipsLabelRead = new Core_IPS_Labels__c(Name='AccessLevel_Read',Value__c='Read');
        Core_IPS_Labels__c ipsLabelEdit = new Core_IPS_Labels__c(Name='AccessLevel_Edit',Value__c='Edit');
        
        IpsLabels.add(ipsLabelTeam);
        IpsLabels.add(ipsLabelOwner);
        IpsLabels.add(ipsLabelRead);
        IpsLabels.add(ipsLabelEdit);
        
        
        Insert IpsLabels;
        
        
        //Creating cases
        List<Case> ListOfCases = TestUtilities.getListOfCases(2);
        
        // Create Users
        List<User>ListOfUser = TestUtilities.getListOfUser(6);
        
        ListOfUser.get(0).FirstName= 'Admin Test';
        ListOfUser.get(0).LastName= 'Admin Sys Admin';
        ListOfUser.get(0).ProfileID =  ProfileList.get(0).Id;
        
         system.assertEquals(ListOfUser.get(0).FirstName,'Admin Test');
        
        ListOfUser.get(1).FirstName= 'Agent Test';
        ListOfUser.get(1).LastName= 'Agent IPS Agent';
        ListOfUser.get(1).ProfileID =  IPAgentProfileIds.get(0);
        
        ListOfUser.get(2).FirstName= 'Sales Test';
        ListOfUser.get(2).LastName= 'Sales Rep';
        ListOfUser.get(2).ProfileID =  SalesRepProfIds.get(0);
        
        ListOfUser.get(3).FirstName= 'Rep Test';
        ListOfUser.get(3).LastName= 'Rep Sales Rep';
        ListOfUser.get(3).ProfileID =  SalesRepProfIds.get(0);
        
        ListOfUser.get(4).FirstName= 'Sales Test 2';
        ListOfUser.get(4).LastName= 'Sales Sales Rep 2';
        ListOfUser.get(4).ProfileID =  SalesRepProfIds.get(0);
        
        ListOfUser.get(5).FirstName= 'Sales Test 3';
        ListOfUser.get(5).LastName= 'Sales Sales Rep 3';
        ListOfUser.get(5).ProfileID =  SalesRepProfIds.get(0);
        
        insert ListOfUser;
        /*
UserRole role = new UserRole();
role.name='CEO';
// Creating SETUP OBJECT (USERROLE) RECORD
insert role;
ListOfUser.get(0).userroleid =role.id;               
update ListOfUser;
*/
        
        System.RunAs(ListOfUser[0]) {
            Account acct = new Account();
            acct = TestUtilities.getListOfAccounts(1)[0]; //.getAccountRecord();
            //acct.Core_IPS_Active__c = true;
            
            //acct.ownerid = ListOfUser.get(0).id;
            acct.Core_Military_Aerospace_and_Government__c = false;
            insert acct;
            
            //Adding Sales Rep to AccountTeamMember
            AccountTeamMember atm = new AccountTeamMember(UserId=ListOfUser.get(2).Id,AccountId=acct.Id,TeamMemberRole ='Team Member (100%)');
            
            atmList.add(atm);
            
            insert atmList;
            
            List<AccountShare> affectedAcctShare = [select Id,CaseAccessLevel,rowcause from AccountShare where AccountId=:atm.AccountId and UserOrGroupId =:atm.UserId limit 1];
            
            //Providing Read-Only to Case for Sales Rep
            for(AccountShare actshare: affectedAcctShare) {
                actshare.CaseAccessLevel = 'Read';
            }
            
            update affectedAcctShare;
            
            for(Contact Con : ListOfContacts){
                Con.Accountid = acct.Id;
                Con.Core_IPS_Intel_Support_Owner__c = ListOfUser.get(1).id;
                Con.Core_IPS_Active__c = true;
                //Con.ownerid = ListOfUser.get(0).id;
            }               
            insert ListOfContacts;
            
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
            ListOfAssets.get(0).accountId = acct.Id;
            // if(tid!=1){
            ListOfAssets.get(0).core_supported_product__c = ListOfSupportedProduct[0].id;
            //}
            insert ListOfAssets;
            System.assert(ListOfAssets.get(0).Id != null, 'Asset Record not created');
            
            
            //insert contactList;
            ListOfCases.get(0).OwnerId=ListOfUser.get(1).Id;
            ListOfCases.get(0).AccountId = acct.Id;
            ListOfCases.get(0).Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
            ListOfCases.get(0).contactId = ListOfContacts.get(0).Id;
            insert ListOfCases;
            
        }
        
        System.assertEquals(ListOfUser.get(0).profileid, ProfileList.get(0).Id);
        
        System.assert(ListOfCases[0].Id != null, 'Record not created');        
        
        System.runAs(ListOfUser.get(0)) {            
            
            CaseRecord = ListOfCases.get(0); 
            //caseRecord.ContactId = contactList.get(0).Id;
            
            List<Core_IPS_Case_Interested_Party__c> ListOfIP = TestUtilities.getInternalInterestedParties(3);            
            
            ListOfIP[0].Case__c = CaseRecord.Id;
            ListOfIP[0].User__c = ListOfUser.get(0).Id;
            ListOfIP[0].Type__c = 'External';
            
            
            ListOfIP[1].Case__c = ListOfCases.get(1).Id;
            ListOfIP[1].User__c = ListOfUser.get(1).Id;
            ListOfIP[1].Type__c = 'Internal';
            
            /*Ashutosh - US103988 - Added another interested party*/
            ListOfIP[2].Case__c = CaseRecord.Id;
            ListOfIP[2].User__c = ListOfUser.get(2).Id;
            ListOfIP[2].Type__c = 'Internal';
            
            insert ListOfIP;
        }
        
        System.runAs(ListOfUser.get(0)) {
            Test.startTest();
            //commenting for Classic EOL - Tejaswini
        /*    PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClone;
            Test.setCurrentPage(InternalCaseCreationPage); */
            ApexPages.currentPage().getParameters().put('id',CaseRecord.Id); 
            Core_IPS_Case_Clone_Controller ipsInternalCaseController = new Core_IPS_Case_Clone_Controller(new ApexPages.StandardController(CaseRecord));
            
            ipsInternalCaseController.cloneCase.Subject = 'clone case subject';
            ipsInternalCaseController.cloneCase.Core_Issue_Description__c = 'clone case description';
            ipsInternalCaseController.cloneCase.Core_Severity__c = 'Normal';            
            ipsInternalCaseController.DisplayPriorityReason = true;
            ipsInternalCaseController.isPartnerFAE=true;
            ipsInternalCaseController.cloneCase.Core_Severity_Reason__c='Test Reason'; 
            ipsInternalCaseController.cloneCase.Core_CaseType__c = 'Issue';
            ipsInternalCaseController.saveCaseDetails();
            ipsInternalCaseController.cloneCase.Core_IPS_Customer_Visible__c = false;
            ipsInternalCaseController.saveCaseDetails();
            ipsInternalCaseController.cloneCase.Core_Issue_Description__c = '';
            ipsInternalCaseController.saveCaseDetails();
            //ipsInternalCaseController.cloneCase.Core_Issue_Description__c = 'test';
           //ipsInternalCaseController.cloneCase.Core_CaseType__c = '';
            ipsInternalCaseController.saveCaseDetails();
            
            Test.stopTest();
        } 
    }
    
    static testmethod void testPortalUser(){
        test.startTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' and name='Admin' Limit 1];
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        User usr = [Select Id,UserRoleId from User where IsActive = true AND UserRoleId=:portalRole.Id AND profileId=:prof.id limit 1];
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
                Email='babux5x5@intel.com',
                MailingCountry = 'India'
            );
            Database.insert(contact1);
            Profile p = [select id, name from Profile where name in ('IPS Agent-Partner') limit 1]; 
             system.assertEquals(p.name,'IPS Agent-Partner');
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
            system.runAs(usr){
                // Setting the Visualforce Page
                //Commented bcz Core_IPS_Customer_Case_Creation is getting called  US:TWC745-5417 
               // PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
                //Test.setCurrentPage(CustomerCaseCreationPage);
                ApexPages.currentPage().getParameters().put('mode','edit');
                Case CaseRecord =  TestUtilities.getCase(); 
                CaseRecord.AccountId=portalAccount1.id;
                CaseRecord.contactid=contact1.id;
                insert CaseRecord;
                ApexPages.currentPage().getParameters().put('id',CaseRecord.id);
                Core_IPS_Case_Clone_Controller  ipsCustomerCaseController1 = new Core_IPS_Case_Clone_Controller (new ApexPages.StandardController(CaseRecord));    
            }
        }
        test.stopTest();  
    }
    
    //Test as a IPS External Customer User
    static testmethod void testPortalUserIPSCustomerUser(){
        test.startTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' and name='Admin' Limit 1];
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        User usr = [Select Id,UserRoleId from User where IsActive = true AND UserRoleId=:portalRole.Id AND profileId=:prof.id limit 1];
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
                Email='babux5x5@intel.com',
                MailingCountry ='India'
            );
            Database.insert(contact1);
            Profile p = [select id, name from Profile where name in ('IPS External Customer') limit 1]; 
             system.assertEquals(p.Name,'IPS External Customer');
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
            system.runAs(usr){
                // Setting the Visualforce Page
                //Commented bcz Core_IPS_Customer_Case_Creation is getting called  US:TWC745-5417 
               // PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
                //Test.setCurrentPage(CustomerCaseCreationPage);
                ApexPages.currentPage().getParameters().put('mode','edit');
                Case CaseRecord =  TestUtilities.getCase(); 
                CaseRecord.AccountId=portalAccount1.id;
                CaseRecord.contactid=contact1.id;
                insert CaseRecord;
                ApexPages.currentPage().getParameters().put('id',CaseRecord.id);
                Core_IPS_Case_Clone_Controller  ipsCustomerCaseController1 = new Core_IPS_Case_Clone_Controller (new ApexPages.StandardController(CaseRecord));    
                ipsCustomerCaseController1.UpdateEnvDetails();
            }
        }
        test.stopTest();  
    }
    
    
    //Test as a IPS External Customer User
    static testmethod void testPortalUserIPSCustomerUser2(){
        test.startTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' and name='Admin' Limit 1];
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        User usr = [Select Id,UserRoleId from User where IsActive = true AND UserRoleId=:portalRole.Id AND profileId=:prof.id limit 1];
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
                Email='babux5x5@intel.com',
                MailingCountry = 'India'
            );
            Database.insert(contact1);
            Profile p = [select id, name from Profile where name in ('IPS External Customer') limit 1]; 
             system.assertEquals(p.Name,'IPS External Customer');
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
            system.runAs(usr){
                // Setting the Visualforce Page
               //Commented bcz Core_IPS_Customer_Case_Creation is getting called  US:TWC745-5417 
                //PageReference CustomerCaseCreationPage = Page.Core_IPS_Customer_Case_Creation;
                //Test.setCurrentPage(CustomerCaseCreationPage);
                ApexPages.currentPage().getParameters().put('mode','edit');
                Case CaseRecord =  TestUtilities.getCase(); 
                CaseRecord.AccountId=portalAccount1.id;
                CaseRecord.contactid=contact1.id;
                insert CaseRecord;
                ApexPages.currentPage().getParameters().put('id',CaseRecord.id);
                Core_IPS_Case_Clone_Controller  ipsCustomerCaseController1 = new Core_IPS_Case_Clone_Controller (new ApexPages.StandardController(CaseRecord));    
                Core_IPS_Case_Clone_Controller.CaseRecordSave oi = new Core_IPS_Case_Clone_Controller.CaseRecordSave();
                oi.saveCase(CaseRecord);
            }
        }
        test.stopTest();  
    }
    
    //Asset Page Init Test Method
    static testmethod void pageInitAssetTest(){
        getRecords(2);
        
        //Create account
        Account portalAccount1 = new Account(
            Name = 'newAcc3',
            BillingCity = 'folsom',
            BillingCountry = 'USA',
            BillingStreet = 'Creek Side Dr'    
        );
        Database.insert(portalAccount1);
        //Create contact
        Contact contact1 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia',
            LastName  = 'portalTcestUser',
            Email='babux5x5@intcel.com',
            MailingCountry = 'India'
        );
        Database.insert(contact1);
        
        
        System.RunAs(ListOfInternalSfUsers.get(0)){
            CaseRecord =  new case();
            CaseRecord.AssetId = ListOfAssets.get(0).id;
            CaseRecord.Status = 'Closed';
            CaseRecord.Core_Issue_Description__c = '';
            CaseRecord.contactId = contact1.id;
            insert CaseRecord;
            //commenting for Classic EOL - Tejaswini
      /*      PageReference InternalCaseCreationPage = Page.Core_IPS_CaseClone;
            Test.setCurrentPage(InternalCaseCreationPage); */
            Core_IPS_Case_Clone_Controller ipsInternalCaseController = new Core_IPS_Case_Clone_Controller(new ApexPages.StandardController(CaseRecord));
            ipsInternalCaseController.pageInit();
            CaseRecord.AssetId = ListOfAssets.get(0).id;
            ipsInternalCaseController.renderErrorFlag = true;
            ipsInternalCaseController.selectedAccountId = null;
             system.assertEquals(ipsInternalCaseController.renderErrorFlag,true);
            
        }
    }
   

}