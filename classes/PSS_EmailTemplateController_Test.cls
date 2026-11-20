/****************************************************************************************************************************************
* Class Name  : PSS_EmailTemplateController_Test 
* Version     : 1.0 
* Created Date: 02/12/2021
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Priyanka                                02/12/2021           Test class for the class PSS_EmailTemplateController
*****************************************************************************************************************************************/
//IPA2.0: US-TWC729-7976

@isTest
public class PSS_EmailTemplateController_Test {
/*    @testSetup static void testSetUp(){
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
        //testAccount.Core_Sales_Groups__c='PRC';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account accObj = new Account();//PMP_TestDataUtility.createIntelAccount('Test PAG Account',devRecordTypeId,true);
        accObj.RecordTypeId = devRecordTypeId;
        accObj.Name = 'Test PAG Account';       
        accObj.Core_Account_Country__c='India';
        //accObj.Core_Sales_Groups__c='PRC';
        accObj.Core_Account_Type__c='ODM';
        accObj.BillingStreet='Bangalore Central';
        accObj.BillingCity='Bangalore';
        accObj.BillingCountry='IND';
        accObj.BillingState='KA';
        accObj.BillingPostalCode='560029';
        accObj.Industry='Agriculture';
        insert accObj;
        
        PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
                                                        PMP_Account_Id__c=accObj.Id);
        insert testCompany;
        
        Core_Account_Group_Member__c acg=new Core_Account_Group_Member__c();
        acg.Core_Intel_Account_Id__c=testAccount.Id;
        acg.Core_Partner_Account_Id__c=accObj.Id;
        insert acg;*/
        
        /* pagMemberList = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where 
Core_Partner_Account_Id__c IN :accIdCompInfoMap.keySet()];*/
        //Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
        //User u = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
        //                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
        //               LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
        //             TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test', Contact = conObj);
        //insert u;
        //User u =PMP_TestDataUtility.createUser(true); 
        // u.=testAccount.Id;
        //update u;
        /*Folder folder = [SELECT Id from Folder WHERE DeveloperName= 'PMP_Marketplace_Images' LIMIT 1];
        Document doc = new Document(Name='IntelLogo',FolderId = folder.Id); 
        insert doc;
        ArdiraSurvey__Survey__c survey = new ArdiraSurvey__Survey__c();
        survey.Name='test proposal';
        insert survey;
        ArdiraSurvey__Survey_Result__c surveyResult=new ArdiraSurvey__Survey_Result__c();
        surveyResult.ArdiraSurvey__Assessment_Result__c='test';
        surveyResult.ArdiraSurvey__Assigned_To_User__c=u.Id;
        surveyResult.ArdiraSurvey__Survey__c=survey.Id;
        surveyResult.PSS_Solution_Submitter_UserId_Id__c=u.Id;
        surveyResult.PSS_Proposal_Name_Txt__c='test proposal';
        //surveyResult.ArdiraSurvey__Status__c='';
        surveyResult.PSS_Company_Id__c=testCompany.Id;
        insert surveyResult;
        surveyResult.ArdiraSurvey__Status__c='Approved';
        update surveyResult;*/
        /*ArdiraSurvey__Survey_Result__c surveyResult1=new ArdiraSurvey__Survey_Result__c();
surveyResult1.ArdiraSurvey__Assessment_Result__c='test';
surveyResult1.ArdiraSurvey__Assigned_To_User__c=u.Id;
surveyResult1.ArdiraSurvey__Survey__c=survey.Id;
surveyResult.PSS_Solution_Submitter_UserId_Id__c=u.Id;
surveyResult.ArdiraSurvey__Status__c='Approved';
surveyResult.PSS_Company_Id__c=testCompany.Id;
insert surveyResult1;*/
        
        /*PMP_TestDataUtility.createDocument();
        
        System.runAs(u){
            PSS_Solution_Contact_Association__c conAss1= new PSS_Solution_Contact_Association__c();
            conAss1.PSS_Active__c=true;
            conAss1.PSS_Assigned_User__c=u.Id;
            conAss1.PSS_Assigned_Contact__c=conObj.Id;
            conAss1.PSS_Solution_Name__c=surveyResult.Id;
            insert conAss1;
        }
        
    }
    @isTest
    public static void sendEmailTest(){
        
        Test.startTest();
        PSS_EmailTemplateController ctrl=new PSS_EmailTemplateController();
        ctrl.headerMessage = 'Solution Submitted Successfully';
        ArdiraSurvey__Survey_Result__c  existingSolution = [Select Id,PSS_Solution_Submitter_UserId_Id__c,ArdiraSurvey__Status__c,PSS_Company_Id__c 
                                                            from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='test proposal' limit 1];
        ctrl.solutionId = existingSolution.Id; 
        ArdiraSurvey__Survey_Result__c solution = ctrl.getSolutionData();
        String solutionEditURL = ctrl.getEditSolutionURL();
        String solutionCreateURL = ctrl.getCreateSolutionURL();
        String solutionPreviewURL = ctrl.getSolutionPreviewURL();
        String offeringURl =ctrl.getOfferingURL();
        String loginHomePageURL =ctrl.getLoginHomePageURL();
        List<PSS_Solution_Contact_Association__c> getAssociationDataToBeDisplayed =ctrl.getAssociationDataToBeDisplayed();
        String headerURL= ctrl.getHeaderURL();
        String PublishedOfferingURL = ctrl.getPublishedOfferingURL();
        String companyURL = ctrl.getcompanyURL();
        
        System.AssertNotEquals(solution.Id,null,PSS_EmailTemplateController.class.getName() + 'TestMethod: ' + 'sendEmailTest()' + ' Success');
        System.AssertNotEquals(solutionCreateURL,null,PSS_EmailTemplateController.class.getName() + 'TestMethod: ' + 'sendEmailTest()' + ' Success');
        System.AssertNotEquals(solutionEditURL,null,PSS_EmailTemplateController.class.getName() + 'TestMethod: ' + 'sendEmailTest()' + ' Success');
        System.AssertNotEquals(solutionPreviewURL,null,PSS_EmailTemplateController.class.getName() + 'TestMethod: ' + 'sendEmailTest()' + ' Success');
        System.AssertNotEquals(offeringURl,null,PSS_EmailTemplateController.class.getName() + 'TestMethod: ' + 'sendEmailTest()' + ' Success');
        System.AssertNotEquals(loginHomePageURL,null,PSS_EmailTemplateController.class.getName() + 'TestMethod: ' + 'sendEmailTest()' + ' Success');
        System.AssertNotEquals(headerURL,null,PSS_EmailTemplateController.class.getName() + 'TestMethod: ' + 'sendEmailTest()' + ' Success');
        
        PSS_EmailTemplateController ctrl1=new PSS_EmailTemplateController();
        ArdiraSurvey__Survey_Result__c solution1 = ctrl1.getSolutionData();
        ctrl1.solutionId = NULL;
        Test.stopTest();
    }*/
}