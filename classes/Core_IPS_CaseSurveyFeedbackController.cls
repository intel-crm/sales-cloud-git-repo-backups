/****************************************************************************************************
*Class Name:  Core_IPS_CaseSurveyFeedbackController
*Description:  Apex Controller to fetch Survey Feedback curresponding to a Case
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------       
* 
* Sneha                      06/03/2020                    Created for US549642 LEX: create case : Survey feature for each Case
****************************************************************************************************/
public with sharing class Core_IPS_CaseSurveyFeedbackController {

   @AuraEnabled(cacheable = true)
    public static List<Core_IPS_Response__c> getSurveyFeedbackList(String caseId){

        return [SELECT Id, Core_IPS_Case__c,Core_IPS_Answer__c,CreatedDate, Core_IPS_Question__c 
                FROM Core_IPS_Response__c 
                WHERE Core_IPS_Question_Master__r.recordtype.Name  = 'Survey' AND Core_IPS_Case__c =: caseId];        
    }

}