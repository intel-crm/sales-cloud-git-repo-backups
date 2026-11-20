/*IPA2.0: US-TWC729-7976*/
@isTest
global without sharing class PSS_StrategicAttributeInterface //implements ArdiraSurvey.SurveyProcessingInterface
{
    /*public static Object svProcessEvent(String eventInfo) {
        EventInfo evInfo = (EventInfo)JSON.deserialize(eventInfo, EventInfo.class);
        List<ResultData> resultList = new List<ResultData>();
        
        List<ArdiraSurvey__Question_Result__c> surveyQuestionResultList = [select Id, ArdiraSurvey__Answer_Text__c,ArdiraSurvey__Question__c,
                                                                           ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c,
                                                                           ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c
                                                                           from ArdiraSurvey__Question_Result__c where  ArdiraSurvey__Survey_Result__r.Id =: evInfo.surveyResultId
                                                                           AND ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c =: PSS_StaticConstants.IOTG_VIRTUAL_LAYER];
        
        String strategicAttribute='';
        if(!surveyQuestionResultList.isEmpty()){
            strategicAttribute=String.isNotBlank(surveyQuestionResultList.get(0).ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c)?
                surveyQuestionResultList.get(0).ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c:'';
            
            for(ArdiraSurvey__Question_Result__c aqr:surveyQuestionResultList){
                if(aqr.ArdiraSurvey__Answer_Text__c=='Yes'){
                    
                    if(String.isNotBlank(strategicAttribute) && !strategicAttribute.contains(PSS_StaticConstants.WORKLOAD_CONSOLIDATION))
                        strategicAttribute =strategicAttribute+';'+PSS_StaticConstants.WORKLOAD_CONSOLIDATION;
                    else if(!strategicAttribute.contains(PSS_StaticConstants.WORKLOAD_CONSOLIDATION)){
                        strategicAttribute =PSS_StaticConstants.WORKLOAD_CONSOLIDATION ;
                    }
                    
                    break;
                }
                else if(aqr.ArdiraSurvey__Answer_Text__c=='No'){
                    
                    string str = PSS_StaticConstants.WORKLOAD_CONSOLIDATION;
                    string attribute =strategicAttribute;
                    list<string> statribute = strategicAttribute.split(';');
                    if(strategicAttribute.Contains(str)){
                        statribute.remove(statribute.indexOf(str));
                        strategicAttribute = string.join(statribute,';');
                        
                    }
                    else {
                        strategicAttribute = attribute;
                        
                    }
                    
                }
            }
        }
        surveyQuestionResultList.get(0).ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c=strategicAttribute;
        ResultData resData=new ResultData();
        resData.questionId=surveyQuestionResultList.get(0).ArdiraSurvey__Question__c;
        resData.questionResults=surveyQuestionResultList.get(0);
        resultList.add(resData);
        
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()){
            ArdiraSurvey__Survey_Result__c solutionUpdate = New ArdiraSurvey__Survey_Result__c (Id=evInfo.surveyResultId); 
            
            solutionUpdate.PSS_Strategic_Attributes_Nm__c=strategicAttribute;
            
            update solutionUpdate;
        }
        
        
        
        return JSON.serialize(resultList);
    }
    private class ResultData {
        Id questionId;
        ArdiraSurvey__Question_Result__c questionResults;
    }
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