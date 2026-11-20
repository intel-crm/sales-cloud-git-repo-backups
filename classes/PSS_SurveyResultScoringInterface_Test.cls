/*************************************************************************************************************************************************************************
* Class Name  : PSS_SurveyResultScoringInterface_Test
* Version     : 1.0 
* Created Date: 08/06/2021
* Modification Log :
*
* Developer         Modification Log                    Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Sooriya           M-01    : Original version          08/06/2021              Test class for the PSS_SurveyResultScoringInterface class
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SurveyResultScoringInterface_Test {
    
    /*@testSetup static void setup() {
       
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        
        PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
        companyInfo1.PMP_One_Partner_ID__c = acc.Id;
        update companyInfo1;
        
        ArdiraSurvey__Survey__c survey=new ArdiraSurvey__Survey__c();
        survey.ArdiraSurvey__CNav_Pagination__c='Section';
        survey.Name='Solution Survey New';
        survey.ArdiraSurvey__Status__c='Open';
        insert survey;
        
        ArdiraSurvey__Survey_Result__c surveyResult1 = PSS_TestDataUtility.createSolution();
        surveyResult1.PSS_Proposal_Name_Txt__c='TestSurveyResult1';
        surveyResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        surveyResult1.PSS_Partner_Account_Id__c = acc.Id;
        surveyResult1.PSS_Programs_Applicable_Nm__c = 'MRS';
        surveyResult1.PSS_Company_Id__c = companyInfo1.Id;
        surveyResult1.ArdiraSurvey__Survey__c = survey.Id;
        insert surveyResult1;
        
        List<ArdiraSurvey__Question__c> questionList =New List<ArdiraSurvey__Question__c>();
        ArdiraSurvey__Question__c question1 = New ArdiraSurvey__Question__c();
        question1.PSS_Question_Unique_Key_Txt__c = 'IOTG_IntelProduct';
        question1.ArdiraSurvey__Survey__c = survey.Id;
        questionList.add(question1); 
        
        ArdiraSurvey__Question__c question2 = New ArdiraSurvey__Question__c();
        question2.PSS_Question_Unique_Key_Txt__c = PMP_Utility.getValue('PSS_Hidden_Category_Scoring_Question');
        question2.ArdiraSurvey__Survey__c = survey.Id;
        questionList.add(question2); 
        
        insert questionList;
        
        List<ArdiraSurvey__Question_Result__c> questionResultList =New List<ArdiraSurvey__Question_Result__c>();
        ArdiraSurvey__Question_Result__c questionResult1 = New ArdiraSurvey__Question_Result__c();
        questionResult1.ArdiraSurvey__Repeat_Position__c = '001';
        questionResult1.ArdiraSurvey__Answer_Text__c ='Intel® Xeon SP Bronze';
        questionResult1.ArdiraSurvey__Question__c = question1.Id;
        questionResult1.ArdiraSurvey__Survey__c = survey.Id;
        questionResult1.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        questionResultList.add(questionResult1);  
        
        ArdiraSurvey__Question_Result__c questionResult2 = New ArdiraSurvey__Question_Result__c();
        questionResult2.ArdiraSurvey__Question__c = question2.Id;
        questionResult2.ArdiraSurvey__Survey__c = survey.Id;
        questionResult2.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        questionResultList.add(questionResult2);  
        
        insert questionResultList;
        
        ArdiraSurvey__Category__c surveyCategory1 = New ArdiraSurvey__Category__c ();
        surveyCategory1.Name = 'MRS';
        surveyCategory1.PSS_Category_Threshold_Value__c = 10;
        insert surveyCategory1;
        
        ArdiraSurvey__Survey_Category_Result__c surveyCategoryResult1 = New ArdiraSurvey__Survey_Category_Result__c();
        surveyCategoryResult1.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        surveyCategoryResult1.ArdiraSurvey__Category__c = surveyCategory1.Id;
        surveyCategoryResult1.ArdiraSurvey__Score_Raw__c =10;
        insert surveyCategoryResult1;
    }
    
    @isTest
    public static void svProcessEventTest(){
        ArdiraSurvey__Survey_Result__c surveyResult = [Select id from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c ='TestSurveyResult1'];
        List<ArdiraSurvey__Question__c> questionList = [Select id from ArdiraSurvey__Question__c where ArdiraSurvey__Survey__r.name ='Solution Survey New' ];
        List<ArdiraSurvey__Question_Result__c> questionResultList = [Select id from ArdiraSurvey__Question_Result__c where ArdiraSurvey__Survey_Result__c = :surveyResult.Id ];
        
        EventInfo eventInfo = New EventInfo();
        eventInfo.eventId = 'survey_processing';
        eventInfo.surveyResultId = surveyResult.Id;
        
        List<QuestionData> qdList = New List<QuestionData>();
        QuestionData qd1 = New QuestionData();
        qd1.questionId = questionList[0].Id;
        qd1.questionResultId = questionResultList[0].Id;
        qdList.add(qd1);
        
        eventInfo.questionData = qdList;
        String evtJSON = JSON.serialize(eventInfo);
        
        Test.startTest();
        PSS_SurveyResultScoringInterface.svProcessEvent(evtJSON);
        Test.stopTest();

        Map <String,Object> returnMap = (Map<String,Object>)JSON.deserializeUntyped(evtJSON);
        system.assertEquals('survey_processing', returnMap.get('eventId'), 'values are equal');
    }
    
    //To Generate the input Json
    private class EventInfo {
        String eventId;
        Id surveyResultId;
        Id currentSectionId;
        List<QuestionData> questionData;
        String selectedLanguage;
    }
    private class QuestionData {
        Id questionId;
        Id questionResultId;
        Integer rowNumber;
    }*/


}