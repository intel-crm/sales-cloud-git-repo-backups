/*************************************************************************************************************************************************************************
* Class Name  : PSS_QuestionResult_TriggerHelper
* Version     : 1.0 
* Created Date: 07/04/2022
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Krishna ch              M-01    : Original version       6/30/2022                         Helper class for the question result Trigger
**************************************************************************************************************************************************************************/
public without sharing class PSS_QuestionResult_TriggerHelper {
    
     /**
	* @description - method to update the solution reporing fields with respective question results using trigger.
	* @param - aqrList(list of question results list),oldMap,newMap,isInsert,isUpdate
	* This method is called from PSS_QuestionResultTrigger_TriggerHandler class
	**/
    
    /*public static void solutionUpdate(List<ArdiraSurvey__Question_Result__c> aqrList){
        List<String> questionsUniqueKey=new List<String>();
        Set<String> questionsUniqueKeyChanged=new Set<String>();
        Set<Id> solIds = new Set<Id>();
        Set<string> questionIds = new Set<String>();
        Map<string,Id> solQuestionIDsMap = new Map<string,Id>();
        //Fetching All API name of solutions and its related Questions'unique key' from Custom metadata 
        List<PSS_Question_Fields__mdt> fields=[Select PSS_FieldAPI__c,Value__c from PSS_Question_Fields__mdt where Value__c != null]; 
        
        
        List<ArdiraSurvey__Survey_Result__c> solListToUpdate = New List<ArdiraSurvey__Survey_Result__c>();
        List<ArdiraSurvey__Survey_Result__c> solListToUpdateFinal = New List<ArdiraSurvey__Survey_Result__c>();
        
        //Creating list for all the questions unique key for all questions which needs to be displayed
        for(PSS_Question_Fields__mdt f:fields){
            questionsUniqueKey.add(f.Value__c);
        }
        if( !aqrList.isempty()){
            
            for(ArdiraSurvey__Question_Result__c aqr : aqrList){
                //system.debug('new answer--->'+aqr.ArdiraSurvey__Answer_Text__c);
                //system.debug('old answer--->'+oldMap.get(aqr.id).ArdiraSurvey__Answer_Text__c);
                //if((newMap.get(aqr.id).ArdiraSurvey__Answer_Text__c) != (oldMap.get(aqr.id).ArdiraSurvey__Answer_Text__c)){
                questionIds.add(aqr.ArdiraSurvey__Question__c);
                    system.debug('question ids inside--->'+questionIds);
                solQuestionIDsMap.put(aqr.ArdiraSurvey__Question__c,aqr.ArdiraSurvey__Survey_Result__c); 
               // }
            }
            if(!questionIds.isempty() && !solQuestionIDsMap.isempty()){
                for(ArdiraSurvey__Question__c qs : [select id,Name,PSS_Question_Unique_Key_Txt__c from ArdiraSurvey__Question__c where Id IN : questionIds AND PSS_Question_Unique_Key_Txt__c != NULL]){
                    if(questionsUniqueKey.contains(qs.PSS_Question_Unique_Key_Txt__c)){
                        solIds.add(solQuestionIDsMap.get(qs.Id));
                        questionsUniqueKeyChanged.add(qs.PSS_Question_Unique_Key_Txt__c);
                    }
                    
                }
            }
            
        }
      
        if(!solIds.isempty()){
            
            solListToUpdate = [Select id,name,PSS_Proposal_Name_Txt__c,PSS_PrimaryUseCase_txt__c,PSS_Channel_Target_txt__c,
                               PSS_Cloud_Service_Provider_txt__c,PSS_OS_details_txt__c,PSS_Geographies_to_expand_txt__c,PSS_AdditionalUseCases_txt__c,
                               PSS_Primary_Contact_Email_txt__c,PSS_Geographies_Deployed_In_txt__c,PSS_Geographies_Available_In_txt__c,
                               PSS_PrimaryIndustry_txt__c,PSS_Ran_on_Virtual_Machine_txt__c,PSS_AdditionalIndustries_txt__c,
                               PSS_Primary_Contact_txt__c,PSS_Connectivity_Details_txt__c,PSS_Unique_End_Customers_txt__c,
                               PSS_Offer_Description_txt__c,PSS_Unique_Facilities_txt__c, (Select ArdiraSurvey__Question_Text__c,ArdiraSurvey__Answer_Text__c,
                                                                                           ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c,ArdiraSurvey__Answer_Rich_Text__c
                                                                                           from ArdiraSurvey__Question_Results__r 
                                                                                           where ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c 
                                                                                           IN :questionsUniqueKeyChanged) from ArdiraSurvey__Survey_Result__c where Id IN :solIds ];
            
            for(ArdiraSurvey__Survey_Result__c asr : solListToUpdate){
                for(PSS_Question_Fields__mdt f:fields){
                    for(ArdiraSurvey__Question_Result__c aqr:asr.ArdiraSurvey__Question_Results__r){
                        if(f.Value__c == aqr.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c){
                            if(String.isNotBlank(aqr.ArdiraSurvey__Answer_Rich_Text__c)){
                                asr.put(f.PSS_FieldAPI__c,aqr.ArdiraSurvey__Answer_Rich_Text__c);
                                if(!solListToUpdateFinal.contains(asr)){
                                    solListToUpdateFinal.add(asr);
                                }
                                break;
                            }
                            else{
                                asr.put(f.PSS_FieldAPI__c,aqr.ArdiraSurvey__Answer_Text__c);
                                if(!solListToUpdateFinal.contains(asr)){
                                    solListToUpdateFinal.add(asr);
                                }
                                break;
                                
                            }
                        }
                    }
                    
                }
                
            }
            //questionResultTriggerFlag is to stop the solution trigger logic on question results update.
            if(!solListToUpdateFinal.isempty()){
                PSS_StaticConstants.questionResultTriggerFlag = False;
                update solListToUpdateFinal;
                PSS_StaticConstants.questionResultTriggerFlag = True;
            }
            
            
        }
    }*/
    
    
    
}