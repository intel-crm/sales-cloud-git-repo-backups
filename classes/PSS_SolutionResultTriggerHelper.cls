/**************************************************************************************
Apex Class Name : PSS_SolutionResultTriggerHelper
Version     : 1.0 
Created Date: 12th Feb, 2021
Description : Trigger handler for PMP_SurveyResultTrigger
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shahrukh                  12/02/2021               Original Version
*************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public without sharing class PSS_SolutionResultTriggerHelper{
    /**
    * @description : Method to update convert offering checkbox on ardira survey result
    * @param List,Map
    * @return void
    **/
    /*public static void convertSolutionToOffering(List<ArdiraSurvey__Survey_Result__c> solList, Map<Id, ArdiraSurvey__Survey_Result__c> oldMap) {
        Set<Id> userIds = new Set<Id>();
        Map<Id, Id> userMap = new Map<Id, Id>();
        Set<Id> finalUserIds = new Set<Id>();
        Map<Id, Id> finalUserIdCompId = new Map<Id, Id>(); //to stamp company id on the survey response
    
        // Get created by Id and store it in a set if status is changed to completed
        findChangedToCompleted(solList, oldMap, userIds);
    
        // Getting one partner Id if user has it populated on user object
        getUserPartnerIds(userIds, userMap);
    
        // Getting company benefit type from marketing profile info which is published under this one partner Id
        getCompanyBenefitType(userMap, finalUserIds, finalUserIdCompId);
    
        // Changing the convert solution indicator to true based on finalUserIds
        updateSolutionCompanyIds(solList, finalUserIds, finalUserIdCompId);
    }
    
    private static void findChangedToCompleted(List<ArdiraSurvey__Survey_Result__c> solList, Map<Id, ArdiraSurvey__Survey_Result__c> oldMap, Set<Id> userIds) {
        for (ArdiraSurvey__Survey_Result__c sol : solList) {
            if ((oldMap.get(sol.Id).PSS_Partner_Solution_Lifecycle_Status_Nm__c != sol.PSS_Partner_Solution_Lifecycle_Status_Nm__c)
                    && (sol.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.COMPLETED || sol.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.ADMIN_REVIEW)) {
                userIds.add(sol.CreatedById);
            }
        }
    }
    
    private static void getUserPartnerIds(Set<Id> userIds, Map<Id, Id> userMap) {
        if (!userIds.isEmpty()) {
            for (User u : [SELECT Id, Core_IPA_One_Partner_Id__c FROM User WHERE Id IN :userIds AND Core_IPA_One_Partner_Id__c != null]) {
                userMap.put(u.Core_IPA_One_Partner_Id__c, u.Id);
            }
        }
    }
    
    private static void getCompanyBenefitType(Map<Id, Id> userMap, Set<Id> finalUserIds, Map<Id, Id> finalUserIdCompId) {
        if (!userMap.isEmpty() && Schema.sObjectType.PMP_Company__c.isAccessible()) {
            for (PMP_Company__c com : [SELECT Id, PMP_One_Partner_ID__c FROM PMP_Company__c WHERE PMP_Is_Published_Ind__c = true AND PMP_Partner_Benefit_Type__c = :PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED AND PMP_One_Partner_ID__c IN :userMap.keySet() AND PMP_Benefit_Update_Ind__c = false]) {
                finalUserIds.add(userMap.get(com.PMP_One_Partner_ID__c));
                finalUserIdCompId.put(userMap.get(com.PMP_One_Partner_ID__c), com.Id);
            }
        }
    }
    
    private static void updateSolutionCompanyIds(List<ArdiraSurvey__Survey_Result__c> solList, Set<Id> finalUserIds, Map<Id, Id> finalUserIdCompId) {
        for (ArdiraSurvey__Survey_Result__c sol : solList) {
            if (finalUserIds.contains(sol.CreatedById)) {
                sol.PSS_Company_Id__c = finalUserIdCompId.get(sol.CreatedById);
            }
        }
    }*/
    

}