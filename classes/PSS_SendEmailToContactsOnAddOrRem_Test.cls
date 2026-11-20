/****************************************************************************************************************************************
* Class Name  : PSS_SendEmailToContactsOnAddOrRem_Test 
* Version     : 1.0 
* Created Date: 08/26/2021
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Priyanka                                08/26/2021           Test class for the class PSS_SendEmailToContactsOnAddOrRemove
*****************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SendEmailToContactsOnAddOrRem_Test {
    /*@testSetup
    public static void testDataSetUp() {
        //User adminUser = new User(Id = UserInfo.GetUserId());
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        adminUser.userRoleId = role.id;
        update adminUser;
        System.runAs(adminUser){
            Account intelAccount;
            Contact conObj;
            User poeUser;
            string intelAccountRecTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();            
            intelAccount = PMP_TestDataUtility.createIntelAccount('Intel Account10B',intelAccountRecTypeId,true);
            conObj = PMP_TestDataUtility.createContact(intelAccount.id,true);
            Profile prf2=[SELECT Id  FROM Profile WHERE name='Partner' limit 1];
            
            poeUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = prf2.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                               FirstName='Test'                       
                              );
            poeUser.ContactId=conObj.Id;
            poeUser.isActive=true;
            insert poeUser;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PMP_External_Partner_Admin'];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = poeUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;
            
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
            
            //Inerting Document used in mail Header
            PMP_TestDataUtility.createDocument();
            List<EmailTemplate> emailTemplateList= new List<EmailTemplate>();
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.Body = 'test email body';
            validEmailTemplate.DeveloperName = 'SolutionShared';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            emailTemplateList.add(validEmailTemplate);
                        
            //Inerting Document used in mail Header
            //PMP_TestDataUtility.createDocument();
            //List<EmailTemplate> emailTemplateList= new List<EmailTemplate>();
            EmailTemplate validEmailTemplate2 = new EmailTemplate();
            validEmailTemplate2.isActive = true;
            validEmailTemplate2.Name = 'name';
            validEmailTemplate2.Body = 'test email body';
            validEmailTemplate2.DeveloperName = 'SolutionShared_Submitter';
            validEmailTemplate2.TemplateType = 'text';
            validEmailTemplate2.FolderId = UserInfo.getUserId();
            emailTemplateList.add(validEmailTemplate2);
            
            insert emailTemplateList;
            
            
            
            ArdiraSurvey__Survey__c survey = new ArdiraSurvey__Survey__c();
            survey.Name='test proposal';
            insert survey;
            List<ArdiraSurvey__Survey_Result__c> surveyResList= new List<ArdiraSurvey__Survey_Result__c>();
            ArdiraSurvey__Survey_Result__c surveyResult1=new ArdiraSurvey__Survey_Result__c();
            surveyResult1.ArdiraSurvey__Assessment_Result__c='test1';
            surveyResult1.ArdiraSurvey__Assigned_To_User__c=adminUser.Id;
            surveyResult1.ArdiraSurvey__Survey__c=survey.Id;
            surveyResult1.PSS_Solution_Submitter_UserId_Id__c=adminUser.Id;
            surveyResult1.PSS_Company_Id__c=companyInfo.Id;
            surveyResult1.PSS_Proposal_Name_Txt__c ='test proposal1';
            surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Update Required';
            surveyResList.add(surveyResult1);
            
            ArdiraSurvey__Survey_Result__c surveyResult2=new ArdiraSurvey__Survey_Result__c();
            surveyResult2.ArdiraSurvey__Assessment_Result__c='test2';
            surveyResult2.ArdiraSurvey__Assigned_To_User__c=poeUser.Id;
            surveyResult2.ArdiraSurvey__Survey__c=survey.Id;
            surveyResult2.PSS_Solution_Submitter_UserId_Id__c=poeUser.Id;
            surveyResult2.PSS_Company_Id__c=companyInfo.Id;
            surveyResult2.PSS_Proposal_Name_Txt__c   ='test proposal2';
            surveyResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Draft';
            surveyResList.add(surveyResult2);
            
            insert surveyResList;

            List<PSS_Solution_Contact_Association__c> conAssList= new List<PSS_Solution_Contact_Association__c>();
            PSS_Solution_Contact_Association__c conAss= new PSS_Solution_Contact_Association__c();
            conAss.PSS_Active__c=true;
            conAss.PSS_Assigned_User__c=poeUser.Id;
            conAss.PSS_Assigned_Contact__c=poeUser.ContactId;
            conAss.PSS_Solution_Name__c=surveyResult2.Id;
            conAssList.add(conAss);
            
            PSS_Solution_Contact_Association__c conAss2= new PSS_Solution_Contact_Association__c();
            conAss2.PSS_Active__c=true;
            conAss2.PSS_Assigned_User__c=poeUser.Id;
            conAss2.PSS_Assigned_Contact__c=poeUser.ContactId;
            conAss2.PSS_Solution_Name__c=surveyResult2.Id;
            conAssList.add(conAss2);
            
            
            PSS_Solution_Contact_Association__c conAss1= new PSS_Solution_Contact_Association__c();
            conAss1.PSS_Active__c=true;
            conAss1.PSS_Assigned_User__c=poeUser.Id;
            conAss1.PSS_Assigned_Contact__c=poeUser.ContactId;
            conAss1.PSS_Solution_Name__c=surveyResult1.Id;
            conAssList.add(conAss1);
            insert conAssList;
            
        }
    }
    public static testMethod void sendEmailTest(){
        EmailTemplate empTemp=[select id,Name,DeveloperName from EmailTemplate where DeveloperName ='SolutionShared' LIMIT 1];
        test.startTest();
        List<PSS_Solution_Contact_Association__c> solutions=[SELECT Id,PSS_Solution_Name__c,PSS_Solution_Name__r.PSS_Partner_Solution_Lifecycle_Status_Nm__c,
                                       PSS_Solution_Name__r.CreatedById,PSS_Solution_Name__r.CreatedBy.IsActive,PSS_Solution_Name__r.PSS_Solution_Submitter_UserId_Id__c,
                                       PSS_Solution_Name__r.PSS_Solution_Submitter_UserId_Id__r.IsActive,
                                       PSS_Assigned_User__c,PSS_Assigned_Contact__c,PSS_Assigned_Contact__r.Name
                                                             FROM PSS_Solution_Contact_Association__c limit 3];
        List<PSS_SendEmailToContactsOnAddOrRemove.ContactAssociationWrapper> reqwrplist = new List<PSS_SendEmailToContactsOnAddOrRemove.ContactAssociationWrapper>();
        PSS_SendEmailToContactsOnAddOrRemove.ContactAssociationWrapper req1 = new PSS_SendEmailToContactsOnAddOrRemove.ContactAssociationWrapper();
        req1.contactAssId = solutions[0].Id;
        req1.templateName=empTemp.DeveloperName;
        reqwrplist.add(req1);
        PSS_SendEmailToContactsOnAddOrRemove.ContactAssociationWrapper req2 = new PSS_SendEmailToContactsOnAddOrRemove.ContactAssociationWrapper();
        req2.contactAssId = solutions[1].Id;
        req2.templateName=empTemp.DeveloperName;
        reqwrplist.add(req2);
        
        PSS_SendEmailToContactsOnAddOrRemove.ContactAssociationWrapper req3 = new PSS_SendEmailToContactsOnAddOrRemove.ContactAssociationWrapper();
        req3.contactAssId = solutions[2].Id;
        req3.templateName=empTemp.DeveloperName;
        reqwrplist.add(req3);
        
        
        Integer beforeInvocations = Limits.getEmailInvocations();
        System.assertEquals(0,beforeInvocations,'no email sent');
        PSS_SendEmailToContactsOnAddOrRemove.sendEmailToContacts(reqwrplist);
        Integer afterInvocation = Limits.getEmailInvocations();
        System.assertNotEquals(0,afterInvocation,'email sent');
        test.stopTest(); 
    }*/
}