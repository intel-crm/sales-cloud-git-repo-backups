/*************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionCategoryResultTriggerHelper 
* Version     : 1.0 
* Created Date: 6/16/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX              M-01    : Original version       6/16/2021                         Helper class for PSS_SolutionCategoryResultTriggerHelper
***************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionCategoryResultTriggerHelper {
    
//     public static List<ArdiraSurvey__Survey_Category_Result__c> getRecordsToProcess(List<ArdiraSurvey__Survey_Category_Result__c> newCatList){
//         List<ArdiraSurvey__Survey_Category_Result__c> catListToProcess = new List<ArdiraSurvey__Survey_Category_Result__c>();
//         for(ArdiraSurvey__Survey_Category_Result__c catRes : newCatList){
            
//             if(catRes.ArdiraSurvey__Score_Raw__c >0){
//                 catListToProcess.add(catRes);
//             }
//         }
//         return catListToProcess;
//     }
    
    
//     public static void calculateCategoryScore(List<ArdiraSurvey__Survey_Category_Result__c> catResultList){
        
//         List<ArdiraSurvey__Survey_Result__c> resultListToUpdate = new List<ArdiraSurvey__Survey_Result__c>();
//         List<ArdiraSurvey__Survey_Category_Result__c> surveyCatResultList = [Select id,Name,ArdiraSurvey__Survey_Result__c,ArdiraSurvey__Survey_Result__r.PSS_AIIP_Score__c,
//                                                                              ArdiraSurvey__Survey_Result__r.PSS_MRS_Score__c,
//                                                                              ArdiraSurvey__Survey_Result__r.PSS_RRK_Score__c,
//                                                                              ArdiraSurvey__Survey_Result__r.PSS_Fail_Fast_Status_Nm__c,
//                                                                              ArdiraSurvey__Survey_Result__r.PSS_Programs_Applicable_Nm__c,
//                                                                              ArdiraSurvey__Category__r.name,ArdiraSurvey__Category__r.PSS_Category_Threshold_Value__c,
//                                                                              ArdiraSurvey__Survey_Result__r.PSS_Partner_Solution_Lifecycle_Status_Nm__c,ArdiraSurvey__Survey_Result__r.PSS_Solution_Category_Nm__c,
//                                                                              ArdiraSurvey__Score_Raw__c,ArdiraSurvey__Survey_Result__r.ArdiraSurvey__Survey__c
//                                                                              FROM ArdiraSurvey__Survey_Category_Result__c
//                                                                              Where id in : catResultList];
        
//         map<id, ArdiraSurvey__Survey_Result__c> surveyResultMap= new map<id, ArdiraSurvey__Survey_Result__c>();
        
//         for(ArdiraSurvey__Survey_Category_Result__c catResult: surveyCatResultList){
//             ArdiraSurvey__Survey_Result__c res;
//             if(surveyResultMap.containsKey(catResult.ArdiraSurvey__Survey_Result__c)){
//                 res= surveyResultMap.get(catResult.ArdiraSurvey__Survey_Result__c);
//             }else{
//                 res= new ArdiraSurvey__Survey_Result__c(id=catResult.ArdiraSurvey__Survey_Result__c);
//                 res.PSS_Programs_Applicable_Nm__c = NULL;
//                 res.PSS_Solution_Category_Nm__c = catResult.ArdiraSurvey__Survey_Result__r.PSS_Solution_Category_Nm__c;
//             }
//             if(catResult.ArdiraSurvey__Score_Raw__c >=catResult.ArdiraSurvey__Category__r.PSS_Category_Threshold_Value__c ){
//                 res.PSS_Programs_Applicable_Nm__c = (res.PSS_Programs_Applicable_Nm__c == NULL)?catResult.ArdiraSurvey__Category__r.Name+';':res.PSS_Programs_Applicable_Nm__c +catResult.ArdiraSurvey__Category__r.Name+';';
//                 res.PSS_Solution_Category_Nm__c = catResult.ArdiraSurvey__Survey_Result__r.PSS_Solution_Category_Nm__c;
//                 //system.debug('res.PSS_Solution_Category_Nm__c'+res.PSS_Solution_Category_Nm__c);
//             }
//             surveyResultMap.put(catResult.ArdiraSurvey__Survey_Result__c,res);
            
//         }
//         //system.debug('surveyResultMap before'+surveyResultMap);
        
//         //Code added to recalculate solutions applicable if Forecast question is answered
//         //update the solutions applicable based on the response of hidden question
//         String hiddenQuestion =  PMP_Utility.getValue('PSS_Hidden_Question_Key');
//         List<ArdiraSurvey__Question_Result__c> hiddenQueResultList=[SELECT id, ArdiraSurvey__Answer_Text__c,ArdiraSurvey__Survey_Result__c 
//                                                                     FROM ArdiraSurvey__Question_Result__c 
//                                                                     WHERE ArdiraSurvey__Survey_Result__c IN: surveyResultMap.keySet() AND
//                                                                     ArdiraSurvey__Answered__c=true AND
//                                                                     ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c = : hiddenQuestion ];
        
//         Map<id,ArdiraSurvey__Question_Result__c> solutionWithHiddenResponse = new Map<id,ArdiraSurvey__Question_Result__c>();
//         if(hiddenQueResultList!=Null && !hiddenQueResultList.isEmpty()){
//             for(ArdiraSurvey__Question_Result__c queResult : hiddenQueResultList){
//                 solutionWithHiddenResponse.put(queResult.ArdiraSurvey__Survey_Result__c,queResult);
//             }
//         }
//         //system.debug('solutionWithHiddenResponse '+solutionWithHiddenResponse);
//         //iterate over the pre-populated Programs applicable field to check if any updation required based on the hidden que response
//         //
//         //Added by Saurabh
//         //comma separated value for the survey ids to be added in metadata
//         List<PMP_Static_Data__mdt> surveyIds=[select id,Label, Value__c from PMP_Static_Data__mdt where Label='PSS Category Scoring Survey' LIMIT 1];
//         String surveyIDsToExecuteProgramsApplicable='';
//         String activeSurveysId='';
//         if(surveyIds.size()>0){
//             surveyIDsToExecuteProgramsApplicable=surveyIds[0].Value__c;
//             activeSurveysId=surveyCatResultList[0].ArdiraSurvey__Survey_Result__r.ArdiraSurvey__Survey__c;
//         }
//         // System.debug('activeSurvey'+activeSurveysId);
//         // System.debug('surveyIDsToExecuteProgramsApplicable'+surveyIDsToExecuteProgramsApplicable);
        
//         if((String.isNotBlank(activeSurveysId) && surveyIDsToExecuteProgramsApplicable.contains(activeSurveysId) ) || Test.isRunningTest()){
//             for(ArdiraSurvey__Survey_Result__c solutionResult: surveyResultMap.values()){
//                 if(solutionWithHiddenResponse !=NULL && !solutionWithHiddenResponse.isEmpty()){
//                     if(solutionWithHiddenResponse.ContainsKey(solutionResult.id) &&
//                        String.isNotBlank(solutionWithHiddenResponse.get(solutionResult.id).ArdiraSurvey__Answer_Text__c) &&  
//                        solutionResult.PSS_Programs_Applicable_Nm__c.contains('MRS') &&
//                        !solutionWithHiddenResponse.get(solutionResult.id).ArdiraSurvey__Answer_Text__c.contains('MRS')){
//                            //system.debug('MRS Condition satisfied');
//                            solutionResult.PSS_Programs_Applicable_Nm__c = solutionResult.PSS_Programs_Applicable_Nm__c.remove('MRS').replace(';;', ';');
//                        }
//                     if(solutionWithHiddenResponse.ContainsKey(solutionResult.id) &&
//                        String.isNotBlank(solutionWithHiddenResponse.get(solutionResult.id).ArdiraSurvey__Answer_Text__c) &&  
//                        solutionResult.PSS_Programs_Applicable_Nm__c.contains('RRK') &&
//                        !solutionWithHiddenResponse.get(solutionResult.id).ArdiraSurvey__Answer_Text__c.contains('RRK')){
//                            //system.debug('RRK Condition satisfied');
//                            solutionResult.PSS_Programs_Applicable_Nm__c = solutionResult.PSS_Programs_Applicable_Nm__c.remove('RRK').replace(';;', ';');
//                        }
//                     /*if(String.isNotBlank(solutionResult.PSS_Programs_Applicable_Nm__c) &&
// solutionResult.PSS_Programs_Applicable_Nm__c.contains('MRS')&&
// solutionResult.PSS_Programs_Applicable_Nm__c.contains('RRK')){
// solutionResult.PSS_Programs_Applicable_Nm__c = solutionResult.PSS_Programs_Applicable_Nm__c.remove('RRK');
// }*/
                    
//                     surveyResultMap.put(solutionResult.id,solutionResult);
                    
//                 }
//             }
            
//             //system.debug('surveyResultMap after'+surveyResultMap);
//             for(Id resultId : surveyResultMap.keySet()){
//                 ArdiraSurvey__Survey_Result__c res= surveyResultMap.get(resultId);
                
//                 if(String.isNotBlank(res.PSS_Programs_Applicable_Nm__c)){
//                     if(res.PSS_Programs_Applicable_Nm__c.contains('MRS') || res.PSS_Programs_Applicable_Nm__c.contains('RRK')){
//                         res.PSS_Solution_Category_Nm__c ='IOTG';
//                     }else if (res.PSS_Programs_Applicable_Nm__c.contains('Intel Select') || res.PSS_Programs_Applicable_Nm__c.contains('Intel Data Center-Centric Solutions') ){
//                         res.PSS_Solution_Category_Nm__c ='DCG';
//                     }else if(res.PSS_Programs_Applicable_Nm__c == 'Partner Solution;'){
//                         res.PSS_Solution_Category_Nm__c ='Partner Solution';
//                     }
//                     res.PSS_Fail_Fast_Status_Nm__c  = 'Pass';
//                 }else{
//                     res.PSS_Solution_Category_Nm__c =NULL;
//                     res.PSS_Fail_Fast_Status_Nm__c = 'Fail'; 
//                 }
//                 //system.debug('PSS_Solution_Category_Nm__c'+res.PSS_Solution_Category_Nm__c);
//                 surveyResultMap.put(resultId,res);
               
//             }
//         }
//         resultListToUpdate = PSS_ImpactPathScoring_Utility.calculateImpactPathScore(surveyResultMap);
//         //system.debug('resultListbefore::>>'+resultListToUpdate);
//         resultListToUpdate = PSS_BenefitAssignmentTriggerHelper.convertSolutionToOffering(resultListToUpdate);
//         //system.debug('resultListafter::>>'+resultListToUpdate);
//         update resultListToUpdate;
        
        
        
//     } 
    //Add code to recalculate the impact path and benefits if non category questions updated
    
}