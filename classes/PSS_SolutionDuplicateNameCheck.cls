/****************************************************************************************************************************************
* Class Name  : PSS_SolutionDuplicateNameCheck
* Version     : 1.0 
* Created Date: 24-08-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Krishna Ch              24/08/2021                      Validation class to validate the duplicate name check in solutions.
*****************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
global class PSS_SolutionDuplicateNameCheck //implements ArdiraSurvey.SurveyResponseValidationInterfaceV2 
{
    
    //Below method used to validate the duplciate name check in solutions
    //Parameters are survey id,solution id,question id,Soultion Name.
    /*global String validateQuestionResponseV2(Id surveyId, Id surveyResultId, Id questionId, String response) {
        
        Set<String> existingSolutions = new Set<String>();
        Map<String, Object> result = new Map<String, Object>();
        result.put('errorCode', 0);
        result.put('errorMessage','Success');
        String warningMessageToast = System.Label.PSS_Solution_Name_warning_msg;
        String errorMessageToast = System.Label.PSS_solution_Name_error_msg;
        List<ArdiraSurvey__Survey_Result__c> solList = new List<ArdiraSurvey__Survey_Result__c>();
        Set<id> solAccIds = new Set<id>();
        ArdiraSurvey__Survey_Result__c solutionResult = new ArdiraSurvey__Survey_Result__c();
        //Querying the current solution record based on the solution id which is coming from parameter.
        if(surveyResultId != NULL && Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()){
            solList  =[SELECT Id,PSS_Proposal_Name_Txt__c,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c FROM ArdiraSurvey__Survey_Result__c where id =: surveyResultId];
        }
        //checking the current solution record OPID and Partner Account id and keeping those values in one set.
        if(!solList.isempty()){
        for(ArdiraSurvey__Survey_Result__c sol : solList){
            if(sol.PSS_OPID_Account_Id__c != NULL){
                solAccIds.add(sol.PSS_OPID_Account_Id__c);
            }
            if(sol.PSS_Partner_Account_Id__c != NULL){
                solAccIds.add(sol.PSS_Partner_Account_Id__c);
            }
        }
        }
        
        Set<id> oldSolNameAccIds= new Set<Id>();
        //checking the existing solution with same name and keeping OPIDs and partner ids of those solutions in one set.
        if(surveyResultId != NULL && Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()) {
            for(ArdiraSurvey__Survey_Result__c sResult : [Select Id,PSS_Proposal_Name_Txt__c,PSS_OPID_Account_Id__c,
                                                          PSS_OPID_Account_Id__r.Name, PSS_Partner_Account_Id__c,
                                                          PSS_Partner_Account_Id__r.name FROM ArdiraSurvey__Survey_Result__c 
                                                          WHERE PSS_Proposal_Name_Txt__c = :response.toLowerCase() AND  
                                                          Id !=: surveyResultId]){
                                                              
                                                              if(sResult.PSS_OPID_Account_Id__c != NUll ) {
                                                                  oldSolNameAccIds.add(sResult.PSS_OPID_Account_Id__c);
                                                                  
                                                              } 
                                                              if(sResult.PSS_Partner_Account_Id__c != NULL){
                                                                  oldSolNameAccIds.add(sResult.PSS_Partner_Account_Id__c);                                                      
                                                              }
                                                              if(sResult.PSS_Proposal_Name_Txt__c != NULL){                                                     
                                                                  existingSolutions.add(sResult.PSS_Proposal_Name_Txt__c.toLowerCase());
                                                              }                                                           
                                                          }
        }
        //Belowcondition will execute if there is any solution with the same name under same partner and will through error message.
        if (!oldSolNameAccIds.isempty() && ((solList[0].PSS_OPID_Account_Id__c != Null && oldSolNameAccIds.contains(solList[0].PSS_OPID_Account_Id__c) )|| 
                                     (solList[0].PSS_Partner_Account_Id__c != Null && oldSolNameAccIds.contains(solList[0].PSS_Partner_Account_Id__c)))) {
            result.put('errorCode', 1);
            result.put('errorMessage', errorMessageToast);
            return JSON.serialize(result);
            
        }
        //Belowcondition will execute if there is any solution with the same name under different partner and will through warning message.
        else if(!existingSolutions.isempty() && existingSolutions.contains(response.toLowerCase())){
            result.put('errorCode', 3);
            result.put('errorMessage', warningMessageToast);
            return JSON.serialize(result);
        }
       //Belowcondition will execute for unique solution names.
        else{
            result.put('errorCode', 0);
            result.put('errorMessage','Success');
            return JSON.serialize(result);
        }
        
    }*/
}