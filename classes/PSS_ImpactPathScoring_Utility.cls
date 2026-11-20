/*IPA2.0: US-TWC729-7976*/
@isTest 
public without sharing class PSS_ImpactPathScoring_Utility  //extends TriggerHandler
{    
    
//     Public static List<ArdiraSurvey__Survey_Result__c> calculateImpactPathScore(Map<Id, ArdiraSurvey__Survey_Result__c> surveyResultToProcess){
//         system.debug('surveyResultToProcess'+surveyResultToProcess);
//         Map<Id, ArdiraSurvey__Survey_Result__c> surveyResultChanged = new Map<Id, ArdiraSurvey__Survey_Result__c>();
//         List<ArdiraSurvey__Survey_Result__c>resultToUpdate = new List<ArdiraSurvey__Survey_Result__c>();

//         //Map<Id, Decimal> resultToUpdate = new Map<Id, Decimal>();
//         Map<Id, List<PSS_Impact_Path_Scoring_Range__c>> criteriaWithRangesMap = new Map <Id, List<PSS_Impact_Path_Scoring_Range__c>>();
        
//         if(surveyResultToProcess != null && !surveyResultToProcess.isEmpty()){
//             surveyResultChanged = new Map<ID, ArdiraSurvey__Survey_Result__c>([SELECT Id, Name, PSS_Impact_Path_Score__c,PSS_Solution_Impact_Path_Scoring__c,PSS_No_Of_Strategic_Attributes_Applicabl__c,PSS_Strategic_Attributes_Nm__c,PSS_Solution_Category_Nm__c,PSS_Programs_Applicable_Nm__c,
//                                                                                PSS_No_of_Geographies__c,PSS_Solution_Revenue_Projection__c,PSS_Solution_ASP_Profile_Value__c,PSS_No_of_Different_Intel_Technologies__c,
//                                                                                PSS_Strategic_area_DCG__c,PSS_DCG_solution_past_revenue__c,
//                                                                                PSS_Partner_Account_Id__c,PSS_Admin_Suggested_Benefit_Level__c,PSS_Admin_Suggested_Benefit_Level__r.Name,
//                                                                                PSS_System_Suggested_Benefit_Level__c,PSS_System_Suggested_Benefit_Level__r.Name,ArdiraSurvey__Score_Level__c,PSS_Impact_Path_Scoring__c, 
//                                                                                (SELECT id, name,ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c,ArdiraSurvey__Answer_Text__c
//                                                                                 FROM ArdiraSurvey__Question_Results__r
//                                                                                WHERE ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c != NULL),
//                                                                                (SELECT id, name,PSS_Impact_Path_Scoring_Criteria__c,PSS_Question_Impact_Path_Score__c,PSS_Impact_Path_Scoring_Criteria__r.PSS_Ardira_Question__c, 
//                                                                                 PSS_Impact_Path_Scoring_Criteria__r.PSS_Question_Unique_Key__c,PSS_Impact_Path_Scoring_Criteria__r.PSS_Solution_Category__c,
//                                                                                 PSS_Impact_Path_Scoring_Criteria__r.PSS_Survey_Result_Field_Name__c,PSS_Impact_Path_Scoring_Criteria__r.PSS_Weightage__c
//                                                                                 FROM Solution_with_Impact_Path_Scorings__r WHERE PSS_Impact_Path_Scoring_Criteria__r.PSS_Is_Active__c = true)
//                                                                                FROM ArdiraSurvey__Survey_Result__c 
//                                                                                Where Id in : surveyResultToProcess.keySet()]);
            
//             List<PSS_Impact_Path_Scoring_Criteria__c> criteriaList= [SELECT id, (SELECT id, PSS_Impact_Path_Scoring_Criteria__c,PSS_Logical_Operator__c,
//                                                                                  PSS_Response__c,PSS_Score_Value__c FROM Impact_Path_Scoring_Ranges__r 
//                                                                                  ORDER BY PSS_Score_Value__c DESC)
//                                                                      FROM PSS_Impact_Path_Scoring_Criteria__c
//                                                                      WHERE PSS_Is_Active__c=true];
//             for(PSS_Impact_Path_Scoring_Criteria__c criteria: criteriaList){
//                 criteriaWithRangesMap.put(criteria.id,criteria.Impact_Path_Scoring_Ranges__r);
//             }
            
//             List<PSS_Solution_with_Impact_Path_Scoring__c>	solutionWithScoringToUpdate = new List<PSS_Solution_with_Impact_Path_Scoring__c>();
//             if(surveyResultChanged != NULL && !surveyResultChanged.isEmpty()){
//                 for(Id resultId : surveyResultChanged.keySet()){
//                     Map<String, ArdiraSurvey__Question_Result__c> questionWithResultMap = new Map <String, ArdiraSurvey__Question_Result__c>();
//                     for(ArdiraSurvey__Question_Result__c queResult: surveyResultChanged.get(resultId).ArdiraSurvey__Question_Results__r){
//                         questionWithResultMap.put(queResult.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c,queResult);
//                     }
//                     List<PSS_Solution_with_Impact_Path_Scoring__c> solutionWithScoringList = surveyResultChanged.get(resultId).Solution_with_Impact_Path_Scorings__r;
//                     Decimal impactPathScore=0;
                    
//                     for(PSS_Solution_with_Impact_Path_Scoring__c solScore:solutionWithScoringList){
//                         object response = NULL;
//                         system.debug('solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Survey_Result_Field_Name__c'+solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Survey_Result_Field_Name__c);
//                         if(solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Survey_Result_Field_Name__c != Null){
//                             Sobject resultRecord=(Sobject) surveyResultChanged.get(resultId) ;
//                             //system.debug('resultRecord'+resultRecord);
//                             system.debug('solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Survey_Result_Field_Name__c'+solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Survey_Result_Field_Name__c);
//                             string fieldName= solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Survey_Result_Field_Name__c;
//                             //system.debug(fieldName);
                            
//                             response= resultRecord.get(fieldName);
                            
//                         }else if(solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Question_Unique_Key__c != Null){ //otherwise reponse will be directly fetched user's answer
//                             //system.debug('solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Question_Unique_Key__c '+solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Question_Unique_Key__c);
//                             if(questionWithResultMap.containsKey(solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Question_Unique_Key__c)){
//                                 response = (Object)questionWithResultMap.get(solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Question_Unique_Key__c).ArdiraSurvey__Answer_Text__c;
//                             }
//                         }
//                         //system.debug('response'+response);
//                         if(response != NULL){
//                             Decimal score= new PSS_ImpactPathScoring_Utility().getApplicableScore(response,criteriaWithRangesMap.get(solScore.PSS_Impact_Path_Scoring_Criteria__c));
//                             //system.debug('score level :' +score);
//                             solScore.PSS_Question_Impact_Path_Score__c = score * solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Weightage__c;
//                         	//system.debug('solScore.PSS_Question_Impact_Path_Score__c'+solScore.PSS_Question_Impact_Path_Score__c);
//                         }else if(response == NULL ){
//                             Decimal score= new PSS_ImpactPathScoring_Utility().getApplicableScore(0,criteriaWithRangesMap.get(solScore.PSS_Impact_Path_Scoring_Criteria__c));
//                             //system.debug('score level :' +score);
//                             solScore.PSS_Question_Impact_Path_Score__c = score * solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Weightage__c;
//                         	//system.debug('solScore.PSS_Question_Impact_Path_Score__c'+solScore.PSS_Question_Impact_Path_Score__c);
//                         }
//                         //solScore.PSS_Question_Impact_Path_Score__c = 0.75;
//                         system.debug('checking category');
//                         system.debug('surveyResultToProcess.get(resultId).PSS_Solution_Category_Nm__c '+surveyResultToProcess.get(resultId).PSS_Solution_Category_Nm__c);
//                         if(surveyResultToProcess.get(resultId).PSS_Solution_Category_Nm__c == solScore.PSS_Impact_Path_Scoring_Criteria__r.PSS_Solution_Category__c)
//                         	impactPathScore +=solScore.PSS_Question_Impact_Path_Score__c != NULL ?solScore.PSS_Question_Impact_Path_Score__c: 0;
//                          system.debug('impactPathScore inside'+impactPathScore);
//                     }
//                     ArdiraSurvey__Survey_Result__c resultRecord= surveyResultChanged.get(resultId);
//                     resultRecord.PSS_Impact_Path_Score__c=impactPathScore;
//                     resultRecord.PSS_Solution_Category_Nm__c=surveyResultToProcess.get(resultId).PSS_Solution_Category_Nm__c;
//                     resultRecord.PSS_Programs_Applicable_Nm__c=surveyResultToProcess.get(resultId).PSS_Programs_Applicable_Nm__c;
//                     system.debug('surveyResultToProcess.get(resultId).PSS_Solution_Category_Nm__c'+surveyResultToProcess.get(resultId).PSS_Solution_Category_Nm__c);
//                     system.debug('resultRecord.PSS_Impact_Path_Scoring__c '+resultRecord.PSS_Impact_Path_Scoring__c);
//                     //system.debug('surveyResultToProcess.get(resultId).PSS_Solution_Revenue_Projection__c '+surveyResultToProcess.get(resultId).PSS_Solution_Revenue_Projection__c);
//                     if(surveyResultToProcess.get(resultId).PSS_Solution_Category_Nm__c == 'IOTG'){
//                       resultRecord.PSS_Solution_Impact_Path_Scoring__c = impactPathScore;   
//                     }else{
//                       resultRecord.PSS_Solution_Impact_Path_Scoring__c = surveyResultToProcess.get(resultId).PSS_Solution_Revenue_Projection__c ;  
//                     }
//                     resultToUpdate.add(resultRecord);
//                     //Trigger.newMap.get(resultId).PSS_Impact_Path_Score__c= impactPathScore;
//                     solutionWithScoringToUpdate.addAll(solutionWithScoringList);
//                 }
//                 //system.debug('resultToUpdate'+resultToUpdate);
//                 /*for(ArdiraSurvey__Survey_Result__c resultRec: surveyResultList){
//                     resultRec.PSS_Impact_Path_Score__c = resultToUpdate.get(resultRec.id);
//                     system.debug('resultRec.PSS_Impact_Path_Score__c'+resultRec.PSS_Impact_Path_Score__c);
//                 }*/
//                 //system.debug('surveyResultList'+surveyResultList);
//                 //update resultToUpdate;
//                 update solutionWithScoringToUpdate;
               
                
//             }
//         }
//          return resultToUpdate;
        
//     }
    
//     Public Decimal getApplicableScore(Object response,List<PSS_Impact_Path_Scoring_Range__c> rangeList){
//         Decimal scoreValue=0;
//         PSS_ImpactPathScoring_Utility utilityInstance= new PSS_ImpactPathScoring_Utility();
//         for(PSS_Impact_Path_Scoring_Range__c range: rangeList){
//             //system.debug('range.PSS_Logical_Operator__c'+range.PSS_Logical_Operator__c);
//             if(range.PSS_Logical_Operator__c == 'Equal to'){
//                 //system.debug('inside equal');
//                 if(utilityInstance.isEqual(response,(Object)range.PSS_Response__c)){
//                     //system.debug('condition satisfied');
//                     scoreValue = range.PSS_Score_Value__c ;
//                     break;
//                 }
//             }
            
//             else if(range.PSS_Logical_Operator__c == 'Greater than'){
//                 //system.debug('inside Greater than');
//                 Boolean b=String.valueOf(response).isNumeric() && utilityInstance.isGreaterThan(response,(Object)range.PSS_Response__c);
//                 //system.debug('String.valueOf(response).isNumeric() && utilityInstance.isGreaterThan(response,(Object)range.PSS_Response__c '+b);
//                 if(String.valueOf(response).isNumeric() && utilityInstance.isGreaterThan(response,(Object)range.PSS_Response__c)){
//                     //system.debug('condition satisfied');
//                     scoreValue = range.PSS_Score_Value__c ;
//                     break;
//                 }
//             }
            
//             else if(range.PSS_Logical_Operator__c == 'Lower than'){
//                 //system.debug('inside Lower than');
//                 if(utilityInstance.isLowerThan(response,(Object)range.PSS_Response__c)){
//                     //system.debug('condition satisfied');
//                     scoreValue = range.PSS_Score_Value__c ;
//                     break;
//                 }
//             }
            
//             else if(range.PSS_Logical_Operator__c == 'Range'){
//                 //system.debug('inside Range');
//                 String responseToCompareString =String.valueOf(range.PSS_Response__c);
//                 String actualResponse = String.valueOf(response);
//                 if(responseToCompareString.contains('-')){
//                     List<String> splitCompareValues=  String.valueOf(range.PSS_Response__c).split('-');
//                     List<String> splitActualValues=  String.valueOf(response).split('-');
//                     //system.debug('splitValues'+splitCompareValues);
//                     if(((splitActualValues.get(0).isNumeric() 
//                          && utilityInstance.isGreaterThan((Object)splitActualValues.get(0),(Object)splitCompareValues.get(0))) 
//                         || utilityInstance.isEqual((Object)splitActualValues.get(0),(Object)splitCompareValues.get(0)))
//                        && ((splitActualValues.get(0).isNumeric()  &&
//                             utilityInstance.isLowerThan((Object)splitActualValues.get(0),(Object)splitCompareValues.get(1))) 
//                            || utilityInstance.isEqual((Object)splitActualValues.get(0),(Object)splitCompareValues.get(1)))){
//                                //system.debug('condition satisfied');
//                                scoreValue = range.PSS_Score_Value__c ;
//                                break;
//                            }
//                 }
//             }
            
//             else if(range.PSS_Logical_Operator__c == 'Contains'){
//                 //system.debug('inside Contains');
//                 if(utilityInstance.isContains(response,(Object)range.PSS_Response__c)){
//                     //system.debug('condition satisfied');
//                     scoreValue = range.PSS_Score_Value__c ;
//                     break;
//                 }
//             }
            
//             else if(range.PSS_Logical_Operator__c == 'Does not contain'){
//                 //system.debug('inside Does not contain');
//                 if(utilityInstance.isDoesNotContain(response,(Object)range.PSS_Response__c)){
//                     //system.debug('condition satisfied');
//                     scoreValue = range.PSS_Score_Value__c ;
//                     break;
//                 }
//             }
//         }
//         return scoreValue;
//     }
    
//     Public Boolean isEqual(Object ActualResponse, Object ConfigResponse){
//         //system.debug('equality '+String.valueOf(ActualResponse)  == String.valueOf(ConfigResponse));
//         Return (String.valueOf(ActualResponse)  == String.valueOf(ConfigResponse));
//     }
    
//     Public Boolean isGreaterThan(Object ActualResponse, Object ConfigResponse){
//         //system.debug('Greater than ');
//         String string_ActualResponse=String.valueOf(ActualResponse);
//         String string_ConfigResponse=String.valueOf(ConfigResponse);
//         //system.debug('Integer.valueOf(ActualResponse) '+Long.valueOf(string_ActualResponse) );
//         //system.debug('Integer.valueOf(ConfigResponse) '+Long.valueOf(string_ConfigResponse));
//         //system.debug('Integer.valueOf(ActualResponse)  > Integer.valueOf(ConfigResponse)'+(Long.valueOf(string_ActualResponse)  > Long.valueOf(string_ConfigResponse)));
//         Return (Long.valueOf(string_ActualResponse)  > Long.valueOf(string_ConfigResponse));
//     }
    
//     Public Boolean isLowerThan(Object ActualResponse, Object ConfigResponse){
//         //system.debug('Lower than ');
//         Return (Integer.valueOf(ActualResponse)  < Integer.valueOf(ConfigResponse));
//     }
    
//     Public Boolean isContains(Object ActualResponse, Object ConfigResponse){
//         //system.debug('Contains');
//         String response = String.valueOf(ActualResponse);
//         String responseToCompare = String.valueOf(ConfigResponse);
//         Return (response.contains(responseToCompare));
//     }
    
//     Public Boolean isDoesNotContain(Object ActualResponse, Object ConfigResponse){
//         //system.debug('DoesNotContain');
//         String response = String.valueOf(ActualResponse);
//         String responseToCompare = String.valueOf(ConfigResponse);
//         Return (!response.contains(responseToCompare));
//     }
    
    
}