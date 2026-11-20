/*************************************************************************************************************************************************************************
* Class Name  : PSS_SurveyResultProcessingInterface_Test
* Version     : 1.0 
* Created Date: 7/22/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Sooriya              M-01    : Original version       7/22/2021                              Test class for the PSS_SurveyResultProcessingInterface class
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SurveyResultProcessingInterface_Test {
        
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
        surveyResult1.PSS_Strategic_Attributes_Nm__c=PSS_StaticConstants.WORKLOAD_CONSOLIDATION;
        insert surveyResult1;
        
        List<ArdiraSurvey__Question__c> questionList =New List<ArdiraSurvey__Question__c>();
        ArdiraSurvey__Question__c question1 = New ArdiraSurvey__Question__c();
        question1.PSS_Question_Unique_Key_Txt__c = 'IOTG_IntelProduct';
        question1.ArdiraSurvey__Survey__c = survey.Id;
        questionList.add(question1);
        
        ArdiraSurvey__Question__c question2 = New ArdiraSurvey__Question__c();
        question2.PSS_Question_Unique_Key_Txt__c = 'IOTG_ProjectedQuantity';
        question2.ArdiraSurvey__Survey__c = survey.Id;
        questionList.add(question2);
        
        ArdiraSurvey__Question__c question3 = New ArdiraSurvey__Question__c();
        question3.PSS_Question_Unique_Key_Txt__c = PMP_Utility.getValue('PSS_Hidden_Question_Key');
        question3.ArdiraSurvey__Survey__c = survey.Id;
        questionList.add(question3);
        
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
        questionResult2.ArdiraSurvey__Repeat_Position__c = '001';
        questionResult2.ArdiraSurvey__Answer_Number__c = 1000;
        questionResult2.ArdiraSurvey__Answer_Text__c ='vcxvdxzv';
        questionResult2.ArdiraSurvey__Survey__c = survey.Id;
        questionResult2.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        questionResult2.ArdiraSurvey__Question__c = question2.Id;
        questionResultList.add(questionResult2);
        
        ArdiraSurvey__Question_Result__c questionResult3 = New ArdiraSurvey__Question_Result__c();
        questionResult3.ArdiraSurvey__Repeat_Position__c = '001';
        questionResult3.ArdiraSurvey__Answer_Text__c ='vxcvxcv';
        questionResult3.ArdiraSurvey__Survey__c = survey.Id;
        questionResult3.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        questionResult3.ArdiraSurvey__Question__c = question3.Id;
        questionResultList.add(questionResult3);
        
        
        
        
        ArdiraSurvey__Question_Result__c questionResult4 = New ArdiraSurvey__Question_Result__c();
        questionResult4.ArdiraSurvey__Repeat_Position__c = '001';
        questionResult4.ArdiraSurvey__Answer_Text__c ='Intel® Distribution of OpenVINO™ toolkit';
        questionResult4.ArdiraSurvey__Question__c = question1.Id;
        questionResult4.ArdiraSurvey__Survey__c = survey.Id;
        questionResult4.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        questionResultList.add(questionResult4);
        
        ArdiraSurvey__Question_Result__c questionResult5 = New ArdiraSurvey__Question_Result__c();
        questionResult5.ArdiraSurvey__Repeat_Position__c = '001';
        questionResult5.ArdiraSurvey__Answer_Number__c = 1000;
        questionResult5.ArdiraSurvey__Answer_Text__c ='vcxvdxzv';
        questionResult5.ArdiraSurvey__Survey__c = survey.Id;
        questionResult5.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        questionResult5.ArdiraSurvey__Question__c = question2.Id;
        questionResultList.add(questionResult5);
        
        ArdiraSurvey__Question_Result__c questionResult6 = New ArdiraSurvey__Question_Result__c();
        questionResult6.ArdiraSurvey__Repeat_Position__c = '001';
        questionResult6.ArdiraSurvey__Answer_Text__c ='vxcvxcv';
        questionResult6.ArdiraSurvey__Survey__c = survey.Id;
        questionResult6.ArdiraSurvey__Survey_Result__c = surveyResult1.Id;
        questionResult6.ArdiraSurvey__Question__c = question3.Id;
        questionResultList.add(questionResult6);
        
        insert questionResultList;
        
        PSS_Intel_Products__c intelProduct1 = New PSS_Intel_Products__c();
        intelProduct1.PSS_ASP__c = 1000;
        intelProduct1.Name = 'Intel® Xeon SP Bronze';
        intelProduct1.PSS_Product_Type_Txt__c = 'CPU';
        INSERT intelProduct1;

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
        QuestionData qd2 = New QuestionData();
        qd2.questionId = questionList[1].Id;
        qd2.questionResultId = questionResultList[1].Id;
        qdList.add(qd2);
        
        QuestionData qd3 = New QuestionData();
        qd3.questionId = questionList[2].Id;
        qd3.questionResultId = questionResultList[2].Id;
        qdList.add(qd3);
        
        eventInfo.questionData = qdList;
        String evtJSON = JSON.serialize(eventInfo);
        
        Test.startTest();
        PSS_SurveyResultProcessingInterface.svProcessEvent(evtJSON);
        Test.stopTest();

        Map <String,Object> returnMap = (Map<String,Object>)JSON.deserializeUntyped(evtJSON);
        system.assertEquals('survey_processing', returnMap.get('eventId'), 'values are equal');
    }
    
    
    
     @isTest
    public static void svProcessEventTest2(){
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
        QuestionData qd2 = New QuestionData();
        qd2.questionId = questionList[1].Id;
        qd2.questionResultId = questionResultList[1].Id;
        qdList.add(qd2);
        
         QuestionData qd3 = New QuestionData();
        qd3.questionId = questionList[2].Id;
        qd3.questionResultId = questionResultList[2].Id;
        qdList.add(qd3);
        
        QuestionData qd4 = New QuestionData();
        qd4.questionId = questionList[0].Id;
        qd4.questionResultId = questionResultList[3].Id;
        qdList.add(qd4);
        
        QuestionData qd5 = New QuestionData();
        qd5.questionId = questionList[1].Id;
        qd5.questionResultId = questionResultList[4].Id;
        qdList.add(qd5);
        
        QuestionData qd6 = New QuestionData();
        qd6.questionId = questionList[2].Id;
        qd6.questionResultId = questionResultList[5].Id;
        qdList.add(qd6);
        
        eventInfo.questionData = qdList;
        String evtJSON = JSON.serialize(eventInfo);
        
        Test.startTest();
        PSS_SurveyResultProcessingInterface.svProcessEvent(evtJSON);
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