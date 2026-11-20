/*************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionResponseTriggerHelper
* Version     : 1.0 
* Created Date: 6/16/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Swathi              M-01    : Original version       6/16/2021                          Helper class for the solution Trigger
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionResponseTriggerHelper {
    /**
	* @description - method to correct the Ardira Status and Workflow stage fields with required values using trigger.
	* @param - statusChangeresults(list of ardira survey results) and surveyIds(set of survey Ids)
	* This method is called from PSS_SolutionResponse_TriggerHandler class
	**/
//     public Static void populateArdiraStatusAndStage(List<ArdiraSurvey__Survey_Result__c> statusChangeresults,Set<Id> surveyIds){

//         Map<Id,List<ArdiraSurvey__Survey_Workflow_Stage__c>> stageMap = new Map<Id,List<ArdiraSurvey__Survey_Workflow_Stage__c>>();
//         List<ArdiraSurvey__Survey_Workflow_Stage__c> stageRecords = new List<ArdiraSurvey__Survey_Workflow_Stage__c>();
        
//         //Iterating over the workflow stage records by filtering using the survey Id to populate the required stageMap
//         for(ArdiraSurvey__Survey_Workflow_Stage__c stage : [Select Id,Name,ArdiraSurvey__Survey__c, 
//                                                             ArdiraSurvey__Action_Label__c,  
//                                                             ArdiraSurvey__Label__c,
//                                                             ArdiraSurvey__Advance_Survey_Workflow_on_Submit__c
//                                                             from ArdiraSurvey__Survey_Workflow_Stage__c
//                                                             WHERE ArdiraSurvey__Survey__c IN: surveyIds]) {
//                 //If stageMap already contains the survey Id as key add the workflow stage record in the existing list value
//                 if(stageMap.containsKey(stage.ArdiraSurvey__Survey__c)){
//                     stageRecords = new List<ArdiraSurvey__Survey_Workflow_Stage__c>();
//                     stageRecords = stageMap.get(stage.ArdiraSurvey__Survey__c);
//                     stageRecords.add(stage);
//                     stageMap.put(stage.ArdiraSurvey__Survey__c,stageRecords);
//                 }
//                 //If stageMap doesn't contains the survey Id as key then insert the survey Id as key with list of workflow stage record as the value
//                 else{                  
//                     stageRecords = new List<ArdiraSurvey__Survey_Workflow_Stage__c>();
//                     stageRecords.add(stage);
//                     stageMap.put(stage.ArdiraSurvey__Survey__c,stageRecords);
//                 }                                               
//         }
        
//         //Iterating over the list of survey results which came as input from survey result trigger
//         for(ArdiraSurvey__Survey_Result__c aResult : statusChangeresults){
			
//             //getting the workflow stage records list as value from stageMap using the survey Id as key
//             if(stageMap.containsKey(aResult.ArdiraSurvey__Survey__c))
//             {
//                 stageRecords = stageMap.get(aResult.ArdiraSurvey__Survey__c);
//             }
//             String reviewId = '';
//             String dataCollectionId = '';
            
//             //we need the Id of workflow stage record to update the workflow stage look up field in survey result record
//             if(!stageRecords.isEmpty()){
// 				for(ArdiraSurvey__Survey_Workflow_Stage__c stageData : stageRecords){
// 					//If stage name is 'Data Collection' store the Id of the record in dataCollectionId string
// 					if(stageData.Name == PSS_StaticConstants.DATA_COLLECTION){
// 						dataCollectionId = stageData.Id;
// 					}
// 					//If stage name is 'Review' store the Id of the record in reviewId string
// 					else if(stageData.Name == PSS_StaticConstants.REVIEW){
// 						reviewId = stageData.Id;
// 					}
// 				} 
				
// 				//Updating the Ardira status and workflow stage value as per the requirement
// 				if(aResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.ADMIN_REVIEW){
// 					aResult.ArdiraSurvey__Status__c = PSS_StaticConstants.IN_PROGRESS;
// 					aResult.ArdiraSurvey__Workflow_Stage__c = reviewId;
//                     aResult.ArdiraSurvey__End_State__c = false;
// 				}else if(aResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_UPDATE_REQUIRED_STATUS){
// 					aResult.ArdiraSurvey__Status__c = PSS_StaticConstants.IN_PROGRESS;
// 					aResult.ArdiraSurvey__Workflow_Stage__c = dataCollectionId;
//                     aResult.ArdiraSurvey__Last_Workflow_Action__c = PSS_StaticConstants.SOLUTION_WORKFLOW_REJECT_STATUS;
// 				}else if(aResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_APPROVED_STATUS){
// 					aResult.ArdiraSurvey__Status__c = PSS_StaticConstants.COMPLETED;              
// 					aResult.ArdiraSurvey__Workflow_Stage__c = reviewId;             
// 				}else if(aResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_ONHOLD_STATUS){
// 					aResult.ArdiraSurvey__Status__c = PSS_StaticConstants.IN_PROGRESS;                
// 					aResult.ArdiraSurvey__Workflow_Stage__c = reviewId;         
// 				}else if(aResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.REVIEW_SCHEDULED){
// 					aResult.ArdiraSurvey__Status__c = PSS_StaticConstants.IN_PROGRESS;                
// 					aResult.ArdiraSurvey__Workflow_Stage__c = reviewId;         
// 				}
//                 /*else if(aResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_REJECTED_STATUS){
// 					aResult.ArdiraSurvey__Status__c = PSS_StaticConstants.COMPLETED;                
// 					aResult.ArdiraSurvey__Workflow_Stage__c = reviewId;         
// 				}*/
// 			}
//         }
    
//     }
    
//     /**
// * @description method to populate the intel products using trigger.
// * @param List<ArdiraSurvey__Survey_Result__c> surveyResultList
// **/
//     public static void populateIntelProducts(List<ArdiraSurvey__Survey_Result__c> surveyResultList, map<Id,ArdiraSurvey__Survey_Result__c> oldMap){
//         //To store the survey result Ids
//         Set<id> surveyresultIds = new Set<id>();
//         Map<id,IntelProductWappper> surveyAnswerMap = new Map<id,IntelProductWappper>();
        
//         //variable declaration for solution revenue calculation
//         Map<string,decimal> projectedQuantityMap = new Map<string,decimal>();
//         Map<string,decimal> aspValueMap = new Map<string,decimal>();
//         Map<string,decimal> aspValueRepeatPositionMap = new Map<string,decimal>();
//         Map<string,string> productTypeMap = new Map<string,string>();
// 		Set<String> productTypeSet = new Set<String>();
//         Set<Id> questionSet = new Set<Id>();
//         Integer dcgProducts = 0;
//         Integer noOfRegions = 0;
        
//         //Iterating over the survey result record to get the survey result ids
//         for(ArdiraSurvey__Survey_Result__c surveyResult : surveyResultList){
//             surveyresultIds.add(surveyResult.Id);
//         }
        
// 	    //Querying the survey result and equivalent question result records
//         List<ArdiraSurvey__Survey_Result__c> surveyQuestionResultList = [Select Id, PSS_Comma_Separated_Intel_Products_Txt__c,PSS_Is_Benefit_Assigned_Ind__c,PSS_DCG_solution_past_revenue__c,PSS_Strategic_area_DCG__c,PSS_Strategic_Attributes_Nm__c,
//                                                                          (select Id, ArdiraSurvey__Survey_Result__c,ArdiraSurvey__Survey_Result__r.Id, ArdiraSurvey__Repeat_Position__c,
//                                                                           ArdiraSurvey__Answer_Number__c,ArdiraSurvey__Answer_Text__c,
//                                                                           ArdiraSurvey__Question__c,ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c 
//                                                                           from ArdiraSurvey__Question_Results__r 
//                                                                           Where ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c IN :PSS_StaticConstants.PRODUCT_UNIQUE_KEYS)
//                                                                          FROM ArdiraSurvey__Survey_Result__c 
//                                                                          Where Id IN : SurveyresultIds];
        
//         if(!surveyQuestionResultList.isEmpty()){
        
//         	//Querying all the records in PSS_Intel_Products__c object to form a key value pair of answer name and asp value
//             for (PSS_Intel_Products__c prod: [select id,PSS_Product_Type_Txt__c,PSS_ASP__c,Name from PSS_Intel_Products__c where Name != null]){
//             	aspValueMap.put(prod.Name,prod.PSS_ASP__c);  
//                 productTypeMap.put(prod.Name,prod.PSS_Product_Type_Txt__c);
//         	}
        	
//             //Iterating over the  survey results
//             for(ArdiraSurvey__Survey_Result__c asr : surveyQuestionResultList){
//                 //Creating the wrapper
//                 IntelProductWappper intelWrapper= new IntelProductWappper();
//                 //Iterating over the  survey question results
//                 for(ArdiraSurvey__Question_Result__c sqr : asr.ArdiraSurvey__Question_Results__r){
//                     //if the answer text of question result is not null or blank
//                     if(String.IsNotBlank(sqr.ArdiraSurvey__Answer_Text__c)){
//                         //If the question unique key of the question result = IOTG_IntelProduct
//                         if(sqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.IOTG_INTELPRODUCT){ //TODO-Change to static constants
                            
//                             //if the wrapper.inteproductNames already contains some value then append the new value with a comma seperated to the existing value
//                             intelWrapper.inteproductNames = String.isNotBlank(intelWrapper.inteproductNames) ?  intelWrapper.inteproductNames +', '+ sqr.ArdiraSurvey__Answer_Text__c 
//                                 							:sqr.ArdiraSurvey__Answer_Text__c;
//                             if(!productTypeSet.contains(productTypeMap.get(sqr.ArdiraSurvey__Answer_Text__c))){
//                             	productTypeSet.add(productTypeMap.get(sqr.ArdiraSurvey__Answer_Text__c));
//                        			intelWrapper.noOfIntelTechnologies +=1;
//                             }
//                             //getting the asp value of the answer text from the aspValueMap using the answer text as key
//                             //if intelWrapper.aspValue alrea contains some value then add the new aspValue with the exisitng value
//                             if(aspValueMap.get(sqr.ArdiraSurvey__Answer_Text__c)!=null && intelWrapper.aspValue <= aspValueMap.get(sqr.ArdiraSurvey__Answer_Text__c)){
//                             	intelWrapper.aspValue = aspValueMap.get(sqr.ArdiraSurvey__Answer_Text__c);
//                             }
//                             //creating the this map with key as question result repeat position and value as asp value
//                             aspValueRepeatPositionMap.put(sqr.ArdiraSurvey__Repeat_Position__c,aspValueMap.get(sqr.ArdiraSurvey__Answer_Text__c));
//                         }
//                         //If the question unique key of the question result = DCG_IntelProduct
//                         else if(sqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.DCG_INTELPRODUCT){
//                             questionSet.add(sqr.Id);
//                             intelWrapper.inteproductNames = sqr.ArdiraSurvey__Answer_Text__c;
//                             intelWrapper.noOfIntelTechnologies += PSS_Utility.geNumberOfValuesSelected(sqr.ArdiraSurvey__Answer_Text__c,',');
//                         }
                        
//                         //If the question unique key of the question result = IOTG_Geo_Countries
//                         if(sqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.IOTG_Geographies_deployed){    
//                             questionSet.add(sqr.Id);
//                             intelWrapper.noOfGeographies  = sqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.IOTG_Geographies_deployed ? 
//                                                        PSS_Utility.geNumberOfValuesSelected(sqr.ArdiraSurvey__Answer_Text__c,',') : intelWrapper.noOfGeographies;
//                         }
//                         //If the question unique key of the question result = DCG-PastRevenue
//                         intelWrapper.dcgPastRevenue  = sqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.DCG_PASTREVENUE ? 
//                              						  Decimal.valueOf(sqr.ArdiraSurvey__Answer_Text__c) : intelWrapper.dcgPastRevenue;
                        
//                         //If the question unique key of the question result = dcg-revenue-projection
//                         intelWrapper.forecastedRevenue = sqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.DCG_REVENUEPROJECTION ? 
//                         								 Decimal.valueOf(sqr.ArdiraSurvey__Answer_Text__c) : intelWrapper.forecastedRevenue;
                        
//                         //If the question unique key of the question result = DCG_StrategicQue
//                         intelWrapper.StrategicAttribute = sqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.DCG_STRATEGICQUE ?
//                                                           sqr.ArdiraSurvey__Answer_Text__c : intelWrapper.StrategicAttribute;
//                     }

//                     //Creating the product quantity map with repeat position as key and quantity number as value to use it for IOTG revenue calculation
//                     if(sqr.ArdiraSurvey__Answer_Number__c!=Null && sqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c== PSS_StaticConstants.IOTG_PROJECTED_QUANTITY){
//                     	projectedQuantityMap.put(sqr.ArdiraSurvey__Repeat_Position__c,sqr.ArdiraSurvey__Answer_Number__c);
//                     }
//                 }

//                 //Adding the survey result Id as key and the framed wrapper as value 
//                 surveyAnswerMap.put(asr.Id,intelWrapper);
//             }
        
        
//         //If surveyAnswerMap is not Empty
//         if(!surveyAnswerMap.isEmpty()){
//             //If projected quantity map is not empty then we have to do the revenue calculation using this map values
//             if(!projectedQuantityMap.isEmpty()){
//                 //Iterating over the survey result and question results again to calculate IOTG product revenue
//                 for(ArdiraSurvey__Survey_Result__c asr : surveyQuestionResultList){
//                         for(ArdiraSurvey__Question_Result__c sqr : asr.ArdiraSurvey__Question_Results__r){
//                             decimal aspValue=0.0;  
//                         	decimal quantity=0.0;
//                             //If answer text is not null or empty and question of question result is having unique key as IOTG_IntelProduct
//                             if(String.IsNotBlank(sqr.ArdiraSurvey__Answer_Text__c) && sqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c == PSS_StaticConstants.IOTG_INTELPRODUCT){
//                                 aspValue = aspValueRepeatPositionMap.get(sqr.ArdiraSurvey__Repeat_Position__c)!=null ? aspValueRepeatPositionMap.get(sqr.ArdiraSurvey__Repeat_Position__c) : aspValue;
//                                 quantity = projectedQuantityMap.get(sqr.ArdiraSurvey__Repeat_Position__c)!=null ? projectedQuantityMap.get(sqr.ArdiraSurvey__Repeat_Position__c) : quantity;

//                                 //revenue is the total sum of (aspvalue*quantity) for all IOTG question results
//                                 surveyAnswerMap.get(sqr.ArdiraSurvey__Survey_Result__c).iotgRevenue += aspValue*quantity; 
//                              }
//                         }
//                 }
//             }
            
            
//             if(!questionSet.isEmpty()){
//                 for(ArdiraSurvey__Question_Result_Choice__c aqrc: [select id,ArdiraSurvey__Question_Result__c,ArdiraSurvey__Question_Result__r.ArdiraSurvey__Question__c,ArdiraSurvey__Question_Result__r.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c from ArdiraSurvey__Question_Result_Choice__c where ArdiraSurvey__Question_Result__c IN:questionSet]){
//                     if(aqrc.ArdiraSurvey__Question_Result__r.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c==PSS_StaticConstants.DCG_INTELPRODUCT){
//                         dcgProducts+=1;  
//                     }else if(aqrc.ArdiraSurvey__Question_Result__r.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c==PSS_StaticConstants.IOTG_Geographies_deployed){
//                         noOfRegions+=1;
//                     }
//                 }
//             }
            
//             for(ArdiraSurvey__Survey_Result__c surveyResult : surveyResultList){
//             	if(surveyAnswerMap.get(surveyResult.Id)!=Null){
//                 	surveyResult.PSS_Comma_Separated_Intel_Products_Txt__c = surveyAnswerMap.get(surveyResult.Id).inteproductNames;
//                     surveyResult.PSS_No_of_Different_Intel_Technologies__c = dcgProducts>0?dcgProducts: surveyAnswerMap.get(surveyResult.Id).noOfIntelTechnologies;
//                     surveyResult.PSS_No_of_Geographies__c = noOfRegions;
//                     surveyResult.PSS_DCG_solution_past_revenue__c=surveyAnswerMap.get(surveyResult.Id).dcgPastRevenue;
//                     //If forecasted revenue value then pass that or iotg revenue pass that, else pass 0.0
//                     surveyResult.PSS_Solution_Revenue_Projection__c = surveyAnswerMap.get(surveyResult.Id).forecastedRevenue!=0.0 ? surveyAnswerMap.get(surveyResult.Id).forecastedRevenue
//                                                                       :surveyAnswerMap.get(surveyResult.Id).iotgRevenue!=0.0 ? surveyAnswerMap.get(surveyResult.Id).iotgRevenue
//                                                                       : 0.0 ;
//                     surveyResult.PSS_Strategic_area_DCG__c=surveyAnswerMap.get(surveyResult.Id).strategicAttribute;
//                     /*if(surveyResult.PSS_Strategic_Attributes_Nm__c == oldMap.get(surveyResult.id).PSS_Strategic_Attributes_Nm__c){
//                         surveyResult.PSS_Strategic_Attributes_Nm__c = surveyAnswerMap.get(surveyResult.Id).iotgStrategicAttribute;
//                     }*/
//                     surveyResult.PSS_Solution_ASP_Profile_Value__c = surveyAnswerMap.get(surveyResult.Id).aspValue;
//                  }
//              }
//         }
//         }
                  
//     }
    
//     /**
// * @description method to assign the sharing record permission.
// * @param List<ArdiraSurvey__Survey_Result__c> ardiraSolutionResultlist
// **/
    
//     public static void createSharingRecords(List<ArdiraSurvey__Survey_Result__c> surveyResults) {
//         //System.debug('SurvyResults : '+surveyResults);
//          set<string> conIds = new set<string>();
//          map<string, string> contactusermap = new map<string, string>();
//          string recordId;
//           Map<string,string> parentUserExsistMap = new  Map<string,string>(); 
//         if(surveyResults != null && surveyResults.size() > 0) {
            
//             Map<Id, List<ArdiraSurvey__Survey_Result__c>> accIdAndSurveyResults = new Map<Id, List<ArdiraSurvey__Survey_Result__c>>();
//             Set<Id> intelAccountIds = new Set<Id>();
//             List<ArdiraSurvey__Survey_Result__Share> surveyResultShares = new List<ArdiraSurvey__Survey_Result__Share>();
//             List<ArdiraSurvey__Survey_Result__Share> surveyResultSharesForAssignTo = new List<ArdiraSurvey__Survey_Result__Share>();

//             for(ArdiraSurvey__Survey_Result__c sr : surveyResults) {
                
//                 if(sr.PSS_Partner_Account_Id__c != null) {
//                     if(accIdAndSurveyResults.get(sr.PSS_Partner_Account_Id__c) == null) {
//                         accIdAndSurveyResults.put(sr.PSS_Partner_Account_Id__c, new List<ArdiraSurvey__Survey_Result__c>());
//                     }
//                   /*  if(accIdAndSurveyResults.get(sr.ArdiraSurvey__Assigned_To_Contact__c)==null){
//                         accIdAndSurveyResults.put(sr.ArdiraSurvey__Assigned_To_Contact__c, new List<ArdiraSurvey__Survey_Result__c>());
//                     }*/
//                     accIdAndSurveyResults.get(sr.PSS_Partner_Account_Id__c).add(sr);
//                    // accIdAndSurveyResults.get(sr.ArdiraSurvey__Assigned_To_Contact__c).add(sr);
//                 }
//                 if(sr.ArdiraSurvey__Assigned_To_Contact__c != null){
//                          conIds.add(sr.ArdiraSurvey__Assigned_To_Contact__c);
//                          recordId = sr.Id;
//                 }
//             }
//             if(accIdAndSurveyResults.size() > 0 && Schema.sObjectType.Core_Account_Group_Member__c.isAccessible()) {
//                 List<Core_Account_Group_Member__c> accGrpMembers = [SELECT Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c 
//                                                                     FROM Core_Account_Group_Member__c 
//                                                                     WHERE Core_Intel_Account_Id__c IN :accIdAndSurveyResults.keySet() OR
//                                                                     Core_Partner_Account_Id__c IN :accIdAndSurveyResults.keySet()];
//                 for(Core_Account_Group_Member__c agm : accGrpMembers) {
//                     if(agm.Core_Intel_Account_Id__c != null) {
//                         intelAccountIds.add(agm.Core_Intel_Account_Id__c);
//                     }
//                 }
               
//                 if(intelAccountIds.size() > 0) {
//                     Id currentUserId = UserInfo.getUserId();
//                     for(AccountTeamMember atm : [SELECT Id,UserId,AccountId FROM AccountTeamMember 
//                                                     WHERE AccountId IN :intelAccountIds and user.IsActive = true]) {
//                     	if(accIdAndSurveyResults.containsKey(atm.AccountId)){                               
//                         	for(ArdiraSurvey__Survey_Result__c sr : accIdAndSurveyResults.get(atm.AccountId)) {
//                             	if(sr.OwnerId != atm.UserId) {
//                                 	surveyResultShares.add(new ArdiraSurvey__Survey_Result__Share(ParentId=sr.Id,UserOrGroupId=atm.UserId,AccessLevel ='edit',RowCause ='Manual'));
//                             	}
                           
//                         	}
//                      	 }
//                     }
//                     for(ArdiraSurvey__Survey_Result__Share srShare :[select id,ParentId,UserOrGroupId from ArdiraSurvey__Survey_Result__Share where ParentId =:recordId]){
//                         parentUserExsistMap.put(srShare.ParentId, srShare.UserOrGroupId);
//                     }
                    
//                     for(User us : [Select Id,Name,contactId from User where contactId IN :conIds AND isActive = TRUE]){
//                         contactusermap.put(us.contactId, us.id);
//                 }
                    
//                 }
//                  for(ArdiraSurvey__Survey_Result__c sr : surveyResults) {
//                      if((sr.ArdiraSurvey__Assigned_To_Contact__c != NULL && contactusermap.containsKey(sr.ArdiraSurvey__Assigned_To_Contact__c)) && parentUserExsistMap.isEmpty()){
//                          surveyResultShares.add(new ArdiraSurvey__Survey_Result__Share(ParentId=sr.Id,UserOrGroupId=contactusermap.get(sr.ArdiraSurvey__Assigned_To_Contact__c),AccessLevel ='edit',RowCause ='Manual'));
//                          //below line to get the share records only for assign to contact, because email should be sent only for assignTo contact  
//                          surveyResultSharesForAssignTo.add(new ArdiraSurvey__Survey_Result__Share(ParentId=sr.Id,UserOrGroupId=contactusermap.get(sr.ArdiraSurvey__Assigned_To_Contact__c),AccessLevel ='edit',RowCause ='Manual'));
//                      }
//                      else if(!parentUserExsistMap.isEmpty() && (sr.ArdiraSurvey__Assigned_To_Contact__c != NULL && contactusermap.containsKey(sr.ArdiraSurvey__Assigned_To_Contact__c)) 
//                             && parentUserExsistMap.get(sr.id) != contactusermap.get(sr.ArdiraSurvey__Assigned_To_Contact__c)){
                         
//                            surveyResultShares.add(new ArdiraSurvey__Survey_Result__Share(ParentId=sr.Id,UserOrGroupId=contactusermap.get(sr.ArdiraSurvey__Assigned_To_Contact__c),AccessLevel ='edit',RowCause ='Manual'));
//                            //below line to get the share records only for assign to contact, because email should be sent only for assignTo contact
//                            surveyResultSharesForAssignTo.add(new ArdiraSurvey__Survey_Result__Share(ParentId=sr.Id,UserOrGroupId=contactusermap.get(sr.ArdiraSurvey__Assigned_To_Contact__c),AccessLevel ='edit',RowCause ='Manual'));
//                      }
//                  }
                     
//                 if(surveyResultShares.size() > 0) {
//                     insert surveyResultShares;
//                 }
//                 if(surveyResultSharesForAssignTo.size() > 0){
//                     //insert contact association records only for assignTo Contact
//                     PSS_ContactsShare.insertSoltuionContactAssociationRecords(surveyResultSharesForAssignTo, recordId);//should be inserted only for assign to contact
//                 }
                
//             }
//         }
//     }
    
//     /**
//      * @description method to populate all Solution Fields from question list and assign to fields in Partners Solution
//      * @param list of all the survey records.
//      **/
    
//     public static void populateSolutionFieldsFromQuestionResult(List<sObject> surveyResultList){

//         /*Custom metadata
//          *  PSS_FieldAPI__c:Api name of field where we need to store the result
//         	Value__c: Unique Key of Questions related
//         */
       
        
//         //Fetching All API name of solutions and its related Questions'unique key' from Custom metadata 
//         List<PSS_Question_Fields__mdt> fields=[Select PSS_FieldAPI__c,Value__c from PSS_Question_Fields__mdt where Value__c != null]; 
        
//         //Creating list for all the questions unique key for all questions which needs to be displayed
//         List<String> questionsUniqueKey=new List<String>();
//         for(PSS_Question_Fields__mdt f:fields){
//             questionsUniqueKey.add(f.Value__c);
//         }
//         //Fetching Solutions and its related questions where question unique is in above list(questionsUniqueKey)
//         Map<id,ArdiraSurvey__Survey_Result__c> mapOfQuestionRequired=new Map<id,ArdiraSurvey__Survey_Result__c>([Select id, 
//                                                   (Select ArdiraSurvey__Question_Text__c,ArdiraSurvey__Answer_Text__c,
//                                                    ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c,ArdiraSurvey__Answer_Rich_Text__c
//                                                    from ArdiraSurvey__Question_Results__r 
//                                                    where ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c 
//                                                    IN :questionsUniqueKey) 
//                                                    from ArdiraSurvey__Survey_Result__c 
//                                                	   where id IN : surveyResultList]);
        
          
//         //Iterating over all the records and updating the value is answer text for that question is not blank
//         for(SObject asr:surveyResultList){
//              ArdiraSurvey__Survey_Result__c asrInstance=mapOfQuestionRequired.get(asr.id);
//             for(PSS_Question_Fields__mdt f:fields){ 
//                 for(ArdiraSurvey__Question_Result__c aqr:asrInstance.ArdiraSurvey__Question_Results__r){ 
//                     if(f.Value__c == aqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c){
//                            if(String.isNotBlank(aqr.ArdiraSurvey__Answer_Rich_Text__c)){
//                                 asr.put(f.PSS_FieldAPI__c,aqr.ArdiraSurvey__Answer_Rich_Text__c);
//                                break;
//                            }
//                            else{
//                                asr.put(f.PSS_FieldAPI__c,aqr.ArdiraSurvey__Answer_Text__c);
//                                break;
//                            }
//                     }
//                 }
//             }
//         }
  
//     }
    
    
//     public static void populateApprovedDate(List<ArdiraSurvey__Survey_Result__c> surveyList,
//                                            map<Id,ArdiraSurvey__Survey_Result__c> oldMap){
//         for(ArdiraSurvey__Survey_Result__c asr:surveyList){
//             if(asr.PSS_Partner_Solution_Lifecycle_Status_Nm__c=='Approved' && 
//                oldmap.get(asr.id).PSS_Partner_Solution_Lifecycle_Status_Nm__c!=asr.PSS_Partner_Solution_Lifecycle_Status_Nm__c){
//                 asr.PSS_Approval_Date_dt__c=Datetime.now().date();
//             }
//         }
       
//     }
  
//     Public class IntelProductWappper{
//         Public string inteproductNames='';
//         Public Integer noOfIntelTechnologies=0;
//         Public Decimal forecastedRevenue=0;
//         Public Decimal iotgRevenue=0;
//         Public Double aspValue=0.0;
//         Public Integer noOfGeographies=0;
//         Public Decimal dcgPastRevenue=0.0;
//         Public string strategicAttribute='';
//         Public string iotgStrategicAttribute='';
//     }
//    //This below method is used to populate the PSS_PartnerName_Offering_txt__c with partner name,intel admin,view offering. 
//      public static void populateSearchableFields(List<ArdiraSurvey__Survey_Result__c> solutionList, Map<Id, ArdiraSurvey__Survey_Result__c> oldMap){
//         List<ArdiraSurvey__Survey_Result__c> updateSolutionList = new List<ArdiraSurvey__Survey_Result__c>();
//         for(ArdiraSurvey__Survey_Result__c res : solutionList){
//             if(res.PSS_Partner_Name__c !=null ||res.PSS_Intel_Admin_Id__c != null || res.PSS_View_Offering_Txt__c!=null){
//                 updateSolutionList.add(res);
//             }
//         }
//         if(!updateSolutionList.isEmpty()){
//             updateSearchableFields(updateSolutionList,oldMap);
//         }
//     }
//     public static void updateSearchableFields(List<ArdiraSurvey__Survey_Result__c> solutionList, Map<Id, ArdiraSurvey__Survey_Result__c> oldMap){
//         Map<String,ArdiraSurvey__Survey_Result__c> adminSurveyMap= new Map<String,ArdiraSurvey__Survey_Result__c>();
//         Map<string,string> solutionPartnerOfferingNameTxt = new map<string,string>();
//         for(ArdiraSurvey__Survey_Result__c res : solutionList){
//             String completeString = '';
//             if(oldMap != null && !oldMap.isEmpty()){
//                 if((res.PSS_Partner_Name__c != oldMap.get(res.id).PSS_Partner_Name__c) || (res.PSS_Intel_Admin_Id__c != oldMap.get(res.id).PSS_Intel_Admin_Id__c) 
//                     || (res.PSS_View_Offering_Txt__c != oldMap.get(res.id).PSS_View_Offering_Txt__c) ) {
//                 		String partnerName = (res.PSS_Partner_Name__c != null )? res.PSS_Partner_Name__c  : '' ;
//                         adminSurveyMap.put(res.PSS_Intel_Admin_Id__c,res);
                        
//                   String viewOffering = ( res.PSS_View_Offering_Txt__c != null)? res.PSS_View_Offering_Txt__c : '';
//                   completeString = partnerName +';'+ viewOffering;
//             	}
//             }
//             else{
//                 String partnerName = (res.PSS_Partner_Name__c != null)? res.PSS_Partner_Name__c  : '' ;
//                 String viewOffering = ( res.PSS_View_Offering_Txt__c != null)? res.PSS_View_Offering_Txt__c : '';
//                 adminSurveyMap.put(res.PSS_Intel_Admin_Id__c,res);
//                 completeString = partnerName +';'+ viewOffering;               
//             }
           
//             if(!String.isBlank(completeString)){
//                 res.PSS_PartnerName_Offering_txt__c = completeString;
//                 solutionPartnerOfferingNameTxt.put(res.id,res.PSS_PartnerName_Offering_txt__c);
//             }
            
//         }
//         Map<string,string> userIdNameMap = new Map<string,string>();
        
//         if(!adminSurveyMap.keyset().isEmpty()){
//             List<user> userList =[select id,name from user where id in: adminSurveyMap.keySet() And IsActive = True];
//             for(User u: userList){
//                 userIdNameMap.put(u.id,u.name);
//             }
            
//         }
//         if(!userIdNameMap.isEmpty() && !solutionPartnerOfferingNameTxt.isEmpty()){
//         	for(ArdiraSurvey__Survey_Result__c res : solutionList){
//             	if(res.PSS_Intel_Admin_Id__c!= null){
//                		res.PSS_PartnerName_Offering_txt__c = solutionPartnerOfferingNameTxt.get(res.id) +';'+ userIdNameMap.get(res.PSS_Intel_Admin_Id__c);
//             	}
                
//         	} 
//         }
//     }
    
}