/*************************************************************************************************************************************************************************
* Class Name  : PSS_SurveyResultProcessingInterface
* Version     : 1.0 
* Created Date: 7/17/2021
* Modification Log :
*
* Developer         Modification Log                    Date                              Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Sooriya           M-01    : Original version       7/17/2021                 Interface Class to update the hidden question values based on the other question results
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
global with sharing class PSS_SurveyResultProcessingInterface //implements ArdiraSurvey.SurveyProcessingInterface 
{
    
//     public static Object svProcessEvent(String eventInfo) {
//         EventInfo evInfo = (EventInfo)JSON.deserialize(eventInfo, EventInfo.class);
//         List<ResultData> resultList = new List<ResultData>();
//         /* Start logic here */
        
//         Set<Id> questionResultIds = New Set<Id>(); 
//         Map<Id,ProductRevenue> solRevMap = New Map<Id,ProductRevenue>();
//         //Hidden Question Unique text
//         Final String hiddenQuestion =  PMP_Utility.getValue('PSS_Hidden_Question_Key');
//         Final Integer scoreLimit_MRS_RRK= Integer.ValueOf(PMP_Utility.getValue('PSS_MRS_RRK_Scoring_Limit'));
//         Final Integer scoreLimit_RRK= Integer.ValueOf(PMP_Utility.getValue('PSS_RRK_Scoring_Limit'));
//         Final Integer scoreLimit_PartnerSolution= Integer.ValueOf(PMP_Utility.getValue('PSS_Partner_Solution_Scoring_Limit'));
        
//         //Iterating the questionDataList of input json to get the questionresult Id's
//         for(QuestionData qData : evInfo.questionData){
//             questionResultIds.add(qData.questionResultId);
//         }
        
//         //List of all intel products question results
//         List<ArdiraSurvey__Question_Result__c> intelProductsQuestionResults =  getIntelProductsQuestionResults(questionResultIds);
       
        
//         String strategicAttribute='';
       
//             //Getting the calculated revenue value
//         if(!intelProductsQuestionResults.isEmpty()){
//             solRevMap = calculateIntelProductRevenue(intelProductsQuestionResults);
//             strategicAttribute=String.isNotBlank(intelProductsQuestionResults.get(0).ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c)?
//                                 intelProductsQuestionResults.get(0).ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c:'';
//             //system.debug('testing::'+intelProductsQuestionResults);
//             for(ArdiraSurvey__Question_Result__c aqr:intelProductsQuestionResults){
//                 //system.debug('testing::'+aqr);
//                 if(aqr.ArdiraSurvey__Answer_Text__c.contains('OpenVINO')){
//                     if(String.isNotBlank(strategicAttribute) && !strategicAttribute.contains('Vision'))
//                         strategicAttribute =strategicAttribute+';'+'Vision;';
//                     else if(!strategicAttribute.contains('Vision')) {
//                         strategicAttribute ='Vision;' ;
//                     }           
//                     break;
//                 }
//                 else{
//                     string attribute =strategicAttribute;
//                     if(String.isNotBlank(strategicAttribute)){
//                         list<string> statribute = strategicAttribute.split(';');
//                         if(strategicAttribute.Contains('Vision')){
//                             statribute.remove(statribute.indexOf('Vision'));
//                             strategicAttribute = string.join(statribute,';');
//                         }
//                         else {
//                             strategicAttribute = attribute;
//                         }
//                     }   
//                 }
//             }
//         }
            
//             //Querying Hidden Question result records using the Hidden question Unique key text and survey result id from json
//             ArdiraSurvey__Question_Result__c hiddenQuestionResult =[select Id,ArdiraSurvey__Answer_Text__c,ArdiraSurvey__Answered__c,ArdiraSurvey__Question__c,
//                                                                     ArdiraSurvey__Survey_Result__c from ArdiraSurvey__Question_Result__c 
//                                                                     where ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c = : hiddenQuestion 
//                                                                     and ArdiraSurvey__Survey_Result__c = :evInfo.surveyResultId Limit 1];
            
//             if(hiddenQuestionResult!=Null && !solRevMap.isEmpty()){
                
//                 //Revenue is calculated by multiplying the quantity of each product with their respective ASP value
//                 //Total revenue will be the sum of all intel products revenue
//                 Decimal solutionRevenue = solRevMap.get(evInfo.surveyResultId).solutionRevenue!=Null ?
//                     solRevMap.get(evInfo.surveyResultId).solutionRevenue : 0.0;   
                
//                 //The flag will be true if any one of the  Intel Products selected falls under 'CPU' Product type 
//                 Boolean qualified = solRevMap.get(evInfo.surveyResultId).isQualified;
                
//                 //calculating the programs applicable value
//                 String programsApplicable = PSS_SurveyResultScoringInterface.getProgramsApplicable (evInfo.surveyResultId);
//                 String answerTextValue = '';
                
//                 //passing the eligible category names based on the solution revenue and qualified flag
//                 answerTextValue = solutionRevenue >= scoreLimit_MRS_RRK && qualified ? PSS_StaticConstants.MRS_RRK 
//                     : solutionRevenue >= scoreLimit_RRK && qualified ? PSS_StaticConstants.RRK 
//                         : solutionRevenue < scoreLimit_PartnerSolution ? PSS_StaticConstants.PARTNER_SOLUTION
//                             : PSS_StaticConstants.NO_CATEGORY;
                
//                 //If answerTextValue doesn't contains 'MRS' and programsApplicable contains 'MRS' remove MRS from programsApplicable and pass it
//                 answerTextValue = !answerTextValue.contains(PSS_StaticConstants.MRS) && String.isNotBlank(programsApplicable) && 
//                     programsApplicable.contains(PSS_StaticConstants.MRS) ? programsApplicable.remove(PSS_StaticConstants.MRS)
//                     //If answerTextValue doesn't contains 'RRK' and programsApplicable contains 'RRK' remove RRK from programsApplicable and pass it
//                     : !answerTextValue.contains(PSS_StaticConstants.RRK) && String.isNotBlank(programsApplicable) && 
//                         programsApplicable.contains(PSS_StaticConstants.RRK) ? programsApplicable.remove(PSS_StaticConstants.RRK)
//                         //if answerTextValue is Blank or 'No Category' then return 'Partner Solution'
//                         : String.IsBlank(answerTextValue) || answerTextValue == PSS_StaticConstants.NO_CATEGORY ? PSS_StaticConstants.PARTNER_SOLUTION
//                             : programsApplicable;
                
//                 //Remove ; from begining if it is present
//                 answerTextValue = answerTextValue.removeStart(';');
//                 //Remove ; from end if it is present
//                 answerTextValue = answerTextValue.removeEnd(';');
//                 answerTextValue = answerTextValue.replace(';;', ';');
                
//                 hiddenQuestionResult.ArdiraSurvey__Answer_Text__c = String.isNotBlank(answerTextValue) ? answerTextValue : PSS_StaticConstants.NO_CATEGORY;
//                 hiddenQuestionResult.ArdiraSurvey__Answered__c =true;
                
//                 //Wrapper data with Hidden question details 
//                 ResultData result = New ResultData();
//                 result.questionId = hiddenQuestionResult.ArdiraSurvey__Question__c;
//                 result.questionResults = hiddenQuestionResult;
//                 resultList.add(result);
                
//                 //Updating the Programs applicable value in Survey Result Record
//                 if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()){
//                     ArdiraSurvey__Survey_Result__c solutionUpdate = New ArdiraSurvey__Survey_Result__c (Id=evInfo.surveyResultId); 
//                     solutionUpdate.PSS_Programs_Applicable_Nm__c = String.IsNotBlank(answerTextValue) && answerTextValue!= PSS_StaticConstants.NO_CATEGORY 
//                         ? answerTextValue : PSS_StaticConstants.PARTNER_SOLUTION;
//                     solutionUpdate.PSS_Strategic_Attributes_Nm__c=strategicAttribute;
//                     update solutionUpdate;
//                 }
//             }
            
//             /* End logic here */
//             return JSON.serialize(resultList);
//         }
        
        
//         /**
// * @author - Sooriya
// * @description-To calculate the selected intel products revenue and to check whether CPU product type is selected
// * @param intelProductsList - Intel products Question Results List 
// * @return Map<Id,ProductRevenue> - Map key is the survey result Id and value is the ProductRevenue wrapper
// */
//         Public static Map<Id,ProductRevenue> calculateIntelProductRevenue (List<ArdiraSurvey__Question_Result__c> intelProductsList) {
            
//             //variable declaration for solution revenue calculation
//             Map<string,decimal> projectedQuantityMap = new Map<string,decimal>();
//             Map<string,decimal> aspValueMap = new Map<string,decimal>();
//             Map<String,String> productTypeMap = new Map<String,String>();
//             Map<Id,ProductRevenue> productRevenueMap = new Map<Id,ProductRevenue>();
            
//             //Looping through survey question result to populate projectedQuantityMap and intelProdAnswerMap
//             for(ArdiraSurvey__Question_Result__c questionResult: intelProductsList){
//                 if(questionResult.ArdiraSurvey__Answer_Number__c!=Null && questionResult.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.IOTG_PROJECTED_QUANTITY){
//                     projectedQuantityMap.put(questionResult.ArdiraSurvey__Repeat_Position__c,questionResult.ArdiraSurvey__Answer_Number__c);
//                 }               
//             }
            
//             //Looping through survey question results once again for mathematical calculations of solution revenue projection
//             if(!projectedQuantityMap.isEmpty()){
                
//                 for(PSS_Intel_Products__c prod: [select id,PSS_ASP__c,Name,PSS_Product_Type_Txt__c from PSS_Intel_Products__c where Name != Null]){
//                     //form a map with key as product name and  value as ASP value
//                     aspValueMap.put(prod.Name,prod.PSS_ASP__c); 
                    
//                     // form a map with key as product name and  value as product type
//                     productTypeMap.put(prod.Name,prod.PSS_Product_Type_Txt__c); 
//                 }
                
//                 //Iterating over the question results to calculate the revenue of intel products
//                 for(ArdiraSurvey__Question_Result__c questionResult: intelProductsList){
//                     decimal aspValue = 0.0;
//                     decimal quantity = 0.0;
//                     decimal revenue = 0.0;
//                     Boolean qualified = false;
//                     if(String.isNotBlank(questionResult.ArdiraSurvey__Answer_Text__c) && questionResult.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.IOTG_INTELPRODUCT){
//                         //ASP value for the product name
//                         aspValue = aspValueMap.get(questionResult.ArdiraSurvey__Answer_Text__c)!=null ? aspValueMap.get(questionResult.ArdiraSurvey__Answer_Text__c) : aspValue;
                        
//                         //Quantity of the product 
//                         quantity = projectedQuantityMap.get(questionResult.ArdiraSurvey__Repeat_Position__c)!=null ? projectedQuantityMap.get(questionResult.ArdiraSurvey__Repeat_Position__c) : quantity;
                        
//                         //The flag will be true if any one of the intel products in the question results falls under 'CPU' product type
//                         qualified = productTypeMap.get(questionResult.ArdiraSurvey__Answer_Text__c) =='CPU' ? true : false; 
                        
//                         //Revenue is calculated by multiplying the quantity of each product with their respective ASP value
//                         //Total revenue will be the sum of all intel products revenue
//                         revenue = aspValue * quantity;
                        
//                         //If values are already present in the map for the survey result key then updating the existing value wrapper
//                         if(productRevenueMap.containsKey(questionResult.ArdiraSurvey__Survey_Result__r.Id)){
//                             productRevenueMap.get(questionResult.ArdiraSurvey__Survey_Result__r.Id).solutionRevenue += revenue;
//                             //If existing value is true that means one of the Intel product is under CPU product type,so keep the same value or else pass the latest qualified boolean value
//                             productRevenueMap.get(questionResult.ArdiraSurvey__Survey_Result__r.Id).isQualified = productRevenueMap.get(questionResult.ArdiraSurvey__Survey_Result__r.Id).isQualified == true ?
//                                 true : qualified ;
//                         }
//                         //If values are not present in the map for the survey result key then inserting the new value wrapper
//                         else{
//                             ProductRevenue prodRevenue = New ProductRevenue();
//                             prodRevenue.solutionRevenue = revenue;
//                             prodRevenue.isQualified = qualified;
//                             productRevenueMap.put(questionResult.ArdiraSurvey__Survey_Result__r.Id,prodRevenue);
//                         }
//                     }
//                 }
//             }
//             return productRevenueMap;
//         }
        
        
//         /**
// * @author - Sooriya
// * @description- To get the Intel Products question results records using the question result Ids
// * @param questionResultIds - Set of Intel products Question Results Ids
// * @return List<ArdiraSurvey__Question_Result__c> - List of the intel products question results records
// */
//         Public static List<ArdiraSurvey__Question_Result__c> getIntelProductsQuestionResults(Set<Id> questionResultIds) {
            
//             List<String> questionUniqueKeyList = PSS_StaticConstants.INTEL_PRODUCT_UNIQUE_KEYS;
//             List<ArdiraSurvey__Question_Result__c> intelProductsList = New List<ArdiraSurvey__Question_Result__c>();
            
//             if(!questionResultIds.isEmpty()){    
//                 //Querying all the intel products in survey result
//                 intelProductsList = [select Id, ArdiraSurvey__Survey_Result__c,ArdiraSurvey__Survey_Result__r.Id, ArdiraSurvey__Repeat_Position__c,
//                                      ArdiraSurvey__Answer_Number__c,ArdiraSurvey__Answer_Text__c,ArdiraSurvey__Answered__c,
//                                      ArdiraSurvey__Question__c,ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c, ArdiraSurvey__Survey_Result__r.PSS_Strategic_Attributes_Nm__c
//                                      from ArdiraSurvey__Question_Result__c where Id IN: questionResultIds
//                                      AND ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c IN : questionUniqueKeyList];
//             }
            
//             return intelProductsList;
//         }
        
        
//         /* EventInfo Class you will get it in parementer 'eventInfo' as a string and need to deserialize it */
//         private class EventInfo {
//             String eventId;
//             Id surveyResultId;
//             Id currentSectionId;
//             List<QuestionData> questionData;
//             String selectedLanguage;
//         }
//         private class QuestionData {
//             Id questionId;
//             Id questionResultId;
//             Integer rowNumber;
//         }
//         /* Response format pass as List */
//         private class ResultData {
//             Id questionId;
//             ArdiraSurvey__Question_Result__c questionResults;
//         }
        
//         //Wrapper to store the result of calculateIntelProductRevenue method
//         private class ProductRevenue {
//             Decimal solutionRevenue;
//             Boolean isQualified;
//         }
        
    }