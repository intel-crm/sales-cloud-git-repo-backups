/****************************************************************************************************************************************
* Class Name  : PSS_TestDataUtility 
* Version     : 1.0 
* Created Date: 15-02-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh Riyan              16/02/2021                    Utility Class to create test data.
*****************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_TestDataUtility{


    /*public static Id intelAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    public static Id intelContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();
    public static UserRole portalRole = [Select Id,Name,DeveloperName From UserRole Where DeveloperName = 'Admin' Limit 1];
    public static Profile profile1 = [Select Id from Profile where name = 'System Administrator'];

    public static User createTestUser(Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = 
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@intel.com',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId);
        return tuser;
    }
    
    public static User partnerAccountOwner(){

        String orgId = UserInfo.getOrganizationId();
        String dateString = 
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;

        User portalAccountOwner = new User();
        portalAccountOwner.UserRoleId = portalRole.Id;
        portalAccountOwner.ProfileId = profile1.Id;
        portalAccountOwner.Alias = 'admUse2r';
        portalAccountOwner.Email='test1234@example.com';
        portalAccountOwner.EmailEncodingKey='UTF-8';
        portalAccountOwner.LastName='Test2';
        portalAccountOwner.LanguageLocaleKey='en_US';
        portalAccountOwner.FederationIdentifier ='8974563';
        portalAccountOwner.LocaleSidKey='en_US';
        portalAccountOwner.ProfileId = profile1.Id;
        portalAccountOwner.TimeZoneSidKey='America/Los_Angeles';
        portalAccountOwner.UserName = uniqueName + '@test' + orgId + '.org';
        portalAccountOwner.PortalRole = 'Manager';

        return portalAccountOwner;
    }

    public static Account createPartnerAccount(String accountName, Id accountRecordTypeId, Id portalAccountOwner){

        Account testAccount = new Account();
        testAccount.Name=accountName;
        testAccount.Core_Sales_Group__c='Global Accounts';
        testAccount.Core_Account_Type__c='Other';
        testAccount.Industry='Others';
        testAccount.RecordTypeId = accountRecordTypeId;
        testAccount.BillingStreet='1234 testAccountSetup';
        testAccount.BillingCity='testCity1';
        testAccount.BillingState='OR';
        testAccount.BillingCountry='USA';
        testAccount.BillingPostalCode='12345';
        testAccount.Core_CNDA_Number__c = '126545';
        testAccount.OwnerId = portalAccountOwner;

        return testAccount;
    }

    public static Contact createPartnerContact(String lastName, String emailId, Id accountId){

        Contact testContact = new Contact();
        testContact.FirstName='Test';
        testContact.Core_Set_ERPM_Status_Bypass__c = true;
        testContact.LastName=lastName;
        testContact.Email=emailId;
        testContact.AccountId=accountId;
        testContact.Core_Personal_Email_Indicator__c = false;
        testContact.Core_Enterprise_Id__c='12345';
        testContact.Core_AGS_Integration_Status__c='Success';
        testContact.Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId();
        testContact.Core_Login_Status__c ='deleted';

        return testContact;

    }

    public static User createPartnerUser(String lastName,String emailId,Id contactId){
       
        Profile partnerProfile = [select id, name from Profile where name = 'Partner' Limit 1];
        UserRole partnerRole = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];

        String orgId = UserInfo.getOrganizationId();
        String dateString = 
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;

        User user1 = new User();
        user1.Alias = 'admUse2r';
        user1.UserRoleId = partnerRole.Id;
        user1.Email =emailId;
        user1.EmailEncodingKey ='UTF-8';
        user1.LastName =lastName;
        user1.LanguageLocaleKey ='en_US';
        user1.FederationIdentifier =contactId + '9342657';
        user1.LocaleSidKey ='en_US';
        user1.ProfileId = partnerProfile.Id;
        user1.ContactId = contactId;
        user1.TimeZoneSidKey ='America/Los_Angeles';
        user1.UserName = uniqueName + '@test' + orgId + '.org';
        user1.PortalRole = 'Manager';
        user1.isActive = true;

        return user1;
    }

    public static PMP_Company__c createCompany(String companyName, Id accountId, String benefitType){

        PMP_Company__c company = new PMP_Company__c();
        company.Name = companyName;
        company.PMP_Account_Id__c = accountId;
        company.PMP_Account_Industry__c='Others';
        company.PMP_Is_Published_Ind__c=true;
        company.PMP_Partner_Benefit_Type__c = benefitType;
        company.PMP_One_Partner_ID__c = accountId;

        return company;
    }

    public static ArdiraSurvey__Survey_Result__c createSolution(){
     
        ArdiraSurvey__Survey__c survey = new ArdiraSurvey__Survey__c();
     
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
         
        //survey.Name = 'Test Survey'+dateString + Math.random();
        survey.Name = 'Test Survey'+dateString + Math.random()*10;
        survey.ArdiraSurvey__CNav_Pagination__c = 'Question';
        survey.ArdiraSurvey__Status__c = 'Draft';
        survey.ArdiraSurvey__Enable_Workflow__c=true;
        insert survey;
         
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
         
        user u = createTestUser(sysAdminProfile.Id,'Test','Name');
        insert u;
         
        ArdiraSurvey__Survey_Result__c surveyResult = new ArdiraSurvey__Survey_Result__c();
        surveyResult.ArdiraSurvey__Survey__c = survey.Id;
        surveyResult.ArdiraSurvey__Assigned_To_User__c = u.Id;
         
        return surveyResult;
     
    }

    public static ArdiraSurvey__Survey__c createSurvey(){

        ArdiraSurvey__Survey__c survey = new ArdiraSurvey__Survey__c();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
         
        survey.Name = 'Test Survey'+dateString;
        survey.ArdiraSurvey__CNav_Pagination__c = 'Question';
        survey.ArdiraSurvey__Status__c = 'Open';

        return survey;
    }

    public static ArdiraSurvey__Survey_Result__c createArdiraSolution(Id surveyId, Id companyId,Id partnerId){

        User assignee = PSS_TestDataUtility.createTestUser(profile1.Id,'Admin','TestUser');
        insert assignee;

        ArdiraSurvey__Survey_Result__c surveyResult = new ArdiraSurvey__Survey_Result__c();
        surveyResult.ArdiraSurvey__Survey__c = surveyId;
        surveyResult.PSS_Partner_Account_Id__c = partnerId;
        surveyResult.PSS_Proposal_Name_Txt__c='TestDuplicateOffering1';
        surveyResult.PSS_Follow_up_Date_Dt__c=system.today()+2;
        surveyResult.PSS_Review_Scheduled_Date_dt__c =system.today()+10;
        surveyResult.ArdiraSurvey__Score_Raw__c=20;
        surveyResult.PSS_Company_Id__c=companyId;
        surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Draft';
        surveyResult.ArdiraSurvey__Assigned_To_User__c = assignee.Id;
        surveyResult.PSS_Solution_Category_Nm__c = 'IOTG';

        return surveyResult;
    }
    
    public static ArdiraSurvey__Question__c createQuestion(Id surveyId){
        ArdiraSurvey__Question__c ques= new ArdiraSurvey__Question__c();
        ques.ArdiraSurvey__Survey__c= surveyId;
        ques.ArdiraSurvey__Question__c='Test';
        ques.ArdiraSurvey__Question_Plain_Text__c='Test';
        ques.ArdiraSurvey__Type__c='Text-Short';
        //ques.ArdiraSurvey__Logical_Id__c ='1234';
        return ques;
    }*/
}