//IPA2.0: US-TWC729-7976
@isTest
/*************************************************************************************************************************************************************************
* Class Name  : PSS_ActivationCallOnSolution 
* Version     : 1.0 
* Created Date: 4/06/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Hanuma              M-01    : Original version       4/06/2021                         Class for Activation call realted logic
**************************************************************************************************************************************************************************/
public without sharing class PSS_ActivationCallOnSolution {
     /**
    * @description Method to get solution result data based on solution Id
    * @param String RecordId
    * @return List<ArdiraSurvey__Survey_Result__c>
    **
    @AuraEnabled(cacheable=true)
    public static List<ArdiraSurvey__Survey_Result__c> getSurveyResult(String recordId){
        list<ArdiraSurvey__Survey_Result__c> surveyResult = new List<ArdiraSurvey__Survey_Result__c>();
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()){
            surveyResult = [Select Id, Name, PSS_Solution_Activation_Call_Date_dt__c,PSS_SolutionStatusActivationComments_Txt__c, PSS_Solution_Status_Nm__c FROM 
                                                            ArdiraSurvey__Survey_Result__c
                                                            WHERE
                                                            Id =: recordId];
        }
        return surveyResult;
    } */
    
    /*@AuraEnabled
    public static List<solutionListWrapper> getSurveyResult(String recordId){
        list<ArdiraSurvey__Survey_Result__c> surveyResult = new List<ArdiraSurvey__Survey_Result__c>();
        list<solutionListWrapper> solutionWrap = new list<solutionListWrapper>();
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()){
            surveyResult = [Select Id, Name, PSS_Solution_Activation_Call_Date_dt__c,
                            PSS_SolutionStatusActivationComments_Txt__c, PSS_Solution_Status_Nm__c,
                            PSS_Partner_Solution_Lifecycle_Status_Nm__c
                            FROM ArdiraSurvey__Survey_Result__c
                            WHERE Id =: recordId];
        }
        
        for(ArdiraSurvey__Survey_Result__c solutionResult : surveyResult){
            solutionListWrapper solWrap = new solutionListWrapper();
            solWrap.solutionStatus = solutionResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c;
            solWrap.solutionActivationStatus = solutionResult.PSS_Solution_Status_Nm__c;
            solWrap.solutionActivationDate = solutionResult.PSS_Solution_Activation_Call_Date_dt__c;
            solWrap.solutionActivationComments = solutionResult.PSS_SolutionStatusActivationComments_Txt__c;
            solutionWrap.add(solWrap);
        }
        
        return solutionWrap;
    }*/

     /**
    * @description method to update solution result data based on solution Id
    * @param List<Object> surveyResult
    * @return String recordId
    **/
    /*@AuraEnabled
    public static void updateResultRecord(List<Object> surveyResult, String recordId){
        list<ArdiraSurvey__Survey_Result__c> surveyAnswerResult = new List<ArdiraSurvey__Survey_Result__c>();
        List<String> answersValues = new List<String>();
        for(Object object1 : surveyResult){
            string string1 = (string)JSON.deserializeUntyped(JSON.serialize(object1));
            answersValues.add(String.valueOf(string1));
        }
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()){
            for(ArdiraSurvey__Survey_Result__c result : [Select Id, Name, PSS_Solution_Activation_Call_Date_dt__c ,
                                                        PSS_SolutionStatusActivationComments_Txt__c, PSS_Solution_Status_Nm__c 
                                                         FROM ArdiraSurvey__Survey_Result__c
                                                         WHERE Id =: recordId ]){
                                                        result.PSS_Solution_Activation_Call_Date_dt__c = Date.valueOf(answersValues[0]);
                                                        result.PSS_Solution_Status_Nm__c = string.valueOf(answersValues[1]);
                                                        result.PSS_SolutionStatusActivationComments_Txt__c = string.valueOf(answersValues[2]);
                                                        surveyAnswerResult.add(result);
            }
        }
        try{
            if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()){           
                update surveyAnswerResult;
            }
        }catch(DmlException e){
            throw e;
        }
    }
    
    public class solutionListWrapper{
        @AuraEnabled
        public string solutionStatus{get;set;}
        @AuraEnabled
        public string solutionActivationStatus{get;set;}
        @AuraEnabled
        public date solutionActivationDate{get;set;}
        @AuraEnabled
        public string solutionActivationComments{get;set;}
	}*/
}