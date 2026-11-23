//IPA2.0: US-TWC729-7976
global class CustomValidation //implements ArdiraSurvey.SurveyResponseValidationInterface
{
	/*global String validateQuestionResponse(Id surveyId, Id questionId, String response){

		system.debug('surveyId:::'+surveyId);
		system.debug('questionId:::'+questionId);
		system.debug('response:::'+response);
    
		Set<String> existingSolutions = new Set<String>();*/
		/*List<ArdiraSurvey__Survey_Result__c> solutionResultList = new List<ArdiraSurvey__Survey_Result__c>();
		ArdiraSurvey__Survey_Result__c solutionResult = new ArdiraSurvey__Survey_Result__c();
        map<Id,string> solutionMap = new map<Id,string>();

        solutionResultList = [SELECT Id,Name,PSS_Proposal_Name_Txt__c,PSS_Partner_Account_Id__c,PSS_Partner_Account_Id__r.name 
		                        FROM ArdiraSurvey__Survey_Result__c WHERE Id=:questionId];

		if(!solutionResultList.isEmpty()){
			solutionResult = solutionResultList[0];
            system.debug('solutionResult ::: '+solutionResult.Id);
		}

            for(ArdiraSurvey__Survey_Result__c sResult : [Select Id,PSS_Proposal_Name_Txt__c,PSS_Partner_Account_Id__c,PSS_Partner_Account_Id__r.name FROM ArdiraSurvey__Survey_Result__c 
                                                            WHERE PSS_Proposal_Name_Txt__c = :solutionResult.PSS_Proposal_Name_Txt__c AND  Id !=: solutionResult.Id]){
            			
                         system.debug('sResult.PSS_Proposal_Name_Txt__c:::'+sResult.PSS_Proposal_Name_Txt__c);
                         system.debug('sResult.PSS_Partner_Account_Id__c:::'+sResult.PSS_Partner_Account_Id__c);                                        
                     	if(String.isNotBlank(sResult.PSS_Proposal_Name_Txt__c)){
                         existingSolutions.add(sResult.PSS_Proposal_Name_Txt__c.toLowerCase());
                         solutionMap.put(sResult.PSS_Partner_Account_Id__c,sResult.PSS_Proposal_Name_Txt__c);
                     }
                 }
        
                if(solutionMap.containsKey(solutionResult.PSS_Partner_Account_Id__c)){
                   // existingSolutions.add(sResult.PSS_Proposal_Name_Txt__c.toLowerCase());
                    // duplicate solution under same partner
                    return 'Entered Solution name already exist in same account.'+' '+solutionResult.PSS_Partner_Account_Id__r.name;
                } 

                else if(String.isNotBlank(solutionResult.PSS_Proposal_Name_Txt__c) && existingSolutions.contains(solutionResult.PSS_Proposal_Name_Txt__c)){
                   // system.debug('sResult.PSS_Proposal_Name_Txt__c:::'+sResult.PSS_Proposal_Name_Txt__c);      
                    //existingSolutions.add(sResult.PSS_Proposal_Name_Txt__c.toLowerCase());
                    return 'Entered Solution name already exist in all solutions.';// duplicate solution exist
                } 
                else{
                	return 'Success';
                } */ 
        
       /*for (ArdiraSurvey__Survey_Result__c solutionResult : [SELECT Id,Name,PSS_Proposal_Name_Txt__c,PSS_Partner_Account_Id__c FROM ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c =:response ]){
		
			if(String.isNotBlank(solutionResult.PSS_Proposal_Name_Txt__c)){
				existingSolutions.add(solutionResult.PSS_Proposal_Name_Txt__c.toLowerCase());
			}
		}
		if (existingSolutions.contains(response.toLowerCase())) {
			return 'Entered Solution name already exist.';
		} 
		else {
			return 'Success';
		} 
	}*/
}