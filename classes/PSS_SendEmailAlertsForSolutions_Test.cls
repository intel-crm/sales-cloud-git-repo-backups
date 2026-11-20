/****************************************************************************************************************************************
* Class Name  : PSS_SendEmailAlertsForSolutions_Test 
* Version     : 1.0 
* Created Date: 02/10/2021
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Priyanka                                02/10/2021           Test class for the class PSS_SendEmailAlertsForSolutions
*****************************************************************************************************************************************/

@isTest
public class PSS_SendEmailAlertsForSolutions_Test {
    /*@testSetup
    public static void testDataSetUp() {
     
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        adminUser.userRoleId = role.id;
        update adminUser;
        
        System.runAs(adminUser){
            User u1 =PMP_TestDataUtility.createInactiveUser(true);
            u1.IsActive = false;
            update u1;
            
            Account intelAccount;
            Contact conObj;
            User poeUser;
            // System.runAs(thisUser){
            string intelAccountRecTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
            intelAccount = PMP_TestDataUtility.createIntelAccount('Intel Account10B',intelAccountRecTypeId,true);
            conObj = PMP_TestDataUtility.createContact(intelAccount.id,true);
            Profile prf2=[SELECT Id  FROM Profile WHERE name='Partner' limit 1];
            //UserRole ur = [Select Id,PortalType, PortalAccountId From UserRole where PortalAccountId=:intelAccount.Id limit 1];
            poeUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = prf2.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                               FirstName='Test'                       
                              );
            poeUser.ContactId=conObj.Id;
            insert poeUser;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PMP_External_Partner_Admin'];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = poeUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;
            
            // String devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
            Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
            
            Account testAccount = PMP_TestDataUtility.createAccount('PartnerAccount',partnerRecordTypeId,true);
            PMP_Company__c companyInfo = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
                                                            PMP_Account_Id__c=testAccount.Id);
            companyInfo.PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile';
            insert companyInfo;
            
            Core_Account_Group_Member__c pag=new Core_Account_Group_Member__c();
            pag.Core_Partner_Account_Id__c=testAccount.Id;
            //pag.Core_MDA_Ind__c=false;
            pag.Core_Intel_Account_Id__c=intelAccount.Id;
            insert pag;
            
            Core_Apex_EmailNotification__c  emNotif=new Core_Apex_EmailNotification__c ();
            emNotif.name ='unique_name_addSomethingSpecialHere';
            emNotif.Core_Allowed_Permission_Nm__c='PMP_External_Partner_Admin';
            emNotif.Core_IsActive_Ind__c=true;
            emNotif.Core_Email_Template_Nm__c='unique_name_addSomethingSpecialHere';
            emNotif.Core_IsRecurring_Ind__c=false;
            insert emNotif;
            
            ArdiraSurvey__Survey__c survey = new ArdiraSurvey__Survey__c();
            survey.Name='test proposal';
            insert survey;
            ArdiraSurvey__Survey_Result__c surveyResult1=new ArdiraSurvey__Survey_Result__c();
            surveyResult1.ArdiraSurvey__Assessment_Result__c='test1';
            surveyResult1.ArdiraSurvey__Assigned_To_User__c=adminUser.Id;
            surveyResult1.ArdiraSurvey__Survey__c=survey.Id;
            surveyResult1.PSS_Solution_Submitter_UserId_Id__c=adminUser.Id;
            surveyResult1.PSS_Company_Id__c=companyInfo.Id;
            surveyResult1.PSS_Proposal_Name_Txt__c ='test proposal1';
            surveyResult1.PSS_Programs_Applicable_Nm__c='RRK;MRS';

            insert surveyResult1;
            
            ArdiraSurvey__Survey_Result__c surveyResult2=new ArdiraSurvey__Survey_Result__c();
            surveyResult2.ArdiraSurvey__Assessment_Result__c='test2';
            surveyResult2.ArdiraSurvey__Assigned_To_User__c=u1.Id;
            surveyResult2.ArdiraSurvey__Survey__c=survey.Id;
            surveyResult2.PSS_Solution_Submitter_UserId_Id__c=u1.Id;
            surveyResult2.PSS_Company_Id__c=companyInfo.Id;
            surveyResult2.PSS_Proposal_Name_Txt__c   ='test proposal2';
            surveyResult2.PSS_Programs_Applicable_Nm__c='RRK;MRS';
            surveyResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
            insert surveyResult2;
                        
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.Body = 'test email body';
            validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
            
        }
    }
    public static testMethod void sendEmailTest(){
        EmailTemplate empTemp=[select id,Name,DeveloperName from EmailTemplate where DeveloperName ='unique_name_addSomethingSpecialHere' LIMIT 1];
        test.startTest();
        List<ArdiraSurvey__Survey_Result__c> solutions = [select id, ownerId from ArdiraSurvey__Survey_Result__c  limit 2 ];
        List<PSS_SendEmailAlertsForSolutions.EmailWrapperForSolutions> reqwrplist = new List<PSS_SendEmailAlertsForSolutions.EmailWrapperForSolutions>();
        PSS_SendEmailAlertsForSolutions.EmailWrapperForSolutions req1 = new PSS_SendEmailAlertsForSolutions.EmailWrapperForSolutions();
        //solutions[0].PSS_Partner_Solution_Lifecycle_Status_Nm__c='Approved';
        //update solutions[0];
        req1.solutionId = solutions[0].Id;
        req1.templateName=empTemp.DeveloperName;
        reqwrplist.add(req1);
        
        PSS_SendEmailAlertsForSolutions.EmailWrapperForSolutions req2 = new PSS_SendEmailAlertsForSolutions.EmailWrapperForSolutions();
        req2.solutionId = solutions[1].Id;
        req2.templateName=empTemp.DeveloperName;
        reqwrplist.add(req2);

        Integer beforeInvocations = Limits.getEmailInvocations();
        System.assertEquals(0,beforeInvocations,'no email sent');
        PSS_SendEmailAlertsForSolutions.sendSolutionsEmailNotifications(reqwrplist);
        Integer afterInvocation = Limits.getEmailInvocations();
        System.assertNotEquals(0,afterInvocation,'email sent');
        test.stopTest(); 
    }*/
}