/***********************************************************************************************
* Class Name  : PSS_SurveyResultScoringInterface
* Version     : 1.0 
* Created Date: 08/06/2021
* Modification Log :
*
* Developer         Modification Log                 Date                Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Sooriya           M-01    : Original version       08/06/2021          Interface Class to pass the programs applicable fieldvalue of the survey result record to the 
                                                                         the answer text field of hidden question result record 
***********************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
global without sharing class PSS_SurveyResultScoringInterface //implements ArdiraSurvey.SurveyProcessingInterface 
{
    // public static Object svProcessEvent(String eventInfo) {
    //     EventInfo evInfo = (EventInfo)JSON.deserialize(eventInfo, EventInfo.class);
    //     List<ResultData> resultList = new List<ResultData>();
    //     /* Start logic here */
        
    //     //Hidden Question Unique text
    //     Final String hiddenQuestion = PMP_Utility.getValue('PSS_Hidden_Category_Scoring_Question');
    //     //System.debug(hiddenQuestion);
    //     ArdiraSurvey.SurveyVistaGlobalUtility.updateSurveyResultScore(evInfo.surveyResultId);
    //     List<String> queUniqueKeyList= new List<String>();
    //     queUniqueKeyList.add(hiddenQuestion);
    //     queUniqueKeyList.add(PSS_StaticConstants.IOTG_HIDDEN_CATEGORY_SCORING_NEW);
        
    //     String programsApplicable = getProgramsApplicable (evInfo.surveyResultId);
        
    //     //Querying Hidden Question result records using the Hidden question Unique key text and survey result id from json
    //     List<ArdiraSurvey__Question_Result__c> hiddenQuestionResult =[select Id,ArdiraSurvey__Answer_Text__c,ArdiraSurvey__Answered__c,ArdiraSurvey__Question__c,
    //                                                             ArdiraSurvey__Survey_Result__c from ArdiraSurvey__Question_Result__c 
    //                                                             where ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c in : queUniqueKeyList 
    //                                                             and ArdiraSurvey__Survey_Result__c = :evInfo.surveyResultId];   
    //     if(hiddenQuestionResult!=Null && !hiddenQuestionResult.isEmpty()){   
    //         for(ArdiraSurvey__Question_Result__c hiddenQue:hiddenQuestionResult){
    //             hiddenQue.ArdiraSurvey__Answer_Text__c = String.isNotBlank(programsApplicable) ? programsApplicable
    //                                                                 : PSS_StaticConstants.NO_CATEGORY;
    //             hiddenQue.ArdiraSurvey__Answered__c =true; 
                
    //             //Wrapper data with Hidden question details 
    //             ResultData result = New ResultData();
    //             result.questionId = hiddenQue.ArdiraSurvey__Question__c;
    //             result.questionResults = hiddenQue;
    //             resultList.add(result);
    //         }
    //     }
        
    //     /* End logic here */

    //     return JSON.serialize(resultList);
    // }
    
    // /**
    // * @author - Sooriya
    // * @description-To get the programs applicable values from the survey category result records
    // * @param surveyResultId - Survey result Id
    // * @return String - programs applicable values with ';' seperated
    // */
    
    // public static String getProgramsApplicable(Id surveyResultId) {
    //     String programsApplicable = '';
    //     //Iterating over the survey category result records using the survey result id
    //     for(ArdiraSurvey__Survey_Category_Result__c categoryResult : [Select id,ArdiraSurvey__Category__r.Name,ArdiraSurvey__Score_Raw__c,
    //                                                                   ArdiraSurvey__Category__r.PSS_Category_Threshold_Value__c 
    //                                                                   FROM ArdiraSurvey__Survey_Category_Result__c 
    //                                                                   Where ArdiraSurvey__Survey_Result__c =: surveyResultId]){
    //         //if category result raw score is greater than or equal to survey category threshold value then enter inside 
    //         if(categoryResult.ArdiraSurvey__Score_Raw__c >=categoryResult.ArdiraSurvey__Category__r.PSS_Category_Threshold_Value__c ){
    //             if(categoryResult.ArdiraSurvey__Category__r.Name != PSS_StaticConstants.INTEL_SELECT 
    //                && categoryResult.ArdiraSurvey__Category__r.Name != PSS_StaticConstants.INTEL_SCALE
    //                && categoryResult.ArdiraSurvey__Category__r.Name != PSS_StaticConstants.INTEL_DATA_CENTER){
    
    //             //category names seperated with ';'
    //             programsApplicable = String.isBlank(programsApplicable) ? categoryResult.ArdiraSurvey__Category__r.Name 
    //                                  :programsApplicable + ';' + categoryResult.ArdiraSurvey__Category__r.Name ;
    //             }
    //         }
    //    }
    //     return programsApplicable;
        
    // }
    
    //  /* EventInfo Class you will get it in parementer 'eventInfo' as a string and need to deserialize it */
    // private class EventInfo {
    //     String eventId;
    //     Id surveyResultId;
    //     Id currentSectionId;
    //     List<QuestionData> questionData;
    //     String selectedLanguage;
    // }
    // private class QuestionData {
    //     Id questionId;
    //     Id questionResultId;
    //     Integer rowNumber;
    // }
    // /* Response format pass as List */
    // private class ResultData {
    //     Id questionId;
    //     ArdiraSurvey__Question_Result__c questionResults;
    // }

}