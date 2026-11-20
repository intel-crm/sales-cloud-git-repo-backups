/***************************************************************************************************
Apex Class Name:  Core_IPS_MAG_Response_LEX_Controller
US no          :  US943887
Version        :  1.0 
Created Date   :  25/03/2021 
Function       :  Controller to get records which will be used to diplay in MINDS section of Case
Modification Log :
* Developer                     Date                    Description
* ----------------------------------------------------------------------------                 
* Chandrashekar                 25/03/2021               Created
****************************************************************************************************/
public with sharing class Core_IPS_MAG_Response_LEX_Controller {
    @AuraEnabled(cacheable = true)
    public static List<Core_IPS_GEC_Details__c> getMagResponses(String caseId) {
        List<Core_IPS_GEC_Details__c> responseList;
        if(Core_IPS_GEC_Details__c.SObjectType.getDescribe().isQueryable()){
            responseList = [SELECT Core_IPS_GEC_Question1__c, Core_IPS_GEC_Question2__c, LastModifiedBy.Name, CreatedDate FROM Core_IPS_GEC_Details__c WHERE Core_IPS_Case__c =: caseId];
        }
        return responseList;
    }
    @AuraEnabled(cacheable = true)
    public static List<Case> getEnvironmentalDetailResponse(String caseId) {
        List<Case> responseList;
        String recordType = 'Core_IPS_MAG_Question';
        String query1 = 'SELECT id, (SELECT Core_IPS_Question_Master__r.RecordType.DeveloperName, Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__c, Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__r.Core_IPS_Question_Text__c, Core_IPS_Question__c, Core_IPS_Answer__c, LastModifiedBy.Name, CreatedDate FROM Core_IPS_Responses__r WHERE Core_IPS_Question_Master__r.RecordType.DeveloperName =:recordType) FROM Case WHERE id =: caseId';
        responseList = Database.query(query1);
        return responseList;
    }
}