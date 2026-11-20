/****************************************************************************************************************************************
* Class Name  : PSS_SolutionCatResultTriggerHelper_Test  
* Version     : 1.0 
* Created Date: 18-06-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* MP Team - Sooriya			18-06-2021				  Test class for PSS_SolutionCategoryResultTriggerHelper
*****************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionCatResultTriggerHelper_Test {
    
    // @testSetup
    // Public static void testDataSetup(){
        
    //     Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
    //     Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
    //     Contact con = PMP_TestDataUtility.createContact(acc.Id,true);
        
    //     PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
    //     companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
    //     companyInfo1.PMP_One_Partner_ID__c = acc.Id;
    //     update companyInfo1;
        
    //     Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount2', devRecordTypeId, true);
    //     Contact con2 = PMP_TestDataUtility.createContact(acc2.Id,true);
        
    //     PMP_Company__c companyInfo2 = PMP_TestDataUtility.createCompanyInformation('test intel company2', acc2.Id, true);
    //     companyInfo2.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
    //     companyInfo2.PMP_One_Partner_ID__c = acc2.Id;
    //     update companyInfo2;
        
    //     ArdiraSurvey__Survey__c survey=new ArdiraSurvey__Survey__c();
    //     survey.ArdiraSurvey__CNav_Pagination__c='Section';
    //     survey.Name='Solution Survey New';
    //     survey.ArdiraSurvey__Status__c='Open';
    //     insert survey;
        
    //    List<PMP_Static_Data__mdt> surveyIds=[select id,Label, Value__c from PMP_Static_Data__mdt where Label='PSS Category Scoring Survey' LIMIT 1];
			
        
    //     ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createSolution();
    //     surveyResult1.PSS_Proposal_Name_Txt__c='TestSurveyResult1';
    //     surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
    //     surveyResult1.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
    //     surveyResult1.PSS_Partner_Account_Id__c = acc.Id;
    //     surveyResult1.PSS_Programs_Applicable_Nm__c = 'MRS;RRK';
    //     surveyResult1.PSS_Company_Id__c = companyInfo1.Id;
    //     surveyResult1.ArdiraSurvey__Survey__c = survey.Id;//surveyIds[0].Value__c;
    //     surveyResult1.PSS_Fail_Fast_Status_Nm__c = 'Pass';
        
    //     insert surveyResult1;
        
    //     ArdiraSurvey__Category__c surveyCategory = New ArdiraSurvey__Category__c ();
    //     surveyCategory.Name = 'MRS';
    //     surveyCategory.PSS_Category_Threshold_Value__c = 10;
    //     insert surveyCategory;
        
    //     ArdiraSurvey__Category__c surveyCategory1 = New ArdiraSurvey__Category__c ();
    //     surveyCategory1.Name = 'RRK';
    //     surveyCategory1.PSS_Category_Threshold_Value__c = 11;
    //     insert surveyCategory1;
        
    //     ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult1 = New ArdiraSurvey__Survey_Category_Result__c();
    //     surveyCategoryResult1.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
    //     surveyCategoryResult1.ArdiraSurvey__Category__c = surveyCategory.Id;
    //     surveyCategoryResult1.ArdiraSurvey__Score_Raw__c =10;
    //     insert surveyCategoryResult1;
        
    //     ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult2 = New ArdiraSurvey__Survey_Category_Result__c();
    //     surveyCategoryResult2.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
    //     surveyCategoryResult2.ArdiraSurvey__Category__c = surveyCategory1.Id;
    //     surveyCategoryResult2.ArdiraSurvey__Score_Raw__c =10;
    //     insert surveyCategoryResult2;
        
    //     ArdiraSurvey__Survey_Result__c surveyResult2 = PSS_TestDataUtility.createSolution();
    //     surveyResult2.PSS_Proposal_Name_Txt__c='TestSurveyResult2';
    //     surveyResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
    //     surveyResult2.ArdiraSurvey__Assigned_To_Contact__c = con2.Id;
    //     surveyResult2.PSS_Partner_Account_Id__c = acc2.Id;
    //     surveyResult2.PSS_Programs_Applicable_Nm__c = 'Intel Select';
    //     surveyResult2.PSS_Company_Id__c = companyInfo2.Id;
    //     surveyResult2.ArdiraSurvey__Survey__c = survey.Id;//surveyIds[0].Value__c;
    //     insert surveyResult2;
        
    //     /*ArdiraSurvey__Category__c surveyCategory2 = New ArdiraSurvey__Category__c ();
    //     surveyCategory2.Name = 'MRS';
    //     surveyCategory2.PSS_Category_Threshold_Value__c = 2;
    //     insert surveyCategory2;*/
        
    //     /*ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult3 = New ArdiraSurvey__Survey_Category_Result__c();
    //     surveyCategoryResult3.ArdiraSurvey__Survey_Result__c = surveyResult2.Id;
    //     surveyCategoryResult3.ArdiraSurvey__Category__c = surveyCategory.Id;
    //     surveyCategoryResult3.ArdiraSurvey__Score_Raw__c =2;
    //     insert surveyCategoryResult3;*/
        
       
        
    //     List<ArdiraSurvey__Question__c> questionList =New List<ArdiraSurvey__Question__c>();
    //     ArdiraSurvey__Question__c question1 = New ArdiraSurvey__Question__c();
    //     question1.PSS_Question_Unique_Key_Txt__c = PMP_Utility.getValue('PSS_Hidden_Question_Key');
    //     question1.ArdiraSurvey__Survey__c = survey.Id;
    //     questionList.add(question1); 
        
    //     insert questionList;
        
    //     List<ArdiraSurvey__Question_Result__c> questionResultList =New List<ArdiraSurvey__Question_Result__c>();
        
    //     ArdiraSurvey__Question_Result__c questionResult1 = New ArdiraSurvey__Question_Result__c();
    //     questionResult1.ArdiraSurvey__Question__c = question1.Id;
    //     questionResult1.ArdiraSurvey__Survey__c = survey.Id;
    //     questionResult1.ArdiraSurvey__Answered__c = true;
    //     questionResult1.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
    //     questionResult1.ArdiraSurvey__Answer_Text__c = 'test';
    //     questionResultList.add(questionResult1);  
        
    //     insert questionResultList;
    // }
    
    // @isTest
    // static void calculateCategoryScoreTest(){
        
    //     List<ArdiraSurvey__Survey_Category_Result__c> catResultList = [Select Id from ArdiraSurvey__Survey_Category_Result__c limit 10
    //                                                                   // where  (ArdiraSurvey__Survey_Result__r.PSS_Proposal_Name_Txt__c ='TestSurveyResult1'
    //                                                                   // OR ArdiraSurvey__Survey_Result__r.PSS_Proposal_Name_Txt__c ='TestSurveyResult2')
    //                                                                   ];
        
    //     Test.startTest();
    //     	PSS_SolutionCategoryResultTriggerHelper.calculateCategoryScore(catResultList);
    //     Test.stopTest();
        
    //     ArdiraSurvey__Survey_Result__c surveyResult = [Select Id ,PSS_Fail_Fast_Status_Nm__c from ArdiraSurvey__Survey_Result__c 
    //                                                      Where PSS_Proposal_Name_Txt__c ='TestSurveyResult1' Limit 1];
        
    //     system.assertEquals('Pass', surveyResult.PSS_Fail_Fast_Status_Nm__c, 'Passed');
        
    // }
    
}