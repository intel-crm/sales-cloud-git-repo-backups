/*-------------------------------------------------------------------------------------------
Apex Class  : Core_AcceptReject_Lead_LexController
Version     : 1.0 
Created Date: 11 JUNE 2018
Function    : Apex class for lead accept/reject lightning component
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            11/06/2018              Original Version
* Bishal Singh				11/04/2024				Modified
-------------------------------------------------------------------------------------------*/

public without sharing class Core_AcceptReject_Lead_LexController {
    
    @auraEnabled
    public static String updateLead(String leadId){
        String alertMsg = 'You have successfully accepted the Lead.';
        Lead leadUpdate = [select Id, OwnerId, RecordTypeId, Core_Lead_State__c, Core_Rejection_Comments__c, Core_Rejection__c,
                           Core_Partner_Lead_Owner__c from Lead where Id =: leadId];
        
        String recTypeName = [select Id, Name from RecordType where Id =: leadUpdate.RecordTypeId].Name;
        
        if(recTypeName.equalsIgnoreCase('Lead')){
            if(leadUpdate.OwnerId <> UserInfo.getUserId()){
                alertMsg = 'Please take the ownership of the Lead before Accepting.';
            }else{
                leadUpdate.Core_Lead_State__c = 'Accepted'; 
                leadUpdate.Core_Rejection_Comments__c = null; 
                leadUpdate.Core_Rejection__c = null;
                update leadUpdate;
            }
        }else if(recTypeName.equalsIgnoreCase('Partner Lead')){
            leadUpdate.Status = 'Partner Qualified Lead'; 
            leadUpdate.Core_Lead_State__c = 'Accepted'; 
            leadUpdate.Core_Partner_Lead_Owner__c = UserInfo.getUserId(); 
            leadUpdate.Core_Rejection_Comments__c = null; 
            leadUpdate.Core_Rejection__c = null;
            update leadUpdate;
        }else if(recTypeName.equalsIgnoreCase('Prospect')){
            if(leadUpdate.OwnerId <> UserInfo.getUserId()){
                alertMsg = 'Please take the ownership of the Prospect before Accepting.';
            }else{
                leadUpdate.Core_Lead_State__c = 'Accepted'; 
                leadUpdate.Core_Rejection_Comments__c = null; 
                leadUpdate.Core_Rejection__c = null;
                update leadUpdate;
            }
        }
        return alertMsg;
    }
    
    
    //To update lead status to 'Tele Qualified Lead' through Convert to Lead button link on Lead detailPage added by Rajesh
    @auraEnabled
    public static void updateTeleQualifiedLead(String leadId){
        lead ld=new lead(Id=leadId,Status='Tele Qualified Lead');
        update ld;
    }
    
    @auraEnabled
    public static void updateToLead(Lead leadObj){
        Lead leadToUpdate = new Lead();
        leadToUpdate.Id = leadObj.Id;
        leadToUpdate.Core_Rejection__c = leadObj.Core_Rejection__c;
        leadToUpdate.Core_Rejection_Comments__c = leadObj.Core_Rejection_Comments__c;
        leadToUpdate.Core_Lead_State__c = 'Rejected';
        update leadToUpdate;
    }
    
    @auraEnabled
    public static picklistMsgWrapper getPicklistValues(String leadId, String objectType, String fieldName){
        picklistMsgWrapper picklistWrap = new picklistMsgWrapper();
        Lead leadUpdate = [select Id, OwnerId, RecordTypeId, Core_Rejection__c, Core_Rejection_Comments__c from Lead where Id =: leadId];
        String recTypeName = [select Id, DeveloperName from RecordType where Id =: leadUpdate.RecordTypeId].DeveloperName;
        if(recTypeName.equalsIgnoreCase('Lead')){
            if(leadUpdate.OwnerId == UserInfo.getUserId()){
                picklistWrap.pickListValueList = fetchPicklistValuesByRecType(objectType, fieldName, leadUpdate.RecordTypeId);
                picklistWrap.message = 'success';
            }else{
                picklistWrap.pickListValueList = null;
                picklistWrap.message = 'Please take the ownership of the Lead before Rejecting.';
            }
        }else if(recTypeName.equalsIgnoreCase('Partner_Lead')){
            picklistWrap.pickListValueList = fetchPicklistValuesByRecType(objectType, fieldName, leadUpdate.RecordTypeId);
            picklistWrap.message = 'success';
        }else if(recTypeName.equalsIgnoreCase('Prospect')){
            if(leadUpdate.OwnerId == UserInfo.getUserId()){
                picklistWrap.pickListValueList = fetchPicklistValuesByRecType(objectType, fieldName, leadUpdate.RecordTypeId);
                picklistWrap.message = 'success';
            }else{
                picklistWrap.pickListValueList = null;
                picklistWrap.message = 'Please take the ownership of the Prospect before Rejecting.';
            }
        }
        picklistWrap.leadObj = leadUpdate;
        return picklistWrap;
    }
    
    /************************************************************************************************************
    *Method Name : fetchPicklistValuesByRecType
    *Created Date: 04/11/2024
    *Modified: Bishal Singh
    *Modification : Updated the callout, previously using session id it's been move to Named Credentials.
    ************************************************************************************************************/
    public static List<String> fetchPicklistValuesByRecType(String objectType, String fieldName, String recordTypeId) {
        List<String> result = new List<String>();
        
        if (String.isEmpty(objectType) || String.isEmpty(fieldName) || String.isEmpty(recordTypeId)) {
            return result;
        }
        
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            request.setEndpoint('callout:PicklistNamedCredential/' + objectType + '/picklist-values/' + recordTypeId + '/' + fieldName);
            request.setHeader('Content-Type', 'application/json; charset=UTF-8');
            request.setMethod('GET');
            
            HttpResponse res = http.send(request);
            
            if (res.getStatusCode() != 200) {
                throw new AuraHandledException('HTTP error: ' + res.getStatusCode() + ' - ' + res.getStatus());
            }

            Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (root.containsKey('values')) {
                fetchPicklistFromRoot(result, root);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching picklist values: ' + e.getMessage());
        }
        return result;
    }
    
    /************************************************************************************************************
    *Method Name : fetchPicklistFromRoot
    *Created Date: 05/11/2024
    *Author: Bishal Singh
    *Description : Retrieve picklist values from root
    ************************************************************************************************************/
    private static void fetchPicklistFromRoot(List<String> result,Map<String, Object> root){
        List<Object> pValues = (List<Object>) root.get('values');
        for (Object pValue : pValues) {
            if (pValue instanceof Map<String, Object>) {
                Map<String, Object> pValueMap = (Map<String, Object>) pValue;
                String value = (String) pValueMap.get('value');
                if (value != null) {
                    result.add(value);
                }
            }
        }
    }
    
    public class picklistMsgWrapper{
        @auraEnabled
        public Lead leadObj{get;set;}
        @auraEnabled
        public List<String> pickListValueList{get;set;}
        @auraEnabled
        public String message{get;set;}
    }
}