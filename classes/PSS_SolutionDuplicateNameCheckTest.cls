/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionDuplicateNameCheckTest {
    /*@testSetup
    static void setup(){
        
        Profile salesRepPrf = [select id, name from Profile where name = 'Partner' Limit 1];
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole portalRole = [Select Id,Name,DeveloperName From UserRole Where DeveloperName = 'Admin' Limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id intelAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

        User partnerOwner = PSS_TestDataUtility.partnerAccountOwner();
        System.runAs ( thisUser ) {
            insert partnerOwner;
        }

        Account partnerAccount = PSS_TestDataUtility.createPartnerAccount('TestPartnerAccount2',devRecordTypeId,partnerOwner.Id);
        Account partnerAccount1 = PSS_TestDataUtility.createPartnerAccount('TestPartnerAccount3',devRecordTypeId,partnerOwner.Id);
        System.runAs ( thisUser ) {
            insert partnerAccount;
            insert partnerAccount1;
        }
        
        PMP_Company__c companyInfo1 = PSS_TestDataUtility.createCompany('intelCompany1',partnerAccount.Id,PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED);
        PMP_Company__c companyInfo2 = PSS_TestDataUtility.createCompany('intelCompany2',partnerAccount1.Id,PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED);

        ArdiraSurvey__Survey__c Survey = PSS_TestDataUtility.createSurvey();
        insert Survey;
        
       // User assignee = PSS_TestDataUtility.createTestUser(profile1.Id,'Admin','TestUser');
       //insert assignee;

        ArdiraSurvey__Survey_Result__c surveyResult = new ArdiraSurvey__Survey_Result__c();
        surveyResult.ArdiraSurvey__Survey__c = Survey.id;
        surveyResult.PSS_OPID_Account_Id__c = partnerAccount.id;
        surveyResult.PSS_Partner_Account_Id__c = partnerAccount1.id;
        surveyResult.PSS_Proposal_Name_Txt__c='TestDuplicateOffering1';
        surveyResult.PSS_Follow_up_Date_Dt__c=system.today()+2;
        surveyResult.PSS_Review_Scheduled_Date_dt__c =system.today()+10;
        surveyResult.ArdiraSurvey__Score_Raw__c=20;
        surveyResult.PSS_Company_Id__c=companyInfo1.id;
        surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Draft';
        surveyResult.ArdiraSurvey__Assigned_To_User__c = partnerOwner.Id;
        surveyResult.PSS_Solution_Category_Nm__c = 'DCG';
        insert surveyResult;
        
        ArdiraSurvey__Survey_Result__c surveyResult1 = new ArdiraSurvey__Survey_Result__c();
        surveyResult1.ArdiraSurvey__Survey__c = Survey.id;
        surveyResult1.PSS_OPID_Account_Id__c = partnerAccount1.id;
        surveyResult1.PSS_Proposal_Name_Txt__c='TestDuplicateOffering99';
        surveyResult1.PSS_Follow_up_Date_Dt__c=system.today()+2;
        surveyResult1.PSS_Review_Scheduled_Date_dt__c =system.today()+10;
        surveyResult1.ArdiraSurvey__Score_Raw__c=20;
        surveyResult1.PSS_Company_Id__c=companyInfo2.id;
        surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Draft';
        surveyResult1.ArdiraSurvey__Assigned_To_User__c = partnerOwner.Id;
        surveyResult1.PSS_Solution_Category_Nm__c = 'DCG';
        insert surveyResult1;
      
    }
    
    @isTest
    static void validateQuestionResponseV2Error(){
        
        ArdiraSurvey__Survey_Result__c asResults =[select id,Name,PSS_Proposal_Name_Txt__c,ArdiraSurvey__Survey__c,ArdiraSurvey__Survey__r.id,PSS_OPID_Account_Id__c,PSS_Partner_Account_Id__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='TestDuplicateOffering1' LIMIT 1];
       
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
         User partnerOwner = [ select Id from User where Email  ='test1234@example.com'];
       
        Account partnerAccount1 = PSS_TestDataUtility.createPartnerAccount('TestPartnerAccount09',devRecordTypeId,partnerOwner.Id);
        
         ArdiraSurvey__Survey_Result__c surveyResult1 = new ArdiraSurvey__Survey_Result__c();
        surveyResult1.ArdiraSurvey__Survey__c = asResults.ArdiraSurvey__Survey__r.id;
        surveyResult1.PSS_OPID_Account_Id__c = partnerAccount1.id;
        surveyResult1.PSS_Partner_Account_Id__c = partnerAccount1.id;
        surveyResult1.PSS_Proposal_Name_Txt__c='TestDuplicateOffering99';
        surveyResult1.PSS_Follow_up_Date_Dt__c=system.today()+2;
        surveyResult1.PSS_Review_Scheduled_Date_dt__c =system.today()+10;
        surveyResult1.ArdiraSurvey__Score_Raw__c=20;
       // surveyResult1.PSS_Company_Id__c=companyInfo2.id;
        surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Draft';
        surveyResult1.ArdiraSurvey__Assigned_To_User__c = partnerOwner.Id;
        surveyResult1.PSS_Solution_Category_Nm__c = 'DCG';
        Test.startTest();
        insert surveyResult1;
        system.assertEquals('Draft', surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
        PSS_SolutionDuplicateNameCheck cv= new PSS_SolutionDuplicateNameCheck();
        cv.validateQuestionResponseV2(asResults.ArdiraSurvey__Survey__r.Id,asResults.id,Null,'TestDuplicateOffering99');
        Test.stopTest();
    }
    
     @isTest
    static void validateQuestionResponseV2Sucess(){
        
        ArdiraSurvey__Survey_Result__c asResults =[select id,Name,PSS_OPID_Account_Id__c,PSS_Proposal_Name_Txt__c,ArdiraSurvey__Survey__c,ArdiraSurvey__Survey__r.id from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='TestDuplicateOffering1' LIMIT 1];
        system.assertEquals('TestDuplicateOffering1', asResults.PSS_Proposal_Name_Txt__c);
        Test.startTest();
        PSS_SolutionDuplicateNameCheck cv= new PSS_SolutionDuplicateNameCheck();
        cv.validateQuestionResponseV2(asResults.ArdiraSurvey__Survey__r.Id,asResults.id,Null,'TestDuplicateOffering2');
        Test.stopTest();
    }
    
    @isTest
    static void validateQuestionResponseV2Warning(){
        
        ArdiraSurvey__Survey_Result__c asResults =[select id,Name,PSS_Proposal_Name_Txt__c,ArdiraSurvey__Survey__c,ArdiraSurvey__Survey__r.id,PSS_OPID_Account_Id__c,PSS_Partner_Account_Id__c from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='TestDuplicateOffering1' LIMIT 1];
       Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
         User partnerOwner = [ select Id from User where Email  ='test1234@example.com'];
       
        Account partnerAccount1 = PSS_TestDataUtility.createPartnerAccount('TestPartnerAccount09',devRecordTypeId,partnerOwner.Id);
        
         ArdiraSurvey__Survey_Result__c surveyResult1 = new ArdiraSurvey__Survey_Result__c();
        surveyResult1.ArdiraSurvey__Survey__c = asResults.ArdiraSurvey__Survey__r.id;
        surveyResult1.PSS_OPID_Account_Id__c = partnerAccount1.id;
        surveyResult1.PSS_Partner_Account_Id__c = partnerAccount1.id;
        surveyResult1.PSS_Proposal_Name_Txt__c='TestDuplicateOffering99';
        surveyResult1.PSS_Follow_up_Date_Dt__c=system.today()+2;
        surveyResult1.PSS_Review_Scheduled_Date_dt__c =system.today()+10;
        surveyResult1.ArdiraSurvey__Score_Raw__c=20;
       // surveyResult1.PSS_Company_Id__c=companyInfo2.id;
        surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Draft';
        surveyResult1.ArdiraSurvey__Assigned_To_User__c = partnerOwner.Id;
        surveyResult1.PSS_Solution_Category_Nm__c = 'DCG';
        Test.startTest();
        insert surveyResult1;
        system.assertEquals('TestDuplicateOffering99', surveyResult1.PSS_Proposal_Name_Txt__c);
        PSS_SolutionDuplicateNameCheck cv= new PSS_SolutionDuplicateNameCheck();
        cv.validateQuestionResponseV2(asResults.ArdiraSurvey__Survey__r.Id,surveyResult1.id,Null,'TestDuplicateOffering1');
        Test.stopTest();
    }*/

}