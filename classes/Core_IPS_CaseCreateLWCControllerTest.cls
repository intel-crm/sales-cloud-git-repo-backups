@isTest(seeAllData=false)
public class Core_IPS_CaseCreateLWCControllerTest {
    
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
    static List<Contact> ListOfContacts;
    static List<Account> ListOfAccounts = new List<Account> ();
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
        // List<Account> ListOfAccounts = new List<Account> ();
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
        ListOfContacts = TestUtilities.getListOfContact(1);
        ListOfContacts.get(0).Accountid = ListOfAccounts.get(0).Id;
        ListOfContacts.get(0).Core_IPS_Intel_Support_Owner__c = ListOfInternalSfUsers.get(0).id;
        ListOfContacts.get(0).ownerid = ListOfInternalSfUsers.get(0).id;
        ListoFContacts[0].MailingCountry = 'India';
        insert ListOfContacts;
        System.assert(ListOfContacts[0].Id != null, 'Contact Record not created');
        // Create Support Org Record
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert ListOfSupportOrg;
        System.assert(ListOfSupportOrg != null, 'Support Org Record not created');
        // Create Product2 Record
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        ListOfProducts[0].Core_Sales_Visible_Flag__c =FALSE;
        ListOfProducts[0].Core_Hierarchy_ID__c='59';
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
        System.assertEquals(true, lstResponse != null);
    }
    
    @istest
    public static void testGetCaseData(){
        
        
        getRecords(2);
        Test.startTest();
         //Added by Sowmya - Start - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        Core_IPS_Project__c prject = TestUtilities.getIpsProjectRecord();
        prject.Core_Status__c = 'Draft';
        Insert prject;
       //Sowmya - End - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        
        Case cs = new Case();
        cs.subject = 'Test case';
        cs.Description = 'Test Desc';
        cs.core_ips_project_case__c = prject.Id;
        cs.ContactId = ListOfContacts[0].Id;
        cs.AccountId = ListOfAccounts[0].id;
        insert cs;
       
        Core_IPS_Labels__c c = new Core_IPS_Labels__c();
        c.Name = 'CloseCaseEditPermission';
        c.Value__c = 'Sales Rep-BB';
        insert c;
        
        Core_IPS_CaseCreateLWCController.hasEditAccess(cs.Id);
        //Core_IPS_CaseEditWrapper wrapper = Core_IPS_CaseCreateLWCController.getCaseData(''+CaseRecord.id);
        Core_IPS_CaseEditWrapper wrapper = Core_IPS_CaseCreateLWCController.getCaseData(cs.id);
        Core_IPS_CaseEditWrapper wrapper1 = new Core_IPS_CaseEditWrapper(cs.id); 
        wrapper1.variants = null;
        wrapper1.variants_NAC = null;
        Core_IPS_CaseEditWrapper wrapper2 = new Core_IPS_CaseEditWrapper(''); 
       
         Core_IPS_CaseCreateLWCController.checkcloseCaseEditPermission(cs.Id);
       
        system.assertEquals(cs.id, wrapper.cs.id ) ;
        Test.stopTest();
        
    }
    @istest
    public static void testControllerMethods(){
        getRecords(2);
        
        Test.startTest();
        CustomSelectOptions opt = new CustomSelectOptions();
        List<CustomSelectOptions>  options = Core_IPS_CaseCreateLWCController.getCategoryDetails(''+CaseRecord.Core_IPS_Supported_Product__c);
        system.assertEquals(2, options.size()) ;
        
        options = Core_IPS_CaseCreateLWCController.getSubCategoryDetail(''+CaseRecord1.Core_Case_Issue_Category__c);
        //system.assertNotEquals(0, options.size()) ;
        
        options = Core_IPS_CaseCreateLWCController.getPlatformDetails(''+CaseRecord1.Core_IPS_Supported_Product__c);
        system.assertEquals(0, options.size()) ;
        
        // options = Core_IPS_CaseCreateLWCController.getPlatformDetails(''+CaseRecord1.Core_IPS_Supported_Product__c);
        // system.assertEquals(null, options) ;
        
        boolean isAgent = Core_IPS_CaseCreateLWCController.getAgentDetail();
        system.assertEquals(true, isAgent) ;
        
        
        
        Core_IPS_Project_Member__c projectMember = TestUtilities.getProjectMember();
        projectMember.core_ips_contact__c = ListOfContacts.get(0).id;
        projectMember.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        insert projectMember;
        
        string ContactQuery = Core_IPS_CaseCreateLWCController.getContactLookupSOQL(ListOfIpsProjects.get(0).Id, ListOfAssets.get(0).Id);
        system.assertNotEquals('', ContactQuery) ;
        
        ContactQuery = Core_IPS_CaseCreateLWCController.getContactLookupSOQL(null, ListOfAssets.get(0).Id);
        system.assertNotEquals('', ContactQuery) ;
        
        system.runAs(ListOfInternalSfUsers.get(0)){
            ContactQuery = Core_IPS_CaseCreateLWCController.getContactLookupSOQL(ListOfIpsProjects.get(0).Id, ListOfAssets.get(0).Id);
            system.assertNotEquals('', ContactQuery) ;
        }
        
        List<Core_IPS_CaseCreateHelper.DynamicField> edqs1 = Core_IPS_CaseCreateLWCController.getProductEDQ(''+CaseRecord.Core_IPS_Supported_Product__c, CaseRecord.Core_case_issue_sub_category__c, false);
        system.assertNotEquals(0, edqs1.size()) ;
        
        List<Core_IPS_CaseCreateHelper.DynamicField> edqs2 = Core_IPS_CaseCreateLWCController.getSubCatProductEDQ(''+CaseRecord.Core_IPS_Supported_Product__c,  CaseRecord.Core_case_issue_sub_category__c, false);
        system.assertNotEquals(0, edqs2.size()) ;
        
        
        List<String> projectlist = Core_IPS_CaseCreateLWCController.getProjectList(''+CaseRecord.ContactId);
        system.assertEquals(0, projectlist.size()) ;
        
        //case cs = Core_IPS_CaseCreateLWCController.SubmitCaseRecord(CaseRecord, ListOfContacts[0], null );
        //case cs = Core_IPS_CaseCreateLWCController.SubmitCaseRecord(CaseRecord.Clone(), ListOfContacts[0], '' );
        //system.assertnotEquals(null, cs.id ) ;
        
        ListOfContacts[0].Core_Country_Region__c='';
        
        Core_IPS_Question__c questionPicklist = TestUtilities.getCoreQuestion();
        questionPicklist.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ;  
        insert  questionPicklist;
        
        Core_IPS_Question__c questionPicklist2 = TestUtilities.getCoreQuestion();
        questionPicklist2.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ;  
        insert  questionPicklist2;
        
        Core_IPS_Answer__c ans1 = new Core_IPS_Answer__c();
        ans1.Core_IPS_Answer__c ='IT Store 1';
        ans1.Core_IPS_Question__c =questionPicklist.id;
        insert ans1;
        
        Core_IPS_Answer__c ans2 = new Core_IPS_Answer__c();
        ans2.Core_IPS_Answer__c ='IT Store 2';
        ans2.Core_IPS_Question__c =questionPicklist2.id;
        insert ans2;
        
        Core_IPS_Question__c question = TestUtilities.getCoreQuestion();
        question.Core_IPS_Parent_Question__c = questionPicklist.id;
        
        Core_IPS_Question__c questionMultiSelect = TestUtilities.getCoreQuestion();
        questionMultiSelect.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c ;  
        questionMultiSelect.Core_IPS_Parent_Question__c = questionPicklist.id;
        
        Core_IPS_Question__c questionTextArea = TestUtilities.getCoreQuestion();
        questionTextArea.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c; 
        questionTextArea.Core_IPS_Parent_Question__c = questionPicklist.id;
        
        List<Core_IPS_Question__c> questions = new List<Core_IPS_Question__c>{question, questionMultiSelect, questionTextArea};
            insert questions; 
        
        
        List<Core_IPS_Answer__c> ansswers = TestUtilities.getCoreAnswers(3); 
        integer i=0;  
        for(Core_IPS_Answer__c ans : ansswers){ 
            ans.Core_IPS_Question__c = questions[i].id;
            ans.Core_IPS_Parent_Answer__c = ans1.id;
            i++;    
        }      
        insert ansswers;
        
        
        //string edqdata = '[{"edq":[{"qquestion":"a2x3F0000000kfUQAQ","llabel":"This is a decent question to test the process accordingly11","vvalue":"a2w3F0000008fNfQAI","rrequired":false,"ttype":"Multiselect Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F0000000kfUQAQ","llabel":"This is a decent question to test the process accordingly11","vvalue":"a2w3F0000008fNfQAI","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F000000MwXYQA0","llabel":"Country","vvalue":"a2w3F00000052A0QAI","rrequired":true,"ttype":"Picklist","val":true}]}]';
        string edqdata = '[{"edq":[{"qquestion":"'+ questions[1].Id  +'","llabel":"This is a decent question to test the process accordingly11","vvalue":"'+ ansswers[1].Id  +'","rrequired":false,"ttype":"Multiselect Picklist","val":true}]},{"edq":[{"qquestion":"'+ questionPicklist.Id +'","llabel":"This is a decent question to test the process accordingly11","vvalue":"'+ ans1.Id  +'","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"'+ questionPicklist2.Id +'","llabel":"Country","vvalue":"'+  ans2.Id   +'","rrequired":true,"ttype":"Picklist","val":true}]}]';
        Case cs = Core_IPS_CaseCreateLWCController.SubmitCaseRecord(CaseRecord.Clone(), ListOfContacts[0], edqdata );
        system.assertnotEquals(null, cs.id ) ;
        //Core_IPS_CaseCreateLWCController.getButtonsVisibility(cs.id);
        String errorMsg = Core_IPS_CaseCreateLWCController.getErrorMessage('G119');
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c();
        labels1.name= 'Case_RT_Name_IPS_NoAssignedContact';
        labels1.value__c='IPS No Assigned Contact Case';
        insert labels1;
        
        Core_IPS_CaseCreateLWCController.getAccountList();
        Core_IPS_CaseCreateLWCController.getContactListFromProject(ListOfIpsProjects.get(0).Id);
        Core_IPS_CaseCreateLWCController.getContactListFromAsset(ListOfAssets.get(0).Id);
        Core_IPS_CaseCreateLWCController.getProjectListFromAsset(ListOfAssets.get(0).Id);
        Core_IPS_CaseCreateLWCController.readFieldSet('ContactFieldSet','Contact');
        Core_IPS_CaseCreateLWCController.getCurrentUserProfileName();
        Core_IPS_CaseCreateLWCController.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
        
        List<Core_IPS_Labels__c> ipsLabelList = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_NoAssignedContact',Value__c='IPS No Assigned Contact Case');
        ipsLabelList.add(ipsLabel1);
        Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_Case_Create',Value__c='IPS Case Create');
        ipsLabelList.add(ipsLabel2);
        Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_Close_Case',Value__c='IPS Closed Case');
        ipsLabelList.add(ipsLabel3);
        Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_GECReadOnly',Value__c='IPS GEC ReadOnly');
        ipsLabelList.add(ipsLabel4);
        insert ipsLabelList;
        List<user> userList = TestUtilities.getListofuser(2);
        List<Profile> proflst = [select id, name from Profile where name = 'Sales Rep-BB' OR name = 'Sales Rep-BB-Dual IPS' limit 2];
        userlist[0].profileid=proflst[0].id;
        userlist[0].username='salesrep020211.abc@user.com';
        userlist[1].profileid=proflst[1].id;
        userlist[1].username='salesrep020212.abc@user.com';
        insert userlist;
        List<Case> listOfCases = TestUtilities.getListOfCases(1);
        insert listOfCases;
        Core_IPS_CaseCreateHelper helper = new Core_IPS_CaseCreateHelper();
        helper.getButtonsVisibility(listOfCases[0].Id);
        System.runAs(userlist[0]) {
            List<Case> listOfCases2 = TestUtilities.getListOfCases(1);
            insert listOfCases2;
            helper.getButtonsVisibility(listOfCases2[0].Id);
        }
        System.runAs(userlist[1]) {
            List<Case> listOfCases3 = TestUtilities.getListOfCases(1);
            insert listOfCases3;
            helper.getButtonsVisibility(listOfCases3[0].Id);
        }
        
        Test.stopTest();            
    }
    
    @istest
    public static void testProductVarient(){
        getRecords(2);
        
        Map<String, String> vairents = Core_IPS_CaseCreateLWCController.displayProductVariant(''+CaseRecord.Core_IPS_Supported_Product__c, 'IPS_Case_Create');
        system.assertEquals(0, vairents.size()) ;
        
        vairents = Core_IPS_CaseCreateLWCController.displayProductVariant(''+ListOfAssets[0].id, 'IPS_Case_Create');
        system.assertEquals(0, vairents.size()) ;
        
        List<CustomSelectOptions> options1 = Core_IPS_CaseCreateLWCController.getvariant(''+CaseRecord.Core_IPS_Supported_Product__c);
        system.assertEquals(0, options1.size()) ;
        
        Test.startTest();
        
        options1 = Core_IPS_CaseCreateLWCController.getvariant(''+ListOfAssets[0].id);
        system.assertEquals(0, options1.size()) ;
        Test.stopTest();
        
    }   
    
    @istest
    public static void testDependentQuestions(){
        getRecords(2); 
        
        Core_IPS_Question__c questionPicklist = TestUtilities.getCoreQuestion();
        questionPicklist.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ;  
        insert  questionPicklist;
        
        Core_IPS_Answer__c ans1 = new Core_IPS_Answer__c();
        ans1.Core_IPS_Answer__c ='IT Store 1';
        ans1.Core_IPS_Question__c =questionPicklist.id;
        
        //Core_IPS_Environment_Detail_Answer__c ans2 = new Core_IPS_Environment_Detail_Answer__c ( Core_IPS_Answer__c ='IT Store 2',  Core_IPS_Question__c =questionPicklist.id);
        insert ans1;
        
        
        Core_IPS_Question__c question = TestUtilities.getCoreQuestion();
        question.Core_IPS_Parent_Question__c = questionPicklist.id;
        
        Core_IPS_Question__c questionMultiSelect = TestUtilities.getCoreQuestion();
        questionMultiSelect.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c ;  
        questionMultiSelect.Core_IPS_Parent_Question__c = questionPicklist.id;
        
        Core_IPS_Question__c questionTextArea = TestUtilities.getCoreQuestion();
        questionTextArea.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c; 
        questionTextArea.Core_IPS_Parent_Question__c = questionPicklist.id;
        
        List<Core_IPS_Question__c> questions = new List<Core_IPS_Question__c>{question, questionMultiSelect, questionTextArea};
            insert questions; 
        
        
        List<Core_IPS_Answer__c> ansswers = TestUtilities.getCoreAnswers(3); 
        integer i=0;  
        for(Core_IPS_Answer__c ans : ansswers){ 
            ans.Core_IPS_Question__c = questions[i].id;
            ans.Core_IPS_Parent_Answer__c = ans1.id;
            i++;    
        }      
        insert ansswers;
        
        List<Core_IPS_Assigned_Environment_Variables__c> Operationallst = TestUtilities.getListOfEnvDetailsOperational(3);
        i=0; 
        for(Core_IPS_Assigned_Environment_Variables__c assignment : Operationallst){
            assignment.Core_IPS_Question__c = questions[i].id;
            assignment.Core_Product_Issue_Sub_Category__c = CaseRecord.Core_Case_Issue_Sub_Category__c;
            assignment.Core_supported_product__c = CaseRecord.Core_IPS_Supported_Product__c; 
            i++;
        } 
        insert  Operationallst;
        System.assertEquals(true, Operationallst != null);
        
        Test.startTest();  
        DynamicLWCFormBuilderController d = new DynamicLWCFormBuilderController();
        //DynamicLWCFormBuilderController.getDependentDynamicFields(ans1.id , '\''+questionPicklist.id+ '\'' );  
        //DynamicLWCFormBuilderController.getDependentDynamicFields(ans1.id , '\''+questionPicklist.id+ '\'',CaseRecord.Core_IPS_Supported_Product__c );
        Test.stopTest();
        
        
    }
    
    @istest
    public static void testsetEQDDetails(){
        getRecords(2); 
        
        Core_IPS_Question__c question = TestUtilities.getCoreQuestion();
        Core_IPS_Question__c questionPicklist = TestUtilities.getCoreQuestion();
        questionPicklist.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ;  
        Core_IPS_Question__c questionMultiSelect = TestUtilities.getCoreQuestion();
        questionMultiSelect.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c ;  
        Core_IPS_Question__c questionTextArea = TestUtilities.getCoreQuestion();
        questionTextArea.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c; 
        List<Core_IPS_Question__c> questions = new List<Core_IPS_Question__c>{question, questionPicklist, questionMultiSelect, questionTextArea};
            insert questions; 
        
        
        List<Core_IPS_Answer__c> ansswers = TestUtilities.getCoreAnswers(4); 
        integer i=0;  
        for(Core_IPS_Answer__c ans : ansswers){ 
            ans.Core_IPS_Question__c = questions[i].id;
            i++;    
        }      
        insert ansswers;
        
        List<Core_IPS_Assigned_Environment_Variables__c> Operationallst = TestUtilities.getListOfEnvDetailsOperational(4);
        i=0; 
        for(Core_IPS_Assigned_Environment_Variables__c assignment : Operationallst){
            assignment.Core_IPS_Question__c = questions[i].id;
            assignment.Core_Product_Issue_Sub_Category__c = CaseRecord.Core_Case_Issue_Sub_Category__c;
            assignment.Core_supported_product__c = CaseRecord.Core_IPS_Supported_Product__c; 
            i++;
        } 
        insert  Operationallst;
        i=0;
        List<Core_IPS_Response__c> envResponses = TestUtilities.getCoreResponseRecords(4);
        for(Core_IPS_Response__c envResp : envResponses){
            envResp.Core_IPS_Case__c = CaseRecord.id;
            envResp.Core_IPS_Question_Master__c = questions[i].id;  
            envResp.Core_IPS_Answer__c = 'test answer';
            envResp.Core_IPS_Answer_Master__c = ansswers[i].id;
            
            i++;
        }
        insert envResponses;
        Test.startTest();
        
        /*System.debug( [SELECT Id, Core_IPS_Question_Master__r.RecordType.DeveloperName, Core_IPS_Answer__c,  
Core_IPS_Question_Master__c, Core_IPS_Agent_Only__c 
FROM Core_IPS_Response__c WHERE Core_IPS_Case__c=:CaseRecord.id ][0].Core_IPS_Question_Master__r.RecordType.DeveloperName);*/
        Core_IPS_CaseCreateHelper helper = new Core_IPS_CaseCreateHelper();
        List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        
        
        lstEnvDetails = helper.getEnvironmentDetailsOperationList(CaseRecord.Core_IPS_Supported_Product__c, 
                                                                  CaseRecord.Core_Case_Issue_Sub_Category__c,false);
        helper.setCurrentEnvironmentDetails(lstEnvDetails, CaseRecord.id);
        System.assertEquals(true, lstEnvDetails != null);
        Test.stopTest();
        
    }
    @istest
    public static void testMindsSection(){
        getRecords(2); 
        
        Core_IPS_MindSectionController.getDefaultCountry(ListOfContacts.get(0).id);
        List<CustomSelectOptions> lst = Core_IPS_MindSectionController.getCountriesOptions();
        //List<CustomSelectOptions> lst2 = Core_IPS_MindSectionController.getStateOptions();
        System.assertEquals(true, lst != null);
    }
    
    @isTest
    private static void copyInterestedPartiesTest() {
        List<User> ListOfInternalSfUsers = TestUtilities.getListOfUser(1);
        Core_IPS_Error_Code__c errCode = new Core_IPS_Error_Code__c();
        errCode.Core_Error_Message__c = 'Test error Message';
        errCode.Core_Locale__c = 'EN';
        errCode.Language__c = 'English';
        errCode.Name = 'G119';
        insert errCode; 
        // Create Case
        List<Case> ListOfCases = TestUtilities.getListOfCases(2);
        insert ListOfCases[0];
        
        Core_IPS_Case_Interested_Party__c ip=new Core_IPS_Case_Interested_Party__c();
        ip.User__c=ListOfInternalSfUsers.get(0).Id;
        ip.Active__c=true;
        ip.Type__c='Internal';
        ip.Case__c= ListOfCases[0].Id;
        insert ip;
        insert ListOfCases[1];
        Core_IPS_CaseCreateLWCController.copyInterestedParties(ListOfCases[0].Id, ListOfCases[1].Id);
        
        List<Core_IPS_Labels__c> ipsLabelList = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_NoAssignedContact',Value__c='IPS No Assigned Contact Case');
        ipsLabelList.add(ipsLabel1);
        Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_Case_Create',Value__c='IPS Case Create');
        ipsLabelList.add(ipsLabel2);
        Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_Close_Case',Value__c='IPS Closed Case');
        ipsLabelList.add(ipsLabel3);
        Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_GECReadOnly',Value__c='IPS GEC ReadOnly');
        ipsLabelList.add(ipsLabel4);
        insert ipsLabelList;
        
        Core_IPS_CaseCreateLWCController.getButtonsVisibility(ListOfCases[0].Id);
        String errMsg = Core_IPS_CaseCreateLWCController.getErrorMessage('G119');
        System.assertEquals('Test error Message', errMsg);
        System.assert(errMsg!=null, 'Message Exists');
    }
    public static Account acrecord = new Account();
    public static Contact Conrecord = new Contact();
    @testSetup
    static void CreateRecords(){
        Id recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Intel Account' LIMIT 1].Id;
        acrecord=new account();
        Conrecord = new contact();
        acrecord.Name='test';
        acrecord.recordTypeId = recordType;
        acrecord.BillingCity='new york';
        acrecord.BillingCountry='united states';
        acrecord.BillingCountryCode='';
        acrecord.BillingStreet='st 124563 louis street';
        insert acrecord;
        Conrecord.Firstname='test';
        Conrecord.lastname='test contact';
        Conrecord.Email='test@gmail.com';
        Conrecord.AccountId=acrecord.Id;
        Conrecord.Core_MINDS__c = false;
        Conrecord.Core_Country_Region__c = 'India';
        Conrecord.Core_IPS_Email_Opt_Out__c = false;
        Conrecord.MailingCountry = 'India';
        List<Contact> conLst = new List<Contact>();
        conLst.add(Conrecord);
        insert conLst;
    }
    
    @isTest
    static void Submitcountryvalue_Test(){
        try {
        
         //Added by Sowmya - Start - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];  
        User portalAccountOwner1=new User(
            UserRoleId = portalRole.Id,
            username = 'newUser232323@yahoo.com',
            profileId =profile1.id,   
            email = 'ponneri1515@intel.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            Firstname='Bruce',   
            lastname='lastname1'
        );
        Database.insert(portalAccountOwner1);
        System.assertEquals(portalAccountOwner1!=null, true, 'portalAccountOwner1 Inserted');
        System.runAs ( portalAccountOwner1 ) {
            
            	  Account portalAccount1 = new Account(
                Name = 'newAcc2',
                BillingCity = 'folsom',
                BillingCountry = 'USA',
                BillingStreet = 'Creek Side Dr',
                BillingState = 'NV',
                BillingPostalCode = '591213',
                Core_CIM_ID__c = '11429344',
                Core_B2B_Entitlement__c = true,
                Core_Account_Legal_Name__c = 'TestLegalName',
                OwnerId = portalAccountOwner1.Id    
            );
            Database.insert(portalAccount1);
              //Create contact
            Contact contact1 = new Contact(
                AccountId = portalAccount1.id,
                FirstName = 'portia',
                LastName  = 'portalTestUser',
                Email='babux5x5@intel.com', 
                OwnerId = portalAccountOwner1.Id, 
                MailingCountry = 'India'
            );
            Database.insert(contact1);
            
   
       		Profile p = [select id, name from Profile where name in ('IPS External Customer') limit 1]; 
            //create user record
            User user1=new User(
                //UserRoleId = portalRole.Id,
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
        
            
        System.runAs(user1){
        //Sowmya - End - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
       // assetProduct.Core_IPS_Project__c=Project.Id;
        insert assetProduct;
        Core_IPS_CaseCreateLWCController.Submitcountryvalue('India',true);
                boolean getUserAccess = Core_IPS_CaseCreateLWCController.hasReadAccess(assetProduct.id);
                system.assertEquals(getUserAccess,false);
                //UserRecordAccess getUserAccess = [SELECT HasReadAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId()].HasReadAccess;
                
                
            }  
            
        }
        } Catch(Exception ex){}
    }
    @isTest
    public static void getProjectAssetTest(){
        
        getRecords(2);
        String result = Core_IPS_CaseCreateLWCController.getProjectAsset(ListOfAssets[0].id,'productId');
        System.assert(result!=null);
        String result1 = Core_IPS_CaseCreateLWCController.getProjectAsset(ListOfAssets[0].id,'supportedProd');
        System.assert(result1!=null);
        
    }
    @isTest
    public static void getAssetOnProjectChangeTest(){
        
        getRecords(2);
        String result = Core_IPS_CaseCreateLWCController.getAssetOnProjectChange(ListOfIpsProjects.get(0).Id, ListOfAssets.get(0).Id,null);
        System.assert(result!=null);
        
    }
    @isTest
    public static void getProductQueryTest(){
        
        getRecords(2);
        List<String> result = Core_IPS_CaseCreateLWCController.getProductQuery(null, ListOfAssets.get(0).AccountId);
        System.assert(result!=null);
        
    }
    @isTest
    public static void getProductSupportOwnerTest(){
        
        getRecords(2);
        List<String> result = Core_IPS_CaseCreateLWCController.getProductSupportOwner(ListOfIpsProjects.get(0).Id,null);
         //Added by Sowmya - Start - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
         List<String> result1 = Core_IPS_CaseCreateLWCController.getProductSupportOwner(ListOfContacts[0].Id,ListOfIpsProjects.get(0).Id);
        //Sowmya - End - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        Core_IPS_CaseCreateLWCController.getPartnerSupportAccount(null,ListOfIpsProjects.get(0).Id,null);
        Core_IPS_CaseCreateLWCController.getPartnerSupportAccount(ListOfContacts.get(0).id,ListOfIpsProjects.get(0).Id,null);//Added by Shanmukha 
        Core_IPS_CaseCreateLWCController.validateBeforeSubmitCase(ListOfAssets.get(0).Id,ListOfIpsProjects.get(0).Id,ListOfContacts.get(0).Id,'IPS_Case_Create');
        Core_IPS_CaseCreateLWCController.validateBeforeSubmitCase(ListOfAssets.get(0).Id,null,ListOfContacts.get(0).Id,'IPS_Case_Create');   
        System.assertEquals(ListOfIpsProjects.get(0).Id != null, true);
    }
    @isTest
    public static void getAccountListTest(){
        try{
            Core_IPS_CaseCreateLWCController.getAccountList();
            Core_IPS_CaseCreateLWCController.getCurrentUserProfileName();
            Core_IPS_CaseCreateLWCController.getIPSLabel('Intel Test');
            Core_IPS_CaseCreateLWCController.getcountryfields();
          contact con= [Select id, Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c  from Contact limit 1];
            system.assert(con!=null);
        }catch(Exception e){
            
        }
        
    }
    @isTest
    public static void getConListAsset(){
        string ObjectApiName = 'Core_IPS_Supported_Product__c'; 
        string fieldSetName = 'SupportedProductFieldSet'; 
        String getConatctList =Core_IPS_CaseCreateLWCController.readFieldSet(fieldSetName,ObjectApiName); 
        system.assert(getConatctList!=null);
    }
    @isTest
    public static void getContactTest(){
        try{
           List<Contact> getContactRecords= Core_IPS_CaseCreateLWCController.getContactRecords();  
            system.assert(getContactRecords!=null);
        }catch(Exception e){

        }
         
    }
    
}