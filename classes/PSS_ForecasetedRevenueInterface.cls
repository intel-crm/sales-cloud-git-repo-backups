/*IPA2.0: US-TWC729-7976*/
@isTest 
global with sharing class PSS_ForecasetedRevenueInterface //implements ArdiraSurvey.SurveyProcessingInterface 
{
    // public static Object svProcessEvent(String eventInfo) {
    //     EventInfo evInfo = (EventInfo)JSON.deserialize(eventInfo, EventInfo.class);
    //     List<ResultData> resultList = new List<ResultData>();
        
    //     Set<Id> questionResultIds = New Set<Id>(); 
    //     for(QuestionData qData : evInfo.questionData){
    //         questionResultIds.add(qData.questionResultId);
    //     }
    //     String strategicAttribute='';
        
    //     List<ArdiraSurvey__Question_Result__c> intelProductsQuestionResults =  getIntelProductsQuestionResults(questionResultIds);
    //     if(!intelProductsQuestionResults.isEmpty()){
    //          strategicAttribute=String.isNotBlank(intelProductsQuestionResults.get(0).ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c)?
    //             				intelProductsQuestionResults.get(0).ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c:'';
           
    //         for(ArdiraSurvey__Question_Result__c aqr:intelProductsQuestionResults){
                
    //             if(aqr.ArdiraSurvey__Answer_Text__c.contains('OpenVINO')){
    //                 if(String.isNotBlank(strategicAttribute) && !strategicAttribute.contains('Vision'))
    //                     strategicAttribute =strategicAttribute+';'+'Vision;';
    //                 else if(!strategicAttribute.contains('Vision')) {
    //                     strategicAttribute ='Vision;' ;
    //                 }           
    //                 break;
    //             }
    //             else{
    //                 string attribute =strategicAttribute;
    //                 if(String.isNotBlank(strategicAttribute)){
    //                     list<string> statribute = strategicAttribute.split(';');
    //                     if(strategicAttribute.Contains('Vision')){
    //                         statribute.remove(statribute.indexOf('Vision'));
    //                         strategicAttribute = string.join(statribute,';');
    //                     }
    //                     else {
    //                         strategicAttribute = attribute;
    //                     }
    //                 }   
    //             }
    //         }
    //     }
        
    //      if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()){
    //                 ArdiraSurvey__Survey_Result__c solutionUpdate = New ArdiraSurvey__Survey_Result__c (Id=evInfo.surveyResultId); 
    //                 solutionUpdate.PSS_Strategic_Attributes_Nm__c=strategicAttribute;
    //                 update solutionUpdate;
    //             }
        
    //    return JSON.serialize(resultList);
    // }
    
    //  Public static List<ArdiraSurvey__Question_Result__c> getIntelProductsQuestionResults(Set<Id> questionResultIds){
            
    //         List<String> questionUniqueKeyList = PSS_StaticConstants.INTEL_PRODUCT_UNIQUE_KEYS;
    //         List<ArdiraSurvey__Question_Result__c> intelProductsList = New List<ArdiraSurvey__Question_Result__c>();
            
    //         if(!questionResultIds.isEmpty()){    
    //             //Querying all the intel products in survey result
    //             intelProductsList = [select Id, ArdiraSurvey__Survey_Result__c,ArdiraSurvey__Survey_Result__r.Id, ArdiraSurvey__Repeat_Position__c,
    //                                  ArdiraSurvey__Answer_Number__c,ArdiraSurvey__Answer_Text__c,ArdiraSurvey__Answered__c,
    //                                  ArdiraSurvey__Question__c,ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c, ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c
    //                                  from ArdiraSurvey__Question_Result__c where Id IN: questionResultIds
    //                                  AND ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c IN : questionUniqueKeyList];
    //         }
            
    //         return intelProductsList;
    //     }
    
    //  private class ResultData {
    //     Id questionId;
    //     ArdiraSurvey__Question_Result__c questionResults;
    // }
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
}